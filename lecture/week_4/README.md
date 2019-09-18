# Functional Programming and Higher-Order Functions #

Here we introduce _functional programming_, which is a whole programming paradigm (way of thinking about programming).
Functional programming discourages, or even outright prevents, mutable state.
That is, reassigning the value of a variable (usually via `=`) is discouraged or disallowed.
While this can be restrictive, it can make code easier to reason about: a variable will *always* have the same value.

Functional programming gets its namesake from _higher-order functions_, which is a key language feature.
All functional languages support higher-order functions, and even most modern non-functional languages support higher-order functions too.

Higher-order functions (AKA closures, anonymous functions, lambdas) allow us to abstract over computation directly.
The idea is that functions themselves are values.
Like values, functions can now be passed as parameters, and even returned from other functions.

## Taking a Function as a Parameter ##

From the first assignment, you saw the following code in the test suite:

```javascript
function runTest(test) {
    process.stdout.write(test.name + ": ");
    try {
        test();
        process.stdout.write("pass\n");
    } catch (error) {
        process.stdout.write("FAIL\n");
        console.log(error);
    }
} // runTest
function test_nil_instanceof_list() {
    // code that performs actual test
}
function runTests() {
    runTest(test_nil_instanceof_list);
    // more tests follow...
}
```

Look closely at the call to `runTest`.
Notably, the call to `runTest` takes `test_nil_instanceof_list` as a *parameter*; we do *not* call `test_nil_instanceof_list` here.
This code takes advantage of higher-order functions, and is treating the `test_nil_instanceof_list` function as a parameter.
`runTest` itself will call the passed function, specifically with the line `test()`.
This separation allows us to run the test in a try/catch block within `runTest`, allowing us to avoid putting each individual test in its own try/catch block.

Phrased another way, higher-order functions allow us to treat whole computations as parameters with a minimum amount of code.
`runTest` treats the test itself to run as a parameter, where each test executes its own specific code.

## Returning a Function as a Value ##

Functions can also be returned from other functions.
For example, consider the following JavaScript code:

```javascript
function addThis(x) {
  return function (y) {
    return x + y;
  }
}

let addFive = addThis(5);
addFive(6);
```

This code snippet returns `11`, indicating that we ended up computing `5 + 6`.
However, we did this in two steps:

1. `addThis(5)` was called, which returns a function.
   The function returned itself takes a parameter `y`, and the returned function will add `y` to `addThis`' parameter `x`.
2. The function from `addThis(5)` was called with parameter `6`.
   The function returned from `addThis(5)` saved the value of `x` it was passed (namely `5`), and computed `5 + 6`.

## Aside: Compared to First-Order Functions ##

Higher-order functions are in contrast to first-order functions, wherein functions are not treated like values.
For example, C has first-order functions.
First-order functions may allow us to pass around _function pointers_ as values, but not whole functions.
Function pointers differ from whole functions in that these cannot save the values of any variables which were in scope.
For example, with the code snippet above, function pointers alone could not save `x`, so we could not implement the above code directly in C.

Higher-order functions which use saved variables are called _closures_, because they "close over" the variables which they use.

## Toy Examples ##

- `sets.js` (in the same directory) implements sets using higher-order functions.
  We can think of sets as functions that take an element, and return a boolean saying whether or not the element is in the set.
  With this approach, sets themselves become functions.
  The empty set is a function that always returns false.
  We can "add" an element to a set by returning a new set/function that wraps around an existing set/function, where the wrapped version will either return `true` if the passed element is equal to the added element, or will otherwise call the existing set/function.
- `maps.js` (in the same directory) implements maps using higher-order functions.
  Maps use the same sort of idea as sets, but now we have values associated with each element as opposed to booleans.

## Practical Application: Array/List Manipulation ##

Higher-order functions are commonly used to manipulate arrays and lists in many languages, including languages which are not traditionally functional.
A key observation is that the majority of loops perform certain common operations, or compositions of common operations, like:

### Looking for Certain Elements ###

```java
for (int x = 0; x < arr.length; x++) {
  if (elementIsSignificant(arr[x])) {
    // ...
  }
}
```

### Processing Each Element Independently ###

```java
for (int x = 0; x < arr.length; x++) {
  doSomething(arr[x]);
}
```

### Creating Parallel Arrays ###

```java
double[] result = new double[arr.length];
for (int x = 0; x < arr.length; x++) {
  result[x] = computeSomething(arr[x]);
}
```

### Building a Single Result Using Each Element ###

```java
int sum = 0;
for (int x = 0; x < arr.length; x++) {
  sum = sum + arr[x];
}
```

In each of the above snippets, most of the code for the loop itself is boilerplate.
Each task only requires a relatively small part of the written code to be changed to adapt it to another similar problem.
Since higher-order functions allow us to pass computations as parameters, we can _abstract over_ computations; that is, we can define functions which perform the above operations, but treat the differing snippet as a parameter.
With the help of these defined functions, we can largely eliminate loops from our programs.

JavaScript's standard library already has all of these operations built-in.
These are listed below:


- *Looking for certain elements.*
  [`Array.prototype.filter`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/filter) takes a higher-order function to select specific elements from an array.
  The passed higher-order function takes an element, returning `true` if it should be selected, else `false`.
  In the prior code snippet, `elementIsSignificant` acts as the passed function, and `filter` will return an array containing all the elements for which `elementIsSignificant` returns `true`.
- *Processing each element independently.*
  [`Array.prototype.forEach`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/forEach) takes a higher-order function which is called on each element from an array.
  In the prior code snippet, `doSomething` acts as the passed function.
- *Creating parallel arrays.*
  [`Array.prototype.map`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/map) takes a higher-order function to transform values in a parameter array to values in a returned array.
  The passed higher-order function takes an element from the parameter array, and returns what the new element should be in the result array.
  In the prior code snippet, `computeSomething` acts as the passed function.
- *Building a single result using each element.*
  [`Array.prototype.reduce`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/Reduce) takes a starting _accumulator_, as well as a function that takes the current accumulator and the current element of the array.
  Given this information, the passed function will compute the new value of the accumulator.
  In the prior code snippet, the initial accumulator is `0`, and `sum` represents the accumulator.
  The function itself computes `sum + arr[x]`.
  `reduce` is very powerful; all the prior operations can be implemented in terms of `reduce`.

