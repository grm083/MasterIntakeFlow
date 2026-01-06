/**
* @author WM
* @date 9/02/2022
**/

/* test class for BatchToCreateGenesysForPITasks*/

@isTest
public class BatchToCreateGenesysForPITasksTest {
    public static final string SYS_ADMIN = 'System Administrator';
    private static final string TESTSUPPLIER = 'testsupplier';
    private static final string SUPPLIER = 'Vendor';
    
    /* set up the test data*/
    @testSetup static void setup() {
        /*Profile p = TestDataFactory.getProfile(SYS_ADMIN);
        User usr = TestDataFactory.createUser(p);
        Database.insert(usr);*/ //Commented for SDT-33458
        Boolean BypassValidation = true; //Modified for SDT-33458 
        Boolean GenesysEnabled = false; //Modified for SDT-33458 
        User usr = TestDataFactory.getCSRUser(BypassValidation, GenesysEnabled); //Modified for SDT-33458
        
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
    
    
    @isTest static void firstTest(){ 
        Test.startTest();
        
        //user currentuser = [SELECT id, isActive,ProfileId,User_categorization_code__c FROM User where Alias = 'standt' LIMIT 1];
        //Querying CSR User.
        User currentuser = [SELECT Id, Profile.Name, LastName, IsActive FROM User WHERE Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive = true LIMIT 1]; //Modified for SDT-33458
        system.runAs(currentuser){
           currentuser.User_categorization_code__c = 'CSGEN' ;
            Database.update(currentuser); // Modified for SDT-33458
            List<Task> taskListtoInsert = new List<Task> ();
            //list<case> caselist = [select id, origin, CaseNumber from Case WHERE status =: Constant_Util.OPEN  LIMIT 1];// Modified for SDT-33458
            Case caseObj = [select id, origin, CaseNumber from Case WHERE status =: Constant_Util.OPEN  LIMIT 1];// Modified for SDT-33458
            //System.debug ('caselist[0].id ' + caselist[0].id);
            Id tskrecordTyeId     = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('Pending_Information').getRecordTypeId();
            //  integer i;
            for(integer i=0;i<=5;i++){
                Task tsk = new Task();
                tsk.recordTypeId = tskrecordTyeId;
                tsk.subject = 'Pending Information';
                tsk.WhatId = caseObj.id; // Modified for SDT-33458
                tsk.Process__c = 'Pending Information';
                tsk.Description = 'Test TaskComments';
                tsk.OwnerId = currentuser.id;
                DateTime currentDateTime = System.now();
                tsk.Due_Date_Time__c = currentDateTime;
                tsk.Last_Agent_Id__c = currentuser.id;
                // Database.insert(tsk);
                taskListtoInsert.add(tsk);
                
            }
            for(integer i=0;i<=5;i++){
                Task tsk = new Task();
                tsk.recordTypeId = tskrecordTyeId;
                tsk.subject = 'Service Follow up';
                tsk.WhatId = caseObj.id; // Modified for SDT-33458
                tsk.Process__c = 'Service Follow up';
                tsk.Description = 'Test Service Follow up';
                tsk.OwnerId = currentuser.id;
                DateTime currentDateTime = System.now();
                tsk.Due_Date_Time__c = currentDateTime;
                tsk.Last_Agent_Id__c = currentuser.id;
                // Database.insert(tsk);
                taskListtoInsert.add(tsk);
                
            }
            Database.insert(taskListtoInsert);
            // list<Task> taskList = [SELECT Id, subject, Is_GR_byPendingInfoTask__c,Due_Date_Time__c,status,ownerID,whatId,Last_Agent_ID__c,Process__c from Task where Id =: tsk.Id LIMIT 1];
            //     ScheduleCreateGenesysForTask.scheduleGRRecordCreation(taskList,userMap);
            
            schedulerBatchToCreateGenesysForPITask testsche = new schedulerBatchToCreateGenesysForPITask();
            String sch = '0 0 23 * * ?';
            system.schedule('Test status Check', sch, testsche );
            Test.stopTest(); 
          
        }
    }
    
    
}