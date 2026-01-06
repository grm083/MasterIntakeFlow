/*************************************************************
@Name: BatchToUpdateCaseStatusTest
@Author: Shilpa Bhatia
@CreateDate: 09/04/2020
@Description: Test class of BatchToUpdateCaseStatus
**************************************************************/

@isTest
public class BatchToUpdateCaseStatusTest {
	
    private static final string SYS_ADMIN = 'System Administrator';
    private static final string PRODUCT = '8 yrd';
    private static final string KROGER = 'kroger';
    private static final string RITA = 'Rita';
    private static final string REPLY = 'Reply';
    private static final string TESTSUPPLIER = 'testsupplier';
    private static final string SUPPLIER = 'Vendor';
    private static final string ASSET_NAME = '8 yrd Dumpster';
    private static final string CASE_NAME = 'First';       
    private static final string EMPTY_AND_DO_NOT_RETURN = 'Empty and Do NOT Return';
    private static final string NAME = 'test';
    private static final string NAME1 = 'test1';   
    private static final string PENDING_APPROVAL = 'Pending Approval';
    private static final string REPAIRS = 'Repairs';
    private static final string PROJECT_VALUE = '123';
    private static final string COMPACTOR = 'COMPACTOR';       
    private static final string COMMERCIAL = 'Commercial';
    private static final string NY_TIMEZONE = 'America/New_York';
    
     
    // method for setting up data    
    @testSetup static void setup() {
   		List<User> testRunUserList = new List<User>();

        Profile p = TestDataFactory.getProfile(SYS_ADMIN);

        User usr = TestDataFactory.createUser(p);
        usr.Bypass_Validation__c = true;
        testRunUserList.add(usr);
       
        System.runAs(usr){
            List<Account> acclist = TestDataFactory.createAccount(KROGER, usr,Constant_Util.CLIENT);
            acclist[0].AccountNumber = 'HMD';
            
            Database.insert(acclist);
            
            List<Account> locationlist = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, acclist.get(0).id);
            
            locationlist[0].tz__Timezone_SFDC__c = NY_TIMEZONE;
            locationlist[0].tz__UTF_Offset__c = -4;
            Database.insert(locationlist);
            
            List<Contact> conlist = TestDataFactory.createContact(RITA, REPLY, acclist.get(0), usr);
            Database.insert(conlist);
            
            List<product2> productlist = TestDataFactory.createProduct(PRODUCT);
            productlist[0].Family = COMMERCIAL;
            productlist[0].ProductTypeSelected__c = COMPACTOR;
            Database.insert(productlist);
            
            list<Account> supplieracclist = TestDataFactory.createAccount(TESTSUPPLIER , usr, SUPPLIER);
            supplieracclist[0].AccountNumber = '600';
            Database.insert(supplieracclist);
            
            List<Project_Code__c> pCodeList = TestDataFactory.createProjectCode(acclist.get(0).Id);
            Database.insert(pCodeList);
            
            List<Asset> assetlist = TestDataFactory.createAsset(ASSET_NAME, acclist.get(0), conlist.get(0), productlist.get(0), usr, locationlist.get(0));
            assetlist[0].Supplier__c = supplieracclist[0].Id;
            assetlist[0].Project_Code__c = pCodeList[0].Id; 
            Database.insert(assetlist);

           // This will return a caseList with 4 cases of Case Type = Pickup
            // and Case Sub Type = Extra Pickup
            List<Case> caselist = TestDataFactory.createCase(CASE_NAME, acclist.get(0), conlist.get(0), usr, locationlist.get(0), assetlist.get(0));
            Database.insert(caselist);               
	}
  }      
    
    @isTest static void batchToUpdateCaseStatusTest(){
        
        List<Case>cslst = [Select id,CreatedDate from Case limit 4];
        
            cslst[0].status = 'Open';
            cslst[0].Case_Sub_Status__c = 'Integration Error';
        	cslst[1].status = 'Open';
            cslst[1].Case_Sub_Status__c = 'Integration Error';
        	cslst[2].status = 'Open';
            cslst[2].Case_Sub_Status__c = 'Integration Error';
             update cslst;
    
        Database.BatchableContext dbc;
       
        String cronexp = '0 0 0 * * ?';
        BatchToUpdateCaseStatus b = new BatchToUpdateCaseStatus();
        b.execute(dbc,cslst);
        Database.executeBatch(b);
        
        Test.startTest();
        
        String jobId = System.schedule('BatchToUpdateCaseStatus',  cronexp, new BatchToUpdateCaseStatus());
        CronTrigger cronTrgr = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId Limit 1];
        
        Test.stopTest();
        
        System.assertEquals(0, cronTrgr.TimesTriggered);
    
    }
}