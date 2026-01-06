/**
* @author Accenture
* @date 2/6/2019
* @description : Apex class GetChildCaseTest 
**/
/*Test class for GetChildCase*/
@isTest(seeAllData = false)
public class GetChildCaseTest {
    private static final string SYS_ADMIN = 'System Administrator';
    private static final string EMAIL = 'testfrom@test.com';
    private static final string COMPACTOR = 'COMPACTOR';
    private static final string NAME = 'test';
    private static final string CHECK = 'Check';
    private static final string APPROVALS = 'Approvals';
    private static final string VALUE_TEST = 'Test';
/* method for setting up data*/ 
    @testSetup static void setup() {
     
        Profile p = TestDataFactory.getProfile(SYS_ADMIN);
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
            Database.insert(productlist);
            list<Asset> assetlist = TestDataFactory.createAsset(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                                productlist.get(0), usr, locationlist.get(0));
            assetlist[0]. Supplier__c = acclist[1].Id;
            Database.insert(assetlist);
            
            list<Case> caselist = TestDataFactory.createCase(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                             usr, locationlist.get(0), assetlist.get(0));
            Database.insert(caselist[0]);
            
            list<Business_Rule__c> brlst = TestDataFactory.createBusinessRule(NAME,acclist.get(0),locationlist.get(0));
            brlst[0].Service__c = Constant_Util.EXTRA_PICKUP;
            brlst[0].Schedule_Type__c = Constant_Util.EMPTY_STRING;
            brlst[0].Container__c = Constant_Util.EMPTY_STRING;
            brlst[0].Multiple_Mandatory_Approvers__c = false;
            brlst[0].AssetId__c = assetlist[0].Id;
            brlst[0].RecordTypeid = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.APPROVAL).getRecordTypeId();
            brlst[0].Required_Information__c = null; 
            Database.insert(brlst);
            
            list<Contact> conlist1 = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST,VALUE_TEST, acclist.get(0), usr);
            conlist1[0].Email = EMAIL;
            Database.insert(conlist1);
            
        }
    }
    @isTest static void MulticasewithoutTest(){ 
   		String subject= Constant_Util.EMPTY_STRING;
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(currentuser){
            Account acc = [select id from Account where RecordTypeId =: Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constant_Util.CLIENT).getRecordTypeId() LIMIT 1];
            Account Loc = [select id,Account.ParentId from Account where RecordTypeId =: Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constant_Util.LOCATION).getRecordTypeId() LIMIT 1];
            list<case> caselist = [select id, origin, contactid, Case_Type__c, Client__c, Location__c,Reference_Number__c, 
                                       PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                       Service_Date__c,SLA_Service_Date_Time__c,CaseNumber from Case LIMIT 1];
            Contact c = [Select id from Contact where Id =:caselist[0].contactid LIMIT 1];
            Asset a = [Select Id from Asset where Id=: caselist[0].assetid LIMIT 1];
            Business_Rule__c b = [select id from Business_Rule__c LIMIT 1];
            
            Case c2 = new Case();
//test class errors - SDT - 33363
            c2.RecordTypeId = TestDataFactory.getRecordType('Pickup Case','Case');
            c2.AssetId = caselist[0].assetid;
            c2.Client__c = caselist[0].Client__c;
            c2.origin = caselist[0].origin;
            c2.Location__c = caselist[0].Location__c;
            c2.Case_Type__c = caselist[0].Case_Type__c;
            c2.Case_Sub_Type__c = caselist[0].Case_Sub_Type__c;
            c2.ParentId = caselist[0].Id;
            c2.Reference_Number__c = caselist[0].CaseNumber;
            Database.insert(c2);
            
            Approval_Log__c al = new Approval_Log__c();
            al.BusinessRuleId__c = b.Id;
            al.Approver_Type__c = Constant_Util.EMPTY_STRING;
            al.ServiceApprovers__c = CHECK;
            al.CaseId__c = caselist[0].Id;
            Database.insert(al);
            
            List<Task> tasklist = new List<Task>();
            Task tsk = new Task();
            tsk.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(APPROVALS).getRecordTypeId(); 
            tsk.Process__c = Constant_Util.OBTAIN_SERVICE_APPROVAL;
            tsk.subject = Constant_Util.OBTAIN_SERVICE_APPROVAL;
            tsk.WhatId = caselist[0].Id;
            tsk.Attempt__c = 1;
            tsk.MultiCaseId__c = caselist[0].Id;
            tsk.OwnerId = currentuser.Id;
            tsk.Approval_Log__c = al.Id;
            tsk.Business_Rule__c = b.Id;
            tasklist.add(tsk);
            
            Approval_Log__c al1 = new Approval_Log__c();
            al1.BusinessRuleId__c = b.Id;
            al1.Approver_Type__c = Constant_Util.EMPTY_STRING;
            al1.ServiceApprovers__c = CHECK;
            al1.CaseId__c = c2.Id;
            Database.insert(al1);
            
            Task tsk1 = new Task();
            tsk1.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(APPROVALS).getRecordTypeId(); 
            tsk1.Process__c = Constant_Util.OBTAIN_SERVICE_APPROVAL;
            tsk1.subject = Constant_Util.OBTAIN_SERVICE_APPROVAL;
            tsk1.Outcome__c = null;
            tsk1.MultiCaseId__c = caselist[0].Id;
            tsk1.Attempt__c = 1;
            tsk1.Approval_Log__c = al1.Id;
            tsk1.OwnerId = currentuser.Id;
            tsk1.WhatId = c2.Id;
            tsk1.Business_Rule__c = b.Id;
            tasklist.add(tsk1);
            
            Test.startTest();
            Database.insert(tasklist);
            GetChildCase g = new GetChildCase();
            g.parentcse = caselist[0];
            List<Case> result = g.getcases();
            User u=g.getuser();
            Test.stopTest();
            system.assert(result!=null);
            system.assertEquals(UserInfo.getUserId(),currentuser.Id);
        }      
    }
}