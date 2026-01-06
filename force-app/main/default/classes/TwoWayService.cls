
/*************************************************************
@Name: TwoWayService
@Author: TCS
@Description: This class will be called for business logic of Two way communication. 
**************************************************************/
public without sharing class TwoWayService {
    
        
    
    /*
     * @Method Name    : saveComments
     * @Author         : TCS
     * @description    : 
     * @param          : Comment data(String), Origin field value of the Case record and CaseNumber field value of Case record
     * @return         : 
     */
    public static String saveComments (string CommentData , String Origin, string caseNumber){        
        System.debug('CommentData>>>'+CommentData);
                                
        APICallUtility apiObj = new APICallUtility();
        List<Integration_Request_URLs__mdt> integrationMetdata = apiObj.returnMetaData('Two_way_Save_Comment');
        String UserId =  IntegrationHandlerUtil.getLoggedInUserAcornId();
        
        String Endpoint = integrationMetdata[0].End_Point__c.replace('{CaseNumber}', String.valueOf(caseNumber));
        System.debug('Endpoint>>>'+Endpoint);
        HttpResponse responseOBJ = apiObj.authenticateAndResponsePOST(CommentData,Endpoint,integrationMetdata[0] , UserId);
        System.debug('*** Result' + responseOBJ.getBody());
        
        return responseOBJ.getBody();    
    }
    
    
    
    /*
     * @Method Name    : returnResponseBodyObj
     * @Author         : TCS
     * @description    : This method is called from CommentController.createComment() method. 
     * The request body for add comment functionality is created here. 
     * API call is done and response is parsed into an apex object and returned.
     * @param          : Comment body from the component, Case origin, Case Number, CreatedById of Case.
     * @return         : responseBodyObjForAddComment object.
     */
     public static responseBodyObjForAddComment returnResponseBodyObj(List<String> recipientList,String commentBody, String origin, string caseNumber, String createdBy) {
        Integer httpStatusCode;
        //addition for adding email to add comments
		List<recipients> recipientsList = new List<recipients>();
        List<ExceptionLog__c> exceptionLogList = new List<ExceptionLog__c>();  
		responseBodyObjForAddComment returnObj = new responseBodyObjForAddComment();
        
         try { 
             String userName = UserInfo.getName();
             //recipients recipientOBJ = new recipients(userName);
             //List<recipients> recipientsList  = new List<recipients>();
             //recipientsList.add(recipientOBJ);
             //origin = '';
             //addition for adding email to add comments
			for(Integer i = 0; i < recipientList.size(); i++) {
                recipients currentRecipient = new recipients();
                if(origin == SERVICE_CHANNEL)
                {
                    currentRecipient.user = recipientList[i];
                }
                else if(origin == OFFICETRAX) {
                    currentRecipient.user = recipientList[i];
                    currentRecipient.referenceNumber = recipientList[i];
                }
                recipientsList.add(currentRecipient);
                
            }
             
             requestBodyObjForAddComment requestBodyObj = new requestBodyObjForAddComment(CaseNumber, origin, commentBody, FALSE, createdBy, recipientsList, METHOD_NAME_RETURN_RESPONSE_BODYOBJ);
             
             String jsonStringRequestBody = returnJSONString(requestBodyObj);
             System.debug('requestBodyObj>>>'+jsonStringRequestBody);
             
             
             
             //Integer k = 1/0;
             
             String responseBody = saveComments(jsonStringRequestBody, origin, caseNumber);
             returnObj = parseResponseBodyForAddComment(responseBody);
             System.debug('returnObj>>>'+returnObj);
             
             if(returnObj.problem != null) {
                 for(Integer i =0; i<returnObj.problem.errors.size(); i++) {
                     ExceptionLog__c exLog = logExceptions(returnObj.problem.errors[i].message, METHOD_NAME_RETURN_RESPONSE_BODYOBJ, API_EXCEPTION);
                     System.debug(exLog);
                     exceptionLogList.add(exLog);
                 }
                 System.debug(exceptionLogList.size());
             }
         }
         
         catch(Exception ex) {
             returnObj.data = null;
             //Calling createProblemObject() method. It returns problem object.
             problem problemObject = createProblemObject(httpStatusCode, ex);
             returnObj.problem = problemObject;
             system.debug(returnObj);
             
             //calling the logExceptions() method.
             ExceptionLog__c exLog = logExceptions(ex.getMessage(), METHOD_NAME_RETURN_RESPONSE_BODYOBJ, GENERIC_EXCEPTION);
             system.debug(exLog);
             exceptionLogList.add(exLog);
             
         }
         //inserting exception logs.
        insertExceptionLogList(exceptionLogList);
         
        return returnObj;
    }
    
    
    /*
     * @Method Name    : returnResponseBodyObjForSentAlert
     * @Author         : TCS
     * @description    : This method is called from sentAlert class. 
     * The request body for sent alert functionality is created here. 
     * API call is done and response is parsed into an apex object and returned.
     * @param          : Comment body from the component, Case origin, Case Number, CreatedById of Case and recipient list.
     * @return         : responseBodyObjForAddComment object.
     */
    Public static responseBodyObjForAddComment returnResponseBodyObjForSentAlert(List<String> recipientsList, List<String> recipientsNameList, String caseNumber, String origin, String message, String createdBy){
        List<recipients> recipientList = new List<recipients>();
        Integer httpStatusCode;
        List<ExceptionLog__c> exceptionLogList = new List<ExceptionLog__c>();  
		responseBodyObjForAddComment returnObj = new responseBodyObjForAddComment();
        
        try {
            for(Integer i=0;i<recipientsList.size();i++) {
                recipients currentRecipient = new recipients();
                if(origin == SERVICE_CHANNEL)
                {
                    currentRecipient.user = recipientsList[i];
                }
                else if(origin == OFFICETRAX) {
                    currentRecipient.user = recipientsNameList[i];
                    currentRecipient.referenceNumber = recipientsList[i];
                }
                recipientList.add(currentRecipient);                
            }
            requestBodyObjForAddComment requestBodyObj = new requestBodyObjForAddComment(CaseNumber, origin, message, TRUE, createdBy, recipientList, METHOD_NAME_RETURN_RESPONSE_BODYOBJ_FOR_SENTALERT);
            system.debug(requestBodyObj);
            String jsonStringRequestBody = returnJSONString(requestBodyObj);
            system.debug(jsonStringRequestBody);
            
            
            //Integer k = 1/0;
            
            String responseBody = saveComments(jsonStringRequestBody, origin, caseNumber);
            returnObj = parseResponseBodyForAddComment(responseBody);
            System.debug(returnObj);
            
            if(returnObj.problem != null) {
                for(Integer i =0; i<returnObj.problem.errors.size(); i++) {
                    ExceptionLog__c exLog = logExceptions(returnObj.problem.errors[i].message, METHOD_NAME_RETURN_RESPONSE_BODYOBJ_FOR_SENTALERT, API_EXCEPTION);
                    System.debug(exLog);
                    exceptionLogList.add(exLog);
                }
                System.debug(exceptionLogList.size());
            }
            
        }
        
        catch(Exception ex) {
            returnObj.data = null;
            //Calling createProblemObject() method. It returns problem object.
            problem problemObject = createProblemObject(httpStatusCode, ex);
            returnObj.problem = problemObject;
            system.debug(returnObj);
            
            //calling the logExceptions() method.
            ExceptionLog__c exLog = logExceptions(ex.getMessage(), METHOD_NAME_RETURN_RESPONSE_BODYOBJ_FOR_SENTALERT, GENERIC_EXCEPTION);
            system.debug(exLog);
            exceptionLogList.add(exLog);
            
        }
        //insering exception logs.
        insertExceptionLogList(exceptionLogList);
        
        return returnObj;
        
    }
    
    
    /*
     * @Method Name    : displayComments
     * @Author         : TCS
     * @description    : 
     * @param          : Origin field value of the Case record and CaseNumber field value of Case record
     * @return         : DisplayCommentsWrapper object with values from the JSON received from the API utility class
     */
    //changed arguments of displayComments method
    public static DisplayCommentsWrapper displayComments (string caseNumber,Integer pageIndex,Integer pageSize){
        Integer httpStatusCode;
        List<ExceptionLog__c> exceptionLogList = new List<ExceptionLog__c>();  
        DisplayCommentsWrapper disComments = new DisplayCommentsWrapper();
        
        try {
            String UserId =  IntegrationHandlerUtil.getLoggedInUserAcornId();
            
            APICallUtility apiObj = new APICallUtility();
            List<Integration_Request_URLs__mdt> integrationMetdata = apiObj.returnMetaData('Two_way_View_Comment');
            
            String Endpoint = integrationMetdata[0].End_Point__c.replace('{CaseNumber}', String.valueOf(caseNumber));
            Endpoint = Endpoint + '?PageIndex='+pageIndex+'&PageSize='+pageSize;
            System.debug('Endpoint>>>'+Endpoint);
            
            
            //Integer k = 1/0;
            
            HttpResponse responseOBJ = apiObj.authenticateAndResponseGET(Endpoint,integrationMetdata[0] , UserId);
            System.debug('*** Result' + responseOBJ.getBody());
            
            String JString;
            JString = responseOBJ.getBody();
            System.debug(JString);
            
            disComments = parsedisplayComment(JString);
            system.debug(disComments);
            //SDT-36481
            disComments.location = extractLocation(disComments.data);
            
            if(disComments.problem != null) {
                for(Integer i =0; i<disComments.problem.errors.size(); i++) {
                    ExceptionLog__c exLog = logExceptions(disComments.problem.errors[i].message, METHOD_NAME_DISPLAY_COMMENTS, API_EXCEPTION);
                    System.debug(exLog);
                    exceptionLogList.add(exLog);
                }
                System.debug(exceptionLogList.size());
            }
            
        }
        
        catch(Exception ex) {
            System.debug('inside catch');
            disComments.data = null;
            //Calling createProblemObject() method. It returns problem object.
            problem problemObject = createProblemObject(httpStatusCode, ex);
            disComments.problem = problemObject;
            system.debug(disComments);
            
            //calling the logExceptions() method.
            ExceptionLog__c exLog = logExceptions(ex.getMessage(), METHOD_NAME_DISPLAY_COMMENTS, GENERIC_EXCEPTION);
            system.debug(exLog);
            exceptionLogList.add(exLog);
            
        }
        
        //inserting exceptionLogList;
        insertExceptionLogList(exceptionLogList);
        
        system.debug(disComments);
        return disComments;
    }
    
    /*
     * @Method Name    : getRecipients
     * @Author         : TCS
     * @description    : 
     * @param          : Origin field value of the Case record and CaseNumber field value of Case record
     * Modification    : Changes for Officetrax SDT-36424
     * @return         : 
     */
    public static responseBodyObjForGetRecipients getRecipients (String Origin, string caseNumber){
        Integer httpStatusCode;
        List<ExceptionLog__c> exceptionLogList = new List<ExceptionLog__c>();   
        responseBodyObjForGetRecipients responseObject = new responseBodyObjForGetRecipients();
        
        try {
            String UserId =  IntegrationHandlerUtil.getLoggedInUserAcornId();
            
            APICallUtility apiObj = new APICallUtility();
            //SDT-36424: Changes for officetrax 
            List<Integration_Request_URLs__mdt> integrationMetdata =  new List<Integration_Request_URLs__mdt>();

            if(Origin == SERVICE_CHANNEL)
            {
                integrationMetdata = apiObj.returnMetaData('Two_way_Get_Recipients');
            }
            else if(Origin == OFFICETRAX){
                integrationMetdata = apiObj.returnMetaData('Two_way_Officetrax_Get_Recipients');
            }
            String Endpoint = integrationMetdata[0].End_Point__c.replace('{CaseNumber}', String.valueOf(caseNumber));
            System.debug('Endpoint>>>'+Endpoint);
            
            
            //Integer k = 1/0;
            
            HttpResponse responseOBJ = apiObj.authenticateAndResponseGET(Endpoint,integrationMetdata[0] , UserId);
            httpStatusCode = responseOBJ.getStatusCode();
            System.debug('*** Result' + responseOBJ.getBody());
            
            String  JString = responseOBJ.getBody();
            responseObject = parseResponseBodyForGetRecipients(JString);
            
            system.debug(responseObject);   
            
            if(responseObject.problem != null) {
                for(Integer i =0; i<responseObject.problem.errors.size(); i++) {
                    ExceptionLog__c exLog = logExceptions(responseObject.problem.errors[i].message, METHOD_NAME_GET_RECIPIENTS, API_EXCEPTION);
                    System.debug(exLog);
                    exceptionLogList.add(exLog);
                }
                System.debug(exceptionLogList.size());
            }
        }
        
        catch(Exception ex) {
            responseObject.data = null;
            //Calling createProblemObject() method. It returns problem object.
            problem problemObject = createProblemObject(httpStatusCode, ex);
            responseObject.problem = problemObject;
            system.debug(responseObject);
            
            //calling the logExceptions() method.
            ExceptionLog__c exLog = logExceptions(ex.getMessage(), METHOD_NAME_GET_RECIPIENTS, GENERIC_EXCEPTION);
            system.debug(exLog);
            exceptionLogList.add(exLog);
            
        }
        insertExceptionLogList(exceptionLogList);
        
        return responseObject;
        
    }
    
    /*
     * @Method Name    : caseDetails
     * @Author         : TCS
     * @description    : 
     * @param          : Case Id
     * @return         : CaseObj
     */
    public static Case returnCaseDetails(String caseId) {
        //making changes for passing reference number instead of case number
        Case caseObj = [SELECT CaseNumber,Reference_Number__c,Origin,createdbyId,createdby.name FROM Case WHERE Id=:caseId limit 1]; 
        return caseObj;

      }
    
    public class DisplayCommentsWrapper{
        @AuraEnabled public problem problem;
        @AuraEnabled public List<CommentsData> data;
        @AuraEnabled public Integer pageIndex;   //0
        @AuraEnabled public Integer pageSize;    //0
        @AuraEnabled public Integer count;   //0  
	@AuraEnabled public string location ;   //SDT-36481
    
    }
           
    public class CommentsData {
        @auraEnabled public String caseNumber;   //string
        @auraEnabled public String referenceNumber;  //string
        @auraEnabled public String caseOrigin;   //string
        @auraEnabled public String systemOrigin; //string
        @auraEnabled public String message;  //string
        @auraEnabled public boolean isActionRequired;
        @auraEnabled public String receivedDate; //2023-05-05T14:36:13.715Z
        @auraEnabled public String sentDate; //2023-05-05T14:36:13.715Z
        @auraEnabled public String partnerReference; //string
        @auraEnabled public String wmReference;  //string
        @auraEnabled public String createdBy;  //string    
        @auraEnabled public List<recipients> recipients;           
    }
   //helper class //SDT-36481
    public static string extractLocation(List<CommentsData> data){

         String extractedDetails = '';
 
    for (CommentsData commentData : data) {
        String message = commentData.message;
    
       if (String.isNotBlank(message) && message.contains('Location')) {
            // Replace literal "\\n" with actual line break
            message = message.replace('\\n', '\n');
            message = message.replace('\n', '<br/>');
 
            // Extract the part after "Location:"
            Integer locationIndex = message.indexOf('Location:');
            if (locationIndex != -1) {
                String locationBlock = message.substring(locationIndex).trim(); // Include "Location:"
 
                List<String> locationLines = locationBlock.split('\n');
 
               for (String line : locationLines) {   
                    if (line.contains('Created By')) {
                        line = line.replace('Created By', '<b>Created By</b>');
                    }
                if (line.contains('Location:')) {
                        line = line.replace('Location:', '<b>Location:</b>');
                     }
                    extractedDetails += line;
                }
                break;
            }
        }
    }
 
    return extractedDetails;
    } 
	
	

    
    public static DisplayCommentsWrapper parsedisplayComment(String json){
        return (DisplayCommentsWrapper) System.JSON.deserialize(json, DisplayCommentsWrapper.class);
    }
     
    
    /*
     Method to parse and return a JSON String for the request body object for Add Comments.
    */
    public static String returnJSONString(requestBodyObjForAddComment requestBodyObj) {
        System.debug(JSON.serialize(requestBodyObj));
        return JSON.serialize(requestBodyObj);
    }
    
    //This class is the structure of the request body for Add Comment callout.       
    public class requestBodyObjForAddComment{
        @auraEnabled public String referenceNumber;  
        @auraEnabled public String caseOrigin;  
        @auraEnabled public String message;  
        @auraEnabled public boolean isActionRequired;
        @auraEnabled public String createdBy;  
        @auraEnabled public List<recipients> recipients;
        
        /*
        *Constructor to form the request body object for Add Comments.
        */
        public requestBodyObjForAddComment(String referenceNumber, String caseOrigin, String message, 
                                           Boolean isActionRequired, String createdBy, List<recipients> recipientList, String methodName) {
                                               
            this.referenceNumber = referenceNumber;                                            
            this.caseOrigin = caseOrigin;
            this.message = message;                                          
            this.isActionRequired = isActionRequired;
            this.createdBy = createdBy; 
            //Changes related to SDT - 31863
            if(methodName == METHOD_NAME_RETURN_RESPONSE_BODYOBJ_FOR_SENTALERT || methodName == METHOD_NAME_RETURN_RESPONSE_BODYOBJ) {
                if(recipientList.size() > 0 && recipientList != null)
                {
					this.recipients =  recipientList;
                }
            }                                                              
        }
    }
    
    public class recipients {
       @auraEnabled public String user;  
       @auraEnabled public String referenceNumber;  
       
    //    public recipients(String user, String referenceNumber) {
    //        this.user = user;
    //        this.referenceNumber = referenceNumber;
    //    }
    }
    
  
    /*
     Method to parse the JSON string response coming from the API callout of Add Comment.
     */
    public static responseBodyObjForAddComment parseResponseBodyForAddComment(String jsonString) {
        return (responseBodyObjForAddComment) System.JSON.deserialize(jsonString, responseBodyObjForAddComment.class);
    }
    
    
    //This class is the structure of the the response coming from API for Save Comment(AddComment and SendAlert).
    public class responseBodyObjForAddComment{
        @auraEnabled public problem problem;
        @auraEnabled public data data;
    }
    
    //This class is the structure of the JSON response coming from API for getting the recipients in Send Alert functionality.
    public class responseBodyObjForGetRecipients {
        @auraEnabled public problem problem;
        @auraEnabled public List<data> data;
    } 
    
    public class data {
        @auraEnabled public Integer conversationId;
        @auraEnabled public Integer id;
        @auraEnabled public String userName;
        @auraEnabled public String referenceNumber;
        @auraEnabled public String email;
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
    
    
    /*
     Method to parse the JSON string response coming from the API callout of Add Comment.
     */
    public static responseBodyObjForGetRecipients parseResponseBodyForGetRecipients(String jsonString){
        return (responseBodyObjForGetRecipients) System.JSON.deserialize(jsonString, responseBodyObjForGetRecipients.class);
    }

    /*
     * @Method Name    : logExceptions
     * @Author         : TCS
     * @description    : This method contains the logic to log the exceptions handled 
     * from the above methods for Two Way Communication.
     * @param          : Error message and method name.
     * @return         : Exception log record.
     */
    public static ExceptionLog__c logExceptions(String errorMessage, String methodName, String exceptionType) {
        
        String orgId = UserInfo.getOrganizationId();
        ExceptionLog__c exLogRecord = buildExceptionObject(orgId, methodName, LoggingLevel.ERROR, errorMessage, 
                                                           UserInfo.getUserId(), true, exceptionType); 
        System.debug('Exception log >>> ' + exLogRecord);
        
        return exLogRecord;
    }
    

	private static ExceptionLog__c buildExceptionObject(String orgID, String methodName, 
                                                        System.LoggingLevel severity, String apexErrMsg,
                                                        String user, Boolean handled, String exceptionType){
            
		ExceptionLog__c exceptionLog = new ExceptionLog__c();
 		exceptionLog.Exception_Details__c = apexErrMsg;
 		exceptionLog.Org_Id__c = orgID;

 		exceptionLog.Exception_Type__c = exceptionType;
 		exceptionLog.Application_Name__c = TWO_WAY_COMMUNICATION;
 		exceptionLog.Class_Name__C = CLASS_NAME_TWO_WAY_SERVICE;
 		exceptionLog.Method_Name__c = methodName;
 		//exceptionLog.Line_Number__c = handled?excp.getLineNumber():null;

 		exceptionLog.Username__c = user;
 		exceptionLog.Severity__c = severity.name();
 		//exceptionLog.Exception_Code__c ='';

 		exceptionLog.Log_Time__c = System.now();
	    exceptionLog.isHandled__c = handled;
 	    exceptionLog.Number_of_Times_Occured__c = 1;
                                                             

 		return exceptionLog;
 	}
    
     /*
     * The below method is to build the exception sObject.
     */
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
    
    /*
     * The below method is to insert the exception sObject list.
     */
    public static void insertExceptionLogList(List<ExceptionLog__c> exceptionLogList) {
        insert exceptionLogList;
    }
    	 

    
    public static final String EXCEPTION_CODE_FILTER = 'first error:';
    public static final String BLANK_SPACE = '';
    public static final Integer EXCEPTION_CODE_SIZE_LIMIT = 100; 
    public static final Integer REMOVE_DETAILS_VALUE = 2;
    public static final String CONTINUATION_String ='..';
    public static final String COLON = ':';
 	public static final String ENTER = '\n';
    public static final Integer EXCEPTION_DETAILS_SIZE_LIMIT = 131072;
    public static final String METHOD_NAME_GET_RECIPIENTS = 'getRecipients';
    public static final String GENERIC_EXCEPTION = 'Generic Exception';
    public static final String API_EXCEPTION = 'API Exception';
    public static final String TWO_WAY_COMMUNICATION = 'Two Way Communication';
    public static final String CLASS_NAME_TWO_WAY_SERVICE = 'TwoWayService';
    public static final String METHOD_NAME_DISPLAY_COMMENTS = 'displayComments';
    public static final String METHOD_NAME_RETURN_RESPONSE_BODYOBJ = 'returnResponseBodyObj';
    public static final String ERROR = 'Catch Exception';
    public static final String METHOD_NAME_RETURN_RESPONSE_BODYOBJ_FOR_SENTALERT = 'returnResponseBodyObjForSentAlert';
    public static final String SERVICE_CHANNEL = 'Service Channel';
    public static final String OFFICETRAX = 'Officetrax';
    
    
}
