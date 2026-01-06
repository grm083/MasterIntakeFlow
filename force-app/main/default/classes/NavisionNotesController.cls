public without sharing class NavisionNotesController {
    public static final String GENERIC_EXCEPTION = 'Generic Exception';
    public static final String API_EXCEPTION = 'API Exception';
    public static final String NAVISION_NOTES_APEX = 'ViewNavisionNotesController';
    public static final String ERROR = 'Catch Exception';
    
        @AuraEnabled
        public static ticketResponse getNavisionNotes(String issueTrackingNumber,Boolean isFailureTest) {
            Integer httpStatusCode;
            TicketResponse ticketResponse = new TicketResponse();
            try {
                                                            
                    APICallUtility apiObj = new APICallUtility();
                    List<Integration_Request_URLs__mdt> integrationMetdata = apiObj.returnMetaData('Get_Navision_Notes');
                	String UserId =  IntegrationHandlerUtil.getLoggedInUserAcornId();
                
                    String Endpoint = integrationMetdata[0].End_Point__c.replace('{issueTrackingNumber}', String.valueOf(issueTrackingNumber));
                	
                	//For getting coverage in Exception Handling
                    if(isFailureTest && Test.isRunningTest()){
                        integrationMetdata = null;
                    }
                    HttpResponse responseOBJ = apiObj.authenticateAndResponseGET(Endpoint,integrationMetdata[0], UserId);
					
                	httpStatusCode = responseOBJ.getStatusCode();
                
                	String responseBody = responseOBJ.getBody();  
                
                    if (responseBody !=null && responseBody !=''){
                        ticketResponse = (TicketResponse) JSON.deserialize(responseBody, TicketResponse.class);
                    }

                
            } catch(Exception ex) {
                UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), NAVISION_NOTES_APEX + 
                                                        ' Tracking Number: ' + issueTrackingNumber + httpStatusCode,
                                                        LoggingLevel.ERROR);
                
                ticketResponse.data = null;

                problem problemObject = createProblemObject(httpStatusCode, ex);
                
                ticketResponse.problem = problemObject;
            }
            return ticketResponse;
        }
    
        public static problem createProblemObject(Integer httpStatusCode, Exception ex) {
        String statusCode;
        
        if(httpStatusCode == null) {
            statusCode = String.valueOf(0);
        }
        else {
            statusCode = String.valueOf(httpStatusCode);
        }
        
        problem problemObject = new problem();
        problemObject.title = ERROR;
        problemObject.status = httpStatusCode;
        
        errors errorObject = new errors();
        errorObject.code = statusCode;
        errorObject.message = ex.getMessage();
        List<errors> errorsObject = new List<errors>();
        errorsObject.add(errorObject);
        
        problemObject.errors = errorsObject;
        
        return problemObject;
        
    }
    
        public class TicketResponse{
            @auraEnabled public problem problem;
            @auraEnabled public list<TicketData> data;
            
        }
        
        public class TicketData{
            
            @auraEnabled public String acornTicketNumber;
            @auraEnabled public Integer commentStringNumber;
            @auraEnabled public String commentStringDateTime;
            @auraEnabled public String commentStringDesc;
            
        }
        
         // Generic Error Code For display messge
         public class problem {
             @auraEnabled public String title;
             @auraEnabled public Integer status;
             @auraEnabled public List<errors> errors;
         }
         public class errors {
             @auraEnabled public String code;
             @auraEnabled public String message;
         }
}