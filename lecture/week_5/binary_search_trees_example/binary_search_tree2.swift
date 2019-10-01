indirect enum Tree<A> {
    case internalNode(A, Tree<A>, Tree<A>)
    case leaf
}

enum ComparisonResult {
    case equalTo
    case lessThan
    case greaterThan
}

func contains<A>(tree: Tree<A>,
                 element: A,
                 comparator: (A, A) -> ComparisonResult) -> Bool {
    switch tree {
    case let .internalNode(value, leftNode, rightNode):
        switch comparator(element, value) {
        case .equalTo:
            return true
        case .lessThan:
            return contains(tree: leftNode,
                            element: element,
                            comparator: comparator)
        case .greaterThan:
            return contains(tree: rightNode,
                            element: element,
                            comparator: comparator)
        }
    case .leaf:
        return false
    }
} // contains

func insert<A>(tree: Tree<A>,
               element: A,
               comparator: (A, A) -> ComparisonResult) -> Tree<A> {
    switch tree {
    case let .internalNode(value, leftNode, rightNode):
        switch comparator(element, value) {
        case .equalTo:
            return tree
        case .lessThan:
            return Tree.internalNode(value,
                                     insert(tree: leftNode,
                                            element: element,
                                            comparator: comparator),
                                     rightNode)
        case .greaterThan:
            return Tree.internalNode(value,
                                     leftNode,
                                     insert(tree: rightNode,
                                            element: element,
                                            comparator: comparator))
        }
    case .leaf:
        return Tree.internalNode(element, Tree.leaf, Tree.leaf)
    }
} // contains

func treesEqual<A>(_ first: Tree<A>,
                   _ second: Tree<A>,
                   comparator: (A, A) -> Bool) -> Bool {
    switch (first, second) {
    case let (.internalNode(value1, left1, right1), .internalNode(value2, left2, right2)):
        return (comparator(value1, value2) &&
                  treesEqual(left1, left2, comparator: comparator) &&
                  treesEqual(right1, right2, comparator: comparator))
    case (.leaf, .leaf):
        return true
    case _:
        return false
    }
} // treesEqual

func treeToString<A>(_ tree: Tree<A>, toString: (A) -> String) -> String {
    switch tree {
    case let .internalNode(value, leftNode, rightNode):
        let valueString = toString(value)
        let leftString = treeToString(leftNode, toString: toString)
        let rightString = treeToString(rightNode, toString: toString)
        return "internalNode(\(valueString), \(leftString), \(rightString))"
    case .leaf:
        return "leaf"
    }
} // treeToString

func intToString(_ i: Int) -> String {
    return i.description
}

func intComparator(_ first: Int, _ second: Int) -> ComparisonResult {
    if first == second {
        return ComparisonResult.equalTo
    } else if first < second {
        return ComparisonResult.lessThan
    } else {
        assert(first > second)
        return ComparisonResult.greaterThan
    }
}

func intsEqual(_ first: Int, _ second: Int) -> Bool {
    return first == second
}

// ---BEGIN MAIN---
assert(contains(tree: Tree.leaf,
                element: 1,
                comparator: intComparator) == false)
assert(contains(tree: Tree.internalNode(1, Tree.leaf, Tree.leaf),
                element: 1,
                comparator: intComparator) == true)
assert(contains(tree: Tree.internalNode(1,
                                        Tree.internalNode(0, Tree.leaf, Tree.leaf),
                                        Tree.leaf),
                element: 0,
                comparator: intComparator) == true)
assert(contains(tree: Tree.internalNode(0,
                                        Tree.leaf,
                                        Tree.internalNode(1, Tree.leaf, Tree.leaf)),
                element: 1,
                comparator: intComparator) == true)
assert(treesEqual(insert(tree: Tree.leaf,
                         element: 1,
                         comparator: intComparator),
                  Tree.internalNode(1, Tree.leaf, Tree.leaf),
                  comparator: intsEqual))
assert(treesEqual(insert(tree: Tree.internalNode(0, Tree.leaf, Tree.leaf),
                         element: 0,
                         comparator: intComparator),
                  Tree.internalNode(0, Tree.leaf, Tree.leaf),
                  comparator: intsEqual))
assert(treesEqual(insert(tree: Tree.internalNode(1, Tree.leaf, Tree.leaf),
                         element: 0,
                         comparator: intComparator),
                  Tree.internalNode(1, Tree.internalNode(0, Tree.leaf, Tree.leaf), Tree.leaf),
                  comparator: intsEqual))
assert(treesEqual(insert(tree: Tree.internalNode(1, Tree.leaf, Tree.leaf),
                         element: 2,
                         comparator: intComparator),
                  Tree.internalNode(1, Tree.leaf, Tree.internalNode(2, Tree.leaf, Tree.leaf)),
                  comparator: intsEqual))

