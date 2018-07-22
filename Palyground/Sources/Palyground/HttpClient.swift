//
// Created by mike on 2018/07/16.
//

import Foundation
import NIO
import NIOHTTP1
import NIOOpenSSL
import RxSwift

typealias Ssl = NIOOpenSSL.SSLContext

class HttpClient {

    let url: URL

    let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)

    init(url: URL) {
        self.url = url
    }

    func get() -> Single<String> {
        return Single<String>.create { single in
            NSLog("configuring client")
            let tlsConfiguration = TLSConfiguration.forClient()
            let sslContext: Ssl = try! Ssl(configuration: tlsConfiguration)
            let bridge = Bridge.onSuccess { string in
                single(.success(string))
            }.onFailure({ error in single(.error(error)) })
            let clientHandler = HttpClientHandler(bridge)
            NSLog("initializing bootstrap")
            let clientBootstrap = ClientBootstrap(group: self.eventLoopGroup)
                    .channelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
                    .channelInitializer(self.initializeChannel(sslContext: sslContext, clientHandler: clientHandler))
            NSLog("connecting server")
            guard let future = self.connect(bootstrap: clientBootstrap) else {
                NSLog("cannot connect to url: \(self.url)")
                return Disposables.create()
            }
            NSLog("getting hostname")
            guard let host = self.host() else {
                NSLog("cannot determine host of \(self.url)")
                return Disposables.create()
            }
            NSLog("preparing request")
            let eventLoopFuture: EventLoopFuture<Void> = future.then { channel in
                NSLog("channel: \(channel)[active:\(channel.isActive),writable:\(channel.isWritable)]")
                var httpHeadPart = HTTPRequestHead(version: HTTPVersion(major: 1, minor: 1), method: HTTPMethod.GET, uri: self.url.absoluteString)
                NSLog("publishing request")
                httpHeadPart.headers = HTTPHeaders([
                    ("Host", host),
                    ("Connection", "close"),
                    ("Accept-Encoding", "gzip"),
                    ("User-Agent", "swift-nio"),
                    ("Accept", "application/json")
                ])
                NSLog("writing header")
                let fu = channel.writeAndFlush(HTTPClientRequestPart.head(httpHeadPart))
                NSLog("writing finished")
                return fu
            }
            NSLog("request has been published")
            return Disposables.create {
                eventLoopFuture
            }
        }
    }

    func connect(bootstrap: ClientBootstrap) -> EventLoopFuture<Channel>? {
        if let host = url.host,
           let port = port() {
            return bootstrap.connect(host: host, port: port)
        } else {
            return nil
        }
    }

    func port() -> Int? {
        if url.isFileURL {
            return nil
        }
        if let port = url.port {
            return port
        } else if let scheme = url.scheme {
            if scheme == "https" {
                return 443
            } else {
                return 80
            }
        }
        return 80
    }

    func host() -> String? {
        if let host = url.host {
            return host
        } else {
            return nil
        }
    }

    private func initializeChannel(sslContext: Ssl, clientHandler: HttpClientHandler) -> (Channel) -> EventLoopFuture<Void> {
        return { channel in
            let pipeline: ChannelPipeline = channel.pipeline
            let sslHandler = try! OpenSSLClientHandler(context: sslContext)
            _ = pipeline.add(handler: LoggingHandler("internet", "ssl-handler"))
            _ = pipeline.add(name: "ssl-handler", handler: sslHandler)
            _ = pipeline.add(handler: LoggingHandler("ssl-handler", "http-codecs"))
            _ = pipeline.addHTTPClientHandlers()
            _ = pipeline.add(handler: LoggingHandler("http-codecs", "client-handler"))
            return pipeline.add(name: "client-handler", handler: clientHandler, first: false)
        }
    }
}

class Bridge {
    let onSuccess: (String) -> ()
    let onFailure: (Error) -> ()

    private init(_ onSuccess: @escaping (String) -> (), _ onFailure: @escaping (Error) -> ()) {
        self.onSuccess = onSuccess
        self.onFailure = onFailure
    }

    static func onSuccess(_ handle: @escaping (String) -> ()) -> Builder {
        return Builder(handle)
    }

    class Builder {
        let onSuccess: (String) -> ()

        init(_ onSuccess: @escaping (String) -> ()) {
            self.onSuccess = onSuccess
        }

        func onFailure(_ handle: @escaping (Error) -> ()) -> Bridge {
            return Bridge(onSuccess, handle)
        }
    }
}

class LoggingHandler: ChannelInboundHandler {

    typealias OutboundIn = Any
    typealias OutboundOut = Any

    typealias InboundIn = Any
    typealias InboundOut = Any

    let head: String
    let tail: String

    init(_ head: String, _ tail: String) {
        self.head = head
        self.tail = tail
    }

    func channelRead(ctx: ChannelHandlerContext, data: NIOAny) {
        NSLog("reading from: \(head) to: \(tail)")
        ctx.fireChannelRead(data)
    }

    func channelReadComplete(ctx: ChannelHandlerContext) {
        NSLog("read complete from: \(head) to: \(tail)")
        ctx.fireChannelReadComplete()
    }

    func errorCaught(ctx: ChannelHandlerContext, error: Error) {
        NSLog("error[\(error)] from: \(head) to: \(tail)")
        ctx.fireErrorCaught(error)
    }

    func write(ctx: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {
        NSLog("writing from: \(tail) to: \(head)")
        ctx.write(data, promise: promise)
    }

    func flush(ctx: ChannelHandlerContext) {
        NSLog("flushing from: \(tail) to: \(head)")
        ctx.flush()
    }
}

class HttpClientHandler: ChannelInboundHandler {

    enum Error: Swift.Error {
        case notInitialized
    }

    typealias InboundIn = HTTPClientResponsePart

    private var count: Int = 0
    private var bodies: [String] = []

    let single: Bridge

    init(_ single: Bridge) {
        self.single = single
    }

    private func body() {
        single.onSuccess(bodies.joined(separator: ""))
    }

    func channelRead(ctx: ChannelHandlerContext, data: NIOAny) {
        NSLog("channelRead[\(count + 1)]")
        count += 1
        let httpResponsePart = unwrapInboundIn(data)
        switch httpResponsePart {
        case .head(let httpResponseHeader):
            NSLog("[\(count)]response header:")
            for (name, value) in httpResponseHeader.headers {
                NSLog("\(name): \(value)")
            }
        case .body(var buffer):
            if let body = buffer.readString(length: buffer.size) {
                bodies.append(body)
                NSLog("[\(count)]response body:\n \(body)")
            } else {
                NSLog("response body:\n empty")
            }
        case .end(let httpHeaders):
            if let headers = httpHeaders {
                NSLog("[\(count)](end)response header:")
                for (name, value) in headers {
                    NSLog("\(name): \(value)")
                }
            } else {
                NSLog("[\(count)]response end.\n")
            }
        }
    }

    func channelReadComplete(ctx: ChannelHandlerContext) {
        NSLog("channelReadComplete")
        ctx.close()
        body()
    }

    func errorCaught(ctx: ChannelHandlerContext, error: Error) {
        NSLog("error caught: \(error)")
        ctx.channel.close()
        single.onFailure(error)
    }
}

extension ByteBuffer {
    var size: Int {
        return self.writerIndex - self.readerIndex
    }
}
