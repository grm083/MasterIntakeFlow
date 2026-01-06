/*************************************************************
@Name: CloneApprovalRules
@Author: Soham Datta
@CreateDate: 24/01/20125
@Description: Invocable class to return cloned approval record Id to the CustomCloningBusinessRule Flow
**************************************************************/

public with sharing class CloneApprovalRules {
    
    // Wrapper class for input
    public class InputWrapper {
        
        //Store loop counter value
        @InvocableVariable(label='Loop Count')
        public String loopCount;
        
        //Store approval rule that will clone
        @InvocableVariable(label='Parent Approval Rules')
        public Business_Rule__c parentApprovalRule;
    }
    
    //Define the invocable method
    @InvocableMethod(label='Clone Approval Rules')
    public static List<dataList> insertApprovalRecords(List<InputWrapper> inputs){
        
        //Preparing return list
        List<DataList> dataList = new List<DataList>();
        DataList data = new DataList();
        
        //Setting flag value based on loopcounter
        Boolean flagAllowSave = inputs[0].loopCount == '1' ? false : true;
        
        //Cloning Approval Rule
        data.createdBusinessRule = inputs[0].parentApprovalRule.clone(false, true, false, false);
        data.createdBusinessRule.End_Date__c = null;
        data.createdBusinessRule.Active_Inactive_Reason__c = '';
        
        if(!flagAllowSave){
            data.duplicateBusinessRule = detectDuplicateRecords(data.createdBusinessRule);
        }
        
        try{
            //Bypass Duplicate Rule while Insert
            Database.DMLOptions dmlOpts = new Database.DMLOptions();
            dmlOpts.DuplicateRuleHeader.allowSave = flagAllowSave;
            
            //Inserting Cloned Approval Rule
            Database.SaveResult sr = Database.insert(data.createdBusinessRule, dmlOpts);
            
            // Operation was successful
            if (sr.isSuccess()) {
                
                //Storing cloned Approval Rule Id           
                if(String.isNotBlank(data.createdBusinessRule.Id)){
                    data.clonedBusinessRuleId = data.createdBusinessRule.Id;
                }
                
            } else {
                // Operation failed
                for(Database.Error err : sr.getErrors()) {
                    data.errorMessage = err.getMessage();
                    break;
                }
            }
            
            dataList.add(data);
            
        }catch(Exception ex){
            
            data.errorMessage = ex.getDMLMessage(0);
            dataList.add(data);
            return dataList;
            
        }
        
        // Return the list of output wrappers
        return dataList;
    }
    
    //Method to find duplicate Business Rules
    public static List<Business_Rule__c> detectDuplicateRecords(Business_Rule__c clonedRule){
        
        return [SELECT Id, Name, Alias__c, Record_Type_Name__c, RecordTypeId, AccountId__c, Container__c, Effective_Date__c, LocationId__c, 
                Schedule_Type__c, Service__c, AssetId__c, Category_Type__c, Group__c, 
                Project_Code__c, Case_Reason__c, Material__c ,Business_rule_name__c, Active__c
                FROM Business_Rule__c
                WHERE RecordTypeId = :clonedRule.RecordTypeId
                AND AccountId__c = :clonedRule.AccountId__c
                AND Container__c = :clonedRule.Container__c
                AND LocationId__c = :clonedRule.LocationId__c
                AND Schedule_Type__c = :clonedRule.Schedule_Type__c
                AND Service__c = :clonedRule.Service__c
                AND AssetId__c = :clonedRule.AssetId__c
                AND Category_Type__c = :clonedRule.Category_Type__c
                AND Group__c = :clonedRule.Group__c
                AND Project_Code__c = :clonedRule.Project_Code__c
                AND Case_Reason__c = :clonedRule.Case_Reason__c
                AND Material__c = :clonedRule.Material__c];
        
    }
    
    public class DataList {
        
        //Store Duplicate Approval Records to display to user
        @InvocableVariable(label='duplicateRecordFromApex')
        public List<Business_Rule__c> duplicateBusinessRule;
        
        //Store Cloned Approval Rule 
        @InvocableVariable(label='createdBusinessRuleFromApex')
        public Business_Rule__c createdBusinessRule;
        
        //Store Cloned Approval Rule Id
        @InvocableVariable(label='Cloned Business Rule Id')
        public String clonedBusinessRuleId;
        
        //Store Error Message
        @InvocableVariable(label='errorMessage')
        public string errorMessage;
        
    }
    
}