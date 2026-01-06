/*************************************************************
@Name: contactUpdateBatch
@Author: Accenture
@CreateDate: 03/08/2020
@Description: SDT- 13765 One Time Batch class to update fields No. of Location and Business Association on Contact
@UsedBy: 
**************************************************************/
public class contactUpdateBatch implements Database.Batchable<sObject> {
	List <Contact> updatecontact = null;
    private Static final String query = 'SELECT Id from contact';
    private Static final String YES = 'Yes';
    private Static final String NO = 'No';
    public Database.QueryLocator start(Database.BatchableContext BC){
       
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<contact> scope){
        List<Contact> conlist = (List<Contact>)scope;
    	updatecontact = new List<Contact>();
        set<Id> contactIdset = new Set<Id>();
        map<Id,Integer> conlocCountMap = new map<Id,Integer>();
        set<Id> brAssociationSet = new set<Id>();
        for (contact c : conlist){
        	contactIdset.add(c.Id);
        }
        for(Aggregateresult ar : [SELECT COUNT(Id)cnt,contactId FROM AccountContactRelation WHERE Account_Record_Type__c =: Constant_Util.LOCATION and contactId IN: contactIdset Group by contactId]){
			conlocCountMap.put((ID)ar.get('contactId'),Integer.valueof(ar.get('cnt')));
        }
        for(Service_Approver__c  sa : [Select Id,Approver_Contact__c FROM Service_Approver__c WHERE Approver_Contact__c In : contactIdset and Active__c = true and Business_Rule__r.Active__c = true Limit 49999]){
            brAssociationSet.add(sa.Approver_Contact__c);
        }
        contact con = null;
        for (contact cnt : conlist){
        	con = new contact();
            con.Id = cnt.Id;
            con.No_Of_Locations_Assoc_With_Contact__c = !conlocCountMap.IsEmpty() && conlocCountMap.size() > 0 && conlocCountMap.containskey(cnt.Id) ? conlocCountMap.get(cnt.Id) : 0;
            con.Business_Rule_Association__c = !brAssociationSet.IsEmpty() && brAssociationSet.size() > 0 && brAssociationSet.contains(cnt.Id) ? YES : NO;
            updatecontact.add(con);
        }
        if(!updatecontact.isEmpty() && updatecontact.size() > 0){
            try {
                Database.Update(updatecontact,false);
            }catch(Exception ex){
                system.debug('Exception Occured'+ex.getStackTraceString());
            }
        }
    }
    public void finish(Database.BatchableContext BC) {
    }
}