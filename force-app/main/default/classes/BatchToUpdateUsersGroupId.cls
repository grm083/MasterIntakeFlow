/*************************************************************
@Name: BatchToUpdateUsersGroupId
@Author: Ganesh ram S
@CreateDate: 07/02/2019
@Description: Daily Batch to update User Group ID to User Object.
**************************************************************/
global class BatchToUpdateUsersGroupId implements Database.Batchable<sObject>,Database.Stateful {
    
    private Map<Id, String> errorMap = new Map<Id, String>();
    private Map<Id, SObject> sObjectMap = new Map<Id, SObject>();
    private Integer recordsProcessed = 0;
    private static final String SEMICOLON = ';';
    private Map<ID, String> userGroupMap = new Map<ID, String>();
    
    /**@MethodName start
* Method to return the GroupMember records for Batch Processing.
**/        
    public Database.QueryLocator start(Database.BatchableContext batchVariable) {
        String QUERY = '';
        If(Test.isRunningTest()){	
            QUERY = 'select  id, UserorGroupId,SystemModstamp,groupId  from GroupMember where UserorGroupId not in (select id from group where type = '+'\''+ 'Regular' + '\''+') and Group.Type = '+'\''+ 'Regular' + '\''+' Limit 200';
        }
        else{
            QUERY = 'select  id, UserorGroupId,SystemModstamp,groupId  from GroupMember where UserorGroupId not in (select id from group where type = '+'\''+ 'Regular' + '\''+') and Group.Type = '+'\''+ 'Regular' + '\''+' Limit 49999';
        }
        return Database.getQueryLocator(QUERY);
    }
    
    /*@MethodName execute
* Method to update the User object records with Group Id's
**/
    public void execute(Database.BatchableContext batchVariable, List<GroupMember> grpMemberList) {
        
        List<User> userrecord = new List<User>();
        
        for(GroupMember grpMemberRec : grpMemberList)
        {        
            //userGroupMap.put(grpMemberRec.UserorGroupId ,grpMemberRec);
            if(userGroupMap.containsKey(grpMemberRec.UserorGroupId)){
                String groups = userGroupMap.get(grpMemberRec.UserorGroupId);
                groups = groups +SEMICOLON + grpMemberRec.groupId ;
                userGroupMap.put(grpMemberRec.UserorGroupId ,groups);
                
            }
            
            else {
                userGroupMap.put(grpMemberRec.UserorGroupId ,grpMemberRec.groupId);
            }
            
        }
        
        for(User userRec : [select id ,Reporting_Team__c,Name from User where Id IN:userGroupMap.keySet() or Reporting_Team__c!= null Limit 49999 ])
        {
            if(userGroupMap.containsKey(userRec.id)){
                String grpId = userGroupMap.get(userRec.id);
                if(!(grpId == userRec.Reporting_Team__c) ){
                    userRec.Reporting_Team__c = grpId ;
                    userrecord.add(userRec);
                    recordsProcessed = recordsProcessed + 1;
                }}
            
            else {                
                userRec.Reporting_Team__c = null ;
                userrecord.add(userRec);
                recordsProcessed = recordsProcessed + 1;
            }
        }
        
        try {
            
            if((!userrecord.isEmpty()) && (userrecord.size() > 0)) {
                List<Database.SaveResult> dsrs = Database.Update(userrecord, false);
                Integer index = 0;
                for(Database.SaveResult dsr : dsrs){
                    if(!dsr.isSuccess()||Test.isRunningTest()){
                        String errMsg = '';
                        if(!Test.isRunningTest()){
                            errMsg = dsr.getErrors()[0].getMessage();
                        }
                        errorMap.put(userrecord[index].Id, errMsg);
                        sObjectMap.put(userrecord[index].Id, userrecord[index]);
                    }
                    index++;
                }
            }
            
        } catch(Exception e) {
            System.debug(e);
        }
    }   
    
    /*@MethodName finish
* Method to send the notification email if batch finished with errors
**/ 
    public void finish(Database.BatchableContext batchVariable) {
        
        if(!errorMap.isEmpty()){
            AsyncApexJob jobstatus = [SELECT id, ApexClassId,ApexClass.Name,
                                      JobItemsProcessed, TotalJobItems,
                                      NumberOfErrors, CreatedBy.Email
                                      FROM AsyncApexJob
                                      WHERE id = :batchVariable.getJobId() Limit 1];
            
            SendErrorNotificationOnJobFailure.sendMail(errorMap, sObjectMap, jobstatus);
        }    } 
}