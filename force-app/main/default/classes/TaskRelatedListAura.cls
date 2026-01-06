/**
* @author Accenture
* @date 2/5/2019
* @description : Aura class for DisplayTaskRelatedList lightning component 
*                Created by SDT604
**/
public without sharing class TaskRelatedListAura {
    
    /**
* Method to get the details from the related to field
*/
    @AuraEnabled
    public static RelatedObjectWrapper getRelatedTo(String recId)
    {
        RelatedObjectWrapper objWrapper = new RelatedObjectWrapper();
        try{
            //get the whatid
            Task taskObj  = [SELECT Id, WhatId FROM Task WHERE ID =: recId LIMIT 1];
            if(taskObj.WhatId != null){
                 
            objWrapper.recordId = taskObj.WhatId;
            
            //get the sobjecttype for the whatid
            Schema.SObjectType sobjectType = taskObj.WhatId.getSObjectType();
            String relatedObj = sobjectType.getDescribe().getName();
            objWrapper.objectName = relatedObj;
            
            List<Schema.FieldSetMember> fieldSetMemberList = new List<Schema.FieldSetMember>(); 
            //get the fieldset for the sobjecttype
            if((Constant_Util.KEYWORD_CASE).equalsIgnoreCase(relatedObj)){
                fieldSetMemberList = readFieldSet(Constant_Util.TASK_CASE_FIELDSET, relatedObj);
            }
            
            //create a query for all the fields in the fieldset and get values
            List<String> queryStr = new List<String>();
            for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList){
                queryStr.add(fieldSetMemberObj.getFieldPath());
            }
            objWrapper.fieldList = queryStr;
            //system.debug('objWrapper: '+objWrapper);
                
            }
           
            
        }catch(Exception e){
            //TODO: once the exception handling is in place
            //System.debug('Exception::::'+e.getStackTraceString());
        }
        return objWrapper;
        
    }
    
    /**
* Method to get the details of the fieldset
*/
    private static List<Schema.FieldSetMember> readFieldSet(String fieldSetName, String ObjectName){
        Map<String, Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType sObjectTypeObj = globalDescribeMap.get(ObjectName);
        Schema.DescribeSObjectResult describeSObjectResultObj = sObjectTypeObj.getDescribe();        
        Schema.FieldSet fieldSetObj = describeSObjectResultObj.FieldSets.getMap().get(fieldSetName);        
        return fieldSetObj.getFields(); 
    }  
    
    /**
* RelatedObjectWrapper
*/
    public without sharing class RelatedObjectWrapper{
        @auraenabled public String recordId {get;set;}
        @auraenabled public String objectName {get;set;}
        @auraenabled public List<String> fieldList {get;set;}        
    }
}