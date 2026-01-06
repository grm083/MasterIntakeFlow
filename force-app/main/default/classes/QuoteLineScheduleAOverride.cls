/*
* @Name          QuoteLineScheduleAOverride
* @Author        Pavankumar Kulkarni
* @Vendor        TCS
* @Date          29/02/2024
* @description   This class will be used to collate all the functionality related to Quote Line Field ScheduleAOverride, SDT-36171
*/
public class QuoteLineScheduleAOverride {

    // Method: setValueOnScheduleAOverrideFieldOnQuoteLine
    // Usage : To update the field ScheduleAOverride__c either from Asset (Service Detail/Service Header) and from Parent Quote Line (Bundle) on the child line (Waste Stream/Waste Category etc)
    // Input : Mainly the quote line (quoteline), other inputs are supporting variables
    // Output : Mainly the quote line (quoteline)
    // Caller : AssetQuoteProcurementController.ConvertAssetToQuoteLineUpdated()
    // Test class: This method is covered by AssetQuoteProcurementControllerTest.testScheduleAOverrideFieldDefaults
    public static void setValueOnScheduleAOverrideFieldOnQuoteLine(Boolean isChildQL, Boolean isAssetDetail, SBQQ__QuoteLine__c quoteline, SBQQ__QuoteLine__c parentquoteline, Asset asset, List<Schema.PicklistEntry> scheduleAOverrideEntries)
    {
        String fieldValue = '';
        
        if(isChildQL && !isAssetDetail && parentquoteline.ScheduleAOverride__c != null && parentquoteline.ScheduleAOverride__c != '')
        {
            quoteline.ScheduleAOverride__c = parentquoteline.ScheduleAOverride__c;
        }
        else if(asset != null)
        {
            fieldValue = UTIL_Picklist.getPicklistEntryByLabel(scheduleAOverrideEntries, asset.Schedule_A_Override__c);
            if(fieldValue!= null && fieldValue != '')
            {
                quoteline.ScheduleAOverride__c = fieldValue;
            }
        }
    }
}