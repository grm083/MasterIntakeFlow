/*
* @Name          STPExceptionUtilTest
* @Author        Digdershika Ojha
* @Vendor		 TCS
* @Date          25/07/2023
* @description	  This class test STPExceptionUtil, initially created for story SDT-31298
*/
@isTest (SeeAllData = FALSE)
public class STPExceptionUtilTest {
    
    public static final string SYS_ADMIN = 'System Administrator';
    
    @testSetup
    public static void setup(){
        Profile adminProfile = TestDataFactory.getProfile(SYS_ADMIN);
        User usr = TestDataFactory.createUser(adminProfile);
        Database.insert(usr); 
        
        System.runAs(usr){
            ExceptionLog__c exceptionLogObj = new ExceptionLog__c();
            exceptionLogObj.Method_Name__c = 'setup';
            exceptionLogObj.Application_Name__c = 'appName';
            exceptionLogObj.Exception_Details__c = 'Test details';
            exceptionLogObj.Class_Name__c = 'Test class';
            exceptionLogObj.Exception_Type__c = 'Test Exception Type';
            insert exceptionLogObj;
        }
    }
	/*
	 * @MethodName    testCreateExceptionLogObj
	 * @description	  This method will be used to test createExceptionLogObj creation of ExceptionLog__c object
	 * @return		  void
	 */
    @isTest
    public static void testCreateExceptionLogObj(){
        ExceptionLog__c exceptionLogObj = [SELECT Id, Exception_Details__c from ExceptionLog__c where Application_Name__c like 'appName'];
        ExceptionLog__c exceptionLog = STPExceptionUtil.createExceptionLogObj(exceptionLogObj);
        //system.assertEquals( UTIL_ErrorConstants.EXECPTION_DESCRIPTION,exceptionLog.Exception_Description__c,'Expected ' + UTIL_ErrorConstants.EXECPTION_DESCRIPTION);
    }
    /*
	 * @MethodName    testSetStepByStepExceptionObj
	 * @description	  This method will be used to test setting parameters for ExceptionLog__c and its database insertion 
	 * @return		  void
	 */
    @isTest
    public static void testSetStepByStepExceptionObj(){
        String methodName = 'testSetStepByStepExceptionObj';
        STPExceptionUtil.setStepByStepExceptionObj(methodName,'appName','Details');
        ExceptionLog__c exceptionLog = [SELECT Id, Method_Name__c from ExceptionLog__c where Method_Name__c =: methodName];
        //system.assertEquals( methodName ,exceptionLog.Method_Name__c,'Expected testSetStepByStepExceptionObj');
    }
}