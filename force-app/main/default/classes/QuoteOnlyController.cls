/*
* @Name          QuoteOnlyController
* @Author        Seema Dhikale
* @Vendor        TCS
* @Date          25/11/2024
* @description   This class will be used for Quote Only - Amendment Quotes Story 33101
*/
public class QuoteOnlyController {
    public static final string QUOTETYPE_AMENDMENT = 'Amendment';
    public static final String sPendingApproval = 'Pending Approval';
    public static final String sApproved = 'Approved';
    public static final String sRejected = 'Rejected';
    
    @AuraEnabled
    public static Boolean getIsAmendmentQuote(Id quoteId) 
    {
        Boolean isAmendementQuote=false;
        String quoteType = [select SBQQ__Type__c from SBQQ__Quote__c where id=:quoteId limit 1].SBQQ__Type__c;
        isAmendementQuote = (quoteType==QUOTETYPE_AMENDMENT) ? true : false;
        return isAmendementQuote;
    }
    
    @AuraEnabled
    public static boolean getshowAddQuoteOnlyServiceButtonForAmendment(Id quoteId) 
    {
        boolean showQuoteonlyServicesForAmendment=false;
        Boolean isAmendementQuote=getIsAmendmentQuote(quoteId);
        Boolean isEligibleCreateMoreQuoteOnly = checkIfMoreQuoteOnlyServicesCanBeAdded(quoteId).showAddQuoteOnlyServiceButton;
        if(isAmendementQuote && isEligibleCreateMoreQuoteOnly)
            showQuoteonlyServicesForAmendment = true;
        else 
            showQuoteonlyServicesForAmendment = false;
        return showQuoteonlyServicesForAmendment;
     
    }
    @AuraEnabled
    public static boolean getDisableQuoteOnlyButtonForAmendment(Id quoteId) 
    {
        boolean disableQuoteonlyServicesForAmendment=false;
        Boolean isAmendementQuote=getIsAmendmentQuote(quoteId);
        Boolean isMoreThanOneQuoteOnlyCreated = checkIfMoreQuoteOnlyServicesCanBeAdded(quoteId).disableQuoteonlyCheckbox;
        if(isAmendementQuote && isMoreThanOneQuoteOnlyCreated)
            disableQuoteonlyServicesForAmendment = true;
        else 
            disableQuoteonlyServicesForAmendment = false;
        return disableQuoteonlyServicesForAmendment;
        
    }
    
    //Creating a wrapper class that will store info about how mant quote only services added till now
    public class QuoteOnlyWrapper
    {
        @AuraEnabled public Boolean showAddQuoteOnlyServiceButton {get; set;}
        @AuraEnabled public Boolean disableQuoteonlyCheckbox {get; set;}
    }
    
    @AuraEnabled
    public static QuoteOnlyWrapper checkIfMoreQuoteOnlyServicesCanBeAdded(Id quoteId) 
    {
        boolean isEligibleCreateMoreQuoteOnly = false;//if false then button add quote only service button will not be visible
        boolean isMoreThanOneQuoteOnlyCreated = false;//if true then checkbox quote only will be disabled
        string maxAllowedTabCount = System.Label.Number_of_Quote_Only_Allowed;
        integer existingQuoteOnlyCount = 1;
        
        //SDT 33101 New
        //List<AggregateResult> aggregateList = [SELECT count(Quote_Only_Copy_of__c) FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c=:quoteId];
        
        List<AggregateResult> aggregateList = [SELECT count(id) FROM SBQQ__QuoteLine__c 
                                               WHERE SBQQ__Quote__c=:quoteId and SBQQ__RequiredBy__c =null 
                                               and SBQQ__Quote__r.SBQQ__Type__c =:Constant_Util.QUOTE_TYPE_AMEND and
                                               SBQQ__Quote__r.Quote_Only__c =true];
        
        //get existin gQuoteOnly bundle Count = 
        object a=aggregateList[0].get('expr0');
        existingQuoteOnlyCount = (Integer)a;
        if(existingQuoteOnlyCount>0)
        {
            isMoreThanOneQuoteOnlyCreated=true;
        }
        
        if(existingQuoteOnlyCount<=(integer.valueof(maxAllowedTabCount)-1))//SDT33101 New added =
        {
            isEligibleCreateMoreQuoteOnly = true;
        }
        QuoteOnlyWrapper qoWrapper = new QuoteOnlyWrapper();
        qoWrapper.showAddQuoteOnlyServiceButton = isEligibleCreateMoreQuoteOnly;
        qoWrapper.disableQuoteonlyCheckbox = isMoreThanOneQuoteOnlyCreated;
        return qoWrapper;
    }
    
    //TCS-pkulkarn-SDT-33101-Added method to handle Amendment Quote approval via email
    //Caller: QuoteApprovalHandler.handleInboundEmail
    /*
    TCS-pkulkarn-SDT-44682-29-Jan-2025-Added documentation
    Parameter - emailSubjectParametersList - This list indicates the number of parameters on the email received for Approval/Decline
    When SDT-33101 related email is used, response from Customer for Approval involves 3 parameters in the Subject line (Approved:QuoteId:QuoteLineId). For Decline it will have 2(Declined:QuoteId).
	*/
    public static void handleAmendmentQuoteApprovalViaEmail(SBQQ__Quote__c quoteRecord, List<String> emailSubjectParametersList)
    {
        Id approvedQuoteLineId = null;
        //SDT 33101 New
        //List<AggregateResult> aggregateList = [SELECT count(Quote_Only_Copy_of__c) FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c=:quoteRecord.Id];
        
        List<AggregateResult> aggregateList = [SELECT count(id) FROM SBQQ__QuoteLine__c 
                                               WHERE SBQQ__Quote__c=:quoteRecord.Id and SBQQ__RequiredBy__c =null 
                                               and SBQQ__Quote__r.SBQQ__Type__c =:Constant_Util.QUOTE_TYPE_AMEND and
                                               SBQQ__Quote__r.Quote_Only__c =true];
        
        Integer existingQuoteOnlyCount = 0; 
        Boolean isMoreThanOneQuoteOnlyCreated = false;
        object a=aggregateList[0].get('expr0');
        existingQuoteOnlyCount = (Integer)a;
        //TCS-pkulkarn-SDT-44682-29-Jan-2025-Added following 2 variables
        final Integer emailResponseParameterCountTwo = 2;
        final Integer emailResponseParameterCountThree = 3;
        if(existingQuoteOnlyCount>0)
        {
            isMoreThanOneQuoteOnlyCreated=true;
        }
        List<EmailMessage> eMsgList = new List<EmailMessage>();
        DateTime emailActiveTillDate;
        eMsgList = [SELECT Subject, FromName, MessageDate FROM EmailMessage where Subject like 'Approval Required – Service Change Request -Multiple Quotes -%' and RelatedToId =:quoteRecord.Id limit 1];
        
        if(eMsgList!=null && eMsgList.size()>=1){
            emailActiveTillDate = eMsgList[0].MessageDate.addDays(30);
        }
        //quote only+multiple bundle
        if(quoteRecord.SBQQ__Type__c == Constant_Util.QUOTE_TYPE_AMEND && emailActiveTillDate!=null && emailActiveTillDate>=date.today() && isMoreThanOneQuoteOnlyCreated && quoteRecord.Quote_Only__c==true){
            Integer emailSubjectParametersListCount = emailSubjectParametersList.size();
            if(emailSubjectParametersListCount == emailResponseParameterCountTwo)	//Quote approved in a Single Bundle scenario
            {
                if(emailSubjectParametersList[0] == Constant_Util.QUOTE_APPROVED)
                {
                    updateQuoteLineApproveByField(approvedQuoteLineId, quoteRecord.Id, Constant_Util.QUOTE_APPROVED);
                    //TCS-pkulkarn-SDT-42555-21-Nov-2024-Added following line to fix the defect. Approve/Decline/Cancel buttons to be disabled for Sales once Quote is approved via email
                    quoteRecord.Is_Amendment_Quote_Approved_By_Sales__c = true;		
                    QuoteApprovalHandler.assignQuoteToSSMTeam(quoteRecord);
                }
                if(emailSubjectParametersList[0] == Constant_Util.QUOTE_DECLINED)
                {
                    quoteRecord.SBQQ__Status__c = Constant_Util.QUOTE_DECLINED;
                    updateQuoteLineApproveByField(approvedQuoteLineId, quoteRecord.Id, Constant_Util.QUOTE_DECLINED);		//Update the quote line Approved By field
                }
            }
            else if(emailSubjectParametersListCount == emailResponseParameterCountThree)	//TCS-pkulkarn-SDT-44682-29-Jan-2025-Replace harcoded value 3 with variable //Quote approved in a Multi Bundle scenario
            {
                if(emailSubjectParametersList[0] == Constant_Util.QUOTE_APPROVED)
                {
                    approvedQuoteLineId = emailSubjectParametersList[2];		//Get Quote Line Id from Subject
                    QuoteApprovalHandler.assignQuoteToSSMTeam(quoteRecord);
                    //TCS-pkulkarn-SDT-42555-21-Nov-2024-Added following line to fix the defect. Approve/Decline/Cancel buttons to be disabled for Sales once Quote is approved via email
                    quoteRecord.Is_Amendment_Quote_Approved_By_Sales__c = true;
                    updateQuoteLineApproveByField(approvedQuoteLineId, quoteRecord.Id, Constant_Util.QUOTE_APPROVED);		//Update the quote line Approved By field
                }
            }
        }
        
        //SDT 33101 end 
        if(quoteRecord.SBQQ__Type__c == Constant_Util.QUOTE_TYPE_AMEND && !isMoreThanOneQuoteOnlyCreated)
        {
            Integer emailSubjectParametersListCount = emailSubjectParametersList.size();
            if(emailSubjectParametersListCount == emailResponseParameterCountTwo)	//TCS-pkulkarn-SDT-44682-29-Jan-2025-Replace harcoded value 2 with variable //Quote approved in a Single Bundle scenario
            {
                if(emailSubjectParametersList[0] == Constant_Util.QUOTE_APPROVED)
                {
                    //TCS-pkulkarn-SDT-44682-29-Jan-2025-Commented below line. No need to update Customer Approval flag for single bundle, non-quote only amendment quote
                    //updateQuoteLineApproveByField(approvedQuoteLineId, quoteRecord.Id, Constant_Util.QUOTE_APPROVED);
                    //TCS-pkulkarn-SDT-42555-21-Nov-2024-Added following line to fix the defect. Approve/Decline/Cancel buttons to be disabled for Sales once Quote is approved via email
                    quoteRecord.Is_Amendment_Quote_Approved_By_Sales__c = true;		
                    QuoteApprovalHandler.assignQuoteToSSMTeam(quoteRecord);
                }
                if(emailSubjectParametersList[0] == Constant_Util.QUOTE_DECLINED)
                {
                    quoteRecord.SBQQ__Status__c = Constant_Util.QUOTE_DECLINED;
                    //TCS-pkulkarn-SDT-44682-29-Jan-2025-Commented below line. No need to update Customer Approval flag for single bundle, non-quote only amendment quote
                    //updateQuoteLineApproveByField(approvedQuoteLineId, quoteRecord.Id, Constant_Util.QUOTE_DECLINED);		//Update the quote line Approved By field
                }
            }
            else if(emailSubjectParametersListCount == emailResponseParameterCountThree)	//TCS-pkulkarn-SDT-44682-29-Jan-2025-Replace harcoded value 3 with variable //Quote approved in a Multi Bundle scenario
            {
                if(emailSubjectParametersList[0] == Constant_Util.QUOTE_APPROVED)
                {
                    approvedQuoteLineId = emailSubjectParametersList[2];		//Get Quote Line Id from Subject
                    QuoteApprovalHandler.assignQuoteToSSMTeam(quoteRecord);
                    //TCS-pkulkarn-SDT-42555-21-Nov-2024-Added following line to fix the defect. Approve/Decline/Cancel buttons to be disabled for Sales once Quote is approved via email
                    quoteRecord.Is_Amendment_Quote_Approved_By_Sales__c = true;
                    updateQuoteLineApproveByField(approvedQuoteLineId, quoteRecord.Id, Constant_Util.QUOTE_APPROVED);		//Update the quote line Approved By field
                }
            }
        }
    }
    
    //TCS-pkulkarn-SDT-33101-Added method to handle Amendment Quote approval (for multi bundle scenario) via email
    public static void updateQuoteLineApproveByField(Id approvedQuoteLineId, Id quoteId, String sStatus)
    {
        Set<Id> quoteIdSet = new Set<Id>();
        List<SBQQ__QuoteLine__c> quoteLineRecords = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> quoteLineRecordsToBeUpdated = new List<SBQQ__QuoteLine__c>();
        List<String> quoteLineCustomerApprovals = new List<String>();
        
        quoteIdSet.add(quoteId);
        quoteLineRecords = QuoteLineSelector.getAllQuoteLinesByQuoteIds(quoteIdSet);
        
        if(quoteLineRecords.size() > 1)
        {
            for(SBQQ__QuoteLine__c quoteLine : quoteLineRecords)
            {
                quoteLineCustomerApprovals.add(quoteLine.CustomerApproval__c);
            }
            if(!quoteLineCustomerApprovals.contains(sRejected)){
                for(SBQQ__QuoteLine__c quoteLine : quoteLineRecords)
                {
                    if(quoteLine.Id == approvedQuoteLineId && approvedQuoteLineId != null && sStatus.equalsIgnoreCase(Constant_Util.QUOTE_APPROVED))
                    {
                        quoteLine.CustomerApproval__c = sApproved;
                        quoteLineRecordsToBeUpdated.add(quoteLine);
                    }else if((quoteLine.SBQQ__RequiredBy__r.SBQQ__RequiredBy__c == approvedQuoteLineId ||quoteLine.SBQQ__RequiredBy__c == approvedQuoteLineId) && approvedQuoteLineId != null && sStatus.equalsIgnoreCase(Constant_Util.QUOTE_APPROVED)){
                        quoteLine.CustomerApproval__c = sApproved;
                        quoteLineRecordsToBeUpdated.add(quoteLine);
                    }
                    else
                    {
                        quoteLine.CustomerApproval__c = sRejected;
                        quoteLineRecordsToBeUpdated.add(quoteLine);
                    }
                }
            }
        }
        
        if(quoteLineRecords.size() == 1)
        {
            if(sStatus.equalsIgnoreCase(Constant_Util.QUOTE_APPROVED))
            {
                quoteLineRecords[0].CustomerApproval__c = sApproved;
                quoteLineRecordsToBeUpdated.add(quoteLineRecords[0]);
            }
        }
        
        if(quoteLineRecordsToBeUpdated.size() > 0)
        {
            UPDATE quoteLineRecordsToBeUpdated;
        }
    }
    
    public static void saveQuoteOnly(Id quoteId, Boolean quoteOnly, String quoteType) 
    {
        //TCS-pkulkarn-SDT-42718-31-Jan-2025-Added
        SBQQ__Quote__c quoteRecord = new SBQQ__Quote__c();
        quoteRecord.Id = quoteId;
        quoteRecord.Quote_Only__c = quoteOnly;
        UPDATE quoteRecord;
        updateCustomerApprovalFieldOnQuoteLines(quoteId, quoteOnly, quoteType);
        //TCS-pkulkarn-SDT-42718-31-Jan-2025-End
    }
    @AuraEnabled
    public static boolean displayApprovalButton(Id quoteId) 
    {
        Boolean displayApprovalButton = false;
        Boolean Is_ApprovedByCustomer = false;
        Boolean Is_SSMOrSalesTeamUser = getIfSSMOrSalesTeamUser();
        Boolean Is_AmendmentQuote = getIsAmendmentQuote(quoteId);
        Approval_Log__c approvalByCustomer;
        try{
            approvalByCustomer = [select id from Approval_Log__c 
                                  where Quote__c=: quoteId
                                  and Status__c=:Constant_Util.QUOTE_APPROVED 
                                  limit 1];
        }catch(exception e){
            
        }
        if(Is_SSMOrSalesTeamUser && Is_AmendmentQuote && approvalByCustomer==null){
            displayApprovalButton = true;
        }
        return displayApprovalButton;
    }
    public static Boolean getIfSSMOrSalesTeamUser() { 
        Boolean Is_SSMOrSalesTeamUser = false;
        List<String> UCCCodeListOfSSMAndSSTUsers = new List<String>();
        UCCCodeListOfSSMAndSSTUsers = System.Label.SSMTeamUCCCodes.split(',');
        UCCCodeListOfSSMAndSSTUsers.addAll(System.Label.SalesTeamUCCCodes.split(','));
        UCCCodeListOfSSMAndSSTUsers.addAll(System.Label.SSTTeamUCCCodes.split(','));//SDT33101 New
        User u = [SELECT Id, User_categorization_code__c FROM User WHERE Id =: UserInfo.getUserId()];
        if(u.User_categorization_code__c != null && (UCCCodeListOfSSMAndSSTUsers.contains(u.User_categorization_code__c)))
        {
            Is_SSMOrSalesTeamUser = true;
        }
        
        return Is_SSMOrSalesTeamUser;
    }
    
    //TCS-pkulkarn-SDT-33101-Added method to handle Amendment Quote approval (for multi bundle scenario) via email
    public static void approveQuoteLine(Id quoteId, Id qlIdToApprove)
    {
        Set<Id> quoteIdSet = new Set<Id>();
        List<SBQQ__QuoteLine__c> quoteLineRecords = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> quoteLineRecordsToBeUpdated = new List<SBQQ__QuoteLine__c>();
        
        quoteIdSet.add(quoteId);
        quoteLineRecords = QuoteLineSelector.getAllQuoteLinesByQuoteIds(quoteIdSet);
        
        if(quoteLineRecords.size() > 0)
        {
            for(SBQQ__QuoteLine__c quoteLine : quoteLineRecords)
            {
                if(quoteLine.Id == qlIdToApprove || quoteLine.SBQQ__RequiredBy__c == qlIdToApprove || quoteLine.SBQQ__RequiredBy__r.SBQQ__RequiredBy__c == qlIdToApprove)
                {
                    quoteLine.CustomerApproval__c = sApproved;
                    quoteLineRecordsToBeUpdated.add(quoteLine);
                }
                else
                {
                    quoteLine.CustomerApproval__c = sRejected;
                    quoteLineRecordsToBeUpdated.add(quoteLine);
                }
            }
        }
        if(quoteLineRecordsToBeUpdated.size() > 0)
        {
            UPDATE quoteLineRecordsToBeUpdated;
        }
    }
    
    //TCS-pkulkarn-SDT-33101-11-Nov-2024-Added new method to query Bundle Quote Lines based on QuoteId
    //Caller: QuoteTriggerHandler.onBeforeUpdate
    public static void validateAmendmentQuoteApproval(List<SBQQ__Quote__c> quoteList, Map<Id,SBQQ__Quote__c> oldMap)
    {
        Set<Id> quoteIds = new Set<Id>();
        Map<Id, List<SBQQ__QuoteLine__c>> quoteWithQuoteLines = new Map<Id, List<SBQQ__QuoteLine__c>>();
        List<SBQQ__QuoteLine__c> bundleQuoteLines =  new List<SBQQ__QuoteLine__c>();
        Integer approvedBundleCount = 0;
        Integer pendingApprovalBundleCount = 0;
        Integer bundleCount = 0;
        String sCustomerApproval = '';
        String sSSMUserCategory = 'SSM';
        String sSalesUserCategory = 'SALES';
        String sSSTUserCategory = 'SST';
        
        for(SBQQ__Quote__c quote : quoteList)
        {
            if(quote.SBQQ__Status__c == Constant_Util.QUOTE_APPROVED && 
               oldMap.get(quote.Id).SBQQ__Status__c == Constant_Util.QUOTE_PRICE_CONFIGURED && 
               quote.SBQQ__Type__c == QUOTETYPE_AMENDMENT &&
               quote.Quote_Only__c == true 
              )
            {
                quoteIds.add(quote.Id);
            }
        }
        
        if(quoteIds.size() > 0)
        {
            bundleQuoteLines = QuoteLineSelector.getBundleQuoteLinesByQuoteIds(quoteIds);
        }
        
        for(SBQQ__QuoteLine__c quoteLine : bundleQuoteLines)
        {
            if(quoteWithQuoteLines.containsKey(quoteLine.SBQQ__Quote__c))
            {
                quoteWithQuoteLines.get(quoteLine.SBQQ__Quote__c).add(quoteLine);
            }
            else
            {
                quoteWithQuoteLines.put(quoteLine.SBQQ__Quote__c, new List<SBQQ__QuoteLine__c>{quoteLine});
            }
        }
        
        for(Id quoteId : quoteWithQuoteLines.keySet())
        {
            bundleQuoteLines = quoteWithQuoteLines.get(quoteId);
            approvedBundleCount = 0;
            pendingApprovalBundleCount = 0;
            bundleCount = bundleQuoteLines.size();
            
            if(bundleCount >= 1)//SDT 42687 adding = in condition as validation should be shown for single bundle as well
            {
                for(SBQQ__QuoteLine__c quoteLine : bundleQuoteLines)
                {
                    sCustomerApproval = quoteLine.CustomerApproval__c;
                    if(sCustomerApproval.equalsIgnoreCase(Constant_Util.APPROVED))
                    {
                        approvedBundleCount = approvedBundleCount + 1;
                    }
                    if(sCustomerApproval.equalsIgnoreCase(sPendingApproval))
                    {
                        pendingApprovalBundleCount = pendingApprovalBundleCount + 1;
                    }
                }
                
                if(pendingApprovalBundleCount == bundleCount)
                {
                    //Set Error on Quote
                    for(SBQQ__Quote__c quote : quoteList)
                    {
                        if(quoteId == quote.Id)
                        {
                            //Chandu Kari SDT-45082 20-02-2025 Bypase the validation for single bundle quote.
                            if(bundleCount > 1 && quote.Quote_Only__c == true){
                                quote.addError(System.Label.AmendmentQuoteValidationError1);
                            }
                        }
                    }
                }
                else if(approvedBundleCount == 1)
                {
                    for(SBQQ__Quote__c quote : quoteList)
                    {
                        if(quoteId == quote.Id)
                        {
                            //TCS-pkulkarn-SDT-44690-21-01-2025-Removed check for SALES and SST Logged_In_User_Category__c, added check for SSM
                            //if(sSalesUserCategory.equalsIgnoreCase(quote.Logged_In_User_Category__c) || sSSTUserCategory.equalsIgnoreCase(quote.Logged_In_User_Category__c))
                            if(sSSMUserCategory.equalsIgnoreCase(quote.Logged_In_User_Category__c) == false)
                            {
                                quote.SBQQ__Status__c = Constant_Util.QUOTE_PRICE_CONFIGURED;
                                QuoteApprovalHandler.assignQuoteToSSMTeam(quote);
                                //TCS-pkulkarn-SDT-44690-21-01-2025-Added
                                if(sSalesUserCategory.equalsIgnoreCase(quote.Logged_In_User_Category__c))
                                {
                                	quote.Is_Amendment_Quote_Approved_By_Sales__c = true;
                                }
                            }
                            else if(sSSMUserCategory.equalsIgnoreCase(quote.Logged_In_User_Category__c) && bundleCount > 1)
                            {
                                quote.Quote_Only__c = false;
                            }
                        }
                    }
                }
            }
        }
    }
    
    //TCS-pkulkarn-SDT-33101-11-Nov-2024-Added new method to query Bundle Quote Lines based on QuoteId
    //Caller: PricingJSONRequest.integrationToAPI
    public static Id getApproveBundleFromAmendmentQuote(Id quoteId)//, String sQuoteType)
    {
        Set<Id> quoteIds = new Set<Id>();
        List<SBQQ__QuoteLine__c> bundleQuoteLines = new List<SBQQ__QuoteLine__c>();
        Id returnBundleId = null;
        quoteIds.add(quoteId);
        
        bundleQuoteLines = QuoteLineSelector.getBundleQuoteLinesByQuoteIds(quoteIds);
            if(bundleQuoteLines.size() > 1)
            {
                for(SBQQ__QuoteLine__c quoteLine : bundleQuoteLines)
                {
                    if(sApproved.equalsIgnoreCase(quoteLine.CustomerApproval__c))
                    {
                        returnBundleId = quoteLine.Id;
                    }
                }
            }
        return returnBundleId;
    } 
    @AuraEnabled
    public static string getAssetEquipmemtSize(Id assetId) 
    {
       string EquipementSize = [select Equipment_Size__c from asset where id =:assetId limit 1][0].Equipment_Size__c;
        return EquipementSize;
    }
    //TCS-pkulkarn-SDT-42718-31-Jan-2025-Added
    public static void updateCustomerApprovalFieldOnQuoteLines(Id quoteId, Boolean quoteOnly, String quoteType)
    {
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> quoteLinesForUpdate = new List<SBQQ__QuoteLine__c>();
        Set<Id> quoteIdSet = new Set<Id>();
        
        quoteIdSet.add(quoteId);

        if(quoteOnly && quoteId != null && quoteType == QUOTETYPE_AMENDMENT)
        {
            quoteLines = QuoteLineSelector.getAllQuoteLinesByQuoteIds(quoteIdSet);
        }

        for(SBQQ__QuoteLine__c quoteLine : quoteLines)
        {
            if((quoteLine.CustomerApproval__c == null || quoteLine.CustomerApproval__c == '' ))
            {
                quoteLine.CustomerApproval__c = sPendingApproval;
                quoteLinesForUpdate.add(quoteLine);
            }
        }

        if(quoteLinesForUpdate.size() > 0)
        {
            RecurrsiveTriggerHandler.isSkipQuoteLineTrigger = true;
            UPDATE quoteLinesForUpdate;
            RecurrsiveTriggerHandler.isSkipQuoteLineTrigger = false;
        }
    }
    //TCS-pkulkarn-SDT-42718-31-Jan-2025-End
}