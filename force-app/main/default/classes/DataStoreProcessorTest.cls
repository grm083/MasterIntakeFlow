//Purpose: Test class for DataStoreProcessor 
//Author: Gunjan Shah - Coforge
//CreatedDate: 13-Oct-2025

@isTest(seeAllData = false)
public class DataStoreProcessorTest {

    @testSetup static void setup(){
        Profile p = TestDataFactory.getProfile('System Administrator');
        User usr = TestDataFactory.createUser(p);
        Database.insert(usr);
        
        system.runAs(usr){
            list<Account> acclist = TestDataFactory.createAccount('test', usr);
            Database.insert(acclist);

            list<Account> locationlist = TestDataFactory.createLocation('Location', usr, acclist.get(0).id);
            Database.insert(locationlist);
        }
    }

    @isTest public static void testConvertAndInsertToDataStore() {
        List<Account> accountList = [SELECT ID FROM Account LIMIT 1];
        List<Account> locationlist = [SELECT ID, Name FROM Account WHERE ParentId =:accountList[0].ID];
        String relatedRecordId = accountList[0].Id;
        DataStoreProcessor dataProcessor = new DataStoreProcessor();
        
        Test.startTest();
        String result = dataProcessor.convertAndInsertToDataStore(locationlist, relatedRecordId);
        Test.stopTest();

        System.assertEquals(result, 'SUCCESS');
    }
    
    @isTest public static void testreconstructJson() {
        List<Account> accountList = [SELECT ID FROM Account LIMIT 1];
        List<Account> locationlist = [SELECT ID, Name FROM Account WHERE ParentId =:accountList[0].ID];
        String relatedRecordId = accountList[0].Id;
        DataStoreProcessor dataProcessor = new DataStoreProcessor();
        dataProcessor.convertAndInsertToDataStore(locationlist, relatedRecordId);

        Test.startTest();
        List<Account> dsbundles = (List<Account>) dataProcessor.reconstruct(list<Account>.class, relatedRecordId);
        Test.stopTest();

        System.assertEquals(dsbundles.size(), 1);
    }

    @isTest public static void  testGetFieldsAsCommaSeparatedString() {
        Test.startTest();
        DataStoreProcessor.getFieldsAsCommaSeparatedString('Account');
        Test.stopTest();
    }
}