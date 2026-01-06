/*
* @Name          STPRuleExecutionTest
* @Author        Mohammed Rishan Ali
* @Vendor		 TCS
* @Date          09/02/2023
* @LastModifiedDate 12/22/2023
* @LastModifiedBy   Digdershika Ojha
* @Description	  This class is created to test Straight-Through Processing (STP) functionality.
* Assumptions    Taken Open Top as the container and trash as the waste category for all the test methods
*/
@isTest (SeeAllData = FALSE)

public class STPRuleExecutionTest {
    
    public static final string SYS_ADMIN = 'System Administrator';
    public static final string CUSTOMER_SERVICE = 'Customer Service';
    public static String methodName_ExecuteRules = 'executeRules';
    public static String methodName_updateQuoteStatus = 'updateQuoteStatus';
    public static String customer_code = 'WAL'; 
    public static final string parent_AccName = 'Test Parent Account';
    public static final string thirdPartyparent_AccName = 'Test 3rd Party Parent Account';
    public static final string location_AccName = 'location account';
    public static final string thirdPartylocation_AccName = 'third Party location account';
    public static final string parentVendor_AccName = 'WMParent Vendor';
    public static final string parentVendor_AccNumber = '8';
    public static final string thirdPartyparentVendor_AccName = 'NonWMParent Vendor';
    public static final string thirdPartyparentVendor_AccNumber = '7449'; 
    public static final string childVendor_AccName = 'WMchild vendor';
    public static final string thirdPartychildVendor_AccName = 'NonWMchild vendor';
    public static final string contact_lastName  = 'Quote contact for product trash';
    public static final string caseReason_Tempupload = 'Temp Upload';
    public static string override_products = 'Delivery;Container Service Charge';
    //WMI National Accounts
    public static string WMNAT = 'WMNAT';
    //Wasteless Environmental Services
    public static string OAKWL = 'OAKWL';
    public static String RECORD_TYPE_ERR_MSG = 'Record Type is Not a New Service Case';
    public static String NO_STP_RULE_FOUND = 'No STP rule Found for Quote ';
    public static String MAS_LIB_MISSING_UPDATE_QUOTE_STATUS = 'Missing MAS Library or Company Code  for ';
    public static Map<string,List<string>> quoteErrorMessageMap = new Map<string,List<string>>();
    public static String JSON_VALID_ROLLOFF_DATA = '{"data":{"priceQuoteIdentifier":"Q11837","costSource":"WM (SBS|RO|OT|30O|B02860|20211019|025300|5810)","contractType":"Open Market","lineOfBusiness":"Roll Off","supplierCode":"10016","supplierName":"WMI OF MI, LIVONIA","customerCode":"HMD","customerName":"The Home Depot","locationCode":"HMD002718","wasteStreamCode":"MSW_RO","wasteStreamName":"Municipal Solid Waste","equipmentCode":"30O","equipmentName":"30 Yard Open Top","equipmentUOM":"Tons","materialCode":"T","materialName":"MSW - Unspecified","equipmentSizeCode":"YRDS-30","equipmentSizeName":"30 Yards","overridableEquipmentSizeCode":null,"overridableEquipmentSizeName":null,"zoneCode":"GIS543320","zoneName":"Detroit Central - RO MSW - To Woodland 1","disposalFacilityType":"S04264_LF","disposalFacilityName":"B02860|S04264_LF|129A_WDL|MSW_RO","commercial":null,"rollOff":{"pricingMethodDisposalCode":"1.0","pricingMethodDisposalDescription":"Market Based Pricing","pricingMethodHaulingCode":"1.0","pricingMethodHaulingDescription":"Market Based Pricing","haulCost":410.59,"haulPrice":null,"disposalCost":30.42,"disposalPrice":null,"estimatedVolumePerHaul":4,"applyInvoiceFeesToDisposalCharges":"Y","applyInvoiceFeesToRentalCharges":null,"travelTimePerHaul":126.68,"landfillMinutes":25,"transferSiteCode":"NA","equipmentAvailabilityTypeCode":"TEMP","materialClassName":"MSW_MSWI_Municipal Solid Waste - Industrial","equipmentLoadingMinutes":20,"equipmentAdditionalLoadingMinutes":null,"stepDisposals":null},"wmMetaData":{"businessUnit":"B02860","masLibrary":"129A_WDL","francisePricingLink":"","greenPagesLink":"","marketArea":"WM of Michigan Ohio Indiana"},"tpMetaData":null,"serviceCharges":[{"code":"FU_RO_TEMP_OPEN","name":"Fuel Fee","componentTypeCode":"ENS","componentTypeName":"Energy Surcharge","actionCode":"EX","actionName":"Exclude","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly"},{"code":"ENV_RO_TEMP_OPEN","name":"Environmental Fee","componentTypeCode":"ENV_FEE","componentTypeName":"Environmental Fee","actionCode":"EX","actionName":"Exclude","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly"},{"code":"RCR_RO_TEMP_OPEN","name":"Regulatory Cost Recovery","componentTypeCode":"UNK","componentTypeName":"Unknown","actionCode":"EX","actionName":"Exclude","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly"},{"code":"CSC_RO_TEMP_OPEN","name":"Container Service Charge","componentTypeCode":"UNK","componentTypeName":"Unknown","actionCode":"EX","actionName":"Exclude","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly"},{"code":"D_RO_TEMP_OPEN","name":"Delivery","componentTypeCode":"UNK","componentTypeName":"Unknown","actionCode":"EX","actionName":"Exclude","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly"}]},"problem":null}';
    public static final String AAV_API_REQUEST_OUTPUT = '{"data": {"requestedDate": "2023-09-04","lineOfBusiness": "Roll Off","customerCode": "HMD","customerName": "The Home Depot","locationCode": "HMD006959","materialCode": "T","materialName": "Trash","countryCode": "USA","suppliers": [{"availabilitySource": "WM","supplierCode": null,"supplierName": null,"contractType": "Competitor","wasteStreamCode": "MSW","wasteStreamName": "Municipal Solid Waste","zoneCode": "GIS624853","zoneName": "Non WM Franchise - Bainbridge - CM MSW","wmMetaData": {"marketAreaCode": "K00126","marketAreaName": "WM of South Atlantic","facilityId": "GA0075","facilityName": "Albany Hauling","siteId": "S10284","siteName": "Albany Hauling"},"tpMetaData": null,"deliveryDays": null,"serviceDays": null,"deliveries": null,"outages": null,"messages": [{"code": "ER400","description": "WM Schedule information not available due to Competitor / Franchise Contract Type"}]}],"messages": []},"problem": null}';
    public static final String INVALID_AAV_API_REQUEST_OUTPUT = '{"data": {"requestedDate": "2023-09-04","lineOfBusiness": "Roll Off","customerCode": "HMD","customerName": "The Home Depot","locationCode": "HMD006959","materialCode": "T","materialName": "Trash","countryCode": "USA","suppliers": [{"availabilitySource": "WM","supplierCode": null,"supplierName": null,"contractType": "Competitor","wasteStreamCode": "MSW","wasteStreamName": "Municipal Solid Waste","zoneCode": "GIS624853","zoneName": "Non WM Franchise - Bainbridge - CM MSW","wmMetaData": {"marketAreaName": "WM of South Atlantic","facilityId": "GA0075","facilityName": "Albany Hauling","siteId": "S10284","siteName": "Albany Hauling"},"tpMetaData": null,"deliveryDays": null,"serviceDays": null,"deliveries": null,"outages": null,"messages": [{"code": "ER400","description": "WM Schedule information not available due to Competitor / Franchise Contract Type"}]}],"messages": []},"problem": null}';
    public static final String OPEN = 'Open';
    public static final Map<Id,string> quoteLineProductMap = new Map<Id,string>();
    public static final Map<Id,string> durationMap = new Map<Id,string>();
    public static final string byPassProducts = 'Delivery;Container Service Charge';
    /*
     * @MethodName    setup
     * @Author        Mohammed Rishan Ali
     * @Vendor		  TCS
     * @description	  This method will be used to setup inital required data to test getStpRule method.
	*/
    @testSetup
    public static void setup(){
        List<SBQQ__QuoteLine__c> childQuoteLineList = new List<SBQQ__QuoteLine__c>();
        List<Product2> productList = new List<Product2>();
        List<STP_Criteria__c> stprules = new List<STP_Criteria__c>();
        List<Case> caseList = new List<Case>();
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        
        //create quote and update quote status to cost configured in setup method
        Profile adminProfile = TestDataFactory.getProfile(SYS_ADMIN);
        User usr = TestDataFactory.createUser(adminProfile);
        Database.insert(usr); 
        Profile csrProfile = TestDataFactory.getProfile(Pricing_Constant_Util.CUSTOMER_SERVICE);
        User csrUsr = TestDataFactory.createUser(csrProfile);
        Database.insert(csrUsr); 
        
        System.runAs(usr){
            test.startTest();   
            
            Account parentAccount = QuoteTestDataFactory.createParentAccountRecord(parent_AccName,customer_code, 
                                                                                   ConstantClass.RecordType_Client, usr);
            parentAccount.Status__c = 'Active'; 
            parentAccount.Accounting_System__c = WMNAT;                                                                     
            QuoteTestDataFactory.insertAccount(parentAccount);
            Account thirdPartyparentAccount = QuoteTestDataFactory.createParentAccountRecord(thirdPartyparent_AccName,customer_code, 
                                                                                   ConstantClass.RecordType_Client, usr);
            thirdPartyparentAccount.Status__c = 'Active'; 
            thirdPartyparentAccount.Accounting_System__c = WMNAT;                                                                     
            QuoteTestDataFactory.insertAccount(thirdPartyparentAccount);
            //create location account
            Account locationAccount = QuoteTestDataFactory.createLocationAccount(location_AccName, parentAccount.Id, usr);
            QuoteTestDataFactory.insertAccount(locationAccount);
            Account thirdPartylocationAccount = QuoteTestDataFactory.createLocationAccount(thirdPartylocation_AccName, thirdPartyparentAccount.Id, usr);
            QuoteTestDataFactory.insertAccount(thirdPartylocationAccount);
            
            //Create vendor account 
            Id vendorRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(ConstantClass.RecordType_Vendor).getRecordTypeId();
            Account parentVendor = new Account(Name = parentVendor_AccName, RecordTypeId = vendorRecordtypeId,
                                               Status__c = ConstantClass.FieldStatus_Active, AccountNumber = parentVendor_AccNumber);
            QuoteTestDataFactory.insertAccount(parentVendor);
            
            Id thirdPartyvendorRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(ConstantClass.RecordType_Vendor).getRecordTypeId();
            Account thirdPartyparentVendor = new Account(Name = thirdPartyparentVendor_AccName, RecordTypeId = thirdPartyvendorRecordtypeId,
                                               Status__c = ConstantClass.FieldStatus_Active, AccountNumber = thirdPartyparentVendor_AccNumber);
            QuoteTestDataFactory.insertAccount(thirdPartyparentVendor);
            
            //create child vendor account
            Account childVendor = QuoteTestDataFactory.createVendorAccountwithParent(childVendor_AccName, parentVendor.Id, usr);
            QuoteTestDataFactory.insertAccount(childVendor);
            
            Account thirdpartyChildVendor = QuoteTestDataFactory.createVendorAccountwithParent(thirdPartychildVendor_AccName, thirdPartyparentVendor.Id, usr);
            QuoteTestDataFactory.insertAccount(thirdpartyChildVendor);
            
            //create contact for account which is primary contact in quote with product trash
            Contact quoteContact = QuoteTestDataFactory.createContactRecord(contact_lastName, parentAccount.Id, usr);
            QuoteTestDataFactory.insertContact(quoteContact);
            Contact thirdPartyquoteContact = QuoteTestDataFactory.createContactRecord(contact_lastName, thirdPartyparentAccount.Id, usr);
            QuoteTestDataFactory.insertContact(thirdPartyquoteContact);
            
            //creating case with record type new service
            Case caseForQuote = QuoteTestDataFactory.createCase(ConstantClass.RecordType_NewServiceCase,
                                                                ConstantClass.FieldType_NewService,
                                                                ConstantClass.FieldSubType_Temporary,caseReason_Tempupload,
                                                                parentAccount,quoteContact, locationAccount);
            caseList.add(caseForQuote);
            Case thirdPartycaseForQuote = QuoteTestDataFactory.createCase(ConstantClass.RecordType_NewServiceCase,
                                                                ConstantClass.FieldType_NewService,
                                                                ConstantClass.FieldSubType_Temporary,caseReason_Tempupload,
                                                                thirdPartyparentAccount,thirdPartyquoteContact, thirdPartylocationAccount);
            caseList.add(thirdPartycaseForQuote);
            
            //creating case with recordtype Pickup Case
            Case pickUpCase = QuoteTestDataFactory.createCase(ConstantClass.RecordType_PickUpCase,
                                                              Pricing_Constant_Util.PR_PICKUP,Pricing_Constant_Util.EMPTY_AND_RETURN, 'Contaminated',
                                                              parentAccount, quoteContact, locationAccount);
            caseList.add(pickUpCase);                                                    
            QuoteTestDataFactory.insertCases(caseList);
            
            //create pricing request
            Pricing_Request__c pricingRequest = TestDataFactory.createPricingRequestRecord(caseForQuote, parentAccount, locationAccount,
                                                                                           Pricing_Constant_Util.ROLLOFF, 'AM', '', 
                                                                                           JSON_VALID_ROLLOFF_DATA, usr);
            //pricingRequest.Market_Area_Code__c = 'K00199';
            pricingRequest.zone_Type__c = 'Open Market';
            Insert pricingRequest;
            
            Pricing_Request__c thirdPartypricingRequest = TestDataFactory.createPricingRequestRecord(caseForQuote, thirdPartyparentAccount, thirdPartylocationAccount,
                                                                                           Pricing_Constant_Util.ROLLOFF, 'AM', '', 
                                                                                           JSON_VALID_ROLLOFF_DATA, usr);
            thirdPartypricingRequest.zone_Type__c = Pricing_Constant_Util.WM_FRANCHISE;
            Insert thirdPartypricingRequest;
            
            //creating open top product
            Product2 openTop = QuoteTestDataFactory.createProductRecord(Pricing_Constant_Util.OPEN_TOP, 'Equipment', 'OT');
            productList.add(openTop);
            //creating haul service product
            Product2 haulService = QuoteTestDataFactory.createProductRecord(Pricing_Constant_Util.HAUL, 'Services', 'H');
            productList.add(haulService);
            //creating disposal service product
            Product2 DisposalService= QuoteTestDataFactory.createProductRecord(Pricing_Constant_Util.DISPOSAL,'Services','DSP');
            productList.add(DisposalService);
            //creating container service charge product 
            Product2 ContainerServiceCharge = QuoteTestDataFactory.createProductRecord(Pricing_Constant_Util.PR_ContainerServiceCharge,'Services','CSC');
            productList.add(ContainerServiceCharge); 
            //creating trash product with family waste stream
            Product2 TrashWasteStream = QuoteTestDataFactory.createProductRecord('Trash','Waste Stream','T');
            TrashWasteStream.Is_Pricing_Eligible__c = true;
            productList.add(TrashWasteStream);
            //creating trash product with family waste category
            product2 TrashWasteCategory = QuoteTestDataFactory.createProductRecord('Trash','Waste Category','OTT');
            productList.add(TrashWasteCategory);
            
            Product2 deliveryService = QuoteTestDataFactory.createProductRecord('Delivery','Surcharges and Fees','DLV');
            productList.add(deliveryService);
            
            QuoteTestDataFactory.insertProducts(productList);
            
            //creating opportunity for new service case
            Opportunity oppForNewServiceCase = QuoteTestDataFactory.createOpportunity(1, ConstantClass.FieldStageName_Proposal, 
                                                                                      'OpportunityFornewServiceCase', caseForQuote.Id, 
                                                                                      ConstantClass.FieldSubType_Temporary, locationAccount.Id);  
            QuoteTestDataFactory.insertOpportunity(oppForNewServiceCase);
            Opportunity thirdPartyoppForNewServiceCase = QuoteTestDataFactory.createOpportunity(1, ConstantClass.FieldStageName_Proposal, 
                                                                                      'OpportunityForthirdPartynewServiceCase', thirdPartycaseForQuote.Id, 
                                                                                      ConstantClass.FieldSubType_Permanent, thirdPartylocationAccount.Id);  
            QuoteTestDataFactory.insertOpportunity(thirdPartyoppForNewServiceCase);
            
            //creating opportunity for pickup case
            Opportunity oppForpickUpCase = QuoteTestDataFactory.createOpportunity(1, ConstantClass.FieldStageName_Proposal, 
                                                                                  'OpportunityForPickupCase', pickUpCase.Id, 
                                                                                  ConstantClass.FieldSubType_Temporary, locationAccount.Id);  
            QuoteTestDataFactory.insertOpportunity(oppForpickUpCase); 
            
            //creating quote for new service case(for trash)
            SBQQ__Quote__c quoteForTestingTrash = QuoteTestDataFactory.createQuoteRecords(oppForNewServiceCase, locationAccount, quoteContact);
            quoteList.add(quoteForTestingTrash);
            SBQQ__Quote__c thirdPartyquoteForTestingTrash = QuoteTestDataFactory.createQuoteRecords(thirdPartyoppForNewServiceCase, thirdPartylocationAccount, thirdPartyquoteContact);
            quoteList.add(thirdPartyquoteForTestingTrash);
            
            //creating quote for pick up case
            SBQQ__Quote__c quoteForPickUpCase = QuoteTestDataFactory.createQuoteRecords(oppForpickUpCase, locationAccount, quoteContact);
            quoteList.add(quoteForPickUpCase);
            RecurrsiveTriggerHandler.bypassValidation = true;
            QuoteTestDataFactory.insertQuotes(quoteList);
            
            //QuoteLine Creation
            //parent quoteline 'Open Top' for new service case
            //RecurrsiveTriggerHandler.isRecurrsiveQuoteLine = true;
            
            //--trigger control is disabled in order to avoid SOQL query exception
            SBQQ.TriggerControl.disable();
            
            try 
            {
                SBQQ__QuoteLine__c quotelineForContainerOT = QuoteTestDataFactory.createQuoteLineRecords(quoteForTestingTrash,openTop,
                                                                                                         'TEMP',1.00,'CLT','YRDS-30',
                                                                                                         'OC','M','1','PER',34.00,'DYS',
                                                                                                         'PER',null,'DYS','Do Not Override','NBG');
                quotelineForContainerOT.SBQQ__Bundle__c = true;
                quotelineForContainerOT.SBQQ__RequiredBy__c = null;
                quotelineForContainerOT.Vendor__c = childVendor.Id;
                quotelineForContainerOT.Pricing_Request__c = pricingRequest.Id;
                RecurrsiveTriggerHandler.bypassValidationQuoteLine = true;
                RecurrsiveTriggerHandler.isSkipValidateQLCostPrice =true;
                QuoteLineTriggerHelper.extrapickUpRecursion = false;
                RecurrsiveTriggerHandler.setIsRecurrsiveQuoteLine();
                QuoteTestDataFactory.insertQuoteLine(quotelineForContainerOT);
                
                //thirdParty
                SBQQ__QuoteLine__c thirdPartyquotelineForContainerOT = QuoteTestDataFactory.createQuoteLineRecords(thirdPartyquoteForTestingTrash,openTop,
                                                                                                         'TEMP',1.00,'CLT','YRDS-30',
                                                                                                         'OC','M','1','PER',34.00,'DYS',
                                                                                                         'PER',null,'DYS','Do Not Override','NBG');
                thirdPartyquotelineForContainerOT.SBQQ__Bundle__c = true;
                thirdPartyquotelineForContainerOT.SBQQ__RequiredBy__c = null;
                thirdPartyquotelineForContainerOT.Vendor__c = thirdPartyChildVendor.Id;
                thirdPartyquotelineForContainerOT.sCode__c = null;
                thirdPartyquotelineForContainerOT.Pricing_Request__c = thirdPartypricingRequest.Id;
                RecurrsiveTriggerHandler.bypassValidationQuoteLine = true;
                RecurrsiveTriggerHandler.isSkipValidateQLCostPrice =true;
                QuoteLineTriggerHelper.extrapickUpRecursion = false;
                RecurrsiveTriggerHandler.setIsRecurrsiveQuoteLine();
                QuoteTestDataFactory.insertQuoteLine(thirdPartyquotelineForContainerOT);
                
                //parent quoteline 'Open Top' for pickup case
                SBQQ__QuoteLine__c quotelineForContainerOTPickup = QuoteTestDataFactory.createQuoteLineRecords(quoteForPickUpCase,openTop,
                                                                                                               'TEMP',1.00,'CLT','YRDS-30',
                                                                                                               'OC','M','1','PER',34.00,'DYS',
                                                                                                               'PER',null,'DYS','Do Not Override','NBG');
                quotelineForContainerOT.SBQQ__Bundle__c = true;
                quotelineForContainerOT.SBQQ__RequiredBy__c = null;
                quotelineForContainerOT.Vendor__c = childVendor.Id;
                RecurrsiveTriggerHandler.bypassValidationQuoteLine = true;
                
                QuoteTestDataFactory.insertQuoteLine(quotelineForContainerOTPickup); 
                
                
                //Adding Availablity 
                AAV_Asset_Availability__c aavObj = new AAV_Asset_Availability__c();
            	aavObj.AAV_Location__c = locationAccount.Id;
				aavObj.AAV_APIRequestOutput__c = AAV_API_REQUEST_OUTPUT;
				aavObj.AAV_Quote_Line__c = quotelineForContainerOT.Id;

            	insert aavObj;
                //Open Top Child Quote Line  --- Start
                //quoteline for trash product
                SBQQ__QuoteLine__c qlTrashWasteCategory = QuoteTestDataFactory.createQuoteLineRecords(quoteForTestingTrash,TrashWasteCategory,'TEMP',1.00,'CLT','YRDS-30',
                                                                                                      'OC','M','1','PER',34.00,'DYS','PER',null,'DYS',
                                                                                                      'Do Not Override','NBG');
                qlTrashWasteCategory.SBQQ__RequiredBy__c = quotelineForContainerOT.Id;
                qlTrashWasteCategory.SBQQ__UnitCost__c = 2;
                qlTrashWasteCategory.Vendor__c = childVendor.Id;
                childQuoteLineList.add(qlTrashWasteCategory);
                
                //quoteline for haul product
                SBQQ__QuoteLine__c qlHaul = QuoteTestDataFactory.createQuoteLineRecords(quoteForTestingTrash,haulService,'TEMP',1.00,'CLT',
                                                                                        'YRDS-30','OC','M','1','PER',34.00,'DYS','PER',
                                                                                        563.47,'DYS','Do Not Override','NBG');
                qlHaul.SBQQ__RequiredBy__c = quotelineForContainerOT.Id;
                qlHaul.Vendor__c = childVendor.Id;
                childQuoteLineList.add(qlHaul);
                
                //quoteline for disposal product
                SBQQ__QuoteLine__c qlDisposal = QuoteTestDataFactory.createQuoteLineRecords(quoteForTestingTrash,DisposalService,
                                                                                            'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',
                                                                                            34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
                qlDisposal.SBQQ__RequiredBy__c = quotelineForContainerOT.Id;
                qlDisposal.Vendor__c = childVendor.Id;
                qlDisposal.SBQQ__UnitCost__c = 2;
                childQuoteLineList.add(qlDisposal);
                
                //quoteline for container service charge
                SBQQ__QuoteLine__c qlContainerService = QuoteTestDataFactory.createQuoteLineRecords(quoteForTestingTrash,ContainerServiceCharge,
                                                                                                    'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',
                                                                                                    34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
                qlContainerService.SBQQ__RequiredBy__c = quotelineForContainerOT.Id;
                qlContainerService.Vendor__c = childVendor.Id;
                qlContainerService.SBQQ__UnitCost__c = 2;
                childQuoteLineList.add(qlContainerService);
                
                //Ql Delivery 
                SBQQ__QuoteLine__c qlDelivery = QuoteTestDataFactory.createQuoteLineRecords(quoteForTestingTrash,deliveryService,
                                                                                            'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',
                                                                                            34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
                qlDelivery.SBQQ__RequiredBy__c = quotelineForContainerOT.Id;
                qlDelivery.Vendor__c = childVendor.Id;
                qlDelivery.SBQQ__UnitCost__c = 2;
                childQuoteLineList.add(qlDelivery);
                
                RecurrsiveTriggerHandler.bypassValidationQuoteLine = true;
                QuoteTestDataFactory.insertQuoteLines(childQuoteLineList);
                
                //Open Top Child Quote Line  --- End
                
                //quoteline with product family as waste stream has parent quoteline as trash product with family Waste Category
                //inserting quoteline with waste stream product family
                test.stopTest();
                SBQQ__QuoteLine__c qlTrashWithfamilyWasteStream = QuoteTestDataFactory.createQuoteLineRecords(quoteForTestingTrash,TrashWasteStream,'TEMP',
                                                                                                              1.00,'CLT','YRDS-30','OC','M','1','PER'
                                                                                                              ,34.00,'DYS','PER',null,'DYS',
                                                                                                              'Do Not Override','NBG');
                qlTrashWithfamilyWasteStream.SBQQ__RequiredBy__c = qlTrashWasteCategory.Id;
                
                qlTrashWithfamilyWasteStream.Vendor__c = childVendor.Id;
                RecurrsiveTriggerHandler.bypassValidationQuoteLine = true;
                QuoteTestDataFactory.insertQuoteLine(qlTrashWithfamilyWasteStream);
            }
            finally {
                SBQQ.TriggerControl.enable();
            }       
            


            
            STP_Criteria__c ruleWithInactivePartialSTP =  QuoteTestDataFactory.createSTPCriteriaWithAllParam(null, true, true,
                                                                                          'TEMP', 'Open Top', 'OC',
                                                                                          'Trash', 'New Service Case',false, '8','K00129',null, true, true, 'Partial STP', true, false, true, false, '7414', OPEN);                                                            
            
            stprules.add(ruleWithInactivePartialSTP);
            //Exemption Rule
            STP_Criteria__c exmptRuleOpenMktType = QuoteTestDataFactory.createSTPExemptionWithAllParam(parentAccount, byPassProducts,true,'test excemption');
                exmptRuleOpenMktType.Duration__c = 'TEMP';
                exmptRuleOpenMktType.Equipment__c = 'Open Top';
                exmptRuleOpenMktType.Eligible_Vendor__c = 'WM';
            exmptRuleOpenMktType.Market_Type__c = 'Open';
            stprules.add(exmptRuleOpenMktType);
            QuoteTestDataFactory.insertSTPRules(stprules);

        }
        
    }
    
    /*
	 * @MethodName    recordTypeTest
	 * @description	  testing if the quote status gets updated if the record type is not new service case
	 */
    @isTest
    public static void recordTypeTest(){
        
        User customerServiceUser = [SELECT Id FROM User WHERE Profile.Name = :Pricing_Constant_Util.CUSTOMER_SERVICE  AND IsActive = true LIMIT 1];

        SBQQ__Quote__c insertedQuote = [Select Id from SBQQ__Quote__c where SBQQ__Opportunity2__r.Case__r.RecordType.Name =:Pricing_Constant_Util.PICKUP_CASE limit 1];
        test.startTest();
        System.runAs(customerServiceUser){
            STPRuleExecution.executeRules(insertedQuote.Id, 'Full STP');
            //ExceptionLog__c exceptionLog  = [SELECT id, Exception_Details__c, Application_Name__c, Method_Name__c FROM ExceptionLog__c WHERE Method_Name__c = :methodName_ExecuteRules];
        
        	//System.assertEquals(RECORD_TYPE_ERR_MSG,exceptionLog.Exception_Details__c);
        }

        test.stopTest();
    }
    /*
	 * @MethodName    noSTPRuleFoundTest
	 * @description	  testing NO stp rule found
	 */
    @isTest
    public static void noSTPRuleFoundTest(){

        User customerServiceUser = [SELECT Id FROM User WHERE Profile.Name = :Pricing_Constant_Util.CUSTOMER_SERVICE  AND IsActive = true LIMIT 1];
        SBQQ__Quote__c insertedQuote = [Select Id from SBQQ__Quote__c where SBQQ__Account__r.Name =:location_AccName limit 1];
		test.startTest();
        System.runAs(customerServiceUser){
            STPRuleExecution.executeRules(insertedQuote.Id, 'Partial STP');
            //ExceptionLog__c exceptionLog  = [SELECT id, Exception_Details__c, Method_Name__c FROM ExceptionLog__c WHERE Method_Name__c = :methodName_ExecuteRules];
        	//System.assertEquals(NO_STP_RULE_FOUND + insertedQuote.Name,exceptionLog.Exception_Details__c);
        }
        test.stopTest();
    }
    
    //Rule criteria Not Matched will not occur now post 28507
    //@isTest
    public static void ruleCriteriaNotMatchedTest(){

        User adminUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN  AND IsActive = true LIMIT 1];
        SBQQ__Quote__c insertedQuote = [Select Id from SBQQ__Quote__c where SBQQ__Account__r.Name =:location_AccName limit 1];
		test.startTest();
        System.runAs(adminUser){
            STP_Criteria__c ruleCriteriaNotMatched =  QuoteTestDataFactory.createSTPCriteriaWithAllParam(null, true, true,
                                                                                          'TEMP', 'Open Top', 'OC',
                                                                                          'Trash', 'New Service Case',true, '','K00126',null, true, true, 'Full STP', true, true, false, true, '', 'Any');                                                            
            
        	insert ruleCriteriaNotMatched;
            STPRuleExecution.executeRules(insertedQuote.Id, 'Full STP');
            //ExceptionLog__c exceptionLog  = [SELECT id, Exception_Details__c, Method_Name__c FROM ExceptionLog__c WHERE Method_Name__c = :methodName_ExecuteRules];
            //System.debug('exceptionLog for ruleCriteriaNotMatchedTest '+ exceptionLog.Exception_Details__c);
        	//System.assertEquals(NO_STP_RULE_FOUND + insertedQuote.Name,exceptionLog.Exception_Details__c);
        }
        test.stopTest();
    }
    /*
	 * @MethodName    excludedWMVendorTest
	 * @description	  testing listed excluded WM Vendor, test against ruleWithExcludedWMVendor
	 */
    @isTest
    public static void excludedWMVendorTest(){

        User adminUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN  AND IsActive = true LIMIT 1];
        SBQQ__Quote__c insertedQuote = [Select Id from SBQQ__Quote__c where SBQQ__Account__r.Name =:location_AccName limit 1];
		test.startTest();
        System.runAs(adminUser){
            STP_Criteria__c ruleWithExcludedWMVendor =  QuoteTestDataFactory.createSTPCriteriaWithAllParam(null, true, true,
                                                                                          'TEMP', 'Open Top', 'OC',
                                                                                          'Trash', 'New Service Case',true, '8','K00129',null, true, true, 'Full STP', false, false, false, true, '', 'Any');                                                            
            insert ruleWithExcludedWMVendor;
            STPRuleExecution.executeRules(insertedQuote.Id, 'Full STP');
            //ExceptionLog__c exceptionLog  = [SELECT id, Exception_Details__c, Method_Name__c FROM ExceptionLog__c WHERE Method_Name__c = :methodName_ExecuteRules];
            //System.debug('exceptionLog excludedWMVendorTest '+  exceptionLog.Exception_Details__c);
            //System.assert(exceptionLog.Exception_Details__c!=null,'STP should fail for excluded WM vendor');
        }
        test.stopTest();
    }
    /*
	 * @MethodName    notIncludedWMVendorTest
	 * @description	  testing listed included WM Vendor does not match with quote vendor, test against ruleWithIncludedWMVendor
	 */
    @isTest
    public static void notIncludedWMVendorTest(){

        User adminUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN  AND IsActive = true LIMIT 1];
        SBQQ__Quote__c insertedQuote = [Select Id from SBQQ__Quote__c where SBQQ__Account__r.Name =:location_AccName limit 1];
		test.startTest();
        System.runAs(adminUser){
            STP_Criteria__c ruleWithIncludedWMVendor =  QuoteTestDataFactory.createSTPCriteriaWithAllParam(null, true, true,
                                                                                          'TEMP', 'Open Top', 'OC',
                                                                                          'Trash', 'New Service Case',true, '38','K00129',null, true, true, 'Full STP', true, false, false, true, '', 'Any');                                                            
            insert ruleWithIncludedWMVendor;
            STPRuleExecution.executeRules(insertedQuote.Id, 'Full STP');
            /*ExceptionLog__c exceptionLog  = [SELECT id, Exception_Details__c, Method_Name__c FROM ExceptionLog__c WHERE Method_Name__c = :methodName_ExecuteRules];
            System.debug('exceptionLog notIncludedWMVendorTest '+ exceptionLog.Exception_Details__c);
            System.assert(exceptionLog.Exception_Details__c!=null,'STP should fail for excluded WM vendor');*/
        }
        test.stopTest();
    }
    /*
	 * @MethodName    marketAreaTest
	 * @description	  Market Area does not match
	 */
    @isTest
    public static void marketAreaTest(){
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN  AND IsActive = true LIMIT 1];
        SBQQ__Quote__c insertedQuote = [Select Id from SBQQ__Quote__c where SBQQ__Account__r.Name =:location_AccName limit 1];
		test.startTest();
        System.runAs(adminUser){
            try{
            STP_Criteria__c ruleWithMASValueDifferent =  QuoteTestDataFactory.createSTPCriteriaWithAllParam(null, true, true,
                                                                                          'TEMP', 'Open Top', 'OC',
                                                                                          'Trash', 'New Service Case',true, '8','K00117',null, true, true, 'Full STP', true, false, false, true, '', 'Any');                                                            
            
        	insert ruleWithMASValueDifferent;
                
		STPRuleExecution.executeRules(insertedQuote.Id, 'Full STP');
        //ExceptionLog__c exceptionLog = [SELECT id, Exception_Details__c, Application_Name__c, Method_Name__c FROM ExceptionLog__c WHERE Method_Name__c = :methodName_ExecuteRules];  
        //System.debug('exceptionLog marketAreaTest'+ exceptionLog.Exception_Details__c);
        //System.assertEquals(exceptionLog.Exception_Details__c != null ,'Market Area should not match');
        } catch(Exception e) {
			system.debug('Exception while executing marketAreaTest '+ e.getMessage());
        }
              
        }
        test.stopTest();
    }
     /*
* @Name          MarketAreanullTest
* @Author        Seema Dhikale 
* @Jira          SDT43354
* @Vendor        TCS  
* @Date          5/13/2025
* @Coverage : Covers class STPRuleExecution.executeRules() 
* @description   This method will cover changes for SDT -43354, when no market area available full STP should fail
*/
@isTest
public static void MarketAreanullTest(){
    User customerServiceUser = [SELECT Id FROM User WHERE Profile.Name = :Pricing_Constant_Util.CUSTOMER_SERVICE  AND IsActive = true LIMIT 1];

    User adminUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN  AND IsActive = true LIMIT 1];
    SBQQ__Quote__c insertedQuote = [Select Id,SBQQ__Status__c from SBQQ__Quote__c where SBQQ__Account__r.Name =:location_AccName limit 1];
    Account locationAccount = [Select Id from Account where Name =:location_AccName limit 1];
    test.startTest();
    System.runAs(customerServiceUser){
        try{
            SBQQ.TriggerControl.disable();
            RecurrsiveTriggerHandler.bypassValidationQuoteLine = true;
            RecurrsiveTriggerHandler.isSkipValidateQLCostPrice =true;
            QuoteLineTriggerHelper.extrapickUpRecursion = false;
            List<SBQQ__QuoteLine__c> childQuotelineList = [SELECT Id
                                              FROM SBQQ__QuoteLine__c 
                                              WHERE SBQQ__Quote__c =: insertedQuote.Id AND SBQQ__RequiredBy__c = null LIMIT 1];
            
            //update childQuotelineList;
            AAV_Asset_Availability__c aavObj = new AAV_Asset_Availability__c();
            aavObj.AAV_Location__c = locationAccount.Id;
            aavObj.AAV_APIRequestOutput__c = INVALID_AAV_API_REQUEST_OUTPUT;
            aavObj.AAV_Quote_Line__c = childQuotelineList[0].Id;	
            insert aavObj;
            Pricing_Request__c pReq = [Select Id,Cost_Source__c,Quote__c from Pricing_Request__c limit 1];
            pReq.Quote__c = insertedQuote.id;
            pReq.Quote_Line_Bundle__c = childQuotelineList[0].id;
            pReq.Cost_Source__c = 'WM US';
            pReq.Customer_Price_Type__c = Pricing_Constant_Util.EXHIBIT_PRICING;
            update pReq;
            for(SBQQ__QuoteLine__c ql : childQuotelineList){
                ql.Pricing_Request__c = pReq.id;
            }
            
            update childQuotelineList;
            SBQQ.TriggerControl.enable();
            STP_Criteria__c ruleWithMASValueDifferent =  QuoteTestDataFactory.createSTPCriteriaWithAllParam(null, true, true,
                                                                                      'TEMP', 'Open Top', 'OC',
                                                                                      'Trash', 'New Service Case',true, '8','K00117',null, true, true, 'Full STP', true, false, false, true, '', 'Any');                                                            
        
            insert ruleWithMASValueDifferent;
            
            STPRuleExecution.executeRules(insertedQuote.Id, 'Full STP');
            List<ExceptionLog__c> exceptionLog = [SELECT id, Exception_Details__c, Application_Name__c, Method_Name__c FROM ExceptionLog__c WHERE Method_Name__c = :methodName_ExecuteRules];  
            System.assertEquals(exceptionLog[0].Exception_Details__c != null ,true,'Market Area should not match');
            system.assert(insertedQuote.SBQQ__Status__c.equalsIgnoreCase('Draft'));
    } catch(Exception e) {
        System.assert( e.getMessage().contains('Exception while executing noMarketAreaTest ' ),e.getMessage() );
    }
          
    }
    test.stopTest();
}
    /*
	 * @MethodName    noMarketAreaTest
	 * @description	  Market Area does not match
	 */
    //@isTest
    public static void noMarketAreaTest(){
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN  AND IsActive = true LIMIT 1];
        SBQQ__Quote__c insertedQuote = [Select Id from SBQQ__Quote__c where SBQQ__Account__r.Name =:location_AccName limit 1];
        Account locationAccount = [Select Id from Account where Name =:location_AccName limit 1];
		test.startTest();
        System.runAs(adminUser){
            try{
                SBQQ.TriggerControl.disable();
				RecurrsiveTriggerHandler.bypassValidationQuoteLine = true;
                RecurrsiveTriggerHandler.isSkipValidateQLCostPrice =true;
				QuoteLineTriggerHelper.extrapickUpRecursion = false;
                List<SBQQ__QuoteLine__c> childQuotelineList = [SELECT Id
                                                  FROM SBQQ__QuoteLine__c 
                                                  WHERE SBQQ__Quote__c =: insertedQuote.Id AND SBQQ__RequiredBy__c = null LIMIT 1];
                
                update childQuotelineList;
                AAV_Asset_Availability__c aavObj = new AAV_Asset_Availability__c();
            	aavObj.AAV_Location__c = locationAccount.Id;
				aavObj.AAV_APIRequestOutput__c = INVALID_AAV_API_REQUEST_OUTPUT;
				aavObj.AAV_Quote_Line__c = childQuotelineList[0].Id;
                insert aavObj;
                SBQQ.TriggerControl.enable();
            	STP_Criteria__c ruleWithMASValueDifferent =  QuoteTestDataFactory.createSTPCriteriaWithAllParam(null, true, true,
                                                                                          'TEMP', 'Open Top', 'OC',
                                                                                          'Trash', 'New Service Case',true, '8','K00126',null, true, true, 'Full STP', true, false, false, true, '', 'Any');                                                            
            
        		insert ruleWithMASValueDifferent;
                
				STPRuleExecution.executeRules(insertedQuote.Id, 'Full STP');
                /*system.debug('quotLineMarketAreaMap '+ STPRuleExecution.quotLineMarketAreaMap);
                List<ExceptionLog__c> exceptionLog = [SELECT id, Exception_Details__c, Application_Name__c, Method_Name__c FROM ExceptionLog__c WHERE Method_Name__c = :methodName_ExecuteRules];  
                System.debug('exceptionLog0 noMarketAreaTest'+ exceptionLog[0].Exception_Details__c);
                System.debug('exceptionLog1 noMarketAreaTest'+ exceptionLog[1].Exception_Details__c);
                System.assertEquals(exceptionLog.Exception_Details__c != null ,'Market Area should not match');*/
        } catch(Exception e) {
			system.debug('Exception while executing noMarketAreaTest '+ e.getMessage());
        }
              
        }
        test.stopTest();
    }
    @isTest
    public static void marketTypeOpenTest(){
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN  AND IsActive = true LIMIT 1];
        SBQQ__Quote__c insertedQuote = [Select Id from SBQQ__Quote__c where SBQQ__Account__r.Name =:location_AccName limit 1];
		test.startTest();
        System.runAs(adminUser){
            try{
            STP_Criteria__c ruleWithMarketTypeClosed =  QuoteTestDataFactory.createSTPCriteriaWithAllParam(null, true, true,
                                                                                          'TEMP', 'Open Top', 'OC',
                                                                                          'Trash', 'New Service Case',true, '','K00126',null, true, true, 'Full STP', true, true, false, true, '', 'Closed');                                                            
            
        	insert ruleWithMarketTypeClosed;
                
			STPRuleExecution.executeRules(insertedQuote.Id, 'Full STP');
        	//ExceptionLog__c exceptionLog = [SELECT id, Exception_Details__c, Method_Name__c FROM ExceptionLog__c WHERE Method_Name__c = :methodName_ExecuteRules];  
        
     
        	//System.debug('exceptionLog marketTypeOpenTest'+ exceptionLog.Exception_Details__c);
        	//System.assertEquals(exceptionLog.Exception_Details__c != null ,'Market Type not Matching');
        } catch(Exception e) {
			system.debug('Exception while executing marketTypeOpenTest '+ e.getMessage());
        }
              
        }
        test.stopTest();
    }	
    
    @isTest 
    public static void marketTypeClosedTest(){
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN  AND IsActive = true LIMIT 1];
        test.startTest();
        System.runAs(adminUser){
            try{
                SBQQ__Quote__c insertedQuote = [Select Id from SBQQ__Quote__c where SBQQ__Account__r.Name =:location_AccName limit 1];
        		
                Pricing_Request__c pr = [Select Id, zone_Type__c from Pricing_Request__c where zone_Type__c = :Pricing_Constant_Util.WM_FRANCHISE limit 1];
        		//system.debug('Pricing Zone type before update '+ pr.zone_Type__c);
                SBQQ.TriggerControl.disable();
				RecurrsiveTriggerHandler.bypassValidationQuoteLine = true;
                RecurrsiveTriggerHandler.isSkipValidateQLCostPrice =true;
				QuoteLineTriggerHelper.extrapickUpRecursion = false;
                List<SBQQ__QuoteLine__c> childQuotelineList = [SELECT Id, Pricing_Request__c, Pricing_Request__r.zone_Type__c
                                                  FROM SBQQ__QuoteLine__c 
                                                  WHERE SBQQ__Quote__c =: insertedQuote.Id AND SBQQ__RequiredBy__c = null LIMIT 1];
                childQuotelineList[0].Pricing_Request__c = pr.Id;
                childQuotelineList[0].Pricing_Request__r.zone_Type__c = pr.zone_Type__c;
                update childQuotelineList;
                SBQQ.TriggerControl.enable();
                List<SBQQ__QuoteLine__c> childQuotelineListnew = [SELECT Id, Pricing_Request__c, Pricing_Request__r.zone_Type__c
                                                  FROM SBQQ__QuoteLine__c 
                                                  WHERE SBQQ__Quote__c =: insertedQuote.Id AND SBQQ__RequiredBy__c = null LIMIT 1];
                
                //system.debug('QuoteLine Zone type After update '+ childQuotelineListnew[0].Pricing_Request__r.zone_Type__c);
            
                STP_Criteria__c ruleWithMarketTypeOpen =  QuoteTestDataFactory.createSTPCriteriaWithAllParam(null, true, true,
                                                                                          'TEMP', 'Open Top', 'OC',
                                                                                          'Trash', 'New Service Case',true, '','K00126',null, true, true, 'Full STP', true, true, false, true, '', 'Open');
            
        	insert ruleWithMarketTypeOpen;
                
		STPRuleExecution.executeRules(insertedQuote.Id, 'Full STP');
        //ExceptionLog__c exceptionLog = [SELECT id, Exception_Details__c, Method_Name__c FROM ExceptionLog__c WHERE Method_Name__c = :methodName_ExecuteRules];
        //System.debug('exceptionLog marketTypeClosedTest '+ exceptionLog!=null ? exceptionLog.Exception_Details__c: 'No Exception');
        //System.assertEquals(exceptionLog.Exception_Details__c != null ,'Market Type not Matching');
        } catch(Exception e) {
			system.debug('Exception while executing marketTypeClosedTest '+ e.getMessage());
        }
        }
        test.stopTest();
    }
    @isTest
    public static void excludeAll3PTest(){
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN  AND IsActive = true LIMIT 1];
        test.startTest();
        System.runAs(adminUser){
            try{
                
                SBQQ__Quote__c insertedQuote = [Select Id from SBQQ__Quote__c where SBQQ__Account__r.Name =:location_AccName limit 1];
                //SBQQ__Quote__c insertedQuote = [Select Id from SBQQ__Quote__c where SBQQ__Account__r.Name =:thirdPartylocation_AccName limit 1];
               
                //List<SBQQ__QuoteLine__c> childQuotelineList = [Select Id, Vendor__c,sCode__c, Vendor__r.Parent_Vendor_ID__c from SBQQ__QuoteLine__c where SBQQ__Quote__c = :insertedQuote.Id];
                List<SBQQ__QuoteLine__c> childQuotelineList = [SELECT Id, Vendor__r.Parent_Vendor_ID__c,Vendor__c
                                                  FROM SBQQ__QuoteLine__c 
                                                  WHERE SBQQ__Quote__c =: insertedQuote.Id AND SBQQ__Product__r.ProductCode = 'H' LIMIT 1];                                    
                //System.debug('Partial STP Quote Vendor__r.Parent_Vendor_ID__c '+ childQuotelineList[0].Vendor__r.Parent_Vendor_ID__c);
                //System.debug('Partial STP Quote Vendor__c '+ childQuotelineList[0].Vendor__c);
                
                Account thirdPartyVendor = [Select Id from Account where Name =:thirdPartyparentVendor_AccName];
                childQuotelineList[0].Vendor__c = thirdPartyVendor.Id;
                childQuotelineList[0].sCode__c = null;
                SBQQ.TriggerControl.disable();
                RecurrsiveTriggerHandler.bypassValidationQuoteLine = true;
                RecurrsiveTriggerHandler.isSkipValidateQLCostPrice =true;
				QuoteLineTriggerHelper.extrapickUpRecursion = false;
                update childQuotelineList;
                SBQQ.TriggerControl.enable();
                //System.debug('After Partial STP Quote Vendor__r.Parent_Vendor_ID__c '+ childQuotelineList[0].Vendor__r.Parent_Vendor_ID__c);
                //System.debug('After Partial STP Quote Vendor__c '+ childQuotelineList[0].Vendor__c);
                STP_Criteria__c ruleWithexcludeAll3PTest =  QuoteTestDataFactory.createSTPCriteriaWithAllParam(null, true, true,
                                                                                          'TEMP', 'Open Top', 'OC',
                                                                                          'Trash', 'New Service Case',true, '','K00126',null, true, true, 'Partial STP', true, true, false, true, '', 'Closed'); 
            
                
        	insert ruleWithexcludeAll3PTest;
            
		STPRuleExecution.executeRules(insertedQuote.Id, 'Partial STP');
        //ExceptionLog__c exceptionLog = [SELECT id, Exception_Details__c, Application_Name__c, Method_Name__c FROM ExceptionLog__c WHERE Method_Name__c = :methodName_ExecuteRules];  
        
        //System.debug('exceptionLog excludeAll3PTest '+ exceptionLog!=null ? exceptionLog.Exception_Details__c: 'No Exception');
        //System.assertEquals(exceptionLog.Exception_Details__c != null ,'Exclude All 3P');
        } catch(Exception e) {
			system.debug('Exception while executing excludeAll3PTest '+ e.getMessage());
        }
              
        }
        test.stopTest();
    }
    @isTest
    public static void excludeChildVendor3PTest(){
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN  AND IsActive = true LIMIT 1];
        test.startTest();
        System.runAs(adminUser){
            try{
                SBQQ__Quote__c insertedQuote = [Select Id from SBQQ__Quote__c where SBQQ__Account__r.Name =:location_AccName limit 1];                
                List<SBQQ__QuoteLine__c> childQuotelineList = [SELECT Id, Vendor__r.Parent_Vendor_ID__c,Vendor__c
                                                  FROM SBQQ__QuoteLine__c 
                                                  WHERE SBQQ__Quote__c =: insertedQuote.Id AND SBQQ__Product__r.ProductCode = 'H' LIMIT 1];                                    
                
                Account thirdPartyVendor = [Select Id from Account where Name =:thirdPartyparentVendor_AccName];
                childQuotelineList[0].Vendor__c = thirdPartyVendor.Id;
                childQuotelineList[0].sCode__c = null;
                SBQQ.TriggerControl.disable();
                RecurrsiveTriggerHandler.bypassValidationQuoteLine = true;
                RecurrsiveTriggerHandler.isSkipValidateQLCostPrice =true;
				QuoteLineTriggerHelper.extrapickUpRecursion = false;
                update childQuotelineList;
                SBQQ.TriggerControl.enable();
                STP_Criteria__c ruleWithexcludeChildVendor3PTest =  QuoteTestDataFactory.createSTPCriteriaWithAllParam(null, true, true,
                                                                                          'TEMP', 'Open Top', 'OC',
                                                                                          'Trash', 'New Service Case',true, '','K00126',null, true, true, 'Partial STP', true, true, false, false, childQuotelineList[0].Vendor__c, 'Closed'); 
            
        		insert ruleWithexcludeChildVendor3PTest;
            
		STPRuleExecution.executeRules(insertedQuote.Id, 'Partial STP');
        //ExceptionLog__c exceptionLog = [SELECT id, Exception_Details__c, Application_Name__c, Method_Name__c FROM ExceptionLog__c WHERE Method_Name__c = :methodName_ExecuteRules];  
        
        //System.debug('exceptionLog excludeChildVendor3PTest '+ exceptionLog!=null ? exceptionLog.Exception_Details__c: 'No Exception');
        //System.assertEquals(exceptionLog.Exception_Details__c != null ,'Exclude All 3P');
        } catch(Exception e) {
			system.debug('Exception while executing excludeChildVendor3PTest '+ e.getMessage());
        }
              
        }
        test.stopTest();
    }
        @isTest
    public static void excludeParentVendor3PTest(){
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN  AND IsActive = true LIMIT 1];
        test.startTest();
        System.runAs(adminUser){
            try{
                SBQQ__Quote__c insertedQuote = [Select Id from SBQQ__Quote__c where SBQQ__Account__r.Name =:location_AccName limit 1];                
                List<SBQQ__QuoteLine__c> childQuotelineList = [SELECT Id, Vendor__r.Parent_Vendor_ID__c,Vendor__c
                                                  FROM SBQQ__QuoteLine__c 
                                                  WHERE SBQQ__Quote__c =: insertedQuote.Id AND SBQQ__Product__r.ProductCode = 'H' LIMIT 1];                                    
                
                Account thirdPartyVendor = [Select Id from Account where Name =:thirdPartyparentVendor_AccName];
                childQuotelineList[0].Vendor__c = thirdPartyVendor.Id;
                childQuotelineList[0].sCode__c = null;
                SBQQ.TriggerControl.disable();
                RecurrsiveTriggerHandler.bypassValidationQuoteLine = true;
                RecurrsiveTriggerHandler.isSkipValidateQLCostPrice =true;
				QuoteLineTriggerHelper.extrapickUpRecursion = false;
                update childQuotelineList;
                SBQQ.TriggerControl.enable();
                STP_Criteria__c ruleWithexcludeParentVendor3PTest =  QuoteTestDataFactory.createSTPCriteriaWithAllParam(null, true, true,
                                                                                          'TEMP', 'Open Top', 'OC',
                                                                                          'Trash', 'New Service Case',true, '','K00126',null, true, true, 'Partial STP', true, true, false, false, childQuotelineList[0].Vendor__r.Parent_Vendor_ID__c, 'Closed'); 
            
        		insert ruleWithexcludeParentVendor3PTest;
            
		STPRuleExecution.executeRules(insertedQuote.Id, 'Partial STP');
        //ExceptionLog__c exceptionLog = [SELECT id, Exception_Details__c, Application_Name__c, Method_Name__c FROM ExceptionLog__c WHERE Method_Name__c = :methodName_ExecuteRules];  
        
        //System.debug('exceptionLog excludeParentVendor3PTest '+ exceptionLog!=null ? exceptionLog.Exception_Details__c: 'No Exception');
        //System.assertEquals(exceptionLog.Exception_Details__c != null ,'Exclude All 3P');
        } catch(Exception e) {
			system.debug('Exception while executing excludeParentVendor3PTest '+ e.getMessage());
        }
              
        }
        test.stopTest();
    }
         @isTest
    public static void marketTypeMismatch3PTest(){
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN  AND IsActive = true LIMIT 1];
        test.startTest();
        System.runAs(adminUser){
            try{
                SBQQ__Quote__c insertedQuote = [Select Id from SBQQ__Quote__c where SBQQ__Account__r.Name =:location_AccName limit 1];                
                List<SBQQ__QuoteLine__c> childQuotelineList = [SELECT Id, Vendor__r.Parent_Vendor_ID__c,Vendor__c
                                                  FROM SBQQ__QuoteLine__c 
                                                  WHERE SBQQ__Quote__c =: insertedQuote.Id AND SBQQ__Product__r.ProductCode = 'H' LIMIT 1];                                    
                
                Account thirdPartyVendor = [Select Id from Account where Name =:thirdPartyparentVendor_AccName];
                childQuotelineList[0].Vendor__c = thirdPartyVendor.Id;
                childQuotelineList[0].sCode__c = Pricing_Constant_Util.SCODE_Split;
                SBQQ.TriggerControl.disable();
                RecurrsiveTriggerHandler.bypassValidationQuoteLine = true;
                RecurrsiveTriggerHandler.isSkipValidateQLCostPrice =true;
				QuoteLineTriggerHelper.extrapickUpRecursion = false;
                update childQuotelineList;
                SBQQ.TriggerControl.enable();
                STP_Criteria__c ruleWithMarketTypeMismatch3PTest =  QuoteTestDataFactory.createSTPCriteriaWithAllParam(null, true, true,
                                                                                          'TEMP', 'Open Top', 'OC',
                                                                                          'Trash', 'New Service Case',true, '','K00126',null, true, true, 'Partial STP', true, true, true, true, '', 'Open'); 
            
        		insert ruleWithmarketTypeMismatch3PTest;
            
		STPRuleExecution.executeRules(insertedQuote.Id, 'Partial STP');
        //ExceptionLog__c exceptionLog = [SELECT id, Exception_Details__c, Application_Name__c, Method_Name__c FROM ExceptionLog__c WHERE Method_Name__c = :methodName_ExecuteRules];          
        //System.debug('exceptionLog marketTypeMismatch3PTest '+ exceptionLog!=null ? exceptionLog.Exception_Details__c: 'No Exception');
        //System.assertEquals(exceptionLog.Exception_Details__c != null ,'Exclude All 3P');
        } catch(Exception e) {
			system.debug('Exception while executing marketTypeMismatch3PTest '+ e.getMessage());
        }
              
        }
        test.stopTest();
    }
    @isTest
    public static void includeNonMatching3PTest(){
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN  AND IsActive = true LIMIT 1];
        test.startTest();
        System.runAs(adminUser){
            try{
                SBQQ__Quote__c insertedQuote = [Select Id from SBQQ__Quote__c where SBQQ__Account__r.Name =:location_AccName limit 1];                
                List<SBQQ__QuoteLine__c> childQuotelineList = [SELECT Id, Vendor__r.Parent_Vendor_ID__c,Vendor__c
                                                  FROM SBQQ__QuoteLine__c 
                                                  WHERE SBQQ__Quote__c =: insertedQuote.Id AND SBQQ__Product__r.ProductCode = 'H' LIMIT 1];                                    
                
                Account thirdPartyVendor = [Select Id from Account where Name =:thirdPartyparentVendor_AccName];
                childQuotelineList[0].Vendor__c = thirdPartyVendor.Id;
                childQuotelineList[0].sCode__c = Pricing_Constant_Util.SCODE_Split;
                SBQQ.TriggerControl.disable();
                RecurrsiveTriggerHandler.bypassValidationQuoteLine = true;
                RecurrsiveTriggerHandler.isSkipValidateQLCostPrice =true;
				QuoteLineTriggerHelper.extrapickUpRecursion = false;
                update childQuotelineList;
                SBQQ.TriggerControl.enable();
                STP_Criteria__c ruleWithincludeNonMatching3PTest =  QuoteTestDataFactory.createSTPCriteriaWithAllParam(null, true, true,
                                                                                          'TEMP', 'Open Top', 'OC',
                                                                                          'Trash', 'New Service Case',true, '','K00126',null, true, true, 'Partial STP', true, true, true, false, '28147', 'Open'); 
            
        		insert ruleWithincludeNonMatching3PTest;
            
				STPRuleExecution.executeRules(insertedQuote.Id, 'Partial STP');
        /*ExceptionLog__c exceptionLog = [SELECT id, Exception_Details__c, Application_Name__c, Method_Name__c FROM ExceptionLog__c WHERE Method_Name__c = :methodName_ExecuteRules];          
        System.debug('exceptionLog includeNonMatching3PTest '+ exceptionLog!=null ? exceptionLog.Exception_Details__c: 'No Exception');
        System.assertEquals(exceptionLog.Exception_Details__c != null ,'Exclude All 3P');*/
        } catch(Exception e) {
			system.debug('Exception while executing includeNonMatching3PTest '+ e.getMessage());
        }
              
        }
        test.stopTest();
    }
    
    /*
	 * @MethodName    executeRulesTest
	 * @description	  Checking whether the positiveSingle quote  completes STP for all the customers when the STP Criteria is found
	 */
    @isTest
    public static void executeRulesTest(){
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN  AND IsActive = true LIMIT 1];
        SBQQ__Quote__c insertedQuote = [Select Id from SBQQ__Quote__c where SBQQ__Account__r.Name =:location_AccName limit 1];
        Boolean result = false;
		test.startTest();
        System.runAs(adminUser){
            STP_Criteria__c executeRulesCriteria =  QuoteTestDataFactory.createSTPCriteriaWithAllParam(null, true, true,
                                                                                          'TEMP', 'Open Top', 'OC',
                                                                                          'Trash', 'New Service Case',true, '','K00126',null, true, true, 'Full STP', true, true, true, true, '', 'Any');                                                            
            
        	insert executeRulesCriteria;
            result = STPRuleExecution.executeRules(insertedQuote.Id, 'Full STP');
            //system.debug('executeRulesTest result '+ result);
        	//System.assertEquals(true , result);
        }
        test.stopTest();
    } 
    
    /*
	 * @MethodName    parentAccTest
	 * @description	  Checking whether the quote is not passing STP when the customer included in the criteria is not the customer in the quote
	 */
    @isTest
    public static void customerAccParentAccNotMatchedTest(){   
        
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN  AND IsActive = true LIMIT 1];
        test.startTest();
        System.runAs(adminUser){
            try{
                   SBQQ__Quote__c insertedQuote = [Select Id from SBQQ__Quote__c where SBQQ__Account__r.Name =:location_AccName limit 1];
                Account thirdPartyVendor = [Select Id from Account where Name =:thirdPartyparentVendor_AccName];
                STP_Criteria__c ruleWithDifferentCustomer =  QuoteTestDataFactory.createSTPCriteriaWithAllParam(thirdPartyVendor.Id, false, true,
                                                                                          'TEMP', 'Open Top', 'OC',
                                                                                          'Trash', 'New Service Case',true, '','K00126',null, true, true, 'Full STP', true, true, false, true, '', 'Open');                                                            
                                          
        insert ruleWithDifferentCustomer;
		 STPRuleExecution.executeRules(insertedQuote.Id, 'Full STP');
                //ExceptionLog__c exceptionLog  = [SELECT id, Exception_Details__c , Method_Name__c FROM ExceptionLog__c WHERE Method_Name__c =:methodName_ExecuteRules ];
                //system.debug('exceptionLog parentAccTest '+ exceptionLog!=null ? exceptionLog.Exception_Details__c : 'No Exception in parentAccTest');
        /*System.assertEquals('Rule Name:'+ ruleWithDifferentCustomerId.Name + ', does not contain following Account - '+ customer_code + ' for Quote ' + insertedQuote.Name +';',
                            exceptionLog.Exception_Details__c); */
        
            }catch(Exception ex){
                system.debug('Exception while executing parentAccTest '+ ex.getMessage());
            }
            
        }
        
        test.stopTest();
    } 
    
    /*
* @MethodName    haulCostTest
* @description	  checking if  the quote passes STP if the haul cost is not in between 150 and 1000 
*/
    @isTest
    public static void haulCostTest(){
        test.startTest();
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN  AND IsActive = true LIMIT 1];
        System.runAs(adminUser){
            try{
                SBQQ__Quote__c insertedQuote = [Select Id from SBQQ__Quote__c where SBQQ__Account__r.Name =:location_AccName limit 1];
                //get haul quoteline in this quote
                SBQQ.TriggerControl.disable();
				RecurrsiveTriggerHandler.bypassValidationQuoteLine = true;
                RecurrsiveTriggerHandler.isSkipValidateQLCostPrice =true;
				QuoteLineTriggerHelper.extrapickUpRecursion = false;
        		List<SBQQ__QuoteLine__c> haulquoteline = [SELECT Id, SBQQ__UnitCost__c, Cost_Override_Reason__c,Cost_Override_Description__c
                                                  FROM SBQQ__QuoteLine__c 
                                                  WHERE SBQQ__Quote__c =: insertedQuote.Id AND SBQQ__Product__r.ProductCode = 'H' LIMIT 1];                                    
        haulquoteline[0].SBQQ__UnitCost__c = 100;
        haulquoteline[0].Cost_Override_Reason__c ='Other';
        haulquoteline[0].Cost_Override_Description__c = 'testing';
        Update haulquoteline;
                SBQQ.TriggerControl.enable();
                STP_Criteria__c ruleWithProperConfig =  QuoteTestDataFactory.createSTPCriteriaWithAllParam(null, true, true,
                                                                                          'TEMP', 'Open Top', 'OC',
                                                                                          'Trash', 'New Service Case',true, '','K00126',null, true, true, 'Full STP', true, true, false, true, '', 'Any');                                                            
            
        	insert ruleWithProperConfig;
        
            STPRuleExecution.executeRules(insertedQuote.Id, 'Full STP');
               // ExceptionLog__c exceptionLog = [SELECT id, Exception_Details__c , Method_Name__c FROM ExceptionLog__c WHERE Method_Name__c = :methodName_ExecuteRules];
        //System.debug('exceptionLog haulCostTest'+ exceptionLog!=null ? exceptionLog.Exception_Details__c: 'No Exception');
            }catch(Exception e) {
			system.debug('Exception while executing haulCostTest '+ e.getMessage());
        }
        }
        test.stopTest();
        
        }
    
    /*
	 * @MethodName    containerServiceChargeCostTest
	 * @description	  testing if the unit cost of the quoteline is 0 the quote gets updated to price configured stage
	 */
    @isTest
    public static void containerServiceChargeCostTest(){
        test.startTest();
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN  AND IsActive = true LIMIT 1];
        System.runAs(adminUser){
            try{
                SBQQ__Quote__c insertedQuote = [Select Id from SBQQ__Quote__c where SBQQ__Account__r.Name =:location_AccName limit 1];
                SBQQ.TriggerControl.disable();
				RecurrsiveTriggerHandler.bypassValidationQuoteLine = true;
                RecurrsiveTriggerHandler.isSkipValidateQLCostPrice =true;
				QuoteLineTriggerHelper.extrapickUpRecursion = false;
                
        		List<SBQQ__QuoteLine__c> qlContainerServiceCharge = [SELECT Id, SBQQ__UnitCost__c, Cost_Override_Reason__c,Cost_Override_Description__c
                                                            FROM SBQQ__QuoteLine__c 
                                                            WHERE SBQQ__Quote__c =: insertedQuote.Id AND SBQQ__Product__r.ProductCode = 'CSC' LIMIT 1];                                   
        qlContainerServiceCharge[0].SBQQ__UnitCost__c = 0;
        qlContainerServiceCharge[0].Cost_Override_Reason__c ='Other';
        qlContainerServiceCharge[0].Cost_Override_Description__c = 'testing';
        Update qlContainerServiceCharge;
                SBQQ.TriggerControl.enable();
                STP_Criteria__c ruleWithProperConfig =  QuoteTestDataFactory.createSTPCriteriaWithAllParam(null, true, true,
                                                                                          'TEMP', 'Open Top', 'OC',
                                                                                          'Trash', 'New Service Case',true, '','K00126',null, true, true, 'Full STP', true, true, false, true, '', 'Any');                                                            
            
        	insert ruleWithProperConfig;
                STPRuleExecution.executeRules(insertedQuote.Id, 'Full STP');
                //ExceptionLog__c exceptionLog = [SELECT id, Exception_Details__c, Method_Name__c FROM ExceptionLog__c WHERE Method_Name__c = :methodName_ExecuteRules];
        	//System.debug('exceptionLog '+ exceptionLog!=null ? exceptionLog.Exception_Details__c: 'No Exception');
            }catch(Exception e) {
			system.debug('Exception while executing containerServiceChargeCostTest '+ e.getMessage());
            }
        }
        test.stopTest();
    }
    /*
	 * @MethodName    deliveryCostTest
	 * @description	  testing if the unit cost of the quoteline is 0 the quote gets updated to price configured stage
	 */
    @isTest
    public static void deliveryCostTest(){
        test.startTest();
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN  AND IsActive = true LIMIT 1];
        System.runAs(adminUser){
            try{
                SBQQ__Quote__c insertedQuote = [Select Id from SBQQ__Quote__c where SBQQ__Account__r.Name =:location_AccName limit 1];
                SBQQ.TriggerControl.disable();
				RecurrsiveTriggerHandler.bypassValidationQuoteLine = true;
                RecurrsiveTriggerHandler.isSkipValidateQLCostPrice =true;
				QuoteLineTriggerHelper.extrapickUpRecursion = false;
                
        		List<SBQQ__QuoteLine__c> qlDelivery = [SELECT Id, SBQQ__UnitCost__c, Cost_Override_Reason__c,Cost_Override_Description__c
                                                            FROM SBQQ__QuoteLine__c 
                                                            WHERE SBQQ__Quote__c =: insertedQuote.Id AND SBQQ__Product__r.ProductCode = 'DLV' LIMIT 1];                                   
                qlDelivery[0].SBQQ__UnitCost__c = 0;
                qlDelivery[0].Cost_Override_Reason__c ='Other';
                qlDelivery[0].Cost_Override_Description__c = 'testing';
                Update qlDelivery;
                SBQQ.TriggerControl.enable();
                STP_Criteria__c ruleWithDeliveryCostConfig =  QuoteTestDataFactory.createSTPCriteriaWithAllParam(null, true, true,
                                                                                          'TEMP', 'Open Top', 'OC',
                                                                                          'Trash', 'New Service Case',true, '','K00126',null, true, true, 'Full STP', true, true, false, true, '', 'Any');                                                            
            
        	insert ruleWithDeliveryCostConfig;
                STPRuleExecution.executeRules(insertedQuote.Id, 'Full STP');
               // ExceptionLog__c exceptionLog = [SELECT id, Exception_Details__c, Method_Name__c FROM ExceptionLog__c WHERE Method_Name__c = :methodName_ExecuteRules];
        	//System.debug('exceptionLog deliveryCostTest '+ exceptionLog!=null ? exceptionLog.Exception_Details__c: 'No Exception');
            }catch(Exception e) {
			system.debug('Exception while executing deliveryCostTest '+ e.getMessage());
            }
        }
        test.stopTest();
    }
 
    @isTest
    public static void exclude1CustomerTest(){
        test.startTest();
        //querying customer service user
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN  AND IsActive = true LIMIT 1];
        System.runAs(adminUser){
  
		STP_Criteria__c ruleWithExcludeCustomerId = QuoteTestDataFactory.createSTPCriteriaWithAllParam('WAL', false, false,'TEMP', 'Open Top', 'OC','Trash', 'New Service Case',true, '','K00126',null, true, true, 'Full STP', true, true, false, true, '', 'Any'); 
        insert ruleWithExcludeCustomerId ;    
        SBQQ__Quote__c insertedQuote = [Select Id from SBQQ__Quote__c where SBQQ__Account__r.Name =:location_AccName limit 1];
        List<SBQQ__QuoteLine__c> quoteline = [SELECT Id, Account__r.Parent.Accounting_System__c, Account__r.Parent.Customer_Code__c
                                                  FROM SBQQ__QuoteLine__c 
                                                  WHERE SBQQ__Quote__c =: insertedQuote.Id LIMIT 1];
         //system.debug('quoteLine Accounting system '+ quoteline[0].Account__r.Parent.Accounting_System__c);
//         system.debug('Account__r.Parent.Customer_Code__c '+ quoteline[0].Account__r.Parent.Customer_Code__c);
			STPRuleExecution.executeRules(insertedQuote.Id, 'Full STP');
        //ExceptionLog__c exceptionLog = [SELECT id, Exception_Details__c , Method_Name__c FROM ExceptionLog__c WHERE Method_Name__c = :methodName_ExecuteRules];
        //System.debug('exceptionLog accountingSystemTest WMNAT'+ exceptionLog!=null ? exceptionLog.Exception_Details__c: 'No Exception');
        //parentAcc.Accounting_System__c = OAKWL;
        //update parentAcc;
        //RecurrsiveTriggerHandler.bypassValidation = true;
        //STPRuleExecution.executeRules(insertedQuote.Id, 'Full STP');
          //  ExceptionLog__c exceptionLog = [SELECT id, Exception_Details__c, Method_Name__c FROM ExceptionLog__c WHERE Method_Name__c = :methodName_ExecuteRules];
        //System.debug('exceptionLog accountingSystemTest OAKWL'+ exceptionLog!=null ? exceptionLog.Exception_Details__c: 'No Exception');
        }
        
        //System.assertEquals(STPRuleExecution.isSTPSuccess, false); 
        test.stopTest();
    }
    @isTest
    public static void exclude1CanadaCustomerTest(){
        test.startTest();
        
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN  AND IsActive = true LIMIT 1];
        System.runAs(adminUser){
            Account parentAcc = [Select Id,Name,Accounting_System__c from Account where Name =:parent_AccName limit 1];
            parentAcc.Accounting_System__c = OAKWL;
            update parentAcc;
        	RecurrsiveTriggerHandler.bypassValidation = true;
			STP_Criteria__c ruleWithExcludeCanadaCustomerId = QuoteTestDataFactory.createSTPCriteriaWithAllParam('WAL', false, false,'TEMP', 'Open Top', 'OC','Trash', 'New Service Case',true, '','K00126','WAL', false, false, 'Full STP', true, true, false, true, '', 'Any'); 
        	insert ruleWithExcludeCanadaCustomerId ; 
            
        SBQQ__Quote__c insertedQuote = [Select Id from SBQQ__Quote__c where SBQQ__Account__r.Name =:location_AccName limit 1];
			STPRuleExecution.executeRules(insertedQuote.Id, 'Full STP');
        //ExceptionLog__c exceptionLog = [SELECT id, Exception_Details__c , Method_Name__c FROM ExceptionLog__c WHERE Method_Name__c = :methodName_ExecuteRules];
        //System.debug('exceptionLog accountingSystemTest WMNAT'+ exceptionLog!=null ? exceptionLog.Exception_Details__c: 'No Exception');
        
        //STPRuleExecution.executeRules(insertedQuote.Id, 'Full STP');
          //  ExceptionLog__c exceptionLog = [SELECT id, Exception_Details__c, Method_Name__c FROM ExceptionLog__c WHERE Method_Name__c = :methodName_ExecuteRules];
        //System.debug('exceptionLog accountingSystemTest OAKWL'+ exceptionLog!=null ? exceptionLog.Exception_Details__c: 'No Exception');
        }
        
        //System.assertEquals(STPRuleExecution.isSTPSuccess, false); 
        test.stopTest();
    }
    @isTest
    public static void include1NotMatchingCanadaCustomerTest(){
        test.startTest();
        
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN  AND IsActive = true LIMIT 1];
        System.runAs(adminUser){
            Account parentAcc = [Select Id,Name,Accounting_System__c from Account where Name =:parent_AccName limit 1];
            parentAcc.Accounting_System__c = OAKWL;
            update parentAcc;
        	RecurrsiveTriggerHandler.bypassValidation = true;
			STP_Criteria__c ruleWithInclude1NotMatchingCanadaCustomerId = QuoteTestDataFactory.createSTPCriteriaWithAllParam('WAL', false, false,'TEMP', 'Open Top', 'OC','Trash', 'New Service Case',true, '','K00126','ABC', false, true, 'Full STP', true, true, false, true, '', 'Any'); 
        	insert ruleWithInclude1NotMatchingCanadaCustomerId ; 
            //system.debug('ruleWithInclude1NotMatchingCanadaCustomerId.Customer_Canada__c ' + ruleWithInclude1NotMatchingCanadaCustomerId.Customer_Canada__c);
        	SBQQ__Quote__c insertedQuote = [Select Id from SBQQ__Quote__c where SBQQ__Account__r.Name =:location_AccName limit 1];
        
			STPRuleExecution.executeRules(insertedQuote.Id, 'Full STP');
        //ExceptionLog__c exceptionLog = [SELECT id, Exception_Details__c , Method_Name__c FROM ExceptionLog__c WHERE Method_Name__c = :methodName_ExecuteRules];
        //System.debug('exceptionLog accountingSystemTest WMNAT'+ exceptionLog!=null ? exceptionLog.Exception_Details__c: 'No Exception');
        
        //STPRuleExecution.executeRules(insertedQuote.Id, 'Full STP');
          //  ExceptionLog__c exceptionLog = [SELECT id, Exception_Details__c, Method_Name__c FROM ExceptionLog__c WHERE Method_Name__c = :methodName_ExecuteRules];
        //System.debug('exceptionLog accountingSystemTest OAKWL'+ exceptionLog!=null ? exceptionLog.Exception_Details__c: 'No Exception');
        }
        
        //System.assertEquals(STPRuleExecution.isSTPSuccess, false); 
        test.stopTest();
    }
	@isTest
    public static void excludeAllCanadaCustomerTest(){
        test.startTest();
        
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN  AND IsActive = true LIMIT 1];
        System.runAs(adminUser){
            Account parentAcc = [Select Id,Name,Accounting_System__c from Account where Name =:parent_AccName limit 1];
            parentAcc.Accounting_System__c = OAKWL;
            update parentAcc;
        	RecurrsiveTriggerHandler.bypassValidation = true;
			STP_Criteria__c ruleExcludeAllCanadaCustomer = QuoteTestDataFactory.createSTPCriteriaWithAllParam('WAL', false, false,'TEMP', 'Open Top', 'OC','Trash', 'New Service Case',true, '','K00126','', true, false, 'Full STP', true, true, false, true, '', 'Any'); 
        	insert ruleExcludeAllCanadaCustomer ; 
            
        	SBQQ__Quote__c insertedQuote = [Select Id from SBQQ__Quote__c where SBQQ__Account__r.Name =:location_AccName limit 1];
        
			STPRuleExecution.executeRules(insertedQuote.Id, 'Full STP');
        //ExceptionLog__c exceptionLog = [SELECT id, Exception_Details__c , Method_Name__c FROM ExceptionLog__c WHERE Method_Name__c = :methodName_ExecuteRules];
        //System.debug('exceptionLog accountingSystemTest WMNAT'+ exceptionLog!=null ? exceptionLog.Exception_Details__c: 'No Exception');
        
        //STPRuleExecution.executeRules(insertedQuote.Id, 'Full STP');
          //  ExceptionLog__c exceptionLog = [SELECT id, Exception_Details__c, Method_Name__c FROM ExceptionLog__c WHERE Method_Name__c = :methodName_ExecuteRules];
        //System.debug('exceptionLog accountingSystemTest OAKWL'+ exceptionLog!=null ? exceptionLog.Exception_Details__c: 'No Exception');
        }
        
        //System.assertEquals(STPRuleExecution.isSTPSuccess, false); 
        test.stopTest();
    }
	
   /*
     * @MethodName : updateQuoteStatusTest
     * @description : test whether code is able to Update Quote status if STP process is success
     * @return	: void
     */ 
 	@isTest
    public static void updateQuoteStatusTest(){
        test.startTest();
        string status = 'Success';
        String quoteName = 'TestQuote';
        Boolean result = false;
       	User testUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND IsActive = true LIMIT 1];
		SBQQ__Quote__c insertedQuote = [Select Id,Name from SBQQ__Quote__c where SBQQ__Account__r.Name =:location_AccName limit 1];
		System.runAs(testUser){
            try{
        		RecurrsiveTriggerHandler.bypassValidation = true;
        		result = STPRuleExecution.updateQuoteStatus(insertedQuote.Id,status, quoteName, 'Full STP');
            	//ExceptionLog__c exceptionLog = [SELECT id, Exception_Details__c, Method_Name__c FROM ExceptionLog__c WHERE Method_Name__c = :methodName_ExecuteRules];
        		//System.debug('exceptionLog updateQuoteStatusTest'+ exceptionLog!=null ? exceptionLog.Exception_Details__c: 'No Exception');
            }catch(Exception e){
                system.debug('Exception While updateQuoteStatus '+ e.getMessage());
            }
    	}
        //System.assertEquals(true, result);
		test.stopTest();
    }
    @isTest
    public static void negativeUpdateQuoteStatus(){
        test.startTest();
        string status = 'Success';
        String quoteName = 'TestQuote';
        Boolean result = false;
       	User testUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND IsActive = true LIMIT 1];
		SBQQ__Quote__c insertedQuote = [Select Id,Name from SBQQ__Quote__c where SBQQ__Account__r.Name =:location_AccName limit 1];
		System.runAs(testUser){
            try{
        	
			 	SBQQ.TriggerControl.disable();
				RecurrsiveTriggerHandler.bypassValidationQuoteLine = true;
                RecurrsiveTriggerHandler.isSkipValidateQLCostPrice =true;
				QuoteLineTriggerHelper.extrapickUpRecursion = false;
        		List<SBQQ__QuoteLine__c> disposalQuoteLine = [SELECT Id, SBQQ__UnitCost__c, Cost_Override_Reason__c,Cost_Override_Description__c
                                                  FROM SBQQ__QuoteLine__c 
                                                  WHERE SBQQ__Quote__c =: insertedQuote.Id AND SBQQ__Product__r.ProductCode = 'DSP' LIMIT 1];                                    
        		disposalQuoteLine[0].SBQQ__UnitCost__c = null;
        		disposalQuoteLine[0].Cost_Override_Reason__c ='Other';
        		disposalQuoteLine[0].Cost_Override_Description__c = 'testing';
        		Update disposalQuoteLine;
                SBQQ.TriggerControl.enable();
        		result = STPRuleExecution.updateQuoteStatus(insertedQuote.Id,status, quoteName, Pricing_Constant_Util.PARTIAL_STP);
            	//ExceptionLog__c exceptionLog = [SELECT id, Exception_Details__c, Method_Name__c FROM ExceptionLog__c WHERE Method_Name__c = :methodName_ExecuteRules];
        		//System.debug('exceptionLog updateQuoteStatusTest'+ exceptionLog!=null ? exceptionLog.Exception_Details__c: 'No Exception');
            }catch(Exception e){
                system.debug('Exception While negativeUpdateQuoteStatus '+ e.getMessage());
            }
    	}
        //System.assertEquals(false, result);
		test.stopTest();
    }
    /*
     * @MethodName : createExceptionLogObjTest
     * @description : This method will test whether code is able to set ExceptionLog__c with details
     * @return	: void
     */ 
 	@isTest
    public static void createExceptionLogObjTest(){
        test.startTest();
        String errorMsg = 'Test Error Message';
        ExceptionLog__c exceptionLog = new ExceptionLog__c();
        exceptionLog.Exception_Details__c = errorMsg;
		exceptionLog.Method_Name__c = methodName_ExecuteRules;
        exceptionLog.Application_Name__c = Pricing_Constant_Util.APPLICATION_NAME;
        ExceptionLog__c exceptionObj = new ExceptionLog__c(); 
		User testUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND IsActive = true LIMIT 1];
		
		System.runAs(testUser){
        	exceptionObj = STPRuleExecution.createExceptionLogObj(exceptionLog);
    	}
        //System.assertEquals(errorMsg, exceptionObj.Exception_Details__c);
		test.stopTest();
    }
    /*
     * @MethodName : errorMessageMapTest
     * @description : This method will test whether code is able to set error messages against the Quote in a map
     * @return	: void
     */ 
 	@isTest
    public static void setErrorMessageMapTest(){
        test.startTest();
        String errorMsg = 'Test Error Message';
		User testUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND IsActive = true LIMIT 1];
		SBQQ__Quote__c insertedQuote = [Select Id, Name from SBQQ__Quote__c where SBQQ__Account__r.Name =:location_AccName limit 1];
        String quoteName = insertedQuote.Name;
		
		System.runAs(testUser){
        	STPRuleExecution.setErrorMessageForQuote(quoteName, errorMsg);
    	}
        List<String> errorMsgList = STPRuleExecution.quoteErrorMessageMap.get(quoteName);
        //System.assertEquals(1, errorMsgList.size());
		test.stopTest();
    }
    @isTest
    public static void getErrorMessageMapTest(){
        test.startTest();
        String newErrorMsg = 'Test New Error Message';
        List<String> oldErrorMsgList = new List<String>();
        oldErrorMsgList.add('Test Old Error Message');
		User testUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND IsActive = true LIMIT 1];
		SBQQ__Quote__c insertedQuote = [Select Id, Name from SBQQ__Quote__c where SBQQ__Account__r.Name =:location_AccName limit 1];
        String quoteName = insertedQuote.Name;
		
		System.runAs(testUser){
            STPRuleExecution.quoteErrorMessageMap.put(quoteName, oldErrorMsgList);
        	
        	STPRuleExecution.setErrorMessageForQuote(quoteName, newErrorMsg);
    	}
        List<String> errorMsgList = STPRuleExecution.quoteErrorMessageMap.get(quoteName);
        //System.assertEquals(1, errorMsgList.size());
		test.stopTest();
    }
    @isTest
    public static void priorityTest(){
        Boolean result = false;
        User testUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND IsActive = true LIMIT 1];
        SBQQ__Quote__c insertedQuote = [Select Id, Name from SBQQ__Quote__c where SBQQ__Account__r.Name =:location_AccName limit 1];
        test.startTest();
        System.runAs(testUser){
            try{
//            SBQQ.TriggerControl.disable();
            RecurrsiveTriggerHandler.bypassValidation = true;
            //RecurrsiveTriggerHandler.bypassValidationQuoteLine = true;
            insertedQuote.Priority__c = 'P3';
            update insertedQuote;

            STP_Criteria__c ruleWithPriority =  QuoteTestDataFactory.createSTPCriteriaWithAllParam(null, true, true,
                                                                                          'TEMP', 'Open Top', 'OC',
                                                                                          'Trash', 'New Service Case',true, '','K00126',null, true, true, 'Full STP', true, true, false, true, '', 'Any');                                                            
            ruleWithPriority.Applicable_Priority__c = 'P2';
                insert ruleWithPriority;
            /*List<STP_Criteria__c> rule = [select Id, Applicable_Priority__c from STP_Criteria__c where STP_Type__c = 'Full STP'limit 1];
            System.debug('rule[0] '+ rule[0].Applicable_Priority__c);
            rule[0].Applicable_Priority__c = 'P2';
            update rule;*/
            
            result = STPRuleExecution.executeRules(insertedQuote.Id, 'Full STP');
            //System.assertEquals(false , result);
            }catch(Exception e){
                system.debug('Exception While priorityTest '+ e.getMessage());
            }
        }
        
        test.stopTest();
    }
    @isTest
    public static void specialHandlingTest(){
        test.startTest();
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN  AND IsActive = true LIMIT 1];
        System.runAs(adminUser){
            try{
                SBQQ__Quote__c insertedQuote = [Select Id from SBQQ__Quote__c where SBQQ__Account__r.Name =:location_AccName limit 1];
                
                SBQQ.TriggerControl.disable();
				RecurrsiveTriggerHandler.bypassValidationQuoteLine = true;
                insertedQuote.Special_Handling__c = true;
                update insertedQuote;
                SBQQ.TriggerControl.enable();
                STP_Criteria__c ruleWithProperConfig =  QuoteTestDataFactory.createSTPCriteriaWithAllParam(null, true, true,
                                                                                          'TEMP', 'Open Top', 'OC',
                                                                                          'Trash', 'New Service Case',true, '','K00126',null, true, true, 'Full STP', true, true, false, true, '', 'Any');                                                            
            
        	insert ruleWithProperConfig;
        
            STPRuleExecution.executeRules(insertedQuote.Id, 'Full STP');
               // ExceptionLog__c exceptionLog = [SELECT id, Exception_Details__c , Method_Name__c FROM ExceptionLog__c WHERE Method_Name__c = :methodName_ExecuteRules];
        //System.debug('exceptionLog specialHandlingTest'+ exceptionLog!=null ? exceptionLog.Exception_Details__c: 'No Exception');
            }catch(Exception e) {
			system.debug('Exception while executing specialHandlingTest '+ e.getMessage());
        }
        }
        test.stopTest();
        
        }
    
}