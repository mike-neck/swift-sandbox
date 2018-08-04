import Foundation

import NIO
import RxSwift

//try! UrlRequestRunner().mainRun()


//guard let url = URL(string: "https://api.github.com/search/repositories?q=netty&sort=stars&order=desc&per_page=3") else {
//    NSLog("url error")
//    exit(1)
//}
//
//let client = HttpClient(url: url)
//
//defer {
//    try? client.eventLoopGroup.syncShutdownGracefully()
//}
//
//let semaphore = DispatchSemaphore(value: 0)
//
//let future: Single<String> = client.get()
//
//future.subscribe { event in
//    switch event {
//    case .error(let e):
//        NSLog("failed:\n\(e)")
//        semaphore.signal()
//    case .success(let body):
//        NSLog("success:\n\(body)")
//        semaphore.signal()
//    }
//}
//
//NSLog("request send.")
//
//semaphore.wait()

let semaphore = DispatchSemaphore(value: -1)

let single = Single<String>.create(subscribe: { single in
    single(.success("foo"))
    return Disposables.create()
})

let bag = DisposeBag()

let disposable = single.map({ $0.lengthOfBytes(using: .utf8) })
        .delay(1.0, scheduler: ConcurrentDispatchQueueScheduler(qos: .default))
        .do(onDispose: {
            semaphore.signal()
            NSLog("onDispose")
        })
        .subscribe { event in
            if case .success(let string) = event {
                NSLog("success: \(string)")
            } else if case .error(let e) = event {
                NSLog("error: \(e)")
            }
            semaphore.signal()
            NSLog("subscribe")
        }

NSLog("wait 0")

semaphore.wait()

NSLog("wait 1")

semaphore.wait()

NSLog("wait 2")

bag.insert(disposable)

NSLog("main")