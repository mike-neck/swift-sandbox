import Foundation

struct User: CustomStringConvertible {
    var description: String {
        var i = id
        let ip = UnsafeMutablePointer(&i)
        var n = name
        let np = UnsafeMutablePointer(&n)
        return "id: \(id)[\(ip.debugDescription)], name: \(name)[\(np.debugDescription)]"
    }
    let id: Int
    let name: String
}

let user: User = User(id: 10, name: "石田三成")

private func showMemoryLayout(of item: Any) {
    let size = MemoryLayout.size(ofValue: item)
    let stride = MemoryLayout.stride(ofValue: item)
    let alignment = MemoryLayout.alignment(ofValue: item)

    print("size: \(size), stride: \(stride), alignment: \(alignment)")
}

showMemoryLayout(of: user)

func showPointer<T>(of pointer: UnsafeMutablePointer<T>) {
    print(pointer.pointee)
    print(pointer.debugDescription)
}

let str = "foo"

str.utf8

var u = user
showPointer(of: &u)
var u2 = user
showPointer(of: &u2)

class CUser: CustomStringConvertible {
    var description: String {
        let ip = UnsafeMutablePointer(&id)
        let np = UnsafeMutablePointer(&name)
        return "id: \(id)[\(ip.debugDescription)], name: \(name)[\(np.debugDescription)]"
    }

    var id: Int
    var name: String
    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}

var cuser = CUser(id: 20, name: "安国寺恵瓊")
var cu2 = cuser

showMemoryLayout(of: cuser)
showPointer(of: &cuser)
showPointer(of: &cu2)

struct Foo {
    var value: Int

    mutating func update(value: Int) {
        self.value = value
    }
}

var foo = Foo(value: 20)
var f = foo

showPointer(of: &foo)
showPointer(of: &f)

foo.update(value: 30)

showPointer(of: &foo)
showPointer(of: &f)

enum Either<L, R> {
    case left(value: L)
    case right(value: R)
    func map<T> (_ f: (R) -> T) -> Either<L,T> {
        switch self {
        case .left(let l): return .left(value: l)
        case .right(let r): return .right(value: f(r))
        }
    }
}

var left: Either<String, Int> = Either.left(value: "foo")
print("\(left)")
var l2 : Either<String, Int> = Either.left(value: "foo")

enum Answer {
    case yes
    case no
}

let y = Answer.yes
let n = Answer.no

if y == n {
    print("same(\(y):\(n)")
} else {
    print("not same")
}

extension String: Error {}

extension Int {
    func neverSmaller(than other: Int) throws -> Bool {
        if self < other {
            throw "\(self) is smaller than \(other)"
        }
        return true
    }
}

do {
    let result = try 10.neverSmaller(than: 20)
    print(result)
} catch {
    print(error)
}


func comp(int: Int, obj: Int) throws -> Bool {
    return try int.neverSmaller(than: obj)
}

protocol Monoid {
    static var zero: Self { get }
    func mappend(_ other: Self) -> Self
}

extension String: Monoid {
    static var zero: String { return "" }
    func mappend(_ other: String) -> String { return self + other }
}

print("\"\(String.zero)\"")
print("foo".mappend("bar"))

extension Array where Element: Monoid {
    func reduce() -> Element {
        return self.reduce(Element.zero) { (elem: Element, value: Element) in value.mappend(elem) }
    }
}

print(["foo", "bar", "baz"].reduce())


