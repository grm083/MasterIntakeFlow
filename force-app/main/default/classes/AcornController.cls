/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 09-01-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class AcornController {
    public static final string ESC_CHAR_REGEX = '(?m)(\\\\r\\\\n|\\\\n\\\\t|\\\\[rnt])';

    @AuraEnabled
    public static List<Comment__c> getAcornComments(String caseId) {
        Id recordTypeId = Schema.getGlobalDescribe().get('Comment__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Acorn_Ticket_Comment').getRecordTypeId();
        
        List<Comment__c> notes= [SELECT Id, Name, Communication_Log_Type_Name__c, Comment__c, CreatedDate,Workflow_Action__c,Workflow_TeamUser__c from Comment__c 
                                              where Case__r.Id =: caseId and RecordTypeId =: recordTypeId order by CreatedDate DESC];
        //System.debug('Returned Notes: ' + notes.size());
        //System.debug('>>>>> ' + notes);
        return notes;
    }

    @AuraEnabled

    public static List<caseComments> getCommentData(String caseId , Integer size, Boolean sortAsc, String sortColumn) {
        
        List<caseComments> notes = new List<caseComments>();
        List<caseComments> notesSorted = new List<caseComments>();
        List<Case> cList = [SELECT Id, Tracking_Number__c
                  FROM Case
                  WHERE Id =: caseId];
        if(cList != null && !cList.isEmpty()){
            Case c = cList[0];
            If (!string.isBlank(c.Tracking_Number__c)  ) {
                List<CaseComments__x> ExtNotes= [SELECT WorkflowAction__c, WorkflowTeamUser__c,
                                                 CreatedDate__c, Comment__c, ChannelType__c,CreatedBy__c
                                                 FROM CaseComments__x 
                                                 WHERE CaseId__c =: caseId
                                                 LIMIT :size ];                                              
                System.debug(ExtNotes);               
                for (CaseComments__x extComment : ExtNotes) {
                    String extCom = extComment.Comment__c;
                    if(!extCom.startsWithIgnoreCase(Constant_Util.CAPACITY_PLANNER))
                    {
                        caseComments instance = new caseComments(extComment.WorkflowAction__c, extComment.WorkflowTeamUser__c,
                                                                 extComment.CreatedDate__c, extComment.Comment__c, extComment.ChannelType__c,extComment.CreatedBy__c , sortAsc , false, sortColumn);
                        notes.add(instance);
                    }
                                    
                }  
    
               List<Comment__c> IntNotes= [SELECT Id, Name, Communication_Log_Type_Name__c, Comment__c,  is_Log__c,
                                            CreatedDate,Workflow_Action__c,Workflow_TeamUser__c, Related_SObject_Id__c, Related_SObject_Key__c from Comment__c 
                                            where Case__r.Id =: caseId AND (is_Log__c = true OR Workflow_Action__c = 'Capacity_Planner' OR Communication_Log_Type_Name__c =: Constant_Util.INTERNAL) LIMIT :size ];
                
                for (Comment__c intComment : IntNotes) {
                    caseComments instance = new caseComments(intComment.Workflow_Action__c, intComment.Workflow_TeamUser__c,
                                                            intComment.CreatedDate, intComment.Comment__c, intComment.Communication_Log_Type_Name__c,null, sortAsc , intComment.is_Log__c, sortColumn);
                    
                    instance = populateCaseComments(instance, intComment);
                    notes.add(instance);
                    System.debug('@@ComInstance'+instance);
																						   
	
																				  
																						   
	
																									  
																			   
																							
							 
																									 
																					  
																					
							 
																									  
																						 
																					 
							 
							
																																				 
																															  
							 
												
					 
                    if(!String.isBlank(intComment.Comment__c) && intComment.Workflow_Action__c == 'Capacity_Planner'){
					 
                        notes.add(instance);
                    }
                }
                notes.sort();
                Integer i = 0;
                Integer max = (size < notes.size()) ? size : notes.size();
                while(i < max){
                    notesSorted.add(notes[i]); 
                    i++;
                }
            } else { 
                Id recordTypeId = Schema.getGlobalDescribe().get('Comment__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Acorn_Ticket_Comment').getRecordTypeId();
																   
							
                List<Comment__c> IntNotes = [SELECT Id, Name, Communication_Log_Type_Name__c, Comment__c,  is_Log__c,
                                            CreatedDate,Workflow_Action__c,Workflow_TeamUser__c, Related_SObject_Id__c, Related_SObject_Key__c from Comment__c 
                                            where Case__r.Id =: caseId and (RecordTypeId =: recordTypeId OR is_Log__c = true OR Communication_Log_Type_Name__c =: Constant_Util.INTERNAL)];
						
																									   
																																				   
																																			  
				 
                
                for (Comment__c intComment : IntNotes) {
                    caseComments instance = new caseComments(intComment.Workflow_Action__c, intComment.Workflow_TeamUser__c,
                                                            intComment.CreatedDate, intComment.Comment__c, intComment.Communication_Log_Type_Name__c,null, sortAsc , intComment.is_Log__c, sortColumn);
                    
                    instance = populateCaseComments(instance , intComment);
																							 
																					 
																					   

																			   
																						  

																								  
																		   
																						
						 
																								 
																				  
																				
						 
																								  
																					 
																				 
						 
						
																																			 
																														  
						 
					 
                    notesSorted.add(instance);
                    notesSorted.sort();
                }
            }
        }
        return notesSorted;
    }
    @AuraEnabled
    public static String createAcornComment(String comment, String caseId) {
        System.debug('Case Id: ' + caseId);
        if (!caseId.startsWith('500')) {
            return 'Invalid Case Id.  You need to be viewing a Case when creating an Acorn Note.';
        } else{}
        
        Id recordTypeId = Schema.getGlobalDescribe().get('Comment__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Acorn_Ticket_Comment').getRecordTypeId();
        Case curCase = [select CaseNumber, Tracking_Number__c from Case where Id =: caseId limit 1];
        
        //Decimal acornUserId = [select Acorn_SUser_ID__c from User where ID =: System.UserInfo.getUserId()].Acorn_SUser_ID__c;
        Id userId = System.UserInfo.getUserId();
        Decimal acornUserId = SystemObjectSelector.acornUserId(userId);
        System.debug('Acorn User Id: ' + acornUserId);
        
        Comment__c note = new Comment__c();
        note.Case__c = caseId;
        note.Comment__c = comment;
        note.Communication_Log_Type_Name__c = 'Internal';
        note.Case_Number__c = curCase.CaseNumber;
        note.recordTypeId = recordTypeId;
        if (String.isNotEmpty(curCase.Tracking_Number__c)) note.Acorn_Tracking_Number__c = curCase.Tracking_Number__c;
        if(comment.startsWithIgnoreCase(Constant_Util.CAPACITY_PLANNER))
        {
            note.Workflow_Action__c = Constant_Util.CAPACITY_PLANNER_ACTION;
        }
        else
        {
            note.Workflow_Action__c = '';
        }
        note.Workflow_TeamUser__c = System.UserInfo.getName();
        note.Acorn_SUser_ID__c = acornUserId;
        note.Type__c = Constant_Util.OBJECT_CASE;
        
        insert note;
        
        return 'ok';
    }
    
 //Bulkified method to create comments for cases    
    public static void createAcornCommentforCase(Map<Id,String>caseComment) {
             
		List<Comment__c> notesList = new List<Comment__c>();
		
		Id recordTypeId = Schema.getGlobalDescribe().get('Comment__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Acorn_Ticket_Comment').getRecordTypeId();
        //Case curCase = [select CaseNumber, Tracking_Number__c from Case where Id =: caseId limit 1];
        //soql 101 issue
        //Decimal acornUserId = [select Acorn_SUser_ID__c from User where ID =: System.UserInfo.getUserId()].Acorn_SUser_ID__c;
       
        //soql 101 issue sprint 8
         Id userId = System.UserInfo.getUserId();
        Decimal acornUserId = SystemObjectSelector.acornUserId(userId);
        System.debug('Acorn User Id: ' + acornUserId);
        
		try{
            if(caseComment.keyset() != null) { 
                    for(Case curCase : [SELECT CaseNumber, Tracking_Number__c FROM Case WHERE Id IN : caseComment.keyset()]){	
                        Comment__c note = new Comment__c();
                        note.Case__c = curCase.Id;
                        note.Comment__c = caseComment.get(curCase.Id);
                        note.Communication_Log_Type_Name__c = 'Internal';
                        note.Case_Number__c = curCase.CaseNumber;
                        note.recordTypeId = recordTypeId;
                        if (String.isNotEmpty(curCase.Tracking_Number__c)) note.Acorn_Tracking_Number__c = curCase.Tracking_Number__c;
                        note.Workflow_Action__c = '';
                        note.Workflow_TeamUser__c = System.UserInfo.getName();
                        note.Acorn_SUser_ID__c = acornUserId;
                        note.Type__c = Constant_Util.OBJECT_CASE;
                    notesList.add(note);                     
                 }
            }
            if(notesList != null && notesList.size() > 0)
            {
                Database.insert(notesList,false);
            }            
		}catch(Exception e){
            //To handle Error in future Sprints
            System.debug('Exception::::'+e.getStackTraceString());
        }		
    }
    
    public class caseComments implements Comparable{
        @AuraEnabled
        public string WorkflowAction {get;set;}
        @AuraEnabled
        public string WorkflowTeamUser {get;set;}
        @AuraEnabled
        public datetime CreatedDate {get;set;}
        @AuraEnabled
        public string Comment {get;set;}
        @AuraEnabled
        public string ChannelType {get;set;}
        @AuraEnabled
        public string CreatedBy {get;set;}//added by saurav
        @AuraEnabled
        public string sObjectId {get;set;}
        @AuraEnabled
        public string commentData {get;set;}
        @AuraEnabled
        public string sobjectType {get;set;}
        @AuraEnabled
        public string sobjectKey {get;set;}
        @AuraEnabled
        public string title {get;set;}
        @AuraEnabled
        public Boolean sortAsc {get;set;}
        @AuraEnabled
        public Boolean isLog {get;set;}
        @AuraEnabled
        public String sortColumn {get;set;}
 
        //Constructor
        public caseComments (String WorkflowAction, String WorkflowTeamUser, 
                            DateTime CreatedDate, String Comment, String ChannelType, 
                            String CreatedBy, Boolean sortAsc, Boolean isLog, String sortColumn) { 
            this.WorkflowAction = WorkflowAction;
            this.WorkflowTeamUser = WorkflowTeamUser;
            this.CreatedDate = CreatedDate;
            //to avoid html tags
            this.Comment = String.isNotEmpty(Comment) ? Comment.replaceAll(ESC_CHAR_REGEX, '<br>') : '';
            this.ChannelType = ChannelType;
            this.CreatedBy = CreatedBy;  
            this.sortAsc = sortAsc;    
            this.sortColumn = sortColumn;
            this.isLog = isLog;            
        }

        public Integer compareTo(Object instance)
        {
            caseComments that = (caseComments)instance;
            Integer sortIndex = 0;
            if(this.sortColumn == Constant_Util.COMMENT_DATE_COLUMN) {
                if (this.CreatedDate > that.CreatedDate) sortIndex = 1;
                if (this.CreatedDate < that.CreatedDate) sortIndex = -1;
            } 
            else  if(this.sortColumn == Constant_Util.COMMENT_USER_TEAM_COLUMN) {
                if (this.WorkflowTeamUser > that.WorkflowTeamUser) sortIndex = 1;
                if (this.WorkflowTeamUser < that.WorkflowTeamUser) sortIndex = -1;
            } 
            else if(this.sortColumn == Constant_Util.EDITED_BY_COLUMN) {
                if (this.CreatedBy > that.CreatedBy) sortIndex = 1;
                if (this.CreatedBy < that.CreatedBy) sortIndex = -1;
            } 
            else if(this.sortColumn == Constant_Util.COMMENT_ACTION_COLUMN) {
                if (this.WorkflowAction > that.WorkflowAction) sortIndex = 1;
                if (this.WorkflowAction < that.WorkflowAction) sortIndex = -1;
            } 
            else if(this.sortColumn == Constant_Util.COMMENT_SOURCE_COLUMN) {
                if (this.ChannelType > that.ChannelType) sortIndex = 1;
                if (this.ChannelType < that.ChannelType) sortIndex = -1;
            }
            if(this.sortAsc) {
                return sortIndex;
																   
						 
            } else {
                return sortIndex*(-1);
																  
						 
            }
        }                   
    }

    public static caseComments populateCaseComments(caseComments instance, Comment__c intComment) {
        if(!String.isBlank(intComment.Comment__c) && 
            (intComment.Workflow_Action__c == Constant_Util.WORK_ORDER_ACTION_TYPE ||
            intComment.Workflow_Action__c == Constant_Util.TASK_ACTION_TYPE||
            intComment.Workflow_Action__c == Constant_Util.EMAIL_ACTION_TYPE)){

            instance.sObjectId = intComment.Related_SObject_Id__c; 
            instance.sobjectKey = intComment.Related_SObject_Key__c;          

            if(intComment.Workflow_Action__c == Constant_Util.WORK_ORDER_ACTION_TYPE){
                instance.sobjectType = Constant_Util.WorkOrder;
                instance.title = Constant_Util.WORK_ORDER_ACTION_TYPE;      
            }
            else if(intComment.Workflow_Action__c == Constant_Util.TASK_ACTION_TYPE){
                instance.sobjectType = Constant_Util.TASK_ACTION_TYPE;
                instance.title = Constant_Util.TASK_ACTION_TYPE;    
            }
            else if(intComment.Workflow_Action__c == Constant_Util.EMAIL_ACTION_TYPE){
                instance.sobjectType = Constant_Util.OBJECT_EMAILMESSAGE;
                instance.title = Constant_Util.EMAIL_ACTION_TYPE;    
            }
            
            if(intComment.Related_SObject_Key__c != null && intComment.Comment__c.startsWith(intComment.Related_SObject_Key__c)){
                instance.commentData = intComment.Comment__c.replace( intComment.Related_SObject_Key__c , '');
            }
        }
        return instance;
    }
	
	/*
     * @Method Name    : returnTwoWayCommMetadata
     * @author         : TCS
     * @description    : This method queries the metadata from 'Two_way_communication__mdt' Custom Metadata type and 
     * keeps the MasterLabel in a list of string.
     * @return         : Returns a list of metadata MasterLabel. 
   */
      @auraEnabled
      public static List<String> returnTwoWayCommMetadata() {
          List<String> masterLabelList = new List<String>();
          masterLabelList = AcornController.returnMetadata();
          return masterLabelList;
      }
    
     /*
     * @Method Name    : returnTwoWayResponse
     * @author         : TCS
     * @description    : This method queries the metadata from 'Two_way_communication__mdt' Custom Metadata type and 
     *  compare with Origin based on that it will return Boolean value based on Custom metadata and case origin.
     * @return         : Returns a list of metadata MasterLabel. 
	 */
    //   @auraEnabled
    //   public static Boolean returnTwoWayResponse(String caseId) {
    //     Boolean returnToTwowayComm = false;  
    //     List<String> masterLabelList = new List<String>();
    //     masterLabelList = AcornController.returnMetadata();      
    //     Case caseObj  = TwoWayService.returnCaseDetails(caseId);
    //     returnToTwowayComm = masterLabelList.contains(caseObj.Origin);
    //     return returnToTwowayComm;
    //   }

      @auraEnabled
      public static responseTwoWayCommunication returnTwoWayResponse(String caseId) {
        responseTwoWayCommunication returnToTwowayComm = new responseTwoWayCommunication();
        // Boolean returnToTwowayComm = false;  
        List<String> masterLabelList = new List<String>();
        masterLabelList = AcornController.returnMetadata();      
        Case caseObj  = TwoWayService.returnCaseDetails(caseId);
        // returnToTwowayComm = masterLabelList.contains(caseObj.Origin);

        returnToTwowayComm.isTwoWayCommunication = masterLabelList.contains(caseObj.Origin);
        returnToTwowayComm.caseOrigin = caseObj.Origin;
        return returnToTwowayComm;
      }
    
    /*
     * @Method Name    : returnMetadata
     * @author         : TCS
     * @description    : This method is a supporing method to fetch Custom metadata and return Labels
     * @return         : Returns a list of metadata MasterLabel. 
   */
      Private static List<String> returnMetadata() {
          List<String> masterLabelList = new List<String>();
          Map<String, Two_way_communication__mdt> mtdataList = MetadataSelector.getTwoWayCommSwitchMtData();
          for(String twoWaycomm: mtdataList.keySet()){
              if(mtdataList.get(twoWaycomm).Enable_Switch__c == true)
              {
                   masterLabelList.add(mtdataList.get(twoWaycomm).Label);
              }
    		}
          return masterLabelList;
      }
    public class responseTwoWayCommunication{
        @auraEnabled public Boolean isTwoWayCommunication;
        @auraEnabled public String caseOrigin;
    }        
}