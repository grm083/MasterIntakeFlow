@isTest
public class UTIL_LoggingServiceTest {
    
	private static final String SYSTEM_ADMIN = 'System Administrator';
    private static final String TEST_EMAIL = 'test@testapex.com';
    private static final String CLASS_ONE = 'CreateApexErrorLog';
    private static final String SUBJECT_ONE =  'Fwd: Force.com Sandbox: script exception from Accenture : '+
                                               'CreateApexErrorLog : Attempted to schedule too '+ 
                                               'many concurrent batch jobs in this org (limit is 5)';                                                
    private static final String BODY_ONE_A =  'Apex script unhandled exception by user/organization: ';
    private static final String BODY_ONE_B = ' /00D90000000fOLB caused by: System.Exception: Attempted to schedule too'+
                                            ' many concurrent batch jobs '+ 
                                            'Class.CreateApexErrorLog.execute: Debug Log: Starts';
    private static final String SUBJECT_TWO = 'Error Ocurred During Flow "Test":';
    private static final String SUBJECT_EXCP = 'Error Ocurred During Flow "EXCEPTION"';
    private static final String BODY_TWO_A = 'Apex script unhandled exception by user/organization: ';
    private static final String BODY_TWO_B = '/00D90000000fOLB Visualforce Page: /apex/flowfinishsecpage '+
                                             'caused by: System.NullPointerException: Attempt to de-reference a null object '+
                                             'Class.CreateApexErrorLog.dataSplit: line 132, column 1,Trigger.TestTrigger:';
    private static final String TEST_ORG_ID = 'TestOrgId';
    private static final String TEST_APP = 'TestApp';
    private static final String TEST_CLASS = 'UTIL_LoggingServiceTest';
    private static final String TEST_METHOD = 'TestMethod';
    private static final String TEST_ACCOUNT = 'Test Account';
    
    
    @testSetup static void setup() {
        Profile p = TestDataFactory.getProfile(SYSTEM_ADMIN);
        User usr = TestDataFactory.createUser(p);
        usr.bypass_validation__c = true;
        Database.insert(usr);
        ExceptionLog_Settings__c logLevel = ExceptionLog_Settings__c.getInstance(UserInfo.getOrganizationId());
        logLevel.Logging_Level__c=UTIL_ErrorConstants.SEVERITY_LEVEL_ERROR;
        insert logLevel;
    }
    
    private static Messaging.InboundEmail emailData(String subject, String body){
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.subject = subject;
        email.plainTextBody = body;
        email.fromAddress = TEST_EMAIL;
        return email;
    }
    
	private static testMethod void unhandledException(){
        //test class errors - SDT - 33363
        User currentuser = [Select id,isActive from User WHERE isActive = TRUE AND Profile.Name = :SYSTEM_ADMIN limit 1];
		String subject1 = SUBJECT_ONE;
        String body1 = UTIL_ErrorConstants.START_APEX_SCRIPT + UTIL_ErrorConstants.SANDBOX_EMAIL + BODY_ONE_A + currentuser.Id + BODY_ONE_B;
                      
        Messaging.InboundEmail email1 = emailData(subject1, body1); 

		String subject2 = SUBJECT_TWO;
        String body2 = UTIL_ErrorConstants.START_APEX_SCRIPT + UTIL_ErrorConstants.SANDBOX_EMAIL + BODY_TWO_A + currentuser.Id + BODY_TWO_B;
          
        String subjectException = SUBJECT_EXCP;
        Messaging.InboundEmail email2 = emailData(subject2, body2);         
        Messaging.InboundEmail email3 = emailData(subjectException, body2);
        Test.startTest();
        System.runAs(currentuser){
           UTIL_LoggingService.logUnhandledException(email1);
           UTIL_LoggingService.logUnhandledException(email2);
           UTIL_LoggingService.logUnhandledException(email3);
        }
        Test.stopTest();
        
        List<ExceptionLog__c> excpDataList = [SELECT Id, Class_Name__c FROM ExceptionLog__c WHERE Class_Name__c=:CLASS_ONE]; 
        System.assertEquals(excpDataList.size(), 2);
        System.assertEquals(excpDataList[0].Class_Name__c, CLASS_ONE);
    }
    private static testMethod void handledException(){
        //test class errors - SDT - 33363
        User currentuser = [Select id,isActive from User WHERE isActive = TRUE AND Profile.Name = :SYSTEM_ADMIN limit 1];
		try{
            Account testData = new Account();
            insert(testData);           
        }
        catch(DMLException excp){        
            Test.startTest();
            System.runAs(currentuser){
               UTIL_LoggingService.logHandledException(excp, TEST_ORG_ID, TEST_APP, LoggingLevel.ERROR);
            }
            Test.stopTest();
        }
        ExceptionLog__c excpData = [SELECT Class_Name__c, Severity__c FROM ExceptionLog__c WHERE Application_Name__c=:TEST_APP]; 
        System.assertEquals(excpData.Class_Name__c, TEST_CLASS);
    }
    
    private static testMethod void handledExceptionMerge(){
        //test class errors - SDT - 33363
        User currentuser = [Select id,isActive from User WHERE isActive = TRUE AND Profile.Name = :SYSTEM_ADMIN limit 1];
        try{
            Account testData1 = new Account();
            insert(testData1);           
        }
        catch(DMLException excp){                    
            try{
                Account testData2 = new Account();
                //Account testData3 = new Account();
                insert(testData2);//insert(testData3);           
            }
            catch(DMLException dmlExcp){
                Test.startTest();
                System.runAs(currentuser){
                   UTIL_LoggingService.logHandledException(excp, TEST_ORG_ID, TEST_APP,  LoggingLevel.ERROR);
                   UTIL_LoggingService.logHandledException(dmlExcp, TEST_ORG_ID, TEST_APP, LoggingLevel.ERROR);
                   UTIL_LoggingService.logHandledException(dmlExcp, TEST_ORG_ID, TEST_APP, LoggingLevel.ERROR);
                }
                Test.stopTest();
            }
        }
        List<ExceptionLog__c> excpData = [SELECT Number_Of_Times_Occured__c FROM ExceptionLog__c WHERE Application_Name__c=:TEST_APP]; 
        System.assertEquals(excpData.size(), 3);
    }
    
     private static testMethod void handledExceptionSave(){
        //test class errors - SDT - 33363
        User currentuser = [Select id,isActive from User WHERE isActive = TRUE AND Profile.Name = :SYSTEM_ADMIN limit 1];
        List<Account> accList = new List<Account>();
        Account accData1= new Account(Name = TEST_ACCOUNT);
        Account accData2= new Account();
        accList.add(accData1);
        accList.add(accData2);
        Database.SaveResult[] svRes = Database.insert(accList, false);          
                
        Test.startTest();
        System.runAs(currentuser){
           UTIL_LoggingService.logDmlResults(svRes, null, accList, TEST_APP, TEST_CLASS, TEST_METHOD, null, LoggingLevel.ERROR);
        }
        Test.stopTest();
        
        ExceptionLog__c excpData = [SELECT Class_Name__c, Severity__c FROM ExceptionLog__c WHERE Application_Name__c=:TEST_APP]; 
        System.assertEquals(excpData.Class_Name__c, TEST_CLASS);
        Integer noOfExcep = [SELECT COUNT() FROM ExceptionLog__c WHERE Application_Name__c=:TEST_APP];
        System.assertEquals(noOfExcep, 1);
    }
    private static testMethod void handledExceptionDelete(){
        //test class errors - SDT - 33363
        User currentuser = [Select id,isActive from User WHERE isActive = TRUE AND Profile.Name = :SYSTEM_ADMIN limit 1];
        List<Account> accList = new List<Account>();
        Account accData1= new Account(Name = TEST_ACCOUNT);
        Account accData2= new Account(Name = TEST_ACCOUNT+1);
        accList.add(accData1);
        accList.add(accData2);
        insert accList;
        delete accList;
        Database.DeleteResult[] delRes = Database.delete(accList, false);            
                
        Test.startTest();
        System.runAs(currentuser){
           UTIL_LoggingService.logDmlResults(null, delRes, accList, TEST_APP, TEST_CLASS, TEST_METHOD, null, LoggingLevel.ERROR);
        }
        Test.stopTest();
        
        List<ExceptionLog__c> excpData = [SELECT Class_Name__c, Severity__c FROM ExceptionLog__c WHERE Application_Name__c=:TEST_APP]; 
        System.assertEquals(excpData[0].Class_Name__c, TEST_CLASS);
        Integer noOfExcep = [SELECT COUNT() FROM ExceptionLog__c WHERE Application_Name__c=:TEST_APP];
        System.assertEquals(noOfExcep, 2);
    }
    
    private static testMethod void handledExceptionSaveMerge(){
        //test class errors - SDT - 33363
        User currentuser = [Select id,isActive from User WHERE isActive = TRUE AND Profile.Name = :SYSTEM_ADMIN limit 1];
        List<Account> accList1 = new List<Account>();
        List<Account> accList2 = new List<Account>();
        
        Account accData1= new Account(Name = TEST_ACCOUNT );
        Account accData2= new Account();
        Account accData4= new Account();
        Account accData3= new Account(Name = TEST_ACCOUNT+1 );
		accList2.add(accData3);
        accList2.add(accData2);
        accList2.add(accData4);
        //Database.SaveResult[] svRes1 = Database.insert(accList1, false);   
        Database.SaveResult[] svRes2 = Database.insert(accList2, false);                        
        Test.startTest();
        System.runAs(currentuser){
			UTIL_LoggingService.logDmlResults(svRes2, null, accList2, TEST_APP, TEST_CLASS, TEST_METHOD, null, LoggingLevel.ERROR);
        }
        Test.stopTest();
        
        ExceptionLog__c excpData = [SELECT Number_Of_Times_Occured__c FROM ExceptionLog__c WHERE Application_Name__c=:TEST_APP]; 
        System.assertEquals(excpData.Number_Of_Times_Occured__c, 2);
    }
    
    private static testMethod void logHandledServiceException(){
        //test class errors - SDT - 33363
        User currentuser = [Select id,isActive from User WHERE isActive = TRUE AND Profile.Name = :SYSTEM_ADMIN limit 1];
         try{
             Account testData = new Account();
             insert(testData);           
         }
         catch(Exception excp){        
             Test.startTest();
             System.runAs(currentuser){
                UTIL_LoggingService.logWebServiceException(excp, TEST_ORG_ID, TEST_APP, TEST_CLASS, TEST_METHOD, null, LoggingLevel.ERROR, TEST_APP, TEST_CLASS, TEST_APP+1, true);
             }
             Test.stopTest();
         }
         ExceptionLog__c excpData = [SELECT Class_Name__c, Severity__c FROM ExceptionLog__c WHERE Application_Name__c=:TEST_APP]; 
         System.assertEquals(excpData.Class_Name__c, TEST_CLASS);
    }
    /*
     * @Method Name    : logExceptionObjectTest
     * @author         : Digdershika Ojha
     * @vendor		   : TCS
     * @story		   : SDT-26174
     * @description    : test insertion of ExceptionLog__c object for general purpose info with no severity
     * @return         : void
     */
    private static testMethod void logExceptionObjectTest(){
        Profile p = TestDataFactory.getProfile('System Administrator');
        User currentuser = TestDataFactory.createUser(p);
		List<ExceptionLog__c> logObjList = new List<ExceptionLog__c>();
        String exceptionType = 'UTIL_LoggingServiceTest';
        Database.insert(currentuser);
        system.runAs(currentuser){
            Test.startTest();
			ExceptionLog__c logObj = new ExceptionLog__c();
			logObj.Exception_Type__c = exceptionType;
			logObjList.add(logObj);
            UTIL_LoggingService.logExceptionObject(logObjList);
            ExceptionLog__c exceptionLog = [SELECT Exception_Type__c FROM ExceptionLog__c WHERE Exception_Type__c=:exceptionType];
            //System.assertEquals(exceptionLog.Exception_Type__c, exceptionType);
            Test.stopTest();
        }
    }

}