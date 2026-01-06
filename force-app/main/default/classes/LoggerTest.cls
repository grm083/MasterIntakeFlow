@isTest(seeAllData=false)
public class LoggerTest {
    private static final string SYS_ADMIN = 'System Administrator';
   
    /* method for setting up data*/ 
    @testSetup static void setup() {
        Profile adminProfile = TestDataFactory.getProfile(SYS_ADMIN);
        User usr = TestDataFactory.createUser(adminProfile);
        Database.insert(usr);  
        system.runAs(usr){
            list<Account> acclist = TestDataFactory.createAccount(Constant_Util.KEYWORD_TEST, usr);
            Database.insert(acclist);
            
            
        } 
    }

    @isTest static void testLogger() {
        
        Logger log = new Logger();
        log.debug('This is a quick log message test');
        
        log.saveLogs();
        
        list<Case> cases = TestDataFactory.createNewCase();
        
        insert cases;
        String caseId = cases[0].Id;
        
        new Logger().addLog(Logger.ERROR, 'This is a test log messages', '', 'testLogger', 'LoggerTest', caseId, '', 500, 'MISSING_PARAM',
                            '/v2/getLog', 'GET', '0.0.0.0', '{headers}').saveLogs();

        
        List<System_Log__c> logs = [select Id from System_Log__c];
        System.assertEquals(1, logs.size());
        
        System.assertEquals(Logger.isValidId(caseId), true);
        List<Account> AccList = [Select Id from Account Limit 1];
        Logger.Log l = new Logger.Log(Logger.ERROR);
        l.jobId = '123';
        
        l.acctId = AccList.get(0).Id;
        //log.saveLog(l);
        //String json = log.toJson();
    }
    
    @isTest static void testRESTHelper() {
        RESTHelper.AcornResponse resp = new RESTHelper.AcornResponse();
        resp.payload = '{json}';
        resp.errorCode = '';
        RESTHelper.DataWrapper data = new RESTHelper.DataWrapper();
        resp.Data = data;
        
        RESTHelper.AcornResponse acornResp = RESTHelper.createAcornErrorResponse(resp, RESTHelper.HTTP_INVALID_MISSING_PARAM, 'Error Occurred.  Missing Case ID');
        RESTHelper.AcornResponse successResp = RESTHelper.createAcornSuccessResponse(resp);
        
        RESTHelper.ErrorsWrapper error = new RESTHelper.ErrorsWrapper('500', 'Exception has Occurred');
        List<RESTHelper.ErrorsWrapper> errors = new List<RESTHelper.ErrorsWrapper>();
        errors.add(error);
        RESTHelper.ErrorMessageWrapper errorResp = new RESTHelper.ErrorMessageWrapper('ERROR', 'Exception', errors);
        
        resp.Problem = errorResp;
        System.assertEquals(resp.hasProblems(), true);
        String theId = '1234ABCD1234ABC';
        
        System.assertEquals(RESTHelper.isValidId(theId), true);
    }
    
}