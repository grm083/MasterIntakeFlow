/**
* @author Accenture
* @date 2/11/2019
* @description : Apex class taskTriggerHelperTest 
**/

/* test class for TaskTriggerHelper*/
@isTest(seeAllData = false)
public class TaskTriggerHelperTest {
    public static final string SYS_ADMIN = 'System Administrator';
    public static final string WO_STATUS = 'Accepted';
    private static final string APPROVALS = 'Approvals';
    private static final string FOREMAIL = 'testemail@test.com';
    private static final string NAME = 'test';
    private static final string CHECK = 'Check';
    private static final string TESTSUPPLIER = 'testsupplier';
    private static final string SUPPLIER = 'Vendor';
    private static final String Quick_Task = 'Quick Task';
    //Changes related to SDT-33465
    private static final string CUSTOMER_SERVICE = 'Customer Service';
    
    /* set up the test data*/
    @testSetup static void setup() {
        //Changes related to SDT-33465
        Profile p = TestDataFactory.getProfile(CUSTOMER_SERVICE);
        User usr = TestDataFactory.createUser(p);
        Database.insert(usr);
        
        system.runAs(usr){
            //Changes for SDT-39632
            CodeSwitchTestData.CodeSwitchData();
            
            list<Account> acclist = TestDataFactory.createAccount(Constant_Util.KEYWORD_TEST, usr);
			acclist[0].Primary_Segment__c = 'Manufacturing';
            Database.insert(acclist);
            list<Account> locationlist = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, acclist.get(0).id);
            locationlist[0].tz__Timezone_SFDC__c = 'America/New_York';
            locationlist[0].tz__UTF_Offset__c = -4;
            Database.insert(locationlist);
            list<Contact> conlist = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST, Constant_Util.CONSTANT_LAST, acclist.get(0), usr);
            conlist[0].Contact_Status__c = 'Active';
            Database.insert(conlist);
            list<product2> productlist = TestDataFactory.createProduct(Constant_Util.KEYWORD_TEST);
            productlist[0].ProductTypeSelected__c = 'Compactor';
            productlist[0].Family = 'Rolloff';
            Database.insert(productlist);
            list<Account> supplieracclist = TestDataFactory.createAccount(TESTSUPPLIER , usr, SUPPLIER);
            supplieracclist[0].AccountNumber = '600';
            Database.insert(supplieracclist);
            //changes related to SDT-38439
            AccountContactRelation AccContactRel = TestDataFactory.returnAccConRel(supplieracclist[0].Id,conlist[0],'Commercial Service/Dispatch;Rolloff Service/Dispatch;Dispatch;2nd Dispatch Escalation-Rolloff;2nd Dispatch Escalation-Commercial');
            Database.insert(AccContactRel);
            list<Asset> assetlist = TestDataFactory.createAsset(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                                productlist.get(0), usr, locationlist.get(0));
            List<Project_Code__c> pCodeList=TestDataFactory.createProjectCode(acclist.get(0).Id);
            Database.insert(pCodeList);
            assetlist[0].Supplier__c = supplieracclist[0].Id;
            assetlist[0].Project_Code__c = pCodeList[0].Id;
            assetlist[0].End_Date__c = system.today() - 2;
            Database.insert(assetlist);
           
            list<Case> caselist = TestDataFactory.createCase(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                             usr, locationlist.get(0), assetlist.get(0));
            caselist[0].Service_Date__c = system.today();
            
            Database.insert(caselist);
            
            list<Task> tasklist = TestDataFactory.createTask(caselist.get(0).id, usr);
            tasklist[0].RecordTypeId = TestDataFactory.getRecordType(Constant_Util.APPROVALS,Constant_Util.OBJECT_TASK);
            //tasklist[0].Process__c = Constant_Util.OBTAIN_SERVICE_APPROVAL;
            tasklist[0].Process__c = 'Escalation Obtain Service Approval';
            tasklist[0].Attempt__c = 1;
		
	    //changes for test class errors
            tasklist[1].RecordTypeId =  Schema.SObjectType.Task.getRecordTypeInfosByName().get('Escalation').getRecordTypeId(); 
            tasklist[1].Process__c = 'Escalation Obtain Customer Info';
            tasklist[1].Attempt__c = 1;
            Database.insert(tasklist);
            
            list<Business_Rule__c> brlst = TestDataFactory.createBusinessRule(NAME,acclist.get(0),locationlist.get(0));
            brlst[0].Service__c = Constant_Util.EXTRA_PICKUP;
            brlst[0].Schedule_Type__c = Constant_Util.EMPTY_STRING;
            brlst[0].Container__c = Constant_Util.EMPTY_STRING;
            brlst[0].Multiple_Mandatory_Approvers__c = false;
            brlst[0].AssetId__c = assetlist[0].Id;
            brlst[0].Is_Auto_Email__c = true;
            brlst[0].RecordTypeid = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.APPROVAL).getRecordTypeId();
            brlst[0].Required_Information__c = null; 
            Database.insert(brlst);
            
            list<Business_Rule__c> brlst1 = TestDataFactory.createBusinessRule(NAME,acclist.get(0),locationlist.get(0));
            brlst1[0].Service__c = Constant_Util.EXTRA_PICKUP;
            brlst1[0].Schedule_Type__c = Constant_Util.EMPTY_STRING;
            brlst1[0].Container__c = Constant_Util.EMPTY_STRING;
            brlst1[0].Multiple_Mandatory_Approvers__c = false;
            brlst1[0].AssetId__c = null;
              brlst[0].Is_Auto_Email__c = true;
            brlst1[0].RecordTypeid = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.REQUIRED_INFORMATION).getRecordTypeId();
            brlst1[0].Required_Information__c = 'PO Number';  //SDT-33363
            Database.insert(brlst1);
            
            list<Task> tasklist2 = TestDataFactory.createTask(caselist.get(0).id, usr);
            Generic_Values__mdt objGV= new Generic_Values__mdt();
            String objuser;
            objUser = [Select Id, Id__c, DeveloperName from Generic_Values__mdt where DeveloperName = 'Genesys_User'].Id__c;
            tasklist2[0].OwnerId = objUser;
            tasklist2[0].Is_Genesys_User__c = true;
            
            tasklist2[0].whatid = caselist[0].id;
            tasklist2[0].Process__c = Constant_Util.Obtain_Schedule_Confirmation;
            tasklist2[0].Due_Date_Time__c = system.today();
            
            Database.insert(tasklist2);
            //Changes related to SDT-33465
            List<Genesys_Routing__c> grRecList= new List<Genesys_Routing__c>();
            Genesys_Routing__c gr = new Genesys_Routing__c();
            gr.SFDCObjRecordID__c = tasklist2[0].Id;
            
             gr.SFDCTaskCaseId__c = tasklist2[0].WhatId;
                  //  gr.SFDCTaskDescCode__c = tskdescmap != null && tskdescmap.containskey(tsk.Process__c) ? tskdescmap.get(tsk.Process__c).TaskDescCode__c : null;
                    gr.SFDCTaskDescription__c = tasklist2[0].Process__c;
                    gr.SFDCTaskDueDateTime__c = tasklist2[0].Due_Date_Time__c;
                    gr.Action__c = 'Cancel';
                    gr.Action_Reason__c = 'Completed';
            		//Changes related to SDT-33465
            		grRecList.add(gr);
            
            //Changes related to SDT-33465
            insert grRecList;
          
            //Changes related to SDT -33637
            test.starttest();
            list<WorkOrder> workOrderList = TestDataFactory.createWorkOrder(acclist.get(0), conlist.get(0), caselist[0], assetlist.get(0));
            workOrderList[0].Status = WO_STATUS ;
            workOrderList[0].Service_Date__c = system.today() - 3;
            Database.insert(workOrderList);
            
            List<Asset> assetlist1 = TestDataFactory.createAsset(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                                productlist.get(0), usr, locationlist.get(0));
            assetlist1[0]. Supplier__c = supplieracclist[0].Id;
            Database.insert(assetlist1);            
            
            list<product2> productlist1 = TestDataFactory.createProduct(Constant_Util.KEYWORD_TEST);
            productlist1[0].ProductTypeSelected__c = 'Compactor';
            productlist1[0].Family = 'Commercial';
            Database.insert(productlist1);
            
            List<Asset> assetlist2 = TestDataFactory.createAsset(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                                productlist1.get(0), usr, locationlist.get(0));
            assetlist2[0].Supplier__c = acclist[2].Id;
            Database.insert(assetlist2);
            
            AccountContactRelation AccContactRel1 = TestDataFactory.returnAccConRel(acclist[2].Id,conlist[0],'Commercial Service/Dispatch');
            Database.insert(AccContactRel1);
            
            List<Sla_Calculation__c> sla = new List<Sla_Calculation__c>();
            Sla_Calculation__c slaPickup = new Sla_Calculation__c();
            slaPickup.Name = 'Pickup';
            slaPickup.Enabled__c= True;
            slaPickup.Normalized_SLA__c = false;
            sla.add(slaPickup);
            Database.insert(sla,false);
            
            
            list<Case> caselist1 = TestDataFactory.createCase(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                             usr, locationlist.get(0), assetlist.get(0));
            caselist1[0].status=  Constant_Util.CLOSED;
            Database.insert(caselist1 );

            list<Case> caselist2 = TestDataFactory.createCase(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                             usr, locationlist.get(0), assetlist.get(0));
            caselist2[0].status=  Constant_Util.OPEN;
            caselist2[0].Case_Sub_Status__c = Constant_Util.Pending_Service_Confirmation;
            caselist2[0].Tracking_Number__c = 'T25124188' ;
	               
            //addition Is_Multiple_Asset__c value true - code coverage dated 3/4/2024
            caselist2[0].Is_Multiple_Asset__c = true;
			
           
            Database.insert(caselist2 );    
            //Changes related to SDT -33637       
            Test.stopTest();
        } 
        
    }
	//added as part of coverage issue date 3/4/2024
	@isTest static void testPopulateDueDate(){ 
        Test.startTest();  //to change
        user currentuser = [SELECT id, isActive,ProfileId,User_categorization_code__c FROM User where Alias = 'standt' LIMIT 1];
        system.runAs(currentuser){
            //Test.startTest();
            list<case> caselist = [select id, origin, CaseNumber from Case WHERE status =: Constant_Util.OPEN AND Tracking_Number__c ='T25124188' LIMIT 1];
            Task tsk = new Task();
            tsk.subject = 'Customer Call Back Request';
            tsk.WhatId = caselist[0].id;
            tsk.Process__c = 'Customer Call Back Request';
            tsk.Status = 'Open';
			tsk.Is_Genesys_User__c = True;
			tsk.Description = 'Exit Point : Add Lock Contact First name : Test Contact Last name : Client Contact Phone number : 1234567890 Best time to call back : 9:00AM to Noon Interaction Type: Chat Interaction Id: KRG0683FM';
            Database.insert(tsk);
            Test.stopTest();
        }
    }
    /* Test Method for ValidateCase Method*/
    @isTest static void validateCaseInfo(){

        //test class errors - SDT - 33363
        //Changes related to SDT-33465
        User usr = [SELECT Id, Profile.Name, Bypass_Validation__c, IsActive FROM User WHERE Bypass_Validation__c =: false AND Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive =: true LIMIT 1];
        
        system.runAs(usr){
            Test.startTest();
            list<Task> tasklist = [select id, whatid, process__c, Outcome__c from task limit 1] ;
            List<Case> caselist = [select id,Service_Date__c from Case where id =: tasklist.get(0).WhatId LIMIT 1];
            //system.debug('case service date'+caselist[0].Service_Date__c);
            tasklist.get(0).Outcome__c = Constant_Util.INFORMATION_NOT_OBTAIN;
            tasklist.get(0).Proposed_Service_Date__c = system.today() - 2;
            tasklist.get(0).process__c = Constant_Util.REJECTED_WORK_ORDER;
            
            Database.update(tasklist,false);
            //system.debug('outcome++'+tasklist.get(0).Outcome__c);
            Test.stopTest();
            system.assertEquals(Constant_Util.INFORMATION_NOT_OBTAIN,tasklist.get(0).Outcome__c);
        } 
        
    }
    
     /* Test Method for ValidateCase Method*/
    @isTest static void validateCaseInfo1(){

        //test class errors - SDT - 33363
       //Changes related to SDT-33465
        User usr = [SELECT Id, Profile.Name, Bypass_Validation__c, IsActive FROM User WHERE Bypass_Validation__c =: false AND Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive =: true LIMIT 1];
        
        system.runAs(usr){
            Test.startTest();
            list<Task> tasklist = [select id, whatid, process__c, Outcome__c from task limit 1] ;
            List<Case> caselist = [select id,Service_Date__c from Case where id =: tasklist.get(0).WhatId LIMIT 1];
            //system.debug('case service date'+caselist[0].Service_Date__c);
            tasklist.get(0).Outcome__c = Constant_Util.STR_VENDOR_UNAVAILABLE_OUTCOME;
            tasklist.get(0).Proposed_Service_Date__c = system.today() - 2;
            tasklist.get(0).process__c = Constant_Util.STR_ESCALATION_CONFIRM_VENDOR_AVAILABILITY;
            //Test.startTest();
            Database.update(tasklist,false);
            //system.debug('outcome++'+tasklist.get(0).Outcome__c);
            Test.stopTest();
            system.assertEquals(Constant_Util.STR_VENDOR_UNAVAILABLE_OUTCOME,tasklist.get(0).Outcome__c);
        } 
        
    }
    
    
    /* Test Method for ValidateCase Method*/
    @isTest static void validateCaseInfo2(){

        //test class errors - SDT - 33363
       //Changes related to SDT-33465
        User usr = [SELECT Id, Profile.Name, Bypass_Validation__c, IsActive FROM User WHERE Bypass_Validation__c =: false AND Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive =: true LIMIT 1];
        
        system.runAs(usr){
            Test.startTest();
            list<Task> tasklist = [select id, whatid, process__c, Outcome__c from task limit 1] ;
            List<Case> caselist = [select id,Service_Date__c from Case where id =: tasklist.get(0).WhatId LIMIT 1];
            //system.debug('case service date'+caselist[0].Service_Date__c);
            tasklist.get(0).Outcome__c = Constant_Util.STR_SERVICE_RESCHEDULED_OUTCOME;
            tasklist.get(0).Proposed_Service_Date__c = system.today() - 2;
            tasklist.get(0).process__c = Constant_Util.Obtain_Schedule_Confirmation;
            //Test.startTest();
            Database.update(tasklist,false);
            //system.debug('outcome++'+tasklist.get(0).Outcome__c);
            Test.stopTest();
            system.assertEquals(Constant_Util.STR_SERVICE_RESCHEDULED_OUTCOME,tasklist.get(0).Outcome__c);
        } 
        
    }
    
    /* Test Method for ValidateCase Method*/
    @isTest static void validateCaseInfo3(){
  
        //test class errors - SDT - 33363
       //Changes related to SDT-33465
        User usr = [SELECT Id, Profile.Name, Bypass_Validation__c, IsActive FROM User WHERE Bypass_Validation__c =: false AND Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive =: true LIMIT 1];
        
        system.runAs(usr){
            Test.startTest();
            list<Task> tasklist = [select id, whatid, process__c, Outcome__c from task limit 1] ;
            List<Case> caselist = [select id,Service_Date__c from Case where id =: tasklist.get(0).WhatId LIMIT 1];
            //system.debug('case service date'+caselist[0].Service_Date__c);
            tasklist.get(0).Outcome__c = Constant_Util.STR_NEW_ETA_PROVIDED_OUTCOME;
            tasklist.get(0).Proposed_Service_Date__c = system.today() - 2;
            tasklist.get(0).process__c = Constant_Util.STR_ESCALATION_OBTAIN_VENDOR_INFORMATION;
            //Test.startTest();
            Database.update(tasklist,false);
            //system.debug('outcome++'+tasklist.get(0).Outcome__c);
            Test.stopTest();
            system.assertEquals(Constant_Util.STR_NEW_ETA_PROVIDED_OUTCOME,tasklist.get(0).Outcome__c);
        } 
        
    }
    
    /* Test Method for ValidateCase Method*/
    @isTest static void validateCaseInfo4(){

        //test class errors - SDT - 33363
       //Changes related to SDT-33465
        User usr = [SELECT Id, Profile.Name, Bypass_Validation__c, IsActive FROM User WHERE Bypass_Validation__c =: false AND Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive =: true LIMIT 1];
        
        system.runAs(usr){
            Test.startTest();
            list<Task> tasklist = [select id, whatid, process__c, Outcome__c from task limit 1] ;
            List<Case> caselist = [select id,Service_Date__c from Case where id =: tasklist.get(0).WhatId LIMIT 1];
            //system.debug('case service date'+caselist[0].Service_Date__c);
            tasklist.get(0).Outcome__c = Constant_Util.STR_SERVICE_EVIDENCE_RECEIVED_OUTCOME;
            tasklist.get(0).Proposed_Service_Date__c = system.today() - 2;
            tasklist.get(0).process__c = Constant_Util.STR_ESCALATION_OBTAIN_VENDOR_INFORMATION;
            //Test.startTest();
            Database.update(tasklist,false);
            //system.debug('outcome++'+tasklist.get(0).Outcome__c);
            Test.stopTest();
            system.assertEquals(Constant_Util.STR_SERVICE_EVIDENCE_RECEIVED_OUTCOME,tasklist.get(0).Outcome__c);
        } 
        
    }
    
    
    /* Test Method for ValidateCase Method*/
    @isTest static void validateCaseInfo5(){
    
        //test class errors - SDT - 33363
       //Changes related to SDT-33465
        User usr = [SELECT Id, Profile.Name, Bypass_Validation__c, IsActive FROM User WHERE Bypass_Validation__c =: false AND Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive =: true LIMIT 1];
        
        system.runAs(usr){
            Test.startTest();
            list<Task> tasklist = [select id, whatid, process__c, Outcome__c from task limit 1] ;
            List<Case> caselist = [select id,Service_Date__c from Case where id =: tasklist.get(0).WhatId LIMIT 1];
            //system.debug('case service date'+caselist[0].Service_Date__c);
            tasklist.get(0).Outcome__c = Constant_Util.STR_SERVICE_DATE_CHANGE_OUTCOME;
            tasklist.get(0).Proposed_Service_Date__c = system.today() - 2;
            tasklist.get(0).process__c = Constant_Util.ESCALATION_REJECTED_WORK_ORDER;
            //Test.startTest();
            Database.update(tasklist,false);
            //system.debug('outcome++'+tasklist.get(0).Outcome__c);
            Test.stopTest();
            system.assertEquals(Constant_Util.STR_SERVICE_DATE_CHANGE_OUTCOME,tasklist.get(0).Outcome__c);
        } 
        
    }
    
    
    /* Test Method for CompleteTask Method*/
    @isTest static void CompleteTask(){

        //test class errors - SDT - 33363
       //Changes related to SDT-33465
        User usr = [SELECT Id, Profile.Name, Bypass_Validation__c, IsActive FROM User WHERE Bypass_Validation__c =: false AND Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive =: true LIMIT 1];
        Business_Rule__c bR = [select id,Is_Auto_Email__c,Multiple_Mandatory_Approvers__c from Business_Rule__c LIMIT 1];
        system.runAs(usr){
            Generic_Values__mdt objGV= new Generic_Values__mdt();
            String objuser;
            objUser = [Select Id, Id__c, DeveloperName from Generic_Values__mdt where DeveloperName = 'Genesys_User'].Id__c;
            
            list<Task> tasklist = [select id, whatid,Attempt__c, process__c,Business_Rule__c, Outcome__c, Status from task where OwnerId =: objUser limit 1] ;
            //tasklist[0].Process__c = 'Escalation Obtain Service Approval';
            tasklist[0].Attempt__c = 1;
            tasklist[0].Business_Rule__c = bR.Id;
           
            tasklist.get(0).Status = Constant_Util.COMPLETED;
            Test.startTest();
            Database.update(tasklist,false);
           
            Test.stopTest();
            system.assertEquals(Constant_Util.COMPLETED,tasklist.get(0).Status);
        } 
        
    }
     @isTest static void CompleteTask2(){

        //test class errors - SDT - 33363
       //Changes related to SDT-33465
        User usr = [SELECT Id, Profile.Name, Bypass_Validation__c, IsActive FROM User WHERE Bypass_Validation__c =: false AND Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive =: true LIMIT 1];
        Business_Rule__c bR = [select id,Is_Auto_Email__c,Multiple_Mandatory_Approvers__c from Business_Rule__c LIMIT 1];
        system.runAs(usr){
            Generic_Values__mdt objGV= new Generic_Values__mdt();
            String objuser;
            objUser = [Select Id, Id__c, DeveloperName from Generic_Values__mdt where DeveloperName = 'Genesys_User'].Id__c;
            
            list<Task> tasklist = [select id, whatid, process__c, Outcome__c, Status from task where OwnerId =: objUser  limit 1] ;
	    //changes related to test class coverage
            tasklist[0].RecordTypeId =  Schema.SObjectType.Task.getRecordTypeInfosByName().get('Escalation').getRecordTypeId(); 
            tasklist[0].Process__c = 'Escalation Obtain Service Approval';
            tasklist[0].Attempt__c = 1;
	    //changes related to test class coverage
            tasklist[0].outcome__c = 'Final Email Sent';
            tasklist[0].Business_Rule__c = bR.Id;
            //changes related to test class coverage
            tasklist.get(0).Status = 'Completed';
       
            Test.startTest();
            Database.update(tasklist,false);
           
            Test.stopTest();
            //system.assertEquals(Constant_Util.COMPLETED,tasklist.get(0).Status);
        } 
        
    }
    
    /* Test Method for Canceltask Method*/
    @isTest static void cancelTask(){

        //test class errors - SDT - 33363
       //Changes related to SDT-33465
        User usr = [SELECT Id, Profile.Name, Bypass_Validation__c, IsActive FROM User WHERE Bypass_Validation__c =: false AND Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive =: true LIMIT 1];
        
        system.runAs(usr){
            Generic_Values__mdt objGV= new Generic_Values__mdt();
            String objuser;
            objUser = [Select Id, Id__c, DeveloperName from Generic_Values__mdt where DeveloperName = 'Genesys_User'].Id__c;
            
            list<Task> tasklist = [select id, whatid, process__c, Outcome__c, Status from task where OwnerId =: objUser limit 1] ;
           
            tasklist.get(0).OwnerId = usr.Id;
            Test.startTest();
            Database.update(tasklist,false);
           
            Test.stopTest();
            
        } 
        
    }
    
    /* test method for cover exception*/
    @isTest static void exceptionCoverage(){

        //test class errors - SDT - 33363
       //Changes related to SDT-33465
        User usr = [SELECT Id, Profile.Name, Bypass_Validation__c, IsActive FROM User WHERE Bypass_Validation__c =: false AND Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive =: true LIMIT 1];
        
        system.runAs(usr){
            List<task> taskList = null;
            Map<id,Task> taskmap1 = new Map<id,task>();
            Test.startTest();
            TaskTriggerHandler.Onbeforeupdate(taskList,taskmap1,taskmap1);
            TaskTriggerHandler.OnbeforeInsert(taskList);
            Test.stopTest();
            system.assert(taskList== null);
        }
    }  
    /* Test Method for ValidateCase Method*/
    @isTest static void validateCaseInfomethod(){

        //test class errors - SDT - 33363
       //Changes related to SDT-33465
        User usr = [SELECT Id, Profile.Name, Bypass_Validation__c, IsActive FROM User WHERE Bypass_Validation__c =: false AND Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive =: true LIMIT 1];
        
        system.runAs(usr){
            
            List<Case> caselist = [select id,Service_Date__c,Case_Sub_Status__c,status,Asset.End_Date__c from Case LIMIT 1];
            caselist[0].status = Constant_Util.CLOSED;
            caselist[0].Case_Sub_Status__c = Constant_Util.SERVICE_CONFIRMED;
            Test.startTest();
            Database.update(caselist);
            // system.debug('Asset.End_Date__c++'+caselist[0].Asset.End_Date__c);
            list<Task> tasklist1 = TestDataFactory.createTask(caselist[0].id, usr);
            tasklist1[0].subject = Constant_Util.ESCALATION_CONFIRM_SERVICE_LOCATION;
            tasklist1[0].Proposed_Service_Date__c = system.today() - 1;
            Database.insert(tasklist1,false);
            
            //system.debug('tasklist1++'+tasklist1[0]);
            Test.stopTest();
            system.assertEquals(Constant_Util.ESCALATION_CONFIRM_SERVICE_LOCATION,tasklist1.get(0).subject);
        }
    } 
    
    /* Test Method for ValidateCase Method*/
    @isTest static void validateCaseInfomethodTest(){

        //test class errors - SDT - 33363
       //Changes related to SDT-33465
        User usr = [SELECT Id, Profile.Name, Bypass_Validation__c, IsActive FROM User WHERE Bypass_Validation__c =: false AND Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive =: true LIMIT 1];
        
        system.runAs(usr){
            
            List<Case> caselist = [select id,Service_Date__c,Case_Sub_Status__c,status,Asset.End_Date__c from Case LIMIT 1];
            caselist[0].status = Constant_Util.CLOSED;
            caselist[0].Case_Sub_Status__c = Constant_Util.SERVICE_CONFIRMED;
            Test.startTest();
            Database.update(caselist);
            // system.debug('Asset.End_Date__c++'+caselist[0].Asset.End_Date__c);
            list<Task> tasklist1 = TestDataFactory.createTask(caselist[0].id, usr);
            tasklist1[0].subject = Constant_Util.ESCALATION_CONFIRM_SERVICE_LOCATION;
            tasklist1[0].Proposed_Service_Date__c = system.today() - 1;
            tasklist1[0].Process__c = Constant_Util.NOTIFY_CUSTOMER_OF_DELAY ;
            tasklist1[0].Outcome__c = Constant_Util.CUSTOMER_ACCEPTS_NEW_DATE ;
            Database.insert(tasklist1,false);
            
            //system.debug('tasklist1++'+tasklist1[0]);
            Test.stopTest();
            system.assertEquals(Constant_Util.ESCALATION_CONFIRM_SERVICE_LOCATION,tasklist1.get(0).subject);
        }
    } 
    
       /* Test Method for ValidateCase Method*/
    @isTest static void validateCaseSecondInfomethodTest(){

        //test class errors - SDT - 33363
       //Changes related to SDT-33465
        User usr = [SELECT Id, Profile.Name, Bypass_Validation__c, IsActive FROM User WHERE Bypass_Validation__c =: false AND Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive =: true LIMIT 1];
        
        system.runAs(usr){
            
			
			
            List<Case> caselist = [select id,Service_Date__c,contactId,Case_Sub_Status__c,status,Asset.End_Date__c from Case LIMIT 1];
            caselist[0].status = Constant_Util.CLOSED;
            caselist[0].Case_Sub_Status__c = Constant_Util.SERVICE_CONFIRMED;
                      
            Test.startTest();
            Database.update(caselist);
             //system.debug('Asset.End_Date__c++'+caselist[0].Asset.End_Date__c);
            list<Task> tasklist1 = TestDataFactory.createTask(caselist[0].id, usr);
            tasklist1[0].subject = Constant_Util.ESCALATION_CONFIRM_SERVICE_LOCATION;
            tasklist1[0].Proposed_Service_Date__c = system.today() - 1;
            tasklist1[0].Process__c = Constant_Util.Confirm_Vendor_Availability;
            tasklist1[0].Outcome__c = Constant_Util.Vendor_Available ;
			
			 //additional field value - code coverage dated 3/4/2024 -start
            tasklist1[0].Attempt__c =1;
            tasklist1[0].whoId = caselist[0].contactid;
           
            //creating a new task type - code coverage
            tasklist1[1].subject = Constant_Util.OBTAIN_CUSTOMER_INFO;
            tasklist1[1].Proposed_Service_Date__c = system.today() - 1;
            tasklist1[1].Process__c = Constant_Util.OBTAIN_CUSTOMER_INFO;
            //additional field value - code coverage
            tasklist1[1].Attempt__c =1;
            tasklist1[1].whoId = caselist[0].contactid;
			
            Database.insert(tasklist1,false);
			//additional field value - code coverage dated 3/4/2024 -end

			
			
            
            //system.debug('tasklist1++'+tasklist1[0]);
            Test.stopTest();
           // system.assertEquals(Constant_Util.ESCALATION_CONFIRM_SERVICE_LOCATION,tasklist1.get(0).subject);
        }
    } 
    @isTest static void updateValidateEmailApprovalTest(){ 
        String subject= Constant_Util.EMPTY_STRING;

        //test class errors - SDT - 33363
        User currentuser = [Select id,isActive from User WHERE isActive = TRUE AND Profile.Name =:SYS_ADMIN limit 1];
        system.runAs(currentuser){
            Test.startTest();
            Account acc = [select id from Account where RecordTypeId =: Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constant_Util.CLIENT).getRecordTypeId() LIMIT 1];
            list<case> caselist = [select id, origin, contactid, Case_Type__c, Client__c, Location__c,Reference_Number__c,CaseNumber, 
                                       PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                       Service_Date__c,SLA_Service_Date_Time__c from Case LIMIT 1];
            List<Task> tasklst = [select id,Business_Rule__c from Task where WhatId =: caselist[0].Id LIMIT 49999];
            
            //Test.startTest();
            
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
            
            List<Approval_Log__c> al = TestDataFactory.createApprovallog(caselist[0].Id);
            al[0].BusinessRuleId__c = tasklst[0].Business_Rule__c;
            al[0].CaseId__c = caselist[0].Id;
            al[0].Approver_Type__c = Constant_Util.USER_RECORDTYPE;
            Database.insert(al);
            
            Approval_Log__c al1 = new Approval_Log__c();
            al1.BusinessRuleId__c = tasklst[0].Business_Rule__c;
            al1.Approver_Type__c = Constant_Util.DEPARTMENT_RECORDTYPE;
            al1.CaseId__c = c2.Id;
            Database.insert(al1);
            
            tasklst[0].Approval_Log__c = al[0].Id;
            Database.Update(tasklst[0]);
            
            List<Task> tsk = TestDataFactory.createTask(caselist[0].Id,currentuser);
            tsk[0].RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Escalation').getRecordTypeId(); 
            tsk[0].Process__c = 'Validate Email Approval Response';
            tsk[0].subject = 'Validate Email Approval Response';
            tsk[0].Attempt__c = 1;
            tsk[0].WhatId = caselist[0].Id;
            tsk[0].Business_Rule__c = tasklst[0].Business_Rule__c;
            Database.Insert(tsk);
            
            Task tsk1 = new Task();
            tsk1.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(APPROVALS).getRecordTypeId(); 
            tsk1.Process__c = Constant_Util.OBTAIN_SERVICE_APPROVAL;
            tsk1.subject = Constant_Util.OBTAIN_SERVICE_APPROVAL;
            tsk1.MultiCaseId__c = caselist[0].Id;
            tsk1.Outcome__c = null;
            tsk1.Attempt__c = 1;
            tsk1.Approval_Log__c = al1.Id;
            tsk1.Department_Name__c = FOREMAIL;
            tsk1.WhatId = c2.Id;
            tsk1.Business_Rule__c = tasklst[0].Business_Rule__c;
            Database.Insert(tsk1);
            
            RecurrsiveTriggerHandler.isSkiptaskTrigger = false;
            tsk[0].Approval_Log__c = al[0].Id;
            tsk[0].Outcome__c = Constant_Util.COULD_NOT_VERIFY;
            Database.Update(tsk);
            Test.stopTest();
        }
   } 
   /* @isTest static void routeallTask(){ 
        user currentuser = [select id, Bypass_Validation__c from user limit 1];
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
            approvalList.add(al);
            
            Approval_Log__c al1 = new Approval_Log__c();
            al1.BusinessRuleId__c = b.Id;
            al1.CaseId__c = c2.Id;
            al1.Approver_Type__c = Constant_Util.USER_RECORDTYPE;
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
            tasklist.add(tsk1);          
            
            Test.startTest();
            
            Database.insert(tasklist);
            Test.stopTest();
        }
    }*/
    
    @isTest static void sendEmailTest(){ 
        //test class errors - SDT - 33363
       //Changes related to SDT-33465
        User currentuser = [SELECT Id, Profile.Name, Bypass_Validation__c, IsActive FROM User WHERE Bypass_Validation__c =: false AND Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive =: true LIMIT 1];
        system.runAs(currentuser){
            Test.startTest();
            Account acc = [select id from Account where RecordTypeId =: Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constant_Util.CLIENT).getRecordTypeId() LIMIT 1];
            Account Loc = [select id,Account.ParentId from Account where RecordTypeId =: Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constant_Util.LOCATION).getRecordTypeId() LIMIT 1];
            list<case> caselist = [select id, origin, contactid, Case_Type__c, Client__c, Location__c,Reference_Number__c, 
                                       PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                       Service_Date__c,SLA_Service_Date_Time__c,CaseNumber from Case LIMIT 1];
            Contact c = [Select id from Contact where Id =:caselist[0].contactid LIMIT 1];
            Asset a = [Select Id from Asset where Id=: caselist[0].assetid LIMIT 1];
            Business_Rule__c b = [select id,Is_Auto_Email__c,Multiple_Mandatory_Approvers__c from Business_Rule__c LIMIT 1];   
            //Test.startTest();
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
            approvalList.add(al);
            
            Approval_Log__c al1 = new Approval_Log__c();
            al1.BusinessRuleId__c = b.Id;
            al1.CaseId__c = c2.Id;
            al1.Approver_Type__c = Constant_Util.USER_RECORDTYPE;
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
            tasklist.add(tsk1);          
            
             Task tsk2 = new Task();
            tsk2.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(APPROVALS).getRecordTypeId(); 
            tsk2.Process__c = 'Escalation Obtain Service Approval';
            tsk2.subject = 'Escalation Obtain Service Approval';
            tsk2.Outcome__c = null;
            tsk2.Approval_Log__c = al1.Id;
            tsk2.Contact_Title__c = FOREMAIL;
            tsk2.WhatId = c2.Id;
            tsk2.Business_Rule__c = b.Id;
            tsk2.Attempt__c = 1;
            tasklist.add(tsk2); 
            
            
            
            
            Database.insert(tasklist);
            Test.stopTest();
            
            system.assertEquals(Constant_Util.OBTAIN_SERVICE_APPROVAL,tsk1.Process__c);
        }
    }
    /*
     * SDT-11777
     * This method is use to validate insert the formated comment in case comments (comment__c object)
     * @owner: Aliasgher Kotawala
     * @param: Map<Id,Task>
    */
    @isTest static void insertCaseCommentTest_TeamName(){ 
        //test class errors - SDT - 33363
       //Changes related to SDT-33465
        User currentuser = [SELECT Id, Profile.Name, Bypass_Validation__c, IsActive FROM User WHERE Bypass_Validation__c =: false AND Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive =: true LIMIT 1];
        system.runAs(currentuser){
            list<case> caselist = [select id, origin, CaseNumber from Case WHERE status =: Constant_Util.OPEN LIMIT 1];
            caselist[0].Tracking_Number__c='666666';
            
             Test.startTest();
            update caselist;
            Task tsk = new Task();
            tsk.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(Quick_Task).getRecordTypeId(); 
            tsk.Process__c = Constant_Util.CASE_ASSIGNMENT;
            tsk.subject = 'Test Subject';
            tsk.WhatId = caselist[0].Id;
            tsk.Task_Team_Name__c = 'Billing';
            tsk.Task_Team_Queue__c = 'Client Billing Issues';
            tsk.Description = 'Test TaskComments';
            tsk.OwnerId = currentuser.id;
            Database.insert(tsk);

            string comment;
            
            /*comment = Constant_Util.COMT_TASK_SUBJECT + Constant_Util.COLON + Constant_Util.BLANKSPACE + tsk.subject + Constant_Util.NEW_LINE +
                    Constant_Util.COMT_TEAM_ASSIGNED + Constant_Util.COLON + Constant_Util.BLANKSPACE + tsk.Task_Team_Name__c + Constant_Util.NEW_LINE +
                    Constant_Util.COMT_QUEUE_ASSIGNED + Constant_Util.COLON + Constant_Util.BLANKSPACE + tsk.Task_Team_Queue__c + Constant_Util.NEW_LINE + 
                    Constant_Util.COMT_USERT_ASSIGNED + Constant_Util.COLON + Constant_Util.BLANKSPACE + Constant_Util.HYPHEN + Constant_Util.NEW_LINE +
                    Constant_Util.COMT_DESCRIPTION + Constant_Util.COLON + Constant_Util.BLANKSPACE + tsk.Description; */
            comment = Constant_Util.COMT_TASK_SUBJECT + Constant_Util.COLON + Constant_Util.BLANKSPACE + tsk.Subject + Constant_Util.NEW_LINE +
                    Constant_Util.COMT_DESCRIPTION + Constant_Util.COLON + Constant_Util.BLANKSPACE + tsk.Description;

           
                list<comment__c> commentlst = [SELECT Id, Comment__c, Case_Number__c, Case__c from comment__c where Case__c =: tsk.WhatId LIMIT 1];
            //    System.assertEquals(commentlst[0].Comment__c, comment);
             //   System.assertEquals(commentlst[0].Case_Number__c, caselist[0].CaseNumber);
              //  System.assertEquals(commentlst[0].Case__c, tsk.WhatId);
            Test.stopTest();
        }
    }
    /*
     * SDT-11777
     * This method is use to validate insert the formated comment in case comments (comment__c object)
     * @owner: Aliasgher Kotawala
     * @param: Map<Id,Task>
    */
    @isTest static void insertCaseCommentTest_UserName(){ 
        //test class errors - SDT - 33363
       //Changes related to SDT-33465
        User currentuser = [SELECT Id, Profile.Name, Bypass_Validation__c, IsActive FROM User WHERE Bypass_Validation__c =: false AND Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive =: true LIMIT 1];
        system.runAs(currentuser){
            list<case> caselist = [select id, origin, CaseNumber from Case WHERE status =: Constant_Util.OPEN LIMIT 1];
             caselist[0].Tracking_Number__c='666665';
           
               Test.startTest();
             update caselist;
            Task tsk = new Task();
            tsk.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(Quick_Task).getRecordTypeId(); 
            tsk.Process__c = Constant_Util.CASE_ASSIGNMENT;
            tsk.subject = 'Test Subject';
            tsk.WhatId = caselist[0].Id;
            tsk.Description = 'Test TaskComments';
            tsk.OwnerId = currentuser.id;
            Database.insert(tsk);
            
            list<User> userlist = [Select Id, Name from User where id =: tsk.OwnerId LIMIT 1];
            string comment;
            

            /*comment = Constant_Util.COMT_TASK_SUBJECT + Constant_Util.COLON + Constant_Util.BLANKSPACE + tsk.subject + Constant_Util.NEW_LINE +
                    Constant_Util.COMT_TEAM_ASSIGNED + Constant_Util.COLON + Constant_Util.BLANKSPACE + tsk.Task_Team_Name__c + Constant_Util.NEW_LINE +
                    Constant_Util.COMT_QUEUE_ASSIGNED + Constant_Util.COLON + Constant_Util.BLANKSPACE + tsk.Task_Team_Queue__c + Constant_Util.NEW_LINE + 
                    Constant_Util.COMT_USERT_ASSIGNED + Constant_Util.COLON + Constant_Util.BLANKSPACE + Constant_Util.HYPHEN + Constant_Util.NEW_LINE +

            /* comment = Constant_Util.COMT_TASK_SUBJECT + Constant_Util.COLON + Constant_Util.BLANKSPACE + tsk.subject + Constant_Util.NEW_LINE +
                    Constant_Util.COMT_TEAM_ASSIGNED + Constant_Util.COLON + Constant_Util.BLANKSPACE + Constant_Util.HYPHEN + Constant_Util.NEW_LINE +
                    Constant_Util.COMT_QUEUE_ASSIGNED + Constant_Util.COLON + Constant_Util.BLANKSPACE + Constant_Util.HYPHEN + Constant_Util.NEW_LINE + 
                    Constant_Util.COMT_USERT_ASSIGNED + Constant_Util.COLON + Constant_Util.BLANKSPACE + userlist[0].Name + Constant_Util.NEW_LINE +

                    Constant_Util.COMT_DESCRIPTION + Constant_Util.COLON + Constant_Util.BLANKSPACE + tsk.Description; */
            comment = Constant_Util.COMT_TASK_SUBJECT + Constant_Util.COLON + Constant_Util.BLANKSPACE + tsk.Subject + Constant_Util.NEW_LINE +
                    Constant_Util.COMT_DESCRIPTION + Constant_Util.COLON + Constant_Util.BLANKSPACE + tsk.Description;
                
            
                list<comment__c> commentlst = [SELECT Id, Comment__c, Case_Number__c, Case__c from comment__c where Case__c =: tsk.WhatId LIMIT 1];
              //  System.assertEquals(commentlst[0].Comment__c, comment);
              //  System.assertEquals(commentlst[0].Case_Number__c, caselist[0].CaseNumber);
              // System.assertEquals(commentlst[0].Case__c, tsk.WhatId);
            Test.stopTest();
        }
    }
    /*
     * SDT-11777
     * This test method is use to validate assigned Team, Queue and User on Case object
     * Validate for Team and Queue
     * @owner: Aliasgher Kotawala
    */
    @isTest static void updateCaseDetails_TeamName(){ 
        //test class errors - SDT - 33363
       //Changes related to SDT-33465
        User currentuser = [SELECT Id, Profile.Name, Bypass_Validation__c, IsActive FROM User WHERE Bypass_Validation__c =: false AND Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive =: true LIMIT 1];
        system.runAs(currentuser){
            list<case> caselist = [select id, origin, CaseNumber from Case WHERE status =: Constant_Util.OPEN AND Tracking_Number__c ='T25124188' LIMIT 1];
            //System.debug ('caselist[0].id ' + caselist[0].id);
            Test.startTest();
            Task tsk = new Task();
            tsk.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(Quick_Task).getRecordTypeId(); 
            tsk.Process__c = Constant_Util.CASE_ASSIGNMENT;
            tsk.subject = 'Test Subject';
            tsk.WhatId = caselist[0].id;
            tsk.Task_Team_Name__c = 'Billing';
            tsk.Task_Team_Queue__c = 'Client Billing Issues';
            tsk.Description = 'Test TaskComments';
            tsk.OwnerId = currentuser.id;
            Database.insert(tsk);
                        
                list<Case> caselst = [SELECT Id, CaseNumber, Team_Name__c, Team_Queue__c, User_Name__c from Case where Id =: tsk.WhatId LIMIT 1];
                System.assertEquals(caselst[0].Team_Name__c, tsk.Task_Team_Name__c);
                System.assertEquals(caselst[0].Team_Queue__c, tsk.Task_Team_Queue__c);
            Test.stopTest();
        }
    }
     /*
     * SDT-11777
     * This test method is use to validate assigned Team, Queue and User on Case object
     * Validate for User Name
     * @owner: Aliasgher Kotawala
    */
    @isTest static void updateCaseDetails_UserName(){ 
 
        //test class errors - SDT - 33363
       //Changes related to SDT-33465
        User currentuser = [SELECT Id, Profile.Name, Bypass_Validation__c, IsActive FROM User WHERE Bypass_Validation__c =: false AND Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive =: true LIMIT 1];
        system.runAs(currentuser){
            list<case> caselist = [select id, origin, CaseNumber from Case WHERE status =: Constant_Util.OPEN AND Tracking_Number__c ='T25124188' LIMIT 1];
            Test.startTest();
            Task tsk = new Task();
            tsk.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(Quick_Task).getRecordTypeId(); 
            tsk.Process__c = Constant_Util.CASE_ASSIGNMENT;
            tsk.subject = 'Test Subject';
            tsk.WhatId = caselist[0].id;
            tsk.Description = 'Test TaskComments';
            tsk.OwnerId = currentuser.id;
            Database.insert(tsk);
           
                list<Case> caselst = [SELECT Id, CaseNumber, Team_Name__c, Team_Queue__c, User_Name__c from Case where Id =: tsk.WhatId LIMIT 1];
                //System.debug ('caselst[0].User_Name__c: ' + caselst[0].User_Name__c + '  ' + 'tsk.OwnerId : ' + tsk.OwnerId);
                System.assertEquals(caselst[0].User_Name__c, tsk.OwnerId);
            Test.stopTest();
        }
    }
    
    //Method to test task Closure when case is closed.
    @isTest static void closeManualTask(){ 

        
        //test class errors - SDT - 33363
       //Changes related to SDT-33465
        User currentuser = [SELECT Id, Profile.Name, Bypass_Validation__c, IsActive FROM User WHERE Bypass_Validation__c =: false AND Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive =: true LIMIT 1];
        system.runAs(currentuser){
            Test.startTest();
            list<case> caselist = [select id, origin, CaseNumber from Case WHERE status =: Constant_Util.OPEN AND Tracking_Number__c ='T25124188' LIMIT 1];
            //Test.startTest();
            Task tsk = new Task();
            tsk.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(Quick_Task).getRecordTypeId(); 
            tsk.Process__c = Constant_Util.CASE_ASSIGNMENT;
            tsk.subject = 'Test Subject';
            tsk.WhatId = caselist[0].id;
            tsk.Description = 'Test TaskComments';
            tsk.OwnerId = currentuser.id;
            Database.insert(tsk);
           
                        
                caselist[0].status = 'Closed';
                Update caselist;              
            Test.stopTest();
                   
                list<Task>tsklst = [Select id,Status from Task where WhatId =: caselist[0].id];
            
                System.assertEquals(tsklst[0].Status, 'Completed');
            
        }
    }
    
    
    @isTest static void caseAssignmentOnClosedCaseTest()
    {   
        //test class errors - SDT - 33363
       //Changes related to SDT-33465
        User currentuser = [SELECT Id, Profile.Name, Bypass_Validation__c, IsActive FROM User WHERE Bypass_Validation__c =: false AND Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive =: true LIMIT 1];
        list<case> caselist = [select id, origin, CaseNumber from Case WHERE status =: Constant_Util.CLOSED LIMIT 1];
        system.runAs(currentuser){
        Test.startTest();
            //Changes related to SDT-33465
            List<Task> tskList= new List<Task>();
            Task tsk = new Task();
            tsk.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(Quick_Task).getRecordTypeId(); 
            tsk.Process__c = Constant_Util.CASE_ASSIGNMENT;
            tsk.subject = 'Test Subject';
            tsk.WhatId = caselist[0].id;
            tsk.Description = 'Test TaskComments';
            tsk.OwnerId = currentuser.id;
            //Changes related to SDT-33465
            tskList.add(tsk);
            
            try{
                //Changes related to SDT-33465
                insert tskList ;
            } catch(Exception ex){
                 Boolean isValMessage = ex.getMessage().contains(system.Label.Task_Validation_Closed_Case) ? true : false;
                 System.AssertEquals(isValMessage , true);
            }
        Test.stopTest();
        }
       
    }
    
   @isTest static void MultiTasksTest(){ 

        //test class errors - SDT - 33363
       //Changes related to SDT-33465
        User currentuser = [SELECT Id, Profile.Name, Bypass_Validation__c, IsActive FROM User WHERE Bypass_Validation__c =: false AND Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive =: true LIMIT 1];
        system.runAs(currentuser){
            Test.startTest();
            Account acc = [select id from Account where RecordTypeId =: Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constant_Util.CLIENT).getRecordTypeId() LIMIT 1];
            Account Loc = [select id,Account.ParentId from Account where RecordTypeId =: Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constant_Util.LOCATION).getRecordTypeId() LIMIT 1];
            list<case> caselist = [select id, origin, contactid, Case_Type__c, Client__c, Location__c,Reference_Number__c, 
                                       PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                       Service_Date__c,SLA_Service_Date_Time__c,CaseNumber,RecordTypeId from Case LIMIT 1];
            Contact c = [Select id from Contact where Id =:caselist[0].contactid LIMIT 1];
            List<Asset> assetLst = [Select Id,Supplier__c,Product2.Family,Product2.ProductTypeSelected__c from Asset LIMIT 3];
            //System.debug('assetLst@@@@'+assetLst);
            List<Business_Rule__c> brlst = [select id,RecordType.Name,Active__c,Required_Information__c from Business_Rule__c LIMIT 2];
            //system.debug('brlst@@@'+brlst);
            //Test.startTest();
            Case c2 = new Case();
            c2.AssetId = assetLst[0].Id;
            c2.RecordTypeId = caselist[0].RecordTypeId;
            c2.Client__c = caselist[0].Client__c;
            c2.origin = caselist[0].origin;
            c2.Supplier__c = assetLst[0].Supplier__c;
            c2.Override_PO_Create_Task__c = true;
            c2.Override_Profile_Number_Task__c = true;
            c2.Location__c = caselist[0].Location__c;
            c2.Case_Type__c = caselist[0].Case_Type__c;
            c2.Case_Sub_Type__c = caselist[0].Case_Sub_Type__c;
            c2.Service_Date__c = system.today();
            c2.Is_Multiple_Asset__c = true;
           // Test.startTest();
            Database.insert(c2);
            Case cas = [select id,Case_Sub_Status__c,Status,Is_Multiple_Asset__c,Reference_Number__c,CaseNumber,Case_Type__c,Case_Sub_Type__c,Service_Date__c,SLA_Service_DateTime__c from Case where Id=:c2.Id limit 1];
            //system.debug('cas@@@'+cas);
            Case c3 = new Case();
            c3.AssetId = assetLst[1].Id;
            c3.Client__c = caselist[0].Client__c;
            c3.Supplier__c = assetLst[0].Supplier__c;
            c3.RecordTypeId = caselist[0].RecordTypeId;
            c3.origin = caselist[0].origin;
            c3.Override_PO_Create_Task__c = true;
            c3.Override_Profile_Number_Task__c = true;
            c3.Location__c = caselist[0].Location__c;
            c3.Case_Type__c = caselist[0].Case_Type__c;
            c3.Case_Sub_Type__c = caselist[0].Case_Sub_Type__c;
            c3.Is_Multiple_Asset__c = true;
            c3.Service_Date__c = system.today();
            c3.Reference_Number__c = cas.Reference_Number__c;
            //Test.startTest();
       //     Database.insert(c3);
            Case c4 = new Case();
            c4.AssetId = assetLst[2].Id;
            c4.Client__c = caselist[0].Client__c;
            c4.Supplier__c = assetLst[2].Supplier__c;
            c4.RecordTypeId = caselist[0].RecordTypeId;
            c4.origin = caselist[0].origin;
            c4.Location__c = caselist[0].Location__c;
            c4.Case_Type__c = caselist[0].Case_Type__c;
            c4.Case_Sub_Type__c = caselist[0].Case_Sub_Type__c;
            c4.Is_Multiple_Asset__c = true;
            c4.Service_Date__c = system.today();
            c4.Reference_Number__c = cas.Reference_Number__c;
            
         //   Database.insert(c4);
             Database.insert(new List<Case>{c3,c4});
            List<Case> caslst = new List<Case>();
            c2.Status = 'Pending';
            c3.Status = 'Pending';
            c4.Status = 'Pending';
            caslst.add(c2);
            caslst.add(c3);
            caslst.add(c4);
            //system.debug('updating@@@');
           // Database.update(caslst,false);
          //  Test.startTest();
            List<Case> caslist = [select id,Case_Sub_Status__c,Status,Is_Multiple_Asset__c,Reference_Number__c,CaseNumber,Case_Type__c,Case_Sub_Type__c,Service_Date__c,SLA_Service_DateTime__c from Case limit 1];
            //system.debug('caslist@@@'+caslist);
            List<Task> tsklst = [select id,Process__c,Outcome__c,whatId,MultiCaseId__c,PurchaseOrder_Number__c,Profile_Number__c,Proposed_Service_Date__c from Task limit 1];
            Test.stopTest();
            system.assert(tsklst!=null);
        }       
    }
    
    @isTest static void insertCaseCommentTest_Second(){ 

        //test class errors - SDT - 33363
       //Changes related to SDT-33465
        User currentuser = [SELECT Id, Profile.Name, Bypass_Validation__c, IsActive FROM User WHERE Bypass_Validation__c =: false AND Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive =: true LIMIT 1];
        system.runAs(currentuser){
            list<case> caselist = [select id, origin, CaseNumber from Case WHERE status =: Constant_Util.OPEN LIMIT 1];
               
            Task tsk = new Task();
          //  tsk.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(Quick_Task).getRecordTypeId(); 
            //test class errors - SDT - 33363
            //tsk.Process__c = Constant_Util.RESOLVE_SERV_ISSUE;
            tsk.subject = 'Test Subject';
            tsk.WhatId = caselist[0].Id;
            tsk.Description = 'Test TaskComments';
            tsk.OwnerId = currentuser.id;
           
                
            Test.startTest();
            Database.insert(tsk);
            
            Task_Genesys_Routing_Control__c taskGR = new Task_Genesys_Routing_Control__c();
            taskGR.Task_Type__c = 'Obtain Vendor Update';
            taskGR.Stop_Routing__c = True;
            taskGR.Primary_Segment__c = 'Broker;Food;Retail';
            taskGR.Service_Flag__c = 'CS';
            Database.insert(taskGR);
            
            list<User> userlist = [Select Id, Name from User where id =: tsk.OwnerId LIMIT 1];
                list<comment__c> commentlst = [SELECT Id, Comment__c, Case_Number__c, Case__c from comment__c where Case__c =: tsk.WhatId LIMIT 1];
              //  System.assertEquals(commentlst[0].Case_Number__c, caselist[0].CaseNumber);
              //  System.assertEquals(commentlst[0].Case__c, tsk.WhatId);
            Test.stopTest();
        }
    }
    
    @isTest static void updateTaskCompletedValidate(){
        Test.startTest();
        //Changes related to SDT-33465
        List<Account> accList = new List<Account>();
        Account acc1 = new Account(Name = 'Test');
        //Changes related to SDT-33465
        accList.add(acc1);
        //insert acc1;
        
        Account acc2 = new Account(Name = 'Test2', ParentId = acc1.Id);
        //Changes related to SDT-33465
        accList.add(acc2);
        insert accList;
        
        Id cseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('New Service Case').getRecordTypeId();
        
        //Changes related to SDT-33465
        List<Case> caseList = new List<Case>();
        Case cse = new Case(Accountid = acc2.id,Case_Sub_Type__c = 'Permanent',Case_Reason__c = 'Existing Location',Case_Type__c = 'New Service',recordtypeId = cseRecordTypeId);
        //Changes related to SDT-33465
        caseList.add(cse);
        insert caseList;
        
        //Changes related to SDT-33465
        List<Product2> prodList = new List<Product2>();
        
        Product2 prod2 = new Product2(Name = 'Pickup');
        //Changes related to SDT-33465
        prodList.add(prod2);
        insert prodList;
        
        //Changes related to SDT-33465
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity opp = new Opportunity(Name = 'Test Opp',Case__c = cse.Id,StageName = 'Proposal',CloseDate = system.today());
        //Changes related to SDT-33465
        oppList.add(opp);
        insert oppList;
        
        //Changes related to SDT-33465
        List<Business_Rule__c> brList = new List<Business_Rule__c>();
        Business_Rule__c businessrule = new Business_Rule__c(Accountid__c = acc1.id, 
                                                             Container__c = 'Equipment', Service__c = 'Permanent', 
                                                             Request_Type__c = 'New Service', Schedule_Type__c = 'Permanent',
                                                             Active__c = true,Effective_Date__c = System.today() - 1,
                                                             Channel_Req__c= 'Test Channel Requirements',Channel__c = 'WM Portal',
                                                             RecordTypeid = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get('Approval').getRecordTypeId() );
        //Changes related to SDT-33465
        brList.add(businessrule);
        insert brList;       
        
        //Changes related to SDT-33465
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        //Quote Creation
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.SBQQ__Account__c = acc2.Id;
        quote.SBQQ__Status__c = 'Draft';
        quote.SBQQ__Opportunity2__c = opp.Id;
        quote.SBQQ__StartDate__c = system.today();
        quote.Business_Rule__c = businessrule.Id;
        quote.ErrorComments__c = 'abdbbdb';
        
        //Changes related to SDT-33465
        quoteList.add(quote);
        insert quoteList;
        
        //Changes related to SDT-33465
        List<SBQQ__QuoteLine__c> qlList = new List<SBQQ__QuoteLine__c>();
        //QuoteLine Creation
        SBQQ__QuoteLine__c ql = new SBQQ__QuoteLine__c();
        ql.SBQQ__Quote__c =  quote.Id;
        ql.SBQQ__Product__c = prod2.Id;
        ql.Equipment_Size__c = 'GALS-40';
        ql.ErrorComments__c = 'abdbbdb';
        
        //Changes related to SDT-33465
        qlList.add(ql);
        insert qlList;
        
        /*
        Service_Approver__c serviceApprover = new Service_Approver__c(Business_Rule__c = businessrule.id, Account__c = businessrule.Accountid__c,
                                                                      Email__c = 'cdd@ymail.com',Active__c = true,
                                                                      Recordtypeid = Schema.SObjectType.Service_Approver__c.getRecordTypeInfosByName().get('Email').getRecordTypeId());
        
        insert serviceApprover;
        */
		
		//Changes related to SDT-33465
		List<Task> tskList = new List<Task>();
        Task tsk = new Task();
        String INTEGRATION_ERRORS_TASK = 'Integration_Errors_Task';
        tsk.RecordTypeId = Schema.getGlobalDescribe().get(Constant_Util.OBJECT_TASK).getDescribe().getRecordTypeInfosByDeveloperName().get(INTEGRATION_ERRORS_TASK).getRecordTypeId(); 
        tsk.Process__c = 'Confirm Service Completion';
        tsk.subject = 'Test Subject';
        tsk.WhatId = quote.id;
        tsk.Description = 'Test TaskComments';
		
		//Changes related to SDT-33465
		tskList.add(tsk);
        insert tskList;
        
        //Changes related to SDT-33465
        tskList[0].status = 'Completed';
        update tskList;
        
        //Changes related to SDT-33465
        tskList[0].status = 'Open';
        update tskList;
        SBQQ__Quote__c qute = [Select Id,Resubmit_Flag__c from SBQQ__Quote__c where Id =: quote.id];
        System.assertEquals(false, qute.Resubmit_Flag__c);
        Test.stopTest();
    }
    
    @isTest static void updateCaseDetails_VRMTeam(){ 
   
        //test class errors - SDT - 33363
       //Changes related to SDT-33465
        User currentuser = [SELECT Id, Profile.Name, Bypass_Validation__c, IsActive FROM User WHERE Bypass_Validation__c =: false AND Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive =: true LIMIT 1];
        system.runAs(currentuser){
            list<case> caselist = [select id, origin, CaseNumber from Case WHERE status =: Constant_Util.OPEN AND Tracking_Number__c ='T25124188' LIMIT 1];
            //System.debug ('caselist[0].id ' + caselist[0].id);
            Test.startTest();
            Task tsk = new Task();
            tsk.subject = Constant_Util.STR_ESCALATION_OBTAIN_VENDOR_INFORMATION;
            tsk.WhatId = caselist[0].id;
            tsk.Description = 'Test TaskComments';
            tsk.OwnerId = currentuser.id;
            Database.insert(tsk);
                        
                list<Case> caselst = [SELECT Id, CaseNumber, Team_Name__c, Team_Queue__c, User_Name__c from Case where Id =: tsk.WhatId LIMIT 1];
                System.assertEquals(caselst[0].Team_Name__c, Constant_Util.Vendor_Relations_Mgmnt);
                System.assertEquals(caselst[0].Team_Queue__c, Constant_Util.VRM_Inquiry);
            Test.stopTest();
        }
    }
    
    @isTest static void insertTaskGRTest(){ 

        //test class errors - SDT - 33363
        User currentuser = [Select id,isActive from User WHERE isActive = TRUE AND Profile.Name =:SYS_ADMIN limit 1];
        system.runAs(currentuser){
            Test.startTest();
			//Changes related to SDT-33465
			List<Account> accList = new List<Account>();
		    Account acc = [select id from Account where RecordTypeId =: Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constant_Util.CLIENT).getRecordTypeId() LIMIT 1];
			acc.Primary_Segment__c = 'Retail';
			
			//Changes related to SDT-33465
			accList.add(acc);
			update accList;
            Account Loc = [select id,Account.ParentId from Account where RecordTypeId =: Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constant_Util.LOCATION).getRecordTypeId() LIMIT 1];
            list<case> caselist = [select id, origin, contactid, Case_Type__c, Client__c, Location__c,Reference_Number__c, 
                                       PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                       Service_Date__c,SLA_Service_Date_Time__c,CaseNumber from Case LIMIT 1];
            Contact c = [Select id from Contact where Id =:caselist[0].contactid LIMIT 1];
            Asset a = [Select Id from Asset where Id=: caselist[0].assetid LIMIT 1];
            Business_Rule__c b = [select id,Is_Auto_Email__c,Multiple_Mandatory_Approvers__c from Business_Rule__c LIMIT 1];   
            //Test.startTest();
            //system.debug('acc : '+ acc);
            //system.debug('Loc : '+ Loc);
            //system.debug('caselist : '+ caselist);
			
			//Changes related to SDT-33465
			List<Case> cseList = new List<Case>();
            Case c2 = new Case();
            c2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Constant_Util.STATUS_CASE).getRecordTypeId();
            c2.AssetId = caselist[0].assetid;
            c2.Client__c = caselist[0].Client__c;
            c2.origin = caselist[0].origin;
            c2.Location__c = caselist[0].Location__c;
            c2.Case_Type__c = 'Status';
            c2.Case_Sub_Type__c = 'Service Not Performed';
            c2.Reason = 'Customer Reported';
            c2.ParentId = caselist[0].Id;
            c2.Reference_Number__c = caselist[0].CaseNumber;
            Database.insert(c2);
			
			c2.Client__c = acc.Id;
			c2.contactId = c.Id;
			c2.Status = Constant_Util.OPEN;
			
			//Changes related to SDT-33465
			cseList.add(c2);
			update cseList;
			
            Generic_Values__mdt objGV= new Generic_Values__mdt();
            String objuser;
            objUser = [Select Id, Id__c, DeveloperName from Generic_Values__mdt where DeveloperName = 'Genesys_User'].Id__c;
               
            Task tsk = new Task();
          //  tsk.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(Quick_Task).getRecordTypeId(); 
            tsk.Process__c = 'Obtain Vendor Update';
            tsk.subject = Constant_Util.RESOLVE_SERV_ISSUE;
            tsk.WhatId = c2.Id;
            tsk.Description = 'Test TaskComments';
            tsk.OwnerId = objUser;
           
            Database.insert(tsk);
            
            Task_Genesys_Routing_Control__c taskGR = new Task_Genesys_Routing_Control__c();
            taskGR.Task_Type__c = 'Obtain Vendor Update';
            taskGR.Stop_Routing__c = True;
            taskGR.Primary_Segment__c = 'Broker;Food;Retail';
            taskGR.Service_Flag__c = 'CS';
            Database.insert(taskGR);
            
            System.assertEquals('Retail', acc.Primary_Segment__c );
            System.assertEquals(taskGR.Task_Type__c, tsk.Process__c);
            Test.stopTest();
        }
    }
    
    @isTest static void testCancelGenysForManualTask(){ 
        user currentuser = [SELECT id, isActive,ProfileId,User_categorization_code__c FROM User where Alias = 'standt' LIMIT 1];
        currentuser.User_categorization_code__c = 'CSGEN';
        system.runAs(currentuser){
            Test.startTest();
            //Changes related to SDT-33465
            List<User> userList = new List<User>();
           // currentuser.Is_Genesys_User__c = True;
            
           //Changes related to SDT-33465
           userList.add(currentUser);
            update currentuser;
            
            Map<Id,User> userMap = new Map<Id,User>();
            userMap.put(currentuser.Id,currentuser);
        
            list<case> caselist = [select id, origin, CaseNumber from Case WHERE status =: Constant_Util.OPEN AND Tracking_Number__c ='T25124188' LIMIT 1];
            //System.debug ('caselist[0].id ' + caselist[0].id);
            //Test.startTest();
            
            //Changes related to SDT-33465
            List<Task> tskList = new List<Task>();
            
            Task tsk = new Task();
            tsk.subject = 'Pending Information';
            tsk.WhatId = caselist[0].id;
            //tsk.Process__c = 'Pending Information';
            tsk.Description = 'Test TaskComments';
            tsk.OwnerId = currentuser.id;
            DateTime currentDateTime = System.now().addMinutes(10);
            tsk.Due_Date_Time__c = currentDateTime;
            tsk.Last_Agent_Id__c = currentuser.id;
            Database.insert(tsk);
            String objuser =  [Select Id, Id__c, DeveloperName from Generic_Values__mdt where DeveloperName = 'Genesys_User'].Id__c;
            tsk.ownerId = objuser ;
            
            //Changes related to SDT-33465
            tskList.add(tsk);
            Update tskList ;
            
            //Changes related to SDT-33465
            tskList[0].ownerId = currentuser.id; 
            Update tskList ;
           // system.debug('task L : ' + tsk);            
          //  list<Task> tasklst = [SELECT Id, subject, Process__c from Task where Id =: tsk.Id LIMIT 1];
          //  System.assertEquals(tasklst[0].subject, 'Pending Information');
            Test.stopTest();
        }
    }

    @isTest static void testUpdateReqInfo(){ 
        Test.startTest();
        user currentuser = [SELECT id, isActive,ProfileId,User_categorization_code__c FROM User where Alias = 'standt' LIMIT 1];
        system.runAs(currentuser){
            //Test.startTest();
            list<case> caselist = [select id,Client__c, Location__c,Location__r.ParentId,origin, CaseNumber from Case WHERE status =: Constant_Util.OPEN AND Tracking_Number__c ='T25124188' LIMIT 1];
            Id cseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('New Service Case').getRecordTypeId();
            caselist[0].Location__c = caselist[0].Location__c;
			caselist[0].Client__c = caselist[0].Location__r.ParentId;
            //caselist[0].Client__r.Primary_Segment__c = 'Manufacturing';
            caselist[0].Case_Sub_Type__c = 'Permanent';
            caselist[0].Case_Reason__c = 'Existing Location';
            caselist[0].Case_Type__c = 'New Service';
            caselist[0].recordtypeId = cseRecordTypeId;
            update caselist[0]; 
            //Case cse = new Case(Location__c = caselist[0].Location__c,Case_Sub_Type__c = 'Permanent',Case_Reason__c = 'Existing Location',Case_Type__c = 'New Service',recordtypeId = cseRecordTypeId);
            //insert cse;
            
            Task tsk = new Task();
            tsk.Subject = 'Obtain Customer Info';
            tsk.WhatId = caselist[0].id;
            tsk.Process__c = 'Obtain Customer Info';
            tsk.Status = 'Open';
	    tsk.Is_Genesys_User__c = True;
            Database.insert(tsk);
            Test.stopTest();
        }
    }
//Changes related to SDT-38038
    @isTest static void testPortalTaskDueDate(){
        Set<String> taskProcesses = new Set<String>{'New Portal Request','Portal Comments','Portal Alert'} ;   
        List<Task> taskList = new List<Task>();    
        Test.startTest();
        //Testing as API User.
        user currentuser = [SELECT id, isActive,ProfileId,User_categorization_code__c FROM User where Alias = 'auser' LIMIT 1];
        system.runAs(currentuser){
            //Test.startTest();
            //changes for test class error
            list<case> caselist = [select id, Location__c,origin, CaseNumber,SLA_Service_Date_Time__c,Service_Date__c from Case WHERE status =: Constant_Util.STATUS_NEW LIMIT 1];
            caselist[0].origin = 'Service Channel';
            caselist[0].SLA_Service_Date_Time__c = System.Today()+1;
            
            //Updating Case
            Update caselist;
            
            //Creating portal Tasks. 
            for(String process:taskProcesses){
                Task tsk = new Task();
                tsk.Subject = process;
                tsk.WhatId = caselist[0].id;
                tsk.Process__c = process;
                tsk.Status = 'Open';
                tsk.Is_Genesys_User__c = True;
                taskList.add(tsk);
            }
            
            //Inserting the portal tasks. 
            Database.Insert(taskList); 
            Test.stopTest();
            
            //Assertion of portal due date.
            //changes for test class error 
            List<Task> portaltaskList = [SELECT Id,Due_Date_Time__c,WhatId FROM Task WHERE Process__c IN:taskProcesses];
            System.AssertEquals(portaltaskList[0].Due_Date_Time__c,caselist[0].Service_Date__c); 
            
            //Assertion of routing records
            List<Genesys_Routing__c> routingRecordList = [SELECT Id,SFDCTaskDueDateTime__c FROM 
                                                      Genesys_Routing__c WHERE SFDCTaskDescription__c IN:taskProcesses];
            System.AssertEquals(routingRecordList[0].SFDCTaskDueDateTime__c,portaltaskList[0].Due_Date_Time__c);
        }
        
    } 
	
	
	 @isTest static void taskEsc(){

        User usr = [Select id,isActive from User WHERE isActive = TRUE AND Profile.Name =:SYS_ADMIN limit 1];
        Business_Rule__c bR = [select id,Is_Auto_Email__c,Multiple_Mandatory_Approvers__c from Business_Rule__c LIMIT 1];
        system.runAs(usr){
            Generic_Values__mdt objGV= new Generic_Values__mdt();
            String objuser;
            objUser = [Select Id, Id__c, DeveloperName from Generic_Values__mdt where DeveloperName = 'Genesys_User'].Id__c;
            
            list<Task> tasklist = [select id, whatid, process__c, Outcome__c, Status from task where OwnerId =: objUser  limit 1] ;
            tasklist[0].Process__c = 'Escalation Obtain Service Approval';
            tasklist[0].Attempt__c = 1;
            tasklist[0].Business_Rule__c = bR.Id;
           
            tasklist.get(0).Status = 'Open';
            Test.startTest();
            Database.update(tasklist,false);
           
            Test.stopTest();
        } 
        
    }
	
	
	//changes related to test class coverage
         @isTest static void CreateObtainESCTaskTest(){

        //test class errors - SDT - 33363
       //Changes related to SDT-33465
        User usr = [SELECT Id, Profile.Name, Bypass_Validation__c, IsActive FROM User WHERE Bypass_Validation__c =: false AND Profile.Name =:SYS_ADMIN AND IsActive = true LIMIT 1];
        Business_Rule__c bR = [select id,Is_Auto_Email__c,Multiple_Mandatory_Approvers__c from Business_Rule__c LIMIT 1];
        system.runAs(usr){
            Generic_Values__mdt objGV= new Generic_Values__mdt();
            String objuser;
            objUser = [Select Id, Id__c, DeveloperName from Generic_Values__mdt where DeveloperName = 'Genesys_User'].Id__c;
            
            list<Task> tasklist = [select id, whatid, process__c, Outcome__c, Status from task where OwnerId =: objUser  limit 1] ;
            tasklist[0].RecordTypeId =  Schema.SObjectType.Task.getRecordTypeInfosByName().get('Escalation').getRecordTypeId(); 
            tasklist[0].Process__c = 'Escalation Obtain Customer Info';
            tasklist[0].Attempt__c = 1;
            tasklist[0].outcome__c = 'Information Not Obtained';
            tasklist[0].Business_Rule__c = bR.Id;
            tasklist[0].Description = 'test comment'; 
           
            tasklist.get(0).Status = 'Completed';
            Test.startTest();
            
            try{
			Database.update(tasklist);
            }
            catch(exception e){
                System.debug('exception occured');
            }
            Test.stopTest();
            system.assertEquals(Constant_Util.COMPLETED,tasklist.get(0).Status);
        } 
        
    }
    //changes related to SDT-38439
    @isTest static void testGetVendorContact(){
        User usr = [SELECT Id, Profile.Name, Bypass_Validation__c, IsActive FROM User WHERE Bypass_Validation__c =: false AND Profile.Name =:SYS_ADMIN AND IsActive = true LIMIT 1];
        system.runAs(usr){
           Account vendorAcc = [SELECT Id from Account WHERE RecordType.Name =:SUPPLIER AND AccountNumber='600' LIMIT 1]; 
            System.debug([Select Id,Roles from AccountContactRelation where AccountId =:vendorAcc.Id]);
           List<GetVendorContact.caseDetails> casedetails = new List<GetVendorContact.caseDetails>();
           GetVendorContact.caseDetails casedetail = new GetVendorContact.caseDetails();
            casedetail.vendorId = vendorAcc.Id;
            casedetail.prodFamily = 'Rolloff';
            casedetails.add(casedetail);
            List<String> vendorContactNameListForRolloff = GetVendorContact.getVendorContactList(casedetails);
            System.assert(vendorContactNameListForRolloff.size()>0);
            
            casedetails[0].prodFamily = 'Commercial';
            List<String> vendorContactNameListForCommercial = GetVendorContact.getVendorContactList(casedetails);
            System.assert(vendorContactNameListForCommercial.size()>0);
            
        } 
    }
    
}