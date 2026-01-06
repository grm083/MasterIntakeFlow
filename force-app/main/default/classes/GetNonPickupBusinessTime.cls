/**************************************************
* ClassName: GetNonPickupBusinessTime
* Author: Kalaiselvi R
* CreatedDate: 21/05/2020
* **************************************************/
public class GetNonPickupBusinessTime {	
	/*
	@Description: This is get resume time with business hours for non pickup cases. this method is invoked from  
	* "Process of Non Pickup Task framework" flow and Due DateTime Population flow
	*/  
	@InvocableMethod
	public static List<DateTime> getBusinessHoursForNonPickupCases(List<FlowInputvalues> flowInputLst) {    
		List<DateTime> delayResumeTimelst = new List<DateTime>();
		for(FlowInputvalues flowInput : flowInputLst) {	
            if(flowInput.delayTimeInterval != null && flowInput.considerBusinessHours){
                decimal decimalHours = decimal.valueOf(flowInput.delayTimeInterval)*3600000;
				Long intervalMilliseconds = Long.valueof(string.valueof(decimalHours.round(System.RoundingMode.HALF_UP))); 
				delayResumeTimelst.add(BusinessHours.addGmt(flowInput.businessHoursId,flowInput.baseDateTime,intervalMilliseconds));
            } else {
				delayResumeTimelst.add(system.now().addHours(Integer.valueOf(flowInput.delayTimeInterval)));
			}
			
		}		
		return delayResumeTimelst;
	}
	// Wrapper class to get flow input variables.
	public class FlowInputvalues{
		@invocablevariable
		public string businessHoursId;

		@invocablevariable
		public DateTime baseDateTime;
		
		@invocablevariable
		public string delayTimeInterval;
		
		@invocablevariable
		public boolean considerBusinessHours;
	}
}