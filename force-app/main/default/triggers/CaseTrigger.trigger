/*************************************************************
@Name: CaseTrigger
@Author: DineshKumar S
@CreateDate: 01/02/2019
@Description: Trigger to Perform operations on Case
**************************************************************/
trigger CaseTrigger on Case (before insert,before update,after update, after insert,before delete) {
    if(RecurrsiveTriggerHandler.isSkipCaseTriggerForTask) return; //added for SDT-32713
    TriggerDispatcher.dispatch(Case.sobjectType);
	
	//Added by jatan for SDT-40344
    if(Test.isRunningTest()){
        List<Code_Switch__c> codeSwitchSettinglst = new  List<Code_Switch__c>();
            Code_Switch__c codeSwitchSetting = new  Code_Switch__c();
            codeSwitchSetting.Name = 'IVR_New_Service';
            codeSwitchSetting.Switch_Off__c = false;
            codeSwitchSettinglst.add(codeSwitchSetting);
            
            Code_Switch__c codeSwitchSettingHaul_Away = new  Code_Switch__c();
            codeSwitchSettingHaul_Away.Name = 'Haul_Away';
            codeSwitchSettingHaul_Away.Switch_Off__c = false;
            codeSwitchSettinglst.add(codeSwitchSettingHaul_Away);
            
            Insert codeSwitchSettinglst;
    }

    //Added by jatan for SDT-40344 - modified by av4 on 26/11/2024
    if(Trigger.isInsert) {
    Code_Switch__c codeSwitchSetting = Code_Switch__c.getValues('IVR_New_Service');
    if(!codeSwitchSetting.Switch_Off__c){
    // Code Comment for Case Quote Automation 
    Map<String,sobject> PayLoadData =  new Map<String,sobject>();
        List<map<String,sobject>> PayLoadList = new List<map<String,sobject>>();
        for(Case caseObj : Trigger.new) 
        {
            if(caseObj.Status == 'Draft' && trigger.isInsert && trigger.isAfter) 
            {
                    PayLoadData.put(caseObj.Id,caseObj);
                    PayLoadList.add(PayLoadData);
                    system.debug('Case '+ caseObj.Id);
                    system.debug('PayLoad '+PayLoadList);
                    PlatformEventProcessor.raiseCaseToquoteEventPE('CaseUpdate', PayLoadList);
            }        
        }
    }  
}
    
}