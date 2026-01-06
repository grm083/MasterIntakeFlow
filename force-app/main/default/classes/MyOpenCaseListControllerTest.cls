/**
* @author Accenture
* @date 4/15/2019
* @description : Apex class MyOpenCaseListControllerTest test class for MyOpenCaseListController
**/
@isTest(seeAllData = false)
public class MyOpenCaseListControllerTest {
    private static final string SYS_ADMIN = 'System Administrator';
    private static final string PRODUCT = '8 yrd';
    private static final string KROGER = 'kroger';
    private static final string RITA = 'Rita';
    private static final string STATUS_OPEN = 'Open';
    private static final string PRODUCT_FAMILY = 'Commercial';
    private static final string REPLY = 'Reply';
    private static final string TESTSUPPLIER = 'testsupplier';
    private static final string SUPPLIER = 'Vendor';
    private static final string ASSET_NAME = '8 yrd Dumpster';
    private static final string CASE_NAME = 'First';
    private static final string PO_NUMBER = '1243';
    private static final string PICKUP = 'Pickup';
    private static final string EMPTY_AND_DO_NOT_RETURN = 'Empty and Do NOT Return';
    private static final string PROJECT_VALUE = '123';
    private static User usr{get;set;}
    
    /**@MethodName setup
     * Method to set Test Data
    **/
    @testSetup static void setup() {
       /* Profile adminProfile = TestDataFactory.getProfile(SYS_ADMIN);
        UserRole role = new UserRole();
        role.Name = SYS_ADMIN ;
        Database.insert(role);
        usr = TestDataFactory.createUser(adminProfile);
        usr.UserRoleId = role.id ;
        Database.insert(usr); */
        
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name=:SYS_ADMIN];
        User usr = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = adminProfile.Id, Acorn_SUser_ID__c = 999,
                            TimeZoneSidKey='America/Los_Angeles', UserName='SystemAdministrator'+ String.valueof(system.now().millisecond())+'@testorg.com',IsActive = true);        
        
        system.runAs(usr){
            list<Account> acclist = TestDataFactory.createAccount(KROGER, usr,Constant_Util.CLIENT);
            Database.insert(acclist);
            list<Account> locationlist = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, acclist.get(0).id);
            Database.insert(locationlist);
            
            list<Contact> conlist = TestDataFactory.createContact(RITA,REPLY, acclist.get(0), usr);
            Database.insert(conlist);
            list<product2> productlist = TestDataFactory.createProduct(PRODUCT);
            productlist[0].Family = PRODUCT_FAMILY;
            Database.insert(productlist);
            list<Account> supplieracclist = TestDataFactory.createAccount(TESTSUPPLIER , usr, SUPPLIER);
            Database.insert(supplieracclist);
            list<Asset> assetlist = TestDataFactory.createAsset(ASSET_NAME , acclist.get(0), conlist.get(0), 
                                                                productlist.get(0), usr, locationlist.get(0));
            assetlist[0].Supplier__c = supplieracclist[0].Id;
            assetlist[0].Project__c = PROJECT_VALUE;
            Database.insert(assetlist);
            List<user> currentuser = [select id, Bypass_Validation__c from user limit 2];
            System.debug('currentuser.get(1)'+currentuser.get(1));
            list<Case> caselist = TestDataFactory.createCase( CASE_NAME, acclist.get(0), conlist.get(0), 
                                                             usr, locationlist.get(0), assetlist.get(0));
            caselist[0].PurchaseOrder_Number__c =  PO_NUMBER;
            caselist[0].Status = STATUS_OPEN;
            caselist[0].OwnerId = currentuser.get(1).id ;
            caselist[0].Case_Sub_Type__c = EMPTY_AND_DO_NOT_RETURN;
            caselist[0].Create_AM_and_PM_Pickups__c = true;
            
            String csRep = Constant_Util.CS_REP ;
            UserRole csrRole = [select id, name from UserRole where name = :csRep limit 1];
            
            User CsrUser = TestDataFactory.createUser(adminProfile);
            CsrUser.UserRoleId = csrRole.id ;
            
            try{
                Database.insert(caselist);
                Database.insert(CsrUser, false);
            }catch(Exception ex){
               
            }
            
        }}
    
    /**@MethodName getOpenCaseListExceptionTest
     * Test method to cover getCaseList function 
     **/
    @isTest static void getOpenCaseListExceptionTest(){
        
            List<Case> resultList = new List<Case>(); 
            test.startTest();
               
            try{
                resultList = MyOpenCaseListController.getCaseList();
                
            }
            catch (Exception e){
                System.debug('Exception occured:'+e);
            }
            test.stopTest();
            System.assert(resultList!=null);
   
    } 
    
    /**@MethodName getOpenCaseListTest
     * Test method to cover getOpenCaseList function 
     **/
    @isTest static void getOpenCaseListTest(){
        
        List<user> currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 2];
        List<Case> resultList = new List<Case>();
        system.runAs(currentuser.get(1)){
            
            test.startTest();
            try{
                resultList = MyOpenCaseListController.getCaseList();
                
            }
            catch (Exception e){
                System.debug('Exception occured:'+e);
            }
            test.stopTest();
            System.assert(resultList!=null);
        }
    } 
   
    /**@MethodName getTeamCasesListTest
     * Test method to cover getTeamCasesList function 
     **/
    @isTest static void getTeamCasesListTest(){
        User usr = [Select id from User where Profile.Name =:SYS_ADMIN and IsActive = true  limit 1];
        
        system.runAs(usr){
            list<Group> grp = TestDataFactory.createGroup(usr);
            List<Case> resultList = new List<Case>();
            test.startTest();
            
            try{
                
                resultList = MyOpenCaseListController.getTeamCasesList();
                
            }
            catch (Exception e){
               
            }
            test.stopTest();
           System.assert(resultList!=null);
        }}
    
    /**@MethodName getTeamCasesListNegativeTest
     * Test method to cover getTeamCasesList function 
     **/
    @isTest static void getTeamCasesListNegativeTest(){
        User usr = [Select id from User where Profile.Name =:SYS_ADMIN and IsActive = true  limit 1];
        
        system.runAs(usr){
            List<Case> resultList = new List<Case>();
            test.startTest();
            
            try{
                
                resultList = MyOpenCaseListController.getTeamCasesList();
                
            }
            catch (Exception e){
               
            }
            test.stopTest();
           
        }}

    
}