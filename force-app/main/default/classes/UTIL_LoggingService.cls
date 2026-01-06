/*
  * @Name          UTIL_LoggingService
  * @Author        Accenture
  * @Date          19/09/2019
  * @Description   UTIL class for the purpose of logging handled and unhandled exceptions by creating ExceptionLog__c record.
  */
public without sharing class UTIL_LoggingService {

     /*
      * @description       This method is used to build the ExceptionLog__c record to be inserted.  
      * @param             excp the Exception object
      * @param             orgID the organization ID
      * @param             applicationName the Application Name
      * @param             className the Class Name
      * @param             methodName the Method Name
      * @param             severity the system.LoggingLevel variable to determine the exception level
      * @param             apexErrMsg the String containing error Message (for unhandledException)
      * @param             exceptionName the String containing exception type (for unhandledException)
      * @param             triggerName the String containing Trigger Name (for unhandledException)
      * @param             severityVal the String containing severity level value (for unhandledException)
      * @param             user the String containing logged in User ID (for unhandledException)
      * @param             codeSnippet the String containing the exception code (for unhandledException)
      * @param             handled the Boolean value to determine if it is handled exception or unhandled
      * @return            ExceptionLog__c
    */ 
    private static ExceptionLog__c buildExceptionObject(Exception excp, String orgID, String applicationName, String className, 
                                                        String methodName, System.LoggingLevel severity, String apexErrMsg, String exceptionName, 
                                                        String triggerName, String severityVal, String user, String codeSnippet, Boolean handled){
         ExceptionLog__c exceptionLog = new ExceptionLog__c();
         exceptionLog.Exception_Details__c = handled?buildExceptionDetails(excp):apexErrMsg;
         exceptionLog.Org_Id__c = orgID;
         exceptionLog.Exception_Type__c = handled?excp.getTypeName():exceptionName;
         exceptionLog.Application_Name__c = applicationName;
         exceptionLog.Class_Name__C = className;
         exceptionLog.Method_Name__c = methodName;
         exceptionLog.Trigger_Name__c = triggerName;
         exceptionLog.Line_Number__c = handled?excp.getLineNumber():null;
		 exceptionLog.Username__c = handled || (user==null || !String.isNotBlank(user))?UserInfo.getUserId():[SELECT Name FROM User WHERE ID=: user limit 1].Id;
         exceptionLog.Severity__c = handled?severity.name():severityVal;
         if(handled){
             Integer startPoint = excp.getMessage().IndexOf(UTIL_ErrorConstants.EXCEPTION_CODE_FILTER)+UTIL_ErrorConstants.EXCEPTION_CODE_FILTER.length();
             String excpCode = excp.getMessage().substring(startPoint).trim();
             excpCode = (excpCode.split(UTIL_ErrorConstants.BLANK_SPACE))[0];
             exceptionLog.Exception_Code__c = excpCode.left(excpCode.length()-1);
         }
         else{
                exceptionLog.Exception_Code__c = codeSnippet.left(UTIL_ErrorConstants.EXCEPTION_CODE_SIZE_LIMIT); //(codeSnippet.contains(UTIL_ErrorConstants.COLON))?codeSnippet.subString(codeSnippet.indexOf(exceptionName+UTIL_ErrorConstants.COLON)+exceptionName.length()+1,codeSnippet.length()).left(UTIL_ErrorConstants.EXCEPTION_CODE_SIZE_LIMIT):
         }
         exceptionLog.Exception_Description__c = handled?excp.getMessage().left(UTIL_ErrorConstants.EXCEPTION_CODE_SIZE_LIMIT-UTIL_ErrorConstants.REMOVE_DETAILS_VALUE)+UTIL_ErrorConstants.CONTINUATION_STRING:codeSnippet.left(UTIL_ErrorConstants.EXCEPTION_CODE_SIZE_LIMIT);
         exceptionLog.Log_Time__c = System.now();
         exceptionLog.isHandled__c = handled;
         exceptionLog.Number_of_Times_Occured__c = 1;                                                 
    
         return exceptionLog;
     }
    /*
      * @description       This method is used to build the exception details from captured exception record
      * @param             excp the Exception object
      * @return            String
      */
     private static String buildExceptionDetails(Exception excp){
         string details = excp.getTypeName()+UTIL_ErrorConstants.COLON+excp.getMessage()+UTIL_ErrorConstants.ENTER+excp.getStackTraceString();
         return details.left(UTIL_ErrorConstants.EXCEPTION_DETAILS_SIZE_LIMIT);
     }
    /*
      * @description       This method is used to build the exception details genrated from database DML methods
      * @param             List of errors during DML excution
      * @return            String
      */
     private static String buildErrorMessageFromErrorList(List<Database.Error> errorList){
         string errorMessage = UTIL_ErrorConstants.BLANK_SPACE;
         for(database.Error error : errorList){
             errorMessage += error + UTIL_ErrorConstants.ENTER;
         }
         return errorMessage.left(UTIL_ErrorConstants.EXCEPTION_DETAILS_SIZE_LIMIT);
     }
    /*
      * @description       This main method to log ExceptionLog__c records in case of Exception obtained due to Database.SaveResult or Database.DeleteResult operation.
      * @param             svResults A List of Database.Saveresult object records
      * @param             delResults A List of Database.Deleteresult object records
      * @param             objs A List of sObject records which threw the exception when being saved
      * @param             appName the Application Name
      * @param             className the Class Name
      * @param             methodName the Method Name
      * @param             triggerName the Trigger Name
      * @param             level the system.LoggingLevel to determine the exception level
      * @return            void
    */
    public static void logDmlResults(List<Database.SaveResult> svResults, List<Database.DeleteResult> delResults, 
                                      List<sObject> objs, String appName, String className, String methodName, String triggerName, 
                                      system.LoggingLevel level){
         List<ExceptionLog__c>  exceptionLogList = new List<ExceptionLog__c>();
                                         
         try{
         if(svResults!=null && delResults==null){
             exceptionLogList = createExceptionForSaveResults(svResults, objs, appName, className, methodName, triggerName, level);
            }
         
         else if(delResults!=null && svResults==null){
             exceptionLogList = createExceptionsForDeleteResults(delResults, objs, appName, className, methodName, triggerName, level);
         }
         else{
             //Novacop fix
         }
         
         if (exceptionLogList.size() > 0 && svResults!=null && delResults==null) {
			/*below 3 lines commented for 17322
			 *  List<ExceptionLog__c> mergeLogList = new List<ExceptionLog__c>();                          
             mergeLogList = mergeExistingErrorLogs(exceptionLogList); 
            insertExceptionList(mergeLogList);     	    //To check duplicate ExceptionLog__c records in list of insertable exceptions 
			*/
             insertExceptionList(exceptionLogList);//added for 17322
		 }
         else if (exceptionLogList.size() > 0 && delResults!=null && svResults==null) {
             //Database.insert(exceptionLogList, false);
             /*below 3 lines commented for 17322
             List<ExceptionLog__c> mergeLogList = new List<ExceptionLog__c>();                          
             mergeLogList = mergeExistingErrorLogs(exceptionLogList);
 			 insertExceptionList(mergeLogList); 			//To check duplicate ExceptionLog__c records in list of insertable exceptions 
			*/
             insertExceptionList(exceptionLogList); //added for 17322
             
         }
         else{
             //Novacop fix
         }
         }
         catch(Exception excp){
             logHandledException(excp, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
         }
     }
    /*
      * @description       This method is used to check duplicate errors in list of errors generated from database DMLs
      * @param             List of ExceptionLog__c object created
      */
     private static void insertExceptionList(List<ExceptionLog__c> mergeLogList){
         
         List<ExceptionLog__c> filteredList = new List<ExceptionLog__c>();
         ExceptionLog__c copyExcp = new ExceptionLog__c();
         
         for(ExceptionLog__c exceptionLog : mergeLogList){
             if(filteredList.size() == 0){
                  filteredList.add(exceptionLog);
             }
             else{                       
                 for(ExceptionLog__c excpRec: filteredList){
                      if(String.isNotBlank(excpRec.Exception_Details__c) && excpRec.Exception_Details__c.equalsIgnoreCase(exceptionLog.Exception_Details__c) &&
                        (((String.isNotBlank(excpRec.Class_Name__c) && excpRec.Class_Name__c.equalsIgnoreCase(exceptionLog.Class_Name__c)) && 
                          (String.isNotBlank(excpRec.Method_Name__c) && excpRec.Method_Name__c.equalsIgnoreCase(exceptionLog.Method_Name__c))) ||
                         (String.isNotBlank(excpRec.Trigger_Name__c) && excpRec.Trigger_Name__c.equalsIgnoreCase(exceptionLog.Trigger_Name__c)))){
                         excpRec.Number_of_Times_Occured__c = (excpRec.Number_of_Times_Occured__c == null?1:excpRec.Number_of_Times_Occured__c) + 1;
                         copyExcp = null;                                 
                      }
                      else{
                          copyExcp = exceptionLog;
                      }
                 }
                 if(copyExcp != null){
                      filteredList.add(copyExcp);
                 } 
             } 
         }                                                            
         if (!filteredList.isEmpty()) {
            logException(filteredList);
         }
     }
    /*
      * @description       This method logs ExceptionLog__c records in case of Exception obtained due to Database.SaveResult
      * @param             svResults A List of Database.Saveresult object records
      * @param             relatedsObjects A List of sObject records which threw the exception when being saved
      * @param             appName the Application Name
      * @param             className the Class Name
      * @param             methodName the Method Name
      * @param             triggerName the Trigger Name
      * @param             level the system.LoggingLevel to determine the exception level
      * @return            List<ExceptionLog__c>
    */
     private static List<ExceptionLog__c> createExceptionForSaveResults(List<Database.SaveResult> saveResults, 
                                                                        List<sObject> relatedsObjects, String appName, 
                                                                        String className, string methodName, String triggerName,
                                                                        System.LoggingLevel level) {
         List<ExceptionLog__c> exceptionLogList = new List<ExceptionLog__c>(); 
         ExceptionLog__c exceptionObj = null;
         if (exceptionLogMeetsSeverityFilter(level.name())){ 
             exceptionObj = new ExceptionLog__c(Exception_Type__c =UTIL_ErrorConstants.DML_EXCEPTION,
                                                Org_Id__c=UserInfo.getOrganizationId(),Class_Name__C =className, 
                                                Method_Name__c = methodname,Username__c = UserInfo.getUserId(), 
                                                Number_of_Times_Occured__c=1,Application_Name__c = appName,
                                                Severity__c = level.name(),Trigger_Name__c=triggerName,isHandled__c = true);         
             for(integer i=0; i <saveResults.size(); ++i) {
                 Database.SaveResult saveresult = saveResults[i];
                 ExceptionLog__c currentExceptionObj = null;
                 
                 if(!saveresult.isSuccess()) {
                     Database.Error[] errors = saveresult.getErrors();
                     String relatedObjectString = UTIL_ErrorConstants.BLANK_SPACE;
                     if (relatedsObjects.size() > i) {
                         relatedObjectString = UTIL_ErrorConstants.RELATED_OBJECT + relatedsObjects[i];
                     }
                    String errorMessage = (buildErrorMessageFromErrorList(errors) + relatedObjectString.left(UTIL_ErrorConstants.EXCEPTION_DETAILS_SIZE_LIMIT));
                     String exceptionCode = UTIL_ErrorConstants.BLANK_SPACE;
                     if (errors.size() > 0) {
                         exceptionCode = errors[0].statusCode.name();
                     }
                      currentExceptionObj = exceptionObj.clone(false, true, false, false);
                     currentExceptionObj.Exception_Code__c=exceptionCode;
                     currentExceptionObj.Log_Time__c=System.Now();
                     currentExceptionObj.Exception_Details__c=errorMessage;currentExceptionObj.Related_To_Id__c =  relatedsObjects[i].Id;
                     system.debug(' Related_To_Id__c>>>> '+  relatedsObjects[i].Id);
                     /*exceptionLogList.add(new ExceptionLog__c(Application_Name__c = appName, Exception_Code__c=exceptionCode, 
                                                              Org_Id__c=UserInfo.getOrganizationId(),Class_Name__C =className, Method_Name__c = methodname,
                                                              Username__c = UserInfo.getUserId(), Number_of_Times_Occured__c=1,
                                                              Log_Time__c = System.Now(), Trigger_Name__c=triggerName, 
                                                              Exception_Details__c = errorMessage, Severity__c = level.name(),
                                                              Exception_Type__c = UTIL_ErrorConstants.DML_EXCEPTION, isHandled__c = true));*/
                     exceptionLogList.add(currentExceptionObj);
                 }
             }
         }
         return exceptionLogList;    
     }
     /*
      * @description       This method logs ExceptionLog__c records in case of Exception obtained due to Database.SaveResult
      * @param             deleteResults A List of Database.DeleteResult object records
      * @param             relatedsObjects A List of sObject records which threw the exception when being saved
      * @param             appName the Application Name
      * @param             className the Class Name
      * @param             methodName the Method Name
      * @param             triggerName the Trigger Name
      * @param             level the system.LoggingLevel to determine the exception level
      * @return            List<ExceptionLog__c>
    */
     private static List<ExceptionLog__c> createExceptionsForDeleteResults(List<Database.DeleteResult> deleteResults, 
                                                                           List<sObject> relatedsObjects, String appName, 
                                                                           String className, String methodName, String triggerName, 
                                                                           System.LoggingLevel level) {
         List<ExceptionLog__c> exceptionLogList = new List<ExceptionLog__c>();
         ExceptionLog__c exceptionObj = null;
         if (exceptionLogMeetsSeverityFilter(level.name())){
             exceptionObj = new ExceptionLog__c(Exception_Type__c =UTIL_ErrorConstants.DML_EXCEPTION,
                                                Org_Id__c=UserInfo.getOrganizationId(),Class_Name__C =className, 
                                                Method_Name__c = methodname,Username__c = UserInfo.getUserId(), 
                                                Number_of_Times_Occured__c=1,Application_Name__c = appName,
                                                Severity__c = level.name(),Trigger_Name__c=triggerName,isHandled__c = true);            
             for(integer i = 0; i < deleteResults.size(); ++i) {
                 Database.DeleteResult delResults = deleteResults[i];
                 ExceptionLog__c currentExceptionObj = null;
                 if(!delResults.isSuccess()) {
                     Database.Error[] errors = delResults.getErrors();
                     String relatedObjectString = UTIL_ErrorConstants.BLANK_SPACE;
                     if (relatedsObjects.size() > i) {
                             relatedObjectString = UTIL_ErrorConstants.RELATED_OBJECT + relatedsObjects[i];
                     }
                     String errorMessage = (buildErrorMessageFromErrorList(errors) + 
                                                relatedObjectString.left(UTIL_ErrorConstants.EXCEPTION_DETAILS_SIZE_LIMIT));                    
                     String exceptionCode = UTIL_ErrorConstants.BLANK_SPACE;
                     if (errors.size() > 0){
                         exceptionCode = errors[0].statusCode.name();
                     }
                     currentExceptionObj = exceptionObj.clone(false, true, false, false);
                     currentExceptionObj.Exception_Code__c=exceptionCode;
                     currentExceptionObj.Log_Time__c=System.Now();
                     currentExceptionObj.Exception_Details__c=errorMessage;
                      currentExceptionObj.Related_To_Id__c =  relatedsObjects[i].Id;//added for 17322
                     /*exceptionLogList.add(new ExceptionLog__c(Application_Name__c = appName , Exception_Code__c=exceptionCode, 
                                                              Org_Id__c=UserInfo.getOrganizationId(),Class_Name__c = className, Method_Name__C = methodName,   
                                                              Username__c = UserInfo.getUserId(), Number_of_Times_Occured__c=1,
                                                              Log_Time__c = System.Now(), Trigger_Name__c=triggerName, 
                                                              Exception_Details__c = errorMessage, Severity__c = level.name(),
                                                              Exception_Type__c = UTIL_ErrorConstants.DML_EXCEPTION, isHandled__c = true));*/
                     exceptionLogList.add(currentExceptionObj);
                 }
             }
         }
         return exceptionLogList;
     }
    /*
      * @description       This main method to log ExceptionLog__c records in case of Exception ocurred
      * @param             Exception record captured
      * @param             orgId Current org Id
      * @param             applicationName the Application Name
      * @param             className the Class Name
      * @param             methodName the Method Name
      * @param             triggerName the Trigger Name
      * @param             severity the system.LoggingLevel to determine the exception level
      * @return            void
    */
    public static void logHandledException(Exception excp, String orgID, String applicationName,System.LoggingLevel severity){
        List<ExceptionLog__c> excpLogVal = new List<ExceptionLog__c>();
        String apxErrMsg=buildExceptionDetails(excp);
        String triggerName=UTIL_ErrorConstants.BLANK_SPACE;
        String className=UTIL_ErrorConstants.BLANK_SPACE;
        String methodName=UTIL_ErrorConstants.BLANK_SPACE;
        try{
        if(apxErrMsg.contains(UTIL_ErrorConstants.PREFIX_CLASS)){
            className=apxErrMsg.substring(apxErrMsg.indexOf(UTIL_ErrorConstants.PREFIX_CLASS) + UTIL_ErrorConstants.PREFIX_CLASS.length());
            methodName=className.substring(className.indexOf(UTIL_ErrorConstants.FULLSTOP)+1, className.indexOf(UTIL_ErrorConstants.COLON)).trim();
            className = className.substring(0, className.indexOf(UTIL_ErrorConstants.FULLSTOP)).trim();
        }
        if(apxErrMsg.contains(UTIL_ErrorConstants.PREFIX_TRIGGER)){
            triggerName = apxErrMsg.substring(apxErrMsg.indexOf(UTIL_ErrorConstants.PREFIX_TRIGGER) + UTIL_ErrorConstants.PREFIX_TRIGGER.length());
            triggerName = triggerName.substring(0, triggerName.indexOf(UTIL_ErrorConstants.COLON)).trim();
        }
        ExceptionLog__c exceptionLog = buildExceptionObject(excp, orgID, applicationName, className, methodName, severity, 
                                                            null, null, triggerName, null, null, null, true); 
        
        /*  commented for 17322  
        excpLogVal = mergeExistingErrorLogs(new List<ExceptionLog__c>{exceptionLog});
        
        if(excpLogVal!=null && excpLogVal.size()==1){
            logException(exceptionLog);
        }*/
          logException(exceptionLog);//added for 17322   
        }
         catch(Exception ex){
             logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
         }
    }
    /*
      * @description       This main method to log ExceptionLog__c records in case of Unhandled Exception ocurred
      * @param             email Messaging.InboundEmail reference
      * @return            void
    */
     public static void logUnhandledException(Messaging.InboundEmail email){
         Boolean isSandBoxEmail = false;
         try{
         if((email.subject.contains(UTIL_ErrorConstants.SANDBOX_EMAIL) || email.plainTextBody.contains(UTIL_ErrorConstants.SANDBOX_EMAIL))){
             isSandboxEmail = true;           
         }
         processExceptionEmail(email, isSandboxEmail);
         }
         catch(Exception excp){
             logHandledException(excp, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
         }        
     }
    /*
      * @description       This main method to log ExceptionLog__c records in case of Unhandled Exception ocurred
      * @param             email Messaging.InboundEmail reference, sanbox identification flag
      * @return            void
    */
     private static void processExceptionEmail(Messaging.InboundEmail email, boolean isSandboxEmail){
         String mailSub=UTIL_ErrorConstants.BLANK_SPACE;
         String emailBody = (email.plainTextBody==null || !String.isNotBlank(email.plainTextBody))?email.htmlBody:email.plainTextBody;
         String exceptionName=UTIL_ErrorConstants.BLANK_SPACE;
         String codeSnippet=UTIL_ErrorConstants.BLANK_SPACE;     
         String triggerName=UTIL_ErrorConstants.BLANK_SPACE;
         String className=UTIL_ErrorConstants.BLANK_SPACE;
         String methodName=UTIL_ErrorConstants.BLANK_SPACE;
         String user = UTIL_ErrorConstants.BLANK_SPACE;
         String orgId = UTIL_ErrorConstants.BLANK_SPACE;
         String apexErrMsg = UTIL_ErrorConstants.BLANK_SPACE;   
         
         
         List<ExceptionLog__c> exceptionLogList = new List<ExceptionLog__c>();                 
         ExceptionLog__c exceptionLog = new ExceptionLog__c();
         
            mailSub = mailSubjectVal(email, isSandboxEmail);
             
            codeSnippet = codeSnipVal(mailSub);
            
            exceptionName = exceptionType(mailSub, emailBody);
             
            apexErrMsg = errorMessage(emailBody);
             
            if(apexErrMsg.contains(UTIL_ErrorConstants.PREFIX_CLASS)){
                 className = apexErrMsg.substring(apexErrMsg.indexOf(UTIL_ErrorConstants.PREFIX_CLASS) + UTIL_ErrorConstants.PREFIX_CLASS.length());
                 methodName = className.substring(className.indexOf(UTIL_ErrorConstants.FULLSTOP)+1, className.indexOf(UTIL_ErrorConstants.COLON)).trim();
                 className = className.substring(0, className.indexOf(UTIL_ErrorConstants.FULLSTOP)).trim();
             }
             
            if(apexErrMsg.contains(UTIL_ErrorConstants.PREFIX_TRIGGER)){
                 triggerName = apexErrMsg.substring(apexErrMsg.indexOf(UTIL_ErrorConstants.PREFIX_TRIGGER) + UTIL_ErrorConstants.PREFIX_TRIGGER.length());
                 triggerName = triggerName.substring(0, triggerName.indexOf(UTIL_ErrorConstants.COLON)).trim();
             }
             
            if(apexErrMsg.contains(UTIL_ErrorConstants.USER)){
                 user = apexErrMsg.subString(apexErrMsg.indexOf(UTIL_ErrorConstants.USER)+UTIL_ErrorConstants.USER.length());
                 String userId = user.subString(user.indexOf(UTIL_ErrorConstants.COLON)+1,user.indexOf(UTIL_ErrorConstants.FORWARD_SLASH)).trim();
                 orgId = user.subString(user.indexOf(UTIL_ErrorConstants.FORWARD_SLASH)+1,user.indexOf(UTIL_ErrorConstants.FORWARD_SLASH)+userId.length()+1).trim();
                 user = userId;
             }
             if(apexErrMsg.contains(UTIL_ErrorConstants.FLOW_ORG) && apexErrMsg.contains(UTIL_ErrorConstants.FLOW_DETAILS)){
                 String org = apexErrMsg.subString(apexErrMsg.indexOf(UTIL_ErrorConstants.FLOW_ORG)+UTIL_ErrorConstants.FLOW_ORG.length());
                 orgId = org.subString(org.indexOf(UTIL_ErrorConstants.BRAKET_OPENING)+1,org.indexOf(UTIL_ErrorConstants.BRAKET_CLOSING)).trim();
                 String userId = apexErrMsg.subString(apexErrMsg.indexOf(UTIL_ErrorConstants.CURRENT_USER)+UTIL_ErrorConstants.CURRENT_USER.length());
                 user = userId.subString(userId.indexOf(UTIL_ErrorConstants.BRAKET_OPENING)+1,userId.indexOf(UTIL_ErrorConstants.BRAKET_CLOSING)).trim();
             }
             exceptionLog = buildExceptionObject(null, orgId, null, className, methodName, null, apexErrMsg, exceptionName, triggerName,
                                                    UTIL_ErrorConstants.SEVERITY_LEVEL_ERROR , 
                                                    user, codeSnippet,  false);  
             /* commented for 17322   
             exceptionLogList = mergeExistingErrorLogs(new List<ExceptionLog__c>{exceptionLog});
             
             if(exceptionLogList!=null && exceptionLogList.size()==1){  
                 logException(exceptionLog);
             } */ 
          logException(exceptionLog);//added for 17322
         
     }
    /*
      * @description       This main method to extract subject value of received exception email with proper parameters
      * @param             email Messaging.InboundEmail reference, sanbox identification flag
      * @return            String
    */
    private static String mailSubjectVal(Messaging.InboundEmail email, boolean isSandboxEmail){
        String mailSub = UTIL_ErrorConstants.BLANK_SPACE;
        if(email.subject.toLowerCase().startsWith(UTIL_ErrorConstants.PREFIX_FW)){
             mailSub = email.subject.substring(UTIL_ErrorConstants.PREFIX_FW.length());
         }
         else if(email.subject.toLowerCase().startsWith(UTIL_ErrorConstants.PREFIX_FWD)){
             mailSub = email.subject.substring(UTIL_ErrorConstants.PREFIX_FWD.length());
         }
         else if(email.subject.toLowerCase().startsWith(UTIL_ErrorConstants.PREFIX_RE)){
             mailSub = email.subject.substring(UTIL_ErrorConstants.PREFIX_RE.length());
         }
         else{
             mailSub = email.subject;
         }
        if(isSandboxEmail){
             mailSub = mailSub.substring(mailSub.indexOf(UTIL_ErrorConstants.SANDBOX_EMAIL) + UTIL_ErrorConstants.SANDBOX_EMAIL.length() + 1, 
                                                         mailSub.length());
         }
         return mailSub;
     }
     /*
      * @description       This method to extract Code Snippet value of received exception email with proper parameters from mail subject
      * @param             Subject of email
      * @return            String
    */
    private static String codeSnipVal(String mailSub){
         String codeSnippet = UTIL_ErrorConstants.BLANK_SPACE;
         codeSnippet = mailSub.substring(mailSub.indexOf(UTIL_ErrorConstants.COLON) + 1, mailSub.length());
         codeSnippet = codeSnippet.substring(codeSnippet.indexOf(UTIL_ErrorConstants.COLON)+1, codeSnippet.length()).trim();        
         return codeSnippet;
     }
    /*
      * @description       This method to extract Exception type from received exception email with proper parameters from mail subject
      * @param             Subject of email, email body
      * @return            String
    */
     private static String exceptionType(String mailSub, String emailBody){
        String exceptionName = UTIL_ErrorConstants.BLANK_SPACE;
        if(mailSub.contains(UTIL_ErrorConstants.CAUSED_BY)){       
             exceptionName = mailSub.substring(mailSub.indexOf(UTIL_ErrorConstants.CAUSED_BY) + UTIL_ErrorConstants.CAUSED_BY.length(), mailSub.length());
             exceptionName = exceptionName.substring(0, exceptionName.indexOf(UTIL_ErrorConstants.COLON));
         }
         else if(mailSub.contains(UTIL_ErrorConstants.FLOW_ERROR)){            
             exceptionName = mailSub.substring(mailSub.indexOf(UTIL_ErrorConstants.FLOW_ERROR) + UTIL_ErrorConstants.FLOW_ERROR.length(), mailSub.length());
             exceptionName = UTIL_ErrorConstants.FLOW_EXCEPTION + UTIL_ErrorConstants.EXCEPTION_NAME_SEPARATOR + exceptionName.substring(0, exceptionName.indexOf(UTIL_ErrorConstants.COLON));
         }
         else if(emailBody.contains(UTIL_ErrorConstants.CAUSED_BY)){            
             exceptionName = emailBody.substring(emailBody.indexOf(UTIL_ErrorConstants.CAUSED_BY) + UTIL_ErrorConstants.CAUSED_BY.length(), emailBody.length());
             exceptionName = exceptionName.substring(0, exceptionName.indexOf(UTIL_ErrorConstants.COLON));
         }
		 else{
            exceptionName = UTIL_ErrorConstants.OTHER_EXCEPTION;
         }
         exceptionName = exceptionName.trim();
         return exceptionName;
     }

    /*
      * @description       This method to extract error message from received exception email with proper parameters from mail subject
      * @param             email body
      * @return            String
    */
     private static String errorMessage(String emailBody){
        String apexErrMsg = UTIL_ErrorConstants.BLANK_SPACE;
        if(emailBody.contains(UTIL_ErrorConstants.START_APEX_SCRIPT) && !emailBody.contains(UTIL_ErrorConstants.SANDBOX_EMAIL)){ 
            apexErrMsg = emailBody.substring(emailBody.indexOf(UTIL_ErrorConstants.START_APEX_SCRIPT)); 
         }
         else if(emailBody.contains(UTIL_ErrorConstants.START_APEX_SCRIPT) && emailBody.contains(UTIL_ErrorConstants.SANDBOX_EMAIL)){
             apexErrMsg = emailBody.substring(emailBody.indexOf(UTIL_ErrorConstants.SANDBOX_EMAIL)); 
         }
         else {
             apexErrMsg = emailBody;
         }
         apexErrMsg = apexErrMsg.left(UTIL_ErrorConstants.EXCEPTION_DETAILS_SIZE_LIMIT);
         return apexErrMsg;
     }
    /*
      * @description       This main method to log ExceptionLog__c records in case of Web Service Exception ocurred
      * @param             excp record captured
      * @param             orgId Current org Id
      * @param             applicationName the Application Name
      * @param             className the Class Name
      * @param             methodName the Method Name
      * @param             triggerName the Trigger Name
      * @param             severity the system.LoggingLevel to determine the exception level
      * @param             ws_application web-service calling application
      * @param             ws_callingClass web-service calling area
      * @param             ws_transactionID web-service transaction id
      * @param             handled handled/Unhandled exception identifier
      * @return            void
    */
     public static void logWebServiceException (Exception excp, String orgID, String applicationName, String className, 
                                             String methodName, String triggerName, System.LoggingLevel severity, String ws_application, 
                                             String ws_callingClass, String ws_transactionID, Boolean handled){
        
        List<ExceptionLog__c> filteredRecords = new List<ExceptionLog__c>();
        
        ExceptionLog__c exceptionLog = buildExceptionObject(excp, orgID, applicationName, className, methodName, severity,
                                                            null, null, triggerName, null, null, null, handled);
        exceptionLog.WS_CallingApplication__c = ws_application;
        exceptionLog.WS_CallingClass__c = ws_callingClass;
        exceptionLog.WS_TransactionID__c = ws_transactionID;
        try{
        /*   commented for 17322 
        filteredRecords = mergeExistingErrorLogs(new List<ExceptionLog__c>{exceptionLog});
        
        if(filteredRecords!=null && filteredRecords.size()==1){            
            logException(exceptionLog);
        }*/
         logException(exceptionLog);//added for 17322   
        }
         catch(Exception ex){
             logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
         }
    }
    /*
      * @description       This method increment the execution counter in case of same exception and update previous exception record
      * @param             exceptionLogList structured new ExceptionLog record
      * @return            List<ExceptionLog__c>
    */
    
    /*
    private static List<ExceptionLog__c> mergeExistingErrorLogs(List<ExceptionLog__c> exceptionLogList){        
         String lineColumn = UTIL_ErrorConstants.BLANK_SPACE;
         List<String> exceptionType = new List<String>();
         List<String> exceptionClass = new List<String>();
         List<String> exceptionMethod = new List<String>();                
         List<ExceptionLog__c> existingExcpLogs = new List<ExceptionLog__c>();
         List<ExceptionLog__c> exceptionLogToBeUpdated = new List<ExceptionLog__c>();
         List<ExceptionLog__c> exceptionLogToBeInserted = new List<ExceptionLog__c>();
         Map<string, List<ExceptionLog__c>> exceptionMap = new Map<string, List<ExceptionLog__c>>();
         Set<ExceptionLog__c> logList = new Set<ExceptionLog__c>();
         for(ExceptionLog__c excp: exceptionLogList){
             exceptionType.add(excp.Exception_Type__c);
             exceptionClass.add(excp.Class_Name__c);
             exceptionMethod.add(excp.Method_Name__c);
         }
        for(ExceptionLog__c  exExcp : [SELECT Id, Name, Trigger_Name__c, Method_Name__c, Class_Name__c, Exception_Details__c, Log_Time__c, 
                                        Number_of_Times_Occured__c, Username__c, WS_CallingApplication__c, WS_CallingClass__c, WS_TransactionID__c, 
										Exception_Type__c,Previous_Occurrence_Log__c FROM ExceptionLog__c WHERE Exception_Type__c IN: exceptionType
										AND Class_Name__c IN: exceptionClass AND Method_Name__c IN: exceptionMethod LIMIT 49999]){
			existingExcpLogs = new List<ExceptionLog__c>();
			if (exceptionMap.containsKey(exExcp.Exception_Type__c+exExcp.Class_Name__c+exExcp.Method_Name__c)) {
				List<ExceptionLog__c> excepLst = exceptionMap.get(exExcp.Exception_Type__c+exExcp.Class_Name__c+exExcp.Method_Name__c);
				excepLst.add(exExcp);
				exceptionMap.put(exExcp.Exception_Type__c+exExcp.Class_Name__c+exExcp.Method_Name__c, excepLst);
			}
		}
         for(ExceptionLog__c excp: exceptionLogList){
             existingExcpLogs = new List<ExceptionLog__c>();
             if(String.isNotBlank(excp.Exception_Details__c) && excp.Exception_Details__c.contains(UTIL_ErrorConstants.LINE_NO) && excp.Exception_Details__c.contains(UTIL_ErrorConstants.COLUMN)){
                 lineColumn = excp.Exception_Details__c.substring(0, excp.Exception_Details__c.IndexOf(UTIL_ErrorConstants.COLUMN));
             }
             else{
                 lineColumn = excp.Exception_Details__c;
             }
             if(exceptionMap.containsKey(excp.Exception_Type__c+excp.Class_Name__c+excp.Method_Name__c)){
				existingExcpLogs.add(excp); 
			 } 
             logMergeException(existingExcpLogs, lineColumn, excp, exceptionLogToBeUpdated, exceptionLogToBeInserted );
         }
         if(!exceptionLogToBeupdated.isEmpty()){            
             logList.addAll(exceptionLogToBeupdated);
             exceptionLogToBeupdated.clear();
             exceptionLogToBeupdated.addAll(logList);
             Database.saveResult[] svRes = Database.update(exceptionLogToBeupdated, false);
             UTIL_LoggingService.logDmlResults(svRes, null, exceptionLogToBeupdated, UTIL_ErrorConstants.ERROR_APPLICATION, UTIL_ErrorConstants.ERROR_LOG_CLASS, UTIL_ErrorConstants.FRAMEWORK_MERGE_METHOD, null, LoggingLevel.ERROR);
            }
		return exceptionLogToBeInserted;
     }
    */
    
    /*
      * @description       This method checks for merge conditions and update required ExceptionLog list for update/insert record
      * @param             existingErrorLogs existing ExceptionLog record
      * @param             lineColumn error details without line no.
      * @param             newExcp newly captured exception
      * @param             exceptionLogToBeUpdated list to be updated incase of repetative exception
      * @param             exceptionLogToBeInserted list to be updated incase of new exception
      * @return            void
    */
    
    /*
     private static void logMergeException(List<ExceptionLog__c> existingErrorLogs, String lineColumn, ExceptionLog__c newExcp,
                                           List<ExceptionLog__c> exceptionLogToBeUpdated, List<ExceptionLog__c> exceptionLogToBeInserted ){
         
        String excpDetails = UTIL_ErrorConstants.BLANK_SPACE;
        
        for(ExceptionLog__c existingLog : existingErrorLogs) {
             
             if(String.isNotBlank(existingLog.Exception_Details__c) && existingLog.Exception_Details__c.contains(UTIL_ErrorConstants.LINE_NO) && existingLog.Exception_Details__c.contains(UTIL_ErrorConstants.COLUMN)){
                 excpDetails = existingLog.Exception_Details__c.substring(0, existingLog.Exception_Details__c.IndexOf(UTIL_ErrorConstants.COLUMN));
             }
             else{
                 excpDetails = existingLog.Exception_Details__c;
             }
             
             if(String.isNotBlank(excpDetails) && excpDetails.trim().equalsIgnoreCase(lineColumn.trim()) &&
                String.isNotBlank(existingLog.Username__c) && (existingLog.Username__c == newExcp.Username__c) &&
                (existingLog.Log_Time__c != null) && (existingLog.Log_Time__c.date() == (System.now()).date())  && (
               ((String.isNotBlank(existingLog.Class_Name__c) && existingLog.Class_Name__c.equalsIgnoreCase(newExcp.Class_Name__c)) &&
                (String.isNotBlank(existingLog.Method_Name__c) && existingLog.Method_Name__c.equalsIgnoreCase(newExcp.Method_Name__c))) ||
                (String.isNotBlank(existingLog.Trigger_Name__c) && existingLog.Trigger_Name__c.equalsIgnoreCase(newExcp.Trigger_Name__c))) ||
                ((String.isNotBlank(existingLog.WS_CallingApplication__c) && existingLog.Class_Name__c.equalsIgnoreCase(newExcp.WS_CallingApplication__c)) && 
                 (String.isNotBlank(existingLog.WS_CallingClass__c) && existingLog.Class_Name__c.equalsIgnoreCase(newExcp.WS_CallingClass__c)))){
                 
                 existingLog.Exception_Details__c = newExcp.Exception_Details__c ;
                 existingLog.Previous_Occurrence_Log__c = (existingLog.Previous_Occurrence_Log__c== null?UTIL_ErrorConstants.BLANK_SPACE:(existingLog.Previous_Occurrence_Log__c+UTIL_ErrorConstants.COMMA)) +UTIL_ErrorConstants.ENTER +UTIL_ErrorConstants.OCCURRENCE_KEYWORD+ existingLog.Number_of_Times_Occured__c+UTIL_ErrorConstants.SPACE+UTIL_ErrorConstants.COLON+UTIL_ErrorConstants.SPACE+existingLog.Log_Time__c;               
                 existingLog.Number_of_Times_Occured__c = (existingLog.Number_of_Times_Occured__c == null?1:existingLog.Number_of_Times_Occured__c) + 1;
                 existingLog.Log_Time__c = System.Now();
                 existingLog.Username__c = newExcp.Username__c;
                 existingLog.WS_TransactionID__c = newExcp.WS_TransactionID__c ;
                 exceptionLogToBeUpdated.add(existingLog);                 
             }               
         } 
                
         if(exceptionLogToBeUpdated.isEmpty()){ 
             exceptionLogToBeInserted.add(newExcp);
         } 
     }
    
    */
    
    /*
      * @description       This method is used to insert ExceptionLog__c object into database ( Single record)
      * @param             ExceptionLog__c
      * @return            void
    */
    private static void logException(ExceptionLog__c exceptionLog){
        if(exceptionLogMeetsSeverityFilter(exceptionLog.severity__c)) {
            Database.insert(exceptionLog,true);
         }
     }
    /*
      * @description       This method is used to insert ExceptionLog__c objects into database ( Multiple record)
      * @param             List<ExceptionLog__c>
      * @return            void
    */
    private static void logException(List<ExceptionLog__c> exceptionLogList){
        List<ExceptionLog__c> exceptionLogsMeetsSeverity = new List<ExceptionLog__c>();
        for(ExceptionLog__c excp : exceptionLogList){
		if(exceptionLogMeetsSeverityFilter(excp.severity__c)) {
			exceptionLogsMeetsSeverity.add(excp);
         }
        }
        if(!exceptionLogsMeetsSeverity.isEmpty()){
        	Database.saveResult[] svRes = Database.insert(exceptionLogsMeetsSeverity, false);
            UTIL_LoggingService.logDmlResults(svRes, null, exceptionLogsMeetsSeverity, UTIL_ErrorConstants.ERROR_APPLICATION, UTIL_ErrorConstants.ERROR_LOG_CLASS, UTIL_ErrorConstants.FRAMEWORK_LOG_METHOD, null, LoggingLevel.ERROR);
        }
     }
    /*
      * @description       This method is used to check severity level of captured Exception
      * @param             Severity level String value
      * @return            Boolean
    */
     private static boolean exceptionLogMeetsSeverityFilter(String severity) {
         boolean result = false;
         if(severity != null) {
             if(severity.equalsIgnoreCase(ExceptionLog_Settings__c.getOrgDefaults().Logging_Level__c)){
                result = true;
             }
         }       
         return result;
     }
   /*
    * @vendor			 TCS
    * @story		   	 SDT-26174
    * @description       This method is used to insert the list of ExceptionLog__c record by STPRuleExecution class only for audit logs without severity level.  
    * @param             list of Exception_Details__c
    * @return            void
    */
    public static void logExceptionObject(List<ExceptionLog__c> exceptionLog){
        try{
        	Database.insert(exceptionLog);
        }catch(Exception ex){
            logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION, LoggingLevel.ERROR);
	
        }
    }

    //Changes related to SDT-48086
    /*
    * @vendor		 TCS
    * @story		 SDT-48086
    * @description       This method is used to create Exception logs for Confirm Configuration flow.  
    * @param             Exception - Exception object,orgID - Organization Id, apploricationName (Confirm Configuration),
    			 severity,className,methodname,triggerName
    * @return            void
    */
    public static void logHandledExceptionWithClass(Exception excp, String orgId, String applicationName,System.LoggingLevel severity, String  className,String methodname,String triggerName)
    {
         ExceptionLog__c exceptionLog = buildExceptionObject(excp, orgId, applicationName, className, methodName, severity, 
                                                            null, null, triggerName, null, null, null, true);
                                                            logException(exceptionLog);
    }

    
    
}
