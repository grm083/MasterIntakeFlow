/*************************************************************
@Name: ServiceApproverHelper
@Author: DineshKumar S
@CreateDate: 07/02/2019
@Description: Helper Class to Perform operations on Service Approver
@UsedBy: ServiceApproverHandler
**************************************************************/
public without sharing class ServiceApproverHelper {
    /*
* This method is used to validate the Service Approver whether the duplication is created or not
* @owner : Priyadharshini R
* @param : ServiceApproverList
*/
    public static void validateSA(List<Service_Approver__c > newsaList){
        set<Id> brIdset = new set<Id>();
        Set<Id> titleIdSet = new set<Id>();
        Set<Id> contactIdSet = new set<Id>();
        set<Id> userIdSet = new Set<Id>();
		set<Id> userSet = new Set<Id>();
		set<string> emailSet = new Set<string>();
        set<string> departmentset = new set<String>();
        set<string> accountset = new set<String>();
		set<string> originSet = new Set<string>();
        Map<String,Service_Approver__c> existingMap = new Map<String,Service_Approver__c>();
      
        String recordTypeName = null;
        try{
            for(Service_Approver__c sa : newsaList){
                brIdset.add(sa.Business_Rule__c);
               If(sa.RecordTypeId.equals(Schema.SObjectType.Service_Approver__c.getRecordTypeInfosByDeveloperName().get(Constant_Util.FLOW_TITLE).getRecordTypeId())){
                    titleIdSet.add(sa.Title__c);
                    recordTypeName = Constant_Util.FLOW_TITLE;
                }
                If(sa.RecordTypeId.equals(Schema.SObjectType.Service_Approver__c.getRecordTypeInfosByDeveloperName().get(Constant_Util.CONTACT_RECORD_TYPE).getRecordTypeId())){
                    contactIdSet.add(sa.Approver_Contact__c);
                    recordTypeName = Constant_Util.CONTACT_RECORD_TYPE;
                }
                If(sa.RecordTypeId.equals(Schema.SObjectType.Service_Approver__c.getRecordTypeInfosByDeveloperName().get(Constant_Util.ATM_RECORD_TYPE_NAME).getRecordTypeId())){
                    accountset.add(sa.Account__c);
                    accountset.add(sa.Location__c);
                    userIdSet.add(sa.Account_Team_Member__c);
                    recordTypeName = Constant_Util.ATM_RECORD_TYPE_NAME;
                }
                If(sa.RecordTypeId.equals(Schema.SObjectType.Service_Approver__c.getRecordTypeInfosByDeveloperName().get(Constant_Util.EA_RECORD_TYPE_NAME).getRecordTypeId())){
                    departmentset.add(sa.Department__c);
                    recordTypeName = Constant_Util.DEPARTMENT_RECORDTYPE;
                }
				If(sa.RecordTypeId.equals(Schema.SObjectType.Service_Approver__c.getRecordTypeInfosByDeveloperName().get(Constant_Util.USER_RECORDTYPE).getRecordTypeId())){
                    userSet.add(sa.User__c);
                    recordTypeName = Constant_Util.USER_RECORDTYPE;
                }
				If(sa.RecordTypeId.equals(Schema.SObjectType.Service_Approver__c.getRecordTypeInfosByDeveloperName().get(Constant_Util.ORIGIN_EMAIL).getRecordTypeId())){
                    emailSet.add(sa.Email__c);
                    recordTypeName = Constant_Util.ORIGIN_EMAIL;
                }
				If(sa.RecordTypeId.equals(Schema.SObjectType.Service_Approver__c.getRecordTypeInfosByDeveloperName().get(Constant_Util.ORIGIN).getRecordTypeId())){
                    originSet.add(sa.Origin__c);
                    recordTypeName = Constant_Util.ORIGIN;
                }
            }
            Map<Id,Business_Rule__c>  brMap = new Map<Id,Business_Rule__c>([Select Id,End_Date__c,No_Approval_Required__c FROM Business_Rule__c WHERE Id IN: brIdset LIMIT 49999]);
            Map<Id,Boolean> accTeammap = new map<Id,Boolean>();
            for(AccountTeamMember accteam : [select id,UserId from AccountTeamMember where AccountId IN: accountset LIMIT 49999]){
                If(userIdSet.contains(accteam.UserId)){
                    accTeammap.put(accteam.UserId,true);
                }
                else{
                    accTeammap.put(accteam.UserId,false);
                }
            }
            for(Service_Approver__c sa : [Select id,Business_Rule__c,Title__c,Approver_Contact__c,Account_Team_Member__c,External_Approver_Email__c,
                                          External_Approver_Phone_Number__c from Service_Approver__c where Business_Rule__c IN: brIdset 
                                          and (Title__c IN: titleIdSet or Approver_Contact__c IN: contactIdSet or Account_Team_Member__c IN: userIdSet
                                               or Department__c IN: departmentset or User__c IN: userSet or Email__c IN: emailSet or Origin__c IN: originSet)and Approver_Type__c =:recordTypeName LIMIT 49999]){
                                                   existingMap.put(sa.Business_Rule__c,sa);
                                               }
          
            for(Service_Approver__c sa : newsaList){
                If(!existingMap.isEmpty() && existingMap.containsKey(sa.Business_Rule__c)){
                    sa.addError(system.Label.Duplicate_Service_Approver_Error);
                }
                If(sa.RecordTypeId.equals(Schema.SObjectType.Service_Approver__c.getRecordTypeInfosByName().get(Constant_Util.ATM_RECORD_TYPE).getRecordTypeId()) 
                   && ( (!accTeammap.isEmpty() && accTeammap.containskey(sa.Account_Team_Member__c) && !accTeammap.get(sa.Account_Team_Member__c)) 
                       || (accTeammap.isEmpty()) || (!accTeammap.isEmpty() && !accTeammap.containskey(sa.Account_Team_Member__c)) ) ){
                           sa.addError(system.Label.CAT_Member_Error);
                       } 
                If(existingMap.isEmpty() && brMap.containsKey(sa.Business_Rule__c)){
                    if(brMap.get(sa.Business_Rule__c).End_Date__c < System.today()){
                        sa.addError(Label.ServiceApproverCannotBeAdded);
                    }
                }
                If(existingMap.isEmpty() && brMap.containsKey(sa.Business_Rule__c) &&  brMap.get(sa.Business_Rule__c).No_Approval_Required__c){
                    sa.addError(Label.No_Approval_Required_Error);
				}
            }
        }
        catch(Exception e){
            //To handle Error in future Sprints
            System.debug('Exception::::'+e.getStackTraceString());
        }
    }
    
    /*
* This method is used to activate the Business Rule when the first Service Approver is created for the respective Business Rule
* @owner : DineshKumar S
* @param : ServiceApproverList */
    public static void activateBr(List<Service_Approver__c > newsaList){
        set<Id> brIdset = new set<Id>();
        List<Business_Rule__c> updatebrlst = new List<Business_Rule__c>();
        try{
            for(Service_Approver__c sa : newsaList){
                if(sa.Active__c && !sa.Requester_Only__c){
                brIdset.add(sa.Business_Rule__c);
                }
            }
            if(brIdset != null && brIdset.size() > 0){
                for(Business_Rule__c br :[Select Id,Active__c from Business_Rule__c where Id IN: brIdset and Active__c =False LIMIT 49999]){
                    br.Active__c = true;
                    updatebrlst.add(br);
                }
            }
            
            If(!updatebrlst.isEmpty() && updatebrlst.size() > 0){
                Database.update(updatebrlst, true);
            }
        }catch(Exception e){
            //To handle Error in future Sprints
            system.debug('$$$$'+e.getStackTraceString());
        }
    }
       /*
* This method is used to deactivate the Business Rule
* @owner : DineshKumar S
* @param : ServiceApproverList */
    public static void deActivateBr(Map<Id,Service_Approver__c > newSaMap){
        set<Id> brIdset = new set<Id>();
        List<Business_Rule__c> updatebrlst = new List<Business_Rule__c>();
        Map<Id,Service_Approver__c> sapMap = new Map<Id,Service_Approver__c>();
        Map<Id,Boolean> saMap = new Map<Id, Boolean>();
        for(Service_Approver__c sa :newSaMap.values()){
            brIdset.add(sa.Business_Rule__c);
        }
        if(brIdset != null && brIdset.size() > 0){
            for(Service_Approver__c sa : [Select Id,Active__c,Requester_Only__c,Business_Rule__c From Service_Approver__c where Business_Rule__c IN: brIdset LIMIT 49999]){
                if(newSaMap.ContainsKey(sa.Id)){
                    sa = newSaMap.get(sa.Id);
                }
                If(saMap.isEmpty() || !saMap.containsKey(sa.Business_Rule__c)){
                    if(!sa.Active__c || (sa.Active__c && sa.Requester_Only__c)){
                        saMap.put(sa.Business_Rule__c,false);
                    }else if(sa.Active__c && !sa.Requester_Only__c){
                        saMap.put(sa.Business_Rule__c,true);
                    }
                }else if(!saMap.isEmpty() && saMap.size() > 0 && saMap.containsKey(sa.Business_Rule__c) && (!sa.Requester_Only__c && sa.Active__c)){
                    saMap.put(sa.Business_Rule__c,true);
                }
            }
        }
        if(!saMap.isEmpty() && saMap.size() > 0){
            for(Business_Rule__c br : [select id,Active__c from Business_Rule__c where Id IN: saMap.keyset() LIMIT 49999]){
                if(!saMap.get(br.Id) && br.Active__c){
                    br.Active__c = false;
                    updatebrlst.add(br);
                }else if(saMap.get(br.Id) && !br.Active__c){
                    br.Active__c = true;
                    updatebrlst.add(br);
                }
            }
        }
        if(!updatebrlst.isEmpty() && updatebrlst.size() > 0){
            Database.update(updatebrlst,false);
        }
    }
    /*
* This method is used to active the contact status from inactive.
*SDT-9888 */
    
    public static void activateConSt(List<Service_Approver__c > newsaList){
        set<Id> conIdset = new set<Id>();
        List<Contact> updateconlist = new List<Contact>();
        try{
            for(Service_Approver__c sa : newsaList){
                if(sa.Active__c){
                conIdset.add(sa.Approver_Contact__c);
             }
			 }
            if(conIdset != null ){
                for(Contact con :[Select Id,Contact_Status__c from Contact where Id IN: conIdset LIMIT 49999]){
                    if(con.Contact_Status__c  != 'Active'){
					con.Contact_Status__c = 'Active';
                    updateconlist.add(con);
                }
            }
            }
            If(!updateconlist.isEmpty()){
                Database.update(updateconlist, false);
            }
        }catch(Exception e){
            //To handle Error in future Sprints
            system.debug('$$$$'+e.getStackTraceString());
        }
    }
    
	/*
	* This method is used to update the Business_Rule_Association__c field to display the business rule association, if any business rule is associated with contact then show "Yes" else "No".
	* @owner : Saurav Dwivedi
	* @param : ServiceApproverList 
	*/
	public static void updateBusinessRuleAssociationOnContact(Map<Id,Service_Approver__c > newSaMap, Map<Id,Service_Approver__c > oldSaMap, Boolean isInsert, Boolean IsUpdate, Boolean isDelete){
		Set<Id> contactIdsForDeleteContact = new Set<Id>();
		Set<Id> contactIdsForActive = new Set<Id>();
		Set<Id> contactIdsForOldContact = new Set<Id>();
		Set<Id> contactIdsForNewContact = new Set<Id>();
		Set<Id> contactIdsForAvailContact = new Set<Id>();
	    List<Contact> contactListToUpdate = new List<Contact>();
	    try{
	    	if(isInsert){
				for(Service_Approver__c sa : newSaMap.values()){
	            	if(sa.Active__c){
	            		contactIdsForActive.add(sa.Approver_Contact__c);
	         		}
	         	}
			 	//For Active Service Approver
			 	if(!contactIdsForActive.isEmpty()){
			 		for(Contact con :[Select Id, Business_Rule_Association__c from Contact where Id IN: contactIdsForActive LIMIT 49999]){
	                	if(con.Business_Rule_Association__c  != 'Yes'){
							con.Business_Rule_Association__c = 'Yes';
	                		contactListToUpdate.add(con);
	            		}
			 		}
			 		if(!contactListToUpdate.isEmpty()){
	            		Database.update(contactListToUpdate, false);
	        		}
				}
			}
			if(isUpdate){
				for(Service_Approver__c sa : newSaMap.values()){
	            	if((sa.Active__c && newSaMap.get(sa.Id).Approver_Contact__c != oldSaMap.get(sa.Id).Approver_Contact__c)){
	            		contactIdsForNewContact.add(sa.Approver_Contact__c); 
	            		contactIdsForOldContact.add(oldSaMap.get(sa.Id).Approver_Contact__c);
	            		contactIdsForAvailContact.add(oldSaMap.get(sa.Id).Approver_Contact__c); 
	            	}
	            	else{
	            		if(sa.Active__c && sa.Approver_Contact__c != null){
	            			contactIdsForNewContact.add(sa.Approver_Contact__c);
	            		}
	            		else if(!sa.Active__c && sa.Approver_Contact__c != null){
	            			contactIdsForAvailContact.add(sa.Approver_Contact__c);
                        } else{}
	            	}
			 	}
			 	//For New Contact Service Approver
				if(!contactIdsForNewContact.isEmpty()){
			 		for(Contact con :[Select Id, Business_Rule_Association__c from Contact where Id IN: contactIdsForNewContact LIMIT 49999]){
                       
	                	if(con.Business_Rule_Association__c  != 'Yes'){
							con.Business_Rule_Association__c = 'Yes';
	                		contactListToUpdate.add(con);
	            		}
			 		}
			 		if(!contactListToUpdate.isEmpty()){
	            		Database.update(contactListToUpdate, false);
	        		}
				}
			 	
			 	//For Old Contact Service Approver
				if(!contactIdsForOldContact.isEmpty()){
			 		for(Contact con :[Select Id, Business_Rule_Association__c from Contact where Id IN: contactIdsForOldContact LIMIT 49999]){
	                	if(con.Business_Rule_Association__c  == 'Yes'){
							con.Business_Rule_Association__c = 'No';
	                		contactListToUpdate.add(con);
	            		}
			 		}
			 		if(!contactListToUpdate.isEmpty()){
	            		Database.update(contactListToUpdate, false);
	        		}
				} 
				//Check for Multiple service Approver
				if(!contactIdsForAvailContact.isEmpty()){
			 		isBRAssociatedWithContact(contactIdsForAvailContact); 
			 	}	
			}
			if(isDelete){
	        	for(Service_Approver__c sa : oldSaMap.values()){
            		contactIdsForDeleteContact.add(sa.Approver_Contact__c);
	         	}
			 	if(!contactIdsForDeleteContact.isEmpty()){
			 		isBRAssociatedWithContact(contactIdsForDeleteContact);
			 	}		
	 			System.debug('>>>contactListToUpdate'+contactListToUpdate);
		 	}
	    }catch(Exception e){
	        //To handle Error in future Sprints
	        system.debug('$$$$'+e.getStackTraceString());
	    }
	}
	
	public static void isBRAssociatedWithContact(Set<Id> contacts){
		List<Contact> contactListToUpdate = new List<Contact>();
        Map<Id, Service_Approver__c> serviceApproverMap = new Map<Id, Service_Approver__c>();
		if(!contacts.isEmpty()){
	 		for(Service_Approver__c serviceApprover : [SELECT id, Approver_Contact__c FROM Service_Approver__c WHERE Active__c = true AND Approver_Contact__c IN : contacts]){
				serviceApproverMap.put(serviceApprover.Approver_Contact__c, serviceApprover);
			}
 			for(Contact con :[Select Id, Business_Rule_Association__c from Contact where Id IN: contacts LIMIT 49999]){
 				if(!serviceApproverMap.ContainsKey(con.Id)){
 					con.Business_Rule_Association__c = 'No';
            	}
 				else{
 					con.Business_Rule_Association__c = 'Yes';
        		}
        		contactListToUpdate.add(con);
	 		} 
	 	}
	 	if(!contactListToUpdate.isEmpty()){
        	Database.update(contactListToUpdate, false);
		}
 	} 
}