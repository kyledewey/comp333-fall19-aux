indirect enum Tree {
    case internalNode(Int, Tree, Tree)
    case leaf
}

func contains(tree: Tree, element: Int) -> Bool {
    switch tree {
    case let .internalNode(value, leftNode, rightNode):
        if element == value {
            return true
        } else if element < value {
            return contains(tree: leftNode, element: element)
        } else {
            assert(element > value)
            return contains(tree: rightNode, element: element)
        }
    case .leaf:
        return false
    }
} // contains

func insert(tree: Tree, element: Int) -> Tree {
    switch tree {
    case let .internalNode(value, leftNode, rightNode):
        if element == value {
            return tree
        } else if element < value {
            return Tree.internalNode(value,
                                     insert(tree: leftNode, element: element),
                                     rightNode)
        } else {
            assert(element > value)
            return Tree.internalNode(value,
                                     leftNode,
                                     insert(tree: rightNode, element: element))
        }
    case .leaf:
        return Tree.internalNode(element, Tree.leaf, Tree.leaf)
    }
} // insert

func treesEqual(_ first: Tree, _ second: Tree) -> Bool {
    switch (first, second) {
    case let (.internalNode(value1, left1, right1), .internalNode(value2, left2, right2)):
        return value1 == value2 && treesEqual(left1, left2) && treesEqual(right1, right2)
    case (.leaf, .leaf):
        return true
    case _:
        return false
    }
} // treesEqual

func treeToString(_ tree: Tree) -> String {
    switch tree {
    case let .internalNode(value, leftNode, rightNode):
        return "internalNode(\(value), \(treeToString(leftNode)), \(treeToString(rightNode))"
    case .leaf:
        return "leaf"
    }
} // treeToString

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

