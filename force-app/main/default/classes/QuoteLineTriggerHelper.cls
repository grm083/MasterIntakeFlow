/* 
* Apex Class : QuoteLineTriggerHelper
* Description : This class is used for Quote Line Object Activities
* Developer : Arvind Kumar
* Date : 03/June/2021
* Edit Comments :
*/

public class QuoteLineTriggerHelper 
{
    private static final string EXTRA_PICKUP_PRODUCT = 'Extra Pickup';
    private static final string PICKUP_PRODUCT = 'Pickup';
    private static final string SCHEDULED_TYPE = 'SCH';
    //SDT 40078
    private static final string EOM_EVENT = 'EV';
    private static final string OCCURENCE_TYPE_ONCALL = 'OC';
    //private static final set<string> nonICCServiceTypes = new set<string>{'Lock Fee','Liner','Hard Top Lid', 'Tarp'};	//pkulkarn-TCS-19-5-2023-Commented this line for SDT-31009
    public static boolean extrapickUpRecursion=true;
	//Changes related to SDT-31628
    public static Map<Id,boolean> extrapickUpDeleteRecursionMap = new Map<Id,boolean>();
    public static Set<Id> QuoteIds = new Set<Id>(); // Used in ExhibitPriceServices Class as part of SDT-44637 Do not change value conditionally
    //45005
    public static String strparentvendor = ' You cannot select a Parent Vendor ';
    /* 
*Developer : Arvind Kumar
*Description : This method is used to mark flag false for Extra pickup.
*Date : 03/June/2021
*/
    public static void removeExtraPickupQuoteLine(List<SBQQ__QuoteLine__c > quoteLineNewList)
    {
        Set<Id> requiredByIds  = new Set<Id>();
        if(!quoteLineNewList.isEmpty()){
            for(SBQQ__QuoteLine__c quoteLine : quoteLineNewList){
                if( quoteLine.SBQQ__RequiredBy__c != null
                   && quoteLine.SBQQ__ProductName__c == EXTRA_PICKUP_PRODUCT){
                       requiredByIds.add(quoteLine.SBQQ__RequiredBy__c );
                   }
            }system.debug('requiredByIds : ' + requiredByIds);
            
            if(!requiredByIds.isEmpty()){
                List<SBQQ__QuoteLine__c> updateQuoteLine = new List<SBQQ__QuoteLine__c>();
                for(SBQQ__QuoteLine__c quotePickupLine : [Select Id,IsExtrapickup__c from SBQQ__QuoteLine__c 
                                                          where SBQQ__ProductName__c =:PICKUP_PRODUCT 
                                                          and SBQQ__RequiredBy__c=:requiredByIds]){
                                                              quotePickupLine.IsExtraPickup__c = false;
                                                              updateQuoteLine.add(quotePickupLine); 
                                                          }//system.debug('updateQuoteLine : ' + updateQuoteLine);
                If(!updateQuoteLine.isEmpty()) {
                    update updateQuoteLine;
                }  
            }
        }
    }
     //45005 START
    public static void validateVendorSelection( List<SBQQ__QuoteLine__c> quoteLines,Map<Id, SBQQ__QuoteLine__c> oldQuoteLineMapping){
    
    if (quoteLines == null || quoteLines.isEmpty()) return;
    if (oldQuoteLineMapping == null) oldQuoteLineMapping = new Map<Id, SBQQ__QuoteLine__c>();
 
    /* --------------------------------------------
       STEP A: EARLY BYPASS CHECK 
       -------------------------------------------- */
 
    Set<Id> earlyVendorIds = new Set<Id>();
    for (SBQQ__QuoteLine__c ql : quoteLines) {
        if (ql.Vendor__c != null){
            earlyVendorIds.add(ql.Vendor__c);
        }
    }
 
    Map<Id, Account> earlyVendorMap = new Map<Id, Account>();
    if (!earlyVendorIds.isEmpty()) {
        earlyVendorMap = new Map<Id, Account>(
            [SELECT Parent_Vendor_Id__c,Vendor_Id__c
             FROM Account
             WHERE Id IN :earlyVendorIds]
        );
    }
 
    Boolean allUnchangedAndNotParent = true;
 
    for (SBQQ__QuoteLine__c ql : quoteLines) {
        if (ql.Vendor__c == null) continue;
 
        // vendor changed?
        if (oldQuoteLineMapping.containsKey(ql.Id) &&
            oldQuoteLineMapping.get(ql.Id).Vendor__c != ql.Vendor__c)
        {
            allUnchangedAndNotParent = false;
            break;
        }
 
        // parent vendor? 
        Account v = earlyVendorMap.get(ql.Vendor__c);
        Boolean isParentVendor = (v != null && v.Parent_Vendor_Id__c == null);
 
        if (isParentVendor) {
            allUnchangedAndNotParent = false;
            break;
        }
    }
 
    if (allUnchangedAndNotParent) {
        System.debug('### Early bypass active — exiting validation.');
        return;
    }
 
    /* --------------------------------------------
       STEP B: CORRECT PARENT DETECTION USING ParentId
       -------------------------------------------- */
 
    // collect all vendor ids again
    Set<Id> vendorIds = new Set<Id>();
    for (SBQQ__QuoteLine__c ql : quoteLines) {
        if (ql.Vendor__c != null) vendorIds.add(ql.Vendor__c);
    }
    if (vendorIds.isEmpty()) return;
 
    // fetch only vendor RT
    Map<Id, Account> vendorMap = new Map<Id, Account>(
        [SELECT Id, Name
         FROM Account
         WHERE Id IN :vendorIds
           AND RecordType.Name = 'Vendor']
    );
 
    // fetch children using ParentId 
    List<Account> childAccounts = [
        SELECT Id, ParentId
        FROM Account
        WHERE ParentId IN :vendorMap.keySet()
          AND RecordType.Name = 'Vendor'
    ];
 
    // set of TRUE parent ACCOUNT IDs
    Set<Id> trueParentAccountIds = new Set<Id>();
    for (Account c : childAccounts) {
        if (c.ParentId != null) {
            trueParentAccountIds.add(c.ParentId);
        }
    }
 
    /* --------------------------------------------
       STEP C: VALIDATE — BLOCK TRUE PARENTS
       -------------------------------------------- */
 
    for (SBQQ__QuoteLine__c ql : quoteLines) {
        if (ql.Vendor__c == null) continue;
        if (!vendorMap.containsKey(ql.Vendor__c)) continue;
 
        Account vendor = vendorMap.get(ql.Vendor__c);
        Boolean isTrueParent = trueParentAccountIds.contains(vendor.Id);
 
        if (isTrueParent) {
            ql.addError(strparentvendor + '(' + vendor.Name + ').');
        }
    }
 
}
  // shajiya 45005 End
    
    /* 
*Developer : Arvind Kumar
*Description : This method is used to mark flag True for Extra pickup.
*Date : 03/June/2021
*/
    public static void addExtraPickupQuoteLine(List<SBQQ__QuoteLine__c > quoteLineNewList)
    {
        Set<Id> requiredByIds  = new Set<Id>();
        
        for(SBQQ__QuoteLine__c quoteLine : quoteLineNewList){
            if( quoteLine.SBQQ__RequiredBy__c != null
               && quoteLine.SBQQ__ProductName__c == EXTRA_PICKUP_PRODUCT){
                   requiredByIds.add(quoteLine.SBQQ__RequiredBy__c );
               }
        }system.debug('requiredByIds : ' + requiredByIds);
        
        if(!requiredByIds.isEmpty()){
            List<SBQQ__QuoteLine__c> updateQuoteLine = new List<SBQQ__QuoteLine__c>();
            for(SBQQ__QuoteLine__c quotePickupLine : [Select Id,IsExtrapickup__c,Occurrence_Type__c from SBQQ__QuoteLine__c 
                                                      where SBQQ__ProductName__c =:PICKUP_PRODUCT 
                                                      and SBQQ__RequiredBy__c=:requiredByIds
                                                      and Occurrence_Type__c =:SCHEDULED_TYPE]){
                                                          quotePickupLine.IsExtraPickup__c = True;
                                                          updateQuoteLine.add(quotePickupLine); 
                                                      }//system.debug('updateQuoteLine : ' + updateQuoteLine);
            If(!updateQuoteLine.isEmpty()) {
                update updateQuoteLine;
            }  
        }
        
    }
    /*--------------------------------------
    *Author : rajan sajani
    *Description : to track quote line addition on quote
    *
    *Story : SDT-36179
    *
    ---------------------------------------*/
    public static void addQuoteLineHistoryRec(List<SBQQ__QuoteLine__c > quoteLineNewList)
    {
    
        List<SBQQ__QuoteLine__c> quotelineListQuote = new List<SBQQ__QuoteLine__c>();
        quotelineListQuote = [Select id,SBQQ__Quote__c,LastModifiedById,LastModifiedBy.Name,LastModifiedDate,SBQQ__Quote__r.Name,Name,SBQQ__Product__r.Name from SBQQ__QuoteLine__c where Id IN : quoteLineNewList and SBQQ__Quote__r.SBQQ__Status__c IN ('Product Configured','Cost Configured')];
        if(quotelineListQuote.size()>0){
        //String QuoteName = quotelineListQuote[0].SBQQ__Quote__r.Name;
		//String QuoteID = quotelineListQuote[0].SBQQ__Quote__c;
    
      	List<Quote_Line_History_Tracking__c> addedQuoteLineList = new List<Quote_Line_History_Tracking__c>();
           for (SBQQ__QuoteLine__c newLine : quotelineListQuote) {
			   
               Quote_Line_History_Tracking__c history = new Quote_Line_History_Tracking__c(
                   Action__c = 'Added',
                   Quote_Line__c = newLine.Id,
                   Quote_Line_Number__c = newLine.Name,
                   Quote_Number__c = newLine.SBQQ__Quote__r.Name,
                   Quote_Id__c= newLine.SBQQ__Quote__c,
                   Product_Name__c = newLine.SBQQ__Product__r.Name,
                   User_Name__c = newLine.LastModifiedBy.Name
                  
               );
               addedQuoteLineList.add(history);
                   System.debug(' addedQuoteLineList^^^ ' +addedQuoteLineList); 

           }
	   if(addedQuoteLineList.size()>0){
           	insert addedQuoteLineList;
	   }
        }
        
    }
    
    /* 
*Developer : Arvind Kumar
*Description : This method is used to update Duration on Quote.
*Date : 04/June/2021
*/
    /* Updated code by
*Developer : Jatan Sharma
*Description : This method is used to Set Account on quoteline.
*Date : 14/June/2021
*/
    /*Updated code by
* Developer : George Martin
* Description : Include default validations in the pre-insert trigger
* Date : 21/June/2021
*/
    public static void updateDurationAndAccountOnQuoteLine(List<SBQQ__QuoteLine__c > quoteLineNewList)
    {
       
        Set<Id> newQLsRequiredByIds = new Set<Id>();
        String caseRecordType = '';     //pkulkarn-TCS-06-Jul-2023-Added for SDT-31055
        for(SBQQ__QuoteLine__c qouteLine : quoteLineNewList){
            //SDT-23055, update price and cost with 0 if the selected product is keys.
            //SDT 33136 setting cost and price to 0 only if asset is not available on Quoteline
            QuoteLineServices.setListUnitCostToZero(qouteLine);
            quoteIds.add(qouteLine.SBQQ__Quote__c); // Used in ExhibitPriceServices Class as part of SDT-44637 do not change coditionally
            newQLsRequiredByIds.add(qouteLine.SBQQ__RequiredBy__c);
        }
        
        Map<Id,List<SBQQ__QuoteLine__c>> mapQuoteAndBundleQL = new  Map<Id,List<SBQQ__QuoteLine__c>>();
        
        if(!quoteIds.isEmpty()){
            Map<Id,SBQQ__Quote__c> mapQuotes = new Map<Id,SBQQ__Quote__c>();
            Map<Id, Id> parentRequiredByMap = new Map<Id, Id>();
            // SDT-31110 - Dynamically get the Quotes and its Bundles
            List<SBQQ__Quote__c> listQuote = QuoteSelector.getQuoteWithParentBundle(quoteIds, newQLsRequiredByIds);
            
            for(SBQQ__Quote__c quotes : listQuote){
                mapQuotes.put(quotes.Id,quotes);
                // put map of QuoteId vs bundle line 
        
                for(SBQQ__QuoteLine__c ql: quotes.SBQQ__lineitems__r)
                {
                    if(ql.SBQQ__RequiredBy__c == null)
                    {
                        // Adding Parent Bundle only
                        if(mapQuoteAndBundleQL.containsKey(quotes.Id))
                        {
                            List<SBQQ__QuoteLine__c> quotelinelst = mapQuoteAndBundleQL.get(quotes.Id);
                            quotelinelst.add(ql);
                            mapQuoteAndBundleQL.put(quotes.Id,quotelinelst);
                        }
                        else{
                            mapQuoteAndBundleQL.put(quotes.Id,new List<SBQQ__QuoteLine__c>{ql});
                        }
                    }
                    else{
                        // Adding SubParent like Lock Fee to Handle keys
                        parentRequiredByMap.put(ql.Id, ql.SBQQ__RequiredBy__c);
                    }
                }
            }
            
            for(SBQQ__QuoteLine__c quoteLines : quoteLineNewList){
                if(mapQuotes.containsKey(quoteLines.SBQQ__Quote__c)){
		    // Changes for the defect 25125
                   
                   // Changes for SDT-31119
                    if (String.isempty(quoteLines.Duration__c))
                    {

                        //pkulkarn-TCS-06-Jul-2023-SDT-31055-Remove hard coded values

                        quoteLines.Duration__c = mapQuotes.get(quoteLines.SBQQ__Quote__c).Duration__c == Constant_Util.QUOTE_LINE_PERMANENT ? Constant_Util.QUOTE_LINE_PERM : Constant_Util.QUOTE_LINE_TEMP;
                        
                    }
                    //&& added for SDT 31118
                    //Changes for SDT-24972
                    //pkulkarn-TCS-06-Jul-2023-SDT-31055-Remove hard coded values New_Service from if condition and SWITCH
                    //SDT 39669 - commenting exisitng IF
                    /*if ((String.isEmpty(quoteLines.VCRCode__c) && mapQuotes.get(quoteLines.SBQQ__Quote__c).RecordType.DeveloperName == Constant_Util.QUOTE_RECORDTYPE_NEW_SERVICE)
                        && mapQuotes.get(quoteLines.SBQQ__Quote__c).SBQQ__Opportunity2__r.Case__r.RecordType.DeveloperName != Constant_Util.MODIFY_EXISTING_SERVICE_CASE_API) {*/
                        if ((String.isEmpty(quoteLines.VCRCode__c) && mapQuotes.get(quoteLines.SBQQ__Quote__c).SBQQ__Type__c == Constant_Util.QUOTE)) {                            
                        SWITCH ON quoteLines.Duration__c {
                            WHEN 'TEMP' {
                                quoteLines.VCRCode__c = Constant_Util.VCR_CODE_NBT;
                            }
                            WHEN 'PERM' {
                                quoteLines.VCRCode__c = Constant_Util.VCR_CODE_NBG;
                            }
                        }
                    }
                    quoteLines.Account__c = mapQuotes.get(quoteLines.SBQQ__Quote__c).SBQQ__Account__c;
                    //SDT-27107
                    //if (mapQuotes.get(quoteLines.SBQQ__Quote__c).SBQQ__Opportunity2__r.Case__r.RecordType.DeveloperName == Constant_Util.R_NEW_SERVICE_CASE)
                       // quoteLines.SBQQ__StartDate__c = mapQuotes.get(quoteLines.SBQQ__Quote__c).SBQQ__StartDate__c;
                    
                     //SDT- 21220 Code added to add Company category code "EPR" for Equipment Repair.
                    SBQQ__Quote__c parentQuote = mapQuotes.get(quoteLines.SBQQ__Quote__c);
                    setCompanyCategoryCodeAsEPR(parentQuote, quoteLines);
                    
                    //Changes for SDT-24848- added condition to override enddate only in case of New Service Case
                    //Commented for  SDT27107
                    /*if (mapQuotes.get(quoteLines.SBQQ__Quote__c).SBQQ__Opportunity2__r.Case__r.RecordType.DeveloperName == Constant_Util.R_NEW_SERVICE_CASE)
                    {
                        if (quoteLines.SBQQ__ProductCode__c == 'DLV') {
                            quoteLines.SBQQ__EndDate__c = quoteLines.SBQQ__StartDate__c;
                        } else {
                            quoteLines.SBQQ__EndDate__c = mapQuotes.get(quoteLines.SBQQ__Quote__c).SBQQ__EndDate__c;
                        }
                    }*/
                    
                    //pkulkarn-TCS-06-Jul-2023-Added below function call for SDT-31055
                    caseRecordType = mapQuotes.get(quoteLines.SBQQ__Quote__c).SBQQ__Opportunity2__r.Case__r.RecordType.DeveloperName;
                    //commenting below line as part of SDT32803
                    //setExceptionReasonForNewQuoteLine(quoteLines, caseRecordType);
                    
                    // SDT-31110 - It is to copy the bundle qL fields in newly inserted quote line
                    
		    Id keysParentId;
                    if(parentRequiredByMap.containsKey(quoteLines.SBQQ__RequiredBy__c))
                    {
                        
			
			
			keysParentId = parentRequiredByMap.get(quoteLines.SBQQ__RequiredBy__c);
                    }
                    
                    QuoteLineServices.setQuoteLineValueFromBundle(quoteLines
                                                                  ,mapQuoteAndBundleQL.get(quoteLines.SBQQ__Quote__c)
                                                                  ,mapQuotes.get(quoteLines.SBQQ__Quote__c), keysParentId);
                    
                    
                }
                
                
                
            }
        }
    }
    
    //sdhikale TCS SDT- 29806 
    //Code added to copy Exception_Effective_Date__c into Exceptions_Effective_Date__c
    public static void setExceptionsEffectiveDate(List<SBQQ__QuoteLine__c > quoteLineNewList){
        if(quoteLineNewList!=null){
            for(SBQQ__QuoteLine__c ql : quoteLineNewList)
            {
                if(ql.Exception_Effective_Date__c!=null){
                    ql.Exception_Effective_Date__c = ql.Exceptions_Effective_Date__c;
                }
            }
        }
    }
    
    //SDT- 21220 Code added to default Company category code "EPR" to Equipment Repair, as Quote Reason is Baler Repair or Compactor Repair..
   public static void setCompanyCategoryCodeAsEPR(SBQQ__Quote__c parentQuote, SBQQ__QuoteLine__c quoteLine){
    		if (parentQuote != null && parentQuote.Case_Reason__c != null){
           		if (parentQuote.Case_Reason__c.equalsIgnoreCase('Baler Repair') ||parentQuote.Case_Reason__c.equalsIgnoreCase('Compactor Repair') )
                 {
                  	  quoteLine.CompanyCategoryCode__c = Constant_Util.EquipmentRepairKey_EPR;
                 } 
       		}
    }

    /*
	* @vendor            TCS
	* @story             SDT-29645
	* @author            Jatan Sharma / Ojha Digdershika
	* @description       Update MAS details to Quote Lines. 
	* @called from       After update of vendor in quoteline. 
	* @return            NA
	*/ 
    
    public static void updateMASDetailsToQuoteLines(Map<Id,SBQQ__QuoteLine__c> oldQuoteLineMap,Set<Id> sqlID){
        List<SBQQ__QuoteLine__c> qLToUpdate = new List<SBQQ__QuoteLine__c>();
        string FacilityId;
        //string FacilityName;
        string SiteId;
        //string SiteName;
        boolean newServiceCase;
        string lineOfBusiness;

        String aav_zoneType;
        String costSource ;
        boolean byPassReviewFlag ;
        string businessUnit;
        //Fetch All quotelines
        List<SBQQ__QuoteLine__c> quoteLineList = [SELECT Id, Vendor__r.Vendor_Business_Unit__c,Vendor__r.FacilityCode__c,Vendor__r.Parent_Vendor_ID__c, MASLibrary__c, MASCompany__c, BypassPriceReview__c, SBQQ__RequiredBy__c, SBQQ__Quote__r.Name, Name,
                                                 (SELECT id, AAV_APIRequestOutput__c from Asset_Availabilities__r),SBQQ__Product__r.Family,
                                                 SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__r.RecordType.Name,
                                                 Pricing_Request__c,Pricing_Request__r.Facility_Id__c, Pricing_Request__r.Site_Id__c           
                                                 FROM SBQQ__QuoteLine__c WHERE Id IN :sqlId OR 
                                                 SBQQ__RequiredBy__c IN :sqlID  OR 
                                                 SBQQ__RequiredBy__r.SBQQ__RequiredBy__c IN :sqlID];
        
        for(SBQQ__QuoteLine__c pQL : quoteLineList){
            if(pQL.SBQQ__RequiredBy__c == null){
                if(pQL.SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__r.RecordType.Name == Constant_Util.New_Service_Case){
                    newServiceCase = true;
                }
                if(pQL.SBQQ__Product__r.Family == Constant_Util.ROLLOFF){
                    lineOfBusiness = 'O';
                }
                else if(pQL.SBQQ__Product__r.Family == Constant_Util.COMMERCIAL){
                    lineOfBusiness = 'C';
                }
                //Availablity information to set bypass value
                 for(AAV_Asset_Availability__c availabilityOutput : pQL.Asset_Availabilities__r){
                     if(availabilityOutput!=null){
                         AvailabilityAPIJsonDeserialize availabilityData = AvailabilityAPIJsonDeserialize.parse(availabilityOutput.AAV_APIRequestOutput__c);
                         if(availabilityData.data != null && availabilityData.data.suppliers.size()>0  && availabilityData.data.suppliers[0] != null){
                             AvailabilityAPIJsonDeserialize.cls_suppliers supplier = availabilityData.data.suppliers[0];
                             if(supplier!=null){
                                 aav_zoneType = supplier.contractType;
                                 costSource = supplier.availabilitySource; 
                             }
                         }
                     }
                 }
                if(pQL.Pricing_Request__c != null && pQL.Pricing_Request__r.Facility_Id__c != null
                  && oldQuoteLineMap.get(pQL.Id).Vendor__c == null){
                    
                    FacilityId = pQL.Pricing_Request__r.Facility_Id__c;
                    //FacilityName = pQL.Pricing_Request__r.Facility_Name__c;
                    SiteId = pQL.Pricing_Request__r.Site_Id__c;
                    //SiteName = pQL.Pricing_Request__r.Site_Name__c;
                }
                else if(pQL.Vendor__r.FacilityCode__c != null){
                    
                    FacilityId = pQL.Vendor__r.FacilityCode__c;
                }

                if(pQL.Vendor__r.Vendor_Business_Unit__c != null )
                {
                    businessUnit = pQL.Vendor__r.Vendor_Business_Unit__c;
                }
            }
        }
       
        //Fetch market area.
        //SDT-39072 - check condition for null facility ID
        //List<AggregateResult> masSetupDetail = new List<AggregateResult>();
        List<MAS_Setup_Detail__c> masSetupDetail = new List<MAS_Setup_Detail__c>();
        if(FacilityId != null){
        masSetupDetail = [SELECT Id, Business_Unit_Number__c, MAS_Line_of_Business__c,MAS_Library__c, MAS_Company_Code__c,Facility_Id__c, Facility_Name__c, Site_Id__c, Site_Name__c , Bypass_Price_Review__c
                                                    FROM MAS_Setup_Detail__c where 
                                                    (Facility_Id__c =:FacilityId and
                                                    Site_Id__c=:SiteId and
                                                    MAS_Line_of_Business__c=:lineOfBusiness and
                                                    Valid_For_New_Service__c =:newServiceCase)
                                                    or
                                                    (Facility_Id__c =:FacilityId and 
                                                    Valid_For_New_Service__c =:newServiceCase and 
                                                    MAS_Line_of_Business__c =:lineOfBusiness)  ];
        }

        //New addition to code                                            
        if(masSetupDetail.size() == 0)
        {
            masSetupDetail = [SELECT Id, Business_Unit_Number__c, MAS_Line_of_Business__c,MAS_Library__c, MAS_Company_Code__c,Facility_Id__c, Facility_Name__c, Site_Id__c, Site_Name__c, Bypass_Price_Review__c 
                                                    FROM MAS_Setup_Detail__c where 
                                                    Business_Unit_Number__c =:businessUnit and 
                                                    MAS_Line_of_Business__c =:lineOfBusiness  ];
        }  
          //Match map entries to quote lines
          for (SBQQ__QuoteLine__c quoteLine : quoteLineList) {
            if(masSetupDetail!=null && masSetupDetail.size() == 1){
                quoteLine.MASLibrary__c = masSetupDetail[0].MAS_Library__c;
                quoteLine.MASCompany__c = masSetupDetail[0].MAS_Company_Code__c;
                 if(aav_zoneType!=null){
                            
                     byPassReviewFlag = PricingRequestSTPProcess.getBypassPriceReview( aav_zoneType, quoteLine.Vendor__r.Parent_Vendor_ID__c,  masSetupDetail[0].MAS_Library__c);
                 }
                 quoteLine.BypassPriceReview__c = byPassReviewFlag == null ? quoteLine.BypassPriceReview__c : byPassReviewFlag;
                
                qLToUpdate.add(quoteLine);
            }
            else{
                quoteLine.MASLibrary__c = null;
                quoteLine.MASCompany__c = null;
                qLToUpdate.add(quoteLine);
            }
        }

        if(qLToUpdate.size() > 0){
            update qLToUpdate;
        }
}
 /*   public static void updateCompanyCode(List<SBQQ__QuoteLine__c> newQuoteLineList, Set<Id> sqlID)
    {
        
            String aav_zoneType;
            String costSource ;
            boolean byPassReviewFlag ;
            List<SBQQ__QuoteLine__c> quoteLineList = [SELECT Id, Vendor__r.Vendor_Business_Unit__c,Vendor__r.Parent_Vendor_ID__c, MASLibrary__c, MASCompany__c, BypassPriceReview__c, SBQQ__RequiredBy__c, SBQQ__Quote__r.Name, Name, (SELECT id, AAV_APIRequestOutput__c from Asset_Availabilities__r) 
                                                      FROM SBQQ__QuoteLine__c
                                                      WHERE Id IN :sqlId OR SBQQ__RequiredBy__c IN :sqlID OR SBQQ__RequiredBy__r.SBQQ__RequiredBy__c IN :sqlID];
            
        List<SBQQ__QuoteLine__c> updateQuoteList = new List<SBQQ__QuoteLine__c>();
        map<String, List<AggregateResult>> BUtoMAS = new Map<String, List<AggregateResult>>();
        
        //Store MAS Details into single aggregate list and Map
        List<AggregateResult> masDetails = [SELECT Count(Id),Business_Unit_Number__c, MAS_Library__c, MAS_Company_Code__c
                                            FROM MAS_Setup_Detail__c
                                            GROUP BY Business_Unit_Number__c, MAS_Library__c, MAS_Company_Code__c];
        
        for (AggregateResult aggResult : masDetails) {
            String BUString = aggResult.get('Business_Unit_Number__c').toString();
            if (BUString != null && BUtoMAS.containsKey(BUString)) {
                List<AggregateResult> tempAggList = BUtoMAS.get(BUString);
                tempAggList.add(aggResult);
                BUtoMAS.put(BUString, tempAggList);
            } else if(BUString != null) {
                BUtoMAS.put(BUString, new List<AggregateResult>{aggResult});
            }
        }
        
        //Match map entries to quote lines
        for (SBQQ__QuoteLine__c quoteLine : quoteLineList) {
            if (quoteLine.Vendor__r.Vendor_Business_Unit__c != null) {
                List<AggregateResult> singleBUtoMAS = BUtoMAS.get(quoteLine.Vendor__r.Vendor_Business_Unit__c);
                if (singleBUtoMAS != null && !singleBUtoMAS.isEmpty() && singleBUtoMAS.size() == 1) {
                    quoteLine.MASLibrary__c = String.valueOf(singleBUtoMAS[0].get('MAS_Library__c'));
                    quoteLine.MASCompany__c = String.valueOf(singleBUtoMAS[0].get('MAS_Company_Code__c'));
		    //SDT-31627 - start
                        try{
                        if(quoteLine.SBQQ__RequiredBy__c == null){
                            system.debug('Inside updateCompanyCode quoteLine.SBQQ__RequiredBy__c');
                            for(AAV_Asset_Availability__c availabilityOutput : quoteLine.Asset_Availabilities__r){
                                if(availabilityOutput!=null){
                                    AvailabilityAPIJsonDeserialize availabilityData = AvailabilityAPIJsonDeserialize.parse(availabilityOutput.AAV_APIRequestOutput__c);
                                    if(availabilityData.data != null && availabilityData.data.suppliers != null && availabilityData.data.suppliers[0] != null){
                                        AvailabilityAPIJsonDeserialize.cls_suppliers supplier = availabilityData.data.suppliers[0];
                                        if(supplier!=null){
                                            aav_zoneType = supplier.contractType;
                                            costSource = supplier.availabilitySource; 
                                        }
                                    }
                                }
                            }
                        }
                        if(aav_zoneType!=null){
                            
                            byPassReviewFlag = PricingRequestSTPProcess.getBypassPriceReview( aav_zoneType, quoteLine.Vendor__r.Parent_Vendor_ID__c,  String.valueOf(singleBUtoMAS[0].get('MAS_Library__c')));
                        }
                        quoteLine.BypassPriceReview__c = byPassReviewFlag == null ? quoteLine.BypassPriceReview__c : byPassReviewFlag;
                    }catch(Exception ex){
                            
                            String appName = 'QuoteLineTriggerHelper By Pass Review Availiability parser failed for Quote '+ quoteLine.SBQQ__Quote__r.Name + ' QuoteLine '+ quoteLine.Name;
                            STPExceptionUtil.setStepByStepExceptionObj('updateCompanyCode', appName,ex.getMessage());
                        }
                        
                        //SDT-31627 - end
                    updateQuoteList.add(quoteLine);
                } else {
                    quoteLine.MASLibrary__c = null;
                    quoteLine.MASCompany__c = null;
                    updateQuoteList.add(quoteLine);
                }
            } else {
                quoteLine.MASLibrary__c = null;
                quoteLine.MASCompany__c = null;
                updateQuoteList.add(quoteLine);
            }
        }
        
	    try {
            update updateQuoteList;
        } catch (exception e) {
            system.debug('Exception thrown during update process: ' + e.getMessage());
        }
        }

 */
   
    //To be included once validated.  This will set the material type field on the quote line
    /* shifted the whole logic in GetDetails Class. Jira ID - SDT-19962
    public static void updateMaterialType(List<SBQQ__QuoteLine__c> quoteLineNewList) {
        
        Set<Id> setQuoteIds = new Set<Id>();
        List<SBQQ__QuoteLine__c> updateQLine = new List<SBQQ__QuoteLine__c>();
        for (SBQQ__QuoteLine__c quoteLine : quoteLineNewList) {
            setQuoteIds.add(quoteLine.SBQQ__Quote__c);
            //setRequiredByIds.add(quoteLine.SBQQ__RequiredBy__c);
        }
        
        List<SBQQ__QuoteLine__c> materialCodeQLList = [SELECT Id, SBQQ__Product__r.Name,Waste_Stream_Code__c, SBQQ__Product__r.ProductCode, SBQQ__RequiredBy__r.SBQQ__RequiredBy__c  
                                                       FROM SBQQ__QuoteLine__c 
                                                       WHERE SBQQ__Product__r.Family = 'Waste Stream' 
                                                       AND SBQQ__Quote__c =: setQuoteIds
                                                      ];
        system.debug('materialCodeQLList : ' + materialCodeQLList);
        if(!materialCodeQLList.isEmpty()){
            for(SBQQ__QuoteLine__c quoteLine : quoteLineNewList){                
                for (SBQQ__QuoteLine__c wsLineItem : materialCodeQLList){
                    If(WSLineItem.SBQQ__RequiredBy__r.SBQQ__RequiredBy__c == quoteLine.Id  || WSLineItem.SBQQ__RequiredBy__r.SBQQ__RequiredBy__c == quoteLine.Id){
                        system.debug('wsLineItem.SBQQ__Product__r.Name : ' + wsLineItem.SBQQ__Product__r.Name);
                        quoteline.Waste_Stream_Code__c = wsLineItem.SBQQ__Product__r.Name;
                        updateQLine.add(quoteline);
                    }                   
                }
            }
            if(!updateQLine.isEmpty()){
                update updateQLine;
            }
        }
        
    } */

        public static void validatePickUp(List<SBQQ__QuoteLine__c> newQuoteLineList, map<id, SBQQ__QuoteLine__c> newQuoteLineMap){
        //SDT 36176 moving this method to new class ExtraPickupHandler
        ExtraPickupHandler.operateExtraPickupLine( newQuoteLineList,  newQuoteLineMap);
    }
    
    
	
	
	/**************************************************
    * Created By:Anup Dey
    * CreatedDate:09/02/2022
    * Story: SDT-21787
    * Comment: changes for 
    * **************************************************/
    public static Map<Id,SBQQ__Quote__c> updateQuotedate(List<SBQQ__QuoteLine__c> quoteLineList)
    {
        // local variables
        List<SObject> soList = new List<SObject>();
        Set<Id> quotelist = new Set<Id>();
        Map<Id, SBQQ__Quote__c> mapOfquote = new Map<Id, SBQQ__Quote__c>();
        List<SBQQ__Quote__c> qList = new List<SBQQ__Quote__c>();
        //creating quote list from updated quotelines
        for(SBQQ__QuoteLine__c qline :quoteLineList)
        {
            quotelist.add(qline.SBQQ__Quote__c);
        }

        // Removed new service Case for SDT-29106 //AND SBQQ__Opportunity2__r.Case__r.RecordType.Name=: Constant_Util.New_Service_Case
        //get quote and cases which are New service type
             qList =[Select Id, SBQQ__StartDate__c, SBQQ__Opportunity2__r.Case__c, SBQQ__Opportunity2__r.Case__r.Tracking_Number__c,
                 SBQQ__Opportunity2__r.Case__r.Service_Date__c, SBQQ__Opportunity2__r.Case__r.RecordType.Name, 
                 SBQQ__Opportunity2__c,SBQQ__Opportunity2__r.case__r.CaseNumber,
                                           SBQQ__Opportunity2__r.case__r.Case_Type__c,SBQQ__Status__c,
                                           SBQQ__Opportunity2__r.case__r.account.Primary_Segment__c,
                                           SBQQ__Opportunity2__r.case__r.Case_Sub_Type__c,
                                           SBQQ__Opportunity2__r.case__r.Case_Reason__c,RecordType.Name,
                                           SBQQ__Opportunity2__r.Case__r.Account.Vendor_ID__c,
                                           SBQQ__Opportunity2__r.Case__r.Id, SBQQ__Opportunity2__r.Case__r.Supplier__r.Name,
                                           SBQQ__Opportunity2__r.Case__r.Supplier__r.Vendor_ID__c,
                                           SBQQ__Opportunity2__r.Case__r.Supplier__r.Parent.Vendor_ID__c,
                                           SBQQ__Opportunity2__r.Case__r.Supplier__r.Parent.Name,
                                           SBQQ__ShippingName__c,SBQQ__Opportunity2__r.Case__r.Last_Agent_ID__c,
                                           SBQQ__Opportunity2__r.Case__r.Asset.Project_Code__c,
                                           SBQQ__Opportunity2__r.Case__r.Asset.Active__c,
                                           SBQQ__Opportunity2__r.Case__r.SLA_Service_Date_Time__c,
                                           Next_Action_Due_Date__c, LastModifiedBy.UserName,
                                           SBQQ__Opportunity2__r.case__r.Location__r.tz__Timezone__c,LastModifiedById
                 From SBQQ__Quote__c  WHERE Id IN: quotelist ];

         Map<Id, SBQQ__Quote__c> quoteMap = new Map<Id, SBQQ__Quote__c>(qList);

         // check if quote lines available
         if(!qList.isempty())
         {
             // creating quoteId and Quote Map
            for(SBQQ__Quote__c q: qList)
            {
                mapOfquote.put(q.Id, q);
            }

            List<SBQQ__Quote__c> tobeUpdatedQuotes =new List<SBQQ__Quote__c>();
            Map<Id, List<SBQQ__QuoteLine__c>> quoteQuotelineMap= new Map<Id, List<SBQQ__QuoteLine__c>>();
            Map<Id, List<Id>> parentQuoteandQuotelineMap= new Map<Id, List<Id>>();
			
            //get parent quote lines which are in draft quote status
            List<SBQQ__QuoteLine__c> quotelines= [SELECT Id,SBQQ__StartDate__c,SBQQ__Quote__r.SBQQ__StartDate__c, SBQQ__RequiredBy__c  from SBQQ__QuoteLine__c 
                                                where SBQQ__Quote__c in :quotelist AND SBQQ__Quote__r.SBQQ__Status__c !=: Constant_Util.QUOTE_APPROVED AND SBQQ__Quote__r.SBQQ__Status__c !=: Constant_Util.QUOTE_DECLINED AND SBQQ__Quote__r.SBQQ__StartDate__c != null AND SBQQ__Product__r.Family !=: Constant_Util.WASTE_STREAM AND SBQQ__Product__r.Family !=: Constant_Util.WASTE_CATEGORY Order by SBQQ__Number__c];  // Changes for SDT-29106

            // Added date null check and list empty check for SDT-29106
            if(!quotelines.isempty())
            {
                // loop through the Quote line to fill the quoteQuotelineMap(this map is holding relationship between quote and quote list)
                for(SBQQ__QuoteLine__c ql: quotelines)
                {
                    if(quoteQuotelineMap.containsKey(ql.SBQQ__Quote__c))
                    {
                        List<SBQQ__QuoteLine__c> tempQL = quoteQuotelineMap.get(ql.SBQQ__Quote__c);
                        tempQL.add(ql);
                        quoteQuotelineMap.put(ql.SBQQ__Quote__c,tempQL);
						 // Changes for SDT-29106: Creating Map of Quote and Parent Lines
						 if(ql.SBQQ__RequiredBy__c==null)
						 {
							//SDT 33101
							//List<Id> tempQLId = parentQuoteandQuotelineMap.get(ql.SBQQ__Quote__c);
							//tempQLId.add(ql.Id);
							//parentQuoteandQuotelineMap.put(ql.SBQQ__Quote__c,tempQLId);
							if(parentQuoteandQuotelineMap != null && parentQuoteandQuotelineMap.size() > 0)
                             {
                                 List<Id> tempQLId = parentQuoteandQuotelineMap.get(ql.SBQQ__Quote__c);
                                 system.debug('In Contain Key');
                                 
                                 tempQLId.add(ql.Id);
                                 parentQuoteandQuotelineMap.put(ql.SBQQ__Quote__c,tempQLId);
                             }
                             else {
                                 parentQuoteandQuotelineMap.put(ql.SBQQ__Quote__c,new List<Id>{ql.Id});
                             }//SDT 33101 end
						 }
                    }
                    else{
                        quoteQuotelineMap.put(ql.SBQQ__Quote__c,new List<SBQQ__QuoteLine__c>{ql});
						// Changes for SDT-29106: Creating Map of Quote and Parent Lines
						if(ql.SBQQ__RequiredBy__c==null)
						{
							parentQuoteandQuotelineMap.put(ql.SBQQ__Quote__c,new List<Id>{ql.Id});
						}
                    }
                }
                
                // Changes for SDT-29106
                boolean isDateChanged = false;
                // loop through quoteQuotelineMap key which is quote
                for (id key : quoteQuotelineMap.keyset()) 
                {
                    // creating probable quote update object
                    SBQQ__Quote__c quote = new SBQQ__Quote__c();
                    quote.Id = key;
                    SBQQ__Quote__c qvalue= mapOfquote.get(key);
                    Date updateDate;
                    // Changes for SDT-29106
                    Integer startDateDifference;
                    if(qvalue!=null && qvalue.SBQQ__StartDate__c!=null)
                    {
                        updateDate = qvalue.SBQQ__StartDate__c;
                    }
                    
                    map<id, date> quoteIdServiceDateMap = CaseSLAEntitlementUTIL.getQuoteIdServiceDateMap(quoteQuotelineMap.keyset());
                    // loop through quoteQuotelineMap key which is quote lines and adding items in probable quote and case which needs to update
                    for(SBQQ__QuoteLine__c ql: quoteQuotelineMap.get(key))
                    {
                        // Changes for SDT-29106
                        if(qvalue.SBQQ__Opportunity2__r.Case__r.RecordType.Name == Constant_Util.New_Service_Case) 
                        {
                            if(parentQuoteandQuotelineMap.get(key).size() ==1 && ql.SBQQ__StartDate__c != null )
                            {
                                updateDate = ql.SBQQ__StartDate__c;
                                isDateChanged= true;
                            }
                            else
                            {
    
                                if(ql.SBQQ__StartDate__c != null && ql.SBQQ__StartDate__c < updateDate )
                                {
                                    updateDate = ql.SBQQ__StartDate__c;
                                    isDateChanged= true;
                                }
                            }
                        }
                        else // Changes for SDT-29106
                        {

                            if(ql.SBQQ__StartDate__c != null)
                            {
                                Integer numberDaysDue = Date.Today().daysBetween(ql.SBQQ__StartDate__c);
                                if(ql.SBQQ__StartDate__c != null && ql.SBQQ__StartDate__c >= Date.Today() && numberDaysDue >= 0)
                                {
                                    if(startDateDifference == null)
                                    {
                                        startDateDifference = numberDaysDue;
                                        updateDate = ql.SBQQ__StartDate__c;
                                        isDateChanged = true;
                                    }
                                    else if(startDateDifference != null && startDateDifference > numberDaysDue)
                                    {
                                        startDateDifference = numberDaysDue;
                                        updateDate = ql.SBQQ__StartDate__c;
                                        isDateChanged = true;
                                    }
                                }
                            }
                        }
                    }
                    // Changes for SDT-29106
                    if(isDateChanged)
                    {
                        quote.SBQQ__StartDate__c = updateDate; 
                        soList.add(quote);
                    }
                    // creating probable case update object
                    Case cs = new Case();
                
                    // if case don't have tracking then will update the case
                    // Changes for SDT-29106
                    if(qvalue!=null && qvalue.SBQQ__Opportunity2__r.Case__r.Tracking_Number__c ==null && isDateChanged)
                    {
                        cs.Id = qvalue.SBQQ__Opportunity2__r.Case__c;
                        cs.Service_Date__c= updateDate;
                        if(quoteIdServiceDateMap.containsKey(qvalue.id) && quoteIdServiceDateMap.get(qvalue.id) != null){
                            if(cs.Service_Date__c>quoteIdServiceDateMap.get(qvalue.id)){
                                cs.Service_Date__c= quoteIdServiceDateMap.get(qvalue.id);   
                            }
                        }
                        soList.add(cs);
                    }
                    
                }
                // check if sObject list is available
                if(!soList.isempty())
                {
                    SBQQ.TriggerControl.disable();
                    try{
                        update soList;
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
     return quoteMap;
    }
    /**************************************************
    * Created By:Aliasgher Kotawala
    * CreatedDate:05/01/2023
    * Story: SDT-26002
    * Comment: Validate quote line Cost Price
    * **************************************************/
    public static void validateQLCostPrice(List<SBQQ__QuoteLine__c> newQuoteLineList,Map<Id,SBQQ__QuoteLine__c> oldQuoteLineMap,Map<Id,SBQQ__QuoteLine__c> newQuoteLineMap)
    {
        //AND(!(ISNEW()),ISCHANGED(SBQQ__UnitCost__c), PRIORVALUE(SBQQ__UnitCost__c) > 0 , ISBLANK(TEXT(Cost_Override_Reason__c)))
        system.debug('inside QuoteLineTriggerHelper validateQLCostPrice');
        for(SBQQ__QuoteLine__c qLine : newQuoteLineList)
        {
            if(qLine.SBQQ__RequiredBy__c != null)
            {
                //Validation Logic for Cost/Price
                if(oldQuoteLineMap.get(qLine.Id) != null)
                {
                    if(oldQuoteLineMap.get(qLine.Id).SBQQ__UnitCost__c != null 
                    && oldQuoteLineMap.get(qLine.Id).SBQQ__UnitCost__c > 0 
                    && qLine.SBQQ__UnitCost__c != oldQuoteLineMap.get(qLine.Id).SBQQ__UnitCost__c
                    && qLine.Cost_Override_Reason__c == null)
                    {
                        //Add Error for Cost Validation
                        qLine.addError('When Cost is Overridden, Cost Override Reason must be provided.');
                    }

                    //Validation Logic for Cost
                    if(oldQuoteLineMap.get(qLine.Id).SBQQ__ListPrice__c != null 
                    && oldQuoteLineMap.get(qLine.Id).SBQQ__ListPrice__c > 0 
                    && qLine.SBQQ__ListPrice__c != oldQuoteLineMap.get(qLine.Id).SBQQ__ListPrice__c
                    && qLine.Price_Override_Reason__c == null)
                    {
                        //Add Error for Price Validation
                        qLine.addError('When Price is Overridden, Price Override Reason must be provided.');
                    }
                }
            }
        }
    }
    
    //TCS-pkulkarn-SDT-32740-25-09-2024-Commented following method
    /*public static void trackClassificationFieldChanges(List<SBQQ__QuoteLine__c> newQuoteLineList, Map<Id,SBQQ__QuoteLine__c> oldQuoteLineMap){
        for(SBQQ__QuoteLine__c newQline: newQuoteLineList){
            //if(newQline.SBQQ__RequiredBy__c == null && newQline.SBQQ__Quote__c!=null){//logic for parent quote line
                if(newQline.SBQQ__Quote__c!=null){
                set<string> typeOfChangeSet = (!String.isBlank(oldQuoteLineMap.get(newQline.Id).Type_of_Change__c)) ? strToset(oldQuoteLineMap.get(newQline.Id).Type_of_Change__c, ';') : (new set<string>());
                //handle LocationPositionName__c change
                if((!String.isBlank(oldQuoteLineMap.get(newQline.Id).LocationPositionName__c)) && newQline.LocationPositionName__c != oldQuoteLineMap.get(newQline.Id).LocationPositionName__c){
                    typeOfChangeSet.add('Position Change');
                }
                //handle ClientGLAccount__c change
                if((!String.isBlank(oldQuoteLineMap.get(newQline.Id).ClientGLAccount__c)) && newQline.ClientGLAccount__c != oldQuoteLineMap.get(newQline.Id).ClientGLAccount__c){
                    typeOfChangeSet.add('Billing Administration Change');
                }
                //handle ClientCostCenter__c change
                if((!String.isBlank(oldQuoteLineMap.get(newQline.Id).ClientCostCenter__c)) && newQline.ClientCostCenter__c != oldQuoteLineMap.get(newQline.Id).ClientCostCenter__c){
                    typeOfChangeSet.add('Billing Administration Change');
                }
                //handle CompanyCategoryCode__c change
                if((!String.isBlank(oldQuoteLineMap.get(newQline.Id).CompanyCategoryCode__c)) && newQline.CompanyCategoryCode__c != oldQuoteLineMap.get(newQline.Id).CompanyCategoryCode__c){
                    typeOfChangeSet.add('Billing Administration Change');
                }
                //handle SBQQ__StartDate__c change
                if(oldQuoteLineMap.get(newQline.Id).SBQQ__StartDate__c!=null  && newQline.SBQQ__StartDate__c != oldQuoteLineMap.get(newQline.Id).SBQQ__StartDate__c){
                    typeOfChangeSet.add('Start Date Change');
                }
                //handle SBQQ__EndDate__c change
                if(oldQuoteLineMap.get(newQline.Id).SBQQ__EndDate__c!=null && newQline.SBQQ__EndDate__c != oldQuoteLineMap.get(newQline.Id).SBQQ__EndDate__c){
                    typeOfChangeSet.add('End Date Change');
                }
                //handle sCode__c change
                if((!String.isBlank(oldQuoteLineMap.get(newQline.Id).sCode__c)) && newQline.sCode__c != oldQuoteLineMap.get(newQline.Id).sCode__c){
                    typeOfChangeSet.add('Market Restriction Change');
                }
                //handle Equipment_Style__c change
                if((!String.isBlank(oldQuoteLineMap.get(newQline.Id).Equipment_Style__c)) && newQline.Equipment_Style__c != oldQuoteLineMap.get(newQline.Id).Equipment_Style__c){
                    typeOfChangeSet.add('Equipment Change');
                }
                //handle Service_Style__c change
                if((!String.isBlank(oldQuoteLineMap.get(newQline.Id).Service_Style__c)) && newQline.Service_Style__c != oldQuoteLineMap.get(newQline.Id).Service_Style__c){
                    typeOfChangeSet.add('Equipment Change');
                }
                //handle Ownership__c change
                if((!String.isBlank(oldQuoteLineMap.get(newQline.Id).Ownership__c)) && newQline.Ownership__c != oldQuoteLineMap.get(newQline.Id).Ownership__c){
                    typeOfChangeSet.add('Ownership Change');
                }
                //handle VCRCode__c change
                if((!String.isBlank(oldQuoteLineMap.get(newQline.Id).VCRCode__c)) && newQline.VCRCode__c != oldQuoteLineMap.get(newQline.Id).VCRCode__c){
                    typeOfChangeSet.add('MAS Change');
                }
                //handle MASLibrary__c change
                if((!String.isBlank(oldQuoteLineMap.get(newQline.Id).MASLibrary__c)) && newQline.MASLibrary__c != oldQuoteLineMap.get(newQline.Id).MASLibrary__c){
                    typeOfChangeSet.add('MAS Change');
                }
                //handle MASCompany__c change
                if((!String.isBlank(oldQuoteLineMap.get(newQline.Id).MASCompany__c)) && newQline.MASCompany__c != oldQuoteLineMap.get(newQline.Id).MASCompany__c){
                    typeOfChangeSet.add('MAS Change');
                }
                //handle MASAccount__c change
                if((!String.isBlank(string.valueOf(oldQuoteLineMap.get(newQline.Id).MASAccount__c))) && newQline.MASAccount__c != oldQuoteLineMap.get(newQline.Id).MASAccount__c){
                    typeOfChangeSet.add('MAS Change');
                }
                //handle MASCustomerUniqueId__c change
                if((!String.isBlank(string.valueOf(oldQuoteLineMap.get(newQline.Id).MASCustomerUniqueId__c))) && newQline.MASCustomerUniqueId__c != oldQuoteLineMap.get(newQline.Id).MASCustomerUniqueId__c){
                    typeOfChangeSet.add('MAS Change');
                }
                //handle MASServiceLine__c change
                if((!String.isBlank(string.valueOf(oldQuoteLineMap.get(newQline.Id).MASServiceLine__c))) && newQline.MASServiceLine__c != oldQuoteLineMap.get(newQline.Id).MASServiceLine__c){
                    typeOfChangeSet.add('MAS Change');
                }
                //handle SBQQ__Quantity__c change
                if((!String.isBlank(string.valueOf(oldQuoteLineMap.get(newQline.Id).SBQQ__Quantity__c))) && newQline.SBQQ__Quantity__c != oldQuoteLineMap.get(newQline.Id).SBQQ__Quantity__c){
                    typeOfChangeSet.add('Change Quantity');
                }
                //handle Equipment_Size__c change
                if((!String.isBlank(oldQuoteLineMap.get(newQline.Id).Equipment_Size__c)) && newQline.Equipment_Size__c != oldQuoteLineMap.get(newQline.Id).Equipment_Size__c){
                    typeOfChangeSet.add('Change Size');
                }
                //handle Occurrence_Type__c change
                if((!String.isBlank(oldQuoteLineMap.get(newQline.Id).Occurrence_Type__c)) && newQline.Occurrence_Type__c != oldQuoteLineMap.get(newQline.Id).Occurrence_Type__c){
                    typeOfChangeSet.add('Change Schedule Type');
                }
                //handle Schedule_Frequency__c change
                if((!String.isBlank(oldQuoteLineMap.get(newQline.Id).Schedule_Frequency__c)) && newQline.Schedule_Frequency__c != oldQuoteLineMap.get(newQline.Id).Schedule_Frequency__c){
                    typeOfChangeSet.add('Change Frequency');
                }
                //handle Frequency_Interval__c change
                if((!String.isBlank(oldQuoteLineMap.get(newQline.Id).Frequency_Interval__c)) && newQline.Frequency_Interval__c != oldQuoteLineMap.get(newQline.Id).Frequency_Interval__c){
                    typeOfChangeSet.add('Change Frequency');
                }
                //handle Service_Days__c change
                if((!String.isBlank(oldQuoteLineMap.get(newQline.Id).Service_Days__c)) && newQline.Service_Days__c != oldQuoteLineMap.get(newQline.Id).Service_Days__c){
                    typeOfChangeSet.add('Change Frequency');
                }
                //handle Vendor__c change
                if((!String.isBlank(oldQuoteLineMap.get(newQline.Id).Vendor__c)) && newQline.Vendor__c != oldQuoteLineMap.get(newQline.Id).Vendor__c){
                    typeOfChangeSet.add('Change Vendor');
                }
                if((!String.isBlank(string.valueOf(oldQuoteLineMap.get(newQline.Id).SBQQ__ListPrice__c))) && newQline.SBQQ__ListPrice__c != oldQuoteLineMap.get(newQline.Id).SBQQ__ListPrice__c){
                    if(newQline.SBQQ__ListPrice__c > oldQuoteLineMap.get(newQline.Id).SBQQ__ListPrice__c){
                     	typeOfChangeSet.add('Price Increase');
                        typeOfChangeSet.remove('Price Decrease');
                    }else{
                        typeOfChangeSet.add('Price Decrease');
                        typeOfChangeSet.remove('Price Increase');
                    }
                }
                if((!String.isBlank(string.valueOf(oldQuoteLineMap.get(newQline.Id).SBQQ__UnitCost__c))) && newQline.SBQQ__UnitCost__c != oldQuoteLineMap.get(newQline.Id).SBQQ__UnitCost__c){
                    if(newQline.SBQQ__UnitCost__c > oldQuoteLineMap.get(newQline.Id).SBQQ__UnitCost__c){
                     	typeOfChangeSet.add('Cost Increase');
                        typeOfChangeSet.remove('Cost Decrease');
                    }else{
                        typeOfChangeSet.add('Cost Decrease');
                        typeOfChangeSet.remove('Cost Increase');
                    }
                }
                if(typeOfChangeSet.size()>0){
                    string typeOfChangeStr = setToStr(typeOfChangeSet,';');
                    if(typeOfChangeStr!=oldQuoteLineMap.get(newQline.Id).Type_of_Change__c){
                        newQline.Type_of_Change__c = typeOfChangeStr;
                    }
                }
            }
        }
    }*/
    public static set<string> strToset(string str, string splitByChar){
        List<string> fList = str.split(splitByChar);
        set<string> fSet = new set<string>();
        fset.addAll(fList);
        return fset;
    }
    public static string setToStr(set<string> setStr, string splitByChar){
        string fStr = '';
        for(string str: setStr){
            if(fStr == ''){
                fStr = str;
            }else{
             	fStr = fStr+splitByChar+str;
            }
        }
        return fStr;
    }
    /*SDT-24736 Classification Changes
    Author : Yeshas Konduru*/

    public static void assignInitialClassificationChanges(List<SBQQ__QuoteLine__c> quoteLineNewList){
        set<id> accIdSet = new set<id>();
        set<id> productIdSet = new set<id>();
        for(SBQQ__QuoteLine__c qLine : quoteLineNewList){
	        //SDT-30892 and SDT-30893 - Added condition qLine.AssetId__c != null
            if(qLine.AssetId__c != null) {
                if(qLine.Account__c != null)
                    accIdSet.add(qLine.Account__c);
                if(qLine.Vendor__c != null)
                    accIdSet.add(qLine.Vendor__c);
                if(qLine.SBQQ__Product__c != null)
                    productIdSet.add(qLine.SBQQ__Product__c);
	        }
        }
        map<id,Account> accountIdAccountMap = new map<id,Account>([SELECT id, Name FROM Account WHERE id IN:accIdSet]);
        map<id,Product2> productIdProductMap = new map<id,Product2>([SELECT id, Name, Family FROM Product2 WHERE id IN:productIdSet]);
        for(SBQQ__QuoteLine__c qLine : quoteLineNewList){
            //pkulkarn-TCS-19-5-2023-Changes for SDT-31009, SDT-30892 and SDT-30893
            //SDT-31009 - removed the condition !nonICCServiceTypes.contains(productIdProductMap.get(qLine.SBQQ__Product__c).Name)
            //SDT-30892 and SDT-30893 - Added condition qLine.AssetId__c != null
            if(qLine.SBQQ__Product__c!=null && qLine.AssetId__c != null) {
                qLine.Initial_Classification_Changes__c = frameICCqLine(qLine,accountIdAccountMap,productIdProductMap);   
            }
        }
    }
    public static string frameICCqLine(SBQQ__QuoteLine__c pqLine,map<id,Account> accountIdAccountMap,map<id,Product2> productIdProductMap){
        ICCqLineWrap iccqLine = new ICCqLineWrap();
        String strMaterialCategory = Constant_Util.EMPTY_STRING;//Added for solution related to SDT-28899
        iccqLine.quantity = (!String.isBlank(string.valueOf(pqLine.SBQQ__Quantity__c))) ? string.valueOf(pqLine.SBQQ__Quantity__c) : '';
        iccqLine.equipmentSize = (!String.isBlank(string.valueOf(pqLine.Equipment_Size__c))) ? string.valueOf(pqLine.Equipment_Size__c) : '';
        iccqLine.equipmentType = (pqLine.SBQQ__Product__c!=null) ? productIdProductMap.get(pqLine.SBQQ__Product__c).Name : '';
        iccqLine.wasteStream = (pqLine.SBQQ__Product__c!=null) ? productIdProductMap.get(pqLine.SBQQ__Product__c).Family : '';
        iccqLine.wasteStreamMaterialType = strMaterialCategory;//Added new wasteStreamMaterialType mapping for SDT-28899
        iccqLine.companyCategory = (!String.isBlank(pqLine.CompanyCategoryName__c)) ? pqLine.CompanyCategoryName__c : '';
        iccqLine.locationPosition = (pqLine.Account__c !=null) ? accountIdAccountMap.get(pqLine.Account__c).Name : '';
        iccqLine.locationPositionName = (pqLine.LocationPositionName__c !=null) ? pqLine.LocationPositionName__c : '';//Added LocationPositionName as a new field as a solution for SDt-28900
        iccqLine.sCode = (!String.isBlank(pqLine.sCode__c)) ? pqLine.sCode__c : '';
        iccqLine.service = (pqLine.SBQQ__Product__c!=null) ? productIdProductMap.get(pqLine.SBQQ__Product__c).Name : '';
        iccqLine.schedule = calculateScheduleField(pqLine);
        //SDT 41407,SDT 41655
        iccqLine.monthlyScheduleDetails = QuoteLineServices.generateMonthlyScheduleDetails(pqLine);
        iccqLine.cost = (!String.isBlank(string.valueOf(pqLine.SBQQ__UnitCost__c))) ? string.valueOf(pqLine.SBQQ__UnitCost__c) : '';
        iccqLine.price = (!String.isBlank(string.valueOf(pqLine.SBQQ__ListPrice__c))) ? string.valueOf(pqLine.SBQQ__ListPrice__c) : '';
        iccqLine.startDate = (!String.isBlank(string.valueOf(pqLine.SBQQ__StartDate__c))) ? string.valueOf(pqLine.SBQQ__StartDate__c) : '';
        iccqLine.endDate = (!String.isBlank(string.valueOf(pqLine.SBQQ__EndDate__c))) ? string.valueOf(pqLine.SBQQ__EndDate__c) : '';
        iccqLine.vendor = (pqLine.Vendor__c!=null) ? accountIdAccountMap.get(pqLine.Vendor__c).Name : '';
        iccqLine.productId = (pqLine.SBQQ__Product__c!=null) ? pqLine.SBQQ__Product__c : '';
        //TCS-SDT-32165-Added following fields
        iccqLine.cUnitOfMeasurement = (pqLine.Cost_Unit_of_Measure__c!=null) ? UTIL_Picklist.getPickListLabelByAPIValue('SBQQ__QuoteLine__c', 'Cost_Unit_of_Measure__c', pqLine.Cost_Unit_of_Measure__c) : '';
        iccqLine.pUnitOfMeasurement = (pqLine.PriceUOM__c!=null) ? UTIL_Picklist.getPickListLabelByAPIValue('SBQQ__QuoteLine__c', 'PriceUOM__c', pqLine.PriceUOM__c) : '';
        //SDT38111
        iccqLine.cMinimumQuantity = (pqLine.CostMinQuantity__c != null) ? string.valueOf(pqLine.CostMinQuantity__c.setScale(2)) : '';
        iccqLine.pMinimumQuantity = (pqLine.PriceMinQuantity__c != null) ? string.valueOf(pqLine.PriceMinQuantity__c.setScale(2)) : '';
        iccqLine.pricingMethod = (pqLine.SBQQ__PricingMethod__c != null) ? UTIL_Picklist.getPickListLabelByAPIValue('SBQQ__QuoteLine__c', 'SBQQ__PricingMethod__c', pqLine.SBQQ__PricingMethod__c) : '';
        iccqLine.costModelType = (pqLine.CostModelType__c != null) ? UTIL_Picklist.getPickListLabelByAPIValue('SBQQ__QuoteLine__c', 'CostModelType__c', pqLine.CostModelType__c): '';
        iccqLine.costUpTo1 = (pqLine.CostUpTo1__c != null) ? string.valueOf(pqLine.CostUpTo1__c) : '';
        iccqLine.costUpTo2 = (pqLine.CostUpTo2__c != null) ? string.valueOf(pqLine.CostUpTo2__c) : '';
        iccqLine.costUpTo3 = (pqLine.CostUpTo3__c != null) ? string.valueOf(pqLine.CostUpTo3__c) : '';
        iccqLine.costUpTo4 = (pqLine.CostUpTo4__c != null) ? string.valueOf(pqLine.CostUpTo4__c) : '';
        iccqLine.steppedCost1 = (pqLine.CostPrice1__c != null) ? string.valueOf(pqLine.CostPrice1__c) : '';
        iccqLine.steppedCost2 = (pqLine.CostPrice2__c != null) ? string.valueOf(pqLine.CostPrice2__c) : '';
        iccqLine.steppedCost3 = (pqLine.CostPrice3__c != null) ? string.valueOf(pqLine.CostPrice3__c) : '';
        iccqLine.steppedCost4 = (pqLine.CostPrice4__c != null) ? string.valueOf(pqLine.CostPrice4__c) : '';
        iccqLine.priceUpTo1 = (pqLine.PriceUpTo1__c != null) ? string.valueOf(pqLine.PriceUpTo1__c) : '';
        iccqLine.priceUpTo2 = (pqLine.PriceUpTo2__c != null) ? string.valueOf(pqLine.PriceUpTo2__c) : '';
        iccqLine.priceUpTo3 = (pqLine.PriceUpTo3__c != null) ? string.valueOf(pqLine.PriceUpTo3__c) : '';
        iccqLine.priceUpTo4 = (pqLine.PriceUpTo4__c != null) ? string.valueOf(pqLine.PriceUpTo4__c) : '';
        iccqLine.steppedPrice1 = (pqLine.PricePrice1__c != null) ? string.valueOf(pqLine.PricePrice1__c) : '';
        iccqLine.steppedPrice2 = (pqLine.PricePrice2__c != null) ? string.valueOf(pqLine.PricePrice2__c) : '';
        iccqLine.steppedPrice3 = (pqLine.PricePrice3__c != null) ? string.valueOf(pqLine.PricePrice3__c) : '';
        iccqLine.steppedPrice4 = (pqLine.PricePrice4__c != null) ? string.valueOf(pqLine.PricePrice4__c) : '';
        //TCS-SDT-32165-Added following fields
        return JSON.serialize(iccqLine);
    }
    
    /*Method Name : getDateTimeInGMTForGivenDateTime
     * Description : The method to convert datetime value from any given timezone to GMT for processing Pricing logic in ACORN.
     * JIRA ID : SDT 29615
     */ 
    public static DateTime getDateTimeInGMTForGivenDateTime(DateTime objGivenDT){
        DateTime objDateTimeGMT;
        if(objGivenDT!=null)
        {
            objDateTimeGMT = DateTime.newInstanceGMT(objGivenDT.yearGMT(),objGivenDT.monthGMT(),objGivenDT.dayGMT(),12, 00, 00);
        }
        return objDateTimeGMT;
    }
    
    /*Method Name : setDateTimeInGMTForGivenQLDateTime
     * Description : The method to convert datetime value from any given timezone to GMT from QuoteLine Trigger.
     * JIRA ID : SDT 29615
     */ 
    public static void setDateTimeInGMTForGivenQLDateTime(List<SBQQ__QuoteLine__c> lstQuoteLine){
        List<SBQQ__QuoteLine__c> lstUpdatedQL = new List<SBQQ__QuoteLine__c>();
        for(SBQQ__QuoteLine__c objCurrQL : lstQuoteLine)
        {
            if(objCurrQL.Exception_Effective_Date__c!=null)
            {
                System.debug('Before=='+objCurrQL.Exception_Effective_Date__c);
                objCurrQL.Exception_Effective_Date__c = getDateTimeInGMTForGivenDateTime(objCurrQL.Exception_Effective_Date__c);
                System.debug('After=='+objCurrQL.Exception_Effective_Date__c);
            }
            //sdhikale TCS SDT-29806
            if(objCurrQL.Exceptions_Effective_Date__c!=null)
            {
                objCurrQL.Exceptions_Effective_Date__c = objCurrQL.Exceptions_Effective_Date__c;
            }
        }
    }
    
    public static string calculateScheduleField(SBQQ__QuoteLine__c qLine){
        string str = '';
        if(qLine.Occurrence_Type__c=='OC'){
            str='On-Call';
        }else{
            str = 'E';
            if(!string.isEmpty(qLine.Frequency_Interval__c)){
                str=str+qLine.Frequency_Interval__c;
            }
            if(!string.isEmpty(qLine.Schedule_Frequency__c)){
                str=str+qLine.Schedule_Frequency__c;
            }
            if(qLine.Schedule_Frequency__c=='W'){
                str=str+'(';
                List<string> daysList = (!string.isEmpty(qLine.Service_Days__c)) ? qLine.Service_Days__c.split(';') : new List<string>();
                if(daysList.contains('S1')){
                    str = str+'Su';
                }
                if(daysList.contains('M')){
                    str = str+'M';
                }
                if(daysList.contains('T')){
                    str = str+'T';
                }
                if(daysList.contains('W')){
                    str = str+'W';
                }
                if(daysList.contains('T1')){
                    str = str+'R';
                }
                if(daysList.contains('F')){
                    str = str+'F';
                }
                if(daysList.contains('S')){
                    str = str+'Sa';
                }
                str=str+')'+' - '+qLine.Final_Frequency__c+'x';
            }
        }
        system.debug('str==>'+str);
        return str;
    }
    
    //pkulkarn-TCS-06-Jul-2023-Added below function for SDT-31055
    static void setExceptionReasonForNewQuoteLine(SBQQ__QuoteLine__c quoteLine, String caseRecordType) {
    	if(checkIfNewQuoteLine(quoteLine) && caseRecordType != Constant_Util.R_NEW_SERVICE_CASE)
    		quoteLine.Exception_Reason__c = Constant_Util.EXCEPTION_REASON_SERVICE_CHANGE;
	}
    //pkulkarn-TCS-06-Jul-2023-Added below function for SDT-31055
    static Boolean checkIfNewQuoteLine(SBQQ__QuoteLine__c quoteLine) {
    	return (quoteLine.AssetId__c == null ? true : false);	//Check if New Quote line added, indicated by AssetId__c == NULL
	}
    
    public class ICCqLineWrap{
        public string quantity;
        public string equipmentSize;
        public string equipmentType;
        public string wasteStream;
        public string wasteStreamMaterialType;//Added LocationPositionName as a new field as a solution for SDt-28899
        public string companyCategory;
        public string locationPosition;
        public string locationPositionName;//Added LocationPositionName as a new field as a solution for SDt-28900
        public string sCode;
        public string service;
        public string schedule;
        //SDT 41407,SDT 41655
        public string monthlyScheduleDetails;
        public string cost;
        public string price;
        public string startDate;
        public string endDate;
        public string vendor;
        public string productId;
        //TCS-SDT-32165-Added following members
        public string cUnitOfMeasurement;
        public string pUnitOfMeasurement;
        public string cMinimumQuantity;
        public string pMinimumQuantity;
        public string pricingMethod;
        public string costModelType;
        public string costUpTo1;
        public string costUpTo2;
        public string costUpTo3;
        public string costUpTo4;
        public string steppedCost1;
        public string steppedCost2;
        public string steppedCost3;
        public string steppedCost4;
        public string priceUpTo1;
        public string priceUpTo2;
        public string priceUpTo3;
        public string priceUpTo4;
        public string steppedPrice1;
        public string steppedPrice2;
        public string steppedPrice3;
        public string steppedPrice4;
        //TCS-SDT-32165-Added following members
    }

// Update CC on Case
    public static void updateCCOnCase(List<SBQQ__QuoteLine__c> newQuoteLineList, Map<Id,SBQQ__QuoteLine__c> oldQuoteLineMap){
        Map<String,String> mapCC = new Map<String,String>();
        Map<String,String> mapCCode = new Map<String,String>();
        for(SBQQ__QuoteLine__c newQline: [Select Id,SBQQ__Quote__r.SBQQ__Status__c,SBQQ__Quote__r.Case_Number__c,CompanyCategoryName__c,CompanyCategoryCode__c from SBQQ__QuoteLine__c WHERE ID IN : newQuoteLineList]){
            system.debug('oldQuoteLineMap : ' + oldQuoteLineMap);
            system.debug('newQline : ' + newQline);
            system.debug('new Qline CC : ' + newQline.CompanyCategoryName__c);
            system.debug('Old Q CC : ' + oldQuoteLineMap.get(newQline.Id).CompanyCategoryName__c);
            system.debug('newQline ID : ' + newQline.Id);
            system.debug('newQline ST : ' + newQline.SBQQ__Quote__r.SBQQ__Status__c);
            system.debug('newQline CN : ' + newQline.SBQQ__Quote__r.Case_Number__c);
            if(oldQuoteLineMap == null && (newQline.SBQQ__Quote__r.SBQQ__Status__c == 'Draft' || newQline.SBQQ__Quote__r.SBQQ__Status__c == 'Product Configured') ){
                mapCC.put(newQline.SBQQ__Quote__r.Case_Number__c,newQline.CompanyCategoryName__c);
                mapCCode.put(newQline.SBQQ__Quote__r.Case_Number__c,newQline.CompanyCategoryCode__c);
            }else if(oldQuoteLineMap != null && (newQline.SBQQ__Quote__r.SBQQ__Status__c == 'Draft' || newQline.SBQQ__Quote__r.SBQQ__Status__c == 'Product Configured') 
                   /* && newQline.CompanyCategoryName__c != oldQuoteLineMap.get(newQline.Id).CompanyCategoryName__c */ ){
                        system.debug('Old Quote and newQline : ' + newQline);
                mapCC.put(newQline.SBQQ__Quote__r.Case_Number__c,newQline.CompanyCategoryName__c);
                mapCCode.put(newQline.SBQQ__Quote__r.Case_Number__c,newQline.CompanyCategoryCode__c);
            } 
        }System.debug('mapCC : ' + mapCC  );
        if(!mapCC.isEmpty()){
            List<Case> updateCase = new List<Case>();
            for(Case cs : [Select Id,CaseNumber,Company_Category__c,CompanyCategoryCode__c from Case WHERE CaseNumber IN : mapCC.KeySet()]){
                if(mapCC.containsKey(cs.CaseNumber) && mapCC.get(cs.CaseNumber)!=null && mapCCode.get(cs.CaseNumber)!=null && cs.Company_Category__c != mapCC.get(cs.CaseNumber)){
                    System.debug('inside Case Loop : ' + mapCC  );
                    cs.Company_Category__c = mapCC.get(cs.CaseNumber);
                    cs.CompanyCategoryCode__c = mapCCode.get(cs.CaseNumber);
                    updateCase.add(cs); 
                }
            }System.debug('updateCase : ' + updateCase  );
            if(!updateCase.isEmpty()){
                update updateCase;
            }
        }
    }
    public static void updateEndDateforAdditionalServices(List<SBQQ__QuoteLine__c> newQuoteLineList,Map<Id,SBQQ__QuoteLine__c> oldQuoteLineMap){    
        List<Id> newQuoteLineIdList = new List<Id>();
        List<SBQQ__QuoteLine__c> lstStartDateUpdatedQuoteLines = new List<SBQQ__QuoteLine__c>();
        for(SBQQ__QuoteLine__c newQline: newQuoteLineList){
		//As part of SDT 32111 adding check newQline.AssetId__c==null
            if(newQline.SBQQ__StartDate__c !=null && newQline.AssetId__c==null){
                newQuoteLineIdList.add(newQline.Id);
            }
        }
        lstStartDateUpdatedQuoteLines = QuoteLineSelector.getquoteLinesToUpdateEndDate(newQuoteLineIdList);
        if(lstStartDateUpdatedQuoteLines.size()>0){
            QuoteLineServices.populateEndDateForAdditionalServices(lstStartDateUpdatedQuoteLines);
        }
    }
			/*
	* @vendor            TCS
	* @story             SDT31782
	* @author            Seema Dhikale
	* @description       This method is used to set default values on quoteLines for SBQQ__BundledQuantity__c as 1 so then it wont get multiplied by itself. Applicable for all case record types 
	* @param             Quoteline being inserted
	* @return            Void
	*/	
	public static void updateBundledQuantity(List<SBQQ__QuoteLine__c> lstQuoteLine){
            for(SBQQ__QuoteLine__c objCurrQL : lstQuoteLine)
            {
			if(objCurrQL.SBQQ__RequiredBy__c!=null && objCurrQL.Product_Option_Type__c == Constant_Util.PRODUCT_OPTION_TYPE_COMPONENT){ //TCS-pkulkarn-22-Sep-23-Added Option Type check 
               objCurrQL.SBQQ__BundledQuantity__c = 1;  
				}				   
            }
        }
        /*Method Name  : CompareQlsizewithAssetsize
		 * Description : This method prevents update of the quoteline records with equipment size "unknown" or "UNK" to 
		 * 				 anyother size such as "YRD-40"..etc.
		 * Jira ID     : SDT-32075
			*/ 
            public static void CompareQlsizewithAssetsize(List<SBQQ__QuoteLine__c> newQuoteLineList, Map<Id,SBQQ__QuoteLine__c> oldQuoteLineMap){
                Set<Id> assetIdsToUpdate = new Set<Id>();
                Set<String>setEmptyequipSize;
                for (SBQQ__QuoteLine__c ql : newQuoteLineList) {         
                    SBQQ__QuoteLine__c oldQuoteLine = oldQuoteLineMap.get(ql.Id);
                    
                   //Quotelines which is having equipment size as "UNK" or "Unknown" is filtered.
                    String emptyEquipmentSize = system.label.EmptyEquipmentSize;
                    setEmptyequipSize = new set<String>(emptyEquipmentSize.split(','));
                    if (setEmptyequipSize.contains(oldQuoteLine.Equipment_Size__c)) {
                           assetIdsToUpdate.add(ql.AssetId__c);    
                    }
                    
                }
                if (!assetIdsToUpdate.isEmpty()) {
                    Map<Id,Asset> assetsToUpdate = new Map<Id,Asset>([SELECT Id, Equipment_Size__c FROM Asset WHERE Id IN :assetIdsToUpdate AND Equipment_Size__c IN :setEmptyequipSize]);
                    for (SBQQ__QuoteLine__c ql : newQuoteLineList) {
                        //added as part of SDT-32927
                        if(assetsToUpdate.keySet().contains(ql.AssetId__c)) {
                            string assetEquipmentSize = assetsToUpdate.get(ql.AssetId__c).Equipment_Size__c;
                            ql.Equipment_Size__c = QuoteProcurementController.getPicklistAPIName(assetEquipmentSize);
                        }
                    }
                }
            }
	
	
	/**************************************************
* Created By:Rajan Sajani
*
* Story: SDT-36179
* To delete quote line history tracking record
* **************************************************/
     public static void deleteQuoteLineHistoryRec(List<SBQQ__QuoteLine__c> newQouteLineList){
        
        List<SBQQ__QuoteLine__c> quotelineListQuote = new List<SBQQ__QuoteLine__c>();
        quotelineListQuote = [Select id,Name,SBQQ__Quote__c,LastModifiedById,LastModifiedBy.Name,LastModifiedDate,SBQQ__Quote__r.Name,SBQQ__Quote__r.SBQQ__Status__c,SBQQ__Product__r.Name from SBQQ__QuoteLine__c where Id IN : newQouteLineList and SBQQ__Quote__r.SBQQ__Status__c IN ('Product Configured','Cost Configured')];
        if(quotelineListQuote.size()>0){
			//String QuoteName = quotelineListQuote[0].SBQQ__Quote__r.Name;
			//String QuoteID = quotelineListQuote[0].SBQQ__Quote__c;
			List<Quote_Line_History_Tracking__c> deletedQuoteLineList = new List<Quote_Line_History_Tracking__c>();
			 
			for (SBQQ__QuoteLine__c  oldLine : quotelineListQuote) {
				
			   Quote_Line_History_Tracking__c history = new Quote_Line_History_Tracking__c(
				   Action__c = 'Deleted',
				   Quote_Line__c = oldLine.Id,
				   Quote_Line_Number__c = oldLine.Name,
				   Quote_Number__c = oldLine.SBQQ__Quote__r.Name,
				   Quote_Id__c= oldLine.SBQQ__Quote__c,
				   Product_Name__c = oldLine.SBQQ__Product__r.Name,
				   User_Name__c = oldLine.LastModifiedBy.Name
				   //Timestamp__c = oldLine.LastModifiedDate
				  
			   );
			   deletedQuoteLineList.add(history);
		   }
		   if(deletedQuoteLineList.size()>0){
				Insert deletedQuoteLineList;
		   }
		   
        }
       
    }
    		
/*
	* @vendor            TCS
	* @story             SDT-38011
	* @author            Seema Dhikale
	* @description       This method is used to copy Exceptions_Effective_Date__c to Exceptions_Effective_Date__c for quoteLine 
	* @called from       Before insert and before update of quoteline. 
	* @return            NA
	*/ 
    public static void setExceptionEffectiveDate(List<SBQQ__QuoteLine__c > quoteLineNewList){
        ExceptionDetailsServices.copyExceptionEffectiveDateToExceptionsEffectiveDate(quoteLineNewList);
    } 

/*Method Name  : nullifyUOMforScheduledPickup
* Description : When occurence type changes from On call to schedule, 
					current system - keeping PriceUOM__c or/and Cost_Unit_of_Measure__c as Event even if event is not correct UOM for Scheduled services. This results in acorn integration error
					tobe system - will nullify PriceUOM__c or/and Cost_Unit_of_Measure__c 
* Jira ID     : SDT-40078
*/ 
public static void nullifyUOMforScheduledPickup(List<SBQQ__QuoteLine__c> newQuoteLineList, Map<Id,SBQQ__QuoteLine__c> oldQuoteLineMap){
    for (SBQQ__QuoteLine__c ql : newQuoteLineList) {         
        SBQQ__QuoteLine__c oldQuoteLine = oldQuoteLineMap.get(ql.Id);
        if(oldQuoteLine!=null){
        if(ql.SBQQ__Quote__r.SBQQ__Type__c != Constant_Util.QUOTE && 
           ql.Occurrence_Type__c!=null && ql.Occurrence_Type__c.equalsIgnoreCase(SCHEDULED_TYPE) &&
           oldQuoteLine.Occurrence_Type__c!=null && !oldQuoteLine.Occurrence_Type__c.equalsIgnoreCase(OCCURENCE_TYPE_ONCALL)){
               if(ql.PriceUOM__c!=null && ql.PriceUOM__c.equalsIgnoreCase(EOM_EVENT)){
                   ql.PriceUOM__c = Constant_Util.EMPTY_STRING;
               }
               if(ql.Cost_Unit_of_Measure__c!=null && ql.Cost_Unit_of_Measure__c.equalsIgnoreCase(EOM_EVENT)){
                   ql.Cost_Unit_of_Measure__c=Constant_Util.EMPTY_STRING;
               }
           }
        }
    }
}
   
    /*
    * @vendor            TCS
    * @story             SDT-38052
    * @author            Digdershika Ojha
    * @description       This method is used to Set Service Action field value in all existing services and newly added service to Do Not Extend by default
    * @called from       Before insert and before update of quoteline. 
    * @return            NA
    */ 
    public static void setDoNotExtendService(List<SBQQ__QuoteLine__c> quoteLineNewList){
        Set<Id> quoteIds = new Set<Id>();
        Map<Id,List<SBQQ__QuoteLine__c>> mapQuoteAndBundleQL = new  Map<Id,List<SBQQ__QuoteLine__c>>();
        List<SBQQ__QuoteLine__c> qlLines = new List<SBQQ__QuoteLine__c>();
       		
        for(SBQQ__QuoteLine__c qouteLine : quoteLineNewList){
            quoteIds.add(qouteLine.SBQQ__Quote__c);            
        }
        if(!quoteIds.isEmpty()){
            qlLines =  QuoteLineSelector.getQuoteLinesToUpdateServiceAction(quoteIds);            
        }
                      
       for(SBQQ__QuoteLine__c ql: qlLines){
           
                        if(mapQuoteAndBundleQL.containsKey(ql.SBQQ__Quote__c))
                        {
                            List<SBQQ__QuoteLine__c> quotelinelst = mapQuoteAndBundleQL.get(ql.SBQQ__Quote__c);
                            quotelinelst.add(ql);
                            mapQuoteAndBundleQL.put(ql.SBQQ__Quote__c,quotelinelst);
                        }
                        else{
                            mapQuoteAndBundleQL.put(ql.SBQQ__Quote__c,new List<SBQQ__QuoteLine__c>{ql});
                        }                
            }        
        
        for(SBQQ__QuoteLine__c quoteLines : quoteLineNewList){
            if(mapQuoteAndBundleQL.containsKey(quoteLines.SBQQ__Quote__c)){
                quoteLines.Service_Action__c = Constant_Util.SERVICE_ACTION_DO_NOT_EXTEND_SERVICE;
            }
        }
        
    }
    
	//SDT-33378
    public static void validateQLStartDate(List<SBQQ__QuoteLine__c> lstQuoteLine,Map<Id,SBQQ__QuoteLine__c> oldQuoteLineMap){
        
        map<Id,SBQQ__QuoteLine__c> tobeCheckedForStartDateChange = new  map<Id,SBQQ__QuoteLine__c>();
        map<Id,Date> mapdatetobeCheckedChange = new  map<Id,Date>();
        
        for(SBQQ__QuoteLine__c ql : lstQuoteLine)
        {
            system.debug('Startdatemanagement validateQLStartDate1>>');
            // not to run for Bundle only child- Check with FC ql.SBQQ__RequiredBy__c!=null &&
            if( oldQuoteLineMap.get(ql.Id) != null){
                system.debug('ql.SBQQ__RequiredBy__c>>'+ql.SBQQ__RequiredBy__c);
                SBQQ__QuoteLine__c oldQL = oldQuoteLineMap.get(ql.Id);
                
                // AssetId!=null for Add change scenario -- weak logic implemented, should broader.
                // 
                if(  ql.AssetId__c!=null && (ql.SBQQ__StartDate__c!=oldQL.SBQQ__StartDate__c ||
                                             ql.Vendor_Commit_Date__c!=oldQL.Vendor_Commit_Date__c) ){
                                                 system.debug('Startdatemanagement ql.SBQQ__StartDate__c>>'+ql.SBQQ__StartDate__c);
                                                 system.debug('Startdatemanagement oldQL.SBQQ__StartDate__c>>'+oldQL.SBQQ__StartDate__c);
                                                 tobeCheckedForStartDateChange.put(ql.Id,ql);                          
                                                 
						// If startdate change caused the QL trigger to run
						if(ql.SBQQ__StartDate__c!=oldQL.SBQQ__StartDate__c){
                                                     mapdatetobeCheckedChange.put(ql.Id,ql.SBQQ__StartDate__c );
                                                     
                                                 }else if(ql.Vendor_Commit_Date__c!=oldQL.Vendor_Commit_Date__c){ 
							// When vendor commit date caused the QL trigger to run
                                                     mapdatetobeCheckedChange.put(ql.Id,ql.Vendor_Commit_Date__c );
                                                 }
                                                 
                                                 
                                             }
            }
        }
        
        // run only when some QL have start dates changed
        if(!tobeCheckedForStartDateChange.isEmpty()){
            // query for AssetparentId for these quotelines.
            List<SBQQ__QuoteLine__c> qlList = [Select Id, SBQQ__StartDate__c,Vendor_Commit_Date__c, AssetId__r.ParentId, SBQQ__RequiredBy__c, AssetId__c 
                                               from SBQQ__QuoteLine__c where Id in:tobeCheckedForStartDateChange.keyset() 
                                              ];
            
            // Run only for QL which has changed
            for(SBQQ__QuoteLine__c qlTobeChecked : qlList){
                
                SBQQ__QuoteLine__c newql =tobeCheckedForStartDateChange.get(qlTobeChecked.Id);
                if(newql!=null){
                    system.debug('Startdatemanagement ql.SBQQ__StartDate__c>>'+newql.SBQQ__StartDate__c);
                    
                    StartDateManagement mananageStartDate = new StartDateManagement();
                    qlTobeChecked.SBQQ__StartDate__c = mapdatetobeCheckedChange.get(qlTobeChecked.Id) ;
                    Boolean isStartDateValid =  mananageStartDate.validateQuoteLineStartDate(qlTobeChecked);
                    if(!isStartDateValid){
                        system.debug('Startdatemanagement validtestdate2>>'+isStartDateValid);
                        // Add Error can be done only on Trigger Variable object not Sobject
                        //TCS-pkulkarn-SDT-41371-2-Sep-2024-Commented if condition for fixing Tech Debt
                        //if(!UserInfo.getName().equalsIgnoreCase('API User Only')){
			            newql.addError( StartDateManagement.InvalidStartDateErrorMessage) ;
		                //} 
                        
                    }
                    
                }
            }
            
        }
        
        
    }

    /*
     * @vendor           TCS
     * @story            //SDT 42214
     * @description       This method is used to update DoNotCreateTaskGridTickets__c,ByPassMASServiceChange__c and BypassPriceReview__c. 
     * @param             old quotelineMap, new Quoteline list
     * @return            Void
     */ 
    public static void updateCheckboxForBSVCRCode(List<SBQQ__QuoteLine__c> newQuoteLineList, Map<Id,SBQQ__QuoteLine__c> oldQuoteLineMap){
        for (SBQQ__QuoteLine__c ql : newQuoteLineList) {
            if(ql.VCRCode__c != oldQuoteLineMap.get(ql.Id).VCRCode__c && (ql.VCRCode__c == Constant_Util.VCR_CODE_BSI ||ql.VCRCode__c == Constant_Util.VCR_CODE_BSD)){
             	if(ql.BypassPriceReview__c) {
                 ql.BypassPriceReview__c = false;
            	}
            ql.DoNotCreateTaskGridTickets__c = true;
            ql.ByPassMASServiceChange__c = true;
            }
        }
    }

    /*
     * @vendor           TCS
     * @story            //SDT 41543, SDT 41968
     * @author           Seema Dhikale
     * @description       This method is used to set default values for haul away quoteLine. 
     * @param             Quoteline being updated and Parent Quote Name
     * @return            Void
     */ 
    public static void assignDefaultsToHaulAwayQL(List<SBQQ__QuoteLine__c> newQuoteLineList){
        for(SBQQ__QuoteLine__c quoteLineRecord : newQuoteLineList){
            HaulAwayService.assignDefaultsToHaulAwayQL(quoteLineRecord);
        }
    }
	/*
* @vendor           TCS
* @story            //SDT 40723
* @description       This method is used to close genesys and task record created for the quote as part of this story 
* @param             old quotelineMap, new Quoteline list, new quotelineMap
* @return            Void
*/ 
 public static void checkVendorCommitDateUpdate(List<SBQQ__QuoteLine__c> newQuoteLineList,Map<Id,SBQQ__QuoteLine__c> oldQuoteLineMap,Map<Id,SBQQ__QuoteLine__c> newQuoteLineMap,Map<Id,SBQQ__Quote__c> quoteMapRecieved)
    {   
        List<Task> TaskListToUpdate= new List<Task>();
        List<Genesys_Routing__c> GenesysListToInsert = new List<Genesys_Routing__c>();
        //List<Id> QuoteIdList = new List<Id>();
        //Map<Id, SBQQ__Quote__c> quoteMap= new Map<Id, SBQQ__Quote__c>();
        List<SBQQ__Quote__c> UpdateQuoteList = new List<SBQQ__Quote__c>();
        Boolean updateQuote = false;
        //Changes by jatan for INC
        Set<id> quoteIds = new set<Id>();
        Set<id> quoteIdsToUpdate = new set<Id>();
        Map<id,List<SBQQ__QuoteLine__c>> quoteQLMap = new Map<id,List<SBQQ__QuoteLine__c>>();

       
        for (SBQQ__QuoteLine__c quoteLine: newQuoteLineList)
        {
            if(oldQuoteLineMap.get(quoteLine.Id).Vendor_Commit_Date__c!=newQuoteLineMap.get(quoteLine.Id).Vendor_Commit_Date__c)
            {
                quoteIds.add(quoteLine.SBQQ__Quote__c);
            }
        }
        if(quoteIds!=null && quoteIds.size()> 0 )
        {
            List<SBQQ__QuoteLine__c> getAllBundles = [select id,SBQQ__RequiredBy__c,Vendor_Commit_Date__c,SBQQ__Quote__c,
            SBQQ__Quote__r.SBQQ__Status__c,SBQQ__Quote__r.RecordType.Name from SBQQ__QuoteLine__c 
            where SBQQ__RequiredBy__c = null AND SBQQ__Quote__c =:quoteIds ];

            for(SBQQ__QuoteLine__c ql : getAllBundles){
                ID key = ql.SBQQ__Quote__c;
                if (!quoteQLMap.containsKey(key)){
                        quoteQLMap.put(key, new List<SBQQ__QuoteLine__c>());
                    }
                    quoteQLMap.get(key).add(ql);
            }
            //END
            Id genesysRoutingRec = Schema.getGlobalDescribe().get(Constant_Util.Genesys_Routing).getDescribe().getRecordTypeInfosByDeveloperName().get(Constant_Util.OBJECT_TASK).getRecordTypeId();
            boolean vendorCommitDateSwitch = CodeSwitchUtility.getCodeSwitchOn('vendorCommitDateSwitch');
            if(!vendorCommitDateSwitch)
            {
                for(Id key : quoteQLMap.keySet()){
                    for (SBQQ__QuoteLine__c quoteLine: quoteQLMap.get(key))
                    {
                        if(
                            quoteLine.SBQQ__RequiredBy__c == null &&
                            quoteLine.Vendor_Commit_Date__c >= system.today() &&
                            quoteLine.SBQQ__Quote__r.SBQQ__Status__c != Constant_Util.QUOTE_PRODUCT_CONFIGURED &&
                            quoteLine.SBQQ__Quote__r.SBQQ__Status__c != Constant_Util.QUOTE_COST_CONFIGURED &&
                            quoteLine.SBQQ__Quote__r.SBQQ__Status__c != Constant_Util.QUOTE_DRAFT &&
                            quoteLine.SBQQ__Quote__r.RecordType.Name == Constant_Util.NEW_SERVICE 
            )
            {
                                updateQuote = true;
                            }
                            else
                            {
                                updateQuote = false;
                                break;
                            }
                    }
                    if(updateQuote)
                    {
                        SBQQ__Quote__c quote = new SBQQ__Quote__c();
                        quote.id = key;
                        quote.SBQQ__Status__c = Constant_Util.APPROVED;
                        quote.Approve_NTE_Amount__c = true;
                        UpdateQuoteList.add(quote);
                    }
                }
        
        if(!UpdateQuoteList.isEmpty())
        {
            for(Task TaskRec:[SELECT Id, status, whatID,OwnerId from Task where Sys_Created_From__c=:TaskAndGenesysPETriggerHelper.CREATED_FROM_PETRIGGER 
                              AND WhatID IN : UpdateQuoteList AND Status=:Constant_Util.OPEN  ])
            {
                TaskRec.Status=Constant_Util.COMPLETED;
                TaskRec.Description = TaskAndGenesysPETriggerHelper.VENDOR_COMMIT_DATE_UPDATED;
                TaskListToUpdate.add(TaskRec);
                
                Genesys_Routing__c grRecord= new Genesys_Routing__c();
                grRecord.action__c=Constant_Util.CANCEL;
                grRecord.SFDCObjRecordID__c=TaskRec.WhatId;
                grRecord.ownerId= quoteMapRecieved.get(TaskRec.WhatId).LastModifiedById;
                grRecord.Action_Reason__c=Constant_Util.TRANSFERRED;
                grRecord.MediaType__c= Constant_Util.SFDCWORKFLOWTASK;
                grRecord.SFDCTaskDescription__c=TaskAndGenesysPETriggerHelper.CANCELLATION_RECORD;
                grRecord.RecordTypeId=genesysRoutingRec;
                grRecord.SFDCCaseNumber__c=quoteMapRecieved.get(TaskRec.WhatId).SBQQ__Opportunity2__r.case__r.CaseNumber;
                grRecord.SFDCCaseType__c=quoteMapRecieved.get(TaskRec.WhatId).SBQQ__Opportunity2__r.case__r.Case_Type__c;
                grRecord.SFDCCaseReason__c=quoteMapRecieved.get(TaskRec.WhatId).SBQQ__Opportunity2__r.case__r.Case_Reason__c;
                grRecord.SFDCAcctSegment__c=quoteMapRecieved.get(TaskRec.WhatId).SBQQ__Opportunity2__r.case__r.account.Primary_Segment__c;
                grRecord.Action_Reason__c='Transferred';
                grRecord.SFDCCaseRefNo__c=quoteMapRecieved.get(TaskRec.WhatId).SBQQ__Opportunity2__r.case__r.CaseNumber;
                grRecord.SFDCCaseSubCaseType__c= quoteMapRecieved.get(TaskRec.WhatId).SBQQ__Opportunity2__r.case__r.Case_Sub_Type__c;
                grRecord.SFDCTaskDescription__c=TaskAndGenesysPETriggerHelper.UPDATE_QUOTE_STARTDATE;
                grRecord.SFDCTaskDescCode__c=TaskAndGenesysPETriggerHelper.UPDATEDATE;  
                grRecord.RecordTypeId=genesysRoutingRec;
                grRecord.SFDCAcctID__c=quoteMapRecieved.get(TaskRec.WhatId).SBQQ__Opportunity2__r.Case__r.Account.Vendor_ID__c;
                grRecord.SFDCAcctLocation__c=quoteMapRecieved.get(TaskRec.WhatId).SBQQ__ShippingName__c;
                grRecord.SFDCAcctSegment__c=quoteMapRecieved.get(TaskRec.WhatId).SBQQ__Opportunity2__r.case__r.account.Primary_Segment__c;
                grRecord.SFDCAcctLocationTimeZone__c=quoteMapRecieved.get(TaskRec.WhatId).SBQQ__Opportunity2__r.case__r.Location__r.tz__Timezone__c;
                grRecord.Send_to_Genesys_Time__c = system.Datetime.now();
                grRecord.SFDCRouteEndTime__c = string.valueof(system.today()) + Constant_Util.END_TIME_TEXT;
                grRecord.SFDCRouteStartTime__c = string.valueof(system.today()) + Constant_Util.START_TIME_TEXT;
                //grRecord.LastAgentId__c=String.isNotBlank(quoteMapRecieved.get(TaskRec.WhatId).SBQQ__Opportunity2__r.Case__r.Last_Agent_ID__c) ? quoteMapRecieved.get(TaskRec.WhatId).SBQQ__Opportunity2__r.Case__r.Last_Agent_ID__c: null;
                grRecord.SFDCTaskCaseId__c=quoteMapRecieved.get(TaskRec.WhatId).SBQQ__Opportunity2__r.Case__r.Id;
                grRecord.SFDCChildVendorAcctNo__c = quoteMapRecieved.get(TaskRec.WhatId).SBQQ__Opportunity2__r.Case__r.Supplier__r.Vendor_ID__c;
                grRecord.SFDCChildVendorName__c = quoteMapRecieved.get(TaskRec.WhatId).SBQQ__Opportunity2__r.Case__r.Supplier__r.Name;
                grRecord.SFDCFunction__c = Constant_Util.FOLLOW_UP;
                grRecord.SFDCObjName__c = Constant_Util.OBJECT_TASK;
                grRecord.SFDCObjName__c = Constant_Util.OBJECT_TASK;
                //grRecord.SFDCTaskDueDateTime__c = quoteMapRecieved.get(TaskRec.WhatId).Next_Action_Due_Date__c;
                grRecord.SFDCParentVendorAcctNo__c = quoteMapRecieved.get(TaskRec.WhatId).SBQQ__Opportunity2__r.Case__r.Supplier__r.Parent.Vendor_ID__c;
                grRecord.SFDCParentVendorName__c = quoteMapRecieved.get(TaskRec.WhatId).SBQQ__Opportunity2__r.Case__r.Supplier__r.Parent.Name;
                grRecord.SFDCRecordType__c = quoteMapRecieved.get(TaskRec.WhatId).SBQQ__Opportunity2__r.Case__r.RecordType.Name;
                grRecord.LastAgentId__c=quoteMapRecieved.get(TaskRec.WhatId).LastModifiedBy.UserName.substringBefore(Constant_Util.AT_SYMBOL);
                HaulAwayService.genUserDetalsWrapper genUserDetalsWrapperRec = HaulAwayService.getIfGenesysEnabledUser(quoteMapRecieved.get(TaskRec.WhatId).LastModifiedById);
                Boolean isGenesysEnabledUser = genUserDetalsWrapperRec.isGenesysEnabledUser;
                String genServiceFlag  = genUserDetalsWrapperRec.genFlag;
                grRecord.SFDCServiceFlag__c = isGenesysEnabledUser== true  ? genServiceFlag : '';
                GenesysListToInsert.add(grRecord);
            }
        
            update UpdateQuoteList;
            update TaskListToUpdate;
            insert GenesysListToInsert;
            }
        }}
    }
   
         // // Added by Gunjan Shah for SDT-50444
      public static void updateBypassPricePreview(List<SBQQ__QuoteLine__c> QuoteLineNewList, Map<Id,SBQQ__QuoteLine__c> oldQuoteLineMap) {
        Set<Id> quoteIDs = new Set<Id>();
        Set<Id> vendorIDS = new Set<Id>();
        Map<Id, SBQQ__Quote__c> quoteMap = new Map<Id, SBQQ__Quote__c>();
        Map<Id, Account> vendorMap = new Map<Id, Account>();

        for(SBQQ__QuoteLine__c ql : QuoteLineNewList) {
                //shajiya added start to check or uncheck the checkbox when changing wm to third party viceversa
            if (oldQuoteLineMap.get(ql.Id).Vendor__c != ql.Vendor__c) {
                if (ql.SBQQ__Quote__c != null && ql.Vendor__c != null) {
                quoteIDs.add(ql.SBQQ__Quote__c);
                vendorIDS.add(ql.Vendor__c);
            }
        }
                //shajiya added end
            
        }
        if(quoteIDs.size() > 0) {
            quoteMap = new Map<Id, SBQQ__Quote__c>([SELECT Id, Case_Type__c FROM SBQQ__Quote__c WHERE ID =: quoteIDs]);
        }
        if(vendorIDS.size() > 0) {
            vendorMap = new Map<Id, Account>([SELECT Id, WM_Vendor__c FROM Account WHERE ID =: vendorIDS]);
        }

        if(quoteMap.size() > 0 && vendorMap.size() > 0){
            for (SBQQ__QuoteLine__c ql : QuoteLineNewList) {
                //shajiya start
                // Skip processing if vendor did not change
                if (oldQuoteLineMap.get(ql.Id).Vendor__c == ql.Vendor__c) {
                    continue;
                    }
    
                Account vendor = vendorMap.get(ql.Vendor__c);
                SBQQ__Quote__c quote = quoteMap.get(ql.SBQQ__Quote__c);
    
                if (vendor == null || quote == null) {
                    continue;
                }
                if (vendorMap.get(ql.Vendor__c).WM_Vendor__c == true && (quoteMap.get(ql.SBQQ__Quote__c).Case_Type__c == 'New Service' || quoteMap.get(ql.SBQQ__Quote__c).Case_Type__c == 'Amendment')){
                    ql.BypassPriceReview__c = true;
                }
                else {
                ql.BypassPriceReview__c = false;
            }
                //shajiya end
            }
        }
    }


}
