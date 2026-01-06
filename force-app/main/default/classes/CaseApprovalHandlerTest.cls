/**
* @author Accenture
* @date 2/6/2019
* @description : Apex class CaseApprovalHandlerTest 
**/
/*Test class for CaseApprovalHandler*/
@isTest(seeAllData = false)
public class CaseApprovalHandlerTest {
       private static final string SYS_ADMIN = 'System Administrator';
       private static final string EMAIL = 'testfrom@test.com';
       private static final string ALTERNATIVE_EMAIL = 'test@test.com';
       private static final string FOREMAIL = 'testemail@test.com';
       private static final string EMAIL_SUBJECT = 'Approved:';
       private static final string NAME = 'test';
       private static final string EMAIL_BODY = 'Test \n Test1 \n test2';
       private static final string EMAIL_BODY1 = 'Test \n\n------';
       private static final string REJECTED = 'Rejected:';
       private static final string APPROVALS = 'Approvals';
       private static final string PO_PSI_VALUE = 'PO Number;PSI';
       private static final string DISTRICT_MANAGER = 'District Manager';
       private static final string COMPACTOR = 'COMPACTOR';
       private static final string SERVICE_APPROVER = 'Service_Approver__c';
       private static final string VALUE_TEST = 'Test';
       private static final string CHECK = 'Check';
       private static final string MIXED = 'Mixed:';
/**
* @author Accenture
* @date 2/27/2019
* @description : Apex method setup 
**/
/* method for setting up data*/ 
    @testSetup static void setup() {
     
        Profile p = TestDataFactory.getProfile(SYS_ADMIN);
        User usr = TestDataFactory.createUser(p);
        Database.insert(usr);  
        system.runAs(usr){
            test.starttest(); //added by av4
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
            
            User usr1 = TestDataFactory.createUser(p);
            usr1.Email = EMAIL;
            Database.insert(usr1);
            
            list<Contact> conlist1 = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST,VALUE_TEST, acclist.get(0), usr1);
            conlist1[0].Email = EMAIL;
            system.debug('conlist1[0].Accountid+++'+conlist1[0].Accountid);
            Database.insert(conlist1);
            
            Task tsk = new Task();
            tsk.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(APPROVALS).getRecordTypeId(); 
            tsk.Process__c = Constant_Util.OBTAIN_SERVICE_APPROVAL;
            tsk.subject = Constant_Util.OBTAIN_SERVICE_APPROVAL;
            tsk.Outcome__c = Constant_Util.NO_OR_PENDING_RESPONSE;
            tsk.WhatId = caselist[0].Id;
            tsk.Business_Rule__c = brlst[0].Id;
			tsk.MultiCaseId__c = caselist[0].Id;
            Database.insert(tsk);
            
            list<Service_Approver__c> serviceApproverlist = TestDataFactory.createServiceApprover(brlst[0]);
            serviceApproverlist[0].Approver_Contact__c = conlist1[0].Id;
            serviceApproverlist[0].Recordtypeid = TestDataFactory.getRecordType(Constant_Util.CONTACT_RECORD_TYPE,SERVICE_APPROVER); 
            Database.insert(serviceApproverlist,false);
            
            list<Service_Approver__c> serviceApproverlist1 = TestDataFactory.createServiceApprover(brlst[0]);
            serviceApproverlist1[0].User__c = usr1.Id;
            serviceApproverlist1[0].Recordtypeid = TestDataFactory.getRecordType(Constant_Util.USER_RECORDTYPE,SERVICE_APPROVER); 
            Database.insert(serviceApproverlist1,false);
            
            list<Service_Approver__c> serviceApproverlist2 = TestDataFactory.createServiceApprover(brlst[0]);
            serviceApproverlist2[0].Email__c = FOREMAIL;
            serviceApproverlist2[0].Recordtypeid = TestDataFactory.getRecordType(Constant_Util.ORIGIN_EMAIL,SERVICE_APPROVER); 
            Database.insert(serviceApproverlist2,false);
            test.stoptest();
            }
}
    
/**
* @author Accenture
* @date 3/27/2019
* @description : Apex method createEmailTest
**/
   @isTest static void createEmailTest(){ 
       String subject= Constant_Util.EMPTY_STRING;
        user currentuser = [select id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        system.runAs(currentuser){
            list<case> caselist = [select id, origin, contactid, Case_Type__c, Client__c, Location__c,Reference_Number__c, 
                                       PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                       Service_Date__c,SLA_Service_Date_Time__c from Case LIMIT 1];
            List<Task> tasklst = [select id from Task where WhatId =: caselist[0].Id LIMIT 49999];
            list<Service_Approver__c> serviceApproverlist = [select id,Approver_Email__c from Service_Approver__c where Recordtypeid =:TestDataFactory.getRecordType(Constant_Util.CONTACT_RECORD_TYPE,SERVICE_APPROVER) Limit 1];
            String emailId = serviceApproverlist[0].Approver_Email__c ;
            List<Messaging.InboundEmail> emaillst = TestDataFactory.createinboundemail(EMAIL_SUBJECT + caselist[0].id + Constant_Util.COLON +caselist[0].Reference_Number__c + Constant_Util.COLON +caselist[0].Case_Type__c,emailId,EMAIL_BODY1);
            Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
            Test.startTest();
            CaseApprovalHandler caseApprove = new CaseApprovalHandler();
            caseApprove.handleInboundEmail(emaillst[0],env);
            
            emaillst[0].subject= REJECTED + caselist[0].id + Constant_Util.COLON +caselist[0].Reference_Number__c + Constant_Util.COLON +caselist[0].Case_Type__c;
            caseApprove.handleInboundEmail(emaillst[0],env);
         	
      		list<Service_Approver__c> serviceApproverlist1 = [select id,Approver_Email__c from Service_Approver__c where Recordtypeid =:TestDataFactory.getRecordType(Constant_Util.USER_RECORDTYPE,SERVICE_APPROVER) Limit 1];
            emailId = serviceApproverlist1[0].Approver_Email__c ;
            List<Messaging.InboundEmail> emaillst1 = TestDataFactory.createinboundemail(EMAIL_SUBJECT + caselist[0].id + Constant_Util.COLON +caselist[0].Reference_Number__c+ Constant_Util.COLON +caselist[0].Case_Type__c,emailId,EMAIL_BODY);
            Messaging.InboundEnvelope env1 = new Messaging.InboundEnvelope();
  			
            CaseApprovalHandler caseApprove1 = new CaseApprovalHandler();
           	Messaging.InboundEmailResult result = caseApprove1.handleInboundEmail(emaillst1[0],env1);
            Test.stopTest();
            system.assert(result != null);
        }
   }
    
/**
* @author Accenture
* @date 3/27/2019
* @description : Apex method alternativeApproverTest
**/
   @isTest static void alternativeApproverTest(){ 
       String subject= Constant_Util.EMPTY_STRING;
        user currentuser = [select id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        system.runAs(currentuser){
            list<case> caselist = [select id, origin, contactid, Case_Type__c, Client__c, Location__c,Reference_Number__c, 
                                       PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                       Service_Date__c,SLA_Service_Date_Time__c from Case LIMIT 1];
            List<Task> tasklst = [select id from Task where WhatId =: caselist[0].Id LIMIT 49999];
            List<Messaging.InboundEmail> emaillst = TestDataFactory.createinboundemail(EMAIL_SUBJECT + caselist[0].id + Constant_Util.COLON +caselist[0].Reference_Number__c+ Constant_Util.COLON +caselist[0].Case_Type__c,ALTERNATIVE_EMAIL,EMAIL_BODY);
            Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
            
            Test.startTest();
            CaseApprovalHandler caseApprove = new CaseApprovalHandler();
            Messaging.InboundEmailResult result = caseApprove.handleInboundEmail(emaillst[0],env);
            Test.stopTest();
            system.assert(result != null);
        }
   }
/**
* @author Accenture
* @date 3/27/2019
* @description : Apex method emailApproverTest
**/
   @isTest static void emailApproverTest(){ 
       String subject= Constant_Util.EMPTY_STRING;
        user currentuser = [select id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        system.runAs(currentuser){
            Account acc = [select id from Account where RecordTypeId =: Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constant_Util.CLIENT).getRecordTypeId() LIMIT 1];
            list<case> caselist = [select id, origin, contactid, Case_Type__c, Client__c, Location__c,Reference_Number__c, 
                                       PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                       Service_Date__c,SLA_Service_Date_Time__c from Case LIMIT 1];
            List<Task> tasklst = [select id,Business_Rule__c from Task where WhatId =: caselist[0].Id LIMIT 49999];
            List<Messaging.InboundEmail> emaillst = TestDataFactory.createinboundemail(EMAIL_SUBJECT + caselist[0].id + Constant_Util.COLON +caselist[0].Reference_Number__c+ Constant_Util.COLON +caselist[0].Case_Type__c,FOREMAIL,EMAIL_BODY);
            Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
            
            Test.startTest();
            CaseApprovalHandler caseApprove = new CaseApprovalHandler();
            Messaging.InboundEmailResult result = caseApprove.handleInboundEmail(emaillst[0],env);
            
            list<Contact> conlist2 = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST,VALUE_TEST, acc, currentuser);
            conlist2[0].Email = FOREMAIL;
            Database.insert(conlist2);
            
            CaseApprovalHandler caseApprove1 = new CaseApprovalHandler();
            Messaging.InboundEmailResult result1 = caseApprove1.handleInboundEmail(emaillst[0],env);
            
            Test.stopTest();
            system.assert(result != null);
        }
   }
/**
* @author Accenture
* @date 3/27/2019
* @description : Apex method userApproverTest
**/
   @isTest static void userApproverTest(){ 
   		String subject= Constant_Util.EMPTY_STRING;
        user currentuser = [select id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        system.runAs(currentuser){
            Account acc = [select id from Account where RecordTypeId =: Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constant_Util.CLIENT).getRecordTypeId() LIMIT 1];
            list<case> caselist = [select id, origin, contactid, Case_Type__c, Client__c, Location__c,Reference_Number__c, 
                                       PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                       Service_Date__c,SLA_Service_Date_Time__c from Case LIMIT 1];
            List<Task> tasklst = [select id,Business_Rule__c from Task where WhatId =: caselist[0].Id LIMIT 49999];
            List<Messaging.InboundEmail> emaillst = TestDataFactory.createinboundemail(EMAIL_SUBJECT + caselist[0].id + Constant_Util.COLON +caselist[0].Reference_Number__c + Constant_Util.COLON +caselist[0].Case_Type__c,FOREMAIL,EMAIL_BODY);
            Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
            
            Test.startTest();
            
            Profile p = TestDataFactory.getProfile(SYS_ADMIN);
            User usr = TestDataFactory.createUser(p);
            usr.Email = FOREMAIL;
            Database.insert(usr,true);
            
            User u =[select id,Email from User where Email =:FOREMAIL Limit 1];
            system.debug('user++'+u);
            
            Approval_Log__c al = new Approval_Log__c();
            al.BusinessRuleId__c = tasklst[0].Business_Rule__c;
            al.CaseId__c = caselist[0].Id;
            //al.Status__c = 'Approved';
            al.Approver_Type__c = Constant_Util.USER_RECORDTYPE;
            al.Required_Approver__c = u.Id;
            Database.insert(al);
            
            CaseApprovalHandler caseApprove = new CaseApprovalHandler();
            Messaging.InboundEmailResult result = caseApprove.handleInboundEmail(emaillst[0],env);
            
            CaseApprovalHandler caseApprove2 = new CaseApprovalHandler();
            Messaging.InboundEmailResult result2 = caseApprove2.handleInboundEmail(emaillst[0],env);
            
            System.assert(result!=null);
        }
   } 
/**
* @author Accenture
* @date 3/27/2019
* @description : Apex method MultiCaseTest
**/
   @isTest static void MultiCaseTest(){ 
   		String subject= Constant_Util.EMPTY_STRING;
        user currentuser = [select id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        system.runAs(currentuser){
            Account acc = [select id from Account where RecordTypeId =: Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constant_Util.CLIENT).getRecordTypeId() LIMIT 1];
            Account Loc = [select id,Account.ParentId from Account where RecordTypeId =: Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constant_Util.LOCATION).getRecordTypeId() LIMIT 1];
            list<case> caselist = [select id, origin, contactid, Case_Type__c, Client__c, Location__c,Reference_Number__c, 
                                       PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                       Service_Date__c,SLA_Service_Date_Time__c,CaseNumber,RecordTypeId from Case LIMIT 1]; //SDT-33363
            Contact c = [Select id from Contact where Id =:caselist[0].contactid LIMIT 1];
            Asset a = [Select Id from Asset where Id=: caselist[0].assetid LIMIT 1];
            List<Task> tasklst = [select id,Business_Rule__c,MultiCaseId__c from Task where WhatId =: caselist[0].Id LIMIT 49999];
            
            Case c2 = new Case();
            c2.AssetId = caselist[0].assetid;
            c2.Client__c = caselist[0].Client__c;
            c2.origin = caselist[0].origin;
            c2.Location__c = caselist[0].Location__c;
	    c2.RecordTypeId = caselist[0].RecordTypeId;//SDT-33363	
            c2.Case_Type__c = caselist[0].Case_Type__c;
            c2.Case_Sub_Type__c = caselist[0].Case_Sub_Type__c;
            c2.ParentId = caselist[0].Id;
            c2.Reference_Number__c = caselist[0].CaseNumber;
            Database.insert(c2);
            
            Approval_Log__c al = new Approval_Log__c();
            al.BusinessRuleId__c = tasklst[0].Business_Rule__c;
            al.Approver_Type__c = Constant_Util.CONTACT_RECORD_TYPE;
            al.CaseId__c = caselist[0].Id;
			al.ServiceApprovers__c = CHECK;
            Database.insert(al);
            
            List<Task> tasklist = new List<Task>();
            Task tsk = new Task();
            tsk.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(APPROVALS).getRecordTypeId(); 
            tsk.Process__c = Constant_Util.OBTAIN_SERVICE_APPROVAL;
            tsk.subject = Constant_Util.OBTAIN_SERVICE_APPROVAL;
            tsk.Outcome__c = Constant_Util.NO_OR_PENDING_RESPONSE;
            tsk.WhatId = caselist[0].Id;
            tsk.WhoId = c.Id;
            tsk.Approval_Log__c = al.Id;
            tsk.Business_Rule__c = tasklst[0].Business_Rule__c;
            tsk.MultiCaseId__c = caselist[0].Id;
            tasklist.add(tsk);
            
            Approval_Log__c al1 = new Approval_Log__c();
            al1.BusinessRuleId__c = tasklst[0].Business_Rule__c;
            al1.Approver_Type__c = Constant_Util.CONTACT_RECORD_TYPE;
            al1.CaseId__c = c2.Id;
            al1.ServiceApprovers__c = CHECK;
            Database.insert(al1);
            
            Task tsk1 = new Task();
            tsk1.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(APPROVALS).getRecordTypeId(); 
            tsk1.Process__c = Constant_Util.OBTAIN_SERVICE_APPROVAL;
            tsk1.subject = Constant_Util.OBTAIN_SERVICE_APPROVAL;
            tsk1.Outcome__c = null;
            tsk1.WhoId = c.Id;
            tsk1.Approval_Log__c = al1.Id;
            tsk1.WhatId = c2.Id;
            tsk1.MultiCaseId__c = caselist[0].Id;
            tsk1.Business_Rule__c = tasklst[0].Business_Rule__c;
            tasklist.add(tsk1);
            
            Database.delete(tasklst);
            Test.startTest();
            Database.insert(tasklist);
            
            List<Messaging.InboundEmail> emaillst1 = TestDataFactory.createinboundemail(EMAIL_SUBJECT + caselist[0].id + Constant_Util.COLON +caselist[0].Reference_Number__c + Constant_Util.COLON +caselist[0].Case_Type__c,FOREMAIL,EMAIL_BODY);
            Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
            
            CaseApprovalHandler caseApprove1 = new CaseApprovalHandler();
            Messaging.InboundEmailResult result1 = caseApprove1.handleInboundEmail(emaillst1[0],env);
            
            Test.stopTest();
            system.assert(result1 != null);
        }      
   }   
/**
* @author Accenture
* @date 3/27/2019
* @description : Apex method MulticaseEmailTest
**/
    @isTest static void MulticaseEmailTest(){ 
   		String subject= Constant_Util.EMPTY_STRING;
        user currentuser = [select id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        system.runAs(currentuser){
            Account acc = [select id from Account where RecordTypeId =: Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constant_Util.CLIENT).getRecordTypeId() LIMIT 1];
            Account Loc = [select id,Account.ParentId from Account where RecordTypeId =: Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constant_Util.LOCATION).getRecordTypeId() LIMIT 1];
            list<case> caselist = [select id, origin, contactid, Case_Type__c, Client__c, Location__c,Reference_Number__c, 
                                       PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                       Service_Date__c,SLA_Service_Date_Time__c,CaseNumber,RecordTypeId from Case LIMIT 1]; //SDT-33363(3)
            Contact c = [Select id from Contact where Id =:caselist[0].contactid LIMIT 1];
            Asset a = [Select Id from Asset where Id=: caselist[0].assetid LIMIT 1];
            List<Task> tasklst = [select id,Business_Rule__c,MultiCaseId__c from Task where WhatId =: caselist[0].Id LIMIT 49999];
            
            Case c2 = new Case();
            c2.AssetId = caselist[0].assetid;
            c2.Client__c = caselist[0].Client__c;
            c2.origin = caselist[0].origin;
            c2.Location__c = caselist[0].Location__c;
	    c2.RecordTypeId = caselist[0].RecordTypeId;//SDT-33363	
            c2.Case_Type__c = caselist[0].Case_Type__c;
            c2.Case_Sub_Type__c = caselist[0].Case_Sub_Type__c;
            c2.ParentId = caselist[0].Id;
            c2.Reference_Number__c = caselist[0].CaseNumber;
            Database.insert(c2);
            
            Approval_Log__c al = new Approval_Log__c();
            al.BusinessRuleId__c = tasklst[0].Business_Rule__c;
            al.Approver_Type__c = Constant_Util.ORIGIN_EMAIL;
            al.CaseId__c = caselist[0].Id;
            al.ServiceApprovers__c = CHECK;
            Database.insert(al);
            
            List<Task> tasklist = new List<Task>();
            Task tsk = new Task();
            tsk.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(APPROVALS).getRecordTypeId(); 
            tsk.Process__c = Constant_Util.OBTAIN_SERVICE_APPROVAL;
            tsk.subject = Constant_Util.OBTAIN_SERVICE_APPROVAL;
            tsk.Outcome__c = Constant_Util.NO_OR_PENDING_RESPONSE;
            tsk.WhatId = caselist[0].Id;
            tsk.ContactEmail__c = FOREMAIL;
            tsk.Approval_Log__c = al.Id;
            tsk.Business_Rule__c = tasklst[0].Business_Rule__c;
            tsk.MultiCaseId__c = caselist[0].Id;
            tasklist.add(tsk);
            
            Approval_Log__c al1 = new Approval_Log__c();
            al1.BusinessRuleId__c = tasklst[0].Business_Rule__c;
            al1.Approver_Type__c = Constant_Util.ORIGIN_EMAIL;
            al1.CaseId__c = c2.Id;
            al1.ServiceApprovers__c = CHECK;
            Database.insert(al1);
            
            Task tsk1 = new Task();
            tsk1.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(APPROVALS).getRecordTypeId(); 
            tsk1.Process__c = Constant_Util.OBTAIN_SERVICE_APPROVAL;
            tsk1.subject = Constant_Util.OBTAIN_SERVICE_APPROVAL;
            tsk1.Outcome__c = null;
            tsk1.Approval_Log__c = al1.Id;
            tsk1.ContactEmail__c = FOREMAIL;
            tsk1.MultiCaseId__c = caselist[0].Id;
            tsk1.WhatId = c2.Id;
            tsk1.Business_Rule__c = tasklst[0].Business_Rule__c;
            tasklist.add(tsk1);
            
            Database.delete(tasklst);
            Test.startTest();
            Database.insert(tasklist);
            
            List<Messaging.InboundEmail> emaillst1 = TestDataFactory.createinboundemail(EMAIL_SUBJECT + caselist[0].id + Constant_Util.COLON +caselist[0].Reference_Number__c + Constant_Util.COLON +caselist[0].Case_Type__c,FOREMAIL,EMAIL_BODY);
            Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
            
            CaseApprovalHandler caseApprove1 = new CaseApprovalHandler();
            Messaging.InboundEmailResult result1 = caseApprove1.handleInboundEmail(emaillst1[0],env);
            
            Test.stopTest();
            system.assert(result1 != null);
        }      
   }
/**
* @author Accenture
* @date 3/27/2019
* @description : Apex method MulticaseDepartmentTest
**/    
    @isTest static void MulticaseDepartmentTest(){ 
   		String subject= Constant_Util.EMPTY_STRING;
        user currentuser = [select id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        system.runAs(currentuser){
            Account acc = [select id from Account where RecordTypeId =: Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constant_Util.CLIENT).getRecordTypeId() LIMIT 1];
            Account Loc = [select id,Account.ParentId from Account where RecordTypeId =: Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constant_Util.LOCATION).getRecordTypeId() LIMIT 1];
            list<case> caselist = [select id, origin, contactid, Case_Type__c, Client__c, Location__c,Reference_Number__c, 
                                       PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                       Service_Date__c,SLA_Service_Date_Time__c,CaseNumber,RecordTypeId from Case LIMIT 1]; //SDT-33363
            Contact c = [Select id from Contact where Id =:caselist[0].contactid LIMIT 1];
            Asset a = [Select Id from Asset where Id=: caselist[0].assetid LIMIT 1];
            List<Task> tasklst = [select id,Business_Rule__c,MultiCaseId__c from Task where WhatId =: caselist[0].Id LIMIT 49999];
            List<Service_Approver__c> sa = [Select id from Service_Approver__c where Business_Rule__c =: tasklst[0].Business_Rule__c LIMIT 2];
            Database.delete(sa,true);
            Service_Approver__c s = [Select id,Approver_Email__c,Email__c from Service_Approver__c where Business_Rule__c =: tasklst[0].Business_Rule__c LIMIT 1];
            s.Email__c = 'test@wm.com';
            Database.Update(s);
            Case c2 = new Case();
            c2.AssetId = caselist[0].assetid;
            c2.Client__c = caselist[0].Client__c;
            c2.origin = caselist[0].origin;
            c2.Location__c = caselist[0].Location__c;
	    c2.RecordTypeId = caselist[0].RecordTypeId;//SDT-33363
            c2.Case_Type__c = caselist[0].Case_Type__c;
            c2.Case_Sub_Type__c = caselist[0].Case_Sub_Type__c;
            c2.ParentId = caselist[0].Id;
            c2.Reference_Number__c = caselist[0].CaseNumber;
            Database.insert(c2);
            
            Approval_Log__c al = new Approval_Log__c();
            al.BusinessRuleId__c = tasklst[0].Business_Rule__c;
            al.Approver_Type__c = Constant_Util.DEPARTMENT_RECORDTYPE;
            al.ServiceApprovers__c = CHECK;
            al.CaseId__c = caselist[0].Id;
            Database.insert(al);
            
            List<Task> tasklist = new List<Task>();
            Task tsk = new Task();
            tsk.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(APPROVALS).getRecordTypeId(); 
            tsk.Process__c = Constant_Util.OBTAIN_SERVICE_APPROVAL;
            tsk.subject = Constant_Util.OBTAIN_SERVICE_APPROVAL;
            tsk.Outcome__c = Constant_Util.NO_OR_PENDING_RESPONSE;
            tsk.WhatId = caselist[0].Id;
            tsk.Department_Name__c = VALUE_TEST;
            tsk.Approval_Log__c = al.Id;
            tsk.Business_Rule__c = tasklst[0].Business_Rule__c;
            tsk.MultiCaseId__c = caselist[0].Id;
            tasklist.add(tsk);
            
            Approval_Log__c al1 = new Approval_Log__c();
            al1.BusinessRuleId__c = tasklst[0].Business_Rule__c;
            al1.Approver_Type__c = Constant_Util.DEPARTMENT_RECORDTYPE;
            al1.CaseId__c = c2.Id;
            al1.ServiceApprovers__c = CHECK;
            Database.insert(al1);
            
            Task tsk1 = new Task();
            tsk1.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(APPROVALS).getRecordTypeId(); 
            tsk1.Process__c = Constant_Util.OBTAIN_SERVICE_APPROVAL;
            tsk1.subject = Constant_Util.OBTAIN_SERVICE_APPROVAL;
            tsk1.Outcome__c = null;
            tsk1.Approval_Log__c = al1.Id;
            tsk1.Department_Name__c = VALUE_TEST;
            tsk1.MultiCaseId__c = caselist[0].Id;
            tsk1.WhatId = c2.Id;
            tsk1.Business_Rule__c = tasklst[0].Business_Rule__c;
            tasklist.add(tsk1);
            
            Database.delete(tasklst);
            Test.startTest();
            Database.insert(tasklist);
            
            List<Messaging.InboundEmail> emaillst1 = TestDataFactory.createinboundemail(EMAIL_SUBJECT + caselist[0].id + Constant_Util.COLON +caselist[0].Reference_Number__c + Constant_Util.COLON +caselist[0].Case_Type__c,FOREMAIL,EMAIL_BODY);
            Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
            
            CaseApprovalHandler caseApprove1 = new CaseApprovalHandler();
            Messaging.InboundEmailResult result1 = caseApprove1.handleInboundEmail(emaillst1[0],env);
            
            Test.stopTest();
            system.assert(result1 != null);
        }      
   }
/**
* @author Accenture
* @date 3/27/2019
* @description : Apex method MulticaseTitleTest
**/
    @isTest static void MulticaseTitleTest(){ 
   		String subject= Constant_Util.EMPTY_STRING;
        user currentuser = [select id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        system.runAs(currentuser){
            Account acc = [select id from Account where RecordTypeId =: Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constant_Util.CLIENT).getRecordTypeId() LIMIT 1];
            Account Loc = [select id,Account.ParentId from Account where RecordTypeId =: Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constant_Util.LOCATION).getRecordTypeId() LIMIT 1];
            list<case> caselist = [select id, origin, contactid, Case_Type__c, Client__c, Location__c,Reference_Number__c,
                                       PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                       Service_Date__c,SLA_Service_Date_Time__c,CaseNumber,RecordTypeId from Case LIMIT 1];//SDT-33363
            Contact c = [Select id from Contact where Id =:caselist[0].contactid LIMIT 1];
            Asset a = [Select Id from Asset where Id=: caselist[0].assetid LIMIT 1];
            List<Task> tasklst = [select id,Business_Rule__c,MultiCaseId__c from Task where WhatId =: caselist[0].Id LIMIT 49999];
            
            Case c2 = new Case();
            c2.AssetId = caselist[0].assetid;
            c2.Client__c = caselist[0].Client__c;
            c2.origin = caselist[0].origin;
            c2.Location__c = caselist[0].Location__c;
	    c2.RecordTypeId = caselist[0].RecordTypeId;//SDT-33363	
            c2.Case_Type__c = caselist[0].Case_Type__c;
            c2.Case_Sub_Type__c = caselist[0].Case_Sub_Type__c;
            c2.ParentId = caselist[0].Id;
            c2.Reference_Number__c = caselist[0].CaseNumber;
            Database.insert(c2);
            
            Approval_Log__c al = new Approval_Log__c();
            al.BusinessRuleId__c = tasklst[0].Business_Rule__c;
            al.Approver_Type__c = Constant_Util.FLOW_TITLE;
            al.CaseId__c = caselist[0].Id;
            al.ServiceApprovers__c = CHECK;
            Database.insert(al);
            
            List<Task> tasklist = new List<Task>();
            Task tsk = new Task();
            tsk.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(APPROVALS).getRecordTypeId(); 
            tsk.Process__c = Constant_Util.OBTAIN_SERVICE_APPROVAL;
            tsk.subject = Constant_Util.OBTAIN_SERVICE_APPROVAL;
            tsk.Outcome__c = Constant_Util.NO_OR_PENDING_RESPONSE;
            tsk.WhatId = caselist[0].Id;
            tsk.Contact_Title__c = VALUE_TEST;
            tsk.Approval_Log__c = al.Id;
            tsk.Business_Rule__c = tasklst[0].Business_Rule__c;
            tsk.MultiCaseId__c = caselist[0].Id;
            tasklist.add(tsk);
            
            Approval_Log__c al1 = new Approval_Log__c();
            al1.BusinessRuleId__c = tasklst[0].Business_Rule__c;
            al1.Approver_Type__c = Constant_Util.FLOW_TITLE;
            al1.CaseId__c = c2.Id;
            al1.ServiceApprovers__c = CHECK;
            Database.insert(al1);
            
            Task tsk1 = new Task();
            tsk1.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(APPROVALS).getRecordTypeId(); 
            tsk1.Process__c = Constant_Util.OBTAIN_SERVICE_APPROVAL;
            tsk1.subject = Constant_Util.OBTAIN_SERVICE_APPROVAL;
            tsk1.Outcome__c = null;
            tsk1.Approval_Log__c = al1.Id;
            tsk1.Contact_Title__c = VALUE_TEST;
            tsk1.MultiCaseId__c = caselist[0].Id;
            tsk1.WhatId = c2.Id;
            tsk1.Business_Rule__c = tasklst[0].Business_Rule__c;
            tasklist.add(tsk1);
            
            Database.delete(tasklst);
            Test.startTest();
            Database.insert(tasklist);
            
            List<Messaging.InboundEmail> emaillst1 = TestDataFactory.createinboundemail(REJECTED + caselist[0].id + Constant_Util.COLON +caselist[0].Reference_Number__c + Constant_Util.COLON +caselist[0].Case_Type__c,FOREMAIL,EMAIL_BODY);
            Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
            
            CaseApprovalHandler caseApprove1 = new CaseApprovalHandler();
            Messaging.InboundEmailResult result1 = caseApprove1.handleInboundEmail(emaillst1[0],env);
            
            Test.stopTest();
            system.assert(result1 != null);
        }      
   }
/**
* @author Accenture
* @date 3/27/2019
* @description : Apex method MulticasewithoutTest
**/
    @isTest static void MulticasewithoutTest(){ 
   		String subject= Constant_Util.EMPTY_STRING;
        user currentuser = [select id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        system.runAs(currentuser){
            Account acc = [select id from Account where RecordTypeId =: Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constant_Util.CLIENT).getRecordTypeId() LIMIT 1];
            Account Loc = [select id,Account.ParentId from Account where RecordTypeId =: Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constant_Util.LOCATION).getRecordTypeId() LIMIT 1];
            list<case> caselist = [select id, origin, contactid, Case_Type__c, Client__c, Location__c,Reference_Number__c, 
                                       PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                       Service_Date__c,SLA_Service_Date_Time__c,CaseNumber,RecordTypeId from Case LIMIT 1]; //SDT-33363
            Contact c = [Select id from Contact where Id =:caselist[0].contactid LIMIT 1];
            Asset a = [Select Id from Asset where Id=: caselist[0].assetid LIMIT 1];
            List<Task> tasklst = [select id,Business_Rule__c,MultiCaseId__c from Task where WhatId =: caselist[0].Id LIMIT 49999];
            
            Case c2 = new Case();
            c2.AssetId = caselist[0].assetid;
            c2.Client__c = caselist[0].Client__c;
            c2.origin = caselist[0].origin;
            c2.Location__c = caselist[0].Location__c;
	    c2.RecordTypeId = caselist[0].RecordTypeId;//SDT-33363	
            c2.Case_Type__c = caselist[0].Case_Type__c;
            c2.Case_Sub_Type__c = caselist[0].Case_Sub_Type__c;
            c2.ParentId = caselist[0].Id;
            c2.Reference_Number__c = caselist[0].CaseNumber;
            Database.insert(c2);
            
            Approval_Log__c al = new Approval_Log__c();
            al.BusinessRuleId__c = tasklst[0].Business_Rule__c;
            al.Approver_Type__c = Constant_Util.DEPARTMENT_RECORDTYPE;
            al.CaseId__c = caselist[0].Id;
            al.ServiceApprovers__c = CHECK;
            Database.insert(al);
            
            List<Task> tasklist = new List<Task>();
            Task tsk = new Task();
            tsk.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(APPROVALS).getRecordTypeId(); 
            tsk.Process__c = Constant_Util.OBTAIN_SERVICE_APPROVAL;
            tsk.subject = Constant_Util.OBTAIN_SERVICE_APPROVAL;
            tsk.Outcome__c = Constant_Util.NO_OR_PENDING_RESPONSE;
            tsk.WhatId = caselist[0].Id;
            tsk.OwnerId = currentuser.Id;
            tsk.Department_Name__c = VALUE_TEST;
            tsk.Approval_Log__c = al.Id;
            tsk.Business_Rule__c = tasklst[0].Business_Rule__c;
            tsk.MultiCaseId__c = caselist[0].Id;
            tasklist.add(tsk);
            
            Approval_Log__c al1 = new Approval_Log__c();
            al1.BusinessRuleId__c = tasklst[0].Business_Rule__c;
            al1.Approver_Type__c = Constant_Util.DEPARTMENT_RECORDTYPE;
            al1.CaseId__c = c2.Id;
            al.ServiceApprovers__c = CHECK;
            Database.insert(al1);
            
            Task tsk1 = new Task();
            tsk1.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(APPROVALS).getRecordTypeId(); 
            tsk1.Process__c = Constant_Util.OBTAIN_SERVICE_APPROVAL;
            tsk1.subject = Constant_Util.OBTAIN_SERVICE_APPROVAL;
            tsk1.Outcome__c = null;
            tsk1.Approval_Log__c = al1.Id;
            tsk1.Department_Name__c = VALUE_TEST;
            tsk1.OwnerId = currentuser.Id;
            tsk1.MultiCaseId__c = caselist[0].Id;
            tsk1.WhatId = c2.Id;
            tsk1.Business_Rule__c = tasklst[0].Business_Rule__c;
            tasklist.add(tsk1);
            
            Database.delete(tasklst);
            Test.startTest();
            Database.insert(tasklist);
            
            List<Messaging.InboundEmail> emaillst1 = TestDataFactory.createinboundemail(EMAIL_SUBJECT + caselist[0].id + Constant_Util.COLON +caselist[0].Reference_Number__c + Constant_Util.COLON +caselist[0].Case_Type__c,FOREMAIL,EMAIL_BODY);
            Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
            
            CaseApprovalHandler caseApprove1 = new CaseApprovalHandler();
            Messaging.InboundEmailResult result1 = caseApprove1.handleInboundEmail(emaillst1[0],env);
            
            Test.stopTest();
            system.assert(result1 != null);
        }      
   }
/**
* @author Accenture
* @date 3/27/2019
* @description : Apex method MulticaseMixedTest
**/
    @isTest static void MulticaseMixedTest(){ 
   		String subject= Constant_Util.EMPTY_STRING;
        user currentuser = [select id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        system.runAs(currentuser){
            Account acc = [select id from Account where RecordTypeId =: Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constant_Util.CLIENT).getRecordTypeId() LIMIT 1];
            Account Loc = [select id,Account.ParentId from Account where RecordTypeId =: Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constant_Util.LOCATION).getRecordTypeId() LIMIT 1];
            list<case> caselist = [select id, origin, contactid, Case_Type__c, Client__c, Location__c,Reference_Number__c, 
                                       PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                       Service_Date__c,SLA_Service_Date_Time__c,CaseNumber,RecordTypeId from Case LIMIT 1]; //SDT-33363
            Contact c = [Select id from Contact where Id =:caselist[0].contactid LIMIT 1];
            Asset a = [Select Id from Asset where Id=: caselist[0].assetid LIMIT 1];
            List<Task> tasklst = [select id,Business_Rule__c,MultiCaseId__c from Task where WhatId =: caselist[0].Id LIMIT 49999];
            List<Service_Approver__c> sa = [Select id from Service_Approver__c where Business_Rule__c =: tasklst[0].Business_Rule__c LIMIT 2];
            Database.delete(sa,true);
            Service_Approver__c s = [Select id,Approver_Email__c,Email__c from Service_Approver__c where Business_Rule__c =: tasklst[0].Business_Rule__c LIMIT 1];
            s.Email__c = 'test@wm.com';
            Database.Update(s);
            
            Case c2 = new Case();
            c2.AssetId = caselist[0].assetid;
            c2.Client__c = caselist[0].Client__c;
            c2.origin = caselist[0].origin;
            c2.Location__c = caselist[0].Location__c;
	    c2.RecordTypeId = caselist[0].RecordTypeId;//SDT-33363	
            c2.Case_Type__c = caselist[0].Case_Type__c;
            c2.Case_Sub_Type__c = caselist[0].Case_Sub_Type__c;
            c2.ParentId = caselist[0].Id;
            c2.Reference_Number__c = caselist[0].CaseNumber;
            Database.insert(c2);
            
            Approval_Log__c al = new Approval_Log__c();
            al.BusinessRuleId__c = tasklst[0].Business_Rule__c;
            al.Approver_Type__c = Constant_Util.ORIGIN_EMAIL;
            al.CaseId__c = caselist[0].Id;
            al.ServiceApprovers__c = CHECK;
            Database.insert(al);
            
            List<Task> tasklist = new List<Task>();
            Task tsk = new Task();
            tsk.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(APPROVALS).getRecordTypeId(); 
            tsk.Process__c = Constant_Util.OBTAIN_SERVICE_APPROVAL;
            tsk.subject = Constant_Util.OBTAIN_SERVICE_APPROVAL;
            tsk.Outcome__c = Constant_Util.NO_OR_PENDING_RESPONSE;
            tsk.WhatId = caselist[0].Id;
            tsk.ContactEmail__c = FOREMAIL;
            tsk.Approval_Log__c = al.Id;
            tsk.Business_Rule__c = tasklst[0].Business_Rule__c;
            tsk.MultiCaseId__c = caselist[0].Id;
            tasklist.add(tsk);
            
            Approval_Log__c al1 = new Approval_Log__c();
            al1.BusinessRuleId__c = tasklst[0].Business_Rule__c;
            al1.Approver_Type__c = Constant_Util.ORIGIN_EMAIL;
            al1.CaseId__c = c2.Id;
            al1.ServiceApprovers__c = CHECK;
            Database.insert(al1);
            
            Task tsk1 = new Task();
            tsk1.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(APPROVALS).getRecordTypeId(); 
            tsk1.Process__c = Constant_Util.OBTAIN_SERVICE_APPROVAL;
            tsk1.subject = Constant_Util.OBTAIN_SERVICE_APPROVAL;
            tsk1.Outcome__c = null;
            tsk1.Approval_Log__c = al1.Id;
            tsk1.ContactEmail__c = FOREMAIL;
            tsk1.MultiCaseId__c = caselist[0].Id;
            tsk1.WhatId = c2.Id;
            tsk1.Business_Rule__c = tasklst[0].Business_Rule__c;
            tasklist.add(tsk1);
            
            Database.delete(tasklst);
            Test.startTest();
            Database.insert(tasklist);
            
            List<Messaging.InboundEmail> emaillst1 = TestDataFactory.createinboundemail(MIXED + caselist[0].id + Constant_Util.COLON +caselist[0].Reference_Number__c + Constant_Util.COLON +caselist[0].Case_Type__c,FOREMAIL,EMAIL_BODY);
            Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
            
            CaseApprovalHandler caseApprove1 = new CaseApprovalHandler();
            Messaging.InboundEmailResult result1 = caseApprove1.handleInboundEmail(emaillst1[0],env);
            
            Test.stopTest();
            system.assert(result1 != null);
        }      
   }
    
    /**
* @author WM
* @date 10/31/2019
* @description : Test method to check creation of validate approval for multi-approver case
**/
    @isTest static void multiApproverTest(){ 
       		String subject= Constant_Util.EMPTY_STRING;
        user currentuser = [select id, Bypass_Validation__c ,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        system.runAs(currentuser){
            Account acc = [select id from Account where RecordTypeId =: Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constant_Util.CLIENT).getRecordTypeId() LIMIT 1];
            list<case> caselist = [select id, origin, contactid, Case_Type__c, Client__c, Location__c,Reference_Number__c, 
                                       PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                       Service_Date__c,SLA_Service_Date_Time__c from Case LIMIT 1];
            List<Task> tasklst = [select id,Business_Rule__c from Task where WhatId =: caselist[0].Id LIMIT 49999];
            List<Messaging.InboundEmail> emaillst = TestDataFactory.createinboundemail(EMAIL_SUBJECT + caselist[0].id + Constant_Util.COLON +caselist[0].Reference_Number__c + Constant_Util.COLON +caselist[0].Case_Type__c,FOREMAIL,EMAIL_BODY);
            Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
            
            List<Business_Rule__c> br =[Select id ,AssetId__c,Multiple_Mandatory_Approvers__c from Business_Rule__c where Service__c = 'EXTRA PICKUP' ];
            br[0].Multiple_Mandatory_Approvers__c = true;
            database.update(br);
            
            Test.startTest();
            
            Profile p = TestDataFactory.getProfile(SYS_ADMIN);
            User usr = TestDataFactory.createUser(p);
            usr.Email = FOREMAIL;
            Database.insert(usr,true);
            
            User u =[select id,Email from User where Email =:FOREMAIL Limit 1];
            system.debug('user++'+u);
            
            Approval_Log__c al = new Approval_Log__c();
            al.BusinessRuleId__c = tasklst[0].Business_Rule__c;
            al.CaseId__c = caselist[0].Id;
            al.Status__c = Constant_Util.APPROVAL_REQUESTED;
            al.Approver_Type__c = Constant_Util.USER_RECORDTYPE;
            al.Required_Approver__c = u.Id;
            Database.insert(al);
            
            CaseApprovalHandler caseApprove = new CaseApprovalHandler();
            Messaging.InboundEmailResult result = caseApprove.handleInboundEmail(emaillst[0],env);
            
            CaseApprovalHandler caseApprove2 = new CaseApprovalHandler();
            Messaging.InboundEmailResult result2 = caseApprove2.handleInboundEmail(emaillst[0],env);
            
            System.assert(result!=null);
        }
        
   }

       
        /**
* @author tcs
* @date 03/04/2024
* @description : Test method to check creation of validate approval for non multi-approver case
**/
	@isTest static void nonMultiApproverTest(){ 
        String subject= Constant_Util.EMPTY_STRING;
     user currentuser = [select id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
     system.runAs(currentuser){
         Account acc = [select id from Account where RecordTypeId =: Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constant_Util.CLIENT).getRecordTypeId() LIMIT 1];
         Account Loc = [select id,Account.ParentId from Account where RecordTypeId =: Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constant_Util.LOCATION).getRecordTypeId() LIMIT 1];
         list<case> caselist = [select id, origin, contactid, Case_Type__c, Client__c, Location__c,Reference_Number__c, 
                                    PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                    Service_Date__c,SLA_Service_Date_Time__c,CaseNumber,RecordTypeId from Case LIMIT 1]; //SDT-33363
         Contact c = [Select id from Contact where Id =:caselist[0].contactid LIMIT 1];
         Asset a = [Select Id from Asset where Id=: caselist[0].assetid LIMIT 1];
         List<Task> tasklst = [select id,Business_Rule__c,MultiCaseId__c from Task where WhatId =: caselist[0].Id LIMIT 49999];
         
         Test.startTest();
         tasklst[0].Process__c = Constant_Util.OBTAIN_SERVICE_APPROVAL;
         tasklst[0].Outcome__c = Constant_Util.OUTCOME_ON_TASK;
         Database.update(tasklst[0]);
         Test.stopTest();
         
         Task tsk1 = new Task();
         tsk1.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(APPROVALS).getRecordTypeId(); 
         tsk1.Process__c = Constant_Util.OBTAIN_SERVICE_APPROVAL;
         tsk1.subject = Constant_Util.OBTAIN_SERVICE_APPROVAL;
         tasklst[0].Outcome__c = null;
         tsk1.MultiCaseId__c = caselist[0].Id;
         tsk1.WhatId = caselist[0].Id;
         tsk1.Business_Rule__c = tasklst[0].Business_Rule__c;
         tsk1.Is_Primary__c = false;
         tsk1.MultiCaseId__c = caselist[0].Id;
         tasklst.add(tsk1);
         Database.insert(tasklst[1]);
         
         List<Messaging.InboundEmail> emaillst1 = TestDataFactory.createinboundemail(EMAIL_SUBJECT + caselist[0].id + Constant_Util.COLON +caselist[0].Reference_Number__c + Constant_Util.COLON +caselist[0].Case_Type__c, FOREMAIL, EMAIL_BODY);
         Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
         
         CaseApprovalHandler caseApprove1 = new CaseApprovalHandler();
         Messaging.InboundEmailResult result1 = caseApprove1.handleInboundEmail(emaillst1[0],env);
         
         
         system.assert(result1 != null);
     }      
}  
 
         /**
* @author tcs
* @date 03/04/2024
* @description : Test method to check creation of validate approval for non multi-approver case
**/
 @isTest static void nonMultiApproverTest2(){ 
        String subject= Constant_Util.EMPTY_STRING;
     user currentuser = [select id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
     system.runAs(currentuser){
         Account acc = [select id from Account where RecordTypeId =: Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constant_Util.CLIENT).getRecordTypeId() LIMIT 1];
         Account Loc = [select id,Account.ParentId from Account where RecordTypeId =: Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constant_Util.LOCATION).getRecordTypeId() LIMIT 1];
         list<case> caselist = [select id, origin, contactid, Case_Type__c, Client__c, Location__c,Reference_Number__c, 
                                    PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                    Service_Date__c,SLA_Service_Date_Time__c,CaseNumber,RecordTypeId from Case LIMIT 1]; //SDT-33363
         Contact c = [Select id from Contact where Id =:caselist[0].contactid LIMIT 1];
         Asset a = [Select Id from Asset where Id=: caselist[0].assetid LIMIT 1];
         List<Task> tasklst = [select id,Business_Rule__c,MultiCaseId__c from Task where WhatId =: caselist[0].Id LIMIT 49999];
         
         Test.startTest();
         tasklst[0].Process__c = Constant_Util.OBTAIN_SERVICE_APPROVAL;
         tasklst[0].Outcome__c = Constant_Util.OUTCOME_ON_TASK;
         Database.update(tasklst[0]);

         Test.stopTest();
         
         
         List<Messaging.InboundEmail> emaillst1 = TestDataFactory.createinboundemail(EMAIL_SUBJECT + caselist[0].id + Constant_Util.COLON +caselist[0].Reference_Number__c + Constant_Util.COLON +caselist[0].Case_Type__c, FOREMAIL, EMAIL_BODY);
         emaillst1[0].subject = emaillst1[0].subject + Constant_Util.COLON + Constant_Util.MIXED;
         Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
         
         CaseApprovalHandler caseApprove1 = new CaseApprovalHandler();
         Messaging.InboundEmailResult result1 = caseApprove1.handleInboundEmail(emaillst1[0],env);
         
         
         system.assert(result1 != null);
     }      
}   

}