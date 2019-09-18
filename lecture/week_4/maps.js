// Idea: a map is representable via a function that:
// - Takes an element
// - Returns the value corresponding to that element if it's in the map, and...
// - null otherwise

function emptyMap() {
    return null;
} // emptyMap

function addMap(existingMap, addKey, addValue) {
    return function (key) {
        if (addKey === key) {
            return addValue;
        } else {
            return existingMap(key);
        }
    };
} // addMap

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

function test_empty_map_is_empty() {
    let map = emptyMap;
    assertEquals(null,
                 map(1));
} // test_empty_map_is_empty

function test_singleton_map_contains_own_element() {
    let map = addMap(emptyMap, 1, "foo");
    assertEquals("foo",
                 map(1));
} // test_singleton_map_contains_own_element

function test_singleton_map_does_not_contain_other_element() {
    let map = addMap(emptyMap, 1, "foo");
    assertEquals(null,
                 map(2));
} // test_singleton_map_does_not_contain_other_element

function test_two_map_contains_first() {
    let map = addMap(addMap(emptyMap, 1, "foo"), 2, "bar");
    assertEquals("bar",
                 map(2));
} // test_two_map_contains_first

function test_two_map_contains_second() {
    let map = addMap(addMap(emptyMap, 1, "foo"), 2, "bar");
    assertEquals("foo",
                 map(1));
} // test_two_map_contains_second

function test_two_map_does_not_contain_other_element() {
    let map = addMap(addMap(emptyMap, 1, "foo"), 2, "bar");
    assertEquals(null,
                 map(3));
} // test_two_map_does_not_contain_other_element

function test_map_overwrite_contains() {
    let map = addMap(addMap(emptyMap, 1, "foo"), 1, "bar");
    assertEquals("bar",
                 map(1));
} // test_map_overwrite_contains

function test_map_overwrite_does_not_contain() {
    let map = addMap(addMap(emptyMap, 1, "foo"), 1, "bar");
    assertEquals(null,
                 map(2));
} // test_map_overwrite_does_not_contain

function runTests() {
    runTest(test_empty_map_is_empty);
    runTest(test_singleton_map_contains_own_element);
    runTest(test_singleton_map_does_not_contain_other_element);
    runTest(test_two_map_contains_first);
    runTest(test_two_map_contains_second);
    runTest(test_two_map_does_not_contain_other_element);
    runTest(test_map_overwrite_contains);
    runTest(test_map_overwrite_does_not_contain);
} // runTests
