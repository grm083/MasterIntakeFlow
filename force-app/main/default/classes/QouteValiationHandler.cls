public class QouteValiationHandler {  
    
    public static string atleastOneQuoteLineErrMsg = 'You must select at least one product for Quote';
    public static set<string> scheduledFrequencySet = new set<string>{'D', 'M', 'Y','W'};
    public static set<string> wasteCategorySet = new set<string>{'Waste Stream', 'Waste Category'};

    //TCS-pkulkarn-SDT-33303-Added variables to store Error message values
    public static String strVendorMissing = ' Vendor missing for ';
    public static String strForQuote = ' For Quote ';
    public static String strCostMissing = ' Cost is missing ';
    public static String strCostUOMType = ' Missing cost unit of measure or model type for ';
    public static String strCostModelTypeRebate = ' Cost model type of Rebate must have a cost of $0.00 for ';
    public static String strCostModelTypeSTP = ' You must enter 2 stepped cost if Cost model type is Stepped. ';
    public static String strPricingUnitMethodSTP = ' You must enter 2 stepped price if Price unit method is stepped. ';
    //Changes related to SDT-39632 -updated strOccuranceType
    public static String strOccuranceType = ' Scheduled/SOC service missing frequency interval for ';
    public static String strScheduleFrequency = ' On-call service should not contain a service frequency or frequency interval for ';
    public static String strMASLibraryOrCode = ' Missing MAS Library or Company Code  for ';
    public static String strSetupComment = ' Missing Setup Comment for ';
    public static String strManagementFee = ' Unit cost should be $0.00 and vendor name should start with WM Fee if product name is Management Fee for ';
    
   public static String HasOpenTaskGridTicketMsg = 'There is a task grid ticket currently open for this asset within Acorn. Please do this change after the task grid ticket is processed.';    
    public static String HasReadyToBillBillablesMsg = 'We cannot modify the service/billable component if the component is on a BillableInvoice, and the invoice is ready-to-bill.';																																															 
    //Changes related to SDT-39632
    public static String strMaterialNotConfigured ='Material Not Configured ';
    public static String strVendorNotActive =' Selected vendor is not active for '; 
    public static String strWmFeeCostChages = ' WM Fee Charges should have a cost of $0 for '; 
    public static String strLocationStatus =' Location Must Be Activated Before this Transaction is Complete '; 
    public static String strExceptionCode = ' An Exception Code/Reason/Description Must Be Provided for '; 
    public static String strVendorCommitDate = ' End Dates must be greater than the vendor commit date for ';
    public static String strPriceMissing = ' Price cannot be blank for ';   
    public static String strPriceModeltypeMissing = ' A Price Model Type (Pricing Method) must be specified for ';
    public static String strWmFeePriceCharges = ' WM Fee Charges require a price greater than 0 for ';  
    public static String strMasUniqueId = ' MAS Unique Id Missing for '; 
    public static String strVCRCode = ' Vendor requires VCR Code field for ';
    
    //set of haul away positive quote Ids - Changes related to SDT-39632
    public static set<Id> haulAwayQuoteSet = new set<Id>();
    
    //set of quotes for which intermediate validations need to be skipped
    public static set<Id> skipStageValidationQuoteIds = new set<Id>();
    
    //set of quote types for which the SDT-39632 new validation needs to be skipped 
    private static set<string> skipValidationQtypes = new set<string>{'Exception', 'Correction'}; 
        
    //Variable for switch on and off of new Validations
    private static Boolean newQuoteValidationOff = false;
    //Constant for New_Quote_Validation
    private static String New_Quote_Validation = 'New_Quote_Validation'; 
    
    //TCS-pkulkarn-SDT-33303-End
    public static void validateQuoteStatus(List<SBQQ__Quote__c> triggerNew, map<id, SBQQ__Quote__c> triggerOldMap){
        
        set<id> pConfiguredQuoteIdSet = new set<id>();
        set<id> cConfiguredQuoteIdSet = new set<id>();
        set<id> priceConfiguredQuoteIdSet = new set<id>();
        set<id> approvedQuoteIdSet = new set<id>();

        //Changes related to SDT-39632
        if(!Test.isRunningTest())
            newQuoteValidationOff = Code_Switch__c.getValues(New_Quote_Validation).Switch_Off__c;
            

        
        for(SBQQ__Quote__c quoteNew : triggerNew){
            if(quoteNew.SBQQ__Status__c!= triggerOldMap.get(quoteNew.Id).SBQQ__Status__c){
                if(quoteNew.SBQQ__Status__c=='Product Configured'){
                    pConfiguredQuoteIdSet.add(quoteNew.Id);
                }
                if(quoteNew.SBQQ__Status__c=='Cost Configured'){
                    cConfiguredQuoteIdSet.add(quoteNew.Id);
                }
                if(quoteNew.SBQQ__Status__c=='Price Configured'){
                    priceConfiguredQuoteIdSet.add(quoteNew.Id);
                }
                //sdt-31000
                if(quoteNew.SBQQ__Status__c=='Approved'){
                    //Changes related to SDT-39632
                    //For skipping intermediate validations for Exception,Correction and STP Quotes. 
                    if(skipValidationQtypes.contains(quoteNew.SBQQ__Type__c) || quoteNew.STP__c == true)
                    {
                        skipStageValidationQuoteIds.add(quoteNew.Id);
                    }
                    approvedQuoteIdSet.add(quoteNew.Id);
                }
                //sdt-31000
            }
        }
        if(pConfiguredQuoteIdSet.size()>0){
            vFSatge(triggerNew,pConfiguredQuoteIdSet);
        }
        
        //sdt-31000
        if(cConfiguredQuoteIdSet.size()>0){
            boolean isSuccess = false;
            isSuccess = vFSatge(triggerNew,cConfiguredQuoteIdSet);
            if(isSuccess){
                vSStage(triggerNew,cConfiguredQuoteIdSet);
            }
            /*boolean firstStageValidated = true;
            vFSatge(triggerNew,cConfiguredQuoteIdSet,firstStageValidated);
            boolean secondStageValidated = true;
            if(firstStageValidated){
                vSStage(triggerNew,cConfiguredQuoteIdSet,secondStageValidated);
            }*/
        }
        if(priceConfiguredQuoteIdSet.size()>0){
            boolean isSuccess = false;
            isSuccess = vFSatge(triggerNew,priceConfiguredQuoteIdSet);
            if(isSuccess){
                isSuccess = vSStage(triggerNew,priceConfiguredQuoteIdSet);
            }
            if(isSuccess){
                isSuccess = vTStage(triggerNew,priceConfiguredQuoteIdSet);
            }
            
            /*boolean firstStageValidated = true;
            vFSatge(triggerNew,priceConfiguredQuoteIdSet,firstStageValidated);
            boolean secondStageValidated = true;
            if(firstStageValidated){
                vSStage(triggerNew,priceConfiguredQuoteIdSet,secondStageValidated);
            }
            boolean thirdStageValidated = true;
            if(secondStageValidated){
                vTStage(triggerNew,priceConfiguredQuoteIdSet,thirdStageValidated);
            }*/
        }
        
        //Changes related to SDT-39632
        if(approvedQuoteIdSet.size()>0){
            boolean isSuccess = false;
            if(!newQuoteValidationOff)
            {
                isSuccess = vFSatge(triggerNew,approvedQuoteIdSet);
                if(isSuccess){
                    isSuccess = vSStage(triggerNew,approvedQuoteIdSet);
                }
                if(isSuccess){
                    isSuccess = vTStage(triggerNew,approvedQuoteIdSet);
                }
                if(isSuccess){
                    approvedStage(triggerNew,approvedQuoteIdSet,triggerOldMap);
                }
            }
            else
            {
                approvedStage(triggerNew,approvedQuoteIdSet,triggerOldMap);
            }
            
        }
    }
    //sdt-31000
    public static boolean approvedStage(List<SBQQ__Quote__c> triggerNew, set<id> quoteIdSet,map<id, SBQQ__Quote__c> triggerOldMap){
        System.debug('here13^^^ ');
        List<SBQQ__Quote__c> quotesWithQuoteLinesList = new List<SBQQ__Quote__c>();
        List<SBQQ__QuoteLine__c> updateQList = new List<SBQQ__QuoteLine__c>();
        map<Id,Business_Rule__c> reqInfomap = new map<Id,Business_Rule__c>();
        List<Business_Rule__c> brList = new List<Business_Rule__c>();
        List<service_approver__c> srList= new List<service_approver__c>();
        Id brIdSet;
        String CaseNum;
        boolean brWithNTE = false;
        String qlineDetails;
        boolean updateFlagNTE = false;
	String approvedIntegrationMsg;
        //pkulkarn-TCS-SDT-40556-Added fields to the SOQL-SBQQ__RequiredBy__r.Duration__c, AssetId__r.End_Date__c, Core_Service__c, SBQQ__EndDate__c, DoNotCreateMASTicket__c, MASRemoval__c, SBQQ__Quote__r.SBQQ__Type__c, Vendor__r.Name, Vendor__r.Parent_Vendor_ID__c, SBQQ__Quote__r.Name
        //Changes related to SDT-39632- added below fields to the query
        //Exception_Type__c,Exception_Reason__c,Exception_Comments__c,SBQQ__Quote__r.Case_record_Type__c,IsAssetQuotelineDifferent__c,VCRCode__c
                quotesWithQuoteLinesList = [SELECT Id,Case_Number__c,Approve_NTE_Amount__c,Project__c, Case_record_Type__c,Business_Rule__c, SBQQ__Status__c, (SELECT id,Name,AssetId__r.Start_Date__c,AssetId__r.InvoiceReadytobillMaxEndDate__c,AssetId__r.HasOpenTaskGridTicket__c, AssetId__r.Has_InvoiceReadytoBillStatus__c,ErrorComments__c, Occurrence_Type__c, Schedule_Frequency__c, Service_Days__c,SBQQ__Cost__c,Vendor__c, Equipment_Size__c, 
                                                                                                                                                       SBQQ__RequiredBy__c, SBQQ__RequiredBy__r.SBQQ__ProductFamily__c, SBQQ__Product__R.Name, 
                                                                                                                                                       SBQQ__RequiredBy__r.Equipment_Size__c,SBQQ__ListPrice__c,NTE_amount_on_SR__c,SBQQ__ProductName__c,SBQQ__MaximumPrice__c, SBQQ__RequiredBy__r.AssetId__r.Equipment_Size__c, AssetId__c,
                                                                                                                                                       SBQQ__RequiredBy__r.Duration__c, AssetId__r.End_Date__c, Core_Service__c,SBQQ__StartDate__c, SBQQ__EndDate__c, DoNotCreateMASTicket__c, MASRemoval__c, SBQQ__Quote__r.SBQQ__Type__c, Vendor__r.Name, 
                                                                                                                                                       Vendor__r.Parent_Vendor_ID__c, SBQQ__Quote__r.Name,Exception_Type__c,Exception_Reason__c,Exception_Comments__c,SBQQ__Quote__r.Case_record_Type__c,IsAssetQuotelineDifferent__c,VCRCode__c,SBQQ__Quote__r.Id,SBQQ__Quote__r.LastModifiedById,
                                                                                                                                                       Vendor_Commit_Date__c,SBQQ__Quote__r.Special_Handling__c,SBQQ__Quote__r.Special_Handling_Reason__c,SBQQ__Quote__r.RecordType.name,SBQQ__Quote__r.SBQQ__Status__c, SBQQ__Quote__c
                                                                                                                                                       FROM SBQQ__LineItems__r WHERE SBQQ__ProductFamily__c NOT IN: wasteCategorySet  
                                                                                                                                                       AND Bypass_Acorn_Integration__c = false) FROM SBQQ__Quote__c WHERE id IN: quoteIdSet];
        map<id,List<SBQQ__QuoteLine__c>> quoteIdQuoteLineListMap = new map<id,List<SBQQ__QuoteLine__c>>();
        //SDT-31000 start
        
        if(QuotesWithQuoteLinesList[0].Case_Number__c != null){
            CaseNum = QuotesWithQuoteLinesList[0].Case_Number__c;
        }
        System.debug('CaseNum^^^ ' +CaseNum);
        
        
        List<Case> csObj = [Select Id,Client__c,Location__c,CaseNumber,Location__r.Location_Type__c,Location__r.Geography__c,
                            Location__r.Division__c,Location__r.Brand__c,AssetId,
                            Case_Type__c,Case_Sub_Type__c,Case_Reason__c from Case where CaseNumber =:CaseNum];
        System.debug('csObj^^^ ' +csObj);
        Id reqInfoRecTypeId = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get('Approval').getRecordTypeId();
        // System.debug('recordTypeIdSet^^^ ' +recordTypeIdSet);
        
        
        Business_Rule__c brRules = GetBRQuotePriorityNTECtrl.getBRNTEPriority(quotesWithQuoteLinesList[0].Id);
        System.debug('Get brRules :: '+brRules);
    	//    List<NTEApprovalRuleHelper.BusinessRulewrapper> businessRulewrapperlst = NTEApprovalRuleHelper.selectBusinessRules(csObj,quotesWithQuoteLinesList[0]);
     	//   System.debug('calling here 2^^^ ');
        if(brRules!= null ){
            System.debug('inside if^^^ ');
            // for(NTEApprovalRuleHelper.BusinessRulewrapper brw : businessRulewrapperlst){
            if(reqInfoRecTypeId.equals(brRules.RecordTypeId)){
                System.debug('inside second if^^ ');
                //  reqInfomap.put(brw.caseId,brw.bRule);
                brList.add(brRules);
                brIdSet = brList[0].Id;
                 // Changes for SDT-37991
                if(brList!=null && brList[0].NTE_Rules__c && !brList[0].No_Approval_Required__c){
                    brWithNTE = true;
                }
                System.debug('brIdSet^^^ '+brIdSet);
            }
            // }
        }
        
        
        if(brIdSet != null){
            // BRWithServiceApproverList= [SELECT Id,(SELECT id,NTE_Amount__c from Approver_Entities__r  WHERE RecordType.Name = 'NTE Approval'
            //    AND Active__c = true ) FROM Business_Rule__c WHERE id = :brIDSet];
            if(brWithNTE){
              //  BRWithServiceApproverList= brList;
                srList = [SELECT id,NTE_Amount__c,Service_Type__c,RecordType.Name,Active__c from service_approver__c WHERE RecordType.Name = 'NTE Approval'
                                    AND Active__c = true AND Business_Rule__c =: brIdSet];
            }
        }
        
        for(SBQQ__Quote__c quote: quotesWithQuoteLinesList){
            if(quote.SBQQ__LineItems__r.size()>0){
                quoteIdQuoteLineListMap.put(quote.id, quote.SBQQ__LineItems__r);
                
            }
        }
        for(SBQQ__Quote__c qt: triggerNew){
            //Changes related to SDT-39632
            if(quoteIdSet.contains(qt.Id) && !haulAwayQuoteSet.contains(qt.Id)){
                if(quoteIdQuoteLineListMap.containsKey(qt.id)){
                   // System.debug('BRWithServiceApproverList1^^^ ' +BRWithServiceApproverList);
                    boolean nteLimitExceeded = false;
                    List<string> qlineList = new List<string>();
                    //pkulkarn-TCS-SDT-40056-Validate add End Date for Commercial, Temporary, WM asset for Add/Change quotes
		            List<SBQQ__QuoteLine__c> quoteLines = quoteIdQuoteLineListMap.get(qt.id);
                    for(SBQQ__QuoteLine__c qLine: quoteIdQuoteLineListMap.get(qt.id)){
                        //SDT-31000 start
                        if(!srList.isEmpty()){
                            System.debug('srList^^^ ' +srList);
                            if(srList.size()>0){                                
                                for(service_approver__c sr :srList){
                                    if(qLine.SBQQ__ListPrice__c != null && qLine.SBQQ__ListPrice__c > sr.NTE_Amount__c && qLine.SBQQ__ProductName__c == sr.Service_Type__c){
                                        nteLimitExceeded = true;
                                        //qlineDetails += qLine.Name;
                                        if(qline.NTE_amount_on_SR__c != sr.NTE_Amount__c){
                                            qline.NTE_amount_on_SR__c = sr.NTE_Amount__c;
                                            updateFlagNTE = true;
                                            updateQList.add(qline);
                                        }
                                        qlineList.add(qLine.Name);
                                        System.debug('inside boolean check^^^');
                                    }
                                }
                                if(qlineList!= null){
                                    qlineDetails = String.join(qlineList,',');
                                }
                            }
                        }
                        //SDT-31000 end
                        
                        
                        
                    }
                    if(checkHasOpenTaskGridTicket(quoteLines))
                    { System.debug('checkHasOpen>>>');                      
                        approvedIntegrationMsg = 'Integration validation(s)  : 1. ' +HasOpenTaskGridTicketMsg; }                
                    
                    if(checkHasReadyToBillBillables(quoteLines))
                    {   System.debug('HasReadyToBill>>>');
                        if(approvedIntegrationMsg != null) {
                        approvedIntegrationMsg =  approvedIntegrationMsg + ' 2.  ' +HasReadyToBillBillablesMsg;  }
                                else {
                                approvedIntegrationMsg =  'Integration validation(s)  : 1. '+HasReadyToBillBillablesMsg; }
                        }
                    
                   // approvedIntegrationMsg = '<p style="color:black;">Black Text</p>';
                   //approvedIntegrationMsg = 'this is '+ '\r\n'+ 'testsdf';
                   
                    
                    if(approvedIntegrationMsg !=null) {
                        //qt.addError(approvedIntegrationMsg);
                        qt.addError(approvedIntegrationMsg,false);
                        return true;
                    }
                    
                    String validationMessage = EndDateHandler.validateEndDateOnCommercialTemporaryContainers(quoteLines);
                    if(validationMessage != 'SUCCESS' && validationMessage != null)
                    {
                        qt.addError(validationMessage);
                        return true;
                    }
                    //pkulkarn-TCS-SDT-40056-End
		 // 40723 START
                    String startDatevalidationMessage = StartDateManagement.validateStartDateOnNewServiceQuote(quoteLines,  triggerOldMap);
                    if(startDatevalidationMessage != Constant_Util.SUCCESS && startDatevalidationMessage != null)
                    {
                        
                       PlatformEventProcessor.RaiseTaskAndGenesysPE(qt.Id);
                        qt.addError(startDatevalidationMessage);
                        return true;
                        
                        
                    }
                    //40723 END
                    
                    //SDT-31000 start
                    if(!qt.Approve_NTE_Amount__c && qt.SBQQ__Status__c == 'Approved' && triggerOldMap.get(qt.Id).SBQQ__Status__c == 'Price Configured' && nteLimitExceeded && qlineDetails != ''){
                        System.debug('final^^^ ');
                        qt.addError('NTE – Approval Needed for  ' +qlineDetails);
                        return true;
                    }   
                    //SDT-31000 end
                    
                    //Changes related to SDT-39632
                    if(!newQuoteValidationOff && !qt.STP__c && !skipValidationQtypes.contains(qt.SBQQ__Type__c))
                    {
                        String validationErrorMessage = '';
                        
                        validationErrorMessage = validateExceptionDetails (quoteLines);                        
                        if(validationErrorMessage != '' && validationErrorMessage !=null)
                        {
                            //qt.addError('abc');
                            qt.addError(validationErrorMessage);
                            return true;
                        }

                    }
                
                
                }
            }
        }
        return true;
    }
/* 39293 */
    public static boolean checkHasOpenTaskGridTicket(List<SBQQ__QuoteLine__c> quoteLines){
        
         boolean checkHasOpenTaskGridTicket = false;         
         for(SBQQ__QuoteLine__c qLine: quoteLines) { 
            if(qLine.AssetId__r.HasOpenTaskGridTicket__c){
                System.debug('qLine.AssetId__r.HasOpenTaskGridTicket__c>>'+qLine.AssetId__r.HasOpenTaskGridTicket__c);
                    checkHasOpenTaskGridTicket = true; break;
            }
         }
         return checkHasOpenTaskGridTicket;
         
    }
    
    /* 39295 */
    public static boolean checkHasReadyToBillBillables(List<SBQQ__QuoteLine__c> quoteLines){
        
         boolean checkHasReadyToBillBillables = false;
         for(SBQQ__QuoteLine__c qLine: quoteLines) { 
            //if(qLine.AssetId__r.Has_InvoiceReadytoBillStatus__c) 
            //System.debug('qLine.AssetId__r.Has_InvoiceReadytoBillStatus__c>>'+qLine.AssetId__r.Has_InvoiceReadytoBillStatus__c);
            if(qLine.AssetId__r.Start_Date__c != qLine.SBQQ__StartDate__c && qLine.AssetId__r.Has_InvoiceReadytoBillStatus__c && qLine.AssetId__r.InvoiceReadytobillMaxEndDate__c !=  null && qLine.SBQQ__StartDate__c <= qLine.AssetId__r.InvoiceReadytobillMaxEndDate__c) 
            {
                
                    checkHasReadyToBillBillables = true; break;
            }
         }
         return checkHasReadyToBillBillables;
         
    }
    //sdt-31000
    public static boolean vFSatge(List<SBQQ__Quote__c> triggerNew, set<id> quoteIdSet){
        List<SBQQ__Quote__c> quotesWithQuoteLinesList = new List<SBQQ__Quote__c>();
        //Changes related to SDT-39632
        map<id,String> quoteIdLocationStatusMap = new map<id,String>();
        //quotesWithQuoteLinesList = [SELECT Id, (SELECT id,Name,ErrorComments__c, Occurrence_Type__c, Schedule_Frequency__c, Service_Days__c,SBQQ__Cost__c,Vendor__c FROM SBQQ__LineItems__r WHERE SBQQ__ProductFamily__c NOT IN: wasteCategorySet AND SBQQ__RequiredBy__c != null AND Bypass_Acorn_Integration__c = false) FROM SBQQ__Quote__c WHERE id IN: quoteIdSet];
        //Changes related to SDT-39632 - remove the wastecategory filter from query - WHERE SBQQ__ProductFamily__c NOT IN: wasteCategorySet
        //Changes related to SDT-39632 - added SBQQ__ProductFamily__c,SBQQ__Account__r.Status__c,Vendor__r.Status__c to the query. 
        //Changes related to SDT-39632 - remove condition Bypass_Acorn_Integration__c = false from query
        //Adding Case fields required for haulaway check in the query. - Is_Haul_Away_Service__c,Haul_Away_Vendor__c
        quotesWithQuoteLinesList = [SELECT Id, Case_record_Type__c, SBQQ__Status__c, SBQQ__Opportunity2__r.Case__r.Is_Haul_Away_Service__c,SBQQ__Opportunity2__r.Case__r.Haul_Away_Vendor__c,SBQQ__Account__r.Status__c, (SELECT id,Name,ErrorComments__c, Occurrence_Type__c, Schedule_Frequency__c, Service_Days__c,SBQQ__Cost__c,Vendor__c, Equipment_Size__c, 
                                                SBQQ__RequiredBy__c, SBQQ__RequiredBy__r.SBQQ__ProductFamily__c, SBQQ__Product__R.Name, 
                                                                                                                                                                                                                          SBQQ__RequiredBy__r.Equipment_Size__c, SBQQ__RequiredBy__r.AssetId__r.Equipment_Size__c,SBQQ__ProductFamily__c,Bypass_Acorn_Integration__c,Vendor__r.Status__c
                                                                                                                                                                                                                          FROM SBQQ__LineItems__r ) FROM SBQQ__Quote__c WHERE id IN: quoteIdSet];
        map<id,List<SBQQ__QuoteLine__c>> quoteIdQuoteLineListMap = new map<id,List<SBQQ__QuoteLine__c>>();

        for(SBQQ__Quote__c quote: quotesWithQuoteLinesList){
            if(quote.SBQQ__LineItems__r.size()>0){
                quoteIdQuoteLineListMap.put(quote.id, quote.SBQQ__LineItems__r);
                //Changes related to SDT-39632 - added SBQQ__Account__r.Status__c to the map
                quoteIdLocationStatusMap.put(quote.id,quote.SBQQ__Account__r.Status__c);
            }
            //Case caseObj = new Case(Is_Haul_Away_Service__c = quote.SBQQ__Opportunity2__r.Case__r.Is_Haul_Away_Service__c,
            //Haul_Away_Vendor__c = quote.SBQQ__Opportunity2__r.Case__r.Haul_Away_Vendor__c);
            
            //Method to check for HaulAway status - Changes related to SDT-39632
            haulAwayQuoteSet = HaulAwayService.haulAwayCheckForBypassValidation(quote,quoteIdSet);
        }

        
        for(SBQQ__Quote__c qt: triggerNew){
            //Changes related to SDT-39632
            if(quoteIdSet.contains(qt.Id) && !haulAwayQuoteSet.contains(qt.Id)){
                if(quoteIdQuoteLineListMap.containsKey(qt.id)){
                    //Changes related to SDT-39632
                    string inactiveVendorQls = '';
                    string occTypeMissingquoteLineNames = '';
                    string quoteLineNames = '';
                    string frequencyErrQuoteLines ='';
                    boolean isMaterialQlAdded = false;
                    for(SBQQ__QuoteLine__c qLine: quoteIdQuoteLineListMap.get(qt.id)){
                        if(qLine.SBQQ__ProductFamily__c !=null && wasteCategorySet.contains(qLine.SBQQ__ProductFamily__c)){
                            isMaterialQlAdded = true;
                        }
                        //Changes related to SDT-39632
                        else if (qLine.Bypass_Acorn_Integration__c == false){
                        if(qLine.SBQQ__RequiredBy__c==null){
                            /*if(qLine.Occurrence_Type__c==null || qLine.Occurrence_Type__c==''){
                                occTypeMissingquoteLineNames = occTypeMissingquoteLineNames+qLine.Name+',';
                            }*/
                        }else{
                            if(qLine.Occurrence_Type__c=='SOC' || qLine.Occurrence_Type__c=='SCH'){
                                if(qLine.Schedule_Frequency__c == '' || qLine.Schedule_Frequency__c == null){
                                    quoteLineNames = quoteLineNames+qLine.Name+',';
                                }else{
                                    if(qLine.Schedule_Frequency__c == 'W' && (qLine.Service_Days__c=='' || qLine.Service_Days__c==null) ){
                                        frequencyErrQuoteLines = frequencyErrQuoteLines+qLine.Name+',';
                                    }
                                    }
                                }
                                if(qLine.Vendor__c !=null && qLine.Vendor__r.Status__c !='Active'){
                                    inactiveVendorQls = inactiveVendorQls + qLine.Name+',';
                                }
                            }   
                        }
                    }
                    /*if(occTypeMissingquoteLineNames!=''){
                        occTypeMissingquoteLineNames= occTypeMissingquoteLineNames.removeEnd(',');
                        qt.addError('Occurrence type should be selected for '+quoteLineNames);
                        return false;
                    }
                    else*/ if(quoteLineNames!=''){
                        quoteLineNames= quoteLineNames.removeEnd(',');
                        qt.addError('Scheduled service missing a service frequency (weekly, monthly, etc.) for '+quoteLineNames);
                        return false;
                        //Changes related to SDT-39632
                    }else if (frequencyErrQuoteLines !=''){
                        system.debug('before frequencyErrQuoteLines==>'+frequencyErrQuoteLines);
                            frequencyErrQuoteLines= frequencyErrQuoteLines.removeEnd(',');
                            qt.addError('Weekly scheduled service missing day(s) of the week for '+frequencyErrQuoteLines);
                        return false;
                        //Changes related to SDT-39632
                    }else if (!newQuoteValidationOff && inactiveVendorQls !=''){
                        inactiveVendorQls= inactiveVendorQls.removeEnd(',');
                        qt.addError(strVendorNotActive+inactiveVendorQls);
                        return false;
                    }
                    
                    //Changes related to SDT-39632  
                    if(!newQuoteValidationOff)
                    {
                        //Changes related to SDT-39632 - adding Error message for material type
                        if(!isMaterialQlAdded ){
                            qt.addError(strMaterialNotConfigured + strForQuote + qt.Name);
                            return false;
                        }
                        //Changes related to SDT-39632 -Check if  Location Is Active
                        else if(quoteIdLocationStatusMap.get(qt.id) != 'Active')
                        {
                            qt.addError(strLocationStatus + strForQuote + qt.Name);
                            return false;
                        }
                    }
                }
                else{
                    qt.addError(atleastOneQuoteLineErrMsg);
                    return false;
                }   
            }
        }
        return true;
    }
    public static boolean vSStage(List<SBQQ__Quote__c> triggerNew, set<id> quoteIdSet){
        List<SBQQ__Quote__c> quotesWithQuoteLinesList = new List<SBQQ__Quote__c>();
        map<id,List<SBQQ__QuoteLine__c>> quoteIdQuoteLineListMap = new map<id,List<SBQQ__QuoteLine__c>>();
             //SDT-32124 -Added IsAssetQuotelineDifferent__c flag and case recordtype
             //TCS-pkulkarn-SDT-33303-Added DoNotCreateTaskGridTickets__c to the SOQL
             //TCS-pkulkarn-SDT-40056-Added fields to the SOQL SBQQ__RequiredBy__c.SBQQ__ProductFamily__c, SBQQ__RequiredBy__c.Duration__c, AssetId__r.End_Date__c, Core_Service__c, SBQQ__EndDate__c, DoNotCreateMASTicket__c, MASRemoval__c, SBQQ__Quote__r.SBQQ__Type__c
        //Changes related to SDT-39632 - added VCRCode__c,Vendor__r.Status__c,MASCustomerUniqueId__c,Vendor_Commit_Date__c,SBQQ__RequiredBy__r.Vendor_Commit_Date__c,SBQQ__RequiredBy__r.SBQQ__EndDate__c,SBQQ__RequiredBy__r.SBQQ__Product__c,SBQQ__RequiredBy__r.SBQQ__Product__r.Name
        //  to the query
        quotesWithQuoteLinesList = [SELECT Id, (SELECT id, Name, PricingUnitMethod__c, CostPrice1__c, CostPrice2__c, PricePrice1__c, PricePrice2__c,ErrorComments__c, Occurrence_Type__c, Schedule_Frequency__c, Service_Days__c, SBQQ__Cost__c, Vendor__c, Vendor__r.Name, Vendor__r.Parent_Vendor_ID__c, Cost_Unit_of_Measure__c, CostModelType__c , Frequency_Interval__c, MASLibrary__c, MASCompany__c, SetupComment__c, SBQQ__ProductName__c, SBQQ__Product__r.Name, SBQQ__UnitCost__c, SBQQ__ListPrice__c,SBQQ__Quote__r.STP__c, SBQQ__Quote__r.name, IsAssetQuotelineDifferent__c,SBQQ__Quote__r.Case_record_Type__c, AssetId__c,
        DoNotCreateTaskGridTickets__c, SBQQ__RequiredBy__r.SBQQ__ProductFamily__c, SBQQ__RequiredBy__r.Duration__c, AssetId__r.End_Date__c, Core_Service__c, 
                                                SBQQ__EndDate__c, DoNotCreateMASTicket__c, MASRemoval__c, SBQQ__Quote__r.SBQQ__Type__c,VCRCode__c,Vendor__r.Status__c,MASCustomerUniqueId__c,Vendor_Commit_Date__c,SBQQ__RequiredBy__r.SBQQ__EndDate__c,SBQQ__RequiredBy__r.Vendor_Commit_Date__c,SBQQ__RequiredBy__r.SBQQ__Product__c,SBQQ__RequiredBy__r.SBQQ__Product__r.Name,SBQQ__RequiredBy__r.Name  FROM SBQQ__LineItems__r WHERE SBQQ__ProductFamily__c NOT IN: wasteCategorySet AND SBQQ__RequiredBy__c != null AND Bypass_Acorn_Integration__c = false) FROM SBQQ__Quote__c WHERE id IN: quoteIdSet];
        // Commented 'SetupComment__c' field reference for story SDT-25787 to change the DataType from 'Text(255)' to 'Long Text(1500)' Will uncomment after DataType is changed
        //quotesWithQuoteLinesList = [SELECT Id, (SELECT id, Name, ErrorComments__c, Occurrence_Type__c, Schedule_Frequency__c, Service_Days__c, SBQQ__Cost__c, Vendor__c, Vendor__r.Name, Cost_Unit_of_Measure__c, CostModelType__c , Frequency_Interval__c, MASLibrary__c, MASCompany__c, SBQQ__ProductName__c, SBQQ__Product__r.Name, SBQQ__UnitCost__c, SBQQ__ListPrice__c FROM SBQQ__LineItems__r WHERE SBQQ__ProductFamily__c NOT IN: wasteCategorySet AND SBQQ__RequiredBy__c != null AND Bypass_Acorn_Integration__c = false) FROM SBQQ__Quote__c WHERE id IN: quoteIdSet];
        for(SBQQ__Quote__c quote: quotesWithQuoteLinesList){
            if(quote.SBQQ__LineItems__r.size()>0){
                quoteIdQuoteLineListMap.put(quote.id, quote.SBQQ__LineItems__r);
            }
        }
        for(SBQQ__Quote__c qt: triggerNew){
            //Changes related to SDT-39632
            if(quoteIdSet.contains(qt.Id) && !haulAwayQuoteSet.contains(qt.Id) && !skipStageValidationQuoteIds.contains(qt.Id)){
            if(quoteIdQuoteLineListMap.containsKey(qt.Id)){
                set<string> errorSet = new set<string>();
                //pkulkarn-TCS-SDT-40056-Validate add End Date for Commercial, Temporary, WM asset for Add/Change quotes
                List<SBQQ__QuoteLine__c> quoteLines = quoteIdQuoteLineListMap.get(qt.id);
                //Validate Vendor Commit Date for Parent QL
                Boolean parentVendorCheckDone = false;
                
                for(SBQQ__QuoteLine__c qLine: quoteIdQuoteLineListMap.get(qt.id)){
                    //SDT-32124 method evaluates not new service and qline changes.
                    if(QuoteLineServices.isQuoteLineChangedforNonNs(qLine)){
                    if(qLine.Vendor__c==null){
                        errorSet.add(qLine.SBQQ__Product__r.Name + strVendorMissing + qLine.Name + strForQuote +qLine.SBQQ__Quote__r.Name);
                    }else{
                        if(qLine.SBQQ__UnitCost__c == null){
                            //errorSet.add('Cost missing for '+qLine.Name + ' Product ' +qLine.SBQQ__Product__r.Name +' For Quote ' +qLine.SBQQ__Quote__r.Name);
                            errorSet.add(qLine.SBQQ__Product__r.Name + strCostMissing +qLine.Name + strForQuote +qLine.SBQQ__Quote__r.Name);
                        }else{
                            if(qLine.Cost_Unit_of_Measure__c==null || qLine.Cost_Unit_of_Measure__c=='' || qLine.CostModelType__c==null || qLine.CostModelType__c=='' ){
                                errorSet.add(qLine.SBQQ__Product__r.Name + strCostUOMType + qLine.Name + strForQuote + qLine.SBQQ__Quote__r.Name);
                            }else{
                                if(qLine.CostModelType__c=='REB'){
                                    if(qLine.SBQQ__UnitCost__c!=0){
                                        errorSet.add(qLine.SBQQ__Product__r.Name + strCostModelTypeRebate + qLine.Name + strForQuote + qLine.SBQQ__Quote__r.Name);
                                    }
                                }
								if(qLine.CostModelType__c=='STP'){
                                    if(qLine.CostPrice1__c==null || qLine.CostPrice2__c==null){
                                        errorSet.add(qLine.SBQQ__Product__r.Name + strCostModelTypeSTP +qLine.Name+ strForQuote +qLine.SBQQ__Quote__r.Name);
                                    }
                                }
                                //TCS-pkulkarn-SDT-41493-Moved this validation to Configure Price -> Submit for Approval and hence commented below code block
                                /*if(qLine.PricingUnitMethod__c=='STP'){
                                    if(qLine.PricePrice1__c==null || qLine.PricePrice2__c==null){
                                        errorSet.add(qLine.SBQQ__Product__r.Name + strPricingUnitMethodSTP + qLine.Name+ strForQuote +qLine.SBQQ__Quote__r.Name);
                                    }
                                }*/
                                if((qLine.Occurrence_Type__c=='SOC' || qLine.Occurrence_Type__c=='SCH') && scheduledFrequencySet.contains(qLine.Schedule_Frequency__c) && (qLine.Frequency_Interval__c=='' || qLine.Frequency_Interval__c==null) ){
                                    errorSet.add(qLine.SBQQ__Product__r.Name + strOccuranceType + qLine.Name + strForQuote +qLine.SBQQ__Quote__r.Name);
                                }else{
                                    if(qLine.Occurrence_Type__c=='OC'){
                                        if((qLine.Schedule_Frequency__c!='' && qLine.Schedule_Frequency__c!=null) || (qLine.Frequency_Interval__c!='' && qLine.Frequency_Interval__c!=null)){
                                            errorSet.add(qLine.SBQQ__Product__r.Name + strScheduleFrequency + qLine.Name + strForQuote + qLine.SBQQ__Quote__r.Name); 
                                        }
                                        
                                    }
                                    string vendorName = qLine.Vendor__r.Name;
                                    String vendorId = qLine.Vendor__r.Parent_Vendor_ID__c;	//TCS-pkulkarn-13-Mar-2024-SDT-33303-Added
                                            if(vendorId == Constant_Util.WM_US_VENDOR || vendorId == Constant_Util.WM_CANADA_VENDOR){
                                                //Changes related SDT-39632 - adding VCR code check for WM Vendor
                                                if(qLine.MASLibrary__c=='' || qLine.MASLibrary__c==null || qLine.MASCompany__c=='' || qLine.MASCompany__c==null)
                                                {
                                                    errorSet.add(qLine.SBQQ__Product__r.Name + strMASLibraryOrCode + qLine.Name + strForQuote + qLine.SBQQ__Quote__r.Name);
                                                }
                                                //Changes related to SDT-39632 - Check for MAS UniqueId
                                                //else if(!New_Quote_Validation_Off && qt.SBQQ__Type__c != 'Quote' && qLine.MASCustomerUniqueId__c == null && !qt.STP__c && !skipValidationQtypes.contains(qt.SBQQ__Type__c) )
                                                //{
                                                //    errorSet.add(qLine.SBQQ__Product__r.Name + strMasUniqueId + qLine.Name+ strForQuote +qLine.SBQQ__Quote__r.Name);
                                                //}
                                                else if(!newQuoteValidationOff && qt.SBQQ__Type__c == 'Quote' && !qt.STP__c && !skipValidationQtypes.contains(qt.SBQQ__Type__c)) 
                                                {
                                                    String vcrCodeErrorMessage = validateVCRCode(new List<SBQQ__QuoteLine__c>{qLine});
                                                    if(vcrCodeErrorMessage != '' && vcrCodeErrorMessage != null)
                                                    {
                                                         errorSet.add(vcrCodeErrorMessage);
                                                    }
                                                    //errorSet.add(qLine.SBQQ__Product__r.Name + strVCRCode + qLine.Name + strForQuote + qLine.SBQQ__Quote__r.Name);
                                                    
                                                }
                                    // Commented 'SetupComment__c' field reference for story SDT-25787 to change the DataType from 'Text(255)' to 'Long Text(1500)' Will uncomment after DataType is changed
                                    //if(vendorName.startsWithIgnoreCase('WM') && (qLine.MASLibrary__c=='' || qLine.MASLibrary__c==null || qLine.MASCompany__c=='' || qLine.MASCompany__c==null )){
                                                
                                                
                                    }
                                    // changes done for SDT-26174
                                    //TCS-pkulkarn-SDT-33303-End
                                    //TCS-pkulkarn-13-Mar-2024-SDT-33303-Added
                                    if(qLine.SetupComment__c == '' || qLine.SetupComment__c == null)
									{
										String validationMessage = validateSetupComment(qLine, qt);
										if(validationMessage != '' && validationMessage != null)
											errorSet.add(validationMessage);
									}
                                    //TCS-pkulkarn-SDT-33303-End
                                    else{
                                        if(qLine.SBQQ__ProductName__c == 'Management Fee'){
                                            //string vendorName = qLine.Vendor__r.Name;
                                            if(qLine.SBQQ__UnitCost__c!=0 || !vendorName.startsWithIgnoreCase('WM Fee')){
                                                errorSet.add(qLine.SBQQ__Product__r.Name + strManagementFee + qLine.Name + strForQuote + qLine.SBQQ__Quote__r.Name);
                                            }
                                                }
                                            }
                                            //Changes related to SDT-39632 - check if cost =0 if vendor is WM Fee
                                            if(!newQuoteValidationOff && !qt.STP__c && !skipValidationQtypes.contains(qt.SBQQ__Type__c))
                                            {
                                                if(qLine.Vendor__r.Name !=null && qLine.Vendor__r.Name.startsWithIgnoreCase('WM Fee') && qLine.SBQQ__UnitCost__c !=0)
                                                {
                                                    errorSet.add(qLine.SBQQ__Product__r.Name + strWmFeeCostChages + qLine.Name + strForQuote + qLine.SBQQ__Quote__r.Name);
                                                }
                                                //Changes related to SDT-39632 - Check for Vendor Commit date for both parent and child QLs.
												parentVendorCheckDone = validateVendorCommitDate(qLine,errorSet,parentVendorCheckDone);

                                            }
                                            
                                        }
                                    }
                                }
                            }
                        }
                        //}
                }
                
                //pkulkarn-TCS-SDT-40056-Added following line
                String validationMessage = EndDateHandler.validateEndDateOnCommercialTemporaryContainers(quoteLines);
                
                string fErrorMsg = '';
                //pkulkarn-TCS-SDT-40056-Added following if block
                if(validationMessage != 'SUCCESS' && validationMessage != null)
                {
                    errorSet.add(validationMessage);
                }
                //pkulkarn-TCS-SDT-40056-End

                if(errorSet.size()>0){
                    for(string err: errorSet){
                        if(fErrorMsg==''){
                            fErrorMsg = err;
                        }else{
                            fErrorMsg= fErrorMsg+' and '+err;
                        }
                    }
                    qt.addError(fErrorMsg);
                    return false;
                }else{
                    return true;
                    }
                }
            }
        }
        return true;
    }
    public static boolean vTStage(List<SBQQ__Quote__c> triggerNew, set<id> quoteIdSet){
        List<SBQQ__Quote__c> quotesWithQuoteLinesList = new List<SBQQ__Quote__c>();
        map<id,List<SBQQ__QuoteLine__c>> quoteIdQuoteLineListMap = new map<id,List<SBQQ__QuoteLine__c>>();
        //TCS-pkulkarn-SDT-41493-Added fields PricingUnitMethod__c, PricePrice1__c, PricePrice2__c, SBQQ__Quote__r.Name to QuoteLine query
        
        //Changes related to SDT-39632 - added below fields to query (moved logic to aprrovedstage)
        //SBQQ__Account__r.Status__c,Exception_Type__c,Exception_Reason__c,Exception_Comments__c,SBQQ__PricingMethod__c,SBQQ__Quote__r.Case_record_Type__c,assetId,IsAssetQuotelineDifferent__c,Vendor__r.Parent_Vendor_ID__c,MASCustomerUniqueId__c
        quotesWithQuoteLinesList = [SELECT Id,SBQQ__Account__r.Status__c, (SELECT id, Name, ErrorComments__c, Occurrence_Type__c, Schedule_Frequency__c, Service_Days__c, SBQQ__Cost__c, Vendor__c, Vendor__r.Name, Cost_Unit_of_Measure__c, CostModelType__c , Frequency_Interval__c, MASLibrary__c, MASCompany__c, SetupComment__c, SBQQ__ProductName__c,SBQQ__Product__r.Name, SBQQ__UnitCost__c, PriceUOM__c, SBQQ__ListPrice__c, PricingUnitMethod__c, PricePrice1__c, PricePrice2__c, SBQQ__Quote__r.Name, SBQQ__PricingMethod__c,Vendor__r.Parent_Vendor_ID__c,MASCustomerUniqueId__c  FROM SBQQ__LineItems__r WHERE SBQQ__ProductFamily__c NOT IN: wasteCategorySet AND SBQQ__RequiredBy__c != null AND Bypass_Acorn_Integration__c = false) FROM SBQQ__Quote__c WHERE id IN: quoteIdSet];
        // Commented 'SetupComment__c' field reference for story SDT-25787 to change the DataType from 'Text(255)' to 'Long Text(1500)' Will uncomment after DataType is changed
        //quotesWithQuoteLinesList = [SELECT Id, (SELECT id, Name, ErrorComments__c, Occurrence_Type__c, Schedule_Frequency__c, Service_Days__c, SBQQ__Cost__c, Vendor__c, Vendor__r.Name, Cost_Unit_of_Measure__c, CostModelType__c , Frequency_Interval__c, MASLibrary__c, MASCompany__c, SBQQ__ProductName__c,SBQQ__Product__r.Name, SBQQ__UnitCost__c, PriceUOM__c, SBQQ__ListPrice__c FROM SBQQ__LineItems__r WHERE SBQQ__ProductFamily__c NOT IN: wasteCategorySet AND SBQQ__RequiredBy__c != null AND Bypass_Acorn_Integration__c = false) FROM SBQQ__Quote__c WHERE id IN: quoteIdSet];
        for(SBQQ__Quote__c quote: quotesWithQuoteLinesList){
            if(quote.SBQQ__LineItems__r.size()>0){
                quoteIdQuoteLineListMap.put(quote.id, quote.SBQQ__LineItems__r);
            }
        }
        for(SBQQ__Quote__c qt: triggerNew){
            //Changes related to SDT-39632 
            if(quoteIdSet.contains(qt.Id) && !haulAwayQuoteSet.contains(qt.Id) && !skipStageValidationQuoteIds.contains(qt.Id)){
            if(quoteIdQuoteLineListMap.containsKey(qt.Id)){
                set<string> errorSet = new set<string>();
                for(SBQQ__QuoteLine__c qLine: quoteIdQuoteLineListMap.get(qt.id)){ 
                    if(qLine.PriceUOM__c==null || qLine.PriceUOM__c==''){
                        errorSet.add('Missing price unit of measure for '+qLine.Name);
                    }else{
                        if(qLine.SBQQ__Product__r.Name == 'Management Fee' && (qLine.SBQQ__ListPrice__c==null || qLine.SBQQ__ListPrice__c<=0 )){
                            errorSet.add('Price of Management Fee product option must be greater than $0.00 '+qLine.Name);
                        }
                    }
                    //TCS-pkulkarn-SDT-41493-Moved this validation from Procure Service -> Configure Price to Configure Price -> Submit for Approval
                    if(qLine.PricingUnitMethod__c=='STP')
                    {
                        if(qLine.PricePrice1__c==null || qLine.PricePrice2__c==null)
                        {
                            errorSet.add(qLine.SBQQ__Product__r.Name + strPricingUnitMethodSTP + qLine.Name+ strForQuote +qLine.SBQQ__Quote__r.Name);
                        }
                    }
                    //TCS-pkulkarn-SDT-41493-End
                        
                        //Changes related to SDT-39632 - Adding Unit Price and Price Model Type Validations to the existing Logic
                        if(!newQuoteValidationOff && !qt.STP__c &&  !skipValidationQtypes.contains(qt.SBQQ__Type__c))
                        {
                            if(qLine.SBQQ__ListPrice__c == null && qLine.PricingUnitMethod__c!='STP')
                            {
                                errorSet.add(qLine.SBQQ__Product__r.Name + strPriceMissing +qLine.Name + strForQuote +qLine.SBQQ__Quote__r.Name);
                            }
                            else if (qLine.SBQQ__PricingMethod__c == null || qLine.SBQQ__PricingMethod__c == '')
                            {
                                errorSet.add(qLine.SBQQ__Product__r.Name + strPriceModeltypeMissing +qLine.Name + strForQuote +qLine.SBQQ__Quote__r.Name);
                            }
                            
                            //Changes related to SDT-39632 - check if price = 0 if vendor is WM Fee
                            string vendorName = qLine.Vendor__r.Name;
                            String vendorId = qLine.Vendor__r.Parent_Vendor_ID__c;
                            
                            if(qLine.Vendor__r.Name !=null && qLine.Vendor__r.Name.startsWithIgnoreCase('WM Fee') && 
                               qLine.SBQQ__ListPrice__c ==0)
                            {
                                errorSet.add(qLine.SBQQ__Product__r.Name + strWmFeePriceCharges + qLine.Name + strForQuote + qLine.SBQQ__Quote__r.Name);
                            }
                            else if((vendorId == Constant_Util.WM_US_VENDOR || vendorId == Constant_Util.WM_CANADA_VENDOR) && 
                                    qt.SBQQ__Type__c != 'Quote' && qLine.MASCustomerUniqueId__c == null) 
                            {
                                errorSet.add(qLine.SBQQ__Product__r.Name + strMasUniqueId + qLine.Name+ strForQuote +qLine.SBQQ__Quote__r.Name);
                        }
                    }
                    
                    }
                    
                string fErrorMsg = '';
                if(errorSet.size()>0){
                    for(string err: errorSet){
                        if(fErrorMsg==''){
                            fErrorMsg = err;
                        }else{
                            fErrorMsg= fErrorMsg+'\n'+err;
                        }
                    }
                    qt.addError(fErrorMsg);
                    return false;
                }else{
                    return true;
                    }
                }
            }
        }
        return true;
    }

    // Method: validateSetupComment
    // Usage : To validate if the SetupComment field is required for a Quote Line 

    // Output : String indicating validation message
    // Caller : QouteValiationHandler.vSStage()
    // Test class: This method is covered by QouteValiationHandlerTest.testvalidateSetupComment()
    // Defect/Story/Author: TCS-pkulkarn-SDT-33303-Added
    public static String validateSetupComment(SBQQ__QuoteLine__c quoteLine, SBQQ__Quote__c quote)
    {
        String validationMessage = '';
        String vendorId = quoteLine.Vendor__r.Parent_Vendor_ID__c;
        
        if (quote.STP__c == false && 
            (vendorId == Constant_Util.WM_US_VENDOR || vendorId == Constant_Util.WM_CANADA_VENDOR) && 
            (quoteLine.DoNotCreateTaskGridTickets__c == false)
           )
        {
        	validationMessage = quoteLine.SBQQ__Product__r.Name + strSetupComment + quoteLine.Name + strForQuote + quoteLine.SBQQ__Quote__r.Name;
        }
        return validationMessage;
    }
    
    // Method: validateExceptionDetails - Changes related to SDT-39632
    // Usage : To validate exception details are populated in the Quotelines which are changed. 
    // Output : String indicating validation message
    // Caller : QouteValiationHandler.approvedStage()
    // Test class: QouteValidationHandler.validateExceptionDetails
    // Defect/Story/Author: TCS-Rishan
    
    public static string validateExceptionDetails(List<SBQQ__QuoteLine__c> quoteLines){
        String exceptionDetailsMessage = ''; 
        set<string> exceptionDetailsErrorSet = new set<string>();       
        for(SBQQ__QuoteLine__c qLine: quoteLines) { 
            //Changes related to SDT-39632 -Check for exception type, code and reason.
            //added QuoteLineServices.isQuoteLineChangedforNonNs(qLine) to confirm the quoteline values are changed. 
            if(QuoteLineServices.isQuoteLineChangedforNonNs(qLine) && qLine.SBQQ__RequiredBy__c !=null &&
               (qLine.Exception_Type__c == null || qLine.Exception_Type__c==''||
                qLine.Exception_Reason__c == null ||qLine.Exception_Reason__c == '' ||
                qLine.Exception_Comments__c == null || qLine.Exception_Comments__c == ''))
            {
                exceptionDetailsErrorSet.add(qLine.SBQQ__Product__r.Name + strExceptionCode + qLine.Name+ strForQuote +qLine.SBQQ__Quote__r.Name);
            }
        }
        if(exceptionDetailsErrorSet.size()>0)
        {
            for(string err: exceptionDetailsErrorSet)
            {
                if(exceptionDetailsMessage==''){
                    exceptionDetailsMessage = err;
                }else{
                    exceptionDetailsMessage= exceptionDetailsMessage+'\n'+err;
                }
            }
        }
        return exceptionDetailsMessage;     
    }
    
    // Method: validateVendorCommitDate
    // Usage : To validate vendor commit date of Quote Line 
    // Output : String indicating validation message
    // Caller : QouteValiationHandler.vSStage()
    // Test class: This method is covered by QouteValiationHandlerTest.vendorCommitDateCheck method
    // Defect/Story/Author: TCS-mali2-SDT-39632-Added
    public Static Boolean validateVendorCommitDate(SBQQ__QuoteLine__c qLine, set<string> errorSet, Boolean parentVendorCheckDone)
    {
       if(qLine.SBQQ__EndDate__c != null && (qLine.Vendor_Commit_Date__c > qLine.SBQQ__EndDate__c))
        {
            errorSet.add(qLine.SBQQ__Product__r.Name + strVendorCommitDate + qLine.Name+ strForQuote +qLine.SBQQ__Quote__r.Name);
        }
        if(!parentVendorCheckDone)
        {
            parentVendorCheckDone = true;
            if(qLine.SBQQ__RequiredBy__c!=null && qLine.SBQQ__RequiredBy__r.SBQQ__EndDate__c != null && 
               qLine.SBQQ__RequiredBy__r.SBQQ__Product__c!=null &&
               (qLine.SBQQ__RequiredBy__r.Vendor_Commit_Date__c > qLine.SBQQ__RequiredBy__r.SBQQ__EndDate__c))
            {
                
                    errorSet.add(qLine.SBQQ__RequiredBy__r.SBQQ__Product__r.Name + strVendorCommitDate + 
                                 qLine.SBQQ__RequiredBy__r.Name+ strForQuote +qLine.SBQQ__Quote__r.Name);  
                
            }
        }
        return parentVendorCheckDone;
    }
    
    
    // Method: validateVCRCode
    // Usage : To validate vendor commit date of Quote Line 
    // Output : String indicating validation message
    // Caller : QouteValiationHandler.vSStage()
    // Test class: This method is covered by QouteValiationHandlerTest.vCRCodeCheck method
    // Defect/Story/Author: TCS-mali2-SDT-39632-Added
    public Static String validateVCRCode(List<SBQQ__QuoteLine__c> quoteLines)
    {
        Set<string> vCRCodeErrorSet = new set<string>();  
        String vCRCodeErrorMessage = ''; 
        
        for(SBQQ__QuoteLine__c qLine: quoteLines) { 
            //Changes related to SDT-39632 -Check for exception type, code and reason.
            String vendorName = qLine.Vendor__r.Name;
            String vendorId = qLine.Vendor__r.Parent_Vendor_ID__c;
            
            if((vendorId == Constant_Util.WM_US_VENDOR || vendorId == Constant_Util.WM_CANADA_VENDOR) && 
               qLine.VCRCode__c ==null || qLine.VCRCode__c == '')
            {
                vCRCodeErrorSet.add(qLine.SBQQ__Product__r.Name + strVCRCode + qLine.Name + strForQuote + qLine.SBQQ__Quote__r.Name);
            }
        }
        
        if(vCRCodeErrorSet.size()>0)
        {
            for(string err: vCRCodeErrorSet)
            {
                if(vCRCodeErrorMessage==''){
                    vCRCodeErrorMessage = err;
                }else{
                    vCRCodeErrorMessage= vCRCodeErrorMessage+'\n'+err;
                }
            }
        }
        
        return vCRCodeErrorMessage; 
        
    }
}
