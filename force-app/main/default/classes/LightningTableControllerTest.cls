/**
* @author Dinesh Kumar S
* @date 4/19/2019
* @description : Apex class LightningTableControllerTest
**/

/* test class for LightningTableController apex class*/
@isTest(seeAllData = false)
public class LightningTableControllerTest {
    private static final string SYS_ADMIN = 'System Administrator';
    private static final string KROGER = 'kroger';
    private static final string OBJECT_NAME = 'Approval_Log__c';
    private static final string FIELDSET_NAME = 'approvallogfieldset';
    private static final string FIELD_NAME_JSON = '["Name","CaseId__c","CaseId__r.CaseNumber"]';
    private Static final string PARENT_FIELD_NAME = 'CaseId__c';
    private static final string CASE_NAME = 'First';
    private static final string RITA = 'Rita';
    private static final string REPLY = 'Reply';
    private static final string PRODUCT = '8 yrd';
    private static final string ASSET_NAME = '8 yrd Dumpster';
    /* set up the test data*/
    @testSetup static void setup() {
        Profile p = TestDataFactory.getProfile(SYS_ADMIN);
        User usr = TestDataFactory.createUser(p);
        Database.insert(usr);
        system.runAs(usr){
            list<Account> acclist = TestDataFactory.createAccount(KROGER, usr);
            Database.insert(acclist);
			list<Account> locationlist = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, acclist.get(0).id);
            Database.insert(locationlist);
            list<Contact> conlist = TestDataFactory.createContact(RITA, REPLY, acclist.get(0), usr);
            Database.insert(conlist);
            list<product2> productlist = TestDataFactory.createProduct(PRODUCT);
            Database.insert(productlist);
            list<Asset> assetlist = TestDataFactory.createAsset(ASSET_NAME, acclist.get(0), conlist.get(0), 
                                                                productlist.get(0), usr, locationlist.get(0));
            Database.insert(assetlist);
            list<Case> caselist = TestDataFactory.createCase(CASE_NAME, acclist.get(0), conlist.get(0), 
                                                             usr, locationlist.get(0), assetlist.get(0));
            Database.insert(caselist);
            list<Approval_Log__c> approvalLoglist = TestDataFactory.createApprovallog(caselist[0].Id);
            Database.insert(approvalLoglist);
        }
    }
    /* test method for getting the service approver*/ 
    @isTest static void getFieldSetTest(){
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        
        system.runAs(currentuser){
            Test.startTest();
            	String result = LightningTableController.getFieldSet(OBJECT_NAME,FieldSET_NAME);
            List<case> caselist = [Select Id from case Limit 1];
            list<Approval_Log__c> approvalLoglst = [Select id,CaseId__c from Approval_Log__c Limit 1];
            	LightningTableController.getRecords(OBJECT_NAME,PARENT_FIELD_NAME,caselist[0].Id,FIELD_NAME_JSON);
            Test.stopTest();
            system.assert(result != null);
        }
    }
    /* test method for getting the service approver */
    @isTest static void exceptionhandlingTest(){
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        
        system.runAs(currentuser){
            Test.startTest();
            	String result = LightningTableController.getFieldSet(null,FieldSET_NAME);
            
            	LightningTableController.getRecords(OBJECT_NAME,PARENT_FIELD_NAME,null,null);
            Test.stopTest();
            system.assert(result != null);
        }
    }
}