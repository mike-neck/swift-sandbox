import Foundation

import Willow
import Logging

typealias Log = Logging.Logger
typealias WilLogger = Willow.Logger

let logger = Logger(logLevels: [LogLevel.all], writers: [ConsoleWriter(modifiers: [TimestampModifier()])])

enum Msg: LogMessage {
    case start(name: String, _ message: String)

    var name: String {
        switch self {
        case .start(let name, _): return name
        }
    }

    var attributes: [String: Any] {
        switch self {
        case .start(_, let message): return ["message": message, "phase": "start"]
        }
    }
}

let schemes = ["h2", "https"]
let separators = ["\\", "://"]
let hosts = ["localhost:2000", "example.com", "www.example.com"]

for scheme in schemes {
    logger.debug(Msg.start(name: "scheme", scheme))
    for sep in separators {
        logger.debug(Msg.start(name: "separator", sep))
        for host in hosts {
            logger.debug(Msg.start(name: "host", host))
            guard let url = URL(string: "\(scheme)\(sep)\(host)") else {
                logger.warnMessage("invalid url: \(scheme)\(sep)\(host)")
                break
            }
            logger.infoMessage("create url: \(url)")
        }
    }
}

logger.infoMessage("nike-done")

extension Logging.Logger.Level {

    func wilowLevel() -> LogLevel {
        switch self {
        case .debug:
            return LogLevel.all
        case .info:
            return .info
        case .notice:
            return .event
        case .warning:
            return .warn
        default:
            return .error
        }
    }

    func handle(logger: WilLogger, withMessage message: LogMessage) {
        switch self {
        case .debug:
            logger.debug(message)
        case .info:
            logger.info(message)
        case .notice:
            logger.event(message)
        case .warning:
            logger.warn(message)
        default:
            logger.error(message)
        }
    }
}

struct WillowLogHandler: LogHandler {

    enum Message: LogMessage {
        case logMessage(file: String, function: String, line: UInt, metaadta: Logging.Logger.Metadata?, message: String)
        var name: String {
            switch self {
            case .logMessage(let file, let function, let line, _, _):
                return """
                       file="\(file)",function="\(function)",line=\(line)
                       """
            }
        }
        var attributes: [String: Any] {
            switch self {
            case .logMessage(_, _, _, let metadata, let message):
                guard let meta = metadata else {
                    return ["message": message]
                }
                return ["message": message, "metadata": meta]
            }
        }
    }

    let delegating: (Logging.Logger.Level) -> WilLogger
    var delegate: WilLogger

    init(delegating: @escaping (Logging.Logger.Level) -> WilLogger, logLevel: Logging.Logger.Level) {
        self.delegating = delegating
        self.delegate = delegating(logLevel)
        self.logLevel = logLevel
    }

    func log(level: Logging.Logger.Level, message: Logging.Logger.Message, metadata: Logging.Logger.Metadata?, file: String, function: String, line: UInt) {
        let msg = Message.logMessage(file: file, function: function, line: line, metaadta: metadata, message: String(describing: message))
        level.handle(logger: delegate, withMessage: msg)
    }

    subscript(metadataKey key: String) -> Log.Metadata.Value? {
        get {
            return metadata[key]
        }
        set {
            metadata[key] = newValue
        }
    }

    var metadata: Log.Metadata = [:]
    var logLevel: Log.Level {
        didSet {
            self.delegate = delegating(logLevel)
        }
    }
}

var apple = Log(
        label: "com.example.App",
        factory: { label in
            WillowLogHandler(delegating: { level in
                WilLogger(logLevels: level.wilowLevel(), writers: [ConsoleWriter(modifiers: [TimestampModifier()])]) }, logLevel: .info) })

apple.info("start info")

for scheme in schemes {
    apple.debug("start scheme: \(scheme)")
    for separator in separators {
        apple.debug("start separator: \(separator)")
        for host in hosts {
            apple.debug("start host: \(host)")
            let string = "\(scheme)\(separator)\(host)"
            if let url = URL(string: string) {
                apple.info("valid url: \(url)")
            } else {
                apple.error("invalid url: \(string)")
            }
        }
    }
}

apple.logLevel = .debug

apple.info("start debug")

for scheme in schemes {
    apple.debug("start scheme: \(scheme)")
    for separator in separators {
        apple.debug("start separator: \(separator)")
        for host in hosts {
            apple.debug("start host: \(host)")
            let string = "\(scheme)\(separator)\(host)"
            if let url = URL(string: string) {
                apple.info("valid url: \(url)")
            } else {
                apple.error("invalid url: \(string)")
            }
        }
    }
}

apple.info("app-done")
