@isTest(seeAllData = false)
public class GetDetailsTest {
    
    private static final string SYS_ADMIN = 'System Administrator';
    private static final string SPECIAL_INS ='Test Special Instructions';
    private static final string CHANNEL_INFO ='Test Channel Instructions';
    private static final string OTHER ='Other';
    private static final string TEST_NAME ='Test';
    private static final string NUMBER_145 ='145';
    private static final string SLA = 'Test SLA Instructions';
    private static final String LOCATION = 'Location';
    private static final String CONTACT = 'Contact';
    private static final string COMMERCIAL = 'Commercial';
    private static final string SCHEDULED ='Scheduled';
    private static final string REPAIRS = 'Repairs';
    private static final string COMPACTOR = 'COMPACTOR';
    private static final string InActive_CORE = 'Inactive COMPACTOR';
    private static final string INTERRUPTION = 'Interruption';
    private static final string STOP_SERVICE = 'Stop Service';
    private static final string CAM = 'CAM';
    private static final string SERVICE_REQUEST_CASE = 'Service Request Case';
    private static final string ADD = 'Add';
    private static final string EQUIPMENT = 'Equipment';
    private static final string COMPACTOR1 = 'Compactor';
    private static final string REPAIR_CASE = 'Repair Case';
    private static final string OPERABLE = 'Operable';
    private static final string COMPACTOR_ACCESSORIES = 'Compactor Accessories';
    public static String customer_code = 'WAL'; 
    public static final string parent_AccName = 'Test Parent Account';
    public static final string thirdPartyparent_AccName = 'Test 3rd Party Parent Account';
    public static final string location_AccName = 'location account';
    public static final string thirdPartylocation_AccName = 'third Party location account';
    public static final string parentVendor_AccName = 'WMParent Vendor';
    public static final string parentVendor_AccNumber = '8';
    public static final string thirdPartyparentVendor_AccName = 'NonWMParent Vendor';
    public static final string thirdPartyparentVendor_AccNumber = 'NonWMParent Vendor';//11746'; 11746 threw some erro last time when i tried
    public static final string childVendor_AccName = 'WMchild vendor';
    public static final string thirdPartychildVendor_AccName = 'NonWMchild vendor';
    public static final string contact_lastName  = 'Quote contact for product trash';
    public static final string caseReason_Tempupload = 'Temp Upload';
    public static string override_products = 'Delivery;Container Service Charge';
    //WMI National Accounts
    public static string WMNAT = 'WMNAT';
    //Wasteless Environmental Services
    public static string OAKWL = 'OAKWL';
    public static final string Project_Code_Header = 'Project_Code_Header';
    public static final string Project_Code_Detail = 'Project_Code_Detail';
    public static final string headerRecType = Schema.SObjectType.Project_Code__c.getRecordTypeInfosByDeveloperName().get(Project_Code_Header).getRecordTypeId();
    public static final string detailRecType = Schema.SObjectType.Project_Code__c.getRecordTypeInfosByDeveloperName().get(Project_Code_Detail).getRecordTypeId();
   
    
    
    @testSetup static void setup() {
        CodeSwitchTestData.CodeSwitchData();
List<SBQQ__QuoteLine__c> childQuoteLineList = new List<SBQQ__QuoteLine__c>();
        List<Product2> productList = new List<Product2>();
        
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
            //Changes for SDT-39632
            CodeSwitchTestData.CodeSwitchData();
            
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
            
            //create contact for account which is primary contact in quote with product trash
            Contact quoteContact = QuoteTestDataFactory.createContactRecord(contact_lastName, parentAccount.Id, usr);
            QuoteTestDataFactory.insertContact(quoteContact);
            
            //creating case with record type new service
            Case caseForQuote = QuoteTestDataFactory.createCase(ConstantClass.RecordType_NewServiceCase,
                                                                ConstantClass.FieldType_NewService,
                                                                ConstantClass.FieldSubType_Temporary,caseReason_Tempupload,
                                                                parentAccount,quoteContact, locationAccount);
            caseList.add(caseForQuote);                                                  
            QuoteTestDataFactory.insertCases(caseList);
            
            
            //creating open top product
            Product2 openTop = QuoteTestDataFactory.createProductRecord(Pricing_Constant_Util.OPEN_TOP, 'Commercial', 'OT');
            productList.add(openTop);
            //creating open top product
            Product2 openTopRollOff = QuoteTestDataFactory.createProductRecord(Pricing_Constant_Util.OPEN_TOP, 'Rolloff', 'OT');
            productList.add(openTopRollOff);
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
            
            Product2 pickupservice = QuoteTestDataFactory.createProductRecord('Pickup','Services','PCK');
            productList.add(pickupservice);
            QuoteTestDataFactory.insertProducts(productList);
            
            //creating opportunity for new service case
            Opportunity oppForNewServiceCase = QuoteTestDataFactory.createOpportunity(1, ConstantClass.FieldStageName_Proposal, 
                                                                                      'OpportunityFornewServiceCase', caseForQuote.Id, 
                                                                                      ConstantClass.FieldSubType_Temporary, locationAccount.Id);  
            QuoteTestDataFactory.insertOpportunity(oppForNewServiceCase);
            
            
            //creating quote for new service case(for trash)
            SBQQ__Quote__c newServiceQuote = QuoteTestDataFactory.createQuoteRecords(oppForNewServiceCase, locationAccount, quoteContact);
            quoteList.add(newServiceQuote);
            
            RecurrsiveTriggerHandler.bypassValidation = true;
            QuoteTestDataFactory.insertQuotes(quoteList);
            
            //QuoteLine Creation
            //parent quoteline 'Open Top' for new service case
            
            //--trigger control is disabled in order to avoid SOQL query exception
            SBQQ.TriggerControl.disable();
            
            try 
            {
                SBQQ__QuoteLine__c quotelineForContainerOTRollOff = QuoteTestDataFactory.createQuoteLineRecords(newServiceQuote,openTopRollOff,
                                                                                                         'TEMP',1.00,'CLT','YRDS-4',
                                                                                                         'OC','M','1','PER',34.00,'DYS',
                                                                                                         'PER',null,'DYS','Do Not Override','NBG');
                quotelineForContainerOTRollOff.SBQQ__Bundle__c = true;
                quotelineForContainerOTRollOff.SBQQ__RequiredBy__c = null;
                quotelineForContainerOTRollOff.Vendor__c = childVendor.Id;
                quotelineForContainerOTRollOff.Schedule_Frequency__c = 'W';
                //quotelineForContainerOT.Pricing_Request__c = pricingRequest.Id;
                RecurrsiveTriggerHandler.bypassValidationQuoteLine = true;
                RecurrsiveTriggerHandler.isSkipValidateQLCostPrice =true;
                QuoteLineTriggerHelper.extrapickUpRecursion = false;
                RecurrsiveTriggerHandler.setIsRecurrsiveQuoteLine();
                QuoteTestDataFactory.insertQuoteLine(quotelineForContainerOTRollOff);
                
                
                //parent quoteline 'Open Top' for Rolloff 
                SBQQ__QuoteLine__c quotelineForContainerOTCommercial = QuoteTestDataFactory.createQuoteLineRecords(newServiceQuote,openTop,
                                                                                                               'TEMP',1.00,'CLT','YRDS-30',
                                                                                                               'OC','M','1','PER',34.00,'DYS',
                                                                                                               'PER',null,'DYS','Do Not Override','NBG');
                quotelineForContainerOTCommercial.SBQQ__Bundle__c = true;
                quotelineForContainerOTCommercial.SBQQ__RequiredBy__c = null;
                quotelineForContainerOTCommercial.Vendor__c = childVendor.Id;
                quotelineForContainerOTCommercial.Schedule_Frequency__c = 'W';
                RecurrsiveTriggerHandler.bypassValidationQuoteLine = true;
                
                QuoteTestDataFactory.insertQuoteLine(quotelineForContainerOTCommercial); 
                
                List<Asset> assets = new List<Asset>();
            Asset baseAsset = new Asset(
            Name = 'Test Asset',
            Occurs__c = '1',
            Frequency__c = 'Daily',
            Monday__c = true,
            Tuesday__c = true,
            Wednesday__c = true,
            Thursday__c = true,
            Friday__c = true,
            Saturday__c = false,
            Sunday__c = false,
            Acorn_SID__c  = '2977664'
        );
        Asset baseAsset1 = new Asset(
            Name = 'Test Asset',
            Occurs__c = '1',
            Frequency__c = 'Weekly',
            Monday__c = true,
            Tuesday__c = true,
            Wednesday__c = true,
            Thursday__c = true,
            Friday__c = true,
            Saturday__c = false,
            Sunday__c = false,
            Acorn_SID__c  = '2977664'
        );
        assets.add(baseAsset);
        assets.add(baseAsset1);   
        insert assets;
                
                //Open Top Child Quote Line - commercial  --- Start
                //quoteline for trash product
                SBQQ__QuoteLine__c qlTrashWasteCategory = QuoteTestDataFactory.createQuoteLineRecords(newServiceQuote,TrashWasteCategory,'TEMP',1.00,'CLT','YRDS-30',
                                                                                                      'OC','M','1','PER',34.00,'DYS','PER',null,'DYS',
                                                                                                      'Do Not Override','NBG');
                qlTrashWasteCategory.SBQQ__RequiredBy__c = quotelineForContainerOTRollOff.Id;
                qlTrashWasteCategory.SBQQ__UnitCost__c = 2;
                qlTrashWasteCategory.Vendor__c = childVendor.Id;
                qlTrashWasteCategory.Schedule_Frequency__c = 'W';
                qlTrashWasteCategory.AssetId__c = assets[0].Id;
                childQuoteLineList.add(qlTrashWasteCategory);
                
            //quoteline for haul product
                SBQQ__QuoteLine__c qlHaul = QuoteTestDataFactory.createQuoteLineRecords(newServiceQuote,haulService,'TEMP',1.00,'CLT',
                                                                                        'YRDS-30','OC','M','1','PER',34.00,'DYS','PER',
                                                                                        563.47,'DYS','Do Not Override','NBG');
                qlHaul.SBQQ__RequiredBy__c = quotelineForContainerOTRollOff.Id;
                qlHaul.Vendor__c = childVendor.Id;
                childQuoteLineList.add(qlHaul);
                
                //quoteline for disposal product
                SBQQ__QuoteLine__c qlDisposal = QuoteTestDataFactory.createQuoteLineRecords(newServiceQuote,DisposalService,
                                                                                            'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',
                                                                                            34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
                qlDisposal.SBQQ__RequiredBy__c = quotelineForContainerOTRollOff.Id;
                qlDisposal.Vendor__c = childVendor.Id;
                qlDisposal.SBQQ__UnitCost__c = 2;
                childQuoteLineList.add(qlDisposal);
                
            //quoteline for container service charge
                SBQQ__QuoteLine__c qlContainerService = QuoteTestDataFactory.createQuoteLineRecords(newServiceQuote,ContainerServiceCharge,
                                                                                                    'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',
                                                                                                    34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
                qlContainerService.SBQQ__RequiredBy__c = quotelineForContainerOTRollOff.Id;
                qlContainerService.Vendor__c = childVendor.Id;
                qlContainerService.SBQQ__UnitCost__c = 2;
                childQuoteLineList.add(qlContainerService);
                
                //Ql Delivery 
                /*SBQQ__QuoteLine__c qlDelivery = QuoteTestDataFactory.createQuoteLineRecords(newServiceQuote,deliveryService,
                                                                                            'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',
                                                                                            34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
                qlDelivery.SBQQ__RequiredBy__c = quotelineForContainerOTRollOff.Id;
                qlDelivery.Vendor__c = childVendor.Id;
                qlDelivery.SBQQ__UnitCost__c = 2;
                childQuoteLineList.add(qlDelivery);*/
                
                RecurrsiveTriggerHandler.bypassValidationQuoteLine = true;

                
                //Open Top Child Quote Line  --- End
                
                //Open Top Child Quote Line - Commercial  --- Start
                
                //Ql Delivery 
                /*SBQQ__QuoteLine__c qlDeliveryCO = QuoteTestDataFactory.createQuoteLineRecords(newServiceQuote,pickupservice,
                                                                                            'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',
                                                                                            34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
                qlDeliveryCO.SBQQ__RequiredBy__c = quotelineForContainerOTCommercial.Id;
                qlDeliveryCO.Vendor__c = childVendor.Id;
                qlDeliveryCO.SBQQ__UnitCost__c = 2;
                childQuoteLineList.add(qlDeliveryCO);*/
                
                //Ql Pickup 
                SBQQ__QuoteLine__c qlPickup = QuoteTestDataFactory.createQuoteLineRecords(newServiceQuote,pickupservice,
                                                                                            'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',
                                                                                            34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
                qlPickup.SBQQ__RequiredBy__c = quotelineForContainerOTCommercial.Id;
                qlPickup.Vendor__c = childVendor.Id;
                qlPickup.SBQQ__UnitCost__c = 2;
                childQuoteLineList.add(qlPickup);
                
                RecurrsiveTriggerHandler.bypassValidationQuoteLine = true;
                QuoteTestDataFactory.insertQuoteLines(childQuoteLineList);
                
                //Open Top Child Quote Line - Commercial  --- End

                
                //quoteline with product family as waste stream has parent quoteline as trash product with family Waste Category
                //inserting quoteline with waste stream product family
                test.stopTest();
            }
            finally {
                SBQQ.TriggerControl.enable();
            } 
    }
    
}  
        @isTest static void getQuoteFieldsTest(){
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
 
        system.runAs(currentuser){
        SBQQ__Quote__c quoteData = new SBQQ__Quote__c();
        quoteData = [SELECT Id, SBQQ__Account__r.AccountNumber,SBQQ__Account__r.ParentId,  SBQQ__Account__r.Id, SBQQ__ShippingStreet__c, SBQQ__ShippingCity__c, SBQQ__ShippingCountry__c, SBQQ__ShippingState__c, SBQQ__ShippingPostalCode__c ,SBQQ__Status__c
                            FROM SBQQ__Quote__c limit 1];
            quoteData.SBQQ__ShippingCity__c = 'Constant';
           
            Test.startTest();
            Database.update(quoteData); 
            GetDetails gd =new GetDetails();
            gd.objQuote =quoteData;
            gd.getQuoteFields();
            gd.getWrapperData();
            gd.getDateFormat();
            gd.getConfigData();
            gd.getuser();
            gd.getMaterialCode();	//PK
            gd.getServiceSchedule();	//PK
            Test.stopTest();
            }   
        }

private static final string EOM_EVENT = 'EV';
    private static final string OCCURENCE_TYPE_ONCALL = 'OC';
    private static final string SCHEDULED_TYPE = 'SCH';
    @isTest static void checkAssetQuoteTest() {
        
        SBQQ__Quote__c testQuote = [SELECT Id, Case__c,SBQQ__Type__c,SBQQ__Opportunity2__r.Case__c, SBQQ__Account__r.Parent.AccountNumber,SBQQ__StartDate__c
        FROM SBQQ__Quote__c WHERE SBQQ__Status__c = 'Draft' AND Case__c != null ORDER BY CreatedDate DESC LIMIT 1];
        if(SBQQ.TriggerControl.isEnabled()){
            SBQQ.TriggerControl.disable();
        }
        testQuote.SBQQ__Type__c=Constant_Util.KEYWORD_EXCEPTION;
        //update testQuote;
        List<SBQQ__QuoteLine__c> quoteLines = [SELECT Id, name,Occurrence_Type__c, PriceUOM__c, Cost_Unit_of_Measure__c,SBQQ__Quote__r.SBQQ__Type__c
                                              FROM SBQQ__QuoteLine__c
                                              WHERE SBQQ__Quote__c=:testQuote.id and Occurrence_Type__c='W'
                                              ORDER BY SBQQ__Number__c DESC limit 1];
        system.debug('quoteLines==>'+quoteLines);
        test.startTest();
        List<SBQQ__QuoteLine__c> quoteLinesToTest = new List<SBQQ__QuoteLine__c>();
        for(SBQQ__QuoteLine__c ql : quoteLines){
            ql.PriceUOM__c=EOM_EVENT;
                ql.Cost_Unit_of_Measure__c=EOM_EVENT;
            quoteLinesToTest.add(ql);
        }
        update quoteLinesToTest;
        system.debug('quoteLines==>'+quoteLines);
        try {
            for(SBQQ__QuoteLine__c ql : quoteLines){
            ql.Occurrence_Type__c = 'W';
        }
            update quoteLines;
        } 
        catch (exception e) {
            throw (e);
        }
        
        system.debug('quoteLines==>'+quoteLines);
        test.stopTest();
        if(quoteLines!=null){
            for(SBQQ__QuoteLine__c ql : quoteLines){
                /*System.assertNotEquals(ql.PriceUOM__c, EOM_EVENT);
                System.assertNotEquals(ql.Cost_Unit_of_Measure__c, EOM_EVENT);
                System.assertEquals(ql.PriceUOM__c, Constant_Util.EMPTY_STRING);
                System.assertEquals(ql.Cost_Unit_of_Measure__c, Constant_Util.EMPTY_STRING);*/
            }
            }   
        }    
 /*
* @Owner : TCS-Seema Dhikale
* @Story : 44716
* @MethodName    checkAlternateServiceTest
* @Coverage : GetDetails.getConfigData()
*/
   
@isTest static void checkAlternateServiceTest() {
    SBQQ__Quote__c testQuote = [SELECT Id, Case__c,SBQQ__Type__c,SBQQ__Opportunity2__r.Case__c, SBQQ__Account__r.Parent.AccountNumber,SBQQ__StartDate__c
    FROM SBQQ__Quote__c WHERE SBQQ__Status__c = 'Draft' AND Case__c != null ORDER BY CreatedDate DESC LIMIT 1];
    
    SBQQ__QuoteLine__c quoteLinesInDraftStatus = [select Id,SBQQ__Quantity__c,toLabel(Equipment_Size__c),SBQQ__Product__r.Name,SBQQ__ProductName__c,toLabel(Occurrence_Type__c),
                     toLabel(Duration__c),toLabel(Schedule_Frequency__c),Service_Schedule__c,Final_Frequency__c,Frequency_Interval__c,Service_Days__c
                     FROM SBQQ__QuoteLine__c
                     WHERE SBQQ__Quote__c =: testQuote.id and SBQQ__RequiredBy__c = null][0];
        Integer draftQuantity = Integer.valueOf(quoteLinesInDraftStatus.SBQQ__Quantity__c);
        String draftEquipmentSize = quoteLinesInDraftStatus.Equipment_Size__c;
        String draftProductName = quoteLinesInDraftStatus.SBQQ__ProductName__c;
        String draftOccurenceType = quoteLinesInDraftStatus.Occurrence_Type__c;
        String draftDuration = quoteLinesInDraftStatus.Duration__c;
        String draftScheduleFrequency = GetDetails.getServiceSchedule(quoteLinesInDraftStatus);
    if(SBQQ.TriggerControl.isEnabled()){
        SBQQ.TriggerControl.disable();
    }

    
    test.startTest();
    GetDetails gd =new GetDetails();
        gd.objQuote =testQuote;
        gd.getQuoteFields();
        gd.getWrapperData();
        gd.getDateFormat();
        gd.getConfigData();
/*    System.assertEquals(draftQuantity, gd.configMap.get(quoteLinesInDraftStatus.id).draftQuantity);
    System.assertEquals(draftEquipmentSize, gd.configMap.get(quoteLinesInDraftStatus.id).draftEquipmentSize);
    System.assertEquals(draftProductName, gd.configMap.get(quoteLinesInDraftStatus.id).draftProductName);
    System.assertEquals(draftOccurenceType, gd.configMap.get(quoteLinesInDraftStatus.id).draftOccurenceType);
    System.assertEquals(draftDuration, gd.configMap.get(quoteLinesInDraftStatus.id).draftDuration);
    System.assertEquals(draftScheduleFrequency, gd.configMap.get(quoteLinesInDraftStatus.id).draftScheduleFrequency);
  */  test.stopTest();
} 
    @isTest
    static void testgetServiceScheduleAsset(){
        List<Asset> assets = [SELECT Id, Occurrence_Type__c, Frequency__c, Occurs__c, Monday__c,
                              Tuesday__c, Wednesday__c, Thursday__c, Friday__c, Saturday__c, Sunday__c FROM Asset];
        
        GetDetails.getServiceScheduleAsset(assets[0]);
        
        Asset a = [SELECT Id, Occurrence_Type__c, Frequency__c, Occurs__c, Monday__c,
                              Tuesday__c, Wednesday__c, Thursday__c, Friday__c, Saturday__c, Sunday__c FROM Asset WHERE Frequency__c = 'Weekly' LIMIT 1];
        GetDetails.getServiceScheduleAsset(a);
    }
}