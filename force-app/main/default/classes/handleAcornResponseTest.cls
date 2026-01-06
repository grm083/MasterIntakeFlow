@isTest
public class handleAcornResponseTest{

    @testSetup static void setup(){
        list<Case> cases = TestDataFactory.createNewCase();
        insert cases;
    }
    
    
    @isTest static void errorResponse(){
		String method = 'GET';
        String endpoint = 'http://api.salesforce.com/endpoint';
        
        List <Case> cases = [SELECT Id FROM Case LIMIT 1];  
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint('http://api.salesforce.com/endpoint');
        req.setMethod('GET');
        
        
        
    	HttpResponse res = new HttpResponse();
        res.SetHeader('Content-type','application-json');
        res.setBody('{"IsSuccess":"false"}');
        res.setStatusCode(404);
        
        Test.startTest();
        IntegrationHandlerUtil.handleAcornResponse(res, req, endpoint, method, cases[0].id);
        Test.stopTest();
    }
}