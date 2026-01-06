/**
* @author WM
* @date 10/9/2020
* @description : Apex class getDetailsForEmailTest
**/

@isTest(seeAllData = false)
public class getDetailsForEmailTest {
    
    private static final string SYS_ADMIN = 'System Administrator';
    private static final string PRODUCT = '8 yrd';
    private static final string KROGER = 'kroger';
    private static final string RITA = 'Rita';
    private static final string REPLY = 'Reply';
    private static final string TESTSUPPLIER = 'testsupplier';
    private static final string SUPPLIER = 'Vendor';
    private static final string ASSET_NAME = '8 yrd Dumpster';
    private static final string NY_TIMEZONE = 'America/New_York';
    private static final string COMMERCIAL = 'Commercial';
    private static final string COMPACTOR = 'COMPACTOR';
	private static final string DISTRICT_MANAGER = 'District Manager';
    private static final string CASE_NAME = 'First';
    private static final string PO_NUMBER = '1243';
    private static final string PHONE = '0123456789';
    private static final string APPROVED = 'Approved';    
    private static final string EMAIL = 'test@wm.com';
    private static final string String_TEST = 'Test';
    
    /* set the test data*/
    @testSetup static void setup() {
        List<User> testRunUserList = new List<User>();
        
        Profile p = TestDataFactory.getProfile(SYS_ADMIN);
        
        User usr = TestDataFactory.createUser(p);
        usr.Bypass_Validation__c = true;
        testRunUserList.add(usr);
        
        User nonByPassValidationUser = TestDataFactory.createUser(p);
        nonByPassValidationUser.Username = 'SystemAdmin'+ String.valueof(system.now().millisecond())+'@testorg.com.wm';
        testRunUserList.add(nonByPassValidationUser);
        Database.insert(testRunUserList);
        
        System.runAs(usr){
            List<Account> acclist = TestDataFactory.createAccount(KROGER, usr,Constant_Util.CLIENT);
            acclist[0].AccountNumber = 'HMD';
            
            Database.insert(acclist);
            
            List<Account> locationlist = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, acclist.get(0).id);
            
            locationlist[0].tz__Timezone_SFDC__c = NY_TIMEZONE;
            locationlist[0].tz__UTF_Offset__c = -4;
            Database.insert(locationlist);
            
            List<Contact> conlist = TestDataFactory.createContact(RITA, REPLY, acclist.get(0), usr);
            conlist[0].Preferred_Method__c='Email';
            Database.insert(conlist);     
            
            List<product2> productlist = TestDataFactory.createProduct(PRODUCT);
            productlist[0].Family = COMMERCIAL;
            productlist[0].ProductTypeSelected__c = COMPACTOR;
            Database.insert(productlist);
            
            list<Account> supplieracclist = TestDataFactory.createAccount(TESTSUPPLIER , usr, SUPPLIER);
            supplieracclist[0].AccountNumber = '600';
            Database.insert(supplieracclist);
            
            List<Asset> assetlist = TestDataFactory.createAsset(ASSET_NAME, acclist.get(0), conlist.get(0), productlist.get(0), usr, locationlist.get(0));
            assetlist[0].Supplier__c = supplieracclist[0].Id;            
            Database.insert(assetlist);
            
             List<Case> caselist = TestDataFactory.createCase(CASE_NAME, acclist.get(0), conlist.get(0), usr, locationlist.get(0), assetlist.get(0));
            
            caselist[0].PurchaseOrder_Number__c =  PO_NUMBER;
            caselist[0].Status = Constant_Util.PENDING;
            caselist[0].Case_Type__c = Constant_Util.PICKUP_CSTYPE;
            caselist[0].Case_Sub_Type__c = Constant_Util.EXTRA_PICKUP;
            
            try{
                Database.insert(caselist);
                System.debug('Caselist+++'+caselist);
            } catch(Exception ex){
                system.debug('Exception while inserting case:::'+ex.getStackTraceString());                                             
            }
           
            list<Business_Rule__c> brlist = TestDataFactory.createBusinessRule(Constant_Util.CONSTANT_FIRST, acclist.get(0), locationlist.get(0));
            brlist[0].Service__c = Constant_Util.EXTRA_PICKUP;
            brlist[0].Schedule_Type__c = Constant_Util.EMPTY_STRING;
            brlist[0].Container__c = Constant_Util.EMPTY_STRING;
            brlist[0].AssetId__c = assetlist[0].Id;
            brlist[0].Is_Auto_Email__c=true;
			brlist[0].RecordTypeId = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.APPROVAL).getRecordTypeId();
            Database.insert(brlist);
            
            
            
            // Add spaces between different types of record creation statements
            list<Account_Title__c> titlelst = TestDataFactory.createAccountTitle(acclist.get(0),DISTRICT_MANAGER);
            Database.insert(titlelst, false);
            
            list<Service_Approver__c> serviceApproverlist = TestDataFactory.createServiceApprover(brlist[0]);
            serviceApproverlist[0].Title__c = titlelst[0].Id;
            Database.insert(serviceApproverlist, false);
            
            List<Approval_Log__c> applist = TestDataFactory.createApprovallog(caselist[0].id);
            applist[0].BusinessRuleId__c = brlist[0].Id;
            applist[0].CaseId__c = caselist[0].Id;  
            Database.Insert(applist);

        }
	}
    
    //Method I - when Approver is Title
    @isTest static void getTitleApprover(){
        
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1]; 
        system.runAs(currentuser){
            List<Asset> aselst = [Select Id, Location__c from Asset where Location__c != null Limit 1];
            List<Account> loclst = [Select Id, Name,ParentId from Account where Id =: aselst.get(0).Location__c Limit 1];
            List<Account> acclst = [Select Id, Name from Account where Id =: loclst.get(0).ParentId Limit 1];
            list<Business_Rule__c> brlst = [Select Id,Accountid__c,locationid__c,Container__c,Service__c,Request_Type__c,Schedule_Type__c,Active__c,Effective_Date__c,RecordTypeid,
                                            Required_Information__c from  Business_Rule__c where RecordTypeid =: Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.APPROVAL).getRecordTypeId() LIMIT 49999];
            brlst[0].Active__c = true;
            Database.update(brlst);
            List<Contact> conlst = [Select Id, Name from Contact where Accountid =: acclst.get(0).Id Limit 1];
          //  list<Service_Approver__c> salst = [Select Id, Business_Rule__c from Service_Approver__c LIMIT 49999];
            List<Case> caselist = [Select id,Status,Case_Sub_Status__c,Case_Type__c,Case_Sub_Type__c from Case where Accountid =: acclst.get(0).Id Limit 1];
            List<Approval_Log__c> appLog = [Select id,Status__c,Actual_Approver_Title__c from Approval_Log__c limit1];
            appLog[0].Actual_Approver_Title__c = String_TEST;
            appLog[0].Status__c = APPROVED;
            Database.update(appLog);
                         
         test.startTest();        
            getDetailsForEmail g = new getDetailsForEmail();
            g.cseDetail = caselist[0];           
        	String ApproverName = g.getApproverName();
         Test.stopTest();
            
            List<Approval_Log__c> upAppLog = [Select id,Status__c,Actual_Approver_Title__c from Approval_Log__c limit1];
            System.assertEquals(ApproverName,String_TEST);
       }
    }  
    
    //when Approver is Contact 
      @isTest static void getContactApprover(){
        
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1]; 
        system.runAs(currentuser){
            List<Asset> aselst = [Select Id, Location__c from Asset where Location__c != null Limit 1];
            List<Account> loclst = [Select Id, Name,ParentId from Account where Id =: aselst.get(0).Location__c Limit 1];
            List<Account> acclst = [Select Id, Name from Account where Id =: loclst.get(0).ParentId Limit 1];
            list<Business_Rule__c> brlst = [Select Id,Accountid__c,locationid__c,Container__c,Service__c,Request_Type__c,Schedule_Type__c,Active__c,Effective_Date__c,RecordTypeid,
                                            Required_Information__c from  Business_Rule__c where RecordTypeid =: Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.APPROVAL).getRecordTypeId() LIMIT 49999];
            brlst[0].Active__c = true;
            Database.update(brlst);
            List<Contact> conlst = [Select Id, Name from Contact where Accountid =: acclst.get(0).Id Limit 1];
            list<Service_Approver__c> salst = [Select Id, Business_Rule__c from Service_Approver__c LIMIT 49999];
            List<Case> caselist = [Select id,Status,Case_Sub_Status__c,Case_Type__c,Case_Sub_Type__c from Case where Accountid =: acclst.get(0).Id Limit 1];
            List<Approval_Log__c> appLog = [Select id,Status__c,Actual_Approver_Title__c from Approval_Log__c limit1];
            appLog[0].Actual_Approver_Contact__c = conlst[0].id;
            appLog[0].Status__c = APPROVED;
            Database.update(appLog);
                
         test.startTest();
            getDetailsForEmail g = new getDetailsForEmail();
            g.cseDetail = caselist[0];           
        	String ApproverName = g.getApproverName();
         Test.stopTest();
            
            List<Approval_Log__c> upAppLog = [Select id,Status__c,Actual_Approver_Contact__c,Actual_Approver_Contact__r.Name from Approval_Log__c limit1];
            System.assertEquals(ApproverName,'Rita Reply');
       }   
    }
    
    //when Approver is User
     @isTest static void getUserApprover(){
        
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1]; 
        system.runAs(currentuser){
            List<Asset> aselst = [Select Id, Location__c from Asset where Location__c != null Limit 1];
            List<Account> loclst = [Select Id, Name,ParentId from Account where Id =: aselst.get(0).Location__c Limit 1];
            List<Account> acclst = [Select Id, Name from Account where Id =: loclst.get(0).ParentId Limit 1];
            list<Business_Rule__c> brlst = [Select Id,Accountid__c,locationid__c,Container__c,Service__c,Request_Type__c,Schedule_Type__c,Active__c,Effective_Date__c,RecordTypeid,
                                            Required_Information__c from  Business_Rule__c where RecordTypeid =: Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.APPROVAL).getRecordTypeId() LIMIT 49999];
            brlst[0].Active__c = true;
            Database.update(brlst);
            List<Contact> conlst = [Select Id, Name from Contact where Accountid =: acclst.get(0).Id Limit 1];
            list<Service_Approver__c> salst = [Select Id, Business_Rule__c from Service_Approver__c LIMIT 49999];
            List<Case> caselist = [Select id,Status,Case_Sub_Status__c,Case_Type__c,Case_Sub_Type__c from Case where Accountid =: acclst.get(0).Id Limit 1];
            List<Approval_Log__c> appLog = [Select id,Status__c,Actual_Approver_Title__c,Actual_Approver__c from Approval_Log__c limit1];
            appLog[0].Actual_Approver__c = currentuser.id;
            appLog[0].Status__c = 'Approved';
            Database.update(appLog);
                
         test.startTest();
            getDetailsForEmail g = new getDetailsForEmail();
            g.cseDetail = caselist[0];           
        	String ApproverName = g.getApproverName();
         Test.stopTest();
       }           
    }
    
    //when Approver is External Approver
     @isTest static void getExternalApprover(){
        
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1]; 
        system.runAs(currentuser){
            List<Asset> aselst = [Select Id, Location__c from Asset where Location__c != null Limit 1];
            List<Account> loclst = [Select Id, Name,ParentId from Account where Id =: aselst.get(0).Location__c Limit 1];
            List<Account> acclst = [Select Id, Name from Account where Id =: loclst.get(0).ParentId Limit 1];
            list<Business_Rule__c> brlst = [Select Id,Accountid__c,locationid__c,Container__c,Service__c,Request_Type__c,Schedule_Type__c,Active__c,Effective_Date__c,RecordTypeid,
                                            Required_Information__c from  Business_Rule__c where RecordTypeid =: Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.APPROVAL).getRecordTypeId() LIMIT 49999];
            brlst[0].Active__c = true;
            Database.update(brlst);
            List<Contact> conlst = [Select Id, Name from Contact where Accountid =: acclst.get(0).Id Limit 1];
            list<Service_Approver__c> salst = [Select Id, Business_Rule__c from Service_Approver__c LIMIT 49999];
            List<Case> caselist = [Select id,Status,Case_Sub_Status__c,Case_Type__c,Case_Sub_Type__c from Case where Accountid =: acclst.get(0).Id Limit 1];
            List<Approval_Log__c> appLog = [Select id,Status__c,Actual_Approver_Title__c from Approval_Log__c limit1];
            appLog[0].Actual_External_Approver_Name__c = 'Test User';
            appLog[0].Status__c = 'Approved';
            Database.update(appLog);
                
         test.startTest();
            getDetailsForEmail g = new getDetailsForEmail();
            g.cseDetail = caselist[0];           
        	String ApproverName = g.getApproverName();
         Test.stopTest();
            
         List<Approval_Log__c> upAppLog = [Select id,Status__c,Actual_External_Approver_Name__c from Approval_Log__c limit1];
         System.assertEquals(ApproverName,'Test User');
       }           
    }
    
    //when Approver is Email
       @isTest static void getEmailApprover(){       
	     //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1]; 
        system.runAs(currentuser){
            List<Asset> aselst = [Select Id, Location__c from Asset where Location__c != null Limit 1];
            List<Account> loclst = [Select Id, Name,ParentId from Account where Id =: aselst.get(0).Location__c Limit 1];
            List<Account> acclst = [Select Id, Name from Account where Id =: loclst.get(0).ParentId Limit 1];
            list<Business_Rule__c> brlst = [Select Id,Accountid__c,locationid__c,Container__c,Service__c,Request_Type__c,Schedule_Type__c,Active__c,Effective_Date__c,RecordTypeid,
                                            Required_Information__c from  Business_Rule__c where RecordTypeid =: Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.APPROVAL).getRecordTypeId() LIMIT 49999];
            brlst[0].Active__c = true;
            Database.update(brlst);
            List<Contact> conlst = [Select Id, Name from Contact where Accountid =: acclst.get(0).Id Limit 1];
            list<Service_Approver__c> salst = [Select Id, Business_Rule__c from Service_Approver__c LIMIT 49999];
            List<Case> caselist = [Select id,Status,Case_Sub_Status__c,Case_Type__c,Case_Sub_Type__c from Case where Accountid =: acclst.get(0).Id Limit 1];
            List<Approval_Log__c> appLog = [Select id,Status__c,Actual_Approver_Title__c from Approval_Log__c limit1];
            appLog[0].Actual_Approver_Email__c = EMAIL;
            appLog[0].Status__c = 'Approved';
            Database.update(appLog);
                
         test.startTest();
            getDetailsForEmail g = new getDetailsForEmail();
            g.cseDetail = caselist[0];           
        	String ApproverName = g.getApproverName();
         Test.stopTest();
            
         List<Approval_Log__c> upAppLog = [Select id,Status__c,Actual_Approver_Email__c from Approval_Log__c limit1];
         System.assertEquals(ApproverName,EMAIL);
       }   
    }
}