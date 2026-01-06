/*************************************************************
@Name: IVRExitControllerTest
@Author: DineshKumar S
@CreateDate: 10/10/2019
@Description: Test class for IVRExitController
@UsedBy: IVRExitController
*************************************************************/
@isTest(seeAllData = false)
public class IVRExitControllerTest {
    private static final string SYS_ADMIN = 'System Administrator'; 
    private static final string PRODUCT = '8 yrd';
    private static final string KROGER = 'kroger';
    private static final string RITA = 'Rita';
    private static final string REPLY = 'Reply';
    private static final string TESTSUPPLIER = 'testsupplier';
    private static final string SUPPLIER = 'Vendor';
    private static final string ASSET_NAME = '8 yrd Dumpster';
    private static final string COMPACTOR = 'COMPACTOR';
    private static final string CASE_NAME = 'First';
    private static final string PO_NUMBER = '1243';
    private static final string SENT = 'Sent';
    private static final string COMMERCIAL = 'Commercial';
    private static final string SCHEDULED = 'Scheduled';
    private static final string PICKUP = 'Pickup';
    public static final String MEDIA_TYPE_VOICE = 'voice';
    /* set the test data*/
    @testSetup static void setup() {
        Profile p = TestDataFactory.getProfile(SYS_ADMIN);
        User usr = TestDataFactory.createUser(p);
        usr.bypass_validation__c = true;
        Database.insert(usr);
        
        system.runAs(usr){
            
            list<Account> acclist = TestDataFactory.createAccount(KROGER, usr,Constant_Util.CLIENT);
            Database.insert(acclist);
            
            list<Account> locationlist = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, acclist.get(0).id);
            Database.insert(locationlist);
            
            list<Contact> conlist = TestDataFactory.createContact(RITA,REPLY, acclist.get(0), usr);
            Database.insert(conlist);
            
            list<product2> productlist = TestDataFactory.createProduct(PRODUCT);
            productlist[0].Family = COMMERCIAL;
            productlist[0].ProductTypeSelected__c = COMPACTOR;
            Database.insert(productlist);
            
            list<Account> supplieracclist = TestDataFactory.createAccount(TESTSUPPLIER , usr, SUPPLIER);
            supplieracclist[0].AccountNumber = '600';
            Database.insert(supplieracclist);
            
            list<Asset> assetlist = TestDataFactory.createAsset(ASSET_NAME , acclist.get(0), conlist.get(0),productlist.get(0), usr, locationlist.get(0));
            assetlist[0].Supplier__c = supplieracclist[0].Id;
            Database.insert(assetlist);
            
            list<Case> caselist = TestDataFactory.createCase( CASE_NAME, acclist.get(0), conlist.get(0), usr, locationlist.get(0), assetlist.get(0));
            caselist[0].PurchaseOrder_Number__c =  PO_NUMBER;
            caselist[0].Status = Constant_Util.PENDING;
            caselist[0].Case_Type__c = Constant_Util.PICKUP_CSTYPE;
            caselist[0].Case_Sub_Type__c = Constant_Util.EXTRA_PICKUP;
			string jsonPop = null;
            // Get partition
        	Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.IvrExit');
            try{
                Integer random = Integer.valueof(crypto.getRandomLong());
                if(random < 0){
                    random = random  * -1;
                }
                String connId = String.valueof(random);
                caselist[0].Last_Customer_Interaction_ID__c = connId;
                Database.insert(caselist,false);
				IVRExitController.Screenpop pop = new IVRExitController.Screenpop();
                pop.MediaType = MEDIA_TYPE_VOICE;
                pop.ContactId = conlist[0].Id;
                pop.AcctId = acclist[0].Id;
                pop.AcctLocationId = locationlist[0].Id;
                pop.CaseRefNo = PO_NUMBER;
                pop.GenesysId = connId;
                pop.Intent = PICKUP;
                pop.ivrani = '809854638';
                pop.ivrContainerId = assetlist[0].Id;
                pop.ivrdnis = '809854638';
                pop.ivrexitpoint = 'Y';
                pop.ivrLang = 'English';
                pop.ivrLOB = 'Retail';
                pop.ivrQueue = 'RETAIL_IV_GENERAL';
                pop.ivrR4C = PICKUP;
                pop.ivrsseligible = 'Y';
                pop.ivrVendor = 'Y';
                pop.ivrWorkOrder = '23435';
                pop.SFDCRecordId = caselist[0].Id;
		//Added as part of SDT-17701
                pop.ivrSpokenName='Test User';
                pop.ivrIntentName='Test Pickup';
                pop.ivrSpokenLoc='HMD000101';
                pop.ivrSpokenRefNum='0023210';

                jsonPop = JSON.serialize(pop);
                // Get partition
                sessionPart.put(connId,jsonPop);
                System.debug('Caselist+++'+caselist);
            }catch(Exception ex){
                system.debug('Exception while inserting case:::'+ex.getStackTraceString());
            }
            
            List<WorkOrder> wo1 = TestDataFactory.createWorkOrder(acclist.get(0),conlist.get(0),caselist[0],assetlist.get(0));
            wo1[0].Status = SENT;
            wo1[0].Send_Status__c = SCHEDULED;
            wo1[0].Acorn_WorkOrder_Number__c = 'w1111';
            wo1[0].Vendor_Account_Id__c =  supplieracclist[0].Id;
            Integer random = Integer.valueof(crypto.getRandomLong());
            if(random < 0){
                random = random  * -1;
            }
            String connId = String.valueof(random);
            wo1[0].customer_Interaction_ID__c = connId;
            Database.Insert(wo1,false);
            sessionPart.put(connId,jsonPop);
        }
    }
    // Test method get Case Related IVR Data.
    @isTest
    static void testCaseIvrData() {
        //test class errors - SDT - 33363
        User u = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(u){
            Case c = [Select Id from Case Limit 1];
            IVRExitController.getIvrDetails(c.Id);
        }
    }
    // Test method get WorkOrder Related IVR Data.
    @isTest
    static void testwoIvrData() {
        //test class errors - SDT - 33363
        User u = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(u){
            workOrder wo = [Select Id from WorkOrder Limit 1];
            IVRExitController.getIvrDetails(wo.Id);
        }
    }
    // Test method to cover exception.
    @isTest
    static void testexception() {
        //test class errors - SDT - 33363
        User u = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(u){
            IVRExitController.getIvrDetails(null);
        }
    }
}