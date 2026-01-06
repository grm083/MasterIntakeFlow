/*************************************************************
@Name: ContactTextOptOutInvokableAPI
@Author: WM
@CreateDate: 09/04/2021
@Description: Invokable class for calling OptOut API
@UsedBy: Process Builder
**************************************************************/
public without sharing class ContactTextOptOutInvokableAPI {

    public class MyInvocableVariable 
    {
        @InvocableVariable(label='Id')
        public Id recId;
        
        @InvocableVariable(label='Old MobilePhone')
        public String oldMobilePhone;
        
        @InvocableVariable(label='Current MobilePhone')
        public String newMobilePhone;
    }
    
    @InvocableMethod(
        label = 'OptOut'
        description = 'Given contact IDs then OptIn/OptOut Text Notification'
    )
    public static void textNotificationOptOut(List<MyInvocableVariable> variableInfo) {
        for(MyInvocableVariable invoVar : variableInfo)
        {
            callOptOutAPI(invoVar.oldMobilePhone,invoVar.recId);
        }
    }
   /*
	* This method will call text notification Optout API.
	* @owner : WM
	* @param : Contact List
	*/    
    @Future(callout = true)
    public static void callOptOutAPI(List<ID> conIds) {
        
        String Token = apiAuth();
        List<subscribers> subList = new List<subscribers>();
        
        for(Contact con : [Select Id,mobilephone from contact where Id IN:conIds ALL ROWS])
        {
            ContactTextOptOutInvokableAPI.subscribers sub = new ContactTextOptOutInvokableAPI.subscribers();
            sub.mobilenumber = '1'+con.MobilePhone;
            sub.subscriberkey = con.Id;
            subList.add(sub);
        }
		apiCall(subList,Token);
    }
   /*
	* This method will call text notification Optout API.
	* @owner : WM
	* @param : String,Id
	*/   
     @Future(callout = true)
    public static void callOptOutAPI(String mobPhone,Id conId) {
        String Token = apiAuth();
        List<subscribers> subList = new List<subscribers>();
        ContactTextOptOutInvokableAPI.subscribers sub = new ContactTextOptOutInvokableAPI.subscribers();
            sub.mobilenumber = '1'+mobPhone;
            sub.subscriberkey = conId;
            subList.add(sub);
        apiCall(subList,Token);
    }
   /*
	* This method will call text notification Optout Authentication API.
	* @owner : WM
	*/
    public static String apiAuth()
    {
        Integration_Request_URLs__mdt apiAuth = [SELECT Client_Key__c,Client_Token__c,Content_Type__c,DeveloperName,End_Point__c,Method__c FROM Integration_Request_URLs__mdt WHERE DeveloperName =:Constant_Util.AUTH_DEVELOPER_NAME Limit 1]; 
        String Token = '';
        Http http = new Http();         
        HttpRequest request = new HttpRequest();         
        request.setMethod(apiAuth.Method__c);         
        request.setEndpoint(apiAuth.End_Point__c);         
        request.setHeader(Constant_Util.CONTENT_TYPE, apiAuth.Content_Type__c);                 
        ContactTextOptOutInvokableAPI.AccessTokenServiceRequest acccessTokenServiceRequestObj = new ContactTextOptOutInvokableAPI.AccessTokenServiceRequest();         
        acccessTokenServiceRequestObj.grant_type = Constant_Util.GRANT_TYPE;         
        acccessTokenServiceRequestObj.client_id= apiAuth.Client_Key__c;         
        acccessTokenServiceRequestObj.client_secret= apiAuth.Client_Token__c;                 
        request.setBody(JSON.serialize(acccessTokenServiceRequestObj));
        if(!Test.isRunningTest())
        {
            try
            {
                HttpResponse response = http.send(request);
                if(response.getStatusCode() == Constant_Util.STATUS_CODE)
                {
                    Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                    Token = String.valueOf(m.get(Constant_Util.ACCESS_TOKEN));
                    return Token;
                }
            }
            catch(Exception e)
            {
               UTIL_LoggingService.logHandledException(e, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR); 
            }
            
        }
        return Token;
    }
   /*
	* This method will call text notification Optout API.
	* @owner : WM
	* @param : subscribers List,String
	*/    
    public static void apiCall(List<subscribers> subList,String Token)
    {
        Integration_Request_URLs__mdt apiCall = [SELECT Client_Key__c,Client_Token__c,Content_Type__c,DeveloperName,End_Point__c,Method__c FROM Integration_Request_URLs__mdt WHERE DeveloperName =: Constant_Util.OPTOUT_DEVELOPER_NAME Limit 1]; 
        ContactTextOptOutInvokableAPI.requestBodyParam reqBody = new ContactTextOptOutInvokableAPI.requestBodyParam();
        reqBody.subscribers = subList;
        reqBody.Subscribe = true;
        reqBody.Resubscribe = true;
        reqBody.keyword = Constant_Util.API_KEYWORD;
        reqBody.SendTime = System.now();    
        Http https = new Http();         
        HttpRequest requests = new HttpRequest();         
        requests.setMethod(apiCall.Method__c);         
        requests.setEndpoint(apiCall.End_Point__c);         
        requests.setHeader(Constant_Util.CONTENT_TYPE, apiCall.Content_Type__c);
        requests.setHeader(Constant_Util.AUTH,Constant_Util.BEARER+ Token);
        requests.setBody(JSON.serialize(reqBody));
        HttpResponse finalresponse = new HttpResponse();
        if(!Test.isRunningTest())
        {
            try
            {
              finalresponse = https.send(requests);  
            }
            catch(Exception e)
            {
                UTIL_LoggingService.logHandledException(e, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
            }
        } 
    }
    
	public class AccessTokenServiceRequest
    {
        public String grant_type;
        public String client_id;
        public String client_secret;
    }
    
    public class subscribers
    {
        public String mobilenumber;
        public String subscriberkey;
    }
    
    public class requestBodyParam
    {
        public List<subscribers> subscribers;
        public Boolean Subscribe;
        public Boolean Resubscribe;
        public String keyword;
        public DateTime SendTime;
    }    
}