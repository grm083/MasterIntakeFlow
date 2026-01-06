/**************************************************
* CreatedDate:15/03/2022
* Created by : Anup Dey
* Comment: Calculate Quote Priority to be used in Quote Status Change Flow
* **************************************************/
global class CalculateQuotePriority {

    //input details that comes to apex from flow
	 global class FlowInputsForQuotePriority{
        @InvocableVariable
        public String quoteId;
         
        @InvocableVariable
        public Datetime startDate;
    }

    @InvocableMethod(label='GetQuotePriority' description='Returns the list days')
    public static List<Integer> GetQuotePriority(List<FlowInputsForQuotePriority> request) {
        List<Integer> results= new List<Integer>();
        try {
            Set<Id> quoteIds = new Set<Id>();
            if(!request.isEmpty())
			{
                BusinessDays bd = new BusinessDays();
                for(FlowInputsForQuotePriority quoteflow: request)
                {
                    
                    if(!string.isEmpty(quoteflow.quoteId))
                    {
                        //system.debug('quoteflow.startDate>>'+ quoteflow.startDate);
                        //system.debug('Date.today>>'+ Date.today());
                        Integer noOfDays = bd.getNoOfDaysfromCurrentDate(quoteflow.startDate);
                        results.add(noOfDays);
                    }
                }
            }
        } catch (Exception ex) {
            system.debug('>>>Exception-->error in GetQuotePriority: ' + ex.getMessage());
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(),UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
            if(request.size() != results.size())
			 {
                Integer notProcessedRecords =request.size() - results.size();
                for(Integer i=0; i < notProcessedRecords; i++) {
					results.add(Null);
				 }
             }
        }
        return results;
    }
}