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

    _ = DispatchQueue.global(qos: .default)

    publishSubject.onNext("foo")
    publishSubject.onNext("bar")

    _ = publishSubject
            .subscribe(
                    onNext: { NSLog("sub1: \($0)") },
                    onCompleted: { NSLog("finished") })
            .disposed(by: disposeBag)

    publishSubject.onNext("Hello")
    publishSubject.onNext("World")

    _ = publishSubject.subscribe { msg in
        NSLog("sub2: \(msg)")
    }

    publishSubject.onNext("both will receive this message")
}

func fifth() {
    // 1つしか保持しない publisher
    let behaviorSubject = BehaviorSubject(value: "foo")

    behaviorSubject.onNext("bar")
    behaviorSubject.onNext("baz")

    let _: Disposable = behaviorSubject.subscribe({ msg in
        NSLog("receive: \(msg)")
    })

    behaviorSubject.onNext("message")
}

func subscriber(name: String) -> (Event<String>) -> () {
    return { msg in
        NSLog("\(name): [\(type(of: msg))] \(String(describing: msg.element))")
    }
}

private func fooBarBaz(observerType: ReplaySubject<String>) {
    observerType.onNext("foo")
    observerType.onNext("bar")
    observerType.onNext("baz")
}

func sixth() {
    let replaySubject = ReplaySubject<String>.create(bufferSize: 3)
    fooBarBaz(observerType: replaySubject)

    let _ = replaySubject.subscribe(subscriber(name: "6-sub1"))

    replaySubject.onNext("next foo")

    let _ = replaySubject.subscribe(subscriber(name: "6-sub2"))

    replaySubject.onNext("next bar")
}

func mapping() {
    let sub = Observable.of("foo", "bar", "baz").map({ str in
        return "\(str) -> \(str.lengthOfBytes(using: .utf8))"
    }).subscribe(subscriber(name: "mapping"))
    sub.disposed(by: DisposeBag())
}

enum Colour {
    case blue
    case red
    case green
}

struct Text {
    let text: String
    let colour: Colour
}

func flatMapping() {
    let colours = Observable<Colour>.of(.blue, .green, .red)
    let texts = Observable<String>.of("foo", "bar")

    _ = colours.flatMap({ c in texts.map({ t in Text(text: t, colour: c) }) })
            .map({ String(describing: $0) })
            .subscribe(subscriber(name: "text-colour"))
}

protocol Monoid {
    associatedtype MonoidType
    func append(other: MonoidType) -> MonoidType
    static func zero() -> MonoidType
}

struct Sum<N: Numeric>: Monoid {
    let value: N

    typealias MonoidType = Sum<N>

    func append(other: Sum<N>) -> Sum<N> {
        return Sum(value: self.value + other.value)
    }

    static func zero() -> Sum<N> {
        return Sum(value: 0 as N)
    }
}

func scanning() {
    let _ = Observable.of(1, 2, 3, 4, 5)
            .map { number in
                Sum(value: number)
            }
            .scan(Sum<Int>.zero(), accumulator: { accum, value in
                NSLog("accum: \(accum), value: \(value)")
                return accum.append(other: value)
            }).map({ String(describing: $0) })
            .subscribe(subscriber(name: "scanning"))
}

func buffer() {
    _ = Observable<Int>.from((1...11).map({ $0 }))
            .buffer(timeSpan: 3, count: 2, scheduler: scheduler)
            .subscribe { event in
                NSLog("type: \(type(of: event)), value: \(String(describing: event))")
            }
}

func filters() {
    _ = PublishSubject<Int>.generate(
                    initialState: Int(arc4random_uniform(20)),
                    condition: { _ in true },
                    iterate: { _ in Int(arc4random_uniform(20)) })
            .take(15)
            .filter {
                $0 > 10
            }
            .map({ String(describing: $0) })
            .subscribe(subscriber(name: "filters"))
}

func startsWith() {
    let _ = Observable.of(2, 3, 5, 8, 13).startWith(1).map({ "current: \($0)" }).subscribe(subscriber(name: "startsWith 1, 2..."))
}

func merge() {
    let left = PublishSubject<Int>()
    let right = PublishSubject<Int>()

    _ = Observable.merge(left, right).subscribe(onNext: { value in
        NSLog("value: \(value)")
    })

    left.onNext(10)
    left.onNext(20)
    left.onNext(30)
    right.onNext(1000)
    left.onNext(40)
    right.onNext(2000)
    right.onNext(3000)
    left.onNext(50)
}

func zipping() {
    struct Msg {
        let number: Int
        let text: String
    }

    let numbers = Observable<Int>.generate(
            initialState: 1,
            condition: { _ in return true },
            iterate: { number in number + 1 }).take(20)
    let strings = Observable<String>.of("foo", "bar", "baz", "qux", "waldo", "garply")

    _ = Observable.zip(numbers, strings, resultSelector: { (num, txt) in Msg(number: num, text: txt) })
            .map({ msg in String(describing: msg) })
            .subscribe(subscriber(name: "zipping"))
}

zipping()
