@isTest(seeAllData=false)
public class AcornCaseDetailsResourceTest {
    @testSetup static void setup() {
    	list<Case> cases = TestDataFactory.createNewCase();
        
        /*Account supplierAcct = new Account(Name = 'Test Supplier', phone = '9999999999', OwnerId = System.UserInfo.getUserId(),AccountNumber='123',
                                  RecordTypeid = TestDataFactory.getRecordType('Vendor','Account'));
insert supplierAcct;*/
        
        //Changes for SDT-33435 Start
		List<Account> supplierAcct = new List<Account>();
		Account acc = new Account();
		acc.Name = 'Test Supplier';
		acc.phone = '9999999999';
		acc.OwnerId = System.UserInfo.getUserId();
		acc.AccountNumber='123';
		acc.RecordTypeid = TestDataFactory.getRecordType('Vendor','Account');
		supplierAcct.add(acc);
        insert supplierAcct;
        //Changes for SDT-33435 End
        
        cases[0].Case_Information__c = 'This is a test';
        //cases[0].Supplier__c = supplierAcct.Id;
        //Changes for SDT-33435 Start       
		if(supplierAcct != null && supplierAcct.size() > 0)
        cases[0].Supplier__c = supplierAcct[0].Id;
        //Changes for SDT-33435 End
        cases[0].Case_Sub_Type__c = Constant_Util.BALES;
        insert cases[0];
        
    }
    
    @isTest static void testAcornRestResource() {
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        ID caseId = [select Id from Case limit 1].Id;
        
        // Get Method Test
        req.requestURI = '/services/apexrest/Case/V1/' + caseId;
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response= res;
        Case c = AcornCaseDetailsResource.getCase();
        System.assertEquals(caseId, c.Id);
        
        // Post Method Test
        req.requestURI = '/services/apexrest/Case/V1';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        Case c2 = AcornCaseDetailsResource.getCase(caseId);
        System.assertEquals(caseId, c2.Id);
        
        /*
        // Get Method V2 Test
        req.requestURI = '/services/apexrest/V2/Case/' + caseId;
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response= res;
        AcornCaseDetailsResourceV2.getCaseDetails();
        //System.assertEquals(caseId, c3.Id);
        
        // Get Method V2 Invalid Param Test
        req.requestURI = '/services/apexrest/V2/Case/' + caseId + '123';
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response= res;
        AcornCaseDetailsResourceV2.getCaseDetails();
        
        // Missing Case Test
        List<Case> cases = [select Id from Case];
        delete cases;
        req.requestURI = '/services/apexrest/V2/Case/' + caseId;
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response= res;
        AcornCaseDetailsResourceV2.getCaseDetails();
		*/
        
        Test.stopTest();
    }
}