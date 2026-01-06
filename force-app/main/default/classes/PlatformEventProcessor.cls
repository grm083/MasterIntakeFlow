/* @description       : The class to Process all the publishing of Platform Event. The same should be utilise to work with any other Platform Event in future
   @author            : Toshender Kumar
 * @group             : AM
 * @last modified on  : 06-21-2023
 * @last modified by  : Toshender
*/
public class PlatformEventProcessor {
    
 /* @description       : The publishes the STPProcessEvent Platform Event. The same is called after Pricing call is done on change of status from Draft to procurement
    @author            : Toshender Kumar
    @group             : AM
    @Vendor            : TCS
    @Reference calls   : From CreatePricingRequest.callPriceOnlyIntegration, PricingRequestHelper.callPricingIntegration
    @last modified on  : 06-21-2023
    @last modified by  : Jatan
*/
     public static void RaiseSTPProcessEventPE(Set<Id> quoteIds , Boolean priceCall){
         
        List<STPProcessEvent__e> events = new List<STPProcessEvent__e>();
        
        for(Id quoteId : quoteIds){
             
            STPProcessEvent__e evt = new STPProcessEvent__e(Payload__c=quoteId , PriceOnlyCall__c = priceCall);
            events.add(evt);
        }
        List<Database.SaveResult> results = EventBus.publish(events);
         system.debug('results '+results);
        
    }
    
/*  @description       : The publishes the Case Quote Creation Event. 
    @author            : Amardeep Chauhan
    @Vendor            : TCS
    @Reference calls   : From CaseUpdateHandler
    @last modified on  : 02-21-2023
    @last modified by  : Amardeep
*/

    public static void RaiseCaseToquoteEventPE(String eventType, List<map<String,sobject>> payLoadData){
         
         
        List<CasetoQuoteAutomation__e> events = new List<CasetoQuoteAutomation__e>();
        String jsonSingleObject;
        for(integer  i=0; i < payLoadData.size();i++) {
            jsonSingleObject =  JSON.serialize(payLoadData[i]);
            CasetoQuoteAutomation__e CaseAutomationPEObj  = new CasetoQuoteAutomation__e();
            CaseAutomationPEObj.EventType__c = eventType;
            CaseAutomationPEObj.PayLoad__c = jsonSingleObject;
            events.add(CaseAutomationPEObj);
        }
        
        List<Database.SaveResult> results = EventBus.publish(events);
        // Iterate through each returned result
        for (Database.SaveResult sr : results) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully inserted event. Event ID: ' + sr.getId());
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred. ' +err.getStatusCode() + ': ' + err.getMessage());
                }
            }
        }
         system.debug('Platform Event Result '+results);
        
    } 
   /*  @description       : The publishes the Task and Genesys Platform Event. 
@author            : Sheikh Sarfaraz
@Vendor            : TCS
@Reference calls   : From QouteValiationHandler
@last modified on  : 07-24-2025
@last modified by  : Sarfaraz
*/
     public static void RaiseTaskAndGenesysPE(Id quoteId){
         
         List<Task_and_Genesys_Platform_Event__e> events = new List<Task_and_Genesys_Platform_Event__e>();
         
         Task_and_Genesys_Platform_Event__e evt = new Task_and_Genesys_Platform_Event__e(Payload__c=quoteId );
         events.add(evt);
         
         List<Database.SaveResult> results = EventBus.publish(events);
         system.debug('results '+results);
     }

}
