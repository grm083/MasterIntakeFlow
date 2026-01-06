/**
* @author Saurav dwivedi
* @date 23/12/2020
* @description : Apex class PersonalQueueTaskClosureBatchTest. 
**/
@isTest(seeAllData = false)
public class PersonalQueueTaskClosureBatchTest {
    //public static final string SYS_ADMIN = 'System Administrator';//Commented for SDT-33463
    private static final string TESTSUPPLIER = 'testsupplier';
    private static final string SUPPLIER = 'Vendor';
    private static final String PQSUBJECT = 'Personal Queue Ticket Assignment';
    /* set up the test data*/
    @testSetup static void setup() {
    /*Profile p = TestDataFactory.getProfile(SYS_ADMIN);
        User usr = TestDataFactory.createUser(p);
        Database.insert(usr);*/ //Commented for SDT-33463
        Boolean BypassValidation = true; //Modified for SDT-33463 
        Boolean GenesysEnabled = false; //Modified for SDT-33463 
        User usr = TestDataFactory.getCSRUser(BypassValidation, GenesysEnabled); //Modified for SDT-33463
        system.runAs(usr){
            list<Account> acclist = TestDataFactory.createAccount(Constant_Util.KEYWORD_TEST, usr);
            Database.insert(acclist);
            
            list<Account> locationlist = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, acclist.get(0).id);
            Database.insert(locationlist);
            
            list<Contact> conlist = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST, Constant_Util.CONSTANT_LAST, acclist.get(0), usr);
            Database.insert(conlist);
            
            list<product2> productlist = TestDataFactory.createProduct(Constant_Util.KEYWORD_TEST);
            productlist[0].ProductTypeSelected__c = 'Compactor';
            Database.insert(productlist);
            
            list<Account> supplieracclist = TestDataFactory.createAccount(TESTSUPPLIER , usr, SUPPLIER);
            supplieracclist[0].AccountNumber = '600';
            Database.insert(supplieracclist);
            
            list<Asset> assetlist = TestDataFactory.createAsset(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                                productlist.get(0), usr, locationlist.get(0));
            assetlist[0].Supplier__c = supplieracclist[0].Id;
            Database.insert(assetlist);
           
            Case testCase = TestDataFactory.returnCase('testCaseRec', accList[0], conlist[0], usr,
                                                      locationlist[0], assetList[0]);
            testCase.Service_Date__c = System.today();
            Database.insert(testCase);
            
            list<Task> tasklist = TestDataFactory.createTask(testCase.id, usr);
            tasklist[0].RecordTypeId = TestDataFactory.getRecordType(Constant_Util.APPROVALS,Constant_Util.OBJECT_TASK);
            tasklist[0].subject = PQSUBJECT;
            tasklist[0].Process__c = Constant_Util.OBTAIN_SERVICE_APPROVAL;
            Database.insert(tasklist);
        }
    }
    
     @isTest static void completeTask(){
        
        /*User usr = [SELECT Id FROM User 
                    WHERE ProfileId =:(TestDataFactory.getProfile('System Administrator')).Id
                    AND IsActive = true
                    LIMIT 1];*/
        //Querying CSR User.
        User usr = [SELECT Id, Profile.Name, LastName, IsActive FROM User WHERE Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive = true LIMIT 1]; //Modified for SDT-33463
        System.runAs(usr) {
            
            List<Case> myCase = [SELECT Id, Status FROM Case LIMIT 1];
            Case caseObj = new Case(); //Modified for SDT-33463
            caseObj.Id = myCase[0].Id; //Modified for SDT-33463
            caseObj.Status = Constant_UTIL.CLOSED; //Modified for SDT-33463
            
            Test.startTest();
               Constant_Util.skipTriggerExecution = true;
                Database.update(caseObj);//Modified for SDT-33463
                Constant_Util.skipTriggerExecution = false;
                String strJobName = 'PersonalQueueTaskClosureBatch-:';
                String strSchedule = '0 30 * * * ?';
                System.schedule(strJobName, strSchedule, new PersonalQueueTaskClosureBatch());
                Database.executeBatch(new PersonalQueueTaskClosureBatch(), 200);
            Test.stopTest();
            task t = [Select Id, Status 
                      from Task 
                      where subject =: PQSUBJECT
                      AND WhatId =: caseObj.Id//Modified for SDT-33463
                      Limit 1];
           	List<Task> tList = [SELECT Id, Status FROM Task];
           
        }
        
    }

}