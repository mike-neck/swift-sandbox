import Foundation
import Logging

func runApp(use logger: Logger) {
    let schemes = ["h2", "https"]
    let separators = ["\\", "://"]
    let hosts = ["localhost", "example.com"]

    for scheme in schemes {
        logger.debug("start scheme: \(scheme)")

        for separator in separators {
            logger.debug("start separator: \(separator)")

            for host in hosts {
                logger.debug("start host: \(host)")

                let urlString = "\(scheme)\(separator)\(host)"
                if let url = URL(string: urlString) {
                    logger.info("valid url: \(url)")
                } else {
                    logger.error("invalid url: \(urlString)")
                }
            }
        }
    }
}

var logger = Logger(label: "com.example.App")

logger.warning("set default logLevel")

runApp(use: logger)

logger.warning("set logLevel debug")

logger.logLevel = .debug

runApp(use: logger)
