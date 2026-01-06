/*
    * @Name          RemovalQuoteLineHandler
    * @Author        Seema Dhikale
    * @Vendor        TCS
    * @Date          2/1/2024
    * @description   This class will serve operations for Removal QuoteLines
    */
    public with sharing class RemovalQuoteLineHandler {
	
        /*
        * @vendor            TCS
        * @story             SDT-32952
        * @author            Seema Dhikale
        * @description       This method is set startdate, endDate, Exception effective date for removal Quoteline
        * @purpose			 Removal quoteline should be started on end date of bundle quoteline
        * @param             Date and Removal Quoteline
        * @return            NA
        */    
        public static void setDatesForRemovalQL(SBQQ__QuoteLine__c removalQL,Date endDate)
        {	
            removalQL.SBQQ__StartDate__c = endDate;
            removalQL.Exception_Effective_Date__c = DateTime.newInstanceGMT(endDate.year(), endDate.month(), endDate.day(),12,00,00);
            removalQL.Exceptions_Effective_Date__c = endDate;
	    removalQL.SBQQ__EndDate__c = endDate;
        }
        
        /*
        * @vendor            TCS
        * @story             SDT-32952
        * @author            Seema Dhikale
        * @description       This method will check and Removal Quoteline only if it has end date
        * @purpose			 Removal quoteline should be added only if bundle quoteline has end date
        * @param             Date and Removal Quoteline
        * @return            NA
        */    
        public static void checkIfBundleQLHasEnddateBeforeInsert(SBQQ__QuoteLine__c removalQLine){
            if(removalQLine.SBQQ__EndDate__c!=null){
                insert removalQLine;
            }
        }
		
		/*
    * @vendor            TCS
    * @story             SDT-32952, SDT 36449
    * @author            Seema Dhikale
    * @description       This method will return true if quoteline is of temporary duration and commercial container
    * @param             parent quoteline and Removal Quoteline
    * @return            NA
    */    
    public static boolean isTempCommercialContainer(SBQQ__QuoteLine__c quoteLine,Map<id,SBQQ__QuoteLine__c> parentQuoteLine){
        boolean isTempCommercialRemovalLine = false;
        if(parentQuoteLine != null && !parentQuoteLine.isEmpty() && parentQuoteLine.containsKey(quoteLine.SBQQ__RequiredBy__c)) {
            if(parentQuoteLine.get(quoteLine.SBQQ__RequiredBy__c).SBQQ__EndDate__c !=null && parentQuoteLine.get(quoteLine.SBQQ__RequiredBy__c).Duration__c ==Constant_Util.QUOTE_LINE_TEMP && parentQuoteLine.get(quoteLine.SBQQ__RequiredBy__c).SBQQ__ProductFamily__c==Constant_Util.COMMERCIAL){
                isTempCommercialRemovalLine = true;
            }
        }
        return isTempCommercialRemovalLine;
    }
    
    }
