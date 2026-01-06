@isTest(seeAllData = false)
public class assetCustomTreeGridController_Test {
    public static final string SYS_ADMIN = 'System Administrator';
    private static final string OTHER ='Other';
    private static final String LOCATION = 'Location';
    private static final string TEST_NAME ='Test';
    private static final String NUM_123 = '123';
    private static final string REQ_INFO ='PSI ;PO NUMBER;Profile Number';
    private static final String CONTACT_NOT_ONSITE = 'Contact Not Onsite';
    private static final string COMPACTOR = 'COMPACTOR';
    private static final string COMMERCIAL = 'Commercial';
    private static final String PICKUP = 'Pickup';
    private static final String SUBJECT = 'Pending Information';
    
    // method for setting up data    
    @testSetup static void setup() {
        Profile p = TestDataFactory.getProfile(SYS_ADMIN);
        User usr = TestDataFactory.createUser(p);
        usr.User_categorization_code__c = 'CSGEN';
        
        
        Database.insert(usr); 
        system.debug('CCC' + usr.User_categorization_code__c);
        
        system.debug(usr.ProfileId);
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

        }
    }
    @isTest static void getAssetRecordsTest(){
        user currentuser = [select id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        system.runAs(currentuser){
            list<Account> locationlist = [select Id from Account limit 1];
            Test.startTest();
            List<Asset>  assetListReturn = assetCustomTreeGridController.getAssetRecords(locationlist[0].Id);
              system.debug(assetListReturn);
            Test.stopTest();
        }
    }
    
}