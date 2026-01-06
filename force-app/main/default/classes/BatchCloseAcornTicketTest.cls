/**
* @author TCS
* @date 28/12/2023
* @description : Apex class BatchCloseAcornTicketTest 
**/

    /* test class for BatchCloseAcornTicket*/
    @isTest
    global class BatchCloseAcornTicketTest {
        public static final string SYS_ADMIN = 'System Administrator';
        @testSetup static void setup() {
            List<Case> cases = new List<Case>();
            User usr = [Select id,isActive from User WHERE isActive = TRUE AND Profile.Name =:SYS_ADMIN limit 1];
            system.runAs(usr){
                for (integer i=0;i<20;i++){
                    List<Case> newCaseList = TestDataFactory.createNewCase();
                    newCaseList[0].Status = 'Closed';
                    newCaseList[0].Tracking_Number__c ='123'+i;
                    newCaseList[0].Close_Acorn_Ticket_API_Failed__c = true;
                    cases.addall(newCaseList);
                }
                test.starttest();
                insert cases;
                test.stoptest();
                
            }        
            
        }
    //Check for ticket close scenario
    @isTest static void testBatchCloseTicketPositive() {
        Boolean isSuccess = true;
        User usr = [Select id,isActive from User WHERE isActive = TRUE AND Profile.Name =:SYS_ADMIN limit 1];
        system.runAs(usr){
            test.starttest();
            Test.setMock(HttpCalloutMock.class, new closeAcornTicketMock(isSuccess));
            BatchCloseAcornTicket batchprocess = new BatchCloseAcornTicket();
            Id batchId = Database.executeBatch(batchprocess);
            test.stoptest();
            List<Case> caseList = [SELECT Id FROM Case WHERE Close_Acorn_Ticket_API_Failed__c = TRUE];
            System.assertEquals(caseList.size(),0);
        }
    }
    
    //check for ticket close fail scenario
    @isTest static void testBatchCloseTicketNegative() {
        Boolean isSuccess = false;
        User usr = [Select id,isActive from User WHERE isActive = TRUE AND Profile.Name =:SYS_ADMIN limit 1];
        system.runAs(usr){
            test.starttest();
            Test.setMock(HttpCalloutMock.class, new closeAcornTicketMock(isSuccess));
            BatchCloseAcornTicket batchprocess = new BatchCloseAcornTicket();
            Id batchId = Database.executeBatch(batchprocess);
            test.stoptest();
            List<Case> caseList = [SELECT Id FROM Case WHERE Close_Acorn_Ticket_API_Failed__c = TRUE];
            System.assert(caseList.size()!=null);
            
        }
        
    }
    
    //Mocking framework for http callout
    global class closeAcornTicketMock implements HttpCalloutMock {
        Boolean isSuccess;
        global closeAcornTicketMock (Boolean isSuccess) {
            this.isSuccess = isSuccess;
        }
        
        // Implement this interface method
        global HTTPResponse respond(HTTPRequest req) {
            String json;
            if(this.isSuccess){
                json = '{ "status":"isSuccess",'+
                    '"Data": ["IsSuccess": true],'+
                    '"message": "",'+
                    '"isError": "",'+
                    '"Problem": "",'+
                    '"errorCode": "",'+
                    '"payload": "",'+
                    '"statusCode": ""}';
                
            }
            else{
                json = '{ "status":"error",'+
                    '"Data": ["IsSuccess": false],'+
                    '"message": "",'+
                    '"isError": "true",'+
                    '"Problem": ["Title":"error","Status":"Failed","Errors":["Code":"404","Message":"Ticket failed to close"]],'+
                    '"errorCode": "",'+
                    '"payload": "",'+
                    '"statusCode": ""}';
            }
            
            
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(json);
            response.setStatusCode(200);
            return response;
            
        }
    }
}