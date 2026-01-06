@isTest public class QuoteTriggerHandlerExceptionTest {
 @isTest static void handleException(){
        String quoteId;
     
     		//Insert case
     		Id cseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('New Service Case').getRecordTypeId(); 
            Case cse = new Case(Case_Sub_Type__c = 'Permanent',Case_Reason__c = 'Existing Location',Case_Type__c = 'New Service',recordtypeId = cseRecordTypeId);
            insert cse;
     
     		//insert opportunity
            Opportunity opp = new Opportunity(Name = 'Test Opp',Case__c = cse.Id,StageName = 'Proposal',CloseDate = system.today());
            insert opp;
            
            SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
            testQuote.SBQQ__Opportunity2__c=opp.Id;
            testQuote.SBQQ__Status__c = Constant_Util.QUOTE_DRAFT;
            testQuote.Assigned_To__c=[select id from user limit 1][0].id;
     		testQuote.SBQQ__Account__c = null; 
            insert testQuote;
     		
     		SBQQ__Quote__c procuredQuote =[SELECT Id,SBQQ__Status__c,SBQQ__Type__c,Assigned_To__c FROM SBQQ__Quote__c LIMIT 1];
            //testQuote.Quote_Only__c = true;
            //RecurrsiveTriggerHandler.runTimes=null;
            RecurrsiveTriggerHandler.mapQuotePricingCallTracker= new map<id,String>();
            List<SBQQ__Quote__c > QuoteList =new List<SBQQ__Quote__c >();
            QuoteList.add(procuredQuote);
            Map<Id,SBQQ__Quote__c> oldMap = new Map<Id,SBQQ__Quote__c>();
     		oldMap.put(testQuote.id,testQuote);
            Map<Id,SBQQ__Quote__c> newMap = new Map<Id,SBQQ__Quote__c>();
          	//Changes related to test class coverage	
          	procuredQuote.SBQQ__Status__c = Constant_Util.QUOTE_PRODUCT_CONFIGURED;
          	newMap.put(procuredQuote.id,procuredQuote); 
     		//Generating an exception forcibly
     		RecurrsiveTriggerHandler.mapQuotePricingCallTracker = NULL;
     		
             try
             {
            QuoteTriggerHandler.onAfterUpdate(QuoteList,oldMap,newMap);
             }
             catch(exception ex){
               system.debug('in catch block');
             }
            test.startTest();
            //update testQuote;
            test.stopTest();
        }
}