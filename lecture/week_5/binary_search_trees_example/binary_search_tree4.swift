indirect enum Tree<A> {
    case internalNode(A, Tree, Tree)
    case leaf
}

extension Tree where A: Comparable {
    func contains(_ element: A) -> Bool {
        switch self {
        case let .internalNode(value, leftNode, rightNode):
            if element == value {
                return true
            } else if element < value {
                return leftNode.contains(element)
            } else {
                assert(element > value)
                return rightNode.contains(element)
            }
        case .leaf:
            return false
        }
    } // contains

    func insert(_ element: A) -> Tree<A> {
        switch self {
        case let .internalNode(value, leftNode, rightNode):
            if element == value {
                return self
            } else if element < value {
                return Tree.internalNode(value,
                                         leftNode.insert(element),
                                         rightNode)
            } else {
                assert(element > value)
                return Tree.internalNode(value,
                                         leftNode,
                                         rightNode.insert(element))
            }
        case .leaf:
            return Tree.internalNode(element, Tree.leaf, Tree.leaf)
        }
    } // contains
}

extension Tree: Equatable where A: Equatable {
    static func ==(first: Tree<A>, second: Tree<A>) -> Bool {
        switch (first, second) {
        case let (.internalNode(value1, left1, right1), .internalNode(value2, left2, right2)):
            return value1 == value2 && left1 == left2 && right1 == right2
        case (.leaf, .leaf):
            return true
        case _:
            return false
        }
    }
} // treesEqual

extension Tree: CustomStringConvertible where A: CustomStringConvertible {
    var description: String {
        switch self {
        case let .internalNode(value, leftNode, rightNode):
            return "internalNode(\(value), \(leftNode), \(rightNode)"
        case .leaf:
            return "leaf"
        }
    }
} // treeToString

// ---BEGIN MAIN---
assert(Tree.leaf.contains(1) == false)
assert(Tree.internalNode(1, Tree.leaf, Tree.leaf).contains(1) == true)
assert(Tree.internalNode(1,
                         Tree.internalNode(0, Tree.leaf, Tree.leaf),
                         Tree.leaf).contains(0) == true)
assert(Tree.internalNode(0,
                         Tree.leaf,
                         Tree.internalNode(1, Tree.leaf, Tree.leaf)).contains(1) == true)
assert(Tree.leaf.insert(1) == Tree.internalNode(1, Tree.leaf, Tree.leaf))
assert(Tree.internalNode(0, Tree.leaf, Tree.leaf).insert(0) == Tree.internalNode(0, Tree.leaf, Tree.leaf))
assert(Tree.internalNode(1, Tree.leaf, Tree.leaf).insert(0) == Tree.internalNode(1, Tree.internalNode(0, Tree.leaf, Tree.leaf), Tree.leaf))
assert(Tree.internalNode(1, Tree.leaf, Tree.leaf).insert(2) == Tree.internalNode(1, Tree.leaf, Tree.internalNode(2, Tree.leaf, Tree.leaf)))

