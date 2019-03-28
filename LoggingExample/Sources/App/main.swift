import Foundation
import Logging

struct NamedLogHandler: LogHandler {

    let label: String
    var delegate: Logger

    init(_ label: String) {
        self.label = label
        self.delegate = Logger(label: label)
    }

    func log(level: Logger.Level, message: Logger.Message, metadata: Logger.Metadata?, file: String, function: String, line: UInt) {
        delegate.log(level: level, message, metadata: metadata, file: file, function: function, line: line)
    }

    subscript(metadataKey metadataKey: String) -> Logging.Logger.Metadata.Value? {
        get {
            return delegate[metadataKey: metadataKey]
        }
        set {
            delegate[metadataKey: metadataKey] = newValue
        }
    }
    var metadata: Logger.Metadata {
        get {
            return delegate.metadata
        }
        set {
            delegate.metadata = newValue
        }
    }
    var logLevel: Logger.Level {
        get {
            return delegate.logLevel
        }
        set {
            delegate.logLevel = newValue
        }
    }
}

struct LoggerFactory {
    static func getLogger(_ label: String) -> Logger {
        let lgr = Logger(label: label, factory:{ str in NamedLogHandler(label) })
        return lgr
    }
}


typealias UserId = Int

struct User: CustomStringConvertible, Decodable, Encodable {

    private static var logger = Logger(label: "com.example.User")

    let id: UserId
    let name: String
    let address: String

    init(_ id: UserId, name: String, address: String) {
        self.id = id
        self.name = name
        self.address = address
    }

    var description: String {
        return """
               User[name: "\(name)", address: "\(address)"]
               """
    }

    func greeting(to user: User) {
        User.logger.info(
                """
                Hello from \(self) to \(user)
                """)
    }

    func receive(data : Data) {
        let json = String(data: data, encoding: .utf8)

        let decoder = JSONDecoder()
        do {
            let user = try decoder.decode(User.self, from: data)
            User.logger.info("success: receive message[\(json)] from \(user)")
        } catch {
            User.logger.warning("failure: receive unknown message[\(json)], \(error)")
        }
    }

    func sendMessage(to user: User) {
        let encoder = JSONEncoder()
        do {
            let json = try encoder.encode(self)
            user.receive(data: json)
            let jsonString = String(data: json, encoding: .utf8)
            User.logger.info("success: sent message[\(jsonString)] to \(user)")
        } catch {
            User.logger.error("failure: sent message to \(user), \(error)")
        }
    }
}

var logger = LoggerFactory.getLogger("com.example.Main")

logger.logLevel = .debug
logger[metadataKey: "operator"] = "master-user"

logger.info("start application")

logger.debug("ユーザーを作る")
let 太郎 = User(100, name: "太郎", address: "東京")
let 花子 = User(300, name: "花子", address: "大阪")

logger.info("greeting from 花子 to 太郎")

花子.greeting(to: 太郎)

logger.info("message from 太郎 to 花子")

太郎.sendMessage(to: 花子)

logger.info("花子 receive unknown message from stranger")

logger.debug("不審なデータ送る")
let unknownMessage = "[こここふふふ]"
guard let data = unknownMessage.data(using: .utf8) else {
    logger.error("error to convert data: \(unknownMessage)")
    exit(1)
}

花子.receive(data: data)
