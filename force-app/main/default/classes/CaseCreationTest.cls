/*
* @author Accenture
* @date 8/14/2019
* @description : Apex class CaseCreation 
*/
@isTest(seeAllData=false)
public class CaseCreationTest {
    //private static final string SYS_ADMIN = 'System Administrator'; //Commented for SDT-33445 
    private static final string CUSTOMER_SERVICE = 'Customer Service'; //Modified for SDT-33445
    private static final string KROGER = 'kroger';
    private static final string ASSET_NAME = '8 yrd Dumpster';
    private static final string RITA = 'Rita';
    private static final string REPLY = 'Reply';
    private static final string COMPACTOR = 'COMPACTOR';
    private static final string COMMERCIAL = 'Commercial';
    private static final string PRODUCT = '8 yrd';
    private static final string TESTSUPPLIER = 'testsupplier';
    private static final string SUPPLIER = 'Vendor';
    private static final string DURATION = 'Temporary';	
    public static final String LOCATION ='Location'; 
    public static final String CLIENT ='Client'; 
    private static final string CASE_NAME = 'First';
    private static final string PO_NUMBER = '1243';
    private static final string PICKUP = 'Pickup';
    private static final string NY_TIMEZONE = 'America/New_York';
   
    
    
    @testSetup static void setup(){
        //Profile prof = TestDataFactory.getProfile(SYS_ADMIN); //Commented for SDT-33445
        Profile prof = TestDataFactory.getProfile(CUSTOMER_SERVICE); //Modified for SDT-33445
        User currentUser = TestDataFactory.createUser(prof);
        Database.insert(currentUser);
        
        system.runAs(currentUser){
            List<Account> accList = TestDataFactory.createAccount(KROGER, currentUser,CLIENT);
            Database.insert(accList);
            List<Account> locationList = TestDataFactory.createLocation(LOCATION, currentUser, accList.get(0).id);
            locationlist[0].tz__Timezone_SFDC__c = NY_TIMEZONE;
            locationlist[0].tz__UTF_Offset__c = -4;
            Database.insert(locationList);  
			List<Contact> conlist = TestDataFactory.createContact(RITA,REPLY, acclist.get(0), currentUser);
            Database.insert(conlist);
			List<Account> supplieracclist = TestDataFactory.createAccount(TESTSUPPLIER , currentUser, SUPPLIER);
            Database.insert(supplieracclist);
			List<product2> productlist = TestDataFactory.createProduct(PRODUCT);
            productlist[0].Family = COMMERCIAL;
            productlist[0].Equipment_Type__c=COMPACTOR;
            productlist[0].ProductTypeSelected__c = COMPACTOR;
            Database.insert(productlist);
			List<Asset> assetlist = TestDataFactory.createAsset(ASSET_NAME , acclist.get(0), conlist.get(0), 
                                                                productlist.get(0), currentUser, locationlist.get(0));
            assetlist[0].Supplier__c = supplieracclist[0].Id;
            assetlist[0].Start_Date__c = System.today();
            Database.insert(assetlist);
            
            list<Case> caselist = TestDataFactory.createCase(CASE_NAME, acclist.get(0), conlist.get(0), 
                                                             currentUser, locationlist.get(0), assetlist.get(0));
            caselist[0].PurchaseOrder_Number__c =  PO_NUMBER;
            caselist[0].Status = Constant_Util.PENDING;
            caselist[0].Case_Type__c = Constant_Util.PICKUP_CSTYPE;
            caselist[0].Case_Sub_Type__c = Constant_Util.EXTRA_PICKUP;
			caselist[0].Case_Sub_Status__c = Constant_Util.PENDING_SERVICE_INTEGRATION;
            caselist[0].Tracking_number__c='123';
			try{
                Database.insert(caselist);
                List<WorkOrder> workOrderList = TestDataFactory.createWorkOrder(acclist.get(0), conlist.get(0), caselist.get(0), 
                                                                            assetlist.get(0));
            	workOrderList[0].Vendor_Account_Id__c = supplieracclist.get(0).Id;
           	 	workOrderList[0].Acorn_WorkOrder_Number__c = 'W123';
            	Database.insert(workOrderList);
                //System.debug('Caselist+++'+caselist);
            }catch(Exception ex){
                system.debug('Exception while inserting case:::'+ex.getStackTraceString());
            }
        }
    }
    
    @isTest public static void relatedCaseCreationTest(){
        //User currentuser = [select id,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363  //Commented for SDT-33445 
        //Querying CSR User.
        User currentuser = [SELECT Id, Profile.Name FROM User WHERE Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive = true LIMIT 1]; //Modified for SDT-33445           
        system.runAs(currentuser){
            System.assertEquals(4, [SELECT Id from Case].SIZE());
            List<Case> testCases=[SELECT Id from Case limit 1];
            Test.startTest();
            CaseCreation.createRelatedCase(testCases);
            Test.stopTest();
            System.assertEquals(5, [SELECT Id from Case].SIZE());
        }
    }
    @isTest public static void relatedCaseCreationTestException(){
        //User currentuser = [select id,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363//SDT-33363  //Commented for SDT-33445 
        //Querying CSR User.
        User currentuser = [SELECT Id, Profile.Name FROM User WHERE Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive = true LIMIT 1]; //Modified for SDT-33445           
        system.runAs(currentuser){
            System.assertEquals(4, [SELECT Id from Case].SIZE());
            List<Case> testCases=[SELECT Id from Case limit 2];
            Test.startTest();
            CaseCreation.createRelatedCase(testCases);
            Test.stopTest();
            System.assertEquals(6, [SELECT Id from Case].SIZE());
        }
    }
    @isTest public static void relatedCaseCreationNoContactTest(){
        //User currentuser = [select id,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363//SDT-33363  //Commented for SDT-33445 
        //Querying CSR User.
        User currentuser = [SELECT Id, Profile.Name FROM User WHERE Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive = true LIMIT 1]; //Modified for SDT-33445           
        system.runAs(currentuser){
            System.assertEquals(4, [SELECT Id from Case].SIZE());
            Test.startTest();
            List<Case> testCases=[SELECT Id from Case limit 1];
            testCases[0].ContactId = null;
            update testCases;
List<WorkOrder> wOrderList = new List<WorkOrder>(); //Modified for SDT-33445
            WorkOrder wOrder = [Select Id,Vendor_Exception_Reason__c from WorkOrder LIMIT 1];
            wOrder.Vendor_Exception_Reason__c = 'WM Cancelled';
            wOrderList.add(wOrder); //Modified for SDT-33445
            update wOrderList; //Modified for SDT-33445
            CaseCreation.createRelatedCase(testCases);
            Test.stopTest();
            System.assertEquals(5, [SELECT Id from Case].SIZE());
        }
    }
       
}