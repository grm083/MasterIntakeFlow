/*************************************************************
@Name: ScreenpopController
@Author: Accenture (Ed Valdez)
@CreateDate: 4/4/2019
@Description: Handles incoming phone call or workitem 
    interactions from Genesys via the Gplus Adapter and
    determines appropriate landing page based on incoming
    query parameters (Genesys attached data)
@UsedBy: SDT-2087, SDT-2088, SDT-2758, SDT-2763, SDT-2689, 
    SDT-3648, SDT-3489, SDT-4002, SDT-4271, SDT-19322
**************************************************************/
public without sharing class ScreenpopController {
    
    public static final Map<String, Id> CaseTypesByIntent = new Map<String, Id>();

    public static final String SESSION_CACHE_KEY = 'cache.screenpop';
    public static final String PARAM_MEDIA_TYPE = 'MediaType';
    public static final String PARAM_IVRMEDIA = 'ivrmedia'; // SDT-26069
    public static final String PARAM_CONNECTION_ID = 'ivrconnid';
    public static final String PARAM_INTERACTION_ID = 'InteractionID';
    public static final String PARAM_INTENT = 'cti_SFDCIntent';
    public static final String PARAM_REF_NO = 'cti_SFDCCaseRefNo';
    public static final String PARAM_ACCT_ID = 'cti_SFDCAcctID';
    public static final String PARAM_LOCATION_ID = 'cti_SFDCAcctLocation';
    public static final String PARAM_ASSET_ID = 'ivrpickupAssetID';
    public static final String PARAM_CONTACT_ID = 'cti_SFDCContactID';
    public static final String INTENT_OTHER = 'other';    
    public static final String INTENT_PICKUP = 'pickup';    
    public static final String INTENT_ETA = 'eta';    
    public static final String INTENT_DELIVERY = 'delivery';    
    public static final String SEARCH1 = '{"componentDef":"forceSearch:searchPage","attributes":{"term":"';
    public static final String SEARCH2 = '","scopeMap":{"type":"TOP_RESULTS"},"context":{"disableSpellCorrection":false,"disableIntentQuery":false,"permsAndPrefs":{"OrgPermissions.UnionAppNavSmartScope":false,"SearchUi.feedbackComponentEnabled":false,"SearchUi.searchUIPilotFeatureEnabled":false,"SearchExperience.LeftNavEnhancementEnabled":true,"Search.crossObjectsAutoSuggestEnabled":true,"Search.maskSearchInfoInLogs":false,"SearchUi.orgHasAccessToSearchTermHistory":false,"SearchResultsLVM.lvmEnabledForSearchResultsOn":true,"SearchUi.searchUIInteractionLoggingEnabled":false,"MySearch.userCanHaveMySearchBestResult":false,"SearchResultsLVM.lvmEnabledForTopResults":false,"MySearch.userCanHaveMySearch":false}},"groupId":"DEFAULT"},"state":{}}';
    public static final String MEDIA_TYPE_VOICE = 'voice';
    public static final String MEDIA_TYPE_WORKITEM = 'workitem';
    public static final String MEDIA_TYPE_CHAT = 'chat'; // Added SDT-25799
    public static final String PARAM_SFDCRecId = 'cti_SFDCObjRecordID';
    public static final Id SERVICE_HEADER_Id = Schema.SobjectType.Asset.getRecordTypeInfosByDeveloperName().get('Service_Header').getRecordTypeId();
    public static final String PARAM_IVRQueue = 'cti_TargetVQ';
    public static final String PARAM_IVRlang = 'cti_ivrlanguage';
    public static final String PARAM_IVRLOB = 'ivrlob';
    public static final String PARAM_IVREXITpOINT = 'cti_ivrexitpoint';
    public static final String PARAM_IVRSELF = 'ivrsseligible';
    public static final String PARAM_IVRSELF_PICKUP = 'ivrsseligiblepickup';
    public static final String PARAM_IVRSELF_STATUS = 'ivrsseligiblestatus';
    public static final String PARAM_IVRDNIS = 'cti_DNIS';
    public static final String PARAM_IVRANI = 'cti_CallersANI';
    public static final String PARAM_IVRVENDOR = 'ivrisvendor';
    public static final String PARAM_IVRWO = 'cti_WorkOrderNumber';
    public static final String PARAM_IVR4C = 'ivrskill';
    public static final String ACORN_WORK_ORDER_PREFIX='W';
    public static Final String PARAM_PICKUP_Date = 'ivrpickupdate';

    //Below parameters added as part of SDT-17701
    public static Final String PARAM_SPOKEN_NAME = 'cti_NameTitle';
    public static Final String PARAM_INTENT_NAME = 'cti_IntentName';
    public static Final String PARAM_SPOKEN_LOC = 'cti_SpokenLocName';
    public static Final String PARAM_SPOKEN_REF = 'cti_SpokenRefNumber';
    //Above parameters added as part of SDT-17701
     //Below parameter added as part of SDT-18313
    public static Final String PARAM_SPOKEN_INTENT = 'cti_SpokenIntent'; 
    //Above parameter added as part of SDT-18313
    public static Final String PARAM_SUBTYPE_TEMPRETURN = 'cti_ivrtempreturn'; // SDT-23351 
    
    // Start - Below Paramater added SDT-19322 // 
     // Start- These must be in lower case //
     // 6-Oct-2021 - Modified Intent Names as per SDT-20935 -- Bulk,Add Lock, Container Lids
    public static final String INTENT_MISSED_SERVICE = 'missed service';
    public static final String INTENT_SERVICE_CHANGE = 'service change';
    public static final String INTENT_RELOCATION = 'relocation';
    public static final String INTENT_ADD_LOCK = 'add lock'; // SDT-20935
    public static final String INTENT_CONTAINER_LIDS = 'container lids'; // SDT-20935
    public static final String INTENT_BULK = 'bulk'; // SDT-20935
    public static final String INTENT_REPAIR = 'repair';
    public static final String INTENT_HAUL_AWAY = 'haul away';
    public static final String INTENT_BALE = 'bale'; // SDT-21062
     // End- These must be in lower case //
    
    public static final String CASETYPE_PICKUP = 'Pickup';
    public static final String CASETYPE_SPECIAL_REQUEST = 'Special Request';
    public static final String CASETYPE_STATUS = 'Status';
    public static final String CASETYPE_CHANGE_SERVICE = 'Change Service';
    
    public static final String CASE_SUBTYPE_BULK = 'Bulk';
    public static final String CASE_SUBTYPE_HAUL_AWAY = 'Haul Away - No Equipment';
    public static final String CASE_SUBTYPE_LIDS = 'Lids';
    public static final String CASE_SUBTYPE_LOCS = 'Locks';
    public static final String CASE_SUBTYPE_SRVC_PERFORM = 'Service Not Performed';
    public static final String CASE_SUBTYPE_SRVC_RELOCATE = 'Relocate Container';
    public static final String CASE_SUBTYPE_BALES = 'Bale(s)'; // SDT-21062
    
    public static final String CASE_REASON_CUST_REPORTED = 'Customer Reported';
    public static final String BLANK_STRING = '';
    
    public static final String CASE_RT_STATUSCASE = 'Status_Case';
    public static final String CASE_RT_MODIFYCASE = 'Modify_Existing_Service_Case';
    public static final String CASE_RT_SERVICEREQCASE = 'Service_Request_Case';
    public static final String CASE_RT_PICKUPCASE = 'Pickup_Case';
    public static final String CASE_RT_REPAIRCASE = 'Repair_Case';
    
    public static final Map<String,String> caseTypeValuesbyIntentMap = new Map<String,String>();
    public static final Map<String,String> caseSubTypebyIntentMap = new Map<String,String>();
    public static final Map<String,String> caseReasonbyIntentMap = new Map<String,String>();


    //SDT-41550 New fields for IVR New service.
    public static final String  NSEqCode = 'cti_NS_EqCode';
    public static final String  NSMatType = 'cti_NS_MatType';
    public static final String  NSEqSizeCode = 'cti_NS_EqSizeCode';
    public static final String  NSDeliveryDate = 'cti_NS_DeliveryDate';
    public static final String  NSRemovalDate = 'cti_NS_RemovalDate';
    public static final String  NSEARDates = 'cti_NS_EARDates';
    public static final String  NSPlacementInts = 'cti_NS_PlacementInts';
    public static final String  NSSiteContName = 'cti_NS_ContactName';
    public static final String  NSSiteContPhNum = 'cti_NS_ContactPhNum';
    public static final String  NSReason = 'cti_NS_Reason';
    public static final String  NSQuoteOnly = 'cti_NS_QuoteOnly';
    public static final String  NSQuoteContName = 'cti_NS_QuoteContName';
    public static final String  NSQuoteContPhNum = 'cti_NS_QuoteContPhNum';
    public static final String  NSCaseSubType = 'cti_NS_CaseSubType';
    public static final String  NSCaseReason = 'cti_NS_CaseReason';
    public static final String  NSCompanyCategory = 'cti_NS_CompCategory';
    




    
    // End //

    public Screenpop pop {get;set;}
   /* public String referenceNumber { get; set; }
    public string workOrder { get; set;}
    public String PageTitle {
        get {
            String env = UserInfo.getUserName();
            env = env == null ? Constant_Util.EMPTY_STRING : env.substringAfterLast('.').trim();
            return Constant_Util.EMPTY_STRING.equals(env) ? 'PRODUCTION' : 'Sandbox: ' + env.toUpperCase();
        }
    }
    Public Boolean iSError {get;set;}
    Public Boolean isredirectCase {get;Set;}*/
	/**@description The custom error message */
    //public String errorMessage {get;set;}
    //@Kyle 4/25 edit made to get DeveloperName() record type Id
    static {
        CaseTypesByIntent.put(INTENT_OTHER, Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constant_Util.STANDARD).getRecordTypeId()); // default generic case
        CaseTypesByIntent.put(INTENT_PICKUP, Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constant_Util.PICK_CASE).getRecordTypeId());
        CaseTypesByIntent.put(INTENT_ETA, Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constant_Util.R_STATUS_CASE).getRecordTypeId());
        CaseTypesByIntent.put(INTENT_DELIVERY, Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constant_Util.R_NEW_SERVICE_CASE).getRecordTypeId());
        /* Start SDT-19322 To get the record type name for particular intent 
		SDT-20935 Modified Intent Names (add lock,container lids,bulk ) */
        CaseTypesByIntent.put(INTENT_MISSED_SERVICE, Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CASE_RT_STATUSCASE).getRecordTypeId());
        CaseTypesByIntent.put(INTENT_SERVICE_CHANGE, Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CASE_RT_MODIFYCASE).getRecordTypeId());
        CaseTypesByIntent.put(INTENT_RELOCATION, Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CASE_RT_SERVICEREQCASE).getRecordTypeId());
        CaseTypesByIntent.put(INTENT_ADD_LOCK, Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CASE_RT_SERVICEREQCASE).getRecordTypeId());
        CaseTypesByIntent.put(INTENT_CONTAINER_LIDS, Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CASE_RT_SERVICEREQCASE).getRecordTypeId());
        CaseTypesByIntent.put(INTENT_BULK, Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CASE_RT_PICKUPCASE).getRecordTypeId());
        CaseTypesByIntent.put(INTENT_REPAIR, Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CASE_RT_REPAIRCASE).getRecordTypeId());
        CaseTypesByIntent.put(INTENT_HAUL_AWAY, Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CASE_RT_PICKUPCASE).getRecordTypeId());
        CaseTypesByIntent.put(INTENT_BALE, Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CASE_RT_PICKUPCASE).getRecordTypeId()); // SDT-21062
        /* End */ 
    }
    
    public PageReference init() {
        //modified as part of SDT-39599
        PageReference page = null;
        try {
        //iSError = false;
        //isredirectCase = false;
        System.debug('>>>>> SCREENPOP URL = [' + ApexPages.currentPage().getUrl() + ']');     
        String ivrMediaParam = defaultTo(ApexPages.currentPage().getParameters().get(PARAM_IVRMEDIA), Constant_Util.EMPTY_STRING);
        String mediaTypeParam = defaultTo(ApexPages.currentPage().getParameters().get(PARAM_MEDIA_TYPE), Constant_Util.EMPTY_STRING);
        system.debug('ivrMediaParam : ' + ivrMediaParam + ': mediaTypeParam : ' + mediaTypeParam);
        String mediaType = mediaTypeParam != null && !Constant_Util.EMPTY_STRING.equals(mediaTypeParam) ? mediaTypeParam : ivrMediaParam;
        String genesysIdKey = MEDIA_TYPE_VOICE.equals(mediaType) || MEDIA_TYPE_CHAT.equals(mediaType) ? PARAM_CONNECTION_ID : PARAM_INTERACTION_ID; // Added Media Type 'Chat' SDT-25799
        //String SFDCreqobjid = defaultto(ApexPages.currentPage().getParameters().get(PARAM_SFDCRecId), Constant_Util.EMPTY_STRING);
        
        pop = new Screenpop(mediaType);
        pop.GenesysId = defaultTo(ApexPages.currentPage().getParameters().get(genesysIdKey), Constant_Util.EMPTY_STRING);
        pop.Intent = defaultTo(ApexPages.currentPage().getParameters().get(PARAM_INTENT), INTENT_OTHER).toLowerCase();
        pop.CaseRefNo = defaultTo(ApexPages.currentPage().getParameters().get(PARAM_REF_NO), Constant_Util.EMPTY_STRING);
        pop.AcctId = defaultTo(ApexPages.currentPage().getParameters().get(PARAM_ACCT_ID), Constant_Util.EMPTY_STRING);
        pop.AcctLocationId = defaultTo(ApexPages.currentPage().getParameters().get(PARAM_LOCATION_ID), Constant_Util.EMPTY_STRING); 
        pop.ContactId = defaultTo(ApexPages.currentPage().getParameters().get(PARAM_CONTACT_ID), Constant_Util.EMPTY_STRING);
        pop.SFDCRecordId = defaultTo(ApexPages.currentPage().getParameters().get(PARAM_SFDCRecId), Constant_Util.EMPTY_STRING);
        pop.ivrQueue = defaultTo(ApexPages.currentPage().getParameters().get(PARAM_IVRQueue), Constant_Util.EMPTY_STRING);
        pop.ivrLang = defaultTo(ApexPages.currentPage().getParameters().get(PARAM_IVRlang), Constant_Util.EMPTY_STRING);
        pop.ivrLOB = defaultTo(ApexPages.currentPage().getParameters().get(PARAM_IVRLOB), Constant_Util.EMPTY_STRING);
        pop.ivrexitpoint = defaultTo(ApexPages.currentPage().getParameters().get(PARAM_IVREXITpOINT), Constant_Util.EMPTY_STRING);
        pop.ivrsseligible = defaultTo(ApexPages.currentPage().getParameters().get(PARAM_IVRSELF), Constant_Util.EMPTY_STRING);
        pop.ivrsseligiblepickup = defaultTo(ApexPages.currentPage().getParameters().get(PARAM_IVRSELF_PICKUP), Constant_Util.EMPTY_STRING);
        pop.ivrsseligiblestatus = defaultTo(ApexPages.currentPage().getParameters().get(PARAM_IVRSELF_STATUS), Constant_Util.EMPTY_STRING);
        pop.ivrdnis = defaultTo(ApexPages.currentPage().getParameters().get(PARAM_IVRDNIS), Constant_Util.EMPTY_STRING);
        pop.ivrWorkOrder = defaultTo(ApexPages.currentPage().getParameters().get(PARAM_IVRWO), Constant_Util.EMPTY_STRING);
        pop.ivrVendor = defaultTo(ApexPages.currentPage().getParameters().get(PARAM_IVRVENDOR), Constant_Util.EMPTY_STRING);
        pop.ivrR4C = defaultTo(ApexPages.currentPage().getParameters().get(PARAM_IVR4C), Constant_Util.EMPTY_STRING);
        pop.ivrContainerId = defaultTo(ApexPages.currentPage().getParameters().get(PARAM_ASSET_ID), Constant_Util.EMPTY_STRING);
        pop.ivrani = defaultTo(ApexPages.currentPage().getParameters().get(PARAM_IVRANI), Constant_Util.EMPTY_STRING);
        pop.ivrPickDate = defaultTo(ApexPages.currentPage().getParameters().get(PARAM_PICKUP_Date), Constant_Util.EMPTY_STRING);
        system.debug('>>>>> genesysIdKey'+genesysIdKey);
        System.debug('>>>>> SCREENPOP RecordId: '+ pop.GenesysId);
        
        //Below parameters added as part of SDT-17701
        pop.ivrSpokenName = defaultTo(ApexPages.currentPage().getParameters().get(PARAM_SPOKEN_NAME), Constant_Util.EMPTY_STRING);
        pop.ivrIntentName = defaultTo(ApexPages.currentPage().getParameters().get(PARAM_INTENT_NAME), Constant_Util.EMPTY_STRING);      
        pop.ivrSpokenLoc = defaultTo(ApexPages.currentPage().getParameters().get(PARAM_SPOKEN_LOC), Constant_Util.EMPTY_STRING);      
        pop.ivrSpokenRefNum = defaultTo(ApexPages.currentPage().getParameters().get(PARAM_SPOKEN_REF), Constant_Util.EMPTY_STRING);
       //Above parameters added as part of SDT-17701
       //Below parameter added as part of SDT-18313
        pop.ivrSpokenIntent = defaultTo(ApexPages.currentPage().getParameters().get(PARAM_SPOKEN_INTENT), Constant_Util.EMPTY_STRING);   
       //Above parameter added as part of SDT-18313
       // Start - SDT-23351
        pop.ivrSubTypeReturn = defaultTo(ApexPages.currentPage().getParameters().get(PARAM_SUBTYPE_TEMPRETURN), Constant_Util.EMPTY_STRING);
        // End

        //SDT-41550 New fields for IVR New service.
        if(pop.Intent == INTENT_DELIVERY)
        {
        pop.NSEqCode = defaultTo(ApexPages.currentPage().getParameters().get(NSEqCode), Constant_Util.EMPTY_STRING);
        pop.NSMatType = defaultTo(ApexPages.currentPage().getParameters().get(NSMatType), Constant_Util.EMPTY_STRING);
        pop.NSEqSizeCode = defaultTo(ApexPages.currentPage().getParameters().get(NSEqSizeCode), Constant_Util.EMPTY_STRING);
        pop.NSDeliveryDate = defaultTo(ApexPages.currentPage().getParameters().get(NSDeliveryDate), Constant_Util.EMPTY_STRING);
        pop.NSRemovalDate = defaultTo(ApexPages.currentPage().getParameters().get(NSRemovalDate), Constant_Util.EMPTY_STRING);
        pop.NSEARDates = defaultTo(ApexPages.currentPage().getParameters().get(NSEARDates), Constant_Util.EMPTY_STRING);
        pop.NSPlacementInts = defaultTo(ApexPages.currentPage().getParameters().get(NSPlacementInts), Constant_Util.EMPTY_STRING);
        pop.NSSiteContName = defaultTo(ApexPages.currentPage().getParameters().get(NSSiteContName), Constant_Util.EMPTY_STRING);
        pop.NSSiteContPhNum = defaultTo(ApexPages.currentPage().getParameters().get(NSSiteContPhNum), Constant_Util.EMPTY_STRING);
        pop.NSReason = defaultTo(ApexPages.currentPage().getParameters().get(NSReason), Constant_Util.EMPTY_STRING);
        pop.NSQuoteOnly = defaultTo(ApexPages.currentPage().getParameters().get(NSQuoteOnly), Constant_Util.EMPTY_STRING);
        pop.NSQuoteContName = defaultTo(ApexPages.currentPage().getParameters().get(NSQuoteContName), Constant_Util.EMPTY_STRING);
        pop.NSQuoteContPhNum = defaultTo(ApexPages.currentPage().getParameters().get(NSQuoteContPhNum), Constant_Util.EMPTY_STRING); 
        pop.NSCaseSubType = defaultTo(ApexPages.currentPage().getParameters().get(NSCaseSubType), Constant_Util.EMPTY_STRING); 
        pop.NSCaseReason = defaultTo(ApexPages.currentPage().getParameters().get(NSCaseReason), Constant_Util.EMPTY_STRING); 
        pop.NSCompanyCategory = defaultTo(ApexPages.currentPage().getParameters().get(NSCompanyCategory), Constant_Util.EMPTY_STRING); 
        }
        
            
        
        //@Kyle edits made for SDT-3720 and SDT-5395 
        //---------------------------------------------------------
        Boolean isTask = false;
        Boolean isCase = false;
        Boolean isNewCase = false;
        Boolean isWorkOrder = false;
        if(!string.isBlank(pop.SFDCRecordId)){
        
            // If task or email message Id is passed
            // Check for Task and EmailMessage
            if(pop.SFDCRecordId.substring(0,3)=='00T'){ 
                page = PopTask(pop);
            }else if(pop.SFDCRecordId.substring(0,3)=='02s'){
                page = popEmailMessage(pop);
            }
           else if(pop.SFDCRecordId.substring(0,3)=='a9L'){
           page = popQuote(pop);
      	 }
        }
       
        if(!String.IsBlank(pop.ivrWorkOrder) && !String.IsBlank(pop.ivrVendor) && Constant_Util.STR_TRUE.equalsIgnoreCase(pop.ivrVendor)){
            page = popRedirectWorkOrder(pop);
			isWorkOrder = page != null ? true : false;
        
        }
        if(!Constant_Util.EMPTY_STRING.equals(pop.CaseRefNo) && page==null){
            page = popExistingCase(pop);
			isCase = page != null ? true : false;
        }
        //---------------------------------------------------------
        if(page == null){
            page = popNewCase(pop); 
			isCase = page != null ? true : false;			
        }else{}
        if((isCase || isWorkOrder) && String.ISNotBlank(pop.GenesysId)){
				createCache(pop);
        }else{}
        if(page != null){
        	page.setRedirect(true);
            }
        }
        catch(Exception ex) {
            logException(ApexPages.currentPage().getUrl(), ex, 'ScreenpopControllerinit');
        }
        return page;
        
    }
    
	//Create Platform Cache Details
	private void createCache(Screenpop pop){
		string jsonPop = JSON.serialize(pop);
	        // Get partition --- /** Change Start Here for SDT-14140 **/
	        //Cache.SessionPartition sessionPart = Cache.Session.getPartition(Constant_Util.IVREXIT);
		// Add cache value to the partition
		string cacheKey = Constant_Util.IVREXIT + Constant_Util.DOT + pop.GenesysId; 
		Cache.Session.put(cacheKey,jsonPop,600);
		/** Change Ends Here for SDT-14140 **/
	}
	
    //Redirect To Work Order
    private PageReference popRedirectWorkOrder(Screenpop pop) {
        PageReference Page = null;
        WorkOrder WO = null;
		List<WorkOrder> wolst = new List<WorkOrder>();
        try{
            for(WorkOrder w : [select id,Acorn_WorkOrder_Number__c,CaseId from WorkOrder where Acorn_WorkOrder_Number__c = : ACORN_WORK_ORDER_PREFIX+pop.ivrWorkOrder or WorkOrderNumber = : pop.ivrWorkOrder LIMIT 1]){
                WO = w;
            }
         	//If, Acorn Work Order is not found, search for Salesforce Work Order Number
            if(WO == null) {
        		//iSError = true;
				//errorMessage = 'Please Provide Valid Work Order Number.';
                //Page = null;
            }else {
                WO.Customer_Interaction_ID__c = pop.GenesysId;
                wolst.add(WO);
                Database.update(wolst,false);
         	Page = new PageReference('/lightning/r/WorkOrder/' + WO.Id + '/view');     
            }
        } catch (Exception ex) {
            //added by av4 for SDT-39599
            logException(convertObjToString(pop), ex, 'ScreenpopControllerpopRedirectWorkOrder');
            
            //logDefaultTask(WO.CaseId, pop.MediaType, pop.GenesysId);
            //No Work Order is found, we need to send error message for agent to know
        }
        return Page;
    }
    //redirect to emailmessage record page
    private PageReference popEmailMessage(Screenpop pop){
        List<Task> emailtask = [SELECT Id, OwnerId, WhatId, What.Type, RecordType.Name, Message_ID__c, Status FROM Task WHERE Message_ID__c = :pop.SFDCRecordId LIMIT 1 FOR UPDATE];
        System.debug('*** emTs' + emailtask);
        List<EmailMessage> emailrec = [SELECT Id, ParentId FROM EmailMessage WHERE Id = : pop.SFDCRecordId LIMIT 1];
        List<Case> updateCase = new list<Case>();
        PageReference page = null;
        
        // Update Owner of Task and Case
        if(emailtask.size()==1){
            system.debug('before emailtask[0]: '+emailtask[0]);
            emailtask[0].OwnerId = UserInfo.getUserId();
            emailtask[0].Is_From_ScreenPop__c = true;
            emailtask[0].Status = Constant_Util.COMPLETED;
            system.debug('after emailtask[0]: '+emailtask[0]);
            if(emailtask[0].What.Type == 'Case'){
                for(Case c : [SELECT Id, OwnerId FROM Case WHERE ID = : emailtask[0].WhatId LIMIT 1]){
                    c.OwnerId = UserInfo.getUserId();
                    c.Is_From_ScreenPop__c = true;
                    updateCase.add(c);
                }
            }
            
        } else if (emailrec.size()==1){
            for(Case c : [SELECT Id, OwnerId FROM Case WHERE Id = :emailrec[0].ParentId]){
                c.OwnerId = UserInfo.getUserId();
                c.Is_From_ScreenPop__c = true;
                updateCase.add(c);
            }
        } else{}
        
        if(emailRec.size()>0){
            page = new PageReference('/' + pop.SFDCRecordId);
        }

    try{
        if(emailtask.size()>0){
            update emailtask;
        }
            if(updateCase.size()>0){
                update updateCase;
            }
        }
        catch(Exception e){
            //added by av4 for SDT-39599
            logException(convertObjToString(pop), e, 'ScreenpopControllerpopEmailMessage');
            System.debug('>>> Exception-- ' + e.getMessage());
            System.debug('>>> Excpetion-- ' + e.getStackTraceString());
        }
        
        return page;
        
    }
    
    //screenpop redirect to task 
    private PageReference popTask(Screenpop pop){
       List<Task> taskmatch = [SELECT Id, OwnerId, WhatId, What.Type, RecordType.Name FROM Task WHERE Id = :pop.SFDCRecordId LIMIT 1 FOR UPDATE]; //SDT-7893 unable to lock row.
        System.debug('>>>> TASK MATCH: '+ taskmatch);
        PageReference page = null;
        
        if(taskmatch.size()==1){
            taskmatch[0].OwnerId = UserInfo.getUserId();
            taskmatch[0].Is_From_ScreenPop__c = true;
            Boolean isCase = Constant_Util.KEYWORD_CASE.equals(taskmatch[0].What.Type) ? true : false ;
            if(isCase){
            for(Case c : [SELECT OwnerId FROM Case WHERE Id = :taskmatch[0].WhatId LIMIT 1]){
                c.OwnerId = UserInfo.getUserId();
				c.Is_From_ScreenPop__c = true;
            }
                //6991 edit
                if( Constant_Util.EMAIL_CASE.equals(taskmatch[0].RecordType.Name)){
                    page = new PageReference('/'+taskmatch[0].WhatId);  
                }else{
                        page = new PageReference('/'+taskmatch[0].id);
                    }
            try{        
            	update taskmatch;
            }catch(Exception e){
                    //added by av4 for SDT-39599
                    logException(convertObjToString(pop), e, 'ScreenpopControllerpopTask');
            	System.debug('Exception -- ' + e.getMessage());
            }
        }
        }else{}
        return page;
    }
    
    
    private PageReference popExistingCase(Screenpop pop) {
        //User u = [SELECT Id, Last_Customer_Interaction_ID__c FROM User WHERE Id = :UserInfo.getUserId()];
        List<Case> caseRecords = new List<Case>();
            for(Case ca : [select id, Last_Agent_ID__c, OwnerId from Case where Reference_Number__c = : pop.CaseRefNo LIMIT 4999]){
                caseRecords.add(ca);
            }
        if(caseRecords.IsEmpty() && caseRecords.size() == 0){
            //iSError = true;
            //isredirectCase = true;
			//errorMessage = 'Please Provide Valid Case Reference Number.';
            return null;
        }else{}

        //------- SDT-2689 & SDT-4271 -----------------------------
        for(Case c : caseRecords) { 
            c.Last_Customer_Interaction_ID__c = pop.GenesysId;
            c.Last_Customer_Interaction_Type__c = pop.MediaType;
        }
        if(caseRecords.size()==1){
            caseRecords[0].OwnerId = UserInfo.getUserId();
			caseRecords[0].Is_From_ScreenPop__c = true;
            
            if(String.isBlank(caseRecords[0].Last_Agent_ID__c))
            {
                updateLastAgentId(caseRecords[0]);
            }
        }
        //u.Last_Customer_Interaction_ID__c = pop.GenesysId;
        
        try{
        //update u;
        CaseTriggerHelper.runCount = 2;
        update caseRecords;
        }
        catch(Exception e){
            //added by av4 for SDT-39599
            logException(convertObjToString(pop), e, 'ScreenpopControllerpopExistingCase');
            System.debug('+++++Exception: '+e);
            System.debug('+++++Exception cause: '+e.getCause());
            
        }
        
        //---------------------------------------------------------
        
        if(caseRecords.size() == 1) {            
            logDefaultTask(caseRecords[0].Id, pop.MediaType, pop.GenesysId, pop.ivrani);
            return new PageReference('/lightning/r/Case/' + caseRecords[0].Id + '/view');            
        } else {
            // TODO (SDT-3648): Bad hack! This breaks Gplus adapter screenpop. Need clean solution here - Ed V
            String searchExpr = EncodingUtil.base64Encode(Blob.valueOf(SEARCH1 + pop.CaseRefNo + SEARCH2));

            logDefaultTask(caseRecords[0].id,pop.MediaType,pop.GenesysId,pop.ivrani);
            return new PageReference('/one/one.app#' + searchExpr);
            //return new PageReference('/lightning/r/Case/'+ caseRecords[0].id + '/view');
        } 
        
    }
    
    //Redirect To Quote
    private PageReference popQuote(Screenpop pop) {
        PageReference Page = null;
        SBQQ__Quote__c sbQuote = null;
		List<SBQQ__Quote__c> quotelst = new List<SBQQ__Quote__c>();
        
        try{
            for(SBQQ__Quote__c sbq: [select id,	Assigned_To__c,Genesys_Record_Created__c,Assing_To_Me_Action__c from SBQQ__Quote__c where id =: pop.SFDCRecordId]){
                sbQuote = sbq;
            }
         	
            if(sbQuote != null) {
        		sbQuote.Genesys_Record_Created__c = false;
                sbQuote.Assigned_To__c= UserInfo.getUserId();
				sbQuote.Assing_To_Me_Action__c = true ; // hot fix SDT-32711 sprint 12/13
                //sbQuote.Is_From_ScreenPop__c = true;
            }
            quotelst.add(sbQuote);
            
            if(!quotelst.isEmpty()){
                
            		Database.update(quotelst);
                }
            
        } catch (Exception e) {
            //added by av4 for SDT-39599
            logException(convertObjToString(pop), e, 'ScreenpopControllerpopQuote');
                //No Quote is found, we need to send error message for agent to know
        }
        return (quotelst[0] == null || quotelst[0].Id == null) ? null : new PageReference('/lightning/r/SBQQ__Quote__c/' + quotelst[0].id + '/view');
    }
    
    
    private PageReference popNewCase(Screenpop pop) {
		if(pop.GenesysId != '')
        {
            List<Case> caseList = findCase(pop.GenesysId);
            if(!caseList.isEmpty()){
                return new PageReference('/lightning/r/Case/' + caseList[0].id + '/view');
            } 
        }
        Case newCase;        
        String supportedIntent = pop.Intent != null && CaseTypesByIntent.containsKey(pop.Intent) ? pop.Intent : INTENT_OTHER;
        newCase = new Case(RecordTypeId = CaseTypesByIntent.get(supportedIntent));
        newCase.Last_Customer_Interaction_ID__c = pop.GenesysId;
        newCase.Last_Customer_Interaction_Type__c = pop.MediaType;
        newCase.Last_Agent_ID__c = getLastAgentUserName();
        
        // Start - SDT-19322 //
        if(caseTypeValuesbyIntentMap.containsKey(supportedIntent)){
            newCase.Case_Type__c = caseTypeValuesbyIntentMap.get(supportedIntent); // getting the Case Type values based on Intent
            newCase.Case_Sub_Type__c = caseSubTypebyIntentMap.get(supportedIntent); // getting the Case Sub Type values based on Intent
            newCase.Case_Reason__c = caseReasonbyIntentMap.get(supportedIntent); // getting the Case Reason values based on Intent    
       
        }
        //Changes done for SDT-41550 by jatan
        else if (supportedIntent == INTENT_DELIVERY){
           newCase.Case_Type__c = 'New Service';
	   newCase.Case_Sub_Type__c =  pop.NSCaseSubType;
	   newCase.Case_Reason__c =  pop.NSCaseReason; 
        }
        // End - SDT-19322 //
        
        String origin = mapOriginToMediaType(pop.MediaType);
        if(origin != null){
            newCase.Origin = origin;
        }else{}
        if(pop.AcctId != null && pop.AcctId.length() > 0){
            newCase.Client__c = pop.AcctId;
         }else{} 
        
        if(pop.AcctLocationId != null && pop.AcctLocationId.length() > 0) {
            
            newCase.Location__c = pop.AcctLocationId;
            if(string.isNotBlank(pop.ivrContainerId)){
                newCase.AssetId = pop.ivrContainerId;
            }else if (newCase.Case_Type__c != 'New Service'){
                // associate asset if 1:1 match found
                Id assetId = findAsset(pop.AcctLocationId);
                newCase.AssetId = String.isNotBlank(string.valueof(assetId)) ? assetId : null;
            }
        }else{}
        
        System.debug('Asset param: '+pop.AcctLocationID);
        System.debug('Find Asset: '+findAsset(pop.AcctLocationID));
        
        if(pop.ContactId != null && pop.ContactId.length() > 0 && pop.ContactId.substring(0,3) == '003'){
            newCase.ContactId = pop.ContactId;
        }else{}
        
        // Start - SDT-23351
        if(pop.ivrSubTypeReturn !=null && !Constant_Util.STRING_NULL.equalsIgnoreCase(pop.ivrSubTypeReturn) && String.isNotBlank(pop.ivrSubTypeReturn)){
            if(Constant_Util.STR_TRUE.equalsIgnoreCase(pop.ivrSubTypeReturn)){
               newCase.Case_Sub_Type__c = Constant_Util.EMPTY_AND_RETURN; 
            }else if(Constant_Util.STR_FALSE.equalsIgnoreCase(pop.ivrSubTypeReturn)){
               newCase.Case_Sub_Type__c = Constant_Util.EMPTY_AND_DONOT_RETURN; 
            }
        } // End
        
        try {
            insert newCase;          
        } catch(Exception ex) {
            //added by av4 for SDT-39599
            logException(convertObjToString(pop), ex, 'ScreenpopControlerpopNewCase');
            System.debug(LoggingLevel.ERROR, 'Screenpop case creation error: ' + ex.getMessage());
            System.debug(LoggingLevel.INFO, 'Screenpop input parameters: ' + pop);
        }
            
        logDefaultTask(newCase.Id, pop.MediaType, pop.GenesysId, pop.ivrani ); // Added new parameters Ani, SDT-18823
        
        return (newCase == null || newCase.Id == null) ? null : new PageReference('/lightning/r/Case/' + newCase.id + '/view');
    }
    
     private static List<Case> findCase(String genesysId){
        List<Case> caseList = [Select Id from Case where Last_Customer_Interaction_ID__c =: genesysId LIMIT 49999];
        return caseList;
    }
    
    private static Id findAsset(String locId) {
                
        Id assetId = null;
          
        if(!string.isblank(locId)){
                List<Asset> assetIds = [select id from Asset where AccountId = : locId AND RecordTypeId = :SERVICE_HEADER_ID AND Is_Active__c = true LIMIT 4999];
                if(assetIds.size()==1){
                    assetId = assetIds.get(0).id;
                }
            System.debug('assetIds size: '+assetIds.size());
            System.debug('assetIds: '+assetIds);
            }else{}
        return assetId;
    }
    
    /* Task Creation - Inbound Customer Interaction
     * */
    private static void logDefaultTask(Id objId, String mediaType, String genesysId, String ivrAni) {
        //modified as part of SDT-39599
        Task t = new Task();
        try {
        if(objId == null || genesysId == null || Constant_Util.EMPTY_STRING.equals(genesysId)){ return;}else{}
        
        // format task description
        String comments = 'MediaType: ' + mediaType
            + '\nGenesys ID: ' + genesysId;
        
        t.OwnerId = UserInfo.getUserId();
        t.Subject = 'Inbound Customer Interaction';
        t.Description = comments;
        t.Interaction_ID__c = genesysId;
        t.Description__c = genesysId;
        t.Status = Constant_Util.COMPLETED;
        t.Priority = 'Normal';
        t.WhatId = objId;
        t.ANI__c = ivrAni; // SDT-18823, Added ANI field
            insert t;
        } catch(Exception ex) {
            //added by av4 for SDT-39599
            logException(convertObjToString(t), ex, 'ScreenpopControllerlogDefaultTask');
            System.debug(LoggingLevel.ERROR, 'Screenpop task creation error: ' + ex.getMessage());
        }
        
    }
    
    private static String defaultTo(String s, String value) {
        s = s == null ? Constant_Util.EMPTY_STRING : s.trim();
        return Constant_Util.EMPTY_STRING.equals(s) ? value : s;
    }
    
    private static String mapOriginToMediaType(String mediaType) {
        
        String origin = null;
        if(MEDIA_TYPE_WORKITEM.equalsIgnoreCase(mediaType))
            origin = 'Email';
        else if(MEDIA_TYPE_VOICE.equals(mediaType))
            origin = 'Phone';
        else if(MEDIA_TYPE_CHAT.equals(mediaType))
            origin = 'Chat Now';
        // Added Chat Now Media Type SDT-25799
        return origin;
    }
    
    private void updateLastAgentId(Case myCase) { 
        
        if(myCase == null) return;   
        
        String agentUserName = getLastAgentUserName();        
        if(Constant_Util.EMPTY_STRING.equals(agentUserName) || agentUserName.equals(myCase.Last_Agent_ID__c)) return;
        
        Integer atIdx = agentUserName.indexOf('@');
        myCase.Last_Agent_ID__c = (atIdx <= 0) ? agentUserName : agentUserName.substring(0, atIdx);
        
        try {
            update myCase;
        } catch(Exception ex) {
            //added by av4 for SDT-39599
            logException(convertObjToString(myCase), ex, 'ScreenpopControllerupdateLastAgentId');
            System.debug(LoggingLevel.ERROR, 'Unable to update Last_Agent_ID__c: ' + ex.getMessage());
        }
        
    }
    
    private String getLastAgentUserName() {        
        String agentUserName = UserInfo.getUserName();        
        if(agentUserName == null || agentUserName.length() < 1) return Constant_Util.EMPTY_STRING;        
        Integer atIdx = agentUserName.indexOf('@');
        return (atIdx <= 0) ? agentUserName : agentUserName.substring(0, atIdx);
    }
    
    //added by av4 for SDT-39599
    public static void logException(String url, Exception ex, String methodName) {
        ExceptionLog__c exLog = new ExceptionLog__c();
        try {
            String lineNumber = String.valueOf(ex.getLineNumber() != null ? ex.getLineNumber() : 0);
            String message = ex.getMessage();
            String stackTrace = ex.getStackTraceString();
            String typeName = ex.getTypeName();
            string exceptionDetails = lineNumber + '-' + message + '-' + stackTrace + '-' + typeName;
            exLog = TwoWayService.logExceptions(exceptionDetails, methodName, 'ScreenPopUpException');
        }
        catch(Exception e) {
            exLog = TwoWayService.logExceptions(e.getMessage(), methodName + ' -> logException()', 'ScreenPopUpException');
            
        }
        if(exLog != null && exLog.Org_Id__c != null) {
            insert exLog;
        }
    }
    
    //added by av4 for SDT-39599
    public static String convertObjToString(Object obj) {
        try {
            String objStr = obj != null ? JSON.serialize(obj) : 'no value for this object';
            objStr = objStr.length() > 254 ? objStr.subString(0, 254) : objStr;
            
            return objStr;
        }
        catch(exception ex) {
            return 'serializing failed in convertObjToString';
        }
    }
    
    // Start - SDT-19322 return Case Types values based on the case Intents name
    // SDT-20935 Modified Intent Names (add lock,container lids,bulk )
    static {
        caseTypeValuesbyIntentMap.put(INTENT_MISSED_SERVICE, CASETYPE_STATUS);
        caseTypeValuesbyIntentMap.put(INTENT_SERVICE_CHANGE, CASETYPE_CHANGE_SERVICE);
        caseTypeValuesbyIntentMap.put(INTENT_RELOCATION, CASETYPE_SPECIAL_REQUEST);
        caseTypeValuesbyIntentMap.put(INTENT_ADD_LOCK, CASETYPE_SPECIAL_REQUEST);
        caseTypeValuesbyIntentMap.put(INTENT_CONTAINER_LIDS, CASETYPE_SPECIAL_REQUEST);
        caseTypeValuesbyIntentMap.put(INTENT_BULK, CASETYPE_PICKUP);
        caseTypeValuesbyIntentMap.put(INTENT_HAUL_AWAY, CASETYPE_PICKUP);
        caseTypeValuesbyIntentMap.put(INTENT_REPAIR, BLANK_STRING);
        caseTypeValuesbyIntentMap.put(INTENT_BALE, CASETYPE_PICKUP); // SDT-21062
    }
    
    // Start - SDT-19322 return Case Sub Types values based on the case Intents name
    // SDT-20935 Modified Intent Names (add lock,container lids,bulk ) 
    static {
        caseSubTypebyIntentMap.put(INTENT_MISSED_SERVICE, CASE_SUBTYPE_SRVC_PERFORM);
        caseSubTypebyIntentMap.put(INTENT_RELOCATION, CASE_SUBTYPE_SRVC_RELOCATE);
        caseSubTypebyIntentMap.put(INTENT_ADD_LOCK, CASE_SUBTYPE_LOCS);
        caseSubTypebyIntentMap.put(INTENT_CONTAINER_LIDS, CASE_SUBTYPE_LIDS);
        caseSubTypebyIntentMap.put(INTENT_BULK, CASE_SUBTYPE_BULK);
        caseSubTypebyIntentMap.put(INTENT_HAUL_AWAY, CASE_SUBTYPE_HAUL_AWAY);
        caseSubTypebyIntentMap.put(INTENT_BALE, CASE_SUBTYPE_BALES); // SDT-21062
    }
    
    // Start - SDT-19322 return Case Reason values based on the case Intents name 
    static {
        caseReasonbyIntentMap.put(INTENT_MISSED_SERVICE,CASE_REASON_CUST_REPORTED);
    }
    
    // End //
        
	/*Public PageReference redirect(){
		
		PageReference page = null;
        referenceNumber = Apexpages.currentPage().getParameters().get('referenceNumber');
        workOrder = Apexpages.currentPage().getParameters().get('workOrder');
		String isNewbtn = Apexpages.currentPage().getParameters().get('isNewbtn');
		Boolean isNewCase = Boolean.valueof(isNewbtn);
		if(isNewCase){
			page = popNewCase(pop);			
		}else if(String.IsNotBlank(referenceNumber)){
			pop.CaseRefNo = referenceNumber;
			page = popExistingCase(pop);
		}else if(String.IsNotBlank(workOrder) && !String.IsBlank(pop.ivrVendor) && 'Y'.equalsIgnoreCase(pop.ivrVendor)){
			pop.ivrWorkOrder = workOrder;
            system.debug('$$$$'+workOrder);
			page = popRedirectWorkOrder(pop);
		}
		createCache(pop);		 
		return page;
	}*/
}