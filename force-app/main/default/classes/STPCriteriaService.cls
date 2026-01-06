/*
* @Name          STPCriteriaService
* @Author        Digdershika Ojha
* @Vendor		  TCS
* @Date          9/02/2023
* @description	  This class will be used as Service class for STPCriteria__c Object
*  generally Service class should call to Query Selector class
*/
public with sharing class STPCriteriaService {
    /*
	* @Method Name    : getSTPRules
	* @author         : Digdershika Ojha
	* @description    : Fetch list of STP_Criteria__c usually called StpRules based on
	*  Active or Inactive, Equipment Size, material and duration
	* @param          : recordType of type String
	* @param          : quoteLineProductMap of type Map<Id,string>
	* @param          : quotLineMaterialMap of type Map<Id,string>
	* @param		  : duration of type String
	* @return         : a list of stp rules 'STP_Criteria__c'
	*/
	/*
    public static list<STP_Criteria__c> getSTPRules(String recordType, Map<Id,string> quoteLineProductMap, Map<Id,string> quotLineMaterialMap, String duration, Map<Id,string> quotLineOccuranceTypeMap)
    {
        List<STP_Criteria__c> stpRules = [select id,Customer__c, Customer_All__c, Customer_Included__c, Duration__c,
                                          Equipment__c, Frequency__c, 
                                          Material__c, Service_Type__c,Parent_VID__c,Active__c, Name,MAS__c
                                          from STP_Criteria__c where Active__c= true and 
                                          Service_Type__c=:recordType and Equipment__c IN: quoteLineProductMap.values()
                                          and Material__c IN:quotLineMaterialMap.values()
                                          and toLabel(Duration__c) =:duration and Frequency__c IN: quotLineOccuranceTypeMap.values()]; 
        return stpRules;
    }
	*/
}