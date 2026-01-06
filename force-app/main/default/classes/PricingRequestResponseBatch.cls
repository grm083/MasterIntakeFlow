/**
* @Name          PricingRequestResponseBatch
* @Author        WM - Ali
* @Date          01/09/2020
* @Description   BATCH class for the purpose of update pricing request before date 10-Sep-20 with API response data
*/
public with sharing class PricingRequestResponseBatch implements Database.Batchable<sObject>,Database.Stateful {
    
    //Datetime startDateTime = Datetime.newInstance(2020, 8, 21);
    Datetime currentDateTime = System.now();
	public final String queryString = 'SELECT Id, Name, CreatedDate, APIRequestOutput__c FROM Pricing_Request__c Where CreatedDate <=: currentDateTime order by Name, CreatedDate asc';
    public List<Pricing_Request__c> priceReqList = new List<Pricing_Request__c>();

    /**@MethodName start
	* Method to return the pricing request records for Batch Processing.x
	**/  
    public Database.QueryLocator start(Database.BatchableContext currentScope){ 
        System.debug('@@@@@@@@~ In Start Batch');
        return Database.getQueryLocator(queryString);
    }

    /*@MethodName execute
    * Method to assign pricing request with API response
    **/
    public void execute(Database.BatchableContext currentScope, List<Pricing_Request__c> priceReqLst){
        System.debug('@@@@@@@@~ In Execute Batch');

        PricingReportingFieldsMetadata reportingFields = new PricingReportingFieldsMetadata();
        try {
            for(Pricing_Request__c priceReq : priceReqLst){
                Pricing_Request__c preq = new Pricing_Request__c();
                preq.Id = priceReq.Id;

                try {
                    System.debug('@@@@@@@@~ Request Id' + priceReq.Id + ' ' + priceReq.Name);

                    if(priceReq.APIRequestOutput__c != null){
                        reportingFields = PricingReportingFieldsMetadata.parse(priceReq.APIRequestOutput__c);

                        if(reportingFields != null && reportingFields.Data != null){

                            // preq.QuoteID__c = reportingFields.Data.priceQuoteIdentifier;
                            // preq.Vendor_Code__c = reportingFields.Data.SupplierCode;
                            // preq.Vendor_Name__c = reportingFields.Data.supplierName;
                            // preq.Customer_Code__c = reportingFields.Data.customerCode;
                            // preq.Cost_Source__c = reportingFields.Data.costSource;
                            // preq.Disposal_Rate_Type__c = reportingFields.Data.pricingMethodDisposalDescription;
                            // preq.Haul_Rate_Type__c = reportingFields.Data.pricingMethodHaulingDescription;
                            // preq.Haul_Cost__c = reportingFields.Data.haulCost;
                            // preq.Disposal_Cost__c = reportingFields.Data.disposalCost;
                            // preq.Haul_Price__c = reportingFields.Data.haulPrice;
                            // preq.Disposal_Price__c = reportingFields.Data.disposalPrice;
                            // preq.Est_Tons_per_Haul__c = reportingFields.Data.estimatedVolumePerHaul;
                            // preq.Business_Unit__c = reportingFields.Data.businessUnit;
                            // preq.Zone_Type__c = reportingFields.Data.zoneContractType;
                            preq.isAPIResult__c = true;
                        }
                        else {
                            preq.isAPIResult__c = false;
                        }
                    }
                    else {
                        preq.isAPIResult__c = false;
                    }
                } 
                catch (Exception ex) {
                    System.debug('@@@@@@@@~ Exception ' + ex);
                    preq.isAPIResult__c = false;
                }

                priceReqList.Add(preq);
            }
            
        } catch (Exception ex) {
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), 'PRICING REQUEST BATCH CLASS',LoggingLevel.ERROR);
        }
    }
    /*@MethodName finish
	* Method to update pricing request with API response
	**/ 
    public void finish(Database.BatchableContext batchVariable) {     
        System.debug('@@@@@@@@~ In Finish Batch');
        Database.SaveResult[] SR;
         try{
            if(priceReqList != null && priceReqList.size() > 0)
            {
                SR = Database.update(priceReqList, false);
                System.debug('@@@@@@@@~ SaveResult:' + SR);
            }
        }catch(Exception ex){
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), 'PRICING REQUEST BATCH CLASS',LoggingLevel.ERROR);
        }
	}  
}