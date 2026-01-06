/*
Author: Rishiraj Singh
Requirement Id/Story: SDT-21793
FC: Rahul Rana
Module: Asset Management/Quote Summary on Case Page
--------------------------------------------------------------------
Description: Modal classes, use to get quote summary from quote/quoteline bundle. Controller class for quoteSummaryComp LWC.
*/

public with sharing class GetQuoteSummary {
    public class RequestServiceConfig{ 
        public String tabName;
        public String selectedService;
        public String wasteStream;
        public String size;
        public Date startDate;
        public Date endDate;
        //Added as part of SDT-29792 start
        public Boolean isUpdateAssetCase;
        public Double originalQuantity;
        //Added as part of SDT-29792 end
        public Double quantity;
        public String descriptionOfWaste;
        public String additionalAccessories;
        public String serviceSchedule;
        public String quoteOnly;
        public String compactorType;
        public String compactorSize;
        public String equipmentStyle;
        public String equipmentSideDoors;
        public String serviceStyle;
        public String typeofLid;
        public String understructure;
        public String ownership;
    }
    public class DeliveryInstructions{
        public String tabName;
        public String contactName;
        public String phoneNumber;
        public String customerPurchaseNumber;
        public String placementInstructions;
    }
    public class SpecialDisposal{
        public String tabName;
        public String certificateOfDisposal;
        public String certificateOfDestruction;
        public String profileNumber;
        public String landfillRequested;
        public String specialDisposalInstructions;
    }
    public class ServiceRestrictions{
        public String tabName;
        public String earliestServiceTime;
        public String latestServiceTime;
        public String gateCodes;
        public String driverInstructions;
    }
    public class ContainerPositions{
        public String tabName;
        public String selectedPosition;
    }
    public class ProjectServices{
        public String tabName;
        public String partOfProject;
        public String selectedProjectName;
    }
    public class Bundle{
        public String bundleId;
        public String bundleProductName;
        public String quoteId;
        public Boolean isNotDraft;
        public RequestServiceConfig requestServiceConfigObj;
        public DeliveryInstructions deliveryInstructionsObj;
        public SpecialDisposal specialDisposalObj;
        public ServiceRestrictions serviceRestrictionsObj;
        public ContainerPositions containerPositionsObj;
        public ProjectServices projectServicesObj;
    }
    public class QuoteSummary{
        public String quoteRecordId;
        public String quoteNumber;
        public String quoteStatus;
        public String quoteDescription;
        public String teamAssignment;
        public Boolean cpqEligible;
        public List<Bundle> bundleList;
    }
    public class DataProcessor{
        public List<SBQQ__Quote__c> quoteList;
        Map<Id,List<SBQQ__QuoteLine__c>> quoteListQLMap;
        Map<Id,List<SBQQ__QuoteLine__c>> parentQLIdListQLMap;
        Map<Id,Quote_Order__c> qlIdQOMap; 
        User userObj;
        String wasteStream= 'Waste Stream';
        String wasteCategory= 'Waste Category';
        String services= 'Services';
        String standardServices= 'Standard Services';
        String dlv= 'Delivery';
        String rscTabStr= 'Requested Service Configuration';
        String diTabStr= 'Delivery Instructions';
        String sdTabStr= 'Special Disposal Details';
        String srTabStr= 'Service Restrictions';
        String cpTabStr= 'Container Positions';
        String psTabStr= 'Project Services';
    }

    @AuraEnabled(cacheable=false)
    public static String getQuoteDetails(String caseId, String userId){ //get the quote data
         
        List<SBQQ__Quote__c> quoteList = new  List<SBQQ__Quote__c>();
        List<SBQQ__QuoteLine__c> qlList = new List<SBQQ__QuoteLine__c>();
        List<Quote_Order__c> qoList = new List<Quote_Order__c>();
        Map<Id,User> userMap= new Map<Id,User>();
        User userObj= new User(Id= userId);
        userMap.put(userId,userObj);
        System.debug('userList>>>1'+userMap.get(userId));
        Case caseObj= new Case(Id= caseId);
        GetQuoteSummary.getData(userMap, caseObj, quoteList, qlList, qoList); //get the data
        System.debug('userList>>>2'+userMap.get(userId).CPQ_Active_User__c);

        Map<Id,List<SBQQ__QuoteLine__c>> quoteListQLMap= new Map<Id,List<SBQQ__QuoteLine__c>>(); //quoteId & List of QL
        Map<Id,List<SBQQ__QuoteLine__c>> parentQLIdListQLMap =  new Map<Id,List<SBQQ__QuoteLine__c>>(); // parent qlId & list of QL
        Map<Id,Quote_Order__c> qlIdQOMap= new Map<Id,Quote_Order__c>(); // delivery service quote line & delivery quote order
        GetQuoteSummary.mapData(qlList, qoList, quoteListQLMap, parentQLIdListQLMap, qlIdQOMap); //map the relational data

        DataProcessor dpObj= new DataProcessor(); //process the data for binding purpose
        dpObj.quoteList= quoteList;
        dpObj.quoteListQLMap = quoteListQLMap;
        dpObj.parentQLIdListQLMap = parentQLIdListQLMap;
        dpObj.qlIdQOMap = qlIdQOMap;
        dpObj.userObj= userMap.get(userId);
        List<QuoteSummary> qsList = GetQuoteSummary.bindingData(dpObj); //bind the data with wrapper classes
        
        String jsonStr = JSON.serialize(qsList);
        return jsonStr;
    }

    @AuraEnabled
    public static List<String> getPicklistSchema(){ //get the QO service type options.
        List<String> options= QuoteProcurementController.getPicklistSchema();
        return options;
    }

    public static String getQuoteStatusDescription(String status){ //get the Quote Description as per the quote status.
        if(status.equals(Constant_Util.QUOTE_DRAFT_LABEL)){
            return Label.QuoteDraftDescription;
        }else if(status.equals(Constant_Util.QUOTE_PRODUCT_CONFIGURED_LABEL)){
            return Label.QuoteProcureDescription;
        }else if(status.equals(Constant_Util.QUOTE_COST_CONFIGURED_LABEL)){
            return Label.QuotePriceDescription;
        }else if(status.equals(Constant_Util.QUOTE_PRICE_CONFIGURED_LABEL)){
            return Label.QuoteApprovalDescription;
        }else if(status.equals(Constant_Util.QUOTE_APPROVED_LABEL)){
            return Label.QuoteApprovedDescription;
        }else if(status.equals(Constant_Util.QUOTE_DECLINED_LABEL)){
            return Label.QuoteDeclinedDescription;
        }else{
            return '';
        }       
    }

    public static void getData(Map<Id,User> userMap, Case caseObj, List<SBQQ__Quote__c> quoteList, List<SBQQ__QuoteLine__c> qlList, List<Quote_Order__c> qoList){
        String dlv= 'Delivery';
        User userObj= [SELECT Id, CPQ_Active_User__c FROM User WHERE Id IN: userMap.keySet() LIMIT 1];
        //updated as part of SDT-29792 start
        List<SBQQ__Quote__c> quoteList1= QuoteLineSelector.getQuoteByCaseId(caseObj);
            //[SELECT Id,Name,SBQQ__Opportunity2__r.Case__r.Case_Record_Type__c,SBQQ__Opportunity2__r.Case__r.AssetDetail__r.Quantity__c, Assigned_To__r.Name, toLabel(SBQQ__Status__c), Quote_Only__c,Project__r.Name,Project_Services_Request__c FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__r.Case__c=:caseObj.Id];
        List<SBQQ__QuoteLine__c> qlList1= QuoteLineSelector.getQuoteLinesByQuoteIdList(quoteList1);
            //[SELECT Id,AssetId__r.Quantity__c,SBQQ__Quote__c,Service_Start_Time__c,Service_End_Time__c,Gate_Code__c,Restriction_Details__c,SBQQ__ProductName__c,SBQQ__ProductFamily__c,	SBQQ__ProductOption__r.SBQQ__Feature__r.Name,toLabel(Equipment_Size__c),SBQQ__StartDate__c,SBQQ__EndDate__c,SBQQ__Quantity__c,Description_of_Waste__c,Service_Schedule__c,LocationPositionName__c,Certificate_of_Disposal__c,Certificate_of_Destruction__c,Profile_Number__c,Landfill_Tickets__c,Special_Disposal_Description__c,Compactor_Type__c,Compactor_Size__c,Equipment_Style__c,toLabel(Service_Style__c),Equipment_Side_Doors__c,Type_of_Lid__c,Understructure__c,toLabel(Ownership__c),SBQQ__RequiredBy__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c IN :quoteList1];
        //updated as part of SDT-29792 end
        List<Quote_Order__c> qoList1= [SELECT Onsite_Contact__c,Onsite_Contact_Phone__c,Cust_Ref_Number__c,Service_Type__c,Service_Date__c,Instructions__c,Service_Quote_Line__c,Placement_Instructions__c FROM Quote_Order__c WHERE Service_Quote_Line__c IN: qlList1 AND Service_Type__c =: dlv];
        
        userMap.put(userObj.Id,userObj);
        quoteList.addAll(quoteList1);
        qlList.addAll(qlList1);
        qoList.addAll(qoList1);
    }

    public static void mapData(List<SBQQ__QuoteLine__c> qlList, List<Quote_Order__c> qoList, Map<Id,List<SBQQ__QuoteLine__c>> quoteListQLMap, Map<Id,List<SBQQ__QuoteLine__c>> parentQLIdListQLMap, Map<Id,Quote_Order__c> qlIdQOMap){
        for(SBQQ__QuoteLine__c ql: qlList){
            if(quoteListQLMap.containsKey(ql.SBQQ__Quote__c)){
                List<SBQQ__QuoteLine__c> qlList1= quoteListQLMap.get(ql.SBQQ__Quote__c);
                qlList1.add(ql);
                quoteListQLMap.put(ql.SBQQ__Quote__c,qlList1); //quoteId & List of QL
            }else{
                List<SBQQ__QuoteLine__c> qlList1= new List<SBQQ__QuoteLine__c>();
                qlList1.add(ql);
                quoteListQLMap.put(ql.SBQQ__Quote__c,qlList1); //quoteId & List of QL
            }
            if(ql.SBQQ__RequiredBy__c != Null){
                if(parentQLIdListQLMap.containsKey(ql.SBQQ__RequiredBy__c)){
                    List<SBQQ__QuoteLine__c> qlList1= parentQLIdListQLMap.get(ql.SBQQ__RequiredBy__c);
                    qlList1.add(ql);
                    parentQLIdListQLMap.put(ql.SBQQ__RequiredBy__c,qlList1); // parent qlId & list of QL
                }else{
                    List<SBQQ__QuoteLine__c> qlList1= new List<SBQQ__QuoteLine__c>();
                    qlList1.add(ql);
                    parentQLIdListQLMap.put(ql.SBQQ__RequiredBy__c,qlList1); // parent qlId & list of QL
                }
            }
        }

        for(Quote_Order__c qo: qoList){
            qlIdQOMap.put(qo.Service_Quote_Line__c,qo);  // delivery service quote line & delivery quote order
        }
    }

    public static List<QuoteSummary> bindingData(DataProcessor dpObj){
        List<QuoteSummary> qsList= new List<QuoteSummary>();
        for(SBQQ__Quote__c quote: dpObj.quoteList){
            QuoteSummary qsObj= new QuoteSummary();
            qsObj.quoteNumber = quote.Name;
            qsObj.teamAssignment = quote.Assigned_To__r.Name;
            qsObj.quoteStatus = quote.SBQQ__Status__c;
            qsObj.quoteDescription = GetQuoteSummary.getQuoteStatusDescription(qsObj.quoteStatus);
            qsObj.quoteRecordId = quote.Id;
            //System.debug('dpObj.userObj.CPQ_Active_User__c>>>'+dpObj.userObj.CPQ_Active_User__c);
            qsObj.cpqEligible= dpObj.userObj.CPQ_Active_User__c;
            List<Bundle> bList = new List<Bundle>();
            if(dpObj.quoteListQLMap.containsKey(quote.Id)){
                List<SBQQ__QuoteLine__c> qlList2= dpObj.quoteListQLMap.get(quote.Id);
                for(SBQQ__QuoteLine__c qlObj: qlList2){
                    if(qlObj.SBQQ__RequiredBy__c == null){
                        Bundle b= new Bundle();
                        b.bundleId= qlObj.Id;
                        b.bundleProductName= qlObj.SBQQ__ProductName__c;
                        b.quoteId= qlObj.SBQQ__Quote__c;
                        if(quote.SBQQ__Status__c == Constant_Util.QUOTE_APPROVED_LABEL || quote.SBQQ__Status__c == Constant_Util.QUOTE_DECLINED_LABEL){
                            b.isNotDraft= false;
                        }else{
                            b.isNotDraft= true;
                        }
                        RequestServiceConfig rscObj= new RequestServiceConfig();
                        rscObj.tabName = dpObj.rscTabStr;
                        rscObj.selectedService = qlObj.SBQQ__ProductName__c;
                        rscObj.size = qlObj.Equipment_Size__c;
                        rscObj.startDate = qlObj.SBQQ__StartDate__c;
                        rscObj.endDate = qlObj.SBQQ__EndDate__c;
                        //Added Original Quantity for Update Asset Case as part of SDT-29792 start
                        GetQuoteSummary.getQuantityComparison(rscObj,qlObj,quote);
                        //Added Original Quantity for Update Asset Case as part of SDT-29792 start
                        rscObj.quantity = qlObj.SBQQ__Quantity__c;
                        rscObj.descriptionOfWaste = qlObj.Description_of_Waste__c;
                        //SDT 41407,SDT41630
                        //rscObj.serviceSchedule = qlObj.Service_Schedule__c;
                        String serviceSchedule = QuoteLineServices.generateMonthlyScheduleDetails(qlObj);
                        if(serviceSchedule == '')
                            rscObj.serviceSchedule = qlObj.Service_Schedule__c;
                        else
                            rscObj.serviceSchedule = serviceSchedule;
                        rscObj.quoteOnly = quote.Quote_Only__c ? 'Yes' : 'No';
                        rscObj.additionalAccessories = '';
                        rscObj.compactorType = qlObj.Compactor_Type__c;
                        rscObj.compactorSize = qlObj.Compactor_Size__c;
                        rscObj.equipmentStyle = qlObj.Equipment_Style__c;
                        rscObj.equipmentSideDoors = qlObj.Equipment_Side_Doors__c;
                        rscObj.serviceStyle = qlObj.Service_Style__c;
                        rscObj.typeofLid = qlObj.Type_of_Lid__c;
                        rscObj.understructure = qlObj.Understructure__c;
                        rscObj.ownership = qlObj.Ownership__c;
                        SpecialDisposal sdObj= new SpecialDisposal();
                        sdObj.tabName = dpObj.sdTabStr;
                        sdObj.certificateOfDisposal = qlObj.Certificate_of_Disposal__c ? 'Yes' : 'No';
                        sdObj.certificateOfDestruction = qlObj.Certificate_of_Destruction__c ? 'Yes' : 'No';
                        sdObj.profileNumber = qlObj.Profile_Number__c;
                        sdObj.landfillRequested = qlObj.Landfill_Tickets__c ? 'Yes' : 'No';
                        sdObj.specialDisposalInstructions = qlObj.Special_Disposal_Description__c;
                        ContainerPositions cpObj = new ContainerPositions();
                        cpObj.tabName = dpObj.cpTabStr;
                        cpObj.selectedPosition = qlObj.LocationPositionName__c;
                        ServiceRestrictions srObj = new ServiceRestrictions();
                        srObj.tabName = dpObj.srTabStr;
                        if(qlObj.Service_Start_Time__c!=null){
                            srObj.earliestServiceTime = GetQuoteSummary.getTime(qlObj.Service_Start_Time__c);
                        }
                        if(qlObj.Service_End_Time__c!=null){
                            srObj.latestServiceTime = GetQuoteSummary.getTime(qlObj.Service_End_Time__c);
                        }
                        srObj.gateCodes = qlObj.Gate_Code__c;
                        srObj.driverInstructions = qlObj.Restriction_Details__c;
                        ProjectServices psObj= new ProjectServices();
                        psObj.tabName = dpObj.psTabStr;
                        psObj.selectedProjectName = quote.Project__r.Name;
                        psObj.partOfProject = quote.Project_Services_Request__c ? 'Yes' : 'No';
                        DeliveryInstructions diObj = new DeliveryInstructions();
                        diObj.tabName = dpObj.diTabStr;
                        if(dpObj.parentQLIdListQLMap.containsKey(qlObj.id)){
                            List<SBQQ__QuoteLine__c> childQlList= dpObj.parentQLIdListQLMap.get(qlObj.id);
                            for(SBQQ__QuoteLine__c chlidQl: childQlList){
                                if(chlidQl.SBQQ__ProductFamily__c == dpObj.wasteCategory){
                                    if(dpObj.parentQLIdListQLMap.containsKey(chlidQl.id)){
                                        List<SBQQ__QuoteLine__c> wasteStreamList = dpObj.parentQLIdListQLMap.get(chlidQl.id);
                                        rscObj.wasteStream = wasteStreamList[0].SBQQ__ProductName__c;
                                    }
                                }else if(chlidQl.SBQQ__RequiredBy__c != null && chlidQl.SBQQ__ProductOption__r.SBQQ__Feature__r.Name != dpObj.standardServices && chlidQl.SBQQ__ProductOption__r.SBQQ__Feature__r.Name != dpObj.wasteStream){
                                    if(rscObj.additionalAccessories!=''){
                                        rscObj.additionalAccessories = rscObj.additionalAccessories+', '+chlidQl.SBQQ__ProductName__c;
                                    }else{
                                        rscObj.additionalAccessories = chlidQl.SBQQ__ProductName__c;
                                    }
                                }else if(chlidQl.SBQQ__RequiredBy__c != null && chlidQl.SBQQ__ProductName__c == dpObj.dlv){
                                    if(dpObj.qlIdQOMap.containsKey(chlidQl.Id)){
                                        Quote_Order__c qo = dpObj.qlIdQOMap.get(chlidQl.Id);
                                        diObj.contactName = qo.Onsite_Contact__c;
                                        diObj.phoneNumber = qo.Onsite_Contact_Phone__c;
                                        diObj.customerPurchaseNumber = qo.Cust_Ref_Number__c;
                                        //SDT-23244 introducing Placement Instructions.
                                        diObj.placementInstructions = qo.Placement_Instructions__c;
                                        //System.debug('diObj.customerPurchaseNumber>>>'+diObj.customerPurchaseNumber);
                                    }
                                }
                            }
                        }
                        b.requestServiceConfigObj = rscObj;
                        b.deliveryInstructionsObj = diObj;
                        b.specialDisposalObj = sdObj;
                        b.containerPositionsObj = cpObj;
                        b.projectServicesObj = psObj;
                        b.serviceRestrictionsObj = srObj;
                        bList.add(b); 
                    }
                }  
            }
            qsObj.bundleList = bList;
            qsList.add(qsObj);
        }
        return qsList;
    }
	
    //Added Original Quantity for Update Asset Case as part of SDT-29792 to compare existing and requested quantity
    public static void getQuantityComparison(RequestServiceConfig rscObj, SBQQ__QuoteLine__c qlObj, SBQQ__Quote__c quote){
        //rscObj.isUpdateAssetCase = quote.SBQQ__Opportunity2__r.Case__r.Case_Record_Type__c==Constant_Util.UPDATE_ASSET_CASE ? true : false;
		//Changes related to SDT - 33165
        rscObj.isUpdateAssetCase = quote.SBQQ__Opportunity2__r.Case__r.Case_Record_Type__c==Constant_Util.MODIFY_EXISTING_SERVICE_CASE ? true : false;
        
       rscObj.originalQuantity = qlObj.AssetId__c!=null ? qlObj.AssetId__r.Quantity__c : null;
   }
    
    public static String getTime(Time t){ //human readbale time format
        Integer hour = Integer.valueOf(String.valueOf(t).left(2)); //first 2 characters are hour
        Integer minute = Integer.valueOf(String.valueOf(t).substringBetween(':',':')); // between both : in String
        DateTime myDT = DateTime.newInstance(Date.today(), Time.newInstance(hour, minute, 0, 0)); // only care about hour and minute
        return myDT.format('h:mm a');
    }
}