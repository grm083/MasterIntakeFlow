@isTest
public class DuplicateContactMergeBatchTest {

    @testSetup static void setup(){
        Profile prof = TestDataFactory.getProfile('System Administrator');
        User currentUser = TestDataFactory.createUser(prof);
        Database.insert(currentUser);
        
        system.runAs(currentUser){
            List<Account> accList = TestDataFactory.createAccount('Kroger' , currentUser, Constant_Util.CLIENT);
            Database.insert(accList);
            List<Contact> conList = new List<Contact>();
            Contact con1 = new Contact(FirstName = 'test first' , LastName = 'test last',
                                        Accountid = accList[0].id, Email='testfrom@test.com');
            Contact con2 = new Contact(FirstName = 'test first', LastName = 'test last',
                                        Accountid = accList[0].id, Email='testfrom@test.com');

            conlist.add(con1);     
            conlist.add(con2);                            
            Database.insert(conList);
        }
    }

    @isTest static void testDuplicateMergeScheduler(){
        List<Contact> contacts = [Select Id, FirstName, LastName, Email, Phone FROM Contact];
        insertDuplicateRecordSet(contacts);
        Test.startTest();
        DuplicateContactMergeBatch sh1 = new DuplicateContactMergeBatch();
        String cron = '0 0 23 * * ?'; 
        system.schedule('Test Contact Duplicate Check', cron, sh1); 
        Test.stopTest(); 
    }    

    @isTest static void testDuplicateMergeBatch(){
        List<Contact> contacts = [Select Id, FirstName, LastName, Email, Phone FROM Contact];
        insertDuplicateRecordSet(contacts);

        Test.startTest();
        DuplicateContactMergeBatch mergeBatch = new DuplicateContactMergeBatch();
		Database.executeBatch(mergeBatch , 1);
        Test.stopTest(); 
        //system.assertEquals(1, [Select Id, FirstName, LastName, Email, Phone FROM Contact].size());
    }    

    private static void insertDuplicateRecordSet(List<Contact> contacts) {
        DuplicateRule rule = [ SELECT id FROM DuplicateRule 
                                WHERE ID = :System.Label.ContactDuplicateRuleId LIMIT 1 ];
      
        DuplicateRecordSet drs = new DuplicateRecordSet(duplicateRuleId = rule.id);       
        insert drs;

        List<DuplicateRecordItem> items = new List<DuplicateRecordItem>();    
        for ( Contact cnt : contacts ) {
            items.add( new DuplicateRecordItem(
                duplicateRecordSetId = drs.id,
                recordId = cnt.id
            ));
        }
        insert items;    
    }
}