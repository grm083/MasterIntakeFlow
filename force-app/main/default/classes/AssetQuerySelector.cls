//Toshender Kumar
//Query Asset object
public class AssetQuerySelector {

    // Get Aggregated Max start and end date of the Asset lines
    public static AggregateResult[] getMaxStartOrEndDate(Id parentAssetId){
        
        return [Select Max(Start_Date__c) start , Max(End_Date__c) end from Asset 
                             
                             where 
                             ParentId=:parentAssetId	
                             group by ParentId
                             Limit 1];
    }
    
    //TCS-pkulkarn-SDT-42417-20-Nov-2024-Added to convert a String Array to a delimiter separated string
    //Caller: CaseController.updateCase()
    //Caller: AssetHeadersForCaseController.replaceAssetHeader()
    public static String covertStringArrayToDelimiterSeparatedString(String[] inputStringArray, String delimiterCharacter)
    {
        return (String.join(inputStringArray, delimiterCharacter));
    }
}