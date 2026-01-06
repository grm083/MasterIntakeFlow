/**************************************************
* ClassName:AssignToMeCntrl
* Author:Kyle Homovec 
* Description:Class created to check ownership of email tasks related to the email message, then complete.  Controller for 
    closeEmailTaskComponent.
* CreatedDate:10/16/2019
* **************************************************/
public without sharing class CloseEmailTaskController {
    //This method updates the email tasks to completed.
    @AuraEnabled
    public static Boolean EmailTaskComplete(Id messageId){ 
        Boolean Tasksupdated = false;
        Set<Id> caseSet = new Set<Id>();
        List<Task> updatetasks = new List<Task>();
        Id Email2CaseRecId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Email to Case').getRecordTypeId();
        EmailMessage message;
        
        message = [SELECT Id, ParentId FROM EmailMessage WHERE Id = :messageId LIMIT 1];
        
        for(Task t : [SELECT Id, WhatId, RecordTypeId, Status, Description FROM Task WHERE WhatId = :message.ParentId AND RecordTypeId = :Email2CaseRecId AND Status != 'Completed' LIMIT 49999 ]){
            t.Status = 'Completed';
            if(!string.isBlank(t.Description)){
                t.Description = 'This task was completed by ' + UserInfo.getUserName() + '\n' + t.Description;
            }else{
                t.Description = 'This task was completed by ' + UserInfo.getUserName();
            }
            
            updatetasks.add(t);
        }
        
        System.debug('tasks to update-- ' + updatetasks);
        if(updatetasks.size()>0){
            try{
                update updatetasks;
            }catch(Exception e){
                System.debug('CloseEmailTask exc --- ' + e.getMessage());
                System.debug('CloseEmailTask stack -- ' + e.getStackTraceString());
            }
            Tasksupdated = true;
        }
        
        return Tasksupdated;

}

//This method checks the related tasks to see if any are not owned by the user or genesys integration user.
@auraEnabled
public static Boolean taskOwnerCheck (Id messageId){ 
    
    Boolean otherOwners = false;
    Id Email2CaseRecId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Email to Case').getRecordTypeId();
    Id currentUserId = UserInfo.getUserId();
    List<Task> taskList = new List <Task>();
    EmailMessage message;
    message = [SELECT Id, ParentId FROM EmailMessage WHERE Id = :messageId LIMIT 1];
    
    User genUser = [SELECT Id, Name FROM User WHERE Name = 'Genesys Integration' LIMIT 1];
    
    for(Task t : [SELECT Id, whatId FROM Task WHERE WhatId = :message.ParentId AND OwnerId != : currentUserId AND OwnerId != :genUser.id AND RecordTypeId = :Email2CaseRecId AND Status != 'Completed' LIMIT 49999]){  
        taskList.add(t);
    }

    if(taskList.size()>0){
        otherOwners = true;
    }
    return otherOwners;

}
}