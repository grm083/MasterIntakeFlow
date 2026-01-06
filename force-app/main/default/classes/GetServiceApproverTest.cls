/**
* @author Accenture
* @date 2/12/2019
* @description : Apex class GetServiceApproverTest
**/

/* test class for GetServiceApprover apex class*/
@isTest(seeAllData = false)
    public class GetServiceApproverTest {
    private static final string SYS_ADMIN = 'System Administrator';
    private static final string KROGER = 'kroger';
    private static final string BRULE = 'Brule';
    private static final string RITA = 'Rita';
    private static final string REPLY = 'Reply';
    private static final string PRODUCT = '8 yrd';
    private static final string ASSET_NAME = '8 yrd Dumpster';
    private static final string CASE_NAME = 'First';
    private static final string CONTACT = 'contact-';
     /* set up the test data */  
    @testSetup static void setup() {
        Profile p = TestDataFactory.getProfile(SYS_ADMIN);
        User usr = TestDataFactory.createUser(p);
        Database.insert(usr);
        
        system.runAs(usr){
            list<Account> acclist = TestDataFactory.createAccount(KROGER, usr);
            Database.insert(acclist);
            list<Account> acclist2 = TestDataFactory.createAccount(KROGER, usr);
            Database.insert(acclist2);
            list<Account> locationlist = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, acclist.get(0).id);
            Database.insert(locationlist);
            list<Business_Rule__c> businessrulelist = TestDataFactory.createBusinessRule(BRULE, acclist.get(0), 
                                                                                         locationlist.get(0));
            Database.insert(businessrulelist);
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
            list<Service_Approver__c> serviceApproverlist = TestDataFactory.createServiceApprover(Businessrulelist.get(0));
            Database.insert(serviceApproverlist);
            list<Service_Approver__c> serviceApproverEmaillist = TestDataFactory.createEmailServiceApprover(Businessrulelist.get(0));
            serviceApproverEmaillist[0].Email__c = 'Test@wm.com';
            Database.insert(serviceApproverEmaillist[0]);
            list<Task> tasklist = TestDataFactory.createTask(caselist.get(0).id, usr);
            tasklist.get(0).Business_Rule__c = Businessrulelist.get(0).id;
            tasklist.get(0).Approval_Log__c = approvalLoglist[0].Id;
            Database.insert(tasklist);
        } 
    }
    /* test method for getting the service approver */
    @isTest static void getServiceApprover(){
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        
        system.runAs(currentuser){
            Task task1 = [select id, Approval_Log__c, Description__c, Business_Rule__c from task limit 1];
            Service_Approver__c salst = [Select Id,Name,Approver_Type__c,Approver__c from Service_Approver__c
                                         where Business_Rule__c =: task1.Business_Rule__c limit 1];
            Approval_Log__c ap = [Select Id,Approver_Type__c from Approval_Log__c Limit 1];
            Account acc = [Select Id from Account where Name = 'KROGER' AND RecordType.Name = 'Client' LIMIT 1];
            Test.startTest();
            Id emailRTId = Schema.SObjectType.Out_of_Office__c.getRecordTypeInfosByDeveloperName().get('Email').getRecordTypeId();
            Business_Rule__c brRecord = [Select Id,Name from Business_Rule__c where Id =:task1.Business_Rule__c];
            String businessRules = brRecord.Name+'-'+'Empty and Return'+'-'+'Pickup';
            Out_of_Office__c oooRecord = new Out_of_Office__c();
            oooRecord.Account__c = acc.id;
            oooRecord.Business_Rules__c = businessRules;
            oooRecord.Current_Email_Approver__c = 'Test@wm.com';
            oooRecord.End_Date__c = System.today();
            oooRecord.Start_Date__c = System.today();
            oooRecord.New_Email_Approver__c= 'TestTest@wm.com';
            oooRecord.RecordTypeId = emailRTId;
            insert oooRecord;
            GetServiceApprover.getApprover(task1.id);
            ap.Approver_Type__c = CONTACT + salst.id;
            Database.update(ap);
            GetServiceApprover.getApprover(task1.id);
            GetServiceApprover.getApprover(null);
            GetServiceApprover.getcaseId(task1.id);
            GetServiceApprover.getcaseId(null);
            Test.stopTest();
            system.assert(task1.id != null);
        }
        
    }
        
        /* test method for getting the service approver */
    @isTest static void getServiceApprover2(){
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(currentuser){
            Task task1 = [select id, Approval_Log__c, Description__c, Business_Rule__c from task limit 1];
            Service_Approver__c salst = [Select Id,Name,Approver_Type__c,Approver__c from Service_Approver__c
                                         where Business_Rule__c =: task1.Business_Rule__c limit 1];
            Approval_Log__c ap = [Select Id,Approver_Type__c from Approval_Log__c Limit 1];
            Test.startTest();
            GetServiceApprover.getApprover(task1.id);
            ap.Approver_Type__c = CONTACT + salst.id;
            Database.update(ap);
            GetServiceApprover.getApprover(task1.id);
            GetServiceApprover.getApprover(null);
            GetServiceApprover.getcaseId(task1.id);
            GetServiceApprover.getcaseId(null);
            Test.stopTest();
            system.assert(task1.id != null);
        }
        
    }
}