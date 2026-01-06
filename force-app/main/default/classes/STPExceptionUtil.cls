/**
 * @description       : Implement exception handling method related to Automated Step by Step STP approval
 * @vendor			  :	TCS
 * @reference		  : PriceOnlyRequestSTPProcess.apxc
 * @last modified on  : 10-07-2023
 * @last modified by  : Digdershika Ojha
**/
public class STPExceptionUtil {
	/*
     * @Method Name    : createExceptionLogObj
     * @story		   : SDT - 31289
     * @description    : creates an object of ExceptionLog__c with details specific to functionality and STPRuleExecutionClass with no severity
     * @param		   : exceptionLog of type ExceptionLog__c
	 * @return         : ExceptionLog__c
     */
    
    public static ExceptionLog__c createExceptionLogObj(ExceptionLog__c exceptionLog){
        
        ExceptionLog__c exceptionLogObj = exceptionLog;
		exceptionLogObj.Org_Id__c = UserInfo.getOrganizationId();
		exceptionLogObj.Exception_Code__c = '';
		exceptionLogObj.Exception_Description__c =  UTIL_ErrorConstants.EXECPTION_DESCRIPTION;
		exceptionLogObj.Log_Time__c = System.now();
		exceptionLogObj.Username__c = UserInfo.getUserId();
		return exceptionLogObj;
    }
    
    /*@methodName- setStepByStepExceptionObj
    *@description- create exception log entries for step by step process.
    *@param- Id : methodName,appName,details
    *@return- void
    */ 
    public static void setStepByStepExceptionObj(String methodName, String appName, String details){
        ExceptionLog__c exceptionLog = new ExceptionLog__c();
            exceptionLog.Class_Name__c = UTIL_ErrorConstants.STEP_STP_CLASS_NAME;
            exceptionLog.Method_Name__c = methodName;
            exceptionLog.Application_Name__c = appName;
        
            exceptionLog.Exception_Details__c = details;
            exceptionLog.Exception_Type__c = UTIL_ErrorConstants.STEP_STP_EXCEPTION_TYPE;
        ExceptionLog__c logObj = createExceptionLogObj(exceptionLog);
        UTIL_LoggingService.logExceptionObject(new List<ExceptionLog__c>{logObj});
    }
}