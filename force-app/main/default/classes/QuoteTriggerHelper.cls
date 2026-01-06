public class QuoteTriggerHelper {
    /*
    private static final string COST_CONFIGURED_STATUS = 'Cost Configured';
    private static final string DRAFT_STATUS = 'Draft';
    private static final string EXTRA_PICKUP_PRODUCT = 'Extra Pickup';
    private static final string PICKUP_PRODUCT = 'Pickup';
    private static final string SCHEDULED_TYPE = 'SCH';
    */    
    private static String sUnknown = 'UNK';		//TCS-pkulkarn-SDT-42390-6-Nov-2024-Added
    private static  boolean flag = false;
    //SDT 48524
    private static String stpUserId = '';
    private static String stpUserName = 'STP Systemuser';
    //SDT-23088 - Flag is created to update Genesys fields Synchronously or Asynchronously through CreateGenesysForQuoteBatch
    public static Boolean RunAsyncGenesysCreation = true;
    
    public static Map<Id,SBQQ__Quote__c> oldMapStatic = new Map<Id,SBQQ__Quote__c>();
    //private static Map<String,String> mapOfoldStatus = new Map<String,String>();
    public static void getQuoteData(List<SBQQ__Quote__c > QuoteNewList, Map<Id,SBQQ__Quote__c> oldMap, Map<Id,SBQQ__Quote__c> newMap){
        
        system.debug('QuoteNewList--->'+ QuoteNewList);
        for(SBQQ__Quote__c quote : newMap.values()){
            system.debug('quote--->' + quote.SBQQ__Status__c);
            if(quote.SBQQ__Status__c != oldMap.get(quote.id).SBQQ__Status__c || quote.SBQQ__Status__c != 'Draft'){
                
                //QuoteApprovalProcess.getQuoteApprovalData(quote);
                //for(Business_Rule__c br : [Select Id,Required_Information__c,AccountId__c,Container__c,Case_Reason__c,Material__c,LocationId__c,Service__c,Schedule_Type__c,End_Date__c,Project_Code__c,AssetId__c,Channel__c,Multiple_Mandatory_Approvers__c,Occurrence_Limit__c,Category_Type__c,Group__c,No_Approval_Required__c,RecordTypeId,Special_Instructions_Approval__c,(Select Id,Account_Team_Member__c,Business_Rule__c,RecordTypeId,Title__c,Account_Department__c,External_Approver_Email__c,External_Approver_Phone_Number__c,Account_Title__c,Approver_Type__c,Email__c,User__c,ServiceApprover__c,SortBy__c,Approver_Contact__c,Title__r.Name,Approver_Contact__r.FirstName,Approver_Contact__r.LastName,Account_Team_Member__r.FirstName,Account_Team_Member__r.LastName,User__r.FirstName,User__r.LastName,Requester_Only__c from Approver_Entities__r where Active__c = true Order BY SortBy__c,ServiceApprover__c ASC) from Business_Rule__c where AccountId__c In: accontIdSet and Active__c =: true and Effective_Date__c <=: System.Today() and RecordTypeId In: recTypeIdset and Request_Type__c In: requestTypeSet and Service__c In: serviceSet and (End_Date__c >=: System.Today() OR End_Date__c =: null) Limit 49999]){
            }
        }
    }
    
    /* 
     *Developer : Jatan Sharma
     *Description : This method is used to set the Flag for Extra pickup. 
     *In Case of extra pick up we need to set and send the flag to API.
     *Date : 5/18/2021
    */
    /* Move the code in Quote Line Trigger
    public static void updateExtraPickup(List<SBQQ__Quote__c > QuoteNewList, Map<Id,SBQQ__Quote__c> oldMap)
    {
        Set<Id> quoteIds = new Set<Id>();
        Set<Id> requiredByIds  = new Set<Id>();
        Id userId = UserInfo.getUserId();
        for(SBQQ__Quote__c quote : QuoteNewList){
            
            if(quote.Assigned_To__c != oldMap.get(quote.id).Assigned_To__c && quote.Assigned_To__c == userId){
                quoteIds.add(quote.Id);
            }
        }
        
        for(SBQQ__QuoteLine__c extraPickup : [Select Id,SBQQ__RequiredBy__c  from SBQQ__QuoteLine__c where SBQQ__ProductName__c =:EXTRA_PICKUP_PRODUCT and SBQQ__Quote__c = :quoteIds]){
            requiredByIds.add(extraPickup.SBQQ__RequiredBy__c);
        }
        
        if(!requiredByIds.isEmpty()){
            List<SBQQ__QuoteLine__c> updateQuoteLine = new List<SBQQ__QuoteLine__c>();
            for(SBQQ__QuoteLine__c quoteLine : [Select Id,IsExtrapickup__c from SBQQ__QuoteLine__c 
                                                where SBQQ__ProductName__c =:PICKUP_PRODUCT 
                                                and SBQQ__RequiredBy__c=:requiredByIds 
                                                and SBQQ__Quote__c = :quoteIds
                                                and Occurrence_Type__c =:SCHEDULED_TYPE ]){
                quoteLine.IsExtraPickup__c = true;
                updateQuoteLine.add(quoteLine); 
            }
            If(!updateQuoteLine.isEmpty()) {
                update updateQuoteLine;
            }  
        }
        
    }
    */
    
    // SDT-23339 : To update GR Service Flag of Quote with respect to Assigned To User.
    public static void updateGenesysRequired(List<SBQQ__Quote__c > QuoteNewList, Map<Id,SBQQ__Quote__c> oldMap, Map<Id,SBQQ__Quote__c> newMap){
        
       // List<SBQQ__Quote__c> lstGenesysQuote= [Select id,Genesys_Enabled__c,GR_Service_Flag__c,Assigned_To__r.GR_Service_Flag__c from SBQQ__Quote__c where id in: QuoteNewList and Genesys_Enabled__c = true ];
       //List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
       //List<Id> quoteListId = new List<Id>();
        
         
        
        for(SBQQ__Quote__c quote:QuoteNewList){
             Boolean isStartDateWithinthirtyDays = checkQuoteStartDateWithinthirtyDays(quote.SBQQ__StartDate__c);
            
             if(quote.Genesys_Enabled__c && quote.Next_Action_Start_Date__c <  System.now() && (!quote.Genesys_Record_Created__c || flag) && quote.Genesys_Record_Created__c == oldMap.get(quote.id).Genesys_Record_Created__c && !isStartDateWithinthirtyDays)
            {
                quote.Is_Genesys_Required__c = true;               
               // quoteListId.add(quote.Id);
                //quoteList.add(quote);
            	}
            
           }   
        }        
  
    //Added for Genesys Integration
    public static void isEligibleForGenesys(List<SBQQ__Quote__c > QuoteNewList, Map<Id,SBQQ__Quote__c> oldMap, Map<Id,SBQQ__Quote__c> newMap)
    {
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        List<Id> quoteListId = new List<Id>();
        for(SBQQ__Quote__c quote : newMap.values()){
            
             Boolean isStartDateWithinthirtyDays = checkQuoteStartDateWithinthirtyDays(quote.SBQQ__StartDate__c);
             System.debug('@@isStartDateWithinthirtyDays'+isStartDateWithinthirtyDays);
             
            if(quote.Genesys_Enabled__c && quote.Next_Action_Start_Date__c <  System.now() && (!quote.Genesys_Record_Created__c || flag) && quote.Genesys_Record_Created__c == oldMap.get(quote.id).Genesys_Record_Created__c && isStartDateWithinthirtyDays)
            {
                quoteListId.add(quote.Id);
                quoteList.add(quote);
            }
        }
        if(!quoteList.isEmpty())
        {
            createGenesysForQuote(quoteList,quoteListId,Constant_Util.STATUS_NEW,null);
        }
    }
    //Added for Genesys Integration
    public static void createGenesysForQuote(List<SBQQ__Quote__c> quoteList,List<Id> quoteListId,String action,EmailMessage newMessage)
    {
        List<Genesys_Routing__c> genList = new List<Genesys_Routing__c>();
        Map<Id,String> durationMap = new Map<Id,String>();
        Map<String,String> mapOfoldStatus = new Map<String,String>();
        //Changes related to SDT-37849
        Boolean orgWideEmailFound = false;

        mapOfoldStatus.put(Constant_Util.QUOTE_DRAFT,Constant_Util.QUOTE_DRAFT);
        mapOfoldStatus.put(Constant_Util.QUOTE_PRODUCT_CONFIGURED,Constant_Util.QUOTE_DRAFT);
        mapOfoldStatus.put(Constant_Util.QUOTE_COST_CONFIGURED,Constant_Util.QUOTE_PRODUCT_CONFIGURED);
        mapOfoldStatus.put(Constant_Util.QUOTE_PRICE_CONFIGURED,Constant_Util.QUOTE_COST_CONFIGURED);
        mapOfoldStatus.put(Constant_Util.QUOTE_DECLINED,Constant_Util.QUOTE_PRICE_CONFIGURED);
      
        Id genesysRoutingRec = Schema.getGlobalDescribe().get(Constant_Util.Genesys_Routing).getDescribe().getRecordTypeInfosByDeveloperName().get(Constant_Util.OBJECT_TASK).getRecordTypeId();
        Id emailToCaseRec = Schema.getGlobalDescribe().get(Constant_Util.Genesys_Routing).getDescribe().getRecordTypeInfosByDeveloperName().get(Constant_Util.EMAILTOCASERECORD).getRecordTypeId();
        
        
        List<SBQQ__Quote__c> quoteLst= [Select id,LastModifiedBy.UserName,Assigned_To__r.GR_Service_Flag__c,LastModifiedBy.Genesys_Enabled__c,Priority__c,LastModifiedById,SBQQ__Account__r.Parent.Customer_Code__c,SBQQ__Account__r.Location_Code__c,SBQQ__Account__r.tz__Timezone__c,SBQQ__Opportunity2__r.Case__r.CaseNumber,SBQQ__Opportunity2__r.Case__r.Reference_Number__c,GR_Service_Flag__c,SBQQ__Opportunity2__r.Case__r.Case_Type__c,SBQQ__Opportunity2__r.Case__r.Case_Reason__c,SBQQ__Opportunity2__r.Case__r.createdby.userRole.name,SBQQ__Account__r.Parent.Primary_Segment__c,SBQQ__Opportunity2__r.Case__r.Asset.Project_Code__c,SBQQ__Status__c,Next_Action_Due_Date__c,Project__c,Project_Services_Request__c,createdby.userRole.name  from SBQQ__Quote__c where id in :quoteList];
        
        //Changes related to SDT-37849
        If(newMessage !=null)
        {
            orgWideEmailFound =findOrgWideEmailAddress(newMessage); 
        }

        
        
        for(SBQQ__QuoteLine__c qLine : [SELECT Id, toLabel(Duration__c),SBQQ__Quote__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c IN:quoteListId AND SBQQ__RequiredBy__c = Null])
        {
            if(!durationMap.containsKey(qLine.SBQQ__Quote__c))
            {
                durationMap.put(qLine.SBQQ__Quote__c, qLine.Duration__c);
            } 
        }
        Map<String,TaskDesc__mdt> taskDescMap = TaskDesc__mdt.getAll();
        Map<String,TaskDesc__mdt> quoteTaskDescMap = new Map<String,TaskDesc__mdt>();
        Generic_Values__mdt genValue = Generic_Values__mdt.getInstance(Constant_Util.GENESYS_USER);       
        for(TaskDesc__mdt taskDesc : taskDescMap.values() )
        {
            quoteTaskDescMap.put(taskDesc.Quote_Status__c,taskDesc);
        }
        try{
            for(SBQQ__Quote__c quote : quoteLst)
            {
                Genesys_Routing__c gen = new Genesys_Routing__c();
               	String userName = quote.LastModifiedBy.UserName.substringBefore(Constant_Util.AT_SYMBOL);
               	gen.LastAgentId__c = quote.LastModifiedBy.Genesys_Enabled__c ? userName : null;
                //Changes related to SDT-37849
                gen.MediaType__c = (newMessage != null && !orgWideEmailFound)? Constant_Util.SFDCEMAILTASK : Constant_Util.SFDCCPQQUOTE;
                //gen.MediaType__c = Constant_Util.SFDCCPQQUOTE;
                gen.RecordTypeId = newMessage != null? emailToCaseRec : genesysRoutingRec;                
                gen.Action__c = action;
				gen.Action_Reason__c = action == Constant_Util.CANCEL ? Constant_Util.TRANSFERRED : null;
                gen.SFDCObjRecordID__c = newMessage != null? newMessage.Id: quote.Id;
                gen.SFDCObjType__c = newMessage != null? Constant_Util.EMAILMESSAGE : Constant_Util.QUOTE;
                gen.SFDCAcctID__c = quote.SBQQ__Account__r.Parent.Customer_Code__c;
                gen.SFDCAcctSegment__c = quote.SBQQ__Account__r.Parent.Primary_Segment__c;
                gen.SFDCAcctLocation__c = quote.SBQQ__Account__r.Location_Code__c;
                gen.SFDCAcctLocationTimeZone__c = quote.SBQQ__Account__r.tz__Timezone__c;
                gen.SFDCCaseNumber__c = quote.SBQQ__Opportunity2__r.Case__r.CaseNumber;
                gen.SFDCCaseRefNo__c = quote.SBQQ__Opportunity2__r.Case__r.Reference_Number__c;
                gen.SFDCCaseType__c = quote.SBQQ__Opportunity2__r.Case__r.Case_Type__c;
                gen.SFDCCaseSubCaseType__c = durationMap.get(quote.Id);
                gen.SFDCCaseReason__c = quote.SBQQ__Opportunity2__r.Case__r.Case_Reason__c;    
                //gen.SFDCServiceFlag__c = quote.GR_Service_Flag__c;
                gen.SFDCServiceFlag__c = quote.Assigned_To__r.GR_Service_Flag__c !=null ? quote.Assigned_To__r.GR_Service_Flag__c:Constant_Util.CS;

                if(flag && action == Constant_Util.CANCEL){
                    gen.SFDCTaskDescCode__c = quoteTaskDescMap.get(mapOfoldStatus.get(quote.SBQQ__Status__c)).TaskDescCode__c;
                    gen.SFDCTaskDescCode__c = quoteTaskDescMap.get(mapOfoldStatus.get(quote.SBQQ__Status__c)).TaskDescCode__c;
                    gen.SFDCTaskDescription__c = quoteTaskDescMap.get(mapOfoldStatus.get(quote.SBQQ__Status__c)).MasterLabel;
                }
                else{
                    //modified as part of SDT-41190
                    if(quote.Sbqq__Status__c == Constant_Util.QUOTE_APPROVED) {
                        gen.SFDCTaskDescCode__c = Constant_Util.APPROVED;              
                        gen.SFDCTaskDescription__c = Constant_Util.APPROVED;
                    }
                    else {
                    gen.SFDCTaskDescCode__c = quoteTaskDescMap.get(quote.SBQQ__Status__c).TaskDescCode__c;              
                    gen.SFDCTaskDescCode__c = quoteTaskDescMap.get(quote.SBQQ__Status__c).TaskDescCode__c;
                    gen.SFDCTaskDescription__c = quoteTaskDescMap.get(quote.SBQQ__Status__c).MasterLabel;
                    }
                    //41190 ends
                }
                
                gen.SFDCTaskDueDateTime__c = quote.Next_Action_Due_Date__c;
                gen.SFDCRouteStartTime__c = String.valueof(System.today()) + Constant_Util.START_TIME_TEXT;
                gen.SFDCRouteEndTime__c = String.valueof(System.today()) + Constant_Util.END_TIME_TEXT;
                gen.SFDCRoutePriority__c = quote.Priority__c;
                gen.Integrate_with_Genesys_Routing__c = true;
                gen.OwnerId = genValue.Id__c;
                if(newMessage != null)
                {
                    gen.LastAgentId__c = newMessage.Message_ID__c;//added by av4 for SDT-41263
                    gen.EmailFrom__c = newMessage.FromAddress;
                    //Changes related to SDT-37849
                    gen.EmailTo__c = newMessage.ToAddress.substringBefore('; ');
                    gen.EmailSubject__c = newMessage.Subject;
                    gen.SFDCIsEmailNew__c = 'False';
                }
                genList.add(gen);
            }
            List<Database.SaveResult> insertOutcome = Database.insert(genList);
            List<Id> insertedGenesysIdList = new List<Id>();
            for(Integer i=0;i<insertOutcome.size();i++)
            {
                if(insertOutcome.get(i).isSuccess())
                {
                    insertedGenesysIdList.add(insertOutcome.get(i).getId());
                }
            }
            //Comment for enqueueJob , part of 25008. This will cover with Flow of Genesys.
            /*
            if(!insertedGenesysIdList.isEmpty() && newMessage == null)
            {
                updateQuoteFlag(insertedGenesysIdList,action);
            }
            */
          }
        catch(Exception e)
        {
            //Handle Exception
        }
    }
    
    public static void changeInStatus(List<SBQQ__Quote__c > QuoteList,Map<Id,SBQQ__Quote__c> oldMap,Map<Id,SBQQ__Quote__c> newMap){
        for(SBQQ__Quote__c quoteRec:quoteList){
            
            if(quoteRec.SBQQ__Status__c != oldMap.get(quoteRec.id).SBQQ__Status__c){
                quoteRec.Genesys_Record_Created__c = false;               
            }
        }
    }
    
    //Added for Genesys Integration
    public static void changeInOwnerOfQuote(List<SBQQ__Quote__c> quoteList,Map<Id,SBQQ__Quote__c> oldMap){
        
        List<Id> quoteListId = new List<Id>();
        
        for(SBQQ__Quote__c quoteRec:quoteList){
            
            quoteListId.add(quoteRec.Id);
            if(quoteRec.Assigned_To__c != oldMap.get(quoteRec.id).Assigned_To__c  && quoteRec.Genesys_Record_Created__c && !quoteRec.Genesys_Enabled__c && oldMapStatic.get(quoteRec.id).SBQQ__Status__c == quoteRec.SBQQ__Status__c)
            {
                createGenesysForQuote(quoteList,quoteListId,Constant_Util.CANCEL,null);
            } 
            else if(quoteRec.Genesys_Record_Created__c && (quoteRec.Action_Type__c != oldMapStatic.get(quoteRec.id).Action_Type__c && (quoteRec.Action_Type__c == 'Status Change' || quoteRec.Action_Type__c == 'Escalation' || quoteRec.Action_Type__c == 'Pending Information')) && !quoteRec.Genesys_Enabled__c)
            {
                flag = true;
                createGenesysForQuote(quoteList,quoteListId,Constant_Util.CANCEL,null);
            }
            else if(quoteRec.Genesys_Record_Created__c && !quoteRec.Genesys_Enabled__c && oldMapStatic.get(quoteRec.id).SBQQ__Status__c != quoteRec.SBQQ__Status__c)
            {
                flag = true;
                createGenesysForQuote(quoteList,quoteListId,Constant_Util.CANCEL,null);
            }
        }
        
    }

    //Added for Genesys Integration
     public static void updateQuoteFlag(List<Id> insertedGenesysIdList,String action)
     {
         //List<Id> upQuoteList = new List<Id>();
        
         
         if(!insertedGenesysIdList.isEmpty() && RunAsyncGenesysCreation){
            Id jobId= System.enqueueJob(new AsyncUpdateQuoteFlag(insertedGenesysIdList,action)); 
         }         
         else{
            AsyncUpdateQuoteFlag syncQuoteFlag = new AsyncUpdateQuoteFlag(insertedGenesysIdList,action);
            syncQuoteFlag.execute(null); 
         }
         
     }
    
    //Start -- Jira ID -> SDT-20030
    // Removed Approved status check for Story: SDT-23394
    // Code has been updated for story SDT-25052 by jatan , We have covered submit for approved and approved status 
    // We have updated Last_Submitted_Modified_User__c with UserInfo.getUserId() as per our assumption like whoever is updating the quote will be a logged in user.
    // Before we are updating it with LastModifiedByid and that was inccorect as last modifier was not returning the updated modified user id.
    public static void updateLastModifiedSubmittedUser(List<SBQQ__Quote__c> quoteList,Map<Id,SBQQ__Quote__c> oldMap)
    {
        // changes done for SDT-26174
        //List<User> stpUser =  [select id from user where name ='STP Systemuser'];
        //SDT 48524
        if(String.isEmpty(stpUserId)){//SDT 48530
				stpUserId = [select id from user where name =:stpUserName][0].id;
			}
        for(SBQQ__Quote__c quote : quoteList){
            if(quote.SBQQ__Status__c == Constant_Util.QUOTE_PRICE_CONFIGURED && quote.SBQQ__Status__c != oldMap.get(quote.id).SBQQ__Status__c){
                quote.Last_Submitted_Modified_User__c = UserInfo.getUserId(); 
            }
            //Condition added for story SDT-26174
            else if (quote.STP__c && quote.SBQQ__Status__c == Constant_Util.QUOTE_APPROVED  && quote.SBQQ__Status__c != oldMap.get(quote.id).SBQQ__Status__c){
                    quote.Assigned_To__c = stpUserId;//stpUser[0].id;//SDT 48524
                    quote.Last_Submitted_Modified_User__c = stpUserId;//stpUser[0].id;//SDT 48524
            }
                //Condition added for story SDT-25052
            else if (quote.SBQQ__Status__c == Constant_Util.QUOTE_APPROVED && oldMap.get(quote.id).SBQQ__Status__c != Constant_Util.QUOTE_PRICE_CONFIGURED && quote.SBQQ__Status__c != oldMap.get(quote.id).SBQQ__Status__c){
                // changes done for SDT-26174
                if(quote.STP__c){
                    quote.Assigned_To__c = stpUserId;//stpUser[0].id;//SDT 48524
                    quote.Last_Submitted_Modified_User__c = stpUserId;//stpUser[0].id;//SDT 48524
                }
                //
                else
                {
                quote.Last_Submitted_Modified_User__c = UserInfo.getUserId();
                } 
            }
        }
    }
    //End --//
    /* 
    *Developer : Ruchika
    *Description : This method is used to call pricing request on status change. 
    *Date : 7/29/2021
    */  
    public static void getQuotePriceData(List<SBQQ__Quote__c > QuoteNewList,Map<Id,SBQQ__Quote__c> oldMap)
    { 
	    SBQQ.TriggerControl.disable();
	    
        for(SBQQ__Quote__c quote : QuoteNewList){
            if(quote.SBQQ__Status__c == Constant_Util.QUOTE_PRODUCT_CONFIGURED && quote.SBQQ__Status__c != oldMap.get(quote.id).SBQQ__Status__c && oldMap.get(quote.id).SBQQ__Status__c == Constant_Util.QUOTE_DRAFT){
                
		// SDT-48527
               if(RecurrsiveTriggerHandler.mapQuotePricingCallTracker==null 
                ||  !RecurrsiveTriggerHandler.mapQuotePricingCallTracker.containsKey(quote.Id))
                {
                CreatePricingRequest.createPricingRequest(quote.Id);  
                 RecurrsiveTriggerHandler.mapQuotePricingCallTracker.put(quote.Id,'called');  
                }	
            }    
        }
	     SBQQ.TriggerControl.enable(); 
    }
	/*
    *Developer  : Rishi
    *Description : SDT-20076 This method is used to send Declined Quote Notification
    *Test Coverage: QuoteDeclineTest class.
    *Date : 9/13/2021
    */
    public static void sendDeclineQuoteNotification(List<SBQQ__Quote__c > QuoteList,Map<Id,SBQQ__Quote__c> oldMap,Map<Id,SBQQ__Quote__c> newMap){
        
        EmailTemplate template = [SELECT Id FROM emailTemplate WHERE DeveloperName = 'Declined_Quote_Email_Template'];
        List<OrgWideEmailAddress> oweaList = [SELECT Id,Address,DisplayName FROM OrgWideEmailAddress WHERE DisplayName =: Constant_Util.EMAIL_TO_QUOTE OR DisplayName =: Constant_Util.PS_EMAIL_TO_QUOTE ORDER BY DisplayName ASC];
        Map<Id,SBQQ__Quote__c> getQuoteMap= getQuoteMap(QuoteList);
        for(SBQQ__Quote__c quoteObj:QuoteList){
            if(quoteObj.SBQQ__Status__c == Constant_Util.QUOTE_DECLINED && quoteObj.SBQQ__Status__c != oldMap.get(quoteObj.id).SBQQ__Status__c){
                if( ( (getQuoteMap.get(quoteObj.Id).CreatedBy.userRole!=null && getQuoteMap.get(quoteObj.Id).CreatedBy.userRole.name.startsWithIgnoreCase('Project Service')) || getQuoteMap.get(quoteObj.Id).SBQQ__Account__r.Parent.Primary_Segment__c == 'Construction and Demolition' || quoteObj.Project__c != null || quoteObj.Project_Services_Request__c) && quoteObj.SBQQ__PrimaryContact__c!=null && getQuoteMap.get(quoteObj.Id).SBQQ__PrimaryContact__r.Email !=null){
                    QuoteDecline.createEmailMessage(quoteObj.Id, template.Id, quoteObj.SBQQ__PrimaryContact__c, oweaList[1].Id);
                } else if(quoteObj.SBQQ__PrimaryContact__c!=null && getQuoteMap.get(quoteObj.Id).SBQQ__PrimaryContact__r.Email !=null){
                    QuoteDecline.createEmailMessage(quoteObj.Id, template.Id, quoteObj.SBQQ__PrimaryContact__c, oweaList[0].Id);
                }
            }
        }
    } 
    //return the current quotes
    public static Map<Id,SBQQ__Quote__c> getQuoteMap(List<SBQQ__Quote__c> quoteList){
        Map<Id,SBQQ__Quote__c> quoteMap= new Map<Id,SBQQ__Quote__c>([SELECT Id,SBQQ__PrimaryContact__c,SBQQ__PrimaryContact__r.Email,LastModifiedBy.UserName,LastModifiedBy.Genesys_Enabled__c,Priority__c,LastModifiedById,SBQQ__Account__r.Parent.Customer_Code__c,SBQQ__Account__r.Location_Code__c,SBQQ__Account__r.tz__Timezone__c,SBQQ__Opportunity2__r.Case__r.CaseNumber,SBQQ__Opportunity2__r.Case__r.Reference_Number__c,SBQQ__Opportunity2__r.Case__r.Case_Type__c,SBQQ__Opportunity2__r.Case__r.Case_Reason__c,SBQQ__Opportunity2__r.Case__r.createdby.userRole.name,SBQQ__Account__r.Parent.Primary_Segment__c,SBQQ__Opportunity2__r.Case__r.Asset.Project_Code__c,SBQQ__Status__c,Next_Action_Due_Date__c,Project__c, Project_Services_Request__c, CreatedBy.userRole.name FROM SBQQ__Quote__c WHERE Id IN :quoteList]);
        return quoteMap;
    }
    
    //Sdt-23088 This method will check if quote's Start Date lies within 30 days of Current date or not.
    public static boolean checkQuoteStartDateWithinthirtyDays(Date startDate){
        //sdt-27107 added Null check for startDate
        if(startDate!=NULL){
        Integer days = startDate.daysBetween(System.today());
        if(days<0){
            days= days*(-1);
        }
        if(days<=Constant_Util.THIRTY){
            return true;
        }
        }
        return false;
              
    }

    /**************************************************
    * Created By:Jatan
    * CreatedDate:26/08/2022
    * Story: SDT-19970
    * Comment: This will decide API call. True = API call , False = No API call
    * **************************************************/
    public static void integrationRequired(List<SBQQ__Quote__c> quoteList,Map<Id,SBQQ__Quote__c> oldMap){

        for(SBQQ__Quote__c quote : quoteList){
           if ((quote.SBQQ__Status__c == Constant_Util.QUOTE_APPROVED || quote.SBQQ__Status__c == Constant_Util.QUOTE_PRODUCT_CONFIGURED)  && quote.SBQQ__Status__c != oldMap.get(quote.id).SBQQ__Status__c ){
		//SDT-30514 and SDT-30515-Added Fourth parameter for Vendor_Commit_Date__c
                //TCS-pkulkarn-2-Sep-2024-SDT-41371-Tech Debt-Added 4th parameter to below call
                string integrationRequired = PricingJSONRequest.integrationToAPI(quote.Name , true , false, false);
                if(integrationRequired == 'False'){
                    quote.Integration_Status__c = 'Acorn integration not required';
                    quote.Acorn_integration_required__c = false;
                    system.debug('quote.Integration_Status__c ' +quote.Integration_Status__c );
                }
                else{
                    quote.Integration_Status__c = 'In Progress';
                    quote.Acorn_integration_required__c = True;
                }

            }
        }
    }
	
	  /**************************************************
    * Created By: TCS
    * CreatedDate: 21/04/2023
    * Story: SDT-28383
    * Comment: This will set Expiration Date based on quote status
    * **************************************************/
    public static void updateExpirationDate(List<SBQQ__Quote__c> quoteList,Map<Id,SBQQ__Quote__c> oldMap){
        for(SBQQ__Quote__c quote : quoteList){
		
		     if(trigger.isBefore && trigger.isInsert ){
              quote.Assing_To_Me_Action__c = true ;  
                //SDT-26938 Bug Fix SDT-32711
            }
		
            if(oldMap == null || (oldMap != null && quote.SBQQ__Status__c != oldMap.get(quote.id).SBQQ__Status__c)) {
                if (quote.SBQQ__Status__c == Constant_Util.QUOTE_DRAFT){
                    DateTime dT = quote.createddate != null ? quote.createddate : System.now();
                     quote.SBQQ__ExpirationDate__c = date.newinstance(dT.year(), dT.month(), dT.day()) + 30;
                } else if (quote.SBQQ__Status__c == Constant_Util.QUOTE_PRODUCT_CONFIGURED){
                     quote.SBQQ__ExpirationDate__c = quote.SBQQ__StartDate__c + 30;
                } else if (quote.SBQQ__Status__c == Constant_Util.QUOTE_COST_CONFIGURED){
                     quote.SBQQ__ExpirationDate__c = date.today() + 30;
                }
            }
        }
    }
     /**************************************************
    * Created By: TCS
    * Developer: Jatan sharma 
    * CreatedDate: 19/06/2023
    * Story: SDT-28383
    * Comment: Integration between Price only API and STP process. This method will call when status changed to cost configured.
               Call the price only API on sucess of it STP process will be called. 
    * **************************************************/
    public static void stpPricingOnlyIntegration(List<SBQQ__Quote__c> quoteList , Map<Id,SBQQ__Quote__c> oldMap){
        Boolean runProcess =  false;
        string RecordType ;
        set <ID> quoteids = new set <ID>();
        
        ID quoteId;
        system.debug(System.Label.STP_Process_on_off_switch);
        //if(System.Label.STP_Process_on_off_switch == 'On')
        //{
        for(SBQQ__Quote__c quote : quoteList ){
        //Run when status changes from price configured to cost configured.
            if(quote.SBQQ__Status__c == constant_util.QUOTE_COST_CONFIGURED && quote.SBQQ__Status__c !=oldMap.get(quote.id).SBQQ__Status__c ){
                runProcess = true;
                quoteId = quote.id;
                quoteids.add(quoteId);
                
            }
            
        }
        if(runProcess)
        {
            List<SBQQ__QuoteLine__c> parentQuoteLine  = [select id, SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__r.RecordType.Name from SBQQ__QuoteLine__c where SBQQ__Quote__r.id =:quoteId and SBQQ__RequiredBy__c = null];
            RecordType = parentQuoteLine[0].SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__r.RecordType.Name;
            if(RecordType == constant_util.New_Service_Case )
            {
                PlatformEventProcessor.RaiseSTPProcessEventPE(quoteids, true);
                //PriceOnlyRequestSTPProcess.callPriceOnlySTPFunctionality(quoteId);
            }
           
            
        }
    //}
    }

    /**************************************************
    * Created By: TCS
    * CreatedDate: 13-Sept-23
    * Story: SDT-31118
    * Comment: This method filters the quotes that are moving from Product Configured to Cost Configured status 
    * and have its case record type as Modify Existing Service Case. Then calls the VCRCodeController.setVCRCodeForBundle() method while passing the 
    * set of filtered quote Ids as the argument
    * **************************************************/
    //SDT 39669 sd
    private static final list<string> QUOTETYPE_EXCEPTION_AMENDMENT_CORRECTION = New List<String>{'Exception','Amendment','Correction'};
    public static void filterQuoteAndUpdateQuoteLinesWithVCR(Map<Id,SBQQ__Quote__c> oldMap, Map<Id, SBQQ__Quote__c> newMap)
    {
		Set<Id> filteredQuoteIdsSet = new Set<Id>();
        
        for(Id currentQuoteId : newMap.keySet()) 
        {
            //TCS-pkulkarn-SDT-38847-15-Apr-2024-Modified the if condition to trigger VCR Code calculation when status changes to Approved. Removed hard code on Case Record Type
            if(newMap.get(currentQuoteId).SBQQ__Status__c == Constant_Util.QUOTE_APPROVED && oldMap.get(currentQuoteId).SBQQ__Status__c != Constant_Util.QUOTE_APPROVED
               && (QUOTETYPE_EXCEPTION_AMENDMENT_CORRECTION.contains(newMap.get(currentQuoteId).SBQQ__Type__c))) 
            /*if(newMap.get(currentQuoteId).SBQQ__Status__c == Constant_Util.QUOTE_APPROVED && oldMap.get(currentQuoteId).SBQQ__Status__c != Constant_Util.QUOTE_APPROVED
               && newMap.get(currentQuoteId).Case_record_Type__c == Constant_Util.MODIFY_EXISTING_SERVICE_CASE) */
            {
                filteredQuoteIdsSet.add(currentQuoteId);
            }
        }
		
		//call method to update vcr
        if(filteredQuoteIdsSet.size() > 0) {
			VCRCodeController.setVCRCodeForBundle(filteredQuoteIdsSet);
		}
    }

    //TCS-pkulkarn-SDT-32740-25-09-2024-Added
    public static void updateTypeOfChangeFieldOnQuoteLines(Map<Id,SBQQ__Quote__c> oldMap, Map<Id, SBQQ__Quote__c> newMap)
    {
        Set<Id> quoteStatusUpdated = new Set<Id>();
        
        for(Id quoteId : oldMap.keySet())
        {
            SBQQ__Quote__c oldQuoteRecord = oldMap.get(quoteId);
            SBQQ__Quote__c newQuoteRecord = newMap.get(quoteId);
            if((newQuoteRecord.SBQQ__Status__c == Constant_Util.QUOTE_APPROVED || newQuoteRecord.SBQQ__Status__c == Constant_Util.QUOTE_PRODUCT_CONFIGURED) && 
               oldQuoteRecord.SBQQ__Status__c != newQuoteRecord.SBQQ__Status__c)
            {
                quoteStatusUpdated.add(quoteId);
            }
        }
        compareAndUpdateTypeOfChangeFieldOnQuoteLine(quoteStatusUpdated);
    }
    //TCS-pkulkarn-SDT-32740-25-09-2024-End

    //TCS-pkulkarn-SDT-32740-25-09-2024-Added
    public static void compareAndUpdateTypeOfChangeFieldOnQuoteLine(Set<Id> quotesUpdated)
    {
        String sScheduled = 'SCH';
        String sScheduledOnCall = 'SOC';
        
        List<Schema.PicklistEntry> occurrenceTypeEntries = Schema.SObjectType.SBQQ__QuoteLine__c.fields.Occurrence_Type__c.getPicklistValues();
        List<Schema.PicklistEntry> sCodeEntries = Schema.SObjectType.SBQQ__QuoteLine__c.fields.sCode__c.getPicklistValues();
        List<Schema.PicklistEntry> ownershipEntries = Schema.SObjectType.SBQQ__QuoteLine__c.fields.Ownership__c.getPicklistValues();
        
        Set<String> strTypeOfChange = new Set<String>();
        List<SBQQ__QuoteLine__c> quoteLinesTobeUpdated = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> quoteLines = QuoteLineSelector.getQuoteLinesToUpdateTypeOfChangeField(quotesUpdated);
        
        //Compare Quote line field with Asset field and update the Type Of Change field on Quote Line
        for(SBQQ__QuoteLine__c quoteLine : quoteLines)
        {
			strTypeOfChange = new Set<String>();
            
            if(quoteLine.LocationPositionName__c != quoteLine.AssetId__r.Container_Position__c)
            {
                strTypeOfChange.add('Position Change');
            }
            if(quoteLine.ClientGLAccount__c != quoteLine.AssetId__r.GL_Code__c ||
              quoteLine.ClientCostCenter__c != quoteLine.AssetId__r.Cost_Center__c ||
              quoteLine.CompanyCategoryCode__c != quoteLine.AssetId__r.Category__c)
            {
                strTypeOfChange.add('Billing Administration Change');
            }
            if(quoteLine.SBQQ__StartDate__c != quoteLine.AssetId__r.Start_Date__c)
            {
                strTypeOfChange.add('Start Date Change');
            }
            if(quoteLine.SBQQ__EndDate__c != quoteLine.AssetId__r.End_Date__c)
            {
                strTypeOfChange.add('End Date Change');
            }
            String assetSCode = UTIL_Picklist.getPicklistEntryByLabel(sCodeEntries, quoteLine.AssetId__r.Sensitivity_Code__c);
            if(quoteLine.sCode__c != assetSCode)
            {
                strTypeOfChange.add('Market Restriction Change');
            }
            if((quoteLine.Equipment_Style__c != null && quoteLine.Equipment_Style__c != '') || 
               (quoteLine.Service_Style__c != null && quoteLine.Service_Style__c != ''))
            {
                strTypeOfChange.add('Equipment Change');
            }
            String assetOwnership = UTIL_Picklist.getPicklistEntryByLabel(ownershipEntries, quoteLine.AssetId__r.Equipment_Owner__c);
            if(quoteLine.Ownership__c != assetOwnership)
            {
                strTypeOfChange.add('Ownership Change');
            }
            if(quoteLine.MASLibrary__c != quoteLine.AssetId__r.MAS_Library__c ||
               quoteLine.MASCompany__c != quoteLine.AssetId__r.MAS_Company_Code__c ||
               quoteLine.MASCustomerUniqueId__c != quoteLine.AssetId__r.MAS_Customer_Unique_Id__c ||
               quoteLine.MASServiceLine__c != quoteLine.AssetId__r.MAS_Line_Number__c ||
               String.valueOf(quoteLine.MASAccount__c) != quoteLine.AssetId__r.MAS_Account_Number__c)
            {
                strTypeOfChange.add('MAS Change');
            }
            if(Integer.valueOf(quoteLine.SBQQ__Quantity__c) > Integer.valueOf(quoteLine.AssetId__r.Quantity__c))
            {
                strTypeOfChange.add('Quantity Increase');
            }
            if(Integer.valueOf(quoteLine.SBQQ__Quantity__c) < Integer.valueOf(quoteLine.AssetId__r.Quantity__c))
            {
                strTypeOfChange.add('Quantity Decrease');
            }
            //TCS-pkulkarn-SDT-42068-Added to fix test class errors
            //TCS-pkulkarn-SDT-42390-6-Nov-2024-Added 'Unknown' check to fix the defect
            if(quoteLine.Equipment_Size__c != null && quoteLine.Equipment_Size__c != '' &&
               quoteLine.AssetId__r.Equipment_Size__c != null && quoteLine.AssetId__r.Equipment_Size__c != '' &&
               sUnknown.equalsIgnoreCase(quoteLine.Equipment_Size__c) == false
              )
            {
                if(Double.valueOf(quoteLine.Equipment_Size__c.substringAfter('-')) > Double.valueOf(quoteLine.AssetId__r.Equipment_Size__c.substringBefore(' ')))
                {
                    strTypeOfChange.add('Size Increase');
                }
                if(Double.valueOf(quoteLine.Equipment_Size__c.substringAfter('-')) < Double.valueOf(quoteLine.AssetId__r.Equipment_Size__c.substringBefore(' ')))
                {
                    strTypeOfChange.add('Size Decrease');
                }
            }
            
            String assetOccurrenceType = UTIL_Picklist.getPicklistEntryByLabel(occurrenceTypeEntries, quoteLine.AssetId__r.Occurrence_Type__c);
            if(quoteLine.Occurrence_Type__c != assetOccurrenceType)
            {
                strTypeOfChange.add('Change Schedule Type');
            }
            else
            {
                if((quoteLine.Occurrence_Type__c == sScheduledOnCall && assetOccurrenceType == sScheduledOnCall) ||
                   (quoteLine.Occurrence_Type__c == sScheduled && assetOccurrenceType == sScheduled))
                {
                    String sFrequencyChange = calculateFrequencyChange(quoteLine);
                    if(sFrequencyChange != '')
                    {
                        strTypeOfChange.add(sFrequencyChange);
                    }
                }
            }
            if(quoteLine.Vendor__c < quoteLine.AssetId__r.Supplier__c)
            {
                strTypeOfChange.add('Change Vendor');
            }
            
            if(quoteLine.SBQQ__ListPrice__c > quoteLine.AssetId__r.SBQQ__RegularPrice__c)
            {
                strTypeOfChange.add('Price Increase');
            }
            if(quoteLine.SBQQ__ListPrice__c < quoteLine.AssetId__r.SBQQ__RegularPrice__c)
            {
                strTypeOfChange.add('Price Decrease');
            }
            if(quoteLine.SBQQ__UnitCost__c > quoteLine.AssetId__r.SBQQ__OriginalUnitCost__c)
            {
                strTypeOfChange.add('Cost Increase');
            }
            if(quoteLine.SBQQ__UnitCost__c < quoteLine.AssetId__r.SBQQ__OriginalUnitCost__c)
            {
                strTypeOfChange.add('Cost Decrease');
            }

            if(strTypeOfChange.size() > 0)
            {
                String strTypeOfChangeValue = QuoteLineTriggerHelper.setToStr(strTypeOfChange, Constant_Util.SEMI_COLON);
                quoteLine.Type_of_Change__c = strTypeOfChangeValue;
            }
            quoteLinesTobeUpdated.add(quoteLine);
        }
        if(quoteLinesTobeUpdated.size() > 0)
        {
            UPDATE quoteLinesTobeUpdated;
        }
    }
    //TCS-pkulkarn-SDT-32740-25-09-2024-End
    
    //TCS-pkulkarn-SDT-32740-25-09-2024-Added
    public static String calculateFrequencyChange(SBQQ__QuoteLine__c quoteLine)
    {
        String sReturnValue = '';
        //Calculate Quote Line's frequency
        Decimal quoteLineFrequency = calculateQuoteLineFrequency(quoteLine);
        //Calculate Asset's frequency
        Decimal assetFrequency = calculateAssetFrequency(quoteLine);
        
        if(quoteLineFrequency > assetFrequency)
        {
            sReturnValue = 'Frequency Increase';
        }
		if(quoteLineFrequency < assetFrequency)
        {
            sReturnValue = 'Frequency Decrease';
        }
        return sReturnValue;
    }
	//TCS-pkulkarn-SDT-32740-25-09-2024-End

	//TCS-pkulkarn-SDT-32740-25-09-2024-Added
    public static Decimal calculateQuoteLineFrequency(SBQQ__QuoteLine__c quoteLine)
    {
        Decimal dQuoteLineFrequency = 0;
        //TCS-pkulkarn-SDT-42068-Added more conditions to fix test class errors
        if(quoteLine.Frequency_Interval__c != null && quoteLine.Frequency_Interval__c != '' && Integer.valueOf(quoteLine.Frequency_Interval__c) != 0)
        {
            //Calculate Quote Line's weekly frequency
            if(quoteLine.Schedule_Frequency__c == 'D')
            {
                dQuoteLineFrequency = 7 / Decimal.valueOf(quoteLine.Frequency_Interval__c);
            }
            else if(quoteLine.Schedule_Frequency__c == 'W')
            {
                List<String> serviceDaysList = quoteLine.Service_Days__c.split(';');
                dQuoteLineFrequency = serviceDaysList.size() / Decimal.valueOf(quoteLine.Frequency_Interval__c);
            }
            else if(quoteLine.Schedule_Frequency__c == 'M')
            {
                dQuoteLineFrequency = 1 / (4 * Decimal.valueOf(quoteLine.Frequency_Interval__c));
            }
            else if(quoteLine.Schedule_Frequency__c == 'W')
            {
                dQuoteLineFrequency = 1 / (52 * Decimal.valueOf(quoteLine.Frequency_Interval__c));
            }
        }
        return dQuoteLineFrequency;
    }
	//TCS-pkulkarn-SDT-32740-25-09-2024-End

	//TCS-pkulkarn-SDT-32740-25-09-2024-Added
    public static Decimal calculateAssetFrequency(SBQQ__QuoteLine__c quoteLine)
    {
        Decimal dAssetFrequency = 0;
        //TCS-pkulkarn-SDT-42068-Added more conditions to fix test class errors
        if(quoteLine.AssetId__r.Occurs__c != null && quoteLine.AssetId__r.Occurs__c != '' && Integer.valueOf(quoteLine.AssetId__r.Occurs__c) != 0)
        {
            //Calculate Asset's weekly frequency
            if(quoteLine.AssetId__r.Frequency__c == 'Daily')
            {
                dAssetFrequency = 7 / Decimal.valueOf(quoteLine.AssetId__r.Occurs__c);
            }
            else if(quoteLine.AssetId__r.Frequency__c == 'Weekly')
            {
                Integer count = 0;
                if(quoteLine.AssetId__r.Monday__c)
                {
                    count = count + 1;
                }
                if(quoteLine.AssetId__r.Tuesday__c)
                {
                    count = count + 1;
                }
                if(quoteLine.AssetId__r.Wednesday__c)
                {
                    count = count + 1;
                }
                if(quoteLine.AssetId__r.Thursday__c)
                {
                    count = count + 1;
                }
                if(quoteLine.AssetId__r.Friday__c)
                {
                    count = count + 1;
                }
                if(quoteLine.AssetId__r.Saturday__c)
                {
                    count = count + 1;
                }
                if(quoteLine.AssetId__r.Sunday__c)
                {
                    count = count + 1;
                }
                if(count > 0)
                {
                    dAssetFrequency = count / Decimal.valueOf(quoteLine.AssetId__r.Occurs__c);
                }
            }
            else if(quoteLine.AssetId__r.Frequency__c == 'Monthly')
            {
                dAssetFrequency = 1 / (4 * Decimal.valueOf(quoteLine.AssetId__r.Occurs__c));
            }
            else if(quoteLine.AssetId__r.Frequency__c == 'Yearly')
            {
                dAssetFrequency = 1 / (52 * Decimal.valueOf(quoteLine.AssetId__r.Occurs__c));
            }
        }
        return dAssetFrequency;
    }
    //TCS-pkulkarn-SDT-32740-25-09-2024-End     
    
         /* 
    *Developer : Harun
    *Description : This method is used to create task  on status change. 
    *Story : SDT-41625,41544,41473
    *Date : 10/21/2024
    */  
   public static void createTaskonHaulAwayQuote(List<SBQQ__Quote__c > QuoteNewList,Map<Id,SBQQ__Quote__c> oldMap){
        
        list<SBQQ__Quote__c> approvedQuotes= new list<SBQQ__Quote__c>();
        for(SBQQ__Quote__c q :QuoteNewList){
            
            if((q.SBQQ__Status__c == Constant_Util.QUOTE_APPROVED || q.SBQQ__Status__c == Constant_Util.QUOTE_DECLINED ) && 
               oldMap.get(q.Id).SBQQ__Status__c != q.SBQQ__Status__c  )
            {
                approvedQuotes.add(q);
            }
        }
        if(!approvedQuotes.isEmpty())
        {
        Set<Id> quoteIds = oldMap.keySet();
        Map<Id,SBQQ__Quote__c> quotesWithDetails = new  Map<Id,SBQQ__Quote__c>();
       // List<SBQQ__Quote__c> quoteRecords = SELECT Id,SBQQ__Opportunity2__r.Case__r.Haul_Away_Service_Booked__c,SBQQ__Opportunity2__r.Case__r.Haul_Away_information__c,SBQQ__Opportunity2__r.Case__r.Is_Haul_Away_Service__c,SBQQ__Opportunity2__r.Case__r.Haul_Away_Vendor__c FROM SBQQ__Quote__c
       //SDT 45079 added Business_Rule__c to SOQL
       if(quotesWithDetails.size() == 0){
        quotesWithDetails = new Map<Id,SBQQ__Quote__c>([SELECT Id,Business_Rule__c,SBQQ__Opportunity2__r.Case__c,SBQQ__Opportunity2__r.Case__r.Haul_Away_Service_Booked__c,SBQQ__Opportunity2__r.Case__r.Haul_Away_information__c,SBQQ__Opportunity2__r.Case__r.Is_Haul_Away_Service__c,SBQQ__Opportunity2__r.Case__r.Haul_Away_Vendor__c,Manual_Approval_Action__c,CreatedBy.UserRole.Name, SBQQ__Account__r.Parent.Primary_Segment__c, Quote_Thread_Id__c, Project__c, Project_Services_Request__c, SBQQ__Status__c,SBQQ__Type__c, Assigned_To__c,Quote_Only__c,LastModifiedById,OwnerId,Name,LastModifiedBy.UserName,SBQQ__Opportunity2__r.Case__r.SLA_Service_Date_Time__c,SBQQ__Opportunity2__r.Case__r.Case_Sub_Type__c,Assigned_To__r.GR_Service_Flag__c,LastModifiedBy.Genesys_Enabled__c,Priority__c,SBQQ__Account__r.Parent.Customer_Code__c,SBQQ__Account__r.Location_Code__c,SBQQ__Account__r.tz__Timezone__c,SBQQ__Opportunity2__r.Case__r.CaseNumber,SBQQ__Opportunity2__r.Case__r.Reference_Number__c,GR_Service_Flag__c,SBQQ__Opportunity2__r.Case__r.Case_Type__c,SBQQ__Opportunity2__r.Case__r.Case_Reason__c,SBQQ__Opportunity2__r.Case__r.Asset.Project_Code__c,Next_Action_Due_Date__c FROM SBQQ__Quote__c WHERE Id IN :quoteIds]);
       }     
      
        Map<Id,Boolean> haulAwayServiceMap = HaulAwayService.getIsHaulAwayServiceforQuote(quotesWithDetails.values());
        List<Task> tasksToCreate = new List<Task>();
        //Map<Id,Id> ApprovaVsQuoteId = new Map<Id,Id>();

        for(SBQQ__Quote__c quote : QuoteNewList){
            if(haulAwayServiceMap.containsKey(quote.Id))
            {
            //Boolean hasHaulAwayService = haulAwayServiceMap.get(quote.Id);
            SBQQ__Quote__c detailedQuote = quotesWithDetails.get(quote.Id);
                //SDT 45079 if br available for quote then dont create task from here
                //if(quote.Business_Rule__c!=null) 
                {
            //if(quote.SBQQ__Status__c != oldMap.get(quote.Id).SBQQ__Status__c && (quote.SBQQ__Status__c == Constant_Util.QUOTE_APPROVED || quote.SBQQ__Status__c == Constant_Util.QUOTE_DECLINED) && (haulAwayServiceMap.get(quote.Id)) && detailedQuote.SBQQ__Opportunity2__r.Case__r.Haul_Away_Service_Booked__c == 'No' && (ApprovaVsQuoteId.get(quote.Id) != null))  {
                    if(quote.Business_Rule__c == null && quote.SBQQ__Status__c != oldMap.get(quote.Id).SBQQ__Status__c && (quote.SBQQ__Status__c == Constant_Util.QUOTE_APPROVED || quote.SBQQ__Status__c == Constant_Util.QUOTE_DECLINED) && (haulAwayServiceMap.get(quote.Id)) && detailedQuote.SBQQ__Opportunity2__r.Case__r.Haul_Away_Service_Booked__c == 'No'
                       //&& !detailedQuote.Manual_Approval_Action__c
                      )  {
                        Boolean isGenesysEnabledUser;
                        String genServiceFlag;
                        Boolean isLastAgentAvailable;
                        List<User> CSResolutionTeamUserList = UserSelector.getCSResolutionTeamUser();
                        String userCSResolutionTeam;
                        Id userCSResolutionTeamId;
                        if(CSResolutionTeamUserList.size() == 1)
                        {
                            userCSResolutionTeamId = CSResolutionTeamUserList[0].Id;
                            userCSResolutionTeam = CSResolutionTeamUserList[0].UserName.substringBefore(Constant_Util.AT_SYMBOL);
                        }
                        HaulAwayService.genUserDetalsWrapper genUserDetalsWrapperRec = HaulAwayService.getIfGenesysEnabledUser(detailedQuote.Assigned_To__c);
                        isGenesysEnabledUser = genUserDetalsWrapperRec.isGenesysEnabledUser;
                        genServiceFlag  = genUserDetalsWrapperRec.genFlag;
			//SDT-46927
                        String userQuoteOwner;
                        if(detailedQuote.Quote_Only__c){
                           userQuoteOwner = userCSResolutionTeamId;
                        } else{
                           userQuoteOwner = detailedQuote.Assigned_To__c;//not genesys enabled user-----------Create a task for the quote owner under the case
                        }                     
			if(isGenesysEnabledUser){
                            String userLastAgent = detailedQuote.LastModifiedBy.UserName.substringBefore(Constant_Util.AT_SYMBOL);
                            Id userLastAgentId = detailedQuote.LastModifiedById;
                            isLastAgentAvailable = HaulAwayService.getIfLastAgentAvailable(userLastAgent);
                            if(isLastAgentAvailable  ){
                                
                                task genTask = HaulAwayService.createGenesysTask(detailedQuote,userQuoteOwner);//Create a task for the case owner under the case
                                HaulAwayService.createGenesysRecord(detailedQuote,userLastAgent,userLastAgentId,genServiceFlag,genTask);//Create a genesys record with the last agent logic.
                                
                            }else{
                                task genTask = HaulAwayService.createGenesysTask(detailedQuote,userCSResolutionTeam);//Create a task for the CS resolution team under the case
                                HaulAwayService.createGenesysRecord(detailedQuote,userCSResolutionTeam,userCSResolutionTeamId,genServiceFlag,genTask);//Create a genesys record for the CS resolution team
                            } 
                        }else{
                            HaulAwayService.createGenesysTask(detailedQuote,userQuoteOwner);//not case
                        }
                    }
            }
        }
        }
        
        if(!tasksToCreate.isEmpty()){
            //Changes related to SDT-48086
            try
            {
                insert  tasksToCreate ;
    
            }
            catch(Exception excp)
            {
                UTIL_LoggingService.logHandledExceptionWithClass(excp, UserInfo.getOrganizationId(),
                                                                UTIL_ErrorConstants.CONFIRM_CONFIGURATION_ACTION,
                                                                System.LoggingLevel.Error,
                                                                UTIL_ErrorConstants.QUOTETRIGGERHELPER_CLASSNAME,
                                                                UTIL_ErrorConstants.AMENDMENTQUOTEAPPROVALBYSINGLEBUNDLE_METHODNAME + '',
                                                                UTIL_ErrorConstants.QUOTETRIGGER_TRIGGERNAME);
            }
        }

        }}
     
         /* 
    *Developer : Harun
    *Description : This method is used to create child case and task associated with it on status change to approved on HaulAway Quote. 
    *Story : SDT-41538
    *Date : 01/06/2025
    */  
    public static void createChargeabilityChildCase(List<SBQQ__Quote__c> QuoteNewList,Map<Id,SBQQ__Quote__c> oldMap){
       
      List<Id> approvedQuotes = new List<Id>();
      Map<Id,Id> quoteToCaseMap = new Map<Id,Id>();
      
      for(SBQQ__Quote__c q :QuoteNewList){
      SBQQ__Quote__c oldQuotes =  oldMap.get(q.Id);
        if(q.SBQQ__Status__c == Constant_Util.QUOTE_APPROVED && oldQuotes.SBQQ__Status__c != Constant_Util.QUOTE_APPROVED ){
          approvedQuotes.add(q.Id);
        }
      
      }
      
      if(!approvedQuotes.isEmpty()){
       
       List<SBQQ__Quote__c> queriedQuotes = [SELECT Id,SBQQ__Opportunity2__r.Case__r.Id,SBQQ__Opportunity2__r.Case__r.Chargeable__c,SBQQ__Opportunity2__r.Case__r.Haul_Away_Service_Booked__c,SBQQ__Opportunity2__r.Case__r.Haul_Away_information__c,SBQQ__Opportunity2__r.Case__r.Is_Haul_Away_Service__c,SBQQ__Opportunity2__r.Case__r.Haul_Away_Vendor__c FROM SBQQ__Quote__c WHERE Id IN :approvedQuotes];
       Map<Id,Boolean> haulAwayServiceMap = HaulAwayService.getIsHaulAwayServiceforQuote(queriedQuotes);

       for(SBQQ__Quote__c q : queriedQuotes){
        if(haulAwayServiceMap.containsKey(q.Id)){
            Boolean hasHaulAwayService = haulAwayServiceMap.get(q.Id);

       if(q.SBQQ__Opportunity2__r.Case__r.Id != null &&(hasHaulAwayService) &&(q.SBQQ__Opportunity2__r.Case__r.Chargeable__c == 'No' || q.SBQQ__Opportunity2__r.Case__r.Chargeable__c == 'Unknown' )){
       
       quoteToCaseMap.put(q.Id,q.SBQQ__Opportunity2__r.Case__r.Id);
       }
       
       }
    }
      }
      
      List<Id> caseIds = quoteToCaseMap.values();
      if(!caseIds.isEmpty()){
      
      for(Id caseId : caseIds){
      
        caseService.createMultipleCasesInvoke(caseId.toString());
      }
      }

    }
    
    //TCS-pkulkarn-SDT-41186-18-Oct-2024-Added below method to check if Amendment Quote is Approved by a Sales Team user.
    //If approved by a Sales Team user, the Quote status is retained to Submit for Approval (to be approved finally by SSM Team)
    //It Sets a flag to indicate that the Quote is approved by Sales Team (Flag/Field: Is Amendment Quote Approved By Sales [Is_Amendment_Quote_Approved_By_Sales__c])
    //Caller: QuoteTriggerHandler.onBeforeUpdate
    public static void verifyAmendmentQuoteApprovalBySalesTeam(List<SBQQ__Quote__c> quoteList,Map<Id,SBQQ__Quote__c> oldMap)
    {
        String sSales = 'SALES';
        String sLoggedInUserCategory = '';
        
        for(SBQQ__Quote__c quote : quoteList)
        {
            if(quote.SBQQ__Status__c == Constant_Util.QUOTE_APPROVED && 
               oldMap.get(quote.Id).SBQQ__Status__c == Constant_Util.QUOTE_PRICE_CONFIGURED && 
               quote.SBQQ__Type__c == Constant_Util.QUOTE_TYPE_AMEND)
            {
                sLoggedInUserCategory = quote.Logged_In_User_Category__c;
                if(sLoggedInUserCategory.equalsIgnoreCase(sSales))
                {
                    quote.SBQQ__Status__c = Constant_Util.QUOTE_PRICE_CONFIGURED;
                    quote.Is_Amendment_Quote_Approved_By_Sales__c = true;
                    QuoteApprovalHandler.assignQuoteToSSMTeam(quote);
                }    
            }
        }
    }
     //Chandu Kari-SDT-45082-19-Feb-2025-Added below method to check if Amendment Quote is Approved by a SSM GEN,SALES GEM & SALESPREM,CSRES user.
    //If approved by a Sales Team user, the Quote status is retained to Submit for Approval (to be approved finally by SSM,SALES,SST Teams)
    //It Sets a Customer Approval as Approved by SSM,SALES,SST Team to be displayed on UI.
    //Caller: QuoteTriggerHandler.onAfterUpdate
    public static void amendmentQuoteApprovalBySingleBundle(List<SBQQ__Quote__c> quoteList)
    {
        Set<Id> approvedQuoteIds = new Set<Id>();
        Set<Id> declinedOrCancelledQuoteIds = new Set<Id>();
        
        for(SBQQ__Quote__c quote : quoteList)
        {
            if(quote.SBQQ__Type__c == Constant_Util.QUOTE_TYPE_AMEND && quote.Quote_Only__c == true && quote.SBQQ__Status__c == Constant_Util.QUOTE_APPROVED){
                approvedQuoteIds.add(quote.Id);
            }
            if(quote.SBQQ__Type__c == Constant_Util.QUOTE_TYPE_AMEND && quote.Quote_Only__c == true && (quote.SBQQ__Status__c == Constant_Util.QUOTE_DECLINED || quote.SBQQ__Status__c == Constant_Util.CANCELLED)){
                declinedOrCancelledQuoteIds.add(quote.Id);
            }
        }
        List<SBQQ__QuoteLine__c> quoteLinesToUpdate = new List<SBQQ__QuoteLine__c>();
        if(approvedQuoteIds.size() == 1){
            for(SBQQ__QuoteLine__c qLine :[SELECT Id, CustomerApproval__c,SBQQ__Quote__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c IN:approvedQuoteIds AND CustomerApproval__c =: Constant_Util.PENDING_APPROVAL]){
                    qLine.CustomerApproval__c = Constant_Util.APPROVED;
                    quoteLinesToUpdate.add(qLine);
            }
        }
        if(declinedOrCancelledQuoteIds.size() > 0){
            for(SBQQ__QuoteLine__c qLine :[SELECT Id, CustomerApproval__c,SBQQ__Quote__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c IN:declinedOrCancelledQuoteIds AND CustomerApproval__c =: Constant_Util.PENDING_APPROVAL]){
                qLine.CustomerApproval__c = Constant_Util.REJECTED;
                quoteLinesToUpdate.add(qLine);
            }
        }
        if(quoteLinesToUpdate.size() > 0){
            //Changes related to SDT-48086
            try
            {
              update quoteLinesToUpdate;
            }
            catch(Exception excp)
            {
                UTIL_LoggingService.logHandledExceptionWithClass(excp, UserInfo.getOrganizationId(),
                                                                UTIL_ErrorConstants.CONFIRM_CONFIGURATION_ACTION,
                                                                System.LoggingLevel.Error,
                                                                UTIL_ErrorConstants.QUOTETRIGGERHELPER_CLASSNAME,
                                                                UTIL_ErrorConstants.AMENDMENTQUOTEAPPROVALBYSINGLEBUNDLE_METHODNAME,
                                                                UTIL_ErrorConstants.QUOTETRIGGER_TRIGGERNAME);
            }
        }
    }
        /*
    *Developer  : TCS - Rishan
    *Description : SDT-37849 to find out org wide address from toaddress and ccaddress
    *Test Coverage: QuoteEmailHandlerTest class - checkForGenesysMediatypeIfORgAddressInTo,checkForGenesysMediatypeIfORgAddressInCC.
    */
    private static boolean findOrgWideEmailAddress(EmailMessage newMessage){ 
        Boolean foundOrgWideEmailForGenesys = false;
        List<String>emailsForNSQueueRouting = System.Label.Emails_For_NSQueue_Routing.split('; ');    
        //Check if any org wide address is present in toddress/ccaddress

        //Combine toAddresses and ccAddresses into a single list
        List<String> allAddresses = new List<String>();
        allAddresses.addAll(newMessage.ToAddress.split('; '));
        if(newMessage.CcAddress !=null)
        {
          allAddresses.addAll(newMessage.CcAddress.split('; ')); 
        }
		//Looping over List of OrgWideEmailAddresses that needs to be checked in toAddress and ccAddress
        for(OrgWideEmailAddress objEmail: OrgWideEmailSelector.getOrgWideAddressList(emailsForNSQueueRouting))
        {
            if(allAddresses.contains(objEmail.Address))
            {
                newMessage.ToAddress = objEmail.Address;
                foundOrgWideEmailForGenesys = true;
                // Exit the loop if one is found
                break; 
            }
        }
        //
        Return foundOrgWideEmailForGenesys;
    }

    //Seema-SDT 44716 SysHistoryTracking__c
    //this method will get call whenever quote is moving from Draft to Procure Servise status, to populate SysHistoryTracking__c field of QLine object.
    //SysHistoryTracking__c is Rich text field to store JSON.
    public static void populateSysdefaultFieldForQLs(Map<Id,SBQQ__Quote__c> oldMap, Map<Id, SBQQ__Quote__c> newMap)
    {
        Set<Id> quoteStatusUpdated = new Set<Id>();
        
        for(Id quoteId : oldMap.keySet())
        {
           SBQQ__Quote__c oldQuoteRecord = oldMap.get(quoteId);
            SBQQ__Quote__c newQuoteRecord = newMap.get(quoteId);
            if(newQuoteRecord.SBQQ__Status__c == Constant_Util.QUOTE_PRODUCT_CONFIGURED && 
               oldQuoteRecord.SBQQ__Status__c == Constant_Util.QUOTE_DRAFT && 
               (QUOTETYPE_EXCEPTION_AMENDMENT_CORRECTION.contains(newQuoteRecord.SBQQ__Type__c)))
            {
                quoteStatusUpdated.add(quoteId);
            }
        }
        List<SBQQ__QuoteLine__c> quoteLines = QuoteLineSelector.getQuoteLinesToUpdateSysField(quoteStatusUpdated);
        List<SBQQ__QuoteLine__c> quoteLinesToUpdate = new List<SBQQ__QuoteLine__c>();
        if(quoteLines.size() > 0){
            for(SBQQ__QuoteLine__c quoteLine : quoteLines)
            {
                SBQQ__QuoteLine__c quoteLineObj = new SBQQ__QuoteLine__c();
                quoteLineObj.id = quoteLine.Id;
                quoteLineObj.SysHistoryTracking__c = AlternateServiceController.frameSysFieldqLine(quoteLine);
                quoteLinesToUpdate.add(quoteLineObj);
                
            }
            RecurrsiveTriggerHandler.isSkipQuoteLineTrigger = true;
            UPDATE quoteLinesToUpdate;
            RecurrsiveTriggerHandler.isSkipQuoteLineTrigger = false;
        }
    }
    //40723
    public static void updateRelatedTaskAndGenesys(List<SBQQ__Quote__c > QuoteList, Map<Id,SBQQ__Quote__c> oldMap, Map<Id,SBQQ__Quote__c> newMap)
    {
        list<SBQQ__Quote__c> approvedQuotes= new list<SBQQ__Quote__c>();
        for(SBQQ__Quote__c q :QuoteList){            
            if((q.SBQQ__Status__c == Constant_Util.QUOTE_APPROVED || q.SBQQ__Status__c == Constant_Util.QUOTE_PRICE_CONFIGURED_LABEL ) )                
            {
                approvedQuotes.add(q);
            }
        }
        if(approvedQuotes.size()>0)
        {
            User NewStoresUser = [SELECT Id, Alias,username FROM User WHERE  Email LIKE 'newstoresteam@wm.com%'LIMIT 1];
            List<Task> TaskListToUpdate= new List<Task>();
            List<Genesys_Routing__c> GenesysListToUpdate = new List<Genesys_Routing__c>();
            // boolean vendorCommitDateSwitch = CodeSwitchUtility.getCodeSwitchOn('vendorCommitDateSwitchContainer__c');
            list<Id> quoteIds= new list<Id>();
        
                       
            for (SBQQ__Quote__c singleQuote:approvedQuotes)
            {            
                if(singleQuote.STP__c==true && oldMap.get(singleQuote.Id).STP__c!= singleQuote.STP__c )
                {
                    quoteIds.add(singleQuote.Id);
                }
            }
            List<task> taskList=[SELECT Id, status, whatID,ownerId from Task where Sys_Created_From__c=:TaskAndGenesysPETriggerHelper.CREATED_FROM_PETRIGGER AND WhatID IN : quoteIds];
            List<Genesys_Routing__c> genesysList= [SELECT Id,ownerId,SFDCObjRecordID__c from Genesys_Routing__c where Sys_Created_From__c=:TaskAndGenesysPETriggerHelper.CREATED_FROM_PETRIGGER AND  SFDCObjRecordID__c IN: quoteIds];
            
            if(taskList.size()>0){
                for (task tsk: taskList)
                {
                tsk.OwnerID=NewStoresUser.Id;
                TaskListToUpdate.add(tsk);
                    
                }}
            if(genesysList.size()>0){
                for (Genesys_Routing__c gr: genesysList)
                {
                    gr.OwnerID=NewStoresUser.Id;
                    HaulAwayService.genUserDetalsWrapper genUserDetalsWrapperRec = HaulAwayService.getIfGenesysEnabledUser(NewStoresUser.Id);
                    Boolean isGenesysEnabledUser = genUserDetalsWrapperRec.isGenesysEnabledUser;
                    String genServiceFlag  = genUserDetalsWrapperRec.genFlag;
                    gr.SFDCServiceFlag__c = isGenesysEnabledUser== true  ? genServiceFlag :'';
                    gr.LastAgentId__c=NewStoresUser.UserName.substringBefore(Constant_Util.AT_SYMBOL);
                    GenesysListToUpdate.add(gr);                    
                }
            }
            if(TaskListToUpdate.size()>0 && GenesysListToUpdate.size()>0){
                update TaskListToUpdate;
                update GenesysListToUpdate;                
            }
        }
    }
}
