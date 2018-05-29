import NIO

let bossGroup = MultiThreadedEventLoopGroup(numThreads: 1)
let workerGroup = MultiThreadedEventLoopGroup(numThreads: 2)

print("SO_REUSEADDR: \(SO_REUSEADDR)")

func log(text: String) {
    print(text)
}

let bootstrap = ServerBootstrap(group: bossGroup, childGroup: workerGroup)
        .serverChannelOption(ChannelOptions.backlog, value: 256)
        .serverChannelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
        .childChannelInitializer { channel in
            channel.pipeline.add(handler: EchoWriteHandler()).then { (v: Void) in
                channel.pipeline.add(handler: EchoReadHandler())
            }
        }
        .childChannelOption(ChannelOptions.socket(IPPROTO_TCP, TCP_NODELAY), value: 1)
        .childChannelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
        .childChannelOption(ChannelOptions.maxMessagesPerRead, value: 16)
        .childChannelOption(ChannelOptions.recvAllocator, value: AdaptiveRecvByteBufferAllocator())

defer {
    try! bossGroup.syncShutdownGracefully()
}
defer {
    try! workerGroup.syncShutdownGracefully()
}

class Logging {
    func info(text: String) {
        print(text)
    }
}

let logging = Logging()

let channel: Channel = try! bootstrap.bind(host: "::1", port: 8000).map { ch in
    logging.info(text: "server started at localhost 8000")
    return ch
}.wait()

try! channel.closeFuture.wait()
