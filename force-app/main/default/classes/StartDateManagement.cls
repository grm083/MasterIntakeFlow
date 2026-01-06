public class StartDateManagement {
    
    
public static string InvalidStartDateErrorMessage = 'Cannot change date, swivel to Acorn to make amendemnts.';
public static string BACK_DATED_SERVICE_REQUESTED='Back-dated service requested';
public static string DELIVERY_NOT_NEEDED_ONSITE='Delivery not needed/container on site';
public static string QUOTE_VALIDATION_MESSAGE='Quote start date is less than today so quote can’t move to Approved status. Please update Vendor commit date to today or greater than today on Parent bundle.';
    
    private static AggregateResult[] groupedResults {get;set;} 
    // The methods requires the Quoteline to have 
    // 1. SBQQ__StartDate__c, 2. Should have AssetId in case of bundle , AssetId_r.ParentId in case of child
    // This can be ensured by querying ql with above fields or setting the fields with required values.
    // Called from QuoteProcurementController.createDelivery
    // Called from WorkOrderController.checkStartDateValidity 
    public Boolean validateQuoteLineStartDate(SBQQ__QuoteLine__c quoteline){        
        
        Datetime maxDate = getMaxDate(quoteline);
        System.debug('Startdatemanagement maxDate ' + maxDate);
        System.debug('Startdatemanagement quoteline.SBQQ__StartDate__c ' + quoteline.SBQQ__StartDate__c);
        System.debug('Startdatemanagement quoteline.SBQQ__StartDate__c > maxDate ' + (quoteline.SBQQ__StartDate__c > maxDate));
        
        return quoteline.SBQQ__StartDate__c > maxDate; 
        // error 
    }
    
    public DateTime getMaxDate(SBQQ__QuoteLine__c quoteline){
        
        DateTime maxDate;
        // check if anyother condition is also required
        // 
        System.debug('Startdatemanagement quotelineId and Asset parent id ' + quoteline.Id + ' ' + quoteline.AssetId__r.ParentId );
        //if(StartDateManagement.groupedResults!=null && StartDateManagement.groupedResults.isEmpty()){
        if(quoteline.Id!=null && (  quoteline.AssetId__c!=null && (quoteline.AssetId__r.ParentId!=null 
                                  ||  quoteline.AssetId__r.ParentId==null )))
        {
            
            Id parentAssetId = quoteline.AssetId__r.ParentId;
            // Possibility with bundle, where bundle is tagged to Asset header directly
            if(  quoteline.AssetId__c!=null && quoteline.AssetId__r.ParentId==null ){
                parentAssetId = quoteline.AssetId__c;
            }
            
            groupedResults= AssetQuerySelector.getMaxStartOrEndDate(parentAssetId);
            
            				/*[Select Max(Start_Date__c) start , Max(End_Date__c) end from Asset 
                             
                             where 
                             ParentId=:quoteline.AssetId__r.ParentId	
                             group by ParentId
                             Limit 1
                            ];*/
            
            
            System.debug('Startdatemanagement groupedResults ' + groupedResults );
            
            for (AggregateResult result : groupedResults){
                
                DateTime maxStartDate = (DateTime)result.get('start');
                DateTime maxEndDate = (DateTime) result.get('end');
                
                System.debug('Startdatemanagement maxStartDate ' + maxStartDate );
                System.debug('Startdatemanagement maxEndDate ' + maxEndDate );
                
                System.debug('Startdatemanagement maxStartDate>maxEndDate ' + (maxStartDate > maxEndDate) );
                
                // is there a situation where start date is null and end date is not null ??
                if(maxEndDate==null){
                    maxDate = maxStartDate;
                }else{
                    
                    maxDate =  maxEndDate!=null && maxStartDate > maxEndDate   ?  maxStartDate  : maxEndDate ;
                }
                
            }
            //}
            
        }      
        
        return maxDate;
        
        
        
    }
    
    //40723 START
    public static String validateStartDateOnNewServiceQuote(List<SBQQ__QuoteLine__c> quoteLines, map<id, SBQQ__Quote__c> triggerOldMap)
    {
        String errorMessage = Constant_Util.SUCCESS;
       
        //Check the Product Family, Duration and Vendor for the Core Service
        for(SBQQ__QuoteLine__c quoteLine : quoteLines)
        {
            
            if(quoteLine.SBQQ__Quote__r.SBQQ__Type__c == Constant_Util.QUOTE &&
               quoteLine.SBQQ__Quote__r.RecordType.name==Constant_Util.NEW_SERVICE &&
               quoteLine.SBQQ__RequiredBy__c == null && quoteline.SBQQ__Quote__r.SBQQ__Status__c!= Constant_Util.QUOTE_COST_CONFIGURED_LABEL &&
               (quoteLine.SBQQ__StartDate__c < date.today() || quoteLine.Vendor_Commit_Date__c < date.today()) && 
               !((quoteLine.SBQQ__Quote__r.Special_Handling_Reason__c==BACK_DATED_SERVICE_REQUESTED || quoteLine.SBQQ__Quote__r.Special_Handling_Reason__c==DELIVERY_NOT_NEEDED_ONSITE) && quoteLine.SBQQ__Quote__r.Special_Handling__c 
              ))
            {
                errorMessage = QUOTE_VALIDATION_MESSAGE;   
                
             
        }
       
            }
    return errorMessage;
    }
//40723 END    
}
