/*************************************************************
@Name: ProjectCodeTriggerHelper
@Author: Anupreethy
@CreateDate: 03/07/2019
@Description: Handler Class to Perform operations on ProjectCode
@UsedBy: ProjectCodeTriggerHelper
**************************************************************/
Public without sharing class ProjectCodeTriggerHelper {
    /*
* This method will Populate Project Code ID
* @owner : Anupreethy
* @param : Project_code__c List
*/ 
    Public static void populateProjectCodeID(List<Project_Code__c> projectCodeList){
        try{
            Integer headerRecCount;
            Integer mx;
            Id headerRecordTypeId = Schema.SObjectType.Project_Code__c.getRecordTypeInfosByDeveloperName().get(Constant_Util.Project_Code_Header).getRecordTypeId();
            Id detailRecordTypeId = Schema.SObjectType.Project_Code__c.getRecordTypeInfosByDeveloperName().get(Constant_Util.Project_Code_Detail).getRecordTypeId();
            
            List<Project_Code__c> headerPCList = new List<Project_Code__c>();
            List<Project_Code__c> detailPCList = new List<Project_Code__c>();
            Set<ID> pcIDs =new Set<ID>();
            set<Id> parentIDset = new set<Id>();
            map<Id,Integer> detailsCountMap = new map<Id,Integer>();
			set<Id> clientIdset = new set<Id>();
			String maxProjectCount;
            Integer subProjectCounter;
            for(Project_Code__c thisCode : projectCodeList){
                if(headerRecordTypeId.equals(thisCode.RecordTypeId) ){
                    clientIdset.add(thisCode.Client_Account__c);
                }else if(detailRecordTypeId.equals(thisCode.RecordTypeId) ){
                    parentIDset.add(thisCode.Project_Code_Header__c);
                    detailsCountMap.put(thisCode.Project_Code_Header__c,0);
                }
            }
			Aggregateresult hc = [select max(Project_Code_ID__c)mx from Project_Code__c where RecordTypeId = : headerRecordTypeId ];
            if(hc!=null && hc.get('mx') == null){
                headerRecCount=0;
            }else{
            headerRecCount = Integer.valueof(hc.get('mx'));
            }
            for(Aggregateresult pc : [select max(Project_Code_ID__c)mx,Project_Code_Header__c from Project_Code__c where Project_Code_Header__c In: parentIDset GROUP BY Project_Code_Header__c]){
                If(pc!=null && Integer.valueof(pc.get('mx')) > 0){
                	detailsCountMap.put((Id)pc.get('Project_Code_Header__c'),Integer.valueof(pc.get('mx'))); 
                }
			}
            for(Project_Code__c thisProjectCode : projectCodeList){
                
                if(headerRecordTypeId.equals(thisProjectCode.RecordTypeId) ){
                    headerRecCount = headerRecCount + 1;
					thisProjectCode.Project_Code_ID__c= headerRecCount;
					
                }else if(detailRecordTypeId.equals(thisProjectCode.RecordTypeId) ){
                    subProjectCounter = detailsCountMap.get(thisProjectCode.Project_Code_Header__c)+1;
					thisProjectCode.Project_Code_ID__c= subProjectCounter;
                    detailsCountMap.put(thisProjectCode.Project_Code_Header__c,subProjectCounter); 
                }
            }
        }  
        catch(Exception e){
            // To Catch Exceptions
            System.debug('Exception::::'+e.getStackTraceString()); 
        }
    }
    
    /*Method to get the Asset details if the associated Sub Project is updated*/
    Public static void toGetAssetProjectCode(List<Project_Code__c> projectCodeList,Map<Id,Project_Code__c> oldProjCodeLst){
        
        Id detailRecordTypeId = Schema.SObjectType.Project_Code__c.getRecordTypeInfosByDeveloperName().get(Constant_Util.Project_Code_Detail).getRecordTypeId();
        
        Map<Id,Project_Code__c> detailProj = new Map<Id,Project_Code__c>();
        List<Asset> assProj= new List<Asset>();
        
        for(Project_Code__c projCode :projectCodeList){           
            //if((detailRecordTypeId.equals(projCode.RecordTypeId)) && ((oldProjCodeLst.get(projCode.ID).Length_of_Project_Days__c != null && projCode.Length_of_Project_Days__c != null && oldProjCodeLst.get(projCode.ID).Length_of_Project_Days__c != projCode.Length_of_Project_Days__c) || (oldProjCodeLst.get(projCode.ID).End_Date__c != null && projCode.End_Date__c != null && oldProjCodeLst.get(projCode.ID).End_Date__c != projCode.End_Date__c) || (oldProjCodeLst.get(projCode.ID).End_Date__c == null && projCode.End_Date__c != null) ||(oldProjCodeLst.get(projCode.ID).Length_of_Project_Days__c == null && projCode.Length_of_Project_Days__c != null))){
            if((detailRecordTypeId.equals(projCode.RecordTypeId)) && ((oldProjCodeLst.get(projCode.ID).Length_of_Project_Days__c != projCode.Length_of_Project_Days__c) || (oldProjCodeLst.get(projCode.ID).End_Date__c != projCode.End_Date__c) ||(oldProjCodeLst.get(projCode.ID).Effective_Date__c != projCode.Effective_Date__c))){
            	detailProj.put(projCode.Id,projCode);
            }            
        }     
        
        for(Asset asst : [SELECT Id, Name, Start_Date__c,Duration__c,Project_Code__c,Product2.ProductTypeSelected__c FROM Asset WHERE Project_Code__c IN : detailProj.keySet() LIMIT 49999]){ 
			asst.active__c = false;
            asst.end_date_based_on_project_code__c = null;
			assProj.add(asst);
        }
		
		if(assProj != null && assProj.Size() > 0 && detailProj != null && detailProj.size()>0){
            ProjectCodeTriggerHelper.toUpdateProjectCodeStatusOnAsset(assProj,true,detailProj);
		}
    }
	/*Method to update the Asset details if the associated Sub Project is updated*/
	Public static void toUpdateProjectCodeStatusOnAsset(List<Asset> assProj,Boolean isProject,Map<Id,Project_Code__c> detailProj){
          
		List<Asset> updateAssetLst = new List<Asset>();
        
        for(Asset asst : assProj){ 
            if(detailProj.get(asst.Project_Code__c).end_date__c == null && (detailProj.get(asst.Project_Code__c).Length_of_Project_Days__c != null && asst.Start_Date__c <=Date.today() && asst.Start_Date__c.addDays(Integer.valueOf(detailProj.get(asst.Project_Code__c).Length_of_Project_Days__c)) >= Date.today()) && detailProj.get(asst.Project_Code__c).Effective_Date__c <= Date.today()){
                asst.active__c = true;
                asst.end_date_based_on_project_code__c = asst.Start_Date__c.addDays(Integer.valueOf(detailProj.get(asst.Project_Code__c).Length_of_Project_Days__c));
            }			
            else if(detailProj.get(asst.Project_Code__c).Length_of_Project_Days__c == null && (detailProj.get(asst.Project_Code__c).end_date__c != null && detailProj.get(asst.Project_Code__c).end_date__c>=Date.today()) && detailProj.get(asst.Project_Code__c).Effective_Date__c <= Date.today()){
                asst.active__c = true;
                asst.end_date_based_on_project_code__c = detailProj.get(asst.Project_Code__c).end_date__c;
            }	
            else if(detailProj.get(asst.Project_Code__c).Length_of_Project_Days__c == null && detailProj.get(asst.Project_Code__c).end_date__c == null && detailProj.get(asst.Project_Code__c).Effective_Date__c <= Date.today()){
                asst.active__c = true;
                asst.end_date_based_on_project_code__c = null;
            }    	
            else if(detailProj.get(asst.Project_Code__c).Effective_Date__c <= Date.today()){
                asst.end_date_based_on_project_code__c = detailProj.get(asst.Project_Code__c).end_date__c !=null ? detailProj.get(asst.Project_Code__c).end_date__c : asst.Start_Date__c.addDays(Integer.valueOf(detailProj.get(asst.Project_Code__c).Length_of_Project_Days__c)) ;
            }
            else{
                //Novacop fix
            }
			if(isProject){
            updateAssetLst.add(asst);
			}
        } 
        
        if(updateAssetLst != null && updateAssetLst.size() > 0){
            Database.SaveResult[] svRes = database.update(updateAssetLst,false);
            UTIL_LoggingService.logDmlResults(svRes, null, updateAssetLst, '', UTIL_ErrorConstants.PROJECT_CODE_MODULE,'',UTIL_ErrorConstants.PROJECT_CODE_TRIGGER, LoggingLevel.ERROR);
        }                       
    }
}