/*************************************************************
@Name: CaseUpdateHandlerTest
@Author: TCS (Abhishek Patel)
@CreateDate: 06/11/24
@Description: Test class for the CaseUpdateHandler class
**************************************************************/

@IsTest
public class CaseUpdateHandlerTest {
    
    @testSetup
    static void createData(){
        
        test.startTest();
        Profile p= TestDataFactory.getProfile('System Administrator');
        User usr= TestDataFactory.createUser(p);
        usr.Bypass_Validation__c = TRUE;
        usr.FirstName = 'testuser#9999';
        usr.Genesys_Enabled__c = FALSE;
        insert usr; // insert user for the System Administrator
        List<Account> accList;
        List<Account> locationList;
        List<Contact> conList;
        List<Case> caseList;
        
        System.runAs(usr){
            accList= TestDataFactory.createAccount('TestParentAccountTest', usr,'Client');
            accList[0].AccountNumber = 'ParentTest';
            List<Account> accList12 = TestDataFactory.createAccount('TestVendorAccountTest', usr,'Vendor');
            accList12[0].Vendor_Business_Unit__c = '2860';
            accList.addAll(accList12);
            insert accList;
            locationList= TestDataFactory.createLocation('TestLocationAccountTest', usr,accList[0].Id);
            locationList[0].AccountNumber = 'ChildTest';
            locationList[0].type = 'location';
            insert locationList;
            conList= TestDataFactory.createContact('TestContactTest', 'TestContactTest', accList[0], usr);
            conList[0].Email= 'testemail'+ String.valueof(system.now().millisecond())+'@testorg1.com.wm';
            conList[0].Phone= '1890870468';
            insert conList;    
        }
        
        Profile prfl = [SELECT Id FROM Profile WHERE Name = 'Customer Service'];
        User usrObj= TestDataFactory.createUser(prfl); 
        usrObj.FirstName = 'testUser#99997';
        usrObj.Bypass_Validation__c = TRUE;
        usrObj.Genesys_Enabled__c = FALSE;
        insert usrObj;
        
        List<PermissionSetLicense> pslList= [SELECT Id FROM PermissionSetLicense WHERE DeveloperName = 'SalesforceCPQ_CPQStandardPerm' AND Status='Active'];
        insert new PermissionSetLicenseAssign(AssigneeId = usrObj.Id, PermissionSetLicenseId= pslList[0].Id);
        List<PermissionSet> psgList= [SELECT Id FROM PermissionSet WHERE Name = 'QuoteOrdersUser'];
        insert new PermissionSetAssignment(AssigneeId = usrObj.Id, PermissionSetId = psgList[0].id);
        
        System.runAs(usrObj){
            list<Case> caselistnew = new list<Case>(); 
            Case cs = new Case(Status ='Draft', Delivery_Date__c = System.Today(), Priority = 'Medium', Origin = 'Phone', ContactId = conList[0].id, 
                               AccountId =  locationList[0].Id, OwnerId = usr.id, Client__c =  accList[0].Id, Location__c =  locationList[0].id, 
                               Case_Type__c = 'New Service', Case_Sub_Type__c = 'Temporary', Case_Reason__c = 'Clean Up Internal',
                               SlaStartDate = system.today(),Recordtypeid = TestDataFactory.getRecordType('New Service Case','Case'));
            caselistnew.add(cs);
            insert caselistnew;
        }
    }
    @isTest
    public static void testCaseUpdateHandlerExecute() {
       List<Case> testCases = [select id from case where Case_Type__c = 'New Service'];
        Map<String, SObject> caseDataMap = new Map<String, SObject>();
        for (Case c : testCases) {
            caseDataMap.put(c.Id, c);
        }
        Test.startTest();
        Map<String, SObject> resultMap = CaseUpdateHandler.execute(caseDataMap);
        System.assertNotEquals(resultMap, null, 'Result map should not be null.');
        System.assertEquals(resultMap.size(), testCases.size(), 'Result map should have same number of cases.');
        
        for (String caseId : resultMap.keySet()) {
            Case updatedCase = (Case) resultMap.get(caseId);
            System.assertEquals(updatedCase.Status, 'New', 'Case status should be updated to "New".');
        }
        
        Test.stopTest();
    }
    
    @isTest
    public static void testCaseUpdateHandlerExceptionHandling() {
        
        List<Case> testCases = [select Id, Equipment_Type_Code__c, Case_Sub_Type__c, Material_Type__c, Equipment_Size_Code__c, Service_Occurrence_Type_Code__c,
                                SalesMeet_Quantity__c, Delivery_Date__c, Company_Category__c, Quote_Only__c, Site_Contact__c, 
                                Site_Contact_Phone__c, Offsite_Street_Address__c, Offsite_City__c, Offsite_State__c, Offsite_Postal_Code__c from case where Case_Type__c = 'New Service'];
        Map<String, sObject> caseDataMap = new Map<String, sObject>();
        For(case c : testCases){
            c.Case_Sub_Type__c = 'Permanant';
            caseDataMap.put(c.Id, c);
        }
        Map<String, SObject> emptyDataMap = new Map<String, SObject>();
        Test.startTest();
        Map<String, sObject> resultMap = CaseUpdateHandler.execute(caseDataMap);
        System.assertEquals(resultMap, null, 'Checking Null part');
		Test.stopTest();
  }
}