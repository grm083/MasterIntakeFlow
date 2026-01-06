trigger QuoteTrigger on SBQQ__Quote__c (after update, after insert,before update, before insert) {
    
    if(!RecurrsiveTriggerHandler.bypassValidation){
        RecurrsiveTriggerHandler.getByPassValidation();
    }
	
	//Invokes Before Insert
    if(Trigger.IsBefore && Trigger.IsInsert){
        QuoteTriggerHandler.onBeforeInsert(Trigger.New);
    }
    
    //Invokes Before Update
    if(Trigger.IsBefore && Trigger.IsUpdate){
      QuoteTriggerHandler.onBeforeUpdate(Trigger.New,Trigger.OldMap,Trigger.newMap);
    }
    
    if(Trigger.IsBefore && Trigger.IsUpdate){
        //Changs added for story SDT-24302
        for(SBQQ__Quote__c q:Trigger.new){
            if(Trigger.oldMap.get(q.id).SBQQ__Status__c != 'Cancelled') {
                QouteValiationHandler.validateQuoteStatus(trigger.new, trigger.oldMap);
            }
        }
        //END
    }
   if(Trigger.IsBefore && Trigger.IsUpdate){
       //Changs added for story SDT-24302
        for(SBQQ__Quote__c q:Trigger.new){
            if(Trigger.oldMap.get(q.id).SBQQ__Status__c != 'Cancelled') {
                validateProductQuoteOrder.vProductQuoteOrder(trigger.new, trigger.oldMap);
            }
        }
    //END
    }
    //Invokes After Update
    if(!RecurrsiveTriggerHandler.bypassValidation && Trigger.IsAfter && Trigger.IsUpdate ){
        QuoteTriggerHandler.onAfterUpdate(Trigger.New, Trigger.oldMap,Trigger.newMap);
        system.debug('QuoteTrigger update method');
        // Added for SDT-26174
        boolean newstpValue = false;
        boolean oldstpValue = false;
        //End
      if(Trigger.isUpdate && Trigger.isAfter){
          Boolean isQuoteVal = true ; 
          for(SBQQ__Quote__c q:Trigger.new){
              if(q.Assigned_To__c !=Trigger.oldMap.get(q.id).Assigned_To__c) {
                  isQuoteVal = false ;
              }
                // Added for SDT-26174
                 newstpValue = q.STP__c;
                 oldstpValue = Trigger.oldMap.get(q.id).STP__c;
                 //End
          }
          //Commenting Below code as a part of Approval Rules Hot-Fix
          //Added new || condition for SDT-26174
        if((RecurrsiveTriggerHandler.runOnce() && isQuoteVal) || (newstpValue == true && newstpValue != oldstpValue))
        {
            if(Test.isRunningTest()){
                List<Code_Switch__c> codeSwitchList = new  List<Code_Switch__c>();
                Code_Switch__c codeSwitchAmendment =  new Code_Switch__c();
                codeSwitchAmendment.Name = 'Amendment Quote Approvals';
                codeSwitchAmendment.Switch_Off__c = false;

                Code_Switch__c codeSwitchException =  new Code_Switch__c();
                codeSwitchException.Name = 'Exception Quote Approvals';
                codeSwitchException.Switch_Off__c = false;

                Code_Switch__c codeSwitchCorrection =  new Code_Switch__c();
                codeSwitchCorrection.Name = 'Correction Quote Approvals';
                codeSwitchCorrection.Switch_Off__c = false;
                
                codeSwitchList.add(codeSwitchCorrection);
                codeSwitchList.add(codeSwitchAmendment);
                codeSwitchList.add(codeSwitchException);
                Insert codeSwitchList;
            }
            Set<String> approvalTypes = new Set<String>();
                approvalTypes.add(Constant_Util.QUOTE);
                if(!Code_Switch__c.getInstance('Amendment Quote Approvals').Switch_Off__c) approvalTypes.add(Constant_Util.QUOTE_TYPE_AMEND);
                if(!Code_Switch__c.getInstance('Exception Quote Approvals').Switch_Off__c) approvalTypes.add(Constant_Util.QUOTE_TYPE_EXCEPTION);
                if(!Code_Switch__c.getInstance('Correction Quote Approvals').Switch_Off__c) approvalTypes.add(Constant_Util.QUOTE_TYPE_CORRECTION);
                
                /* BUG/SDT-47957 - gmarti18
		 * In order to enable automated approvals on the Add/Change type, we should create the above referenced Code Switch records.  This will allow us to 
                 * dynamically retrieve whether automated approvals should be performed.  Once created we can turn them on via Custom Settings and perform testing.
                 * The work performed under BRE-3 in the BusinessRuleUtility class already accounts for the Quote Line details and related Case Types.
                 * 
                 * Furthermore, rewrote the SOQL query to show fields queried by type of field for easier future reference */
                
                Map<Id, SBQQ__Quote__c> mnewQuote = new Map<Id, SBQQ__Quote__c>([SELECT Id, SBQQ__Type__c, SBQQ__Status__c, Duration__c, CreatedById, SBQQ__Account__c, Assigned_To__c, Action_Type__c, Owner.Profile.Name,
                                                                                 Business_Rule__c, Case_Number__c, Case_Type__c, SBQQ__StartDate__c, SBQQ__EndDate__c, SBQQ__PrimaryContact__c, Project__c,
                                                                                 Next_Action_Start_Date__c, Next_Action_Due_Date__c, Last_Action_Performed__c, Genesys_Record_Created__c, CreatedBy.Email, //Quote Fields Specifically
                                                                                 SBQQ__Account__r.Division__c, SBQQ__Account__r.Brand__c, SBQQ__Account__r.Location_Type__c, SBQQ__Account__r.Geography__c, SBQQ__Account__r.ParentId,
                                                                                 SBQQ__Account__r.Parent.AccountNumber, //Account Fields
                                                                                 SBQQ__PrimaryContact__r.Account_Title__c, SBQQ__PrimaryContact__r.Email, SBQQ__PrimaryContact__r.Account_Department__c, //Contact Fields
                                                                                 SBQQ__Opportunity2__r.Case__r.Case_Type__c, SBQQ__Opportunity2__r.Case__r.Case_Sub_Type__c, SBQQ__Opportunity2__r.Case__r.Case_Reason__c,
                                                                                 SBQQ__Opportunity2__r.Case__r.Origin, SBQQ__Opportunity2__r.Case__r.Is_Haul_Away_Service__c, SBQQ__Opportunity2__r.Case__r.Haul_Away_Information__c,
                                                                                 SBQQ__Opportunity2__r.Case__c, SBQQ__Opportunity2__r.Case__r.CreatedBy.Email, SBQQ__Opportunity2__r.Case__r.CreatedById,
                                                                                 SBQQ__Opportunity2__r.Case__r.SuppliedEmail, SBQQ__Opportunity2__r.Case__r.SuppliedName, SBQQ__Opportunity2__r.Case__r.ContactId //Case Fields
                                                                                 FROM SBQQ__Quote__c
                                                                                 WHERE Id IN :Trigger.New AND SBQQ__Status__c =: Constant_Util.QUOTE_PRICE_CONFIGURED AND Quote_Only__c = false]);
                
                for (Id key : mnewQuote.keyset()) {
                    if (!approvalTypes.contains(mnewQuote.get(key).SBQQ__Type__c)) mnewQuote.remove(key);
                }
                
                if(mnewQuote.keyset().size()>0){  
                    QuoteApproval a = new QuoteApproval();
                
                    //Changes related to SDT-39632
                    //a.startApprovalProcess(mnewQuote); 
                    try
                    {
                        a.startApprovalProcess(mnewQuote); 
                    }
                    catch(DMLException ex)
                    {
                        //Changes related to SDT-39632 - Method to show clean exception error message
                        Trigger.new[0].addError(ExceptionModifier.truncateException(ex.getMessage()));
                    }
                }   
            
        }
    }
     
   }   
    //Invokes After Insert
    if(!RecurrsiveTriggerHandler.bypassValidation && Trigger.IsAfter && Trigger.IsInsert){
      //  QuoteTriggerHandler.onAfterInsert(Trigger.New,Trigger.newMap);
    }

}
