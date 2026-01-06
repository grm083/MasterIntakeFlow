@istest
public class CreateCaseHistoryTest {

    @testSetup
    public static void dataSetup() {
        Profile p = TestDataFactory.getProfile('System Administrator');
        User usr = TestDataFactory.createUser(p);
        Database.insert(usr);
        system.runAs(usr){
            Account clientAcc = TestDataFactory.createAccount(Constant_Util.KEYWORD_TEST, usr,'Client')[0];
            Database.insert(clientAcc);
            Account locAcc = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, clientAcc.id)[0];
            locAcc.tz__Timezone_SFDC__c='America/Chicago';
            Database.insert(locAcc);
            Contact contct = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST,Constant_Util.CONSTANT_LAST, clientAcc, usr)[0];
            Database.insert(contct);
            Product2 prdct = TestDataFactory.createProduct('Sample Product Test')[0];
            Database.insert(prdct);
            Asset asst = TestDataFactory.createAsset('Test Asset', clientAcc,contct, prdct, usr,locAcc)[0];
            Database.insert(asst);
            List<Case> cseList = new List<Case>();
                //TestDataFactory.createCase('', clientAcc,contct, usr, locAcc,asst);
            String rcdTypeId = TestDataFactory.getRecordType('Pickup Case', 'Case');
            for(Integer i=0;i<1;i++){
                Case cse = new case();
                cse.ContactId = contct.id;
                cse.AccountId = clientAcc.id;
                cse.OwnerId = usr.id;
                cse.Client__c = locAcc.ParentId;
                cse.Location__c = locAcc.id;
                cse.assetid = asst.id;
                cse.Case_Type__c = 'Pickup';
                cse.Case_Sub_Type__c = 'Extra Pickup';
                cse.SlaStartDate = system.today();
                cse.Service_Date__c = system.today();
                cse.RecordTypeId = rcdTypeId;
                cseList.add(cse);
            }
            
            Database.insert(cseList);
        }
    }
    
    
    public static testmethod void createCommentTest(){
        Case cse = [Select id from Case limit 1];
        test.startTest();
        CaseComment comm = new CaseComment();
        comm.CommentBody = 'Test Test';
        comm.ParentId = cse.Id;
        Database.insert(comm);
        Case_History_Tracker__c tracker = [Select id from Case_History_Tracker__c where Related_Record_Id__c =: comm.Id];
        system.assert(tracker != null);
        Comment__c comment = new Comment__c(Case__c = cse.Id, Comment__c = 'Test Comment');
        Database.insert(comment);
        Case_History_Tracker__c track = [Select id from Case_History_Tracker__c where Related_Record_Id__c =: comment.Id];
        system.assert(track != null);
        test.stopTest();
    }
    
    public static testmethod void createUpdateAprovalLogTest(){
        Case cse = [Select id from Case limit 1];
        test.startTest();
        Approval_Log__c apprvl = new Approval_Log__c();
        apprvl.CaseId__c = cse.Id;
        database.insert(apprvl);
        Case_History_Tracker__c tracker = [Select id from Case_History_Tracker__c where Related_Record_Id__c =: apprvl.Id and Action__c =: Constant_Util.CREATED];
        system.assert(tracker != null);
        apprvl.Status__c = 'Approval Requested';
        //RecurrsiveTriggerHandler.isSkipApprovalLogTrigger = false;
		TriggerDispatcher.skipTriggerExecutionMap.put(Approval_Log__c.sobjectType.getDescribe().getName(),false);
        Database.update(apprvl);
        //RecurrsiveTriggerHandler.isSkipApprovalLogTrigger = false;
		TriggerDispatcher.skipTriggerExecutionMap.put(Approval_Log__c.sobjectType.getDescribe().getName(),false);
        Case_History_Tracker__c track = [Select id from Case_History_Tracker__c where Related_Record_Id__c =: apprvl.Id and Action__c =: Constant_Util.UPDATED];
        system.assert(track != null);
        test.stopTest();
    }
    
      public static testmethod void createWOTest(){  
        Case cse = [Select Id,Status,Location__c,ContactId,AssetId,OwnerId,Case_Sub_Status__c from Case limit 1];
        test.startTest();
        //cse.Status = Constant_Util.PENDING;
        cse.Status = Constant_Util.OPEN;
        cse.Case_Sub_Status__c = Constant_Util.PENDING_SERVICE_INTEGRATION;
		Database.update(cse);
        
        WorkOrder wrkOrdr1 = TestDataFactory.createWorkOrder(new Account(Id=cse.Location__c), new Contact(Id=cse.ContactId),cse, new Asset(Id = cse.AssetId))[0];

        wrkOrdr1.Status = 'Pending/Draft';
   
		TriggerDispatcher.skipTriggerExecutionMap.put(workorder.sobjectType.getDescribe().getName(),false);
        Database.insert(wrkOrdr1);
       
		TriggerDispatcher.skipTriggerExecutionMap.put(workorder.sobjectType.getDescribe().getName(),true);
     
        test.stopTest();
            
        system.assert(wrkOrdr1.Status == 'Pending/Draft'); 
        system.assert(wrkOrdr1 != null);
            
    } 
	
    /*public static testmethod void UpdateWOTest(){
        Case cse = [Select id from Case limit 1];
        cse.Status = 'Pending';
        Database.update(cse);
        test.startTest();
        WorkOrder wrkordr = [Select Id from WorkOrder where CaseId =: cse.Id];
        wrkordr.Status = 'Pending/Draft';
        RecurrsiveTriggerHandler.isSkipWorkOrderTrigger = false;
		//TriggerDispatcher.skipTriggerExecutionMap.put(workorder.sobjectType.getDescribe().getName(),false);
        Database.update(wrkordr);
        RecurrsiveTriggerHandler.isSkipWorkOrderTrigger = true;
		//TriggerDispatcher.skipTriggerExecutionMap.put(workorder.sobjectType.getDescribe().getName(),true);
        Case_History_Tracker__c track = [Select id from Case_History_Tracker__c where Related_Record_Id__c =: wrkordr.Id and Action__c =: Constant_Util.UPDATED];        
        system.assert(track != null);
        test.stopTest();
    }*/
    
    public static testmethod void createCDLTest(){
        Case cse = [Select id from Case limit 1];
        ContentVersion contentverse = new ContentVersion(Title = 'Test',PathOnClient = 'Test',VersionData = Blob.valueOf('Test Content Data'));
        Database.insert(contentverse);
        ContentVersion testContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id =: contentverse.Id];
        
        test.startTest();
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = cse.id;
        contentlink.ShareType = 'V';
        contentlink.ContentDocumentId = testcontent.ContentDocumentId;
        contentlink.Visibility = 'AllUsers';
        RecurrsiveTriggerHandler.isSkipContentDocumentLinkTrigger = false;
		//TriggerDispatcher.skipTriggerExecutionMap.put(ContentDocumentLink.sobjectType.getDescribe().getName(),false);
        Database.insert(contentlink);
        RecurrsiveTriggerHandler.isSkipContentDocumentLinkTrigger = true;
		//TriggerDispatcher.skipTriggerExecutionMap.put(ContentDocumentLink.sobjectType.getDescribe().getName(),true);
        system.debug('link details'+contentlink+' document details'+testContent+' linked type'+contentlink.LinkedEntityId.getSObjectType().getDescribe().getName());
        Case_History_Tracker__c track = [Select id from Case_History_Tracker__c where Related_Record_Id__c =: testcontent.ContentDocumentId and Action__c =: Constant_Util.ADDED];        
        system.assert(track != null);
        test.stopTest();
    }
    
    public static testmethod void createEmailTest(){
        Case cse = [Select id from Case limit 1];
        test.startTest();
        List<EmailMessage> emailList = new List<EmailMessage>();
        EmailMessage emailFro = new EmailMessage();
        emailFro.ParentId = cse.Id;
        emailFro.FromAddress = UserInfo.getUserEmail();
        emailFro.ToAddress = 'xyz@test.com';
        emailFro.Subject = 'Test email';
        emailFro.Incoming = true;
        emailFro.HtmlBody = 'Test';
        emailFro.TextBody = 'Test';
        EmailMessage emailTo = new EmailMessage();
        emailTo.ParentId = cse.Id;
        emailTo.FromAddress = UserInfo.getUserEmail();
        emailTo.ToAddress = 'xyz@test.com';
        emailTo.Subject = 'Test email';
        emailTo.Incoming = false;
        emailTo.HtmlBody = 'Test';
        emailTo.TextBody = 'Test';
        emailList.add(emailTo);
        emailList.add(emailFro);
        Database.insert(emailList);
        Case_History_Tracker__c track = [Select id from Case_History_Tracker__c where Related_Record_Id__c =: emailFro.Id and Action__c =: Constant_Util.RECEIVED];        
        system.assert(track != null);
        test.stopTest();
    }
    
    
    public static testmethod void createUpdateTaskTest(){
        User usr = [SELECT Id, Bypass_Validation__c 
                    FROM User 
                    WHERE ProfileId =:(TestDataFactory.getProfile('System Administrator')).Id 
                    AND IsActive = true 
                    LIMIT 1];

        System.runAs(usr) {      
            Case cse = [SELECT Id FROM Case LIMIT 1];

            test.startTest();
            Task tsk = new Task();
            tsk.WhatId = cse.Id;
            tsk.Subject = 'Test';
            Database.insert(tsk);

            Case_History_Tracker__c tracker = [SELECT Id 
                                            FROM Case_History_Tracker__c 
                                            WHERE Related_Record_Id__c =: tsk.Id 
                                            AND Action__c =: Constant_Util.CREATED
                                            LIMIT 1];
            system.assert(tracker != null);

            tsk.Status = 'Completed';
            tsk.Process__c = 'Confirm Service Completion';
            tsk.Outcome__c = 'Service Confirmed';
            RecurrsiveTriggerHandler.isSkiptaskTrigger = false;
            Database.update(tsk);
            RecurrsiveTriggerHandler.isSkiptaskTrigger = true;
            test.stopTest();

            Case_History_Tracker__c track = [SELECT Id 
                                            FROM Case_History_Tracker__c 
                                            WHERE Related_Record_Id__c =: tsk.Id 
                                            AND Action__c =: Constant_Util.UPDATED LIMIT 1];        
            System.assert(track != null);
        }
    }
    
    public static testmethod void createRelatedCaseTest(){
        Case cse = [Select id from Case limit 1];
        test.startTest();
        Case newCase = cse.clone(false, false, false, false);
        newCase.ParentId = cse.Id;
        newCase.Is_Clone__c = true;
        newCase.Check_Case__c =true;
        Database.insert(newCase);
        Case_History_Tracker__c track = [Select id from Case_History_Tracker__c where Related_Record_Id__c =: newCase.Id and Action__c =: Constant_Util.CREATED];        
        system.assert(track != null);
        List<Case_History_Tracker__c> historyList = CreateCaseHistory.fetchHistoryRecords(cse.Id);
        system.assertEquals(historyList.size(),1);
        test.stopTest();
    }
    
       public static testmethod void getRelatedtaskTest(){
        user currentuser = [SELECT id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        system.runAs(currentuser){
            List<Case> caseList = [Select ID from Case Limit 1];
            list<Task> tasklist = [SELECT Id,Process__c,Outcome__c, Owner.Name, CreatedDate, WhatId,WhoId,Contact_Email__c,Contact_Number__c,Preferred_Contact_Method__c,Business_Rule__c,Business_Rule__r.Multiple_Mandatory_Approvers__c,Approval_Log__c,Attempt__c 
						FROM Task limit 1];
            test.startTest();
            List<Task> resultList = CreateCaseHistory.getRelatedtask(caseList[0].Id);
            test.stopTest();
            system.assert(resultList != null);
        }
    }   
    
}