public with sharing class UTIL_ErrorConstants {
    public static final Integer EXCEPTION_CODE_SIZE_LIMIT = 100;    
        public static final Integer EXCEPTION_DETAILS_SIZE_LIMIT = 131072;
        public static final Integer REMOVE_DETAILS_VALUE = 2;
        public static final String CONTINUATION_String ='..';
        public static final String EXCEPTION_NAME_SEPARATOR ='-';
        public static final String PREFIX_FW = 'fw: ';
        public static final String PREFIX_FWD = 'fwd: ';
        public static final String PREFIX_RE = 're:';
        public static final String CAUSED_BY = 'caused by:';
        public static final String PREFIX_CLASS = 'Class.';
        public static final String PREFIX_TRIGGER = 'Trigger.';
        public static final String COLUMN ='column';
        public static final String LINE_NO = ': line';
        public static final String EXCEPTION_CODE_FILTER = 'first error:';
        public static final String START_APEX_SCRIPT = 'Apex script';
        public static final String IDENTIFY_TRIGGER = 'Apex script unhandled trigger';
        public static final String SANDBOX_EMAIL = 'Sandbox';
        public static final String FLOW_ERROR='Flow';
        public static final String FLOW_EXCEPTION = 'Flow Exception Ocurred'; 
        public static final String USER = 'user/organization'; 
        public static final String BATCH_CLASS_NAME = 'BATCH_PurgeOldExcption';
        public static final String BATCH_QUERY = 'SELECT Id FROM ExceptionLog__c WHERE CreatedDate <= N_DAYS_AGO:';
        public static final String BATCH_METHOD_NAME = 'execute';
        public static final String DML_EXCEPTION = 'System.DMLException';
        public static final String SEVERITY_LEVEL_CUSTOM_SETTING_RECORD = 'ExceptionLog_Settings';
        public static final String SEVERITY_LEVEL_ERROR = 'ERROR';       
        public static final String BLANK_SPACE = '';
        public static final String SPACE = ' ';
        public static final String RELATED_OBJECT = 'Related Object : ';
        public static final String OTHER_EXCEPTION = 'Miscellaneous Exception';
        public static final String COLON = ':';
        public static final String APOSTROPHE = '\'';
        public static final String DOUBLE_QUOTE = '\"';
        public static final String FULLSTOP = '.';
        public static final String FORWARD_SLASH = '/';
        public static final String RECORD_ID = 'Record Id:';
        public static final String ENTER = '\n';
        public static final String COMMA = ',';
        public static final String OCCURRENCE_KEYWORD = 'Occurrence ';
        public static final String ERROR_APPLICATION = 'Error Logging Framework';
        public static final String ERROR_LOG_CLASS = 'UTIL_LoggingService';
        public static final String UNHANDLED_ERROR_LOG_METHOD = 'processExceptionEmail';
        public static final String FRAMEWORK_LOG_METHOD = 'logException';
        public static final String FRAMEWORK_MERGE_METHOD ='mergeExistingErrorLogs';
        public static final String  FLOW_ORG = 'Org:';
        public static final String  FLOW_DETAILS = 'Flow Details'; 
        public static final String  BRAKET_OPENING = '(';
        public static final String  BRAKET_CLOSING = ')';
        public static final String CURRENT_USER = 'Current User:';
    
    //Execution Block Specific Constants
        
    public static final String PROJECT_CODE_MODULE = 'Project Code Module';
	public static final String PROJECT_CODE_TRIGGER = 'ProjectCodeTrigger';
    public static final String CASE_TRIGGER_MODULE = 'Case Trigger' ;
    public static final String CASE_TASK_ROUTING_METHOD = 'completeTaskRouting';
    public static final String CASE_TRIGGER_CLASS = 'CaseTriggerHelper';
	public static final String BATCH_CLASS = 'BatchClass';
    public static final String BATCH_TO_CHANGE_OWNERSHIP = 'BatchToChangeOwnerShip';
    public static final String ASYN_CLASS = 'AsyncCompleteTask';
    public static final String CASE_TRIGGER = 'CaseTrigger';
    public static final String CASE_GENESYS_TASK_ROUTING_METHOD = 'updateGenesysTaskRouting'; 
    public static final String CASE_ADD_CASE_ASSETS_METHOD = 'addCaseAssets';
    public static final String CASE_UPDATE_COMMENTS_TRACKING_NO_METHOD  = 'updateCommentsTrackingNumber';
    public static final String CASE_DELETE_OLD_CASE_ASSET_METHOD = 'deleteOldCaseAssets';
    public static final String CASE_CLOSE_TASK_METHOD = 'closeTasks';
    public static final String CASE_CLOSE_OLD_TASK_METHOD = 'closeOldTasks';

    public static final String WORKORDER_TRIGGER_HELPER =  'WorkOrderTriggerHelper';
    public static final String WORKORDER_UPDATE_CASE_DETAILS = 'updateCaseDetail';
    public static final String WORKORDER_TRIGGER ='WorkOrdertrigger';
    public static final String TASK_TRIGGER_HELPER ='TaskTriggerHelper';
       
	//Pricing Specific Block
    public static final String PRICING_REQUEST_APEX ='Pricing Request Apex';   
    public static final String PRICING_REQUEST_STP_APEX ='Pricing Request STP Process Apex'; 
    
    //Pricing Change Specific Block
    public static final String PRICING_CHANGE_REQUEST_APEX ='Pricing Change Request Apex';

    //Picklist Utility Block
    public static final String UTIL_PICKLIST_APEX ='UTIL Picklist Apex';   
    
    /*
     * @Vendor	TCS
     * @description	STP specific constants used in UTIL_LoggingService
     * 
     */
    public static final String CLASS_NAME = 'STPRuleExecution';
    public static final string EXCEPTION_TYPE = 'STPRuleExecutionException';
    public static final string APPLICATION_NAME = 'STP Rule Execution Apex';
    public static final string EXECPTION_DESCRIPTION =  'Straight through processing failed';
    //SDT - 28509 - Start
    public static final String STP_PRICING_INTEGRATION_STATUSCHANGE_APEX ='STP Pricing Integration Status Change Process Apex';
    public static final String STEP_STP_CLASS_NAME = 'PriceOnlyRequestSTPProcess ';
    public static final string STEP_STP_EXCEPTION_TYPE = 'STPStepByStepException ';
    public static final string STEP_STP_APPLICATION_NAME = 'STP Step By Step Execution Apex ';
    //SDT - 28509 - End
    
    //SDT-30734
    public static final String SERVICE_FLAG_CLASS = 'GetSFDCServiceFlag';
    
    //Changes related to SDT-48016
    public static final String QUOTETRIGGERHELPER_CLASSNAME = 'QuoteTriggerHelper';
    public static final String GETQUOTEPRICEDATA_METHODNAME = 'getQuotePriceData';
    public static final String CREATEPRICINGREQUEST_METHODNAME = 'createPricingRequest';
    public static final String QUOTETRIGGER_TRIGGERNAME = 'QuoteTrigger';
    public static final String QUOTETRIGGERHANDLER_CLASSNAME = 'QuoteTriggerHandler';
    public static final String CREATETASKONHAULAWAYQUOTE_METHODNAME = 'createTaskonHaulAwayQuote';
    public static final String CREATECHARGEABILITYCHILDCASE_METHODNAME = 'createChargeabilityChildCase';
    public static final String CREATEGENESYSTASK_METHODNAME = 'createGenesysTask';
    public static final String CREATEGENESYSRECORD_METHODNAME = 'createGenesysRecord';
    public static final String CREATEMULTIPLECASESINVOKE_METHODNAME = 'createMultipleCasesInvoke';
    public static final String COPYEMAILTOCHILDCASE_METHODNAME = 'copyEmailToChildCase';
    public static final String CREATEOBTAININTERNALRESPOTASK_METHODNAME = 'createObtainInternalRespoTask';
    public static final String AMENDMENTQUOTEAPPROVALBYSINGLEBUNDLE_METHODNAME = 'amendmentQuoteApprovalBySingleBundle';
    public static final String QUOTEPROCUREMNTCONTROLLER_CLASSNAME = 'QuoteProcurementController';
    public static final String ADDCOMMENTFORSLAOVERRIDE_METHODNAME = 'addCommentForSLAOverride';
    public static final String UPDATESTATUS_METHODNAME = 'updateStatus';
    public static final String CREATEQUOTECOMMENT_METHODNAME = 'createQuoteComment';
    public static final String ADDADDITIONALSERVICESCOMMENT_METHODNAME = 'addAdditionalServicesComment';
    public static final String SAVEBYPASSREQUEST_METHODNAME = 'saveByPassSTPRequest';
    public static final String CONFIRM_CONFIGURATION_ACTION = 'Confirm Configuration Action';
}
