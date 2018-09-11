import RxSwift
import Foundation

let observable = Observable.create { (observe: AnyObserver<String>) -> Disposable in
    observe.on(.next("foo"))
    observe.on(.next("bar"))
    observe.on(.next("baz"))
    observe.on(.next("qux"))
    observe.onCompleted()
    return Disposables.create(with: { print("disposing!") })
}

let semaphore = DispatchSemaphore(value: 0)

let disposable = observable.flatMap { str in Observable.of(1, 2, 3).map { ($0, str) } }
        .do(onCompleted: { semaphore.signal() })
    .subscribe { (event: Event<(Int, String)>) -> () in
        switch event {
        case .next(let tpl): print(tpl.0, tpl.1, separator: ", ", terminator: "\n")
        case .error(let err): print("error: \(err)")
        case .completed: print("finished")
        }
    }

semaphore.wait()

disposable.dispose()
