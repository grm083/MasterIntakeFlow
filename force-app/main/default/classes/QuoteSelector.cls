// Selector for Querying Quotes
public class QuoteSelector {
	// Object API name
    public static string ObjectName = 'SBQQ__Quote__c';

    // Return Quote with Parent Bundle with Fieldset as the fields. This used to update the 
    // Newly created lines as part of SDT-31110. which requires child QL to have values of the field in fieldset
    // to be copied from Parent bundle QL record.
    public static List<SBQQ__Quote__c> getQuoteWithParentBundle(Set<Id> quoteIds, Set<Id> newQLsRequiredByIds){
       Set<string> fieldsName = FieldSetReader.readFieldSet(QuoteLineSelector.Fields_To_Copy_From_Bundle,QuotelineSelector.ObjectName);
 	   //System.debug('fieldsName ' +fieldsName);
        // Changes for SDT-31110
        // SDT 39669 SBQQ__Type__c
        string query = 'Select Id,Duration__c,SBQQ__Account__c, SBQQ__StartDate__c,SBQQ__EndDate__c,'+
            ' Case_Reason__c, RecordType.DeveloperName, SBQQ__Opportunity2__r.Case__r.RecordType.DeveloperName, SBQQ__Type__c, (Select ' 
            +  string.join(fieldsName, ',')
            + ' , SBQQ__RequiredBy__c, SBQQ__RequiredBy__r.SBQQ__RequiredBy__c, Name, Id from SBQQ__lineitems__r where SBQQ__RequiredBy__c = NULL OR Id IN: newQLsRequiredByIds )'
            + ' from SBQQ__Quote__c where Id IN : quoteIds'
            ; 

        
       return (List<SBQQ__Quote__c>) Database.query(query); 
       /*return  [Select Id,Duration__c,SBQQ__Account__c, SBQQ__StartDate__c,
                                         SBQQ__EndDate__c, Case_Reason__c, RecordType.DeveloperName, SBQQ__Opportunity2__r.Case__r.RecordType.DeveloperName
                                         , (Select Id from SBQQ__lineitems__r where SBQQ__RequiredBy__c = NULL limit 1)
                                         
                                         from SBQQ__Quote__c 
                                         where Id IN : quoteIds];*/
        
        
    }
}