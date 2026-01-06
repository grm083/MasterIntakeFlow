/*
* @author Accenture
* @date 8/14/2019
* @description : Apex class to create Service Not Performed Status Case  
*/

public class CaseCreation {
    
    @InvocableMethod
    public static void createRelatedCase(List<Case> caselst){
        Set<Id> caseIds=new Set<Id>();
        Set<Id> selectedCaseIds=new Set<Id>();
        List<Case> selectedCases=null;
        list<Case> updatedCaseList= null;
        String UNSPECIFIED = 'Unspecified ';  // Used for Dummy Contact Name
        Set<String> clientNameSet = new Set<String>();
        Map<String,Id> mapClientVsContactId = new Map<String,Id>();
                
		for(Case c: caselst){
            caseIds.add(c.id);
        }
        list<Case> caseListToInsert= new list<Case>();
        list<Case> caseListToUpdate= new list<Case>();
        List<String> vendorExceptionList = new List<String>{'wm cancelled','closed out of business (customer)','location cancelled','missed service'};
		Case caseObj = null;
        try{
            selectedCases= Database.query('SELECT Id,AssetId,Tracking_number__c,Acorn_Work_order__c,ContactId,Case_Sub_Status__c,Client__c,Client__r.Name,Location__c,Reference_Number__c FROM case WHERE Id in :caseIds');
            if(selectedCases!=null){
                String caseDescription=null;
                String strContactId = null;
                // Starts - 18703 Added Unspecified Contact on SNP Case //
                for(Case selected : selectedCases){
                    if(selected.ContactId == null && selected.Client__c !=null){
                        String whereInput = UNSPECIFIED + selected.Client__r.Name; // Unspecified Contact Info
                        clientNameSet.add(whereInput);
                    }
                }
                if(clientNameSet!=null && !clientNameSet.isEmpty()){
                    for(Contact con : [SELECT Id, Name, LastName FROM Contact WHERE Name IN : clientNameSet]){
                        mapClientVsContactId.put(con.LastName, con.Id);
                    }
                }
                // Ends
                for(Case selected : selectedCases){
                    caseDescription=Constant_Util.CASE_DESCRIPTION+selected.Tracking_number__c+', '+selected.Acorn_Work_order__c;
                    // Starts - 18703 // Added Unspecified Contact on SNP Case //
                    if(selected.ContactId == null){
                        system.debug('mapClientVsContactId : ' + mapClientVsContactId);
                        if(!mapClientVsContactId.isEmpty() && mapClientVsContactId.size()>0){
                            strContactId = mapClientVsContactId.get(selected.Client__r.Name);
                        }
                    }else{
                        strContactId = selected.ContactId;
                    }
                    system.debug('strContactId : ' + strContactId);
                    String caseStatus = Constant_Util.STATUS_NEW;
                    // Ends - 18703
                    caseObj = new Case(Status = Constant_Util.STATUS_NEW,Case_Sub_Status__c= Constant_Util.PENDING_SERVICE_ISSUE_RESOLUTION,    
                                       description=caseDescription, 
                                       RecordTypeId =getRecordType(Constant_Util.STATUS_CASE,Constant_Util.KEYWORD_CASE),   
                                       Service_Date__c=System.today(),
                                       Reference_Number__c = selected.Reference_Number__c,
                                       AssetId = selected.assetId,Client__c =selected.Client__c,Case_Sub_Type__c=Constant_Util.SERVICE_NOT_PERFORMED,
                                       Location__c =selected.Location__c,Case_Reason__c=Constant_Util.HAULER_REPORTED,ContactId=strContactId,ParentId=selected.Id);
                    caseListToInsert.add(caseObj);
                    selectedCaseIds.add(selected.Id);
                }
                if(!caseListToInsert.isEmpty()){
                    INSERT caseListToInsert;
                    
                }
                String query='SELECT status,case_sub_status__c,Reference_Number__c,parent.Work_Order__c,parent.Work_Order__r.Vendor_Exception_Reason__c,'
						+ ' Tracking_number__c FROM case WHERE parentId in :selectedCaseIds'
						+ ' and Tracking_number__c=null and case_sub_status__c=';
                
               	query+='\''+Constant_Util.PENDING_SERVICE_ISSUE_RESOLUTION+'\'';
			  	query+=' and case_sub_type__c='+'\''+Constant_Util.SERVICE_NOT_PERFORMED+'\'';
				query+=' and status='+'\''+Constant_Util.STATUS_NEW+'\'';
                
                updatedCaseList=Database.query(query);
                for(Case selected : updatedCaseList){
                    if(selected.parent.Work_Order__c !=null && selected.parent.Work_Order__r.Vendor_Exception_Reason__c !=null ){
                        if(vendorExceptionList.contains(selected.parent.Work_Order__r.Vendor_Exception_Reason__c.toLowercase())){
                            selected.Status = Constant_Util.OPEN;
                        }else{
                            selected.Status = Constant_Util.Case_Closed_Status;
                            selected.case_sub_status__c = Constant_Util.STATUS_PROVIDED;
                        }
                    }
                    caseListToUpdate.add(selected);
                }
                if(!caseListToUpdate.isEmpty()){ 
                    UPDATE caseListToUpdate; 
                    
                }
                
            }
            
        }catch(Exception ex){  
            System.debug('Exception ::: '+ ex.getMessage()+' '+ex.getLineNumber());
        }
    }
    public static Id getRecordType(String RecordTypeName, String SobjectType){
        return Schema.getGlobalDescribe().get(SobjectType).getDescribe().getRecordTypeInfosByName().get(RecordTypeName).getRecordTypeId(); 
    }
    
}