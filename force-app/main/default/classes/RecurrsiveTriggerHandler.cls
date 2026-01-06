/*************************************************************
@Name: RecurrsiveTriggerHandler
@Author: DineshKumar S
@CreateDate: 01/02/2019
@Description: This class is used handle RecurrsiveTigger.
**************************************************************/
public class RecurrsiveTriggerHandler {
    public static Boolean bypassValidation = false;
    public static Boolean bypassValidationWorkOrder = false;
    public static Boolean bypassValidationQuoteLine = false;
    public static Boolean bypassTrigger = false;
    public static Boolean getCaseInfo = false;
    public static Boolean isSkipcaseTrigger = false;
    public static Boolean isSkipcaseTriggerAfterUpdate = false;
    public static Boolean isSkiptaskTrigger = false; //for update event recursion handling
    public static Boolean isSkiptaskInsertTrigger = false; // for insert event recursion handling
    public static Boolean isSkipWorkOrderTrigger = false;
    public static Boolean isSkipWorkOrderUpdate = false;
    public static Boolean isSkipAssetTrigger = false;
	public static Boolean invokeValidationforPricing = false;
    public static Integer runTimes = 0;
    public static Boolean isSkipEmailMessageTrigger = false;
    public static Boolean PassValidationCalledAlready = false;
    public static Boolean PassValidationCalledAlreadyForWorkOrder = false;
    public static Boolean PassValidationCalledAlreadyForPricing = false;
    public static Boolean isSkipCommentTrigger = false;
    public static Boolean isSkipContentDocumentLinkTrigger = false;
    public static Boolean isSkipApprovalLogTrigger = false;
    public static Boolean isSkipCaseCommentTrigger = false;
    public static Boolean isSkipCaseHistoryTrackerTrigger = false;
    public static Boolean isSkipQuoteTrigger = true;
	public static Boolean isRecurrsiveToAcorn = true ;
	public static Boolean isReopenRecurrsiveToAcorn = true ;
    public static Boolean isRecurrsiveQuoteLine = false;
    public static Boolean isSkipValidateQLCostPrice = false;
	public static Boolean isSkipsentChatNowAutoReply = false;

    //added for SDT-31118
    public static Boolean isSkipQuoteLineTrigger = false;
    public static Boolean isSkipCaseTriggerForTask = false; //sdt-32713
    public static Boolean isSkipBrTrigger = false; //SDT-31225
    
    //TCS-pkulkarn-SDT-41184-Added
    public static Boolean isSkipEndDateUpdate = false;
    
    /* Quote Line trigger Management */ 
    public static Boolean isBeforeDelete = true;
    public static Boolean IsBeforeInsert = true;
    public static Boolean IsAfterInsert = true;
    public static Boolean IsAfterUpdate = true;
    
     // SDT-48527 - Used to manage pricingCall to be called only once per quote per transaction
     public static Map<Id,String> mapQuotePricingCallTracker = new Map<Id,String>();

    /*
    * This method is to Identify whether Trigger needs to be By Passed or not.
    * @owner : Dinesh Kumar S
    * @param : 
    */	
    public static boolean runOnce()
    {
        if(isSkipQuoteTrigger)
        {
           isSkipQuoteTrigger = false;
            return true;
        }
        else
        {
            return isSkipQuoteTrigger;
        }
    }
    public static void getByPassValidation(){
        if(!PassValidationCalledAlready){
            RecurrsiveTriggerHandler.bypassValidation = [SELECT Bypass_Validation__c 
                                                         FROM User 
                                                         WHERE id=:UserInfo.getUserId() 
                                                         LIMIT 1][0].Bypass_Validation__c;
            PassValidationCalledAlready = true;
        }
    }

    // The work order handler will check bypassValidation as well
    // Created separate method to avoid possible dependencies
    public static void getByPassValidationForWorkOrder(){
        if(!PassValidationCalledAlreadyForWorkOrder){
            RecurrsiveTriggerHandler.bypassValidationWorkOrder = [SELECT Bypass_Validation__c 
                                                                  FROM User 
                                                                  WHERE id=:UserInfo.getUserId() 
                                                                  LIMIT 1][0].Bypass_Validation__c;
            PassValidationCalledAlreadyForWorkOrder = true;
        }
    }
    
    // This invert the pricing handler bypassValidation
    // Created separate method to avoid possible dependencies
    public static void getByPassValidationForPricing(){
        if(!PassValidationCalledAlreadyForPricing){
            RecurrsiveTriggerHandler.invokeValidationforPricing = [SELECT Bypass_Validation__c 
                                                                  FROM User 
                                                                  WHERE id=:UserInfo.getUserId() 
                                                                  LIMIT 1][0].Bypass_Validation__c;
            PassValidationCalledAlreadyForPricing = true;
        }
    }

    /*
    * This method is to Identify whether Trigger needs to be By Passed or not.
    * @owner : Dinesh Kumar S
    * @param : 
    */	
    Public Static void getTriggerByPass(){
        //Added for Disabling all the logic during deployment activities
        Boolean fullLogicDisabledFlag = Object_Save_Mode__c.getInstance().Full_Logic_Disabled__c;

        //Added for Disabling the trigger during deployment activities
        Boolean triggerDisabledFlag = Object_Save_Mode__c.getInstance().Disable_Trigger__c;
        RecurrsiveTriggerHandler.bypassTrigger = fullLogicDisabledFlag || triggerDisabledFlag ? true : false;
    }
    
    public static integer getRunTimes(){
    	return runTimes;
    }
    
    public static void setRunTimes(){
    	runTimes++;
    }
    public static boolean setIsRecurrsiveQuoteLine(){
        isRecurrsiveQuoteLine = true;
        return isRecurrsiveQuoteLine;
    }
    
}
