@isTest(seeAllData=false)
public class LocationContainerControllerTest {
	
    @testSetup static void setup() {
    	list<Case> cases = TestDataFactory.createNewCase();
        insert cases;
    }
    
    @isTest static void testCaseData() {
        Test.startTest();
        String caseId = [select Id from Case limit 1].Id;
        String caseData = LocationContainerController.getIsWorkOrderCreated(caseId);
        
        Test.stopTest();
    }
}