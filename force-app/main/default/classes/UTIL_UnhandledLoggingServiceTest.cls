@isTest
public class UTIL_UnhandledLoggingServiceTest {
    
    private static final String SYSTEM_ADMIN = 'System Administrator';
    private static final String TEST_EMAIL = 'automation@testapex.com';
    private static final String CLASS_NAME = 'CreateApexErrorLog';
    private static final String SUBJECT_DATA =  'Fwd: Force.com Sandbox: script exception from Accenture : '+
                                                'TestErrTrig : Attempted to schedule too '+ 
                                                'many concurrent batch jobs in this org (limit is 5)';                                                
    private static final String BODY_DATA_A = 'Apex script unhandled exception by user/organization: ';
    private static final String BODY_DATA_B =  '/00D90000000fOLB unhandled caused by: System.Exception: Attempted to schedule too'+
                                               ' many concurrent batch jobs '+ 
                                               'Class.CreateApexErrorLog.execute: Debug Log: Starts';
    
    @testSetup static void setup() {
        Profile p = TestDataFactory.getProfile(SYSTEM_ADMIN);
        User usr = TestDataFactory.createUser(p);
        usr.bypass_validation__c = true;
//test class errors - SDT - 33363
        usr.LastName = 'AdminUserForTest';
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
        User currentuser = [select id, Bypass_Validation__c,isActive from user WHERE isActive = TRUE AND LastName = 'AdminUserForTest' LIMIT 1];
        String subject = SUBJECT_DATA;
        String body = UTIL_ErrorConstants.START_APEX_SCRIPT + UTIL_ErrorConstants.SANDBOX_EMAIL + BODY_DATA_A + currentuser.Id + BODY_DATA_B;
                      
        Messaging.InboundEmail email1 = emailData(subject, body);
        Messaging.InboundEnvelope env1 = new Messaging.InboundEnvelope(); 
        
        UTIL_UnhandledLoggingService apexErrorLog = new UTIL_UnhandledLoggingService();
        
        Test.startTest();
        System.runAs(currentuser){
            apexErrorLog.handleInboundEmail(email1,env1);
        }
        Test.stopTest();
        
        ExceptionLog__c excpData = [SELECT Id, Class_Name__c FROM ExceptionLog__c WHERE Class_Name__c=:CLASS_NAME]; 
        System.assertEquals(excpData.Class_Name__c, CLASS_NAME);
    }

}