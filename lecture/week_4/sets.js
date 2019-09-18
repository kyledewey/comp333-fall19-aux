// Idea: a set is representable via a function that:
// - Takes an element
// - Returns true if the element is in the set, and...
// - Returns false if the element is not in the set.

function emptySet() {
    return false;
} // emptySet

function addSet(existingSet, addElement) {
    return function (element) {
        if (addElement === element) {
            return true;
        } else {
            return existingSet(element);
        }
    };
} // addSet

// ---BEGIN TEST SUITE---
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
        
function assertEquals(expected, received) {
    if (expected !== received) {
        throw ("\tExpected: " + expected.toString() + "\n" +
               "\tReceived: " + received.toString());
    }
} // assertEquals

function test_empty_set_is_empty() {
    let set = emptySet;
    assertEquals(false,
                 set(1));
} // test_empty_set_is_empty

function test_singleton_set_contains_own_element() {
    let set = addSet(emptySet, 1);
    assertEquals(true,
                 set(1));
} // test_singleton_set_contains_own_element

function test_singleton_set_does_not_contain_other_element() {
    let set = addSet(emptySet, 1);
    assertEquals(false,
                 set(2));
} // test_singleton_set_does_not_contain_other_element

function test_two_set_contains_first() {
    let set = addSet(addSet(emptySet, 1), 2);
    assertEquals(true,
                 set(2));
} // test_two_set_contains_first

function test_two_set_contains_second() {
    let set = addSet(addSet(emptySet, 1), 2);
    assertEquals(true,
                 set(1));
} // test_two_set_contains_second

function test_two_set_does_not_contain_other_element() {
    let set = addSet(addSet(emptySet, 1), 2);
    assertEquals(false,
                 set(3));
} // test_two_set_does_not_contain_other_element

function test_set_contains_same_element_twice_and_contains() {
    let set = addSet(addSet(emptySet, 1), 1);
    assertEquals(true,
                 set(1));
} // test_set_contains_same_element_twice_and_contains

function test_set_contains_same_element_twice_does_not_contain_other() {
    let set = addSet(addSet(emptySet, 1), 1);
    assertEquals(false,
                 set(2));
} // test_set_contains_same_element_twice_does_not_contain_other

function runTests() {
    runTest(test_empty_set_is_empty);
    runTest(test_singleton_set_contains_own_element);
    runTest(test_singleton_set_does_not_contain_other_element);
    runTest(test_two_set_contains_first);
    runTest(test_two_set_contains_second);
    runTest(test_two_set_does_not_contain_other_element);
    runTest(test_set_contains_same_element_twice_and_contains);
    runTest(test_set_contains_same_element_twice_does_not_contain_other);
} // runTests

