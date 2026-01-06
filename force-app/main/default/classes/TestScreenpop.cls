@isTest
public class TestScreenpop {
    
    @isTest
    static void testToString() {
        Screenpop pop = new Screenpop();
        String sPop = pop.toString();
        System.assert(sPop != null && sPop.length() > 0);
    }

}