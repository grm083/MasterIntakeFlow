/*
* @Name          STPCriteriaSelector
* @Author        Digdershika Ojha
* @Vendor		 TCS
* @Date          24/02/2023
* @LastModifiedDate 07/11/2023
* @LastModifiedBy   Digdershika Ojha
* @description	 This class will be used as Selector class for STPCriteria__c Object, story SDT-26174
*/
public with sharing class STPCriteriaSelector {
    
    /*
	* @Method Name    : getRecordByMatchingQuote
	* @description    : Fetch list of STP_Criteria__c usually called StpRules based on
	* Active__c, Service_Type__c, Equipment__c, Material__c, Duration__c and Frequency__c
	* @param          : recordType of type String example New Service Case
	* @param          : quoteLineProductMap of type Map<Id,string> example Open Top
	* @param          : quotLineMaterialMap of type Map<Id,string> example Trash
    * @param          : quotLineOccuranceTypeMap of type Map<Id,string> example on-call
	* @param		  : duration of type String example Temporary
    * @param		  : stpEligibilityRecType of type String, a record type
	* @return         : a list of 'STP_Criteria__c'
	*/
    public static List<STP_Criteria__c> getRecordByMatchingQuote(String recordType, Map<Id,string> quoteLineProductMap, Map<Id,string> quotLineMaterialMap, Map<Id, String> duration, Map<Id,string> quotLineOccuranceTypeMap, String stpEligibilityRecType, String STPType)
    {

 		List<STP_Criteria__c> rules = new List<STP_Criteria__c>();
        Set<String> quoteLineProductMapValues = new Set<String>(quoteLineProductMap.values());
        String materialValues= '(\'' + String.join(quotLineMaterialMap.values(), '\',\'') + '\')';
        String durationValues = '(\'' + String.join(duration.values(), '\',\'') + '\')';
        String frequencyValues =  '(\'' + String.join(quotLineOccuranceTypeMap.values(), '\',\'') + '\')';
      
        String query = 'select id,Customer__c, Customer_All__c, Customer_Included__c, Duration__c, Equipment__c, Frequency__c, Material__c, Service_Type__c, Parent_VID__c, Active__c, Name,MAS__c,Customer_Included_Canada__c,Customer_All_Canada__c,Customer_Canada__c, STP_Type__c, All_WM_Vendors__c, WM_Vendor__c, Parent_Non_Parent_VID_s__c, All_3rd_Party_Vendor__c, Child_VID_Check_Include_Uncheck_Exclude__c, Market_Type__c, Applicable_Priority__c from STP_Criteria__c where Active__c = true';
		query += ' and STP_Type__c = ';
        query += ':STPType';
        query += ' and Material__c INCLUDES '+materialValues;
        query += ' and Frequency__c includes ' + frequencyValues;
        query += ' and toLabel(Duration__c) includes '+ durationValues;
        query += ' and Service_Type__c =';
        query += ':recordType';
        query += ' and Equipment__c IN';
        query += ':quoteLineProductMapValues';
        //system.debug('query '+ query);
        rules = Database.query(query);
        
        return rules;        
            
       
    }
    
    /*public static List<STP_Criteria__c> getRecordByMatchingQuoteBulk(Map<Id,string> recordTypeMap, Map<Id,string> quoteLineProductMap, Map<Id,string> quotLineMaterialMap, Map<Id,String> duration, Map<Id,string> quotLineOccuranceTypeMap, String stpEligibilityRecType)
    {
        return [select id,Customer__c, Customer_All__c, Customer_Included__c, Duration__c,
                Equipment__c, Frequency__c, Material__c, Service_Type__c,
                Parent_VID__c,Active__c, Name,MAS__c,Customer_Included_Canada__c,Customer_All_Canada__c,Customer_Canada__c
                from STP_Criteria__c where 
                Active__c= true and 
                Service_Type__c IN: recordTypeMap.values() and
                Equipment__c IN: quoteLineProductMap.values() and
                Material__c IN:quotLineMaterialMap.values() and
                //toLabel(Duration__c) IN:duration.values() and
                toLabel(Duration__c) IN:duration.values() and
                Frequency__c IN: quotLineOccuranceTypeMap.values() and
                recordtype.name =:stpEligibilityRecType];
    }*/

    /*
	* @Method Name    : getSTPExemptionRecord
	* @description    : Fetch list of STP_Criteria__c of type 'Client Pricing Exemption' for a client
	* @param          : recordType of type String example Client Pricing Exemption
	* @param          : parentAccountCustomerCode of type String example HMD
	* @return         : a list of 'STP_Criteria__c'
	*/
    /*public static List<STP_Criteria__c> getSTPExemptionRecord(String recordType, String parentAccountCustomerCode)
    {
        return [select ID, Parent_Account__c, Zero_Cost_Price_Allowed__c , Parent_Account__r.Customer_Code__c
                from STP_Criteria__c where recordtype.name =:recordType
                 and  Parent_Account__r.Customer_Code__c =:parentAccountCustomerCode
                 and Active__c = true];
    }*/
    public static List<STP_Criteria__c> getSTPExemptionRecord(String recordType, String parentAccountCustomerCode,
                                                                 Map<Id,String> durationMap,
                                                                 Map<Id, string> quoteLineProductMap)
    {
        List<STP_Criteria__c> rules = new List<STP_Criteria__c>();
        Set<String> quoteLineProductMapValues = new Set<String>(quoteLineProductMap.values());
        String durationValues = '(\'' + String.join(durationMap.values(), '\',\'') + '\')';//MultiSelect
        
        String query = 'select Id, Parent_Account__c, Zero_Cost_Price_Allowed__c , Parent_Account__r.Customer_Code__c, Duration__c, Equipment__c,Market_Type__c,Eligible_Vendor__c from STP_Criteria__c where Active__c = true';
        query += ' and Parent_Account__r.Customer_Code__c =';
        query += ':parentAccountCustomerCode';
        query += ' and toLabel(Duration__c) includes '+ durationValues;
        query += ' and RecordType.Name =';
        query += ':recordType';
        query += ' and Equipment__c IN ';
        query += ':quoteLineProductMapValues';
        //query += ' and Market_Type__c IN';
        //query += ':setOfqlConfigValues';
        //system.debug('query '+ query);
        rules = Database.query(query);
        
        return rules;  
    }

    /*
    public static List<STP_Criteria__c> getSTPExemptionRecordBulk(String recordType, String parentAccountCustomerCode,Map<Id, string> customerCodeMap)
    {
        return [select ID, Parent_Account__c, Zero_Cost_Price_Allowed__c , Parent_Account__r.Customer_Code__c
                from STP_Criteria__c where recordtype.name =:recordType
                 and  Parent_Account__r.Customer_Code__c IN: customerCodeMap.values()
                 and Active__c = true];
    }*/
}