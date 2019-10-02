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
For those looking for more background on Swift, the [Swift Language Guide](https://docs.swift.org/swift-book/LanguageGuide/TheBasics.html) is a great official reference.

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

### Parametric Polymorphism and Generics ###

The biggest change in `binary_search_tree2.swift` is that we have added _type variables_.
Right from the top, our definition of trees has changed to:

```swift
indirect enum Tree<A> {
    case internalNode(A, Tree<A>, Tree<A>)
    case leaf
}
```

Instead of containing an `Int`, trees now contain an `A`, where `A` is a type variable.
`A` is put in scope with the line `indirect enum Tree<A>`.
`Tree` is no longer a valid type, but `Tree<Int>` and `Tree<String>` are now valid types, where `Tree<Int>` refers to a tree containing `Int`s, and `Tree<String>` refers to a tree containing `String`s.
That is, when refer to `Tree` now, we have to say what type `Tree` itself takes.
`Tree<A>` is also a valid type in the above code; the type variable `A` itself is a type, so `A` can be used as a type.
Specifically, the above code says that internal nodes contain an `A`, along with two other `Tree<A>`s.

Via the use of a type variable, we allow for the creation of `Tree`s which hold different types of values.
Without type variables, we'd be forced to make redundant definitions like:

```swift
indirect enum IntTree {
    case internalNode(Int, IntTree, IntTree)
    case leaf
}

indirect enum StringTree {
    case internalNode(String, StringTree, StringTree)
    case leaf
}
```

Moreover, code which works with trees would similarly have to be duplicated for `IntTree` and `StringTree`, despite the fact that the code would be mostly identical.
This is not ideal.

When type variables are added to data structures (like `enum`s), we refer to them as _generics_.
`Tree` is a generic data structure.

Type variables can also be added to functions / methods.
For example, the signature of `contains` introduces a type variable, specifically with:

```swift
func contains<A>...
```

This snippet shows that the type variable `A` is in scope within the body of `contains`.
This usage of `A` is distinct from the usage of `A` when `Tree` was defined; this is analogous to using the same variable name in different scopes.
When type variables are introduced in the context of a functions / methods, this is referred to as _parametric polymorphism_.
Usually this is conflated with generics; I'm not particular about the terminology, myself.


### Problem with Generics ###

Generics allow our trees to hold values of different types, which gives us a lot more flexibility.
However, this creates a problem: at definition time, we don't know exactly what type `A` is, so we are restricted to operations which work for any type `A`.
Very few operations work for any type.
For example, we can no longer compare values to each other with `==` (as is done in `contains`), nor can we compare values with `<` (as is done in `insert`); we don't know if our `A` actually supports these operations or not.
Our trees are pretty useless without these operations.

### Solution: Higher-Order Functions ###

A key observation is that we can _mostly_ define our functions without knowing what `A` is.
The actual type of `A` only matters in a few contexts, namely when we compare (`contains`, `insert`, `treesEqual`) or convert to a string (`treeToString`).
Rather than try to perform the missing operations in-place, we tweak these functions to take an additional parameter: a higher-order function operation on `A` which performs the missing desired operation.
In this way, we force the caller to tell us exactly how to work with `A`s.
Usually, the caller knows what the actual type of `A` is, so this is not a significant burden on the caller.

For example, let's look at the whole signature of `contains`:

```swift
func contains<A>(tree: Tree<A>,
                 element: A,
                 comparator: (A, A) -> ComparisonResult) -> Bool {
    ...
}
```

From this signature, we can gather:

- The name of the function is `contains`
- Type variable `A` is in scope throughout the rest of `contains`' definition
- `tree` is a `Tree` _parameterized_ by type variable `A`
- `element` is a value of type `A`.
  Considering what `contains` does, `element` is the value to look for in the tree.
- `comparator` is a function that takes two values of type `A`, and returns a `ComparisonResult` saying how the two elements are related to each other.
  From the earlier definition of `enum ComparisonResult`, the first `A` could be `equalTo`, `lessThan`, or `greaterThan` the second `A`.
- Given the above parameters,`contains` returns a boolean value (`Bool`) indicating whether or not `tree` contains `element`.

In the body of `contains`, gather than directly use `==`, `<`, or `>` (as was done in `binary_search_tree1.swift`), we call `comparator` with `element` and `value`, like so: `comparator(element, value)`.
We then immediately use `switch` to see what the result of the comparison was, and dispatch accordingly based on the result.

The rest of the functions similarly take higher-order functions to work with their generic parameters.
Specifically:

- `insert` takes `comparator`, which is used in the same manner as `contains`
- `treesEqual` takes `comparator`, which returns a boolean (`Bool`) indicating whether the two passed `A`s are equal to each other
- `treeToString` takes `toString`, which returns a string representation of the given `A`


## `binary_search_tree3.swift`: Protocols, Bounded Type Variables, and Extensions ##

### Motivation ###

While `binary_search_tree2.swift` is working, looking at the test suite (the `assert` statements near the bottom) reveals that there is a lot of redundancy.
Whenever when dealing with `Tree<Int>`, we always pass `intComparator` and `intsEqual`, reflecting the fact that there is only one way of comparing integers.
Redundant code is code we don't want to write.

### Solution: Protocols and Extensions ###

Swift supports _protocols_, which are somewhat analogous to abstract classes or interfaces from an object-oriented realm.
Like an abstract class, protocols allow us to define abstract methods which will be later defined.
`binary_search_tree3.swift` defines two protocols, shown below:

```swift
protocol CanConvertToString {
    func toString() -> String
} // CanConvertToString

protocol CanCompare {
    func compareTo(_ to: Self) -> ComparisonResult
} // CanCompare
```

`CanConvertToString` defines the `toString` abstract method, which is intended to return a `String` representation of whatever it is called on.
`CanCompare` defines the `compareTo` abstract method, which allows for comparison to another value.
The type `Self` is special, and refers to whatever type `CanCompare` is defined on (more on that in a bit).

Protocols only define abstract methods.
If we want to implement these methods, we must use _extensions_`.
For example, consider the following extension, which is defined near the end of `binary_search_tree3.swift`:

```swift
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
```

The first line (`extension Int: CanCompare`) states that we are extending `Int` with the `CanCompare` protocol.
In object-oriented parlance, this is effectively defining `Int` to extend the abstract `CanCompare` class.
However, unlike with object-oriented classes, we can define extensions on _any_ type, not just ones we define.
In this case, `Int` is Swift's built-in integer type, which is predefined.
Nothing stops us from adding our own methods to `Int`, as we do above.
This extension is done at compile-time.

Notably, `compareTo` is defined to take an `Int` above, as opposed to the `Self` from the protocol.
This is because we now know the exact type of `Self`: it must be `Int`, as we are defining an extension on `Int`.
Phrased another way, this `compareTo` method we define is called on values of type `Int`, so `Self` is `Int`.
Internally, `self` (lowercase) refers to the _value_ we are called on, and `self` is of type `Int` in this context (that is, `self` is of type `Self`).
The rest of the code is pulled directly from the `intComparator` function in `binary_search_tree_2.swift`.

A similar extension is defined which gives `Int` a `toString` method, namely with:

```swift
extension Int: CanConvertToString {
    func toString() -> String {
        return self.description
    } // toString
}
```

This code accesses the `description` field of `self`, where `self` is of type `Int`.
`description` is built-in.

Extensions allow us to add methods even if there isn't a corresponding protocol defining abstract methods.
For example, consider the following code from `binary_search_tree3.swift`:

```swift
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
```

This code adds the `equals` method to _anything_ that extends the `CanCompare` protocol.
This is possible because `CanCompare` provides the `compareTo` method, which can serve as a way of determining equality.
Thanks to this extension, `Int` transitively also has the `equals` method.

### Bounded Type Variables ###

Now that we've added our desired comparison and string conversion methods to `Int`, we can take advantage of these.
However, in order to make use of them, we can no longer work with arbitrary `A` values, but rather `A` values that extend our protocols.
This is done in the signature of `contains` like so:

```swift
func contains<A: CanCompare>(tree: Tree<A>, element: A) -> Bool {
    ...
}
```

We no longer just introduce `A`, but now say `A: CanCompare`.
This introduces type variable `A`, _and_ states that `A` must extend the `CanCompare` protocol.
If an attempt is made to use `contains` with an `A` that doesn't extend `CanCompare`, it is a compile-time error, and it's considered the fault of the caller of `contains`.
Within the body of `contains`, since we know that `A: CanCompare`, we can now call any methods present on `CanCompare`, as with `element.compareTo(value)`.
Similarly, we can call any methods which were added to `CanCompare` itself, as with the call to `value1.equals(value2)` in `treesEqual`.
We no longer have to pass higher-order functions along saying how to compare our values of type `A`; we've now constrained things so that we operate on specific values of type `A` which have certain methods present.
This cuts out the repetition of passing around comparison functions.

### Note: Typeclasses vs. Object-Oriented Classes ###

The protocol/extension mechanism in Swift is based on [typeclasses](https://en.wikipedia.org/wiki/Type_class), which are **distinct** from object-oriented classes.
In typeclass terminology, protocols form typeclasses, and extensions form instances (which are distinct from the word "instance" in object-oriented terminology).
Typeclasses were first present in Haskell, though the basic idea is becoming increasingly popular (e.g., `trait`/`impl` in Rust, `implicit` values and parameters in Scala, Concepts in C++).
These mechanisms shar ethe basic idea of adding arbitrary methods to arbitrary types at compile time.

Internally, the way compilation with typeclasses works is similar to how we did things in `binary_search_tree2.swift`.
Behind the scenes, an extra parameter is passed which holds all the functions available related to the specific protocol required for the specific type (in our case, the methods on `CanCompare` for `Int`).
This is a different (but related) mechanism than is used for class-based object-oriented programming.
We won't get into how this compilation works in this class; COMP 430 (Language Design and Compilers) has more details, if you're interested
For our purposes, it's only necessary to know that this is distinct from class-based inheritance, and allows for different capabilities.
Additionally, typeclasses are wholly non-equivalent; there are some things that work better with class-based inheritance, and others which work better with typeclasses.

## `binary_search_tree4.swift`: Existing Protocols and Extensions With Type Constraints ##

**TODO**
