/* Apex Class : PricingJSONRequest
* Description : This class is used for generating Sample Pricing Request
* Developer : Lovel Panchal (lpanchal@wm.com)
* Date : 19-Feb-2021
* Edit Comments :
* //------------------------------------------------------------------------------
* SDT-19653 Added the Quote Resync Functionality
* 
* //------------------------------------------------------------------------------
*/
global class PricingJSONRequest {
    wQuote Quote;
    public static List<Asset> assetDetails = new List<Asset>();
    public static AssetQuoteProcurementController.TransformationHelper transformationHelper = new AssetQuoteProcurementController.TransformationHelper();
    public static Map<Id,Asset> assetProductMap = new Map<Id,Asset>();
    public static Map<Id,Asset> assetBundleMap = new Map<Id,Asset>();	//TCS-pkulkarn-11-Aug-2023-Added for SDT-31408
    public static set<Id> assetIds = new set<id>();
    public static Set<String> metaDataQLFields = new Set<String>();
    public static string caseType;
    //This is addition field to add in metadata set. Also include this field in lstQuoteLine SOQL if not already present.
    public static set<string> additionFieldsforMetadata = new Set<string>{'Vendor__c', 'LocationPositionName__c', 'Location_Position_Name__c','SBQQ__PricingMethod__c','SBQQ__StartDate__c'};
    public static Boolean isRecurrsiveIntegrationCheck = false ;
    public static Set<string> excludedFields = transformationHelper.readFieldSet('Integration_Excluded_Fields','SBQQ__QuoteLine__c');
    //Changes for SDT-30118
    public static final string SURCHARGES_AND_FEES = 'Surcharges and Fees';
    //Changes related to SDT-39689
    public static final string COMMUNICATION_TYPE_CODE = 'CommunicationChannelTypeCode';
    public static final string QUOTE_CASE_ORIGIN = 'QuoteCaseOrigin';
    //Wrapper class for quote line attribute
    global class wQuotLine{
        string QuoteLineId;
        string SFQuoteLineKey;
        List<Map<String, String>> Errors;
    }
    //Wrapper class for quote attribute
    global class wQuote{
        string RequestedBy;
        string QuoteId;
        String Status;
        String Type;
        Map<String, String> QuoteError ;
        List<wQuotLine> QuoteLines;
		List<WorkOrderWrapper> WorkOrders;
    }
	//Wrapper class for WorkOrders node.
    global class WorkOrderWrapper{
        String PurchaseOrderNumber;
        String WorkOrderNumber;
        String ServiceDesc;
        String TicketNumber;
        String ServiceDate;
        String ChildTicketNumber;
    }

    /* This method will parse the json and create related task
* @param jSONRes: Json string from post 
* @return null. 
* */
    global static void updateQuoteLinesStatus(string jSONRes){
        // adding new variables for SDT-21248
        //string ticketNumber='';
        //boolean isTicketNumber=false;
        string caseComment ='';
        //Added for SDT-22100 , Get LoggedIn User AcornId
        string acornTicketNumber = '';
        string getLoggedInUserAcornId  = IntegrationHandlerUtil.getLoggedInUserAcornId();
        //SDT-22100 End
        Map<string,string> QuoteCaseComment = new Map<string,string>();
        system.debug('jSONRes '+jSONRes);
        PricingJSONRequest pq = (PricingJSONRequest)JSON.deserialize(jSONRes, PricingJSONRequest.class);
        system.debug('pq '+  pq);
        wQuote wq = pq.Quote;
        system.debug('wq' +wq);
        Map<String,SBQQ__Quote__c> parentQuoteMap = new Map<String,SBQQ__Quote__c>();
        system.debug('Before parentQuote');
        //replacing syncedQuoteMap with parentQuote- Rishi 06/29
        // Added 'SBQQ__ShippingCountry__c' field for Story SDT-25855
        // SDT30086 adding SBQQ__Type__c
        SBQQ__Quote__c parentQuote =   [SELECT Id,Name, SBQQ__Type__c,Resubmit_Flag__c,ErrorComments__c,Acorn_Work_Order_Details__c,
        CreatedBy.UserRole.Name,SBQQ__Account__r.Parent.Primary_Segment__c,Project_Services_Request__c,Project__c, SBQQ__ShippingCountry__c FROM SBQQ__Quote__c WHERE Name =:wq.QuoteId LIMIT 1];
        system.debug('Before parentQuote' + parentQuote);
        //Added for SDT-22100 fetching HTTP request details for ASSIGNING team queue to acorn tickets.
        Integration_Request_URLs__mdt REASSIGN_TICKET =   [select DeveloperName,MasterLabel,Client_Key__c,Client_Token__c,Timeout__c,
                                                        Content_Type__c,End_Point__c,Method__c from Integration_Request_URLs__mdt 
                                                        where DeveloperName =:Constant_Util.REASSIGN_TICKET ];
        parentQuoteMap.put(parentQuote.Name,parentQuote);
        List<Task> lTask = new List<Task>();
        Id Recrdtypeid = [select Id,DeveloperName from RecordType where SobjectType ='task' and DeveloperName = 'Integration_Errors_Task'].id;
        Generic_Values__mdt user = [select id, Label, DeveloperName, Id__c from Generic_Values__mdt where DeveloperName = 'Salesforce_Support_Team'];
        //String taskSubject = Constant_Util.ACORN_TASK_SUBJECT;
        Map<String, String> mapType = new Map<String, String>();
        Map<string, Map<String, List<string>>> mapQuoteLinesStatus = new Map<string, Map<String, List<string>>>();
        List<SBQQ__QuoteLine__c> syncedSuccessQL = new List<SBQQ__QuoteLine__c>();
        List<Quote_Order__c> syncedSuccessQO = new List<Quote_Order__c>();
        if(wq.Status == 'Success'){
            if(wq.Type.equalsIgnoreCase('Asset')){
                for(SBQQ__QuoteLine__c qLine : [Select Id, SBQQ__Quote__c,IsSynced__c from SBQQ__QuoteLine__c where SBQQ__Quote__r.name =:wq.QuoteId]){
                    qLine.IsSynced__c = true;
                    //added as part of sdt-25114
                    qLine.ErrorComments__c = null;
                    syncedSuccessQL.add(qLine);
                    SBQQ__Quote__c quote= parentQuoteMap.get(wq.QuoteId);
                    quote.Resubmit_Flag__c= false;
                    //added as part of SDT-25114
                    quote.ErrorComments__c = null;

                    //Changes added for story SDT-19971, This will update integration status to In-Progress.
                    quote.Integration_Status__c = 'Success';
                    parentQuoteMap.put(wq.QuoteId,quote);
                }
                if(!syncedSuccessQL.isEmpty() && !parentQuoteMap.isEmpty()){
                    update parentQuoteMap.values();
                    update syncedSuccessQL;
                }
            }
            //Developer : Jatan sharma
            //changes done for SDT-19724
            //In case of WO success also checking isSync to true for QuoteLine.
            else if (wq.Type.equalsIgnoreCase('WorkOrder')){
                String table='';
                if(wq.WorkOrders!=null){
                    table  ='<p><span style=\"color: #2e6c80;\"><strong>Acorn Work Order Details</strong></span></p>\r\n<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\" style=\"font-size:12px; width:100%; word-wrap: normal\">\r\n<thead><tr>\r\n<th style=\"width:20%\">Tracking Number</th>\r\n<th style=\"width:20%\">Purchase Order</th>\r\n<th style=\"width:20%\">Work Order</th>\r\n<th style=\"width:20%\">Service Description</th>\r\n<th style=\"width:20%\">Service Date</th></tr></thead><tbody>';
                    List<WorkOrderWrapper> wowrapList= wq.WorkOrders;
                    Integer i=0;
                    system.debug('wowrapList '+wowrapList);
                    for(WorkOrderWrapper wowrapObj: wowrapList){
                        system.debug('wowrapObj ' +wowrapObj);
                        string teamQueue = '';
                        table = table + '<tr>\r\n<td tabindex=\"'+i+'\">\r\n<div>'+wowrapObj.TicketNumber+'</div>\r\n</td>\r\n<td tabindex=\"'+i+'\">\r\n<div>'+wowrapObj.PurchaseOrderNumber+'</div>\r\n</td>\r\n<td tabindex=\"'+i+'\">\r\n<div>'+wowrapObj.WorkOrderNumber+'</div>\r\n</td>\r\n<td tabindex=\"'+i+'\">\r\n<div>'+wowrapObj.ServiceDesc+'</div>\r\n</td>\r\n<td tabindex=\"'+i+'\">\r\n<div>'+wowrapObj.ServiceDate.subString(0,10)+'</div>\r\n</td>\r\n</tr>';
                        i++;
                        //Changes done by Anup and Jatan for SDT-21248
                        if(wowrapObj!=null && wowrapObj.TicketNumber !=null )
                        {
                            //Changes done for SDT-22100 -  Start
                            //Assigning queue team to acorn ticket based on below criteria.
                            if(!String.isempty(wowrapObj.ChildTicketNumber) && acornTicketNumber == wowrapObj.ChildTicketNumber)
                            {
                                continue;
                            }
                            if(String.isempty(wowrapObj.ChildTicketNumber)){
                               acornTicketNumber = wowrapObj.TicketNumber;
                            }
                            else{
                                acornTicketNumber = wowrapObj.ChildTicketNumber;
                            }
                            
                            // Added for Story SDT-25855
                            // Check for 'Canada' Shipping Country
                            //SDT 30086
                            if(parentQuote.SBQQ__Type__c ==  Constant_Util.QUOTE){
                                if(!String.isempty(parentQuote.SBQQ__ShippingCountry__c) && parentQuote.SBQQ__ShippingCountry__c == Constant_Util.Canada_Shipping_Country)
                                {
                                    teamQueue= Constant_Util.AcornTeam_WMSSC_Customer_Service;
                                }
                                else
                                {
                                    if(parentQuote.Project__c !=null || (parentQuote.CreatedBy.UserRole.Name!=null && parentQuote.CreatedBy.UserRole.Name.contains(Constant_Util.Project_Services)) || parentQuote.SBQQ__Account__r.Parent.Primary_Segment__c == Constant_Util.CONSTRUCTION_AND_DEMOLITION || parentQuote.Project_Services_Request__c == true ){
                                        teamQueue = Constant_Util.AcornTeam_PS_Vendor_Inquiry;
                                        system.debug('Inside first if');
                                    }
                                    else if (wowrapObj.ServiceDesc == Constant_Util.ServiceType_Delivery) {
                                        system.debug('Inside ServiceType_Delivery');
                                        teamQueue = Constant_Util.AcornTeam_CS_Delivery_Vendor_Inquiries;
                                    }
                                }	
                            } else if(parentQuote.SBQQ__Type__c ==  Constant_Util.QUOTE_TYPE_AMEND || parentQuote.SBQQ__Type__c ==  Constant_Util.QUOTE_TYPE_EXCEPTION){
                                if(!String.isempty(parentQuote.SBQQ__ShippingCountry__c) && parentQuote.SBQQ__ShippingCountry__c == Constant_Util.Canada_Shipping_Country)
                                {
                                    teamQueue= Constant_Util.Canada_WMSSC_Customer_Service;
                                }
                                else if(!String.isempty(parentQuote.SBQQ__ShippingCountry__c) && parentQuote.SBQQ__ShippingCountry__c == Constant_Util.UNITED_STATES){
                                    teamQueue = Constant_Util.CS_FOLLOW_UP;
                                }
                            }
                            //teamQueue = Constant_Util.AcornTeam_CS_Delivery_Vendor_Inquiries;
                            if(!String.isempty(teamQueue)){
                               assignQueuetoAcornTicket(acornTicketNumber,teamQueue,Reassign_Ticket,getLoggedInUserAcornId);
                            }
                            // SDT-22100 END
                            caseComment = caseComment+' ' +wowrapObj.ServiceDesc + ' work orders created under the following Ticket '+ wowrapObj.TicketNumber + '<br/>';
                            
                        }
                    }
                    QuoteCaseComment.put(wq.QuoteId,caseComment);
                    table+='</tbody>\r\n</table>';
                }
                for(SBQQ__QuoteLine__c oQuoteLine : [Select Id,SBQQ__Quote__c,Name,IsSynced__c,(Select Id ,IsSynced__c From Quote_Orders__r) from SBQQ__QuoteLine__c where SBQQ__Quote__r.name =:wq.QuoteId]){
                    oQuoteLine.IsSynced__c = true;
                    //added as part of SDT-25114
                    oQuoteLine.ErrorComments__c = null;
                    syncedSuccessQL.add(oQuoteLine);
                    SBQQ__Quote__c quote= parentQuoteMap.get(wq.QuoteId);
                    quote.Resubmit_Flag__c= false;
                    //added as part of SDT-25114
                    quote.ErrorComments__c = null;
                    //Changes added for story SDT-19971, This will update integration status to In-Progress.
                    quote.Integration_Status__c = 'Success';
                    if(table !=null && table !=''){
                        quote.Acorn_Work_Order_Details__c= table;
                    }
                    parentQuoteMap.put(wq.QuoteId,quote);
                    for(Quote_Order__c qo : oQuoteLine.Quote_Orders__r){
                        syncedSuccessQO.add(qo);
                        qo.IsSynced__c = true;
                    }
                }
                if(!syncedSuccessQO.isEmpty()){
                    update syncedSuccessQO;
                }
                if(!syncedSuccessQL.isEmpty() && !parentQuoteMap.isEmpty()){
                    update parentQuoteMap.values();
                    update syncedSuccessQL;

                    //Changes done by Anup and Jatan for SDT-21248
                    List<SBQQ__Quote__c> QuoteList= new List<SBQQ__Quote__c>();
                    QuoteList.add(parentQuoteMap.values());
                    closeCaseonWOIntegration(QuoteList, QuoteCaseComment); 
                }
            }
            //Changes related to SDT-25114
            //query the integration error tasks under the quote
            SBQQ__Quote__c quote= parentQuoteMap.get(wq.QuoteId);
            List<Task> integrationErrorTsklst = [SELECT Id,Status FROM Task WHERE WhatID =:quote.Id and Recordtypeid =:Recrdtypeid and Status != 'Completed'];
            System.debug('tasklistt'+integrationErrorTsklst);
            //looping through integration error tasks and setting the status as complete.
            for(Task tsk:integrationErrorTsklst){
                tsk.Status = 'Completed';
            }
            
            //updating integration error tasks.
            if(integrationErrorTsklst!=null && !integrationErrorTsklst.isEmpty()){
                update integrationErrorTsklst;
            }
        }
        // Status: failure, For type: Asset & Work Order
        else {
            Task tsk = new Task();
            if(wq.QuoteError != null && wq.QuoteError.size() >0){
                String message = wq.QuoteError.get('Message') ;//String.join(new List<String>(mapQuoteLinesStatus.get(oQuoteLine.Name).get('ErrorMessage')), ':');
                if(wq.Type.equalsIgnoreCase('Asset')){
                    SBQQ__Quote__c quote= parentQuoteMap.get(wq.QuoteId);
                    tsk.Subject= 'Integration Issue in Quote - '+ quote.Name+ '/ Quote Lines/ WorkOrder';
                    tsk.Status='Open'; 
                    tsk.Priority='Normal'; 
                    tsk.WhatID = quote.Id; 
                    tsk.ownerid = user.id__c;

                    //modified as part of SDT-25114 - uncommented
                    if(String.isNotEmpty(message)){
                        tsk.Description = message + '\n'; 
                    }
                    tsk.Recordtypeid = Recrdtypeid;
                    tsk.ActivityDate = system.Today();
                    
                    lTask.add(tsk);
                    
                    quote.ErrorComments__c = message;
                    //Changes added for story SDT-19971, This will update integration status to In-Progress.
                    quote.Integration_Status__c = 'Failure';
                    //added as part of SDT-25114
                    quote.DoResyncOutBoundcall__c = true;
                    quote.Resubmit_Flag__c =  false;
                    parentQuoteMap.put(wq.QuoteId,quote);
                }
            }
            if( wq != null &&  wq.QuoteLines != null) {
                for(wQuotLine wQL : wq.QuoteLines){
                    Map<String, List<string>> mapError = new Map<String, List<string>>();
                    List<String> lErrorMessage = new List<String>();
                    List<String> lErrorType = new List<String>();
                    for(Map<String, String> mError : wQL.Errors){
                        lErrorMessage.add(mError.get('Message'));
                        lErrorType.add(mError.get('Type'));
                    }
                    mapError.put('ErrorMessage',lErrorMessage);
                    mapError.put('mapError',lErrorType);
                    mapQuoteLinesStatus.put(wQL.SFQuoteLineKey,mapError); 
                }
                //System.debug('mapError -->'+mapError);
                System.debug('mapQuoteLinesStatus -->'+mapQuoteLinesStatus);
                List<SBQQ__QuoteLine__c> syncedQL = new List<SBQQ__QuoteLine__c>();
                List<Quote_Order__c> syncedQO = new List<Quote_Order__c>();
                String message;
                String quoteMessage;
                String table='';
                if(wq.Type.equalsIgnoreCase('WorkOrder')){
                    if(wq.WorkOrders!=null){
                        table  ='<p><span style=\"color: #2e6c80;\"><strong>Acorn Work Order Details</strong></span></p>\r\n<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\" style=\"font-size:12px; width:100%; word-wrap: normal\">\r\n<thead><tr>\r\n<th style=\"width:20%\">Tracking Number</th>\r\n<th style=\"width:20%\">Purchase Order</th>\r\n<th style=\"width:20%\">Work Order</th>\r\n<th style=\"width:20%\">Service Description</th>\r\n<th style=\"width:20%\">Service Date</th></tr></thead><tbody>';
                        List<WorkOrderWrapper> wowrapList= wq.WorkOrders;
                        Integer i=0;
                        for(WorkOrderWrapper wowrapObj: wowrapList){
                            table = table + '<tr>\r\n<td tabindex=\"'+i+'\">\r\n<div>'+wowrapObj.TicketNumber+'</div>\r\n</td>\r\n<td tabindex=\"'+i+'\">\r\n<div>'+wowrapObj.PurchaseOrderNumber+'</div>\r\n</td>\r\n<td tabindex=\"'+i+'\">\r\n<div>'+wowrapObj.WorkOrderNumber+'</div>\r\n</td>\r\n<td tabindex=\"'+i+'\">\r\n<div>'+wowrapObj.ServiceDesc+'</div>\r\n</td>\r\n<td tabindex=\"'+i+'\">\r\n<div>'+wowrapObj.ServiceDate.subString(0,10)+'</div>\r\n</td>\r\n</tr>';
                            i++;
                        }
                        table+='</tbody>\r\n</table>';
                    }
                }
                //Work order error mapping
                //Developer : Jatan sharma/Rishi
                //changes done for SDT-19752 & SDT-19724
                for(SBQQ__QuoteLine__c quoteLineObj: [Select Id,SBQQ__Quote__c,Name,IsSynced__c,ErrorComments__c,(Select Id ,Name,IsSynced__c,ErrorComments__c From Quote_Orders__r) from SBQQ__QuoteLine__c where SBQQ__Quote__r.name =:wq.QuoteId]){
                    if(wq.Type.equalsIgnoreCase('Asset')){
                        if(mapQuoteLinesStatus.keyset().contains(quoteLineObj.Name)){		
                            message =  String.join(new List<String>(mapQuoteLinesStatus.get(quoteLineObj.Name).get('ErrorMessage')), '\n');
                            System.debug('message : ' + message);
                            if(String.isNotEmpty(message)){
                                String recordlink = URL.getOrgDomainUrl().toExternalForm()+'/lightning/r/SBQQ__QuoteLine__c/'+quoteLineObj.Id+'/view';
                                if(String.isNotEmpty(tsk.Description)){
                                    tsk.Description += '\n' + quoteLineObj.Name + ' Link: ' +recordlink+ '\n' + message + '\n';
                                }else{
                                    tsk.Description = quoteLineObj.Name + ' Link: ' +recordlink+ '\n' + message + '\n';
                                }
                            }
                            quoteLineObj.ErrorComments__c = message;
                            SBQQ__Quote__c quote= parentQuoteMap.get(wq.QuoteId);
                            quote.ErrorComments__c = tsk.Description;
                            //added as part of SDT-25114
                            tsk.Description = 'This task is only for Tracking purpose' + '\n' + tsk.Description;
                            //Changes added for story SDT-19971, This will update integration status to In-Progress.
                    		quote.Integration_Status__c = 'Failure';
                            //added as part of SDT-25114
                            quote.DoResyncOutBoundcall__c = true;
                            quote.Resubmit_Flag__c =  false;
                            parentQuoteMap.put(wq.QuoteId,quote);
                            syncedQL.add(quoteLineObj);
                        }
                    }
                    if(wq.Type.equalsIgnoreCase('WorkOrder')){
                        //making Quoteline IsSynced__c= true when there is no quotelione error found.
                        quoteLineObj.IsSynced__c= true;
                        syncedQL.add(quoteLineObj);
                        if(!quoteLineObj.Quote_Orders__r.isEmpty()){
                            for(Quote_Order__c qoObj: quoteLineObj.Quote_Orders__r){
                                if(mapQuoteLinesStatus.keyset().contains(qoObj.Name)){			// recording error on error comments field on QO and making isSynched false.	
                                    quoteMessage =  String.join(new List<String>(mapQuoteLinesStatus.get(qoObj.Name).get('ErrorMessage')), '\n');
                                    System.debug('message : ' + quoteMessage);
                                    String recordlink = URL.getOrgDomainUrl().toExternalForm()+'/lightning/r/Quote_Order__c/'+qoObj.Id+'/view';
                                    qoObj.IsSynced__c = false;
                                    qoObj.ErrorComments__c = quoteMessage;
                                    SBQQ__Quote__c quote= parentQuoteMap.get(wq.QuoteId);
                                    quote.ErrorComments__c += '\n' + qoObj.Name + ' Link: ' +recordlink+ '\n' + quoteMessage + '\n';        
                                    if(table !=null && table !=''){
                                        quote.Acorn_Work_Order_Details__c= table;
                                    }
                                    //Changes added for story SDT-19971, This will update integration status to In-Progress.
                    				quote.Integration_Status__c = 'Failure';
                                    //added as part of SDT-25114
                                    quote.DoResyncOutBoundcall__c = true;
                                    quote.Resubmit_Flag__c =  false;
                                    parentQuoteMap.put(wq.QuoteId,quote);
                                   } else{ // qoObj.IsSynced__c= true to all successfully resynched QO's.
                                    qoObj.IsSynced__c= true; 
                                }
                                syncedQO.add(qoObj);
                            }
                        }
                    }
                }                
                if(syncedQL.size() > 0){
                    //syncedQuote[0].Resubmit_Flag__c = true; // we will mark true when the all task will closed.
                    update syncedQL;    
                }
              	if(syncedQO.size() > 0){
                    update syncedQO;
                } // As discussed in the call with yogesh and Pankaj, Quote Order will not update
                
               if(!parentQuoteMap.isEmpty()){
                    update parentQuoteMap.values();
                }
            }
            if(lTask.size() > 0){
                insert lTask;
            }
        }
    }
    
    /* This method will use to generate Pricing Request
* @param quoteName : Quote name for requested pricing data
* @return : Return the json of pricing request
* */
    global static String generatePricingJSON(String quoteName, Boolean integrationCall){
        //This will generate the Json for API. Changes done for SDT-19970.
        //SDT-30514 and SDT-30515-Added Fourth parameter for Vendor_Commit_Date__c
        //TCS-pkulkarn-2-Sep-2024-SDT-41371-Tech Debt-Added 4th parameter to below call
        return integrationToAPI(quoteName , false , false, integrationCall);
    }
    /* This method will check for and return the parent field value
* @param fieldName : field api name to get the value
* @param objValue : record to get the value 
* @return value of queried field
* */
    public static String getParentValue(String fieldName, sObject objValue){
        integer i = 0;
        String returnVal = '';
        
        if(fieldName.split('\\.').size() > 1 ){
            for(string value : fieldName.split('\\.')){
                i = i + 1;
                if(fieldName.split('\\.').size() > i){
                    objValue = objValue.getSObject(value);
                }
                else if(objValue != null){
                    returnVal = objValue.get(value) != null ? String.valueOf(objValue.get(value)) : '';
                }
            }
        } else {
            returnVal = objValue.get(fieldName) != null ? String.valueOf(objValue.get(fieldName)) : '';
        }
        return returnVal;
    }
    
    //Developer :Jatan Sharma
    //Date : 5/11/2021
    //Work Order case mapping for Case Type,Case subtype,Case Reason. 
    //This method will map the Case_Type__c ,Case_Sub_Type__c and Case_Reason__c from the input of Work order object.
    //MetaData used : QOServiceProductCombination__mdt
    public static Map<String,Object> caseTypeMapping(Map<String,Object> mapWO, Quote_Order__c objQO){
        
        try{
                  
        QOServiceProductCombination__mdt  metadata =[select Case_Type__c ,Case_Sub_Type__c , Case_Reason__c From QOServiceProductCombination__mdt 
                                                   where Service__c =:objQO.Service_Type__c and Primary_Component__c =:objQO.Product_Type__c 
                                                   and Occurrence_Type__c=:objQO.Occurrence_Type__c and Duration__c=:objQO.Duration__c
                                                   and ServiceProdFilter__c = True and IsTransformation__c = True];

        mapWO.put('Case_Type__c', metadata.Case_Type__c);
        mapWO.put('Case_Sub_Type__c', metadata.Case_Sub_Type__c);
        mapWO.put('Case_Reason__c', metadata.Case_Reason__c);
        
        }
        catch (Exception ex){
        mapWO.put('Case_Type__c', '');
        mapWO.put('Case_Sub_Type__c', '');
        mapWO.put('Case_Reason__c', '');
        }
        return mapWO;
    }

   /**************************************************
    * Created By:Jatan and Anup
    * CreatedDate:09/02/2022
    * Story: SDT-21248
    * Comment: changes to close the Case when WO is integrated successfully.
    * **************************************************/
  public static void closeCaseonWOIntegration(List<SBQQ__Quote__c> quoteList, Map<string,string> quoteCaseComment) {
    // local variables    
    boolean wointegrated = false;
    List<id> caseIds = new List<id>();
    List<case> finalcaselist = new List<case>();
    List<Comment__c> finalcommentlist = new List<Comment__c>();
    Map<id, List<SBQQ__Quote__c>> CaseQuoteMap = new Map<id, List<SBQQ__Quote__c>>();
    List<sObject> quoteUpdate = new list<sObject>();
    
    // get Acorn user user iD
    Decimal acornUserId = [select Acorn_SUser_ID__c from User where ID =: System.UserInfo.getUserId()].Acorn_SUser_ID__c;
    
    // get record Id
    Id recordTypeId = Schema.getGlobalDescribe()
      .get('Comment__c')
      .getDescribe()
      .getRecordTypeInfosByDeveloperName()
      .get('Acorn_Ticket_Comment')
      .getRecordTypeId();
    
      //Fetching case Ids for all quotes all quotes details.
    List<SBQQ__Quote__c> objquote = [
      SELECT id, SBQQ__Status__c, SBQQ__Opportunity2__r.Case__c
      FROM SBQQ__Quote__c
      WHERE id IN :quoteList
    ];

    //Iterating over quotes to get case Id only for approved quotes
    for (SBQQ__Quote__c quote : objquote) {
      if (quote.SBQQ__Status__c == Constant_Util.QUOTE_APPROVED) {
        caseIds.add(quote.SBQQ__Opportunity2__r.Case__c);
      }
    }

    //Fetching all quotes related to case
    list<SBQQ__Quote__c> quotes = [
      SELECT
        id,
        SBQQ__Status__c,
        name, 
        Acorn_Work_Order_Details__c,
        SBQQ__Opportunity2__r.Case__c,
        SBQQ__Opportunity2__r.Case__r.casenumber,
        SBQQ__Opportunity2__r.Case__r.Tracking_Number__c
      FROM SBQQ__Quote__c
      WHERE SBQQ__Opportunity2__r.Case__c IN :caseIds
    ];

    // loop through the Quotes to fill the CaseQuoteMap(this map is holding relationship between case and quote list)
    for (SBQQ__Quote__c q : quotes) {
      //check if key exists in Map
      if (CaseQuoteMap.containsKey(q.SBQQ__Opportunity2__r.Case__c)) {
        List<SBQQ__Quote__c> quotelst = CaseQuoteMap.get(
          q.SBQQ__Opportunity2__r.Case__c
        );
        quotelst.add(q);
        CaseQuoteMap.put(q.SBQQ__Opportunity2__r.Case__c, quotelst);
      } else {
        CaseQuoteMap.put(
          q.SBQQ__Opportunity2__r.Case__c,
          new List<SBQQ__Quote__c>{ q }
        );
      }
    }

    //Iterating over CaseQuoteMap
    for (id key : CaseQuoteMap.keyset()) {
      for (SBQQ__Quote__c qobj : CaseQuoteMap.get(key)) {
        if (
           qobj.Acorn_Work_Order_Details__c !=null
        ) {
          wointegrated = true;
          // check if quoteCaseComment variable is not null
          if(quoteCaseComment !=null && quoteCaseComment.size() > 0)
          {
              // check if key exists in Map
            if (quoteCaseComment.get(qobj.name) != null) {
                Comment__c comment = new Comment__c();
                //comment.Comment__c = quoteCaseComment.get(qobj.name).replace('@case',(qobj.SBQQ__Opportunity2__r.Case__r.casenumber != null ? qobj.SBQQ__Opportunity2__r.Case__r.casenumber : ''));
                comment.Comment__c = quoteCaseComment.get(qobj.name);
                comment.Case__c = key;
                comment.Case_Number__c = qobj.SBQQ__Opportunity2__r.Case__r.casenumber;
                comment.recordTypeId = recordTypeId;
                if (String.isNotEmpty(qobj.SBQQ__Opportunity2__r.Case__r.Tracking_Number__c))
                 comment.Acorn_Tracking_Number__c = qobj.SBQQ__Opportunity2__r.Case__r.Tracking_Number__c;
                comment.Communication_Log_Type_Name__c = 'Internal';
                comment.Workflow_TeamUser__c = System.UserInfo.getName();
                comment.Acorn_SUser_ID__c = acornUserId;
                comment.Type__c = Constant_Util.OBJECT_CASE;
                finalcommentlist.add(comment); 
              }
          }
        } else {
          wointegrated = false;
        }
      }
      
      // Creating to be closed case list
      /*
      if (wointegrated == true) {
        Case casetobeClosed = new Case();
        casetobeClosed.Id = key;
        casetobeClosed.Status = 'Closed';
        finalcaselist.add(casetobeClosed);
      }
      */
    }
    // Passing case list and comment list for add/update
   // updateCasestoClosed(finalcaselist, finalcommentlist);
   updateCommentList(finalcommentlist);
 }

   /**************************************************
    * Created By:Jatan and Anup
    * CreatedDate:09/02/2022
    * Story: SDT-21248
    * Comment: changes to update the cases to Closed and add case comment
    * **************************************************/
   private static void updateCasestoClosed(
    List<Case> finalcaselist,
    List<Comment__c> finalcommentlist
  ) {

    // check if case list is available
    if (!finalcaselist.isEmpty()) {
      //update finalcaselist;
      List<Database.SaveResult> caseSaveResults = Database.update(
        finalcaselist,
        true
      );
    }
    
    // check if comment list is available
    if (!finalcommentlist.isempty()) {

      //Insert Comments.
      List<Database.SaveResult> caseSaveResults = Database.insert(
        finalcommentlist,
        true
      );
    }
  }
 /**************************************************
    * Created By:Amardeep
    * CreatedDate:09/02/2022
    * Story: SDT-31622
    * Comment: changes to update the case comment
    * **************************************************/
  private static void updateCommentList(
    List<Comment__c> finalcommentlist
  ) {
    
    // check if comment list is available
    if (!finalcommentlist.isempty()) {

      //Insert Comments.
      List<Database.SaveResult> caseSaveResults = Database.insert(
        finalcommentlist,
        true
      );
    }
  }
  /**************************************************
    * Created By:Jatan
    * CreatedDate:28/02/2022
    * Story: SDT-22100
    * Comment: Acorn ticket assignment, This method will assign queue team to acorn ticket based on some criteria. 
    * **************************************************/
  public static void assignQueuetoAcornTicket(string ticketNumber , string TeamQueue , Integration_Request_URLs__mdt REASSIGN_TICKET , string getLoggedInUserAcornId){
      Http h = new Http();
      HttpRequest req = new HttpRequest();
      String Endpoint = REASSIGN_TICKET.End_Point__c;
      Endpoint = Endpoint.replace('{TrackingNumber}', ticketNumber);
      req.setEndpoint(Endpoint);
      req.setMethod(REASSIGN_TICKET.Method__c);
      req.setHeader('Content-Type',REASSIGN_TICKET.Content_Type__c);
      req.setHeader('X-USERID', getLoggedInUserAcornId);
      req.setHeader('X-PARTNER-KEY',REASSIGN_TICKET.Client_Key__c);
      req.setHeader('Authorization',REASSIGN_TICKET.Client_Token__c);
      req.setTimeout(REASSIGN_TICKET.Timeout__c.intValue());
      //String RequestBody = '{"TeamName":"' + TeamQueue + '","Comments":"Testing Auto assignment done for tickets from salesforce"}' ;
      String RequestBody = '{"TeamName":"' + TeamQueue + '","Comments":""}' ;
      req.setBody(RequestBody);

      if(!Test.isRunningTest()) {
        Http http = new Http();
        try{
            HTTPResponse res = http.send(req);                 
            //Executing web service call
            System.debug('STATUS:' + res.getStatus());
            System.debug('STATUS_CODE:' + res.getStatusCode());
        }
        catch(System.CalloutException e){
            //Exception handling goes here..
            system.debug(e);
        }
      }
    }

    /**************************************************
    * Created By:Jatan
    * CreatedDate:26/08/2022
    * Story: SDT-19970
    * Comment: Generate Asset Map in Keys as Product ID and Value as Asset. 
    * **************************************************/
    public static void generateAssetMap(Set<Id> assetIds){
       
        if(assetIds != null && !assetIds.isempty() )
        {
            //assetDetails = [Select Id,ContactId,AccountId,ParentId,RootAssetId,Product2Id,ProductCode,ProductFamily,ProductDescription,IsCompetitorProduct,CreatedDate,CreatedById,LastModifiedDate,LastModifiedById,SystemModstamp,IsDeleted,CurrencyIsoCode,Name,SerialNumber,InstallDate,ManufactureDate,StatusReason,Uuid,ExternalIdentifier,PurchaseDate,UsageEndDate,Status,DigitalAssetStatus,Price,Quantity,Description,OwnerId,RecordTypeId,LocationId,AssetProvidedById,AssetServicedById,IsInternal,AssetLevel,StockKeepingUnit,LastViewedDate,LastReferencedDate,Duration__c,Location__c,Acorn_SBID__c,Acorn_SCOD__c,Acorn_SID__c,Acorn_Update_Datetime__c,Acorn_Vendor_Id__c,BusinessUnit_Name__c,Bypass_Cost_Grid__c,Bypass_MAS__c,Category__c,Container_Position__c,Contract_Notes__c,Cost_Center__c,Cost_Currency__c,Cost_Increment_1__c,Cost_Increment_2__c,Cost_Increment_3__c,Cost_Increment_4__c,Cost_Minimum_Quantity__c,Cost_Model_Type__c,Cost_Price_1__c,Cost_Price_2__c,Cost_Price_3__c,Cost_Price_4__c,Cost_Total_Tax__c,Cost_Unit__c,Cost_UpTo_1__c,Cost_UpTo_2__c,Cost_UpTo_3__c,Cost_UpTo_4__c,Cost__c,Customer_Account_Number__c,EDI_Price_Source__c,End_Date__c,Equipment_Owner__c,Equipment_Size__c,Equipment_Type__c,Every__c,Exception_Comments__c,Exception_Effective_Date__c,Exception_Reason_Detail__c,Exception_Reason__c,Exclude_Holidays__c,Exclude_Saturdays__c,Exclude_Sundays__c,Frequency__c,Friday_AM__c,Friday_Frequency__c,Friday_PM__c,Friday__c,GL_Code__c,Generate_Service_Events__c,Has_Extra_Pickup__c,Is_Active__c,Is_Core_Service__c,Is_Hold_Until_Posted__c,Is_Locally_Billed__c,Is_Monitored__c,Is_Override_Rule__c,Location_Code__c,MAS_Account_Number__c,MAS_Company_Code__c,MAS_Customer_Unique_Id__c,MAS_Library__c,MAS_Line_Number__c,MAS_Setup_Comment__c,MAS_VCR_Code__c,MAS_Waste_Stream__c,Market_Area__c,Material_Grade__c,Material_Grade_Code__c,Material_Type__c,Monday_AM__c,Monday_Frequency__c,Monday_PM__c,Monday__c,Monitored__c,Negotiater_ContactId__c,Negotiater_UserId__c,Occurrence_Type__c,Occurrence__c,Occurs__c,Of_Every1__c,Of_Every2__c,Of_Every3__c,Of_Every__c,Of_Month__c,On_Date__c,On_Day1__c,On_Day2__c,On_Day3__c,On_Day__c,On_the__c,Override_UserId__c,Price_Currency__c,Price_Increment_1__c,Price_Increment_2__c,Price_Increment_3__c,Price_Increment_4__c,Price_Minimum_Quantity__c,Price_Model_Type__c,Price_Price_1__c,Price_Price_2__c,Price_Price_3__c,Price_Price_4__c,Price_Tax_Inclusive__c,Price_Total_Tax__c,Price_Unit__c,Price_UpTo_1__c,Price_UpTo_2__c,Price_UpTo_3__c,Price_UpTo_4__c,Price__c,Project__c,Quantity__c,Reason_for_Change__c,Required_Time_of_Day__c,Saturday_AM__c,Saturday_Frequency__c,Saturday_PM__c,Saturday__c,Schedule_A_Override__c,Schedule__c,Send_Schedule_A__c,Sensitivity_Code__c,Service_Header_Id__c,Service_Info__c,Service_Type__c,Start_Date__c,Sunday_AM__c,Sunday_Frequency__c,Sunday_PM__c,Sunday__c,Supplier__c,Third_Party_Source__c,Thursday_AM__c,Thursday_Frequency__c,Thursday_PM__c,Thursday__c,Time_of_Day_AM__c,Time_of_Day_PM__c,Tuesday_AM__c,Tuesday_Frequency__c,Tuesday_PM__c,Tuesday__c,Vendor_Account_Number__c,Vendor_BU__c,Vendor_ID__c,Vendor_Service_Number__c,Waste_Profile__c,Wednesday_AM__c,Wednesday_Frequency__c,Wednesday_PM__c,Wednesday__c,Weekly_Frequency__c,Cost_Tax_Inclusive__c,MAS_Company_Account_Number__c,MAS_Unique_Text__c,SBID_text_c__c,SCOD_text__c,Core_MAS_Unique__c,Core_Quantity__c,Core_Schedule__c,Lower_Case_Asset_Details__c,Occurrence_Type_Formula__c,Active__c,End_Date_Based_on_Project_code__c,End_Dated_Asset__c,Project_Code__c,Schedule_Type__c,Created_By_User_Id__c,End_Date_Warning__c,Material_Prompt_ID__c,Voice_Prompt__c,Dumpster_Service_Style__c,Dumpster_Style__c,Is_Null_End_Date__c,Originating_Case__c,SBQQ__AdditionalDiscountAmount__c,Is_Self_Service__c,SBQQ__BillingFrequency__c,SBQQ__BillingType__c,SBQQ__Bundle__c,SBQQ__BundledQuantity__c,SBQQ__Bundled__c,SBQQ__ChargeType__c,SBQQ__CombineKey__c,SBQQ__ComponentDiscountedByPackage__c,SBQQ__CreditProductId__c,SBQQ__CurrentSubscription__c,SBQQ__Dimension__c,SBQQ__DiscountScheduleType__c,SBQQ__DiscountSchedule__c,SBQQ__Discount__c,SBQQ__DistributorDiscount__c,SBQQ__DynamicOptionId__c,SBQQ__FromServiceCloud__c,SBQQ__LatestQuoteLine__c,SBQQ__ListPrice__c,SBQQ__MarkupAmount__c,SBQQ__MarkupRate__c,SBQQ__Number__c,SBQQ__OptionDiscountAmount__c,SBQQ__OptionDiscount__c,SBQQ__OptionLevel__c,SBQQ__OptionType__c,SBQQ__OrderProduct__c,SBQQ__OriginalUnitCost__c,SBQQ__PackageProductCode__c,SBQQ__PackageProductDescription__c,SBQQ__PartnerDiscount__c,SBQQ__PriceDimension__c,SBQQ__PricingMethod__c,SBQQ__ProductOption__c,SBQQ__QuoteLine__c,SBQQ__RegularPrice__c,SBQQ__RenewalUpliftRate__c,SBQQ__RequiredByAsset__c,SBQQ__RequiredById__c,SBQQ__RequiredByProduct__c,SBQQ__RequiredBySubscription__c,SBQQ__RevisedAsset__c,SBQQ__RootAsset__c,SBQQ__RootId__c,SBQQ__SegmentIndex__c,SBQQ__SegmentKey__c,SBQQ__SegmentLabel__c,SBQQ__SubscriptionEndDate__c,SBQQ__SubscriptionQuoteLine__c,SBQQ__SubscriptionStartDate__c,SBQQ__Subscription__c,SBQQ__TermDiscountSchedule__c,SBQQ__UnitCost__c,SBQQ__VirtualAsset__c,CPQ_Product__c,CPQ_Material__c, RecordType.DeveloperName , Account_Position__c, MASBox__c from asset where id=:assetIds and Is_Active__c=true]; 
            //SDT-38285 start
            //Added Supplier__r.Parent_Vendor_ID__c for story SDT-39662
            assetDetails = [Select Id,Supplier__r.Parent_Vendor_ID__c,ContactId,AccountId,ParentId,RootAssetId,Product2Id,ProductCode,ProductFamily,ProductDescription,IsCompetitorProduct,CreatedDate,CreatedById,LastModifiedDate,LastModifiedById,SystemModstamp,IsDeleted,CurrencyIsoCode,Name,SerialNumber,InstallDate,ManufactureDate,StatusReason,Uuid,ExternalIdentifier,PurchaseDate,UsageEndDate,Status,DigitalAssetStatus,Price,Quantity,Description,OwnerId,RecordTypeId,LocationId,AssetProvidedById,AssetServicedById,IsInternal,AssetLevel,StockKeepingUnit,LastViewedDate,LastReferencedDate,Duration__c,Location__c,Acorn_SBID__c,Acorn_SCOD__c,Acorn_SID__c,Acorn_Update_Datetime__c,Acorn_Vendor_Id__c,BusinessUnit_Name__c,Bypass_Cost_Grid__c,Bypass_MAS__c,Category__c,Container_Position__c,Contract_Notes__c,Cost_Center__c,Cost_Currency__c,Cost_Increment_1__c,Cost_Increment_2__c,Cost_Increment_3__c,Cost_Increment_4__c,Cost_Minimum_Quantity__c,Cost_Model_Type__c,Cost_Price_1__c,Cost_Price_2__c,Cost_Price_3__c,Cost_Price_4__c,Cost_Total_Tax__c,Cost_Unit__c,Cost_UpTo_1__c,Cost_UpTo_2__c,Cost_UpTo_3__c,Cost_UpTo_4__c,Cost__c,Customer_Account_Number__c,EDI_Price_Source__c,End_Date__c,Equipment_Owner__c,Equipment_Size__c,Equipment_Type__c,Every__c,Exception_Comments__c,Exception_Effective_Date__c,Exception_Reason_Detail__c,Exception_Reason__c,Exclude_Holidays__c,Exclude_Saturdays__c,Exclude_Sundays__c,Frequency__c,Friday_AM__c,Friday_Frequency__c,Friday_PM__c,Friday__c,GL_Code__c,Generate_Service_Events__c,Has_Extra_Pickup__c,Is_Active__c,Is_Core_Service__c,Is_Hold_Until_Posted__c,Is_Locally_Billed__c,Is_Monitored__c,Is_Override_Rule__c,Location_Code__c,MAS_Account_Number__c,MAS_Company_Code__c,MAS_Customer_Unique_Id__c,MAS_Library__c,MAS_Line_Number__c,MAS_Setup_Comment__c,MAS_VCR_Code__c,MAS_Waste_Stream__c,Market_Area__c,Material_Grade__c,Material_Type__c,Monday_AM__c,Monday_Frequency__c,Monday_PM__c,Monday__c,Monitored__c,Negotiater_ContactId__c,Negotiater_UserId__c,Occurrence_Type__c,Occurrence__c,Occurs__c,Of_Every1__c,Of_Every2__c,Of_Every3__c,Of_Every__c,Of_Month__c,On_Date__c,On_Day1__c,On_Day2__c,On_Day3__c,On_Day__c,On_the__c,Override_UserId__c,Price_Currency__c,Price_Increment_1__c,Price_Increment_2__c,Price_Increment_3__c,Price_Increment_4__c,Price_Minimum_Quantity__c,Price_Model_Type__c,Price_Price_1__c,Price_Price_2__c,Price_Price_3__c,Price_Price_4__c,Price_Tax_Inclusive__c,Price_Total_Tax__c,Price_Unit__c,Price_UpTo_1__c,Price_UpTo_2__c,Price_UpTo_3__c,Price_UpTo_4__c,Price__c,Project__c,Quantity__c,Reason_for_Change__c,Required_Time_of_Day__c,Saturday_AM__c,Saturday_Frequency__c,Saturday_PM__c,Saturday__c,Schedule_A_Override__c,Schedule__c,Send_Schedule_A__c,Sensitivity_Code__c,Service_Header_Id__c,Service_Info__c,Service_Type__c,Start_Date__c,Sunday_AM__c,Sunday_Frequency__c,Sunday_PM__c,Sunday__c,Supplier__c,Third_Party_Source__c,Thursday_AM__c,Thursday_Frequency__c,Thursday_PM__c,Thursday__c,Time_of_Day_AM__c,Time_of_Day_PM__c,Tuesday_AM__c,Tuesday_Frequency__c,Tuesday_PM__c,Tuesday__c,Vendor_Account_Number__c,Vendor_BU__c,Vendor_ID__c,Vendor_Service_Number__c,Waste_Profile__c,Wednesday_AM__c,Wednesday_Frequency__c,Wednesday_PM__c,Wednesday__c,Weekly_Frequency__c,Cost_Tax_Inclusive__c,MAS_Company_Account_Number__c,MAS_Unique_Text__c,SBID_text_c__c,SCOD_text__c,Core_MAS_Unique__c,Core_Quantity__c,Core_Schedule__c,Lower_Case_Asset_Details__c,Occurrence_Type_Formula__c,Active__c,End_Date_Based_on_Project_code__c,End_Dated_Asset__c,Project_Code__c,Schedule_Type__c,Created_By_User_Id__c,End_Date_Warning__c,Material_Prompt_ID__c,Voice_Prompt__c,Dumpster_Service_Style__c,Dumpster_Style__c,Is_Null_End_Date__c,Originating_Case__c,SBQQ__AdditionalDiscountAmount__c,Is_Self_Service__c,SBQQ__BillingFrequency__c,SBQQ__BillingType__c,SBQQ__Bundle__c,SBQQ__BundledQuantity__c,SBQQ__Bundled__c,SBQQ__ChargeType__c,SBQQ__CombineKey__c,SBQQ__ComponentDiscountedByPackage__c,SBQQ__CreditProductId__c,SBQQ__CurrentSubscription__c,SBQQ__Dimension__c,SBQQ__DiscountScheduleType__c,SBQQ__DiscountSchedule__c,SBQQ__Discount__c,SBQQ__DistributorDiscount__c,SBQQ__DynamicOptionId__c,SBQQ__FromServiceCloud__c,SBQQ__LatestQuoteLine__c,SBQQ__ListPrice__c,SBQQ__MarkupAmount__c,SBQQ__MarkupRate__c,SBQQ__Number__c,SBQQ__OptionDiscountAmount__c,SBQQ__OptionDiscount__c,SBQQ__OptionLevel__c,SBQQ__OptionType__c,SBQQ__OrderProduct__c,SBQQ__OriginalUnitCost__c,SBQQ__PackageProductCode__c,SBQQ__PackageProductDescription__c,SBQQ__PartnerDiscount__c,SBQQ__PriceDimension__c,SBQQ__PricingMethod__c,SBQQ__ProductOption__c,SBQQ__QuoteLine__c,SBQQ__RegularPrice__c,SBQQ__RenewalUpliftRate__c,SBQQ__RequiredByAsset__c,SBQQ__RequiredById__c,SBQQ__RequiredByProduct__c,SBQQ__RequiredBySubscription__c,SBQQ__RevisedAsset__c,SBQQ__RootAsset__c,SBQQ__RootId__c,SBQQ__SegmentIndex__c,SBQQ__SegmentKey__c,SBQQ__SegmentLabel__c,SBQQ__SubscriptionEndDate__c,SBQQ__SubscriptionQuoteLine__c,SBQQ__SubscriptionStartDate__c,SBQQ__Subscription__c,SBQQ__TermDiscountSchedule__c,SBQQ__UnitCost__c,SBQQ__VirtualAsset__c,CPQ_Product__c,CPQ_Material__c, RecordType.DeveloperName , Account_Position__c, MASBox__c, Material_Grade_Code__c, Month_Relative_Interval__c, Month_Relative__c from asset where id=:assetIds and Is_Active__c=true]; 
            //SDT-38285 End
        }

        For(Asset asset : assetDetails){
            if(asset!= null && asset.RecordType.DeveloperName == Constant_Util.SERVICE_DETAILS) 
            {
                assetProductMap.put(asset.id,asset);
            }
            //TCS-pkulkarn-11-Aug-2023-Added for SDT-31408
            if(asset!= null && asset.RootAssetId == asset.Id)
            {
                assetBundleMap.put(asset.id,asset);
            }
        }
    }

    /**************************************************
    * Created By:Jatan
    * CreatedDate:26/08/2022
    * Story: SDT-19970
    * Comment: This will compare the Asset and QuoteLine data to identify the change in data. 
    * **************************************************/
    public static AssetQuoteProcurementController.comparisonResponseModel compareAssetQuoteLineDetails(Asset asset ,SBQQ__QuoteLine__c toCompareQL, SBQQ__QuoteLine__c parentQL, boolean debugRequired, Set<string> updateBaselineFields, Set<string> endAndExtendBaselineFields, Set<string> excludedFields, List<Asset_Quoteline_Mapping__mdt> assetQuoteLineMappings){

        AssetQuoteProcurementController.comparisonResponseModel responseModel = new AssetQuoteProcurementController.comparisonResponseModel();
        // Assigning Default Values
        responseModel.isUpdateBaseline = responseModel.isEndAndExtendBaseline = false;
        responseModel.isQLMached= true;

        //Create new Quoteline
        SBQQ__QuoteLine__c ql = new SBQQ__QuoteLine__c ();
        //Convert Asset to Quoteline
        //SBQQ__QuoteLine__c convertedQL = transformationHelper.ConvertAssetToQuoteLine(asset,ql, parentQL, True, True);
        SBQQ__QuoteLine__c convertedQL = transformationHelper.ConvertAssetToQuoteLineUpdated(asset,ql, parentQL, True, True , assetQuoteLineMappings, True);

        //Asset Map
        String serializeAssetQL = JSON.serialize(convertedQL);
        Map<String, Object> assetMap = (Map<String, Object>)JSON.deserializeUntyped(serializeAssetQL);
        //Quoteline Map 
        String serializeQL = JSON.serialize(toCompareQL);
        Map<String, Object> qlMap = (Map<String, Object>)JSON.deserializeUntyped(serializeQL);

        // Changes for SDT-27107
        //Adding additional fields that are not present or directly mapped.
        metaDataQLFields.addAll(additionFieldsforMetadata);
       
        // local basline variables
        Boolean isUpdateBaseline =false, isEndAndExtendBaseline = false;

        //Looping through Map to identify change in data.
        for(string Key : metaDataQLFields)
        {
            key =key.trim();
            // if(key == 'LocationPositionName__c'){
                // system.debug('assetMap'+ assetMap.containsKey(key));
                // system.debug('Matched '+'Key >>> '+Key+ ' -- QL Value >>> '+qlMap.get(Key) + ' -- Asset Value >>>'+assetMap.get(Key));
                // system.debug('assetMap mathed' +assetMap.get(Key) != qlMap.get(Key));
            // }
            
            if(assetMap.containsKey(key))
            {
                //if(assetMap.get(Key) != qlMap.get(Key))
                if(!checkAssetAndQuoteLineFields(assetMap, qlMap, key, debugRequired))
                {
                    if(debugRequired)
                    {
                      system.debug(' Quote Line '+toCompareQL.name + ' Not Matched '+'Key >>> '+Key+ ' -- QL Value >>> '+qlMap.get(Key) + ' -- Asset Value >>>'+assetMap.get(Key));
                    }
                     // For End and Extend base line Case: Asset has EndDate and updated in QL
                    if((key == 'SBQQ__EndDate__c' && assetMap.get(Key) != null && qlMap.get(Key) != null))
                    {
                        isEndAndExtendBaseline = true;
                    }
                    // For End and Extend base line Case: Asset has EndDate and date removed in QL
                    else if(key == 'SBQQ__EndDate__c' && assetMap.get(Key) != null && qlMap.get(Key) == null){
                        isUpdateBaseline = true;
                    }
                    // Condition to check if Key matched with Only Update BaseLine case
                    // For Update base line Case: Asset has EndDate and updated NULL in QL
                    // Special Logic For End Date :: If End date is changed (Not null in Asset and QuoteLine) then updating EndandExtend flag 
                    else if(endAndExtendBaselineFields.contains(key))
                    {
                        isEndAndExtendBaseline = true;
                    }
                    // Special Logic For End Date :: If End date is null (null in Asset and QuoteLine) then updating Updatebaseline flag 
                    else if(updateBaselineFields.contains(key))
                    {
                        // Condition to check if Key matched with End and Extend BaseLine case
                        // For End and Extend base line Case: Asset has EndDate and updated in QL
                        isUpdateBaseline = true;
                    } 
                    // End and Extend found then breaking the loop
                    if(isEndAndExtendBaseline)
                    {
                        break;
                    }
                }
            }
        }

        if(isUpdateBaseline)
        {
            responseModel.isUpdateBaseline = true;
            responseModel.isQLMached = false;
        }
        if(isEndAndExtendBaseline)
        {
            responseModel.isEndAndExtendBaseline = true;	
            responseModel.isQLMached = false;
        }
    return responseModel;
}

// Method to check Asset and Quote Line fields
public static Boolean checkAssetAndQuoteLineFields(Map<String, Object> assetMap, Map<String, Object> qlMap, String key, boolean debugRequired)
{
   
    // Replacing 'PricingUnitMethod__c' Key as we are converting this field for comparision
    if(key == 'PricingUnitMethod__c'){
        Key='SBQQ__PricingMethod__c';
    }
    // Assigning Asset and QuoteLine values to the Object Variables
    Object assetFieldValue=assetMap.get(Key);
    Object QLFieldValue =qlMap.get(Key);
    

    // Special case for CompanyProjectName__c to Ignore "-" from default QL field
    if(assetFieldValue == null && QLFieldValue == '-')
    {
        return true;
    }
    // Special case for QL Price to because CPQ package by default setting up Price as 0 if Price is null
    else if(assetFieldValue == null && QLFieldValue == 0.00)
    {
        return true;
    }
    // Specific Case for DoNotCreateTaskGridTickets__c, SBQQ__EffectiveStartDate__c as this field not exist in Asset
    // EXCEPTION_EFFECTIVE_DATE because it was randomly updating 
    // Exception_Comments__c because we are updating this while creating new Quotes
    // Final_Frequency__c as this is formula field
    else if(excludedFields.contains(key))
    {
        return true; 
    }
    // Compare other fields
    else if(assetFieldValue == QLFieldValue)
    {
        return true; 
    }
    else
    {
        return false;
    }
}

   /**************************************************
    * Created By:Jatan
    * CreatedDate:26/08/2022
    * Story: SDT-19970
    * Comment: This will generate the JSON response for API integration.
    * 28-Jul-2023 : SDT-30514 and SDT-30515-Added Fourth parameter for Vendor_Commit_Date__c 
    * **************************************************/
    global static String integrationToAPI(String quoteName , boolean assetIntegration , boolean debugRequired, Boolean integrationCall) { 
        //TCS-pkulkarn-2-Sep-2024-SDT-41371-Tech Debt-Added 4th parameter to the method signature
        // From QuoteName get QuoteId and update the flag of resubmit.
        String QuoteId = '';
        String sQuoteType = '';		//TCS-pkulkarn-SDT-33101-11-Nov-2024-Added
        Map<String,Object> finalMap = new Map<String,Object>();
        Set<String> setFields = new Set<String>();
        Set<String> quoteOrderFields = new Set<String>();
        List<PricingJsonSetting__mdt> lststart = new List<PricingJsonSetting__mdt>();
        List<PricingJsonSetting__mdt> lstIntegrationHeader = new List<PricingJsonSetting__mdt>();
        List<PricingJsonSetting__mdt> lstIntegrationDetail = new List<PricingJsonSetting__mdt>();
        List<PricingJsonSetting__mdt> lstWorkorders = new List<PricingJsonSetting__mdt>();
        Id lastUpdatedQuoteId = null; //TCS-pkulkarn-9-Aug-2023-Added for SDT-31408
        //sdt-37527
        String materialTypeValue;
        String materialGradeValue;
        List<String> materialTypeValueList = new List<String>();
        List<String> materialGradeValueList = new List<String>();
        List<Material_type_Material_Grade_mapping__mdt> materialMapping = new List<Material_type_Material_Grade_mapping__mdt>();
        Map<String, String> quoteToMaterialGrade = new Map<String, String>();
        Map<String, String> quoteToMaterialGradeCode = new Map<String, String>();

        //sdt-37527

        // Getting all metadata where isActive true
        List<PricingJsonSetting__mdt> lstRecords = new List<PricingJsonSetting__mdt>([Select Attribute__c,Default_Value__c,IsDisable__c,Json_Node__c,Field_API_Name__c,Object_API_Name__c from PricingJsonSetting__mdt where IsDisable__c != true]);
        for(PricingJsonSetting__mdt objRec: lstRecords){
            if(objRec.Field_API_Name__c != null){
                List<String> lstStr = (objRec.Field_API_Name__c).split(',');
                for(String str : lstStr){
                    if(objRec.Object_API_Name__c == 'SBQQ__QuoteLine__c'){
                        setFields.add(str);
                        metaDataQLFields.add(str);
                    } else if(objRec.Object_API_Name__c == 'Quote_Order__c'){
                        quoteOrderFields.add(str);
                    }
                } 
            }
            
            if(objRec.Json_Node__c == 'Start'){
                lststart.add(objRec);
            }
            else if(objRec.Json_Node__c == 'IntegrationHeader'){
                lstIntegrationHeader.add(objRec);
            }
            else if(objRec.Json_Node__c == 'IntegrationDetail'){
                lstIntegrationDetail.add(objRec);
            }else if(objRec.Json_Node__c == 'Workorders'){
                lstWorkorders.add(objRec);
            }
        }
        List<Map<String,String>> lstMapObjValue = new List<Map<String,String>>();
        List<String> qlIdList = new List<String>();
        Map<String,SBQQ__QuoteLine__c> mapParentQLI = new Map<String,SBQQ__QuoteLine__c>();
        Map<String, String> quoteToMaterialCode = new Map<String, String>();
        Map<String,list<SBQQ__QuoteLine__c>> mapChildQLI = new Map<String,List<SBQQ__QuoteLine__c>>();
        List<Map<String,Object>> lstqlDetails = new List<Map<String,Object>>();
        //SDT 33101 New
        Boolean amendmentFlag =false;
        //List<Map<String,Object>> lstDetails = new List<Map<String,Object>>();
        //Getting List or WasteStream Lines.
        //Developer : Jatan Sharma
        //Changes related SDT-19791,SDT-19790,SDT-19782,SDT-19738,SDT-19734,SDT-19723,SDT-19297
        List<SBQQ__QuoteLine__c> materialCode = [SELECT Id, SBQQ__Product__r.Name, SBQQ__Product__r.ProductCode, SBQQ__RequiredBy__r.SBQQ__RequiredBy__c  
                                                FROM SBQQ__QuoteLine__c 
                                                WHERE SBQQ__Product__r.Family = 'Waste Stream' 
                                                AND SBQQ__Quote__r.name =: quoteName];
        // Added Customer Requested Date and Vendor Commit Date for Story 31408 , Story 30515
        //TCS-pkulkarn-8-Aug-2023-Added QuoteLine's Vendor_Commit_Date__c, SBQQ__RequiredBy__r.Vendor_Commit_Date__c, Quote_SLA_Date__c
        //TCS-pkulkarn-SDT-32782-Added SBQQ__Quote__r.Name, SBQQ__Quote__r.SBQQ__Status__c to the query
        //SDT32803 adding CreatedBy.User_categorization_code__c,LastModifiedBy.User_categorization_code__c
        //added for SDT34351 ,SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__r.Reference_Number__c
        //Added SBQQ__Quote__r.SBQQ__Type__c for sdt-38052
        List<SBQQ__QuoteLine__c> lstQuoteLine = Database.Query('Select '+ String.join(new List<String>(setFields), ', ') +','+ String.join(new List<String>(additionFieldsforMetadata), ', ') +
                                                            ',SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__r.Reference_Number__c,CreatedBy.User_categorization_code__c,Material_Type__c,LastModifiedBy.User_categorization_code__c,SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__r.RecordType.Name,AssetId__c,SBQQ__ProductOption__r.SBQQ__ConfiguredSKU__r.Family,SBQQ__ProductOption__r.SBQQ__Feature__r.Name,SBQQ__Product__c,EventRecurrence__c,SBQQ__ProductOption__r.SBQQ__ProductCode__c,SBQQ__ProductFamily__c,SBQQ__ProductName__c,SBQQ__RequiredBy__c,SBQQ__Product__r.Family,SBQQ__RequiredBy__r.SBQQ__RequiredBy__c, SBQQ__Quote__r.Customer_Request_Date__c, SBQQ__Quote__r.Vendor_Commit_Date__c, Vendor_Commit_Date__c, SBQQ__RequiredBy__r.Vendor_Commit_Date__c, Quote_SLA_Date__c, SBQQ__RequiredBy__r.SBQQ__Product__c, SBQQ__Quote__r.Name, SBQQ__Quote__r.SBQQ__Type__c,SBQQ__Quote__r.SBQQ__Status__c, '+ // SDT-31973
                                                            '(Select '+ String.join(new List<String>(quoteOrderFields), ', ') + ',Id,Product_Type__c,Occurrence_Type__c,Duration__c, Service_Quote_Line__r.SBQQ__ProductFamily__c  from Quote_Orders1__r) '+ //Changes for SDT-30118
                                                            ' from SBQQ__QuoteLine__c where SBQQ__Quote__r.Name = :quoteName and Bypass_Acorn_Integration__c = FALSE Order By SBQQ__Number__c');
        //SDT-37527
        List<SBQQ__QuoteLine__c> materialGrade = [SELECT Id, SBQQ__Product__r.Name,material_type__c,materialGrade__c,SBQQ__Product__r.ProductCode, SBQQ__RequiredBy__r.SBQQ__RequiredBy__c  
                                                FROM SBQQ__QuoteLine__c 
                                                WHERE SBQQ__Product__r.Family = 'Waste Category' 
                                                AND SBQQ__Quote__r.name =: quoteName];
       // System.debug('materialGrade^^^ '+materialGrade);
         for(SBQQ__QuoteLine__c materialGradeQL: materialGrade)
        {
           
            if(!String.isempty(materialGradeQL.SBQQ__Product__r.Name) && !String.isempty(materialGradeQL.MaterialGrade__c)){
                materialTypeValue =materialGradeQL.SBQQ__Product__r.Name;   
                materialgradeValue =materialGradeQL.materialGrade__c;
            }
              if(materialTypeValue != '' && materialGradeValue != ''){
                    materialTypeValueList.add(materialTypeValue);  //Trash, Cardboard
                    materialGradeValueList.add(materialgradeValue); //International Trash, Waxed OCC
              }
                    //System.debug('materialTypeValueList^^^ '+materialTypeValueList);
//System.debug('materialGradeValueList^^^ '+materialGradeValueList);
        }
         //SDT-37527
        
        // Local variables to store Customer Requested Date and Vendor Commit Date for Story 31408 , Story 30515
        Date vendorCommitDate;
        List<SBQQ__QuoteLine__c> tobeStartDateUpdateQLs = new List<SBQQ__QuoteLine__c>();
        //SDT 34351
        List<SBQQ__QuoteLine__c> tobeExceptionDetailsUpdateQLs = new List<SBQQ__QuoteLine__c>();
        Set<Id> surChargeIds = new Set<Id>();
        for(SBQQ__QuoteLine__c objQL: lstQuoteLine)
        {
            system.debug(' objQL.SBQQ__ProductName__c'+ objQL.SBQQ__ProductName__c);
            if(objQL.SBQQ__RequiredBy__c == null){
                mapParentQLI.put(objQL.Id, objQL); // Getting the Primary QuoteLine 
                assetIds.add(objQL.AssetId__c);		//TCS-pkulkarn-9-Aug-2023-Added for SDT-31408
            }
            else{
                if(!mapChildQLI.containsKey(objQL.SBQQ__RequiredBy__c)){
                    mapChildQLI.put(objQL.SBQQ__RequiredBy__c, new List<SBQQ__QuoteLine__c>());
                }
                
                // Changes for 30118 : 
                if(objQL.SBQQ__Product__r.Family !=SURCHARGES_AND_FEES)
                    mapChildQLI.get(objQL.SBQQ__RequiredBy__c).add(objQL);

                if(objQL.SBQQ__Product__r.Family ==SURCHARGES_AND_FEES && mapParentQLI.containsKey(objQL.SBQQ__RequiredBy__c))
                {
                    surChargeIds.add(objQL.Id);
                    mapChildQLI.get(objQL.SBQQ__RequiredBy__c).add(objQL);
                }
                if(surChargeIds.contains(objQL.SBQQ__RequiredBy__c))
                {
                    mapChildQLI.get(objQL.SBQQ__RequiredBy__r.SBQQ__RequiredBy__c).add(objQL);
                }
                //Store the Asset Ids of child QL for SDT-19970
                assetIds.add(objQL.AssetId__c);
            }

            
            //Developer : Jatan Sharma
            //Changes related SDT-19791,SDT-19790,SDT-19782,SDT-19738,SDT-19734,SDT-19723,SDT-19297
            for (SBQQ__QuoteLine__c WSLineItem : materialCode){
                 // Changes for 30118 
                If((WSLineItem.SBQQ__RequiredBy__r.SBQQ__RequiredBy__c == objQL.SBQQ__RequiredBy__c || WSLineItem.SBQQ__RequiredBy__r.SBQQ__RequiredBy__c == objQL.SBQQ__RequiredBy__r.SBQQ__RequiredBy__c) && !quoteToMaterialCode.containsKey(objQL.SBQQ__RequiredBy__c)){
                    quoteToMaterialCode.put(objQL.SBQQ__RequiredBy__c , WSLineItem.SBQQ__Product__r.ProductCode);
                }
            }
            //SDT-37527
           for (SBQQ__QuoteLine__c WCLineItem : materialGrade){
                 // Changes for 30118 
                 //System.debug('WCLineItem.SBQQ__RequiredBy__c^^ ' +WCLineItem.SBQQ__RequiredBy__c);
                      //System.debug('objQL.SBQQ__RequiredBy__c^^ ' +objQL.SBQQ__RequiredBy__c);
                                
                If(WCLineItem.SBQQ__RequiredBy__c == objQL.SBQQ__RequiredBy__c && !quoteToMaterialGrade.containsKey(objQL.Id)){
                    
                    quoteToMaterialGrade.put(objQL.Id , WCLineItem.SBQQ__Product__r.Name);
                    System.debug('quoteToMaterialGrade^^ ' +quoteToMaterialGrade);

                    
                }
            }
            //SDT-37527
            //Developer : Jatan Sharma
            //Changes related SDT-19791,SDT-19790,SDT-19782,SDT-19738,SDT-19734,SDT-19723,SDT-19297
            //if(objQL.SBQQ__Product__r.Family == 'Waste Stream' && !quoteToMaterialCode.containsKey(objQL.SBQQ__RequiredBy__c)) {
            //   quoteToMaterialCode.put(objQL.SBQQ__RequiredBy__c , objQL.SBQQ__ProductOption__r.SBQQ__ProductCode__c);
            //}

            qlIdList.add(objQL.Id);
            QuoteId =objQL.SBQQ__Quote__c;
            sQuoteType = objQL.SBQQ__Quote__r.SBQQ__Type__c;	//TCS-pkulkarn-SDT-33101-11-Nov-2024-Added
            // Assigning variables Vendor Commit Date for Story 31408 , Story 30515
            //vendorCommitDate = quoteVendorCommitDate;		//TCS-pkulkarn-9-Aug-2023-Commented for SDT-31408
        }
        //sdt-37527
        if(!materialTypeValueList.isEmpty() && !materialGradeValueList.isEmpty()){
            //System.debug('here34^^^ ');
        materialMapping = [SELECT Material_Type__c,Material_Grade__c,Material_Grade_Code__c  FROM Material_type_Material_Grade_mapping__mdt WHERE Material_Type__c IN :materialTypeValueList and Material_Grade__c IN : materialGradeValueList];
        
        //System.debug('materialMapping^^^ ' +materialMapping);
        }
        //sdt-37527

        //Changes for SDT-19970
        //This will generate the AssetMap
        if(assetIds != null && !assetIds.isempty())
        {
            generateAssetMap(assetIds);
        }
        //End

        // DoResyncOutBoundcall__c need to be set  false in order to ReSync to work ---------
        if(!assetIntegration){
            SBQQ__Quote__c oQuote = new SBQQ__Quote__c(); 
            oQuote.Id =  [select id from  SBQQ__Quote__c where name=:quoteName][0].id;
            oQuote.DoResyncOutBoundcall__c = false;
            //Changes added for story SDT-19971, This will update integration status to In-Progress.
            oQuote.Integration_Status__c = 'In Progress';
            system.debug('oQuote--'+oQuote);
            update oQuote;
        ///////////------------------------------------------------
        }
        List<Map<String,Object>> lstHeader = new List<Map<String,Object>>();

        // Changes for SDT-30514
        // Update baseline fields
        Set<string> updateBaselineFields = transformationHelper.readFieldSet('Update_Baseline','SBQQ__QuoteLine__c');
        // End and Extend fields
        Set<string> endAndExtendBaselineFields = transformationHelper.readFieldSet('End_and_Extend_Baseline','SBQQ__QuoteLine__c');
        // Excluded Fields
        Set<string> excludedFields = transformationHelper.readFieldSet('Integration_Excluded_Fields','SBQQ__QuoteLine__c');
        // get the Asset Quote Line Mapping for specific fields
        List<Asset_Quoteline_Mapping__mdt> assetQuoteLineMappings = [SELECT AssetDataType__c,AssetField__c,AssetFieldValue__c,IsActive__c,QuoteLineField__c,QuoteLineFieldValue__c FROM Asset_Quoteline_Mapping__mdt Where IsActive__c = true];

        //SDT 33101 reverse/TCS-pkulkarn-SDT-33101-11-Nov-2024-Added new method //SDT 33101 New
        Id amendmentQuoteApprovedBundleId = null;
        if(sQuoteType==Constant_Util.QUOTE_TYPE_AMEND){
            amendmentQuoteApprovedBundleId = QuoteOnlyController.getApproveBundleFromAmendmentQuote(QuoteId);//, sQuoteType);
        }
        //Id amendmentQuoteApprovedBundleId = QuoteOnlyController.getApproveBundleFromAmendmentQuote(QuoteId, sQuoteType);
        //TCS-pkulkarn-SDT-33101-11-Nov-2024-End //SDT 33101 New
        
        for(SBQQ__QuoteLine__c objQLI :mapParentQLI.values())
        {
            //SDT 33101 reverse/TCS-pkulkarn-SDT-33101-11-Nov-2024-Added new method //SDT 33101 New
            if(amendmentQuoteApprovedBundleId != null && amendmentQuoteApprovedBundleId != objQLI.Id && integrationCall == true)
            {
            	continue;	//Skip the non approved Bundle from Integration for Amendment quote
        	}
            //TCS-pkulkarn-SDT-33101-11-Nov-2024-End
            
            List<Map<String,Object>> lstDetails = new List<Map<String,Object>>();
            
            //TCS-pkulkarn-14-Aug-2023-Added for SDT-31408
            Date bundleVendorCommitDate = null;
            if(objQLI.Quote_SLA_Date__c == null && objQLI.Vendor_Commit_Date__c == null)
                bundleVendorCommitDate = system.now().date().addDays(7);
            else if(objQLI.Quote_SLA_Date__c != null && objQLI.Vendor_Commit_Date__c == null)
                bundleVendorCommitDate = objQLI.Quote_SLA_Date__c;
            else
                bundleVendorCommitDate = objQLI.Vendor_Commit_Date__c;
            //TCS-pkulkarn-End 
            
            //TCS-pkulkarn-13-Oct-2023-Added for SDT-32782
            Map<Id, SBQQ__QuoteLine__c> bundlewisePickupQuoteLinesMap = new Map<Id, SBQQ__QuoteLine__c>();
            Map<Id, SBQQ__QuoteLine__c> bundlewiseExtraPickupQuoteLinesMap = new Map<Id, SBQQ__QuoteLine__c>();
            Boolean isExtraPickupLineUpdated = false;
            Boolean isPickupChanged = false;
            //pkulkan-TCS-SDT-39624-Added following two variables to store Start Date of Pickup and Extra Pickup per bundle
            Map<Id, Date> bundlewisePickupStartDateMap = new Map<Id, Date>();
            Map<Id, Date> bundlewiseExtraPickupStartDateMap = new Map<Id, Date>();
            
            //SDT32803
            boolean changeExceptionReasonFlag=false;
			if(!mapChildQLI.isEmpty() && mapChildQLI!=null){
				for(SBQQ__QuoteLine__c objChild: mapChildQLI.get(objQLI.Id))
				{
					if(objChild.SBQQ__ProductName__c == Constant_Util.PR_EXTRA_PICKUP)
                    {
						bundlewiseExtraPickupQuoteLinesMap.put(objChild.SBQQ__RequiredBy__c, objChild);
                        bundlewiseExtraPickupStartDateMap.put(objChild.SBQQ__RequiredBy__c, objChild.SBQQ__StartDate__c);	//pkulkan-TCS-SDT-39624-Added
                    }
				}
			}
            //End-SDT-32782
            
            if(lstIntegrationDetail.size() > 0 && mapChildQLI.containsKey(objQLI.Id)){
                // Loop to add IntegrationDetails
                for(SBQQ__QuoteLine__c objChild: mapChildQLI.get(objQLI.Id)){
                    
                    //pkulkarn-8-Aug-2023-Added following code for SDT-31408
                    if(objChild.SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__r.RecordType.Name == Constant_Util.New_Service_Case)
                    {
                        if(lastUpdatedQuoteId != objChild.SBQQ__Quote__c)
                        {
                            tobeStartDateUpdateQLs = CheckAndUpdateVendorCommitDateAndStartDate(objChild.SBQQ__Quote__c, tobeStartDateUpdateQLs);                            
                            lastUpdatedQuoteId = objChild.SBQQ__Quote__c;
                        }
                    }
					
                    if(objChild.SBQQ__Product__r.Family != 'Waste Stream'){
                        //Add Change code start here for story SDT-19970, Only Run for Update Asset Case
                        //Changes for SDT-26868
                        if(objChild.SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__r.RecordType.Name != Constant_Util.New_Service_Case)
                        {
                            caseType = objChild.SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__r.RecordType.Name;
                            Asset asset =  assetProductMap.get(objChild.AssetId__c );
                            //If result is True continue the loop to iterate next data.
                            if(asset != null ){
                                // Changes for SDT-27107
                            AssetQuoteProcurementController.comparisonResponseModel responseModel = compareAssetQuoteLineDetails(asset,objChild,objQLI,false,updateBaselineFields,endAndExtendBaselineFields, excludedFields, assetQuoteLineMappings);

                            system.debug('responseModel > '+responseModel);
                            if (responseModel!= null && responseModel.isQLMached == true){
                                continue;
                            }
                            else{
                                // if QL's not matched then assigning Vendor Commit Date and Creating new QL list to update for Update BaseLine Case
				//TCS-pkulkarn-13-Oct-2023-Added for SDT-32782
                            		if(objChild.SBQQ__ProductName__c == Constant_Util.PR_PICKUP)
                                    {
                                        bundlewisePickupQuoteLinesMap.put(objChild.SBQQ__RequiredBy__c, objChild);	
                                        isPickupChanged = true;
                                        bundlewisePickupStartDateMap.put(objChild.SBQQ__RequiredBy__c, objChild.SBQQ__StartDate__c);	//pkulkan-TCS-SDT-39624-Added
                                    }
                            		//End-SDT-32782
                                tobeStartDateUpdateQLs= AssignVendorCommitToQLs(bundleVendorCommitDate, responseModel, objChild, tobeStartDateUpdateQLs, debugRequired);
				//TCS-pkulkarn-13-Oct-2023-Added for SDT-32782
            			//Handle Extra pick changes-Retrieve List of Extra Pickup Quote Lines if Pickup line start date is changed
	                            if(bundlewiseExtraPickupQuoteLinesMap.size() > 0 && bundlewiseExtraPickupQuoteLinesMap.containsKey(objChild.SBQQ__RequiredBy__c) && isPickupChanged == true && isExtraPickupLineUpdated == false)
	                            {
                                    //pkulkan-TCS-SDT-39624-Handle Extra Pickup Start Date and Exception Details update
                                    List<SBQQ__QuoteLine__c> extraPickupQuoteLineListForUpdate = new List<SBQQ__QuoteLine__c>();
                                    if(bundlewiseExtraPickupQuoteLinesMap.keyset().contains(objChild.SBQQ__RequiredBy__c))
                                    {
                                        if(bundlewiseExtraPickupQuoteLinesMap.get(objChild.SBQQ__RequiredBy__c).AssetId__c == null)
                                        {
                                            //Check if Start Date on Pickup and Extra Pickup is same and if Extra Pickup needs to be updated (when user has not changed the Extra Pickup Start Date)
                                            if(bundlewiseExtraPickupStartDateMap.get(objChild.SBQQ__RequiredBy__c) == bundlewisePickupStartDateMap.get(objChild.SBQQ__RequiredBy__c))
                                            {
                                                extraPickupQuoteLineListForUpdate = QuoteProcurementController.getExtraPickupLineForStartDateUpdate(bundlewisePickupQuoteLinesMap, bundlewiseExtraPickupQuoteLinesMap, false);
                                                //Extra Pickup needs to be updated in case of Start Date change on Pickup
                                                if(extraPickupQuoteLineListForUpdate.size() > 0)
                                                {
                                                    tobeStartDateUpdateQLs= AssignVendorCommitToQLs(bundleVendorCommitDate, responseModel, objChild, extraPickupQuoteLineListForUpdate, debugRequired);
                                                    isExtraPickupLineUpdated = true;
                                                }
                                                //Extra Pickup needs to be updated with Exception Details in case of no change on Start Date on Pickup
                                                else
                                                {
                                                    tobeStartDateUpdateQLs.add(bundlewiseExtraPickupQuoteLinesMap.get(objChild.SBQQ__RequiredBy__c));
                                                    isExtraPickupLineUpdated = true;
                                                }
                                                
                                            }
                                            else
                                            {
                                                tobeStartDateUpdateQLs.add(bundlewiseExtraPickupQuoteLinesMap.get(objChild.SBQQ__RequiredBy__c));
                                                isExtraPickupLineUpdated = true;
                                            }
                                        }
                                        else if(bundlewiseExtraPickupQuoteLinesMap.get(objChild.SBQQ__RequiredBy__c).AssetId__c != null)
                                        {
                                            extraPickupQuoteLineListForUpdate = QuoteProcurementController.getExtraPickupLineForStartDateUpdate(bundlewisePickupQuoteLinesMap, bundlewiseExtraPickupQuoteLinesMap, false);
                                        
                                            if(extraPickupQuoteLineListForUpdate.size() > 0)
                                            {
                                                tobeStartDateUpdateQLs= AssignVendorCommitToQLs(bundleVendorCommitDate, responseModel, objChild, extraPickupQuoteLineListForUpdate, debugRequired);
                                                isExtraPickupLineUpdated = true;
                                            }
                                        }
                                    }
                                    //pkulkan-TCS-SDT-39624-End
	                            }
	                            //End-SDT-32782
                                    //SDT32803 SDT 34351
                                    changeExceptionReasonFlag = ExceptionDetailsServices.setExceptionReason(objChild,changeExceptionReasonFlag);
                            }
							}
                            //TCS-pkulkarn-8-Aug-2023-Added following code for SDT-31408. To update start date for new products/services added (Asset Id will be NULL for newly added lines)
                            //pkulkan-TCS-SDT-39624-Added check for Extra Pickup. Extra Pickup updates are handled in the if block above
                            else if(asset == null && objChild.SBQQ__ProductName__c != Constant_Util.PR_EXTRA_PICKUP)
                            {
                                AssetQuoteProcurementController.comparisonResponseModel responseModel = new AssetQuoteProcurementController.comparisonResponseModel();
                                responseModel.isEndAndExtendBaseline = true;
                                tobeStartDateUpdateQLs = AssignVendorCommitToQLs(bundleVendorCommitDate, responseModel, objChild, tobeStartDateUpdateQLs, debugRequired);
                            }
                        }
                        //added sdt-37527
                                if(objChild.SBQQ__Product__r.Family != 'Waste Category'){
                             
                                    if(!materialMapping.isEmpty()){
                                        for(Material_type_Material_Grade_mapping__mdt gradeMapRec : materialMapping){
                                           
                                                    //System.debug('gradeMapRec.Material_Type__c^^^^ ' +gradeMapRec.Material_Type__c);
                                                //System.debug('objchild.Material_Type__c^^^^ ' +quoteToMaterialGrade.get(objChild.Id));
                                                //System.debug('gradeMapRec.Material_Grade__c^^^^ ' +gradeMapRec.Material_Grade__c);
                                                //System.debug('objchild.materialGrade__c^^^^ ' +objchild.materialGrade__c);
                                            if(gradeMapRec.Material_Type__c == quoteToMaterialGrade.get(objChild.Id) && gradeMapRec.Material_Grade__c == objchild.materialGrade__c){
                                             
                                                 quoteToMaterialGradeCode.put(objchild.Id , gradeMapRec.Material_Grade_Code__c);
    
                                            }
                                            
                                             
                                        }
                                    }
                                }
                            //added  sdt-37527
                        //End
                        Map<String,Object> mapDetails = new Map<String,Object>();
                        List<Map<String,Object>> lstWOrders = new List<Map<String,Object>>();
                        for(PricingJsonSetting__mdt objmdt : lstIntegrationDetail){
                            if(objmdt.Default_Value__c != null){
                                mapDetails.put(objmdt.Attribute__c,objmdt.Default_Value__c);
                            }
                            // else if(objmdt.Attribute__c == 'priceModelTypeCode' && objChild.SBQQ__PricingMethod__c == 'List') {
                            //     mapDetails.put(objmdt.Attribute__c, 'PER');
                            // }
                            else if(objmdt.Field_API_Name__c != null){
                                if((objmdt.Field_API_Name__c).contains(',')){
                                    string aggValue = '';
                                    for(string str : (objmdt.Field_API_Name__c).split(',')){
                                        aggValue+=getParentValue(str, objChild);
                                    }
                                    mapDetails.put(objmdt.Attribute__c,aggValue);
                                }else if(objChild != null) {
                                    mapDetails.put(objmdt.Attribute__c,getParentValue(objmdt.Field_API_Name__c , objChild));
                                }
                            } else if(objmdt.Attribute__c == 'materialTypeCode' ){
                                mapDetails.put(objmdt.Attribute__c,quoteToMaterialCode.get(objChild.SBQQ__RequiredBy__c));
                            }
                            else if(objmdt.Attribute__c == 'equipmentTypeCode'){
                                //Developer : Yeshas Konduru
                                //SDT-19800
                                if(objQLI.SBQQ__ProductCode__c == 'CMP')
                                {
                                    if(objQLI.Equipment_Size__c != null && objQLI.Equipment_Size__c.contains('-'))   
                                    {
                                        integer eqSize = Integer.valueOf(objQLI.Equipment_Size__c.substringAfter('-'));
                                        if(eqSize >= 10)
                                        {
                                            mapDetails.put(objmdt.Attribute__c, objQLI.SBQQ__ProductCode__c);
                                        }
                                        else
                                        {
                                            mapDetails.put(objmdt.Attribute__c, 'VTC');
                                        }
                                    }
                                }
                                else
                                {
                                    mapDetails.put(objmdt.Attribute__c,objQLI.SBQQ__ProductCode__c);
                                }
                            }
                            // SDT-31973
                            else if(objmdt.Attribute__c == 'ParentProductKey' ){
                                mapDetails.put(objmdt.Attribute__c,objChild.SBQQ__RequiredBy__r.SBQQ__Product__c);
                            }
                             //SDT-37527
                            
                            if(objmdt.Attribute__c == 'materialGradeCode' ){
                                
                                mapDetails.put(objmdt.Attribute__c,quoteToMaterialGradeCode.get(objChild.Id));
                                 
                            }
                            //SDT-37527
                        }system.debug('lstWorkorders : ' +lstWorkorders.size());
                        system.debug('objChild.getSObjects' + objChild.getSObjects('Quote_Orders1__r'));
                        if(lstWorkorders.size() > 0 && objChild.getSObjects('Quote_Orders1__r') != null){
                            for(Quote_Order__c objQO : objChild.getSObjects('Quote_Orders1__r')){
                                // Loop to add WorkOrders
                                Map<String,Object> mapWO = new Map<String,Object>();
                                for(PricingJsonSetting__mdt objmdt : lstWorkorders){
                                    if(objmdt.Default_Value__c != null){
                                        mapWO.put(objmdt.Attribute__c,objmdt.Default_Value__c);
                                    }
                                    else if(objmdt.Field_API_Name__c != null && objmdt.Object_API_Name__c == 'SBQQ__QuoteLine__c'){
                                        system.debug('Field_API_Name__c '+objmdt.Field_API_Name__c);
                                        system.debug('objChild '+objChild);
                                        //Changes related to SDT-39689
                                        if(objmdt.Attribute__c == COMMUNICATION_TYPE_CODE){
                                            String commChannelValue= getParentValue(objmdt.Field_API_Name__c , objChild);
                                            mapWO.put(objmdt.Attribute__c, String.isempty(commChannelValue)? Constant_Util.PHONE :  commChannelValue ); 
                                        } 
                                        else{
                                        mapWO.put(objmdt.Attribute__c,getParentValue(objmdt.Field_API_Name__c , objChild));
                                        }
                                    }else if(objmdt.Field_API_Name__c != null && objmdt.Object_API_Name__c == 'Quote_Order__c' ){
                                        //Changes for SDT-30118
                                        if(objQO.Service_Quote_Line__r.SBQQ__ProductFamily__c ==SURCHARGES_AND_FEES && objmdt.Attribute__c ==Constant_Util.CASETYPEFIELD)
                                        {
                                            mapWO.put(objmdt.Attribute__c,Constant_Util.ServiceType_Delivery);
                                        }
                                        else{
                                         mapWO.put(objmdt.Attribute__c,getParentValue(objmdt.Field_API_Name__c , objQO));
                                        }
                                    } else if(objmdt.Attribute__c !='Case_Sub_Type__c'){
                                        mapWO.put(objmdt.Attribute__c,'');
                                    } 
                                }
                                //mapWO = mapTypeAndSubType(mapWO, objChild, getCaseSubtypeMap(), objQO, objQLI);
                                mapWO = caseTypeMapping(mapWO,objQO);
                                
                                lstWOrders.add(mapWO);
                            }
                        }
                        mapDetails.put('Workorders',lstWOrders);
                        lstDetails.add(mapDetails);
                    }
                }
                //SDT32803,33495 
                
                for(SBQQ__QuoteLine__c objChild : tobeStartDateUpdateQLs){//mapChildQLI.get(objQLI.Id)){
                    //SDT34351
                    String caseType = objQLI.SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__r.RecordType.Name;
                    boolean isPrevStartDateAndExceptionEffectiveDateSame = false;
                    if(caseType != Constant_Util.New_Service_Case){
                        ExceptionDetailsServices.setExceptionDetails(objChild,objQLI,changeExceptionReasonFlag,isPrevStartDateAndExceptionEffectiveDateSame);
                        system.debug('I am called'+objChild.Id);
                            if(tobeStartDateUpdateQLs.contains(objChild)){
                            Integer indexofobjChild = tobeStartDateUpdateQLs.indexOf(objChild);
                            tobeStartDateUpdateQLs.get(indexofobjChild).Exception_Type__c=objChild.Exception_Type__c;
                            tobeStartDateUpdateQLs.get(indexofobjChild).Exceptions_Effective_Date__c=objChild.Exceptions_Effective_Date__c;
                            tobeStartDateUpdateQLs.get(indexofobjChild).Exception_Reason__c=objChild.Exception_Reason__c;
                            tobeStartDateUpdateQLs.get(indexofobjChild).Exception_Comments__c=objChild.Exception_Comments__c;
                    }
                }
                }
            }
            
            if(lstIntegrationHeader.size() > 0){
                // Loop to add IntegrationHeader
                Map<String,Object> mapHeader = new Map<String,Object>();
                for(PricingJsonSetting__mdt objmdt : lstIntegrationHeader){
                    if(objmdt.Attribute__c == 'groupIndicator'){
                        mapHeader.put(objmdt.Attribute__c,QuoteName);
                    }
                    else{
                        if(objmdt.Default_Value__c != null){
                            mapHeader.put(objmdt.Attribute__c,objmdt.Default_Value__c);
                        }
                        else{
                         //Changes related to SDT-39689
                         if(objmdt.Attribute__c == QUOTE_CASE_ORIGIN){
                              String commChannelValue= getParentValue(objmdt.Field_API_Name__c , objQLI);
                              mapHeader.put(objmdt.Attribute__c, String.isempty(commChannelValue)? Constant_Util.PHONE :  commChannelValue ); 
                            }else{
                            mapHeader.put(objmdt.Attribute__c,getParentValue(objmdt.Field_API_Name__c, objQLI));
                            }
                        }
                    }
                }
                lstqlDetails.addAll(lstDetails);
                if(lstDetails.size() > 0){
                    mapHeader.put('IntegrationDetail',lstDetails);
                    lstHeader.add(mapHeader);
                }
                
            }
            if(lststart.size() > 0){
                for(PricingJsonSetting__mdt objmdt : lststart){
                    if(objmdt.Default_Value__c != null){
                        finalMap.put(objmdt.Attribute__c,objmdt.Default_Value__c);
                    }
                    else{
                        finalMap.put(objmdt.Attribute__c,QuoteName);
                    }
                }
            }
            //SDT 33101 New
            if(!integrationCall && amendmentQuoteApprovedBundleId == objQLI.Id && lstDetails.size()==0){
                amendmentFlag=true;
            }
        }
        
	//TCS-pkulkarn-SDT-41371-Tech Debt-Do not update start dates while running integration call from API Hub-Added if condition
    if(integrationCall == false)
    {
        //pkulkarn-8-Aug-2023-Added following code for SDT-31408-Compare and update Bundle Start Date to be in Sync for display
	    tobeStartDateUpdateQLs = UpdateBundleStartDates(tobeStartDateUpdateQLs, mapParentQLI.values(), updateBaselineFields, endAndExtendBaselineFields, excludedFields, assetQuoteLineMappings, debugRequired);
				
	    //Updating QuoteLines for start date change and mismatch found for Story 31408 , Story 30515
        updatingEligibleQuoteLines(tobeStartDateUpdateQLs,debugRequired); //31408 
        UpdateWorkOrderServiceDates(tobeStartDateUpdateQLs);
    }
        //Changes for SDT-26868
        if(caseType != Constant_Util.New_Service_Case && lstqlDetails.size()<=0){
            system.debug('Inside new condition');
            return 'False';
        }
        finalMap.put('IntegrationHeader',lstHeader);
        return JSON.serialize(finalMap);
    }

    // Method to update Eligible Start date update QuoteLines
    private static Boolean updatingEligibleQuoteLines(List<SBQQ__QuoteLine__c> tobeStartDateUpdateQLs, Boolean debugRequired)
    {
        Boolean success = false;
        // Checking if QLs available
        if(tobeStartDateUpdateQLs!=null && !tobeStartDateUpdateQLs.isEmpty())
        {
            SBQQ.TriggerControl.disable();
            try{
                isRecurrsiveIntegrationCheck = true;
                if(debugRequired)
                    system.debug('tobeStartDateUpdateQLs Size>' + tobeStartDateUpdateQLs.size());
                if(!debugRequired)
                    Update tobeStartDateUpdateQLs;
                isRecurrsiveIntegrationCheck = false;
                success = true;
            }
            catch(Exception ex){
                system.debug('Exception '+ex.getMessage());
            }
            finally{
                SBQQ.TriggerControl.enable();
            }            
        }
        return success;
    }

    // Assigning Vendor Commit Date to changed QLs
    private static List<SBQQ__QuoteLine__c> AssignVendorCommitToQLs(Date bundleVendorCommitDate, AssetQuoteProcurementController.comparisonResponseModel responseModel, SBQQ__QuoteLine__c objChild, List<SBQQ__QuoteLine__c> tobeStartDateUpdateQLs, Boolean debugRequired)
    {
        //SDT 34351
        List<id> tobeStartDateUpdateQLsIds=new list<id>();
        if(tobeStartDateUpdateQLs.size()>0){
            for(SBQQ__QuoteLine__c ql : tobeStartDateUpdateQLs){
                tobeStartDateUpdateQLsIds.add(ql.id);
            }
        }
        //SDT-32124
        objChild.IsAssetQuotelineDifferent__c = True;
        //pkulkarn-14-Aug-2023-Added following code for SDT-31408
        if(responseModel!= null && responseModel.isEndAndExtendBaseline == true)
        {
            if(objChild.SBQQ__RequiredBy__c == null && objChild.SBQQ__StartDate__c != bundleVendorCommitDate)
            {    
                //commenting for SDT 34351 = objChild.Exceptions_Effective_Date__c
                boolean isStartDateAndExceptionEffectiveDateSame = false;
                if(objChild.SBQQ__StartDate__c==objChild.Exceptions_Effective_Date__c){
                    isStartDateAndExceptionEffectiveDateSame = true; 
                }
                objChild.SBQQ__StartDate__c = bundleVendorCommitDate;
                if(isStartDateAndExceptionEffectiveDateSame){
                    ExceptionDetailsServices.setExceptionDate(objChild);
                }
                system.debug('bundleupdate');
            }
            else if(objChild.SBQQ__RequiredBy__c != null && objChild.SBQQ__StartDate__c != bundleVendorCommitDate)
            {
                //commenting for SDT 34351 = objChild.Exceptions_Effective_Date__c
                boolean isStartDateAndExceptionEffectiveDateSame = false;
                if(objChild.SBQQ__StartDate__c==objChild.Exceptions_Effective_Date__c){
                    isStartDateAndExceptionEffectiveDateSame = true; 
                }
                objChild.SBQQ__StartDate__c = bundleVendorCommitDate;
                if(isStartDateAndExceptionEffectiveDateSame){
                    ExceptionDetailsServices.setExceptionDate(objChild);
                }
            }
            //SDT-38052 - Start
            //objChild.Service_Action__c ='';
            if(objChild.SBQQ__Quote__r.SBQQ__Type__c ==  Constant_Util.QUOTE_TYPE_AMEND || 
                               objChild.SBQQ__Quote__r.SBQQ__Type__c ==  Constant_Util.QUOTE_TYPE_EXCEPTION || 
                              objChild.SBQQ__Quote__r.SBQQ__Type__c == Constant_Util.QUOTE_TYPE_CORRECTION){
                                  if(objChild.AssetId__c!=null){
            List<Schema.PicklistEntry> serviceActionEntries = Schema.SObjectType.SBQQ__QuoteLine__c.fields.Service_Action__c.getPicklistValues();
	            objChild.Service_Action__c = AssetQuoteProcurementController.getPicklistEntryByLabel(serviceActionEntries, Constant_Util.EXTEND_SERVICE);
    	    }
                              }
            
            //SDT-38052 - End
            //SDT 34351
            if(tobeStartDateUpdateQLsIds.size()>0 && tobeStartDateUpdateQLsIds.contains(objChild.id) && objChild.SBQQ__ProductName__c == Constant_Util.PR_EXTRA_PICKUP){
                
            }else
            	tobeStartDateUpdateQLs.add(objChild);
            
            if(debugRequired)
            {
                system.debug('objChild.SBQQ__StartDate__c >'+ objChild.SBQQ__StartDate__c );
				system.debug('objChild.Exceptions_Effective_Date__c >'+ objChild.Exceptions_Effective_Date__c );
                system.debug('tobeStartDateUpdateQLs >'+ tobeStartDateUpdateQLs );
            }
    	}
        // Changes for SDT-31788
        else if (responseModel!= null && responseModel.isUpdateBaseline)
        {
            objChild.Service_Action__c =QuoteLineSelector.SERVICE_ACTION_DO_NOT_EXTEND_SERVICE;
            tobeStartDateUpdateQLs.add(objChild);
        }
		return tobeStartDateUpdateQLs;
        //pkulkarn-14-Aug-2023-End
        
        /* pkulkarn-8-Aug-2023-End commented for SDT-31408/409
         * if(vendorCommitDate != null && responseModel!= null && responseModel.isEndAndExtendBaseline == true) //&& !debugRequired
        {
            objChild.SBQQ__StartDate__c = vendorCommitDate;
            tobeStartDateUpdateQLs.add(objChild);
            if(debugRequired)
            {
                system.debug('objChild.SBQQ__StartDate__c >'+ objChild.SBQQ__StartDate__c );
                system.debug('tobeStartDateUpdateQLs >'+ tobeStartDateUpdateQLs );
            }
        }
        return tobeStartDateUpdateQLs;*/
    }
    
    public static List<SBQQ__QuoteLine__c> CheckAndUpdateVendorCommitDateAndStartDate(Id quoteId, List<SBQQ__QuoteLine__c> tobeStartDateUpdateQLs)
    {
        /**************************************************
        * Created By: TCS, Pavankumar Kulkarni
        * CreatedDate: 7-Aug-23
        * Story: SDT-31408
        * Comment: To update Customer Request Date and Vendor Commit Date with Bundle or Today + 7 (if SLA Date is null) when Quote is moved from Draft to Procure Service status
        * **************************************************/
        Map<Id, SBQQ__QuoteLine__c> quoteLinesToBeUpdatedMap = new Map<Id, SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> quoteLinesToBeUpdated = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> bundleLinesToBeUpdated = new List<SBQQ__QuoteLine__c>();
        Map<Id, Date> bundleVendorCommitDate = new Map<Id, Date>();
        //SDT 32952 cretaing map of bundle id and its end date, which will be used to set removal line's start and end date
        Map<Id, Date> bundleEndDate = new Map<Id, Date>();
        //STD 36449
        Map<Id, SBQQ__QuoteLine__c> parentQuoteLine = new Map<Id, SBQQ__QuoteLine__c>();
        //SDT 32952 added SBQQ__EndDate__c in query
        //STD 36449 added Duration__c
        //SDT 34351 quote__r.Name,Case_Number__c,SBQQ__Opportunity2__r.Case__r.Reference_Number__c ,Exception_Type__c, Exception_Reason__c, Exception_Comments__c, Exception_Effective_Date__c,
        List<SBQQ__QuoteLine__c> allQuoteLines = [SELECT Id, Exception_Type__c, Exception_Reason__c, Exception_Comments__c, Exception_Effective_Date__c,
                                                  SBQQ__Quote__r.Name, SBQQ__Quote__r.Case_Number__c, SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__r.Reference_Number__c, SBQQ__EndDate__c,SBQQ__ProductName__c, Quote_SLA_Date__c, Vendor_Commit_Date__c, Exceptions_Effective_Date__c, SBQQ__StartDate__c, SBQQ__ProductFamily__c, SBQQ__Quote__c, 
                                                  SBQQ__RequiredBy__c, SBQQ__RequiredBy__r.SBQQ__RequiredBy__c, SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__r.RecordType.Name,Duration__c
                                                  ,SBQQ__RequiredBy__r.SBQQ__RequiredBy__r.SBQQ__Quote__r.Name,SBQQ__RequiredBy__r.SBQQ__RequiredBy__r.SBQQ__Quote__r.Case_Number__c,SBQQ__RequiredBy__r.SBQQ__RequiredBy__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__r.Reference_Number__c
                                                  FROM SBQQ__QuoteLine__c 
                                                  WHERE SBQQ__Quote__c = :quoteId];
        
        for(SBQQ__QuoteLine__c quoteLine : allQuoteLines)
        {
            if(quoteLine.SBQQ__RequiredBy__c == null)
            {
                if(quoteLine.Quote_SLA_Date__c == null && quoteLine.Vendor_Commit_Date__c == null)
                {
                    quoteLine.Quote_SLA_Date__c = quoteLine.Vendor_Commit_Date__c = system.now().date().addDays(7);
                    bundleVendorCommitDate.put(quoteLine.Id, quoteLine.Vendor_Commit_Date__c);
                    quoteLinesToBeUpdatedMap.put(quoteLine.Id, quoteLine);
                }
				else if(quoteLine.Quote_SLA_Date__c != null && quoteLine.Vendor_Commit_Date__c == null)
                {
                    quoteLine.Vendor_Commit_Date__c = quoteLine.Quote_SLA_Date__c;
                    bundleVendorCommitDate.put(quoteLine.Id, quoteLine.Vendor_Commit_Date__c);
                    quoteLinesToBeUpdatedMap.put(quoteLine.Id, quoteLine);
                }
                else
                {
                    bundleVendorCommitDate.put(quoteLine.Id, quoteLine.Vendor_Commit_Date__c);
                }
                //SDT 32952
                //adding bundle id and its end date to map which will be used to set removal line's start and end date 
                /*if(quoteLine.SBQQ__EndDate__c != null){
                    bundleEndDate.put(quoteLine.Id, quoteLine.SBQQ__EndDate__c);
                }*/
                //SDT 36449
                parentQuoteLine.put(quoteLine.Id, quoteLine);
            }
        }
        //SDT 34351
        boolean isStartDateAndExceptionEffectiveDateSame = false;
        for(SBQQ__QuoteLine__c quoteLine : allQuoteLines)
        {
            //SDT 34351
            isStartDateAndExceptionEffectiveDateSame = false;
            if(quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__r.RecordType.Name == Constant_Util.New_Service_Case)
            {
                SWITCH on quoteLine.SBQQ__ProductFamily__c
                {
                    WHEN 'Waste Category'
                    {
                        if(bundleVendorCommitDate.containsKey(quoteLine.SBQQ__RequiredBy__c))
                        {
                            if(bundleVendorCommitDate.get(quoteLine.SBQQ__RequiredBy__c) != null && quoteLine.SBQQ__StartDate__c != bundleVendorCommitDate.get(quoteLine.SBQQ__RequiredBy__c))
                            {
                                //commenting for SDT 34351 = quoteLine.Exceptions_Effective_Date__c
                                if(quoteLine.SBQQ__StartDate__c==quoteLine.Exceptions_Effective_Date__c){
                                    isStartDateAndExceptionEffectiveDateSame = true; 
                                }
                                quoteLine.SBQQ__StartDate__c = bundleVendorCommitDate.get(quoteLine.SBQQ__RequiredBy__c);
                                //SDT 38011
                                //quoteLine.Exception_Effective_Date__c = (quoteLine.SBQQ__StartDate__c != null) ? DateTime.newInstanceGMT(quoteLine.SBQQ__StartDate__c.year(),quoteLine.SBQQ__StartDate__c.month(),quoteLine.SBQQ__StartDate__c.day(),12,00,00):quoteLine.SBQQ__StartDate__c;
                            }
                        }
                    }
                    WHEN 'Waste Stream'
                    {
                        if(bundleVendorCommitDate.get(quoteLine.SBQQ__RequiredBy__r.SBQQ__RequiredBy__c) != null && quoteLine.SBQQ__StartDate__c != bundleVendorCommitDate.get(quoteLine.SBQQ__RequiredBy__r.SBQQ__RequiredBy__c))
                        {
                            //commenting for SDT 34351 = quoteLine.Exceptions_Effective_Date__c
                            if(quoteLine.SBQQ__StartDate__c==quoteLine.Exceptions_Effective_Date__c){
                                isStartDateAndExceptionEffectiveDateSame = true; 
                            }
                            quoteLine.SBQQ__StartDate__c = bundleVendorCommitDate.get(quoteLine.SBQQ__RequiredBy__r.SBQQ__RequiredBy__c);
                            //SDT 38011
                            //quoteLine.Exception_Effective_Date__c = (quoteLine.SBQQ__StartDate__c != null) ? DateTime.newInstanceGMT(quoteLine.SBQQ__StartDate__c.year(),quoteLine.SBQQ__StartDate__c.month(),quoteLine.SBQQ__StartDate__c.day(),12,00,00):quoteLine.SBQQ__StartDate__c;
                        }
                    }
                    WHEN else
                    {
                        String typeOfRecord = 'none';
                        Date vendorCommitDateToBeStartDate = null;
                        if(quoteLine.SBQQ__RequiredBy__c == null)
                        {
                            typeOfRecord = 'Root';
                            vendorCommitDateToBeStartDate = bundleVendorCommitDate.get(quoteLine.Id);
                        }
                        else if(quoteLine.SBQQ__RequiredBy__c != null && quoteLine.SBQQ__RequiredBy__r.SBQQ__RequiredBy__c == null)
                        {
                            typeOfRecord = 'Child';
                            vendorCommitDateToBeStartDate = bundleVendorCommitDate.get(quoteLine.SBQQ__RequiredBy__c);
                        }
                        else if(quoteLine.SBQQ__RequiredBy__c != null && quoteLine.SBQQ__RequiredBy__r.SBQQ__RequiredBy__c != null)
                        {
                            typeOfRecord = 'GrandChild';
                            vendorCommitDateToBeStartDate = bundleVendorCommitDate.get(quoteLine.SBQQ__RequiredBy__r.SBQQ__RequiredBy__c);
                        }
                        
                        if(vendorCommitDateToBeStartDate != null && quoteLine.SBQQ__StartDate__c != vendorCommitDateToBeStartDate)
                        {
                            //commenting for SDT 34351 = quoteLine.Exceptions_Effective_Date__c
                            if(quoteLine.SBQQ__StartDate__c==quoteLine.Exceptions_Effective_Date__c){
                                isStartDateAndExceptionEffectiveDateSame = true;
                            }
                            quoteLine.SBQQ__StartDate__c = vendorCommitDateToBeStartDate;
                            ExceptionDetailsServices.setExceptionDetails(quoteLine, parentQuoteLine.get(quoteLine.SBQQ__RequiredBy__c), false, isStartDateAndExceptionEffectiveDateSame);
                            // SDT-31973
                            if(quoteLine.SBQQ__ProductName__c == Constant_Util.ServiceType_Delivery || quoteLine.SBQQ__ProductName__c == Constant_Util.KEYS)
                                quoteLine.SBQQ__EndDate__c = bundleVendorCommitDate.get(quoteLine.SBQQ__RequiredBy__c);
                            //SDT32952
                           if(quoteLine.SBQQ__ProductName__c == Constant_Util.REMOVAL)
                            {
							//SDT 36499 prevent empty bundle end date scenario for removal line on permenant containers
                            if(RemovalQuoteLineHandler.isTempCommercialContainer(quoteLine,parentQuoteLine)){
                                Date endDate = parentQuoteLine.get(quoteLine.SBQQ__RequiredBy__c).SBQQ__EndDate__c;
                                    RemovalQuoteLineHandler.setDatesForRemovalQL(quoteLine,endDate);
                                }
                            }
                            quoteLine.Exception_Effective_Date__c = (quoteLine.SBQQ__StartDate__c != null) ? DateTime.newInstanceGMT(quoteLine.SBQQ__StartDate__c.year(),quoteLine.SBQQ__StartDate__c.month(),quoteLine.SBQQ__StartDate__c.day(),12,00,00):quoteLine.SBQQ__StartDate__c;
                            quoteLinesToBeUpdatedMap.put(quoteLine.Id, quoteLine);
                        }
                    }
                }
                ExceptionDetailsServices.setExceptionDetails(quoteLine, parentQuoteLine.get(quoteLine.SBQQ__RequiredBy__c), false, isStartDateAndExceptionEffectiveDateSame);
                quoteLinesToBeUpdatedMap.put(quoteLine.Id, quoteLine);
            }
        }
        
        quoteLinesToBeUpdated = quoteLinesToBeUpdatedMap.Values();
        for(SBQQ__QuoteLine__c quoteLine : quoteLinesToBeUpdated)
            tobeStartDateUpdateQLs.add(quoteLine);
        return tobeStartDateUpdateQLs;
    }
    
    public static SBQQ__QuoteLine__c CheckAndUpdateOldExceptionEffectiveDateField(SBQQ__QuoteLine__c quoteLine)
    {
        /**************************************************
        * Created By: TCS, Pavankumar Kulkarni
        * CreatedDate: 7-Aug-23
        * Story: SDT-31408
        * Comment: To update Exception Effective Date, the old field
        * **************************************************/
        if(quoteLine != null)
            quoteLine.Exception_Effective_Date__c = (quoteLine.SBQQ__StartDate__c != null) ? DateTime.newInstanceGMT(quoteLine.SBQQ__StartDate__c.year(),quoteLine.SBQQ__StartDate__c.month(),quoteLine.SBQQ__StartDate__c.day(),12,00,00):quoteLine.SBQQ__StartDate__c;
        	
        return quoteLine;
    }
    
    public static List<SBQQ__QuoteLine__c> UpdateBundleStartDates(List<SBQQ__QuoteLine__c> tobeStartDateUpdateQLs, List<SBQQ__QuoteLine__c> quoteLines, Set<string> updateBaselineFields, Set<string> endAndExtendBaselineFields, Set<string> excludedFields, List<Asset_Quoteline_Mapping__mdt> assetQuoteLineMappings, boolean debugRequired)
    {
		/**************************************************
        * Created By: TCS, Pavankumar Kulkarni
        * CreatedDate: 7-Aug-23
        * Story: SDT-31408
        * Comment: To update Start Date on Bundle quote lines
        * *************************************************/

        for(SBQQ__QuoteLine__c objQLI : quoteLines)
        {
            String caseType = objQLI.SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__r.RecordType.Name;
            Asset asset = assetBundleMap.get(objQLI.AssetId__c);
            SBQQ__QuoteLine__c quoteLineRecord = new SBQQ__QuoteLine__c();
            if(caseType != Constant_Util.New_Service_Case)
            {
                if(asset != null)
                {
                    AssetQuoteProcurementController.comparisonResponseModel responseModel = compareAssetQuoteLineDetails(asset,objQLI,objQLI,true,updateBaselineFields,endAndExtendBaselineFields, excludedFields, assetQuoteLineMappings);
                    if(objQLI.SBQQ__RequiredBy__c == null && objQLI.Vendor_Commit_Date__c == null && objQLI.Quote_SLA_Date__c == null)
                    {
                        quoteLineRecord.Id = objQLI.Id;
                        quoteLineRecord.Vendor_Commit_Date__c = quoteLineRecord.Quote_SLA_Date__c = system.now().date().addDays(7);
                    }
                    else if(objQLI.SBQQ__RequiredBy__c == null && objQLI.Quote_SLA_Date__c != null && objQLI.Vendor_Commit_Date__c == null )
                    {
                        quoteLineRecord.Id = objQLI.Id;
                        quoteLineRecord.Vendor_Commit_Date__c = objQLI.Quote_SLA_Date__c;
                    }

                    if (responseModel!= null && responseModel.isQLMached == true)
                    {
                        //Do nothing, continue with next record;
                    }    
                    // if QL's not matched then assigning Vendor Commit Date and Creating new QL list to update for Update BaseLine Case
                    else
                    {
						if(responseModel!= null && responseModel.isEndAndExtendBaseline == true)
                        {
                            if(objQLI.SBQQ__RequiredBy__c == null && quoteLineRecord.Id != null && quoteLineRecord.Vendor_Commit_Date__c != null && quoteLineRecord.SBQQ__StartDate__c != quoteLineRecord.Vendor_Commit_Date__c)
                            {
                                //commenting for SDT 34351 = quoteLineRecord.Exceptions_Effective_Date__c
                                boolean isStartDateAndExceptionEffectiveDateSame = false;
                                if(quoteLineRecord.SBQQ__StartDate__c==quoteLineRecord.Exceptions_Effective_Date__c){
                                    isStartDateAndExceptionEffectiveDateSame = true;
                                }
                                quoteLineRecord.SBQQ__StartDate__c  = quoteLineRecord.Vendor_Commit_Date__c;
                                if(isStartDateAndExceptionEffectiveDateSame){
                                    ExceptionDetailsServices.setExceptionDate(quoteLineRecord);
                                }
                                quoteLineRecord = CheckAndUpdateOldExceptionEffectiveDateField(quoteLineRecord);
                            }
                            else if(objQLI.SBQQ__RequiredBy__c == null && quoteLineRecord.Id == null && objQLI.Vendor_Commit_Date__c != null && objQLI.SBQQ__StartDate__c != objQLI.Vendor_Commit_Date__c)
                            {    
                                quoteLineRecord.Id = objQLI.Id;
                                //commenting for SDT 34351 = quoteLineRecord.Exceptions_Effective_Date__c
                                boolean isStartDateAndExceptionEffectiveDateSame = false;
                                if(quoteLineRecord.SBQQ__StartDate__c==quoteLineRecord.Exceptions_Effective_Date__c){
                                    isStartDateAndExceptionEffectiveDateSame = true;
                                }
                                quoteLineRecord.SBQQ__StartDate__c = objQLI.Vendor_Commit_Date__c;
                                if(isStartDateAndExceptionEffectiveDateSame){
                                    ExceptionDetailsServices.setExceptionDate(quoteLineRecord);
                                }
                                quoteLineRecord = CheckAndUpdateOldExceptionEffectiveDateField(quoteLineRecord);
                            }
                            if(debugRequired)
                                system.debug('bundleupdate' + JSON.serialize(quoteLineRecord));
                        }
                    }
                }
            }
            if(quoteLineRecord.Id != null)
                tobeStartDateUpdateQLs.add(quoteLineRecord);
        }
        return tobeStartDateUpdateQLs;
    }
    
    public static void UpdateWorkOrderServiceDates(List<SBQQ__QuoteLine__c> tobeStartDateUpdateQLs)
    {
		/**************************************************
        * Created By: TCS, Pavankumar Kulkarni
        * CreatedDate: 18-Aug-23
        * Story: SDT-31408
        * Comment: To update Service Date on Work Orders
        * *************************************************/
        Set<Id> quoteLineIds = new Set<Id>();
        List<Quote_Order__c> workOrdersListToBeUpdated = new List<Quote_Order__c>();
        Map<Id, Quote_Order__c> workOrdersMap = new Map<Id, Quote_Order__c>();
        
        for(SBQQ__QuoteLine__c quoteLine : tobeStartDateUpdateQLs)
        {
                quoteLineIds.add(quoteLine.Id);
        }
        
        //Query Work Orders
        //SDT32952 adding Service_Quote_Line__r.SBQQ__Product__r.Name in query
        List<Quote_Order__c> workOrdersList = [SELECT Id, Service_Date__c, Service_Quote_Line__c, Service_Quote_Line__r.SBQQ__StartDate__c,Service_Quote_Line__r.SBQQ__Product__r.Name
                                               FROM Quote_Order__c
                                               WHERE Service_Quote_Line__c IN :quoteLineIds
                                              ];
        
        if(workOrdersList.size() > 0)
        {
            for(Quote_Order__c workOrder : workOrdersList)
            {
                //SDT32952 adding if check for setting start date only for delivery workorder
                if(workOrder.Service_Date__c != workOrder.Service_Quote_Line__r.SBQQ__StartDate__c && workOrder.Service_Quote_Line__r.SBQQ__Product__r.Name==Constant_Util.ServiceType_Delivery)
                {
                    workOrder.Service_Date__c = workOrder.Service_Quote_Line__r.SBQQ__StartDate__c;
                	workOrdersListToBeUpdated.add(workOrder);
                }
            }    
        }
        
        if(workOrdersListToBeUpdated.size() > 0)
            UPDATE workOrdersListToBeUpdated;
    }
}