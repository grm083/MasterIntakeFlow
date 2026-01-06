@isTest
public class BooleanStringConverterTest {

    static testMethod void testBoolReplace() {
    	
        List<String> userNotes = new List<string>();
    	userNotes.add('True');
        userNotes.add('true');
    	userNotes.add('False');
        userNotes.add('false');
        
        List<String> returnedNotes = BooleanStringConverter.replaceTrueFalse(userNotes);
        system.assertEquals('Yes', returnedNotes.get(0));
        system.assertEquals('Yes', returnedNotes.get(1));
        system.assertEquals('No', returnedNotes.get(2));
        system.assertEquals('No', returnedNotes.get(3));
        system.assert(returnedNotes != null);
    
    }
    
}