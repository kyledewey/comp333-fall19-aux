public class FileDestination implements OutputDestination {
    private FileOutputStream stream;

    public class FileDestination(String destination) {
        stream = new FileOutputStream(new File(destination));
    }

    public void writeThing(String thing) {
        stream.writeln(thing);
    }
}
