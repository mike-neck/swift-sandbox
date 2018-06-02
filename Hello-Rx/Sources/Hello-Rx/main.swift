import RxSwift
import Foundation

let scheduler = SerialDispatchQueueScheduler(qos: .default)

func first() {
    let subscription = Observable<Int>.interval(0.3, scheduler: scheduler)
            .subscribe({ event in
                NSLog("event: \(event)")
            })

    Thread.sleep(forTimeInterval: 2.5)

    subscription.dispose()
}

func second() {
    let _ = Observable.of("foo")
            .subscribe { event in
                NSLog("type: \(type(of: event)), event: \(String(describing: event))")
            }
}

func third() {
    let semaphore = DispatchSemaphore(value: 0)

    let disposeBag = DisposeBag()

    let subscription = Observable.just("suc")
            .delay(0.01, scheduler: scheduler)
            .subscribe(
                    onNext: { str in NSLog(str) },
                    onError: { error in NSLog("error: \(String(describing: error))") },
                    onCompleted: { () in semaphore.signal() })

    subscription.disposed(by: disposeBag)
}

func fourth() {
    let disposeBag = DisposeBag()

    // subscribe した後のイベントしか購読できない publisher
    let publishSubject = PublishSubject<String>()

    let dispatchQueue = DispatchQueue.global(qos: .default)

    publishSubject.onNext("foo")
    publishSubject.onNext("bar")

    let sub1 = publishSubject
            .subscribe(
                    onNext: { NSLog("sub1: \($0)") },
                    onCompleted: { NSLog("finished") })
            .disposed(by: disposeBag)

    publishSubject.onNext("Hello")
    publishSubject.onNext("World")

    let sub2 = publishSubject.subscribe { msg in
        NSLog("sub2: \(msg)")
    }

    publishSubject.onNext("both will receive this message")
}

func fifth() {
    // 1つしか保持しない publisher
    let behaviorSubject = BehaviorSubject(value: "foo")

    behaviorSubject.onNext("bar")
    behaviorSubject.onNext("baz")

    let sub1: Disposable = behaviorSubject.subscribe({ msg in
        NSLog("receive: \(msg)")
    })

    behaviorSubject.onNext("message")
}

func subscriber(name: String) -> (Event<String>) -> () {
    return { msg in
        NSLog("\(name): \(msg.element)")
    }
}

func sixth() {
    let replaySubject = ReplaySubject<String>.create(bufferSize: 3)
    replaySubject.onNext("foo")
    replaySubject.onNext("bar")
    replaySubject.onNext("baz")

    let _ = replaySubject.subscribe(subscriber(name: "6-sub1"))

    replaySubject.onNext("next foo")

    let _ = replaySubject.subscribe(subscriber(name: "6-sub2"))

    replaySubject.onNext("next bar")
}

fourth()

fifth()

sixth()
