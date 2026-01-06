/*************************************************************
@Name: ContactTextOptInInvokableAPI
@Author: WM
@CreateDate: 09/04/2021
@Description: Invokable class for calling OptIn API
@UsedBy: Process Builder
**************************************************************/
public without sharing class ContactTextOptInInvokableAPI {
    
    public class InvocableVariable 
    {
        @InvocableVariable(label='Id')
        public Id recId;
        
        @InvocableVariable(label='Contact Email')
        public String contactEmail;
        
        @InvocableVariable(label='Contact Name')
        public String contactName;
    }
	
    @InvocableMethod(
        label = 'OptIn'
        description = 'Given contact IDs then OptIn/OptOut Text Notification'
    )
    public static void textNotificationOptIn(List<InvocableVariable> variableInfo) {
        
        for(InvocableVariable invoVar : variableInfo)
        {
            callOptInAPI(invoVar.recId,invoVar.contactEmail,invoVar.contactName);
        }        

    }
   /*
	* This method will call text notification OptIn API.
	* @owner : WM
	* @param : String,String,String
	*/     
    @Future(callout = true)
    public static void callOptInAPI(String recId, String conEmail, String conName) {
        
        Integration_Request_URLs__mdt apiCall = [SELECT Client_Key__c,Client_Token__c,Content_Type__c,DeveloperName,End_Point__c,Method__c FROM Integration_Request_URLs__mdt WHERE DeveloperName =: Constant_Util.OPTIN_DEVELOPER_NAME Limit 1]; 
        String Token = ContactTextOptOutInvokableAPI.apiAuth();
        ContactTextOptInInvokableAPI.SubscriberAttributes sub = new ContactTextOptInInvokableAPI.SubscriberAttributes();
        sub.Name = conName;
        sub.ContactId = recId;
        sub.PreferredLanguage = Constant_Util.PREFERRED_LANGUAGE;
        ContactTextOptInInvokableAPI.ContactAttributes conAttributes = new ContactTextOptInInvokableAPI.ContactAttributes();
        conAttributes.SubscriberAttributes = sub;
        ContactTextOptInInvokableAPI.To toInfo = new ContactTextOptInInvokableAPI.To();
        toInfo.Address = conEmail;
        toInfo.SubscriberKey = recId;
        toInfo.ContactAttributes = conAttributes;
        ContactTextOptInInvokableAPI.apiTo finalBody = new ContactTextOptInInvokableAPI.apiTo();
        finalBody.To = toInfo;
        Http https = new Http();         
        HttpRequest requests = new HttpRequest();         
        requests.setMethod(apiCall.Method__c);         
        requests.setEndpoint(apiCall.End_Point__c);         
        requests.setHeader(Constant_Util.CONTENT_TYPE, apiCall.Content_Type__c);
        requests.setHeader(Constant_Util.AUTH,Constant_Util.BEARER+ Token);
        requests.setBody(JSON.serialize(finalBody));
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

	public class SubscriberAttributes
    {
        public String Name;
        public String ContactId;
        public String PreferredLanguage;
    }
    
    public class ContactAttributes
    {
        public SubscriberAttributes SubscriberAttributes;
    }
    
    public class To
    {
        public String Address;
        public String SubscriberKey;
        public ContactAttributes ContactAttributes;
    }
    
    public class apiTo
    {
        public To To;
    }
}