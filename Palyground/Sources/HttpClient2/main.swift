import NIO
import NIOHTTP1
import NIOOpenSSL

private final class HTTPResponseHandler: ChannelInboundHandler {

    let promise: EventLoopPromise<Void>

    var canFinishPromise: EventLoopPromise<Void>?

    init(_ promise: EventLoopPromise<Void>) {
        self.promise = promise
    }

    typealias InboundIn = HTTPClientResponsePart

    func channelRegistered(ctx: ChannelHandlerContext) {
        print("=== channel registered ===")
        let p: EventLoopPromise<Void> = ctx.eventLoop.newPromise()
        let future = p.futureResult
        future.whenSuccess { _ in self.promise.succeed(result: ()) }
        self.canFinishPromise = p
    }

    func channelRead(ctx: ChannelHandlerContext, data: NIOAny) {
        let httpResponsePart = unwrapInboundIn(data)
        switch httpResponsePart {
        case .head(let httpResponseHeader):
            print("\(httpResponseHeader.version) \(httpResponseHeader.status.code) \(httpResponseHeader.status.reasonPhrase)")
            for (name, value) in httpResponseHeader.headers {
                print("\(name): \(value)")
            }
        case .body(var byteBuffer):
            if let responseBody = byteBuffer.readString(length: byteBuffer.readableBytes) {
                print(responseBody)
            }
        case .end(_):
            canFinishPromise?.succeed(result: ())
        }
    }

    func channelReadComplete(ctx: ChannelHandlerContext) {
        print("=== channel read complete ===")
    }

    func errorCaught(ctx: ChannelHandlerContext, error: Error) {
        print("Error: ", error)
        canFinishPromise?.succeed(result: ())
    }
}

let url = "https://api.github.com/search/repositories?q=netty&sort=stars&order=desc&per_page=5"

let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
let promise: EventLoopPromise<Void> = eventLoopGroup.next().newPromise()

let tlsConfiguration = TLSConfiguration.forClient()
let sslContext = try! SSLContext(configuration: tlsConfiguration)
let openSslHandler = try! OpenSSLClientHandler(context: sslContext, serverHostname: "api.github.com")

let bootstrap = ClientBootstrap(group: eventLoopGroup)
        .channelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
        .channelInitializer { channel in
            _ = channel.pipeline.add(handler: openSslHandler)
            _ = channel.pipeline.addHTTPClientHandlers()
            return channel.pipeline.add(handler: HTTPResponseHandler(promise))
        }

func sendRequest(_ channel: Channel) -> EventLoopFuture<Channel> {
    var request = HTTPRequestHead(version: HTTPVersion(major: 1, minor: 1), method: HTTPMethod.GET, uri: "https://api.github.com/search/repositories?q=netty&sort=stars&order=desc&per_page=3")
    request.headers = HTTPHeaders([
        ("Host", "api.github.com"),
        ("User-Agent", "swift-nio"),
        ("Accept-Encoding", "identity"),
        ("Accept", "application/json"),
    ])
    _ = channel.write(HTTPClientRequestPart.head(request))
    return channel.writeAndFlush(HTTPClientRequestPart.end(nil)).map { channel }
}

let ch = bootstrap.connect(host: "api.github.com", port: 443)
        .then { sendRequest($0) }

defer {
    try! promise.futureResult.then { ch }.then { $0.close() }.wait()
    try! eventLoopGroup.syncShutdownGracefully()
}
