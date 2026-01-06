/*
Use of Class : This class will be ue as Selector class for Product Rule related Object
Generally Service class should call to Query Selector class 
*/
public class SBQQConfigurationRuleSelector {

    //Get Configuration Product Rule by Product Id
    public static List<SBQQ__ConfigurationRule__c> getConfigurationRuleByProductId(Id productId) {
        return [SELECT Id, SBQQ__Product__c, SBQQ__ProductRule__c
        FROM SBQQ__ConfigurationRule__c
        WHERE SBQQ__Product__c =: productId AND SBQQ__Active__c = TRUE];
    }

    //Get Error Condition by Product Rule Id
    public static List<SBQQ__ErrorCondition__c> getErrorCondition(Set<Id> ruleIds)
    {
        return [SELECT Id, SBQQ__Rule__c, SBQQ__TestedField__c, SBQQ__Operator__c, SBQQ__FilterType__c, SBQQ__FilterValue__c
                          FROM SBQQ__ErrorCondition__c
                          WHERE SBQQ__Rule__c IN: ruleIds AND SBQQ__Operator__c = 'equals'];
    }

    //Get Product Action by Product Rule Id
    public static List<SBQQ__ProductAction__c> getActionByRule(Set<Id> ruleIds)
    {
        return [SELECT Id, SBQQ__Rule__c, SBQQ__Product__c
                FROM SBQQ__ProductAction__c
                WHERE SBQQ__Rule__c IN: ruleIds AND SBQQ__Type__c = 'Add'];
    }
}