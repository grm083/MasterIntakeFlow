global class PersonalQueueTicketAssignmentTaskBatch implements Database.Batchable<sObject>,Database.Stateful {
    
    Private static final String query = 'SELECT id, Workflow_TeamUser__c, CaseId__c,Workflow_TeamUserId__c,isWorkflowCatUser__c,isWorkflowTeam__c FROM Personal_Queue_Info__c where CaseId__c!= null AND LastModifiedDate = LAST_N_DAYS:1 AND CaseId__r.Status != \'Closed\' order by LastModifiedDate desc LIMIT 49999';
    global final Map<String,String> ticketsWithFailedTaskCreation = new Map<String,String>();
    global final Map<Id,id> caseIdwithUser = new Map<Id,id>();
    Map<Id, Id> TaskidcaseMap = new Map<Id, Id>(); 
    
    
    global PersonalQueueTicketAssignmentTaskBatch(){
    }
    
    public Database.QueryLocator start(Database.BatchableContext batchVariable) {
        system.debug('in start'+Database.getQueryLocator(query));
        return Database.getQueryLocator(query);
        
    }
    
    global void execute(Database.BatchableContext BC, List<Personal_Queue_Info__c> personalQueueInfoList){
        Set<Id> caseId = new Set<Id>();
        Set<Id> caseId2 = new Set<Id>();
        Set<Id> caseId3 = new Set<Id>();
        Set<Id> finalCaseSet = new Set<Id>();
        Set<Id> taskcount = new Set<Id>();
        Set<Id> casePqCatId = new Set<Id>();
        Map<Integer,String> ticketPositionVSTicketCaseNumber = new Map<Integer,String>();
        List<Task> createNewTaskFromCaseAssignment = new List<Task>();
        List<Personal_Queue_Info__c> personalQinfoList = new List<Personal_Queue_Info__c>();
        
        
        set<string> userEmailSet = new set<string>();
        map<string, id> usernameUserIdMap = new map<string, id>();
        map<string,id> usernameCaseIdMap = new map<string,id>();
        map<id,Personal_Queue_Info__c> catUserMap = new map<id,Personal_Queue_Info__c>();
        map<id,Personal_Queue_Info__c> teamUserMap = new map<id,Personal_Queue_Info__c>();
        map<id, List<Id>> openPqTaskCat = new map<id, List<Id>>();
        map<id, List<Id>> openTqTaskTeam = new map<id, List<Id>>();
        map<id, Integer> countPqTask = new map<id, Integer>();
        map<id, Integer> countTqTask = new map<id, Integer>();
        
        if(personalQueueInfoList.size()>0){
            for(Personal_Queue_Info__c pInfo : personalQueueInfoList){
                if(pInfo.isWorkflowCatUser__c && pInfo.CaseId__c != null)
                {
                    if(!catUserMap.containsKey(pInfo.CaseId__c))
                    {
                        catUserMap.put(pInfo.CaseId__c,pInfo);
                    }
                }
                else if(pInfo.isWorkflowTeam__c && pInfo.CaseId__c != null)
                {
                    if(!teamUserMap.containsKey(pInfo.CaseId__c))
                    {
                        teamUserMap.put(pInfo.CaseId__c,pInfo);
                    }
                }
                else
                {
                    caseId.add(pInfo.CaseId__c);
                    if(pInfo.Workflow_TeamUser__c != null){
                        userEmailSet.add(pInfo.Workflow_TeamUser__c.toLowerCase()+'@wm.com');
                    }  
                }
            }
            System.debug('userEmailSet.size()-->'+userEmailSet.size());
            if(userEmailSet.size()>0){
                usernameUserIdMap = getUserNameUserIdMap(userEmailSet);
                for(Personal_Queue_Info__c pInfo : personalQueueInfoList)
                {
                    if(pInfo.Workflow_TeamUser__c != null){
                        if(usernameUserIdMap.containsKey(pInfo.Workflow_TeamUser__c.toLowerCase()))
                        {
                            caseIdwithUser.put(pInfo.CaseId__c, usernameUserIdMap.get(pInfo.Workflow_TeamUser__c.toLowerCase()));
                        }
                    }   
                }
                
                
                System.debug('@@Map'+caseIdwithUser);       
                List <Case > caseList = [Select id,Status from Case where Id IN :caseId and Status != 'Closed' and CreatedDate >= LAST_N_DAYS:90 LIMIT 49999];
                system.debug('caseList-->'+caseList);
                if(caseList.size()>0){
                    for(Case c : caseList){
                        caseId2.add(c.id);
                    }
                }
                List<Task>  tsklist =  [SELECT Id,status,WhatId FROM Task WHERE WhatId IN :caseId2 and status = 'Open' LIMIT 49999] ;
                system.debug('tsklist-->'+tsklist);
                for(Task tsk : tsklist){
                    caseId3.add(tsk.WhatId); 
                }
                if(!caseId3.isEmpty())
                {
                    caseId2.removeAll(caseId3);
                }
                System.debug('@@@Final Case List'+caseId2);
                
                //Removing out this condition " and Status != 'Closed' and CreatedDate >= LAST_N_DAYS:90 LIMIT 49999"
                List <Case > caseList2 = [Select id,Status from Case where Id IN :caseId2];
                system.debug('caseList2-->'+caseList2);
                system.debug('tsklist.size()-->'+tsklist.size());
                
                for(Integer i=0; i<caseList2.size();i++){
                    if(caseIdwithUser.containsKey(caseList2[i].Id) && caseIdwithUser.get(caseList2[i].Id)!=null){
                        Task tObj = new Task();
                        tObj.whatId = caseList2[i].Id;
                        tObj.Subject = 'Personal Queue Ticket Assignment';
                        tObj.Status = 'Open';
                        tObj.Priority = 'Low';
                        if(System.now().hour() >= 15){
                            tObj.Due_Date_Time__c = System.now().addDays(1);
                            tObj.ActivityDate = tObj.Due_Date_Time__c.date();
                        }
                        else{
                            tObj.Due_Date_Time__c = System.now();
                            tObj.ActivityDate = tObj.Due_Date_Time__c.date();
                        }
                        tObj.OwnerId = caseIdwithUser.get(caseList2[i].Id);
                        tObj.Description = 'Acorn Ticket assigned to Personal Queue';
                        ticketPositionVSTicketCaseNumber.put(i,caseList2[i].Id);
                        createNewTaskFromCaseAssignment.add(tObj);     
                    } 
                }
                
            }
            if(!catUserMap.isEmpty())
            {
                //List <Case > casePqList = [Select id,Status from Case where Id IN :catUserMap.keySet() and Status != 'Closed' and CreatedDate >=LAST_N_YEARS:1 LIMIT 49999];
                List<Task>  tskPqlist =  [SELECT Id,status,WhatId,OwnerId,subject FROM Task WHERE WhatId IN :catUserMap.keySet() and status = 'Open' AND subject = 'Personal Queue Ticket Assignment' LIMIT 49999] ;
                for(Task pqTask : tskPqlist)
                {
                    Integer pqCount = 1;
                    Integer tqCount = 0;
                    if(openPqTaskCat.containsKey(pqTask.WhatId))
                    {
                        openPqTaskCat.get(pqTask.WhatId).add(pqTask.OwnerId);
                    }
                    else
                    {
                        openPqTaskCat.put(pqTask.WhatId,new List<Id>{pqTask.OwnerId});
                    }
                    if(pqTask.subject == 'Personal Queue Ticket Assignment')
                    {
                        if(countPqTask.containsKey(pqTask.WhatId))
                        {
                            pqCount++;
                            countPqTask.put(pqTask.WhatId,pqCount);
                        }
                        else
                        {
                            countPqTask.put(pqTask.WhatId,pqCount);
                        }
                    }
                    /*else
                    {
                        if(countTqTask.containsKey(pqTask.WhatId))
                        {
                            tqCount++;
                            countTqTask.put(pqTask.WhatId,tqCount);
                        }
                        else
                        {
                            countTqTask.put(pqTask.WhatId,tqCount);
                        }
                    }*/
                }
                for(Id cPqCase : catUserMap.keySet()){
                    Personal_Queue_Info__c pqDetails = catUserMap.get(cPqCase);
                    Boolean isCreatePqTask = True;
                    if(openPqTaskCat.containsKey(cPqCase))
                    {
                        List<Id> ownwerIdList = openPqTaskCat.get(cPqCase);
                        if(ownwerIdList.contains(pqDetails.Workflow_TeamUserId__c))
                        {
                            isCreatePqTask = False;
                        }
                    }
                    if(countPqTask.get(cPqCase) >= 1)
                    {
                        isCreatePqTask = False;
                    }
                    if(isCreatePqTask){
                        Task tObj = new Task();
                        tObj.whatId = cPqCase;
                        tObj.Subject = 'Personal Queue Ticket Assignment';
                        tObj.Status = 'Open';
                        tObj.Priority = 'Low';
                        if(System.now().hour() >= 15){
                            tObj.Due_Date_Time__c = System.now().addDays(1);
                            tObj.ActivityDate = tObj.Due_Date_Time__c.date();
                        }
                        else{
                            tObj.Due_Date_Time__c = System.now();
                            tObj.ActivityDate = tObj.Due_Date_Time__c.date();
                        }
                        tObj.OwnerId = pqDetails.Workflow_TeamUserId__c;
                        tObj.Description = 'Acorn Ticket assigned to Personal Queue';
                        //ticketPositionVSTicketCaseNumber.put(i,caseList2[i].Id);
                        createNewTaskFromCaseAssignment.add(tObj);     
                    } 
                }
            }
            if(!teamUserMap.isEmpty())
            {
               Integer tqCount = 1;
               List<Task>  tskTqlist =  [SELECT Id,status,WhatId,OwnerId,subject FROM Task WHERE WhatId IN :teamUserMap.keySet() and status = 'Open' LIMIT 49999] ;
                for(Task pqTask : tskTqlist)
                {
                    if(openTqTaskTeam.containsKey(pqTask.WhatId))
                    {
                        openTqTaskTeam.get(pqTask.WhatId).add(pqTask.OwnerId);
                    }
                    else
                    {
                        openTqTaskTeam.put(pqTask.WhatId,new List<Id>{pqTask.OwnerId});
                    }
                    if(pqTask.subject == 'Team Queue Ticket Assignment')
                    {
                        if(countTqTask.containsKey(pqTask.WhatId))
                        {
                            tqCount++;
                            countTqTask.put(pqTask.WhatId,tqCount);
                        }
                        else
                        {
                            countTqTask.put(pqTask.WhatId,tqCount);
                        }
                    }
                }
                for(Id cTqCase : teamUserMap.keySet()){
                    Personal_Queue_Info__c pqDetails = teamUserMap.get(cTqCase);
                    Boolean isCreatePqTask = True;
                    if(openTqTaskTeam.containsKey(cTqCase))
                    {
                        List<Id> ownwerIdList = openTqTaskTeam.get(cTqCase);
                        if(ownwerIdList.contains(pqDetails.Workflow_TeamUserId__c))
                        {
                            isCreatePqTask = False;
                        }
                    }
                    if(countTqTask.get(cTqCase) >= 1)
                    {
                        isCreatePqTask = False;
                    }
                    if(isCreatePqTask){
                        Task tObj = new Task();
                        tObj.whatId = cTqCase;
                        tObj.Subject = 'Team Queue Ticket Assignment';
                        tObj.Status = 'Open';
                        tObj.Priority = 'Low';
                        if(System.now().hour() >= 15){
                            tObj.Due_Date_Time__c = System.now().addDays(1);
                            tObj.ActivityDate = tObj.Due_Date_Time__c.date();
                        }
                        else{
                            tObj.Due_Date_Time__c = System.now();
                            tObj.ActivityDate = tObj.Due_Date_Time__c.date();
                        }
                        tObj.OwnerId = pqDetails.Workflow_TeamUserId__c;
                        tObj.Description = 'Acorn Ticket assigned to Team Queue';
                        //ticketPositionVSTicketCaseNumber.put(i,caseList2[i].Id);
                        createNewTaskFromCaseAssignment.add(tObj);     
                    } 
                } 
            }
            Database.SaveResult[] resultsTask = database.insert(createNewTaskFromCaseAssignment, false);
            for(Integer idx=0; idx < resultsTask.size(); idx++) {
                if (resultsTask[idx].isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully inserted task records ID:' + ticketPositionVSTicketCaseNumber.get(idx));
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : resultsTask[idx].getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Fields that affected the error for task creation: ' + err.getFields());
                        ticketsWithFailedTaskCreation.put(ticketPositionVSTicketCaseNumber.get(idx),err.getMessage());
                    }
                }
            }
            system.debug('::'+ticketsWithFailedTaskCreation.size());    
            
            
            
        }
        
    }
    
    global void finish(Database.BatchableContext BC){
        
        system.debug('::'+ticketsWithFailedTaskCreation);
        String htmlBody = '';
        if(!ticketsWithFailedTaskCreation.isEmpty() || test.isRunningTest()){
            AsyncApexJob job = [SELECT Id, Status, NumberOfErrors,JobItemsProcessed,CreatedById,TotalJobItems, CreatedBy.Email,CreatedBy.Name,ApexClass.Name
                                FROM AsyncApexJob
                                WHERE Id = :BC.getJobId()];
            List<String> sendTo = new List<String>();
            sendTo.add(job.CreatedById);
            //open table..
            htmlBody = '<p>Below is a list of tickets for which task insertion has failed.</p><table border="1" style="border-collapse: collapse"><caption>Ticket Details</caption><tr><th>Ticket Number</th><th>Failed Reason</th></tr>';
            //iterate over list and output columns/data into table rows...
            for(String ticketNumber : ticketsWithFailedTaskCreation.keySet()){
                htmlBody += '<tr><td>' + ticketNumber + '</td><td>' + ticketsWithFailedTaskCreation.get(ticketNumber) + '</td></tr>';
            }
            //close table...
            htmlBody += '</table>';
            
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
          	mail.setToAddresses(sendTo);
            mail.setSubject('Task Creation Failed for the Acorn Ticket');
            mail.setHTMLbody(htmlBody); 
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });    
        }
    }
    public static map<string, id> getUserNameUserIdMap(set<string> emailStrSet){
        map<string, id> userNameUserIdMap = new map<string, id>();
        for(user u : [SELECT id, username FROM User where email IN :emailStrSet AND  isActive = true]){
            userNameUserIdMap.put(u.username.substringBefore(Constant_Util.AT_SYMBOL), u.Id);
        }
        return userNameUserIdMap;
    }
}