# Binary Search Trees Example #

This directory contains code which implements a small library that works with [binary search trees (BSTs)](https://en.wikipedia.org/wiki/Binary_search_tree).
This library contains:

- Code defining BST structure
- A `contains` operation, which determines whether or not a BST contains a given value
- An `insert` operation, which possibly adds a value to an existing BST.
  If the BST already contains the value, it leaves the BST unchanged.
- A `treeEqual` operation, which determines if two BSTs have equal **structure**.
  Note that two BSTs with identical values but different structure will **not** be considered equal according to this routine.
- A `treeToString` operation, which returns a string representation of a gioven BST

This code defines _immutable_ BSTs.
With this in mind, `insert` does not modify the existing tree, but rather returns a new tree.
This works much like append with immutable linked lists.

## Functional Programming and Swift ##

This library is implemented in Swift, and the intention with this ongoing example is to teach some key concepts in functional programming.
While Swift is not a purely functional language (loops and mutation are not discouraged), it has a bunch of features which traditionally come from functional languages.
We will introduce most of these features as we go along.

For the moment, you need to know that Swift:

- Is a compiled language.
  There is a separate compile time, compilation preceeds execution, and compilation can possibly fail.
  Swift compiles to machine code, much like C/C++.
- Is statically typed.
  All the types are known at compile time.
- Has type inference.
  In many contexts, we do not need to explicitly list the type used.
  For example, when declaring variables, we can do something like `let x = 7`; there is no need to explicitly say that `x` is an integer, as the Swift compiler can deduce this from the fact that we assigned `x` to be `7`, and `7` is an integer.
- Is reference counted.
  Swift automatically reclaims memory with reference counting, with reclaims memory incrementally at predictable times.
  The downside is that if we create cyclic data structures, memory will leak.
  Programmers can get around this problem by using some additional language-level features, but we won't be getting into those.

The rest of this document goes discusses some key programming language features through the lens of Swift.
Specifically, we look at the code in each of the `.swift` files, and explain what this code does.

## `binary_search_tree1.swift`: Algebraic Data Types and Pattern Matching ##

### Algebraic Data Types ###

Starting from the top, we see something that likely doesn't look familiar:

```swift
indirect enum Tree {
    case internalNode(Int, Tree, Tree)
    case leaf
}
```

This uses `enum`, which is a reserved word for [C/C++/Java](https://docs.oracle.com/javase/tutorial/java/javaOO/enum.html).
Like `enum` in C/C++/Java, `enum` is used to introduce a whole new type, and the type is composed of multiple mutually-exclusive cases.
However, unlike C/C++/Java, this `enum` allows for each case to have additional data associated with it.
The specific definition above says the following:

- `Tree` is an `enum`.
  Additionally, `Tree` is self-referential (one of the cases internally uses `Tree`), which is denoted with the `indirect` reserved word.
- There are two kinds of `Tree`s:
    1. Internal nodes, denoted with the identifier `internalNode`.
       Each internal node holds an `Int` and two `Tree`s.
    2. Leaf nodes, denoted with the identifier `leaf`.
       Leaf nodes store no data in our definition.

Both leaf nodes (`leaf`) and internal nodes (`internalNode`) are kinds of `Tree`s.
We can create them like so:

```swift
let tree1: Tree = Tree.leaf;
let tree2: Tree = Tree.internalNode(57, Tree.leaf, Tree.leaf);
let tree3: Tree = Tree.internalNode(1,
                                    Tree.internalNode(0, Tree.leaf, Tree.leaf),
                                    Tree.internalNode(2, Tree.leaf, Tree.leaf))
```

At the type level, these are all indistinguishable from each other; these are all of type `Tree`, and we cannot specifically refer to the type of an internal node or a leaf.
This is analogous to boolean values in most languages; both `true` and `false` are of type `Bool`, and we cannot distinguish between `true` and `false` at the type level.

The kind of `enum` Swift supports is specifically known as an _algebraic data type_.
Algebraic data types allow us to succinctly define different, mutually-exclusive cases, where each case internally can store an arbitrary amount of data.
Algebraic data types are typically associated with functional languages, but it is becoming increasingly common to see them in other languages.
Notably, Scala, Haskell, Rust, and OCaml all have algebraic data types.

### Pattern Matching ###

While we need to define the tree structure and construct trees, we also need to have operations on the trees.
These operations need to effectively "look" at the given tree they have, and act accordingly.
For this, we use `switch` in Swift, as shown below in the `contains` method:

```swift
func contains(tree: Tree, element: Int) -> Bool {               // line 1
    switch tree {                                               // line 2
    case let .internalNode(value, leftNode, rightNode):         // line 3
        if element == value {                                   // line 4
            return true                                         // line 5
        } else if element < value {                             // line 6
            return contains(tree: leftNode, element: element)   // line 7
        } else {                                                // line 8
            assert(element > value)                             // line 9
            return contains(tree: rightNode, element: element)  // line 10
        }                                                       // line 11
    case .leaf:                                                 // line 12
        return false                                            // line 13
    }                                                           // line 14
} // contains                                                   // line 15
```

Going line-by-line, this code does the following:

- (Line 1) Defines the signature of `contains`.
  The syntax `tree: Tree` states that the first parameter is of type `Tree`, and is named `tree`; this is in contrast to a C/C++/Java style of `Tree tree`.
  The syntax `-> Bool` states that `contains` returns a value of type `Bool`, where `Bool` is the boolean value type in Swift.
- (Line 2) Opens a `switch` on `tree`.
  For the moment, this looks like a `switch` in C/C++/Java.
- (Line 3) This `case` will apply if the `tree`, in reality, is an `internalNode`.
  Additionally, the values in the internal node are extracted out into the new varibles `value` (for the integer in the internal node), `leftNode` (for the first `Tree` nested in the internal node), and `rightNode` (for the second `Tree` nested in the internal node).
  Swift knows what the definition of `internalNode` is, so there is no need to explicitly state what the types of `value`, `leftNode`, and `rightNode` are; Swift knows these are `Int`, `Tree`, and `Tree`, respectively.
- (Lines 4-5) If the passed `element` is equal to the `value` in the node, then return `true`: we've found the element is within
- (Lines 6-7) If the passed `element` is less than the `value` in the node, then recursively search the left child.
  Note the syntax for function calls in Swift.
  By default, we explicitly must list the name of the function's formal parameter (i.e., `tree`) when passing the actual parameter (i.e., `leftNode`).
  This helps make the code [self-documenting](https://docs.oracle.com/javase/tutorial/java/javaOO/enum.html).
- (Lines 8-9) Otherwise, ensure that the element passed is greater than the value in the node.
  This should be true based on our logic, but it's not very explicit without the `assert`.
  Assert, which is not unique to Swift, checks if a condition is true, and typically forces the program to crash if the condition isn't true.
  `assert` is useful for checking assumptions in our code; this code will break if `element > value` isn't true, therefore we prefer a direct crash than some subtly incorrect behavior.
- (Line 10) Call `contains` recurisvely on the right child.
- (Lines 12-13) If we instead have a leaf node, return `false` directly.
  Since our leaves hold no data and have no children, it's impossible for `element` to be contained within.

The `switch` used in the code above is much more powerful than the `switch` from C/C++/Java.
While this `switch` is used to distinguish between different cases (like C/C++/Java), it additionally allows us to concisely extract out values held within the particular case.

We can actually go further than this.
In addition to extracting values, we can also check to see if those values match a particular pattern.
For example, consider the following code:

```swift
switch tree {
case let .internalNode(rootValue, .internalNode(leftValue, _, _), .internalNode(rightValue, _, _)):
  // more code follows ...
}
```

The above case will only match if `tree` is an internal node whose left and right children are both internal nodes.
This simultaneously extracts out the value in `tree`, as well as the values held in the left and right children.
The underscore (`_`) is a catch-all, and basically says "anything can be here, and I don't want to extract out its value into a variable".
Each case consists of a pattern, and patterns can be nested in each other.

This feature with `switch` is commonly referred to as _pattern matching_.
To be useful, algebraic datatypes practically need pattern matching in order to execute the right code for the right case.
As such, languages with algebraic datatypes almost uniformly support pattern matching.

### Remainder of Code ###

There are some additional things to bring out in the rest of the code.

Recall that when calling functions, we normally must say what the name of the formal argument was.
Sometimes, we want there to be a sort of external interface and internal interface for this.
This is illustrated below:

```swift
func myFunction(externalName internalName: Int) -> Int { return internalName; }

myFunction(externalName: 7)
```

In this case, we say that the caller must use `externalName` for the formal parameter name.
Internal to `myFunction`, `internalName` is used instead.

Always requiring the caller to specify the formal argument name can be annoying or unnecessary.
This is arguably true for `treesEqual` in the file.
It's pretty clear that `treesEqual` compares two trees, just based on the name and the number of parameters it takes.
Giving them names won't help improve clarity.
In these cases, we can use underscore (`_`) as the external name, which tells Swift that the caller doesn't need to provide any sort of name to the function.
This is shown below in `treesEqual`:

```swift
func treesEqual(_ first: Tree, _ second: Tree) -> Bool {
  // more code...
  ...treesEqual(left1, left2)...
  // more code...
}
```

In the code snippet above, the (recursive) call to `treesEqual` did not specify any formal parmeter names, and just passed the actual parameters along.
This is because the external name was set to underscore (`_`).

Another Swift feature used in this code is that of _string interpolation_.
This is used in `treeToString`, and the bit of code is shown below:

```swift
"internalNode(\(value), \(treeToString(leftNode)), \(treeToString(rightNode))"
```

This expression constructs a string with double quotes (`"`), but it embeds Swift code inside of it.
Specifically, within the string, every part that starts with `\(` and ends with `)` specifies Swift code that returns a string.
This avoids a lot of string concatenation (with `+`), and helps make this concise.

## `binary_search_tree2.swift`: Parametric Polymorphism, Generics, and Higher-Order Functions ##

**TODO**

## `binary_search_tree3.swift`: Bounded Type Variables and Protocols ##

**TODO**

## `binary_search_tree4.swift`: Extensions With Type Constraints ##

**TODO**
