@isTest(seeAllData=false)
public class AcornControllerTest {
    private static final string SYS_ADMIN = 'System Administrator';
    private static final String ACC_NUMBER = '1236';
    private static final string PHONE_NINE = '9999999999';
    private static final string NAISC_31 = '31';
    
    @testSetup static void setup() {
        Profile adminProfile = TestDataFactory.getProfile(SYS_ADMIN);
        User usr = TestDataFactory.createUser(adminProfile);
        usr.LastName = 'AdminUserForTest';
        Database.insert(usr);  
        List<Account> acclist = new List<Account>();
        Id recordTypeid = TestDataFactory.getRecordType('Client','Account');
        Account acclist1 = new Account(Name = Constant_Util.KEYWORD_TEST, phone = PHONE_NINE, OwnerId = usr.id, AccountNumber=ACC_NUMBER,
                                        RecordTypeid = recordTypeid, 
                                        IsPricingEligible__c = true, NAICS_Code__c = NAISC_31);
        acclist.Add(acclist1);
        Database.insert(acclist);

        list<Contact> conlist = TestDataFactory.createContact('Service', 'Channel', acclist1, usr);
        Database.insert(conlist);

        list<Case> cases = TestDataFactory.createNewCase();
        insert cases;
        
        Case c1 = new Case();
        Case c2 = new Case();
        
        c1.Subject = 'Case Without Acorn';
        c1.Status = 'New';
        c1.Origin = 'Service Channel';
        c1.ContactId = conlist.get(0).id;

        c2.Subject = 'Case With Acorn';
        c2.Status = 'New';
        c2.Origin = 'Officetrax';
        c2.Tracking_Number__c = 'T12345678';
        
        insert c1;        
        insert c2;
    }
    
    @isTest static void testAcornNotes1() {
        Test.startTest();
        Case case2 = [select Id,CaseNumber from Case WHERE Tracking_Number__c != Null limit 1];
        Comment__c createComment = TestDataFactory.createCommentRecord(case2.Id,case2.CaseNumber,Constant_Util.WORK_ORDER_ACTION_TYPE);
        Database.insert(createComment);
        List<AcornController.caseComments> extComments1 = AcornController.getCommentData(case2.Id , 5 , false ,'Date');
        System.assertEquals(extComments1.size(), 1);
        
        Test.stopTest();
    }
    
    @isTest static void testAcornNotes2() {
        Test.startTest();
        Case case2 = [select Id,CaseNumber from Case WHERE Tracking_Number__c != Null limit 1];
        // Create Comment Record
        Comment__c createComment = TestDataFactory.createCommentRecord(case2.Id,case2.CaseNumber,Constant_Util.TASK_ACTION_TYPE);
        Database.insert(createComment);
        List<AcornController.caseComments> extComments1 = AcornController.getCommentData(case2.Id , 5, false , 'Date') ;
        Map<Id,String> caseComment = new Map<Id,String>();
        caseComment.put(case2.Id, 'Test Comments');
        AcornController.createAcornCommentforCase(caseComment);
        System.assertEquals(extComments1.size(), 1);
        
        Test.stopTest();
    }
    
    @isTest static void testAcornNotes3() {
        Test.startTest();
        Case case2 = [select Id,CaseNumber from Case WHERE Tracking_Number__c = Null limit 1];
        // Create Comment Record
        Comment__c createComment = TestDataFactory.createCommentRecord(case2.Id,case2.CaseNumber,Constant_Util.EMAIL_ACTION_TYPE);
        Database.insert(createComment);
        List<AcornController.caseComments> extComments1 = AcornController.getCommentData(case2.Id , 5, false , 'Date') ;
        System.assertEquals(extComments1.size(), 1);
        Test.stopTest();
    }
    


    /*
	* @MethodName    : returnTwoWayResponse
	* @Author        : 
	* @Vendor		 : TCS
	* @description	 : This method will test the scenario where the action is initiated with a case record id.
	*/
    @isTest static void returnTwoWayResponse(){
        List<user> currentuser = [select id, Bypass_Validation__c,isActive from user WHERE isActive = TRUE AND LastName = 'AdminUserForTest' LIMIT 1];
        system.runAs(currentuser.get(0)){
            Test.startTest();
            Case testCase = [select Id, Origin From Case WHERE Origin = :'Officetrax' LIMIT 1];
            AcornController.responseTwoWayCommunication returnToTwowayComm = AcornController.returnTwoWayResponse(testCase.Id);        
            Test.stopTest();
            system.assert(returnToTwowayComm != null);            
       }
    } 
}