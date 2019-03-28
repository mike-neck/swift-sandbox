import Foundation

import Logging

import HeliumLogger
import LoggerAPI

typealias Unused = LoggerAPI.Logger
typealias AppleLogger = Logging.Logger

extension AppleLogger.Level {
    func asHeliumType() -> LoggerMessageType {
        switch self {
        case .debug: return .debug
        case .info: return .info
        case .notice: return .verbose
        case .warning: return .warning
        case .error: return .error
        case .critical: return .error
        case .alert: return .error
        case .emergency: return .error
        }
    }
}

struct HLoggerImpl: LogHandler {

    let label: String
    var delegate: HeliumLogger
    var metadata: AppleLogger.Metadata = [:]
    var level: AppleLogger.Level
    let constructor: (LoggerMessageType) -> HeliumLogger

    init(label: String, delegate: @escaping (LoggerMessageType) -> HeliumLogger) {
        self.label = label
        self.delegate = delegate(.info)
        self.level = .info
        self.constructor = delegate
    }

    func log(level: AppleLogger.Level, message: AppleLogger.Message, metadata: AppleLogger.Metadata?, file: String, function: String, line: UInt) {
        var meta: String
        if let map = metadata {
            meta = map.description
        } else {
            meta = ""
        }
        let msg = "\(message), \(meta)"
        delegate.log(level.asHeliumType(), msg: msg, functionName: function, lineNum: Int(line), fileName: file)
    }

    subscript(metadataKey metadataKey: String) -> AppleLogger.Metadata.Value? {
        get {
            return metadata[metadataKey]
        }
        set {
            metadata[metadataKey] = newValue
        }
    }

    var logLevel: AppleLogger.Level {
        set {
            self.level = newValue
            let type = newValue.asHeliumType()
            self.delegate = self.constructor(type)
        }
        get {
            return self.level
        }
    }
}

struct LoggerFactory {
    static func getLogger(label: String) -> AppleLogger {
        return AppleLogger(label: label, factory: { lb in HLoggerImpl(label: lb, delegate: { type in HeliumLogger(type) }) })
    }
}

NSLog("test \(#file) \(#line)")
NSLog("test")

var logger = LoggerFactory.getLogger(label: "com.example.App")


let schemes = ["h2", "https"]
let separators = ["\\", "://"]
let hosts = ["localhost:2000", "example.com", "www.example.com"]

for scheme in schemes {
    logger.debug("start scheme: \(scheme)")
    for sep in separators {
        logger.debug("start separator: \(sep)")
        for host in hosts {
            logger.debug("start host: \(host)")
            if let url = URL(string: "\(scheme)\(sep)\(host)") {
                logger.info("done \(url)")
            } else {
                logger.error("error \(scheme)\(sep)\(host)")
            }
        }
    }
}

logger.info("change log level to debug")

logger.logLevel = .debug

for scheme in schemes {
    logger.debug("start scheme: \(scheme)")
    for sep in separators {
        logger.debug("start separator: \(sep)")
        for host in hosts {
            logger.debug("start host: \(host)")
            if let url = URL(string: "\(scheme)\(sep)\(host)") {
                logger.info("done \(url)")
            } else {
                logger.error("error \(scheme)\(sep)\(host)")
            }
        }
    }
}
