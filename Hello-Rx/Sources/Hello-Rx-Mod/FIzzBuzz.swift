import Foundation

public protocol Natural {
    associatedtype Next
    func next() throws -> Next
}

class FizzBuzzError: Error {}

public struct Count: Natural {
    let current: Int
    let max: Int

    public typealias Next = Count

    public var hasNext: Bool {
        get {
            return current < max
        }
    }

    public func next() throws -> Count {
        if !hasNext {
            throw FizzBuzzError()
        }
        return Count(current: self.current + 1, max: max)
    }
}

public enum Mod {
    case odd(current: Int, max: Int)
    case even(max: Int)
}

extension Mod: Natural {
    public typealias Next = Mod

    public func next() -> Next {
        switch self {
        case .odd(let current, let max):
            let nextValue: Int = current + 1
            if nextValue == max {
                return .even(max: max)
            } else {
                return .odd(current: nextValue, max: max)
            }
        case .even(let max):
            return .odd(current: 1, max: max)
        }
    }
}

fileprivate func first(max: Int) -> Count {
    return Count(current: 1, max: max)
}

public enum FizzBuzzValue {
    case number(value: Int)
    case fizz
    case buzz
    case fizzBuzz
}

struct FizzBuzzContext {
    let three: Mod
    let five: Mod
    let number: Count

    init(three: Mod = .odd(current: 1, max: 3), five: Mod = .odd(current: 1, max: 5), number: Count) {
        self.three = three
        self.five = five
        self.number = number
    }

    var hasNext: Bool {
        get {
            return number.hasNext
        }
    }

    var fizzBuzz: FizzBuzzValue {
        get {
            switch (three, five) {
            case (.even(_), .even(_)): return .fizzBuzz
            case (.even(_), _): return .fizz
            case (_, .even(_)): return .buzz
            case (_, _): return .number(value: number.current)
            }
        }
    }
}

extension FizzBuzzContext: Natural {
    typealias Next = FizzBuzzContext
    func next() -> FizzBuzzContext {
        return try! FizzBuzzContext(three: three.next(), five: five.next(), number: number.next())
    }
}

extension FizzBuzzValue: CustomStringConvertible {
    public var description: String {
        switch self {
        case .number(let value):
            return "\(value)"
        case .fizz:
            return "Fizz"
        case .buzz:
            return "Buzz"
        case .fizzBuzz:
            return "FizzBuzz"
        }
    }
}

fileprivate func buildFizzBuzz(
        context: FizzBuzzContext,
        list: [FizzBuzzValue] = [FizzBuzzValue]()) -> [FizzBuzzValue] {
    if !context.hasNext {
        return list
    }
    var next = [FizzBuzzValue]()
    next.append(contentsOf: list)
    next.append(context.fizzBuzz)
    return buildFizzBuzz(context: context.next(), list: next)
}

public func fizzBuzz(to: Int) {
    let context = FizzBuzzContext(number: first(max: to))
    let fizzBuzz = buildFizzBuzz(context: context)
    for fb in fizzBuzz {
        print(String(describing: fb))
    }
}
