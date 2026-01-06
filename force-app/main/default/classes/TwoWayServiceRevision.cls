/*************************************************************
@Name: TwoWayServiceRevision
@Author: TCS
@Creator: Aliasgher Kotawala
@Date: 04/03/2024
@Description: This class will be called for business logic of Two way communication for Service Revision. 
**************************************************************/
public without sharing class TwoWayServiceRevision {

        /*
     * @Method Name    : getServiceStatus
     * @Author         : TCS
     * @description    : Get the status list from external Intake systems like (Service channel and Office trax)
     * @param          : Origin field value of the Case record and CaseNumber field value of Case record
     * Modification    : 
     * @return         : 
     */
    public static responseBodyObjForGetServiceStatus getServiceStatus(String caseNumber){
        Integer httpStatusCode;
        List<ExceptionLog__c> exceptionLogList = new List<ExceptionLog__c>();   
        responseBodyObjForGetServiceStatus responseObject = new responseBodyObjForGetServiceStatus();
        
        try {
            String UserId =  IntegrationHandlerUtil.getLoggedInUserAcornId();
            
            APICallUtility apiObj = new APICallUtility();
            //SDT-36424: Changes for officetrax 
            List<Integration_Request_URLs__mdt> integrationMetdata =  apiObj.returnMetaData('Two_way_Get_ServiceStatus');

            String Endpoint = integrationMetdata[0].End_Point__c.replace('{CaseNumber}', String.valueOf(caseNumber));
            // String Endpoint = integrationMetdata[0].End_Point__c.replace('{CaseNumber}', '66620315');
            System.debug('Endpoint>>>'+Endpoint);
            
            HttpResponse responseOBJ = apiObj.authenticateAndResponseGET(Endpoint,integrationMetdata[0] , UserId);
            httpStatusCode = responseOBJ.getStatusCode();
            System.debug('*** Result' + responseOBJ.getBody());
            
            String  JString = responseOBJ.getBody();
            responseObject = parseResponseBodyForGetServiceStatus(JString);
            
            system.debug('*** Parse Result' +responseObject);   
            
            if(responseObject.problem != null) {
                for(Integer i =0; i<responseObject.problem.errors.size(); i++) {
                    ExceptionLog__c exLog = TwoWayService.logExceptions(responseObject.problem.errors[i].message, METHOD_NAME_SERVICE_STATUS, API_EXCEPTION);
                    System.debug(exLog);
                    exceptionLogList.add(exLog);
                }
                System.debug(exceptionLogList.size());
            }
        }        
        catch(Exception ex) {
            responseObject.data = null;
            //Calling createProblemObject() method. It returns problem object.
            TwoWayService.problem problemObject = TwoWayService.createProblemObject(httpStatusCode, ex);
            responseObject.problem = problemObject;
            system.debug(responseObject);
            
            //calling the logExceptions() method.
            ExceptionLog__c exLog = TwoWayService.logExceptions(ex.getMessage(), METHOD_NAME_SERVICE_STATUS, GENERIC_EXCEPTION);
            system.debug(exLog);
            exceptionLogList.add(exLog);
            
        }
        TwoWayService.insertExceptionLogList(exceptionLogList);
        
        return responseObject;        
    }

    //This class is the structure of the JSON response coming from API for getting the service status in update portal functionality.
    public class responseBodyObjForGetServiceStatus {
        @auraEnabled public TwoWayService.problem problem;
        @auraEnabled public serviceStatusData data;
    } 
    
    public class serviceStatusData {
        @auraEnabled public String serviceStatus;
        @auraEnabled public Datetime serviceDate;  
        @auraEnabled public List<serviceStatuses> serviceStatuses;  
    }

    public class serviceStatuses {
        @auraEnabled public String name;
    }
    
    /*
     Method to parse the JSON string response coming from the API callout of Service Status.
     */
    public static responseBodyObjForGetServiceStatus parseResponseBodyForGetServiceStatus(String jsonString){
        return (responseBodyObjForGetServiceStatus) System.JSON.deserialize(jsonString, responseBodyObjForGetServiceStatus.class);
    }
    
    /*
     * @Method Name    : saveCaseServiceRevision
     * @Author         : TCS
     * @description    : Save the case status and service date to external system.
     * @param          : ServiceDataBody (String), Origin field value of the Case record and CaseNumber field value of Case record
     * @return         : 
     */
    public static String saveCaseServiceRevision (string ServiceDataBody , String Origin, string caseNumber){        
        System.debug('ServiceDataBody>>>'+ServiceDataBody);
                                
        APICallUtility apiObj = new APICallUtility();
        List<Integration_Request_URLs__mdt> integrationMetdata = apiObj.returnMetaData('Two_way_Update_Case_Status');
        String UserId =  IntegrationHandlerUtil.getLoggedInUserAcornId();
        System.debug('test'+integrationMetdata[0].End_Point__c);
        String Endpoint = integrationMetdata[0].End_Point__c.replace('{CaseNumber}', String.valueOf(caseNumber));
        // String Endpoint = integrationMetdata[0].End_Point__c.replace('{CaseNumber}', '66620315');
        System.debug('Endpoint>>>'+Endpoint);
        HttpResponse responseOBJ = apiObj.authenticateAndResponsePOST(ServiceDataBody,Endpoint,integrationMetdata[0] , UserId);
        System.debug('*** Result' + responseOBJ.getBody());
        
        return responseOBJ.getBody();    
    }

    /*
     * @Method Name    : returnResponseBodyObjForServiceRevision
     * @Author         : TCS
     * @description    : This method is called from UpdatePortal class. 
     * The request body for Service Revision functionality is created here. 
     * API call is done and response is parsed into an apex object and returned.
     * @param          : CaseReferenceNumber, Case origin, Service Date, Service Status, CreatedById.
     * @return         : responseBodyObjForServiceRevision object.
     */
    Public static responseBodyObjForServiceRevision returnResponseBodyObjForServiceRevision(String caseReferenceNumber, String origin, Datetime serviceDate, String serviceStatus, String createdBy){
        Integer httpStatusCode;
        List<ExceptionLog__c> exceptionLogList = new List<ExceptionLog__c>();  
		responseBodyObjForServiceRevision returnObj = new responseBodyObjForServiceRevision();
        
        try 
        {
            requestBodyObjForServiceRevision requestBodyObj = new requestBodyObjForServiceRevision(caseReferenceNumber, origin, serviceDate, serviceStatus, createdBy);
            // requestBodyObjForServiceRevision requestBodyObj = new requestBodyObjForServiceRevision('66620315', origin, serviceDate, serviceStatus, createdBy);
            system.debug(requestBodyObj);
            String jsonStringRequestBody = returnJSONString(requestBodyObj);
            system.debug(jsonStringRequestBody);            
            
            //Integer k = 1/0;
            
            String responseBody = saveCaseServiceRevision(jsonStringRequestBody, origin, caseReferenceNumber);
            returnObj = parseResponseBodyForServiceRevision(responseBody);
            System.debug(returnObj);
            
            if(returnObj.problem != null) {
                for(Integer i =0; i<returnObj.problem.errors.size(); i++) {
                    ExceptionLog__c exLog = TwoWayService.logExceptions(returnObj.problem.errors[i].message, METHOD_NAME_RETURN_RESPONSE_BODYOBJ_FOR_SERVICEREVISION, API_EXCEPTION);
                    System.debug(exLog);
                    exceptionLogList.add(exLog);
                }
                System.debug(exceptionLogList.size());
            }            
        }        
        catch(Exception ex) {
            returnObj.data = null;
            //Calling createProblemObject() method. It returns problem object.
            TwoWayService.problem problemObject = TwoWayService.createProblemObject(httpStatusCode, ex);
            returnObj.problem = problemObject;
            system.debug(returnObj);
            
            //calling the logExceptions() method.
            ExceptionLog__c exLog = TwoWayService.logExceptions(ex.getMessage(), METHOD_NAME_RETURN_RESPONSE_BODYOBJ_FOR_SERVICEREVISION, GENERIC_EXCEPTION);
            system.debug(exLog);
            exceptionLogList.add(exLog);            
        }
        //insering exception logs.
        TwoWayService.insertExceptionLogList(exceptionLogList);
        
        return returnObj;        
    }

    //This class is the structure of the request body for Service Revision callout.       
    public class requestBodyObjForServiceRevision{
        @auraEnabled public String referenceNumber;  
        @auraEnabled public String caseOrigin;  
        @auraEnabled public Datetime serviceDate;  
        @auraEnabled public String serviceStatus;  
        @auraEnabled public String createdBy;  
        
        /*
        *Constructor to form the request body object for Service Revision.
        */
        public requestBodyObjForServiceRevision(String referenceNumber, String caseOrigin,   
                                            Datetime serviceDate, String serviceStatus,
                                            String createdBy) {
                                                
            this.referenceNumber = referenceNumber;                                            
            this.caseOrigin = caseOrigin;
            this.serviceDate = serviceDate;
            this.serviceStatus = serviceStatus;
            this.createdBy = createdBy; 
        }
    }

    //This class is the structure of the the response coming from API for Save Service Revision.
    public class responseBodyObjForServiceRevision{
        @auraEnabled public TwoWayService.problem problem;
        @auraEnabled public serviceResData data;
    }

    public class serviceResData {
        @auraEnabled public Boolean isSuccess;
    }

    /*
     Method to parse the JSON string response coming from the API callout of Service Revision.
    */
    public static responseBodyObjForServiceRevision parseResponseBodyForServiceRevision(String jsonString) {
        return (responseBodyObjForServiceRevision) System.JSON.deserialize(jsonString, responseBodyObjForServiceRevision.class);
    }

    /*
     Method to parse and return a JSON String for the request body object for Service Revision.
    */
    public static String returnJSONString(requestBodyObjForServiceRevision requestBodyObj) {
        System.debug(JSON.serialize(requestBodyObj));
        return JSON.serialize(requestBodyObj);
    }

    /*
     * @Method Name    : displayServiceRevision
     * @Author         : TCS
     * @description    : 
     * @param          : Origin field value of the Case record and CaseNumber field value of Case record
     * @return         : DisplayServiceRevisionWrapper object with values from the JSON received from the API utility class
     */
    public static DisplayServiceRevisionWrapper displayServiceRevision(string caseNumber, Integer pageIndex, Integer pageSize){
        Integer httpStatusCode;
        List<ExceptionLog__c> exceptionLogList = new List<ExceptionLog__c>();  
        DisplayServiceRevisionWrapper disServiceRecord = new DisplayServiceRevisionWrapper();
        
        try {
            String UserId =  IntegrationHandlerUtil.getLoggedInUserAcornId();
            
            APICallUtility apiObj = new APICallUtility();
            List<Integration_Request_URLs__mdt> integrationMetdata = apiObj.returnMetaData('Two_way_Get_Case_ServiceRevisions');
            
            String Endpoint = integrationMetdata[0].End_Point__c.replace('{CaseNumber}', String.valueOf(caseNumber)); //66620315
            // String Endpoint = integrationMetdata[0].End_Point__c.replace('{CaseNumber}', '66620315');
            Endpoint = Endpoint + '?PageIndex='+pageIndex+'&PageSize='+pageSize;
            System.debug('Endpoint>>>'+Endpoint);
            
            
            //Integer k = 1/0;
            
            HttpResponse responseOBJ = apiObj.authenticateAndResponseGET(Endpoint, integrationMetdata[0], UserId);
            System.debug('*** Result' + responseOBJ.getBody());
            
            String JString;
            JString = responseOBJ.getBody();
            System.debug(JString);
            
            disServiceRecord = parsedisplayServiceRevision(JString);
            system.debug(disServiceRecord);
            
            if(disServiceRecord.problem != null) {
                for(Integer i =0; i<disServiceRecord.problem.errors.size(); i++) {
                    ExceptionLog__c exLog = TwoWayService.logExceptions(disServiceRecord.problem.errors[i].message, METHOD_NAME_DISPLAY_SERVICE_REVISION, API_EXCEPTION);
                    System.debug(exLog);
                    exceptionLogList.add(exLog);
                }
                System.debug(exceptionLogList.size());
            }            
        }        
        catch(Exception ex) {
            System.debug('inside catch');
            disServiceRecord.data = null;
            //Calling createProblemObject() method. It returns problem object.
            TwoWayService.problem problemObject = TwoWayService.createProblemObject(httpStatusCode, ex);
            disServiceRecord.problem = problemObject;
            system.debug(disServiceRecord);
            
            //calling the logExceptions() method.
            ExceptionLog__c exLog = TwoWayService.logExceptions(ex.getMessage(), METHOD_NAME_DISPLAY_SERVICE_REVISION, GENERIC_EXCEPTION);
            system.debug(exLog);
            exceptionLogList.add(exLog);            
        }
        
        //inserting exceptionLogList;
        TwoWayService.insertExceptionLogList(exceptionLogList);
        
        system.debug(disServiceRecord);
        return disServiceRecord;
    }

    public class DisplayServiceRevisionWrapper{
        @AuraEnabled public TwoWayService.problem problem;
        @AuraEnabled public List<ServiceData> data;
        @AuraEnabled public Integer pageIndex;   //0
        @AuraEnabled public Integer pageSize;    //10
        @AuraEnabled public Integer count;   //0    
    }
           
    public class ServiceData {
        @auraEnabled public String caseNumber;   //string
        @auraEnabled public String referenceNumber;  //string
        @auraEnabled public String serviceDate; //2023-05-05T14:36:13.715Z
        @auraEnabled public String serviceStatus;  //string
        @auraEnabled public String processedDate; //2023-05-05T14:36:13.715Z
        @auraEnabled public String userMessage;  //string
        @auraEnabled public String exceptionMessage; //string
        @auraEnabled public String createDate; //2023-05-05T14:36:13.715Z
        @auraEnabled public String createdBy;  //string    
    }
    
    public static DisplayServiceRevisionWrapper parsedisplayServiceRevision(String json){
        return (DisplayServiceRevisionWrapper) System.JSON.deserialize(json, DisplayServiceRevisionWrapper.class);
    }

    public static final String GENERIC_EXCEPTION = 'Generic Exception';
    public static final String API_EXCEPTION = 'API Exception';
    public static final String METHOD_NAME_DISPLAY_SERVICE_REVISION = 'displayServiceRevision';
    public static final String METHOD_NAME_SERVICE_STATUS = 'getServiceStatus';
    public static final String METHOD_NAME_RETURN_RESPONSE_BODYOBJ_FOR_SERVICEREVISION = 'returnResponseBodyObjForServiceRevision';
}