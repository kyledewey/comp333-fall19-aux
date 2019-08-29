public class ConsoleDestination implements OutputDestination {
    public ConsoleDestination() {}
    public void writeThing(String thing) {
        System.out.println(thing);
    }
}
