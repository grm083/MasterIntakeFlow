/*************************************************************
@Name: ExceptionLogEmailSend
@Author: WM
@CreateDate: 01/03/2021
@Description: Class to check exception log type count and sending email.
@UsedBy: 
**************************************************************/
public without sharing class ExceptionLogEmailSend {
    /*
    * @Description - It is used for generation exception type count.
    * @owner : WM
    */
    public static void generateCount()
    {
        Map<String,Integer> countMap = new Map<String,Integer>();
        for(ExceptionLog__c excLog: [SELECT Exception_Type__c FROM ExceptionLog__c WHERE CreatedDate = today])
        {
            if(countMap.containsKey(excLog.Exception_Type__c))
            {
                countMap.put(excLog.Exception_Type__c,countMap.get(excLog.Exception_Type__c)+1);
            }
            else
            {
                countMap.put(excLog.Exception_Type__c,1);
            }
        }
        sendEmail(countMap);
    }
   
    /*
    * @Description - It is used for sending email with exception count.
    * @owner : WM
    * @Param : Map<String,Integer>
    */
    public static void sendEmail(Map<String,Integer> countMapVal)
    {
        String htmlBody;
        Boolean isSendMessage = false;
        ExceptionLog_Settings__c excRec = ExceptionLog_Settings__c.getOrgDefaults();
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<String> sendTo = new List<String>();
        sendTo.add(excRec.Exception_Log_Email_DL__c);
        htmlBody = '<html><head><style>table, th, td {border: 1px solid black;}</style></head><body><p>Hi Team,</p><p>Here are the details of the exception occurred.</p>'
            		+'<table style="width:100%"><tr><th>Exception Type</th><th>Exception occured</th> </tr>';
        for(String excType : countMapVal.keySet())
        {
            if(countMapVal.get(excType) >= excRec.Exception_Type_Limit__c)
            {
                htmlBody = htmlBody + '<tr><td>'+excType+'</td><td>'+countMapVal.get(excType)+'</td></tr>';
                isSendMessage = true;
            } 
        }
        htmlBody = htmlBody+'</table><p>Regards,</br>CI Team</p></body></html>';
        try{
            if(isSendMessage)
            {
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.setToAddresses(sendTo);
                message.subject = 'Exception Occurrences';
                message.setHtmlBody(htmlBody);
                mails.add(message);
                Messaging.sendEmail(mails);
            }
        }
        catch(Exception ex)
        {
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
        }
    }
}