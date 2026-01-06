@isTest
public with sharing class ProductRulesExecutorTest {
    @testSetup public static void setupData() {
        List<Product2> prodList = new List<Product2>();
        Product2 container = new Product2(Name = 'Open Top', Family = 'Equipment', ProductCode = 'OT');
        Product2 dumpster = new Product2(Name = 'Dumpster', Family = 'Rolloff', ProductCode = 'DMP');
        Product2 compactor = new Product2(Name = 'Compactor', Family = 'Commercial', ProductCode = 'CMP');
        Product2 toter = new Product2(Name = 'Toter', Family = 'Commercial', ProductCode = 'TOT');
        prodList.add(container);
        prodList.add(dumpster);
        prodList.add(compactor);
        prodList.add(toter);
        insert prodList;
        List<SBQQ__ProductRule__c> prodRuleList= new List<SBQQ__ProductRule__c>();
        SBQQ__ProductRule__c prodRule = new SBQQ__ProductRule__c(Name = 'Make Product description mandatory', SBQQ__Scope__c= 'Product', SBQQ__Active__c =true, SBQQ__Type__c ='Validation',SBQQ__EvaluationEvent__c ='Save',SBQQ__AdvancedCondition__c= '( 10 AND 20 )',SBQQ__ConditionsMet__c = 'All',SBQQ__ErrorMessage__c='Description of Waste is mandatory for the selected Waste Stream',SBQQ__EvaluationOrder__c=1);
        SBQQ__ProductRule__c prodRule1 = new SBQQ__ProductRule__c(Name = 'Make Product description mandatory test', SBQQ__Scope__c= 'Product', SBQQ__Active__c =true, SBQQ__Type__c ='Validation',SBQQ__EvaluationEvent__c ='Save',SBQQ__AdvancedCondition__c= '( 30 AND 40 )',SBQQ__ConditionsMet__c = 'All',SBQQ__ErrorMessage__c='Description of Waste is mandatory for the selected Waste Stream test',SBQQ__EvaluationOrder__c=2);
        SBQQ__ProductRule__c prodRule2 = new SBQQ__ProductRule__c(Name = 'Make Product description mandatory test test', SBQQ__Scope__c= 'Product', SBQQ__Active__c =true, SBQQ__Type__c ='Validation',SBQQ__EvaluationEvent__c ='Save',SBQQ__AdvancedCondition__c= '( 50 AND 60 )',SBQQ__ConditionsMet__c = 'Any',SBQQ__ErrorMessage__c='Description of Waste is mandatory for the selected Waste Stream test test',SBQQ__EvaluationOrder__c=3);
        prodRuleList.add(prodRule);
        prodRuleList.add(prodRule1);
        prodRuleList.add(prodRule2);
        SBQQ__ProductRule__c prodRule3 = new SBQQ__ProductRule__c(Name = 'test', SBQQ__Scope__c= 'Product', SBQQ__Active__c =true, SBQQ__Type__c ='Validation',SBQQ__EvaluationEvent__c ='Save',SBQQ__AdvancedCondition__c= '( 70 AND 80 )',SBQQ__ConditionsMet__c = 'All',SBQQ__ErrorMessage__c='test',SBQQ__EvaluationOrder__c=4);
      	SBQQ__ProductRule__c prodRule4 = new SBQQ__ProductRule__c(Name = 'test test', SBQQ__Scope__c= 'Product', SBQQ__Active__c =true, SBQQ__Type__c ='Validation',SBQQ__EvaluationEvent__c ='Save',SBQQ__AdvancedCondition__c= '( 90 AND 100 )',SBQQ__ConditionsMet__c = 'All',SBQQ__ErrorMessage__c='test test',SBQQ__EvaluationOrder__c=5);
        SBQQ__ProductRule__c prodRule5 = new SBQQ__ProductRule__c(Name = 'test test test', SBQQ__Scope__c= 'Product', SBQQ__Active__c =true, SBQQ__Type__c ='Validation',SBQQ__EvaluationEvent__c ='Save',SBQQ__AdvancedCondition__c= '( 110 AND 120 )',SBQQ__ConditionsMet__c = 'Any',SBQQ__ErrorMessage__c='test test test',SBQQ__EvaluationOrder__c=6);
        SBQQ__ProductRule__c prodRule6 = new SBQQ__ProductRule__c(Name = 'Make Product description mandatory test test test test', SBQQ__Scope__c= 'Product', SBQQ__Active__c =true, SBQQ__Type__c ='Validation',SBQQ__EvaluationEvent__c ='Save',SBQQ__AdvancedCondition__c= '( 130 AND 140 )',SBQQ__ConditionsMet__c = 'Any',SBQQ__ErrorMessage__c='Description of Waste is mandatory for the selected Waste Stream test test test test',SBQQ__EvaluationOrder__c=7);
        prodRuleList.add(prodRule3);
        prodRuleList.add(prodRule4);
        prodRuleList.add(prodRule5);
        prodRuleList.add(prodRule6);
        insert prodRuleList;

        List<SBQQ__ConfigurationRule__c> configRuleList =new List<SBQQ__ConfigurationRule__c>();
        configRuleList.add(new SBQQ__ConfigurationRule__c(SBQQ__Active__c = true, SBQQ__Product__c = container.Id, SBQQ__ProductRule__c=prodRule.Id));
        configRuleList.add(new SBQQ__ConfigurationRule__c(SBQQ__Active__c = true, SBQQ__Product__c = dumpster.Id, SBQQ__ProductRule__c=prodRule1.Id));
        configRuleList.add(new SBQQ__ConfigurationRule__c(SBQQ__Active__c = true, SBQQ__Product__c = compactor.Id, SBQQ__ProductRule__c=prodRule2.Id));
        configRuleList.add(new SBQQ__ConfigurationRule__c(SBQQ__Active__c = true, SBQQ__Product__c = container.Id, SBQQ__ProductRule__c=prodRule3.Id));
        configRuleList.add(new SBQQ__ConfigurationRule__c(SBQQ__Active__c = true, SBQQ__Product__c = dumpster.Id, SBQQ__ProductRule__c=prodRule4.Id));
        configRuleList.add(new SBQQ__ConfigurationRule__c(SBQQ__Active__c = true, SBQQ__Product__c = compactor.Id, SBQQ__ProductRule__c=prodRule5.Id));
        configRuleList.add(new SBQQ__ConfigurationRule__c(SBQQ__Active__c = true, SBQQ__Product__c = toter.Id, SBQQ__ProductRule__c=prodRule6.Id));
        insert configRuleList;

        List<SBQQ__ErrorCondition__c> errorCondList = new List<SBQQ__ErrorCondition__c>();
        errorCondList.add(new SBQQ__ErrorCondition__c(SBQQ__FilterType__c = 'Value', SBQQ__FilterValue__c = 'Metal',  SBQQ__Index__c =20, SBQQ__Operator__c = 'equals', SBQQ__Rule__c = prodRule.Id, SBQQ__TestedField__c ='Optional_Product__c', SBQQ__TestedObject__c='Product Option'));
        errorCondList.add(new SBQQ__ErrorCondition__c(SBQQ__FilterType__c = 'Value', SBQQ__Index__c =10, SBQQ__Operator__c = 'equals', SBQQ__Rule__c = prodRule.Id, SBQQ__TestedField__c ='Description_of_Waste__c', SBQQ__TestedObject__c='Configuration Attributes'));
        errorCondList.add(new SBQQ__ErrorCondition__c(SBQQ__FilterType__c = 'Value', SBQQ__FilterValue__c = 'Metal',  SBQQ__Index__c =30, SBQQ__Operator__c = 'equals', SBQQ__Rule__c = prodRule1.Id, SBQQ__TestedField__c ='Optional_Product__c', SBQQ__TestedObject__c='Product Option'));
        errorCondList.add(new SBQQ__ErrorCondition__c(SBQQ__FilterType__c = 'Value', SBQQ__Index__c =40, SBQQ__Operator__c = 'equals', SBQQ__Rule__c = prodRule1.Id, SBQQ__TestedField__c ='Description_of_Waste__c', SBQQ__TestedObject__c='Configuration Attributes'));
        errorCondList.add(new SBQQ__ErrorCondition__c(SBQQ__FilterType__c = 'Value', SBQQ__FilterValue__c = 'Metal',  SBQQ__Index__c =50, SBQQ__Operator__c = 'equals', SBQQ__Rule__c = prodRule2.Id, SBQQ__TestedField__c ='Optional_Product__c', SBQQ__TestedObject__c='Product Option'));
        errorCondList.add(new SBQQ__ErrorCondition__c(SBQQ__FilterType__c = 'Value', SBQQ__Index__c =60, SBQQ__Operator__c = 'equals', SBQQ__Rule__c = prodRule2.Id, SBQQ__TestedField__c ='Description_of_Waste__c', SBQQ__TestedObject__c='Configuration Attributes'));
        errorCondList.add(new SBQQ__ErrorCondition__c(SBQQ__FilterType__c = 'Value', SBQQ__FilterValue__c = 'Metal',  SBQQ__Index__c =70, SBQQ__Operator__c = 'equals', SBQQ__Rule__c = prodRule3.Id, SBQQ__TestedField__c ='Optional_Product__c', SBQQ__TestedObject__c='Product Option'));
        errorCondList.add(new SBQQ__ErrorCondition__c(SBQQ__FilterType__c = 'Value', SBQQ__Index__c =80, SBQQ__Operator__c = 'equals', SBQQ__Rule__c = prodRule3.Id, SBQQ__TestedField__c ='Description_of_Waste__c', SBQQ__TestedObject__c='Configuration Attributes'));
        errorCondList.add(new SBQQ__ErrorCondition__c(SBQQ__FilterType__c = 'Value', SBQQ__FilterValue__c = 'Metal',  SBQQ__Index__c =90, SBQQ__Operator__c = 'equals', SBQQ__Rule__c = prodRule4.Id, SBQQ__TestedField__c ='Optional_Product__c', SBQQ__TestedObject__c='Product Option'));
        errorCondList.add(new SBQQ__ErrorCondition__c(SBQQ__FilterType__c = 'Value', SBQQ__Index__c =100, SBQQ__Operator__c = 'equals', SBQQ__Rule__c = prodRule4.Id, SBQQ__TestedField__c ='Description_of_Waste__c', SBQQ__TestedObject__c='Configuration Attributes'));
        errorCondList.add(new SBQQ__ErrorCondition__c(SBQQ__FilterType__c = 'Value', SBQQ__FilterValue__c = 'Metal',  SBQQ__Index__c =110, SBQQ__Operator__c = 'equals', SBQQ__Rule__c = prodRule5.Id, SBQQ__TestedField__c ='Optional_Product__c', SBQQ__TestedObject__c='Product Option'));
        errorCondList.add(new SBQQ__ErrorCondition__c(SBQQ__FilterType__c = 'Value', SBQQ__Index__c =120, SBQQ__Operator__c = 'equals', SBQQ__Rule__c = prodRule5.Id, SBQQ__TestedField__c ='Description_of_Waste__c', SBQQ__TestedObject__c='Configuration Attributes')); 
        errorCondList.add(new SBQQ__ErrorCondition__c(SBQQ__FilterType__c = 'Value', SBQQ__FilterValue__c = 'Metal',  SBQQ__Index__c =130, SBQQ__Operator__c = 'equals', SBQQ__Rule__c = prodRule6.Id, SBQQ__TestedField__c ='Optional_Product__c', SBQQ__TestedObject__c='Product Option'));
        errorCondList.add(new SBQQ__ErrorCondition__c(SBQQ__FilterType__c = 'Value', SBQQ__Index__c =140, SBQQ__Operator__c = 'equals', SBQQ__Rule__c = prodRule6.Id, SBQQ__TestedField__c ='Description_of_Waste__c', SBQQ__TestedObject__c='Configuration Attributes')); 
        insert errorCondList;

        List<SBQQ__ProductRule__c> updateProdRule = new List<SBQQ__ProductRule__c>();
        prodRule.SBQQ__ConditionsMet__c = 'Custom';
        updateProdRule.add(prodRule);
        prodRule3.SBQQ__ConditionsMet__c = 'Custom';
        updateProdRule.add(prodRule3);
        update updateProdRule;
    }

    @isTest public static void executeProductRuleTestForCustom(){

        Id productId = [SELECT Id FROM Product2 WHERE Name = 'Open Top' LIMIT 1].Id;
        Test.startTest();
            List<ProductRulesExecutor.ErrorConditionsModal> errCondModalList = new List<ProductRulesExecutor.ErrorConditionsModal>();
            ProductRulesExecutor.ErrorConditionsModal errorConditionsObj =  new ProductRulesExecutor.ErrorConditionsModal();
            errorConditionsObj.testedObject = 'Configuration Attributes';
            errorConditionsObj.testedField = 'Description_of_Waste__c';
            errorConditionsObj.testedValue = null;
            errorConditionsObj.testedValueType = 'String';
            errCondModalList.add(errorConditionsObj);

            ProductRulesExecutor.ErrorConditionsModal errorConditionsObj1 =  new ProductRulesExecutor.ErrorConditionsModal();
            errorConditionsObj1.testedObject = 'Product Option';
            errorConditionsObj1.testedField = 'Optional_Product__c';
            errorConditionsObj1.testedValue = 'Metal';
            errorConditionsObj1.testedValueType = 'String';
            errCondModalList.add(errorConditionsObj1);

            Map<String,List<String>> resultErrorMap = ProductRulesExecutor.executeProductRule(productId,errCondModalList);
        Test.stopTest();
    }

    @isTest public static void executeProductRuleTestForAll(){

        Id productId = [SELECT Id FROM Product2 WHERE Name = 'Dumpster' LIMIT 1].Id;
        Test.startTest();
            List<ProductRulesExecutor.ErrorConditionsModal> errCondModalList = new List<ProductRulesExecutor.ErrorConditionsModal>();
            ProductRulesExecutor.ErrorConditionsModal errorConditionsObj =  new ProductRulesExecutor.ErrorConditionsModal();
            errorConditionsObj.testedObject = 'Configuration Attributes';
            errorConditionsObj.testedField = 'Description_of_Waste__c';
            errorConditionsObj.testedValue = null;
            errorConditionsObj.testedValueType = 'String';
            errCondModalList.add(errorConditionsObj);

            ProductRulesExecutor.ErrorConditionsModal errorConditionsObj1 =  new ProductRulesExecutor.ErrorConditionsModal();
            errorConditionsObj1.testedObject = 'Product Option';
            errorConditionsObj1.testedField = 'Optional_Product__c';
            errorConditionsObj1.testedValue = 'Metal';
            errorConditionsObj1.testedValueType = 'String';
            errCondModalList.add(errorConditionsObj1);

            Map<String,List<String>> resultErrorMap = ProductRulesExecutor.executeProductRule(productId,errCondModalList);
        Test.stopTest();
    }

    @isTest public static void executeProductRuleTestForAny(){

        Id productId = [SELECT Id FROM Product2 WHERE Name = 'Compactor' LIMIT 1].Id;
        Test.startTest();
            List<ProductRulesExecutor.ErrorConditionsModal> errCondModalList = new List<ProductRulesExecutor.ErrorConditionsModal>();
            ProductRulesExecutor.ErrorConditionsModal errorConditionsObj =  new ProductRulesExecutor.ErrorConditionsModal();
            errorConditionsObj.testedObject = 'Configuration Attributes';
            errorConditionsObj.testedField = 'Description_of_Waste__c';
            errorConditionsObj.testedValue = null;
            errorConditionsObj.testedValueType = 'String';
            errCondModalList.add(errorConditionsObj);

            ProductRulesExecutor.ErrorConditionsModal errorConditionsObj1 =  new ProductRulesExecutor.ErrorConditionsModal();
            errorConditionsObj1.testedObject = 'Product Option';
            errorConditionsObj1.testedField = 'Optional_Product__c';
            errorConditionsObj1.testedValue = 'Metal';
            errorConditionsObj1.testedValueType = 'String';
            errCondModalList.add(errorConditionsObj1);

            Map<String,List<String>> resultErrorMap = ProductRulesExecutor.executeProductRule(productId,errCondModalList);
        Test.stopTest();
    }
}