/* Author: Accenture
 * Last Modified: 4/17/19
 * 
 * Usage:
 * 
 */
global with sharing class Logger {
    
    public List<Logger.Log> logCache = new List<Logger.Log>();
    public static Boolean USE_CACHE = true;					// Used if logging before callouts to avoid DML exceptions
    public static Boolean CREATE_PLATFORM_EVENT = true;
    public static final String ERROR = 'ERROR';
    public static final String WARNING = 'WARNING';
    public static final String INFO = 'INFO';
    
    public Logger() {}
    
    // for json representation
    public class Log {
        public String message {get;set;}
        public DateTime createdDate {get;set;}
        public String level {get;set;}
        public String userId {get;set;}
        public String acctId {get;set;}
        public String parentId {get;set;}
        public String env {get;set;}
        public String action {get;set;}
        public String className {get;set;}
        public String payload {get;set;}
        public Integer statusCode {get;set;}
        public String statusMessage {get;set;}
        public String url {get;set;}
        public String method {get;set;}
        public String jobID {get;set;}
        public String source {get;set;}
        public String remoteAddress {get;set;}
        public String headers {get;set;}
        
        public Log(String l) {
            this.level = l;
            this.env = System.URL.getSalesforceBaseUrl().getHost();
            this.source = 'Salesforce';
            this.createdDate = DateTime.now();
            this.userId = UserInfo.getUserId();
        }
    }

    public void debug(String msg) {
        Logger.Log log1 = new Logger.Log('INFO');
        log1.message = msg;
        
        if (Logger.USE_CACHE) {
            this.logCache.add(log1);
        } else {
            this.saveLog(log1);
        }
    }
    
    // discover which type and do addLog acordingly 
    public void log(RestRequest req, RestResponse resp, RESTHelper.AcornResponse response) {
       // addLog
    }
    
    // discover which type and do addLog acordingly
    public void log(HttpRequest req, HttpResponse resp) {
       // addLog
    }
    
    // Future log capability
    public Logger addLog(String param1, String param2) {
        return this;
    }

    // Add API Log
    public Logger addLog(String level, String msg, String acctId, String action, String className, String parentId, String payload, Integer statusCode, String statusMessage,
                       String url, String method, String remoteAddress, String headers) {
        Logger.Log log1 = new Logger.Log(level);
        log1.message = msg;
        log1.acctId = acctId;
        log1.action = action;
        log1.className = className;
        log1.parentId = parentId;
        log1.payload = payload.replace(' ', '');
        log1.statusCode = statusCode;
        log1.statusMessage = statusMessage;
        log1.url = url;
        log1.method = method;
        //log1.jobID = jobID;             
        log1.remoteAddress = remoteAddress;
        log1.headers = headers;
                           
        if (Logger.USE_CACHE) {
            this.logCache.add(log1);
        } else {
            this.saveLog(log1);
        }
        return this;
    }
    
    public Logger saveLog(Logger.Log l) {
        System_log_event__e event = Logger.log2SystemEvent(l);
        System_Log__c log = Logger.toSObject(l);
        insert log;
        insert event;
        return this;
    }

    public Logger saveLogs() {
        System.debug('Saving logs: ' + logCache.size());
        try {    
            List<SObject> logsToAdd = new List<SObject>();
            List<SObject> eventsToAdd = new List<SObject>();
            for (Logger.Log l : logCache) { 
                logsToAdd.add(Logger.toSObject(l));
                eventsToAdd.add(Logger.log2SystemEvent(l));
            }
            Database.SaveResult[] srList = Database.insert(logsToAdd, false);
            
            if (CREATE_PLATFORM_EVENT) {
                Database.SaveResult[] eventSrList = EventBus.publish(eventsToAdd);
                srList.addAll(eventSrList);
            }
            
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully inserted log. Log ID: ' + sr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Log fields that affected this error: ' + err.getFields());
                    }
                }
            }
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        return this;
    }

    /*
     * Create a New Platform Event
     */
    public static System_log_event__e log2SystemEvent(Logger.Log log) {
        // Message, Level, User, ParentId
        System_log_event__e event = new System_log_event__e();
        event.Message__c = log.message;
        event.Level__c = log.level;
        event.User_Id__c = log.userId;
        event.Parent_Id__c = log.parentId;
        event.Log_Id__c = '';
        
        return event;
    }
    
    public static System_Log__c toSObject(Logger.Log l) {
        System_Log__c log = new System_Log__c();
        log.Level__c = l.level;
        if (isValidId(l.acctId)) log.Account__c = l.acctId;
        log.Message__c = l.message;
        if (isValidId(l.userId)) log.UserId__c = l.userId;
        if (isValidId(l.parentId)) log.Parent_ID__c = l.parentId;
        if (isValidId(l.parentId) && l.parentId.startsWith('500')) {
            log.Case__c = l.parentId;
        }
        log.Environment__c = l.env;
        log.Class_Name__c = l.className;
        log.Payload__c = l.payload;
        log.Status_Code__c = l.statusCode;
        log.Url__c = l.url;
        log.Status_Message__c = l.statusMessage;
        log.Method__c = l.method;
        if (String.isNotEmpty(l.jobId)) log.Job_Id__c = l.jobId;
        log.Remote_Address__c = l.remoteAddress;
        log.Headers__c = l.headers;
        
        return log;
    }
    
    public static Boolean isValidId(String Idparam) {
        String id = String.escapeSingleQuotes(Idparam);
        if((id.length() == 15 || id.length() == 18) && Pattern.matches('^[a-zA-Z0-9]*$', id)) {
            return true;
        }
        return false;
    }
    
    public String toJson() {
        return Json.serialize(logCache);
    }
    
}