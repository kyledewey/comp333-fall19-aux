indirect enum Tree<A> {
    case internalNode(A, Tree<A>, Tree<A>)
    case leaf
}

enum ComparisonResult {
    case equalTo
    case lessThan
    case greaterThan
}

protocol CanCompare {
    func compareTo(_ to: Self) -> ComparisonResult
} // CanCompare

protocol CanConvertToString {
    func toString() -> String
} // CanConvertToString

func contains<A: CanCompare>(tree: Tree<A>, element: A) -> Bool {
    switch tree {
    case let .internalNode(value, leftNode, rightNode):
        switch element.compareTo(value) {
        case .equalTo:
            return true
        case .lessThan:
            return contains(tree: leftNode, element: element)
        case  .greaterThan:
            return contains(tree: rightNode, element: element)
        }
    case .leaf:
        return false
    }
} // contains

func insert<A: CanCompare>(tree: Tree<A>, element: A) -> Tree<A> {
    switch tree {
    case let .internalNode(value, leftNode, rightNode):
        switch element.compareTo(value) {
        case .equalTo:
            return tree
        case .lessThan:
            return Tree.internalNode(value,
                                     insert(tree: leftNode, element: element),
                                     rightNode)
        case .greaterThan:
            return Tree.internalNode(value,
                                     leftNode,
                                     insert(tree: rightNode, element: element))
        }
    case .leaf:
        return Tree.internalNode(element, Tree.leaf, Tree.leaf)
    }
} // insert

func treesEqual<A: CanCompare>(_ first: Tree<A>, _ second: Tree<A>) -> Bool {
    switch (first, second) {
    case let (.internalNode(value1, left1, right1), .internalNode(value2, left2, right2)):
        return value1.equals(value2) && treesEqual(left1, left2) && treesEqual(right1, right2)
    case (.leaf, .leaf):
        return true
    case _:
        return false
    }
} // treesEqual

func treeToString<A: CanConvertToString>(_ tree: Tree<A>) -> String {
    switch tree {
    case let .internalNode(value, leftNode, rightNode):
        return "internalNode(\(value.toString()), \(treeToString(leftNode)), \(treeToString(rightNode))"
    case .leaf:
        return "leaf"
    }
} // treeToString

extension Int: CanCompare {
    func compareTo(_ other: Int) -> ComparisonResult {
        if self == other {
            return ComparisonResult.equalTo
        } else if self < other {
            return ComparisonResult.lessThan
        } else {
            assert(self > other)
            return ComparisonResult.greaterThan
        }
    } // compareTo
}

extension CanCompare {
    func equals(_ other: Self) -> Bool {
        switch self.compareTo(other) {
        case .equalTo:
            return true
        case _:
            return false
        }
    } // equals
} // CanCompare

extension Int: CanConvertToString {
    func toString() -> String {
        return self.description
    } // toString
}

// ---BEGIN MAIN---
assert(contains(tree: Tree.leaf, element: 1) == false)
assert(contains(tree: Tree.internalNode(1, Tree.leaf, Tree.leaf), element: 1) == true)
assert(contains(tree: Tree.internalNode(1,
                                        Tree.internalNode(0, Tree.leaf, Tree.leaf),
                                        Tree.leaf),
                element: 0) == true)
assert(contains(tree: Tree.internalNode(0,
                                        Tree.leaf,
                                        Tree.internalNode(1, Tree.leaf, Tree.leaf)),
                element: 1) == true)
assert(treesEqual(insert(tree: Tree.leaf, element: 1),
                  Tree.internalNode(1, Tree.leaf, Tree.leaf)))
assert(treesEqual(insert(tree: Tree.internalNode(0, Tree.leaf, Tree.leaf),
                         element: 0),
                  Tree.internalNode(0, Tree.leaf, Tree.leaf)))
assert(treesEqual(insert(tree: Tree.internalNode(1, Tree.leaf, Tree.leaf),
                         element: 0),
                  Tree.internalNode(1, Tree.internalNode(0, Tree.leaf, Tree.leaf), Tree.leaf)))
assert(treesEqual(insert(tree: Tree.internalNode(1, Tree.leaf, Tree.leaf),
                         element: 2),
                  Tree.internalNode(1, Tree.leaf, Tree.internalNode(2, Tree.leaf, Tree.leaf))))

