/*************************************************************
@Name: QuoteApprovalHandler
@Author: Shilpa Bhatia
@CreateDate: 4/9/2021
@Description: 
@UsedBy: Quote Approval Email Service
**************************************************************/
global without sharing class QuoteApprovalHandler implements Messaging.InboundEmailHandler {
    
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
       
        //SDT 45079 Haul Away
    	Boolean isHaulAway;
        Boolean isGenesysEnabledUser;
        String genServiceFlag;
        Boolean isLastAgentAvailable;
        String QUOTEREFERENCENEW = '(?i)(ref:).*(:ref)';
        //SDT-24578 - will attach Email to Quote if Reference Id is present.   
        SBQQ__Quote__c NSQuote = new SBQQ__Quote__c();
        Pattern quoteThread = Pattern.compile(QUOTEREFERENCENEW);
       // Pattern quoteThread = Pattern.compile(Constant_Util.QUOTEREFERENCE);
        Matcher quoteMatch = quoteThread.matcher(email.htmlBody);
        //TCS-pkulkarn-SDT-41186-14-Oct-2024-Added below variable
        String quoteApprovalStatus = '';
        Integer approvalRequestedCount = 0;      
        String refId = '';
        if (quoteMatch.find()) {
            refId = quoteMatch.group(0);
        }
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        String fromAddress = email.fromAddress;
        List<String> toAddress = email.toAddresses;
        String isMultiMandatoryApprovers;
      
        string subject = Constant_Util.EMPTY_STRING;
        subject = email.subject;
        List<String> sublst =  subject.split(Constant_Util.COLON);
        String quoteId = sublst != null && sublst.size() > 1 ? Id.valueof(sublst[1]) : '';
          
        if (refId != '') {
         EmailMessageCreation.attachEmailIfRefExists(email);    
        }
       //SDT-24578 End
        
        List<String> lemails = new List<String>();
        // Check statue or Quote if that is not Approved then only process this block //
        if(quoteId != ''){
            
         //TCS-pkulkarn-SDT-41186-14-Oct-2024-Added Type (SBQQ__Type__c), Assigned To (Assigned_To__c) field to the SOQL
         //SDT 33101 ,Quote_Only__c
         //SDT 45079 SBQQ__Opportunity2__r.Case__c,LastModifiedById,OwnerId,Name
         SBQQ__Quote__c objQuote = [SELECT Id, CreatedBy.UserRole.Name, SBQQ__Account__r.Parent.Primary_Segment__c, Quote_Thread_Id__c, Project__c, Project_Services_Request__c, SBQQ__Status__c, Business_Rule__c,
                                    SBQQ__Type__c, Assigned_To__c,Business_Rule__r.Is_Auto_Email__c, Business_Rule__r.Multiple_Mandatory_Approvers__c
                                    ,Quote_Only__c,SBQQ__Opportunity2__r.Case__c,LastModifiedById,OwnerId,Name,LastModifiedBy.UserName,SBQQ__Opportunity2__r.Case__r.SLA_Service_Date_Time__c,
                                    SBQQ__Opportunity2__r.Case__r.Case_Sub_Type__c,Assigned_To__r.GR_Service_Flag__c,LastModifiedBy.Genesys_Enabled__c,Priority__c,SBQQ__Account__r.Parent.Customer_Code__c,SBQQ__Account__r.Location_Code__c,SBQQ__Account__r.tz__Timezone__c,SBQQ__Opportunity2__r.Case__r.CaseNumber,SBQQ__Opportunity2__r.Case__r.Reference_Number__c,GR_Service_Flag__c,SBQQ__Opportunity2__r.Case__r.Case_Type__c,SBQQ__Opportunity2__r.Case__r.Case_Reason__c,SBQQ__Opportunity2__r.Case__r.Asset.Project_Code__c,Next_Action_Due_Date__c
                                    FROM SBQQ__Quote__c 
                                    WHERE Id =: quoteId LIMIT 1];
            ///Sdt-20074
        String segment = objQuote.SBQQ__Account__r.Parent.Primary_Segment__c;
        List<Service_Approver__c> lserviceApprovers = [SELECT id,Email__c,Account__c,Recordtype.Name,Business_Rule__c,Approver_Contact__c,Title__c,Department__c,Account_Department__c,Account_Title__c,User__c,Approver_Email__c 
                                                           FROM Service_Approver__c 
                                                           WHERE (Recordtype.Name = 'Contact' OR 
                                                              Recordtype.Name = 'User' OR 
                                                              Recordtype.Name = 'Title' OR 
                                                              Recordtype.Name = 'Email' OR 
                                                              Recordtype.Name = 'Department') 
                                                              AND Active__c = TRUE AND Business_Rule__c =:objQuote.Business_Rule__c]; 
            //added by chandu kari
         
        //
        Set<String> approverSet = new Set<String>();
        for(Service_Approver__c c : lserviceApprovers){
            approverSet.add(c.Approver_Email__c);
        }
            //System.debug('objQuot---------->'+objQuote);
            if(objQuote != null && (objQuote.SBQQ__Status__c.equalsIgnoreCase(CONSTANT_UTIL.QUOTE_APPROVED) || objQuote.SBQQ__Status__c.equalsIgnoreCase(CONSTANT_UTIL.QUOTE_DECLINED)))
            {
                //System.debug('objQuote Status---------->'+objQuote.SBQQ__Status__c);
                String status;
                status = sublst[0] == CONSTANT_UTIL.QUOTE_APPROVED ? CONSTANT_UTIL.QUOTE_APPROVED : CONSTANT_UTIL.QUOTE_DECLINED;
                lemails.add(fromAddress);
                //QuoteApproval.createInboundApprovalLog(lEmails, QuoteId, status, email.plainTextBody,objQuote.Business_Rule__c);
            }
            else if(objQuote != null)
            {
                String declinedBy;

                //TCS-pkulkarn-SDT-41186-14-Oct-2024-Added if condition and moved the Status assginment to else part
                if(objQuote.SBQQ__Type__c == Constant_Util.QUOTE_TYPE_AMEND )//&& sublst[0] == CONSTANT_UTIL.QUOTE_APPROVED)    //TCS-pkulkarn-SDT-33101-11-Nov-2024-Commented Approved check-Removed comments on Approved check
                {
                    QuoteOnlyController.handleAmendmentQuoteApprovalViaEmail(objQuote, sublst);		//TCS-pkulkarn-SDT-33101-11-Nov-2024-Revert 33101
                    //assignQuoteToSSMTeam(objQuote);		//SDT 33101 New //Reverted 33101 code //TCS-pkulkarn-SDT-33101-11-Nov-2024-Commented. Amendment quote approval handeled in QuoteOnlyController.handleAmendmentQuoteApprovalViaEmail()
                    //TCS-pkulkarn-SDT-42555-21-Nov-2024-Added following line to fix the defect. Approve/Decline/Cancel buttons to be disabled for Sales once Quote is approved via email
                    //objQuote.Is_Amendment_Quote_Approved_By_Sales__c = true; //SDT 33101 New
                }
                else
                {
                    isHaulAway = HaulAwayService.getIsHaulAwayService(objQuote.SBQQ__Opportunity2__r.Case__c);
                    //SDT 45079 Seema
                    if(isHaulAway){
                        RecurrsiveTriggerHandler.isSkipCaseTriggerForTask= true;
                        //Added by Chandu Kari SDT-49972 - Start
                        lemails.add(fromAddress);
                        QuoteApproval.createInboundApprovalLog(lemails, quoteId, sublst[0], email.plainTextBody, objQuote.Business_Rule__c); 
                        if(objQuote.Business_Rule__r.Multiple_Mandatory_Approvers__c){
                            isMultiMandatoryApprovers = handleMultipleMandatoryApprovers(quoteId, approverSet);
                        }
                        if(isMultiMandatoryApprovers != 'SubmitForApprovalQuote'){
                            objQuote.SBQQ__Status__c = sublst[0] == CONSTANT_UTIL.QUOTE_APPROVED ? CONSTANT_UTIL.QUOTE_APPROVED : CONSTANT_UTIL.QUOTE_DECLINED;
                            quoteApprovalStatus = objQuote.SBQQ__Status__c;
                        }else{
                            //This assinment for Task creation on Case and not for update quote status.
                            objQuote.SBQQ__Status__c = sublst[0] == CONSTANT_UTIL.QUOTE_APPROVED ? CONSTANT_UTIL.QUOTE_APPROVED : CONSTANT_UTIL.QUOTE_DECLINED;
                        }
                        //--End
                        List<User> CSResolutionTeamUserList = UserSelector.getCSResolutionTeamUser();
                        String userCSResolutionTeam;
                        Id userCSResolutionTeamId;
                        if(CSResolutionTeamUserList.size() == 1)
                        {
                            userCSResolutionTeamId = CSResolutionTeamUserList[0].Id;
                            userCSResolutionTeam = CSResolutionTeamUserList[0].UserName.substringBefore(Constant_Util.AT_SYMBOL);
                        }
                        HaulAwayService.genUserDetalsWrapper genUserDetalsWrapperRec = HaulAwayService.getIfGenesysEnabledUser(objQuote.Assigned_To__c);
                        //isGenesysEnabledUser = HaulAwayService.getIfGenesysEnabledUser(objQuote.Assigned_To__c);
                        isGenesysEnabledUser = genUserDetalsWrapperRec.isGenesysEnabledUser;
                        genServiceFlag  = genUserDetalsWrapperRec.genFlag;
                        String userQuoteOwner = objQuote.Assigned_To__c;
                        //not genesys enabled user-----------Create a task for the quote owner under the case
                        if(isGenesysEnabledUser){
                            String userLastAgent = objQuote.LastModifiedBy.UserName.substringBefore(Constant_Util.AT_SYMBOL);
                            Id userLastAgentId = objQuote.LastModifiedById;
                            isLastAgentAvailable = HaulAwayService.getIfLastAgentAvailable(userLastAgent);
                            if(isLastAgentAvailable){
                                task genTask = HaulAwayService.createGenesysTask(objQuote,userQuoteOwner);//userLastAgentId) Create a task for the case owner under the case
                                HaulAwayService.createGenesysRecord(objQuote,userLastAgent,userLastAgentId,genServiceFlag,genTask);//Create a genesys record with the last agent logic.
                            }else{
                                task genTask = HaulAwayService.createGenesysTask(objQuote,userCSResolutionTeamId);//Create a task for the CS resolution team under the case
                                HaulAwayService.createGenesysRecord(objQuote,userCSResolutionTeam,userCSResolutionTeamId,genServiceFlag,genTask);//Create a genesys record for the CS resolution team
                            } 
                        }else{
                            HaulAwayService.createGenesysTask(objQuote,userQuoteOwner);//not case
                        }
                        //Added by Chandu Kari SDT-49972 - Start
                        if(isMultiMandatoryApprovers != 'SubmitForApprovalQuote'){
                            update objQuote;
                        }
                        RecurrsiveTriggerHandler.isSkipCaseTriggerForTask= false;

                    }
                    else{
                       objQuote.SBQQ__Status__c = sublst[0] == CONSTANT_UTIL.QUOTE_APPROVED ? CONSTANT_UTIL.QUOTE_APPROVED : CONSTANT_UTIL.QUOTE_DECLINED;
                    }
                    //SDT 45079 end
                    
                }
               
                if(!isHaulAway){ 
                update objQuote;
                }
                //--End
                lemails.add(fromAddress);
                
                String emailTextBody;
                if(objQuote.SBQQ__Status__c == CONSTANT_UTIL.QUOTE_DECLINED)
                {
                    List<String> comment = email.plainTextBody.split(CONSTANT_UTIL.REFERENCE_COLON);
                    emailTextBody = (comment != null && comment.size() > 0) ? comment[0] : CONSTANT_UTIL.EMPTY_STRING;
                }
                else 
                {
                    emailTextBody = email.plainTextBody;
                }
                //TCS-pkulkarn-SDT-41186-14-Oct-2024-Added if condition and moved the Status assginment to else part
                if(objQuote.SBQQ__Type__c == Constant_Util.QUOTE_TYPE_AMEND && sublst[0] == CONSTANT_UTIL.QUOTE_APPROVED)
                {
                    quoteApprovalStatus = sublst[0] == CONSTANT_UTIL.QUOTE_APPROVED ? CONSTANT_UTIL.QUOTE_APPROVED : CONSTANT_UTIL.QUOTE_DECLINED;
                }
                else
                {
                        quoteApprovalStatus = objQuote.SBQQ__Status__c;
                }
                //TCS-pkulkarn-SDT-41186-14-Oct-2024-End
                if(!isHaulAway){
                    QuoteApproval.createInboundApprovalLog(lEmails, QuoteId, quoteApprovalStatus, emailTextBody, objQuote.Business_Rule__c);
                }
                //Send Decline Email
                onRejectEmailSendNotificatio(objQuote);
            }
      
        }
        return result;
    }

    /*
    *Developer  : Aliasgher
    *Description : SDT-20835 This method is used to send Declined Quote Notification
    *Date : 9/6/2022
    */
    private void onRejectEmailSendNotificatio(SBQQ__Quote__c objQuote)
    {
        if(objQuote.SBQQ__Status__c == CONSTANT_UTIL.QUOTE_DECLINED)
        {
            QuoteDecline.sendDeclineQuoteNotification(objQuote.Id);
        }
    } 

    //TCS-pkulkarn-SDT-41186-14-Oct-2024-Added
    //This method assigns a Quote to SSM Team User
    public static void assignQuoteToSSMTeam(SBQQ__Quote__c objQuote)
    {
        List<User> ssmTeamUser = UserSelector.getSSMUser();
        if(ssmTeamUser.size() == 1)
        {
            objQuote.Assigned_To__c = ssmTeamUser[0].Id;
        }
    }

    /*
    *Developer  : Chandu Kari
    *Description : SDT-49772 , 46926 This method is used fetching approved and declined approva loggs
    *Date : 11/19/25
    */
    public static String handleMultipleMandatoryApprovers(String quoteId,Set<String> setApprovers){
        String result;
        List<Approval_log__c> approvalLogs = [SELECT Id,Status__c,Email__c,Quote__c,BusinessRuleId__r.Is_Auto_Email__c,BusinessRuleId__r.Multiple_Mandatory_Approvers__c 
                                              FROM Approval_log__c 
                                              WHERE Quote__c =:quoteId 
                                              //AND Status__c ='Approval Requested' //  AND Status__c != 'Approved'
                                              AND BusinessRuleId__r.Is_Auto_Email__c = True
                                              AND BusinessRuleId__r.Multiple_Mandatory_Approvers__c = True];
        
        Set<String> approvedEmails = new Set<String>();
        Set<String> declinedEmails = new Set<String>();
        for(Approval_log__c alg: approvalLogs){
            if(alg.Status__c == 'Approved'){
                approvedEmails.add(alg.Email__c);
            }
            if(alg.Status__c == 'Declined'){
                declinedEmails.add(alg.Email__c);
                result = 'DeclineQuote';
            }
            
        }
        
        if(declinedEmails.size() >0){
            return result;
        }
        else{
            result = areEmailSetsEqual(setApprovers, approvedEmails);
        }
        return result;
        
    }
    /*
    *Developer  : Pulkit Grover
    *Description : SDT-49772 , 46926 This method is used checking declined and approved sets are equal or not
    *Date : 11/19/25
    */
    public static String areEmailSetsEqual(Set<String> setApprovers, Set<String> approvedEmails) {
        String result;
        // Check if both sets are equal 
         if(setApprovers.equals(approvedEmails)){
            result = 'ApprovedQuote';
         }else{
             result = 'SubmitForApprovalQuote';
         }
        return result;
    }
    
}