import RxSwift
import Foundation

let scheduler = SerialDispatchQueueScheduler(qos: .default)
let subscription = Observable<Int>.interval(0.3, scheduler: scheduler)
        .subscribe({ event in
            NSLog("event: \(event)")
        })

Thread.sleep(forTimeInterval: 2.5)

subscription.dispose()

let semaphore = DispatchSemaphore(value: 0)

let _ = Observable.of("foo")
        .subscribe { event in NSLog("type: \(type(of: event)), event: \(String(describing: event))") }

let disposeBag = DisposeBag()

let subscription2 = Observable.just("suc")
        .delay(0.01, scheduler: scheduler)
        .subscribe(
                onNext: { str in NSLog(str) },
                onError: { error in NSLog("error: \(String(describing: error))") },
                onCompleted: { () in semaphore.signal() })

subscription2.disposed(by: disposeBag)
