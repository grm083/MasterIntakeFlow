/*
Use of Class : This class will be ue as Service class for Product Object

Generally Service class should call to Query Selector class 
*/
public with sharing class ProductServices {
    
    // Constants: 
    public static final string ACTION_TYPE = 'Hide & Remove';
    public static final string TESTING_FIELD = 'Case_record_Type__c';
    

    //Author - TCS
    /* Method is used to return list of Product oprions based on Product */
    //SDT - 31122
    public static List<SBQQ__ProductOption__c> filterProductOptions(Id productId,Id quoteId) { 
                String caseRecordType;
                List<SBQQ__ProductOption__c> accessoryList = QuoteProcurementController.getAccessories(productId);
                 
                List<SBQQ__Quote__c> quoteObject = [Select id, name,Case_record_Type__c from SBQQ__Quote__c where id  = :quoteId limit 1];
                if(quoteObject.size() > 0)
                     caseRecordType = quoteObject[0].Case_record_Type__c;
            
                Set<id> ProductRuleIds = new Set<id>();
                List<SBQQ__ErrorCondition__c> errorList = SBQQConfigurationRuleService.getProductRules(productId);
                for(SBQQ__ErrorCondition__c errorObject :errorList)
                {
                System.debug('errorObject.SBQQ__FilterValue__c>>>'+errorObject.SBQQ__FilterValue__c+'>>caseRecordType'+caseRecordType);
                    if(errorObject.SBQQ__TestedField__c == TESTING_FIELD && errorObject.SBQQ__FilterValue__c == caseRecordType)
                            ProductRuleIds.add(errorObject.SBQQ__Rule__c);
                }
                //List<SBQQ__ProductAction__c> productActionList =  [Select id,SBQQ__Product__c,SBQQ__Type__c,SBQQ__Rule__c from SBQQ__ProductAction__c where SBQQ__Rule__c IN:ProductRuleIds and (SBQQ__Type__c = 'Hide & Remove' OR SBQQ__Type__c ='Show & Add')];
                List<SBQQ__ProductAction__c> productActionList =  [Select id,SBQQ__Product__c,SBQQ__Type__c,SBQQ__Rule__c from SBQQ__ProductAction__c where SBQQ__Rule__c IN:ProductRuleIds and (SBQQ__Type__c = 'Hide & Remove')];
                System.debug('productActionList>>>'+productActionList);

                for(SBQQ__ProductAction__c productActionObj :productActionList)
                {
                   // for(SBQQ__ProductOption__c productOptionObj :accessoryListIteration)
                    for (Integer i = (accessoryList.size()-1) ; i>= 0 ; i--)
                    {
                        SBQQ__ProductOption__c productOptionObj = accessoryList[i];
                        System.debug('productActionObj.SBQQ__Product__c>>>'+productActionObj.SBQQ__Product__c);
                        System.debug('SBQQ__Type__c>>>'+productActionObj.SBQQ__Type__c);
                        System.debug('productOptionObj.id>>>'+productOptionObj.id);
                       if(productActionObj.SBQQ__Type__c == ACTION_TYPE && productOptionObj.SBQQ__OptionalSKU__c == productActionObj.SBQQ__Product__c)
                        {
                            accessoryList.remove(accessoryList.indexOf(productOptionObj));
                            
                        }
                    }           
                        
                }
        return accessoryList;
    }
}