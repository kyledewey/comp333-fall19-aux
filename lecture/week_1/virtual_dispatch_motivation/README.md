# Virtual Dispatch Motivation and Example #

We wrote this code in class on 8/28, starting from
a bit of low-quality code in `main` in `Temp.java`.
Note that this is incomplete and does not compile
(notably, it's missing the `doesUserWantConsole` and
`fileDestination` methods in `Temp.java`), but it
still illustrates the sort of problem that virtual
dispatch solves.

## Problem ##

We have a program that can output to either the console
or to a file.  The user selects which destination they
want when the program begins.  As the program progresses,
output is incrementally written to whatever source was
selected by the user.

## Original Code ##

We started with code like the following:

```java
public class Temp {
  public static void main(String[] args) {
    boolean userWantsConsole = doesUserWantConsole(args);
    String destinationFile = getDestinationFile(args);

    // do some computation
    
    if (userWantsConsole) {
      System.out.println("Thing to write");
    } else {
      File file = new File(destinationFile);
      FileOutputStream stream = new FileOutputStream(file);
      stream.writeln("Thing to write");
      stream.close()
    }
  }
}
```

There are some major issues with this code:

- Code to write things is intermixed with computation code
- If we want to write something out multiple times, we'll need to
  duplicate this code
- The stream should be kept open and closed only at the very end;
  opening and closing files is not cheap, and we only need to do
  each of these operations once

After some incremental steps, we cleaned up the code, leading to
the following:

```java
public class Temp {
  FileOutputStream stream = null;

  public static void writeThing(String thingToWrite,
                                boolean userWantsConsole,
                                String destinationFile) {
    if (userWantsConsole) {
      System.out.println(thing);
    } else {
      if (stream == null) {
        File file = new File(destinationFile);
        stream = new FileOutputStream(file);
      }
      stream.writeln(thing);
    }
  }
  
  public static void main(String[] args) {
    boolean userWantsConsole = doesUserWantConsole(args);
    String destinationFile = getDestinationFile(args);

    // do some computation

    writeThing("Thing to write", userWantsConsole, destinationFile);
    
    // do some more computation
    
    writeThing("Other thing to write", userWantsConsole, destinationFile);
  }
}
```

This code is better, but it still has some problems:

- `userWantsConsole` and `destinationFile` repeatedly get passed
- The `if` condition in `writeThing` is checked every single time we
  go to write something, even though the output destination is fixed
  once the program starts.  That is, the condition will always evaluate
  to the same result as the program goes on.
- If we add more destinations, `writeThing` will need to change, and this
  `if` will keep getting bigger.  We can use `switch`, but we still have
  the same problem of needing to check a bunch of cases each time we
  print.
- The `stream` variable currently is accessible by anything that can
  access `Temp`.  `stream` is specifically only relevant when the
  destination is a file, and further only relevant to the handful of lines
  in `writeThing` that use `stream`.  However, `stream` is accessible to
  everything currently.

## Classes to the Rescue ##

A key observation is that the output destination does not change once the
program starts.  With this in mind, it doesn't make sense to keep checking
the destination.  Similarly, it doesn't make sense to keep passing
`userWantsConsole` and `destinationFile` around; these parameters will
keep getting used in the same way, and they don't change.

Effectively, we want to set what the output behavior is once, and keep
that behavior throughout program execution.  With dynamic dispatch, we
can do just that.  We solved this problem here by introducing the
`OutputDestination` interface (effectively an `abstract class`, if you're
unfamiliar with Java interfaces).  The `OutputDestination` interface
has a single method for writing something, which takes only the string
to write.  We then define two classes which implement `OutputDestination`,
namely `ConsoleDestination` and `FileDestination`.  Each one of these
classes contains state and code only relevant to the specific output
destination it deals with (e.g., `FileDestination` contains `stream`, but
`ConsoleDestination` does not).  In `Temp`, the `makeDestination` will
create and return the right destination, depending on the parameters.
While there _is_ an `if` here, this condition is only ever evaluated
once; the returned `OutputDestination` instance "knows" what kind of
destination it is, and doesn't need to keep checking this.

## Where is the Virtual Dispatch? ##

The actual virtual dispatch part occurs at the calls to
`destination.writeThing` in the `main` method in `Temp.java`.
At compile time, we don't know which `writeThing` method is being
called; it could be either `FileDestination`'s `writeThing` or
`ConsoleDestination`'s `writeThing`.  However, at runtime, we will
definitely call one of these methods, determined by the specific
object returned by `makeDestination`.  The "virtual dispatch" part
specifically refers to this process by which the Java Virtual Machine
figures out which method to call at runtime.  This is also called
"dynamic dispatch", "ad-hoc polymorphism", or simply "polymorphism".
(Note that "polymorphism" is more broad than just virtual dispatch,
though it's sometimes treated synonymously with virtual dispatch.)

It's likely that you've never heard the term "virtual dispatch", but
if you're used to abstract classes or interfaces, you're already
familiar with the concept.  In object-oriented languages, this is how
we get fundamentally different behaviors when the "same" method is
called (i.e., `writeThing` does dramatically different things depending
on what specifically we called it on, but the caller doesn't need to
worry about this).

## Relationship to Other Languages ##

The idea of getting different behaviors come out of the same call is
not unique to object-oriented languages.  Notably, higher-order functions
(which predate object-oriented languages by several decades) allow for
different behaviors in a more direct way.  Higher-order functions are
closely tied to functional programming, and we will see these a bit
later in the course.

