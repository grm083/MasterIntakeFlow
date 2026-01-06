/**************************************************
* ClassName:GetBusinessDelayTime
* Author:Dinesh
* CreatedDate:18/2/2019
* **************************************************/
public class GetBusinessDelayTime {
    @InvocableMethod(label='Get Business ResumeTime' description='Returns the list of Business Hours Delay Resume Time to the flow.')
    public static List<DateTime> getDelayBusinessHours(List<string> rec) {    
        system.debug(rec);
        decimal decimalHours=0;
        Long intervalMilliseconds=0;
        List<String> inputlst = new List<String>();
        //Id businessHoursId = [Select id from BusinessHours where Name = : Constant_Util.BUSINESSNAME and IsActive = true LIMIT 1].Id;
        // soql 101 issue fix SDT-40083
        String Name = Constant_Util.BUSINESSNAME;
        Id businessHoursId  = SystemObjectSelector.getBusinessHoursId(Name);
        List<DateTime> delayResumeTimelst = new List<DateTime>();
        for(string input : rec){
            inputlst = input.split(Constant_Util.SEMI_COLON);
        system.debug('$$$$$ inputlst: '+inputlst); 
        DateTime baseTime = DateTime.valueOfGMT(inputlst[0]);
        system.debug('Base Time: '+baseTime);
        //decimal decimalHours = decimal.valueOf(inputlst[1])*3600000;
        //Long intervalMilliseconds = decimalHours.longValue();
        if(inputlst.size()>1){
            if(inputlst.size()==3 && inputlst[2] == 'Yes'){
            	inputlst[1] = '0';
            }
            decimalHours = decimal.valueOf(inputlst[1])*3600000;
            intervalMilliseconds = Long.valueof(string.valueof(decimalHours.round(System.RoundingMode.HALF_UP))); 
        }
        system.debug('$$$$$ intervalMilliseconds'+intervalMilliseconds);
        
        system.debug('$$$$$ BusinessHours: '+BusinessHours.add(businessHoursId,baseTime,intervalMilliseconds));
        
        delayResumeTimelst.add(BusinessHours.addGmt(businessHoursId,baseTime,intervalMilliseconds));
        system.debug('$$$$$ delayResumeTimelst: '+delayResumeTimelst);
        }
        
        return delayResumeTimelst;
    }
}