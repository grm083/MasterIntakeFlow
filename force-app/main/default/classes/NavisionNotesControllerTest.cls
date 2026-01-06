@isTest
global class NavisionNotesControllerTest {
    
    @isTest static void getNavisionNotes(){
        //test class errors - SDT - 33363
        User csrUser = [SELECT Id, Profile.Name, Bypass_Validation__c, IsActive FROM User WHERE Bypass_Validation__c =: false 
                        AND Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive =: true LIMIT 1];
        system.runAs(csrUser){
            // Set mock callout class
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new viewNavNotesMock(true));
            NavisionNotesController.ticketResponse response = NavisionNotesController.getNavisionNotes('T12341234',false);        
            Test.stopTest();
            system.assert(response != null);
        }
        
    }
    
    @isTest static void getNavisionNotesCalloutFailure(){
        //test class errors - SDT - 33363
        User csrUser = [SELECT Id, Profile.Name, Bypass_Validation__c, IsActive FROM User WHERE Bypass_Validation__c =: false 
                        AND Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive =: true LIMIT 1];
        
		ExceptionLog_Settings__c logLevel = ExceptionLog_Settings__c.getInstance(UserInfo.getOrganizationId());
        logLevel.Logging_Level__c=UTIL_ErrorConstants.SEVERITY_LEVEL_ERROR;
        insert logLevel;
        system.runAs(csrUser){
            //try{
                // Set mock callout class
                Test.startTest();
                Test.setMock(HttpCalloutMock.class, new viewNavNotesMock(false));
                NavisionNotesController.ticketResponse response = NavisionNotesController.getNavisionNotes('T12341234',true);        
                Test.stopTest();
            
            	ExceptionLog__c exceptionLog = [select Method_Name__c, Class_Name__c, Application_Name__c, Exception_Details__c, Exception_Type__c from ExceptionLog__c limit 1];
				System.assert(exceptionLog.Application_Name__c.contains('T12341234'));
            //}
            //catch(exception e){
            //    System.debug('exception');
            //}
        }
        
    }
    
    //Mocking framework for http callout
    global class viewNavNotesMock implements HttpCalloutMock {
        Boolean  isMockResponseSuccessful; 
        global viewNavNotesMock(Boolean isMockResponseSuccessful) {
            this.isMockResponseSuccessful  = isMockResponseSuccessful;
        }
        // Implement this interface method
        global HTTPResponse respond(HTTPRequest req) {
            HttpResponse response = new HttpResponse();
            if(isMockResponseSuccessful){
                String responseBody =  '{"problem": { "title": "string","status": 0,'+
                    '"errors": [{"code": "string","message": "string"}]},'+
                    '"data": [{'+
                    '"acornTicketNumber": "string",'+
                    '"commentStringNumber": 0,'+
                    '"commentStringDateTime": "string",'+
                    '"commentStringDesc": "test note"}'+']}';
                //response = new HttpResponse();
                response.setHeader('Content-Type', 'application/json');
                response.setBody(responseBody);
                response.setStatusCode(200);
            }
            else
            {
                response.setStatusCode(400);
                response.setHeader('Content-Type', 'application/json');
                response.setStatus('Bad request');              
            }
            
            return response;
        }
    }
}