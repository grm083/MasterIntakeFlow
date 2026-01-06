/**
  * @Name          UTIL_UnhandledLoggingService
  * @author        Accenture
  * @date		       23/09/2019
  * @description   This Class is invoked in the event of an Email being sent due to an Unhandled Exception thrown by any running class and is used to call method from UTIL_LoggingService class to create the ExceptionLog__c record.
  */
global without sharing class UTIL_UnhandledLoggingService implements Messaging.InboundEmailHandler {
  /*
      * @description       This method handles unhandled exception and process capturing accoridingly
      * @param             standard parameters for Email Service
      * @return            Messaging.InboundEmailResult
    */
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope){
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();        
        UTIL_LoggingService.logUnhandledException(email);
        return result;
    }
}