import Foundation

protocol Foo { func foo() }

public protocol Factory {
    associatedtype Obj where Obj : Factory
    static func new() -> Obj
}

class Bar: Foo {

    let name: String

    init(_ name: String) {
        self.name = name
    }

    func foo() {
        NSLog("foo: \(name)")
    }

    func bar() {
        NSLog("bar: \(name)")
    }
}

extension Bar: Factory {
    typealias Obj = Bar

    class func new() -> Bar {
        return Bar("")
    }
}
