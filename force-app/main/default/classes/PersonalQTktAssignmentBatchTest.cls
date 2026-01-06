/**
* @author WM
* @date 11/05/2022
* @description : Apex class PersonalQTktAssignmentBatchTest. 
**/
@isTest(seeAllData = false)
public class PersonalQTktAssignmentBatchTest {
    public static final string SYS_ADMIN = 'System Administrator';
    private static final string TESTSUPPLIER = 'testsupplier';
    private static final string SUPPLIER = 'Vendor';
    private static final String PQSUBJECT = 'Personal Queue Ticket Assignment';
    
    /* set up the test data*/
    @testSetup static void setup() {
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        Profile p = TestDataFactory.getProfile(SYS_ADMIN);
        Profile pCat = TestDataFactory.getProfile('Customer Account Team');
        User usr = TestDataFactory.createUser(p);
        Database.insert(usr);
        User usrCat = TestDataFactory.createUser(pCat);
        usrCat.Username = uniqueName + orgId +'cat@wm.com';
        usrCat.Email = uniqueName + orgId +'cat@wm.com';
        usrCat.IsActive = true;
        Database.insert(usrCat);
        user UserToUpdate = new user();
        UserToUpdate.username = uniqueName + orgId +'@wm.com';
        UserToUpdate.email = uniqueName + orgId +'@wm.com';
        UserToUpdate.id = usr.id;
        update UserToUpdate;
        system.runAs(UserToUpdate){
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
            
            Personal_Queue_Info__c perQ = new Personal_Queue_Info__c();
            perQ.CaseId__c = testCase.id;
            perQ.Workflow_TeamUser__c = uniqueName + orgId;
            perQ.Workflow_TeamUserId__c = UserToupdate.Id;
            Database.insert(perQ);
            
            Personal_Queue_Info__c perCatQ = new Personal_Queue_Info__c();
            perCatQ.CaseId__c = testCase.id;
            perCatQ.Workflow_TeamUser__c = uniqueName + orgId+'cat';
            perCatQ.Workflow_TeamUserId__c = usrCat.Id;
            perCatQ.isWorkflowCatUser__c = true;
            Database.insert(perCatQ);
            
            Personal_Queue_Info__c perTeamQ = new Personal_Queue_Info__c();
            perTeamQ.CaseId__c = testCase.id;
            perTeamQ.Workflow_TeamUser__c = 'Sales Dollar Tree Family Dollar Team';
            perTeamQ.Workflow_TeamUserId__c = usrCat.Id;
            Database.insert(perTeamQ);
            perTeamQ.Workflow_TeamUser__c = 'Sales Amazon Team';
            Database.update(perTeamQ);
        }
    }
    
    @isTest static void completeTask(){
        
        User usr = [SELECT Id,username FROM User 
                    WHERE ProfileId =:(TestDataFactory.getProfile('System Administrator')).Id
                    AND IsActive = true AND username like '%@wm.com%'
                    LIMIT 1];
        if(usr!= null){
            System.runAs(usr) {
                Case myCase = [SELECT Id, Status FROM Case LIMIT 1];
                Test.startTest();
                Constant_Util.skipTriggerExecution = true;
                update myCase;
                Constant_Util.skipTriggerExecution = false;
                Database.executeBatch(new PersonalQueueTicketAssignmentTaskBatch(), 200);
                Test.stopTest();
                
                
            }
        }
        
        
    }
    
}