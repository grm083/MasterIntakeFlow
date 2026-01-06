/*
* @vendor			 TCS
* @story		   	 SDT-44716
* @author			 Seema Dhikale
* @description       This class will be used for Alternate Services
* @covered by        AlternateServiceControlllerTest 
*/
public class AlternateServiceController {
    /*
* @Method Name    : getQuoteDetails
* @author         : Toshender SDT-44716
* @description    : This method is a supporing method to remove attributes node from JSON which is not needed and will take some space
* @Covered by 	  : AlternateServiceController.Test.testPopulateSysdefaultFieldForQLsUpdateEquipmentSizeForCSRUser()
* */
    public static String removeAttributesNode(String jsonString) {
        String regexPattern = '\"attributes\":\\s*\\{[^}]+\\},';
        Pattern regex = Pattern.compile(regexPattern);
        Matcher matcher = regex.matcher(jsonString);
        return matcher.replaceAll('');
    }
    
        /*
* @Method Name    : getQuoteDetails
* @author         : Toshender SDT-44716
* @description    : This method is will get called from QuoteLineTriggerHelper.PopulateSysdefaultFieldForQLs()
* @Covered by 	  : AlternateServiceController.testPopulateSysdefaultFieldForQLsUpdateEquipmentSizeForCSRUser()
* */
    public static string frameSysFieldqLine(SBQQ__QuoteLine__c qlObj){
        String jsonQuoteLineRecord = '';
        if(qlObj!=null){
            jsonQuoteLineRecord = JSON.Serialize(qlObj);
            jsonQuoteLineRecord = removeAttributesNode(jsonQuoteLineRecord);
        }
        return jsonQuoteLineRecord;
    }
    /*
* @Method Name    : getQuoteDetails
* @author         : Toshender SDT-44716
* @description    : This method is will get called from GetDetails.getConfigData()
* @Covered by 	  : AlternateServiceController.testPopulateSysdefaultFieldForQLsUpdateEquipmentSizeForCSRUser()
* */
    public static SBQQ__QuoteLine__c getDraftAlternateServiceDetails(string sysHistoryTrackingFeild){
        SBQQ__QuoteLine__c qlObj = new SBQQ__QuoteLine__c();
        if(sysHistoryTrackingFeild!='' && sysHistoryTrackingFeild!=null){
            qlObj =  (SBQQ__QuoteLine__c) JSON.deserialize(sysHistoryTrackingFeild, SBQQ__QuoteLine__c.class); 
        }
        return qlobj;
    }
}