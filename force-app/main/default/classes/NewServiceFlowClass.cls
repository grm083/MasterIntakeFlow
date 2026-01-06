global class NewServiceFlowClass {
  @InvocableMethod
	  global static List<DateTime> sla_delivery_DateTime_operation(List<FlowInputs> request) {
  
          List<DateTime> returnlist = new List<DateTime>(); 
          Date tempdeliveryDate= request[0].deliveryDate;
          string caseId =request[0].caseId;
          system.debug('caseid--->' + caseId);          
          system.debug('tempdeliveryDate--->' + tempdeliveryDate);
          string timezoneName = '';
          Case c = [select Location__r.tz__Timezone_SFDC__c from case where id= : caseId Limit 1];        
          Datetime DeliveryDateTime =DateTime.newInstance(0, 0, 0, 0, 0, 0);          
          Date targetDate = null;
          Time targetTime = null;          
          targetDate = Date.newInstance(tempdeliveryDate.year(), tempdeliveryDate.month(), tempdeliveryDate.day());
          targetTime = Time.newInstance(21, 0, 0, 0);
  
          try{
          DeliveryDateTime = getadditionalDate(targetDate,targetTime,c.Location__r.tz__Timezone_SFDC__c);
          system.debug('DeliveryDateTime-->' + DeliveryDateTime);
          returnlist.add(DeliveryDateTime);
          }catch(Exception ex){  
            System.debug('Exception ::: '+ ex.getMessage()+' '+ex.getLineNumber());
        }
          return returnlist;
          
      }



    private static Datetime getadditionalDate(Date targetDate,Time targetTime,String Totimezone){
        TimeZone targetTimezone;
        Integer offsetSeconds;
        DateTime additionalDate;
        
        targetTimezone = TimeZone.getTimeZone(Totimezone);
        offsetSeconds = targetTimezone.getOffset(targetDate) / 1000;
        additionalDate = Datetime.newInstanceGmt(targetDate, targetTime).addSeconds(-offsetSeconds);
        return additionalDate;
    }

         //input details that comes to apex from flow
    global class FlowInputs{
    
        @InvocableVariable
        public string caseId;
        
        @InvocableVariable
        public Date deliveryDate;
        
    }

    

}