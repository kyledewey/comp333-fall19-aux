# Grammars, Abstract Syntax Trees, and Parsing #

This covers some background about how compilers and interpreters read in and understand input programs.
This is fairly minimal, and is not intended to be a complete discussion of this problem.
For a more complete view, you may wish to refer to [this document](https://ucsb-cs56-pconrad.github.io/tutorials/parsing/), specifically all the links underneath the "More on parsing" section.


## Grammars ##

Before we can start reading in programs, we need to answer a basic question: what _is_ a valid program?
Without a definition of validity, we don't really know what we need to read in, nor how to interpret it.
For example, we need a way of saying the arithmetic expressions `1` and `2 + 3` are valid, but that `1foo + 2` is not valid.

In order to define valid programs, we borrow the concept of [context-free grammars (CFGs)](https://en.wikipedia.org/wiki/Context-free_grammar) from linguistics.
True to their name, CFGs talk about the _grammar_ of a given language; that is, the rules governing where words can be placed in a _sentence_.
While CFGs were originally created to talk about natural languages, they are a good (and often better) fit for talking about programming languages.
In the context of a CFG, a program forms a complete sentence.

CFGs are often written in Backus-Naur form (BNF).
Let's explain BNF via example:

```
expr ::= integer | expr '+' expr
digit ::= '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9'
integer ::= digit | digit integer
```

The above BNF describes arithmetic expressions which use `+`.
Each line is referred to as a _production rule_, and each part between the `|` (pipe) is a _production_`.
The part before the `::=` gives the name of the production rule.
The part after the `::=` says what it means to be a valid input for this production.
The `|` is effectively logical OR, stating that a given input could be one thing or another thing.
The use of single quotes (as with `'+'`) states that the specific string in the quotes must be present in the input, whereas a lack of quotes indicates the use of another production.

With all this in mind, let's do a rough translation of the above BNF into plain English.
We'll start with the first line: `expr ::= integer | expr '+' expr`.
This says:

- `expr ::=`: An `expr` (short for "expression") is...
- `integer`: Whatever the `integer` production rule accepts...
- `|`: ...or...
- `expr '+' expr`: Whatever `expr` accepts, followed by a `+` character, followed by whatever `expr` accepts.
  You can think of following one part directly with another as logical AND.

This shows that production rules are permitted to be recursive, which is necessary for most practical languages.
For example, most languages allow you to nest `if` as many levels deep as you want; this is becuase their grammars are defined recursively, allowing for `if` to be defined within an `if`.

Onto the second and third lines.
This line states that a `digit` is either `0`, `1`, ..., `9`.
With this in mind `digit` accepts single-digit integers.
The third line (`integer ::= digit | digit integer`) is used to accept possibly multi-digit integers.
Specifically, this states:

- `integer ::=`: An `integer` is...
- `digit`: ...whatever `digit` accepts...
- `|`: ...or...
- `digit integer`: ...whatever `digit` accepts, followed by whatever `integer` accepts.
  Here, we use recursion to repeatedly accept single-digit integers, collectively allowing for multi-digit integers of arbitrary length.

While this example is relatively small, this covers all the essentials of BNF.
With these same concepts, we can define a grammar describing complete programming languages.


## Abstract Syntax Trees ##

While we can use grammars to talk about the validity of programs, we usually care about more than just validity.
Specifically, we want to be able to read in the program and interpret its meaning.
For this purpose, it's inconvenient to work with the raw input from the programmer, which is effectively a big string.
To understand why this is inconvenient, let's consider the following snippets, one per line:

```
int x=1+2;
int x = 1 + 2;
int x = 1 + 2; // set x to 3
int x = (1 + 2);
int x = ((1) + (2));
```

Each one of these snippets is different.
However, from the standpoint of a compiler/interpreter, they all do the _exact_ same thing.
While it can be convenient for humans to have different ways of writing the same thing, we intentionally don't want these to be treated differently.
To that end, it's better if the compiler/interpreter uses a [canonical form](https://en.wikipedia.org/wiki/Canonical_form) of some sort to treat these uniformly.

The canonical form which is almost universally used is that of an [abstract syntax tree (AST)](https://en.wikipedia.org/wiki/Abstract_syntax_tree).
While this name sounds complex, each one of its parts says a lot about what we're working with:

- "abstract": it removes any non-essential details, e.g., how much whitespace was used, if parentheses were present, if a comment was used, etc.
- "syntax": it describes what the programmer wrote
- "tree": it is a [tree](https://en.wikipedia.org/wiki/Tree_(graph_theory)), in the same way that a binary tree is a tree.
  However, these trees can have more complex structures than possible with binary trees.

Let's see some ASTs for some expressions:

`8`:

![](eight.png)

In this case, we just have a leaf node, holding the value `8`.

`2 + 3`:

![](two_plus_three.png)

Operations (like `+`) are placed in internal nodes in the tree.
The operands (`2` and `3`) are placed in child nodes.
The order of the child nodes matters; if this had been `3 + 2`, the values in the two child nodes would be swapped.

`2 + 3 + 4`:

![](two_plus_three_plus_four.png)

Recalling the normal PEMDAS rules for arithmetic, addition is performed left-to-right.
This means that `2 + 3 + 4` is equivalent to `(2 + 3) + 4`.
This is represented in the AST by having the subtree for `2 + 3` nested below the `+` involving `4`.
This shows that `2 + 3` is at higher precedence; we have to add `2` and `3` before we can add `4`.
If the input expression had instead been `(2 + 3) + 4`, it would have resulted in the _exact same_ AST.
That is, given this AST, we don't know if the input were `2 + 3 + 4`, `(2 + 3) + 4`, `2+3+4`, etc.

`2 + 3 * 4`:

![](two_plus_three_times_four.png)

Recalling again the PEMDAS rules, this expression is equivalent to `2 + (3 * 4)`.
We see this in the tree structure, where the `3 * 4` must be evaluated before we can evaluate the addition.


### Representing ASTs in Swift ###

ASTs written on a screen only get us so far.
We need to have some way to represent these with data structures in code.
For that purpose, we will make use of `enum` in Swift, like so:

```swift
indirect enum Exp {
    case integer(Int)
    case plus(Exp, Exp)
    case mult(Exp, Exp)
}
```

This code defines the `Exp` `enum`, short for "Expression".
This says that there are three kinds of expressions:

- An `integer` expression, which holds a native Swift `Int`.
  This represents our leaves in the AST, which hold only integers in the above examples.
- A `plus` expression, which holds two subexpressions.
  This represents `+` internal nodes in our AST.
- A `mult` expression, which holds two subexpressions.
  This represents `*` internal nodes in our AST.

Using the `Exp` definition above, we can now represent the above ASTs in memory.
For example:

`8`:

```
Exp.integer(8)
```

`2 + 3`:

```
Exp.plus(
  Exp.integer(2),
  Exp.integer(3))
```

`2 + 3 + 4`:

```
Exp.plus(
  Exp.plus(
    Exp.integer(2),
    Exp.integer(3)),
  Exp.integer(4))
```

`2 + 3 * 4`:

```
Exp.plus(
  Exp.integer(2),
  Exp.mult(
    Exp.integer(3),
    Exp.integer(4)))
```

Now we can represent our ASTs in memory.


## Parsing ##

The specific portion of a compiler/interpreter that is responsible for reading in a program and turning it into an AST is the _parser_.
From a high level, we can think of the parser as a function with the following signature:

```swift
func parser(input: String) -> AST? { ... }
```

That is, a parser takes in the input program as a string, and possibly returns an AST (hence `AST?`).
If, however, the input program is invalid, then `parser` won't return an `AST`; in this case, we are said to have a _syntax error_.

Parsing can be both computationally expensive (to the tune of `O(n^3)`) and memory-intensive.
Given early computers with severely limited resources, this was problematic, particularly for early language design.
As a result, a lot of work has gone into making fast (in the common case) and efficient parsing algorithms.
However, many of these algorithms are fairly complex, and merit significant discussion just to understand them.
For our purposes, we won't cover these.
Instead, we will cover a (comparatively) simpler parsing approach, based on [parser combinators](https://en.wikipedia.org/wiki/Parser_combinator).

The key idea with parser combinators is that we can define certain primitive building blocks with which to create bigger parsers.
These building blocks are based on higher-order functions, and are roughly based on the signature of the `parser` function above.
Instead of defining `parser` as a single toplevel function, we define `parser` as a _signature_ of a higher-order function, like so:

```swift
typealias Parser = (String) -> (String, AST)?
```

In Swift, `typealias` is used to create an alias between a name (which will be treated as a valid kind of type) and an existing type.
This is analogous to `typedef` in C/C++.
In the snippet above, the type `Parser` is defined to be identical to a function which takes a `String`, and possibly returns (hence the `?`) a pair of `String` and `AST`.
This is slightly different from the original toplevel definition of `parser`, in that now we return a `String` in addition to the `AST`.
The idea here is that the returned `String` holds everything that we still have to parse.
That is, `Parser` is a bit weaker than the toplevel `parser` from before; `Parser` only parses a _prefix_ of the input, whereas `parser` must parse the entire input.
Once the given `Parser` has finished parsing what it can handle, it returns back the `String` holding everything it didn't parse.

### Tokenization ###

While we _can_ define a parser that directly works with `String` as an input, this is usually inconvenient.
Instead, we usually define an earlier pass called [tokenization](https://en.wikipedia.org/wiki/Lexical_analysis) which breaks the original `String` input into "tokens".
Each token is somewhat analogous to a word in natural language.
To see how tokens work, consider the following program snippet (in JavaScript):

```javascript
if (x > 7) {
  return 42;
}
```

Notably, `if` and `return`, while both being composed of multiple characters, each behave as a single unit.
Additionally, the fact that there is whitespace in this program is irrelevant; while a parser can skip over this whitespace, it's easier to handle this now.
With all this in mind, we may represent the above program with the following list of tokens:

- `ifToken`
- `leftParenToken`
- `variableToken("x")`
- `greaterThanToken`
- `integerToken(7)`
- `rightParenToken`
- `leftCurlyToken`
- `returnToken`
- `integerToken(42)`
- `semicolonToken`
- `rightCurlyToken`

This strips out the irrelevant information about whitespace, and it puts `if` and `return` into their own distinct tokens.
However, this is still a list of tokens, not an AST, so parsing is still necessary on these tokens to make an AST.
As with ASTs, we can represent tokens with Swift `enum`s, like so:

```swift
enum Token {
    case integerToken(Int)
    case variableToken(String)
    case leftParenToken
    case rightParenToken
    case leftCurlyToken
    case rightCurlyToken
    case ifToken
    case returnToken
    case semicolonToken
}
```

Tokenization is not unique to parser combinators; most parsing algorithms assume tokenization has been performed already.

### Generalizing `Parser` ###

With tokens in mind, we update our `Parser` definition, like so:

```swift
typealias Parser = (List<Token>) -> (List<Token>, AST)?
```

Instead of taking and returning `String`s, `Parser` now operates on lists of `Token`s.
If we use an immutable list implementation (as you have implemented in assignments 1 and 2), then this will end up giving us a significant memory savings over the `String`-based representation.
Specifically, we only need to keep the list of tokens representing the whole program in memory once, and then individual parsers will return different pointers into this same data structure.

We can generalize this definition a bit.
First, instead of forcing parsers to return `AST`s, we can define parsers which return _anything_.
In other words, we can make `Parser` generic.
This generic definition is shown below:

```swift
typealias Parser<A> = (List<Token>) -> (List<Token>, A)?
```

Now we can define parsers for anything, including things that aren't ASTs.
To better understand why we might want to do this, consider the following hypothetical production rule describing `if`:


```
expr ::= 'if' '(' expr ')' '{' expr '}' 'else' '{' expr '}' | ...
```

An AST encoding `if` only needs to care about the condition, the true branch, and the false branch.
However, there is quite a bit more syntactic noise around the `if`, including the parentheses and curly braces.
This information will need to be parsed in, but it won't result in an AST.
As such, the original non-general definition of `Parser` couldn't parse in `(`, `{`, etc.: the original definition forces us to always result in an `AST`.
However, with the generic definition in mind, we can now define a parser for these components, like so:

```swift
struct Unit {}
func leftParenParser() -> Parser<Unit> { ... }
```

In this snippet above, `Unit` is just an empty `struct`; this doesn't do anything particularly useful, and serves as a sort of dummy value which can be created with `Unit()`.
With `leftParenParser`, we need a dummy value because it doesn't result in anything meaningful for us; the real work of `leftParenParser` is in checking that we have a `(` token next, and then returning a position in our list of tokens one token past the `(` (or returning nothing if we don't have a `(`).

We can still make this definition better.
Specific to the `?` part, this is referred to as [`Optional` in Swift](https://developer.apple.com/documentation/swift/optional).
Notably, if this parser fails to parse, we don't get any information about _how_ it failed.
This is tantamount to getting a syntax error without any further information: no line numbers, no position in the code where a problem was spotted, or anything.
To make this better, we will introduce a new type representing the output of the parser, shown below:

```swift
enum ParseResult<A> {
    case success(List<Token>, A)
    case failure(String)
}

typealias Parser<A> = (List<Token>) -> ParseResult<A>
```

`ParseResult` gives us strictly more information than `(List<Token>, A)` did.
Namely, we have two cases:

- `success`, representing a successful parse.
  On success, we have more tokens to parse in (`List<Token>`), as well as a value we parsed in (`A`).
- `failure`, representing an unsuccessful parse.
  This holds an error message which is intended to describe what the error was, as a `String`.

### Defining Parser Combinators - `tokenP` ###

From here, we can start to build up the primitive pieces from which we can build larger parsers.
We'll start with a relatively primitive parser: one which expects a fixed token, and succeeds if it sees the token, and fails otherwise.
This is shown below:

```swift
func tokenP(_ expectedToken: Token) -> Parser<Unit> {
    return { tokens in
        switch tokens {
        case .cons(let receivedToken, let rest):
            if expectedToken == receivedToken {
                return ParseResult.success(rest, Unit())
            } else {
                return ParseResult.failure(
                  "Expected: \(expectedToken); Received: \(receivedToken)")
            }
        case .empty:
            return ParseResult.failure("Out of tokens")
        }
    }
} // tokenP
```

`tokenP` is a function which returns a `Parser` which parses the given token.
Since `Parser` is a type alias for functions, `tokenP` itself returns a function, done with the `{ tokens in ... }` expression.
The `{ tokens in ... }` expression defines a higher-order function which takes the parameter `tokens` and returns whatever the `...` returns.
As shown, this returned higher-order function will:

- Look at the input tokens (`tokens`)
- If the tokens are non-empty, it will see if the starting token (`receivedToken`) is equal to the given token (`expectedToken`).
    - If they are equal, the parser is successful.
      The resulting `success` holds the remainder of the tokens to parse (`rest`), along with a new `Unit` value (`Unit()`).
      As previously explained, `Unit` is effectively a dummy value here; `success` requires us to put in some parsed-in value, but we don't really have any meaningful result here, so we just use `Unit` instead.
    - If they are not equal, the parser is unsuccessful.
      We return an error message saying we expected `expectedToken`, but received `receivedToken`.
- If the tokens are empty, then we definitely cannot parse in the `expectedToken`.
  As such, we return an error message saying we ran out of tokens.


### Defining Parser Combinators - `numP` ###

Next, we will define a parser that parses in an `Int`, with the expectation that integers form their own kind of token.
This is shown below:

```swift
func numP() -> Parser<Int> {
    return { tokens in
        switch tokens {
        case .cons(.integerToken(let value), let rest):
            return ParseResult.success(rest, value)
        case .cons(let received, _):
            return ParseResult.failure(
              "Expected integer token; Received: \(received)")
        case .empty:
            return ParseResult.failure("Out of tokens")
        }
    }
} // numP
```

As with `tokenP`, `numP` returns a higher-order function.
`numP` will:

- Look at the input tokens (`tokens`)
- If the tokens are non-empty and begin with `integerToken`, it extracts out the specific `Int` value held in the `integerToken`.
  It then returns success, returning the specific `Int` value, along with the remainder of the tokens (`rest`).
- If the tokens are non-empty but do *not* begin with `integerToken`, it returns an error message saying that an integer token was expected, but we instead got whatever token was received.
- If the tokens are empty, then it returns an error message saying there were no more tokens.

### Defining Parser Combinators - `andP` ###

`tokenP` and `numP` are parsers which only can handle a single token.
We need something much more powerful to handle a full language.
For this purpose, we define another routine which can _combine_ two parsers together, forming a bigger parser.
The first kind of combination we consider is analogous to logical AND: run the first parser, and on success, run the second parser.
The code implementing this is shown below:

```swift
func andP<A, B>(_ leftParser: @escaping @autoclosure () -> Parser<A>,
                _ rightParser: @escaping @autoclosure () -> Parser<B>) -> Parser<(A, B)> {
    return { tokens in
        switch leftParser()(tokens) {
        case .success(let restLeft, let a):
            switch rightParser()(restLeft) {
            case .success(let restRight, let b):
                return ParseResult.success(restRight, (a, b))
            case .failure(let error):
                return ParseResult.failure(error)
            }
        case .failure(let error):
            return ParseResult.failure(error)
        }
    }
} // andP
```

While this likely looks pretty intimidating, it's not so bad if we look at it bit-by-bit.
Let's first break down the signature:

- `func andP<A, B>`: `andP` is being defined, and it is parameterized by two type variables `A` and `B`.
- `(_ leftParser:`): it takes a parameter which will be called `leftParser` inside the body of `andP`.
  The caller does not provide an argument label (e.g., `andP(leftParser: ...)`), as underscore (`_`) was used.
- `@escaping`: This is specifically used when the following two conditions are true:
      - We are taking a parameter that's a higher-order function, and...
      - We return a higher-order function which closes over this parameter
  Without `@escaping`, the code fails to compile, and the compiler will suggest adding `@escaping` to the definition.
  See [this page](https://docs.swift.org/swift-book/LanguageGuide/Closures.html), under "Escaping Closures" for more information.
- `@autoclosure`: This says that the caller's parameter will be automatically wrapped in a function which takes no arguments and returns whatever the caller actually passed.
  In other words, if the caller wrote `andP(something, ...)`, Swift would automatically turn this into `andP({ () in something }, ...)`.
  This is effectively [call-by-name](https://en.wikipedia.org/wiki/Evaluation_strategy#Call_by_name) evaluation.
  Exactly why this is needed won't be clear at this point; the short version is that this ends up preventing infinite recursion later.
- `() -> Parser<A>`: the first parameter is a function which takes no arguments and returns a `Parser<A>`.
  Note that `Parser<A>` is a typealias for a function; expanding this out means we take `() -> ((List<Token>) -> ParseResult<A>)`.
  The outermost `() ->` is needed because of the use of `@autoclosure`; more on that later.
  The `Parser<A>` part shows that `andP` is taking a parser of `A`s as a parameter.
- `_ rightParser: @escaping @autoclosure () -> Parser<B>`: same idea as before, but now there is a second parser we take, and it parses in `B`s.
- `-> Parser<(A, B)>`: `andP` returns a parser of `(A, B)` pairs.

The overarching idea is that the given `Parser<A>` knows how to parse in `A`s, and the given `Parser<B>` knows how to parse in `B`s.
Putting them together, we parse an `A` followed by a `B`.
We save both the `A` and `B` parsed, returning an `(A, B)` pair.

We now go through the body of `andP`:

- As before, it returns a higher-order function which takes the tokens (`tokens`)
- With `leftParser()`, we call `leftParser` with no arguments.
  This gives us back a `Parser<A>`.
- We then immediately call the `Parser<A>` returned by `leftParser()` (recall that `Parser<A>` is an alias for `(List<Token>) -> ParseResult<A>`).
  We pass the input tokens `tokens`.
- We look at the result of calling the `Parser<A>`.
      - On success, we do the same sort of call with the `Parser<B>` (`rightParser`), with the remaining tokens (`restLeft`) from the `Parser<A>` (`leftParser`).
          - If that succeeds, we return success, putting the `a` and `b` from the `Parser<A>` and `Parser<B>` into a single pair of type `(A, B)`.
            The remaining tokens are what was left after `Parser<B>` succeeded (`restRight`).
          - If that fails, we fail overall, and just return the error we have
      - On failure, we fail overall, and return the error we have

Basically, `andP`, chains two parsers along sequentially.
If either fail, the whole `andP` fails.


### Defining Parser Combinators - `orP` ###

`andP` is only one way of combining two parsers.
We look at another way here: `orP`.
`orP` effectively tries a logical OR between two parsers: we try the first given parser, and if it fails, we instead try the second parser.
If the first parser succeeds, we just return the result from the first parser, without ever calling the second.
The code for `orP` is below:

```swift
func orP<A>(_ leftParser: @escaping @autoclosure () -> Parser<A>,
            _ rightParser: @escaping @autoclosure () -> Parser<A>) -> Parser<A> {
    return { tokens in
        switch leftParser()(tokens) {
        case .failure(_):
            return rightParser()(tokens)
        case let success: return success
        }
    }
} // orP
```

This has a similar signature to `andP`.
However, this time around only one generic type (`A`) is introduced, and both the provided parsers must be of this same type (`A`).
This is because, at compile time, we don't know exactly which parser will succeed, or even if any parser will succeed.
Since we don't know which parser will work, the resuling value could be from either parser.
This is only possible if both parsers give back a value of the same type, hence we have two `Parser<A>`s.

The body of `orP` is arguably the simplest one yet.
As before, this returns a higher-order function that takes input tokens (`tokens`), and then will:

- Get the leftmost parser with `leftParser()`, and call this parser with the input `tokens`.
  We then look at the result of this call.
      - If this fails, we return the result of doing the same thing with the rightmost parser.
        The rightmost parser may succeed or fail; in either case, we want to return whatever the rightmost parser returns.
      - If this succeeds, then we return whatever the leftmost parser succeeded with.


### Defining Parser Combinators - Putting it All Together ###

The file `minimal_example.swift` in this same directory builds a parser of basic arithmetic expressions using the following grammar:

```
exp ::= integer '+' exp | integer
```

Notably, this file defines:

- `integerP` for handling `integer` above, where `integer` is expected to be from a token
- `plusP` for handling `integer '+' exp`
- `expressionP` for handling the `exp` production rule overall

If compiled and run, this will parse and print the ASTs corresponding to `123`, `123 + 456`, and `123 + 456 + 789`.

Note that `expressionP` calls `plusP`, and that `plusP` called `expressionP`.
This is known as _mutual recursion_, where a function doesn't call itself directly, but rather indirectly; it is said that `expressionP` and `plusP` are mutually-recursive.
It's common to end up with mutually-exclusive definitions when defining parsers, as grammars themselves tend to be defined in mutually-recursive ways.

Depending on the input grammar, parser combinators can see problems with infinite recursion.
For example, consider the following function:

```swift
// thing ::= integer thing | integer
func parseThing() -> Parser<Thing> {
    // types don't quite work as written
    return orP(andP(integerAsThing(), parseThing()),
               integerAsThing())
}
```

As shown, `parseThing` calls itself recursively.
As `parseThing` itself has no base case, this would normally lead to infinite recursion.
However, a key observation is that the recursive call to `parseThing` is only needed if the internal `andP` and `orP` needs it, and `andP` and `orP` might not need it, depending on the input.
In other words, we only need to call `parseThing` recursively for as many `Thing`s we have in the input.
A quick fix is to make `andP` and `orP` take a _function_ that returns a `Parser<Thing>`, instead of a `Parser<Thing>` directly.
This way, `andP` and `orP` can ultimately decide if they need a `Parser<Thing>`.

Normally, we'd need to explicitly pass functions, like so:

```swift
func parseThing() -> Parser<Thing> {
    // types don't quite work as written
    return orP({ () in andP( { () in integerAsThing() }, { () in parseThing() }) },
               { () in integerAsThing() })
}
```

The syntax `{ () in ... }` defines a higher-order function that takes no parameters and returns whatever `...` returns.
This way, `andP` and `orP` can call the function as needed to yield a `Parser<Thing>`, and as long as our input is finite (and it always is in practice), we don't have infinite recursion.
However, this looks pretty ugly, and it's repetitive.

Here is where `@autoclosure` comes in.
`@autoclosure` does this for us _automatically_.
That is, when we write the first version of `parseThing`, we automatically get the second version of `parseThing`.


### On Grammar Design and S-Expressions ###

If you look closely at the output of the `expressionP` parser in `minimal_example.swift`, you may notice something odd: it parses `1 + 2 + 3` as `1 + (2 + 3)`, instead of the expected `1 + (2 + 3)`.
This issue is rooted not in our use of parser combinators, but in the very definition of the grammar itself.
That is, it's possible to define an equivalent grammar that will parse this as we expect, but the grammar would be more complex.
For our purposes, I wanted to keep things as simple as possible, therefore I went with the simple-but-slightly-wrong grammar.

Additionally, our grammar was designed to avoid [left recursion](https://en.wikipedia.org/wiki/Left_recursion), which was also vital for the use of parser combinators.
Left-recursive grammars perform recursion on the same production rule without reading anything in, like so:

```
expr ::= integer | expr '+' expr
```

Notably, the right production of `expr` (`expr` '+' `expr`) uses `expr` recursively before reading anything.
With parser combinators (and some other parsing algorithms), this ends up resulting in infinite recursion.
Specifically, parser combinators will keep recursively trying `expr`, and because this second production doesn't read any tokens before making the next recursive call, it will never make any progress.

The usual fix for this problem is to change the grammar itself so it's no longer left-recursive.
[An algorithm exists for removing left recursion](https://en.wikipedia.org/wiki/Left_recursion#Removing_left_recursion), though the end result usually isn't as readable as what we started with.

For our purposes, with the [third assignment](https://kyledewey.github.io/comp333-fall19/assignments/assign_3/), I wanted to keep the grammar simple to read, but also realistic and feasible to parse directly with parser combinators.
In order to achieve all these goals, the grammar used in assignment 3 is based on [S-expressions](https://en.wikipedia.org/wiki/S-expression).
Notably, S-expressions require parentheses to be used whenever operations are performed, which leads to naturally unambiguous representations.
As such, we don't need to modify the grammar in any way to embed precedence.
Additionally, the operation is placed before the operands.
For example, `1 + 2` becomes `(+ 1 2)`.
Since expresions with operations are always proceeded by a left parenthesis, this prevents any issues involving left recursion from occurring; nested expressions are always guaranteed to start with a left parenthesis, so we always at least need to read a left parenthesis, forcing progress to be made at every step.

While S-expressions may look strange, the entire [Lisp](https://en.wikipedia.org/wiki/Lisp_(programming_language)) family of languages uses a syntax based on S-expressions, including [Scheme](https://en.wikipedia.org/wiki/Scheme_(programming_language)), [Clojure](https://clojure.org/), and [Racket](https://racket-lang.org/).
