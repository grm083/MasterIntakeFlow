/*************************************************************
@Name: ProjectCodeTriggerHandler
@Author: Anupreethy
@CreateDate: 03/07/2019
@Description: Handler Class to Perform operations on Project_Code__c
@UsedBy: ProjectCodeTrigger
**************************************************************/
Public without sharing class ProjectCodeTriggerHandler {
   /*
	* It is invoked on before inserting a project code
	* @owner : Anupreethy
	* @param : Project_Code__c List
	*/ 
    Public static void onBeforeInsert(List<Project_Code__c> projectCodeList){
        ProjectCodeTriggerHelper.populateProjectCodeID(projectCodeList);
    }
    
    Public static void onAfterUpdate(List<Project_Code__c> projectCodeList,Map<Id,Project_Code__c>oldProjCodeLst){
        ProjectCodeTriggerHelper.toGetAssetProjectCode(projectCodeList,oldProjCodeLst);
    }

}