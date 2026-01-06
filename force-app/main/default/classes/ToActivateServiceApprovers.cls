/*************************************************************
@Name: ToActivateServiceApprovers
@Author: Priyadharshini R
@CreateDate: 11/03/2019
@Description: SDT-8860 : This class is used to update InActive service Approvers to Active
*************************************************************/
public class ToActivateServiceApprovers implements Database.Batchable<sObject>{
	public Database.QueryLocator start(Database.BatchableContext bc) {
		String query = 'select id,Active__c from Service_Approver__c where Active__c = false';
        return Database.getQueryLocator(query);
	}
	public void execute(Database.BatchableContext bc, List<Service_Approver__c> scope){
        List<Service_Approver__c> updateSALst = new List<Service_Approver__c>();
		for(Service_Approver__c sa: scope){
			sa.Active__c = true;
			updateSALst.add(sa);
		}
		if(updateSALst != null && updateSALst.size() > 0){
            try{
            	Database.update(updateSALst,false);
            }catch(Exception ex){
            	system.debug('Exception::::'+ex.getStackTraceString());
             	System.debug('Exception::::'+ex.getMessage());
        	}
		}
	}
	public void finish(Database.BatchableContext bc) {
        try{
        }catch(Exception ex){
            system.debug('Exception $$$'+ex.getStackTraceString());
        }
    } 
}