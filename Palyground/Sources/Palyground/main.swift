import Foundation

import NIO
import RxSwift

//try! UrlRequestRunner().mainRun()


guard let url = URL(string: "https://api.github.com/search/repositories?q=netty&sort=stars&order=desc&per_page=3") else {
    NSLog("url error")
    exit(1)
}

let client = HttpClient(url: url)

defer {
    try? client.eventLoopGroup.syncShutdownGracefully()
}

let semaphore = DispatchSemaphore(value: 0)

let future: Single<String> = client.get()

future.subscribe { event in
    switch event {
    case .error(let e):
        NSLog("failed:\n\(e)")
        semaphore.signal()
    case .success(let body):
        NSLog("success:\n\(body)")
        semaphore.signal()
    }
}

NSLog("request send.")

semaphore.wait()
