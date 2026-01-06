/*************************************************************
@Name: QuoteLineTiggerHandler
@Author: Arvind Kumar
@CreateDate: 03/June/2021
@Description: Handler Class to Perform operations on QuoteLine
@UsedBy: QuoteLineTrigger
**************************************************************/
public class QuoteLineTriggerHandler {
   
    /*
    * It is invoked on before Insert the QuoteLine 
    * @owner : Arvind Kumar
    * @param : map<Id,Task>
    */
    public static void onBeforeInsert(List<SBQQ__QuoteLine__c> newQuoteLineList){
       // try{ 
	    //QuoteIds from the below method are used in ExhibitPriceServices Class as part of SDT-44637 Do not change value conditionally 
		QuoteLineTriggerHelper.updateDurationAndAccountOnQuoteLine(newQuoteLineList); // SDT-31110 -copy parent details in new created child.
            //QuoteLineTriggerHelper.updateMaterialType(newQuoteLineList);
            //QuoteLineTriggerHelper.quoteLineDefaults(newQuoteLineList);
            /*SDT-24736 Classification Changes
            Author : Yeshas Konduru*/
            QuoteLineTriggerHelper.assignInitialClassificationChanges(newQuoteLineList);
        	QuoteLineTriggerHelper.setDateTimeInGMTForGivenQLDateTime(newQuoteLineList);//Added for SDT-29615
        //SDT 31782 assign SBQQ__BundledQuantity__c as one 
        QuoteLineTriggerHelper.updateBundledQuantity(newQuoteLineList);
        //SDT 38011

        //pkulkan-TCS-SDT-39624-Added following method call to set fields on Extra Pickup quote line before insert
		ExtraPickupHandler.handleExtraPickupInsertion(newQuoteLineList);
        //pkulkan-TCS-SDT-39624-End

        QuoteLineTriggerHelper.setExceptionEffectiveDate(newQuoteLineList);
        //SDT 41543, SDT 41968
    	QuoteLineTriggerHelper.assignDefaultsToHaulAwayQL(newQuoteLineList);
        /*}
        catch(Exception e){
            //To handle Error in future Sprints
            System.debug('Exception occured::::'+e.getStackTraceString());
        }*/
        //SDT-38052
        QuoteLineTriggerHelper.setDoNotExtendService(newQuoteLineList);
	ExhibitPriceServices.updateManuallyAddedQuoteLines(newQuoteLineList, QuoteLineTriggerHelper.QuoteIds); //Added by Sarfaraz for SDT-44637
    QuoteLineTriggerHelper.validateVendorSelection(newQuoteLineList, new Map<Id, SBQQ__QuoteLine__c>());//shajiya 45005
    }
    /*
* It is invoked on After Insert the QuoteLine 
* @owner : Arvind Kumar
* @param : map<Id,QuoteLine>
*/
   public static void onAfterInsert(List<SBQQ__QuoteLine__c> newQouteLineList){
        //try{
            // List<SBQQ__QuoteLine__c> commercialQL = new List<SBQQ__QuoteLine__c>();
            // for(SBQQ__QuoteLine__c ql : newQouteLineList)
            // {
            //     if(ql.SBQQ__ProductFamily__c != null && ql.SBQQ__ProductFamily__c.equals(Constant_Util.COMMERCIAL))
            //     {
            //         commercialQL.add(ql);
            //     }
            // }
            QuoteLineTriggerHelper.addExtraPickupQuoteLine(newQouteLineList);
            //QuoteLineTriggerHelper.updateMaterialType(newQouteLineList);
	     QuoteLineTriggerHelper.addQuoteLineHistoryRec(newQouteLineList);//sdt-36179
	   
        /*}
        catch(Exception e){
            //To handle Error in future Sprints
            System.debug('Exception occured::::'+e.getStackTraceString());
        }*/
    }
    /*
    * It is invoked on After Update the QuoteLine 
    * @owner : Arvind Kumar
    * @param : map<Id,SBQQ__QuoteLine__c>
    */
    public static void onAfterUpdate(List<SBQQ__QuoteLine__c> newQuoteLineList,Map<Id,SBQQ__QuoteLine__c> oldQuoteLineMap,Map<Id,SBQQ__QuoteLine__c> newQuoteLineMap){
	    
               
        List<SBQQ__QuoteLine__c> lstNewQuote = new  List<SBQQ__QuoteLine__c>();
        Set<id> setQls = new Set<Id>();
            
        for(SBQQ__QuoteLine__c quoteLine : newQuoteLineList){
            //Only Parent QuoteLines are considered SDT-20236
            if(quoteLine.SBQQ__RequiredBy__c == null && quoteLine.Vendor__c != oldQuoteLineMap.get(quoteLine.Id).Vendor__c)
            {      
                lstNewQuote.add(quoteLine);
                setQls.add(quoteLine.Id);   
     			
            }       
        }
        //SDT-29645 - start
        /*if(!lstNewQuote.isEmpty() && !setQls.isEmpty())
        { 
            system.debug('OnAfterUpdate--->' + setQls);
            QuoteLineTriggerHelper.updateCompanyCode(lstNewQuote,setQls);            
        }*/      
        
        if(!setQls.isEmpty()){
            
            QuoteLineTriggerHelper.updateMASDetailsToQuoteLines(oldQuoteLineMap,setQls);
        }
        //SDT-29645 - End
        
        //QuoteLineTriggerHelper.updateQuoteStartDate(newQuoteLineList);    
        // changes done for SDT-28018 Removed flag from Trigger.Trigger and added here by jatan
        if(!RecurrsiveTriggerHandler.isRecurrsiveQuoteLine){

            
            if(QuoteLineTriggerHelper.extrapickUpRecursion == true){
                QuoteLineTriggerHelper.extrapickUpRecursion = false;
                QuoteLineTriggerHelper.validatePickUp(newQuoteLineList, newQuoteLineMap);
		QuoteLineTriggerHelper.updateCCOnCase(newQuoteLineList, newQuoteLineMap);     
            }
 
        
        System.debug('>>>>onAfterUpdate >> Before updateQuotedate');
        //changes for SDT-21787 & SDT-21802 by Anup Dey 
        // Changes for SDT- 30515 and 30514
        if(!PricingJSONRequest.isRecurrsiveIntegrationCheck)
        {
             Map<Id,SBQQ__Quote__c> quoteMap=QuoteLineTriggerHelper.updateQuotedate(newQuoteLineList); 
             //40723
             QuoteLineTriggerHelper.checkVendorCommitDateUpdate(newQuoteLineList, oldQuoteLineMap, newQuoteLineMap,quoteMap);
        }
        //SDT31120
        QuoteLineTriggerHelper.updateEndDateforAdditionalServices(newQuoteLineList,oldQuoteLineMap);

        RecurrsiveTriggerHandler.setIsRecurrsiveQuoteLine();

    }
    } 
    /*
    public static void onAfterUpdate(List<SBQQ__QuoteLine__c> newQuoteLineList, map<id, SBQQ__QuoteLine__c> newQuoteLineMap){
        
       
    }
    /*
    * It is invoked on before delete the QuoteLine 
    * @owner : Arvind Kumar
    * @param : map<Id,SBQQ__QuoteLine__c>
    */
    public static void onBeforeDelete(List<SBQQ__QuoteLine__c> newQouteLineList){
        //try{  
			//Changes related to SDT -31628
			//QuoteLineTriggerHelper.filterExtrapickupQL(newQouteLineList);		
            //SDT 36176 moved filterExtrapickupQL() from QuoteLineTriggerHelper class to ExtraPickupHandler class
        ExtraPickupHandler.filterExtrapickupQL(newQouteLineList);
         QuoteLineTriggerHelper.deleteQuoteLineHistoryRec(newQouteLineList); //SDT-36179
            QuoteLineTriggerHelper.removeExtraPickupQuoteLine(newQouteLineList);
        /*}
        catch(Exception e){
            //To handle Error in future Sprints
            System.debug('Exception occured::::'+e.getStackTraceString());
        }*/
    }

    public static void onBeforeUpdate(List<SBQQ__QuoteLine__c> newQuoteLineList,Map<Id,SBQQ__QuoteLine__c> oldQuoteLineMap,Map<Id,SBQQ__QuoteLine__c> newQuoteLineMap){
        //QuoteLineTriggerHelper.addExtraPickupQuoteLine(newQuoteLineList);
        //Changes for SDT-26002
        system.debug('Check flag RecurrsiveTriggerHandler.isSkipValidateQLCostPrice ' + RecurrsiveTriggerHandler.isSkipValidateQLCostPrice);

        if(!RecurrsiveTriggerHandler.isSkipValidateQLCostPrice)
        {
            if(newQuoteLineList != null && oldQuoteLineMap != null)
            {
                QuoteLineTriggerHelper.validateQLCostPrice(newQuoteLineList, oldQuoteLineMap, newQuoteLineMap);
            }
        }  
        
		//TCS-pkulkarn-SDT-32740-25-09-2024-Commented following line
        //QuoteLineTriggerHelper.trackClassificationFieldChanges(newQuoteLineList, oldQuoteLineMap);
        //SDT-32075- call a function from QuoteLineTriggerHelper to prevent update of quoteline with Equipment size as "unknown"
        QuoteLineTriggerHelper.CompareQlsizewithAssetsize(newQuoteLineList, oldQuoteLineMap);
        //SDT 38011
        QuoteLineTriggerHelper.setExceptionEffectiveDate(newQuoteLineList);
        // Added by Gunjan Shah for SDT-50444
        QuoteLineTriggerHelper.updateBypassPricePreview(newQuoteLineList, oldQuoteLineMap);

        //pkulkan-TCS-SDT-39624-Added following method calls
        ExtraPickupHandler.validateAndSetIsExtraPickupFlagOnPickup(newQuoteLineList);
        ExtraPickupHandler.validateExtraPickupStartDate(newQuoteLineList, oldQuoteLineMap, newQuoteLineMap);
        //pkulkan-TCS-SDT-39624-End
        //SDT 40078
		QuoteLineTriggerHelper.nullifyUOMforScheduledPickup(newQuoteLineList, oldQuoteLineMap);
        //SDT 33378
        QuoteLineTriggerHelper.validateQLStartDate(newQuoteLineList,oldQuoteLineMap);
        //pkulkarn-TCS-SDT-41184-Added following method call
        EndDateHandler.updateEndDatesOnQuoteLines(newQuoteLineList, oldQuoteLineMap, newQuoteLineMap);
        //SDT-41473 - SDT-41542 - update end date logic for haul away
         EndDateHandler.updateEndDatesOnQuoteLinesforHaulAway(newQuoteLineList, oldQuoteLineMap, newQuoteLineMap);
        //SDT 41543, SDT 41968
    	QuoteLineTriggerHelper.assignDefaultsToHaulAwayQL(newQuoteLineList);
        //SDT-42214
        QuoteLineTriggerHelper.updateCheckboxForBSVCRCode(newQuoteLineList,oldQuoteLineMap);
        QuoteLineTriggerHelper.validateVendorSelection(newQuoteLineList, (Map<Id, SBQQ__QuoteLine__c>) Trigger.oldMap);//shajiya 45005
    }
     /*
    * It is invoked on before delete the QuoteLine 
    * Description: Delete availability records if quoteline record is deleted.
    * @owner : Hanmi Reddy
    * @param : map<Id,SBQQ__QuoteLine__c>
    * Ticket : SDT-30735
    */
    public static void onBeforeDelete(map<Id,SBQQ__QuoteLine__c> oldQouteLineMap){
        list<AAV_Asset_Availability__c> availabilityList = [SELECT Id
                                FROM AAV_Asset_Availability__c 
                                WHERE AAV_Quote_Line__c =: oldQouteLineMap.keySet()];
        if(availabilityList != null && availabilityList.size() > 0){
            delete availabilityList;
        }
    }
}
