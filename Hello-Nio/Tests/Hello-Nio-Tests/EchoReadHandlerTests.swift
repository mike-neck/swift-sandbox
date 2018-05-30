import XCTest
@testable import NIO
@testable import Hello_Nio_Handlers

struct TestLogger {
    var logMessage: String?

    func hasMessage() -> Bool {
        if let _ = logMessage {
            return true
        } else {
            return false
        }
    }
}

class EchoReadHandlerTest: XCTestCase {

    func testChannelRegistered() throws {
        var logger: TestLogger = TestLogger()
        let handler = EchoReadHandler(logger: { msg in logger.logMessage = msg })
        defer {
            print("\(logger.logMessage)")
        }

        let channel = EmbeddedChannel()

        try channel.pipeline.add(handler: handler).wait()

        channel.pipeline.fireChannelRegistered()
    }
}
