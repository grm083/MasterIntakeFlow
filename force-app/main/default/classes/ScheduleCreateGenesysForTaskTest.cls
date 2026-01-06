/**
* @author WM
* @date 7/13/2022
* @description : Apex class ScheduleCreateGenesysForTaskTest 
**/

/* test class for ScheduleCreateGenesysForTask*/

@isTest
public class ScheduleCreateGenesysForTaskTest {
    //public static final string SYS_ADMIN = 'System Administrator';//Commented for SDT-33464
    private static final string TESTSUPPLIER = 'testsupplier';
    private static final string SUPPLIER = 'Vendor';
    
    /* set up the test data*/
    @testSetup static void setup() {
        /*Profile p = TestDataFactory.getProfile(SYS_ADMIN);
        User usr = TestDataFactory.createUser(p);
        Database.insert(usr);*/ //Commented for SDT-33464 
        
        Boolean BypassValidation = true; //Modified for SDT-33464 
        Boolean GenesysEnabled = false; //Modified for SDT-33464 
        User usr = TestDataFactory.getCSRUser(BypassValidation, GenesysEnabled); //Modified for SDT-33464

        
        system.runAs(usr){
            list<Account> acclist = TestDataFactory.createAccount(Constant_Util.KEYWORD_TEST, usr);
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
            AccountContactRelation AccContactRel = TestDataFactory.returnAccConRel(supplieracclist[0].Id,conlist[0],'Commercial Service/Dispatch;Rolloff Service/Dispatch;Dispatch');
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
            
        } 
        
    }
    
    
    @isTest static void testScheduleGenesysTask(){ 
        Test.startTest();
        
        //user currentuser = [SELECT id, isActive,ProfileId,Is_Genesys_User__c FROM User where Alias = 'standt' LIMIT 1];
        //Querying CSR User.
        User currentuser = [SELECT Id, isActive, ProfileId, Is_Genesys_User__c FROM User WHERE Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive = true LIMIT 1]; //Modified for SDT-33464
        system.runAs(currentuser){
            
            currentuser.Is_Genesys_User__c = True;
            Database.update(currentuser);// Modified for SDT-33464
            
            Map<Id,User> userMap = new Map<Id,User>();
            userMap.put(currentuser.Id,currentuser);
            
            
            list<case> caselist = [select id, origin, CaseNumber from Case WHERE status =: Constant_Util.OPEN  LIMIT 1];
            //System.debug ('caselist[0].id ' + caselist[0].id);
            
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
            //system.debug('tsk : '  + tsk);
            list<Task> taskList = [SELECT Id, subject, Is_GR_byPendingInfoTask__c,Due_Date_Time__c,status,ownerID,whatId,Last_Agent_ID__c,Process__c from Task where Id =: tsk.Id LIMIT 1];
            ScheduleCreateGenesysForTask.scheduleGRRecordCreation(taskList,userMap);
            //schedule next execution after a minute
            /*   String nextScheduleTime=String.valueof(currentDateTime.second()) +' '+String.valueof(currentDateTime.minute())+' '
+String.valueof(currentDateTime.hour())+' '+String.valueof(currentDateTime.day())+' '
+String.valueof(currentDateTime.month())+' ? '+String.valueof(currentDateTime.Year());
ScheduleCreateGenesysForTask schJob = new ScheduleCreateGenesysForTask(taskList,userMap);
String jobName = 'Every 1 min' + '-' + taskList[0].Last_Agent_ID__c + '-' + taskList[0].Id; 
system.schedule( jobName, nextScheduleTime, schJob);
*/ //  System.assertEquals(tasklst[0].subject, 'Pending Information Case');
            Test.stopTest();
        }
    }
    
}