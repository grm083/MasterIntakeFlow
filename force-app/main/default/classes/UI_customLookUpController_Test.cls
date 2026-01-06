@isTest(seeAllData = false)
public class UI_customLookUpController_Test {
    private static final string COMPACTOR = 'COMPACTOR';
    private static final string COMMERCIAL = 'Commercial';
    private static final String PICKUP = 'Pickup';
    private static final String NUM_123 = '123';
    @testSetup static void setup() {
        Profile p = TestDataFactory.getProfile('System Administrator');
        User usr = TestDataFactory.createUser(p);
        Database.insert(usr);
        system.runAs(usr){
            list<Account> acclist = TestDataFactory.createAccount(Constant_Util.KEYWORD_TEST, usr);
            Database.insert(acclist);
            list<Account> locationlist = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, acclist.get(0).id);
            Database.insert(locationlist);
            list<Contact> conlist = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST,Constant_Util.CONSTANT_LAST, acclist.get(0), usr);
            Database.insert(conlist);
            list<product2> productlist = TestDataFactory.createProduct(Constant_Util.KEYWORD_TEST);
            productlist[0].ProductTypeSelected__c = COMPACTOR;
            productlist[0].Family = COMMERCIAL;
            Database.insert(productlist);
            list<Asset> assetlist = TestDataFactory.createAsset(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                                productlist.get(0), usr, locationlist.get(0));
            Database.insert(assetlist);
            list<Case> caselist = TestDataFactory.createCase(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                             usr, locationlist.get(0), assetlist.get(0));
            caselist[0].Service_Date__c = system.today() + 1;
            caselist[0].Case_Sub_Status__c = Constant_Util.INTEGRATION_ERROR;
            caselist[0].Tracking_Number__c = NUM_123;
            
            Database.insert(caselist);
        }
    }
    @isTest static void filedWrapperDataSetTest(){
        //test class errors - SDT - 33363
        User currentuser = [Select id,isActive from User WHERE isActive = TRUE limit 1];
        system.runAs(currentuser){
            Test.startTest();
            case caseRec = [Select Id FROM Case  Limit 1];
            List < sObject > sobjListUser = UI_customLookUpController.fetchLookUpValues('Mike','User',caseRec.Id);
            List < sObject > sobjListAccount = UI_customLookUpController.fetchLookUpValues('Mike','Account',caseRec.Id);
            system.assert(!sobjListUser.isEmpty());
            Test.stopTest();
            
        }
    }
}