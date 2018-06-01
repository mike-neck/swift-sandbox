import RxSwift
import Foundation

let scheduler = SerialDispatchQueueScheduler(qos: .default)
let subscription = Observable<Int>.interval(0.3, scheduler: scheduler)
        .subscribe( {event in
            NSLog("event: \(event)")
        } )

Thread.sleep(forTimeInterval: 2.5)

subscription.dispose()


