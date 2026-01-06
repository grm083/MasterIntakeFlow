/*
Use of Class : This class will be ue as Service class for Product Rule related Object
Generally Service class should call to Query Selector class 
*/
public class SBQQConfigurationRuleService {
    
    //get Product Rule by ProductId
    public static List<SBQQ__ErrorCondition__c> getProductRules(Id productId){
        
        List<SBQQ__ErrorCondition__c> errorConditions = new List<SBQQ__ErrorCondition__c>();
        Set<Id> ruleIds = new Set<Id>();

        List<SBQQ__ConfigurationRule__c> configRules = SBQQConfigurationRuleSelector.getConfigurationRuleByProductId(productId);
        
        if (configRules.size() == 0) {
            return errorConditions;
        } else {
            for (SBQQ__ConfigurationRule__c c: configRules) {
                ruleIds.add(c.SBQQ__ProductRule__c);
            }
        }
        
        errorConditions = SBQQConfigurationRuleSelector.getErrorCondition(ruleIds);

        return errorConditions;

    }

    //Get Product rule by condition
    public static Set<Id> getActions(List<SBQQ__ErrorCondition__c> conditions, SBQQ__QuoteLine__c parentLine) {
        //this set stores the field names that are not in quoteline object, but is coming in errorcondition.
        Set<String> fieldsNotInQuoteLine = new Set<String>{'Case_record_Type__c'};

        Set<Id> productRules = new Set<Id>();

        for (SBQQ__ErrorCondition__c e : conditions) {
            String checkedField = e.SBQQ__TestedField__c;
            //checking if the current checked field is not in the set that contains the fields to be bypassed.
            if(!fieldsNotInQuoteLine.contains(checkedField)) {
                String errCondField = e.SBQQ__FilterValue__c;
                Object qlFieldObject = parentLine.get(checkedField);
                String qlCondField = String.valueOf(qlFieldObject);
                if (errCondField == qlCondField) {
                    productRules.add(e.SBQQ__Rule__c);
                }
            }
        }

        return productRules;

    }

    //Get Productmactions by Rules
    public static Set<Id> getAddRuleProducts(Set<Id> rules) {

        Set<Id> addProducts = new Set<Id>();
        List<SBQQ__ProductAction__c> addActions = SBQQConfigurationRuleSelector.getActionByRule(rules);
        for (SBQQ__ProductAction__c a: addActions) {
            addProducts.add(a.SBQQ__Product__c);
        }
        return addProducts;

    }
}