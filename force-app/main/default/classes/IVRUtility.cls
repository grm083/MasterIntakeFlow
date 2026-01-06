/*************************************************************
@Name: QuoteLineCreationHandler
@Author: TCS (Jatan sharma)
@CreateDate: 23/10/24
@Description: Utility class for IVR New service Process.
@UsedBy: SDT-31997
**************************************************************/
public with sharing class IVRUtility {

    private static string const_Delivery = 'Delivery';
    private static string const_HAUL = 'Haul';
    private static string const_Temporary = 'Temporary';
    private static string const_TEMP = 'TEMP';
    private static string const_PERM = 'PERM';
    private static string const_Pickup = 'Pickup';
    private static string const_ASAP = 'ASAP';
    private static string const_newQuote = 'newQuote';
	private static string const_taskCallObject = 'IVR New Service Case Creation';
	private static string const_taskStatus = 'Open';
	private static string const_taskSubject = 'Obtain Internal Response';
	private static string const_taskType = 'Call';
	private static string const_taskProcess = 'Case Assignment';
	private static string const_taskTeamUser = 'CSGEN';
	private static string const_taskPriority = 'Normal';
	private static string const_ExceptionDescription = 'IVR Process Failed';
	private static string const_ApplicationName = 'IVR/Chat Now New Service';
	private static string const_ExceptionType = 'IVR New service Error';


    public static void createQuoteOrder(ID quoteId, Id parentQL, case caseData,List<SBQQ__QuoteLine__c> qlList) {
        Id HaulId;
        QuoteProcurementController.OrderWrapper qo = new QuoteProcurementController.orderWrapper();
        string caseSubType = caseData.Case_Sub_Type__c == const_Temporary ? const_TEMP : const_PERM;
        //Build Order Wrapper
        qo.parentQuoteLine = parentQL;
        qo.serviceDate = caseData.Delivery_Date__c;
        qo.serviceEndDate = caseData.Removal_Date__c;
        qo.serviceType = const_Delivery;
        qo.quantity = 1.0;
        qo.onsiteContact = caseData.Site_Contact__c;
        qo.onsitePhone = caseData.Site_Contact_Phone__c;
        qo.PONumber = caseData.PurchaseOrder_Number__c;
        qo.duration = caseSubType;
        qo.quoteId = quoteID;
        qo.instructions = caseData.SalesMeet_Container_Position__c;
        qo.acornInstructions = 'ONSITE CONTACT : '+ caseData.Site_Contact__c+'; '+ 'CONTACT PHONE : '+ caseData.Site_Contact_Phone__c+'; ' +qo.instructions;
        QuoteProcurementController.createDelivery(
            qo,
            const_Delivery,
            qo.instructions
        );
        for(SBQQ__QuoteLine__c quoteLine : qlList){
            if(quoteLine.SBQQ__Product__r.Name == const_HAUL)
            {
                 HaulId = quoteLine.Id;
            }
        }

         if(caseData.Empty_and_Return_Date__c !=null){
        List<String> EmptyandReturnDates = caseData.Empty_and_Return_Date__c.split(',');
            List<WorkOrderController.QuoteOrderWrapper> lQwrap = new List<WorkOrderController.QuoteOrderWrapper>();
                for(string serviceDate : EmptyandReturnDates){
                WorkOrderController.QuoteOrderWrapper qwrp = new WorkOrderController.QuoteOrderWrapper();
                qwrp.quoteLineParentId=parentQL;
                qwrp.serviceType=const_Pickup;
                qwrp.productType=const_HAUL;
                qwrp.quoteLineId=HaulId;
                qwrp.serviceDate=serviceDate;
                qwrp.serviceTime=const_ASAP;
                qwrp.contact=caseData.Site_Contact__c;
                qwrp.phone=caseData.Site_Contact_Phone__c;
                qwrp.instruction=caseData.SalesMeet_Container_Position__c;
                qwrp.custRefNumber=caseData.PurchaseOrder_Number__c;
                qwrp.actionType=const_newQuote;
                qwrp.duration=caseSubType;
                qwrp.occurenceType=caseData.Service_Occurrence_Type_Code__c;
                qwrp.serviceLineStartDate=caseData.Delivery_Date__c;
                qwrp.serviceLineEndDate=caseData.Removal_Date__c;
                qwrp.disableDelete=false;
                qwrp.bypassWorkOrder=false;
                lQwrap.add(qwrp);
            }
            string workOrderData = JSON.serialize(lQwrap);
            WorkOrderController.AssetAvailabilityWrapper assetAvail = new WorkOrderController.AssetAvailabilityWrapper();
            assetAvail.assetAvailability = false;
            string success = WorkOrderController.actionsOnQuoteLineOrders(quoteId,parentQL,caseData.Delivery_Date__c,caseData.Removal_Date__c,caseData.Delivery_Date__c,workOrderData,assetAvail);
            system.debug(success);
         }
    }

    public static void taskandGenesysRouting(List<case> getData, String source, String ExceptionDetails) {
        boolean createGeneysisRouting = true;
        string userGrServiceFlag;
        boolean sfdcTeamuserAssingment = false;
        boolean updateTaskOwner = false;
        task t = new task();
        CSR_User_Data_Setup__mdt csgenUserData = CSR_User_Data_Setup__mdt.getInstance('CSGEN');
        system.debug(csgenUserData);
        if (csgenUserData != null) {
            sfdcTeamuserAssingment = true;
            userGrServiceFlag = csgenUserData.GR_Service_Flag__c;
            //updateTaskOwner = csgenUserData.Is_Genesys_User__c ? false : true;
            t.Last_Agent_ID__c = UserInfo.getUserId();
            //t.Last_Agent_ID__c = csgenUserData.SFDC_user_Id__c;
            t.OwnerId = UserInfo.getUserId();
        }
        Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName()
            .get('Initiate_Task')
            .getRecordTypeId();
        t.whatId = getData[0].ID;
        t.CallObject = const_taskCallObject;
        t.Status = const_taskStatus;
        t.Subject = const_taskSubject;
        t.recordTypeId = recordTypeId;
        t.Priority = const_taskPriority;
        t.type = const_taskType;
        t.Process__c = const_taskProcess;
        t.Due_Date_Time__c = system.now();
        t.ActivityDate = date.valueOf(system.now());
        t.Description__c ='Case routed to agent for manual processing. '+'\r\n'
        +' Please use Task Comments section to create Quote and configure product.';
        t.Description =
            'Product configuration details :' +'\r\n'+' ' +
            '\r\n' +
            'Equipment : ' +
            getData[0].Equipment_Type_Code__c +
            '\r\n' +' ' +'\r\n'+
            'Material : ' +
            getData[0].Material_Type__c +
            '\r\n' +' ' +'\r\n'+
            'Equipment Size : ' +
            getData[0].Equipment_Size_Code__c +
            '\r\n' +' ' +'\r\n'+
            'Service Occurrence : ' +
            getData[0].Service_Occurrence_Type_Code__c +
            '\r\n' +' ' +'\r\n'+
            'Quantity : ' +
            getData[0].SalesMeet_Quantity__c +
            '\r\n' +' ' +'\r\n'+
            'Delivery Date : ' +
            Datetime.newInstance(getData[0].Delivery_Date__c.year(), getData[0].Delivery_Date__c.month(), getData[0].Delivery_Date__c.day()).format('MM.dd.YYYY')
             +
            '\r\n' +' ' +'\r\n'+
            'Ownership : ' +
            'Vendor Owned' +
            '\r\n' +' ' +'\r\n'+
            'Company Category : ' +
            getData[0].Company_Category__c +
            '\r\n' +' ' +'\r\n'+
            'Quote Only : ' +
            getData[0].Quote_Only__c +
            '\r\n' +' ' +'\r\n'+
            'Site Contact : ' +
            getData[0].Site_Contact__c +
            '\r\n' +' ' +'\r\n'+
            'Site Contact Phone : ' +
            getData[0].Site_Contact_Phone__c +
            '\r\n' +' ' +'\r\n'+
            'Placement Instruction : ' +
            getData[0].Offsite_Street_Address__c +
            '\r\n' +' ' +'\r\n'+
            'Offsite City : ' +
            getData[0].Offsite_City__c +
            '\r\n' +' ' +'\r\n'+
            'Offsite State : ' +
            getData[0].Offsite_State__c +
            '\r\n' +' ' +'\r\n'+
            'Offsite Postal Code  : ' +
            getData[0].Offsite_Postal_Code__c +
            '\r\n';
            
            try {
            insert t;
            } catch (Exception ex) {
                createGeneysisRouting = false;
                createIVRExceptionLogObj('taskandGenesysRouting', ex.getMessage(),'IVRUtility');
            }
            if(createGeneysisRouting){
                CreatePendingInformationTask.createGeneysRouting(t,userGrServiceFlag,sfdcTeamuserAssingment);
            }
    }

    public static ExceptionLog__c createIVRExceptionLogObj(String MethodName,String ExceptionDetails,string className){
        ExceptionLog__c exceptionLogObj = new ExceptionLog__c();
        exceptionLogObj.Org_Id__c = UserInfo.getOrganizationId();
        exceptionLogObj.Exception_Description__c = const_ExceptionDescription;
        exceptionLogObj.Exception_Details__c = ExceptionDetails; // holds errorMessage
        exceptionLogObj.Log_Time__c = System.now();
        exceptionLogObj.Username__c = UserInfo.getUserId();
        exceptionLogObj.Class_Name__C = className;
        exceptionLogObj.Method_Name__c = MethodName;
        exceptionLogObj.Application_Name__c = const_ApplicationName;
        exceptionLogObj.Exception_Type__c = const_ExceptionType;
        insert exceptionLogObj;
        return exceptionLogObj;
    }

    @future(callout=true)
    public static void createAvailablity(ID ParentQuoteLineID) {
        AAV_Asset_Availability__c avv = QuoteProcurementController.getAvailabilityResponse(
            ParentQuoteLineID
        );
    }

}
