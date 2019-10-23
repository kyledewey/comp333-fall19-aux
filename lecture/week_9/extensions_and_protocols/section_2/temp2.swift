protocol HasMultiply {
    func multiply(other: Self) -> Self
}

extension Double: HasMultiply {
    func multiply(other: Double) -> Double {
        // self: this
        return self * other
    }
}

extension Double {
    func otherMethod() -> Int {
        return 42
    }
}

extension Int: HasMultiply {
    func multiply(other: Int) -> Int {
        return self * other
    }
}

let result = (2.1).multiply(other: 3.4)
print(result)

extension Int {
    func add(_ other: Int) -> Int {
        return self + other
    }
}

let result2 = 5.add(6)
print(result2)

print((2.1).otherMethod())

func toplevel(_ param: Int) -> Int {
    return param
}

print(toplevel(5))

protocol Equality {
    func equals(_ other: Self) -> Bool
}

//extension Int {
extension Int: Equality {
    func equals(_ other: Int) -> Bool {
        return other == self
    }
}

print(5.equals(5))
print(5.equals(6))
//print(5.equalsTwoDiff("foo"))

indirect enum Tree<A> {
    case internalNode(A, Tree<A>, Tree<A>)
    case empty
}

enum ComparisonResult {
    case equalTo
    case lessThan
    case greaterThan
}

// func contains<A>(tree: Tree<A>,
//                  element: A,
//                  compare: (A, A) -> ComparisonResult) -> Bool { ... }

// protocol Compare {
//     func compare(_ other: Self) -> ComparisonResult
// }

// extension Tree where A: Compare {
//     // A is in scope
//     // self: Tree<A>
//     func contains(element: A) -> Bool {
//         //element.compare(element)
//         switch self {
//         case .internalNode(let value, let leftNode, let rightNode):
//             element.compare(value)
//         }
//     }
// }

// // Tree<Int>
// extension Tree where A == Int {
//     func sum() -> Int { ... }
// }

indirect enum List<A> {
    case cons(A, List<A>)
    case empty
}

extension List where A == Int {
    func evens() -> List<Int> {
    }
    func evens() -> List<String> {
        let list: List<String> = List.empty
        return list
    }
}
