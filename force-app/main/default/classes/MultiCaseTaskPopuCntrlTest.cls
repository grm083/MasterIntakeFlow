/**
* @author Accenture
* @date 2/6/2019
* @description : Apex class MultiCaseTaskPopuCntrlTest 
**/
/*Test class for MultiCaseTaskPopuCntrl*/
@isTest(seeAllData = false)
public class MultiCaseTaskPopuCntrlTest {
    private static final string SYS_ADMIN = 'System Administrator';
    private static final string EMAIL = 'testfrom@test.com';
    private static final string COMPACTOR = 'COMPACTOR';
    private static final string NAME = 'test';
    private static final string MIXED = ' Mixed:';
    private static final string CHECK = 'Check';
    private static final string APPROVALS = 'Approvals';
    private static final string VALUE_TEST = 'Test';
    private static final string FOREMAIL = 'testemail@test.com';
/* method for setting up data*/ 
    @testSetup static void setup() {
     
        Profile p = TestDataFactory.getProfile(SYS_ADMIN);
        User usr = TestDataFactory.createUser(p);
        Database.insert(usr);  
        system.runAs(usr){
            //Changes related to Sprint 10 test class errors
            Test.startTest();
            list<Account> acclist = TestDataFactory.createAccount(Constant_Util.KEYWORD_TEST, usr);
            Database.insert(acclist);
            list<Account> locationlist = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, acclist.get(0).id);
            locationlist[0].tz__Timezone_SFDC__c = 'America/New_York';
            locationlist[0].tz__UTF_Offset__c = -4;
            Database.insert(locationlist);
            list<Contact> conlist = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST,Constant_Util.CONSTANT_LAST, acclist.get(0), usr);
            conlist[0].Contact_Status__c = 'Active';
            Database.insert(conlist);
            AccountContactRelation AccContactRel = TestDataFactory.returnAccConRel(acclist[1].Id,conlist[0],'Commercial Service/Dispatch;Rolloff Service/Dispatch;Dispatch');
            Database.insert(AccContactRel);
            list<product2> productlist = TestDataFactory.createProduct(Constant_Util.KEYWORD_TEST);
            productlist[0].ProductTypeSelected__c = COMPACTOR;
            productlist[0].Family = 'Rolloff';
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
            
            list<Business_Rule__c> brlst1 = TestDataFactory.createBusinessRule(NAME,acclist.get(0),locationlist.get(0));
            brlst1[0].Service__c = Constant_Util.EXTRA_PICKUP;
            brlst1[0].Schedule_Type__c = Constant_Util.EMPTY_STRING;
            brlst1[0].Container__c = Constant_Util.EMPTY_STRING;
            brlst1[0].Multiple_Mandatory_Approvers__c = false;
            brlst1[0].AssetId__c = null;
            brlst1[0].RecordTypeid = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.REQUIRED_INFORMATION).getRecordTypeId();
            brlst1[0].Required_Information__c = 'PO Number'; //SDT-33363
            Database.insert(brlst1);
            
            list<Contact> conlist1 = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST,VALUE_TEST, acclist.get(0), usr);
            conlist1[0].Email = EMAIL;
            Database.insert(conlist1);
            
            List<Asset> assetlist1 = TestDataFactory.createAsset(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                                productlist.get(0), usr, locationlist.get(0));
            assetlist1[0]. Supplier__c = acclist[1].Id;
            Database.insert(assetlist1);            
            
            List<Sla_Calculation__c> sla = new List<Sla_Calculation__c>();
            Sla_Calculation__c slaPickup = new Sla_Calculation__c();
            slaPickup.Name = 'Pickup';
            slaPickup.Enabled__c= True;
            slaPickup.Normalized_SLA__c = false;
            sla.add(slaPickup);
            
            Database.insert(sla,false);
            //Changes related to Sprint 10 test class errors
            Test.stopTest();
        }
    }
    @isTest static void MultiTasksTest1(){ 
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(currentuser){
            Account acc = [select id from Account where RecordTypeId =: Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constant_Util.CLIENT).getRecordTypeId() LIMIT 1];
            Account Loc = [select id,Account.ParentId from Account where RecordTypeId =: Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constant_Util.LOCATION).getRecordTypeId() LIMIT 1];
            list<case> caselist = [select id, origin, contactid, Case_Type__c, Client__c, Location__c,Reference_Number__c, 
                                       PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                       Service_Date__c,SLA_Service_Date_Time__c,CaseNumber,RecordTypeId from Case LIMIT 1];
            List<Asset> assetLst = [Select Id,Supplier__c,Product2.Family,Product2.ProductTypeSelected__c from Asset LIMIT 2];

            List<Business_Rule__c> brlst = [select id,RecordType.Name,Active__c,Required_Information__c from Business_Rule__c LIMIT 2];
			List<Case> caseInsertlst = new List<Case>();
            List<Task> tasklist = new List<Task>();


            Test.startTest(); 
			Case c2 = new Case();
            c2.AssetId = assetLst[0].Id;
            c2.RecordTypeId = caselist[0].RecordTypeId;
            c2.Client__c = caselist[0].Client__c;
            c2.origin = caselist[0].origin;
            c2.Supplier__c = assetLst[0].Supplier__c;
            c2.Location__c = caselist[0].Location__c;
            c2.Case_Type__c = caselist[0].Case_Type__c;
            c2.Case_Sub_Type__c = caselist[0].Case_Sub_Type__c;
            c2.Service_Date__c = system.today();
            c2.Is_Multiple_Asset__c = true;
            c2.ParentId = caselist[0].Id;
            c2.Reference_Number__c = caselist[0].CaseNumber;
            caseInsertlst.add(c2);

            Case c3 = new Case();
            c3.AssetId = assetLst[1].Id;
            c3.Client__c = caselist[0].Client__c;
            c3.Supplier__c = assetLst[0].Supplier__c;
            c3.RecordTypeId = caselist[0].RecordTypeId;
            c3.origin = caselist[0].origin;
            c3.Location__c = caselist[0].Location__c;
            c3.Case_Type__c = caselist[0].Case_Type__c;
            c3.Case_Sub_Type__c = caselist[0].Case_Sub_Type__c;
            c3.Is_Multiple_Asset__c = true;
            c3.Service_Date__c = system.today();
            c3.ParentId = caselist[0].Id;
            c3.Reference_Number__c = caselist[0].CaseNumber;
            caseInsertlst.add(c3);
            Database.insert(caseInsertlst);

            List<Case> caslst = new List<Case>();
            c2.Status = 'Pending';
            c3.Status = 'Pending';
            caslst.add(c2);
            caslst.add(c3);
            
            Database.update(caslst,false);

            List<Approval_Log__c> approvalList = new List<Approval_Log__c>();
            Approval_Log__c al = new Approval_Log__c();
            al.BusinessRuleId__c = brlst[0].Id;
            al.CaseId__c = c2.Id;
            al.Approver_Type__c = Constant_Util.DEPARTMENT_RECORDTYPE;
            al.ServiceApprovers__c = CHECK;
            approvalList.add(al);
            
            Approval_Log__c al1 = new Approval_Log__c();
            al1.BusinessRuleId__c = brlst[0].Id;
            al1.Approver_Type__c = Constant_Util.DEPARTMENT_RECORDTYPE;
            al1.CaseId__c = c3.Id;
            al1.ServiceApprovers__c = CHECK;
            approvalList.add(al1);
            
            Database.insert(approvalList);
            
            list<EmailMessage> emlst = TestDataFactory.createEmailMessage(MIXED,VALUE_TEST,caselist[0]);
            emlst[0].FromAddress = FOREMAIL;
            Database.Insert(emlst);
            
            Task tsk = new Task();
            tsk.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(APPROVALS).getRecordTypeId(); 
            tsk.Process__c = Constant_Util.MULTI_CASE_APPROVAL_TASK;
            tsk.subject = Constant_Util.MULTI_CASE_APPROVAL_TASK;
            tsk.WhatId = c2.Id;
            tsk.Department_Name__c = FOREMAIL;
            tsk.ContactEmail__c = FOREMAIL;
            tsk.Approval_Log__c = al.Id;
            tsk.Business_Rule__c = brlst[0].Id;
            tsk.Attempt__c = 1;
            tsk.MultiCaseId__c = caselist[0].Id;
            tasklist.add(tsk);
            //Changes related to Sprint 10 test class errors
            Test.stopTest();
            Task tsk1 = new Task();
            tsk1.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(APPROVALS).getRecordTypeId(); 
            tsk1.Process__c = Constant_Util.OBTAIN_SERVICE_APPROVAL;
            tsk1.subject = Constant_Util.OBTAIN_SERVICE_APPROVAL;
            tsk1.Outcome__c = null;
            tsk1.Approval_Log__c = al1.Id;
            tsk1.Department_Name__c = FOREMAIL;
            tsk1.WhatId = c3.Id;
            tsk1.Attempt__c = 1;
            tsk1.MultiCaseId__c = caselist[0].Id;
            tsk1.Business_Rule__c = brlst[0].Id;
            tasklist.add(tsk1);
            Database.insert(tasklist);

            List<Task> tsklst = [select id,Process__c,Outcome__c,whatId,MultiCaseId__c,PurchaseOrder_Number__c,Profile_Number__c,Proposed_Service_Date__c from Task where whatId =: c2.Id LIMIT 1];
            List<Task> childtsklst = [select id,Process__c,whatId,MultiCaseId__c,Outcome__c,PurchaseOrder_Number__c,Profile_Number__c,Proposed_Service_Date__c,WhoId from Task where whatId =: c3.Id LIMIT 1];
            
            MultiCaseTaskPopuCntrl.getTaskList(tsklst[0].Id,true);

            tsklst[0].Outcome__c = 'Vendor Available';
            tsklst[0].WhoId = caselist[0].contactid;
            tsklst[0].Approver_Name__c = caselist[0].contactid;
            tsklst[0].ContactEmail__c = 'Test@gmail.com';
           // Database.Update(tsklst);
            List<Task> updateTasklst = new List<Task>();
	    if(childtsklst.size() > 0)
            {
		    updateTasklst.add(childtsklst[0]);
		    updateTasklst[0].Outcome__c = 'Vendor Unavailable';
		    MultiCaseTaskPopuCntrl.populateOutcome(updateTasklst,tsklst[0].Id);
	    }
            
            //Task t = [Select id,Outcome__c from Task where Id=:tsklst[0].Id];
            //system.assertEquals('Vendor Available',t.Outcome__c);
            
             
        }       
    }
    @isTest static void MulticaseDepartmentTest(){ 
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
            Business_Rule__c b = [select id from Business_Rule__c where RecordType.Name =: Constant_Util.APPROVAL LIMIT 1];
            
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
            
            List<Approval_Log__c> approvalList = new List<Approval_Log__c>();
            Approval_Log__c al = new Approval_Log__c();
            al.BusinessRuleId__c = b.Id;
            al.CaseId__c = caselist[0].Id;
            al.Approver_Type__c = Constant_Util.DEPARTMENT_RECORDTYPE;
            al.ServiceApprovers__c = CHECK;
            approvalList.add(al);
            
            List<Task> tasklist = new List<Task>();
            
            Approval_Log__c al1 = new Approval_Log__c();
            al1.BusinessRuleId__c = b.Id;
            al1.Approver_Type__c = Constant_Util.DEPARTMENT_RECORDTYPE;
            al1.CaseId__c = c2.Id;
            al1.ServiceApprovers__c = CHECK;
            approvalList.add(al1);
            
            Database.insert(approvalList);
            
            system.debug('approvalList'+approvalList);
            list<EmailMessage> emlst = TestDataFactory.createEmailMessage(MIXED,VALUE_TEST,caselist[0]);
            emlst[0].FromAddress = FOREMAIL;
            Database.Insert(emlst);
            
            Task tsk = new Task();
            tsk.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(APPROVALS).getRecordTypeId(); 
            tsk.Process__c = Constant_Util.MULTI_CASE_APPROVAL_TASK;
            tsk.subject = Constant_Util.MULTI_CASE_APPROVAL_TASK;
            tsk.WhatId = caselist[0].Id;
            tsk.Department_Name__c = FOREMAIL;
            tsk.ContactEmail__c = FOREMAIL;
            tsk.Approval_Log__c = al.Id;
            tsk.Business_Rule__c = b.Id;
            tsk.Attempt__c = 1;
            tsk.MultiCaseId__c = caselist[0].Id;
            tasklist.add(tsk);
            
            Task tsk1 = new Task();
            tsk1.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(APPROVALS).getRecordTypeId(); 
            tsk1.Process__c = Constant_Util.OBTAIN_SERVICE_APPROVAL;
            tsk1.subject = Constant_Util.OBTAIN_SERVICE_APPROVAL;
            tsk1.Outcome__c = null;
            tsk1.Approval_Log__c = al1.Id;
            tsk1.Department_Name__c = FOREMAIL;
            tsk1.WhatId = c2.Id;
            tsk1.Attempt__c = 1;
            tsk1.MultiCaseId__c = caselist[0].Id;
            tsk1.Business_Rule__c = b.Id;
            tasklist.add(tsk1);
            
            Test.startTest();
            
            Database.insert(tasklist);
            
            //MultiCaseTaskPopuCntrl mu = new MultiCaseTaskPopuCntrl();
            MultiCaseTaskPopuCntrl.getTaskList(tsk.Id,true);
            Test.stopTest();
        }
    }
        @isTest static void MulticaseUserTest(){ 
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
            Business_Rule__c b = [select id from Business_Rule__c where RecordType.Name =: Constant_Util.APPROVAL LIMIT 1];
            
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
            
            List<Approval_Log__c> approvalList = new List<Approval_Log__c>();
            Approval_Log__c al = new Approval_Log__c();
            al.BusinessRuleId__c = b.Id;
            al.CaseId__c = caselist[0].Id;
            al.Approver_Type__c = Constant_Util.USER_RECORDTYPE;
            al.ServiceApprovers__c = CHECK;
            approvalList.add(al);
            
            Approval_Log__c al1 = new Approval_Log__c();
            al1.BusinessRuleId__c = b.Id;
            al1.CaseId__c = c2.Id;
            al1.Approver_Type__c = Constant_Util.USER_RECORDTYPE;
            al1.ServiceApprovers__c = CHECK;
            approvalList.add(al1);
            
            Database.insert(approvalList);
            
            List<Task> tasklist = new List<Task>();
            Task tsk = new Task();
            tsk.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(APPROVALS).getRecordTypeId(); 
            tsk.Process__c = Constant_Util.OBTAIN_SERVICE_APPROVAL;
            tsk.subject = Constant_Util.OBTAIN_SERVICE_APPROVAL;
            tsk.WhatId = caselist[0].Id;
            tsk.Attempt__c = 1;
            tsk.Contact_Title__c = FOREMAIL;
            tsk.Approval_Log__c = al.Id;
            tsk.Business_Rule__c = b.Id;
            tsk.MultiCaseId__c = caselist[0].Id;
            tasklist.add(tsk);
            
            Task tsk1 = new Task();
            tsk1.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(APPROVALS).getRecordTypeId(); 
            tsk1.Process__c = Constant_Util.OBTAIN_SERVICE_APPROVAL;
            tsk1.subject = Constant_Util.OBTAIN_SERVICE_APPROVAL;
            tsk1.Outcome__c = null;
            tsk1.Approval_Log__c = al1.Id;
            tsk.Contact_Title__c = FOREMAIL;
            tsk1.WhatId = c2.Id;
            tsk1.Business_Rule__c = b.Id;
            tsk1.Attempt__c = 1;
            tsk1.MultiCaseId__c = caselist[0].Id;
            tasklist.add(tsk1);          
            
            Test.startTest();
            
            Database.insert(tasklist);
            
            //MultiCaseTaskPopuCntrl mu = new MultiCaseTaskPopuCntrl();
            MultiCaseTaskPopuCntrl.getTaskList(tsk.Id,true);
             MultiCaseTaskPopuCntrl.getTaskList(tsk.Id,false);
            tasklist[0].Outcome__c = Constant_Util.APPROVED;
            MultiCaseTaskPopuCntrl.populateOutcome(tasklist, tsk.Id);
            Test.stopTest();
        }
    }
    @isTest static void MulticaseTitleTest(){ 
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
            Business_Rule__c b = [select id from Business_Rule__c where RecordType.Name =: Constant_Util.APPROVAL LIMIT 1];
            
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
            
            List<Approval_Log__c> approvalList = new List<Approval_Log__c>();
            Approval_Log__c al = new Approval_Log__c();
            al.BusinessRuleId__c = b.Id;
            al.CaseId__c = caselist[0].Id;
            al.Approver_Type__c = Constant_Util.FLOW_TITLE;
            al.ServiceApprovers__c = CHECK;
            approvalList.add(al);
                        
            Approval_Log__c al1 = new Approval_Log__c();
            al1.BusinessRuleId__c = b.Id;
            al1.CaseId__c = c2.Id;
            al1.Approver_Type__c = Constant_Util.FLOW_TITLE;
            al1.ServiceApprovers__c = CHECK;
            approvalList.add(al1);
            
            Database.insert(approvalList);
            
            List<Task> tasklist = new List<Task>();
            Task tsk = new Task();
            tsk.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Escalation').getRecordTypeId(); 
            tsk.Process__c = Constant_Util.VALIDATE_EMAIL_APPROVAL_RESPONSE;
            tsk.subject = Constant_Util.VALIDATE_EMAIL_APPROVAL_RESPONSE;
            tsk.WhatId = caselist[0].Id;
            tsk.Contact_Title__c = FOREMAIL;
            tsk.Approval_Log__c = al.Id;
            tsk.Business_Rule__c = b.Id;
            tsk.MultiCaseId__c = caselist[0].Id;
            tsk.Attempt__c = 1;
            tasklist.add(tsk);
            
            Task tsk1 = new Task();
            tsk1.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(APPROVALS).getRecordTypeId(); 
            tsk1.Process__c = Constant_Util.OBTAIN_SERVICE_APPROVAL;
            tsk1.subject = Constant_Util.OBTAIN_SERVICE_APPROVAL;
            tsk1.Outcome__c = null;
            tsk1.Approval_Log__c = al1.Id;
            tsk1.Contact_Title__c = FOREMAIL;
            tsk1.MultiCaseId__c = caselist[0].Id;
            tsk1.WhatId = c2.Id;
            tsk1.Business_Rule__c = b.Id;
            tsk1.Attempt__c = 1;
            tasklist.add(tsk1);          
            
            Test.startTest();
            
            Database.insert(tasklist);
            
            //MultiCaseTaskPopuCntrl mu = new MultiCaseTaskPopuCntrl();
            MultiCaseTaskPopuCntrl.getTaskList(tsk.Id,true);
            MultiCaseTaskPopuCntrl.getTaskList(tsk.Id,false);
            Test.stopTest();
        }
    }
    @isTest static void MulticaseEmailTest(){ 
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
            Business_Rule__c b = [select id from Business_Rule__c where RecordType.Name =: Constant_Util.APPROVAL LIMIT 1];
            
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
            
            List<Approval_Log__c> approvalList = new List<Approval_Log__c>();
            Approval_Log__c al = new Approval_Log__c();
            al.BusinessRuleId__c = b.Id;
            al.CaseId__c = caselist[0].Id;
            al.Approver_Type__c = Constant_Util.ORIGIN_EMAIL;
            al.ServiceApprovers__c = CHECK;
            approvalList.add(al);
            
            Approval_Log__c al1 = new Approval_Log__c();
            al1.BusinessRuleId__c = b.Id;
            al1.CaseId__c = c2.Id;
            al1.Approver_Type__c = Constant_Util.ORIGIN_EMAIL;
            al1.ServiceApprovers__c = CHECK;
            approvalList.add(al1);
            
            Database.insert(approvalList);
            
            List<Task> tasklist = new List<Task>();
            Task tsk = new Task();
            tsk.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(APPROVALS).getRecordTypeId(); 
            tsk.Process__c = Constant_Util.OBTAIN_SERVICE_APPROVAL;
            tsk.subject = Constant_Util.OBTAIN_SERVICE_APPROVAL;
            tsk.Outcome__c = Constant_Util.NO_OR_PENDING_RESPONSE;
            tsk.WhatId = caselist[0].Id;
            tsk.ContactEmail__c = FOREMAIL;
            tsk.Approval_Log__c = al.Id;
            tsk.Business_Rule__c = b.Id;
            tsk.MultiCaseId__c = caselist[0].Id;
            tsk.Attempt__c = 1;
            tasklist.add(tsk);
            
            Task tsk1 = new Task();
            tsk1.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(APPROVALS).getRecordTypeId(); 
            tsk1.Process__c = Constant_Util.OBTAIN_SERVICE_APPROVAL;
            tsk1.subject = Constant_Util.OBTAIN_SERVICE_APPROVAL;
            tsk1.Outcome__c = null;
            tsk1.Approval_Log__c = al1.Id;
            tsk1.ContactEmail__c = FOREMAIL;
            tsk1.MultiCaseId__c = caselist[0].Id;
            tsk1.WhatId = c2.Id;
            tsk1.Business_Rule__c = b.Id;
            tsk1.Attempt__c = 1;
            tasklist.add(tsk1);
            
            Test.startTest();
            
            Database.insert(tasklist);
            
            //MultiCaseTaskPopuCntrl mu = new MultiCaseTaskPopuCntrl();
            MultiCaseTaskPopuCntrl.getTaskList(tsk.Id,true);
            MultiCaseTaskPopuCntrl.populateOutcome(tasklist, tsk.Id);
            Test.stopTest();
        }
    }
    @isTest static void MultiCaseContactTest(){ 
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
            Business_Rule__c b = [select id from Business_Rule__c where RecordType.Name =: Constant_Util.APPROVAL LIMIT 1];
            
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
            
            List<Approval_Log__c> approvalList = new List<Approval_Log__c>();
            
            Approval_Log__c al = new Approval_Log__c();
            al.BusinessRuleId__c = b.id;
            al.CaseId__c = caselist[0].Id;
            al.Approver_Type__c = Constant_Util.CONTACT_RECORD_TYPE;
            al.ServiceApprovers__c = CHECK;
            approvalList.add(al);

			Approval_Log__c al1 = new Approval_Log__c();
            al1.BusinessRuleId__c = b.id;
            al1.CaseId__c = c2.Id;
            al1.Approver_Type__c = Constant_Util.CONTACT_RECORD_TYPE;
            al1.ServiceApprovers__c = CHECK;
            approvalList.add(al1);
            
            Database.insert(approvalList);
            
            List<Task> tasklist = new List<Task>();
            Task tsk = new Task();
            tsk.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(APPROVALS).getRecordTypeId(); 
            tsk.Process__c = Constant_Util.OBTAIN_SERVICE_APPROVAL;
            tsk.subject = Constant_Util.OBTAIN_SERVICE_APPROVAL;
            tsk.WhatId = caselist[0].Id;
            tsk.WhoId = c.Id;
            tsk.Approval_Log__c = al.Id;
            tsk.Business_Rule__c = b.id;
            tsk.MultiCaseId__c = caselist[0].Id;
            tsk.Attempt__c = 1;
            tasklist.add(tsk);
            
            Task tsk1 = new Task();
            tsk1.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(APPROVALS).getRecordTypeId(); 
            tsk1.Process__c = Constant_Util.OBTAIN_SERVICE_APPROVAL;
            tsk1.subject = Constant_Util.OBTAIN_SERVICE_APPROVAL;
            tsk1.Outcome__c = null;
            tsk1.WhoId = c.Id;
            tsk1.Approval_Log__c = al1.Id;
            tsk1.MultiCaseId__c = caselist[0].Id;
            tsk1.WhatId = c2.Id;
            tsk1.Business_Rule__c = b.id;
            tsk1.Attempt__c = 1;
            tasklist.add(tsk1);
            
            Test.startTest();
            Database.insert(tasklist);
            MultiCaseTaskPopuCntrl.getTaskList(tsk.Id,true);
            MultiCaseTaskPopuCntrl.populateOutcome(tasklist, tsk.Id);
            Test.stopTest();
        }
    }
}