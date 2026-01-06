/*************************************************************
@Name: TwoWayAPICall 
@Author: TCS
@Description: This class will be called for all API calling of Two way communication. 
**************************************************************/
public without sharing class APICallUtility {
    
    /*
     * @Method Name    : authenticateAndResponseGET
     * @Author         : TCS
     * @description    : 
     * @param          : Request body(String), Integration_Request_URLs__mdt metadata, and UserId
     * @return         : HTTPResponse object
     */
      public HTTPResponse authenticateAndResponseGET(string endpoint, Integration_Request_URLs__mdt integrationMetdata , string userId){
      HttpRequest req = formRequest(endpoint,integrationMetdata,userId, null);
      HTTPResponse responseObj = returnHTTPResponse(req);                 

      Return responseObj;    
    }

    /*
     * @Method Name    : authenticateAndResponseGET
     * @Author         : TCS
     * @description    : 
     * @param          : Request body(String), Integration_Request_URLs__mdt metadata, UserId and RequestId
     * @return         : HTTPResponse object
     */
    public HTTPResponse authenticateAndResponseGET(string endpoint, Integration_Request_URLs__mdt integrationMetdata , string userId, string requestId){
      HttpRequest req = formRequest(endpoint, integrationMetdata, userId, requestId);
      HTTPResponse responseObj = returnHTTPResponse(req);                 

      Return responseObj;    
    }
   
   
   /*
     * @Method Name    : authenticateAndResponsePost
     * @Author         : TCS
     * @description    : 
     * @param          : Request body(String), Integration_Request_URLs__mdt metadata, and UserId
     * @return         : HTTPResponse object
     */
      public HTTPResponse authenticateAndResponsePOST(string requestBody ,string endpoint, Integration_Request_URLs__mdt integrationMetdata , string userId){
       HttpRequest req = formRequest(endpoint,integrationMetdata,userId,null);
      req.setBody(RequestBody);
      HTTPResponse responseObj = returnHTTPResponse(req);                 
      Return responseObj ;    
   }

   /*
     * @Method Name    : apiCAll
     * @Author         : TCS
     * @description    : 
     * @param          : Request body(String), Integration_Request_URLs__mdt metadata, and UserId
     * @return         : HTTPRequest object
     */
    Private HttpRequest formRequest(String endpoint,Integration_Request_URLs__mdt integrationMetdata , string userId, string requestId){
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(Endpoint);
        req.setMethod(integrationMetdata.Method__c);
        req.setHeader('Content-Type',integrationMetdata.Content_Type__c);
        req.setHeader('X-USERID', userId);
        req.setHeader('X-PARTNER-KEY',integrationMetdata.Client_Key__c);
        req.setHeader('Authorization',integrationMetdata.Client_Token__c);
        if(String.isNotEmpty(requestId))
        {
          req.setHeader('X-Request-Id', requestId);
        }
        req.setTimeout(integrationMetdata.Timeout__c.intValue());
        
        return req;
         
     }
    
    /*
     * @Method Name    : returnHTTPResponse
     * @Author         : TCS
     * @description    : 
     * @param          : Request body
     * @return         : HTTPResponse object
     */
    private HTTPResponse returnHTTPResponse(HttpRequest requestBody){
    
      Http http = new Http();
      HTTPResponse responseObj = http.send(requestBody);                 
      Return responseObj ;    
   }
    
    
    /* Method 2  : return CustomMetadata Object based on "Integration Request URLs Name"  */
    /*
     * @Method Name    : returnMetaData
     * @Author         : TCS
     * @description    : This method queries the metadata from 'Integration Request URLs' Custom Metadata Type 
     * based on 'Integration Request URLs Name'
     * @param          : Integration Request URLs Name.
     * @return         : 'Integration_Request_URLs__mdt' Metadata Object.  
     */
    public List<Integration_Request_URLs__mdt> returnMetaData(String intReqUrlName) {
        List<Integration_Request_URLs__mdt> intReqUrlMetaData = new List<Integration_Request_URLs__mdt>();
        intReqUrlMetaData = [SELECT QualifiedApiName, NamespacePrefix, DeveloperName, MasterLabel, Id, Label, Client_Token__c, 
                          Client_Key__c, Timeout__c, Method__c, Content_Type__c, 
                          End_Point__c FROM Integration_Request_URLs__mdt WHERE DeveloperName =: intReqUrlName LIMIT 1];
                
        return intReqUrlMetaData;
    }
   
    
    /* Below methods are for Sample JSON Return*/
    
    public static String returnVIEWCommentJson() {
        String returnJSON;
                returnJSON = '{ "problem": { "title": "string","status": 0,"errors": [{"code": "string","message": "string"}]},"data": [{'+
      '"caseNumber": "string",'+
     '"referenceNumber": "string",'+
      '"caseOrigin": "string",'+
      '"systemOrigin": "string",'+
      '"message": "This is the first comment!",'+
      '"isActionRequired": true,'+
      '"receivedDate": "2023-05-05T14:36:13.715Z",'+
      '"sentDate": "2023-05-05T14:36:13.715Z",'+
      '"partnerReference": "string",'+
      '"wmReference": "string",'+
      '"recipients": [{"user": "string"}]}, {'+
      '"caseNumber": "string",'+
     '"referenceNumber": "string",'+
      '"caseOrigin": "string",'+
      '"systemOrigin": "string",'+
      '"message": "This is the second comment! This is the second comment!This is the second comment!'+
                    'This is the second comment!This is the second comment This is the second comment This is the second commentThis is the second commen'+
                    'This is the second comment!This is the second comment!",'+
      '"isActionRequired": true,'+
      '"receivedDate": "2023-05-05T14:36:13.715Z",'+
      '"sentDate": "2024-10-11T14:36:13.715Z",'+
      '"partnerReference": "string",'+
      '"wmReference": "string",'+
      '"recipients": [{"user": "string"}]}],'+
      '"pageIndex": 0,'+
      '"pageSize": 0,'+
      '"count": 0}';
        return returnJSON;
    }
    
    
    public static String returnVIEWCommentJsonPage() {
        String returnJSON;
                returnJSON = '{ "problem": { "title": "string","status": 0,"errors": [{"code": "string","message": "string"}]},"data": [{'+
      '"caseNumber": "string",'+
     '"referenceNumber": "string",'+
      '"caseOrigin": "string",'+
      '"systemOrigin": "string",'+
      '"message": "We are on Page 2 . we need to work fast to finsih the project. THIs will help us to grow",'+
      '"isActionRequired": true,'+
      '"receivedDate": "2023-05-05T14:36:13.715Z",'+
      '"sentDate": "2023-05-05T14:36:13.715Z",'+
      '"partnerReference": "string",'+
      '"wmReference": "string",'+
      '"recipients": [{"user": "string"}]}, {'+
      '"caseNumber": "string",'+
     '"referenceNumber": "string",'+
      '"caseOrigin": "string",'+
      '"systemOrigin": "string",'+
      '"message": "We are on Page 2 . we need to work fast to finsih the project. THIs will help us to grow'+
                    'We are on Page 2 . we need to work fast to finsih the project. THIs will help us to grow This is the fourth commentThis is the fourth commen'+
                    'This is the fourth comment!This is the fourth comment!",'+
      '"isActionRequired": true,'+
      '"receivedDate": "2023-05-05T14:36:13.715Z",'+
      '"sentDate": "2024-10-11T14:36:13.715Z",'+
      '"partnerReference": "string",'+
      '"wmReference": "string",'+
      '"recipients": [{"user": "string"}]}],'+
      '"pageIndex": 0,'+
      '"pageSize": 0,'+
      '"count": 0}';
      // System.debug('returnJSON>>>'+returnJSON);
        return returnJSON;
    }
    
    public static String returnGetRecipients() {
        String returnJSON;
         returnJSON = '[{"problem": {"title": "string","status": 0,"errors": [{"code": "string","message": "string"}]},'+
            '"data": {"id": 0,"userName": "Amardeep","email": "chauan@wm.com"}}]';
        return returnJSON;
    }
    
    /* Method 5  : Sample JSON Return add comments*/
    
    public static String returnADDCommentJson() {
        String returnJSON;
                returnJSON = '{"problem": {"title": "SampleTitle","status": 0,"errors": [{"code": "200","message": "this is parse message"'+
        '}]},"data": {"conversationId": 12121212}}';
      // System.debug('returnJSON>>>'+returnJSON);
        return returnJSON;
    }
}