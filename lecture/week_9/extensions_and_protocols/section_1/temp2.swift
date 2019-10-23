extension Double {
    func multiply(other: Double) -> Double {
        return self * other
    }
}

extension Int {
    func add(_ other: Int) -> Int {
        return self + other
    }
}

// let result = (2.1).multiply(other: 3.7)
// print(result)

let result = 5.add(6)
//print(result)

protocol MyProtocol {
    func foo() -> Int
    func bar(x: Int) -> Int
}

extension Int: MyProtocol {
    func foo() -> Int { return 42 }
    func bar(x: Int) -> Int { return x }
}

// print(5.foo())
// print(6.bar(x: 7))

protocol Multiply {
    func mult(x: Self) -> Self
}

extension Int: Multiply {
    func mult(x: Int) -> Int {
        return self * x
    }
}

extension Double: Multiply {
    func mult(x: Double) -> Double {
        return self * x
    }
}

// print(5.mult(x: 6))
// print((2.1).mult(x: 3.3))

protocol Equality {
    func equals(_ x: Self) -> Bool
}

extension Int: Equality {
    func equals(_ x: Int) -> Bool {
        return self == x
    }
}

extension Double: Equality {
    func equals(_ x: Double) -> Bool {
        return self == x
    }
}

print(5.equals(5))
print(5.equals(6))
print((2.1).equals(2.1))
print((2.1).equals(2.2))
    
func toplevel(_ param: Int) -> Int {
    return param
}

print(toplevel(7))

extension Int {
    func something<A>(_ x: A) -> A {
        return x
    }
}

print(5.something("foo"))

enum SomeEnum<A> {
    case thing(A)
}

extension SomeEnum {
    func getThing() -> A {
        switch self {
        case .thing(let value):
            return value
        }
    }
}

let value = SomeEnum.thing(5)
print(value.getThing())

enum BinaryTree<A> {
    case internalNode(A, BinaryTree<A>, BinaryTree<A>)
    case leaf
}

enum ComparisonResult {
    case equalTo
    case lessThan
    case greaterThan
}

protocol Compare {
    func compare(_ other: Self) -> ComparisonResult
}

extension Int: Compare {
    func compare(_ other: Int) -> ComparisonResult {
        if self == other {
            return ComparisonResult.equalTo
        } else if self < other {
            return ComparisonResult.lessThan
        } else {
            assert(self > other)
            return ComparisonResult.greaterThan
        }
    }
}

// func contains<A>(tree: BinaryTree<A>,
//                  element: A,
//                  comparison: (A, A) -> ComparisonResult) -> Bool {
//     ...
// }

// func contains<A: Compare>(tree: BinaryTree<A>,
//                           element: A) -> Bool {
//     switch tree {
//     case .internalNode(let value, let leftNode, let rightNode):
//         element.compare(value) ...

extension BinaryTree where A: Compare {
    func contains(element: A) -> Bool {
        switch self {
        case .internalNode(let value, let leftNode, let rightNode):
            element.compare(value) ...
        }
    }
}

// BinaryTree<Int>
extension BinaryTree where A == Int {
}

extension BinaryTree where A == Double {
}

indirect enum List<A> {
    case cons(A, List<A>)
    case empty
}

extension List where A == Int {
    func evens() -> List<Int> {
        ...
    }
}
