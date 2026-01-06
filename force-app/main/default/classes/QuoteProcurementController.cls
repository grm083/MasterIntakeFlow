//Class: QuoteProcurementController
//Purpose: To return and manipulate data on the SBQQ__QuoteLine__c object
//in accordance with the business process
//Author: George R Martin III
//Date: 6/14/2021

public class QuoteProcurementController {
    
    //The Purpose of this class will be to showcase the quote lines to a user 
    //in a simple consumable interface.  Some additional bells and whistles will be added
    //to ensure that users can also append cost, price, vendor details and MAS information
    //should that be desired in future releases
    public static set<string> wasteCategorySet = new set<string>{'Waste Stream', 'Waste Category'};
    //SDT-30089 - start
    public static String specialHandling_Automatic_Reason = 'Automatically flagged by system';
    public static String specialHandling_BackDated_Reason = 'Back-dated service requested';
    //SDT-30089 - end
    
    //SDT-47978 - Added variable by Yugandhar Adem : START
    public static String specialHandling_Delivery_Not_Needed = 'Delivery not needed/container on site';
    //SDT-47978 - Added variable by Yugandhar Adem : END

    //TCS-pkulkarn-SDT-33303-Added variables to store Error message values.
    public static String strVendorMissing = 'Vendor missing';
    public static String strMASLibraryOrCode = 'Missing MAS Library, Company Code';
    public static String strSetupComment = 'Missing Setup Comment';
    public static String strOrSetupComment = ' or Setup Comment';
    public static String strCostUOMType = 'Missing Cost Unit of Measure or Model Type';
    public static String strCostModelTypeRebate = 'Cost Model Type of Rebate must have a Cost of $0.00';
    public static String strCostMissing = 'Cost Missing';
    public static String strManagementFee = 'Unit cost should be $0.00 and vendor name should start with WM Fee if product name is Management Fee ';
    public static String strVendorInactive = 'Selected vendor is not active ';
    public static String strWMFeeUnitCost =' WM Fee charges should have a cost of 0$';
    public static String strMassIdMissing =  'MAS Unique ID is Missing';
    public static String strVCRCodeMissing =  'Vendor requires VCR Code field';//only for WM
    public static String strPriceMissing='Price cannot be blank';
    public static String strPricingMethodMissing = 'Price Model type (pricing method) must be specified';  
    public static String strWMFeeList = ' WM Fee charges requires a price greater than 0';
    //TCS-pkulkarn-SDT-33303-End
    //TCS-pkulkarn-SDT-41532-Added following two variables
    public static String strCostModelTypeSTP = 'You must enter 2 stepped cost if Cost model type is Stepped. ';
    public static String strPricingUnitMethodSTP = 'You must enter 2 stepped price if Price unit method is stepped. ';
    //TCS-pkulkarn-SDT-41532-End
    //Chandu kari - SDT-48563 Mapping for the QuotrL Line Error Messages.
    public static Map<String,String> mapOfQLErrorMsgs=  new Map<String,String>();
    public static List<String> vFStageErrorList = new List<String>();
    public static List<String> vSStageErrorList = new List<String>();
    public static List<String> vTStageErrorList = new List<String>();
    public static List<String> allStageErrorList = new List<String>();
    @AuraEnabled
    public static ProductsWrapper buildQuoteWrapper(String quoteId) {
        SBQQ__Quote__c parentQuote = [SELECT Id, SBQQ__Account__r.Parent.AccountNumber,
                                      SBQQ__Account__r.ParentId, Project__c, SBQQ__Account__c,
                                      SBQQ__Account__r.Division__c, SBQQ__Account__r.Geography__c,
                                      SBQQ__Account__r.Location_Type__c, SBQQ__Account__r.Brand__c,
                                      Case_Sub_Type__c, Case_Reason__c, Case_Type__c,
                                      SBQQ__Opportunity2__r.Case__r.Origin,
                                      SBQQ__Opportunity2__r.Case__r.Recordtype.Name, toLabel(SBQQ__Status__c),
                                      SBQQ__PrimaryContact__r.Name, SBQQ__PrimaryContact__c
                                      FROM SBQQ__Quote__c
                                      WHERE Id =: quoteId];
        ProductsWrapper pw = new ProductsWrapper();
        //TCS-SDT-31625-Added SBQQ__Quantity__c field to the query
        List<SBQQ__QuoteLine__c> headerRecords = [SELECT SBQQ__Quote__r.Case_Type__c, SBQQ__Quote__r.Name, SBQQ__Quote__c,MaterialGrade__c,
                                                  SBQQ__ProductName__c, toLabel(Duration__c),Vendor__r.Name, Vendor__r.Parent_Vendor_Id__c,
                                                  toLabel(Equipment_Size__c), SBQQ__StartDate__c, SBQQ__EndDate__c,Occurrence_Type__c, SBQQ__Quantity__c,
                                                  AssetId__c, CompanyCategoryName__c, SBQQ__Product__c, SBQQ__ProductFamily__c,SBQQ__ProductCode__c
                      							  FROM SBQQ__QuoteLine__c
                      							  WHERE SBQQ__Quote__c =: quoteId AND SBQQ__RequiredBy__c = Null];
        List<HeaderWrapper> confProducts = new List<HeaderWrapper>();
        
        for (SBQQ__QuoteLine__c header : headerRecords){
            HeaderWrapper prod = new HeaderWrapper();
            prod.caseType = parentQuote.Case_Type__c;
            prod.caseSubType = parentQuote.Case_Sub_Type__c;
            prod.caseReason = parentQuote.Case_Reason__c;
            prod.caseOrigin = parentQuote.SBQQ__Opportunity2__r.Case__r.Origin;
            prod.caseRecordType = parentQuote.SBQQ__Opportunity2__r.Case__r.Recordtype.Name;
            prod.quoteName = header.SBQQ__Quote__r.Name;
            prod.productId = header.SBQQ__Product__c;
            prod.productFamily = header.SBQQ__ProductFamily__c;
            prod.quoteID = header.SBQQ__Quote__c;
            prod.quantity = header.SBQQ__Quantity__c;
            prod.equipmentType = header.SBQQ__ProductName__c;
            prod.duration = header.Duration__c;
            prod.quoteStatus = parentQuote.SBQQ__Status__c;
            prod.equipmentSize = header.Equipment_Size__c;
            prod.selectedMaterialGrade = header.MaterialGrade__c; //SDT-37527
            prod.startDate = header.SBQQ__StartDate__c;
            prod.endDate = header.SBQQ__EndDate__c;
            prod.primaryContact = parentQuote.SBQQ__PrimaryContact__r.Name;
            prod.contactID = parentQuote.SBQQ__PrimaryContact__c;
            prod.occurrenceType = header.Occurrence_Type__c;
            prod.clientId = parentQuote.SBQQ__Account__r.ParentId;
            prod.locationId = parentQuote.SBQQ__Account__c;
            prod.locationDivision = parentQuote.SBQQ__Account__r.Division__c;
            prod.locationGeography = parentQuote.SBQQ__Account__r.Geography__c;
            prod.locationType = parentQuote.SBQQ__Account__r.Location_Type__c;
            prod.locationBrand = parentQuote.SBQQ__Account__r.Brand__c;
            prod.projectCodeId = parentQuote.Project__c;
            prod.assetId = header.AssetId__c;
	    prod.companyCategoryName = header.CompanyCategoryName__c;
	    prod.equipmentTypeCode = header.SBQQ__ProductCode__c;//SDT-38040-MAA
        prod.vendorName = header.Vendor__r.Name;
        prod.parentVendorId =  header.Vendor__r.Parent_Vendor_Id__c;
            
            List<SBQQ__QuoteLine__c> detailRecords = [SELECT SBQQ__ProductName__c, SBQQ__ProductCode__c, SBQQ__ProductFamily__c
           											  FROM SBQQ__QuoteLine__c
                      								  WHERE (SBQQ__RequiredBy__c =: header.Id OR SBQQ__RequiredBy__r.SBQQ__RequiredBy__c =: header.Id) AND SBQQ__ProductFamily__c != 'Waste Category'];
            for (SBQQ__QuoteLine__c detail: detailRecords) {
                //Immediately store the material type to the header record and skip to the next
                //iteration
                if (detail.SBQQ__ProductFamily__c == 'Waste Stream') {
                    prod.materialType = detail.SBQQ__ProductName__c;
                    prod.materialTypeCode = detail.SBQQ__ProductCode__c;
                    break;
                }
            }
           confProducts.add(prod);
            
        }
        pw.configuredProducts = confProducts;
        return pw;
    }     
    //sdt-31000
    
    @AuraEnabled
    public static List<nteWrapper> showErrorWrapper(String quoteId, List<Id> parentQLineIds) {
    //List<nteWrapper> pwList = new List<nteWrapper>();
    List<nteWrapper> nWrapperList = new List<nteWrapper>();
    List<SBQQ__Quote__c> quotesWithQuoteLinesList = new List<SBQQ__Quote__c>();
    map<id,List<SBQQ__QuoteLine__c>> quoteIdQuoteLineListMap = new map<id,List<SBQQ__QuoteLine__c>>();
    List<SBQQ__QuoteLine__c> updateQList = new List<SBQQ__QuoteLine__c>();
    List<Business_Rule__c> brList = new List<Business_Rule__c>();
    map<Id,Business_Rule__c> reqInfomap = new map<Id,Business_Rule__c>();
    List<Business_Rule__c> BRWithServiceApproverList= new List<Business_Rule__c>();
    List<service_approver__c> srList= new List<service_approver__c>();
    set<Id> recordTypeIdSet = new set<Id>();
    Id brIdSet;
    String CaseNum;
    boolean nteLimitExceeded  = false;
    boolean quoteUpdate = false;
    boolean success = false;
    boolean brWithNTE = false;
    List<string> qlineList = new List<string>();
    String qlineString;
    boolean updateFlagNTE = false;
        //SDT-37527
        quotesWithQuoteLinesList = [SELECT Id,Case_Number__c,is_NTE_Quote__c,Project__c, Case_record_Type__c,Business_Rule__c, SBQQ__Status__c, (SELECT id,Name,ErrorComments__c, Occurrence_Type__c, Schedule_Frequency__c, Service_Days__c,SBQQ__Cost__c,Vendor__c, Equipment_Size__c, MaterialGrade__c,
                                                                                                                                                 SBQQ__RequiredBy__c, SBQQ__RequiredBy__r.SBQQ__ProductFamily__c, SBQQ__Product__R.Name, 
                                                                                                                                                 SBQQ__RequiredBy__r.Equipment_Size__c,SBQQ__ListPrice__c,NTE_amount_on_SR__c,SBQQ__ProductName__c,SBQQ__MaximumPrice__c, SBQQ__RequiredBy__r.AssetId__r.Equipment_Size__c, AssetId__c
                                                                                                                                                 FROM SBQQ__LineItems__r WHERE SBQQ__ProductFamily__c NOT IN: wasteCategorySet  
                                                                                                                                                 AND Bypass_Acorn_Integration__c = false and SBQQ__RequiredBy__c IN :parentQLineIds) FROM SBQQ__Quote__c WHERE id =: quoteId];
        
        System.debug('quotesWithQuoteLinesList^^^ ' +quotesWithQuoteLinesList);
        
        
        if(QuotesWithQuoteLinesList[0].Case_Number__c != null){
            CaseNum = QuotesWithQuoteLinesList[0].Case_Number__c;
        }
        System.debug('CaseNum^^^ ' +CaseNum);
        
        List<Case> csObj = [Select Id,Client__c,Location__c,CaseNumber,Location__r.Location_Type__c,Location__r.Geography__c,
                            Location__r.Division__c,Location__r.Brand__c,AssetId,Case_Type__c,Case_Sub_Type__c,Case_Reason__c from Case where CaseNumber =:CaseNum];
        System.debug('csObj^^^ ' +csObj);
        Id reqInfoRecTypeId = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get('Approval').getRecordTypeId();
        //recordTypeIdSet.add(reqInfoRecTypeId);
         System.debug('recordTypeIdSet^^^ ' +recordTypeIdSet);
               
        
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
                BRWithServiceApproverList= brList;
                srList = [SELECT id,NTE_Amount__c,Service_Type__c,RecordType.Name,Active__c from service_approver__c WHERE RecordType.Name = 'NTE Approval'
                                    AND Active__c = true AND Business_Rule__c =: brIdSet];
            }
        }
        
        for(SBQQ__Quote__c quote: quotesWithQuoteLinesList){
            if(quote.SBQQ__LineItems__r.size()>0){
                quoteIdQuoteLineListMap.put(quote.id, quote.SBQQ__LineItems__r);
                
            }
        }
        system.debug('quoteIdQuoteLineListMap >'+ quoteIdQuoteLineListMap);
        system.debug('srList >'+ srList);
        if(!srList.isEmpty()){
            for(SBQQ__Quote__c qt: quotesWithQuoteLinesList){
                System.debug('here3^^^ ' + qt);
                for(SBQQ__QuoteLine__c qLine: quoteIdQuoteLineListMap.get(qt.Id)){
                    if(!srList.isEmpty() && srList.size()>0){
                        for(Service_approver__c sr :srList){
                            system.debug('sr >'+ sr);
                            if( (qt.SBQQ__Status__c == 'Cost Configured' || qt.SBQQ__Status__c == 'Product Configured' || qt.SBQQ__Status__c == 'Price Configured') && qLine.SBQQ__ListPrice__c != null  && qLine.SBQQ__ListPrice__c > sr.NTE_Amount__c && qLine.SBQQ__ProductName__c == sr.Service_Type__c){
                                System.debug('here2^^^ '  + sr);
                                nteLimitExceeded = true;
                                nteWrapper nWrapper = new nteWrapper();
                                nWrapper.showMessage = nteLimitExceeded;
                                nWrapper.qlineDetails = qLine.Name;
                                nWrapper.qlineId = qLine.SBQQ__RequiredBy__c;
                                nWrapperList.add(nWrapper);
                                //qlineList.add(qLine.Name);
                                //qlineString = String.join(nWrapper.qlineDetails,',');
                                if(qline.NTE_amount_on_SR__c != sr.NTE_Amount__c){
                                    qline.NTE_amount_on_SR__c = sr.NTE_Amount__c;
                                    updateFlagNTE = true;
                                    updateQList.add(qline);
                                }
                            }
                        }
                        // if(qlineList!= null){
                        //     qlineString = String.join(qlineList,',');
                        // }
                    }
                }
                if((qt.SBQQ__Status__c == 'Cost Configured' || qt.SBQQ__Status__c == 'Product Configured' || qt.SBQQ__Status__c == 'Price Configured') && nteLimitExceeded ){
                    //nWrapper.showMessage = true;
                    //nWrapper.qlineDetails = qlineString;
                    if(qt.is_NTE_Quote__c ==false){
                        qt.is_NTE_Quote__c =true;
                        quoteUpdate = true;
                    }
                } 
                else{
                    //nWrapper.showMessage = false;
                    if(qt.is_NTE_Quote__c ==true){
                        qt.is_NTE_Quote__c =false;
                        quoteUpdate = true;
                    }
                } 
            }
            if(updateFlagNTE && nteLimitExceeded){
                update updateQList;
            }
            if(quoteUpdate){
                update quotesWithQuoteLinesList;
            }
        }
        System.debug('here1^^^ ' + nWrapperList);
        return nWrapperList;
    }
    /*
  	 * @Name          getMaterialTypes
  	 * @Vendor		  TCS
  	 * @Author        WM - Rajan Sajani
  	 * @Date          2/22/202a
  	 * @param		   material : String
  	 * @return		  List<Map<String, String>>
  	 * @story		  SDT-7527
  	 * @Description   It passes material grade type valuesand label for picklist 
  	 */
    @AuraEnabled(cacheable=true)
  
     public static List<Map<String, String>> getMaterialTypes(String material) {
       List<Map<String, String>> grades = new List<Map<String, String>>();
         grades.add(new Map<String,String>{'label'=>'--None--','value'=>''});
       for (Material_type_Material_Grade_mapping__mdt m : [SELECT Material_Type__c,Material_Grade__c,Material_Grade_Code__c  FROM Material_type_Material_Grade_mapping__mdt WHERE Material_Type__c = :material]) {
           Map<String, String> grade = new Map<String, String>();
           grade.put('label', m.Material_Grade__c);
           grade.put('value', m.Material_Grade__c);
           grades.add(grade);
       }
       return grades;
   }

//sdt-31000
       
    @AuraEnabled
    public static ProductsWrapper buildWrapper(String quoteId) {
        
        
        
        SBQQ__Quote__c parentQuote = [SELECT Id, SBQQ__Account__r.Parent.AccountNumber
                               FROM SBQQ__Quote__c
                               WHERE Id =: quoteId];
        
        map<String, String> companyCategoriesMap = AcornCompanyDetails.getAcornCCMap(parentQuote.SBQQ__Account__r.Parent.AccountNumber);
        
        //Define the new product wrapper and store the picklist values in the 
        //highest level of the wrapper class
        ProductsWrapper pw = new ProductsWrapper();
        pw.disableMAS = TRUE;
        pw.disableCost = TRUE;
        pw.disablePrice = TRUE;
        //pw = setUserAccess(pw);
        
        //Store the header records in a list for iteration and further query
        List<SBQQ__QuoteLine__c> headerRecords = getQuoteProducts(quoteId);
        Map<Id, Boolean> bundleStatusMap = PricingRequestSTPProcess.getQuoteProductDetail(quoteId);
        
        if (headerRecords.size() == 0 || headerRecords == Null) {
            pw.singleQuoteId = quoteId;
            return pw;
        }
        
        List<HeaderWrapper> confProducts = new List<HeaderWrapper>();
        
        for (SBQQ__QuoteLine__c header : headerRecords){
            HeaderWrapper prod = new HeaderWrapper();
            
            //Store key attributes related to the product (less material types)
            //SDT 33101
            prod.quoteOnlyCopyOf = header.Quote_Only_Copy_of__c;
            //TCS adding caseType for SDT-27578 
            prod.caseType = header.SBQQ__Quote__r.Case_Type__c;
            prod.caseRecordType = header.SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__r.Recordtype.Name;
            prod.parentId = header.Id;
            prod.locationId = header.Account__c;
            prod.quoteLineName = header.Name;
            prod.companyCategories = companyCategoriesMap;
            prod.productId = header.SBQQ__Product__c;
            prod.equipmentType = header.SBQQ__ProductName__c;
            prod.equipmentTypeCode = header.SBQQ__ProductCode__c;
            prod.equipmentSize = header.Equipment_Size__c;
            prod.duration = header.Duration__c;
            prod.startDate = header.SBQQ__StartDate__c;
	    DateTime SLADateTime = QuoteFavoritesController.determineSLA(header.Id);
            if(SLADateTime != null){
             	prod.originalSLAstartDate = SLADateTime.date();
            }	
            prod.slaOverrideReason = header.SLA_Override_Reason__c;
            prod.slaOverrideComment = header.SLA_Override_Comment__c ;
            prod.endDate = header.SBQQ__EndDate__c;
            prod.companyCategory = header.CompanyCategoryCode__c;
	    prod.selectedMaterialGrade = header.MaterialGrade__c; //SDT-37527

            prod.companyCategoryName = header.CompanyCategoryName__c;
            prod.vendorId = header.Vendor__c;
            prod.vendorName = header.Vendor__r.Name;
            prod.vendorNumber = header.Vendor__r.AccountNumber;
            prod.vendorBU = header.Vendor__r.Vendor_Business_Unit__c;
            //SDT-29645 - Start
            prod.vendorFacilityCode = header.Vendor__r.FacilityCode__c;
            //SDT-29645 - End
            prod.parentVendorId =  header.Vendor__r.Parent_Vendor_Id__c;
            prod.quoteStatus = header.SBQQ__Quote__r.SBQQ__Status__c;
            prod.quoteName = header.SBQQ__Quote__r.Name;
            prod.quoteIdNav = '/' + header.SBQQ__Quote__c;
            prod.sCode = header.sCode__c;
            //SDT 41407
            prod.monthlyScheduleDetails = QuoteLineServices.generateMonthlyScheduleDetails(header);
            prod.lineFrequency = header.Service_Schedule__c;
            prod.quoteLineNumber = header.SBQQ__Number__c;
            prod.wasteDescription = header.Description_of_Waste__c;
            prod.Quantity = header.SBQQ__Quantity__c;
            prod.quantityEditable = header.SBQQ__Product__r.SBQQ__QuantityEditable__c;
            
            //Readded for 20079 after overwrite for 20085
            prod.quoteID = header.SBQQ__Quote__c;
            prod.primaryContact = header.SBQQ__Quote__r.SBQQ__PrimaryContact__r.Name;
            prod.contactID = header.SBQQ__Quote__r.SBQQ__PrimaryContact__r.Id;
            prod.occurrenceType = header.Occurrence_Type__c;
            prod.productFamily = header.SBQQ__ProductFamily__c;
            prod.bundleProcuredStatus = header.BundleProcuredStatus__c;
            prod.deliveryOverrideReason = header.AAV_Delivery_Override_Reason__c; //SDT-30864 : Asset Availabilty
            prod.deliveryOverrideComment = header.AAV_Delivery_Override_Comment__c; //SDT-30864 : Asset Availabilty
            prod.serviceOverrideReason = header.AAV_Service_Override_Reason__c; //SDT-29100 : Asset Availabilty
            prod.serviceOverrideComment = header.AAV_Service_Day_Override_Comment__c; //SDT-29100 : Asset Availabilty
            prod.nteWarnning=false; // Changes for 31000
            prod.nteWarnningMessage=''; // Changes for 31000
            
            //SDT-41473 - 42045
            Id caseId = header.SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__c;
            prod.isHaulAway = HaulAwayService.getIsHaulAwayService(caseId);

            //COD SDT-20244 POC
            if (header.Certificate_of_Destruction__c == true || header.Certificate_of_Disposal__c == true) {
                prod.isCOD = TRUE;
            } else {
                prod.isCOD = FALSE;
            }
            
            if (header.Vendor__r.Contact_Manually_Vendor__c == TRUE) {
                prod.vendorManualDispatch = 'Yes';
            }else {
                prod.vendorManualDispatch = 'No';
            }
            if (header.Vendor__r.Prepayment_Required__c == 'Yes' && header.Vendor__r.Prepayment_Required__c != Null) {
                prod.vendorPrepayment = 'Yes';
            } else {
                prod.vendorPrepayment = 'No';
            }
            //prod.vendorPrepayment = header.Vendor__r.Prepayment_Required__c;
            prod.quoteOnly = header.SBQQ__Quote__r.Quote_Only__c;
            //SDT33101
            prod.quoteType = header.SBQQ__Quote__r.SBQQ__Type__c; 
            prod.customerApproval = header.CustomerApproval__c;
            //SDT33101 End
            
            //Store MAS information for the product where already populated
            MASWrapper prodMAS = new MASWrapper();
            prodMAS.MASLibrary = header.MASLibrary__c;
            prodMAS.MASCompany = header.MASCompany__c;
            prodMAS.MASAccount = header.MASAccount__c;
            prodMAS.MASUniqueId = header.MASCustomerUniqueId__c;
            prodMAS.MASServiceLine = header.MASServiceLine__c;
            prodMAS.MASBox = header.MASBox__c;
            // Commented 'SetupComment__c' field reference for story SDT-25787 to change the DataType from 'Text(255)' to 'Long Text(1500)' Will uncomment after DataType is changed
            prodMAS.MASComment = header.SetupComment__c;
            prodMAS.MASBypassPrice = header.BypassPriceReview__c;
            prodMAS.MASDoNotCreate = header.DoNotCreateMASTicket__c;
            //SDT-29392 start
            prodMAS.DoNotCreateTaskGridTickets = header.DoNotCreateTaskGridTickets__c;
            //SDT-29392 end
            prodMAS.VCRCode = header.VCRCode__c;
            prod.MAS = prodMAS;
            
            //Store detail records
            List<DetailWrapper> prodDetails = new List<DetailWrapper>();
            List<WOWrapper> workOrders = new List<WOWrapper>();
            List<Quote_Order__c> quoteOrders = getOrders(header.Id);
            for (Quote_Order__c qo : quoteOrders) {
                WOWrapper woInstance = new WOWrapper();
                woInstance.serviceDate = qo.Service_Date__c;
                woInstance.serviceType = qo.Service_Type__c;
                woInstance.instructions = qo.Acorn_Instructions__c;
                workOrders.add(woInstance);
            }
            
            prod.workOrders = workOrders;
            
            String costCompareMessage = '';
            List<SBQQ__QuoteLine__c> detailRecords = getQuoteDetails(header.Id);
            for (SBQQ__QuoteLine__c detail: detailRecords) {
                
                //Immediately store the material type to the header record and skip to the next
                //iteration
                if (detail.SBQQ__ProductFamily__c == 'Waste Stream') {
                    prod.materialType = detail.SBQQ__ProductName__c;
                    prod.materialTypeCode = detail.SBQQ__ProductCode__c;
                    continue;
                }
                
                DetailWrapper detailInstance = new DetailWrapper();
                detailInstance.quoteLineName = detail.Name;
                detailInstance.componentId = detail.Id;
                detailInstance.componentType = detail.SBQQ__ProductName__c;
                detailInstance.componentQuantity = Integer.valueOf(detail.SBQQ__Quantity__c);
                detailInstance.componentStartDate = detail.SBQQ__StartDate__c;
                detailInstance.componentEndDate = detail.SBQQ__EndDate__c;
                detailInstance.occurrenceType = detail.Occurrence_Type__c;
                detailInstance.scheduleFrequency = detail.Schedule_Frequency__c;
                detailInstance.frequencyInterval = detail.Frequency_Interval__c;
                detailInstance.serviceDays = detail.Service_Days__c;
                detailInstance.errorMessage = detail.ErrorComments__c;
                //Chandu Kari--SDT-48563
                detailInstance.qLErrorMessages = mapOfQLErrorMsgs.get(detail.Name);
                
                if(String.isBlank(detail.ErrorComments__c)) {
                    detailInstance.iconName = 'utility:check';
                    detailInstance.errorMessage = 'All validations passed';
                } else {
                    detailInstance.iconName = 'utility:warning';
                    prod.lineError = TRUE;
                }
                
                //Create the cost details
                detailInstance.vendorCost = detail.SBQQ__UnitCost__c;
                detailInstance.costCurrencyCode = detail.SBQQ__UnitCost__c != null ? detail.CurrencyIsoCode : Constant_Util.EMPTY_STRING;                 
                detailInstance.costUOM = detail.Cost_Unit_of_Measure__c;
                detailInstance.costMin = detail.CostMinQuantity__c;
                
                //Create the price details
                detailInstance.customerPrice = detail.SBQQ__ListPrice__c;
                detailInstance.priceCurrencyCode = detail.SBQQ__ListPrice__c != null ? detail.CurrencyIsoCode : Constant_Util.EMPTY_STRING;                 
                detailInstance.priceUOM = detail.PriceUOM__c;
                detailInstance.priceMin = detail.PriceMinQuantity__c;

                //Changes for SDT-26044
                if(detail.SBQQ__ProductCode__c == 'H')
                {
                    costCompareMessage = detail.Cost_Compare_Message__c;
                }                
                prodDetails.add(detailInstance);
            }
            prod.procurementErrorMessage = bundleStatusMap.get(header.Id) == true ? '' : header.ProcurementErrorMessage__c;
            //Changes for SDT-26044
            if(!String.isEmpty(costCompareMessage))
            {
                if(prod.procurementErrorMessage == Constant_Util.QLI_PROCURMENT_SUCCESS)
                    prod.procurementErrorMessage =  costCompareMessage;
                else
                    prod.procurementErrorMessage += '\n' + costCompareMessage;
            }
            
             //SDT-31246  && SDT-31583 
             if(header.Availability_Flag__c != null){
                prod.procurementErrorMessage = AAV_AvailabilityUtility.getAvailabilityBellIconMessage(header, prod.procurementErrorMessage);                
                //system.debug('Test Availability MSG '+ prod.procurementErrorMessage );
            }
            //END

           prod.details = prodDetails;
            
            confProducts.add(prod);
            
        }
        
        pw.configuredProducts = confProducts;
        
        /*Debugging only - START
        SBQQ__Quote__c q = [SELECT Id, ErrorComments__c
                            FROM SBQQ__Quote__c
                            WHERE Id =: quoteId];
        q.ErrorComments__c = JSON.serialize(pw);
        update q; */
        //Debuggin only - END
        
        return pw;
    }
    
    //STARTING HERE - MAS methods for retrival and writing to quote lines
    //Returns the MAS Library and Company Code details for user selection and entry
    //SDT-29645 - Start
    /*
    @AuraEnabled
    public static List<AggregateResult> returnMASDetails(String businessUnit) {
        
        List<AggregateResult> MASDetails = new List<AggregateResult>();
        
        MASDetails = [SELECT MAS_Library__c, MAS_Company_Code__c, MAS_Line_of_Business__c, Bypass_Price_Review__c
                      FROM MAS_Setup_Detail__c
                      WHERE Business_Unit_Number__c =: businessUnit
                      GROUP BY MAS_Library__c, MAS_Company_Code__c, MAS_Line_of_Business__c, Bypass_Price_Review__c];
        
        return MASDetails;
        
    }*/
    //SDT-29645 - End
    //SDT-29645 - Start
    @AuraEnabled
    public static List<AggregateResult> returnUniqueMASDetails(Id quoteLineId) {
        
        SBQQ__QuoteLine__c parentLine = null;
        boolean newServiceCase = false;
        string lineOfBusiness;
        List<AggregateResult> MASDetails = new List<AggregateResult>();
        string businessUnit;


        List<SBQQ__QuoteLine__c> quoteLines = getQuoteLineMASDetails(quoteLineId);

        if(!quoteLines.isEmpty() && quoteLines.size()>0){
            parentLine = quoteLines[0];
        }

        if(parentLine != null){

            if(parentLine.SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__r.RecordType.Name == Constant_Util.New_Service_Case){
                newServiceCase = true;
            }
            if(parentLine.SBQQ__Product__r.Family == Constant_Util.ROLLOFF){
                lineOfBusiness = 'O';
            }
            else if(parentLine.SBQQ__Product__r.Family == Constant_Util.COMMERCIAL){
                lineOfBusiness = 'C';
            }
            
            if(parentLine.Vendor__r.Vendor_Business_Unit__c != null )
                {
                    businessUnit = parentLine.Vendor__r.Vendor_Business_Unit__c;
                }
            
            
            if(parentLine.Vendor__r.FacilityCode__c != null){
                MASDetails = [SELECT MAS_Library__c, MAS_Company_Code__c, MAS_Line_of_Business__c, Bypass_Price_Review__c
                      FROM MAS_Setup_Detail__c
                      Where (Facility_Id__c =:parentLine.Vendor__r.FacilityCode__c and 
                            MAS_Line_of_Business__c =:lineOfBusiness and 
                            Valid_For_New_Service__c =:newServiceCase) 
                      GROUP BY MAS_Library__c, MAS_Company_Code__c, MAS_Line_of_Business__c, Bypass_Price_Review__c];
            }

            if(MASDetails.size() == 0){
                MASDetails = [SELECT MAS_Library__c, MAS_Company_Code__c, MAS_Line_of_Business__c, Bypass_Price_Review__c
                      FROM MAS_Setup_Detail__c
                      Where (Business_Unit_Number__c =:businessUnit and
                            MAS_Line_of_Business__c =:lineOfBusiness
                            )
                      GROUP BY MAS_Library__c, MAS_Company_Code__c, MAS_Line_of_Business__c, Bypass_Price_Review__c];
            }
        }
        
        
        return MASDetails;
        
    }
    //SDT-29645 - End
    
    @AuraEnabled
    public static Boolean updateVendorDetails(HeaderWrapper headerRecord) {
        
        Boolean success;
        
        List<SBQQ__QuoteLine__c> QuoteLines = [SELECT Id, Vendor__c,sCode__c
                                               FROM SBQQ__QuoteLine__c
                                               WHERE Id =: headerRecord.parentId OR SBQQ__RequiredBy__c =: headerRecord.parentId OR
                                               SBQQ__RequiredBy__r.SBQQ__RequiredBy__c =: headerRecord.parentId];
        
        system.debug('Selected s-code is: ' + headerRecord.sCode);
        system.debug('Selected vendor is: ' + headerRecord.vendorName);
        
        for (SBQQ__QuoteLine__c QuoteLine: QuoteLines) {
            QuoteLine.Vendor__c = headerRecord.vendorId;
            QuoteLine.sCode__c = headerRecord.sCode;
        }
        
        try{
            update QuoteLines;
            success = true;
        } catch (exception e) {
            system.debug(e.getMessage());
            success = false;
        }
        
        return success;
        
    }
    
    @AuraEnabled
    public static Boolean updateCompanyCategories(HeaderWrapper headerRecord) {
        
        Boolean success;
        
        List<SBQQ__QuoteLine__c> QuoteLines = [SELECT Id, CompanyCategoryCode__c
                                               FROM SBQQ__QuoteLine__c
                                               WHERE Id =: headerRecord.parentId OR SBQQ__RequiredBy__c =: headerRecord.parentId OR
                                               SBQQ__RequiredBy__r.SBQQ__RequiredBy__c =: headerRecord.parentId];
        
        for (SBQQ__QuoteLine__c QuoteLine: QuoteLines) {
            QuoteLine.CompanyCategoryCode__c = headerRecord.companyCategory;
        }
        
        try{
            update QuoteLines;
            success = true;
        } catch (exception e) {
            system.debug(e.getMessage());
            success = false;
        }
        
        return success;
        
    }
    
    //The Lightning Component will return the HeaderWrapper portion of the total
    //wrapper which will enable us to write the values directly to the quote lines.
    //This will update every quote line with the same MAS details for consistency.
    @AuraEnabled
    public static MASResponseWrapper writeMASDetails(HeaderWrapper headerRecord) {
        
        Boolean success;
        
        List<SBQQ__QuoteLine__c> QuoteHeaders = [SELECT Id, MASLibrary__c, MASCompany__c, MASAccount__c, MASCustomerUniqueId__c, MASServiceLine__c, 
                                                 MASBox__c, BypassPriceReview__c, BypassMASServiceChange__c, SetupComment__c, DoNotCreateMASTicket__c,
                                                 DoNotCreateTaskGridTickets__c,//added DoNotCreateTaskGridTickets__c for SDT 29392
                                                 // Commented 'SetupComment__c' field reference for story SDT-25787 to change the DataType from 'Text(255)' to 'Long Text(1500)' Will uncomment after DataType is changed
                                                 //MASBox__c, BypassPriceReview__c, BypassMASServiceChange__c, DoNotCreateMASTicket__c,
                                                 VCRCode__c
                                                 FROM SBQQ__QuoteLine__c
                                                 WHERE Id =: headerRecord.parentId OR SBQQ__RequiredBy__c =: headerRecord.parentId OR
                                                 SBQQ__RequiredBy__r.SBQQ__RequiredBy__c =: headerRecord.parentId];
        
        for (SBQQ__QuoteLine__c QuoteHeader: QuoteHeaders ) {
            if(!String.isBlank(headerRecord.MAS.MASLibrary))
                QuoteHeader.MASLibrary__c = headerRecord.MAS.MASLibrary;
            if(!String.isBlank(headerRecord.MAS.MASCompany))
                QuoteHeader.MASCompany__c = headerRecord.MAS.MASCompany;
            if(headerRecord.MAS.MASAccount != null)
                QuoteHeader.MASAccount__c = headerRecord.MAS.MASAccount;
            if(headerRecord.MAS.MASUniqueId != null)
                QuoteHeader.MASCustomerUniqueId__c = headerRecord.MAS.MASUniqueId;
            if(headerRecord.MAS.MASServiceLine != null)
                QuoteHeader.MASServiceLine__c = headerRecord.MAS.MASServiceLine;
            if(!String.isBlank(headerRecord.MAS.MASBox))
                QuoteHeader.MASBox__c = headerRecord.MAS.MASBox;
            // Commented 'SetupComment__c' field reference for story SDT-25787 to change the DataType from 'Text(255)' to 'Long Text(1500)' Will uncomment after DataType is changed
            if(!String.isBlank(headerRecord.MAS.MASComment))
                QuoteHeader.SetupComment__c = headerRecord.MAS.MASComment;
            QuoteHeader.BypassPriceReview__c = headerRecord.MAS.MASBypassPrice;
            QuoteHeader.DoNotCreateMASTicket__c = headerRecord.MAS.MASDoNotCreate;
            //SDT 29392 start
            QuoteHeader.DoNotCreateTaskGridTickets__c = headerRecord.MAS.DoNotCreateTaskGridTickets;
            //SDT 29392 end
            if(!String.isBlank(headerRecord.MAS.VCRCode))
                QuoteHeader.VCRCode__c = headerRecord.MAS.VCRCode;
        }
        
        MASResponseWrapper response = new MASResponseWrapper();
        SObjectAccessDecision decision = Security.stripInaccessible(AccessType.UPDATABLE, QuoteHeaders);
        try{
            //update QuoteHeaders;
            if(decision.getRemovedFields().size() > 0){
                response.ErrorMessage='You do not have access to MAS fields';
                response.IsSuccess = false;
                return response;
            }
            else{
                update decision.getRecords();
                response.IsSuccess = true;
            }
        } catch (exception e) {
            system.debug(e.getMessage());
            response.IsSuccess = false;
            response.ErrorMessage= e.getMessage();
        }
        
        return response;
        
    }
/*
  	 * @Name          getBypassPriceReview
  	 * @Vendor		  TCS
  	 * @Author        WM - Jatan Sharma
  	 * @Date          13/09/2023
  	 * @param		  quoteLineId : Id, masLibrary : String
  	 * @return		  boolean
  	 * @story		  SDT-31627
  	 * @Description   It sets BY Pass review flag checked/unchecked based on closed market, parent vendor and MAS libraries 
  	 */

    @AuraEnabled
    public static boolean bypassPriceReview(id quoteLineId, string masLibrary){
        boolean byPassReviewFlag;
        List<SBQQ__QuoteLine__c> quoteLineList = [SELECT Id,SBQQ__RequiredBy__c,BypassPriceReview__c,sCode__c,Vendor__r.Parent_Vendor_ID__c,SBQQ__Quote__r.Name, Name,
                                                 (SELECT id, AAV_APIRequestOutput__c from Asset_Availabilities__r) 
                                                  FROM SBQQ__QuoteLine__c
                                                  WHERE Id =:quoteLineId ];

          for(SBQQ__QuoteLine__c quoteLine : quoteLineList)
          {
            if(quoteLine.SBQQ__RequiredBy__c == null)
            {
                byPassReviewFlag = quoteLine.BypassPriceReview__c;
                for(AAV_Asset_Availability__c availabilityOutput : quoteLine.Asset_Availabilities__r)
                {
                    if(availabilityOutput!=null){
                        AvailabilityAPIJsonDeserialize availabilityData ;
                        try{
                        availabilityData = AvailabilityAPIJsonDeserialize.parse(availabilityOutput.AAV_APIRequestOutput__c);
                            if(availabilityData.data != null && availabilityData.data.suppliers != null && availabilityData.data.suppliers.size() > 0){
                        AvailabilityAPIJsonDeserialize.cls_suppliers supplier = availabilityData.data.suppliers[0];
                        if(supplier!=null){
                            if(supplier.contractType!=null ){
                             
                            return byPassReviewFlag = PricingRequestSTPProcess.getBypassPriceReview( supplier.contractType, quoteline.Vendor__r.Parent_Vendor_ID__c, masLibrary );
                            }
                        }
                            }
                        }catch(Exception ex){
                            
                            String appName = 'QuoteProcurementController By Pass Review Availiability parser failed for Quote '+ quoteLine.SBQQ__Quote__r.Name + ' QuoteLine '+ quoteLine.Name;
                            STPExceptionUtil.setStepByStepExceptionObj('bypassPriceReview', appName,ex.getMessage());
                        }
                        
                        
                        
                    }
                   
                }
                if(quoteline.sCode__c == 'FRCH'){
                        return byPassReviewFlag = PricingRequestSTPProcess.getBypassPriceReview( 'WM Franchise',  quoteline.Vendor__r.Parent_Vendor_ID__c, masLibrary );
                    }
            }
        }
        return byPassReviewFlag;
    }
    
    //STARTING HERE - Utility classes that are utilized to construct the wrapper class
    //Returns the header records configured for the quote for storage in the wrapper class
    public static List<SBQQ__QuoteLine__c> getQuoteProducts(Id quoteId) {
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        //SDT 33101 Quote_Only_Copy_of__c added
        //SDT-37527 field add in query
        quoteLines = [SELECT Id,PricingUnitMethod__c, SBQQ__Quote__c,Vendor__r.Status__c,Vendor_Commit_Date__c ,SBQQ__Quote__r.STP__c, SBQQ__ListPrice__c, SBQQ__UnitCost__c, SBQQ__ProductName__c, SBQQ__ProductFamily__c, SBQQ__ProductCode__c, 
                      Vendor__c, Vendor__r.Vendor_Business_Unit__c, Vendor__r.Parent_Vendor_Id__c, Vendor__r.Name, Vendor__r.AccountNumber,
                      Occurrence_Type__c, Schedule_Frequency__c, Frequency_Interval__c, Service_Days__c, SBQQ__Quantity__c, Name,
                      PriceUOM__c, PriceMinQuantity__c, SBQQ__PricingMethod__c, CostModelType__c, Cost_Unit_of_Measure__c, Account__c,
                      CostMinQuantity__c, MASLibrary__c, MASCompany__c, MASAccount__c, MASCustomerUniqueId__c, MASServiceLine__c, 
                      MASBox__c, BypassPriceReview__c, BypassMASServiceChange__c, SetupComment__c, DoNotCreateMASTicket__c, DoNotCreateTaskGridTickets__c, Location_Position_Name__c,
                      // Commented 'SetupComment__c' field reference for story SDT-25787 to change the DataType from 'Text(255)' to 'Long Text(1500)' Will uncomment after DataType is changed
                      //MASBox__c, BypassPriceReview__c, BypassMASServiceChange__c, DoNotCreateMASTicket__c, Location_Position_Name__c,
                      SBQQ__RequiredBy__c, toLabel(Equipment_Size__c), toLabel(Duration__c), SBQQ__StartDate__c, SBQQ__EndDate__c, sCode__c, SBQQ__RequiredBy__r.SBQQ__RequiredBy__c,
                      Vendor__r.Contact_Manually_Vendor__c, Vendor__r.Prepayment_Required__c, SBQQ__Quote__r.Case_Type__c, SBQQ__Quote__r.SBQQ__Status__c, CompanyCategoryCode__c,MaterialGrade__c,CompanyCategoryName__c,
                      SBQQ__Quote__r.SBQQ__Account__r.Parent.AccountNumber, SBQQ__Quote__r.Name, SBQQ__Quote__r.SBQQ__PrimaryContact__r.Name, 
                      SBQQ__Quote__r.SBQQ__PrimaryContact__r.Id, Certificate_of_Destruction__c, Certificate_of_Disposal__c, VCRCode__c, Service_Schedule__c,
                      SBQQ__Number__c, SBQQ__Quote__r.Quote_Only__c, Profile_Number__c, Description_of_Waste__c, SBQQ__Product__c, SBQQ__Product__r.SBQQ__QuantityEditable__c,
                      SLA_Override_Reason__c, SLA_Override_Comment__c,ProcurementErrorMessage__c,BundleProcuredStatus__c, CurrencyIsoCode,
                      SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__r.Recordtype.Name,AAV_Delivery_Override_Comment__c,AAV_Delivery_Override_Reason__c, //SDT-30864
                      AAV_Service_Override_Reason__c,AAV_Service_Day_Override_Comment__c, //SDT-29100
                      AAV_Requested_AdditionalServicesAccessor__c,AAV_Delivery_Availability__c,AAV_Service_Availability__c,Availability_Flag__c, ////SDT-29399 
                      AAV_Asset_Availability_API_Errors__c, //SDT - 31583
                      Vendor__r.FacilityCode__c //SDT-29645
                      ,Quote_Only_Copy_of__c,SBQQ__Quote__r.SBQQ__Type__c,CustomerApproval__c//SDT 33101
                      ,Day_of_Month__c,Month_Relative_Interval__c,Month_Relative__c, //SDT41407
                      SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__r.Is_Haul_Away_Service__c,SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__c //SDT-41473
                      FROM SBQQ__QuoteLine__c
                      WHERE SBQQ__Quote__c =: quoteId AND SBQQ__RequiredBy__c = Null];
        
        system.debug('Quote lines returned: ' + quoteLines.size());
        
        return quoteLines;
        
    }
    //Added for story SDT-21065
    public static List<SBQQ__QuoteLine__c> getQuoteLineMASDetails(Id quoteLineId) {
        
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        //SDT- 29645 - Vendor__c,Vendor__r.FacilityCode__c
        quoteLines = [SELECT Id,Vendor__r.Status__c,PricingUnitMethod__c,Vendor_Commit_Date__c,SBQQ__Quote__r.SBQQ__Type__c,SBQQ__Quote__r.Case_Type__c,SBQQ__Quote__r.STP__c,MASLibrary__c, MASCompany__c, MASAccount__c, MASCustomerUniqueId__c, MASServiceLine__c, 
                      MASBox__c, BypassPriceReview__c, BypassMASServiceChange__c, SetupComment__c, DoNotCreateMASTicket__c
                      ,DoNotCreateTaskGridTickets__c, SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__r.RecordType.Name//added for SDT 29392
                      // Commented 'SetupComment__c' field reference for story SDT-25787 to change the DataType from 'Text(255)' to 'Long Text(1500)' Will uncomment after DataType is changed
                      //MASBox__c, BypassPriceReview__c, BypassMASServiceChange__c,  DoNotCreateMASTicket__c
                      ,Vendor__c,Vendor__r.FacilityCode__c, Vendor__r.Vendor_Business_Unit__c,
                      SBQQ__Product__R.family
                      
                      FROM SBQQ__QuoteLine__c
                      WHERE id =: quoteLineId];
        
        return quoteLines;
        
    }
    //Returns the detail records for each header objects for storage in the wrapper class
    public static List<SBQQ__QuoteLine__c> getQuoteDetails(Id quoteLineId) {
        
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        //TCS-pkulkarn-SDT-33303-Added DoNotCreateTaskGridTickets__c to the SOQL
        //TCS-pkulkarn-SDT-41532-Added fields CostPrice1__c, CostPrice2__c, PricePrice1__c, PricePrice2__c to SOQL
        quoteLines = [SELECT Id, SBQQ__Quote__c,PricingUnitMethod__c,Vendor__r.Status__c,Vendor_Commit_Date__c, SBQQ__Quote__r.SBQQ__Type__c,SBQQ__Quote__r.Case_Type__c,SBQQ__Quote__r.STP__c,
                     SBQQ__ListPrice__c, SBQQ__UnitCost__c, SBQQ__ProductName__c, SBQQ__ProductCode__c, SBQQ__ProductFamily__c,
                      Vendor__c,Vendor__r.Vendor_Business_Unit__c, Vendor__r.Parent_Vendor_Id__c, Vendor__r.Name, Vendor__r.AccountNumber,
                      Occurrence_Type__c, Schedule_Frequency__c, Frequency_Interval__c, Service_Days__c,SBQQ__Cost__c, SBQQ__Quantity__c, Name,
                      PriceUOM__c, PriceMinQuantity__c, SBQQ__PricingMethod__c, CostModelType__c, Cost_Unit_of_Measure__c, ErrorComments__c,
                      CostMinQuantity__c, MASLibrary__c, MASCompany__c, MASAccount__c, MASCustomerUniqueId__c, MASServiceLine__c, 
                      MASBox__c, BypassPriceReview__c, BypassMASServiceChange__c, SetupComment__c, DoNotCreateMASTicket__c, Location_Position_Name__c,
                      // Commented 'SetupComment__c' field reference for story SDT-25787 to change the DataType from 'Text(255)' to 'Long Text(1500)' Will uncomment after DataType is changed
                      //MASBox__c, BypassPriceReview__c, BypassMASServiceChange__c, DoNotCreateMASTicket__c, Location_Position_Name__c,
                      SBQQ__RequiredBy__c, Equipment_Size__c, Duration__c, SBQQ__StartDate__c, SBQQ__EndDate__c, sCode__c, SBQQ__RequiredBy__r.SBQQ__RequiredBy__c,
                      SBQQ__Quote__r.SBQQ__Status__c,Bypass_Acorn_Integration__c, VCRCode__c, SBQQ__Product__c, SBQQ__Product__r.SBQQ__QuantityEditable__c,
                      Pricing_API_Method__c, CurrencyIsoCode, Cost_Compare_Message__c,IsAssetQuotelineDifferent__c,SBQQ__Quote__r.Case_record_Type__c,  //SDT-32124 - added IsAssetQuotelineDifferent__c,SBQQ__Quote__r.Case_record_Type__c 
                      SBQQ__RequiredBy__r.SBQQ__ProductName__c, SBQQ__Product__R.Name, SBQQ__RequiredBy__r.Equipment_Size__c, SBQQ__RequiredBy__r.AssetId__r.Equipment_Size__c,
                      SBQQ__RequiredBy__r.SBQQ__ProductFamily__c, AssetId__c, 
                      DoNotCreateTaskGridTickets__c, CostPrice1__c, CostPrice2__c, PricePrice1__c, PricePrice2__c
                      FROM SBQQ__QuoteLine__c
                      WHERE (SBQQ__RequiredBy__c =: quoteLineId OR SBQQ__RequiredBy__r.SBQQ__RequiredBy__c =: quoteLineId) AND SBQQ__ProductFamily__c != 'Waste Category'];
        //SDT-20085 - Yeshas K
        if(quoteLines.size()>0){
            for(SBQQ__QuoteLine__c qLine : quoteLines){
                if(!(wasteCategorySet.contains(qLine.SBQQ__ProductFamily__c)) && qLine.SBQQ__RequiredBy__c!=null && qLine.Bypass_Acorn_Integration__c == false){
                    qLine.ErrorComments__c = assignQuoteLineErrorMEssage(qLine);   
                }
            }
        }
        //update quoteLines;
        return quoteLines;
        
    }
    
    @AuraEnabled
    public static List<Quote_Order__c> getOrders (Id quoteLineId) {
        
        List<Quote_Order__c> quoteOrders = new List<Quote_Order__c>();
        
        quoteOrders = [SELECT Id, Service_Date__c, Service_Type__c, Instructions__c, Acorn_Instructions__c,
                      Quote_Line__r.Location_Position_Name__r.Container_Position__c, Quote_Line__r.Location_Position_Name__r.AlternateStreet__c
                      FROM Quote_Order__c
                      WHERE Quote_Line__c =:quoteLineId];
        
        return quoteOrders;
        
    }
    @AuraEnabled
    public static string deleteQuoteOrders(List<Quote_Order__c> quoteOrders){
        string fResult = 'SUCCESS';
        try{
            delete quoteOrders;
        }
        catch(exception ex){
            fResult = ex.getMessage();
        }
        return fResult;
    }
    
   //working for 48563
   //SDT-20085 - Yeshas K
    //modified as per 48563 shajiya
   public static string assignQuoteLineErrorMEssage(SBQQ__QuoteLine__c qLine) {
    // List to collect all error messages
    List<String> errors = new List<String>();
	vFStageErrorList.clear(); // Empties the list for every quote line
    vSStageErrorList.clear(); // Empties the list for every quote line
    vTStageErrorList.clear(); // Empties the list for every quote line
    allStageErrorList.clear(); // Empties the list for every quote line
    if (qLine.SBQQ__Quote__r.SBQQ__Status__c == 'Draft') { 
        String errMsg = vFStage(qLine);
        if (errMsg != null && errMsg != '') {
            errors.add(errMsg);  
        }
    }
 
    // Stage for 'Product Configured'
    else if (qLine.SBQQ__Quote__r.SBQQ__Status__c == 'Product Configured') { 
        String errMsg = vFStage(qLine);
        if (errMsg != null && errMsg != '') {
            errors.add(errMsg); 
        }
 
        // Now check vSStage, even if vFStage doesn't return any error
        errMsg = vSStage(qLine);
        if (errMsg != null && errMsg != '') {
            errors.add(errMsg);  
        }
    }
 
    // Stage for 'Cost Configured'
    else if (qLine.SBQQ__Quote__r.SBQQ__Status__c == 'Cost Configured') {
        // Get error message from vFStage
        String errMsg = vFStage(qLine);
        if (errMsg != null && errMsg != '') {
            errors.add(errMsg); 
        }
 
        // Now check vSStage, even if vFStage doesn't return any error
        errMsg = vSStage(qLine);
        if (errMsg != null && errMsg != '') {
            errors.add(errMsg);  
        }
 
        // Now check vTStage, even if vFStage and vSStage don't return any errors
        errMsg = vTStage(qLine);
        if (errMsg != null && errMsg != '') {
            errors.add(errMsg);  
        }
    }
    allStageErrorList.addAll(vFStageErrorList);
    allStageErrorList.addAll(vSStageErrorList);
    allStageErrorList.addAll(vTStageErrorList);
    mapOfQLErrorMsgs.put(qline.Name,String.join(allStageErrorList, '; '));
    // Join all collected error messages into a single string, separated by a semicolon
    return String.join(errors, '; ');
}
//Modified as per 48563 shajiya

    //SDT-20085 - Yeshas K
    public static string vFStage(SBQQ__QuoteLine__c qLine){
        string errMsg = '';
        if(qLine.Occurrence_Type__c=='SOC' || qLine.Occurrence_Type__c=='SCH'){
            if(qLine.Schedule_Frequency__c == '' || qLine.Schedule_Frequency__c == null){
                errMsg='Scheduled service missing a service frequency (weekly, monthly, etc.)';
                vFStageErrorList.add(errMsg);
            }else{
                if(qLine.Schedule_Frequency__c == 'W' && (qLine.Service_Days__c=='' || qLine.Service_Days__c==null) ){
                    errMsg='Weekly scheduled service missing day(s) of the week';
                     vFStageErrorList.add(errMsg);
                }
            }
        }
        //Additional validation:vendor is inactive
        
            if (((qline.SBQQ__Quote__r.SBQQ__Type__c == 'Amendment' ||qline.SBQQ__Quote__r.SBQQ__Type__c == 'Exception' || qline.SBQQ__Quote__r.SBQQ__Type__c == 'Correction' || 
                 (qline.SBQQ__Quote__r.SBQQ__Type__c == 'Quote' && qline.SBQQ__Quote__r.STP__c == FALSE ) 
                 ) || 
                 (qline.SBQQ__Quote__r.SBQQ__Type__c == 'Quote' && qline.SBQQ__Quote__r.STP__c == TRUE )
                 )&& qLine.Vendor__c != null) {
                string vendorStatus = qLine.Vendor__r.Status__c;
             // Only check vendor status if vendor is not null
             if (vendorStatus == 'Inactive') {
                errMsg = strVendorInactive;
                vFStageErrorList.add(errMsg); 
             }
            }
        return errMsg;
    }
    //SDT-20085 - Yeshas K
    public static string vSStage(SBQQ__QuoteLine__c qLine){
        string errMsg = '';
    //SDT-32124 -- add method to evaluate not new service and Quoteline changed
        if(QuoteLineServices.isQuoteLineChangedforNonNs(qLine)) {
        if(qLine.Vendor__c == null){
            errMsg=strVendorMissing;
            vSStageErrorList.add(errMsg);
        }

        else{
            //Additional Validation:vendor is In active
            
              if ((qline.SBQQ__Quote__r.SBQQ__Type__c == 'Amendment' ||qline.SBQQ__Quote__r.SBQQ__Type__c == 'Exception' || qline.SBQQ__Quote__r.SBQQ__Type__c == 'Correction' || (qline.SBQQ__Quote__r.SBQQ__Type__c == 'Quote' && qline.SBQQ__Quote__r.STP__c == FALSE) ) && qLine.Vendor__c != null) {
                string vendorStatus = qLine.Vendor__r.Status__c;
             // Only check vendor status if vendor is not null
             if (vendorStatus == 'Inactive') {
                errMsg = strVendorInactive; 
                vSStageErrorList.add(errMsg);
             }
            }
            string vendorName = qLine.Vendor__r.Name;
            
            //string vendorName = qLine.Vendor__r.Name;
            String vendorId = qLine.Vendor__r.Parent_Vendor_ID__c;	//TCS-pkulkarn-13-Mar-2024-SDT-33303-Added-Modified if condition and removed SetupComment check
            if((vendorId == Constant_Util.WM_US_VENDOR || vendorId == Constant_Util.WM_CANADA_VENDOR))
            {
            //if(vendorName.startsWithIgnoreCase('WM') && (qLine.MASLibrary__c=='' || qLine.MASLibrary__c==null || qLine.MASCompany__c=='' || qLine.MASCompany__c==null || qLine.SetupComment__c=='' || qLine.SetupComment__c==null)){
            // Commented 'SetupComment__c' field reference for story SDT-25787 to change the DataType from 'Text(255)' to 'Long Text(1500)' Will uncomment after DataType is changed
            //if(vendorName.startsWithIgnoreCase('WM') && (qLine.MASLibrary__c=='' || qLine.MASLibrary__c==null || qLine.MASCompany__c=='' || qLine.MASCompany__c==null)){
                if(qLine.MASLibrary__c=='' || qLine.MASLibrary__c==null || qLine.MASCompany__c=='' || qLine.MASCompany__c==null)
                {    
                    errMsg=strMASLibraryOrCode;
                    vSStageErrorList.add(errMsg);
                }
                //TCS-pkulkarn-13-Mar-2024-SDT-33303-Added
                if((qLine.SetupComment__c == '' || qLine.SetupComment__c == null) && qLine.DoNotCreateTaskGridTickets__c == false)
                {
                    if(errMsg.equalsIgnoreCase(Constant_Util.EMPTY_STRING) == false)
                    {
                        errMsg = strMASLibraryOrCode + strOrSetupComment;
                        vSStageErrorList.add(errMsg);
                    }
                    else
                    {
                        errMsg = strSetupComment;
                        vSStageErrorList.add(errMsg);
                    }
                }
                //TCS-pkulkarn-13-Mar-2024-SDT-33303-End
            }
             // Additional Vlaidation: for Start Date and End Date mismatch ***
            
                     Date vendorCommitDate = qLine.Vendor_Commit_Date__c; // Vendor commit date
                    // Date startDate = qLine.SBQQ__StartDate__c; // Start date from Quote Line
                     Date endDate = qLine.SBQQ__EndDate__c; // End date from Quote Line
 
            // Combined check for Vendor Commit Date or Start Date being greater than End Date
                   if (((vendorCommitDate != null && endDate != null && vendorCommitDate > endDate)) && (qline.SBQQ__Quote__r.SBQQ__Type__c == 'Amendment' || qline.SBQQ__Quote__r.SBQQ__Type__c == 'Quote' ) ) {
                        errMsg = 'End Dates must be greater than the vendor commit date';
                        vSStageErrorList.add(errMsg);
                        }


             // Additional Validation: Check if VCR Code is missing for WM vendors
             if(vendorId == Constant_Util.WM_US_VENDOR || vendorId == Constant_Util.WM_CANADA_VENDOR){
            if (( qline.SBQQ__Quote__r.SBQQ__Type__c == 'Quote' )&& vendorName != null && (qLine.VCRCode__c == null || qLine.VCRCode__c == '')) {
                errMsg = strVCRCodeMissing;
                vSStageErrorList.add(errMsg);
            }
        }
 
           /* //Additional validation: Missing Mass Unique ID validation
            if ((qline.SBQQ__Quote__r.SBQQ__Type__c == 'Amendment') && qLine.MASCustomerUniqueId__c == null || qLine.MASCustomerUniqueId__c == 0) {
                errMsg = strMassIdMissing;
            }
            */
            //Chandu Kar-SDT-48563
            
            if((qLine.Cost_Unit_of_Measure__c == '' || qLine.Cost_Unit_of_Measure__c == null) || (qLine.CostModelType__c == '' || qLine.CostModelType__c == null)){
                    vSStageErrorList.add(strCostUOMType);
                }
                        if(qLine.CostModelType__c=='STP')
                        {
                            if(qLine.CostPrice1__c==null || qLine.CostPrice2__c==null)
                            {
                                vSStageErrorList.add(strCostModelTypeSTP);
                            }
                        }
                        if(qLine.CostModelType__c=='REB')
                        {
                            if(qLine.SBQQ__UnitCost__c!=0){
                                vSStageErrorList.add(strCostModelTypeRebate);
                            }
                        }
                            if(qLine.SBQQ__UnitCost__c == null){
                                vSStageErrorList.add(strCostMissing);
                            }else{
                                if(qLine.SBQQ__ProductName__c == 'Management Fee'){
                                    //string vendorName = qLine.Vendor__r.Name;
                                    if(qLine.SBQQ__UnitCost__c!=0 || !vendorName.startsWithIgnoreCase('WM Fee')){
                                        vSStageErrorList.add(strManagementFee);
                                    }
                                }
                                //SDT- 48564 Additional Validation:Check if Vendor is "WM Fee" and Unit Cost does not equal to  0
                               else if ( (qLine.SBQQ__Quote__r.SBQQ__Type__c == 'Amendment' || qLine.SBQQ__Quote__r.SBQQ__Type__c == 'Quote' ) && !qLine.SBQQ__Quote__r.STP__c && vendorName != null && vendorName.startsWithIgnoreCase('WM Fee') && qLine.SBQQ__UnitCost__c != 0 ) {
                                     vSStageErrorList.add(strWMFeeUnitCost);
                 
                                 }
                                else{
                                    vSStageErrorList.add(validateOccurence(qLine));
                                }
                            }
            //Chandu Kari end
            if(errMsg.equalsIgnoreCase(Constant_Util.EMPTY_STRING))
            {
                if((qLine.Cost_Unit_of_Measure__c == '' || qLine.Cost_Unit_of_Measure__c == null) || (qLine.CostModelType__c == '' || qLine.CostModelType__c == null)){
                    errMsg = strCostUOMType;
                    vSStageErrorList.add(errMsg);
                }
                else{
                    //TCS-pkulkarn-SDT-41532-Added for showing validation error on Configured Products section on Quote Page
                        //qLine.CostModelType__c=='REB' check moved to else if part
                        if(qLine.CostModelType__c=='STP')
                        {
                            if(qLine.CostPrice1__c==null || qLine.CostPrice2__c==null)
                            {
                                errMsg = strCostModelTypeSTP;
                                vSStageErrorList.add(errMsg);
                            }
                        }
                        //TCS-pkulkarn-SDT-41532-End
                        else if(qLine.CostModelType__c=='REB')
                        {
                            if(qLine.SBQQ__UnitCost__c!=0){
                                errMsg=strCostModelTypeRebate;
                                vSStageErrorList.add(errMsg);
                            }
                        }
                        else{
                            if(qLine.SBQQ__UnitCost__c == null){
                                errMsg=strCostMissing;
                                vSStageErrorList.add(errMsg);
                            }else{
                                if(qLine.SBQQ__ProductName__c == 'Management Fee'){
                                    //string vendorName = qLine.Vendor__r.Name;
                                    if(qLine.SBQQ__UnitCost__c!=0 || !vendorName.startsWithIgnoreCase('WM Fee')){
                                        errMsg=strManagementFee;
                                        vSStageErrorList.add(errMsg);
                                    }
                                }
                                //SDT- 48564 Additional Validation:Check if Vendor is "WM Fee" and Unit Cost does not equal to  0
                               else if ( (qLine.SBQQ__Quote__r.SBQQ__Type__c == 'Amendment' || qLine.SBQQ__Quote__r.SBQQ__Type__c == 'Quote' ) && !qLine.SBQQ__Quote__r.STP__c && vendorName != null && vendorName.startsWithIgnoreCase('WM Fee') && qLine.SBQQ__UnitCost__c != 0 ) {
                
                                     errMsg = strWMFeeUnitCost ;
                                     vSStageErrorList.add(errMsg);
                 
                                 }
                                else{
                                    errMsg= validateOccurence(qLine);
                                    vSStageErrorList.add(errMsg);
                                }
                            }
                    }
                }   
            }
        }
    }
    //added as part of sdt 32753
        //alert is shown only in product configured status
        if((errMsg.equalsIgnoreCase(Constant_Util.EMPTY_STRING)) && (qLine.SBQQ__RequiredBy__r.SBQQ__ProductFamily__c.equalsIgnoreCase(Constant_Util.COMMERCIAL)) 
           && (qLine.SBQQ__Quote__r.SBQQ__Status__c.equalsIgnoreCase(QuoteLineServices.STATUS_PRODUCT_CONFIGURED)) 
           && ((qLine.SBQQ__Product__R.Name.equalsIgnoreCase(Constant_Util.REMOVAL)) 
               || (qLine.SBQQ__Product__r.Name.equalsIgnoreCase(Constant_Util.SWAPOUT_PRODUCT)))
           && (qLine.SBQQ__Quote__r.Case_record_Type__c != Constant_Util.New_Service_Case)) {
               errMsg = validateRemovalAndSwapoutSize(qLine);
               vSStageErrorList.add(errMsg);
        }
    return errMsg;
    }
    //SDT-20085 - Yeshas K
    public static string validateOccurence(SBQQ__QuoteLine__c qLine){
        string errMsg = '';
        if(qLine.Occurrence_Type__c=='SOC' || qLine.Occurrence_Type__c=='SCH'){
            //Changes related to defect SDT-48522 raised for SDT-39632 
            if(qLine.Schedule_Frequency__c=='D' || qLine.Schedule_Frequency__c=='M' || qLine.Schedule_Frequency__c=='Y' || qLine.Schedule_Frequency__c == 'W'){
                if(qLine.Frequency_Interval__c==null || qLine.Frequency_Interval__c==''){
                    errMsg = 'Scheduled/SOC service missing frequency interval';
                }
            }
        }else{
            if(qLine.Occurrence_Type__c=='OC' && ((qLine.Schedule_Frequency__c!='' && qLine.Schedule_Frequency__c!=null) ||( qLine.Frequency_Interval__c!='' && qLine.Frequency_Interval__c!=null) ) ){
                errMsg='On-call Service should not contain a Service Frequency or Frequency interval';
            }
        }
        return errMsg;
    }

    //added as part of sdt 32753
    public static String validateRemovalAndSwapoutSize(SBQQ__QuoteLine__c currentQuoteline) {
        //string to store error message
        String errMsg = '';
        
        // get the Equipment Size
        List<Schema.PicklistEntry> equipment_SizeEntries = Schema.SObjectType.SBQQ__QuoteLine__c.fields.Equipment_Size__c.getPicklistValues();
        
        //checking if the parent is commercial family
        if((currentQuoteline.SBQQ__RequiredBy__c != NULL) && (currentQuoteline.SBQQ__RequiredBy__r.SBQQ__ProductFamily__c.equalsIgnoreCase(Constant_Util.COMMERCIAL))) 
        {
            //system.debug('insidefirstif');
            String convertedAssetSize = AssetQuoteProcurementController.getPicklistEntryByLabel(equipment_SizeEntries, currentQuoteLine.SBQQ__RequiredBy__r.AssetId__r.Equipment_Size__c);
            
            //checking if the size is changed for this bundle
            if(currentQuoteLine.SBQQ__RequiredBy__r.Equipment_Size__c != convertedAssetSize) 
            {
                //system.debug('convertedAssetSize >> ' + convertedAssetSize);
                //checking if the size for removal or swapout is not the asset size - fail status change for quote
                if(!(currentQuoteline.Equipment_Size__c.equalsIgnoreCase(convertedAssetSize))) 
                {
                    //System.debug('inside last if currentQuoteline.Equipment_Size__c >> ' + currentQuoteline.Equipment_Size__c);
                    errMsg = 'Please ensure your Swapout and Removal have the correct sizes';
                }
            }
        }
        return errMsg;
    }

    public static string vTStage(SBQQ__QuoteLine__c qLine){
        string errMsg = '';
        //Additional validation:vendor is inactive
          if ((qline.SBQQ__Quote__r.SBQQ__Type__c == 'Amendment' ||qline.SBQQ__Quote__r.SBQQ__Type__c == 'Exception' || qline.SBQQ__Quote__r.SBQQ__Type__c == 'Correction' || (qline.SBQQ__Quote__r.SBQQ__Type__c == 'Quote' && qline.SBQQ__Quote__r.STP__c == FALSE) ) && qLine.Vendor__c != null) {
                string vendorStatus = qLine.Vendor__r.Status__c;
             // Only check vendor status if vendor is not null
             if (vendorStatus == 'Inactive') {
                errMsg = strVendorInactive; 
                vTStageErrorList.add(errMsg);
             }
            }
            string vendorName = qLine.Vendor__r.Name;
            
            // Additional Vlaidation: for Start Date and End Date mismatch ***
            
                     Date vendorCommitDate = qLine.Vendor_Commit_Date__c; // Vendor commit date
                    // Date startDate = qLine.SBQQ__StartDate__c; // Start date from Quote Line
                     Date endDate = qLine.SBQQ__EndDate__c; // End date from Quote Line
 
            // Combined check for Vendor Commit Date or Start Date being greater than End Date
               if (((vendorCommitDate != null && endDate != null && vendorCommitDate > endDate) ) && (qline.SBQQ__Quote__r.SBQQ__Type__c == 'Amendment' || qline.SBQQ__Quote__r.SBQQ__Type__c == 'Quote') ) {
                    errMsg = 'End Dates must be greater than the vendor commit date';
                    vTStageErrorList.add(errMsg);
                    }
            //Additional validation: Missing Mass Unique ID validation
            String vendorId = qLine.Vendor__r.Parent_Vendor_ID__c; 
            if ((vendorId == Constant_Util.WM_US_VENDOR || vendorId == Constant_Util.WM_CANADA_VENDOR) && (qline.SBQQ__Quote__r.SBQQ__Type__c  != 'Quote') && (qLine.MASCustomerUniqueId__c == null)) {
                errMsg = strMassIdMissing;
                vTStageErrorList.add(errMsg);
            }
            // Additional Validation: Check if VCR Code is missing for WM vendors
            if(vendorId == Constant_Util.WM_US_VENDOR || vendorId == Constant_Util.WM_CANADA_VENDOR){
            if (( qline.SBQQ__Quote__r.SBQQ__Type__c == 'Quote' )&& vendorName != null  && (qLine.VCRCode__c == null || qLine.VCRCode__c == '')) {
                errMsg = strVCRCodeMissing;
                vTStageErrorList.add(errMsg);
            }
        }
          // Additional validation: Check if Pricing Method is missing
          if( !qline.SBQQ__Quote__r.STP__c){
          if(qline.SBQQ__Quote__r.SBQQ__Type__c == 'Amendment' || qline.SBQQ__Quote__r.SBQQ__Type__c == 'Quote') {
          if (qLine.SBQQ__PricingMethod__c == null || qLine.SBQQ__PricingMethod__c == '') {
               errMsg = strPricingMethodMissing ;
               vTStageErrorList.add(errMsg);
          }
        }
    }
              //Additional validation: Vendor validation for "WM Fee" with  List Price = 0 in Configure Price stage
         if (vendorName != null && vendorName.startsWithIgnoreCase('WM Fee')) {
         if (qLine.SBQQ__ListPrice__c == 0) {
            errMsg = strWMFeeList;
            vTStageErrorList.add(errMsg);
         }
        }
        // Additional validation:: unit List Price Missing 
        if ((qline.SBQQ__Quote__r.SBQQ__Type__c == 'Amendment' || qline.SBQQ__Quote__r.SBQQ__Type__c == 'Quote' ) && !qLine.SBQQ__Quote__r.STP__c && qLine.SBQQ__ListPrice__c == null && qLine.PricingUnitMethod__c!='STP' ) {
                errMsg = strPriceMissing;
                vTStageErrorList.add(errMsg);
           }
        if(qLine.PriceUOM__c==null || qLine.PriceUOM__c==''){
            errMsg='Missing price unit of measure';
            vTStageErrorList.add(errMsg);
        }else{
            if(qLine.SBQQ__ProductName__c == 'Management Fee' && (qLine.SBQQ__ListPrice__c==null || qLine.SBQQ__ListPrice__c<=0 )){
                errMsg='Price of Management Fee product option must be greater than $0.00';
                vTStageErrorList.add(errMsg);
            }
        }
        //TCS-pkulkarn-SDT-41532-Added for showing validation error on Configured Products section on Quote Page
        if(qLine.SBQQ__PricingMethod__c=='STP')
        {
            if(qLine.PricePrice1__c==null || qLine.PricePrice2__c==null)
            {
                errMsg = strPricingUnitMethodSTP;
                vTStageErrorList.add(errMsg);
            }
        }
        //TCS-pkulkarn-SDT-41532-End
        return errMsg;
    }
    
    
    //Performs a SOSL search based on user input of vendor account details
    //Business has expressed a need to search by VID over name.  SOSL will 
    //accommodate this request.
@AuraEnabled
public static List<Account> searchVendors(String searchString) {
 
    List<Account> vendorList = new List<Account>();
        
    List<List<SObject>> searchList = [FIND :searchString
                                      IN ALL FIELDS
                                          RETURNING Account(Id, Name, AccountNumber, Vendor_Business_Unit__c, ShippingState, ShippingCity,FacilityCode__c, Parent_Vendor_Id__c, Status__c,Vendor_Id__c,ParentId
                                                            WHERE RecordType.Name = 'Vendor')];
        
    vendorList = (Account[])searchList[0];
 
        // 45005 
    // --- Step 2: Collect child vendors to detect true parents
        List<Account> childVendors = [SELECT Id, ParentId FROM Account 
        WHERE ParentId != null AND RecordType.Name = 'Vendor'
        LIMIT 49999
    ];
 
    // Build set of TRUE parent Account Ids (using ParentId)
    Set<Id> trueParentIds = new Set<Id>();
    for (Account child : childVendors) {
        trueParentIds.add(child.ParentId);
    }
 
    // --- Step 3: Filter vendors
    List<Account> filteredVendors = new List<Account>();
    for (Account vendor : vendorList) {
 
        // CASE 1: Standalone vendors (Parent_Vendor_Id__c == null)
        if (vendor.Parent_Vendor_Id__c == null) {
 
            // Show standalone vendor ONLY if it is NOT a true 
            if (!trueParentIds.contains(vendor.Id)) {
                filteredVendors.add(vendor);
                //System.debug('Adding standalone vendor: ' + vendor.Name + ' (VID: ' + vendor.Vendor_Id__c + ')');
            } else {
                System.debug('Skipping TRUE parent vendor: ' + vendor.Name + ' (VID: ' + vendor.Vendor_Id__c + ')');
            }
        } 
        // CASE 2: Child vendors (always include)
        else {
            filteredVendors.add(vendor);
            //System.debug('Adding child vendor: ' + vendor.Name + ' (VID: ' + vendor.Vendor_Id__c + ')');
        }
    }
    return filteredVendors;
}
         //45005

    
    @AuraEnabled
    public static List<Account_Position__c> allPositions(QuoteProcurementController.HeaderWrapper header) {
        
        List<Account_Position__c> ALP = new List<Account_Position__c>();
        List<Account_Position__c> ALPDefault = new List<Account_Position__c>();
        List<Account_Position__c> ALPOther = new List<Account_Position__c>();
        
        ALPDefault = [SELECT Id, Name, Container_Position__c, AlternateStreet__c,
               AlternateCity__c, AlternateState__c, AlternatePostalCode__c
               FROM Account_Position__c
               WHERE AccountId__c =: header.locationId and Container_Position__c = 'Default'];

        ALPOther = [SELECT Id, Name, Container_Position__c, AlternateStreet__c,
               AlternateCity__c, AlternateState__c, AlternatePostalCode__c
               FROM Account_Position__c
               WHERE AccountId__c =: header.locationId and Container_Position__c != 'Default' ORDER BY Container_Position__c ASC];
        
        ALP.addAll(ALPDefault);
        ALP.addAll(ALPOther);

        return ALP;
        
    }
    
    @AuraEnabled
    public static List<Account_Position__c> searchPositions(QuoteProcurementController.HeaderWrapper header, String searchString) {
        
        List<Account_Position__c> ALP = new List<Account_Position__c>();
        
        if(!String.isBlank(searchString))
        {
            List<List<SObject>> searchList = [FIND :searchString
                                            IN ALL FIELDS
                                            RETURNING Account_Position__c(Id, Name, Container_Position__c, AlternateStreet__c,
                                                                        AlternateCity__c, AlternateState__c, AlternatePostalCode__c
                                                                        WHERE AccountId__c =: header.locationId ORDER BY Container_Position__c ASC)];
            ALP = (Account_Position__c[])searchList[0];
        }
        else
        {
            ALP = allPositions(header);
        }
        return ALP;
        
    }
    
    /*@AuraEnabled
    public static void uncheckPricing(String quoteId) {
        SBQQ__Quote__c q = [SELECT Id, Show_Get_Price__c
                           FROM SBQQ__Quote__c
                           WHERE Id =:quoteId];
        q.Show_Get_Price__c = FALSE;
        update q;
    }*/
    
    @AuraEnabled
    public static List<ProductsWrapper> getCaseQuotes(String CaseId) {
        
        List<ProductsWrapper> caseProducts = new List<ProductsWrapper>();
        
        List<SBQQ__Quote__c> caseQuotes = new List<SBQQ__Quote__c>();
        
        caseQuotes = [SELECT Id FROM SBQQ__Quote__c
                     WHERE SBQQ__Opportunity2__r.Case__c =: CaseId];
        
        for (SBQQ__Quote__c q : caseQuotes) {
            
            ProductsWrapper pw = new ProductsWrapper();
            pw = buildWrapper(q.Id);
            caseProducts.add(pw);
            
        }
        
        system.debug(caseProducts);
        
        return caseProducts;
        
    }
    
    @AuraEnabled
    public static List<ProductsWrapper> getDuplicates(String CaseId) {
        List<ProductsWrapper> caseProducts = new List<ProductsWrapper>();
        
        List<SBQQ__Quote__c> caseQuotes = new List<SBQQ__Quote__c>();
        Case c = [SELECT Id, Location__c, Service_Date__c
                 FROM Case
                 WHERE Id =: CaseId];
        
        caseQuotes = [SELECT Id 
                      FROM SBQQ__Quote__c
                     WHERE SBQQ__Account__c =: c.Location__c AND
                        SBQQ__StartDate__c >=: c.Service_Date__c - 3 AND
                        SBQQ__StartDate__c <=: c.Service_Date__c + 3];
        
        for (SBQQ__Quote__c q : caseQuotes) {
            
            ProductsWrapper pw = new ProductsWrapper();
            pw = buildQuoteWrapper(q.Id);
            caseProducts.add(pw);
            
        }
        
        system.debug(caseProducts);
        
        return caseProducts;
        
    }

    @AuraEnabled
    public static String storeOnsite(QuoteProcurementController.HeaderWrapper header, String positionName)
    {
        //System.debug('In storeOnsite');
        String result;
        if(validatePosition(header.locationId, positionName))
        {
            Account_Position__c accPosition = new Account_Position__c();
            accPosition.AccountId__c = header.locationId;
            accPosition.Container_Position__c = positionName;

            insert accPosition;

            updateALPOnQuoteLine(header, accPosition.Id, positionName, false);

            result = 'Success';
        }
        else
        {
            result = 'Duplicate';
        }

        return result;
    }
    @AuraEnabled
    public static String storeOffsite(QuoteProcurementController.HeaderWrapper header, String OffsitePosition , string street, string city,string state ,string postal)
    {
        //System.debug('In storeOffsite');
        String result;
        
        Account_Position__c accPosition = new Account_Position__c();
        accPosition.AccountId__c = header.locationId;
        accPosition.AlternateStreet__c	 = !String.isBlank(street) ? street : Constant_Util.EMPTY_STRING;
        accPosition.AlternateCity__c = !String.isBlank(city) ? city : Constant_Util.EMPTY_STRING;
        accPosition.AlternateState__c = !String.isBlank(state) ? state : Constant_Util.EMPTY_STRING;
        accPosition.AlternatePostalCode__c = !String.isBlank(postal) ? postal : Constant_Util.EMPTY_STRING;

        accPosition.Container_Position__c = Constant_Util.OFFSITE + Constant_Util.COLON + Constant_Util.BLANKSPACE + OffsitePosition;
        if(!String.isBlank(street) || !String.isBlank(city) || !String.isBlank(state) || !String.isBlank(postal))
        {
            accPosition.Container_Position__c += 
            ' at ' + 
            accPosition.AlternateStreet__c + Constant_Util.BLANKSPACE + 
            accPosition.AlternateCity__c + Constant_Util.BLANKSPACE + 
            accPosition.AlternateState__c + Constant_Util.BLANKSPACE + 
            accPosition.AlternatePostalCode__c;
        }
        

        if(validatePosition(header.locationId, accPosition.Container_Position__c))
        {
            insert accPosition;

            updateALPOnQuoteLine(header, accPosition.Id, accPosition.Container_Position__c, true);
            
            result = 'Success';
        }
        else
        {
            result = 'Duplicate';
        }
        return result;
    }

    private static Boolean validatePosition(Id locationId, String containerPosition)
    {
        List<Account_Position__c> accPos = new List<Account_Position__c>();
        Boolean isValid = true;

        //SOSL query not give proper duplicate record result within time frame
        //That's why use SOQL and use loop, as TextArea filed didn't use directly in where clause
        accPos = [SELECT Id, Name, Container_Position__c
               FROM Account_Position__c
               WHERE AccountId__c =: locationId];

        for(Account_Position__c ap : accPos)
        {
            if(ap.Container_Position__c == containerPosition)
            {
                isValid = false;
                break;
            }
        }       

        return isValid;
    }
    
    @AuraEnabled
    public static List<SBQQ__QuoteLine__c> showLocationPosition(Id quoteLineId)
    {
        String result;
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();    
        quoteLines = [SELECT Id,LocationPositionName__c,Location_Position_Name__c,Location_Position_Name__r.Name, Location_Position_Name__r.Container_Position__c   FROM SBQQ__QuoteLine__c
                      WHERE id =: quoteLineId order by createddate desc];
        
        // if(!quoteLines.isEmpty() && quoteLines.size()>0){ 
        //     for (SBQQ__QuoteLine__c ql : quoteLines){ 
        //         if(ql.Location_Position_Name__c!=null)
        //         {
        //             result = ql.Location_Position_Name__c;
        //         }}}
        return quoteLines;
    }
   
    @AuraEnabled
    public static void updateALPOnQuoteLine(QuoteProcurementController.HeaderWrapper header, Id ALPId, String setupComments, Boolean isOffsite)
    {
        List<SBQQ__QuoteLine__c> upsertQLLIst = new List<SBQQ__QuoteLine__c>();
        //Changes for SDT-29968
        List<SBQQ__QuoteLine__c> detailQuoteLines = QuoteLineServices.getQuoteLinesForPosition(header.parentId);
        if(detailQuoteLines.size() > 0 && !detailQuoteLines.isEmpty())
        {
            for(SBQQ__QuoteLine__c qLine : detailQuoteLines)
            {
                SBQQ__QuoteLine__c sql = new SBQQ__QuoteLine__c();
                sql.Id = qLine.Id;
                sql.Location_Position_Name__c = ALPId;
                sql.LocationPositionName__c = setupComments;
                // Commented 'SetupComment__c' field reference for story SDT-25787 to change the DataType from 'Text(255)' to 'Long Text(1500)' Will uncomment after DataType is changed
                if(isOffsite){
                    sql.SetupComment__c = setupComments;
                }
                upsertQLLIst.add(sql);
            }
        }

        if(upsertQLLIst.size() > 0 && !upsertQLLIst.isEmpty()){
            System.debug('upsert list -- ' + upsertQLLIst);
            try{
                update upsertQLLIst;
            }catch(Exception e){
                System.debug('Exception caught -- ' + e.getMessage());
            }
        }
    }

    @AuraEnabled
    public static Boolean updateQuoteOverview(HeaderWrapper productWrapper) {
		system.debug('productWrapper==>'+productWrapper);
	List<SBQQ__QuoteLine__c> qlList = QuoteLineServices.getQuoteLinesByParentId(productWrapper.parentId);

        productWrapper.equipmentSize = getPicklistAPIName(productWrapper.equipmentSize);
        for(SBQQ__QuoteLine__c ql : qlList) {
	    //ql.SBQQ__StartDate__c = productWrapper.startDate;
            //ql.SBQQ__EndDate__c = (ql.SBQQ__ProductName__c == 'Delivery') ? productWrapper.startDate : productWrapper.endDate;
            if (ql.SBQQ__ProductOption__r.SBQQ__Type__c != 'Accessory') {
            	ql.SBQQ__Quantity__c = productWrapper.quantity;
            }
            
            //TCS-pkulkarn-SDT-33379-5-Dec-2023-Added following call to Update Quantity on Lock Fee and Lock products
            QuoteLineServices.updateQuantityForLockProducts(ql, productWrapper.quantity);
            
            ql.Description_of_Waste__c = productWrapper.wasteDescription;
            ql.SLA_Override_Reason__c = productWrapper.slaOverrideReason;
            ql.SLA_Override_Comment__c = productWrapper.slaOverrideComment;
            ql.Equipment_Size__c = productWrapper.equipmentSize;
            system.debug('productWrapper.equipmentSize==>'+productWrapper.equipmentSize);
            //SDT-37527
             if(productWrapper.selectedMaterialGrade != null)
			ql.MaterialGrade__c = productWrapper.selectedMaterialGrade;
            if(!String.isEmpty(productWrapper.companyCategory))
                ql.CompanyCategoryCode__c = productWrapper.companyCategory;
            if(!String.isEmpty(productWrapper.companyCategoryName))
                ql.CompanyCategoryName__c = productWrapper.companyCategoryName;

                //SDT-42448
                 if(ql.SBQQ__RequiredBy__c == null){
                        ql.Quote_SLA_Date__c = QuoteProcurementController.callDetermineSLA(ql.Id);
                    } 
        }

        try {
            update qlList;
            return true;
        } catch (exception e) {
            system.debug('error is ==>'+e.getMessage());
            
            return false;
        }
    }
    public static string getPicklistAPIName(string labelName){
        string result = labelName;
        Schema.DescribeFieldResult fieldResult = SBQQ__QuoteLine__c.Equipment_Size__c.getDescribe();
        List<Schema.PicklistEntry> values = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry v : values) {
            if (v.getLabel()  == labelName) {
                result = v.getValue();
            }
        }
        return result;
    }
    // Added for SDT-20583/20584
    @AuraEnabled
    public static string getAddProductId() {
        String addProduct = [SELECT Id FROM SBQQ__CustomAction__c WHERE Name =: Constant_Util.ADD_PRODUCTS].Id;
        return addProduct;
        
    }
    @AuraEnabled
    public static Map<String, String> getSizes(Id productId, Boolean returnAll) {
        return QuoteFavoritesController.getSizes(productId, returnAll);
    }
    // Added for SDT-20583
    public class FavoriteProductHeader{
        @AuraEnabled public String productName {get; set;}
     // @AuraEnabled public Id productID {get; set;}
        @AuraEnabled public List<QuoteProcurementController.FavoriteProductDetail> listcontainerDetails {get; set;}
    }
    // Added for SDT-20583
    public class FavoriteContainerWrapper{
        @AuraEnabled public List<QuoteProcurementController.FavoriteProductHeader> ContainerList {get; set;}
    }
   // Added for SDT-20583 
    public class FavoriteProductDetail{
        @AuraEnabled public String containerType {get; set;}
        @AuraEnabled public Id FavoriteID {get; set;}
        @AuraEnabled public String materialType {get; set;}
        @AuraEnabled public String equipmentSize {get; set;}
        
    }
  /*  
    public with sharing class ConfigurationAttribute {
    public String EquipmentSize;
    public String cost;
    public String value;
    public String vendor;
        public ConfigurationAttribute() {}
    }
        
    public with sharing class Response {
    public List<ConfigurationAttribute> configurationAttribute;
    public Integer Count;
    public Response() {}
}*/
  // Added for SDT-20583 - Creating Quote and QuoteLine based on the data selection from Favriotes screen.  
    @AuraEnabled
    public static String addQuoteAndQuoteine(String favroiteId, String caseId, String quoteID, Boolean quoteScreen) {
        
        //Double parentLineNumber;
        Decimal parentLineNumber;
        
        system.debug('FavroiteId, CaseId' + favroiteId + caseId);
        String bundleId = null;
        List<SBQQ__FavoriteProduct__c> favorites = new List<SBQQ__FavoriteProduct__c>();
        favorites = [SELECT Id, Name, SBQQ__ConfigurationAttributes__c, SBQQ__Favorite__c, SBQQ__Product__c,
                     SBQQ__Product__r.Name, SBQQ__RequiredBy__c, SBQQ__RequiredBy__r.SBQQ__RequiredBy__c, SBQQ__Quantity__c,
                     SBQQ__ProductOption__c, SBQQ__ProductOption__r.SBQQ__Type__c, SBQQ__ProductOption__r.Occurrence_Type__c, 
                     SBQQ__ProductOption__r.CostModelType__c, SBQQ__ProductOption__r.Cost_Unit_of_Measure__c, SBQQ__ProductOption__r.PriceUOM__c,
                     SBQQ__ProductOption__r.Schedule_Frequency__c, SBQQ__ProductOption__r.Frequency_Interval__c, SBQQ__ProductOption__r.SBQQ__Quantity__c, SBQQ__ProductOption__r.SBQQ__ProductFamily__c
                     FROM SBQQ__FavoriteProduct__c where SBQQ__Favorite__c =: favroiteId ORDER BY SBQQ__Favorite__c, SBQQ__RequiredBy__c];
        system.debug('favorites--->'+ favorites);
        SBQQ__Quote__c quote;
        //String quoteID;
        if(!quoteScreen){
            quoteID = GetCaseInformation.createOppQuote(CaseId);
            system.debug('quoteID--->'+ quoteID);
            quote= [Select id, SBQQ__Account__c from SBQQ__Quote__c where id =: quoteID];
            parentLineNumber = 1;
        }else{
            quote=[SELECT Id,SBQQ__Account__c FROM SBQQ__Quote__c WHERE Id =:quoteID];
        }
        
        List<SBQQ__QuoteLine__c> maxQL = [SELECT SBQQ__Number__c
                                          FROM SBQQ__QuoteLine__c
                                          WHERE SBQQ__Quote__c =: quoteID
                                          ORDER BY SBQQ__Number__c DESC
                                          LIMIT 1];
        
        parentLineNumber = maxQL.size() > 0 ? maxQL[0].SBQQ__Number__c : 1;
                
        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
        Map<String, Object> plAttributes = (Map<String, Object>)JSON.deserializeUntyped(favorites[0].SBQQ__ConfigurationAttributes__c);
        system.debug('plAttributes--->'+ plAttributes);
        
        String equipmentPql = String.valueOf(plAttributes.get('Equipment_Size__c'));
        String occurrenceType = String.valueOf(plAttributes.get('Occurrence_Type__c'));
        system.debug('equipmentPql--->'+ equipmentPql);
            
        SBQQ__QuoteLine__c parentQLine = QuoteLineServices.returnParentQuoteline(quote.id,favorites[0].SBQQ__Product__c,equipmentPql,occurrenceType,true,favorites[0].SBQQ__ProductOption__r.SBQQ__Quantity__c,parentLineNumber);
        
        
        Product2 product = [SELECT ID, SBQQ__PricingMethod__c FROM Product2 Where ID =: parentQLine.SBQQ__Product__c];
        system.debug('parentQLine--->'+ parentQLine);
        insert parentQLine;
        system.debug('parentQLine--->'+ parentQLine);

        String qLineID = parentQLine.Id;
        Double currLineNumber = parentLineNumber + 3;
        String wasteCategoryId;
        system.debug('qLineID--->'+ qLineID);
		
        //sdt-27107
        Date SLADate = Null;
        //Date.valueOf(QuoteFavoritesController.determineSLA(parentQLine.Id));
        //sdt-27107 end
        
        parentQLine.SBQQ__StartDate__c = SLADate;
        quoteLineList.add(parentQLine);
        if(qLineID !=''){
            Integer i;
            for(i = 1; i < favorites.size(); i++){
                system.debug('favorites[i]--->'+ favorites[i].SBQQ__Product__c);
                Map<String, Object> attributes = (Map<String, Object>)JSON.deserializeUntyped(favorites[i].SBQQ__ConfigurationAttributes__c);
                String equipmentSize = String.valueOf(attributes.get('Equipment_Size__c'));
                
                String productFamily = favorites[i].SBQQ__ProductOption__r.SBQQ__ProductFamily__c;
                
                if (productFamily == 'Waste Category') {
                    
                    SBQQ__QuoteLine__c qLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote.id,
                                                                      SBQQ__Product__c = favorites[i].SBQQ__Product__c,
                                                                      Equipment_Size__c = equipmentSize,
                                                                      SBQQ__RequiredBy__c = parentQLine.Id,
                                                                      SBQQ__ProductOption__c = favorites[i].SBQQ__ProductOption__c,
                                                                      SBQQ__Favorite__c = favorites[i].SBQQ__Favorite__c,
                                                                      SBQQ__OptionLevel__c = 1,
                                                                      SBQQ__Quantity__c = favorites[i].SBQQ__ProductOption__r.SBQQ__Quantity__c,
                                                                      SBQQ__Number__c = parentLineNumber + 1,
                                                                      Occurrence_Type__c = favorites[i].SBQQ__ProductOption__r.Occurrence_Type__c, 
                                                                      CostModelType__c = favorites[i].SBQQ__ProductOption__r.CostModelType__c, 
                                                                      Cost_Unit_of_Measure__c = favorites[i].SBQQ__ProductOption__r.Cost_Unit_of_Measure__c, 
                                                                      PriceUOM__c = favorites[i].SBQQ__ProductOption__r.PriceUOM__c,
                                                                      Schedule_Frequency__c = favorites[i].SBQQ__ProductOption__r.Schedule_Frequency__c,
                                                                      Frequency_Interval__c = favorites[i].SBQQ__ProductOption__r.Frequency_Interval__c,
                                                                      SBQQ__StartDate__c = SLADate,SBQQ__EndDate__c = SLADate
                                                                     );
                                                                      //SBQQ__PricingMethod__c = product.SBQQ__PricingMethod__c);  //SDT- 21487 * SBQQ__PricingMethod__c - value updating to 'List' to edit the LIST UNIT PRICE in QuoteLines.

                                                                      //SBQQ__PricingMethod__c = Constant_Util.LIST_PRICING_METHOD);  //SDT- 21487 * SBQQ__PricingMethod__c - value updating to 'List' to edit the LIST UNIT PRICE in QuoteLines.
                    
                    try {
                        insert qLine;
                        wasteCategoryId = qLine.Id;
                    } catch (exception e) {
                        system.debug('An error occurred during waste category insert.  Error is: ' + e.getMessage());
                    }
                    
                } else {
                    SBQQ__QuoteLine__c qLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote.id,
                                                                      SBQQ__Product__c = favorites[i].SBQQ__Product__c,
                                                                      Equipment_Size__c = equipmentSize,
                                                                      SBQQ__RequiredBy__c = productFamily == 'Waste Stream' ? wasteCategoryId : parentQLine.Id,
                                                                      SBQQ__ProductOption__c = favorites[i].SBQQ__ProductOption__c,
                                                                      SBQQ__Favorite__c = favorites[i].SBQQ__Favorite__c,
                                                                      SBQQ__OptionLevel__c = productFamily == 'Waste Stream' ? 2 : 1,
                                                                      SBQQ__Number__c = productFamily == 'Waste Stream' ? parentLineNumber + 2 : currLineNumber,
                                                                      SBQQ__CostEditable__c = productFamily == 'Waste Stream' ? false : true,
                                                                      SBQQ__PriceEditable__c = productFamily == 'Waste Stream' ? false : true,
                                                                      SBQQ__Quantity__c = favorites[i].SBQQ__ProductOption__r.SBQQ__Quantity__c,
                                                                      Occurrence_Type__c = favorites[i].SBQQ__ProductOption__r.Occurrence_Type__c, 
                                                                      CostModelType__c = favorites[i].SBQQ__ProductOption__r.CostModelType__c, 
                                                                      Cost_Unit_of_Measure__c = favorites[i].SBQQ__ProductOption__r.Cost_Unit_of_Measure__c, 
                                                                      PriceUOM__c = favorites[i].SBQQ__ProductOption__r.PriceUOM__c,
                                                                      Schedule_Frequency__c = favorites[i].SBQQ__ProductOption__r.Schedule_Frequency__c,
                                                                      Frequency_Interval__c = favorites[i].SBQQ__ProductOption__r.Frequency_Interval__c,
                                                                      SBQQ__StartDate__c = SLADate,SBQQ__EndDate__c = SLADate
                                                                      );
                                                                      //SBQQ__PricingMethod__c = product.SBQQ__PricingMethod__c);
                                                                      //SBQQ__PricingMethod__c = Constant_Util.LIST_PRICING_METHOD); //SDT- 21487 * SBQQ__PricingMethod__c - value updating to 'List' to edit the LIST UNIT PRICE in QuoteLines. 
                    quoteLineList.add(qLine);
                    currLineNumber = currLineNumber + 1;
                    system.debug('equipmentSize--->'+ equipmentSize);
                }
                
                
                
            }
            upsert quoteLineList;
            system.debug('quoteLineList--->'+ quoteLineList);
            
        }
        system.debug('quoteID--->'+ quoteID);
        return quoteID;
    }
    
	// Added for SDT-20583
    @AuraEnabled
    public static FavoriteContainerWrapper getFavorites() {
        system.debug('getFavorites--->');
        List<SBQQ__FavoriteProduct__c> favorites = new List<SBQQ__FavoriteProduct__c>();
        FavoriteContainerWrapper pw = new FavoriteContainerWrapper();
        List<FavoriteProductHeader> headerList = new List<FavoriteProductHeader>();
        
        favorites = [SELECT Id, Name, SBQQ__ConfigurationAttributes__c, SBQQ__Favorite__c, SBQQ__Product__c,
                    SBQQ__Product__r.Name, SBQQ__RequiredBy__c, SBQQ__RequiredBy__r.SBQQ__RequiredBy__c, SBQQ__RequiredBy__r.Name, SBQQ__Quantity__c
                    FROM SBQQ__FavoriteProduct__c
                    ORDER BY SBQQ__Favorite__c, SBQQ__RequiredBy__c];
        
       system.debug('Favorites--->'+ favorites);
       List<SBQQ__FavoriteProduct__c> favoriteProducts = [SELECT Id, Name, SBQQ__ConfigurationAttributes__c, SBQQ__Favorite__c, SBQQ__Product__c,
                    SBQQ__Product__r.Name, SBQQ__RequiredBy__c, SBQQ__RequiredBy__r.SBQQ__RequiredBy__c, SBQQ__Quantity__c
                    FROM SBQQ__FavoriteProduct__c where SBQQ__RequiredBy__c = null];
        
        
        Set<String> productList = new Set<String>();
        for (SBQQ__FavoriteProduct__c f : favoriteProducts)
        {
            productList.add(f.Name);
        }
         	List<String> uniqueProductList = new List<String>();
       		uniqueProductList.addAll(productList);
       
        for (String str : uniqueProductList){
             String containerType = str;
             FavoriteProductHeader hw = new FavoriteProductHeader();
             hw.productName = str;
			 List<FavoriteProductDetail> detailList = new List<FavoriteProductDetail>();
       		 for (SBQQ__FavoriteProduct__c f : favoriteProducts) {
                 
					String isReq = f.SBQQ__RequiredBy__r.Name;
                	if (f.Name == str) {
                        
							Map<String, Object> attributes = (Map<String, Object>)JSON.deserializeUntyped(f.SBQQ__ConfigurationAttributes__c);
                            FavoriteProductDetail dw = new FavoriteProductDetail();
                            dw.containerType = f.SBQQ__Product__r.Name;
                            dw.FavoriteID = f.SBQQ__Favorite__c;
                       		dw.equipmentSize = String.valueOf(attributes.get('Equipment_Size__c'));
                            for (SBQQ__FavoriteProduct__c material :favorites)
                            {
                                system.debug('f.Id--->'+ f.Id);
                                if(material.SBQQ__Favorite__c == f.SBQQ__Favorite__c && material.SBQQ__RequiredBy__c !=  f.Id && material.SBQQ__RequiredBy__r.SBQQ__RequiredBy__c !=null && material.SBQQ__RequiredBy__r.Name !=null)
                                {
                                   dw.materialType = material.Name;
                                }
                            }
                            detailList.add(dw);
             			 }
         		}
				hw.listcontainerDetails = detailList;
                headerList.add(hw);
            system.debug('headerList--->'+ headerList);
            system.debug('detailList--->'+ detailList);
        } 
        pw.ContainerList = headerList;
        system.debug('pw--->'+ pw);
        return pw;
        
    }
   // Added for SDT-20583
    @AuraEnabled
    public static String addQuoteAsProductNotListed(String CaseId) {
        system.debug('CaseId--->'+ CaseId);
        String quoteID = GetCaseInformation.createOppQuote(CaseId);
        system.debug('quoteID--->'+ quoteID);
        return quoteID; 
  	}
    // Added for SDT-20584
  	@AuraEnabled
    public static string goToCase(String quoteID){
       
        SBQQ__Quote__c quote = [Select ID, SBQQ__Opportunity2__r.Case__c FROM SBQQ__Quote__c WHERE ID =: quoteID];
       
        return quote.SBQQ__Opportunity2__r.Case__c;
    } 
    //Added for SDT-20939
    @AuraEnabled
    public static List<String> getPicklistSchema(){
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Quote_Order__c.Service_Type__c.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            options.add(p.getValue());
		}
        return options;
    }

    //Added for story SDT-21065
     @AuraEnabled
    public static MASWrapper getMasDetails(Id quoteLineId) { //
        MASWrapper masWrapper = new MASWrapper();
        List<SBQQ__QuoteLine__c> quoteLines = getQuoteLineMASDetails(quoteLineId);
        //system.debug('getMasDetails quoteLines'+ quoteLines);
        if(!quoteLines.isEmpty() && quoteLines.size()>0)
        {
            SBQQ__QuoteLine__c parentLine = quoteLines[0];
            masWrapper.MASLibrary = parentLine.MASLibrary__c;
            masWrapper.MASCompany = parentLine.MASCompany__c;
            masWrapper.MASAccount = parentLine.MASAccount__c;
            masWrapper.MASUniqueId = parentLine.MASCustomerUniqueId__c;
            masWrapper.MASServiceLine = parentLine.MASServiceLine__c;
            masWrapper.MASBox = parentLine.MASBox__c;
            // Commented 'SetupComment__c' field reference for story SDT-25787 to change the DataType from 'Text(255)' to 'Long Text(1500)' Will uncomment after DataType is changed
            masWrapper.MASComment = parentLine.SetupComment__c;
            masWrapper.MASBypassPrice = parentLine.BypassPriceReview__c;
            masWrapper.MASDoNotCreate = parentLine.DoNotCreateMASTicket__c;
            //SDT 29392 start
            masWrapper.DoNotCreateTaskGridTickets = parentLine.DoNotCreateTaskGridTickets__c;
            
            // DoNotCreateTaskGridTicket CheckBox will be visible for all other case record type except New Service Because in New service case, Acorn will consider this as True
            if(parentLine.SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__r.RecordType.Name != Constant_Util.New_Service_Case)
                masWrapper.IsDoNotCreateTaskGridTicketVisible = true;
            
                //SDT 29392 end
            // Changes for SDT-25787
            masWrapper.MASCommentSize = Schema.SObjectType.SBQQ__QuoteLine__c.fields.SetupComment__c.getLength();
            //masWrapper.VCRCode = quoteLines[0].VCRCode__c;
        }
        return masWrapper;
    }
    //Story 21060
    //Fetch the data from parent quoteline to store on Financial detail component.
    @AuraEnabled
    public static FinancialDetailWrapper getQLFinancialDetail(Id quoteLineId)
    {
        FinancialDetailWrapper fdWrapper = new FinancialDetailWrapper();
        try
        {
        List <SBQQ__QuoteLine__c> qlData = [SELECT Id, SBQQ__Quote__c, CompanyCategoryCode__c, ClientGLAccount__c, ClientCostCenter__c, SBQQ__Quote__r.Quote_Only__c
                                    FROM  SBQQ__QuoteLine__c
                                    WHERE Id =:  quoteLineId LIMIT 1];
        if(!qlData.isEmpty())
        {
            fdWrapper.quoteOnly = qlData[0].SBQQ__Quote__r.Quote_Only__c;
            fdWrapper.companyCategory = qlData[0].CompanyCategoryCode__c;
            fdWrapper.clientGLNo = qlData[0].ClientGLAccount__c;
            fdWrapper.customerCostCenter = qlData[0].ClientCostCenter__c;
        }
        }
        catch (exception ex) {
            system.debug('exception from getQLFinancialDetail call '+ ex.getMessage());
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(),UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
        }

        return fdWrapper;
    }
    //Story 21060
    //Save the data fetched from Financial detail component to save on respective quotelines.
    @AuraEnabled
    public static string updateFinancialDetail(Id quoteLineId, Boolean isQuoteOnly, String companyCategory,String companyCategoryName, String generalLedgerNo, String customerCostCenter)
    {
        //List<SBQQ__QuoteLine__c> quoteLinelst = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c qlHdr = new SBQQ__QuoteLine__c();
        SBQQ__Quote__c qRecord = new SBQQ__Quote__c();
        List<sObject> quoteUpdate = new list<sObject>();
        system.debug('isQuoteOnly--->'+ isQuoteOnly);
        String returnMessage = 'Failed';
        try
        {
        List<SBQQ__QuoteLine__c> qlRecords = [SELECT Id, SBQQ__Quote__c, CompanyCategoryCode__c,CompanyCategoryName__c, ClientGLAccount__c, ClientCostCenter__c
                                    FROM  SBQQ__QuoteLine__c
                                    WHERE SBQQ__RequiredBy__c =:  quoteLineId];
        if(!qlRecords.isEmpty())
        {
            for(SBQQ__QuoteLine__c ql : qlRecords)
            {
                if(String.isNotBlank(companyCategoryName) && String.isNotBlank(companyCategory)){
                    ql.CompanyCategoryCode__c = companyCategory;
                    ql.CompanyCategoryName__c = companyCategoryName;
                }
		ql.ClientGLAccount__c = generalLedgerNo;
                ql.ClientCostCenter__c = customerCostCenter;

                quoteUpdate.add(ql);
            }

            qlHdr.Id = quoteLineId;
            if(String.isNotBlank(companyCategoryName) && String.isNotBlank(companyCategory)){
                qlHdr.CompanyCategoryCode__c = companyCategory;
                qlHdr.CompanyCategoryName__c = companyCategoryName;
            }
            qlHdr.ClientGLAccount__c = generalLedgerNo;
            qlHdr.ClientCostCenter__c = customerCostCenter;

            quoteUpdate.add(qlHdr);

            //update quoteLinelst;

            qRecord.Id = qlRecords[0].SBQQ__Quote__c;
            qRecord.Quote_Only__c = isQuoteOnly;
            quoteUpdate.add(qRecord);

            update quoteUpdate;

            returnMessage = 'Success';
        }                            
    }
    catch(exception ex){
        system.debug('exception from updateFinancialDetail '+ex.getMessage());
        UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(),UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
    }

        return returnMessage;
    }
	
    //Displays active projects
    @AuraEnabled
    public static List<Project_Code__c> getActiveProjects(Id quoteId, String searchString) {
        List<SBQQ__Quote__c> currentQuote = [SELECT Id, Project__c,Project__r.Name, SBQQ__Account__c, SBQQ__Account__r.ParentId
                                            FROM SBQQ__Quote__c
                                            WHERE Id =: quoteId
                                            LIMIT 1];
        
        List<List<SObject>> projectSOSL = [FIND :searchString
                                          IN NAME FIELDS
                                          RETURNING Project_Code__c(Id, Name, Project_Manager__r.Name, Program_Manager__r.Name, Effective_Date__c,
                                          End_Date__c, Duration__c, Company_Category__c 
                                          WHERE Client_Account__c =: currentQuote[0].SBQQ__Account__r.ParentId
                                          ORDER BY Project_Manager__r.Name ASC, Effective_Date__c DESC)];
        
        List<Project_Code__c> activeProjects = projectSOSL[0];
        
        return activeProjects;
    }

    @AuraEnabled
    public static Business_Rule__c quoteBusinessRules(Id quoteId, String caseType, String subType) {
        
        Business_Rule__c limitingRule = new Business_Rule__c(); 

        SBQQ__Quote__c q = [SELECT Id, SBQQ__Account__r.ParentId
                            FROM SBQQ__Quote__c
                            WHERE Id=: quoteId
                            LIMIT 1];
        
        List<Business_Rule__c> businessRuleList = [SELECT Id, AccountId__c, Request_Type__c, Service__c, Case_Reason__c, Required_Information__c
                                                    FROM Business_Rule__c
                                                    WHERE AccountId__c =: q.SBQQ__Account__r.ParentId 
                                                    AND Active__c = true 
                                                    AND ((Request_Type__c =: caseType AND Service__c =: subType)
                                                    AND (Request_Type__c =: caseType AND Service__c = null))];

        for (Business_Rule__c br: businessRuleList) {
            //Most to least selective
            if (br.Service__c == subType) {
                limitingRule = br;
            } else if (br.Service__c == null) {
                limitingRule = br;
            }
        }

        return limitingRule;
    }
    @AuraEnabled
    public static SBQQ__Quote__c getQuoteStatusDetails(Id quoteId) {
        //SDT - 30089 - added 2 fields - Special_Handling__c, Special_Handling_Reason__c
        //TCS-pkulkarn-SDT-41184-Added SBQQ__Type__c to the SOQL
        SBQQ__Quote__c q = [SELECT Id, SBQQ__Status__c, Assigned_To__r.Name, Quote_Only__c,SBQQ__Opportunity2__r.Case__r.RecordType.Name,// SDT-29101 : Added recordType Name for Case 
                            SBQQ__PrimaryContact__r.Name, SBQQ__PrimaryContact__r.Phone, SBQQ__Opportunity2__r.Case__c, 
                            Project__c,Project__r.Name, Project_Services_Request__c, QuoteProcuredStatus__c, Special_Handling__c, Special_Handling_Reason__c, Special_Handling_Reason_Details__c, SBQQ__Type__c,
                            SBQQ__Opportunity2__r.Case__r.Vendor_Service_Id__c,SBQQ__Opportunity2__r.Case__r.Chargeable__c //SDT-42651  //SDT-41538
                            FROM SBQQ__Quote__c
                            WHERE Id =: quoteId
                            LIMIT 1];
        
        return q;
    }
    //SDT-30072 : Check Asset Availability Permission
    @AuraEnabled
    public static Boolean hasAssetAvailabilityPermission(){
        return FeatureManagement.checkPermission(Constant_Util.ASSET_AVAILABILITY_CUSTOM_PERMISSION); 
    }
    // - 41624
    @AuraEnabled
    public static Boolean hasAssetAvailabilityPermissionWithHaulAway(Id caseId){
        Boolean isHaul = false;
        isHaul = HaulAwayService.getIsHaulAwayService(caseId);
        return FeatureManagement.checkPermission(Constant_Util.ASSET_AVAILABILITY_CUSTOM_PERMISSION) && !isHaul; 
    } // - 41624
    
    //SDT-29101 : get Asset Availability response
    @AuraEnabled
    public static AAV_Asset_Availability__c getAvailabilityResponse(String quoteLineId){
        return AAV_APIIntegration.getAvailabilityResponse(quoteLineId);
    }
    //SDT-30864 - Asset Availability: get Delivery Override Reasons Picklist Values
    @AuraEnabled
    public static List<String> getDeliveryOverrideReasons() {
        List<String> deliveryOverrideReasons = new List<String>();
        for (Schema.PicklistEntry pick : SBQQ__QuoteLine__c.AAV_Delivery_Override_Reason__c.getDescribe().getPicklistValues()) 
        {
            if(pick.isActive())
                deliveryOverrideReasons.add(pick.getValue());
        }
        return deliveryOverrideReasons;
    }
    //SDT-30963 : update new Equipement size and related fields
    @AuraEnabled
    public static Boolean updateAlternateProduct(HeaderWrapper productWrapper) {
        try{
            if(productWrapper.parentId!=null){
                List<SBQQ__QuoteLine__c> qlList = QuoteLineServices.getQuoteLinesByParentId(productWrapper.parentId);
                for(SBQQ__QuoteLine__c ql : qlList) {
                    ql.Equipment_Size__c = productWrapper.equipmentSize;
                    ql.SLA_Override_Reason__c ='';
                    ql.SLA_Override_Comment__c ='';
                    ql.SBQQ__StartDate__c = null;
                    ql.AAV_Delivery_Override_Reason__c='';//SDT-30864
                    ql.AAV_Delivery_Override_Comment__c='';//SDT-30864
                }    
                update qlList;
                return true;
            }
        }
        catch(exception e){
            system.debug('updateAlternateProduct Error->'+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        return false;
    }
    @AuraEnabled
    public static SBQQ__Quote__c getQuoteForOrders(Id quoteId) {
        SBQQ__Quote__c targetQuote = new SBQQ__Quote__c();

        targetQuote = [SELECT Id, Name, Project__c, Project_Services_Request__c
                        FROM SBQQ__Quote__c
                        WHERE Id =: quoteId];

        return targetQuote;
    }
    
    @AuraEnabled
    public static Boolean updateQuoteForOrders(SBQQ__Quote__c updatedQuote) {
        
        try {
            update updatedQuote;
            return true;
        } catch (exception e) {
            return false;
        }

    }

    public static List<SBQQ__ErrorCondition__c> getProductRules(Id productId){
        
        List<SBQQ__ErrorCondition__c> errorConditions = new List<SBQQ__ErrorCondition__c>();
        Set<Id> ruleIds = new Set<Id>();

        List<SBQQ__ConfigurationRule__c> configRules = [SELECT Id, SBQQ__Product__c, SBQQ__ProductRule__c
                                                        FROM SBQQ__ConfigurationRule__c
                                                        WHERE SBQQ__Product__c =: productId AND SBQQ__Active__c = TRUE];
        
        if (configRules.size() == 0) {
            return errorConditions;
        } else {
            for (SBQQ__ConfigurationRule__c c: configRules) {
                ruleIds.add(c.SBQQ__ProductRule__c);
            }
        }
        
        errorConditions = [SELECT Id, SBQQ__Rule__c, SBQQ__TestedField__c, SBQQ__Operator__c, SBQQ__FilterType__c, SBQQ__FilterValue__c
                          FROM SBQQ__ErrorCondition__c
                          WHERE SBQQ__Rule__c IN: ruleIds AND SBQQ__Operator__c = 'equals'];

        return errorConditions;

    }

    public static Set<Id> getActions(List<SBQQ__ErrorCondition__c> conditions, SBQQ__QuoteLine__c parentLine) {

        Set<Id> productRules = new Set<Id>();

        for (SBQQ__ErrorCondition__c e : conditions) {
            String checkedField = e.SBQQ__TestedField__c;
            String errCondField = e.SBQQ__FilterValue__c;
            Object qlFieldObject = parentLine.get(checkedField);
            String qlCondField = String.valueOf(qlFieldObject);
            if (errCondField == qlCondField) {
                productRules.add(e.SBQQ__Rule__c);
            }
        }

        return productRules;

    }

    public static Set<Id> getAddRuleProducts(Set<Id> rules) {

        Set<Id> addProducts = new Set<Id>();
        List<SBQQ__ProductAction__c> addActions = [SELECT Id, SBQQ__Rule__c, SBQQ__Product__c
                                                   FROM SBQQ__ProductAction__c
                                                   WHERE SBQQ__Rule__c IN: rules AND SBQQ__Type__c = 'Add'];
        for (SBQQ__ProductAction__c a: addActions) {
            addProducts.add(a.SBQQ__Product__c);
        }
        return addProducts;

    }

    public static Set<Id> getRemRuleProducts(Set<Id> rules) {

        Set<Id> remProducts = new Set<Id>();
        List<SBQQ__ProductAction__c> remActions = [SELECT Id, SBQQ__Rule__c, SBQQ__Product__c
                                                   FROM SBQQ__ProductAction__c
                                                   WHERE SBQQ__Rule__c IN: rules AND SBQQ__Type__c = 'Add'];
        for (SBQQ__ProductAction__c a: remActions) {
            remProducts.add(a.SBQQ__Product__c);
        }
        return remProducts;

    }

    @AuraEnabled
    public static SBQQ__QuoteLine__c getQuoteLineForOrders(Id qlid) {
        SBQQ__QuoteLine__c targetQuoteLine = new SBQQ__QuoteLine__c();

        targetQuoteLine = [SELECT Id, Profile_Number__c, Landfill_Tickets__c, Special_Disposal_Description__c,
                            Service_Start_Time__c, Service_End_Time__c, Gate_Code__c, Certificate_of_Destruction__c, Certificate_of_Disposal__c,
                           Restriction_Details__c
                            FROM SBQQ__QuoteLine__c
                            WHERE Id =: qlid];

        return targetQuoteLine;
    }

    //SDT-29381 - Harun - getting label of quoteline Equipment_Size__c 
    public static String getPicklistLabel(String qlinepicklistAPIValue)
    {     
        string qlinepicklistLabel = '';
       
        Schema.DescribeFieldResult fieldResult = SBQQ__QuoteLine__c.Equipment_Size__c.getDescribe();
        Map<String, String> picklistValuesMap = new Map<String, String>(); 
        for (Schema.PicklistEntry entry : fieldResult.getPicklistValues()) {
          picklistValuesMap.put(entry.getValue(), entry.getLabel());
     	}
		if (picklistValuesMap.containsKey(qlinepicklistAPIValue)) {
 		    qlinepicklistLabel = picklistValuesMap.get(qlinepicklistAPIValue);
   			System.debug('Picklist Field Label: ' + qlinepicklistLabel);
         }
        return qlinepicklistLabel;
    }

    @AuraEnabled
    public static qLineWrapper getQuoteLineForOrdersWrapper(Id qlid) {
        SBQQ__QuoteLine__c targetQuoteLine = new SBQQ__QuoteLine__c();

        targetQuoteLine = [SELECT Id, Profile_Number__c, Landfill_Tickets__c, Special_Disposal_Description__c,
                            Service_Start_Time__c, Service_End_Time__c, Gate_Code__c, Certificate_of_Destruction__c, Certificate_of_Disposal__c,
                           Restriction_Details__c, Location_Position_Name__c, SLA_Override_Comment__c, SLA_Override_Reason__c,Equipment_Size__c,
                           AssetId__r.Equipment_Size__c,SBQQ__Quantity__c,AssetId__r.Quantity__c //SDT-29381 - Harun - Added Equipment_Size__c,AssetId__r.Equipment_Size__c,SBQQ__Quantity__c,AssetId__r.Quantity__c
                            FROM SBQQ__QuoteLine__c
                            WHERE Id =: qlid];
        qLineWrapper wrap = new qLineWrapper();
        wrap.cQLine = targetQuoteLine;
        wrap.serviceStartTime = string.valueOf(targetQuoteLine.Service_Start_Time__c);
        wrap.serviceEndTime = string.valueOf(targetQuoteLine.Service_End_Time__c);
        //Changes for SDT-26541
        //SDT-27107 - PavanK - Converted from single object to List of Objects
        List<SBQQ__QuoteLine__c> deliveryLine = [SELECT Id, SBQQ__Product__r.Name,SBQQ__Product__r.ProductCode, SBQQ__RequiredBy__c FROM SBQQ__QuoteLine__c WHERE SBQQ__RequiredBy__c =: qlid AND SBQQ__Product__r.Name =: Constant_Util.ServiceType_Delivery Limit 1];
        if(deliveryLine.size() > 0 && !deliveryLine.isempty())
            wrap.hasDelivery = true;
            
        string quoteLineEquipsize =  getPicklistLabel(targetQuoteLine.Equipment_Size__c);
        //SDT-29381 - Harun - added two conditions comparing asset equipment size and quantity with its quoteline size and quantity .
        if((quoteLineEquipsize != targetQuoteLine.AssetId__r.Equipment_Size__c)||(targetQuoteLine.SBQQ__Quantity__c > targetQuoteLine.AssetId__r.Quantity__c))  
            wrap.hasDelivery = true;
        
        //SDT-27107 - End
        return wrap;
    }
    public class  qLineWrapper{
        @AuraEnabled public SBQQ__QuoteLine__c cQLine{set;get;}
        @Auraenabled public string serviceStartTime{set;get;}
        @Auraenabled public string serviceEndTime{set;get;}
        //Changes for SDT-26541
        @Auraenabled public Boolean hasDelivery{set;get;}
    }
    @Auraenabled
    public static Boolean updateQuoteLineForOrders(SBQQ__QuoteLine__c updatedQuoteLine) {
        try {
            // DateTime SLADateTime = QuoteFavoritesController.determineSLAforProjectcodeentitlements(updatedQuoteLine.Id);
            // updatedQuoteLine.SBQQ__StartDate__c = SLADateTime.date();
            //Assigning Latest Location Position to avoid overlapping with old one
            //SDT-30089 - start
            List<SBQQ__QuoteLine__c> qlList = [Select Id, Location_Position_Name__c, SBQQ__Quote__c,SBQQ__Quote__r.Special_Handling__c from SBQQ__QuoteLine__c WHERE Id =: updatedQuoteLine.Id];
            //SDT-30089 - end
            if(qlList.size() > 0 && !qlList.isEmpty())
            {
                SBQQ__QuoteLine__c qlPosition = qlList[0];

                if(qlPosition.Location_Position_Name__c != null)
                {
                    updatedQuoteLine.Location_Position_Name__c = qlPosition.Location_Position_Name__c;
                }
            }
            
            update updatedQuoteLine;

             //SDT-30089 - start
             updateSpecialHandling(qlList[0].SBQQ__Quote__c);
             //SDT-30089 - end
            
            return true;    
           } 
        
        catch (exception e) {
            return false;
        }  

    }

    /**************************************************
    * Created By:TCS
    * CreatedDate:03/18/2025
    * Defect: SDT-45088
    * To create a case comment displaying both the quote sla override reason and override comment the user selected at Intake screen and MIF flow.
    * **************************************************/
    @AuraEnabled
    public static void addCommentForSLAOverrideFromIntake(String caseId) {
        addCommentForSLAOverride(caseId, Null, Null);
    }
    
    @InvocableMethod(label='Add Comment for SLA Override' description='This action is for creating sla override comment')
    public static void addCommentForSLAOverrideFromMIF(List<InputWrapperForMIFFlow> input) {
        addCommentForSLAOverride(input[0].caseId, input[0].slaComment, input[0].slaReason);
    }
    
    public class InputWrapperForMIFFlow {
        @InvocableVariable(label='Case Id')
        public string caseId;
        @InvocableVariable(label='Sla Comment')
        public string slaComment;
        @InvocableVariable(label='Sla Reason')
        public string slaReason;
    }
    /**************************************************
	* Created By:TCS av4
	* CreatedDate:28/11/2023
	* Defect: SDT-25005
	* To create a case comment displaying both the quote sla override reason and override comment the user selected at intake screen.
	* **************************************************/
    @AuraEnabled
    public static void addCommentForSLAOverride(String caseId, String slaComment, String slaReason) {
        
        try {
            String commentBody;
            String trackingNumber;
            String caseNumber;

                //creating a  map of metadata records of Comment_Log_Detail__mdt type and getting the SLA_Override record
                Map<String , Comment_Log_Detail__mdt> commentLogTemplateData = new Map<String , Comment_Log_Detail__mdt>();
                for(Comment_Log_Detail__mdt c : Comment_Log_Detail__mdt.getAll().values()){
                    commentLogTemplateData.put(c.DeveloperName , c);
                }
                Comment_Log_Detail__mdt slaOverrideCommentTemplate = commentLogTemplateData.get('SLA_Override');
                
                Id recordTypeId = Schema.getGlobalDescribe().get('Comment__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Acorn_Ticket_Comment').getRecordTypeId();
            
            //when called from MIF flow
            if(String.isNotEmpty(slaComment) && String.isNotEmpty(slaReason)) {
                commentBody = slaOverrideCommentTemplate.Comment__c.replaceAll('<Reason__x>', slaReason);
                commentBody = commentBody.replaceAll('<Comment__c>', slaComment);
                List<Case> csList = [Select Id, CaseNumber, Tracking_Number__c from Case where Id =: caseId limit 1];
                if(csList.size() > 0) {
                    caseNumber = csList[0].CaseNumber;
                    trackingNumber = csList[0].Tracking_Number__c;
                }
            }
            
            else {
                //querying the quoteline
                list<SBQQ__QuoteLine__c> ql = [Select Id, SLA_Override_Reason__c, SLA_Override_Comment__c, sbqq__Quote__r.SBQQ__Opportunity2__r.Case__c, 
                                            SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__r.CaseNumber, SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__r.Tracking_Number__c
                                            FROM SBQQ__QuoteLine__c WHERE sbqq__Quote__r.SBQQ__Opportunity2__r.Case__c =: caseId AND SBQQ__Requiredby__c =: null
                                            AND SLA_Override_Reason__c != null limit 1];
                if(ql.size() > 0) {
                //Decimal acornUserId = [select Acorn_SUser_ID__c from User where ID =: System.UserInfo.getUserId()].Acorn_SUser_ID__c;
                
                    String overrideReason = ql[0].SLA_Override_Reason__c;
                    String overrideComment = ql[0].SLA_Override_Comment__c;
                    commentBody = slaOverrideCommentTemplate.Comment__c.replaceAll('<Reason__x>', overrideReason);
                    commentBody = commentBody.replaceAll('<Comment__c>', overrideComment);
                    
                    caseNumber = ql[0].SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__r.CaseNumber;
                    if (String.isNotEmpty(ql[0].SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__r.Tracking_Number__c))  {
                        trackingNumber = ql[0].SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__r.Tracking_Number__c;
                    }
                    
                    //insert comment;
                    
                }
            }
                
                 //creating a Comment__c record
            if(String.isNotBlank(commentBody)) // SDT-48501
	    {
                Comment__c comment = new Comment__c();
                comment.recordTypeId = recordTypeId;
                comment.Comment__c = commentBody;
                comment.is_Log__c = true;
                comment.Workflow_TeamUser__c = System.UserInfo.getName();
                //comment.Acorn_SUser_ID__c = acornUserId;
                comment.Communication_Log_Type_Name__c = 'Internal';
            	comment.Case__c = caseId;
		comment.Type__c = Constant_Util.OBJECT_CASE;
            	comment.Case_Number__c = caseNumber;
            	comment.Acorn_Tracking_Number__c = trackingNumber;
                
                insert comment;
	    }
            
            
        }catch(Exception ex){
            //Changes related to SDT-48086
            UTIL_LoggingService.logHandledExceptionWithClass(ex, UserInfo.getOrganizationId(),
                                                            UTIL_ErrorConstants.CONFIRM_CONFIGURATION_ACTION,
                                                            System.LoggingLevel.Error,
                                                            UTIL_ErrorConstants.QUOTEPROCUREMNTCONTROLLER_CLASSNAME,
                                                            UTIL_ErrorConstants.ADDCOMMENTFORSLAOVERRIDE_METHODNAME,
                                                            null);
        }
        
    }

	
	// SDT-31752 - Earlier getAccessories was used to get only the assessories, now assessories and already selected 
    // Assessory from Quoteline is been sent so that selection can occur.
	// It also sends back a map of Product Option Id and Optional SKU ID 
    @AuraEnabled
    public static  Map<String,List<Object>> getAccessoriesWithSelection(Id productId, Id quoteId) {
         List<Id> selectedAccessoryList = new List<Id>();
		 List<Id> disabledAccessoryList = new List<Id>();
         Map<Id,Id> mapOptionIdAndOptionSKUId = new Map<Id,Id>();
        QuoteLineSelector.getProductOptionForQuote(quoteId,selectedAccessoryList,mapOptionIdAndOptionSKUId, disabledAccessoryList);
        
        Map<String,List<Object>> mapSelectedAndAvailableAssesory = new Map<String,List<Object>>();
        
        // Get All the relevant accesories for the product
        //mapSelectedAndAvailableAssesory.put('AllAccessory', getAccessories(productId));
		// added for SDT-32086
		mapSelectedAndAvailableAssesory.put('AllAccessory', ProductServices.filterProductOptions(productId,quoteId));
        mapSelectedAndAvailableAssesory.put('SelectedAccessory', selectedAccessoryList);
        mapSelectedAndAvailableAssesory.put('mapOptionIdAndOptionSKUId',new List<Object>{mapOptionIdAndOptionSKUId});
        // Changes for SDT-31752
        mapSelectedAndAvailableAssesory.put('disabledAccessoryList', disabledAccessoryList);
        return mapSelectedAndAvailableAssesory;
    }
    

    @AuraEnabled
    public static List<SBQQ__ProductOption__c> getAccessories(Id productId) {

        List<SBQQ__ProductOption__c> accessoryList = new List<SBQQ__ProductOption__c>();
        //SDT-23055: adding few more fields in query and setting order by SBQQ__Number__c DESC
        accessoryList = [SELECT Id, SBQQ__ConfiguredSKU__r.Name, SBQQ__OptionalSKU__c,SBQQ__OptionalSKU__r.Name, SBQQ__QuantityEditable__c, SBQQ__Quantity__c
                        FROM SBQQ__ProductOption__c
                        WHERE SBQQ__ConfiguredSKU__c =: productId AND SBQQ__Feature__r.Name IN ('Additional Services','General Accessories') ORDER BY SBQQ__Number__c DESC];

        return accessoryList;

    }

    /*
     * SDT-23055
     * Dev: Rishi
     * Description: Created this method to return keys for Padlocks.
     * 
     */
    @AuraEnabled
    public static List<SBQQ__ProductOption__c> getPadlockKeys(List<Id> padLockIdList){
        List<SBQQ__ProductOption__c> accessoryList = new List<SBQQ__ProductOption__c>();

        accessoryList = [SELECT Id, SBQQ__ConfiguredSKU__r.Name, SBQQ__ConfiguredSKU__c, SBQQ__OptionalSKU__c,SBQQ__OptionalSKU__r.Name, SBQQ__QuantityEditable__c, SBQQ__Quantity__c
                        FROM SBQQ__ProductOption__c
                        WHERE SBQQ__ConfiguredSKU__c IN: padLockIdList];
        if(!accessoryList.isEmpty()){
            return accessoryList;
        }
        return null;
    }
    
    @AuraEnabled
    public static List<SBQQ__ConfigurationAttribute__c> getConfigAttributes(Id productId, String quoteLineId) {
        /*SDT-22447-START*/
        //Create MAP to store product specific equipment style values which are not required to display on UI.
        Map<String,Set<String>> equipmentStyleValuesWithProduct = new Map<String,Set<String>>();
        equipmentStyleValuesWithProduct.put('Dumpster',new Set<String>{'Apartment Style','Pre-Crusher','Horizontal','Vertical'});
        equipmentStyleValuesWithProduct.put('Compactor',new Set<String>{'Slant Top','Tall','Split Container','Cathedral','Loading Dock','Slant-Top'});
        
        String currentProductName; 
        if(String.isNotBlank(productId)){
            Product2 productObj = [SELECT Id, Name FROM Product2 WHERE Id =: productId LIMIT 1]; 
            if(productObj != null){
                currentProductName = productObj.Name;
            }
        }    
        /*SDT-22447-END*/
        
        List<SBQQ__ConfigurationAttribute__c> attributeList = new List<SBQQ__ConfigurationAttribute__c>();

        attributeList = [SELECT Id, SBQQ__TargetField__c, SBQQ__ApplyToProductOptions__c, SBQQ__Product__r.Name, SBQQ__ColumnOrder__c, SBQQ__DisplayOrder__c,
                        SBQQ__Feature__r.Name, Picklist_Values__c, Name
                        FROM SBQQ__ConfigurationAttribute__c
                        WHERE SBQQ__Product__c =: productId AND SBQQ__TargetField__c NOT IN('Equipment_Size__c', 'Duration', 'Occurrence_Type__c',
                                                                                            'Certificate_of_Destruction__c', 'Certificate_of_Disposal__c',
                                                                                            'Description_of_Waste__c', 'Profile_Number__c', 'Vendor__c')
                        ORDER BY SBQQ__Feature__r.Name ASC, SBQQ__DisplayOrder__c ASC, SBQQ__ColumnOrder__c ASC];
        
        system.debug('attributeList--->'+ attributeList);

        String configList = '';
        for (SBQQ__ConfigurationAttribute__c conf: attributeList) {
            if (configList == '') {
                configList = conf.SBQQ__TargetField__c;
            } else {
                configList += ', ' + conf.SBQQ__TargetField__c;
            }
        }

        String queryString = 'SELECT Id, ' + configList + ' FROM SBQQ__QuoteLine__c WHERE Id=: quoteLineId LIMIT 1';
        SBQQ__QuoteLine__c targetQL = database.query(queryString);
        
        for (SBQQ__ConfigurationAttribute__c conf : attributeList) {
            List<PicklistSelect> picklistOptions = new List<PicklistSelect>();
            Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
            system.debug('gd-->' + gd);
            Schema.SObjectType t = gd.get('SBQQ__QuoteLine__c');
            
            system.debug('t-->' + t);
            Schema.DescribeSObjectResult dsr = t.getDescribe();
            system.debug('dsr-->' + dsr);
            Map<String, Schema.SObjectField> fieldMap = dsr.fields.getMap();
            Schema.DescribeFieldResult dfr = fieldMap.get(conf.SBQQ__TargetField__c).getDescribe();
            List<Schema.PicklistEntry> ple = dfr.getPicklistValues();
            for(Schema.PicklistEntry p : ple) {
                PicklistSelect ps = new PicklistSelect(); 
                ps.value = p.getValue();
                ps.label = p.getLabel();
                ps.selected = (p.getValue() == targetQL.get(conf.SBQQ__TargetField__c)) ? true : false;
                system.debug('Target Field Value is: ' + targetQL.get(conf.SBQQ__TargetField__c));
                /*SDT-22447-START*/
                if(conf.SBQQ__TargetField__c.equalsIgnoreCase('Equipment_Style__c')){
                    Boolean isOptionValid = isEquipmentStyleOptionValidByProductName(equipmentStyleValuesWithProduct, currentProductName, conf.SBQQ__TargetField__c, ps.value);
                    if(isOptionValid){
                        picklistOptions.add(ps); 
                    }  
                }
                else{
                    picklistOptions.add(ps);
                }
                /*SDT-22447-END*/  
            }
            System.debug('>>>picklistOptions'+picklistOptions);
            conf.Picklist_Values__c = String.valueOf(JSON.serialize(picklistOptions));
        }
 
        return attributeList;
 
    }

    /*SDT-22447-START*/
    //Get the Product specific Equipment style values  
    public static Boolean isEquipmentStyleOptionValidByProductName(Map<String,Set<String>> equipmentStyleValuesWithProduct, String currentProductName,String targetField, String equipmentStyleOption){
        if(equipmentStyleValuesWithProduct.containsKey(currentProductName) 
            && targetField.equalsIgnoreCase('Equipment_Style__c')  
            && !equipmentStyleValuesWithProduct.get(currentProductName).contains(equipmentStyleOption)){
            return true;
        }
        else{
            return false;  
        }   
    } 
    /*SDT-22447-END*/

    @AuraEnabled
    public static string updateConfigAttribute(Id quoteLineId, String fieldName, String fieldValue, Id quoteId){
        String queryString = 'SELECT Id, SBQQ__Quote__c, ' + String.escapeSingleQuotes(fieldName) + ' FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quoteId ';
        List<SBQQ__QuoteLine__c> quoteLines = Database.query(queryString);
        for(SBQQ__QuoteLine__c ql: quoteLines)
        {
            if(fieldName == 'Ownership__c')
            {
                ql.Ownership__c=fieldValue;
            }
            else if(ql.Id == quoteLineId)
            {
                ql.put(fieldName, fieldValue);
            }
        }
        try{
            update quoteLines;
            return 'SUCCESS';
        } catch (Exception e) {
            return e.getMessage();
        }
    }

    @AuraEnabled
    public static string addProductOption(Id quoteLineId, Id productOptionId){
        
        List<SBQQ__QuoteLine__c> quoteLines = [SELECT Id, SBQQ__Number__c, SBQQ__StartDate__c, Equipment_Size__c,
                                              SBQQ__Quote__c, SID__c
                                              FROM SBQQ__QuoteLine__c
                                              WHERE Id=: quoteLineId OR SBQQ__RequiredBy__c =: quoteLineId
                                              ORDER BY SBQQ__Number__c DESC];
      
        // SDT-31973
        SBQQ__ProductOption__c prodOption = [SELECT Id, SBQQ__OptionalSKU__c, SBQQ__OptionalSKU__r.Name, SBQQ__OptionalSKU__r.ProductCode, SBQQ__Quantity__c, Occurrence_Type__c,
                                             CostModelType__c, Cost_Unit_of_Measure__c, PriceUOM__c, Schedule_Frequency__c,
                                             Frequency_Interval__c
                                             FROM SBQQ__ProductOption__c
                                             WHERE Id=: productOptionId];

        SBQQ__QuoteLine__c qLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = quoteLines[0].SBQQ__Quote__c,
                                                            SBQQ__Product__c = prodOption.SBQQ__OptionalSKU__c,
                                                            Equipment_Size__c = quoteLines[0].Equipment_Size__c,
                                                            SBQQ__RequiredBy__c = quoteLineId,
                                                            SBQQ__ProductOption__c = prodOption.Id,
                                                            SBQQ__OptionLevel__c = 1,
                                                            SBQQ__Number__c = quoteLines[0].SBQQ__Number__c + 1,
                                                            SBQQ__CostEditable__c = true,
                                                            SBQQ__PriceEditable__c = true,
                                                            SBQQ__Quantity__c = prodOption.SBQQ__Quantity__c,
                                                            Occurrence_Type__c = prodOption.Occurrence_Type__c, 
                                                            CostModelType__c = prodOption.CostModelType__c, 
                                                            Cost_Unit_of_Measure__c = prodOption.Cost_Unit_of_Measure__c, 
                                                            PriceUOM__c = prodOption.PriceUOM__c,
                                                            Schedule_Frequency__c = prodOption.Schedule_Frequency__c,
                                                            Frequency_Interval__c = prodOption.Frequency_Interval__c,
                                                            SBQQ__StartDate__c = quoteLines[0].SBQQ__StartDate__c,
                                                            SID__c= quoteLines[0].SID__c);
        system.debug('qLine==>'+qLine);
        // SDT-31973
        // For Key line adding ites End date same as start date
        if(prodOption.SBQQ__OptionalSKU__r.Name == Constant_Util.KEYS)
        {
            qLine.SBQQ__EndDate__c = qLine.SBQQ__StartDate__c;
        }
        try {
            insert qLine;
            //return 'SUCCESS'; //SDT-23055: commenting it to retrieve inserted quoteline id
            return String.valueOf(qLine.Id);
        } catch (exception e) {
            return e.getMessage();
        }

    }
     // SDT-31752
    // quoteId = Parent QL Id
    // ProductionOptionId is the Id of the Optional SKU on the product option, This is to remove the option Id
    @AuraEnabled
    public static string removeProductOption(Id quoteLineId, Id productOptionId) {
               
        SBQQ__QuoteLine__c quoteLine = [SELECT Id
                                        FROM SBQQ__QuoteLine__c
                                        WHERE SBQQ__RequiredBy__c =: quoteLineId 
                                        AND SBQQ__ProductOption__r.SBQQ__OptionalSKU__c =: productOptionId
                                        LIMIT 1];
        
        try {
            delete quoteLine;
            return 'SUCCESS';
        } catch (exception e) {
            return e.getMessage();
        }
    }
    /*
     * SDT-23055
     * Dev: Rishi
     * Description: Created this method to remove QL for keys when accessories get unchecked
     * SDT-31752
     * quoteId = Parent QL Id
     * ProductionOptionId is the Id of the Optional SKU on the product option. This is done to remove the dependency of option Id
     */
    @AuraEnabled
    public static string removeProductOption(Id quoteLineId, Id productOptionId, Id keyOptionId) {
        
        List<SBQQ__QuoteLine__c> quoteLine = [SELECT Id
                                        FROM SBQQ__QuoteLine__c
                                        WHERE (SBQQ__RequiredBy__c =: quoteLineId AND SBQQ__ProductOption__r.SBQQ__OptionalSKU__c =: productOptionId) OR
                                        (SBQQ__RequiredBy__r.SBQQ__RequiredBy__c =: quoteLineId AND SBQQ__ProductOption__c =: keyOptionId)
                                        LIMIT 2];
        try {
            delete quoteLine;
            return 'SUCCESS';
        } catch (exception e) {
            return e.getMessage();
        }
    }

    /*
     * SDT-23055
     * Dev: Rishi
     * Description: Created this method to update keys Quantity on qls
     * 
     */

    @AuraEnabled
    public static string updateKeysQuantity(Id parentId, List<KeyMapWrapper> keyObj){
        Set<String> idSet= new Set<String>();
        Map<String,String> keyMap= new Map<String,String>();
        for(KeyMapWrapper obj:keyObj){
            System.debug('obj.id>>>'+obj.id);
            idSet.add((String)obj.id);
            keyMap.put((String)obj.id,(String)obj.value);
        }
        List<SBQQ__QuoteLine__c> quoteLines = [SELECT Id,SBQQ__Quantity__c,SBQQ__ProductOption__c
                                                FROM SBQQ__QuoteLine__c
                                                WHERE SBQQ__RequiredBy__r.SBQQ__RequiredBy__c =: parentId AND SBQQ__ProductOption__c IN: idSet];
        System.debug('quoteLines>>>'+quoteLines);
        List<SBQQ__QuoteLine__c> updatedquoteLinesList = new List<SBQQ__QuoteLine__c>();
        for(SBQQ__QuoteLine__c ql: quoteLines){
            if(keyMap.containsKey(ql.SBQQ__ProductOption__c)){
                ql.SBQQ__Quantity__c = (keyMap.get(ql.SBQQ__ProductOption__c)== null || keyMap.get(ql.SBQQ__ProductOption__c)=='') ? 0:Decimal.valueOf(keyMap.get(ql.SBQQ__ProductOption__c));
                updatedquoteLinesList.add(ql);    
            }
        }
        try{
            if(!updatedquoteLinesList.isEmpty()){
                update updatedquoteLinesList;
            }
            return 'SUCCESS';
        }catch (exception e) {
            return e.getMessage();
        }
    }

    // Getting all intergration metadata where isActive true
    public static Set<String> getIntegrationFieldsOfQL()
    {
        // local variable
        Set<String> setFields = new Set<String>();
        List<PricingJsonSetting__mdt> lstRecords = new List<PricingJsonSetting__mdt>([Select Attribute__c,Default_Value__c,IsDisable__c,Json_Node__c,Field_API_Name__c,Object_API_Name__c from PricingJsonSetting__mdt where IsDisable__c != true]);
        for(PricingJsonSetting__mdt objRec: lstRecords){
            if(objRec.Field_API_Name__c != null){
                List<String> lstStr = (objRec.Field_API_Name__c).split(',');
                for(String str : lstStr){
                    if(objRec.Object_API_Name__c == 'SBQQ__QuoteLine__c'){
                        setFields.add(str);
                    } 
                } 
            }
        }
        return setFields;
    }

    @AuraEnabled
    public static QuoteSummaryWrapper createDelivery(OrderWrapper ow, String orderType, string placementInstructions) 
    {
        //String result;
        QuoteSummaryWrapper wrapper = new QuoteSummaryWrapper();
        wrapper.isAssetChanged = false;
        //Changes for SDT-27107
        Set<String> setFields = new Set<String>();
        Id parentQLId = ow.parentQuoteLine;
        Id quoteId = ow.quoteId;
        String vendorServiceId  = ow.vendorServiceId;

        // Getting all intergration metadata where isActive true
        setFields = getIntegrationFieldsOfQL();
	setFields.add('sbqq__Quote__r.SBQQ__Opportunity2__r.Case__c'); //41624

        // fields that need to check to update the start date // SDT-33378
        set<string> additionFieldsforMetadata = new Set<string>{'Vendor__c', 'LocationPositionName__c', 'Location_Position_Name__c','SBQQ__PricingMethod__c','SBQQ__StartDate__c', 'AssetId__r.ParentId'};

        String wasteStream = Constant_Util.WASTE_STREAM;
        String wasteCategory = Constant_Util.WASTE_CATEGORY;

        // Get all quote lines
        //List<SBQQ__QuoteLine__c> quoteLines = Database.Query('Select '+ String.join(new List<String>(setFields), ', ') +','+ String.join(new List<String>(additionFieldsforMetadata), ', ') +',SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__r.RecordType.Name,AssetId__c,SBQQ__ProductOption__r.SBQQ__ConfiguredSKU__r.Family,SBQQ__ProductOption__r.SBQQ__Feature__r.Name,SBQQ__Product__c,EventRecurrence__c,SBQQ__ProductOption__r.SBQQ__ProductCode__c,SBQQ__ProductFamily__c,SBQQ__ProductName__c,SBQQ__RequiredBy__c,SBQQ__Product__r.Family,SBQQ__RequiredBy__r.SBQQ__RequiredBy__c, SBQQ__Quote__r.Project__c,  SBQQ__Quote__r.Project_Services_Request__c, SBQQ__Product__r.Name from SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :quoteId AND (SBQQ__Product__r.Family != :wasteStream AND SBQQ__Product__r.Family != :wasteCategory)');
        List<SBQQ__QuoteLine__c> quoteLines = QuoteLineSelector.getQuoteLinesByQuoteId(setFields, parentQLId, quoteId, additionFieldsforMetadata);
            //Database.Query('Select '+ String.join(new List<String>(setFields), ', ') +','+ String.join(new List<String>(additionFieldsforMetadata), ', ') +',SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__r.RecordType.Name,AssetId__c,SBQQ__ProductOption__r.SBQQ__ConfiguredSKU__r.Family,SBQQ__ProductOption__r.SBQQ__Feature__r.Name,SBQQ__Product__c,EventRecurrence__c,SBQQ__ProductOption__r.SBQQ__ProductCode__c,SBQQ__ProductFamily__c,SBQQ__ProductName__c,SBQQ__RequiredBy__c,SBQQ__Quote__r.Name,SBQQ__Product__r.Family,SBQQ__RequiredBy__r.SBQQ__RequiredBy__c, SBQQ__Quote__r.Project__c,  SBQQ__Quote__r.Project_Services_Request__c, SBQQ__Product__r.Name, (Select Id, Service_Type__c from Quote_Orders__r) from SBQQ__QuoteLine__c WHERE Id = :parentQLId OR SBQQ__RequiredBy__c =:parentQLId OR SBQQ__RequiredBy__r.SBQQ__RequiredBy__c =:parentQLId ');
        
        //Local Variable
        List<SBQQ__QuoteLine__c> PqLine = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> deliveryQuoteLines = new List<SBQQ__QuoteLine__c>();
        // 41624
        List<SBQQ__QuoteLine__c> pickupQuoteLines = new List<SBQQ__QuoteLine__c>(); //end - 41624
        boolean isQLChanged = false;
        set<Id> assetIds = new set<id>();
        Map<Id,Asset> assetProductMap = new Map<Id,Asset>();
        List<SBQQ__QuoteLine__c> tobeChangeQuoteLines = new List<SBQQ__QuoteLine__c>();
        // Changes for SDT-30118
        Set<Id> surChargeIds = new Set<Id>();
        boolean isKeyDeliveryAdded = false;
        //get delivery line
        for(SBQQ__QuoteLine__c deliveryQL : quoteLines)
        {
            //identify Delivery QL
            if(deliveryQL.SBQQ__ProductName__c == orderType)
            {
                deliveryQuoteLines.add(deliveryQL);
            }

            //41624

            if(deliveryQL.SBQQ__ProductName__c.equalsIgnoreCase(Constant_Util.Haul_Away_Service) && deliveryQL.SBQQ__RequiredBy__c!= null)
            {
                deliveryQuoteLines.add(deliveryQL);
            }
            // End - 41624
            
            //identify Parent QL
            if(deliveryQL.SBQQ__RequiredBy__c == null)
            {
                PqLine.add(deliveryQL);
            }
            // Checking for Surcharge and Fee and adding in surcharge list
            if(deliveryQL.SBQQ__Product__r.Family == PricingJSONRequest.SURCHARGES_AND_FEES)
            {
                surChargeIds.add(deliveryQL.Id);
            }

            // Adding Keys in filtered bundle QuoteLineList
            if(surChargeIds.contains(deliveryQL.SBQQ__RequiredBy__c) && !isKeyDeliveryAdded)
            {
                deliveryQuoteLines.add(deliveryQL);
                isKeyDeliveryAdded =true;
            }

            // create a set of Asset Ids
            if(deliveryQL.AssetId__c != null)
                assetIds.add(deliveryQL.AssetId__c);
        }

        String positionName=Constant_Util.EMPTY_STRING;
        String caseRecordType = PqLine.size() > 0 ? PqLine[0].SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__r.RecordType.Name: Constant_Util.EMPTY_STRING;

        // system.debug('assetIds >'+ assetIds );
        // system.debug('caseRecordType >'+ caseRecordType );
        // check for Update Asset Record
        if(caseRecordType != Constant_Util.New_Service_Case)
        {
            List<Asset> assetDetails = new List<Asset>();
            if(assetIds != null && !assetIds.isempty() )
            {
                //SDT-38285 - start
                //Added Supplier__r.Parent_Vendor_ID__c for story SDT-39662
                assetDetails = [Select Id,ContactId,AccountId,ParentId,RootAssetId,Product2Id,ProductCode,ProductFamily,ProductDescription,
                                IsCompetitorProduct,CreatedDate,CreatedById,LastModifiedDate,LastModifiedById,SystemModstamp,IsDeleted,
                                CurrencyIsoCode,Name,SerialNumber,InstallDate,ManufactureDate,StatusReason,Uuid,ExternalIdentifier,
                                PurchaseDate,UsageEndDate,Status,DigitalAssetStatus,Price,Quantity,Description,OwnerId,RecordTypeId,
                                LocationId,AssetProvidedById,AssetServicedById,IsInternal,AssetLevel,StockKeepingUnit,LastViewedDate,
                                LastReferencedDate,Duration__c,Location__c,Acorn_SBID__c,Acorn_SCOD__c,Acorn_SID__c,Acorn_Update_Datetime__c,
                                Acorn_Vendor_Id__c,BusinessUnit_Name__c,Bypass_Cost_Grid__c,Bypass_MAS__c,Category__c,Container_Position__c,
                                Contract_Notes__c,Cost_Center__c,Cost_Currency__c,Cost_Increment_1__c,Cost_Increment_2__c,Cost_Increment_3__c,
                                Cost_Increment_4__c,Cost_Minimum_Quantity__c,Cost_Model_Type__c,Cost_Price_1__c,Cost_Price_2__c,
                                Cost_Price_3__c,Cost_Price_4__c,Cost_Total_Tax__c,Cost_Unit__c,Cost_UpTo_1__c,Cost_UpTo_2__c,
                                Cost_UpTo_3__c,Cost_UpTo_4__c,Cost__c,Customer_Account_Number__c,EDI_Price_Source__c,End_Date__c,
                                Equipment_Owner__c,Equipment_Size__c,Equipment_Type__c,Every__c,Exception_Comments__c,
                                Exception_Effective_Date__c,Exception_Reason_Detail__c,Exception_Reason__c,Exclude_Holidays__c,
                                Exclude_Saturdays__c,Exclude_Sundays__c,Frequency__c,Friday_AM__c,Friday_Frequency__c,Friday_PM__c,Friday__c,
                                GL_Code__c,Generate_Service_Events__c,Has_Extra_Pickup__c,Is_Active__c,Is_Core_Service__c,
                                Is_Hold_Until_Posted__c,Is_Locally_Billed__c,Is_Monitored__c,Is_Override_Rule__c,Location_Code__c,
                                MAS_Account_Number__c,MAS_Company_Code__c,MAS_Customer_Unique_Id__c,MAS_Library__c,MAS_Line_Number__c,
                                MAS_Setup_Comment__c,MAS_VCR_Code__c,MAS_Waste_Stream__c,Market_Area__c,Material_Grade__c,Material_Type__c,
                                Monday_AM__c,Monday_Frequency__c,Monday_PM__c,Monday__c,Monitored__c,Negotiater_ContactId__c,
                                Negotiater_UserId__c,Occurrence_Type__c,Occurrence__c,Occurs__c,Of_Every1__c,Of_Every2__c,Of_Every3__c,
                                Of_Every__c,Of_Month__c,On_Date__c,On_Day1__c,On_Day2__c,On_Day3__c,On_Day__c,On_the__c,Override_UserId__c,
                                Price_Currency__c,Price_Increment_1__c,Price_Increment_2__c,Price_Increment_3__c,Price_Increment_4__c,
                                Price_Minimum_Quantity__c,Price_Model_Type__c,Price_Price_1__c,Price_Price_2__c,Price_Price_3__c,
                                Price_Price_4__c,Price_Tax_Inclusive__c,Price_Total_Tax__c,Price_Unit__c,Price_UpTo_1__c,Price_UpTo_2__c,
                                Price_UpTo_3__c,Price_UpTo_4__c,Price__c,Project__c,Quantity__c,Reason_for_Change__c,Required_Time_of_Day__c,
                                Saturday_AM__c,Saturday_Frequency__c,Saturday_PM__c,Saturday__c,Schedule_A_Override__c,Schedule__c,
                                Send_Schedule_A__c,Sensitivity_Code__c,Service_Header_Id__c,Service_Info__c,Service_Type__c,Start_Date__c,
                                Sunday_AM__c,Sunday_Frequency__c,Sunday_PM__c,Sunday__c,Supplier__c,Supplier__r.Parent_Vendor_ID__c,Third_Party_Source__c,Thursday_AM__c,
                                Thursday_Frequency__c,Thursday_PM__c,Thursday__c,Time_of_Day_AM__c,Time_of_Day_PM__c,Tuesday_AM__c,
                                Tuesday_Frequency__c,Tuesday_PM__c,Tuesday__c,Vendor_Account_Number__c,Vendor_BU__c,Vendor_ID__c,
                                Vendor_Service_Number__c,Waste_Profile__c,Wednesday_AM__c,Wednesday_Frequency__c,Wednesday_PM__c,
                                Wednesday__c,Weekly_Frequency__c,Cost_Tax_Inclusive__c,MAS_Company_Account_Number__c,MAS_Unique_Text__c,
                                SBID_text_c__c,SCOD_text__c,Core_MAS_Unique__c,Core_Quantity__c,Core_Schedule__c,Lower_Case_Asset_Details__c,
                                Occurrence_Type_Formula__c,Active__c,End_Date_Based_on_Project_code__c,End_Dated_Asset__c,Project_Code__c, RootAsset.Project_Code__r.ProjectCode_Id__c, //SDT-40012 Added Project_Code__r.ProjectCode_Id__c
                                Schedule_Type__c,Created_By_User_Id__c,End_Date_Warning__c,Material_Prompt_ID__c,Voice_Prompt__c,
                                Dumpster_Service_Style__c,Dumpster_Style__c,Is_Null_End_Date__c,Originating_Case__c,
                                SBQQ__AdditionalDiscountAmount__c,Is_Self_Service__c,SBQQ__BillingFrequency__c,SBQQ__BillingType__c,
                                SBQQ__Bundle__c,SBQQ__BundledQuantity__c,SBQQ__Bundled__c,SBQQ__ChargeType__c,SBQQ__CombineKey__c,
                                SBQQ__ComponentDiscountedByPackage__c,SBQQ__CreditProductId__c,SBQQ__CurrentSubscription__c,SBQQ__Dimension__c,
                                SBQQ__DiscountScheduleType__c,SBQQ__DiscountSchedule__c,SBQQ__Discount__c,SBQQ__DistributorDiscount__c,
                                SBQQ__DynamicOptionId__c,SBQQ__FromServiceCloud__c,SBQQ__LatestQuoteLine__c,SBQQ__ListPrice__c,
                                SBQQ__MarkupAmount__c,SBQQ__MarkupRate__c,SBQQ__Number__c,SBQQ__OptionDiscountAmount__c,SBQQ__OptionDiscount__c,
                                SBQQ__OptionLevel__c,SBQQ__OptionType__c,SBQQ__OrderProduct__c,SBQQ__OriginalUnitCost__c,
                                SBQQ__PackageProductCode__c,SBQQ__PackageProductDescription__c,SBQQ__PartnerDiscount__c,
                                SBQQ__PriceDimension__c,SBQQ__PricingMethod__c,SBQQ__ProductOption__c,SBQQ__QuoteLine__c,SBQQ__RegularPrice__c,
                                SBQQ__RenewalUpliftRate__c,SBQQ__RequiredByAsset__c,SBQQ__RequiredById__c,SBQQ__RequiredByProduct__c,
                                SBQQ__RequiredBySubscription__c,SBQQ__RevisedAsset__c,SBQQ__RootAsset__c,SBQQ__RootId__c,SBQQ__SegmentIndex__c,
                                SBQQ__SegmentKey__c,SBQQ__SegmentLabel__c,SBQQ__SubscriptionEndDate__c,SBQQ__SubscriptionQuoteLine__c,
                                SBQQ__SubscriptionStartDate__c,SBQQ__Subscription__c,SBQQ__TermDiscountSchedule__c,SBQQ__UnitCost__c,
                                SBQQ__VirtualAsset__c,CPQ_Product__c,CPQ_Material__c, RecordType.DeveloperName , Account_Position__c,
                                MASBox__c, Material_Grade_Code__c, Month_Relative_Interval__c, Month_Relative__c 
                                from asset where id IN :assetIds]; // Changes for SDT-32105 
                //SDT-38285 - end
            }

            //iterating Asset Detail record to create a Map<assetId, Asset>
            For(Asset asset : assetDetails){
            if(asset!= null) 
            {
                assetProductMap.put(asset.id,asset);
            }
            }
            AssetQuoteProcurementController.TransformationHelper transformationHelper = new AssetQuoteProcurementController.TransformationHelper();
            // Changes for SDT-30514
            // Update baseline fields
            Set<string> updateBaselineFields = transformationHelper.readFieldSet('Update_Baseline','SBQQ__QuoteLine__c');
            // End and Extend fields
            Set<string> endAndExtendBaselineFields = transformationHelper.readFieldSet('End_and_Extend_Baseline','SBQQ__QuoteLine__c');
            // Excluded Fields
            Set<string> excludedFields = transformationHelper.readFieldSet('Integration_Excluded_Fields','SBQQ__QuoteLine__c');
            // get the Asset Quote Line Mapping for specific fields
            List<Asset_Quoteline_Mapping__mdt> assetQuoteLineMappings = [SELECT AssetDataType__c,AssetField__c,AssetFieldValue__c,IsActive__c,QuoteLineField__c,QuoteLineFieldValue__c FROM Asset_Quoteline_Mapping__mdt Where IsActive__c = true];
			
            //TCS-pkulkarn-13-Oct-2023-Added for SDT-32782
            Map<Id, SBQQ__QuoteLine__c> bundlewisePickupQuoteLinesMap = new Map<Id, SBQQ__QuoteLine__c>();
            Map<Id, SBQQ__QuoteLine__c> bundlewiseExtraPickupQuoteLinesMap = new Map<Id, SBQQ__QuoteLine__c>();
            //End-SDT-32782
            
            

            for(SBQQ__QuoteLine__c ql : quoteLines)
            {
                Asset asset =  assetProductMap.get(ql.AssetId__c);
                SBQQ__QuoteLine__c parentQL =PqLine[0];
				
				// changing enddate logic for 32792 start
                date endDateFromAsset=ql.SBQQ__EndDate__c;
                date endDatefromCIntake=(ql.SBQQ__ProductName__c == Constant_Util.ServiceType_Delivery) ? ow.serviceDate : (ow.serviceEndDate != null) ? ow.serviceEndDate : null;
                ql.SBQQ__EndDate__c = (endDatefromCIntake != null) ? endDatefromCIntake : endDateFromAsset;
				// Setting up end date before comparison so if End date is null we can detect in Asset and QL comparison
                //ql.SBQQ__EndDate__c = (ql.SBQQ__ProductName__c == Constant_Util.ServiceType_Delivery) ? ow.serviceDate : (ow.serviceEndDate != null) ? ow.serviceEndDate : null;
                // changing enddate logic for 32792 end
				
                if(asset != null && ql.SBQQ__ProductFamily__c != Constant_Util.WASTE_CATEGORY && ql.SBQQ__ProductFamily__c != Constant_Util.WASTE_STREAM){
                    // Changes for SDT-30514 and SDT-30515
                    AssetQuoteProcurementController.comparisonResponseModel responseModel= transformationHelper.compareAssetQuoteLines(asset, ql, parentQL, false, updateBaselineFields, endAndExtendBaselineFields, excludedFields, assetQuoteLineMappings);
                    //Changes for SDT-28571 , Bug: SDT-29124
                    if(responseModel!=null && responseModel.isQLMached)
                    {
                        Boolean isAssetHasProject = false;
                        if(asset.Project_Code__c != null)
                            isAssetHasProject = true;

                        if((ql.SBQQ__Quote__r != null && ql.SBQQ__Quote__r.Project__c !=  asset.Project_Code__c) || (ql.SBQQ__Quote__r.Project_Services_Request__c != isAssetHasProject))
                        {
                            responseModel.isQLMached = false;
                        }
                    }
                    //system.debug('qlMached >>'+ qlMached);
                   if(responseModel!=null && !responseModel.isQLMached)
                    {
                        //system.debug('isUpdateBaseline 2>>'+ responseModel.isUpdateBaseline);
                        //Changes for SDT-30514 & SDT- 30515- If this is not Update Baseline Case then Will update Start Date and Assign Default Values to it else will Update Only respected field
                        if(responseModel.isEndAndExtendBaseline)
                        {
                            
                            ql.SBQQ__StartDate__c =ow.serviceDate;
			    
			    //SDT-33378
                                // not to run for Bundle only child
                                //if(ql.AssetId__r.ParentId!=null){
                                    StartDateManagement mananageStartDate = new StartDateManagement();
                                    Boolean isStartDateValid =  mananageStartDate.validateQuoteLineStartDate(ql);
                                    if(!isStartDateValid){
                                     throw new AuraHandledException( StartDateManagement.InvalidStartDateErrorMessage) ;
                                    }
                               
                                
                            //}
			    
                            //ql.Exception_Effective_Date__c = ow.serviceDate;     //pkulkarn-TCS-28-Mar-23-Added for SDT-28044
                            //SDT-29615 Start
                            //SDT 34351
                            //ql.Exception_Effective_Date__c = (ow.serviceDate!=null)?DateTime.newInstanceGMT(ow.serviceDate.year(),ow.serviceDate.month(),ow.serviceDate.day(),12,00,00):ow.serviceDate;
                            //SDT-29615 End
                            //sdhikale TCS SDT-29806
                            //SDT 34351
                            //ql.Exceptions_Effective_Date__c = ow.serviceDate;
                            ql.SBQQ__EndDate__c = (ql.SBQQ__ProductName__c == Constant_Util.ServiceType_Delivery || ql.SBQQ__ProductName__c == Constant_Util.KEYS) ? ow.serviceDate : (ow.serviceEndDate != null) ? ow.serviceEndDate : null;
                            
                            //Changes for SDT-29104 and Changes for SDT-29385 are moved to this method to set default values
                            //SDT-38052 Start - replacing null assignment with condition assignment
                            //ql.Service_Action__c ='';
                            if(ql.SBQQ__Quote__r.SBQQ__Type__c ==  Constant_Util.QUOTE_TYPE_AMEND || 
                               ql.SBQQ__Quote__r.SBQQ__Type__c ==  Constant_Util.QUOTE_TYPE_EXCEPTION || 
                               ql.SBQQ__Quote__r.SBQQ__Type__c == Constant_Util.QUOTE_TYPE_CORRECTION){
                                   List<Schema.PicklistEntry> serviceActionEntries = Schema.SObjectType.SBQQ__QuoteLine__c.fields.Service_Action__c.getPicklistValues();
                                   if(ql.AssetId__c!=null){                                       
                                       ql.Service_Action__c = AssetQuoteProcurementController.getPicklistEntryByLabel(serviceActionEntries, Constant_Util.EXTEND_SERVICE);
                                   }
                               }
                            //SDT-38052 - End
                             //Modify for SDT-33285
                            QuoteLineServices.setDefaultValuesForQuoteLines(ql,ql.SBQQ__Quote__r.Name,asset);
                            //TCS-pkulkarn-13-Oct-2023-Added for SDT-32782-Capture Pickup line updates into a map
                            if(ql.SBQQ__ProductName__c == Constant_Util.PR_PICKUP)
                            {
                                bundlewisePickupQuoteLinesMap.put(ql.SBQQ__RequiredBy__c, ql);
                            }
                            //End-SDT-32782
                        }
                        // Changes for SDT-31788
                        else if (responseModel!= null && responseModel.isUpdateBaseline)
                        {
                           ql.Service_Action__c =QuoteLineSelector.SERVICE_ACTION_DO_NOT_EXTEND_SERVICE;
                        }
                        tobeChangeQuoteLines.add(ql);

                        //Changes for SDT-28571
                        wrapper.isAssetChanged = true;
                    }
		    //TCS-pkulkarn-13-Oct-2023-Added for SDT-32782-Capture Extra Pickup quote lines into a map
                    if(ql.SBQQ__ProductName__c == Constant_Util.PR_EXTRA_PICKUP)
                    {
                        bundlewiseExtraPickupQuoteLinesMap.put(ql.SBQQ__RequiredBy__c, ql);
                    }
                    //End-SDT-32782
                }
                else{
                    if(ql.SBQQ__ProductFamily__c != Constant_Util.WASTE_CATEGORY && ql.SBQQ__ProductFamily__c != Constant_Util.WASTE_STREAM)
                    {
                        ql.SBQQ__StartDate__c =ow.serviceDate;
                        //ql.Exception_Effective_Date__c = ow.serviceDate;     //pkulkarn-TCS-28-Mar-23-Added for SDT-28044
                        //SDT-29615 Start
                        //SDT34351 ql.Exception_Effective_Date__c = (ow.serviceDate!=null)?DateTime.newInstanceGMT(ow.serviceDate.year(),ow.serviceDate.month(),ow.serviceDate.day(),12,00,00):ow.serviceDate;
                        //SDT-29615 End
                        //sdhikale TCS SDT-29806
                        //SDT 34351 ql.Exceptions_Effective_Date__c = ow.serviceDate;
                        ql.SBQQ__EndDate__c = (ql.SBQQ__ProductName__c == Constant_Util.ServiceType_Delivery || ql.SBQQ__ProductName__c == Constant_Util.KEYS) ? ow.serviceDate : (ow.serviceEndDate != null) ? ow.serviceEndDate : null;
                        // if(ow.serviceEndDate != null)
                        //     ql.SBQQ__EndDate__c = ow.serviceEndDate;
                        //Changes for SDT-29104
                        //Changes for SDT-29104 and Changes for SDT-29385 are moved to this method to set default values
                       // QuoteLineServices.setDefaultValuesForQuoteLines(ql,ql.SBQQ__Quote__r.Name,asset); //Modify for SDT-33285
                       QuoteLineServices.setDefaultValuesForQuoteLines(ql,ql.SBQQ__Quote__r.Name); 
                       tobeChangeQuoteLines.add(ql);
                        //Changes for SDT-28571
                        wrapper.isAssetChanged = true;
                    }
                }
            }
            
            //TCS-pkulkarn-13-Oct-2023-Added for SDT-32782
            //Handle Extra pick changes-Retrieve List of Extra Pickup Quote Lines if Pickup line start date is changed
            List<SBQQ__QuoteLine__c> extraPickupQuoteLineListForUpdate = getExtraPickupLineForStartDateUpdate(bundlewisePickupQuoteLinesMap, bundlewiseExtraPickupQuoteLinesMap, true);
               // if(extraPickupQuoteLineListForUpdate.size() > 0)
               // {
                 //   tobeChangeQuoteLines.addAll(extraPickupQuoteLineListForUpdate);
              //  }
           // }
                 
           map<id,SBQQ__QuoteLine__c> extraPickupQuoteMAP= new map<id,SBQQ__QuoteLine__c>();
           for(SBQQ__QuoteLine__c extraPickupObj : extraPickupQuoteLineListForUpdate)
           {
                extraPickupQuoteMAP.put(extraPickupObj .Id,extraPickupObj);
           }
      if(extraPickupQuoteLineListForUpdate.size() > 0)
                {
                    boolean listCheck = false;                              
                               for(SBQQ__QuoteLine__c currentQuotelineObj : tobeChangeQuoteLines)
                              {
                                  if(extraPickupQuoteMAP.get(currentQuotelineObj.id) !=null)
                                  {
                                    for(Id key : bundlewiseExtraPickupQuoteLinesMap.keyset())
                                    {
                                        listCheck =  true;
                                        Date pickupLineStartDate = bundlewisePickupQuoteLinesMap.get(key).SBQQ__StartDate__c;
                                        currentQuotelineObj.SBQQ__StartDate__c = pickupLineStartDate;
                                        //SDT34351 currentQuotelineObj.Exception_Effective_Date__c = DateTime.newInstanceGMT(pickupLineStartDate.year(), pickupLineStartDate.month(), pickupLineStartDate.day(),12,00,00);
                                        // SDT34351 currentQuotelineObj.Exceptions_Effective_Date__c = pickupLineStartDate;
                                    }                                    
                                  }
                              }
                    If(!listCheck)
                    {
                        tobeChangeQuoteLines.addAll(extraPickupQuoteLineListForUpdate);
                    }
                }
            //End-SDT-32782
        }
        else
        {
            for(SBQQ__QuoteLine__c QL : quoteLines)
            {
                QL.SBQQ__StartDate__c = ow.serviceDate;
            //  if(ow.serviceEndDate != null)
            //     QL.SBQQ__EndDate__c = ow.serviceEndDate;
            QL.SBQQ__EndDate__c = (QL.SBQQ__ProductName__c == Constant_Util.ServiceType_Delivery || QL.SBQQ__ProductName__c == Constant_Util.KEYS) ? ow.serviceDate : (ow.serviceEndDate != null) ? ow.serviceEndDate : null;
                tobeChangeQuoteLines.add(QL);
            }
        }

        Boolean isRemovalAvailable=false;
        Boolean isOrderAvailable=false;
        Boolean isKeyOrderAvailable=false;
        //Additional Login to check Existing Quote Order for defect #SDT-25715
        List<Quote_Order__c> quoteOrderLst = new List<Quote_Order__c>();
        if(PqLine[0].Quote_Orders__r != null)
        {
            quoteOrderLst = PqLine[0].Quote_Orders__r;
        }
        Map<String,Id> serviceTypeOrderIdMap = new Map<String,Id>();
        if(quoteOrderLst!= null && !quoteOrderLst.isempty())
        {
            for(Quote_Order__c order: quoteOrderLst)
            {
                // Check if Service Type avaiable
                if(order.Service_Type__c == ow.serviceType || order.Service_Type__c.equalsIgnoreCase(Constant_Util.Haul_Away_Service) ) //41624
                {
                    isOrderAvailable= true;
                }
                // Check if Removal avaiable
                if(order.Service_Type__c == Constant_Util.REMOVAL)
                {
                    isRemovalAvailable= true;
                }
                 // Check if Lock Delivery Service Type avaiable
                 if(order.Service_Type__c == Constant_Util.LOCK_DELIVERY)
                 {
                    isKeyOrderAvailable= true;
                 }
            // Creating Map between Service Type and Order Id
            serviceTypeOrderIdMap.put(order.Service_Type__c, order.Id);
        }
    }

    //TCS-pkulkarn-SDT-41184-Added to avoid recursion on End Date update
    if(ow.serviceEndDate != null)
    {
        RecurrsiveTriggerHandler.isSkipEndDateUpdate = true;
    }
    //TCS-pkulkarn-SDT-41184-End
    if(tobeChangeQuoteLines!=null && !tobeChangeQuoteLines.isEmpty())
        {
            //DML to update QLs details along with start date
            RecurrsiveTriggerHandler.isSkipValidateQLCostPrice = true;
            update tobeChangeQuoteLines;
            RecurrsiveTriggerHandler.isSkipValidateQLCostPrice = false;
        }

        
    String dateStr = Constant_Util.EMPTY_STRING;
    //create Haul and Removal lines
    if(ow.serviceEndDate != null)
    {
        dateStr = ow.serviceEndDate.format();  
    }
    else
        deleteHaulRemovalqLine(parentQLId);

    //system.debug('dateStr > '+ dateStr);              
    validateHaulRemovalqLine(parentQLId, dateStr);
    
        

        if (deliveryQuoteLines.size() == 0) 
        {
            String productFamily =''; 
            if(PqLine.size()>0 && PqLine[0].SBQQ__ProductCode__c != ''){
                productFamily = PqLine[0].SBQQ__ProductFamily__c;
                if(PqLine[0].SBQQ__ProductCode__c =='CMP' && PqLine[0].Equipment_Size__c != null && PqLine[0].Equipment_Size__c.contains('-'))  
                {
                    Double eqSize = Double.valueOf(PqLine[0].Equipment_Size__c.substringAfter('-'));
                    if(eqSize < 10)
                    {
                        productFamily = Constant_Util.COMMERCIAL;
                    }
                }
                
                if(productFamily == Constant_Util.COMMERCIAL)
                    wrapper.result = validateAndCreateRemovalQouteOrder(ow, positionName, placementInstructions, isRemovalAvailable, serviceTypeOrderIdMap);
                else
                    wrapper.result = 'N/A';
            }
            else{
                wrapper.result = 'N/A';
            }
            //return wrapper;		//TCS-pkulkarn-6-Sep-2023-Commented and moved to end of method-SDT-30092
        } 
        else 
        {
            List<Quote_Order__c> quoteOrderList = new List<Quote_Order__c>();
            // Changes for SDT-30118
            //41624
            Boolean isHaul_Away = HaulAwayService.getIsHaulAwayService(quotelines[0].sbqq__Quote__r.SBQQ__Opportunity2__r.Case__c);
            if(isHaul_Away){
                ow.serviceType = Constant_Util.Haul_Away_Service;
            }
            for(SBQQ__QuoteLine__c ql : deliveryQuoteLines)
            {
                Quote_Order__c newDel = new Quote_Order__c();
                if (ql.Location_Position_Name__c != null) {
                    positionName=ql.Location_Position_Name__r.Container_Position__c;
                // Removed offsite check for this bug #SDT-22324
                //if (ql.Location_Position_Name__c != null && ql.Location_Position_Name__r.Container_Position__c.contains('OFFSITE')) {
                    newDel.Instructions__c ='POSITION:' + ql.Location_Position_Name__r.Container_Position__c + '\n'  + ow.instructions;
                    newDel.Acorn_Instructions__c ='POSITION:' + ql.Location_Position_Name__r.Container_Position__c + '\n'  + ow.acornInstructions;
                } else {
                    newDel.Instructions__c = ow.instructions;
                    newDel.Acorn_Instructions__c = ow.acornInstructions;
                }
                newDel.Quote_Line__c = ow.parentQuoteLine;
                newDel.Service_Quote_Line__c = ql.Id;
                if(ql.SBQQ__ProductFamily__c == PricingJSONRequest.SURCHARGES_AND_FEES)
                {   if(isHaul_Away){
                    newDel.Service_Type__c = Constant_Util.Haul_Away_Service;
                }   else{
                    newDel.Service_Type__c = Constant_Util.LOCK_DELIVERY;
                }
                    
                }
                else{
                        newDel.Service_Type__c = ow.serviceType;
                    
                    
                }
                newDel.Quantity__c = ow.quantity;
                newDel.Onsite_Contact__c = ow.onsiteContact;
                newDel.Onsite_Contact_Phone__c = ow.onsitePhone;
                newDel.Product_Type__c = ql.SBQQ__ProductName__c;
                if(String.isNotEmpty(ow.PONumber)){
                    newDel.Cust_Ref_Number__c = ow.PONumber;
                }
                newDel.Duration__c = ow.Duration;
                newDel.Occurrence_Type__c = ql.Occurrence_Type__c;
                newDel.Service_Time_Span__c = 'ASAP';
                newDel.Placement_Instructions__c= placementInstructions;
                //SDT-41473 - 41625 - 41966
                newDel.Vendor_Service_Id__c = vendorServiceId;
                newDel.Service_Date__c = ow.serviceDate;
                system.debug('isOrderAvailable >>'+ isOrderAvailable);
                if(isOrderAvailable)
                {
                    // In case of update pulling the Id from ServiceType and Order Map
                    newDel.Id = serviceTypeOrderIdMap.get(ow.serviceType);
                }
                if (isKeyOrderAvailable)
                {
                    if(isHaul_Away){
                        newDel.Id = serviceTypeOrderIdMap.get(Constant_Util.Haul_Away_Service);
                    }
                    else{
                        newDel.Id = serviceTypeOrderIdMap.get(Constant_Util.LOCK_DELIVERY);
                        system.debug('newDel.Id >' + newDel.Id);
                    }
                    
                }
                quoteOrderList.add(newDel);
            }
            
            try {
               
                upsert quoteOrderList;
            

                
                wrapper.result = validateAndCreateRemovalQouteOrder(ow, positionName, placementInstructions, isRemovalAvailable, serviceTypeOrderIdMap);
                //return wrapper;		//TCS-pkulkarn-6-Sep-2023-Commented and moved to end of method-SDT-30092
            } catch (exception e) {
                wrapper.result = e.getMessage();
                return wrapper;
            }
        }
        
        //TCS-pkulkarn-Added code for SDT-30092
        try 
        {
            if(PqLine[0].SBQQ__ProductFamily__c == Constant_Util.COMMERCIAL && caseRecordType != Constant_Util.New_Service_Case)
        		CreateDeliveryRemovalForCommercialProducts(PqLine[0].Id, ow);
        }
        catch (exception e) 
        {
            wrapper.result = e.getMessage();
        }
        //TCS-pkulkarn-SDT-30092-End
        return wrapper;		//TCS-pkulkarn-6-Sep-2023-Moved to end of method-SDT-30092
    }
    public static string validateAndCreateRemovalQouteOrder(OrderWrapper ow, String positionName, string placementInstructions, Boolean isRemovalAvailable, Map<String,Id> serviceTypeOrderIdMap){
        system.debug('inside validateAndCreateRemovalQouteOrder==');
        string result='SUCCESS';
        List<SBQQ__QuoteLine__c> removalHaulQuoteLines = new List<SBQQ__QuoteLine__c>();
        removalHaulQuoteLines = [SELECT Id, Occurrence_Type__c, SBQQ__ProductName__c, Location_Position_Name__r.Container_Position__c,
                                 Location_Position_Name__c,SBQQ__EndDate__c,Duration__c FROM SBQQ__QuoteLine__c 
                                 WHERE SBQQ__RequiredBy__c=:ow.parentQuoteLine AND 
                                 (SBQQ__ProductName__c ='Haul' OR SBQQ__ProductName__c ='Removal')];
        if(removalHaulQuoteLines.size()>0 && removalHaulQuoteLines[0].SBQQ__EndDate__c!=null){
            
            result = createQuoteOrder(ow, removalHaulQuoteLines[0], positionName, placementInstructions,isRemovalAvailable,serviceTypeOrderIdMap);
        }
        return result;
    }
    public static String createQuoteOrder(OrderWrapper ow, SBQQ__QuoteLine__c qLine, String positionName, string placementInstructions,Boolean isRemovalAvailable, Map<String,Id> serviceTypeOrderIdMap) {

        String result;
        SBQQ__QuoteLine__c ql = qLine;
        Quote_Order__c newRemovalDel = new Quote_Order__c();
        // Removed offsite check for this bug #SDT-22324
        if (positionName != null && positionName != '') {
            newRemovalDel.Instructions__c ='POSITION:' + positionName + '\n'  + ow.instructions;
            newRemovalDel.Acorn_Instructions__c ='POSITION:' + positionName + '\n'  + ow.acornInstructions;
        } else {
            newRemovalDel.Instructions__c = ow.instructions;
            newRemovalDel.Acorn_Instructions__c = ow.acornInstructions;
        }
        newRemovalDel.Quote_Line__c = ow.parentQuoteLine;
        newRemovalDel.Service_Quote_Line__c = ql.Id;
        //newRemovalDel.Service_Date__c = ow.serviceDate;
        if(qLine.SBQQ__EndDate__c !=null)
            newRemovalDel.Service_Date__c = qLine.SBQQ__EndDate__c;
        newRemovalDel.Service_Type__c = 'Removal';
        newRemovalDel.Quantity__c = ow.quantity;
        newRemovalDel.Onsite_Contact__c = ow.onsiteContact;
        newRemovalDel.Onsite_Contact_Phone__c = ow.onsitePhone;
        newRemovalDel.Product_Type__c = ql.SBQQ__ProductName__c;
        newRemovalDel.Cust_Ref_Number__c = ow.PONumber;
        newRemovalDel.Duration__c = ow.Duration;
        newRemovalDel.Occurrence_Type__c = ql.Occurrence_Type__c;
        newRemovalDel.Service_Time_Span__c = 'ASAP';
        newRemovalDel.Placement_Instructions__c= placementInstructions;
        //SDT-41473 - 41625 - 41966
        newRemovalDel.Vendor_Service_Id__c = ow.vendorServiceId;
        try {
            if(isRemovalAvailable)
            {
                // In case of update pulling the Id from ServiceType and Order Map
                newRemovalDel.Id = serviceTypeOrderIdMap.get(newRemovalDel.Service_Type__c);
                update newRemovalDel;
            }
            else
                insert newRemovalDel;
            result = 'SUCCESS';
            return result;
        } catch (exception e) {
            result = e.getMessage();
            return result;
        }
        
    }

    @AuraEnabled 
    public static OrderWrapper generateOrderWrapper(){
        OrderWrapper ow = new OrderWrapper();
        ow.parentQuoteLine = '';
        ow.serviceQuoteLine = '';
        ow.serviceDate = system.today();
        ow.serviceType = '';
        ow.onsiteContact = '';
        ow.onsitePhone ='';
        ow.instructions = '';
		ow.acornInstructions = '';
        ow.productType = '';
        ow.PONumber = '';
        ow.duration = '';
        ow.occurrenceType = '';
        ow.serviceTimeSpan = '';
        //Changes for SDT-27107
        ow.quoteId = '';
        ow.serviceEndDate =null;
        
        //SDT-41473 - 41625 - 41966
        ow.vendorServiceId = '';
        system.debug('Returned structure of the orderwrapper is: ' + ow);

        return ow;
    }

    @AuraEnabled
    public static String updateStatus(Id quoteId, String newStatus, Boolean quoteOnly) {
        SBQQ__Quote__c q = [SELECT Id, SBQQ__Status__c, Quote_Only__c
        ////SDT 42652 Haul Away
        ,SBQQ__Opportunity2__r.Case__c,SBQQ__Opportunity2__r.Case__r.Haul_Away_Service_Booked__c,
        SBQQ__Opportunity2__r.Case__r.Chargeable__c,SBQQ__Opportunity2__r.Case__r.Is_Haul_Away_Service__c,
        SBQQ__Opportunity2__r.Case__r.Haul_Away_information__c, SBQQ__Opportunity2__r.Case__r.Haul_Away_Vendor__c,
        Business_Rule__r.Is_Auto_Email__c, Business_Rule__r.No_Approval_Required__c, Genesys_Record_Created__c
                           FROM SBQQ__Quote__c
                           WHERE Id=:quoteId];
                
                           String result;
        //SDT 42652 Haul Away
        Boolean isHaulAway = HaulAwayService.getIsHaulAwayService(q.SBQQ__Opportunity2__r.Case__c);
        if(isHaulAway==true){
            String haulAwayServiceBooked = q.SBQQ__Opportunity2__r.Case__r.Haul_Away_Service_Booked__c;
            if(haulAwayServiceBooked.equalsIgnoreCase(Constant_Util.PROCURED_YES)){
                q.SBQQ__Status__c = Constant_Util.APPROVED;
            }
            else{
                q.SBQQ__Status__c = Constant_Util.QUOTE_PRICE_CONFIGURED;
                
            }
        }
        else{
            q.SBQQ__Status__c = newStatus;
        }
        q.Quote_Only__c = quoteOnly;
        try {
            //Changes for SDT-49634 - Disable CPQ Package Trigger
            SBQQ.TriggerControl.disable();
            update q;
            result = 'SUCCESS';
        } catch (exception e) {
            //Changes related to SDT-48086
            UTIL_LoggingService.logHandledExceptionWithClass(e, UserInfo.getOrganizationId(),
                                                UTIL_ErrorConstants.CONFIRM_CONFIGURATION_ACTION,
                                                System.LoggingLevel.Error,
                                                UTIL_ErrorConstants.QUOTEPROCUREMNTCONTROLLER_CLASSNAME,
                                                UTIL_ErrorConstants.UPDATESTATUS_METHODNAME,
                                                null);
            //Changes related to SDT-39632
            throw new AuraHandledException(e.getMessage());
        }
        finally{
            SBQQ.TriggerControl.enable();
        }
        //41544
        //     SBQQ__Quote__c q1 = [SELECT Id, SBQQ__Status__c, Quote_Only__c
                            
        //                     ,SBQQ__Opportunity2__r.Case__c,SBQQ__Opportunity2__r.Case__r.Haul_Away_Service_Booked__c,
        //                     SBQQ__Opportunity2__r.Case__r.Chargeable__c,SBQQ__Opportunity2__r.Case__r.Is_Haul_Away_Service__c,
        //                     SBQQ__Opportunity2__r.Case__r.Haul_Away_information__c, SBQQ__Opportunity2__r.Case__r.Haul_Away_Vendor__c,
        //                     Business_Rule__r.Is_Auto_Email__c, Business_Rule__r.Id, Business_Rule__r.No_Approval_Required__c, Genesys_Record_Created__c
        //                    FROM SBQQ__Quote__c
        //                    WHERE Id=:quoteId];
        //     system.debug('Business_Rule__r.Is_Auto_Email__c' + q1.Business_Rule__r.Is_Auto_Email__c);
        //     system.debug('Business_Rule__r.No_Approval_Required__c' + q1.Business_Rule__r.No_Approval_Required__c);
        //     system.debug('Genesys_Record_Created__c' + q1.Genesys_Record_Created__c);
        //     if(q1.Business_Rule__r.Is_Auto_Email__c == false && q1.Business_Rule__r.No_Approval_Required__c == false && q1.SBQQ__Status__c == 'Price Configured'){
        //             q1.Genesys_Record_Created__c = true;
        //         }
        // try {
        //     update q1;
        //     result = 'SUCCESS';
        //     system.debug('Genesys_Record_Created__c' + q1.Genesys_Record_Created__c);

        return result;

    }

    @AuraEnabled
    public static List<String> getSLAOverrideReasons() {
        List<String> slaReasons = new List<String>();
        Schema.DescribeFieldResult slaPicklistField = SBQQ__QuoteLine__c.SLA_Override_Reason__c.getDescribe();
        List<Schema.PicklistEntry> slaPicklistValues = slaPicklistField.getPicklistValues();
        for (Schema.PicklistEntry pck : slaPicklistValues) {
            slaReasons.add(pck.getValue());
        }
        return slaReasons;
    }

    @AuraEnabled
    public static String createQuoteLines(Id quoteId, Id productId, Id wasteStream, String equipmentSize) {

        String successMessage;
        List<SBQQ__ErrorCondition__c> errorConditions = new List<SBQQ__ErrorCondition__c>();
        Set<Id> actionIds = new Set<Id>();
        Set<Id> addProducts = new Set<Id>();
        Set<Id> remProducts = new Set<Id>();
        List<SBQQ__QuoteLine__c> newLines = new List<SBQQ__QuoteLine__c>();
        
        List<SBQQ__QuoteLine__c> insertQuoteLines = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> updateQuoteLines = new List<SBQQ__QuoteLine__c>();
        Map<String,Id> relationshipMap =  new Map<String,Id>();
        
        SBQQ__ProductOption__c materialOption = getMaterialOption(wasteStream);

        SBQQ__ProductOption__c categoryOption = getCategoryOption(materialOption.SBQQ__ConfiguredSKU__c, productId);

        Decimal quoteLineNumber = getMaxQuoteLineNumber(quoteId);
        
        Decimal parentLineNumber;
        String wasteCategoryId;

        

        SBQQ__QuoteLine__c parentQLine = QuoteLineServices.returnParentQuoteline(quoteId,productId,equipmentSize,'OC',true,1,quoteLineNumber);
        
          parentLineNumber = quoteLineNumber;
        quoteLineNumber = quoteLineNumber + 3;
        DateTime SLADate;

        try {
            insertQuoteLines.add(parentQLine);
        } catch (exception e) {
           system.debug(e.getMessage());
        }


        errorConditions = SBQQConfigurationRuleService.getProductRules(productId);
        if (errorConditions.size() > 0) {
            actionIds = SBQQConfigurationRuleService.getActions(errorConditions, parentQLine);
            addProducts = SBQQConfigurationRuleService.getAddRuleProducts(actionIds);
        }

        List<SBQQ__ProductOption__c> productOptions = [SELECT Id, Name, SBQQ__Quantity__c, Occurrence_Type__c, CostModelType__c,
                                                      Cost_Unit_of_Measure__c, PriceUOM__c, Schedule_Frequency__c, Frequency_Interval__c,
                                                      SBQQ__OptionalSKU__c, Equipment_Size__c, SBQQ__ProductFamily__c
                                                      FROM SBQQ__ProductOption__c
                                                      WHERE SBQQ__ConfiguredSKU__c =: productId AND (SBQQ__Selected__c = true OR SBQQ__OptionalSKU__c IN: addProducts) AND
                                                      SBQQ__ProductFamily__c != 'Waste Category' AND SBQQ__ProductFamily__c != 'Waste Stream'];

        productOptions.add(categoryOption);
        productOptions.add(materialOption);

        for (SBQQ__ProductOption__c po : productOptions) {

            if (po.SBQQ__ProductFamily__c == 'Waste Category') {

                SBQQ__QuoteLine__c qLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = quoteId,
                                                                SBQQ__Product__c = po.SBQQ__OptionalSKU__c,
                                                                Equipment_Size__c = equipmentSize,
                                                                SBQQ__StartDate__c = NULL,  
                                                                //SBQQ__RequiredBy__c = parentQLine.Id,
                                                                SBQQ__ProductOption__c = po.Id,
                                                                SBQQ__OptionLevel__c = 1,
                                                                SBQQ__Quantity__c = po.SBQQ__Quantity__c,
                                                                SBQQ__Number__c = parentLineNumber + 1,
                                                                SBQQ__CostEditable__c = false,
                                                                SBQQ__PriceEditable__c = true,
                                                                Occurrence_Type__c = po.Occurrence_Type__c,
                                                                CostModelType__c = po.CostModelType__c,
                                                                Cost_Unit_of_Measure__c = po.Cost_Unit_of_Measure__c,
                                                                PriceUOM__c = po.PriceUOM__c,
                                                                Schedule_Frequency__c = po.Schedule_Frequency__c,
                                                                Frequency_Interval__c = po.Frequency_Interval__c);

                try {
                    insertQuoteLines.add(qline);
                    //insert qline;
                    //wasteCategoryId = qline.Id;
                    
                } catch (exception e) {
                    system.debug(e.getMessage());
                }
            } else {
                SBQQ__QuoteLine__c qLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = quoteId,
                                                                SBQQ__Product__c = po.SBQQ__OptionalSKU__c,
                                                                Equipment_Size__c = equipmentSize,
                                                                //SBQQ__RequiredBy__c = po.SBQQ__ProductFamily__c == 'Waste Stream' ? wasteCategoryId : parentQLine.Id,
                                                                SBQQ__ProductOption__c = po.Id,
                                                                SBQQ__OptionLevel__c = po.SBQQ__ProductFamily__c == 'Waste Stream' ? 2 : 1,
                                                                SBQQ__Number__c = po.SBQQ__ProductFamily__c == 'Waste Stream' ? parentLineNumber + 2 : quoteLineNumber,
                                                                SBQQ__CostEditable__c = po.SBQQ__ProductFamily__c == 'Waste Stream' ? false : true,
                                                                SBQQ__PriceEditable__c = po.SBQQ__ProductFamily__c == 'Waste Stream' ? false : true,
                                                                SBQQ__Quantity__c = po.SBQQ__Quantity__c,
                                                                SBQQ__StartDate__c = parentQLine.SBQQ__StartDate__c,  
                                                                Occurrence_Type__c = po.Occurrence_Type__c, 
                                                                CostModelType__c = po.CostModelType__c,
                                                                Cost_Unit_of_Measure__c = po.Cost_Unit_of_Measure__c, 
                                                                PriceUOM__c = po.PriceUOM__c,
                                                                Schedule_Frequency__c = po.Schedule_Frequency__c,
                                                                Frequency_Interval__c = po.Frequency_Interval__c); 
                
                //newLines.add(qLine);
                insertQuoteLines.add(qLine);
                quoteLineNumber = quoteLineNumber + 1;
            }

        }

        try {
            //insert newLines;
            insert insertQuoteLines;
            //List<SBQQ__QuoteLine__c> insertLines = QuoteLineServices.getQuoteLinesByQuoteId(quoteId);
            
            // get all inserted Ids
            Set<Id> allInsertedIds = new Set<Id>();
            for(SBQQ__QuoteLine__c quoteLineObj: insertQuoteLines)
            {
                 allInsertedIds.add(quoteLineObj.Id);
            }


         List<SBQQ__QuoteLine__c> insertLines = QuoteLineServices.getQuoteLinesByIds(allInsertedIds);
         //Haul Away SDT 44574
         Id haulAwayVendorId;
         boolean isHaulAway = HaulAwayService.getIsHaulAwayServiceForQuote(quoteId);
         String hVendor;
         if(isHaulAway){
         for(SBQQ__QuoteLine__c quoteLineObj: insertLines)
         {
             //This loop is added to calculate Vendor__c for Quoteline once and same should be used for rest of bundle QLs
             if(quoteLineObj.SBQQ__RequiredBy__c ==null && haulAwayVendorId==null){
             String vendor = quoteLineObj.SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__r.Haul_Away_Vendor__c;
              String location = quoteLineObj.SBQQ__Quote__r.SBQQ__ShippingCountry__c;
             hVendor = HaulAwayService.getHaulAwayVendorByLocation(vendor,location);
             haulAwayVendorId = HaulAwayService.getHaulAwayVendor(hVendor);
                 quoteLineObj.Vendor__c = haulAwayVendorId;
             }
         }  
        } 
         /* Loop for finding Id for relationship  */
            for(SBQQ__QuoteLine__c quoteLineObj: insertLines)
            {
                //Haul Away SDT 44574
                if(isHaulAway && haulAwayVendorId!=null){
                    quoteLineObj.Vendor__c = haulAwayVendorId;
                }
                //Haul Away end
                if(quoteLineObj.SBQQ__Bundle__c)
                    relationshipMap.put('ParentQuote',quoteLineObj.id);
                
                if(quoteLineObj.SBQQ__ProductFamily__c == 'Waste Category')
                    relationshipMap.put('WasteCategory',quoteLineObj.id);
            }      
            
            boolean isExtraPickup=false;
            /* Updating relationship */
            for(SBQQ__QuoteLine__c quoteLineObj: insertLines)
            {
                if(quoteLineObj.SBQQ__Bundle__c)
                {
                     //System.debug('insideParent>>');
                    //SLADate = QuoteFavoritesController.determineSLA(relationshipMap.get('ParentQuote'));
                    //quoteLineObj.SBQQ__StartDate__c = SLADate.date();
                    updateQuoteLines.add(quoteLineObj);
                }
                if(quoteLineObj.SBQQ__ProductFamily__c == 'Waste Stream')
                {
                    quoteLineObj.SBQQ__RequiredBy__c  = relationshipMap.get('WasteCategory');
                    updateQuoteLines.add(quoteLineObj);  
                }
                else if(quoteLineObj.SBQQ__Bundle__c != true && quoteLineObj.SBQQ__ProductFamily__c != 'Waste Stream')
                {
                    quoteLineObj.SBQQ__RequiredBy__c = relationshipMap.get('ParentQuote');
                    updateQuoteLines.add(quoteLineObj);

                    if(quoteLineObj.SBQQ__RequiredBy__c != null && quoteLineObj.SBQQ__ProductName__c == Constant_Util.EXTRA_PICKUP){
                        isExtraPickup =true;
                     }
                    
                }
            }

            if(isExtraPickup)
            {
                for(SBQQ__QuoteLine__c quotePickupLine : updateQuoteLines){
                    if(quotePickupLine.SBQQ__ProductName__c == Constant_Util.PICKUP_CSTYPE && quotePickupLine.Occurrence_Type__c == Constant_Util.SCHEDULED_TYPE)
                    {
                        quotePickupLine.IsExtraPickup__c = true;
                    }
                }
            }

            update updateQuoteLines;
            successMessage = relationshipMap.get('ParentQuote');
           // successMessage = parentQLine.Id;
        } catch (exception e) {
            successMessage = e.getMessage();
        }

        return successMessage;
    }
    
    public static SBQQ__ProductOption__c getMaterialOption(String wasteStream) {

        SBQQ__ProductOption__c materialOption = [SELECT Id, Name, SBQQ__Quantity__c, Occurrence_Type__c, CostModelType__c,
                                                Cost_Unit_of_Measure__c, PriceUOM__c, Schedule_Frequency__c, Frequency_Interval__c,
                                                SBQQ__ConfiguredSKU__c, SBQQ__OptionalSKU__c, Equipment_Size__c, SBQQ__ProductFamily__c
                                                FROM SBQQ__ProductOption__c
                                                WHERE Id =: wasteStream
                                                LIMIT 1];
        return materialOption;

    }
    
    public static SBQQ__ProductOption__c getCategoryOption(String materialParentSKU, String productId) {

        SBQQ__ProductOption__c categoryOption = [SELECT Id, Name, SBQQ__Quantity__c, Occurrence_Type__c, CostModelType__c,
                                                Cost_Unit_of_Measure__c, PriceUOM__c, Schedule_Frequency__c, Frequency_Interval__c,
                                                SBQQ__ConfiguredSKU__c, SBQQ__OptionalSKU__c, Equipment_Size__c, SBQQ__ProductFamily__c
                                                FROM SBQQ__ProductOption__c
                                                WHERE SBQQ__OptionalSKU__c =: materialParentSKU AND SBQQ__ConfiguredSKU__c =: productId
                                                LIMIT 1];
        return categoryOption;

    }

    public static Decimal getMaxQuoteLineNumber(String quoteId) {

        List<SBQQ__QuoteLine__c> maxQL = [SELECT SBQQ__Number__c
                                          FROM SBQQ__QuoteLine__c
                                          WHERE SBQQ__Quote__c =: quoteID
                                          ORDER BY SBQQ__Number__c DESC
                                          LIMIT 1];

        Decimal quoteLineNumber = (maxQL.size() > 0) ? maxQL[0].SBQQ__Number__c + 1: 1;

        return quoteLineNumber;

    }
    /*SDT-25277 Deleting Removal Quoteline*/
    @AuraEnabled
    public static string deleteHaulRemovalqLine(string parentQLineId){
        string msg = 'SUCCESS';
        try{
		//changes done for 32420 and 32464 --- removal QL will only get delete in case its quote's type is 'Quote'
            List<SBQQ__QuoteLine__c> haulRemovalQLinesListToDelete = new List<SBQQ__QuoteLine__c>();
            List<SBQQ__QuoteLine__c> haulRemovalQLinesList = new List<SBQQ__QuoteLine__c>();
            haulRemovalQLinesList = [SELECT id,SBQQ__Quote__r.SBQQ__Type__c
                                     FROM SBQQ__QuoteLine__c 
                                     WHERE SBQQ__RequiredBy__c=:parentQLineId 
                                     AND SBQQ__Product__c!= null 
                                     AND SBQQ__Product__r.Name = 'Removal'];
            if(haulRemovalQLinesList.size()>0){
                for(SBQQ__QuoteLine__c ql : haulRemovalQLinesList){
                    if(ql.SBQQ__Quote__r.SBQQ__Type__c == 'Quote'){
                        haulRemovalQLinesListToDelete.add(ql);
                    }
                }
            }
            system.debug('Inside deleteHaulRemovalqLine ==>'+haulRemovalQLinesList);
            if(haulRemovalQLinesListToDelete.size()>0){
                delete haulRemovalQLinesListToDelete;
            }     
        }
        catch(exception ex){
            msg = ex.getMessage();
        }
        return msg;
    }

    @AuraEnabled
    public static string validateHaulRemovalqLine(string parentQLineId, string endDate){
        system.debug('parentQLineId==>'+parentQLineId);
        string result = 'SUCCESS';
        SBQQ__QuoteLine__c parentQLine = getParentQline(parentQLineId);
        system.debug('parentQLine==>'+parentQLine);
        system.debug('parentQLine.Duration__c==>'+parentQLine.Duration__c);
        system.debug('parentQLine.SBQQ__ProductFamily__c==>'+parentQLine.SBQQ__ProductFamily__c);
        if(parentQLine.Duration__c =='TEMP'){
            if(parentQLine.SBQQ__ProductFamily__c=='Rolloff'){
                result = validateHaul(parentQLine, endDate);// need to add quote serial number logic in near future
            }else if(parentQLine.SBQQ__ProductFamily__c=='Commercial'){
                result = validateRemoval(parentQLine, endDate);// need to add quote serial number logic in near future
            }
        }
        return result;
    }

    // Changes for SDT-31623
    public static SBQQ__ProductOption__c getProductOptionId(string parentQLineProdutId, string childProductId){
        
        SBQQ__ProductOption__c productOption = new SBQQ__ProductOption__c();
        List<SBQQ__ProductOption__c> pOptionList = [SELECT id, SBQQ__ConfiguredSKU__c, SBQQ__ConfiguredSKU__r.Name, SBQQ__OptionalSKU__c, 
                                                    SBQQ__OptionalSKU__r.Name, Occurrence_Type__c , Cost_Unit_of_Measure__c, CostModelType__c, PriceUOM__c // Changes for SDT-32028
                                                    FROM SBQQ__ProductOption__c 
                                                    WHERE SBQQ__ConfiguredSKU__c = :parentQLineProdutId AND 
                                                    SBQQ__OptionalSKU__c=:childProductId];
        if(pOptionList.size()>0){
            productOption = pOptionList[0];
        }
        return productOption;
    }
    public static id getProductId(string productName, string parentQuotelineProductId){
        List<SBQQ__ProductOption__c> pOptionList = new List<SBQQ__ProductOption__c>();
        pOptionList = [SELECT SBQQ__OptionalSKU__c
                                                    FROM SBQQ__ProductOption__c 
                                                    WHERE SBQQ__ConfiguredSKU__c = :parentQuotelineProductId 
                                                    AND SBQQ__OptionalSKU__r.Name=:productName];
        
        if(pOptionList.size()==0){
            return null;
        }
        return pOptionList[0].SBQQ__OptionalSKU__c;
    }
    public static SBQQ__QuoteLine__c assignParentQLineFields(SBQQ__QuoteLine__c parentQLine){
        SBQQ__QuoteLine__c childQLine = new SBQQ__QuoteLine__c(
        	SBQQ__Quote__c = parentQLine.SBQQ__Quote__c,
            SBQQ__RequiredBy__c = parentQLine.Id,
            Account__c = parentQLine.Account__c,
            SBQQ__StartDate__c = parentQLine.SBQQ__StartDate__c,
            SBQQ__EndDate__c = parentQLine.SBQQ__EndDate__c, 
            //SDT 34351 Exception_Effective_Date__c = parentQLine.Exception_Effective_Date__c,
            //sdhikale TCS SDT-29806
            //SDT 34351 Exceptions_Effective_Date__c = parentQLine.Exceptions_Effective_Date__c,
            Exception_Type__c = parentQLine.Exception_Type__c,
            Exception_Comments__c = parentQLine.Exception_Comments__c,
            Exception_Reason__c = parentQLine.Exception_Reason__c,
  			Equipment_Size__c = parentQLine.Equipment_Size__c,
            Occurrence_Type__c = parentQLine.Occurrence_Type__c,
            Schedule_Frequency__c = parentQLine.Schedule_Frequency__c,
            Frequency_Interval__c = parentQLine.Frequency_Interval__c,
            Day_of_Month__c = parentQLine.Day_of_Month__c,
            Service_Days__c = parentQLine.Service_Days__c,
            Duration__c = parentQLine.Duration__c,
            //SDT-38285 - start
            Month_Relative_Interval__c = parentQLine.Month_Relative_Interval__c,
            Month_Relative__c = parentQLine.Month_Relative__c
            //SDT-38285 - End
        );
        
            //End SDT-29615 
        return childQLine;
    }
    public static string validateHaul(SBQQ__QuoteLine__c parentQLine, string endDate){
        system.debug('parentQLine==>1679'+parentQLine);
        string result = 'SUCCESS';
        try{
            SBQQ__QuoteLine__c haulQLine = getQLine(parentQLine.Id,'Haul');
            system.debug('haulQLine==>'+haulQLine);
            if(haulQLine == null || haulQLine.Id == null){
                haulQLine = new SBQQ__QuoteLine__c();
                haulQLine = assignParentQLineFields(parentQLine);
                haulQLine.SBQQ__Product__c = getProductId('Haul', parentQLine.SBQQ__Product__c);
                haulQLine.SBQQ__Quantity__c = 1;
                //date d = date.valueOf(endDate);
                //haulQLine.SBQQ__EndDate__c = date.valueOf(d);
                if(!String.isEmpty(endDate))
                {
                    date haulenddate = date.parse(endDate);
                    haulQLine.SBQQ__EndDate__c = haulenddate;
                }
                if(haulQLine.SBQQ__Product__c!=null){
                    // Changes for SDT-31623
                    SBQQ__ProductOption__c haulProductOption= getProductOptionId(parentQLine.SBQQ__Product__c, haulQLine.SBQQ__Product__c);
                    if(haulProductOption!= null && haulProductOption.Id != null)
                    {
                        haulQLine.SBQQ__ProductOption__c= haulProductOption.Id;
                    }
                }
                
                haulQLine.SBQQ__Number__c = getMaxQuoteLineNumber(parentQLine.SBQQ__Quote__c);
                insert haulQLine;
                // haulQLine = [SELECT id, SBQQ__EndDate__c FROM SBQQ__QuoteLine__c WHERE id=:haulQLine.id];
                // if(haulQLine.SBQQ__EndDate__c==null){
                //     haulQLine.SBQQ__EndDate__c = haulenddate;
                //     update haulQLine;
                // }
            }
            else
            {
                SBQQ__QuoteLine__c updatedhaulQLine = assignParentQLineFields(parentQLine);
                updatedhaulQLine.Id = haulQLine.Id;
                system.debug('haulQLine.Exception_Effective_Date__c >'+ haulQLine.Exception_Effective_Date__c);
                //sdhikale TCS SDT-29806
                system.debug('haulQLine.Exceptions_Effective_Date__c >'+ haulQLine.Exceptions_Effective_Date__c);
                update updatedhaulQLine;
            }
        }catch(exception ex){
        	result= ex.getMessage();
        }
        return result;
    }

    //Changes for SDT-31623: To clear Schedule values
    private static SBQQ__QuoteLine__c clearScheduleValues(SBQQ__QuoteLine__c qLine)
    {
        qLine.Schedule_Frequency__c =  null;
        qLine.Frequency_Interval__c =  null;
        qLine.Day_of_Month__c =  null;
        qLine.Service_Days__c = null;
        //SDT-38285 - start
        qLine.Month_Relative_Interval__c = null;
        qLine.Month_Relative__c = null;
        //SDT-38285 - End
        return qLine;
    }

    public static string validateRemoval(SBQQ__QuoteLine__c parentQLine, string endDate){
        string result = 'SUCCESS';
        try{
            SBQQ__QuoteLine__c removalQLine = getQLine(parentQLine.Id,'Removal');
            if(removalQLine == null || removalQLine.Id == null){
                removalQLine = new SBQQ__QuoteLine__c();
                removalQLine = assignParentQLineFields(parentQLine);
                removalQLine.SBQQ__Product__c = getProductId('Removal', parentQLine.SBQQ__Product__c);
                removalQLine.SBQQ__Quantity__c = 1;
                system.debug('parentQLine.SBQQ__ProductOption__c==>'+parentQLine.SBQQ__ProductOption__c);
                system.debug('removalQLine.SBQQ__Product__c==>'+removalQLine.SBQQ__Product__c);
                if(removalQLine.SBQQ__Product__c!=null){
		    // Changes for SDT-31623
                    SBQQ__ProductOption__c removalProductOption= getProductOptionId(parentQLine.SBQQ__Product__c, removalQLine.SBQQ__Product__c);
                    if(removalProductOption!= null && removalProductOption.Id != null)
                    {
                        // Setting up Occurrence_Type__c = On Call for Removal and removing other schedule values
                        removalQLine.SBQQ__ProductOption__c =removalProductOption.Id;
                        removalQLine.Occurrence_Type__c =removalProductOption.Occurrence_Type__c;
                        // Changes for SDT-32028
                        removalQLine.PriceUOM__c =removalProductOption.PriceUOM__c ;
                        removalQLine.Cost_Unit_of_Measure__c =removalProductOption.Cost_Unit_of_Measure__c;
                        removalQLine.CostModelType__c =removalProductOption.CostModelType__c;
                        //Removing Other Schedule Values
                        removalQLine = clearScheduleValues(removalQLine);
                    }
                }
                //removalQLine.SBQQ__ProductOption__c = getProductOptionId(parentQLine.SBQQ__ProductOption__c, 'Removal');
                // date d = date.valueOf(endDate);
                // removalQLine.SBQQ__EndDate__c = date.valueOf(d);
                if(!String.isEmpty(endDate))
                {
                    date removalenddate = date.parse(endDate);
					//SDT 32952
                    //removalQLine.SBQQ__EndDate__c = removalenddate;
					RemovalQuoteLineHandler.setDatesForRemovalQL(removalQLine,removalenddate);
                }
                removalQLine.SBQQ__Number__c = getMaxQuoteLineNumber(parentQLine.SBQQ__Quote__c);
                
				//SDT 32952
				//Removal Quoteline will only be inserted if bundle has end date 
				//insert removalQLine;
				//TCS-pkulkarn-SDT-41184-Added if condition to check for Quote Type-Removal quote line not to be added for Add/Change quotes for TEMP Duration on Commercial containers
                if(parentQLine.SBQQ__Quote__r.SBQQ__Type__c == Constant_Util.QUOTE)
                {
                    RemovalQuoteLineHandler.checkIfBundleQLHasEnddateBeforeInsert(removalQLine);
                }
                
                // removalQLine = [SELECT id, SBQQ__EndDate__c FROM SBQQ__QuoteLine__c WHERE id=:removalQLine.id];
                // if(removalQLine.SBQQ__EndDate__c==null){
                //     removalQLine.SBQQ__EndDate__c = removalenddate;
                //     update removalQLine;
                // }
                
            }
            else
            {
                SBQQ__QuoteLine__c updatedremovalQLine = assignParentQLineFields(parentQLine);
                updatedremovalQLine.Id = removalQLine.Id;
				//SDT32952
				if(!String.isEmpty(endDate))
				{
					date removalDate = date.parse(endDate);
					RemovalQuoteLineHandler.setDatesForRemovalQL(updatedremovalQLine,removalDate);
				}
               
	       
	       // Overriding Occurrence_Type__c Value from Removal QL
                updatedremovalQLine.Occurrence_Type__c=removalQLine.Occurrence_Type__c;
                 //Removing Other Schedule Values
                updatedremovalQLine = clearScheduleValues(updatedremovalQLine);
                system.debug('removalQLine.Exception_Effective_Date__c >'+ removalQLine.Exception_Effective_Date__c);
                //sdhikale TCS SDT-29806
                system.debug('removalQLine.Exceptions_Effective_Date__c >'+ removalQLine.Exceptions_Effective_Date__c);
                update updatedremovalQLine;
            }
        }catch(exception ex){
        	result= ex.getMessage();
        }
        return result;
    }
    public static SBQQ__QuoteLine__c getQLine(string qLineId, string prdName){
        //SDT-38285 Added Month_Relative_Interval__c and Month_Relative__c
        List<SBQQ__QuoteLine__c> qLineList = [SELECT id, SBQQ__Quote__c, SBQQ__RequiredBy__c, Account__c, SBQQ__StartDate__c, SBQQ__EndDate__c, Exception_Effective_Date__c, Exceptions_Effective_Date__c,  Exception_Type__c, Exception_Comments__c, Exception_Reason__c, Equipment_Size__c, Occurrence_Type__c, Schedule_Frequency__c, Frequency_Interval__c, Day_of_Month__c, Service_Days__c, Duration__c, Month_Relative_Interval__c, Month_Relative__c FROM SBQQ__QuoteLine__c WHERE SBQQ__RequiredBy__c=:qLineId 
                                             AND SBQQ__ProductName__c =:prdName];
        if(qLineList.size()>0){
         	return qLineList[0];   
        }
        return null;
    }
    public static SBQQ__QuoteLine__c getParentQline(string parentQLineId){
        //SDt-38285 Added Month_Relative_Interval__c and Month_Relative__c
        //TCS-pkulkarn-SDT-41184-Added SBQQ__Quote__r.SBQQ__Type__c to the SOQL
        List<SBQQ__QuoteLine__c> pQLineList = [SELECT id, SBQQ__Quote__c, Account__c, SBQQ__StartDate__c, SBQQ__EndDate__c, Exception_Effective_Date__c, Exceptions_Effective_Date__c, Exception_Type__c,
                                               Exception_Comments__c, Exception_Reason__c, Equipment_Size__c, SBQQ__Quantity__c, Occurrence_Type__c, Schedule_Frequency__c,
                                               Frequency_Interval__c, Day_of_Month__c, Service_Days__c, SBQQ__Product__c, SBQQ__ProductOption__c,Duration__c,SBQQ__ProductFamily__c,
                                               SBQQ__Product__r.ProductCode, Month_Relative_Interval__c, Month_Relative__c, SBQQ__Quote__r.SBQQ__Type__c
                                               FROM SBQQ__QuoteLine__c WHERE id=:parentQLineId];
        if(pQLineList.size()>0){
            return pQLineList[0];
        }
        return null;
    }
    
    @AuraEnabled 
    public static Map<string,Object> fetchUser(Id quoteId){
        
        Map<string,Object> result = new Map<string,Object>();
        
        User u = [select id,UserRole.Name,RoleCombination__c, Profile.Name from User where id =: userInfo.getUserId()];
        
        result.put('User', u);
        result.put('NewServiceRecordType', Constant_Util.New_Service_Case);
        //SDT-41473
        result.put('isHaulAway', HaulAwayService.getIsHaulAwayServiceForQuote(quoteId));
        
        return result;
    }
    
    // method to get the Quotelines by Quotes
    @AuraEnabled 
    public static List<HeaderWrapper> getQuoteLinesByQuote(Id quoteId)
    {
        List<HeaderWrapper> headerList = new List<HeaderWrapper>();
        List<SBQQ__QuoteLine__c> headerRecords = getQuoteProducts(quoteId);
        for (SBQQ__QuoteLine__c header : headerRecords){
            HeaderWrapper prod = new HeaderWrapper();
            prod.parentId = header.Id;
            prod.locationId = header.Account__c;
            prod.quoteLineName = header.Name;
            prod.productId = header.SBQQ__Product__c;
            prod.equipmentType = header.SBQQ__ProductName__c;
            prod.equipmentTypeCode = header.SBQQ__ProductCode__c;
            prod.equipmentSize = header.Equipment_Size__c;
            prod.duration = header.Duration__c;
            prod.quoteID = header.SBQQ__Quote__c;

            List<SBQQ__QuoteLine__c> detailRecords = getQuoteDetails(header.Id);
            for (SBQQ__QuoteLine__c detail: detailRecords) {
                //Immediately store the material type to the header record and skip to the next
                //iteration
                if (detail.SBQQ__ProductFamily__c == 'Waste Stream') {
                    prod.materialType = detail.SBQQ__ProductName__c;
                    prod.materialTypeCode = detail.SBQQ__ProductCode__c;
                    continue;
                }
            }
            headerList.add(prod);
        }
        return headerList;
    }

     // method to get the products
     @AuraEnabled 
     public static List<Product2> getProducts()
     {
         return QuoteFavoritesController.getProducts();
     }

     //method to get the selected Products
     @AuraEnabled
    public static Product2 getPreselectedProduct(string selectedProductName){
        return QuoteFavoritesController.getPreselectedProduct(selectedProductName);
    }

    //get the materials by product
    @AuraEnabled
    public static List<SBQQ__ProductOption__c> getWasteStreams(Id productId) {
        return QuoteFavoritesController.getWasteStreams(productId);
    }

    @AuraEnabled
    public static Map<String, String> getDurations() {
        Map<String, String> durationMap = new Map<String, String>();
        List<Schema.PicklistEntry> durationEntries = Schema.SObjectType.SBQQ__QuoteLine__c.fields.Duration__c.getPicklistValues();
        for(Schema.PicklistEntry pe :durationEntries){
            if(pe.value!='SEAS')
            {
                durationMap.put(pe.value, pe.label);
            }
        }
        return durationMap;
    }
    @AuraEnabled
    public static SBQQ__QuoteLine__c getParentQlineRec(Id parentId)
    {
      return [SELECT Id, SBQQ__StartDate__c, SBQQ__EndDate__c, SBQQ__Quantity__c, Description_of_Waste__c,
      SBQQ__ProductName__c,SBQQ__ProductFamily__c, SBQQ__ProductOption__r.SBQQ__Type__c, SBQQ__Product__c, Equipment_Size__c, SBQQ__Quote__c,
      SBQQ__RequiredBy__c,Duration__c, SID__c
      FROM SBQQ__QuoteLine__c
      WHERE Id =: parentId];
    }
    
          /*
     * SDT-26026
     * Dev: Jatan
     * Description: Created Comment for quote
     * 
     */
    @AuraEnabled
    public static void createQuoteComment(String quoteComment , id caseId){
        String result ;
        try {
            system.debug('In Procurement calss ' +QuoteComment +' ' +caseId);
            //List<SBQQ__Quote__c> caseId = [select SBQQ__Opportunity2__r.Case__c from SBQQ__Quote__c where id =: quoteId limit 1];
          result =  AcornController.createAcornComment(quoteComment,caseId);
        } catch (Exception e) {
            //Changes related to SDT-48086
            UTIL_LoggingService.logHandledExceptionWithClass(e, UserInfo.getOrganizationId(),
                                                            UTIL_ErrorConstants.CONFIRM_CONFIGURATION_ACTION,
                                                            System.LoggingLevel.Error,
                                                            UTIL_ErrorConstants.QUOTEPROCUREMNTCONTROLLER_CLASSNAME,
                                                            UTIL_ErrorConstants.CREATEQUOTECOMMENT_METHODNAME+ UTIL_ErrorConstants.BLANK_SPACE+ 
                                                            'AcornController.createAcornComment',
                                                            null);
            
            throw new AuraHandledException(e.getMessage());
        }
        //return result;
    }
	
	/*
     * SDT-27107
     * Dev: Seema
     * Description: get SLA date
     * 
     */

    @AuraEnabled
    public static Date callDetermineSLA(String parentQuoteLineId) {
        if(!QuoteFavoritesController.getSLASwitch())
        {
            //Code Change for SDT-39637 & 45007
            Date slaDate;
            DateTime slaDateTime = QuoteFavoritesController.determineSLA(parentQuoteLineId);
            system.debug('SLA Datetime ' + slaDateTime);

            slaDate = slaDateTime.dateGmt();
            System.debug('SLA Date: ' + slaDate);
            return slaDate; 
        }
        else
        {
            // Old Code before SDT-34542 Change
            DateTime slaDate ;
            try {
                slaDate=QuoteFavoritesController.determineSLA(parentQuoteLineId);
            } 
            catch (Exception e) 
            {
                throw new AuraHandledException(e.getMessage());
            } 
            return slaDate.date(); 
        }        
    }
    
    /*
     * SDT-27107
     * Dev: Seema
     * Description: Populate Start And EndDate On Related QuoteLines as null.
     * 
     */
    @AuraEnabled
    public static void removeStartAndEndDateOnRelatedQL(String parentQuoteLineId) {
        try {
          If(parentQuoteLineId!=NULL)
          {
             List<SBQQ__QuoteLine__c> qlList =  QuoteLineServices.getQuoteLinesByParentId(parentQuoteLineId);
             
              if(qlList.size()>0){
                  for(SBQQ__QuoteLine__c ql : qlList){
                    if(ql.SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__r.RecordType.DeveloperName==Constant_Util.New_Service_Case){
                            ql.SBQQ__StartDate__c=NULL;
                            ql.SBQQ__EndDate__c=NULL;
                        }
                  }
                  update qlList;
        }
          }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
	

    /*SDT-21804- 
        Dev: Rishi
        FC: Anmoal Bharti
        Description: added validation for description of waste field on quote line. 
        This validation is only applicable when Quote/Quote lines are being created/updated from CEI screen.
		Test Coverage is covered with methods validateDescriptionOfWasteForAllTest(), validateDescriptionOfWasteForAnyTest() ,validateDescriptionOfWasteForCustomTest() and validateDescriptionOfWasteForSuccessTest() of ServiceSchedulerCtrlTest class
    */
    public static Map<String,List<String>> validateDescriptionOfWaste(HeaderWrapper productWrapper) {
        Map<String,List<String>> resultErrorMap;
        if(productWrapper.materialType!=null){
            String wasteDescription = String.isBlank(productWrapper.wasteDescription) ? null : productWrapper.wasteDescription;
            resultErrorMap = QuoteProcurementController.validateProductRules(productWrapper.productId, wasteDescription, productWrapper.materialType);
        }
        if(resultErrorMap!=null && !resultErrorMap.isEmpty()){
            return resultErrorMap;
        }else{
            List<String> successList = new List<String>();
            successList.add('Success');
            resultErrorMap = new Map<String,List<String>>();
            resultErrorMap.put('Success',successList);
            return resultErrorMap;
        }
    }
	
    /*SDT-21804- 
        Dev: Rishi
        FC: Anmoal Bharti
        Description: added validation for description of waste field on quote line. 
        This validation is only applicable when Quote/Quote lines are being created/updated from CEI screen.
		Test Coverage is covered with methods validateDescriptionOfWasteForAllTest(), validateDescriptionOfWasteForAnyTest() ,validateDescriptionOfWasteForCustomTest() and validateDescriptionOfWasteForSuccessTest() of ServiceSchedulerCtrlTest class
    */
    public static Map<String,List<String>> validateProductRules(String productId, String wasteDescription,String wasteStream){
        List<ProductRulesExecutor.ErrorConditionsModal> errCondModalList = new List<ProductRulesExecutor.ErrorConditionsModal>();
        ProductRulesExecutor.ErrorConditionsModal errorConditionsObj =  new ProductRulesExecutor.ErrorConditionsModal();
        errorConditionsObj.testedObject = 'Configuration Attributes';
        errorConditionsObj.testedField = 'Description_of_Waste__c';
        errorConditionsObj.testedValue = wasteDescription;
        errorConditionsObj.testedValueType = 'String';
        errCondModalList.add(errorConditionsObj);

        ProductRulesExecutor.ErrorConditionsModal errorConditionsObj1 =  new ProductRulesExecutor.ErrorConditionsModal();
        errorConditionsObj1.testedObject = 'Product Option';
        errorConditionsObj1.testedField = 'SBQQ__ProductName__c';
        errorConditionsObj1.testedValue = wasteStream;
        errorConditionsObj1.testedValueType = 'String';
        errCondModalList.add(errorConditionsObj1);

        Map<String,List<String>> resultErrorMap = ProductRulesExecutor.executeProductRule(productId,errCondModalList);
        System.debug('resultErrorMap>>'+resultErrorMap);
        return resultErrorMap;
    }
          /*
     * SDT-26217
     * Dev: Jatan
     * Description: getCompanyCategory for seachable dropdown
     * 
     */ 
    @AuraEnabled
    public static List<Map<String, String>> getCompanyCategory(string quoteId) {

        SBQQ__Quote__c parentQuote = [SELECT Id, SBQQ__Account__r.Parent.AccountNumber
                               FROM SBQQ__Quote__c
                               WHERE Id =: quoteId];
        
        
        map<String, String> companyCategoriesMap = AcornCompanyDetails.getAcornCCMap(parentQuote.SBQQ__Account__r.Parent.AccountNumber);
        
        List<Map<String, String>> companyList = new List<Map<String, String>>();
       

        list<sortingWrapper> sortedList = new list<sortingWrapper>();

        if(companyCategoriesMap != null && !companyCategoriesMap.isEmpty()) {
            for(string sobjName : companyCategoriesMap.keyset()) {
                Map<String, String> sObjMap = new Map<String, String>();
                    sObjMap.put('label', companyCategoriesMap.get(sobjName));
                    sObjMap.put('value', sobjName);
                    sortedList.add(new sortingWrapper(sObjMap));
                
            }
        }

        sortedList.sort();
        for(sortingWrapper sortObjMap : sortedList) {
            companyList.add(sortObjMap.sObjFldsMap);
        }
        return companyList;
    }
  /*
     * SDT-26217
     * Dev: Jatan
     * Description: sort Company Category
     * 
     */
    public class sortingWrapper implements Comparable {
        public Map<String, String> sObjFldsMap;

        public sortingWrapper(Map<String, String> sObjFldsMap) {
            this.sObjFldsMap = sObjFldsMap;
        }

        public Integer compareTo(Object compareTo) {
            return sObjFldsMap.get('label').compareTo(((sortingWrapper)compareTo).sObjFldsMap.get('label'));
        }
    }
    
    //Quote Approval Automation (all case types) requires a dynamic getter method to match up against
    //the custom metadata values.  This method will simply allow us to extend the classes below to use a faux
    //getter method to return values
    public abstract class CoreObject {
        public Object getField(String parameterName) {
            String jsonInstance = Json.serialize(this);
            Map<String, Object> untypedInstance;
            untypedInstance = (Map<String, Object>)JSON.deserializeUntyped(jsonInstance);
            return untypedInstance.get(parameterName);
        }
    }
	
    //sdt-31000
    public class nteWrapper{
        //@AuraEnabled public List<QuoteProcurementController.HeaderWrapper> configuredProducts {get; set;}
        @AuraEnabled public Boolean showMessage {get; set;}
        @AuraEnabled public String qlineDetails {get; set;}
		@AuraEnabled public String qlineId {get; set;}
        
    }
    //sdt-31000
    //Creating a wrapper class that will store data in a way that is consumable for 
    //end users.  Breaks into three categories - header records, detail records, and
    //MAS Details.  Includes conversions for Picklist values.
    public class ProductsWrapper{
        @AuraEnabled public List<QuoteProcurementController.HeaderWrapper> configuredProducts {get; set;}
        @AuraEnabled public Boolean disableMAS {get; set;}
        @AuraEnabled public Boolean disableCost {get; set;}
        @AuraEnabled public Boolean disablePrice {get; set;}
        @AuraEnabled public String singleQuoteId {get; set;}
    }
    //The header wrapper is effectively how we would describe a service to a customer
    //(e.g., your 30 yard trash open top)
    public class HeaderWrapper extends CoreObject{
        //TCS adding caseType for SDT-27578 
        @AuraEnabled public String caseType {get; set;}
        @AuraEnabled public String caseSubType {get; set;}
        @AuraEnabled public String caseReason {get; set;}
        @AuraEnabled public String caseOrigin {get; set;}
        @AuraEnabled public String projectCodeId {get; set;}
        @AuraEnabled public id parentId {get; set;}
	@AuraEnabled public id clientId {get;set;}
        @AuraEnabled public id locationId {get; set;}
	@AuraEnabled public id locationDivision {get; set;}
        @AuraEnabled public id locationGeography {get; set;}
        @AuraEnabled public id locationType {get; set;}
        @AuraEnabled public id locationBrand {get; set;}
        @AuraEnabled public String quoteLineName {get; set;}
        @AuraEnabled public Id productId {get; set;}
        @AuraEnabled public Boolean quantityEditable {get; set;}
        @AuraEnabled public Id favoriteId {get; set;}
        @AuraEnabled public Decimal quantity {get; set;}
	@AuraEnabled public Id assetId {get; set;}
        @AuraEnabled public String equipmentType {get; set;}
        @AuraEnabled public String equipmentTypeCode {get; set;}
        @AuraEnabled public String equipmentSize {get; set;}
        @AuraEnabled public String duration {get; set;}
        @AuraEnabled public String materialType {get; set;}
        @AuraEnabled public String materialTypeCode {get; set;}
        @AuraEnabled public String wasteDescription {get; set;}
        @AuraEnabled public Date startDate {get; set;}
	@AuraEnabled public Date originalSLAstartDate {get; set;}
        @AuraEnabled public Date endDate {get; set;}
        @AuraEnabled public String quoteIdNav {get; set;}
        @AuraEnabled public String quoteName {get; set;}
        @AuraEnabled public String quoteStatus {get; set;}
        @AuraEnabled public Id vendorId {get; set;}
        @AuraEnabled public String companyCategory {get; set;}
        @AuraEnabled public String companyCategoryName {get; set;}
        @AuraEnabled public String selectedMaterialGrade {get; set;}// SDT-37527

        @AuraEnabled public String vendorName {get; set;}
        @AuraEnabled public String vendorNumber {get; set;}
        @AuraEnabled public String vendorBU {get; set;}
        @AuraEnabled public String vendorFacilityCode {get; set;}//SDT-29645
        @AuraEnabled public String parentVendorId {get; set;}
        @AuraEnabled public String vendorManualDispatch {get; set;}
        @AuraEnabled public String vendorPrepayment {get; set;}
        @AuraEnabled public Boolean isCOD {get; set;}
        @AuraEnabled public Boolean lineError {get; set;}
        //SDT-41473
        @AuraEnabled public Boolean isHaulAway {get; set;}
        //Adding VCR and SCode for SDT-20795
        @AuraEnabled public String sCode {get; set;}
        //Readded for 20079 after overwrite for 20085///
        @AuraEnabled public String primaryContact {get; set;}
        @AuraEnabled public String contactID {get; set;}
        @AuraEnabled public String lineFrequency {get; set;}
        @AuraEnabled public String monthlyScheduleDetails{set;get;}	//SDT-41407
        @AuraEnabled public String quoteID {get; set;}//Occurrence_Type__c 
        @AuraEnabled public String occurrenceType {get; set;}
        @AuraEnabled public Decimal quoteLineNumber {get; set;}
        @AuraEnabled public map<String,String> companyCategories {get; set;}
        @AuraEnabled public Boolean quoteOnly {get; set;}
        @AuraEnabled public String slaOverrideReason {get; set;}
        @AuraEnabled public String slaOverrideComment {get; set;}
        @AuraEnabled public String productFamily {get; set;}
        @AuraEnabled public String bundleProcuredStatus {get; set;}
        @AuraEnabled public String procurementErrorMessage {get; set;}
        @AuraEnabled public QuoteProcurementController.MASWrapper MAS {get; set;}
        @AuraEnabled public List<QuoteProcurementController.DetailWrapper> details {get; set;}
        @AuraEnabled public List<QuoteProcurementController.WOWrapper> workOrders {get; set;}
        /*SDT-24736 Classification Changes
        Author : Yeshas Konduru*/
        @AuraEnabled public string caseRecordType {get; set;}
        @AuraEnabled public string deliveryOverrideReason {get; set;} //SDT-30864 : Asset Availabilty
        @AuraEnabled public string deliveryOverrideComment {get; set;} //SDT-30864 : Asset Availabilty
        @AuraEnabled public string serviceOverrideReason {get; set;} //SDT-29100 : Asset Availabilty
        @AuraEnabled public string serviceOverrideComment {get; set;} //SDT-29100 : Asset Availabilty
        @AuraEnabled public Boolean nteWarnning {get; set;} // changes for SDT-31000
        @AuraEnabled public string nteWarnningMessage {get; set;} // changes for SDT-31000
        //SDT33101
        @AuraEnabled public String quoteType {get; set;}
        @AuraEnabled public String customerApproval {get; set;}
        @AuraEnabled public String quoteOnlyCopyOf {get; set;}
    }
    //Details are further broken into cost and price categories, and describe 
    //the charges associated with a service
    public class DetailWrapper {
        @AuraEnabled public String qLErrorMessages { get; set; }//Chandu Kari--SDT-48563
        @AuraEnabled public Id componentId {get; set;}
        @AuraEnabled public String quoteLineName {get; set;}
        @AuraEnabled public Id productId {get; set;}
        @AuraEnabled public String componentType {get; set;}
        @AuraEnabled public Integer componentQuantity {get; set;}
        @AuraEnabled public Date componentStartDate {get; set;}
        @AuraEnabled public Date componentEndDate {get; set;}
        @AuraEnabled public String occurrenceType {get; set;}
        @AuraEnabled public String scheduleFrequency {get; set;}
        @AuraEnabled public String frequencyInterval {get; set;}
        @AuraEnabled public String serviceDays {get; set;}
        @AuraEnabled public String errorMessage {get; set;}
        @AuraEnabled public Decimal vendorCost {get; set;}
        @AuraEnabled public String costCurrencyCode {get; set;}
        @AuraEnabled public String costUOM {get; set;}
        @AuraEnabled public Decimal costMin {get; set;}
        @AuraEnabled public Decimal customerPrice {get; set;}
        @AuraEnabled public String priceCurrencyCode {get; set;}
        @AuraEnabled public String priceUOM {get; set;}
        @AuraEnabled public Decimal priceMin {get; set;}
        @AuraEnabled public String iconName {get; set;}
    }
    //Vendor cost and Customer Price are separate entities for permissions purposes
    public class VendorCost {
        //Future iterations can store stepped tonnage here
    }
    public class CustomerPrice {
        //Future iterations can store stepped tonnage here
    }
    
    //MAS details are broken out to ensure we can tackle just MAS Integration for now
    public class MASWrapper {
        @AuraEnabled public String MASLibrary {get; set;}
        @AuraEnabled public String MASCompany {get; set;}
        @AuraEnabled public Double MASAccount {get; set;}
        @AuraEnabled public Double MASUniqueId {get; set;}
        @AuraEnabled public Double MASServiceLine {get; set;}
        @AuraEnabled public String MASBox {get; set;}
        @AuraEnabled public String MASComment {get; set;}
        @AuraEnabled public Boolean MASBypassPrice {get; set;}
        @AuraEnabled public Boolean MASDoNotCreate {get; set;}
        //SDT-29392 start
        @AuraEnabled public Boolean DoNotCreateTaskGridTickets {get; set;}
        @AuraEnabled public Boolean IsDoNotCreateTaskGridTicketVisible {get; set;}
        //SDT-29392 end
        @AuraEnabled public String VCRCode {get; set;}
        //added new Property for SDT-25787
        @AuraEnabled public Integer MASCommentSize {get; set;}
    }
    //SDT-29392 start
    public class MASResponseWrapper
    {
        @AuraEnabled public Boolean IsSuccess {get; set;}  
        @AuraEnabled public String ErrorMessage {get; set;}  
    }
    //WorkOrder details for display purposes
    public class WOWrapper {
        @AuraEnabled public Date serviceDate {get; set;}
        @AuraEnabled public String serviceType {get; set;}
        @AuraEnabled public String instructions {get; set;}
    }
    //SDT-21060
    //FinancialDetail Wrapper to fetch data.
    public class FinancialDetailWrapper{
        @AuraEnabled public Boolean quoteOnly {get; set;}
        @AuraEnabled public String companyCategory {get; set;}
        @AuraEnabled public String clientGLNo {get; set;}
        @AuraEnabled public String customerCostCenter {get; set;}
    }
    //Wrapper class for orders
    //Correlates to Quote_Order__c object
    public class OrderWrapper {
        @AuraEnabled public String parentQuoteLine {get; set;} //Quote_Line__c
        @AuraEnabled public String serviceQuoteLine {get; set;} //Service_Quote_Line__c
        @AuraEnabled public Date serviceDate {get; set;} //Service_Date__c
        @AuraEnabled public String serviceType {get; set;} //Service_Type__c (Picklist)
        @AuraEnabled public Decimal quantity {get; set;} //Quantity__c

        @AuraEnabled public String onsiteContact {get; set;} //Onsite_Contact__c
        @AuraEnabled public String onsitePhone {get; set;} //Onsite_Contact_Phone__c
        @AuraEnabled public String instructions {get; set;} //Instructions__c
		@AuraEnabled public String acornInstructions {get; set;} //Acorn Instructions__c 

        @AuraEnabled public String productType {get; set;} //Product_Type__c
        @AuraEnabled public String PONumber {get; set;} //Cust_Ref_Number__c
        @AuraEnabled public String duration {get; set;} //Duration__c
        @AuraEnabled public String occurrenceType {get; set;} //Occurrence_Type__c
        @AuraEnabled public String serviceTimeSpan {get; set;} //Service_Time_Span__c
        //Changes for SDT-27107
        @AuraEnabled public String quoteId {get; set;} 
        @AuraEnabled public Date serviceEndDate {get; set;}

        //SDT-41473 - 41625 - 41966
        @AuraEnabled public String vendorServiceId {get; set;} //Vendor_Service_Id__c
    }
    public class PicklistSelect {
        @AuraEnabled public String value {get; set;}
        @AuraEnabled public String label {get; set;}
        @AuraEnabled public Boolean selected {get; set;}
    }

    /*
     * SDT-23055
     * Dev: Rishi
     * Description: Created this wrapper for catering PO and its Quantities. It will be used in updateKeysQuantity
     * 
     */
    public class KeyMapWrapper{
        @AuraEnabled public String value {get; set;}
        @AuraEnabled public String id {get; set;}
    }
    
    /*
     * SDT-28571
     * Dev: Aliasgher
     * Description: Create this wrapper for Quote Summary Confirmation, It will be used in CreateDelivery.
    */
    public class QuoteSummaryWrapper{
        @AuraEnabled public String result {get;set;}
        @AuraEnabled public Boolean isAssetChanged {get;set;}
    }
    
    /*
    * SDT-30108
    */
    @AuraEnabled
    public static string addAdditionalServicesComment(String quoteId){
        string result;
        try {
            AAV_AvailabilityUtility.availabilityComments(quoteId);
            result = 'SUCCESS';
        } catch (Exception e) {
            //Changes related to SDT-48086
            UTIL_LoggingService.logHandledExceptionWithClass(e, UserInfo.getOrganizationId(),
                                                            UTIL_ErrorConstants.CONFIRM_CONFIGURATION_ACTION,
                                                            System.LoggingLevel.Error,
                                                            UTIL_ErrorConstants.QUOTEPROCUREMNTCONTROLLER_CLASSNAME,
                                                            UTIL_ErrorConstants.ADDADDITIONALSERVICESCOMMENT_METHODNAME+ UTIL_ErrorConstants.BLANK_SPACE+ 
                                                            'AcornController.createAcornComment',null);
            throw new AuraHandledException(e.getMessage());
        }
        return result;
    }

    
    /*
     * SDT-29084
     * Description : Fetch stp by Pass reason picklist values
    */
    @AuraEnabled
    public static Map<String, String> getByPassSTPReasonList()
    {
        Map<String,String> prValue = new Map<String,String>();
        List<String> pckValuelist =  UTIL_Picklist.getPickListValuesIntoList('SBQQ__Quote__c','Special_Handling_Reason__c');
        for(String pckValue : pckValuelist){
            prValue.put(pckValue.split(',').get(1), pckValue.split(',').get(0));//TODO - check what it returns
        }
        return prValue;
    } 
    /*
     * SDT-29084
     * Description : save stp by Pass reasons fields
    */
    
    @AuraEnabled
    public static void saveByPassSTPRequest(Id quoteId, Boolean byPassSTPFlag, String byPassSTPReason, String byPassSTPOtherReason, Boolean quoteOnly){
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.Id = quoteId;
        quote.Special_Handling__c = byPassSTPFlag;
        quote.Special_Handling_Reason__c = byPassSTPReason;
        quote.Special_Handling_Reason_Details__c     = byPassSTPOtherReason;
        quote.Quote_Only__c = quoteOnly;
        try
        {
            update quote;
        }
        catch(Exception ex)
        {
            //Changes related to SDT-48086
            UTIL_LoggingService.logHandledExceptionWithClass(ex, UserInfo.getOrganizationId(),
                                                             UTIL_ErrorConstants.CONFIRM_CONFIGURATION_ACTION,
                                                             System.LoggingLevel.Error,
                                                             UTIL_ErrorConstants.QUOTEPROCUREMNTCONTROLLER_CLASSNAME,
                                                             UTIL_ErrorConstants.SAVEBYPASSREQUEST_METHODNAME,
                                                             null);
        }
    }

    @AuraEnabled
    public static Boolean getReqBusinessRulesCC(Id quoteId){
        Boolean isReqQuoteCC = false; 
        //system.debug('quoteId '+quoteId);
        for(SBQQ__Quote__c q : [SELECT Id, SBQQ__Account__c, SBQQ__Account__r.ParentId,Case_Type__c,Case_Sub_Type__c,
                            SBQQ__Opportunity2__r.Case__r.Business_RuleId__c,SBQQ__Opportunity2__r.Case__r.Required_Information__c 
                                FROM SBQQ__Quote__c WHERE Id=: quoteId LIMIT 1]){
        system.debug('q Parent Acc : ' + q.SBQQ__Account__r.ParentId);
        if (q!=null && String.isNotBlank(q.SBQQ__Opportunity2__r.Case__r.Business_RuleId__c) && String.isNotBlank(q.SBQQ__Opportunity2__r.Case__r.Required_Information__c) 
            &&  q.SBQQ__Opportunity2__r.Case__r.Required_Information__c.contains(Constant_Util.COMPANY_CATEGORY)) {
                    isReqQuoteCC = True;
                } 
        }
        system.debug(' :isReqQuoteCC : ' + isReqQuoteCC);
        return isReqQuoteCC;
    }
    
    public static void CreateDeliveryRemovalForCommercialProducts(String parentQuoteLineId, OrderWrapper orderWrapper)
    {
        // Created By: TCS, pkulkarn
        // CreatedDate: 30-Aug-23
        // Story: SDT-30092
        // Comment: To check and create Delivery, Removal Quote lines and Work Orders for Commercial (Product Family) products when there is a change in Quantity and/or Size
        // Input/Output: parentQuoteLineId/none
        //SDT -38285 Add in select query Month_Relative_Interval__c and Month_Relative__c
        
        List<SBQQ__QuoteLine__c> quoteLines = [ SELECT Id, SBQQ__RequiredBy__c, SBQQ__RequiredBy__r.SBQQ__RequiredBy__c, SBQQ__Quantity__c, SBQQ__ProductFamily__c, SBQQ__Product__c, SBQQ__Product__r.Name, SBQQ__Quote__c, Account__c,
                                                SBQQ__StartDate__c, AssetId__c, AssetId__r.Equipment_Size__c, AssetId__r.Quantity__c, Vendor__c, Vendor__r.Parent_Vendor_ID__c, SBQQ__ProductName__c, 
                                                SBQQ__EndDate__c, Exception_Effective_Date__c, Exceptions_Effective_Date__c, Exception_Type__c, Exception_Comments__c, Exception_Reason__c, Equipment_Size__c,  Occurrence_Type__c, 
                                                Schedule_Frequency__c, Frequency_Interval__c, Day_of_Month__c,  Month_Relative_Interval__c, Month_Relative__c, Service_Days__c, Duration__c, Location_Position_Name__c, Location_Position_Name__r.Container_Position__c,
                                                (Select Id, Service_Type__c, Quantity__c, Quote_Line__c, Service_Quote_Line__c from Quote_Orders__r)
                                                FROM SBQQ__QuoteLine__c
                                                WHERE Id = :parentQuoteLineId OR SBQQ__RequiredBy__c =:parentQuoteLineId OR SBQQ__RequiredBy__r.SBQQ__RequiredBy__c =:parentQuoteLineId];

        
        SBQQ__QuoteLine__c parentQuoteLine = null;
        String vendorId = '';
	Integer quoteLineQuantity, assetQuantity;
        Double quoteLineSize, assetSize;
        Boolean changeInSize = false, changeInQuantity = false;
        Integer differenceInQuantity = 0;
        Boolean quantityIncreased = false;
        Boolean quantityDecreased = false;
        List<SBQQ__ProductOption__c> productOptionsList = null;
        
        //Get parent quote line and other information
        for(SBQQ__QuoteLine__c quoteLine : quoteLines)
        {
            if(quoteLine.SBQQ__RequiredBy__c == null)
            {
                parentQuoteLine = quoteLine;
                vendorId = quoteLine.Vendor__r.Parent_Vendor_ID__c;
                quoteLineQuantity = Integer.valueOf(quoteLine.SBQQ__Quantity__c);
                quoteLineSize = Double.valueOf(quoteLine.Equipment_Size__c.substringAfter('-'));
                assetQuantity = Integer.valueOf(quoteLine.AssetId__r.Quantity__c);
                assetSize = Double.valueOf(quoteLine.AssetId__r.Equipment_Size__c.substringBefore(' '));
            }
        }

        if(quoteLines != null && quoteLines.size() > 0 && parentQuoteLine != null)
        {
            //Retrieve Product Options
            productOptionsList = retrieveProductOptionsList(parentQuoteLine.SBQQ__Product__c);
            
            //Determine type of change in Quantity and Size
            if(quoteLineQuantity != assetQuantity && quoteLineQuantity > 0 && assetQuantity > 0)
            {
                changeInQuantity = true;
                differenceInQuantity = Math.abs(quoteLineQuantity - assetQuantity);
                if(quoteLineQuantity < assetQuantity)
                {
                    quantityDecreased = true;
                }
                else if(quoteLineQuantity > assetQuantity)
                {
                    quantityIncreased = true;
                }
            }
            if(quoteLineSize != assetSize)
            {
                changeInSize = true;
            }
        }
		
        //Remove existing Delivery/Removal/Swapout work orders 
		if(parentQuoteLine != null && (changeInSize || changeInQuantity))
            removeExistingWorkOrders(parentQuoteLine);    
        
        //Handle Size change
        if(changeInSize == true && changeInQuantity == false)
        {
            HandleSizeChange(quoteLines, parentQuoteLine, productOptionsList, vendorId, orderWrapper);
        }
        
        //Handle change in Quantity
        if(changeInSize == false && changeInQuantity == true)
        {
            HandleQuantityChange(quoteLines, parentQuoteLine, productOptionsList, quantityIncreased, quantityDecreased, differenceInQuantity, vendorId, orderWrapper);
        }
        
        //Handle change in Quantity and Size
        if(changeInSize == true && changeInQuantity == true)
        {
            HandleSizeAndQuantityChange(quoteLines, parentQuoteLine, productOptionsList, quantityIncreased, quantityDecreased, differenceInQuantity, vendorId, orderWrapper);
        }
    }

    private static void HandleSizeChange(List<SBQQ__QuoteLine__c> quoteLines, SBQQ__QuoteLine__c parentQuoteLine, List<SBQQ__ProductOption__c> productOptionsList, String vendorId, OrderWrapper orderWrapper)
    {
        // Created By: TCS, pkulkarn
        // CreatedDate: 30-Aug-23
        // Story: SDT-30092
        // Comment: To handle Size change
        // Input/Output: List of asset/true or false

        SBQQ__QuoteLine__c deliveryQuoteLine, removalQuoteLine, finalDeliveryQuoteLine, finalRemovalQuoteLine, swapoutQuoteLine, finalSwapoutQuoteLine;
        List<Quote_Order__c> workOrderList = new List<Quote_Order__c>();
        List<SBQQ__QuoteLine__c> quoteLinesCreated = new List<SBQQ__QuoteLine__c>();
        
        
        if(vendorId == Constant_Util.WM_US_VENDOR || vendorId == Constant_Util.WM_CANADA_VENDOR || vendorId == Constant_Util.REPUBLIC_VENDOR)
        {
            //Create Delivery and Removal Quote Lines if not present
            deliveryQuoteLine = getDeliveryQuoteLine(quoteLines);
            removalQuoteLine = getRemovalQuoteLine(quoteLines);

            //Delivery does not exist, create one
            if(deliveryQuoteLine == null)
            {
                //Get Product Option for delivery
                SBQQ__ProductOption__c deliveryProductOption = null;
                for(SBQQ__ProductOption__c productOption : productOptionsList)
                {
                    if(productOption.SBQQ__OptionalSKU__r.Name == Constant_Util.ServiceType_Delivery)
                        deliveryProductOption = productOption;
                }
                //Create Delivery Quote Line
                if(deliveryProductOption != null)
                {
                    SBQQ__QuoteLine__c newDeliveryQuoteLine = createQuoteLine(parentQuoteLine, deliveryProductOption, Constant_Util.ServiceType_Delivery, orderWrapper);

                    if(newDeliveryQuoteLine != null)
                    {
                        if(vendorId == Constant_Util.REPUBLIC_VENDOR)
                        {
                            newDeliveryQuoteLine.SBQQ__Quantity__c = parentQuoteLine.AssetId__r.Quantity__c; 
                        }
                        INSERT newDeliveryQuoteLine;
                        finalDeliveryQuoteLine = newDeliveryQuoteLine;
                    }
                }
            }
            //Delivery exists, update the quantity based on Vendor
            else
            {
                deliveryQuoteLine.SBQQ__BundledQuantity__c = null;
                if(vendorId == Constant_Util.REPUBLIC_VENDOR)
                {
                    deliveryQuoteLine.SBQQ__Quantity__c = parentQuoteLine.AssetId__r.Quantity__c; 
                }
                else	//WM Vendor
                {
                    deliveryQuoteLine.SBQQ__Quantity__c = 1; 
                }
                deliveryQuoteLine.SBQQ__StartDate__c = orderWrapper.serviceDate;
                UPDATE deliveryQuoteLine;
                finalDeliveryQuoteLine = deliveryQuoteLine;
            }

            //Removal does not exist, create one
            if(removalQuoteLine == null)
            {
                //Get Product Option for delivery
                SBQQ__ProductOption__c removalProductOption = null;
                for(SBQQ__ProductOption__c productOption : productOptionsList)
                {
                    if(productOption.SBQQ__OptionalSKU__r.Name == Constant_Util.REMOVAL)
                        removalProductOption = productOption;
                }
                //Create Removal Quote Line
                if(removalProductOption != null)
                {
                    SBQQ__QuoteLine__c newRemovalQuoteLine = createQuoteLine(parentQuoteLine, removalProductOption, Constant_Util.REMOVAL, orderWrapper);
                    
                    if(newRemovalQuoteLine != null)
                    {
                        if(vendorId == Constant_Util.REPUBLIC_VENDOR)
                        {
                            newRemovalQuoteLine.SBQQ__Quantity__c = parentQuoteLine.AssetId__r.Quantity__c; 
                        }
                        newRemovalQuoteLine.Equipment_Size__c = retriveQuoteLineEquivalentEquipmentSizeFromAsset(parentQuoteLine);
                        INSERT newRemovalQuoteLine;
                        finalRemovalQuoteLine = newRemovalQuoteLine;
                    }
                }
            }
            //Removal exists, update the quantity based on Vendor
            else
            {
                removalQuoteLine.SBQQ__BundledQuantity__c = null;
                if(vendorId == Constant_Util.REPUBLIC_VENDOR)
                {
                    removalQuoteLine.SBQQ__Quantity__c = parentQuoteLine.AssetId__r.Quantity__c; 
                }
                else	//WM Vendor
                {
                    removalQuoteLine.SBQQ__Quantity__c = 1; 
                }
				removalQuoteLine.SBQQ__StartDate__c = orderWrapper.serviceDate;
                removalQuoteLine.Equipment_Size__c = retriveQuoteLineEquivalentEquipmentSizeFromAsset(parentQuoteLine);
                UPDATE removalQuoteLine;
                finalRemovalQuoteLine = removalQuoteLine;
            }

            //Create Work Orders
            if(finalDeliveryQuoteLine != null)
            {
                //When Vendor is WM
                if(vendorId == Constant_Util.WM_US_VENDOR || vendorId == Constant_Util.WM_CANADA_VENDOR)
                {
                    CreateWorkOrder(finalDeliveryQuoteLine, Integer.valueOf(parentQuoteLine.AssetId__r.Quantity__c), Constant_Util.ServiceType_Delivery, 1, workOrderList, orderWrapper);
                }
                if(vendorId == Constant_Util.REPUBLIC_VENDOR)
                {
                    CreateWorkOrder(finalDeliveryQuoteLine, 1, Constant_Util.ServiceType_Delivery, Integer.valueOf(finalDeliveryQuoteLine.SBQQ__Quantity__c), workOrderList, orderWrapper);
                }
            }

            if(finalRemovalQuoteLine != null)
            {
                //When Vendor is WM
                if(vendorId == Constant_Util.WM_US_VENDOR || vendorId == Constant_Util.WM_CANADA_VENDOR)
                {
                    CreateWorkOrder(finalRemovalQuoteLine, Integer.valueOf(parentQuoteLine.AssetId__r.Quantity__c), Constant_Util.REMOVAL, 1, workOrderList, orderWrapper);
                }
                if(vendorId == Constant_Util.REPUBLIC_VENDOR)
                {
                    CreateWorkOrder(finalRemovalQuoteLine, 1, Constant_Util.REMOVAL, Integer.valueOf(finalRemovalQuoteLine.SBQQ__Quantity__c), workOrderList, orderWrapper);
                }
            }
			
            if(workOrderList.size() > 0)
                INSERT workOrderList;
        }
        //Other vendor - create Swapout line
        else
        {
            swapoutQuoteLine = getSwapoutQuoteLine(quoteLines);
            if(swapoutQuoteLine == null)
            {
                //Create Swapout Quote Line for Other vendors
                //Get Product Option for Swapout
                SBQQ__ProductOption__c swapoutProductOption = null;
                for(SBQQ__ProductOption__c productOption : productOptionsList)
                {
                    if(productOption.SBQQ__OptionalSKU__r.Name == Constant_Util.SWAPOUT_PRODUCT)
                    swapoutProductOption = productOption;
                }
                
                //Create Removal Quote Line
                if(swapoutProductOption != null)
                {
                    SBQQ__QuoteLine__c newSwapoutQuoteLine = createQuoteLine(parentQuoteLine, swapoutProductOption, Constant_Util.SWAPOUT_PRODUCT, orderWrapper);
                
                    if(newSwapoutQuoteLine != null)
                    {
                        newSwapoutQuoteLine.SBQQ__Quantity__c = parentQuoteLine.AssetId__r.Quantity__c; 
                        newSwapoutQuoteLine.Equipment_Size__c = getPicklistAPIName(parentQuoteLine.AssetId__r.Equipment_Size__c);
                        INSERT newSwapoutQuoteLine;
                        finalSwapoutQuoteLine = newSwapoutQuoteLine;
                    }
                }
            }
            //Swapout exists, update the same Quote line
            else
            {
                swapOutQuoteLine.SBQQ__Quantity__c = parentQuoteLine.AssetId__r.Quantity__c; 
                swapOutQuoteLine.SBQQ__BundledQuantity__c = null;
                swapOutQuoteLine.Equipment_Size__c = getPicklistAPIName(parentQuoteLine.AssetId__r.Equipment_Size__c);
				swapOutQuoteLine.SBQQ__StartDate__c = orderWrapper.serviceDate;
                UPDATE swapOutQuoteLine;
                finalSwapoutQuoteLine = swapOutQuoteLine;
            }

            //Create Work order
            if(finalSwapoutQuoteLine != null)
            {
                CreateWorkOrder(finalSwapoutQuoteLine, 1, Constant_Util.WORK_ORDER_SVC_TYPE_CONTAINER_EXCHANGE, Integer.valueOf(parentQuoteLine.AssetId__r.Quantity__c), workOrderList, orderWrapper);
            }
            
            if(workOrderList.size() > 0)
            {
     			INSERT workOrderList;
            }   
        }
    }

    private static void HandleQuantityChange(List<SBQQ__QuoteLine__c> quoteLines, SBQQ__QuoteLine__c parentQuoteLine, List<SBQQ__ProductOption__c> productOptionsList, Boolean quantityIncreased, Boolean quantityDecreased, Integer differenceInQuantity, String vendorId, OrderWrapper orderWrapper)
    {
        // Created By: TCS, pkulkarn
        // CreatedDate: 30-Aug-23
        // Story: SDT-30092
        // Comment: To handle change in quantity logic
        
        SBQQ__QuoteLine__c deliveryQuoteLine, removalQuoteLine, finalDeliveryQuoteLine, finalRemovalQuoteLine;
        List<Quote_Order__c> workOrderList = new List<Quote_Order__c>();
        List<SBQQ__QuoteLine__c> quoteLinesCreated = new List<SBQQ__QuoteLine__c>();
    
        //Get Delivery/Removal quote lines if created already
        deliveryQuoteLine = getDeliveryQuoteLine(quoteLines);
        removalQuoteLine = getRemovalQuoteLine(quoteLines);
    
        if(quantityIncreased)
        {
            //Delivery does not exist, create one
            if(deliveryQuoteLine == null)
            {
                //Get Product Option for delivery
                SBQQ__ProductOption__c deliveryProductOption = null;
                for(SBQQ__ProductOption__c productOption : productOptionsList)
                {
                    if(productOption.SBQQ__OptionalSKU__r.Name == Constant_Util.ServiceType_Delivery)
                        deliveryProductOption = productOption;
                }
                //Create Delivery Quote Line
                if(deliveryProductOption != null)
                {
                    SBQQ__QuoteLine__c newDeliveryQuoteLine = createQuoteLine(parentQuoteLine, deliveryProductOption, Constant_Util.ServiceType_Delivery, orderWrapper);
    
                    if(newDeliveryQuoteLine != null)
                    {
                        //Republic or other vendor
                        if(vendorId == Constant_Util.REPUBLIC_VENDOR || (vendorId != Constant_Util.WM_US_VENDOR && vendorId != Constant_Util.WM_CANADA_VENDOR))
                        {
                            newDeliveryQuoteLine.SBQQ__Quantity__c = differenceInQuantity; 
                        }
                        INSERT newDeliveryQuoteLine;
                        finalDeliveryQuoteLine = newDeliveryQuoteLine;
                    }
                }
            }
            //Delivery exists, update the quantity based on Vendor
            else
            {
                deliveryQuoteLine.SBQQ__BundledQuantity__c = null;
                //Republic or other vendor
                if(vendorId == Constant_Util.REPUBLIC_VENDOR || (vendorId != Constant_Util.WM_US_VENDOR && vendorId != Constant_Util.WM_CANADA_VENDOR))
                {
                    deliveryQuoteLine.SBQQ__Quantity__c = differenceInQuantity; 
                }
                //WM Vendor
                else if(vendorId == Constant_Util.WM_US_VENDOR || vendorId == Constant_Util.WM_CANADA_VENDOR)	
                {
                    deliveryQuoteLine.SBQQ__Quantity__c = 1;
                }
				deliveryQuoteLine.SBQQ__StartDate__c = orderWrapper.serviceDate;
                UPDATE deliveryQuoteLine;
                finalDeliveryQuoteLine = deliveryQuoteLine;
            }
    
            //Create Work Orders
            //WM Vendors
            if(vendorId == Constant_Util.WM_US_VENDOR || vendorId == Constant_Util.WM_CANADA_VENDOR)
            {
                if(finalDeliveryQuoteLine != null)
                {
                    CreateWorkOrder(finalDeliveryQuoteLine, differenceInQuantity, Constant_Util.ServiceType_Delivery, 1, workOrderList, orderWrapper);
                }
            }
            //Republic or other vendors
            else if(vendorId == Constant_Util.REPUBLIC_VENDOR || (vendorId != Constant_Util.WM_US_VENDOR && vendorId != Constant_Util.WM_CANADA_VENDOR))
            {
                if(finalDeliveryQuoteLine != null)
                {
                    CreateWorkOrder(finalDeliveryQuoteLine, 1, Constant_Util.ServiceType_Delivery, differenceInQuantity, workOrderList, orderWrapper);
                }
            }
            
            //Insert work orders
            if(workOrderList.size() > 0)
            {
                INSERT workOrderList;
            }
        }
    
        if(quantityDecreased)
        {
            //Removal does not exist, create one
            if(removalQuoteLine == null)
            {
                //Get Product Option for delivery
                SBQQ__ProductOption__c removalProductOption = null;
                for(SBQQ__ProductOption__c productOption : productOptionsList)
                {
                    if(productOption.SBQQ__OptionalSKU__r.Name == Constant_Util.REMOVAL)
                        removalProductOption = productOption;
                }
                //Create Removal Quote Line
                if(removalProductOption != null)
                {
                    SBQQ__QuoteLine__c newRemovalQuoteLine = createQuoteLine(parentQuoteLine, removalProductOption, Constant_Util.REMOVAL, orderWrapper);
                    
                    if(newRemovalQuoteLine != null)
                    {
                        //Republic or other vendor
                        if(vendorId == Constant_Util.REPUBLIC_VENDOR || (vendorId != Constant_Util.WM_US_VENDOR && vendorId != Constant_Util.WM_CANADA_VENDOR))
                        {
                            newRemovalQuoteLine.SBQQ__Quantity__c = differenceInQuantity; 
                        }
                        INSERT newRemovalQuoteLine;
                        finalRemovalQuoteLine = newRemovalQuoteLine;
                    }
                }
            }
            //Removal exists, update the quantity based on Vendor
            else
            {
                removalQuoteLine.SBQQ__BundledQuantity__c = null;
                if(vendorId == Constant_Util.REPUBLIC_VENDOR || (vendorId != Constant_Util.WM_US_VENDOR && vendorId != Constant_Util.WM_CANADA_VENDOR))
                {
                    removalQuoteLine.SBQQ__Quantity__c = differenceInQuantity; 
                }
                //WM Vendor
                else if(vendorId == Constant_Util.WM_US_VENDOR || vendorId == Constant_Util.WM_CANADA_VENDOR)	
                {
                    removalQuoteLine.SBQQ__Quantity__c = 1; 
                }
				removalQuoteLine.SBQQ__StartDate__c = orderWrapper.serviceDate;
                UPDATE removalQuoteLine;
                finalRemovalQuoteLine = removalQuoteLine;
            }
    
            //Create Work orders
            //WM Vendors
            if(vendorId == Constant_Util.WM_US_VENDOR || vendorId == Constant_Util.WM_CANADA_VENDOR)
            {
                if(finalRemovalQuoteLine != null)
                {
                    CreateWorkOrder(finalRemovalQuoteLine, differenceInQuantity, Constant_Util.REMOVAL, 1, workOrderList, orderWrapper);
                }
            }
            //Republic or other vendors
            else if(vendorId == Constant_Util.REPUBLIC_VENDOR || (vendorId != Constant_Util.WM_US_VENDOR && vendorId != Constant_Util.WM_CANADA_VENDOR))
            {
                if(finalRemovalQuoteLine != null)
                {
                    CreateWorkOrder(finalRemovalQuoteLine, 1, Constant_Util.REMOVAL, differenceInQuantity, workOrderList, orderWrapper);
                }
            }
            
            //Insert work orders
            if(workOrderList.size() > 0)
            {
                INSERT workOrderList;
            }
        }
    }

    private static void HandleSizeAndQuantityChange(List<SBQQ__QuoteLine__c> quoteLines, SBQQ__QuoteLine__c parentQuoteLine, List<SBQQ__ProductOption__c> productOptionsList, Boolean quantityIncreased, Boolean quantityDecreased, Integer differenceInQuantity, String vendorId, OrderWrapper orderWrapper)
    {
        // Created By: TCS, pkulkarn
        // CreatedDate: 30-Aug-23
        // Story: SDT-30092
        // Comment: To handle change in quantity logic
        
        SBQQ__QuoteLine__c deliveryQuoteLine, removalQuoteLine, finalDeliveryQuoteLine, finalRemovalQuoteLine, swapoutQuoteLine, finalSwapoutQuoteLine;
        List<Quote_Order__c> workOrderList = new List<Quote_Order__c>();
        List<SBQQ__QuoteLine__c> quoteLinesCreated = new List<SBQQ__QuoteLine__c>();
    
        //Get Delivery/Removal quote lines if created already
        deliveryQuoteLine = getDeliveryQuoteLine(quoteLines);
        removalQuoteLine = getRemovalQuoteLine(quoteLines);
    	swapoutQuoteLine = getSwapoutQuoteLine(quoteLines);
        
        //For other vendors create Swapout line
        if(vendorId != Constant_Util.WM_US_VENDOR && vendorId != Constant_Util.WM_CANADA_VENDOR && vendorId != Constant_Util.REPUBLIC_VENDOR)
        {
            if(swapoutQuoteLine == null)
            {
                //Get Product Option for Swapout
                //SBQQ__QuoteLine__c swapOutQuoteLine;
                SBQQ__ProductOption__c swapoutProductOption = null;
                for(SBQQ__ProductOption__c productOption : productOptionsList)
                {
                    if(productOption.SBQQ__OptionalSKU__r.Name == Constant_Util.SWAPOUT_PRODUCT)
                    swapoutProductOption = productOption;
                }
                
                //Create Swapout Quote Line
                if(swapoutProductOption != null)
                {
                    SBQQ__QuoteLine__c newSwapoutQuoteLine = createQuoteLine(parentQuoteLine, swapoutProductOption, Constant_Util.SWAPOUT_PRODUCT, orderWrapper);
                
                    if(newSwapoutQuoteLine != null)
                    {
                        newSwapoutQuoteLine.SBQQ__Quantity__c = parentQuoteLine.AssetId__r.Quantity__c; 
                        newSwapoutQuoteLine.Equipment_Size__c = getPicklistAPIName(parentQuoteLine.AssetId__r.Equipment_Size__c);
                        INSERT newSwapoutQuoteLine;
                        finalSwapoutQuoteLine = newSwapoutQuoteLine;
                    }
                }
            }
            //Swapout exists, update the same Quote line
            else
            {
                swapOutQuoteLine.SBQQ__Quantity__c = parentQuoteLine.AssetId__r.Quantity__c; 
                swapOutQuoteLine.SBQQ__BundledQuantity__c = null;
                swapOutQuoteLine.Equipment_Size__c = getPicklistAPIName(parentQuoteLine.AssetId__r.Equipment_Size__c);
				swapOutQuoteLine.SBQQ__StartDate__c = orderWrapper.serviceDate;
                UPDATE swapOutQuoteLine;
                finalSwapoutQuoteLine = swapOutQuoteLine;
            }
    
            if(finalSwapoutQuoteLine != null)
            {
                CreateWorkOrder(finalSwapoutQuoteLine, 1, Constant_Util.WORK_ORDER_SVC_TYPE_CONTAINER_EXCHANGE, Integer.valueOf(finalSwapoutQuoteLine.SBQQ__Quantity__c), workOrderList, orderWrapper);
            }
            
            if(workOrderList.size() > 0)
            {
                INSERT workOrderList;
            }
        }
    
        //For WM and Republic vendors, create Delivery, Removal quote lines and work orders
        else
        {
            //Delivery does not exist, create one
            if(deliveryQuoteLine == null)
            {
                //Get Product Option for delivery
                SBQQ__ProductOption__c deliveryProductOption = null;
                for(SBQQ__ProductOption__c productOption : productOptionsList)
                {
                    if(productOption.SBQQ__OptionalSKU__r.Name == Constant_Util.ServiceType_Delivery)
                        deliveryProductOption = productOption;
                }
                //Create Delivery Quote Line
                if(deliveryProductOption != null)
                {
                    SBQQ__QuoteLine__c newDeliveryQuoteLine = createQuoteLine(parentQuoteLine, deliveryProductOption, Constant_Util.ServiceType_Delivery, orderWrapper);
    
                    if(newDeliveryQuoteLine != null)
                    {
                        //Republic vendor
                        if(vendorId == Constant_Util.REPUBLIC_VENDOR)
                        {
                            if(quantityIncreased)
                            {   
                                newDeliveryQuoteLine.SBQQ__Quantity__c = Integer.valueOf(differenceInQuantity + parentQuoteLine.AssetId__r.Quantity__c); 
                            }
                            else if(quantityDecreased)
                            {
                                newDeliveryQuoteLine.SBQQ__Quantity__c = Integer.valueOf(parentQuoteLine.AssetId__r.Quantity__c - differenceInQuantity); 
                            }
                        }
                        INSERT newDeliveryQuoteLine;
                        finalDeliveryQuoteLine = newDeliveryQuoteLine;
                    }
                }
            }
            //Delivery exists, update the quantity based on Vendor
            else
            {
                deliveryQuoteLine.SBQQ__BundledQuantity__c = null;
                
                //Republic vendor
                if(vendorId == Constant_Util.REPUBLIC_VENDOR)
                {
                    if(quantityIncreased)
                    {
                        deliveryQuoteLine.SBQQ__Quantity__c = Integer.valueOf(differenceInQuantity + parentQuoteLine.AssetId__r.Quantity__c); 
                    }
                    else if(quantityDecreased)
                    {
                        deliveryQuoteLine.SBQQ__Quantity__c = Integer.valueOf(parentQuoteLine.AssetId__r.Quantity__c - differenceInQuantity); 
                    }
                }
                //WM Vendor
                if(vendorId == Constant_Util.WM_US_VENDOR || vendorId == Constant_Util.WM_CANADA_VENDOR)
                {
	                deliveryQuoteLine.SBQQ__Quantity__c = 1; 
                }
				deliveryQuoteLine.SBQQ__StartDate__c = orderWrapper.serviceDate;
                UPDATE deliveryQuoteLine;
                finalDeliveryQuoteLine = deliveryQuoteLine;
            }
    
            //Create Delivery Work Orders
            if(finalDeliveryQuoteLine != null)
            {
                if(quantityIncreased)
                {
                    //WM Vendors
                    if(vendorId == Constant_Util.WM_US_VENDOR || vendorId == Constant_Util.WM_CANADA_VENDOR)
                    {
                        CreateWorkOrder(finalDeliveryQuoteLine, Integer.valueOf(differenceInQuantity + parentQuoteLine.AssetId__r.Quantity__c), Constant_Util.ServiceType_Delivery, 1, workOrderList, orderWrapper);
                    }
                    //Republic vendor
                    else if(vendorId == Constant_Util.REPUBLIC_VENDOR)
                    {
                        CreateWorkOrder(finalDeliveryQuoteLine, 1, Constant_Util.ServiceType_Delivery, Integer.valueOf(differenceInQuantity + parentQuoteLine.AssetId__r.Quantity__c), workOrderList, orderWrapper);
                    }
                }
                else if(quantityDecreased)
                {
                    //WM Vendors
                    if(vendorId == Constant_Util.WM_US_VENDOR || vendorId == Constant_Util.WM_CANADA_VENDOR)
                    {
                        CreateWorkOrder(finalDeliveryQuoteLine, Integer.valueOf(parentQuoteLine.AssetId__r.Quantity__c - differenceInQuantity), Constant_Util.ServiceType_Delivery, 1, workOrderList, orderWrapper);
                    }
                    //Republic vendor
                    else if(vendorId == Constant_Util.REPUBLIC_VENDOR)
                    {
                        CreateWorkOrder(finalDeliveryQuoteLine, 1, Constant_Util.ServiceType_Delivery, Integer.valueOf(parentQuoteLine.AssetId__r.Quantity__c - differenceInQuantity), workOrderList, orderWrapper);
                    }
                }
            }
            system.debug('DeliveryWorkOrderSize' + workOrderList.size());
            //Insert work orders
            if(workOrderList.size() > 0)
            {
                INSERT workOrderList;
            }
    
            //Removal does not exist, create one
            if(removalQuoteLine == null)
            {
                //Get Product Option for delivery
                SBQQ__ProductOption__c removalProductOption = null;
                for(SBQQ__ProductOption__c productOption : productOptionsList)
                {
                    if(productOption.SBQQ__OptionalSKU__r.Name == Constant_Util.REMOVAL)
                        removalProductOption = productOption;
                }
                //Create Removal Quote Line
                if(removalProductOption != null)
                {
                    SBQQ__QuoteLine__c newRemovalQuoteLine = createQuoteLine(parentQuoteLine, removalProductOption, Constant_Util.REMOVAL, orderWrapper);
                    
                    if(newRemovalQuoteLine != null)
                    {
                        if(vendorId == Constant_Util.REPUBLIC_VENDOR)
                        {
                            newRemovalQuoteLine.SBQQ__Quantity__c = Integer.valueOf(parentQuoteLine.AssetId__r.Quantity__c); 
                        }
                        newRemovalQuoteLine.Equipment_Size__c = retriveQuoteLineEquivalentEquipmentSizeFromAsset(parentQuoteLine);
                        INSERT newRemovalQuoteLine;
                        finalRemovalQuoteLine = newRemovalQuoteLine;
                    }
                }
            }
            //Removal exists, update the quantity based on Vendor
            else
            {
                removalQuoteLine.SBQQ__BundledQuantity__c = null;
                if(vendorId == Constant_Util.REPUBLIC_VENDOR)
                {
                	removalQuoteLine.SBQQ__Quantity__c = Integer.valueOf(parentQuoteLine.AssetId__r.Quantity__c); 
                }
                //WM Vendor
                if(vendorId == Constant_Util.WM_US_VENDOR || vendorId == Constant_Util.WM_CANADA_VENDOR)
                {
	                removalQuoteLine.SBQQ__Quantity__c = 1; 
                }
				removalQuoteLine.SBQQ__StartDate__c = orderWrapper.serviceDate;
                removalQuoteLine.Equipment_Size__c = retriveQuoteLineEquivalentEquipmentSizeFromAsset(parentQuoteLine);
                UPDATE removalQuoteLine;
                finalRemovalQuoteLine = removalQuoteLine;
            }
    
            //Create Removal Work orders
            if(finalRemovalQuoteLine != null)
            {
                workOrderList = new List<Quote_Order__c>();
                //WM Vendors
                if(vendorId == Constant_Util.WM_US_VENDOR || vendorId == Constant_Util.WM_CANADA_VENDOR)
                {
                    CreateWorkOrder(finalRemovalQuoteLine, Integer.valueOf(parentQuoteLine.AssetId__r.Quantity__c), Constant_Util.REMOVAL, 1, workOrderList, orderWrapper);
                }
    
                //Republic vendor
                else if(vendorId == Constant_Util.REPUBLIC_VENDOR)
                {
                    CreateWorkOrder(finalRemovalQuoteLine, 1, Constant_Util.REMOVAL, Integer.valueOf(parentQuoteLine.AssetId__r.Quantity__c), workOrderList, orderWrapper);
                }
            }

            //Insert removal work orders
            if(workOrderList.size() > 0)
            {
                INSERT workOrderList;
            }
        }
    }
    
    private static void CreateWorkOrder(SBQQ__QuoteLine__c quoteLine, Integer noOfWorkOrders, String serviceType, Integer quantity, List<Quote_Order__c> workOrderList, OrderWrapper orderWrapper)
    {
        // Created By: TCS, pkulkarn
        // CreatedDate: 30-Aug-23
        // Story: SDT-30092
        // Comment: To create quote line
        // Input/Output: Parent QL, # of Work Orders to be created, Service Type, Work Order Quantity, OrderWrapper/Work Order list
        for(Integer index = 0; index < noOfWorkOrders; index++)
        {
            Quote_Order__c workOrder = new Quote_Order__c();
            if (quoteLine.Location_Position_Name__c != null) 
            {
                //positionName = quoteLine.Location_Position_Name__r.Container_Position__c;
                workOrder.Instructions__c ='POSITION:' + quoteLine.Location_Position_Name__r.Container_Position__c + '\n'  + orderWrapper.instructions;
                workOrder.Acorn_Instructions__c ='POSITION:' + quoteLine.Location_Position_Name__r.Container_Position__c + '\n'  + orderWrapper.acornInstructions;
            } 
            else 
            {
                workOrder.Instructions__c = orderWrapper.instructions;
                workOrder.Acorn_Instructions__c = orderWrapper.acornInstructions;
            }
            workOrder.Quote_Line__c = quoteLine.SBQQ__RequiredBy__c;
            workOrder.Service_Quote_Line__c = quoteLine.Id;
            workOrder.Service_Type__c = serviceType;
            workOrder.Quantity__c = quantity;
            workOrder.Onsite_Contact__c = orderWrapper.onsiteContact;
            workOrder.Onsite_Contact_Phone__c = orderWrapper.onsitePhone;
            if(serviceType == Constant_Util.WORK_ORDER_SVC_TYPE_CONTAINER_EXCHANGE)
                workOrder.Product_Type__c = Constant_Util.SWAPOUT_PRODUCT;
            else
                workOrder.Product_Type__c = serviceType;
            workOrder.Cust_Ref_Number__c = orderWrapper.PONumber;
            workOrder.Duration__c = orderWrapper.Duration;
            workOrder.Occurrence_Type__c = quoteLine.Occurrence_Type__c;
            workOrder.Service_Time_Span__c = 'ASAP';
            workOrder.Placement_Instructions__c= orderWrapper.instructions;
            //SDT-41473 - 41625 - 41966
            workOrder.Vendor_Service_Id__c = orderWrapper.vendorServiceId;
            workOrder.Service_Date__c = orderWrapper.serviceDate;
            workOrderList.add(workOrder);
        }
    }
    
    private static SBQQ__QuoteLine__c createQuoteLine(SBQQ__QuoteLine__c parentQuoteLine, SBQQ__ProductOption__c productOption, String lineType, OrderWrapper orderWrapper)
    {
        // Created By: TCS, pkulkarn
        // CreatedDate: 30-Aug-23
        // Story: SDT-30092
        // Comment: To create quote line
        // Input/Output: Parent QL, Product Option, Type of Product, Orderwrapper/Quote line

        SBQQ__QuoteLine__c quoteLine;
        //Create Quote Line
        if(productOption != null)
        {
            quoteLine = new SBQQ__QuoteLine__c();
            quoteLine = assignParentQLineFields(parentQuoteLine);
            quoteLine.SBQQ__StartDate__c = orderWrapper.serviceDate;
            quoteLine.SBQQ__EndDate__c = null;		//TCS-pkulkarn-SDT-41184-Added to avoid setting parent bundle End Date
            quoteLine.SBQQ__Quantity__c = 1;
            quoteLine.SBQQ__Number__c = getMaxQuoteLineNumber(parentQuoteLine.SBQQ__Quote__c);
            quoteLine.SBQQ__Product__c = productOption.SBQQ__OptionalSKU__c;
            quoteLine.SBQQ__ProductOption__c = productOption.Id;
            quoteLine.Occurrence_Type__c = productOption.Occurrence_Type__c;
            quoteLine.PriceUOM__c = productOption.PriceUOM__c;
            quoteLine.Cost_Unit_of_Measure__c = productOption.Cost_Unit_of_Measure__c;
            quoteLine.CostModelType__c = productOption.CostModelType__c;
            quoteLine.SBQQ__OptionLevel__c = 1;
            quoteLine.SBQQ__CostEditable__c = true;
            quoteLine.SBQQ__PriceEditable__c = true;
            
            quoteLine = clearScheduleValues(quoteLine);
        }
        return quoteLine;
    }

    private static SBQQ__QuoteLine__c getDeliveryQuoteLine(List<SBQQ__QuoteLine__c> quoteLines)
    {
        // Created By: TCS, pkulkarn
        // CreatedDate: 30-Aug-23
        // Story: SDT-30092
        // Comment: To check if Delivery quote line exists
        // Input/Output: List of asset/true or false

        
        SBQQ__QuoteLine__c deliveryLine;

        for(SBQQ__QuoteLine__c quoteLine : quoteLines)
        {
            if(quoteLine.SBQQ__Product__r.Name == Constant_Util.ServiceType_Delivery)
            {
                deliveryLine = quoteLine;
                break;
            }
        }
        return deliveryLine;
    }

    private static SBQQ__QuoteLine__c getRemovalQuoteLine(List<SBQQ__QuoteLine__c> quoteLines)
    {
        // Created By: TCS, pkulkarn
        // CreatedDate: 30-Aug-23
        // Story: SDT-30092
        // Comment: To check if Removal quote line exists
        // Input/Output: List of asset/true or false

        Boolean result = false;
        SBQQ__QuoteLine__c removalLine;
        for(SBQQ__QuoteLine__c quoteLine : quoteLines)
        {
            if(quoteLine.SBQQ__Product__r.Name == Constant_Util.REMOVAL)
            {
                removalLine = quoteLine;
                break;
            }
        }
        return removalLine;
    }
    
    private static SBQQ__QuoteLine__c getSwapoutQuoteLine(List<SBQQ__QuoteLine__c> quoteLines)
    {
        // Created By: TCS, pkulkarn
        // CreatedDate: 8-Sep-23
        // Story: SDT-30092
        // Comment: To check if Removal quote line exists
        // Input/Output: List of quote lines/Swapout quote line

        Boolean result = false;
        SBQQ__QuoteLine__c swapOutLine;
        for(SBQQ__QuoteLine__c quoteLine : quoteLines)
        {
            if(quoteLine.SBQQ__Product__r.Name == Constant_Util.SWAPOUT_PRODUCT)
            {
                swapOutLine = quoteLine;
                break;
            }
        }
        return swapOutLine;
    }

    private static List<SBQQ__ProductOption__c> retrieveProductOptionsList(Id productId)
    {
        return [SELECT Id, Occurrence_Type__c, PriceUOM__c, Cost_Unit_of_Measure__c, CostModelType__c, SBQQ__ConfiguredSKU__c, SBQQ__ConfiguredSKU__r.Name, SBQQ__OptionalSKU__c, SBQQ__OptionalSKU__r.Name FROM SBQQ__ProductOption__c WHERE SBQQ__ConfiguredSKU__c =: productId ];
    }
    
    private static void removeExistingWorkOrders(SBQQ__QuoteLine__c quoteLine)
    {
        // Created By: TCS, pkulkarn
        // CreatedDate: 7-Sep-23
        // Story: SDT-30092
        // Comment: To remove existing work orders on Bundle. This is required when user moves back and forth on the Intake screen
        // Input/Output: Bundle Quote Line/void
        
        List<Quote_Order__c> workOrderList = quoteLine.Quote_Orders__r;
        List<Quote_Order__c> workOrderListToBeDeleted = new List<Quote_Order__c>();
        
        for(Quote_Order__c workOrder : workOrderList)
        {
            if(workOrder.Service_Type__c == Constant_Util.ServiceType_Delivery || workOrder.Service_Type__c == Constant_Util.REMOVAL || workOrder.Service_Type__c == Constant_Util.WORK_ORDER_SVC_TYPE_CONTAINER_EXCHANGE)
                workOrderListToBeDeleted.add(workOrder);
        }
        if(workOrderListToBeDeleted != null && workOrderListToBeDeleted.size() > 0)
            DELETE workOrderListToBeDeleted;
    }
    
    private static String retriveQuoteLineEquivalentEquipmentSizeFromAsset(SBQQ__QuoteLine__c parentQuoteLine)
    {
		// Created By: TCS, pkulkarn
        // CreatedDate: 3-Sep-2023
        // Story: SDT-30092, Defect SDT-32775
        // Comment: To update retrieve Equipment Size field value on Quote Line for the equivalent field on Asset
        // Input/Output: Quote Line/Equipment Size value
        
        return getPicklistAPIName(parentQuoteLine.AssetId__r.Equipment_Size__c);
    }
    
    
    
    /*
     * @Name          updateSpecialHandling
     * @Vendor        TCS
     * @Author        WM - Jatan Sharma / Digdershika Ojha
     * @Date          04/10/2023
     * @param         updatedQuoteLine : SBQQ__QuoteLine__c
     * @param         locationPositionName : String
     * @return        void
     * @story         SDT-30089
     * @Description   It updates quote if special handling auto enable criteria match.
     */

    public static void updateSpecialHandling(Id quoteId){

        List<SBQQ__QuoteLine__c> quoteLine = [select id ,Quote_SLA_Date__c,Certificate_of_Destruction__c,Certificate_of_Disposal__c,
        Gate_Code__c,Service_Start_Time__c,Service_End_Time__c,Restriction_Details__c,SBQQ__Quote__r.Special_Handling__c, SBQQ__Quote__r.Special_Handling_Reason__c, SBQQ__Quote__r.Special_Handling_Reason_Details__c 
        from SBQQ__QuoteLine__c where SBQQ__Quote__c =:quoteId and SBQQ__RequiredBy__c = null ];
        SBQQ__Quote__c quoteObj = new SBQQ__Quote__c();

        if(quoteLine !=null)
        {
            for(SBQQ__QuoteLine__c updatedQuoteLine :quoteLine)
            {
                if(updatedQuoteLine.Quote_SLA_Date__c < system.today())
                {
                    quoteObj.Special_Handling__c = true;
                    //quoteObj.Special_Handling_Reason__c = specialHandling_BackDated_Reason;
                    //SDT-31144
                    //SDT-47978 - Modified by Yugandhar Adem : START
                    quoteObj.Special_Handling_Reason__c = specialHandling_Delivery_Not_Needed;
                    //SDT-47978 - Modified by Yugandhar Adem : START
                    quoteObj.Special_Handling_Reason_Details__c = '';
                    break;
                }
                else if(updatedQuoteLine.Quote_SLA_Date__c >= system.today() &&
                    (updatedQuoteLine.Certificate_of_Destruction__c || updatedQuoteLine.Certificate_of_Disposal__c 
                    || !String.isBlank(updatedQuoteLine.Gate_Code__c) || updatedQuoteLine.Service_Start_Time__c != null 
                    || updatedQuoteLine.Service_End_Time__c != null 
                    || !String.isBlank(updatedQuoteLine.Restriction_Details__c)))
                {
                    quoteObj.Special_Handling__c = true;
                    quoteObj.Special_Handling_Reason__c = specialHandling_Automatic_Reason;
                    //SDT-31144
                    quoteObj.Special_Handling_Reason_Details__c = '';
                    break;
                }
                else{
                    //if(updatedQuoteLine.SBQQ__Quote__r.Special_Handling_Reason__c == specialHandling_BackDated_Reason || updatedQuoteLine.SBQQ__Quote__r.Special_Handling_Reason__c == specialHandling_Automatic_Reason)
                     //SDT-47978 - Modified by Yugandhar Adem : START
                    if(updatedQuoteLine.SBQQ__Quote__r.Special_Handling_Reason__c == specialHandling_Delivery_Not_Needed || updatedQuoteLine.SBQQ__Quote__r.Special_Handling_Reason__c == specialHandling_Automatic_Reason)
                    {
                        quoteObj.Special_Handling__c = false;
                        quoteObj.Special_Handling_Reason__c = null;
                         //SDT-31144
                        quoteObj.Special_Handling_Reason_Details__c = '';
                    }
                }
            }
        }
        
        if(quoteObj!=null){
            quoteObj.Id = quoteId;
            update quoteObj;
        }
    }
    
    public static List<SBQQ__QuoteLine__c> getExtraPickupLineForStartDateUpdate(Map<Id, SBQQ__QuoteLine__c> bundlewisePickupQuoteLinesMap, Map<Id, SBQQ__QuoteLine__c> bundlewiseExtraPickupQuoteLinesMap, Boolean updateFromIntakeScreen)
    {
        // Author : TCS, SDT-32782
        // Date: 13-Oct-2023
        // Usage : To retrieve a list of Extra Pickup quote lines to update when Pickup quote line is updated
        // Input : Map of Pickup and Extra Pickup quote lines
        // Output : List of Extra Pickup quote lines to be updated
        // To retrieve the Extra Pickup line for update when Pickup line is updated with a new start date
        // Issue/Purpose : 
        // When there is Pickup and Extra Pickup present for a service, and when the Pickup service is updated with new Start Date because of Service changes like Quantity Frequency etc
        // the Extra Pickup was not integrated as there was no change on the Extra Pickup. Hence only Pickup line was integrated with ACORN and Extra Pickup was not.
        // To enable the Integration, the Extra Pickup line was updated with same Start Date as Pickup.
        List<SBQQ__QuoteLine__c> extraPickupQuoteLineListForUpdate = new List<SBQQ__QuoteLine__c>();
        
        for(Id key : bundlewiseExtraPickupQuoteLinesMap.keyset())
        {
            Id parentQuoteLineId = key;
            SBQQ__QuoteLine__c extraPickupQuoteLine = bundlewiseExtraPickupQuoteLinesMap.get(key);
            
            //Check if Pickup exists for the Extra Pickup for the same Bundle
            if(bundlewisePickupQuoteLinesMap.keyset().contains(parentQuoteLineId))
            {
                Date pickupLineStartDate = bundlewisePickupQuoteLinesMap.get(key).SBQQ__StartDate__c;
                Date extraPickupLineStartDate = bundlewiseExtraPickupQuoteLinesMap.get(parentQuoteLineId).SBQQ__StartDate__c;

                if(extraPickupLineStartDate != pickupLineStartDate && pickupLineStartDate != null)	//Check if Extra Pickup lines needs to be updated
                {
                    SBQQ__QuoteLine__c extraPickupLineForUpdate  = bundlewiseExtraPickupQuoteLinesMap.get(parentQuoteLineId);
                    extraPickupLineForUpdate.SBQQ__StartDate__c = pickupLineStartDate;
                    //TCS-pkulkarn-SDT-33383-7-Dec-2023-Commented following call-No need to set Cost, Price and other fields when Extra Pick up is updated with new Start Date
                    /*if(updateFromIntakeScreen)
                    {
                    	QuoteLineServices.setDefaultValuesForQuoteLines(extraPickupLineForUpdate,extraPickupLineForUpdate.SBQQ__Quote__r.Name);
                    }
		    */
                    extraPickupQuoteLineListForUpdate.add(extraPickupLineForUpdate);	//Add the Extra Pickup quotelines to a List
                }
            }
        }
        return extraPickupQuoteLineListForUpdate;
    }
    //SDT 33101
    @AuraEnabled
    public static Boolean getIsAmendmentQuote(Id quoteId) {
        return QuoteOnlyController.getIsAmendmentQuote(quoteId);
    }
    //SDT 33101
    @AuraEnabled
    public static Boolean getshowAddQuoteOnlyServiceButtonForAmendment(Id quoteId) {
        return QuoteOnlyController.getshowAddQuoteOnlyServiceButtonForAmendment(quoteId);
    }
    //SDT 33101
    @AuraEnabled
    public static Boolean getDisableQuoteOnlyButtonForAmendment(Id quoteId) {
        return QuoteOnlyController.getDisableQuoteOnlyButtonForAmendment(quoteId);
    }
    
    //SDT 33101
    @AuraEnabled
    public static void saveQuoteOnly(Id quoteId,boolean quoteOnly, String quoteType) 
    {
       //TCS-pkulkarn-SDT-42718-31-Jan-2025-Added quoteType parameter in the signature and the below method call
        QuoteOnlyController.saveQuoteOnly(quoteId,quoteOnly, quoteType);
    }
    @AuraEnabled
    public static boolean displayApprovalButton(Id quoteId) 
    {
        boolean shouldDisplayApprovalButton = QuoteOnlyController.displayApprovalButton(quoteId);
       return shouldDisplayApprovalButton;
    }
    @AuraEnabled
    public static void approveQuoteLine(Id quoteId,id qlIdToApprove) 
    {
       QuoteOnlyController.approveQuoteLine(quoteId,qlIdToApprove);
    }
 /*
* @Method Name    : getMultivendorPricingRecord
* @author         : Chandu Kari SDT-20689
* @description    : This method is a supporing method to assign quote line values
* @param          : Id quoteId
* @return :  list<Pricing_Request__c>
* */
    @AuraEnabled(cacheable=true)
    public static List<Pricing_Request__c> getMultivendorPricingRecord(Id quoteId){
        List<Pricing_Request__c> priceReq= new List<Pricing_Request__c>();
        try{
            priceReq = PricingRequestSelector.getStandardPricingRequestList(quoteId);
        }catch(Exception ex){
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.PRICING_REQUEST_APEX,LoggingLevel.ERROR);
        }
        return priceReq;
    }
    //Created by Chandu Kari SDT-20689
    @AuraEnabled
    public static boolean getAMMultiVendorSwitch() 
    {
       boolean multiVendorSwitch = PricingRequestSelector.isPricingMulltiVendorAMSwitchON();
       return multiVendorSwitch;
    }
}
