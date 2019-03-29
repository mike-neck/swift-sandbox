import Foundation

import Willow
import Logging

public typealias Log = Logging.Logger
public typealias WilLogger = Willow.Logger

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

    @inlinable func handle(logger: WilLogger, withMessage message: LogMessage) {
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

    let createLogger: (Logging.Logger.Level) -> WilLogger
    var delegate: WilLogger

    init(delegating: @escaping (Logging.Logger.Level) -> WilLogger, logLevel: Logging.Logger.Level) {
        self.createLogger = delegating
        self.delegate = delegating(logLevel)
        self.logLevel = logLevel
    }

    func log(
            level: Logging.Logger.Level,
            message: Logging.Logger.Message,
            metadata: Logging.Logger.Metadata?,
            file: String,
            function: String,
            line: UInt) {
        let msg = Message.logMessage(
                file: file, function: function, line: line, metaadta: metadata, message: String(describing: message))
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
            self.delegate = createLogger(logLevel)
        }
    }
}


let schemes = ["h2", "https"]
let separators = ["\\", "://"]
let hosts = ["localhost:2000", "example.com", "www.example.com"]

public func runAppForWillow(use willow: WilLogger) {
    for scheme in schemes {
        willow.debugMessage("start scheme: \(scheme)")

        for sep in separators {
            willow.debugMessage("start separator: \(sep)")

            for host in hosts {
                willow.debugMessage("start host: \(host)")

                let urlString = "\(scheme)\(sep)\(host)"
                guard let url = URL(string: urlString) else {
                    willow.warnMessage("invalid url: \(urlString)")
                    break
                }
                willow.infoMessage("valid url: \(url)")
            }
        }
    }
}

public func runAppForApple(use apple: Log) {
    for scheme in schemes {
        apple.debug("start scheme: \(scheme)")

        for separator in separators {
            apple.debug("start separator: \(separator)")

            for host in hosts {
                apple.debug("start host: \(host)")
                let urlString = "\(scheme)\(separator)\(host)"

                if let url = URL(string: urlString) {
                    apple.info("valid url: \(url)")
                } else {
                    apple.error("invalid url: \(urlString)")
                }
            }
        }
    }
}




let args = CommandLine.arguments

if args.count == 1 || args[1] == "willow" {

    let willow = WilLogger(logLevels: LogLevel.all, writers: [ConsoleWriter(modifiers: [TimestampModifier()])])

    runAppForWillow(use: willow)

} else if args[1] == "info" {
    let apple = Log(
            label: "com.example.App",
            factory: { label in
                WillowLogHandler(delegating: { level in
                    WilLogger(
                            logLevels: level.wilowLevel(),
                            writers: [ConsoleWriter(modifiers: [TimestampModifier()])])
                }, logLevel: .info)
            })

    apple.info("start info")

    runAppForApple(use: apple)

} else if args[1] == "debug" {
    var apple = Log(
            label: "com.example.App",
            factory: { label in
                WillowLogHandler(delegating: { level in
                    WilLogger(
                            logLevels: level.wilowLevel(),
                            writers: [ConsoleWriter(modifiers: [TimestampModifier()])])
                }, logLevel: .info)
            })

    apple.info("start info")

    apple.logLevel = .debug

    runAppForApple(use: apple)
}
