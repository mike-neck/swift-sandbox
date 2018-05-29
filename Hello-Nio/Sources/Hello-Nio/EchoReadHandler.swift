//
// Created by mike on 2018/05/29.
//

import NIO
import Foundation

class EchoReadHandler: ChannelInboundHandler {

    typealias InboundIn = ByteBuffer
    typealias OutboundOut = String

    init() {
        self.compositeBytes = ByteBufferAllocator().buffer(capacity: 64)
    }

    var remote: String?

    var compositeBytes: ByteBuffer

    func channelRegistered(ctx: ChannelHandlerContext) {
        self.remote = ctx.remoteAddress?.description ?? "unknown"
        print("new channel registered.[\(remote)]")
    }

    func channelRead(ctx: ChannelHandlerContext, data: NIOAny) {
        var buffer = unwrapInboundIn(data)
        let size = buffer.readableBytes
        if (compositeBytes.writableBytes < size) {
            compositeBytes.changeCapacity(to: size - compositeBytes.writableBytes + compositeBytes.capacity)
        }
        compositeBytes.write(buffer: &buffer)
    }

    func channelReadComplete(ctx: ChannelHandlerContext) {
        let message = compositeBytes.readString(length: compositeBytes.readableBytes)
        print("message[from: \(remote)]: \(message)")
        ctx.write(wrapOutboundOut(message ?? ""), promise: nil)
    }

    func errorCaught(ctx: ChannelHandlerContext, error: Error) {
        print("error: \(error)")
        ctx.close(promise: nil)
    }
}

class EchoWriteHandler: ChannelOutboundHandler {

    typealias OutboundIn = String
    typealias OutboundOut = ByteBuffer

    func write(ctx: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {
        let message = unwrapOutboundIn(data)
        var buffer = ByteBufferAllocator().buffer(capacity: message.utf8.count)
        buffer.write(string: message)
        ctx.writeAndFlush(wrapOutboundOut(buffer))
                .whenComplete({ let _ = ctx.close() })
    }
}

struct Message: CustomStringConvertible {
    let text: String
    let time: NSDate

    var description: String {
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 9) as TimeZone
        return """
        {text: \"\(text)\", time: \"\(formatter.string(from: self.time as Date))\"}
        """
    }
}
