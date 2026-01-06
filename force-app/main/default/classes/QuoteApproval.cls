/* 
* Apex Class : QuoteApproval
* Description : This class is used for Quote Approval
* Developer : Lovel
* Date : 
* Additional Comments : Refactor the Code by Yogesh, Arvind & Chetan.
* Modified Comment : Code Refactored by Anup Dey for STP usage : 6/23/2023
*/

public class QuoteApproval 
{
    // Global variables
    public static Map<String,String> approverTypeMap = new Map<String,String>();
    public static Map<String,String> mapQuoteWithBRule = new Map<String,String>();
    public static Boolean isTitleRecordType = false;
    //SDT 32654
    public static String QUOTETYPE = 'Quote';
    public static String NEWSERVICECASE = 'New Service Case';
    public static Boolean isContactRecordType = false;
    public static Boolean isNTEbusinessRule = false;
    public static Boolean isDepartmentRecordType = false;
    public static Boolean isUserRecordType = false;
    public static Boolean isEmailToCase = false;
    public static Boolean isEmailRecordType = false;
    //Changes for SDT-30717
    public static Map<Id,Boolean> mapBRuleAutoEmail = new Map<Id,Boolean>();
    Map<decimal, List<Map<String, String>>> mPriorityFieldConditionMap = new Map<decimal, List<Map<String, String>>>();
    //variable to be used in this class only
    //SDT-25177 This variable will be in used in ApprovalLogCreation method . It will be set to true once Approval log is created.
    //It will be set to false once Email is sent to Service Approver in createEmailMessage method.
    private static Boolean isApprovalLogCreated = false;
    public static Boolean isRequestorOnly = false;
    public static List<string> requesterOnlylst = new list<string>();
    public static Map<String,String> requestorOnlyMap = new Map<String,String>();
    private static string NBR = 'NBR';
    // global variable to hold Destination fields
    private set<String> destinationFields =new set<String>();
    
    // Description : This method will call from After update of Quote record.
    public void startApprovalProcess(Map<Id, SBQQ__Quote__c> mnewQuote)
    {
        
        //System.debug('mnewQuote--'+mnewQuote);
        if(!mnewQuote.isEmpty()){
            // local Variables
            Set<Id> sQuoteIds = new Set<Id>();
            Map<Id, Map<String,List<SBQQ__QuoteLine__c>>> getQuoteLinesDurationAndQuote = new Map<Id, Map<String,List<SBQQ__QuoteLine__c>>>();
            Map<String,List<SBQQ__QuoteLine__c>> mQuouteLines =  new Map<String,List<SBQQ__QuoteLine__c>>();
            Map<String, Map<String, Map<Decimal, String>>> mQuoteDurationPriorityCondition = new Map<String, Map<string, Map<Decimal,String>>>();
            Map<decimal, String> getFilterbasedOnPriority = new Map<decimal, String>();
            Map<Id,Map<String, List<String>>> quoteApprovers = new Map<Id,Map<String, List<String>>>();
            //Map <String,Map<String, List<String>>> mDurationApprovers = new Map <String,Map<String, List<String>>>();
            Map <String,List<String>> mServiceApprovers = new Map<String,List<String>>();
            
            //Fetching all the Quote Line records using quote id
            sQuoteIds = mnewQuote.keyset();
            //System.debug('sQuoteIds--+'+sQuoteIds);
            //Changes for SDT-30717
            QuoteLineSelector qlSelector = new QuoteLineSelector();
            List<SBQQ__QuoteLine__c> lQuotelines = qlSelector.getQuoteLinesByQuoteIdHavingOpportunity(sQuoteIds);
            
            if(lQuotelines != Null && !lQuotelines.isEmpty())
            {
                /*This will store the Map of Quote Id with Map of QuoteLines based on Duration__c for prioritization*/
                for(SBQQ__QuoteLine__c objQuoteLine : lQuotelines){
                    mQuouteLines.put(objQuoteLine.Duration__c,lQuotelines); 
                    getQuoteLinesDurationAndQuote.put(objQuoteLine.SBQQ__Quote__c, mQuouteLines);
                }
                
                //Prioritization logic
                mQuoteDurationPriorityCondition = constructPriorityConditions(getQuoteLinesDurationAndQuote,mnewQuote);    
                //System.debug('mQuoteDurationPriorityCondition===='+mQuoteDurationPriorityCondition);
                
                //Get Business Rule Approvers
                for(Id qId : mQuoteDurationPriorityCondition.keyset()){
                    if(mQuoteDurationPriorityCondition.get(qId) != null){
                        for(String duration : mQuoteDurationPriorityCondition.get(qId).keyset()){
                            getFilterbasedOnPriority.putAll(mQuoteDurationPriorityCondition.get(qId).get(duration));
                        }
                    }
                }
    
                // Get Business Approvers
                mServiceApprovers = getBusinessRuleApprovers(getFilterbasedOnPriority,mnewQuote.get(lQuotelines.get(0).SBQQ__Quote__c), lQuotelines);
                system.debug('mServiceApprovers :: ' +mServiceApprovers);
                
                if(mServiceApprovers != null && mServiceApprovers.size() > 0){
                    //Performing a step here to replace instances of {null, null} with {NBR, null}
                    //This will allow services without Business Rules to flow through the auto-approval process 
                    for (String key : mServiceApprovers.keyset()) {
                        if (key == null) {
                            mServiceApprovers.remove(key);
                            mServiceApprovers.put(NBR, null);
                        }
                    }
                    quoteApprovers.put(lQuotelines.get(0).SBQQ__Quote__c,mServiceApprovers);
                    SBQQ.TriggerControl.disable();
                    try{
                        getToAddressesWithQuote(quoteApprovers, mnewQuote);
                    }
                    catch(Exception ex){
                        system.debug('Exception '+ex.getMessage());
                    }
                    finally{
                        SBQQ.TriggerControl.enable();
                    }
                }
            }    
        }
    } 
    
    // Description: Getting the list of approver and updating thw quote, sending the email accordingly 
    public void getToAddressesWithQuote(Map<Id,Map<String, List<String>>> serviceApproverMap, Map<Id,SBQQ__Quote__c> quoteMap){
        if(serviceApproverMap != Null && !serviceApproverMap.isEmpty())
        {
            Set<String> emailAddresses = new Set<String>();
            Map<Id,List<String>> quoteWithEmailAddresses = new Map<Id,List<String>>();
            List<SBQQ__Quote__c> quoteListToUpdate = new List<SBQQ__Quote__c>();
            List<SBQQ__Quote__c> NBRQuoteListToUpdate = new List<SBQQ__Quote__c>();
            List<SBQQ__Quote__c>quoteListWithNoServiceApprovers = new List<SBQQ__Quote__c>();
            Id parentQuoteId;
            System.debug('serviceApproverMap====='+serviceApproverMap);
            if(serviceApproverMap.keySet() != null){
                for(Id quoteId : serviceApproverMap.keySet()){
                    parentQuoteId = quoteId;
                // System.debug('serviceApproverMap$$$$====='+serviceApproverMap.get(quoteId).keySet());
                    for(String brId : serviceApproverMap.get(quoteId).keySet()){
                        mapQuoteWithBRule.put(quoteId, brId); // Added quote with Business rule 
                        if(brId != NBR && serviceApproverMap.get(quoteId).get(brId) !=null) {
                                for(String email : serviceApproverMap.get(quoteId).get(brId)){
                                    //Changes for story SDT-24197
                                    if(String.isNotEmpty(email) && email !=Constant_Util.ORIGIN){
                                        emailAddresses.add(email);
                                    }
                                }
                        }
                        else if(brId != NBR && serviceApproverMap.get(quoteId).get(brId)==null) {
                            SBQQ__Quote__c quoteRec = new SBQQ__Quote__c();
                            quoteRec.id = quoteId;
                            quoteRec.Business_Rule__c = mapQuoteWithBRule.get(quoteId);
                            quoteListWithNoServiceApprovers.add(quoteRec);
                        }
                        
                        else{
                            //SDT 32654 (AC)Quote will be auto approved only if its SBQQ__Type__c is Quotee 
                            if(quoteMap.get(quoteId).SBQQ__Type__c==QUOTETYPE && quoteMap.get(quoteId).SBQQ__Opportunity2__r.Case__r.Case_Type__c!=NEWSERVICECASE && !isNTEbusinessRule){
                                SBQQ__Quote__c quoteRec = new SBQQ__Quote__c();
                                quoteRec.id = quoteId;
                                quoteRec.SBQQ__Status__c = 'Approved';
                            //    system.debug('i am elligible for AC auto approval'+quoteMap.get(quoteId).SBQQ__Type__c);
                            //quoteRec.Business_Rule__c = mapQuoteWithBRule.get(quoteId);
                            // if(approverTypeMap.containsKey(Constant_Util.ORIGIN))
                            // {
                            //     String originValuesforBR = approverTypeMap.get(Constant_Util.ORIGIN);
                            //     if(String.isNotEmpty(originValuesforBR))
                            //     {
                            //         List<String> BRparts = originValuesforBR.split(Constant_Util.COLON);
                            //         if(BRparts !=null && BRparts.size()>1)
                            //         {
                            //             quoteRec.Business_Rule__c = BRparts[2]; 
                            //         }
                            //     }
                            // }
                            NBRQuoteListToUpdate.add(quoteRec);
                            }
                        }
                    }
                }
            }  
            String caseNumber = quoteMap.get(parentQuoteId).Case_Number__c;
            //Changes for SDT-30717
            Id caseId = quoteMap.get(parentQuoteId).SBQQ__Opportunity2__r.Case__c;
            String caseSuppliedName = quoteMap.get(parentQuoteId).SBQQ__Opportunity2__r.Case__r.SuppliedName;
            String caseSuppliedEmail = quoteMap.get(parentQuoteId).SBQQ__Opportunity2__r.Case__r.SuppliedEmail;
            String caseOrigin = quoteMap.get(parentQuoteId).SBQQ__Opportunity2__r.Case__r.Origin;
            String caseCreatedByEmail = quoteMap.get(parentQuoteId).SBQQ__Opportunity2__r.Case__r.CreatedBy.Email;
            String caseCreatedById = quoteMap.get(parentQuoteId).SBQQ__Opportunity2__r.Case__r.CreatedById;
            List<Approval_log__c> finalApprovalLogLst= new List<Approval_log__c>();

            if(NBRQuoteListToUpdate.size()>0){
                update NBRQuoteListToUpdate;
                // Changes for Origin Story SDT-24197
                if(approverTypeMap.containsKey(Constant_Util.ORIGIN))
                {
                    List<Approval_log__c> approvalLogLst = createApprovalLogForOrigin(NBRQuoteListToUpdate.get(0).id,'Approved','Auto Approved');
                    //Changes for SDT-30717
                    finalApprovalLogLst = approvalLogLst;
                }
            
                // Changes for Request Only Story SDT-24198
                if(isRequestorOnly)
                {
                    List<String> emailAddressList = new List<String>(new Set<String>(emailAddresses));
                    List<Approval_log__c> approvalLogLst = createApprovalLogForRequestorOnly(emailAddressList,quoteListToUpdate.get(0).id,'Approved','Auto Approved', quoteMap.get(NBRQuoteListToUpdate.get(0).id).SBQQ__PrimaryContact__r.Email);
                }
                //END
 
                if(approverTypeMap.containsKey(Constant_Util.NO_APPROVAL))
                {
                    List<Approval_log__c> approvalLogLst = createApprovalLogForNoApproval(NBRQuoteListToUpdate.get(0).id,'Approved','Auto Approved');
                    //Changes for SDT-30717
                    finalApprovalLogLst = approvalLogLst;
                }
                // SDT-24196 Role Profile
                if(approverTypeMap.containsKey(Constant_Util.ROLEPROFILE))
                {
                   //Changes for SDT-30717
                    List<Approval_log__c> approvalLogLst = createApprovalLogForRoleProfile(caseId);
                    //Changes for SDT-30717
                    finalApprovalLogLst = approvalLogLst;
                }
                //SDT- 25968
                if(isTitleRecordType)
                {
                    
                    String quoteId = NBRQuoteListToUpdate.get(0).id;
                    String titleValuesString = approverTypeMap.get(quoteMap.get(NBRQuoteListToUpdate.get(0).id).SBQQ__PrimaryContact__r.Email);
                    //System.debug('>>>titleValuesString'+titleValuesString);
                    List<String> titleValues = new List<String>();
                    
                    if(titleValuesString != null)
                    {
                        titleValues = titleValuesString.split(Constant_Util.COLON);
                    }
                    //System.debug('>>>titleValues'+titleValues);
                    
                    if(titleValues != null && !titleValues.isEmpty()){
                        
                        List<Approval_log__c> approvalLogList = createApprovalLogForTitleContactAndDepartment(Constant_Util.SERVICE_TITLE_RECORDTYPE,quoteId, caseId, titleValues[1], quoteMap.get(NBRQuoteListToUpdate.get(0).id).SBQQ__PrimaryContact__r.Email, quoteMap.get(NBRQuoteListToUpdate.get(0).id).SBQQ__PrimaryContact__r.id, Constant_Util.QUOTE_APPROVED, Constant_Util.QUOTE_AUTO_APPROVED, mapQuoteWithBRule.get(quoteId));
                        //system.debug('@@@approvalLogList'+approvalLogList);
                        
                        //Changes for SDT-30717
                        finalApprovalLogLst = approvalLogList;
                    }
                }
                
                if(isDepartmentRecordType)
                {
                    String quoteId = NBRQuoteListToUpdate.get(0).id;
                    String departmentValuesString = approverTypeMap.get(quoteMap.get(NBRQuoteListToUpdate.get(0).id).SBQQ__PrimaryContact__r.Email);
                    List<String> departmentValues = departmentValuesString.split(Constant_Util.COLON);
                    if(departmentValues != null && !departmentValues.isEmpty()){
                        List<Approval_log__c> approvalLogList = createApprovalLogForTitleContactAndDepartment(Constant_Util.SERVICE_DEPARTMENT_RECORDTYPE,quoteId, caseId,departmentValues[1], quoteMap.get(NBRQuoteListToUpdate.get(0).id).SBQQ__PrimaryContact__r.Email, quoteMap.get(NBRQuoteListToUpdate.get(0).id).SBQQ__PrimaryContact__r.id, Constant_Util.QUOTE_APPROVED, Constant_Util.QUOTE_AUTO_APPROVED, mapQuoteWithBRule.get(quoteId));
                        //Changes for SDT-30717
                        finalApprovalLogLst = approvalLogList;
                    }
                }
            }
            
            if(quoteListWithNoServiceApprovers.size()>0){
                update quoteListWithNoServiceApprovers;               
            }
            Map<Id,SBQQ__Quote__c> mapOfQuoteToUpdate= new  Map<Id,SBQQ__Quote__c>();
            //system.debug('emailAddresses >'+ emailAddresses);
            if(!emailAddresses.isEmpty())
            {
                for(Id quoteId : serviceApproverMap.keySet()){
                    if(emailAddresses.contains(quoteMap.get(quoteId).SBQQ__PrimaryContact__r.Email) && !isNTEbusinessRule){
                        SBQQ__Quote__c quoteRec = new SBQQ__Quote__c();
                        quoteRec.id = quoteId;
                        quoteRec.SBQQ__Status__c = 'Approved';
                        quoteRec.Business_Rule__c = mapQuoteWithBRule.get(quoteId);
                        quoteListToUpdate.add(quoteRec);
                        
                        setMapOfQuoteToUpdate(quoteRec,mapOfQuoteToUpdate);
                        if(approverTypeMap != Null && !approverTypeMap.isEmpty() && approverTypeMap.containsKey(quoteMap.get(quoteId).SBQQ__PrimaryContact__r.Email))
                        {
                            for (String emailId: approverTypeMap.keySet())
                            {
                              if(emailId == quoteMap.get(quoteId).SBQQ__PrimaryContact__r.Email){
                                    String approvalType = approverTypeMap.get(quoteMap.get(quoteId).SBQQ__PrimaryContact__r.Email);
                                    List<String> splittedValue = approvalType.split(Constant_Util.COLON);
                                    if(splittedValue[0] == Constant_Util.SERVICE_EMAIL_RECORDTYPE)
                                    {
                                        isEmailRecordType = true;
                                    }
                                }
                            }
                        }
                    }
                    
                    //SDT-24002, Quote will be Auto Approved. 
                  //Part1 - From email address for case created via Email-to-Case function is linked to an applicable Approval business rule with an Email Approver Type
                  //System.debug('caseRecord.Origin >'+ caseOrigin);
                    if(caseOrigin != Null && (caseOrigin == 'Email' && emailAddresses.contains(caseSuppliedEmail)) && !isNTEbusinessRule)
                    {
                        SBQQ__Quote__c quoteRec = getQuoteApproved(quoteId, mapQuoteWithBRule.get(quoteId));
                        quoteListToUpdate.add(quoteRec);
                        setMapOfQuoteToUpdate(quoteRec,mapOfQuoteToUpdate);
                        isEmailToCase = true;
                    }
                    
                    //SDT-24002 Part2 - Quote will be Auto Approved, User who created the case is linked to an applicable Approval business rule with a User Approver Type
                    if(approverTypeMap != Null && !approverTypeMap.isEmpty() && approverTypeMap.containsKey(caseCreatedByEmail) && !isNTEbusinessRule )
                    {
                        for (String emailId: approverTypeMap.keySet())
                        {
                          if(emailId == caseCreatedByEmail){
                                String approvalType = approverTypeMap.get(caseCreatedByEmail);
                                List<String> splittedValue = approvalType.split(Constant_Util.COLON);
                                if(splittedValue[0] == Constant_Util.SERVICE_USER_RECORDTYPE)
                                {
                                    SBQQ__Quote__c quoteRec = getQuoteApproved(quoteId, mapQuoteWithBRule.get(quoteId));
                                    quoteListToUpdate.add(quoteRec);
                                    //SDT-25591 - Adding quote to map to stop duplication.
                                    setMapOfQuoteToUpdate(quoteRec,mapOfQuoteToUpdate);
                                    isUserRecordType = true;
                                }
                            }
                        }
                    }
                } 
                
                 List<SBQQ__Quote__c> lstOfQuoteToUpdate = getMapOfQuoteToUpdate(MapOfQuoteToUpdate);
                 quoteListToUpdate = lstOfQuoteToUpdate;
                 //system.debug('quoteListToUpdate >'+ quoteListToUpdate);
                if(!quoteListToUpdate.isEmpty())
                {
                    update quoteListToUpdate;
                    if(isEmailRecordType)
                    {
                        String quoteId = quoteListToUpdate.get(0).id;
                        List<Approval_log__c> approvalLogList = createApprovalLog_EmailTypeAutoApproval(quoteId, caseId,caseSuppliedName, quoteMap.get(quoteListToUpdate.get(0).id).SBQQ__PrimaryContact__r.Email, quoteMap.get(quoteListToUpdate.get(0).id).SBQQ__PrimaryContact__r.id, Constant_Util.QUOTE_APPROVED, Constant_Util.QUOTE_AUTO_APPROVED, mapQuoteWithBRule.get(quoteId) );
                        //Changes for SDT-30717
                        finalApprovalLogLst = approvalLogList;
                    }
                    if(isUserRecordType)//isTitleRecordType
                    {
                        String quoteId = quoteListToUpdate.get(0).id;
                        List<Approval_log__c> approvalLogList = createApprovalLogUserTypeAutoApproval(quoteId, caseId,caseCreatedById, quoteMap.get(quoteListToUpdate.get(0).id).SBQQ__PrimaryContact__r.Email, quoteMap.get(quoteListToUpdate.get(0).id).SBQQ__PrimaryContact__r.id, Constant_Util.QUOTE_APPROVED, Constant_Util.QUOTE_AUTO_APPROVED, mapQuoteWithBRule.get(quoteId) );
                        //Changes for SDT-30717
                        finalApprovalLogLst = approvalLogList;
                    }
                     if(isEmailToCase)
                    {
                        String quoteId = quoteListToUpdate.get(0).id;
                        List<Approval_log__c> approvalLogList = createApprovalLogEmailtoCaseAutoApproval(quoteId, caseId,caseSuppliedName, quoteMap.get(quoteListToUpdate.get(0).id).SBQQ__PrimaryContact__r.Email, quoteMap.get(quoteListToUpdate.get(0).id).SBQQ__PrimaryContact__r.id, Constant_Util.QUOTE_APPROVED, Constant_Util.QUOTE_AUTO_APPROVED, mapQuoteWithBRule.get(quoteId) );
                        //Changes for SDT-30717
                        finalApprovalLogLst = approvalLogList;
                    }
                                      
                 
                    if(isContactRecordType)//isContactRecordType
                    {
                        String quoteId = quoteListToUpdate.get(0).id;
                        String contactValuesString = approverTypeMap.get(quoteMap.get(quoteListToUpdate.get(0).id).SBQQ__PrimaryContact__r.Email);
                        List<String> contactValues;
                        if(contactValuesString != null){
                         contactValues = contactValuesString.split(Constant_Util.COLON);
                         }
                        if(contactValues != null && !contactValues.isEmpty()){
                            List<Approval_log__c> approvalLogList = createApprovalLogForTitleContactAndDepartment(Constant_Util.SERVICE_CONTACT_RECORDTYPE,quoteId, caseId,contactValues[1], quoteMap.get(quoteListToUpdate.get(0).id).SBQQ__PrimaryContact__r.Email, quoteMap.get(quoteListToUpdate.get(0).id).SBQQ__PrimaryContact__r.id, Constant_Util.QUOTE_APPROVED, Constant_Util.QUOTE_AUTO_APPROVED, mapQuoteWithBRule.get(quoteId));
                            //Changes for SDT-30717
                            finalApprovalLogLst = approvalLogList;
                        } 
                    }
                    //createApprovalLog(null,quoteListToUpdate.get(0).id,'Approved','Auto Approved');
        
                     // Changes for Request Only Story SDT-24198
                     if(isRequestorOnly)
                     {
                        //system.debug('quoteMap.get(quoteListToUpdate.get(0).id).SBQQ__PrimaryContact__r.Email '+quoteMap.get(quoteListToUpdate.get(0).id).SBQQ__PrimaryContact__r.Email);
                        List<String> emailAddressList = new List<String>(new Set<String>(emailAddresses));
                         List<Approval_log__c> approvalLogLst = createApprovalLogForRequestorOnly(emailAddressList,quoteListToUpdate.get(0).id,'Approved','Auto Approved', quoteMap.get(quoteListToUpdate.get(0).id).SBQQ__PrimaryContact__r.Email);
                         //Changes for SDT-30717
                         finalApprovalLogLst = approvalLogLst;
                     }
                     //END
                }
                else{
                    //Send Email Message based on Approvers
                    List<String> emailAddressList = new List<String>(new Set<String>(emailAddresses));
                    // Changes done for SDT-24198
                    List<String> newemailAddressList = new list<String>();
                    for(string emailstr : emailAddressList){
                        if(!requesterOnlylst.contains(emailstr)){
                            newemailAddressList.add(emailstr);
                        }
                    }
                    //Changes for SDT-30717
                    Id brId = mapQuoteWithBRule.get(parentQuoteId);
                    Boolean isAutoEmail = mapBRuleAutoEmail.get(brId);

                    // Updating Business Rule on 'Submit for Approval' Quote.
                    SBQQ__Quote__c quoteRec = new SBQQ__Quote__c();
                    quoteRec.id = parentQuoteId;
                    quoteRec.Business_Rule__c = brId;
                    update quoteRec;
                    
                    
                    if(newemailAddressList.size() > 0 && isAutoEmail)
                    {
                       //System.debug('***newemailAddressList'+newemailAddressList);
                    
                       Messaging.SingleEmailMessage email =  createEmailMessage(newemailAddressList,parentQuoteId);
                        if(email != null){
                            attachEmailMessage(email,newemailAddressList,parentQuoteId);
                        }
                    }
                }
            }
        
            else{
                //SDT-24757 // SDT-38003
                if(isContactRecordType && !approverTypeMap.containsKey(Constant_Util.NO_APPROVAL))
                {
                    //System.debug('***parentQuoteId'+parentQuoteId);
                    //System.debug('***ContactID'+quoteMap.get(parentQuoteId).SBQQ__PrimaryContact__r.id);
                    List<Approval_log__c> approvalLogList = createApprovalLogForTitleContactAndDepartment(Constant_Util.SERVICE_CONTACT_RECORDTYPE,parentQuoteId, caseId,null, quoteMap.get(parentQuoteId).SBQQ__PrimaryContact__r.Email, quoteMap.get(parentQuoteId).SBQQ__PrimaryContact__r.id, Constant_Util.QUOTE_APPROVED, Constant_Util.QUOTE_AUTO_APPROVED, mapQuoteWithBRule.get(parentQuoteId));
                    //Changes for SDT-30717
                    finalApprovalLogLst = approvalLogList;
                }
            }
            //Changes for SDT-30717
            if(finalApprovalLogLst!=null && !finalApprovalLogLst.isEmpty())
            {
                approvalLogCreation(finalApprovalLogLst);
            }
        }
    }
    //24002 Approval Log Creation for User type
    public static List<Approval_log__c> createApprovalLogUserTypeAutoApproval(String quoteId, String caseId, String userId, String contactEmail,String contactid, String quoteStatus,String comments, String businesRuleID)
    {
        List<Approval_log__c> approvalLogList = new List<Approval_log__c>();
        //system.debug('quoteId-'+quoteId + 'CaseId-'+caseId+ 'userId-'+userId+ 'contactEmail-'+contactEmail+ 'contactid-'+contactid+ 'quoteStatus-'+quoteStatus+ 'comment-'+comments + 'businesRuleID-'+businesRuleID);
        Approval_log__c approvalLog = new Approval_log__c();
                        approvalLog.CaseId__c = caseId;
                        approvalLog.BusinessRuleId__c = businesRuleID; 
                        approvalLog.Approval_Description__c = comments + ' from ' + Constant_Util.USER_APPROVAL;
                        approvalLog.Actual_Approver_Contact__c = contactid;
                        approvalLog.Actual_Approver__c = userId;
                        approvalLog.Quote__c = quoteId;
                        approvalLog.Status__c = quoteStatus;
                        approvalLog.Approval_Comments__c = comments;
                        approvalLog.Decision_Date_Time__c = DateTime.now();
                        approvalLogList.add(approvalLog);
        //system.debug('approvalLogList--->'+ approvalLogList);
        return approvalLogList;
    
    }   

    public static List<Approval_log__c> createApprovalLogEmailtoCaseAutoApproval(String quoteId, String caseId, String userId, String contactEmail,String contactid, String quoteStatus,String comments, String businesRuleID)
    {
        List<Approval_log__c> approvalLogList = new List<Approval_log__c>();
        //system.debug('quoteId-'+quoteId + 'CaseId-'+caseId+ 'userId-'+userId+ 'contactEmail-'+contactEmail+ 'contactid-'+contactid+ 'quoteStatus-'+quoteStatus+ 'comment-'+comments + 'businesRuleID-'+businesRuleID);
        Approval_log__c approvalLog = new Approval_log__c();
                        approvalLog.CaseId__c = caseId;
                        approvalLog.BusinessRuleId__c = businesRuleID; 
                        approvalLog.Approval_Description__c = comments + ' from ' + 'Case Supplied Email.';
                        approvalLog.Actual_Approver_Contact__c = contactid;
                        approvalLog.Approval_source__c = 'eMail';
                        approvalLog.Actual_Approver_Email__c = contactEmail;
                        approvalLog.Quote__c = quoteId;
                        approvalLog.Status__c = quoteStatus;
                        approvalLog.Approval_Comments__c = comments;
                        approvalLog.Decision_Date_Time__c = DateTime.now();
                        approvalLogList.add(approvalLog);
        //system.debug('approvalLogList--->'+ approvalLogList);
        return approvalLogList;
    }

    //Changes for SDT-24509 Approvl log for Email Approver email is linked to Contact Email. 
    public static List<Approval_log__c> createApprovalLog_EmailTypeAutoApproval(String quoteId, String caseId, String userId, String contactEmail,String contactid, String quoteStatus,String comments, String businesRuleID)
    {
        List<Approval_log__c> approvalLogList = new List<Approval_log__c>();
        //system.debug('quoteId-'+quoteId + 'CaseId-'+caseId+ 'userId-'+userId+ 'contactEmail-'+contactEmail+ 'contactid-'+contactid+ 'quoteStatus-'+quoteStatus+ 'comment-'+comments + 'businesRuleID-'+businesRuleID);
        Approval_log__c approvalLog = new Approval_log__c();
                        approvalLog.CaseId__c = caseId;
                        approvalLog.BusinessRuleId__c = businesRuleID; 
                        approvalLog.Approval_Description__c = comments + ' from ' + 'Email Approver.';
                        approvalLog.Actual_Approver_Contact__c = contactid;
                        approvalLog.Approval_source__c = 'Email Approver';
                        approvalLog.Actual_Approver_Email__c = contactEmail;
                        approvalLog.Quote__c = quoteId;
                        approvalLog.Status__c = quoteStatus;
                        approvalLog.Approval_Comments__c = comments;
                        approvalLog.Decision_Date_Time__c = DateTime.now();
                        approvalLogList.add(approvalLog);
        //system.debug('approvalLogList--->'+ approvalLogList);
        return approvalLogList;
    }
      
        //Approval log Creation for Contact Email, Title and Department
    public static List<Approval_log__c> createApprovalLogForTitleContactAndDepartment(String recordTypeName,String quoteId, String caseId, String titleORDepartmentORContact, String contactEmail,String contactid, String quoteStatus,String comments, String businesRuleID){
        If(!businesRuleID.equalsIgnoreCase(NBR)){   
        //Changes for SDT-30717
         List<Approval_log__c> approvalLogList = new List<Approval_log__c>();
         Approval_log__c approvalLog = new Approval_log__c();
         approvalLog.CaseId__c = caseId;
         approvalLog.BusinessRuleId__c = businesRuleID; 
         approvalLog.Approval_Comments__c = comments;
         approvalLog.Actual_Approver_Contact__c = contactid;
         approvalLog.Quote__c = quoteId;
         approvalLog.Status__c = quoteStatus;
         approvalLog.Decision_Date_Time__c = DateTime.now();

        if(recordTypeName == Constant_Util.SERVICE_TITLE_RECORDTYPE){
            System.debug('>>>createApprovalLogForTitleContactAndDepartment Title Entry');
            approvalLog.Approval_Description__c = comments + ' from Title Approver';
            approvalLog.Actual_Approver_Title__c = titleORDepartmentORContact;
        }
        else if(recordTypeName == Constant_Util.SERVICE_DEPARTMENT_RECORDTYPE){
            approvalLog.Approval_Description__c = comments + ' from Department Approver';
            approvalLog.Actual_Approver_Title__c = titleORDepartmentORContact;
        }
        else if(recordTypeName == Constant_Util.SERVICE_CONTACT_RECORDTYPE){
            approvalLog.Approval_Description__c = comments + ' from Contact Approver';            
        }
        approvalLogList.add(approvalLog);
        return approvalLogList;
        }else{
            return new List<Approval_log__c>();
        }
    }   
   
    //24002 - Quote Status Approved - As in Auto Approved Condition 
    public  SBQQ__Quote__c getQuoteApproved (Id quoteId, Id bRuleId){
        //System.debug ('quoteRec--->'+ quoteId + 'BrId--' +bRuleId);
        SBQQ__Quote__c quoteRec = new SBQQ__Quote__c();
        quoteRec.id = quoteId;
        quoteRec.SBQQ__Status__c = 'Approved';
        quoteRec.Business_Rule__c = bRuleId;
        return quoteRec;
    }
  
    //SDT-25591 Method created to stop duplication.
    public void setMapOfQuoteToUpdate(SBQQ__Quote__c quote,Map<Id,SBQQ__Quote__c> mapOfQuoteToUpdate){
      SBQQ__Quote__c existingQuote= mapOfQuoteToUpdate.get(quote.Id);
      if(existingQuote== null){          
          mapOfQuoteToUpdate.put(quote.Id,quote);
      }
    }
    
    public List<SBQQ__Quote__c> getMapOfQuoteToUpdate(Map<Id,SBQQ__Quote__c> mapOfQuoteToUpdate){
        return mapOfQuoteToUpdate.values();
    }
    
    // Description : To build priority conditions based on custom metadata type.
    public Map<String, Map<string, Map<decimal, String>>> constructPriorityConditions( Map<Id, Map<String,List<SBQQ__QuoteLine__c>>> mSplitQuoteLines,Map<Id, SBQQ__Quote__c> mnewQuote)
    {
        // Changes for SDT-30717
        Quote_Approval_Priority_Setting__mdt[] lApprovalSettings = getQuoteApprovalPrioritysSetting();
        Map<string, string> mduration = new Map<string,string>();
        mduration.put('TEMP','Temporary');
        mduration.put('PERM','Permanent');
        mduration.put('SEAS','Seasonal');
        Map<String, Map<string, Map<decimal, String>>> mQuoteDurationPriorityCondition = new Map<String, Map<string, Map<decimal, String>>>();
        for(String idQuote : mSplitQuoteLines.keyset()){
            SBQQ__Quote__c objQuote = mnewQuote.get(idQuote);
            if(mSplitQuoteLines.get(idQuote) != null){
                Map<String,  Map<decimal, String>> mdurationPriorityCondition = new Map<String,  Map<decimal, String>>();
                for(String duration : mSplitQuoteLines.get(idQuote).keyset()){
                    Map<decimal, String> mPriorityCondition = new Map<decimal, string>();
                    // Changes for SDT-30717
                    Map<string, string> mConditionFieldValueMap = new Map<string,string>();
                    for(Quote_Approval_Priority_Setting__mdt mdtRec : lApprovalSettings){
                        string dot = '\\.';
                        String sourceField = String.valueOf(mdtRec.Source_API_Field__c);
                        //System.debug('sourceField==='+sourceField);
                        integer length = sourceField.split(dot).size();
                        integer counter = 1;
                        sObject sObj = objQuote;
                        String finalval = '';
                        for(String apiName : sourceField.split(dot)){
                         //System.debug('apiName==='+apiName);
                            if(counter == length){
                                finalval = (string)sObj.get(apiName.trim());
                            }
                            else {
                                sObj = sObj.getSobject(apiName);
                            } 
                            counter =  counter + 1;
                        }
                        if(finalval == null){
                            finalval = '';
                        }
                        String categoryType =null;
                        if(sourceField.contains('Location_Type__c')){
                            categoryType = ' AND Category_Type__c=\'Location Type\'' ;
                        }
                        if(sourceField.contains('Geography__c')){
                            categoryType = ' AND Category_Type__c=\'Geography\'' ;
                        }
                        if(sourceField.contains('Brand__c')){
                            categoryType = ' AND Category_Type__c=\'Brand\'' ;
                        }
                        if(sourceField.contains('Division__c')){
                            categoryType = ' AND Category_Type__c=\'Division/Department\'' ;
                        }
                       /* if(mdtRec.Priority__c == 11 || mdtRec.Priority__c ==12){
                           categoryType = ' AND Category_Type__c=\'\'' ;
                        }*/
                        if(mdtRec.Priority__c == 11 || mdtRec.Priority__c ==12 ){
                           categoryType = ' AND Category_Type__c=\'\' AND LocationId__c=\'\' ' ;
                        }
                        
                        if(mPriorityCondition.containskey(mdtRec.Priority__c)){
                            string condition = ' AND '+mdtRec.Destination_API_Field__c+' = ' +'\''+ finalval +'\'';
                            string existingCondition = mPriorityCondition.get(mdtRec.Priority__c);
                            condition = existingCondition + condition;
                            if(categoryType !=null && !condition.contains('Category_Type__c')){
                                condition += categoryType;
                            }
                            mPriorityCondition.put(mdtRec.Priority__c,condition);
                        }
                        else{
                             string condition =null ;
                            condition = 'Active__c = true AND Service__c = '+'\'' + mduration.get(mSplitQuoteLines.get(idQuote).get(duration)[0].Duration__c)+'\''+' AND '+mdtRec.Destination_API_Field__c +' = '+'\''+ finalval +'\'';
                            if(categoryType !=null){
                                condition += categoryType;
                            } mPriorityCondition.put(mdtRec.Priority__c,condition);
                        }

                        // Setting up destination fields to be used in global BR query 
                        destinationFields.add(mdtRec.Destination_API_Field__c);

                        // Changes for SDT-30717 
                        if(mdtRec.Destination_API_Field__c != 'AccountId__c')
                        {
                            if(mPriorityFieldConditionMap.containskey(mdtRec.Priority__c)){
                                mConditionFieldValueMap= assignPriorityCategoryValues(sourceField, mdtRec.Destination_API_Field__c, finalval);
                                
                            }else{
                                    mConditionFieldValueMap = new Map<string,string>();    
                                    mConditionFieldValueMap= assignPriorityCategoryValues(sourceField, mdtRec.Destination_API_Field__c, finalval);
                            }
                            // Adding Destination field values
                            Map<string, string> mConditionDestimnationFieldValueMap = new Map<string, string>();
                            mConditionDestimnationFieldValueMap.put(mdtRec.Destination_API_Field__c,finalval);
                            List<Map<String, String>> existingValue = new List<Map<String, String>>();
                            if(mPriorityFieldConditionMap.containsKey(mdtRec.Priority__c))
                            {
                               existingValue= mPriorityFieldConditionMap.get(mdtRec.Priority__c);
                            }
                            else{
                                existingValue = new List<Map<String, String>>();
                                 // To add Location and Category for Priority 11 and 12
                                List<Map<String, String>> existingLocationCategoryValue =addCategoryTypeLocationforSpecificPriority(mdtRec.Priority__c);
                                // Checking if value present
                                if(existingLocationCategoryValue != null && !existingLocationCategoryValue.isEmpty())
                                {
                                    existingValue.addall(existingLocationCategoryValue);
                                }
                            }
                            // Checking if Category Filter present or not
                            if (mConditionFieldValueMap != null && !mConditionFieldValueMap.isEmpty()) {
                                existingValue.add(mConditionFieldValueMap);
                            }
                            existingValue.add(mConditionDestimnationFieldValueMap);
                            // To add Location and Category for Priority 11 and 12
                            //existingValue= addCategoryTypeLocationforSpecificPriority(mdtRec.Priority__c, existingValue);
                            mPriorityFieldConditionMap.put(mdtRec.Priority__c, existingValue);
                            
                        }
                        //End 
                    }
                    //System.debug('mPriorityCondition===='+mPriorityCondition);
                    mdurationPriorityCondition.put(duration,mPriorityCondition);
                    //System.debug('mConditionFieldValueMap===='+mConditionFieldValueMap);
                    //System.debug('mPriorityFieldConditionMap===='+mPriorityFieldConditionMap);
                }
                mQuoteDurationPriorityCondition.put(idQuote,mdurationPriorityCondition);
            }
        }
        //System.debug('mQuoteDurationPriorityCondition===='+mQuoteDurationPriorityCondition);
        return mQuoteDurationPriorityCondition;
    }

    // Method to add Location and Category for Priority 11 and 12
    private List<Map<String, String>> addCategoryTypeLocationforSpecificPriority(Decimal priority)
    {
        List<Map<String, String>> existingValue = new List<Map<String, String>>();
        if(priority == 11 || priority ==12 ){
            existingValue.add( new Map<String, String>{'Category_Type__c' => ''});
            existingValue.add(new Map<String, String>{'LocationId__c'=>''});
        }
        return existingValue;
    }
    
    // Description : To get business rule and service approvers.
    public Map<String, List<String>> getBusinessRuleApprovers(Map<decimal,String>  mPriorityCondition,SBQQ__Quote__c newQuote, List<SBQQ__QuoteLine__c> listQuotelines)
    {
        //Changes for SDT-30717
        String caseNumber = newQuote.Case_Number__c;
        Id userId = userinfo.getUserId();
        List<EmailMessage> lstEmailMsg = [select id,FromAddress from EmailMessage where ParentId =: newQuote.SBQQ__Opportunity2__r.Case__c];
        List<User> userDetails = new List<User>();
        User emailMsgUser = new User(); 
        User caseUser = new User();
        User quoteUser = new User();
        User loggedInUser = new User();
        Map<String, List<String>> mbusinessRules = new Map<String, List<String>>();
        //Changes for SDT-30717
        String approvalRecordType = 'Approval'; 
        String caseType = newQuote.Case_Type__c;
        //SDT 41544
        Boolean IsHaulAwayService = newQuote.SBQQ__Opportunity2__r.Case__r.Is_Haul_Away_Service__c;
        List<Business_Rule__c> lbusinessRules = new List<Business_Rule__c>();
        
        // Test Logic START
        String locationId = newQuote.SBQQ__Account__c;
        String accountId = newQuote.SBQQ__Account__r.Parent.Id;
        String duration = newQuote.Duration__c; 
        //system.debug('Quotes Account >'+ accountId);
        //system.debug('Quotes duration >'+ duration);
        // to get the business rule by Priority Condition
        //SDT 41544 adding IsHaulAwayService parameter
        //Business_Rule__c businessRule = getBusinessRuleByPriority(approvalRecordType,caseType, accountId, duration, locationId,newQuote.SBQQ__Opportunity2__r.Case__c);
        Business_Rule__c businessRUle = getBusinessRuleByPriority(newQuote.Id);
        system.debug('businessRule > '+ businessRule);
        system.debug('listQuotelines vlaue > '+ listQuotelines);
       // system.debug('mapQDuration newQuote > '+ mapQuouteLines.get(newQuote.Duration__c));
        if(businessRule!=null){
            Boolean isSendAutoEmail = true;
            List<Service_Approver__c> srAppoverList = [Select Id,Service_Type__c,NTE_Amount__c,Business_Rule__r.NTE_Rules__c,Business_Rule__r.Is_Auto_Email__c,Business_Rule__r.No_Approval_Required__c from Service_Approver__c Where RecordType.Name = 'NTE Approval' AND Active__c = TRUE AND Business_Rule__c =: businessRule.Id ];//SDT-38003
            if(!srAppoverList.isEmpty() && srAppoverList.size() > 0 && !listQuotelines.isEmpty()){
                for(Service_Approver__c sr : srAppoverList){
                    system.debug('sr :: '+sr);
                    for(SBQQ__QuoteLine__c qLine: listQuotelines){
                        if(sr.Business_Rule__r.NTE_Rules__c && sr.Business_Rule__r.Is_Auto_Email__c && qLine.SBQQ__ProductName__c == sr.Service_Type__c && qLine.SBQQ__ListPrice__c > sr.NTE_Amount__c ){
                            system.debug('qLine :: '+qLine);
                            isSendAutoEmail = false;
                            system.debug('isSendAutoEmail :: '+isSendAutoEmail);
                        }
                        if(sr.Business_Rule__r.NTE_Rules__c && qLine.SBQQ__ProductName__c == sr.Service_Type__c && qLine.SBQQ__ListPrice__c > sr.NTE_Amount__c && !sr.Business_Rule__r.No_Approval_Required__c ){  //SDT-38003
                            isNTEbusinessRule =true;
                        }
                    }
                }
            }
            system.debug('conditon isSendAutoEmail :: '+isSendAutoEmail);
            if(!isSendAutoEmail){
                mbusinessRules.put(businessRule.Id,null);
                return mbusinessRules;
            }
            else if(isSendAutoEmail){
                lbusinessRules.add(businessRule);
            }
            
        }
        //system.debug('lbusinessRules Size > '+ lbusinessRules.size());
        // Logic END
        
        if(lbusinessRules.size()> 0){
            List<String> toAddresses = new List<String>();
            List<Service_Approver__c> lserviceApprovers = [SELECT id,Email__c,Account__c,Recordtype.Name,Business_Rule__c,Approver_Contact__c,Title__c,Department__c,Account_Department__c,Account_Title__c,User__c,Approver_Email__c, Origin__c,Requester_Only__c 
                                                           FROM Service_Approver__c 
                                                           WHERE (Recordtype.Name = 'Contact' OR 
                                                              Recordtype.Name = 'User' OR 
                                                              Recordtype.Name = 'Title' OR 
                                                              Recordtype.Name = 'Email' OR 
                                                              Recordtype.Name = 'Department' OR 
                                                              Recordtype.Name = 'Origin') 
                                                           AND Active__c = TRUE AND Business_Rule__c =:lbusinessRules[0].Id];  
           //Changes for SDT-30717 
           List<Contact> contacts= new List<Contact>();
           if(lserviceApprovers.size()>0)
           {
                //Changes for SDT-30717
                Set<Id> contactServiceApprovers = new Set<Id>();
                for(Service_Approver__c sApprover :lserviceApprovers)
                {
                    if(sApprover.Recordtype.Name == Constant_Util.SERVICE_CONTACT_RECORDTYPE)
                    {
                        contactServiceApprovers.add(sApprover.Approver_Contact__c);
                    }
                }

                //Changes for SDT-30717
                contacts= getContacts(newQuote.SBQQ__PrimaryContact__c, contactServiceApprovers, newQuote.SBQQ__Opportunity2__r.Case__r.ContactId);
                // To get all internal userId
                Set<Id> internalUserIds = new Set<Id>();
                for(Contact con : contacts)
                {
                    if(con.Internal_User_ID__c != null)
                    {
                        internalUserIds.add(con.Internal_User_ID__c); 
                    }
                }
                
                userDetails =getUserDetails(userId, newQuote.SBQQ__Opportunity2__r.Case__r.CreatedById, newQuote.CreatedById, lstEmailMsg, internalUserIds);
                String fromEmail='';
                if(lstEmailMsg != Null && !lstEmailMsg.isEmpty())
                {
                    fromEmail = lstEmailMsg[0].FromAddress;
                }
                if(userDetails != null && !userDetails.isEmpty())
                {
                    for(User usr: userDetails)
                    {
                        // Identifing Case User
                        if(usr.Id == newQuote.SBQQ__Opportunity2__r.Case__r.CreatedById)
                        {
                            caseUser = usr;
                        }
                        // Identifing Quote User
                        if(usr.Id == newQuote.CreatedById)
                        {
                            quoteUser = usr;
                        }
                        // Identifing Logged-In User
                        if(usr.Id == userId)
                        {
                            loggedInUser = usr;
                        }
                        // Identifing from email user
                        if(usr.email == fromEmail)
                        {
                            emailMsgUser = usr;
                        }
                    }
                }

                mapBRuleAutoEmail.put(lbusinessRules[0].Id, lbusinessRules[0].Is_Auto_Email__c);
                for(Service_Approver__c sApprover :lserviceApprovers)
                {
                    approverTypeMap.put(Constant_Util.FLOW_BUSINESSRULEREC, lbusinessRules[0].Id);
                
                    //system.debug('newQuote.SBQQ__PrimaryContact__c title>'+ newQuote.SBQQ__PrimaryContact__c);
                    if(sApprover.Recordtype.Name == Constant_Util.SERVICE_DEPARTMENT_RECORDTYPE ){
                        //Changes for SDT-30717
                        for(Contact oContact :contacts)
                        {
                            //Changes for SDT-30717
                            if(oContact.AccountId == sApprover.Account__c && oContact.Account_Department__c ==sApprover.Department__c && oContact.Account_Department__c != null && oContact.Account_Department__c == newQuote.SBQQ__PrimaryContact__r.Account_Department__c)
                            {
                                //SDT-25968
                                mbusinessRules.put(NBR,null);
                                //end of SDT-25968
                            
                                //Condition done for SDT-24198
                                if(sApprover.Requester_Only__c){
                                    requesterOnlylst.add(oContact.Email);
                                    requestorOnlyMap.put('RequestOnly',lbusinessRules[0].Id+Constant_Util.COLON+newQuote.SBQQ__Opportunity2__r.Case__r.Id +Constant_Util.COLON + sApprover.Id);
                                }
                                //END
                                approverTypeMap.put(oContact.Email, Constant_Util.SERVICE_DEPARTMENT_RECORDTYPE+Constant_Util.COLON+sApprover.Account_Department__c); 

                                isDepartmentRecordType = true;
                                toAddresses.clear();
                                break;
                            }  
                        }
                    }
                    else if(sApprover.Recordtype.Name == Constant_Util.SERVICE_TITLE_RECORDTYPE ){
                        //Changes for SDT-30717
                        for(Contact oContact : contacts)
                        {
                            //Changes for SDT-30717
                            if(oContact.Account_Title__c == sApprover.Title__c && oContact.Account_Title__c != null && oContact.Account_Title__c == newQuote.SBQQ__PrimaryContact__r.Account_Title__c) 
                            {
                                //system.debug('title added--->'+ oContact.Email);
                                //SDT-25968
                                mbusinessRules.put(NBR,null);
                                //End of SDT-25968
                                
                                //Condition done for story SDT-24198 
                                if(sApprover.Requester_Only__c){
                                // requesterOnlylst.add(oContact.Email);
                                    requestorOnlyMap.put('RequestOnly',lbusinessRules[0].Id+Constant_Util.COLON+newQuote.SBQQ__Opportunity2__r.Case__r.Id +Constant_Util.COLON + sApprover.Id);
                                }
                                //END
                                approverTypeMap.put(oContact.Email, Constant_Util.SERVICE_TITLE_RECORDTYPE+Constant_Util.COLON+sApprover.Account_Title__c); 

                                isTitleRecordType = true;
                                toAddresses.clear();
                                break;   
                            }  
                        }
                    }
                    else if(sApprover.Recordtype.Name == Constant_Util.SERVICE_CONTACT_RECORDTYPE){
                        //system.debug('sApprover.Approver_Contact__c >'+ sApprover.Approver_Contact__c);
                        //Changes for SDT-30717
                        for(Contact oContact : contacts)
                        {
                            //SDT-24757
                            //Changes for SDT-30717
                            if(oContact.Id == sApprover.Approver_Contact__c &&  oContact.Email != null && newQuote.SBQQ__PrimaryContact__c == oContact.Id ){
                                approverTypeMap.put(oContact.Email, Constant_Util.SERVICE_CONTACT_RECORDTYPE+Constant_Util.COLON+oContact.Id);   
                                isContactRecordType = true;     
                            } 
                            else if(oContact.Id == sApprover.Approver_Contact__c && newQuote.SBQQ__PrimaryContact__c == oContact.Id ) {
                                mbusinessRules.put(NBR,null);
                                isContactRecordType = true; 
                                toAddresses.clear(); 
                                break;
                            }
                        }
                    } 
                    else if(sApprover.Recordtype.Name == Constant_Util.SERVICE_USER_RECORDTYPE ){
                        approverTypeMap.put(sApprover.Approver_Email__c, Constant_Util.SERVICE_USER_RECORDTYPE+Constant_Util.COLON+sApprover.User__c);
                    }
                    //Changes for SDT-25592
                    else if(sApprover.Recordtype.Name == Constant_Util.SERVICE_EMAIL_RECORDTYPE ){
                        approverTypeMap.put(sApprover.Approver_Email__c, Constant_Util.SERVICE_EMAIL_RECORDTYPE+Constant_Util.COLON+sApprover.User__c);
                    }
                    // Changes for story SDT-24197
                    else if(sApprover.Recordtype.Name == Constant_Util.ORIGIN ){
                        // if Record Type is Origin then match Case Origin and Service Approver Origin
                        if(sApprover.Origin__c == newQuote.SBQQ__Opportunity2__r.Case__r.Origin)
                        {
                            //system.debug('sApprover.Recordtype.Name--->'+sApprover.Recordtype.Name);
                            approverTypeMap.put(Constant_Util.ORIGIN, newQuote.SBQQ__Opportunity2__r.Case__r.Origin +Constant_Util.COLON + newQuote.SBQQ__Opportunity2__r.Case__r.Id +Constant_Util.COLON + lbusinessRules[0].Id);
                            //system.debug('approverTypeMap--->'+approverTypeMap);
                            toAddresses.add(Constant_Util.ORIGIN);
                        }
                        //system.debug('lbusinessRules[0].Id #1>>'+ lbusinessRules[0].Id);
                    }
                    if(sApprover.Approver_Email__c != null){
                        toAddresses.add(sApprover.Approver_Email__c);
                        //Condition added for SDT-24198
                        if(sApprover.Requester_Only__c ){
                            requesterOnlylst.add(sApprover.Approver_Email__c);
                            requestorOnlyMap.put('RequestOnly',lbusinessRules[0].Id+Constant_Util.COLON+newQuote.SBQQ__Opportunity2__r.Case__r.Id +Constant_Util.COLON + sApprover.Id);
                        }
                        //END
                    }
                }
            }  
            
            if(toAddresses != null && toAddresses.size() > 0 ){
                // if addresses contains 'Origin' Changes for story SDT-24197
                if(toAddresses.contains(Constant_Util.ORIGIN))
                {
                    mbusinessRules.put(NBR,null);
                }
                // changes done for story SDT-24198
                else if(requesterOnlylst.size() > 0 && lserviceApprovers.size()>0 && requesterOnlylst.size() == lserviceApprovers.size()){

                    isRequestorOnly = true;
                    mbusinessRules.put(lbusinessRules[0].Id,toAddresses);
                }
                //END
                else{
                    mbusinessRules.put(lbusinessRules[0].Id,toAddresses);
                }
            }
            else{    
                mbusinessRules.put(lbusinessRules[0].Id,null);
            }
            //SDT-24196 
            //Part 1- If LoggedIn User has following profiles or Roles, Quote will be AutoApproved.
            if(loggedInUser.Profile.Name == 'Customer Account Team' || loggedInUser.UserRole.Name == 'Program Manager' || loggedInUser.UserRole.Name == 'National Account Manager' || loggedInUser.title == 'Corporate Services Specialist')
            {                   
                mbusinessRules.clear(); 
                approverTypeMap.clear(); 
                mbusinessRules.put(NBR,null);
                approverTypeMap.put(Constant_Util.ROLEPROFILE, newQuote.Id +Constant_Util.COLON +loggedInUser.Id+Constant_Util.COLON+'');
            }  
            //SDT-24760 - Auto Approve if Created by(User) of Case is having following profiles. 
            else if(caseUser.Profile.Name == 'Customer Account Team' || (caseUser.UserRole != null && (caseUser.UserRole.Name == 'Program Manager' || caseUser.UserRole.Name == 'National Account Manager')) || (caseUser.title != null && caseUser.title == 'Corporate Services Specialist'))
            {
                mbusinessRules.clear(); 
                approverTypeMap.clear(); 
                mbusinessRules.put(NBR,null);
                approverTypeMap.put(Constant_Util.ROLEPROFILE, newQuote.Id +Constant_Util.COLON +caseUser.Id+Constant_Util.COLON+'');
            }
            //SDT-24760 - Auto Approve if Created by(User) of Quote is having following profiles.
            else if(quoteUser.Profile.Name == 'Customer Account Team' || (quoteUser.UserRole != null && (quoteUser.UserRole.Name == 'Program Manager' || quoteUser.UserRole.Name == 'National Account Manager')) || (quoteUser.title != null && quoteUser.title == 'Corporate Services Specialist'))
            {
                mbusinessRules.clear(); 
                approverTypeMap.clear(); 
                mbusinessRules.put(NBR,null);
                approverTypeMap.put(Constant_Util.ROLEPROFILE, newQuote.Id +Constant_Util.COLON +quoteUser.Id+Constant_Util.COLON+'');
            }
        
            //Part 2- If Loggedin User is having profile as Customer Service and Internal User of Contact(associated with Case) is having following Roles/Profiles.  
            else if(loggedInUser.Profile.Name == 'Customer Service'){
                //Changes for SDT-30717
                Contact con = new Contact();
                for(Contact oContact : contacts)
                {
                    // Identifing Case Contact
                    if(oContact.Id == newQuote.SBQQ__Opportunity2__r.Case__r.ContactId)
                    {
                        con=oContact;
                    }
                }
                //Contact con = [select id,Internal_User_ID__c from contact where id =: caseRecord.ContactId limit 1];
                if(con!=null && null != con.Internal_User_ID__c){
                    //Changes for SDT-30717
                    User conDetails = new User();
                    for(User usr: userDetails)
                    {
                        // Identifing internal User
                        if(usr.Id == con.Internal_User_ID__c)
                        {
                            conDetails = usr;
                            break;
                        }
                    }
                    //User conDetails = [Select Id,title,  Profile.Name, UserRole.Name from user where id =: con.Internal_User_ID__c];
                    if(conDetails != null && (conDetails.Profile.Name == 'Customer Account Team' || (conDetails.UserRole != null && (conDetails.UserRole.Name == 'Program Manager' || conDetails.UserRole.Name == 'National Account Manager')) || (conDetails.title != null && conDetails.title == 'Corporate Services Specialist'))){
                        mbusinessRules.clear();
                        approverTypeMap.clear(); 
                        mbusinessRules.put(NBR,null);
                        approverTypeMap.put(Constant_Util.ROLEPROFILE, newQuote.Id +Constant_Util.COLON +'' +Constant_Util.COLON +con.Id );
                    }
                }
             }
            //Part 3 - Case Origin is Email and User who sent email(for Case Creation) is having following Roles/Profile
            else if(!lstEmailMsg.isEmpty()){
                //Changes for SDT-30717
                User emailToCaseUser =emailMsgUser;
                    if(newQuote.SBQQ__Opportunity2__r.Case__r.Origin == 'Email' && (emailToCaseUser != null && (emailToCaseUser.Profile.Name == 'Customer Account Team' || (emailToCaseUser.UserRole != null && (emailToCaseUser.UserRole.Name == 'Program Manager' || emailToCaseUser.UserRole.Name == 'National Account Manager')) || (emailToCaseUser.title != null && emailToCaseUser.title == 'Corporate Services Specialist')))){
                        mbusinessRules.clear();   
                        approverTypeMap.clear();   
                        mbusinessRules.put(NBR,null);
                        approverTypeMap.put(Constant_Util.ROLEPROFILE, newQuote.Id +Constant_Util.COLON + emailToCaseUser.Id +Constant_Util.COLON +'');
                                                                                            
                }                           
            }       
            if(lbusinessRules[0].No_Approval_Required__c){
                mbusinessRules.clear();   
                approverTypeMap.clear();   
                mbusinessRules.put('NBR',null);
                approverTypeMap.put(Constant_Util.NO_APPROVAL,lbusinessRules[0].Id+Constant_Util.COLON+newQuote.SBQQ__Opportunity2__r.Case__r.Id+Constant_Util.COLON+newQuote.Id);                 
            }
            //system.debug('mbusinessRules :: >> : ' + mbusinessRules);
            return mbusinessRules;
        }
        else
        {
            mbusinessRules.put(NBR,null);
            //system.debug('NBR :: >> : ' + mbusinessRules);
            return mbusinessRules;
        }    
    }
    
    // Description : To Send Email to approvers.
    public static Messaging.SingleEmailMessage createEmailMessage(List<String> toAddresses, Id QuoteId){
        
        //SDT-24196 - Approval Logs for Manual Emails
        List<Approval_log__c> approvalLogLst = createApprovalLogForManualEmails(toAddresses,quoteId);
        approvallogcreation(approvalLogLst);
        //System.debug('@@approvalLogLst'+approvalLogLst);
        //Integer i=1/0;
        
        if(isApprovalLogCreated){
            //System.debug('###isApprovalLogCreated'+isApprovalLogCreated);

            // Changes for SDT-25549
            // get the from Email address from Organization-Wide From Email Address
            String orgWideAdd = SBQQQuoteService.getOrganizationWideFromEmailAddress(QuoteId);
        
           system.debug('orgWideAdd > '+ orgWideAdd);
            // Approval Logs logic  Ends
            EmailTemplate template = [SELECT Id FROM emailTemplate WHERE DeveloperName = 'Change_Service_Quote_Approval'];
            string emailTemplateId = template.Id;
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            Contact objContact = new Contact();
            List<Contact> lContacts = [Select Id from Contact Limit 1];
            if(!lContacts.isEmpty())
            {
                objContact = lContacts[0];
            }
            else 
            {
                objContact.LastName = 'Test Email Contact';
                objContact.Email = 'donotreply@ccemail.com';
                insert objContact;
            }
            mail.setTargetObjectId(objContact.Id); 
            mail.setOrgWideEmailAddressId(orgWideAdd);  
            mail.setTemplateId(emailTemplateId);
            mail.setToAddresses(toAddresses);
            mail.setWhatId(QuoteId);
            mail.setTreatTargetObjectAsRecipient(false);
            mail.setBccSender(false);
            mail.setUseSignature(false);
            mail.setSaveAsActivity(false);        
            mails.add(mail);     
            //system.debug('Logged in User>>'+  userinfo.getUserId());
           Messaging.SendEmailResult[] result=  Messaging.sendEmail(mails);
            //Making isApprovalLogCreated false once Email is sent as Email is to be sent only one and approval log is created .
            //Retry Mechanism to send email is not in place , so in an event when email delivery fails , approval log record would require to be deleted .
            if (result!= null && result.size() >0 && result[0].success) {
                // Integer y=1/0;
                isApprovalLogCreated = false;
                System.debug('The email was sent successfully.'+result[0].success);
                } else {
                    isApprovalLogCreated = true;         
                    }
            return mail;
        }
        else{
             //If there is no approval log  , then email will not be sent.
            return null;
        }
    }
    
    //SDT-24578 
    // We are using same Single Message instance because content is not specific to receipient. In case Template changes
    //based on receipient then code need to be modified accordingly.
    public static void attachEmailMessage(Messaging.SingleEmailMessage email,List<String> toAddresses, Id QuoteId){
       Id orgFromAddressId =email.getOrgWideEmailAddressId(); 
       Id userId = userinfo.getUserId();
       User userDetails =[SELECT Id,title,Email,Profile.Name, UserRole.Name FROM User where Id=:userId];
       OrgWideEmailAddress orgWideFromEmailAddress;
       if(orgFromAddressId != null)
            orgWideFromEmailAddress =[SELECT Id,Address,DisplayName FROM OrgWideEmailAddress WHERE Id=:orgFromAddressId];
        List<EmailMessage> lstemail = new List<EmailMessage>(); 
       
        //SDT-25584 - Will attach multiple Emails to Quote 
        if(email != null){
            for(String address : toAddresses){
            EmailMessage newMessage = new EmailMessage();
            newMessage.HtmlBody = email.htmlBody;
            newMessage.Status = '0';
            //Added from and to swapping for SDT-20201
            if(orgWideFromEmailAddress != null && !String.isEmpty(orgWideFromEmailAddress.Address))
                newMessage.FromAddress =orgWideFromEmailAddress.Address;
            else
                newMessage.FromAddress = userDetails.Email;
            newMessage.ToAddress = address;
            newMessage.Subject = email.subject; 
            newMessage.MessageDate = System.now();
            newMessage.RelatedToId = QuoteId;
            lstemail.add(newMessage);
            } 
            insert lstemail;
        }
    }
    
    //SDT-24199 Approval Log Data update and Insert. 
    public static void approvalLogCreation(List<Approval_log__c> approvalLogData){
        //System.debug('@@approvalLogData'+approvalLogData);
        if(approvalLogData.size()>0)
        {  
            List<Approval_log__c> approvalLogList = [Select Id, Status__c, CaseId__c, Quote__c, Quote__r.Id from Approval_Log__c Where Quote__c =:approvalLogData[0].Quote__c and Status__c ='Approval Requested'];
            List<Approval_log__c> approvalLogListToUpdate = new List<Approval_log__c>();  
            if(approvalLogList != null && approvalLogList.size()>0)
            {
                try{
                    for(Approval_log__c approvalLog : approvalLogData)
                    {
                        approvalLog.Id = approvalLogList[0].Id;
                        approvalLogListToUpdate.add(approvalLog);
                    }
                    //system.debug('approvalLogListToUpdate--->'+ approvalLogListToUpdate);
                    update approvalLogListToUpdate;
                    //system.debug('approvalLogListToUpdate--->'+ approvalLogListToUpdate);
                    } catch (exception e) {
                    system.debug(e.getMessage());  
                }       
            }
            else
            {
                //system.debug('approvalLogListToInsert--->'+ approvalLogData);
                insert approvalLogData;                   
                //SDT-25177 - Flag will be used while sending Approval Emails to avoid multiple emails.
                isApprovalLogCreated = true;
            }
        }
    }
    
     /* SDT-24196
     * Description : It handles creation of Approval Logs for Manual Emails
     * Created By : Shilpa Bhatia
    */
    public static List<Approval_log__c> createApprovalLogForManualEmails(List<String> lEmails, String quoteId){
        List<Approval_log__c> approvalLogList = new List<Approval_log__c>();
        if(lEmails != null && lEmails.size() > 0){
        for(String sEmail: lEmails){
            Approval_log__c approvalLog = new Approval_log__c();
            if(approverTypeMap.containsKey(sEmail))
            {
                String appoType = approverTypeMap.get(sEmail);
                List<String> splittedValue = appoType.split(Constant_Util.COLON);
                if(splittedValue[0] == Constant_Util.SERVICE_DEPARTMENT_RECORDTYPE)
                {
                    approvalLog.Required_Approver_Title__c = splittedValue[1];
                }
                else if(splittedValue[0] == Constant_Util.SERVICE_TITLE_RECORDTYPE)
                {
                    approvalLog.Required_Approver_Title__c = splittedValue[1];
                }
                else if(splittedValue[0] == Constant_Util.SERVICE_CONTACT_RECORDTYPE)
                {
                    approvalLog.Required_Approver_Contact__c = splittedValue[1];
                }
                else if(splittedValue[0] == Constant_Util.SERVICE_USER_RECORDTYPE)
                {
                    approvalLog.Required_Approver__c = splittedValue[1];
                }
            }
            approvalLog.Quote__c = QuoteId;
            approvalLog.Status__c = Constant_Util.APPROVAL_REQUESTED;
            approvalLog.Email__c = sEmail;
            approvalLog.Approval_Comments__c = Constant_Util.APPROVAL_PROCESS_INITIATED;
            if(mapQuoteWithBRule.containsKey(QuoteId))
            {
                approvalLog.BusinessRuleId__c = mapQuoteWithBRule.get(QuoteId); 
            }
            approvalLogList.add(approvalLog);
            }
        }
        return approvalLogList;
    }
    
     //SDT-24196 - Approval log Creation for Role/Profile
    public static List<Approval_log__c> createApprovalLogForRoleProfile(Id cseId){
        
        List<Approval_log__c> approvalLogList = new List<Approval_log__c>();
        Approval_log__c approvalLog = new Approval_log__c();
                
        approvalLog.Status__c = Constant_Util.APPROVED;
        approvalLog.Approval_Description__c = Constant_Util.APPROVAL_FROM_ROLE_PROFILE;
        approvalLog.Approval_Comments__c = Constant_Util.QUOTE_AUTO_APPROVED;
        if(approverTypeMap.containsKey(Constant_Util.ROLEPROFILE))
        {
            String roleProfilevalues = approverTypeMap.get(Constant_Util.ROLEPROFILE);
            if(String.isNotEmpty(roleProfilevalues))
            {
                List<String> parts = roleProfilevalues.split(Constant_Util.COLON);
                // System.debug('@@@parts'+parts);
                // System.debug('@@@parts size'+parts.size());
                
                // System.debug('@@@parts'+roleProfilevalues);
                approvalLog.Quote__c = parts[0];
                approvalLog.CaseId__c = cseId;
                
                if(parts[1] !=null && parts[1] !=''){
                    approvalLog.Required_Approver__c = parts[1];
                }
                
                if(parts.size()>2)
                {
                    //System.debug('@@@parts 2'+parts[2]);
                    if(parts[2] != null && parts[2] != '')
                    {
                        approvalLog.Required_Approver_Contact__c = parts[2];
                    }
                }
            }
        }
        //System.debug('@@@@approvalLog'+approvalLog);     
        approvalLogList.add(approvalLog);
        return approvalLogList;
    }
    
    //It handles creation of Approval Logs for Origin Story SDT-24199
    public static List<Approval_log__c> createApprovalLogForOrigin(String quoteId,String status, String comments){
        List<Approval_log__c> approvalLogList = new List<Approval_log__c>();
        Approval_log__c approvalLog = new Approval_log__c();
        //Changes for SDT-24199
        if(approverTypeMap.containsKey(Constant_Util.ORIGIN))
        {
            String originValues = approverTypeMap.get(Constant_Util.ORIGIN);
            if(String.isNotEmpty(originValues))
            {
                List<String> parts = originValues.split(Constant_Util.COLON);
                //System.debug('parts >'+ parts);
                if(parts !=null && parts.size()>1)
                {
                    approvalLog.Actual_Approver_Origin__c = parts[0];
                    approvalLog.CaseId__c = parts[1];
                    //System.debug('parts[2] >'+ parts[2]);
                    approvalLog.BusinessRuleId__c = parts[2]; 
                }
            }
            approvalLog.Approval_Description__c = comments + ' from ' + Constant_Util.ORIGIN;
        }
        approvalLog.Quote__c = QuoteId;
        approvalLog.Status__c = status;
        approvalLog.Approval_Comments__c = comments;
        approvalLog.Decision_Date_Time__c = DateTime.now();
        approvalLogList.add(approvalLog);
        return approvalLogList;
    }
    
     public static List<Approval_log__c> createApprovalLogForNoApproval(String quoteId,String status, String comments){
        List<Approval_log__c> approvalLogList = new List<Approval_log__c>();
        Approval_log__c approvalLog = new Approval_log__c();
        if(approverTypeMap.containsKey(Constant_Util.NO_APPROVAL))
        {
            String originValues = approverTypeMap.get(Constant_Util.NO_APPROVAL);
            if(String.isNotEmpty(originValues))
            {
                List<String> parts = originValues.split(Constant_Util.COLON);
                System.debug('parts >'+ parts);
                
                if(parts !=null && parts.size()>1)
                {
                    
                    approvalLog.CaseId__c = parts[1];
                    
                    approvalLog.BusinessRuleId__c = parts[0]; 
                }
            }
            approvalLog.Approval_Description__c = Constant_Util.NO_APPROVAL;
        }
        approvalLog.Quote__c = QuoteId;
        approvalLog.Status__c = status;
        approvalLog.Approval_Comments__c = comments;
        approvalLog.Decision_Date_Time__c = DateTime.now();
        approvalLogList.add(approvalLog);
        return approvalLogList;
    }

     
    //It handles creation of Approval Logs for Requestor Only
    public static List<Approval_log__c> createApprovalLogForRequestorOnly(List<String> lEmails, String quoteId, String status, String comments, String contactEmail){
        List<Approval_log__c> approvalLogList = new List<Approval_log__c>();
          if(lEmails != null && lEmails.size() > 0){
            for(String sEmail: lEmails){
                Approval_log__c approvalLog = new Approval_log__c();
                approvalLog.Quote__c = QuoteId;
                approvalLog.Approval_Description__c = comments + ' from Requestor Only';
                approvalLog.Approval_source__c=sEmail;
                approvalLog.Decision_Date_Time__c = DateTime.now();
                approvalLog.Email__c = contactEmail;
                approvalLog.Status__c = status;
                approvalLog.Actual_Approver_Email__c=contactEmail;
                approvalLog.Approval_Comments__c = comments;

                if(requestorOnlyMap.containsKey('RequestOnly'))
                {
                    String originValues = requestorOnlyMap.get('RequestOnly');
                    if(String.isNotEmpty(originValues))
                    {
                        List<String> parts = originValues.split(Constant_Util.COLON);
                        System.debug('parts >'+ parts);
                        if(parts !=null && parts.size()>1)
                        {
                            approvalLog.BusinessRuleId__c = parts[0]; 
                            approvalLog.CaseId__c = parts[1];
                            approvalLog.Service_Approvers__c=parts[2];
                        }
                    }
                }
                approvalLogList.add(approvalLog);
            }
        }
        return approvalLogList;
    }
    
    //SDT-24196
    // Description : Create Inbound Approval Log - It handles Approval log creation for Approvals Email Reply
    public static void createInboundApprovalLog(List<String> lEmails, String QuoteId, String Status, String Comments, String businessRuleId){
        Map<String,String> approverTypeInboundMap = new Map<String,String>();
        List<Service_Approver__c> lserviceApprovers = [SELECT id,Email__c,Account__c,Recordtype.Name,Business_Rule__c,Approver_Contact__c,Title__c,Department__c,Account_Department__c,Account_Title__c,User__c,Approver_Email__c 
                                                       FROM Service_Approver__c 
                                                       WHERE (Recordtype.Name =: Constant_Util.SERVICE_CONTACT_RECORDTYPE OR 
                                                              Recordtype.Name =: Constant_Util.SERVICE_USER_RECORDTYPE OR 
                                                              Recordtype.Name =: Constant_Util.SERVICE_TITLE_RECORDTYPE OR 
                                                              Recordtype.Name =: Constant_Util.SERVICE_EMAIL_RECORDTYPE OR 
                                                              Recordtype.Name =: Constant_Util.SERVICE_DEPARTMENT_RECORDTYPE) AND Active__c = TRUE AND Business_Rule__c =:businessRuleId];
        // Changes for SDT-30717
        Set<Id> accountIds = new Set<Id>();
        Set<Id> tittleIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
        for(Service_Approver__c sApprover :lserviceApprovers){
            if(sApprover.Recordtype.Name == Constant_Util.SERVICE_DEPARTMENT_RECORDTYPE){
                accountIds.add(sApprover.Account__c);
            }
            else if(sApprover.Recordtype.Name == Constant_Util.SERVICE_TITLE_RECORDTYPE){
                tittleIds.add(sApprover.Title__c);
            }
            else if(sApprover.Recordtype.Name == Constant_Util.SERVICE_CONTACT_RECORDTYPE){
                contactIds.add(sApprover.Approver_Contact__c);
            }
        }
        List<Contact> contacts = [Select Id,Email,Account_Title__c,AccountId from Contact where AccountId =: accountIds OR Account_Title__c=: tittleIds OR Id =:contactIds]; 
        for(Service_Approver__c sApprover :lserviceApprovers){
            if(sApprover.Recordtype.Name == Constant_Util.SERVICE_DEPARTMENT_RECORDTYPE){
                // Changes for SDT-30717
                for(Contact oContact : contacts){
                    if(oContact.Email != null && oContact.AccountId != null && sApprover.Account__c!= null && oContact.AccountId == sApprover.Account__c)
                    {
                        approverTypeInboundMap.put(oContact.Email, Constant_Util.SERVICE_DEPARTMENT_RECORDTYPE+Constant_Util.COLON+sApprover.Account_Department__c);
                    }
                }
            }
            else if(sApprover.Recordtype.Name == Constant_Util.SERVICE_TITLE_RECORDTYPE){
                // Changes for SDT-30717
                for(Contact oContact : contacts){
                    if(oContact.Email != null && oContact.Account_Title__c != null && sApprover.Title__c != null && oContact.Account_Title__c == sApprover.Title__c)
                    {
                        approverTypeInboundMap.put(oContact.Email, Constant_Util.SERVICE_TITLE_RECORDTYPE+Constant_Util.COLON+sApprover.Account_Title__c);
                    } 
                }
            }
            else if(sApprover.Recordtype.Name == Constant_Util.SERVICE_CONTACT_RECORDTYPE){
                // Changes for SDT-30717
                for(Contact oContact : contacts){
                    
                    if(oContact.Email != null && sApprover.Approver_Contact__c != null && oContact.id == sApprover.Approver_Contact__c)
                        approverTypeInboundMap.put(oContact.Email, Constant_Util.SERVICE_CONTACT_RECORDTYPE+Constant_Util.COLON+oContact.Id);       
                }                    
            }
            else if(sApprover.Recordtype.Name == Constant_Util.SERVICE_USER_RECORDTYPE){
                approverTypeInboundMap.put(sApprover.Approver_Email__c, Constant_Util.SERVICE_USER_RECORDTYPE+Constant_Util.COLON+sApprover.User__c);
            }
        }
        List<Approval_log__c> approvalLogList = new List<Approval_log__c>();
        List<Approval_log__c> approvalLogs = new List<Approval_log__c>();
        List<Approval_log__c> approvalLogListToUpdate = new List<Approval_log__c>();
        if(lEmails != null && lEmails.size() > 0){
            for(String sEmail: lEmails){
                Approval_log__c approvalLog = new Approval_log__c();
                if(approverTypeInboundMap.containsKey(sEmail))
                {
                    String appoType = approverTypeInboundMap.get(sEmail);
                    List<String> splittedValue = appoType.split(Constant_Util.COLON);
                    if(splittedValue[0] == Constant_Util.SERVICE_DEPARTMENT_RECORDTYPE)
                    {
                        approvalLog.Actual_Approver_Title__c = splittedValue[1];
                    }
                    else if(splittedValue[0] == Constant_Util.SERVICE_TITLE_RECORDTYPE)
                    {
                        approvalLog.Actual_Approver_Title__c = splittedValue[1];
                    }
                    else if(splittedValue[0] == Constant_Util.SERVICE_CONTACT_RECORDTYPE)
                    {
                        approvalLog.Actual_Approver_Contact__c = splittedValue[1];
                    }
                    else if(splittedValue[0] == Constant_Util.SERVICE_USER_RECORDTYPE)
                    {
                        approvalLog.Actual_Approver__c = splittedValue[1];
                    }
                }
                approvalLog.Quote__c = QuoteId;
                approvalLog.Status__c = status;
                approvalLog.Actual_Approver_Email__c = sEmail; 
                approvalLog.Approval_Comments__c = Comments;
                approvalLog.BusinessRuleId__c = businessRuleId;
                approvalLogList.add(approvalLog);
                approvalLogs = [Select Id, Status__c, CaseId__c, Quote__c, Quote__r.Id from Approval_Log__c Where Quote__c =:approvalLogList[0].Quote__c and Status__c ='Approval Requested' AND Email__c=:sEmail];
            }
            //SDT-24196 - Approval Log Creation for Emails Reply(Approve/Reject)
            //Comennted by Chandu kari for the SDT-49972
            //approvalLogCreation(approvalLogList);
            if(approvalLogList.size()>0){
                if(approvalLogList != null && approvalLogList.size()>0){
                    try{
                    for(Approval_log__c approvalLog : approvalLogList)
                    {
                        approvalLog.Id = approvalLogs[0].Id;
                        approvalLogListToUpdate.add(approvalLog);
                    }
                    //system.debug('approvalLogListToUpdate--->'+ approvalLogListToUpdate);
                    update approvalLogListToUpdate;
                    //system.debug('approvalLogListToUpdate--->'+ approvalLogListToUpdate);
                } catch (exception e) {
                    system.debug(e.getMessage());  
                }
                }
            }
        } 
    }
    // Changes for SDT-30717
    //Method to get Opportunities by OpportunityId
    private static List<Opportunity> getOpportunitiesByIds(Set<Id> sOppIds)
    {
        //Variables
        List<String> accessibleFields = new List<String>();

        //Fetching all the opportunity fields 
        List<String> lfields = new List<String>(Schema.getGlobalDescribe().get('opportunity').getDescribe().fields.getMap().keySet());
        Map<String, SObjectField> fields = Schema.getGlobalDescribe().get('opportunity').getDescribe().fields.getMap();
        for(String field : lfields){
        if(fields.get(field).getDescribe().isAccessible())
            accessibleFields.add(field.trim());
        }

        //Fetching all the opportunity records
        String query  = 'SELECT '+String.join(accessibleFields, ',')+' FROM '+'Opportunity WHERE Id IN: sOppIds';
        return database.query(query);
    }

    // Changes for SDT-30717
    // Method to get Quote Approval Priority Settings
    private static Quote_Approval_Priority_Setting__mdt[] getQuoteApprovalPrioritysSetting()
    {
        return [SELECT MasterLabel,Source_API_Field__c, Destination_API_Field__c,Priority__c,Is_Deactivated__c 
        FROM Quote_Approval_Priority_Setting__mdt 
        WHERE Is_Deactivated__c =false ORDER BY Priority__c ASC];
    }

    // Changes for SDT-30717
    // Method to get all user info of Logged in, Case, quote, EmailMsg and InternalUser
    private static List<User> getUserDetails(Id userId, Id caseCreatedById, Id quoteCreatedById, List<EmailMessage> emailMsgs, Set<Id> internalUserIds)
    {
        String fromEmail='';
        if(emailMsgs != Null && !emailMsgs.isEmpty())
        {
            fromEmail = emailMsgs[0].FromAddress;
        }
        return [SELECT Id,title,  Profile.Name, UserRole.Name, email FROM User where (Id=:userId or Id=:caseCreatedById or Id=: quoteCreatedById OR email =:fromEmail OR Id =:internalUserIds) AND IsActive = true];
    }

    // Changes for SDT-30717
    // Method to get all contact by quote primary contact, quote contact and BR's contact approvers
    private static List<Contact> getContacts(Id quotePrimaryContact, Set<Id> contactServiceApprovers, Id quoteContactId)
    {
        return [Select Id,Email, Account_Title__c, Account_Department__c, Internal_User_ID__c, AccountId 
        from Contact 
        where Id =:quotePrimaryContact OR Id IN:contactServiceApprovers OR 
        Id =:quoteContactId]; 
    }

    // Method to get the business rule by Priority Condition
    //SDT 41544 adding IsHaulAwayService parameter
    public Business_Rule__c getBusinessRuleByPriority(String approvalRecordType,String caseType,String accountId,String duration, String locationId,Id caseIdToValidateAgainstHaulAway)
    {
        // Converting Set to List of string
        List<String> fieldList = new List<String>();
        fieldList.addall(destinationFields);
        // Converting List into columns
        String filters  = String.join(fieldList, ' , ');
        
        // Get All Business Rule Data Based On Recordtype, Active, AccountId, Request_Type and Service
        //String query = 'SELECT Name,id,AccountId__c,LocationId__c,Request_Type__c,Service__c,Case_Reason__c,Project_Code__c,No_Approval_Required__c, Recordtype.Name, Is_Auto_Email__c, Category_Type__c, group__c FROM Business_Rule__c WHERE Recordtype.Name =: approvalRecordType AND Active__c = true AND AccountId__c =: accountId AND Request_Type__c =: caseType AND Service__c =: duration ';
    //SDT 41544
        String query = 'SELECT Name,id,Service__c,Case_Reason__c,No_Approval_Required__c,NTE_Rules__c, Recordtype.Name, Is_Auto_Email__c, Category_Type__c, '+ filters +' FROM Business_Rule__c WHERE Recordtype.Name =: approvalRecordType AND Active__c = true AND AccountId__c =: accountId AND Request_Type__c =: caseType AND Service__c =: duration ';
        boolean IsHaulAwayService = HaulAwayService.getIsHaulAwayService(caseIdToValidateAgainstHaulAway);
        String HaulAwayService = Constant_Util.Haul_Away_Service;
        String haulAwayContainer = 'Haul Away Service';
         if(IsHaulAwayService){
            //String haulAwayRequestType = 'Pickup';
            String haulAwayRequestType = 'New Service';
            String haulAwayServiceType = 'Temporary';
            
            query = 'SELECT Name,id,Service__c,Case_Reason__c,No_Approval_Required__c,NTE_Rules__c, Recordtype.Name, Is_Auto_Email__c, Category_Type__c, '+ filters +' FROM Business_Rule__c WHERE Recordtype.Name =: approvalRecordType AND Active__c = true AND AccountId__c =: accountId AND Request_Type__c =: haulAwayRequestType AND Service__c =: haulAwayServiceType and Container__c = :haulAwayContainer ' ;
        } else {
            query = 'SELECT Name,id,Service__c,Case_Reason__c,No_Approval_Required__c,NTE_Rules__c, Recordtype.Name, Is_Auto_Email__c, Category_Type__c, '+ filters +' FROM Business_Rule__c WHERE Recordtype.Name =: approvalRecordType AND Active__c = true AND AccountId__c =: accountId AND Request_Type__c =: caseType AND Service__c =: duration and Container__c != :haulAwayContainer';
        }
        List<Business_Rule__c> businessRules = database.query(query);
        //system.debug('businessRules dataset size >'+ businessRules.size());
        //system.debug('mPriorityFieldConditionMap > '+ mPriorityFieldConditionMap);
        //system.debug('mPriorityFieldConditionMap.keyset() > '+ mPriorityFieldConditionMap.keyset());
        // Loop Over priority and remaining filter conditions (** Priority sorting is important)
        // Key Set Should be Sorted by Priority
        for(decimal priority : mPriorityFieldConditionMap.keyset()){
            //Get the remaining filter condition by priority
            //Map<decimal, List<Map<String, String>>>
            List<Map<String, String>> mConditionFieldValueMap = mPriorityFieldConditionMap.get(priority);
            //system.debug('getBusinessRuleByPriority priority >'+ priority);
            //system.debug('mConditionFieldValueMap >'+ mConditionFieldValueMap);
            //Loop Over Selected Business Rules
            for(Business_Rule__c br: businessRules)
            {
                // Serializing Business Rule Object to JSON string
                String businessRuleJson = Json.serialize(br);
                // Deserializing Business Rule Object to get the field and values [** Considering All fields are STRING other this will require coversion]
                Map<String,Object> businesRuleMap = (Map<String,Object>) JSON.deserializeUntyped(businessRuleJson);
                // Local variable, will set this value true when all remaining condition will match
                Boolean isBusinessRuleSelected = false;
                for(Map<String, String> fieldValueMap : mConditionFieldValueMap)
                {
                    //system.debug('fieldValueMap > '+ fieldValueMap);
                    // Loop Over Conditions
                    for(String field : fieldValueMap.keyset())
                    {
                        // if(!String.isEmpty(field))  // // added Haul Away Check //SDT-41473 - SDT-41625
                       if(!String.isEmpty(field) && !(IsHaulAwayService && field == 'Request_Type__c'))
                        {
                            String brFieldValue = (String)businesRuleMap.get(field);
                            String priorityFieldValue = fieldValueMap.get(field);
                            brFieldValue = String.isBlank(brFieldValue)? null : brFieldValue;
                            priorityFieldValue = String.isBlank(priorityFieldValue)? null : priorityFieldValue;

                            // Matching up priority Remaining Condition value with Business Rule value
                            // Data Type should be String for exact match
                            if(brFieldValue == priorityFieldValue)
                            {
                                // Setting Up isBusinessRuleSelected to true as condition Matched
                                isBusinessRuleSelected = true;
                            }
                            else{
                                //Breaking Condition because we are executing 'AND' statement
                                isBusinessRuleSelected = false;
                                break;
                            }
                        }
                    }
                    if(!isBusinessRuleSelected)
                    {
                        // This BR is not select because it does not matches the priority
                        break;
                    }
                }
               
               // Returning the selected Business Rule
               if(isBusinessRuleSelected)
               {
                    return br;
               }
            }
        }
        return null;
    }

    // SDT-49569 included
    public Business_Rule__c getBusinessRuleByPriority(Id quoteId) {
        
    Business_Rule__c approvalRule;
        List<Business_Rule__c> returnedRules = new List<Business_Rule__c>();
        Map<String, List<Business_Rule__c>> businessRuleMap = new Map<String, List<Business_Rule__c>>();

        try {
        if (quoteId == null) {
            return null;
        }

        SBQQ__Quote__c q = [
            SELECT Id,
                   SBQQ__Opportunity2__r.Case__r.Id,
                   SBQQ__Opportunity2__r.Case__r.Case_Type__c,
                   SBQQ__Opportunity2__r.Case__r.Case_Sub_Type__c,
                   SBQQ__Opportunity2__r.Case__r.Location__c
            FROM SBQQ__Quote__c
            WHERE Id = :quoteId
            LIMIT 1
        ];

        String caseType = q.SBQQ__Opportunity2__r.Case__r.Case_Type__c;
        String caseSubType = q.SBQQ__Opportunity2__r.Case__r.Case_Sub_Type__c;
        String locationId = q.SBQQ__Opportunity2__r.Case__r.Location__c;
        // Defect SDT- 50605 -> To display haul away quote to any record type
        Id idForBRData;
         if (((caseType == 'Pickup' && caseSubType == 'Haul Away - No Equipment') || caseType != 'New Service') && quoteId != null) {
            idForBRData = null;
            caseType = 'New Service';
            caseSubType = 'Temporary';
        } else {
            idForBRData = quoteId;
        }

        if (idForBRData == null) {
            List<Business_Rule__c> brList = CaseRulesModalCtrl.getBrRecordsByLocation(locationId);

            if (!brList.isEmpty()) {
                for (Business_Rule__c br : brList) {
                    if (br.Request_Type__c == 'New Service' &&
                        br.Service__c == 'Temporary' &&
                        br.RecordType.Name == 'Approval' && 
                        br.Container__c == 'Haul Away Service') {
                        return br; 
                    }
                }
            }
        } else {
	    businessRuleMap = BusinessRuleUtility.getPriorityBusinessRule(quoteId);
            if (businessRuleMap.size() > 0 && businessRuleMap.containsKey('Approval')) {
            returnedRules = businessRuleMap.get('Approval');
	    approvalRule = returnedRules[0];
            return approvalRule;
            }
        }

        return null;

        } catch (Exception e) {
        System.debug('Error in getBusinessRuleByPriority: ' + e.getMessage());
        return null;
        }
    }

    // Assigning Priority Field and Values to MAP
    private Map<string,string> assignPriorityCategoryValues(String sourceField, String destinationField, String finalval)
    {
        Map<string,string> mConditionFieldValueMap = new Map<string,string>();  
        if(sourceField.contains('Location_Type__c')){
            mConditionFieldValueMap.put('Category_Type__c','Location Type');
        }
        if(sourceField.contains('Geography__c')){
            mConditionFieldValueMap.put('Category_Type__c','Geography');
        }
        if(sourceField.contains('Brand__c')){
            mConditionFieldValueMap.put('Category_Type__c','Brand');
        }
        if(sourceField.contains('Division__c')){
            mConditionFieldValueMap.put('Category_Type__c','Division/Department');
        }

        //mConditionFieldValueMap.put(destinationField,finalval);
        return mConditionFieldValueMap;
    }

    // Get BR Priority
    public Business_Rule__c getBusinessRuleApproversDetails(Map<decimal,String>  mPriorityCondition,SBQQ__Quote__c newQuote, List<SBQQ__QuoteLine__c> listQuotelines)
    {
        //Changes for SDT-30717
        String caseNumber = newQuote.Case_Number__c;
        //Changes for SDT-30717
        String approvalRecordType = 'Approval'; 
        String caseType = newQuote.Case_Type__c;
        //SDT 41544
        Boolean IsHaulAwayService =  newQuote.SBQQ__Opportunity2__r.Case__r.Is_Haul_Away_Service__c;
        // Test Logic START
        String locationId = newQuote.SBQQ__Account__c;
        String accountId = newQuote.SBQQ__Account__r.Parent.Id;
        String duration = newQuote.Duration__c; 
        //system.debug('Quotes Account >'+ accountId);
        system.debug('Quotes duration >'+ duration);
        //system.debug('Quotes Location >'+ locationId);
        // to get the business rule by Priority Condition
        //SDT 41544 adding IsHaulAwayService parameter
        //Business_Rule__c businessRule = getBusinessRuleByPriority(approvalRecordType,caseType, accountId, duration, locationId,newQuote.SBQQ__Opportunity2__r.Case__c);
        Business_Rule__c businessRule = getBusinessRuleByPriority(newQuote.Id);
        system.debug('businessRule > '+ businessRule);
        return businessRule;
    }

}
