trigger CasetoQuoteAutomation on CasetoQuoteAutomation__e (after insert) {
   
    System.debug('>>>>>'+trigger.new.size());
    try {
      
    String eventType     = Trigger.new[0].EventType__c;
    string payload      =  Trigger.new[0].payload__c;
    
    List<CaseQuoteAutomation__mdt> caseQuoteAutomationList = [SELECT Label,Event_Type__c,Next_Event__c,Process__c,Handler__c
                                                              FROM CaseQuoteAutomation__mdt WHERE Event_Type__c =:eventType 
                                                              AND Active__c = true] ;
    
    Map<String, Object> MapOfData = (Map<String, Object>) JSON.deserializeUntyped(Trigger.new[0].PayLoad__c);
    
  Map<String, sobject> MapOfDataUpdated = new Map<String, sobject>();
  for(String key :MapOfData.Keyset())
  {
  string data = JSON.serialize(MapOfData.get(key));
  MapOfDataUpdated.put(key,(sobject)JSON.deserialize(data,sobject.class));
  
  }
  system.debug('Handler '+ caseQuoteAutomationList[0].Handler__c);
  system.debug('Next Event '+ caseQuoteAutomationList[0].Next_Event__c);
  
    
    String handler = caseQuoteAutomationList[0].Handler__c;
    
    IHandler handle = (IHandler)Type.forName(handler).newInstance();
    
   Map<string,sobject> result = handle.execute(MapOfDataUpdated);
   system.debug('Result '+ result);
   
    if(caseQuoteAutomationList[0].Next_Event__c !=null && caseQuoteAutomationList[0].Next_Event__c != '' && result != null) {
    List<CasetoQuoteAutomation__e> events = new List<CasetoQuoteAutomation__e>();
    CasetoQuoteAutomation__e CaseAutomationPEObj  = new CasetoQuoteAutomation__e();
    CaseAutomationPEObj.EventType__c =caseQuoteAutomationList[0].Next_Event__c;
    CaseAutomationPEObj.PayLoad__c = JSON.serialize(result);
    events.add(CaseAutomationPEObj);
    List<Database.SaveResult> results = EventBus.publish(events);
    }
  }
  catch (Exception ex) {
      system.debug(ex.getMessage());
  }
    
    
}