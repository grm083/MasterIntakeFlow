@isTest(seeAllData=false)
public class RedNoteControllerTest {
    @testSetup static void setup() {
        //Integration_Request_URLs__mdt urlMD = new Integration_Request_URLs__mdt();
        //urlMD.DeveloperName = 'Get_Red_Notes';
        //urlMD.End_Point__c = 'https://www.wastemanagement.com/services/v1/getNotes/{AccountNumber}';
        //insert urlMD;
        Profile adminProfile = TestDataFactory.getProfile('System Administrator');
        User usr = TestDataFactory.createUser(adminProfile);
        insert usr;
        list<Account> accounts = TestDataFactory.createAccount('Test Account', usr);
        Integer acctNum = 1;
        for (Account a: accounts) {
            a.AccountNumber = 'Account-' + acctNum;
            acctNum++;     
        }
        insert accounts;
        
        list<Case> cases = TestDataFactory.createNewCase();
        for (Case c: cases) {
            c.AccountId = accounts[0].Id; 
        }
        insert cases;
    }
    
    @isTest static void testRedNotes() {
        ID acctId = [select Id from Account limit 1].Id;
        RedNoteController.getRedNotesExternal(acctId);
        String redNotes = '';
        RedNoteController.removeHTML(redNotes);
        RedNoteController.RedNotesResponse resp = new RedNoteController.RedNotesResponse();
        RedNoteController.RedNotesData data = new RedNoteController.RedNotesData();
        data.Code = '123';
        data.Name = 'Test';
        data.AuthorizationNotes = 'Test Notes<br/>';
        resp.Data = data;      
        List<WorkOrderWebservices.ErrorsWrapper> errors = new List<WorkOrderWebservices.ErrorsWrapper>();
        WorkOrderWebservices.ErrorMessageWrapper problem = new WorkOrderWebservices.ErrorMessageWrapper('', '', errors);
        resp.Problem = problem;
        
        String result = resp.Data.AuthorizationNotes;
        result = RedNoteController.removeHTML(result);
        System.assertEquals('Test Notes', 'Test Notes');
        ID caseId = [select Id from Case limit 1].Id;
        RedNoteController.getRedNotesExternal(caseId);
    }
    @isTest static void testRedNotes2() {
        Account acc = [select Id,RecordType.Name from Account where RecordType.Name = 'Vendor' OR RecordType.Name = 'Franchise'   limit 1];
        ID acctId = acc.Id;
        RedNoteController.getRedNotesExternal(acctId);
        String redNotes = '';
        RedNoteController.removeHTML(redNotes);
        RedNoteController.RedNotesResponse resp = new RedNoteController.RedNotesResponse();
        RedNoteController.RedNotesData data = new RedNoteController.RedNotesData();
        data.Code = '123';
        data.Name = 'Test';
        data.AuthorizationNotes = 'Test Notes<br/>';
        resp.Data = data;      
        List<WorkOrderWebservices.ErrorsWrapper> errors = new List<WorkOrderWebservices.ErrorsWrapper>();
        WorkOrderWebservices.ErrorMessageWrapper problem = new WorkOrderWebservices.ErrorMessageWrapper('', '', errors);
        resp.Problem = problem;
          
        String result = resp.Data.AuthorizationNotes;     
        result = RedNoteController.removeHTML(result);
        System.assertEquals('Test Notes', 'Test Notes');
        ID caseId = [select Id from Case limit 1].Id;
        RedNoteController.getRedNotesExternal(caseId);
       }   
       
   @isTest 
   static void testRedNotes3() {
        User currentUser = [select id from User LIMIT 1];
        List<Account> accList = TestDataFactory.createAccount('Client Acc', currentUser,Constant_Util.CLIENT);
        insert accList;
        List<Account> locationList = TestDataFactory.createLocation(Constant_Util.LOCATION, currentUser, accList.get(0).id);
        insert locationList;
        
        WorkOrder wo = new WorkOrder(AccountId = locationList[0].id , Customer_Location__c = locationList[0].id);
        insert wo;
       // ID caseId = [select Id from Case limit 1].Id;
        RedNoteController.getRedNotesExternal(wo.id);
       }       
}