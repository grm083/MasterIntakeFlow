/*************************************************************
@Name: GenTaskController
@Author: Accenture (Kyle Homovec)
@CreateDate: 4/24/2019
@Description: Handles task insertion on Case for Genesys effort reporting
@UsedBy: SDT-4271
**************************************************************/
public class GenTaskController {
    //public Id caseID = ApexPages.currentPage().getParameters.get('id');
	//public Id userId = UserInfo.getUserId();

    public PageReference taskCheck(){
        
		Id caseID = ApexPages.currentPage().getParameters().get('id');
        //System.debug('parameters: xxxxxxx : '+ApexPages.currentPage().getParameters());
		Id userId = UserInfo.getUserId();
        Id profId = UserInfo.getProfileId();
        //System.debug('CaseId:  '+caseId);

        Profile p = [SELECT Id, Name FROM Profile WHERE Id = :profId LIMIT 1];
		Case c = [SELECT Id, Last_Customer_Interaction_Id__c, Last_Customer_Interaction_Type__c FROM Case WHERE Id = :caseId LIMIT 1];
		
		List<Task> genTasks = [SELECT Id, WhatId, Interaction_ID__c FROM Task WHERE WhatId = :caseId AND Interaction_ID__c = :c.Last_Customer_Interaction_Id__c LIMIT 4999];
		//System.debug('GenTasks list: '+genTasks);
        
		if(genTasks.isEmpty() && c.Last_Customer_Interaction_Id__c != null){
            try{
			Task t = new Task();
			t.Status = Constant_Util.COMPLETED;
			t.Subject = Constant_Util.INBOUND_CUSTOMER_INTERACTION;
			t.WhatId = caseId;
			t.OwnerId = userId;
			t.Interaction_ID__c = c.Last_Customer_Interaction_Id__c;
            t.Description__c = c.Last_Customer_Interaction_Id__c;
			t.Description = 'MediaType: '+c.Last_Customer_Interaction_Type__c + Constant_Util.NEW_LINE + 'Genesys ID: '+c.Last_Customer_Interaction_ID__c;
// Modified for SDT-33461 Start
                if(t != null) { 
                    Database.Insert(t);
                }
                // Modified for SDT-33461 End
            //System.debug('Task inserted: '+t);
                
            }catch(Exception e){
				System.debug('Exception::: ' + e.getStackTraceString());
            }
		}
        
        PageReference pageRef = new PageReference('/lightning/r/Case/'+caseId+'/view');
			return pageRef;
	}
}