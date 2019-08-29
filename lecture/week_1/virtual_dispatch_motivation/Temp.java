public class Temp {
    public static OutputDestination makeDestination(String[] args) {
        boolean userWantsConsole = doesUserWantConsole(args);
        String fileDestination = fileDestination(args);
        
        if (userWantsConsole) {
            return new ConsoleDestination();
        } else {
            return new FileDestination(fileDestination);
        }
    }
    
    public static void main(String[] args) {
        OutputDestination destination = makeDestination(args);
        
        // some computation
        destination.writeThing("Thing to write");
        
        // some other computation
        destination.writeThing("Other thing to write");
    }
}
