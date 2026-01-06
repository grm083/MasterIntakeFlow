/**************************************************
* ClassName:AutoSendEmailToServiceApproversTest
* Author:Ruchika
* Updated By: Soham Datta
* Description: Test Class to cover AutoSendEmailToServiceApprovers
* CreatedDate:2/3/2020
* Test Coverage: 89%
* **************************************************/
@isTest(seeAllData = false)
public class AutoSendEmailToServiceApproversTest {
    
    // set the test data
    @testSetup static void setup() {
        Profile p = TestDataFactory.getProfile('System Administrator');
        User usr = TestDataFactory.createUser(p);
        Database.insert(usr);
        
        System.runAs(usr){
            List<Account> acclist = TestDataFactory.createAccount('test', usr,'Client');
            Database.insert(acclist);
            
            List<Account> locationlist = TestDataFactory.createLocation('Location', usr, acclist.get(0).id);
            Database.insert(locationlist);
            
            List<Contact> conlist = TestDataFactory.createContact('first', 'last', acclist.get(0), usr);
            conlist[0].Preferred_Method__c = 'Email' ;
            conlist[0].Email = 'abc@gmail.com';
            Database.insert(conlist);
            
            List<Product2> productlist = TestDataFactory.createProduct('test');
            Database.insert(productlist);
            
            List<Account> supplieracclist = TestDataFactory.createAccount('testsupplier', usr,'Vendor');
            Database.insert(supplieracclist);
            
            List<Asset> assetlist = TestDataFactory.createAsset('first', acclist.get(0), conlist.get(0), 
                                                                productlist.get(0), usr, locationlist.get(0));
            assetlist[0].Supplier__c = supplieracclist[0].Id;
            Database.insert(assetlist);
            
            // returns 4 cases as of 3/20/2020
            List<Case> caselist = TestDataFactory.createCase('first', acclist.get(0), conlist.get(0), 
                                                             usr, locationlist.get(0), assetlist.get(0));
            caselist[0].AccountId = locationlist[0].Id;
            caselist[0].PurchaseOrder_Number__c =  '1243';
            caselist[0].Case_Type__c = 'Pickup';
            caselist[0].Case_Sub_Type__c = 'Extra Pickup';
            Database.insert(caselist);
            
            // returns 4 cases as of 3/20/2020
            List<Case> caselist2 = TestDataFactory.createCase('first', acclist.get(0), conlist.get(0), 
                                                             usr, locationlist.get(0), assetlist.get(0));
            caselist2[0].AccountId = locationlist[0].Id;
            caselist2[0].PurchaseOrder_Number__c =  '1243';
            caselist2[0].Case_Type__c = 'Pickup';
            caselist2[0].Case_Sub_Type__c = 'Extra Pickup';
            caselist2[0].parentId =  caselist[0].Id;
            Database.insert(caselist2);
            
            // returns a single Extra Pickup Business Rule
            List<Business_Rule__c> approverlst = TestDataFactory.createBusinessRule('test1',acclist.get(0),locationlist.get(0));
            approverlst[0].RecordTypeid = 
            Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get('Approval').getRecordTypeId();           
            approverlst[0].Service__c = 'Empty and Do NOT Return';
            insert approverlst;

            // returns 2 Open Normal Priority Tasks
            List<Task> tasklist = TestDataFactory.createTask(caselist.get(0).id, usr);
            tasklist[0].Business_Rule__c = approverlst[0].Id;
            Database.insert(tasklist);
            
            // returns a single service approver in a list
            List<Service_Approver__c> salst = TestDataFactory.createServiceApprover(approverlst[0]);
            salst[0].Email__c = 'abc@gmail.com';
            salst[0].Business_Rule__c = approverlst[0].Id;
            salst[0].User__c = usr.Id;
            salst[0].Requester_Only__c= false;
            salst[0].Approver_Contact__c = conlist[0].Id;
            insert salst;
            System.debug('salst'+salst);

            // Create Email Templates
            List<EmailTemplate> emailTemplateList = new List<EmailTemplate>();

            EmailTemplate singleCaseTemplate = new EmailTemplate();
            singleCaseTemplate.Name = 'Customer or Internal: Pickup Approval';
            singleCaseTemplate.isActive = true;
            singleCaseTemplate.DeveloperName = 'singlePickupApproval';
            singleCaseTemplate.TemplateType = 'text';
            singleCaseTemplate.FolderId = UserInfo.getUserId();

            emailTemplateList.add(singleCaseTemplate);

            EmailTemplate multiCaseTemplate = new EmailTemplate();
            multiCaseTemplate.Name = 'Pickup Obtain Service Approval - Multi Case';
            multiCaseTemplate.isActive = true;
            multiCaseTemplate.DeveloperName = 'multiPickupApproval';
            multiCaseTemplate.TemplateType = 'text';
            multiCaseTemplate.FolderId = UserInfo.getUserId();
            emailTemplateList.add(multiCaseTemplate);

            insert(emailTemplateList);
        }
    }
    
    //Method to cover ChangeTaskAssignment method in class
    @isTest static void sendEmail() {
        Profile p = TestDataFactory.getProfile('System Administrator');
        User currentuser = [SELECT Id, Bypass_Validation__c 
                            FROM User
                            WHERE ProfileId =: p.Id 
                            AND isActive =: true
                            LIMIT 1];
        
        System.runAs(currentuser){
            List<Case> caselist = [SELECT Id, Origin, contactid, Case_Type__c, Client__c, Location__c, 
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, 
                                   Assetid, PSI__c, PSI_Comments__c, Service_Date__c, SLA_Service_Date_Time__c 
                                   FROM Case 
                                   WHERE PurchaseOrder_Number__c =: '1243'
                                   LIMIT 1];

            List<Task> tsklst = [SELECT Id, WhatId, Business_Rule__c FROM Task];

            List<Contact> Contactlst = [SELECT Id, Preferred_Method__c, Email FROM Contact LIMIT 1];

            List<Business_Rule__c> brlst = [SELECT Id, Accountid__c, Locationid__c, Container__c, Service__c, 
                                            Request_Type__c, Schedule_Type__c, Active__c, Effective_Date__c,
                                            RecordTypeId, Required_Information__c 
                                            FROM  Business_Rule__c 
                                            WHERE RecordTypeid =: Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get('Approval').getRecordTypeId()];

            Set<ID> brlsts =  new Set<ID>();
            Set<ID> cstlsts = new Set<ID>();
            Set<ID> tsklsts = new Set<ID>();

            for(Task t : tsklst)
            {    
                brlsts.add(t.Business_Rule__c);
                cstlsts.add(t.WhatId);  
                tsklsts.add(t.Id);
            }

            Test.startTest();
            AutoSendEmailToServiceApprovers.autosendEmail(brlsts, cstlsts, tsklsts);
            Test.stopTest();

            // need to test single case assertion
            // need to test multi case assertion
            system.assert(brlsts.size() != 0);
            system.assert(cstlsts.size() != 0);
            system.assert(tsklsts.size() != 0);
        }        
    }
    
    //Method to cover ChangeTaskAssignment method in class
    @isTest static void sendEmailforClosedCase() {
        
        Profile p = TestDataFactory.getProfile('System Administrator');
        
        User currentuser = [SELECT Id, Bypass_Validation__c 
                            FROM User
                            WHERE ProfileId =: p.Id 
                            AND isActive =: true
                            LIMIT 1];
        
        
        List<Business_Rule__c> businessRules = [Select Id From Business_Rule__c];
        
        System.runAs(currentuser){
            List<Case> caselist = [SELECT Id, Origin, contactid, Case_Type__c, Client__c, Location__c, 
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, 
                                   Assetid, PSI__c, PSI_Comments__c, Service_Date__c, SLA_Service_Date_Time__c 
                                   FROM Case 
                                   WHERE PurchaseOrder_Number__c =: '1243'
                                   LIMIT 1];
            caselist[0].Status = 'Closed';
            update caselist;

            List<Task> tsklst = [SELECT Id, WhatId, Business_Rule__c FROM Task Where WhatId =: caselist[0].Id];

            List<Contact> Contactlst = [SELECT Id, Preferred_Method__c, Email FROM Contact LIMIT 1];

            List<Business_Rule__c> brlst = [SELECT Id, Accountid__c, Locationid__c, Container__c, Service__c, 
                                            Request_Type__c, Schedule_Type__c, Active__c, Effective_Date__c,
                                            RecordTypeId, Required_Information__c 
                                            FROM  Business_Rule__c 
                                            WHERE RecordTypeid =: Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get('Approval').getRecordTypeId()];

            Set<ID> brlsts =  new Set<ID>();
            Set<ID> cstlsts = new Set<ID>();
            Set<ID> tsklsts = new Set<ID>();

            for(Task t : tsklst)
            {    
                brlsts.add(t.Business_Rule__c);
                cstlsts.add(t.WhatId);  
                tsklsts.add(t.Id);
            }

            Test.startTest();
            AutoSendEmailToServiceApprovers.autosendEmail(brlsts, cstlsts, tsklsts);
            Test.stopTest();

            // need to test single case assertion
            // need to test multi case assertion
            system.assert(brlsts.size() != 0);
            system.assert(cstlsts.size() != 0);
            system.assert(tsklsts.size() != 0);
        }        
    }
    
    //Method to cover ChangeTaskAssignment method in class
    @isTest static void sendEmailforApprovedRequest() {
        
        Profile p = TestDataFactory.getProfile('System Administrator');
        
        User currentuser = [SELECT Id, Bypass_Validation__c 
                            FROM User
                            WHERE ProfileId =: p.Id 
                            AND isActive =: true
                            LIMIT 1];
        
        List<Contact> conlist = [Select Id, Email From Contact Where Email = 'abc@gmail.com'];
        List<Business_Rule__c> approverlst = [Select Id From Business_Rule__c];
        
        System.runAs(currentuser){
            List<Case> caselist = [SELECT Id, Origin, contactid, Case_Type__c, Client__c, Location__c, 
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, 
                                   Assetid, PSI__c, PSI_Comments__c, Service_Date__c, SLA_Service_Date_Time__c 
                                   FROM Case 
                                   WHERE PurchaseOrder_Number__c =: '1243'
                                   LIMIT 1];
            
            List<Task> tasklist = TestDataFactory.createTask(caselist.get(0).id, currentuser);
            tasklist[0].Business_Rule__c = approverlst[0].Id;
            tasklist[0].Outcome__c = 'Approved';
            tasklist[0].Process__c = 'Escalation Obtain Service Approval';
            tasklist[0].Attempt__c = 1;
            tasklist[0].ContactEmail__c = 'abc@gmail.com';
            tasklist[0].WhoId = conlist[0].Id;
            tasklist[0].RecordtypeId = TestDataFactory.getRecordType('Approvals','Task');
            insert tasklist;

            List<Contact> Contactlst = [SELECT Id, Preferred_Method__c, Email FROM Contact LIMIT 1];

            List<Business_Rule__c> brlst = [SELECT Id, Accountid__c, Locationid__c, Container__c, Service__c, 
                                            Request_Type__c, Schedule_Type__c, Active__c, Effective_Date__c,
                                            RecordTypeId, Required_Information__c 
                                            FROM  Business_Rule__c 
                                            WHERE RecordTypeid =: Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get('Approval').getRecordTypeId()];

            Set<ID> brlsts =  new Set<ID>();
            Set<ID> cstlsts = new Set<ID>();
            Set<ID> tsklsts = new Set<ID>();

            for(Task t : tasklist)
            {    
                brlsts.add(t.Business_Rule__c);
                cstlsts.add(t.WhatId);  
                tsklsts.add(t.Id);
            }

            Test.startTest();
            AutoSendEmailToServiceApprovers.autosendEmail(brlsts, cstlsts, tsklsts);
            Test.stopTest();

            // need to test single case assertion
            // need to test multi case assertion
            system.assert(brlsts.size() != 0);
            system.assert(cstlsts.size() != 0);
            system.assert(tsklsts.size() != 0);
        }        
    }
    
    //Method to cover ChangeTaskAssignment method in class
    @isTest static void sendEmailforApprovedRequestAttempt2() {
        
        Profile p = TestDataFactory.getProfile('System Administrator');
        
        User currentuser = [SELECT Id, Bypass_Validation__c 
                            FROM User
                            WHERE ProfileId =: p.Id 
                            AND isActive =: true
                            LIMIT 1];
        
        List<Account> acclist = [Select Id, ParentId From Account Where ParentId = null];
        List<Account> locationlist = [Select Id, ParentId From Account Where ParentId =: acclist[0].Id];
        List<Asset> assetlist = [Select Id, Location__c From Asset Where Location__c =: locationlist[0].Id];
        
        List<Case> caselist = [SELECT Id, Origin, contactid, Case_Type__c, Client__c, Location__c, 
                               PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, 
                               Assetid, PSI__c, PSI_Comments__c, Service_Date__c, SLA_Service_Date_Time__c 
                               FROM Case 
                               WHERE PurchaseOrder_Number__c =: '1243'
                               LIMIT 1];
        
        
        List<Contact> conlist = [Select Id, Email From Contact Where Email = 'abc@gmail.com'];
        List<Business_Rule__c> approverlst = [Select Id From Business_Rule__c];
        
        System.runAs(currentuser){
            
            List<Case> caselistToBeInserted = TestDataFactory.createCase('first', acclist.get(0), conlist.get(0), 
                                                             currentuser, locationlist.get(0), assetlist.get(0));
            caselistToBeInserted[0].AccountId = locationlist[0].Id;
            caselistToBeInserted[0].PurchaseOrder_Number__c =  '1243';
            caselistToBeInserted[0].Case_Type__c = 'Pickup';
            caselistToBeInserted[0].Case_Sub_Type__c = 'Extra Pickup';
            caselistToBeInserted[0].Is_MultiCase_TaskBundling__c = true;
            caselistToBeInserted[0].ParentId = caselist[0].Id;
            insert caselistToBeInserted;
            
            List<Task> tasklist = TestDataFactory.createTask(caselistToBeInserted[0].Id, currentuser);
            tasklist[0].Business_Rule__c = approverlst[0].Id;
            tasklist[0].Outcome__c = 'Approved';
            tasklist[0].Process__c = 'Escalation Obtain Service Approval';
            tasklist[0].Attempt__c = 2;
            tasklist[0].ContactEmail__c = 'abc@gmail.com';
            tasklist[0].WhoId = conlist[0].Id;
            tasklist[0].RecordtypeId = TestDataFactory.getRecordType('Approvals','Task');
            //insert tasklist;

            List<Contact> Contactlst = [SELECT Id, Preferred_Method__c, Email FROM Contact LIMIT 1];

            List<Business_Rule__c> brlst = [SELECT Id, Accountid__c, Locationid__c, Container__c, Service__c, 
                                            Request_Type__c, Schedule_Type__c, Active__c, Effective_Date__c,
                                            RecordTypeId, Required_Information__c 
                                            FROM  Business_Rule__c 
                                            WHERE RecordTypeid =: Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get('Approval').getRecordTypeId()];

            Set<ID> brlsts =  new Set<ID>();
            Set<ID> cstlsts = new Set<ID>();
            Set<ID> tsklsts = new Set<ID>();

            for(Task t : tasklist)
            {    
                brlsts.add(t.Business_Rule__c);
                cstlsts.add(t.WhatId);  
                tsklsts.add(t.Id);
            }

            Test.startTest();
            AutoSendEmailToServiceApprovers.autosendEmail(brlsts, cstlsts, tsklsts);
            Test.stopTest();

            // need to test single case assertion
            // need to test multi case assertion
            system.assert(brlsts.size() != 0);
            system.assert(cstlsts.size() != 0);
            system.assert(tsklsts.size() != 0);
        }        
    }
		

	//Method to cover ChangeTaskAssignment method in class - SDT-11964
     @isTest static void sendEmailWithActivity() {
        user currentuser = [SELECT id, Bypass_Validation__c ,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        system.runAs(currentuser){
            list<case> caselist = [SELECT id, origin, contactid, Case_Type__c, Client__c, Location__c, 
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                   Service_Date__c,SLA_Service_Date_Time__c FROM case LIMIT 1];
            list<Task> tsklst = [SELECT Id,WhatId,Business_Rule__c FROM Task];
            list<contact> Contactlst = [SELECT Id,Preferred_Method__c,Email FROM contact LIMIT 1];
            list<Business_Rule__c> brlst = [SELECT Id,Accountid__c,locationid__c,Container__c,Service__c,Request_Type__c,Schedule_Type__c,Active__c,Effective_Date__c,RecordTypeid,
                                            Required_Information__c FROM  Business_Rule__c WHERE RecordTypeid =: Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get('Approval').getRecordTypeId()];
            list<Service_Approver__c> salst = [SELECT Id, Email__c ,Business_Rule__c FROM Service_Approver__c];
            Set<ID> brlsts =  new Set<ID>();
            Set<ID> cstlsts = new Set<ID>();
            Set<ID> tsklsts = new Set<ID>();
            for(Task t : tsklst)
            {    
                    brlsts.add(t.Business_Rule__c);
                    cstlsts.add(t.WhatId);  
                    tsklsts.add(t.Id);
            }
            Test.startTest();
            AutoSendEmailToServiceApprovers.autosendEmail(brlsts,cstlsts,tsklsts);
            Test.stopTest();          
            List<Task> tsk = [SELECT id,whatid,Subject, whoid FROM Task WHERE WhatId =: caselist[0].Id LIMIT 1];
            List<Contact> cnt= [SELECT id,email FROM contact WHERE id =: tsk[0].whoid];
            System.assert(tsk.size() > 0);

            List<Service_Approver__c> salst2 = [SELECT Id, Email__c, Business_Rule__c FROM Service_Approver__c];

            for(task t: tsk){                
                if(t.Subject !=null && t.Subject.indexOf('Email: WM Approval Needed') != -1)
                {
                    System.assert(true);
                }
            }            
            if( salst2 != null && cnt != null) {
                if(cnt != null && !cnt.isEmpty() && salst2 != null && !salst2.isEmpty() && String.isNotblank(cnt[0].Email) && String.isNotBlank(salst2[0].Email__c) && cnt[0].Email == salst2[0].Email__c)
                {              
                    System.assert(true);
                }
            }
        }        
    }
}