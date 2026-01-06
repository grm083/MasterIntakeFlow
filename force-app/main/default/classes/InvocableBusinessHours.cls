public class InvocableBusinessHours {
    
    @InvocableMethod(label='Calculate Business Hour Offset' 
                     description='Returns the desired due date/time considering Business Hours' 
                     category='Quote')
    public static List<DateTime> calculateBusinessTime(List<InvocableBusinessHours.QuoteFollowUpParameters> delayParams) {
        
        List<DateTime> followUpTimes = new List<DateTime>();
        
        BusinessHours bh = [select Id from BusinessHours where Name =: Constant_Util.BUSINESSNAME];
        
        for (QuoteFollowUpParameters x : delayParams) {
            if (date.Today().daysBetween(x.quoteStartDate) > 45 && Constant_Util.QUOTE_PRODUCT_CONFIGURED.equalsIgnoreCase(x.quoteStatus)) {
                Date targetDate = x.quoteStartDate - 45;
                DateTime followUp = BusinessHours.nextStartDate(bh.Id, targetDate);
                followupTimes.add(followUp);
            } else {
                System.debug('x.delayMinutes====>'+x.delayMinutes);
                DateTime followUp = BusinessHours.add(bh.Id, Datetime.Now(), (x.delayMinutes * 60000));
                followUpTimes.add(followUp);
            }
        }
        
        return followUpTimes;
        
    }
    
    public class QuoteFollowUpParameters {
        @AuraEnabled @InvocableVariable public Date quoteStartDate;
        @AuraEnabled @InvocableVariable public String quoteStatus;
        @AuraEnabled @InvocableVariable public Integer delayMinutes;
    }
    
}