import Foundation

import Willow
import Logging

typealias Log = Logging.Logger

let logger = Logger(logLevels: [LogLevel.all], writers: [ConsoleWriter()])

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

logger.infoMessage("done-normal")
