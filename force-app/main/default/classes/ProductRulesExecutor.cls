/*
Module: Asset Management -CPQ
Dev: Rishi
FC: Anmoal Bharti
Description: ProductRulesExecutor is a generic class to utilize the Product Rules of Validation Type.
             ******Use ProductRulesToExclude__mdt to store the name of Product Rule which are supposed to be excluded from ProductRuleExecutor. We can make a use of Active flag of ProductRulesToExclude__mdt record to include/exclude
             the rule for ProductRuleExecutor. Once the Active flag is disabled or that particuar Product Rule is not present in ProductRulesToExclude__mdt records, rule would automatically be considered to execute for ProductRuleExecutor. We had to create this metadata as
             we are restricted to create any new custom flag/field on Product Rule to make it disable for ProductRuleExecutor but at the same time enable it for Standard Quote Editor. 
             By not using this suffix, as Active Product Rule will only be applicable for Standard Quote Editor Screen.
             executeProductRule() is the method to use for the execution of the validation functionality.
             It requires two parameters as-
                * Product Id - Product Id present on the Parent Bundle Quote Line.
                * ErrorConditionsModal - is used to fill the testedObject, testedField, testedValue, testedValueType.
             In OOB, Error Condition has multiple options of Tested Object and Tested Fields, 
             to implement the error conditions we maintain the same Tested Object and Tested Field in our ErrorConditionModal. 
             However, we need to contemplate before passing values to testedValue and testedValueType of ErrorConditionModal. Please take a help of below example.
             executeProductRule() returns the map of all the failed errors with key as 'Failed' and Values as list of validation error messages, stored in Product rules.
             IN OOB, product rules are based on Product2 records being used to create Bundle from CPQ Quote Editor. 
             However in our case we are utilizing these same product rules for Quote Lines directly. So we consider those fields of Quote Line as target values who are possibly match for Product fields.
             Example:
                List<ProductRulesExecutor.ErrorConditionsModal> errCondModalList = new List<ProductRulesExecutor.ErrorConditionsModal>();
                ProductRulesExecutor.ErrorConditionsModal errorConditionsObj =  new ProductRulesExecutor.ErrorConditionsModal();
                errorConditionsObj.testedObject = 'Configuration Attributes'; *******requires to match what object you want to test against. Should be same as in Error Conditions
                errorConditionsObj.testedField = 'Description_of_Waste__c';  ********requires what field we are validationg. Should be same as in Error Conditions.
                errorConditionsObj.testedValue = wasteDescription;    ***********Variable wasteDescription has the value of Description_of_waste entered through CEI screen.
                errorConditionsObj.testedValueType = 'String'; ***** what type of data it has. Ex: String, DateTime- YYYY-MM-DD 00:00:00,Date- YYYY-MM-DD 00:00:00, Number-Integer/Double, Boolean
                errCondModalList.add(errorConditionsObj);

                ProductRulesExecutor.ErrorConditionsModal errorConditionsObj1 =  new ProductRulesExecutor.ErrorConditionsModal();
                errorConditionsObj1.testedObject = 'Product Option';
                errorConditionsObj1.testedField = 'Optional_Product__c';
                errorConditionsObj1.testedValue = wasteStream; **************** Variable wasteStream has the value of material entered through CEI screen.
                errorConditionsObj1.testedValueType = 'String';
                errCondModalList.add(errorConditionsObj1);

                Map<String,List<String>> resultErrorMap = ProductRulesExecutor.executeProductRule(productId,errCondModalList);
                System.debug('resultErrorMap>>'+resultErrorMap);

[Update] 16-Mar-2022: Currently the class is being used for the STORY- SDT-21804. Its validating Description of waste field as per the mentioned Material Type on the CEI screen.


*/


public with sharing class ProductRulesExecutor {

    public class ProductRuleModal{
        public String productRuleType = 'Validation';
        public String eventEvaluationType = 'Save';
    }

    public class ErrorConditionsModal{
        public String testedObject;
        public String testedField; 
        public String testedValue;
        public String testedValueType;
    }

    public static void getData(Id productId, ProductRuleModal productRuleModalObj, Map<Id,SBQQ__ProductRule__c> productRuleMap, List<SBQQ__ErrorCondition__c> errorCondList){
        List<ProductRulesToExclude__mdt> excludedPRList = [SELECT Id, MasterLabel, Active__c FROM ProductRulesToExclude__mdt WHERE Active__c=true];
        Set<String> productRulesToExcludeList = new Set<String>();
        for(ProductRulesToExclude__mdt excludedObj: excludedPRList){
            productRulesToExcludeList.add(excludedObj.MasterLabel);
        }
        List<SBQQ__ConfigurationRule__c> configRulesList;
        if(!productRulesToExcludeList.isEmpty()){
            configRulesList = [SELECT Id, Name, SBQQ__Active__c, SBQQ__AscendingNestedLevel__c, SBQQ__DescendingActionNesting__c, SBQQ__DescendingNestedLevel__c, SBQQ__Product__c, SBQQ__Product__r.Name, SBQQ__ProductFeature__c, SBQQ__RuleEvaluationEvent__c, SBQQ__RuleType__c,
                                    SBQQ__ProductRule__c, SBQQ__ProductRule__r.Name, SBQQ__ProductRule__r.SBQQ__Active__c, SBQQ__ProductRule__r.SBQQ__Type__c, SBQQ__ProductRule__r.SBQQ__AdvancedCondition__c, SBQQ__ProductRule__r.SBQQ__ConditionsMet__c, SBQQ__ProductRule__r.SBQQ__ErrorMessage__c, SBQQ__ProductRule__r.SBQQ__EvaluationEvent__c, SBQQ__ProductRule__r.SBQQ__EvaluationOrder__c 
                                    FROM SBQQ__ConfigurationRule__c 
                                    WHERE SBQQ__Active__c = true AND SBQQ__Product__c =:productId 
                                    AND (NOT SBQQ__ProductRule__r.Name IN: productRulesToExcludeList) AND SBQQ__ProductRule__r.SBQQ__Active__c = true AND SBQQ__ProductRule__r.SBQQ__Type__c =: productRuleModalObj.productRuleType AND SBQQ__ProductRule__r.SBQQ__EvaluationEvent__c =: productRuleModalObj.eventEvaluationType 
                                    ORDER BY SBQQ__ProductRule__r.SBQQ__EvaluationOrder__c ASC];
        }else{
            configRulesList = [SELECT Id, Name, SBQQ__Active__c, SBQQ__AscendingNestedLevel__c, SBQQ__DescendingActionNesting__c, SBQQ__DescendingNestedLevel__c, SBQQ__Product__c, SBQQ__Product__r.Name, SBQQ__ProductFeature__c, SBQQ__RuleEvaluationEvent__c, SBQQ__RuleType__c,
                                    SBQQ__ProductRule__c, SBQQ__ProductRule__r.Name, SBQQ__ProductRule__r.SBQQ__Active__c, SBQQ__ProductRule__r.SBQQ__Type__c, SBQQ__ProductRule__r.SBQQ__AdvancedCondition__c, SBQQ__ProductRule__r.SBQQ__ConditionsMet__c, SBQQ__ProductRule__r.SBQQ__ErrorMessage__c, SBQQ__ProductRule__r.SBQQ__EvaluationEvent__c, SBQQ__ProductRule__r.SBQQ__EvaluationOrder__c 
                                    FROM SBQQ__ConfigurationRule__c 
                                    WHERE SBQQ__Active__c = true AND SBQQ__Product__c =:productId 
                                    AND SBQQ__ProductRule__r.SBQQ__Active__c = true AND SBQQ__ProductRule__r.SBQQ__Type__c =: productRuleModalObj.productRuleType AND SBQQ__ProductRule__r.SBQQ__EvaluationEvent__c =: productRuleModalObj.eventEvaluationType 
                                    ORDER BY SBQQ__ProductRule__r.SBQQ__EvaluationOrder__c ASC];
        }
        for(SBQQ__ConfigurationRule__c crObj: configRulesList){
            if(!productRuleMap.containsKey(crObj.SBQQ__ProductRule__c)){
                SBQQ__ProductRule__c prodRuleObj = new SBQQ__ProductRule__c();
                prodRuleObj.Id = crObj.SBQQ__ProductRule__c;
                prodRuleObj.Name = crObj.SBQQ__ProductRule__r.Name;
                prodRuleObj.SBQQ__Active__c = crObj.SBQQ__ProductRule__r.SBQQ__Active__c;
                prodRuleObj.SBQQ__Type__c = crObj.SBQQ__ProductRule__r.SBQQ__Type__c;
                prodRuleObj.SBQQ__AdvancedCondition__c = crObj.SBQQ__ProductRule__r.SBQQ__AdvancedCondition__c;
                prodRuleObj.SBQQ__ConditionsMet__c = crObj.SBQQ__ProductRule__r.SBQQ__ConditionsMet__c;
                prodRuleObj.SBQQ__ErrorMessage__c = crObj.SBQQ__ProductRule__r.SBQQ__ErrorMessage__c;
                prodRuleObj.SBQQ__EvaluationEvent__c = crObj.SBQQ__ProductRule__r.SBQQ__EvaluationEvent__c;
                prodRuleObj.SBQQ__EvaluationOrder__c = crObj.SBQQ__ProductRule__r.SBQQ__EvaluationOrder__c;
                productRuleMap.put(crObj.SBQQ__ProductRule__c, prodRuleObj);
            }
        }

        List<SBQQ__ErrorCondition__c> errorCondList1 = [SELECT Id, Name, SBQQ__FilterType__c, SBQQ__FilterValue__c, SBQQ__FilterVariable__c, SBQQ__Index__c, SBQQ__Operator__c, SBQQ__ParentRuleIsActive__c, SBQQ__Rule__c, SBQQ__Rule__r.Name, SBQQ__TestedAttribute__c, SBQQ__TestedField__c, SBQQ__TestedObject__c, SBQQ__TestedVariable__c FROM SBQQ__ErrorCondition__c WHERE SBQQ__Rule__c IN:productRuleMap.keySet() ORDER BY SBQQ__Index__c ASC];
        errorCondList.addAll(errorCondList1);
    }

    public static void evaluateErrorConditions(ErrorConditionsModal errorConditionsObj, List<SBQQ__ErrorCondition__c> errorCondList, Map<Id, Map<String, String>> prId_IndexErrorCondResultMap, Map<Id, List<String>> prodRuleIdErrorCondResultMap){
        for(SBQQ__ErrorCondition__c errObj: errorCondList){
            System.debug('errObj.SBQQ__TestedObject__c>>'+errObj.SBQQ__TestedObject__c+' errorConditionsObj.testedObject>>'+errorConditionsObj.testedObject);
            System.debug('errObj.SBQQ__TestedField__c>>'+errObj.SBQQ__TestedField__c+' errorConditionsObj.testedField>>'+errorConditionsObj.testedField);
            System.debug('errObj.SBQQ__FilterValue__c>>'+errObj.SBQQ__FilterValue__c+' errorConditionsObj.testedValue>>'+errorConditionsObj.testedValue);
            System.debug('errObj.SBQQ__Index__c>>'+errObj.SBQQ__Index__c);
            if(errObj.SBQQ__Index__c != null){
                ProductRulesExecutor.evaluateErrorConditionsWithIndex(errorConditionsObj, errObj, prId_IndexErrorCondResultMap);
            }
            ProductRulesExecutor.evaluateErrorConditionsWithoutIndex(errorConditionsObj, errObj, prodRuleIdErrorCondResultMap);
        }
    }
    public static void evaluateErrorConditionsWithIndex(ErrorConditionsModal errorConditionsObj, SBQQ__ErrorCondition__c errObj, Map<Id, Map<String, String>> prId_IndexErrorCondResultMap){
        if(errObj.SBQQ__TestedObject__c == errorConditionsObj.testedObject && errObj.SBQQ__TestedField__c == errorConditionsObj.testedField){
            if(prId_IndexErrorCondResultMap.containsKey(errObj.SBQQ__Rule__c)){
                Map<String, String> prodRuleIndexdErrorCondMap = prId_IndexErrorCondResultMap.get(errObj.SBQQ__Rule__c);
                if(!prodRuleIndexdErrorCondMap.containsKey(String.valueOf(errObj.SBQQ__Index__c))){
                    //String str = errorConditionsObj.testedValue == errObj.SBQQ__FilterValue__c ? 'True' :'False'; //operator expressions missing
                    String str = OperatorExpression.evaluate(errorConditionsObj.testedValue, errObj.SBQQ__Operator__c, errObj.SBQQ__FilterValue__c, errorConditionsObj.testedValueType) ? 'True' : 'False';
                    System.debug('Str2>>>'+str+'>>'+String.valueOf(errObj.SBQQ__Index__c));
                    prodRuleIndexdErrorCondMap.put(String.valueOf(errObj.SBQQ__Index__c),str);
                    prId_IndexErrorCondResultMap.put(errObj.SBQQ__Rule__c,prodRuleIndexdErrorCondMap);
                }
            }else{
                Map<String, String> prodRuleIndexdErrorCondMap = new Map<String, String>();
                //String str = errorConditionsObj.testedValue == errObj.SBQQ__FilterValue__c ? 'True' :'False'; //operator expressions missing
                String str = OperatorExpression.evaluate(errorConditionsObj.testedValue, errObj.SBQQ__Operator__c, errObj.SBQQ__FilterValue__c, errorConditionsObj.testedValueType) ? 'True' : 'False';
                System.debug('Str3>>>'+str+'>>'+String.valueOf(errObj.SBQQ__Index__c));
                prodRuleIndexdErrorCondMap.put(String.valueOf(errObj.SBQQ__Index__c),str);
                prId_IndexErrorCondResultMap.put(errObj.SBQQ__Rule__c,prodRuleIndexdErrorCondMap);
            }
        }
    }
    public static void evaluateErrorConditionsWithoutIndex(ErrorConditionsModal errorConditionsObj, SBQQ__ErrorCondition__c errObj, Map<Id, List<String>> prodRuleIdErrorCondResultMap){
        if(errObj.SBQQ__TestedObject__c == errorConditionsObj.testedObject && errObj.SBQQ__TestedField__c == errorConditionsObj.testedField){
            if(prodRuleIdErrorCondResultMap.containsKey(errObj.SBQQ__Rule__c)){
                List<String> resultsList = prodRuleIdErrorCondResultMap.get(errObj.SBQQ__Rule__c);
                //String str = errorConditionsObj.testedValue == errObj.SBQQ__FilterValue__c ? 'True' :'False'; //operator expressions missing
                String str = OperatorExpression.evaluate(errorConditionsObj.testedValue, errObj.SBQQ__Operator__c, errObj.SBQQ__FilterValue__c, errorConditionsObj.testedValueType) ? 'True' : 'False';
                resultsList.add(str);
                prodRuleIdErrorCondResultMap.put(errObj.SBQQ__Rule__c,resultsList);
            }else{
                List<String> resultsList = new List<String>();
                //String str = errorConditionsObj.testedValue == errObj.SBQQ__FilterValue__c ? 'True' :'False'; //operator expressions missing
                String str = OperatorExpression.evaluate(errorConditionsObj.testedValue, errObj.SBQQ__Operator__c, errObj.SBQQ__FilterValue__c, errorConditionsObj.testedValueType) ? 'True' : 'False';
                resultsList.add(str);
                prodRuleIdErrorCondResultMap.put(errObj.SBQQ__Rule__c,resultsList);
            }
        }
    }

    public static Map<String,List<String>> executeProductRule(Id productId, List<ErrorConditionsModal> errorCondModalList){
        System.debug('errorCondModalList>>>'+errorCondModalList);
        ProductRuleModal productRuleModalObj = new ProductRuleModal();
        Map<Id,SBQQ__ProductRule__c> productRuleMap = new Map<Id,SBQQ__ProductRule__c>();
        List<SBQQ__ErrorCondition__c> errorCondList = new List<SBQQ__ErrorCondition__c>();
        Map<String,List<String>> resultErrorMap = new Map<String,List<String>>();
        ProductRulesExecutor.getData(productId, productRuleModalObj, productRuleMap, errorCondList);

        if(!productRuleMap.values().isEmpty()){
            Map<Id, Map<String, String>> prId_IndexErrorCondResultMap = new Map<Id, Map<String, String>>(); //Prod Rule vs (index vs result)
            Map<Id, List<String>> prodRuleIdErrorCondResultMap = new Map<Id, List<String>>(); //Prod Rule vs result
            for(ErrorConditionsModal errCondModalObj: errorCondModalList){
                System.debug('errCondModalObj>>'+errCondModalObj);
                ProductRulesExecutor.evaluateErrorConditions(errCondModalObj,errorCondList,prId_IndexErrorCondResultMap,prodRuleIdErrorCondResultMap);
            }
            for(SBQQ__ProductRule__c prObj: productRuleMap.values()){
                if(prObj.SBQQ__ConditionsMet__c== 'Custom' && prObj.SBQQ__AdvancedCondition__c!= null){
                    if(prId_IndexErrorCondResultMap.containsKey(prObj.Id)){
                        Map<String, String> prodRuleIndexdErrorCondMap = prId_IndexErrorCondResultMap.get(prObj.Id);
                        Boolean b = ProductRulesExecutor.customExpressionEvaluation(prObj.SBQQ__AdvancedCondition__c,prodRuleIndexdErrorCondMap);
                        if(b){
                            if(resultErrorMap.containsKey('Failed')){
                                List<String> strList = resultErrorMap.get('Failed');
                                strList.add(prObj.SBQQ__ErrorMessage__c);
                                resultErrorMap.put('Failed',strList);
                            }else{
                                List<String> strList = new List<String>();
                                strList.add(prObj.SBQQ__ErrorMessage__c);
                                resultErrorMap.put('Failed',strList);
                            }
                        }
                    }
                }else if(prObj.SBQQ__ConditionsMet__c== 'All'){
                    if(prodRuleIdErrorCondResultMap.containsKey(prObj.Id)){
                        List<String> resultsList = prodRuleIdErrorCondResultMap.get(prObj.Id);
                        Boolean b = ProductRulesExecutor.allExpressionEvaluation(resultsList);
                        if(b){
                            if(resultErrorMap.containsKey('Failed')){
                                List<String> strList = resultErrorMap.get('Failed');
                                strList.add(prObj.SBQQ__ErrorMessage__c);
                                resultErrorMap.put('Failed',strList);
                            }else{
                                List<String> strList = new List<String>();
                                strList.add(prObj.SBQQ__ErrorMessage__c);
                                resultErrorMap.put('Failed',strList);
                            }
                        }
                    }
                }else if(prObj.SBQQ__ConditionsMet__c== 'Any'){
                    if(prodRuleIdErrorCondResultMap.containsKey(prObj.Id)){
                        List<String> resultsList = prodRuleIdErrorCondResultMap.get(prObj.Id);
                        Boolean b = ProductRulesExecutor.anyExpressionEvaluation(resultsList);
                        if(b){
                            if(resultErrorMap.containsKey('Failed')){
                                List<String> strList = resultErrorMap.get('Failed');
                                strList.add(prObj.SBQQ__ErrorMessage__c);
                                resultErrorMap.put('Failed',strList);
                            }else{
                                List<String> strList = new List<String>();
                                strList.add(prObj.SBQQ__ErrorMessage__c);
                                resultErrorMap.put('Failed',strList);
                            }
                        }
                    }
                }
            }
        }
        return resultErrorMap;
    }

    public static Boolean customExpressionEvaluation(String expression, Map<String, String> prodRuleIndexdErrorCondMap){
        String conditionStr = ' '+expression;
        List<String> strList = expression.split('[AND,(,),OR]');
        for(String str:strList){
            if(str!='' && str!=' '){
                str = str.trim();
                //System.debug('str>>1 '+str);
                String result = prodRuleIndexdErrorCondMap.containsKey(str) ? prodRuleIndexdErrorCondMap.get(str) : 'False';
                //System.debug('result>>1 '+result);
                conditionStr = conditionStr.replace(' '+str+' ',' '+result+' ');
            }
        }
        System.debug('expression>>> '+conditionStr);
        Boolean result = BooleanExpression.evaluate(conditionStr.trim());
        System.debug('result>> '+result);
        return result;
    }

    public static Boolean allExpressionEvaluation(List<String> resultsList){
        String expression = ' ';
        for(String str: resultsList){
            if(str!='' && str!=' '){
                str = str.trim();
                expression = expression == ' '? (expression + str) : (expression +' AND '+ str);
            }
        }
        System.debug('expression>>>'+expression);
        Boolean result = BooleanExpression.evaluate(expression.trim());
        System.debug('result>>'+result);
        return result;
    }

    public static Boolean anyExpressionEvaluation(List<String> resultsList){
        String expression = ' ';
        for(String str: resultsList){
            if(str!='' && str!=' '){
                str = str.trim();
                expression = expression == ' '? (expression + str) : (expression +' OR '+ str);
            }
        }
        System.debug('expression>>>'+expression);
        Boolean result = BooleanExpression.evaluate(expression.trim());
        System.debug('result>>'+result);
        return result;
    }
}