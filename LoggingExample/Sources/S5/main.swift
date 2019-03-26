//
// Created by mike on 2019-03-26.
//

import Foundation


import SwiftyBeaver
import Logging

struct SwiftyBeaverAdapter {
    func debug(_ message: String) {
        print(message)
        SwiftyBeaver.self.debug(message)
    }

    func info(_ message: String) {
        print(message)
        SwiftyBeaver.self.info(message)
    }

    func warning(_ message: String) {
        print(message)
        SwiftyBeaver.self.warning(message)
    }

    func error(_ message: String) {
        print(message)
        SwiftyBeaver.self.error(message)
    }
}

struct SwiftyBeaverHandler: LogHandler {

    var _metadata: Logger.Metadata = [:]

    let label: String
    let delegate: SwiftyBeaverAdapter

    init(label: String, delegate: SwiftyBeaverAdapter) {
        self.label = label
        self.delegate = delegate
    }

    func log(level: Logger.Level, message: Logger.Message, metadata: Logger.Metadata?, file: String, function: String, line: UInt) {
        switch level {
        case .debug: self.delegate.debug("file:\(file), function:\(function), line:\(line), \(message)")
        case .info: self.delegate.info("file:\(file), function:\(function), line:\(line), \(message)")
        case .warning: self.delegate.warning("file:\(file), function:\(function), line:\(line), \(message)")
        default: self.delegate.error("file:\(file), function:\(function), line:\(line), \(message)")
        }
    }

    subscript(metadataKey metadataKey: String) -> Logger.Metadata.Value? {
        get {
            return self._metadata[metadataKey]
        }
        set {
            self._metadata[metadataKey] = newValue
        }
    }
    var metadata: Logger.Metadata  {
        get {
            return _metadata
        }
        set {
            self._metadata = newValue
        }
    }
    var logLevel: Logger.Level = .info
}

func getLogger(_ label: String) -> Logger {
    let swiftyBeaver = SwiftyBeaver.self

    let console = ConsoleDestination()
    console.format = "$DHH:mm:ss$d $L $M"
    swiftyBeaver.addDestination(console)

    return Logger(label: label, factory: { label in SwiftyBeaverHandler(label: label, delegate: SwiftyBeaverAdapter()) })
}

let logger = getLogger("com.example.App")

let schemes = ["h2", "http"]
let hosts = ["localhost:8000", "example.com"]

print("test")

for scheme in schemes {
    logger.debug("scheme: \(scheme) start")
    for host in hosts {
        logger.debug("host: \(host) start")
        guard let url = URL(string: "\(scheme)://\(host)") else {
            logger.warning("Invalid url: \(scheme)://\(host)")
            break
        }
        logger.info("valid url: \(url)")
    }
}

let swiftyBeaver = SwiftyBeaver.self

let console = ConsoleDestination()
console.format = "$DHH:mm:ss$d $L $M"
swiftyBeaver.addDestination(console)

swiftyBeaver.debug("test")