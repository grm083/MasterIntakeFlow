@isTest(seeAllData = false)
public class CreatePendingInformationTask_Test {
    public static final string SYS_ADMIN = 'System Administrator';
    private static final string OTHER ='Other';
    private static final String LOCATION = 'Location';
    private static final string TEST_NAME ='Test';
    private static final String NUM_123 = '123';
    private static final string REQ_INFO ='PSI ;PO NUMBER;Profile Number';
    private static final String CONTACT_NOT_ONSITE = 'Contact Not Onsite';
    private static final string COMPACTOR = 'COMPACTOR';
    private static final string COMMERCIAL = 'Commercial';
    private static final String PICKUP = 'Pickup';
    private static final String SUBJECT = 'Pending Information';
    
    // method for setting up data    
    @testSetup static void setup() {
        Profile p = TestDataFactory.getProfile(SYS_ADMIN);
        User usr = TestDataFactory.createUser(p);
        usr.User_categorization_code__c = 'CSGEN';
        
        
        Database.insert(usr); 
        system.debug('CCC' + usr.User_categorization_code__c);
        
        system.debug(usr.ProfileId);
        system.runAs(usr){
            list<Account> acclist = TestDataFactory.createAccount(Constant_Util.KEYWORD_TEST, usr);
            Database.insert(acclist);
            list<Account> locationlist = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, acclist.get(0).id);
            Database.insert(locationlist);
            list<Contact> conlist = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST,Constant_Util.CONSTANT_LAST, acclist.get(0), usr);
            Database.insert(conlist);
            list<product2> productlist = TestDataFactory.createProduct(Constant_Util.KEYWORD_TEST);
            productlist[0].ProductTypeSelected__c = COMPACTOR;
            productlist[0].Family = COMMERCIAL;
            Database.insert(productlist);
            list<Asset> assetlist = TestDataFactory.createAsset(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                                productlist.get(0), usr, locationlist.get(0));
            Database.insert(assetlist);
            list<Case> caselist = TestDataFactory.createCase(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                             usr, locationlist.get(0), assetlist.get(0));
            caselist[0].Service_Date__c = system.today() + 1;
            caselist[0].Case_Sub_Status__c = Constant_Util.INTEGRATION_ERROR;
            caselist[0].Tracking_Number__c = NUM_123;
            
            Database.insert(caselist);
            
            
            
        }
    }
    
    @isTest static void filedWrapperDataSetTest(){
        user currentuser = [SELECT id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        //  system.debug('DASID' + currentuser.Profile.Id );
        system.runAs(currentuser){
            list<case> caselist = [select id, origin, contactid, Case_Type__c, Client__c, Location__c,
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                   Service_Date__c,SLA_Service_Date_Time__c from case limit 1];
            Test.startTest();
            CreatePendingInformationTask.filedWrapper wrapp  = CreatePendingInformationTask.filedWrapperDataSet(caselist[0].Id);
            List<String> followUpResonValues =  wrapp.followUpReasons ;
            system.assert(!followUpResonValues.isEmpty());
            Test.stopTest();
        }
    }
    @isTest static void createPsiTask_Test(){
        user currentuser = [SELECT id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        system.runAs(currentuser){
            list<case> caselist = [select id, origin, contactid, Case_Type__c, Client__c, Location__c,
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                   Service_Date__c,SLA_Service_Date_Time__c from case limit 1];
            Test.startTest();
            Task tskOb = new Task ();
            tskOb.Subject = 'Pending Information' ;
            tskOb.Due_Date_Time__c = system.now() + 1 ;
            tskOb.Follow_Up_Reasons__c = 'Customer' ;
            tskOb.Description = 'dummyTask' ;
            //  tskOb.Description = 'dummyTask' ;
            string  str  =     CreatePendingInformationTask.createPsiTask(tskOb,caselist[0].Id);
            //  Boolean b =   CreatePendingInformationTask.checkOpenPITask(tskOb,caselist[0].Id);
            List<Task> taskList = [select Id From Task where Subject ='Pending Information'];
            system.assert(str =='Task Created');
            //   system.assert(b == false);
            Test.stopTest();
        }
    }
    @isTest static void createObtainInternalRespoTask_Test(){
        user currentuser = [select id, Bypass_Validation__c,User_categorization_code__c  from user  limit 1];
        List<user> userlist = [select id, Bypass_Validation__c,User_categorization_code__c  from user where IsActive = true AND User_categorization_code__c = 'CSGEN' limit 1]; 
        system.runAs(userlist[0]){
            //  currentuser.User_categorization_code__c = 'CSGEN';
            // currentuser.Is_Genesys_User__c = True;
            // update currentuser ;
            list<case> caselist = [select id, origin, contactid, Case_Type__c, Client__c, Location__c,
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                   Service_Date__c,SLA_Service_Date_Time__c from case limit 1];
            Test.startTest();
            Task tskOb = new Task ();
            tskOb.Subject = 'Obtain Internal Response' ;
            tskOb.Due_Date_Time__c = system.now() + 1 ;
            tskOb.Follow_Up_Reasons__c = 'Customer' ;
            tskOb.Description = 'dummyTask' ;
            tskOb.OwnerId = UserInfo.getUserId() ;
            CreatePendingInformationTask.createObtainInternalRespoTask(tskOb,caselist[0].Id,'Customer Service Team');
            List<Task> taskList = [select Id From Task where Subject ='Obtain Internal Response'];
            system.assert(!taskList.isEmpty());
            Test.stopTest();
            
        }
        
    }
    @isTest static void getCaseObject_Test(){
        user currentuser = [SELECT id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        system.runAs(currentuser){
            list<case> caselist = [select id, origin, contactid, Case_Type__c, Client__c, Location__c,
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                   Service_Date__c,SLA_Service_Date_Time__c from case limit 1];
            Test.startTest();
            CreatePendingInformationTask.caseDetails wrapp = CreatePendingInformationTask.getCaseObject(caselist[0].Id);
            Test.stopTest();
            
        }
    }
    @isTest Static void createPSItaskTest2 (){
        user currentuser = [SELECT id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        system.runAs(currentuser){
            list<case> caselist = [select id, origin, contactid, Case_Type__c, Client__c, Location__c,
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                   Service_Date__c,SLA_Service_Date_Time__c from case limit 1];
            Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Pending_Information').getRecordTypeId();
            List<Task> taskList = new List<Task> ();
            Task tskOb = new Task ();
            tskOb.RecordTypeId = recordTypeId ;
            tskOb.Subject = SUBJECT ;
            tskOb.Due_Date_Time__c = system.now() + 1 ;
            tskOb.Follow_Up_Reasons__c = 'Customer' ;
            tskOb.Description = 'dummyTask' ;
            tskOb.Process__c = SUBJECT ;
            tskOb.Last_Agent_ID__c = UserInfo.getUserId() ;
            tskOb.WhatId = caselist[0].Id;
            tskOb.Attempt__c = 1;
            tskOb.OwnerId = UserInfo.getUserId();
            Task tskOb2 = new Task ();
            tskOb2.RecordTypeId = recordTypeId ;
            tskOb2.Subject = SUBJECT ;
            tskOb2.Due_Date_Time__c = system.now() + 1 ;
            tskOb2.Follow_Up_Reasons__c = 'Vendor' ;
            tskOb2.Description = 'dummyTask' ;
            tskOb2.Process__c = SUBJECT ;
            tskOb2.Last_Agent_ID__c = UserInfo.getUserId() ;
            tskOb2.WhatId = caselist[0].Id;
            tskOb2.Attempt__c = 1;
            tskOb2.OwnerId = UserInfo.getUserId();
            Task tskOb3 = new Task ();
            tskOb3.RecordTypeId = recordTypeId ;
            tskOb3.Subject = SUBJECT ;
            tskOb3.Due_Date_Time__c = system.now() + 1 ;
            tskOb3.Follow_Up_Reasons__c = 'Internal WM' ;
            tskOb3.Description = 'dummyTask' ;
            tskOb3.Process__c = SUBJECT ;
            tskOb3.Last_Agent_ID__c = UserInfo.getUserId() ;
            tskOb3.WhatId = caselist[0].Id;
            tskOb3.Attempt__c = 1;
            tskOb3.OwnerId = UserInfo.getUserId();
            taskList.add(tskOb);
            taskList.add(tskOb2);
            taskList.add(tskOb3);
            insert taskList ;
            Test.startTest();
            Task tskObdummy = new Task ();
            tskObdummy.Subject = 'Pending Information' ;
            tskObdummy.Due_Date_Time__c = system.now() + 1 ;
            tskObdummy.Follow_Up_Reasons__c = 'Customer' ;
            tskObdummy.Description = 'CustomerTest' ;
            //  tskOb.Description = 'dummyTask' ;
            string  str  =     CreatePendingInformationTask.createPsiTask(tskObdummy,caselist[0].Id);
            //  Boolean b =   CreatePendingInformationTask.checkOpenPITask(tskObdummy,caselist[0].Id);
            // system.debug('!!@@' +  str);
            List<Task> listTask = [select Id From Task where Subject ='Pending Information'];
            system.assert(str =='Duplicate Task Found');
            //  system.assert(b == true);
            Test.stopTest();
        }
    }
    @isTest static void createObtainInternalRespoTask_Test2(){
        user currentuser = [select id, Bypass_Validation__c,User_categorization_code__c,Profile.Name  from user where Profile.Name =:SYS_ADMIN AND IsActive =true limit 1];
        system.runAs(currentuser){
            currentuser.User_categorization_code__c = 'CSGEN';
            update currentuser ;
            // currentuser.Is_Genesys_User__c = True;
            // update currentuser ;
            list<case> caselist = [select id, origin, contactid, Case_Type__c, Client__c, Location__c,
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                   Service_Date__c,SLA_Service_Date_Time__c from case limit 1];
            Test.startTest();
            Task tskOb = new Task ();
            tskOb.Subject = 'Obtain Internal Response' ;
            tskOb.Due_Date_Time__c = system.now() + 1 ;
            tskOb.Follow_Up_Reasons__c = 'Customer' ;
            tskOb.Description = 'dummyTask' ;
            // tskOb.OwnerId = UserInfo.getUserId() ;
            CreatePendingInformationTask.createObtainInternalRespoTask(tskOb,caselist[0].Id,'Customer Service Team');
            List<Task> taskList = [select Id From Task where Subject ='Obtain Internal Response'];
            system.assert(!taskList.isEmpty());
            Test.stopTest();
        }
    }
    @isTest static void createObtainInternalRespoTask_Test3(){
        user currentuser = [select id, Bypass_Validation__c,User_categorization_code__c,Profile.Name  from user where Profile.Name =:SYS_ADMIN AND IsActive =true limit 1];
        system.debug('BBB' + currentuser.User_categorization_code__c );
        system.debug('BBB' + currentuser.Profile.Name);
        system.runAs(currentuser){
            currentuser.User_categorization_code__c = null ;
            update currentuser ;
            // currentuser.Is_Genesys_User__c = True;
            // update currentuser ;
            list<case> caselist = [select id, origin, contactid, Case_Type__c, Client__c, Location__c,
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                   Service_Date__c,SLA_Service_Date_Time__c from case limit 1];
            Test.startTest();
            Task tskOb = new Task ();
            tskOb.Subject = 'Obtain Internal Response' ;
            tskOb.Due_Date_Time__c = system.now() + 1 ;
            tskOb.Follow_Up_Reasons__c = 'Customer' ;
            tskOb.Description = 'dummyTask' ;
            tskOb.OwnerId = UserInfo.getUserId() ;
            CreatePendingInformationTask.createObtainInternalRespoTask(tskOb,caselist[0].Id,'Customer Service Team');
            List<Task> taskList = [select Id From Task where Subject ='Obtain Internal Response'];
            system.assert(!taskList.isEmpty());
            Test.stopTest();
        }
    }
    @isTest static void createObtainInternalRespoTask_Test4(){
        user currentuser = [select id, Bypass_Validation__c,User_categorization_code__c,Profile.Name  from user where Profile.Name =:SYS_ADMIN AND IsActive =true limit 1];
        system.debug('BBB' + currentuser.User_categorization_code__c );
        system.debug('BBB' + currentuser.Profile.Name);
        system.runAs(currentuser){
            currentuser.User_categorization_code__c = null ;
            update currentuser ;
            // currentuser.Is_Genesys_User__c = True;
            // update currentuser ;
            list<case> caselist = [select id, origin, contactid, Case_Type__c, Client__c, Location__c,
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                   Service_Date__c,SLA_Service_Date_Time__c from case limit 1];
            Test.startTest();
            Task tskOb = new Task ();
            tskOb.Subject = 'Obtain Internal Response' ;
            tskOb.Due_Date_Time__c = system.now() + 1 ;
            tskOb.Follow_Up_Reasons__c = 'Customer' ;
            tskOb.Description = 'dummyTask' ;
            tskOb.Task_Team_Name__c = 'Service Resolution Team';
            tskOb.Task_Team_Queue__c = 'SST Resolution' ;
            // tskOb.OwnerId = UserInfo.getUserId() ;
            CreatePendingInformationTask.createObtainInternalRespoTask(tskOb,caselist[0].Id,'');
            List<Task> taskList = [select Id From Task where Subject ='Obtain Internal Response'];
            system.assert(!taskList.isEmpty());
            Test.stopTest();
            
        }
    }
    @isTest private static void checkUserIsTaskUserTest(){
        Test.startTest();
        Boolean isTaskUser =  CreatePendingInformationTask.checkUserIsTaskUser('CSGEN');
        Test.stopTest();
    }
    
}
