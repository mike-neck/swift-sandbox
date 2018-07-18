//
// Created by mike on 2018/07/15.
//

import Foundation

class UrlRequestRunner {

    func mainRun() throws {
        guard let url =
            URL(string: "https://api.openweathermap.org/data/2.5/weather?q=Tokyo&appid=bb308867de49c49c03bcb7eec2a38a6f") else {
            NSLog("[\(Thread.current.description)] error url")
            throw URLError.invalidUrl
        }

        NSLog("[\(Thread.current.description)] request: \(url)")
        NSLog("[\(Thread.current.description)] query: \(url.query)")

        let request = URLRequest(url: url)

        let semaphore = DispatchSemaphore(value: 0)

        URLSession.shared.dataTask(with: request) { (data, urlResponse, error) in
            NSLog("[\(Thread.current.description)] process in callback")
            if let e = error {
                NSLog("[\(Thread.current.description)] error: \(e)")
            }
            if let response = urlResponse as? HTTPURLResponse {
                NSLog("[\(Thread.current.description)] status: \(response.statusCode)")
                NSLog("[\(Thread.current.description)] Content-Type: \(response.allHeaderFields["Content-Type"] ?? "")")
            }
            if let d = data {
                let responseBody: String = String(data: d, encoding: String.Encoding.utf8) ?? ""
                NSLog("[\(Thread.current.description)] response body: \(responseBody)")
            }
            semaphore.signal()
            NSLog("[\(Thread.current.description)] callback finished")
        }.resume()

        NSLog("[\(Thread.current.description)] main finished")
        semaphore.wait()

        NSLog("[\(Thread.current.description)] all finished")
    }
}

enum URLError: Swift.Error {
    case invalidUrl
}
