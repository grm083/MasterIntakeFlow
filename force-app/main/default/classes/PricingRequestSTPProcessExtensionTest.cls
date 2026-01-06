/*
 * Code Coverage - Run along with PricingRequestSTPProcessTest
 * Author - Digdershika Ojha
 * Date - 19/03/2024
 */
@isTest(seeAllData=false)
public class PricingRequestSTPProcessExtensionTest {
    public static final string SYS_ADMIN = 'System Administrator';
    public static final string PARENT_ACCNAME = 'Test Parent Account';
    public static final String CUSTOMER_CODE = '10';
    public static final string CLIENT = 'Client';
    public static final string LOC_ACCNAME = 'location account';
    public static final string RECTYPE_VENDOR = 'Vendor';
    public static final string PARENTVENDOR_ACCNAME = 'WMParent Vendor';
    public static final string ACTIVE = 'Active';
    public static final string PARENTVENDOR_ACCNUM = '8';
    public static final string CHILDVENDOR_ACCNAME = 'WMchild vendor';
    public static final string CONTACT_LASTNAME = 'Quote contact';
    public static final string NEWSERVICE_CASE = 'New Service Case';
    public static final string NEWSERVICE = 'New Service';
    public static final string TEMPORARY = 'Temporary';
    public static final string TEMP_UPLOAD = 'Temp Upload';
    public static final string PROPOSAL = 'Proposal';
    public static final string COMMERCIAL = 'Commercial';
    public static final String JSON_VALID_COMMERCIAL_DATA = '{"data":{"priceQuoteIdentifier":"Q11839","costSource":"WM (SBS|CO|DMP|4FY|B02433|20211019|030423|5192)","contractType":"Open Market","lineOfBusiness":"Commercial","supplierCode":"12603|214136|2620","supplierName":"WMI - A FIORE & SON OF NEWARK|WMI OF NJ, ELIZABETH|WM - NJ-NORTH - 2433","customerCode":"HMD","customerName":"The Home Depot","locationCode":"HMD005826","wasteStreamCode":"REC","wasteStreamName":"Recycling","equipmentCode":"4FY","equipmentName":"4 Yard FEL Recycling","equipmentUOM":"Monthly","materialCode":"C","materialName":"Cardboard - OCC","equipmentSizeCode":"YRDS-4","equipmentSizeName":"4 Yards","overridableEquipmentSizeCode":null,"overridableEquipmentSizeName":null,"zoneCode":"GIS513947","zoneName":"UCFLRY","disposalFacilityType":"S02938_MRF","disposalFacilityName":"[B02433] [Recycle_SSRY_CO] Julia Street Recycling","feeComment": null,"isCostOnly": false,"commercial":{"pricingMethodCode":"2.0","pricingMethodCodeDescription":"Cost Plus","cost":32.28,"price":37.12,"equipmentLoadingMinutes":null,"equipmentAdditionalLoadingMinutes":null,"estimatedWeightPerYard":30,"equipmentVolume":4,"extraPickupCost":null,"extraPickupPrice":null},"rollOff":null,"wmMetaData":{"businessUnit":"B02433","masLibrary":"152A_ELC","francisePricingLink":"","greenPagesLink":"","marketArea":"WM of Greater Mid Atlantic"},"tpMetaData":null,"serviceCharges":[{"code":"FU_C_PERM_OPEN","name":"Fuel Fee","componentTypeCode":"ENS","componentTypeName":"Energy Surcharge","actionCode":"AL","actionName":"Allow","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly"},{"code":"ENV_C_PERM_OPEN","name":"Environmental Fee","componentTypeCode":"ENV_FEE","componentTypeName":"Environmental Fee","actionCode":"EX","actionName":"Exclude","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly"},{"code":"RCR_C_PERM_OPEN","name":"Regulatory Cost Recovery","componentTypeCode":"UNK","componentTypeName":"Unknown","actionCode":"EX","actionName":"Exclude","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly"},{"code":"CSC_C_PERM_OPEN","name":"Container Service Charge","componentTypeCode":"UNK","componentTypeName":"Unknown","actionCode":"MR","actionName":"Manual Review","cost":null,"costValueType":null,"costUOM":null,"price":null,"priceValueType":null,"priceUOM":null},{"code":"D_C_PERM_OPEN","name":"Delivery","componentTypeCode":"UNK","componentTypeName":"Unknown","actionCode":"ADJ","actionName":"Adjust","cost":100,"costValueType":"Amount","costUOM":null,"price":115,"priceValueType":"Amount","priceUOM":null}]},"problem":null}';
    public static final String AAV_API_REQUEST_OUTPUT = '{"data": {"requestedDate": "2023-09-04","lineOfBusiness": "Roll Off","customerCode": "HMD","customerName": "The Home Depot","locationCode": "HMD006959","materialCode": "T","materialName": "Trash","countryCode": "USA","suppliers": [{"availabilitySource": "WM","supplierCode": null,"supplierName": null,"contractType": "Competitor","wasteStreamCode": "MSW","wasteStreamName": "Municipal Solid Waste","zoneCode": "GIS624853","zoneName": "OAKWL Franchise - Bainbridge - CM MSW","wmMetaData": {"marketAreaCode": "K00126","marketAreaName": "WM of South Atlantic","facilityId": "GA0075","facilityName": "Albany Hauling","siteId": "S10284","siteName": "Albany Hauling"},"tpMetaData": null,"deliveryDays": null,"serviceDays": null,"deliveries": null,"outages": null,"messages": [{"code": "ER400","description": "WM Schedule information not available due to Competitor / Franchise Contract Type"}]}],"messages": []},"problem": null}';
    public static final String AVAILABILITY_FLAG = 'WM Availability Confirmed';
    public static final String MODELED = 'Modeled';
    public static final String COST_PLUS = 'Cost Plus';
    public static final String STANDARD_PRICING = 'Standard Pricing';
    @testSetup 
    static void setup(){
        Profile adminProfile = TestDataFactory.getProfile(SYS_ADMIN);
        User adminUser = TestDataFactory.createUser(adminProfile);
        Database.insert(adminUser);
        
        //Changes for SDT-39632
        CodeSwitchTestData.CodeSwitchData();
        
        System.runAs(adminUser){
            //Create Parent Account WM
            List<Account> parentAccList = new List<Account>();            
            Account parentAccount = QuoteTestDataFactory.createParentAccountRecord(PARENT_ACCNAME,CUSTOMER_CODE, 
                                                                                   CLIENT, adminUser);
            parentAccount.Accounting_System__c = 'WMNAT';            
            parentAccList.add(parentAccount);
            Insert parentAccList;
            
            //create location account for WM
            List<Account> locationAccList = new List<Account>();            
            Account locationAccount = QuoteTestDataFactory.createLocationAccount(LOC_ACCNAME, parentAccount.Id, adminUser);
            locationAccList.add(locationAccount);
            Insert locationAccList;
            
            //Create vendor account for WM
            Id vendorRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(RECTYPE_VENDOR).getRecordTypeId();
            List<Account> parentVendorList = new List<Account>();
            Account parentVendor = new Account(Name = PARENTVENDOR_ACCNAME, RecordTypeId = vendorRecordtypeId,
                                               Status__c = ACTIVE, AccountNumber = PARENTVENDOR_ACCNUM);
            parentVendorList.add(parentVendor);
            Insert parentVendorList;
            
            //Create child vendor account
            List<Account> childVendorList = new List<Account>();
            Account childVendor = QuoteTestDataFactory.createVendorAccountwithParent(CHILDVENDOR_ACCNAME, parentVendor.Id, adminUser);
            childVendor.Status__c = ACTIVE;
            childVendorList.add(childVendor);
            Insert childVendorList;
            
            //create contact for account which is primary contact in quote for WM
            List<Contact> contactList = new List<Contact>();
            Contact quoteContact = QuoteTestDataFactory.createContactRecord(CONTACT_LASTNAME, parentAccount.Id, adminUser);
            contactList.add(quoteContact);
            Insert contactList;
            
            //creating case for WM
            List<Case> caseListForQuote = new List<Case>();
            Case caseForQuote = QuoteTestDataFactory.createCase(NEWSERVICE_CASE,NEWSERVICE,TEMPORARY, TEMP_UPLOAD, parentAccount, quoteContact, locationAccount);
            caseListForQuote.add(caseForQuote);
            Insert caseListForQuote;
            
            //create opportunity
            List<Opportunity> opportunityList = new List<Opportunity>();
            Opportunity oppForNewServiceCase = QuoteTestDataFactory.createOpportunity(1, PROPOSAL, 
                                                                                      'OpportunityFornewServiceCase', caseForQuote.Id, 
                                                                                      TEMPORARY, locationAccount.Id);  
            opportunityList.add(oppForNewServiceCase);
            Insert opportunityList;
            
            List<SBQQ__Quote__c> quoteListForTesting = new List<SBQQ__Quote__c>();
            //creating quote for new service case for WM
            SBQQ__Quote__c quoteForDMP = QuoteTestDataFactory.createQuoteRecords(oppForNewServiceCase, locationAccount, quoteContact);
            quoteListForTesting.add(quoteForDMP);
            Insert quoteListForTesting;
            
            SBQQ.TriggerControl.disable();
            RecurrsiveTriggerHandler.bypassValidation = true;
            SBQQ.TriggerControl.enable();
            
            //create products
            List<Product2> productList = new List<Product2>();
            Product2 prodDMP = TestDataFactory.createProduct('Dumpster','Commercial', 'DMP');
            prodDMP.Is_Pricing_Eligible__c = true;
            productList.add(prodDMP);
            
            Product2 wasteCategory = QuoteTestDataFactory.createProductRecord('Trash','Waste Category','DMPT');
            productList.add(wasteCategory);
            
            Product2 wasteStream = QuoteTestDataFactory.createProductRecord('Trash','Waste Stream','T');
            productList.add(wasteStream);
            
            Product2 prodPCK = QuoteTestDataFactory.createProductRecord('Pickup',COMMERCIAL,'PCK');
            productList.add(prodPCK);
            
            Product2 prodExtraPCK = QuoteTestDataFactory.createProductRecord('Extra Pickup','Services','PCK');
            productList.add(prodExtraPCK);
            
            Product2 prodDLV = QuoteTestDataFactory.createProductRecord('Delivery','Rolloff','DLV');
            productList.add(prodDLV);
            Insert productList;
            
            SBQQ.TriggerControl.disable();
            RecurrsiveTriggerHandler.bypassValidationQuoteLine = true;
            RecurrsiveTriggerHandler.isSkipValidateQLCostPrice =true;
            RecurrsiveTriggerHandler.setIsRecurrsiveQuoteLine();
            
            //create pricing request for WM
            List<Pricing_Request__c> pricingRequestList = new List<Pricing_Request__c>();
            Pricing_Request__c pricingRequest = TestDataFactory.createPricingRequestRecord(caseForQuote, parentAccount, locationAccount,
                                                                                           COMMERCIAL, 'AM', '', 
                                                                                           JSON_VALID_COMMERCIAL_DATA, adminUser);
            pricingRequest.zone_Type__c = 'Open Market';
            RecurrsiveTriggerHandler.invokeValidationforPricing = false;
            //pricingRequest.Vendor_Code__c = '2509|3265|5284|708';
            pricingRequest.Vendor_Code__c = childVendor.AccountNumber;
            pricingRequest.Customer_Price_Type__c = STANDARD_PRICING;
            //pricingRequest.Pricing_Request__c = true;
            pricingRequestList.add(pricingRequest);
            Insert pricingRequestList;
            
            //create parent quoteline
            List<SBQQ__QuoteLine__c> parentQl = new List<SBQQ__QuoteLine__c>();
            SBQQ__QuoteLine__c qlDMP = QuoteTestDataFactory.createQuoteLineRecords(quoteForDMP,prodDMP,
                                                                                                         'TEMP',1.00,'CLT','YRDS-30',
                                                                                                         'OC','M','1','PER',34.00,'DYS',
                                                                                                         'PER',null,'DYS','Do Not Override','NBG');
            qlDMP.SBQQ__Bundle__c = true;
            qlDMP.SBQQ__RequiredBy__c = null;
            qlDMP.Vendor__c = childVendor.Id;
            qlDMP.Pricing_Request__c = pricingRequest.Id;
            qlDMP.Availability_Flag__c= AVAILABILITY_FLAG;
            qlDMP.SBQQ__StartDate__c = Date.Today().addDays(10);
			qlDMP.AAV_Requested_AdditionalServicesAccessor__c = 'Requested Additional Services & Accessories' ; 
            qlDMP.AAV_Delivery_Availability__c = 'Selected Delivery is as per WM Availability, selected date is beyond SLA days but within 30 days	';
            
            qlDMP.AAV_Service_Availability__c = 'Selected Service is as per WM Availability';
            qlDMP.AAV_Priority__c = 'P3';
            
            parentQl.add(qlDMP);            
            Insert parentQl;
            
            //create asset Availablity For WM
            List<AAV_Asset_Availability__c> availabilityList = new List<AAV_Asset_Availability__c>();
            AAV_Asset_Availability__c aavObj = new AAV_Asset_Availability__c();
            aavObj.AAV_Location__c = locationAccount.Id;
            aavObj.AAV_APIRequestOutput__c = AAV_API_REQUEST_OUTPUT;
            aavObj.AAV_Quote_Line__c = qlDMP.Id;
            availabilityList.add(aavObj);
            
            Insert availabilityList;
            
            //create waste category QuoteLine
            List<SBQQ__QuoteLine__c> wasteCategoryQlList = new List<SBQQ__QuoteLine__c>();
            SBQQ__QuoteLine__c qlWasteCategory = QuoteTestDataFactory.createQuoteLineRecords(quoteForDMP,wasteCategory,'TEMP',1.00,'CLT','YRDS-30',
                                                                                                      'OC','M','1','PER',34.00,'DYS','PER',null,'DYS',
                                                                                                      'Do Not Override','NBG');
            qlWasteCategory.SBQQ__RequiredBy__c = qlDMP.Id;
            qlWasteCategory.Vendor__c = childVendor.Id;
            wasteCategoryQlList.add(qlWasteCategory);
            Insert wasteCategoryQlList;
            
            //create waste stream QuoteLine
            List<SBQQ__QuoteLine__c> wasteStreamQlList = new List<SBQQ__QuoteLine__c>();
            SBQQ__QuoteLine__c qlWasteStream = QuoteTestDataFactory.createQuoteLineRecords(quoteForDMP,wasteStream,'TEMP',
                                                                                                              1.00,'CLT','YRDS-30','OC','M','1','PER'
                                                                                                              ,34.00,'DYS','PER',null,'DYS',
                                                                                                              'Do Not Override','NBG');
            qlWasteStream.SBQQ__RequiredBy__c = qlWasteCategory.Id;
            qlWasteStream.Vendor__c = childVendor.Id;
            wasteStreamQlList.add(qlWasteStream);
            Insert wasteStreamQlList;
            
            //create child quoteLines
            List<SBQQ__QuoteLine__c> childQlList = new List<SBQQ__QuoteLine__c>();
            
            SBQQ__QuoteLine__c qlDelivery = QuoteTestDataFactory.createQuoteLineRecords(quoteForDMP,prodDLV,
                                                                                            'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',
                                                                                            0,'EV','PER',null,'EV','Do Not Override','NBG');
            qlDelivery.SBQQ__RequiredBy__c = qlDMP.Id;
            qlDelivery.Vendor__c = childVendor.Id;
            qlDelivery.SBQQ__UnitCost__c = 0;
            qlDelivery.Cost_Override_Reason__c ='Other';
            qlDelivery.Cost_Override_Description__c = 'testing';            
            childQlList.add(qlDelivery);
                                    
            SBQQ__QuoteLine__c qlExtraPck = QuoteTestDataFactory.createQuoteLineRecords(quoteForDMP,prodExtraPCK,
                                                                                            'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',
                                                                                            0,'EV','PER',null,'EV','Do Not Override','NBG');
            qlExtraPck.SBQQ__RequiredBy__c = qlDMP.Id;
            qlExtraPck.Vendor__c = childVendor.Id;
            //qlExtraPck.SBQQ__UnitCost__c = null;
            qlExtraPck.Cost_Override_Reason__c ='Other';
            qlExtraPck.Cost_Override_Description__c = 'testing';
            qlExtraPck.SBQQ__StartDate__c = Date.Today().addDays(10);
			qlExtraPck.AAV_Requested_AdditionalServicesAccessor__c = 'Requested Additional Services & Accessories' ;           
            qlExtraPck.AAV_Delivery_Availability__c = 'Selected Delivery is as per WM Availability, selected date is beyond SLA days but within 30 days	';
            qlExtraPck.AAV_Priority__c = 'P3';
            childQlList.add(qlExtraPck);
            
            SBQQ__QuoteLine__c qlPck = QuoteTestDataFactory.createQuoteLineRecords(quoteForDMP,prodPCK,
                                                                                            'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',
                                                                                            0,'EV','PER',null,'EV','Do Not Override','NBG');
            qlPck.SBQQ__RequiredBy__c = qlDMP.Id;
            qlPck.Vendor__c = childVendor.Id;
            qlPck.SBQQ__UnitCost__c = 0;
            qlPck.Cost_Override_Reason__c ='Other';
            qlPck.Cost_Override_Description__c = 'testing';
			qlPck.Pricing_API_Method__c = COST_PLUS;			           
            childQlList.add(qlPck);
            
            Insert childQlList;
            pricingRequest.Quote__c = quoteForDMP.id;
            pricingRequest.Quote_Line_Bundle__c = qlDMP.id;
            update pricingRequest;
            SBQQ.TriggerControl.enable();
            
        }
    }
    @isTest
    public static void testQuoteLineProcess(){
        test.startTest();
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN  AND IsActive = true LIMIT 1];
        System.runAs(adminUser){
            try{
                SBQQ__Quote__c insertedQuote = [Select Id from SBQQ__Quote__c where SBQQ__Account__r.Name =: LOC_ACCNAME limit 1];
                if(insertedQuote != null && insertedQuote.Id != null){
                	PricingRequestSTPProcess.quoteLineProcess(insertedQuote.Id);
                }
            }catch(Exception e) {
        	}
        }
        test.stopTest();
    }
    @isTest
    public static void testGetPricingDetails(){
        test.startTest();
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN  AND IsActive = true LIMIT 1];
        System.runAs(adminUser){
            try{
                SBQQ__Quote__c insertedQuote = [Select Id from SBQQ__Quote__c where SBQQ__Account__r.Name =: LOC_ACCNAME limit 1];
                
                if(insertedQuote != null && insertedQuote.Id != null){
                	PricingRequestSTPProcess.getPricingDetails(insertedQuote.Id);
                }
            }catch(Exception e) {
        	}
        }
        test.stopTest();
    }
    @isTest
    public static void testNegativeGetPricingDetails(){
        test.startTest();
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN  AND IsActive = true LIMIT 1];
        System.runAs(adminUser){
            try{
                SBQQ__Quote__c insertedQuote = [Select Id from SBQQ__Quote__c where SBQQ__Account__r.Name =: LOC_ACCNAME limit 1];
                List<SBQQ__QuoteLine__c> qlDMP = [Select id from SBQQ__QuoteLine__c where SBQQ__Quote__r.Id =: insertedQuote.Id  and SBQQ__Product__r.ProductCode = 'DMP' limit 1 ];
                if(qlDMP.size()>0){
                    
                    Pricing_Request__c pr = [Select Id, IsCaseError__c from Pricing_Request__c where Quote_Line_Bundle__c =: qlDMP[0].id];
                    RecurrsiveTriggerHandler.invokeValidationforPricing = false;
                    if(pr!=null){
                    	pr.IsCaseError__c = true;
                    	update pr;
                    }
                }
                if(insertedQuote != null && insertedQuote.Id != null){
                	PricingRequestSTPProcess.getPricingDetails(insertedQuote.Id);
                }
            }catch(Exception e) {
        	}
        }
        test.stopTest();
    }
    @isTest
    public static void testApiReqGetPricingDetails(){
        test.startTest();
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN  AND IsActive = true LIMIT 1];
        System.runAs(adminUser){
            try{
                SBQQ__Quote__c insertedQuote = [Select Id from SBQQ__Quote__c where SBQQ__Account__r.Name =: LOC_ACCNAME limit 1];
                List<SBQQ__QuoteLine__c> qlDMP = [Select id from SBQQ__QuoteLine__c where SBQQ__Quote__r.Id =: insertedQuote.Id  and SBQQ__Product__r.ProductCode = 'DMP' limit 1 ];
                if(qlDMP.size()>0){
                    
                    Pricing_Request__c pr = [Select Id, APIRequestOutput__c from Pricing_Request__c where Quote_Line_Bundle__c =: qlDMP[0].id];
                    RecurrsiveTriggerHandler.invokeValidationforPricing = false;
                    if(pr!=null){
                    	pr.APIRequestOutput__c = null;
                    	update pr;
                    }
                }
                if(insertedQuote != null && insertedQuote.Id != null){
                	PricingRequestSTPProcess.getPricingDetails(insertedQuote.Id);
                }
            }catch(Exception e) {
        	}
        }
        test.stopTest();
    }
    @isTest
    public static void testApiResultGetPricingDetails(){
        test.startTest();
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN  AND IsActive = true LIMIT 1];
        System.runAs(adminUser){
            try{
                SBQQ__Quote__c insertedQuote = [Select Id from SBQQ__Quote__c where SBQQ__Account__r.Name =: LOC_ACCNAME limit 1];
                List<SBQQ__QuoteLine__c> qlDMP = [Select id from SBQQ__QuoteLine__c where SBQQ__Quote__r.Id =: insertedQuote.Id  and SBQQ__Product__r.ProductCode = 'DMP' limit 1 ];
                if(qlDMP.size()>0){
                    
                    Pricing_Request__c pr = [Select Id, isAPIResult__c from Pricing_Request__c where Quote_Line_Bundle__c =: qlDMP[0].id];
                    RecurrsiveTriggerHandler.invokeValidationforPricing = false;
                    if(pr!=null){
                    	pr.isAPIResult__c = false;
                    	update pr;
                    }
                }
                if(insertedQuote != null && insertedQuote.Id != null){
                	PricingRequestSTPProcess.getPricingDetails(insertedQuote.Id);
                }
            }catch(Exception e) {
        	}
        }
        test.stopTest();
    }
    @isTest
    public static void testSaveProcuredStatus(){
        test.startTest();
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN  AND IsActive = true LIMIT 1];
        System.runAs(adminUser){
            try{
                SBQQ__Quote__c insertedQuote = [Select Id from SBQQ__Quote__c where SBQQ__Account__r.Name =: LOC_ACCNAME limit 1];
                if(insertedQuote != null && insertedQuote.Id != null){
                	PricingRequestSTPProcess.saveProcuredStatus(insertedQuote.Id);
                }
            }catch(Exception e) {
        	}
        }
        test.stopTest();
    }
    
    @isTest
    public static void testModeledSaveProcuredStatus(){
        test.startTest();
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN  AND IsActive = true LIMIT 1];
        System.runAs(adminUser){
            try{
                SBQQ__Quote__c insertedQuote = [Select Id from SBQQ__Quote__c where SBQQ__Account__r.Name =: LOC_ACCNAME limit 1];
                SBQQ__QuoteLine__c qlDMP = [Select id, Availability_Flag__c from SBQQ__QuoteLine__c where SBQQ__Quote__r.Id =: insertedQuote.Id  and SBQQ__Product__r.Name = 'Dumpster'  limit 1 ];
                List<SBQQ__QuoteLine__c> qlPCK = [Select id, Pricing_API_Method__c from SBQQ__QuoteLine__c where SBQQ__Quote__r.Id =: insertedQuote.Id  and SBQQ__Product__r.Name = 'Pickup' and SBQQ__RequiredBy__r.SBQQ__ProductFamily__c =: COMMERCIAL  limit 1 ];
                
                    RecurrsiveTriggerHandler.bypassValidationQuoteLine = true;
                    RecurrsiveTriggerHandler.isSkipValidateQLCostPrice =true;
                	QuoteLineTriggerHelper.extrapickUpRecursion = false;                
                    SBQQ.TriggerControl.disable();
                	if(qlDMP != null){
                    	qlDMP.Availability_Flag__c= null;
                    	update qlDMP;
                    }
                    if(qlPCK!=null && qlPCK.size()>0){
                    	qlPCK[0].Pricing_API_Method__c = MODELED;
                    	update qlPCK[0];
                    }
                    SBQQ.TriggerControl.enable();
                
                if(insertedQuote != null && insertedQuote.Id != null){
                	PricingRequestSTPProcess.saveProcuredStatus(insertedQuote.Id);
                }
            }catch(Exception e) {
        	}
        }
        test.stopTest();
    }
    @isTest
    public static void testNoCoreSrvSaveProcuredStatus(){
        test.startTest();
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN  AND IsActive = true LIMIT 1];
        System.runAs(adminUser){
            try{
                SBQQ__Quote__c insertedQuote = [Select Id from SBQQ__Quote__c where SBQQ__Account__r.Name =: LOC_ACCNAME limit 1];
                SBQQ__QuoteLine__c qlDMP = [Select id, Availability_Flag__c from SBQQ__QuoteLine__c where SBQQ__Quote__r.Id =: insertedQuote.Id  and SBQQ__Product__r.Name = 'Dumpster'  limit 1 ];
                List<SBQQ__QuoteLine__c> qlPckNExtraPck = [Select id from SBQQ__QuoteLine__c where SBQQ__Quote__r.Id =: insertedQuote.Id  and (SBQQ__Product__r.Name = 'Pickup' or SBQQ__Product__r.Name = 'Extra Pickup')  limit 2 ];
                
                    RecurrsiveTriggerHandler.bypassValidationQuoteLine = true;
                    RecurrsiveTriggerHandler.isSkipValidateQLCostPrice =true;
                	QuoteLineTriggerHelper.extrapickUpRecursion = false;                
                    SBQQ.TriggerControl.disable();
                    if(qlDMP != null){
                    	qlDMP.Availability_Flag__c= null;
                    	update qlDMP;
                    }
                if(qlPckNExtraPck !=null && qlPckNExtraPck.size()>0){
                    delete qlPckNExtraPck;
                }
                    SBQQ.TriggerControl.enable();
                
                if(insertedQuote != null && insertedQuote.Id != null){
                    
                	PricingRequestSTPProcess.saveProcuredStatus(insertedQuote.Id);
                }
            }catch(Exception e) {
        	}
        }
        test.stopTest();
    }
    @isTest
    public static void testCostZeroNNullSaveProcuredStatus(){
        test.startTest();
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN  AND IsActive = true LIMIT 1];
        System.runAs(adminUser){
            try{
                SBQQ__Quote__c insertedQuote = [Select Id,QuoteProcuredStatus__c from SBQQ__Quote__c where SBQQ__Account__r.Name =: LOC_ACCNAME limit 1];
                SBQQ__QuoteLine__c qlDMP = [Select id, Availability_Flag__c from SBQQ__QuoteLine__c where SBQQ__Quote__r.Id =: insertedQuote.Id  and SBQQ__Product__r.Name = 'Dumpster'  limit 1 ];
                List<SBQQ__QuoteLine__c> qlPckNExtraPck = [Select id from SBQQ__QuoteLine__c where SBQQ__Quote__r.Id =: insertedQuote.Id  and (SBQQ__Product__r.Name = 'Pickup' or SBQQ__Product__r.Name = 'Extra Pickup')  limit 2 ];
                
                    RecurrsiveTriggerHandler.bypassValidationQuoteLine = true;
                    RecurrsiveTriggerHandler.isSkipValidateQLCostPrice =true;
                	QuoteLineTriggerHelper.extrapickUpRecursion = false;                
                    SBQQ.TriggerControl.disable();
                	if(qlDMP != null){
                    	qlDMP.Availability_Flag__c= null;
                    	update qlDMP;
                    }
                    if(qlPckNExtraPck !=null && qlPckNExtraPck.size()>0){
                        
                    	qlPckNExtraPck[0].SBQQ__UnitCost__c = 0;
                        qlPckNExtraPck[1].SBQQ__UnitCost__c = null;
                        update qlPckNExtraPck;
                	}
                    SBQQ.TriggerControl.enable();
                
                if(insertedQuote != null && insertedQuote.Id != null){
                	PricingRequestSTPProcess.saveProcuredStatus(insertedQuote.Id);
                }
            }catch(Exception e) {
        	}
        }
        test.stopTest();
    }	
	@isTest
    public static void testCostNullNZeroSaveProcuredStatus(){
        test.startTest();
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN  AND IsActive = true LIMIT 1];
        System.runAs(adminUser){
            try{
                SBQQ__Quote__c insertedQuote = [Select Id,QuoteProcuredStatus__c from SBQQ__Quote__c where SBQQ__Account__r.Name =: LOC_ACCNAME limit 1];
                SBQQ__QuoteLine__c qlDMP = [Select id, Availability_Flag__c from SBQQ__QuoteLine__c where SBQQ__Quote__r.Id =: insertedQuote.Id  and SBQQ__Product__r.Name = 'Dumpster'  limit 1 ];
                List<SBQQ__QuoteLine__c> qlPckNExtraPck = [Select id from SBQQ__QuoteLine__c where SBQQ__Quote__r.Id =: insertedQuote.Id  and (SBQQ__Product__r.Name = 'Pickup' or SBQQ__Product__r.Name = 'Extra Pickup')  limit 2 ];
                
                    RecurrsiveTriggerHandler.bypassValidationQuoteLine = true;
                    RecurrsiveTriggerHandler.isSkipValidateQLCostPrice =true;
                	QuoteLineTriggerHelper.extrapickUpRecursion = false;                
                    SBQQ.TriggerControl.disable();
                	if(qlDMP != null){
                    	qlDMP.Availability_Flag__c= null;
                    	update qlDMP;
                    }
                    if(qlPckNExtraPck !=null && qlPckNExtraPck.size()>0){
                        
                    	qlPckNExtraPck[0].SBQQ__UnitCost__c = null;
                        qlPckNExtraPck[1].SBQQ__UnitCost__c = 0;
                        update qlPckNExtraPck;
                	}
                    SBQQ.TriggerControl.enable();
                
                if(insertedQuote != null && insertedQuote.Id != null){
                	PricingRequestSTPProcess.saveProcuredStatus(insertedQuote.Id);
                }
            }catch(Exception e) {
        	}
        }
        test.stopTest();
    }
	@isTest
    public static void testCostBothZeroSaveProcuredStatus(){
        test.startTest();
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN  AND IsActive = true LIMIT 1];
        System.runAs(adminUser){
            try{
                SBQQ__Quote__c insertedQuote = [Select Id,QuoteProcuredStatus__c from SBQQ__Quote__c where SBQQ__Account__r.Name =: LOC_ACCNAME limit 1];
                SBQQ__QuoteLine__c qlDMP = [Select id, Availability_Flag__c from SBQQ__QuoteLine__c where SBQQ__Quote__r.Id =: insertedQuote.Id  and SBQQ__Product__r.Name = 'Dumpster'  limit 1 ];
                List<SBQQ__QuoteLine__c> qlPckNExtraPck = [Select id from SBQQ__QuoteLine__c where SBQQ__Quote__r.Id =: insertedQuote.Id  and (SBQQ__Product__r.Name = 'Pickup' or SBQQ__Product__r.Name = 'Extra Pickup')  limit 2 ];
                
                    RecurrsiveTriggerHandler.bypassValidationQuoteLine = true;
                    RecurrsiveTriggerHandler.isSkipValidateQLCostPrice =true;
                	QuoteLineTriggerHelper.extrapickUpRecursion = false;                
                    SBQQ.TriggerControl.disable();
                	if(qlDMP != null){
                    	qlDMP.Availability_Flag__c= null;
                    	update qlDMP;
                        //system.debug('qlDMP.Availability_Flag__c '+ qlDMP.Availability_Flag__c);
                    }
                    if(qlPckNExtraPck !=null && qlPckNExtraPck.size()>0){
                        
                    	qlPckNExtraPck[0].SBQQ__UnitCost__c = 0;
                        qlPckNExtraPck[1].SBQQ__UnitCost__c = 0;
                        update qlPckNExtraPck;
                	}
                    SBQQ.TriggerControl.enable();
                
                if(insertedQuote != null && insertedQuote.Id != null){
                	PricingRequestSTPProcess.saveProcuredStatus(insertedQuote.Id);
                }
            }catch(Exception e) {
        	}
        }
        test.stopTest();
    }
	@isTest
    public static void testCostBothNullSaveProcuredStatus(){
        test.startTest();
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN  AND IsActive = true LIMIT 1];
        System.runAs(adminUser){
            try{
                SBQQ__Quote__c insertedQuote = [Select Id,QuoteProcuredStatus__c from SBQQ__Quote__c where SBQQ__Account__r.Name =: LOC_ACCNAME limit 1];
                SBQQ__QuoteLine__c qlDMP = [Select id, Availability_Flag__c from SBQQ__QuoteLine__c where SBQQ__Quote__r.Id =: insertedQuote.Id  and SBQQ__Product__r.Name = 'Dumpster'  limit 1 ];
                List<SBQQ__QuoteLine__c> qlPckNExtraPck = [Select id from SBQQ__QuoteLine__c where SBQQ__Quote__r.Id =: insertedQuote.Id  and (SBQQ__Product__r.Name = 'Pickup' or SBQQ__Product__r.Name = 'Extra Pickup')  limit 2 ];
                
                    RecurrsiveTriggerHandler.bypassValidationQuoteLine = true;
                    RecurrsiveTriggerHandler.isSkipValidateQLCostPrice =true;
                	QuoteLineTriggerHelper.extrapickUpRecursion = false;                
                    SBQQ.TriggerControl.disable();
                	if(qlDMP != null){
                    	qlDMP.Availability_Flag__c= null;
                    	update qlDMP;
                        //system.debug('qlDMP.Availability_Flag__c '+ qlDMP.Availability_Flag__c);
                    }
                    if(qlPckNExtraPck !=null && qlPckNExtraPck.size()>0){
                        
                    	qlPckNExtraPck[0].SBQQ__UnitCost__c = null;
                        qlPckNExtraPck[1].SBQQ__UnitCost__c = null;
                        update qlPckNExtraPck;
                	}
                    SBQQ.TriggerControl.enable();
                
                if(insertedQuote != null && insertedQuote.Id != null){
                	PricingRequestSTPProcess.saveProcuredStatus(insertedQuote.Id);
                }
            }catch(Exception e) {
        	}
        }
        test.stopTest();
    }
	@isTest
    public static void testCostValueNNullSaveProcuredStatus(){
        test.startTest();
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN  AND IsActive = true LIMIT 1];
        System.runAs(adminUser){
            try{
                SBQQ__Quote__c insertedQuote = [Select Id,QuoteProcuredStatus__c from SBQQ__Quote__c where SBQQ__Account__r.Name =: LOC_ACCNAME limit 1];
                SBQQ__QuoteLine__c qlDMP = [Select id, Availability_Flag__c from SBQQ__QuoteLine__c where SBQQ__Quote__r.Id =: insertedQuote.Id  and SBQQ__Product__r.Name = 'Dumpster'  limit 1 ];
                List<SBQQ__QuoteLine__c> qlPckNExtraPck = [Select id from SBQQ__QuoteLine__c where SBQQ__Quote__r.Id =: insertedQuote.Id  and (SBQQ__Product__r.Name = 'Pickup' or SBQQ__Product__r.Name = 'Extra Pickup')  limit 2 ];
                
                    RecurrsiveTriggerHandler.bypassValidationQuoteLine = true;
                    RecurrsiveTriggerHandler.isSkipValidateQLCostPrice =true;
                	QuoteLineTriggerHelper.extrapickUpRecursion = false;                
                    SBQQ.TriggerControl.disable();
                	if(qlDMP != null){
                    	qlDMP.Availability_Flag__c= null;
                    	update qlDMP;
                        //system.debug('qlDMP.Availability_Flag__c '+ qlDMP.Availability_Flag__c);
                    }
                    if(qlPckNExtraPck !=null && qlPckNExtraPck.size()>0){
                        
                    	qlPckNExtraPck[0].SBQQ__UnitCost__c = 567;
                        qlPckNExtraPck[1].SBQQ__UnitCost__c = null;
                        update qlPckNExtraPck;
                	}
                    SBQQ.TriggerControl.enable();
                
                if(insertedQuote != null && insertedQuote.Id != null){
                	PricingRequestSTPProcess.saveProcuredStatus(insertedQuote.Id);
                }
            }catch(Exception e) {
        	}
        }
        test.stopTest();
    }
	@isTest
    public static void testCostNullNValueSaveProcuredStatus(){
        test.startTest();
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN  AND IsActive = true LIMIT 1];
        System.runAs(adminUser){
            try{
                SBQQ__Quote__c insertedQuote = [Select Id,QuoteProcuredStatus__c from SBQQ__Quote__c where SBQQ__Account__r.Name =: LOC_ACCNAME limit 1];
                SBQQ__QuoteLine__c qlDMP = [Select id, Availability_Flag__c from SBQQ__QuoteLine__c where SBQQ__Quote__r.Id =: insertedQuote.Id  and SBQQ__Product__r.Name = 'Dumpster'  limit 1 ];
                List<SBQQ__QuoteLine__c> qlPckNExtraPck = [Select id from SBQQ__QuoteLine__c where SBQQ__Quote__r.Id =: insertedQuote.Id  and (SBQQ__Product__r.Name = 'Pickup' or SBQQ__Product__r.Name = 'Extra Pickup')  limit 2 ];
                
                    RecurrsiveTriggerHandler.bypassValidationQuoteLine = true;
                    RecurrsiveTriggerHandler.isSkipValidateQLCostPrice =true;
                	QuoteLineTriggerHelper.extrapickUpRecursion = false;                
                    SBQQ.TriggerControl.disable();
                	if(qlDMP != null){
                    	qlDMP.Availability_Flag__c= null;
                    	update qlDMP;
                        //system.debug('qlDMP.Availability_Flag__c '+ qlDMP.Availability_Flag__c);
                    }
                    if(qlPckNExtraPck !=null && qlPckNExtraPck.size()>0){
                        
                    	qlPckNExtraPck[0].SBQQ__UnitCost__c = null;
                        qlPckNExtraPck[1].SBQQ__UnitCost__c = 567;
                        update qlPckNExtraPck;
                	}
                    SBQQ.TriggerControl.enable();
                
                if(insertedQuote != null && insertedQuote.Id != null){
                	PricingRequestSTPProcess.saveProcuredStatus(insertedQuote.Id);
                }
            }catch(Exception e) {
        	}
        }
        test.stopTest();
    }
    @isTest
    public static void testCostZeroNValueSaveProcuredStatus(){
        test.startTest();
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN  AND IsActive = true LIMIT 1];
        System.runAs(adminUser){
            try{
                SBQQ__Quote__c insertedQuote = [Select Id,QuoteProcuredStatus__c from SBQQ__Quote__c where SBQQ__Account__r.Name =: LOC_ACCNAME limit 1];
                SBQQ__QuoteLine__c qlDMP = [Select id, Availability_Flag__c from SBQQ__QuoteLine__c where SBQQ__Quote__r.Id =: insertedQuote.Id  and SBQQ__Product__r.Name = 'Dumpster'  limit 1 ];
                List<SBQQ__QuoteLine__c> qlPckNExtraPck = [Select id from SBQQ__QuoteLine__c where SBQQ__Quote__r.Id =: insertedQuote.Id  and (SBQQ__Product__r.Name = 'Pickup' or SBQQ__Product__r.Name = 'Extra Pickup')  limit 2 ];
                
                    RecurrsiveTriggerHandler.bypassValidationQuoteLine = true;
                    RecurrsiveTriggerHandler.isSkipValidateQLCostPrice =true;
                	QuoteLineTriggerHelper.extrapickUpRecursion = false;                
                    SBQQ.TriggerControl.disable();
                	if(qlDMP != null){
                    	qlDMP.Availability_Flag__c= null;
                    	update qlDMP;
                        //system.debug('qlDMP.Availability_Flag__c '+ qlDMP.Availability_Flag__c);
                    }
                    if(qlPckNExtraPck !=null && qlPckNExtraPck.size()>0){
                        
                    	qlPckNExtraPck[0].SBQQ__UnitCost__c = 0;
                        qlPckNExtraPck[1].SBQQ__UnitCost__c = 567;
                        update qlPckNExtraPck;
                	}
                    SBQQ.TriggerControl.enable();
                
                if(insertedQuote != null && insertedQuote.Id != null){
                	PricingRequestSTPProcess.saveProcuredStatus(insertedQuote.Id);
                }
            }catch(Exception e) {
        	}
        }
        test.stopTest();
    }
	@isTest
    public static void testCostValueNZeroSaveProcuredStatus(){
        test.startTest();
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN  AND IsActive = true LIMIT 1];
        System.runAs(adminUser){
            try{
                SBQQ__Quote__c insertedQuote = [Select Id,QuoteProcuredStatus__c from SBQQ__Quote__c where SBQQ__Account__r.Name =: LOC_ACCNAME limit 1];
                SBQQ__QuoteLine__c qlDMP = [Select id, Availability_Flag__c from SBQQ__QuoteLine__c where SBQQ__Quote__r.Id =: insertedQuote.Id  and SBQQ__Product__r.Name = 'Dumpster'  limit 1 ];
                List<SBQQ__QuoteLine__c> qlPckNExtraPck = [Select id from SBQQ__QuoteLine__c where SBQQ__Quote__r.Id =: insertedQuote.Id  and (SBQQ__Product__r.Name = 'Pickup' or SBQQ__Product__r.Name = 'Extra Pickup')  limit 2 ];
                
                    RecurrsiveTriggerHandler.bypassValidationQuoteLine = true;
                    RecurrsiveTriggerHandler.isSkipValidateQLCostPrice =true;
                	QuoteLineTriggerHelper.extrapickUpRecursion = false;                
                    SBQQ.TriggerControl.disable();
                	if(qlDMP != null){
                    	qlDMP.Availability_Flag__c= null;
                    	update qlDMP;
                        //system.debug('qlDMP.Availability_Flag__c '+ qlDMP.Availability_Flag__c);
                    }
                    if(qlPckNExtraPck !=null && qlPckNExtraPck.size()>0){
                        
                    	qlPckNExtraPck[0].SBQQ__UnitCost__c = 567;
                        qlPckNExtraPck[1].SBQQ__UnitCost__c = 0;
                        update qlPckNExtraPck;
                	}
                    SBQQ.TriggerControl.enable();
                
                if(insertedQuote != null && insertedQuote.Id != null){
                	PricingRequestSTPProcess.saveProcuredStatus(insertedQuote.Id);
                }
            }catch(Exception e) {
        	}
        }
        test.stopTest();
    }
    @isTest
    public static void testBothValueSaveProcuredStatus(){
        test.startTest();
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN  AND IsActive = true LIMIT 1];
        System.runAs(adminUser){
            try{
                SBQQ__Quote__c insertedQuote = [Select Id,QuoteProcuredStatus__c from SBQQ__Quote__c where SBQQ__Account__r.Name =: LOC_ACCNAME limit 1];
                SBQQ__QuoteLine__c qlDMP = [Select id, Availability_Flag__c from SBQQ__QuoteLine__c where SBQQ__Quote__r.Id =: insertedQuote.Id  and SBQQ__Product__r.Name = 'Dumpster'  limit 1 ];
                List<SBQQ__QuoteLine__c> qlPckNExtraPck = [Select id from SBQQ__QuoteLine__c where SBQQ__Quote__r.Id =: insertedQuote.Id  and (SBQQ__Product__r.Name = 'Pickup' or SBQQ__Product__r.Name = 'Extra Pickup')  limit 2 ];
                
                    RecurrsiveTriggerHandler.bypassValidationQuoteLine = true;
                    RecurrsiveTriggerHandler.isSkipValidateQLCostPrice =true;
                	QuoteLineTriggerHelper.extrapickUpRecursion = false;                
                    SBQQ.TriggerControl.disable();
                	if(qlDMP != null){
                    	qlDMP.Availability_Flag__c= null;
                    	update qlDMP;
                        //system.debug('qlDMP.Availability_Flag__c '+ qlDMP.Availability_Flag__c);
                    }
                    if(qlPckNExtraPck !=null && qlPckNExtraPck.size()>0){
                        
                    	qlPckNExtraPck[0].SBQQ__UnitCost__c = 567;
                        qlPckNExtraPck[1].SBQQ__UnitCost__c = 567;
                        update qlPckNExtraPck;
                	}
                    SBQQ.TriggerControl.enable();
                
                if(insertedQuote != null && insertedQuote.Id != null){
                	PricingRequestSTPProcess.saveProcuredStatus(insertedQuote.Id);
                }
            }catch(Exception e) {
        	}
        }
        test.stopTest();
    }
}