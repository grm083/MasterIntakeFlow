/*
* @Owner : TCS-Ruchika
* @Story : 20689
* @Class covered : PricingRequestMultiVendorSTPProcess
*/

@isTest(seeAllData=false)
global class PricingRequestMultiVendorSTPProcessTest{
    private static final string SYS_ADMIN = 'System Administrator';
    private static final string TRASH = 'Trash';
    private static final string ON_CALL = 'On-Call';
    private static final string ROLLOFF = 'Rolloff';
    private static final string COMMERCIAL = 'Commercial';
    private static final string SERVICES = 'Services';
    private static final string EQUIPMENT = 'Equipment';
    private static final string FieldApiName = 'Material_Code__c';

    private static final String JSON_VALID_ROLLOFF_DATA = '{"data":{"priceQuoteIdentifier":"Q210791","lineOfBusiness":"Roll Off","priceTypeCode":"New","customerCode":"HMD","customerName":"The Home Depot","locationCode":"HMD002718","serviceBaselineId":null,"equipmentCode":"OT","equipmentName":"Open Top","equipmentSizeCode":"YRDS-30","equipmentSizeName":"30 Yards","materialCode":"T","materialName":"Trash","countryCode":"USA","currencyCode":"USD","equipmentAvailabilityCode":"PERM","sourceSystem":"SFDC","isCostOnly":false,"suppliers":[{"costSource":"WM","priceSource":"Standard Pricing","supplierCode":"3708","supplierName":"WMI OF FL, BROWARD","contractType":"Open Market","wasteStreamCode":"MSW_RO","wasteStreamName":"Municipal Solid Waste","equipmentUOM":"Tons","zoneCode":"GIS545655","zoneName":"Southern Sanitation","zoneDescription":"Southern Sanitation","zoneNotes":null,"disposalFacilityType":"N02806_Disposal","disposalFacilityName":"N02806_Disposal_Third Party Facility","commercial":null,"rollOff":{"pricingMethodDisposalDescription":"Cost Plus","pricingMethodHaulingDescription":"Cost Plus","haulCost":585.52,"haulPrice":null,"disposalCost":70.8,"disposalPrice":70.8,"estimatedVolumePerHaul":4,"haulRecordId":null,"disposalRecordId":null,"originalHaulCost":585.52,"originalDisposalCost":70.8,"stepDisposals":null},"serviceCharges":[{"code":"DLV_C_PERM_OPEN_T","name":"Delivery","componentCode":"DLV","componentName":"Delivery","actionCode":"ADJ","actionName":"Adjust","cost":50,"costValueType":"Amount","costUOM":"Monthly","price":50,"priceValueType":"Amount","priceUOM":"Monthly"},{"code":"MNT_C_PERM_OPEN_T","name":"All Other Minimum Tonnage","componentCode":"DSP","componentName":"Disposal","actionCode":"ADJ","actionName":"Adjust","cost":50,"costValueType":"Amount","costUOM":"Monthly","price":50,"priceValueType":"Amount","priceUOM":"Monthly"},{"code":"CSC_RO_PERM_OPEN","name":"Container Service Charge","componentCode":"UNK","componentName":"Unknown","actionCode":"ADJ","actionName":"Adjust","cost":10,"costValueType":"Amount","costUOM":null,"price":10,"priceValueType":"Amount","priceUOM":null},{"code":"CWO_RO_PERM_OPEN","name":"Container Wash","componentCode":"UNK","componentName":"Unknown","actionCode":"ADJ","actionName":"Adjust","cost":200,"costValueType":"Amount","costUOM":null,"price":200,"priceValueType":"Amount","priceUOM":null},{"code":"D_RO_PERM_OPEN","name":"Delivery","componentCode":"UNK","componentName":"Unknown","actionCode":"ADJ","actionName":"Adjust","cost":139,"costValueType":"Amount","costUOM":null,"price":139,"priceValueType":"Amount","priceUOM":null}],"wmMetaData":{"equipmentCode":"30O","equipmentName":"30 Yard Open Top","masCompany":null,"masLibrary":"ARDTA.114A","maslob":"O","francisePricingLink":"Do Not Change/T/5/","greenPagesLink":null,"marketAreaCode":"K00114","marketAreaName":"WM of Florida","facilityId":"FL0028","facilityName":"Southern Sanitation","siteId":"S03930","siteName":"Southern Sanitation","masCustomerUniqueId":null,"requestTrackingId":"PR250825284488","targetTrackingId":"66dc2524-70bab03d7c6"},"tpMetaData":null,"messages":null},{"costSource":"TP (68525)","priceSource":"Standard Pricing","supplierCode":"222540","supplierName":"DINVERNO GROUP LLC","contractType":"Open Market","wasteStreamCode":"Trash","wasteStreamName":"Trash","equipmentUOM":"Tons","zoneCode":"457660","zoneName":"PRT","zoneDescription":null,"zoneNotes":null,"disposalFacilityType":null,"disposalFacilityName":null,"commercial":null,"rollOff":{"pricingMethodDisposalDescription":"Procured","pricingMethodHaulingDescription":"Procured","haulCost":264,"haulPrice":264,"disposalCost":40,"disposalPrice":40,"estimatedVolumePerHaul":null,"haulRecordId":null,"disposalRecordId":null,"originalHaulCost":264,"originalDisposalCost":40,"stepDisposals":null},"serviceCharges":[{"code":"TPC_RO_PERM_OPEN","name":"Trip","componentCode":"UNK","componentName":"Unknown","actionCode":"ADJ","actionName":"Adjust","cost":70,"costValueType":"Amount","costUOM":"Event","price":200,"priceValueType":"Amount","priceUOM":null},{"code":"REL_RO_PERM_OPEN","name":"Relocation","componentCode":"UNK","componentName":"Unknown","actionCode":"ADJ","actionName":"Adjust","cost":70,"costValueType":"Amount","costUOM":"Event","price":206,"priceValueType":"Amount","priceUOM":null},{"code":"D_RO_PERM_OPEN","name":"Delivery","componentCode":"UNK","componentName":"Unknown","actionCode":"AL","actionName":"Allow","cost":70,"costValueType":"Amount","costUOM":"Event","price":70,"priceValueType":"Amount","priceUOM":"Event"}],"wmMetaData":null,"tpMetaData":{"zoneRank":10,"feeComment":"Test Rebate","diversion":0,"scaleAvailability":"Yes","regulatoryFees":null},"messages":null}]},"problem":null}';
    private static final String JSON_WM_ONLY = '{"data":{"priceQuoteIdentifier":"Q210791","lineOfBusiness":"Roll Off","priceTypeCode":"New","customerCode":"HMD","customerName":"The Home Depot","locationCode":"HMD002718","serviceBaselineId":null,"equipmentCode":"OT","equipmentName":"Open Top","equipmentSizeCode":"YRDS-30","equipmentSizeName":"30 Yards","materialCode":"T","materialName":"Trash","countryCode":"USA","currencyCode":"USD","equipmentAvailabilityCode":"PERM","sourceSystem":"SFDC","isCostOnly":false,"suppliers":[{"costSource":"WM","priceSource":"Standard Pricing","supplierCode":"3708","supplierName":"WMI OF FL, BROWARD","contractType":"Open Market","wasteStreamCode":"MSW_RO","wasteStreamName":"Municipal Solid Waste","equipmentUOM":"Tons","zoneCode":"GIS545655","zoneName":"Southern Sanitation","zoneDescription":"Southern Sanitation","zoneNotes":null,"disposalFacilityType":"N02806_Disposal","disposalFacilityName":"N02806_Disposal_Third Party Facility","commercial":null,"rollOff":{"pricingMethodDisposalDescription":"Cost Plus","pricingMethodHaulingDescription":"Cost Plus","haulCost":585.52,"haulPrice":null,"disposalCost":70.8,"disposalPrice":70.8,"estimatedVolumePerHaul":4,"haulRecordId":null,"disposalRecordId":null,"originalHaulCost":585.52,"originalDisposalCost":70.8,"stepDisposals":null},"serviceCharges":[{"code":"CSC_RO_PERM_OPEN","name":"Container Service Charge","componentCode":"UNK","componentName":"Unknown","actionCode":"ADJ","actionName":"Adjust","cost":10,"costValueType":"Amount","costUOM":null,"price":10,"priceValueType":"Amount","priceUOM":null},{"code":"CWO_RO_PERM_OPEN","name":"Container Wash","componentCode":"UNK","componentName":"Unknown","actionCode":"ADJ","actionName":"Adjust","cost":200,"costValueType":"Amount","costUOM":null,"price":200,"priceValueType":"Amount","priceUOM":null},{"code":"D_RO_PERM_OPEN","name":"Delivery","componentCode":"UNK","componentName":"Unknown","actionCode":"ADJ","actionName":"Adjust","cost":139,"costValueType":"Amount","costUOM":null,"price":139,"priceValueType":"Amount","priceUOM":null}],"wmMetaData":{"equipmentCode":"30O","equipmentName":"30 Yard Open Top","masCompany":null,"masLibrary":"ARDTA.114A","maslob":"O","francisePricingLink":"Do Not Change/T/5/","greenPagesLink":null,"marketAreaCode":"K00114","marketAreaName":"WM of Florida","facilityId":"FL0028","facilityName":"Southern Sanitation","siteId":"S03930","siteName":"Southern Sanitation","masCustomerUniqueId":null,"requestTrackingId":"PR250825284488","targetTrackingId":"66dc2524-70bab03d7c6"},"tpMetaData":null,"messages":null}]},"problem":null}';
    private static final String GREENPAGE_JSON = '{"data":{"priceQuoteIdentifier":"Q210578","lineOfBusiness":"Roll Off","priceTypeCode":"New","customerCode":"HMD","customerName":"The Home Depot","locationCode":"HMD002718","serviceBaselineId":null,"equipmentCode":"OT","equipmentName":"Open Top","equipmentSizeCode":"YRDS-30","equipmentSizeName":"30 Yards","materialCode":"T","materialName":"Trash","countryCode":"USA","currencyCode":"USD","equipmentAvailabilityCode":"PERM","sourceSystem":"SFDC","isCostOnly":false,"suppliers":[{"costSource":"WM","priceSource":"Standard Pricing","supplierCode":"205428","supplierName":"WM - CITY DISPOSAL","contractType":"@contractType","wasteStreamCode":"MSW_CO","wasteStreamName":"Municipal Solid Waste","equipmentUOM":"Monthly","zoneCode":"GIS545664","zoneName":"Detroit Central","zoneDescription":"Detroit Central","zoneNotes":null,"disposalFacilityType":"S04264_Disposal","disposalFacilityName":"S04264_Disposal_Landfill","commercial":null,"rollOff":null,"serviceCharges":null,"wmMetaData":{"equipmentCode":"4FL","equipmentName":"4 Yard FEL","masCompany":null,"masLibrary":"ARDTA.129A","maslob":"C","francisePricingLink":"http://greenpages.wm.com","greenPagesLink":"http://greenpages.wm.com","marketAreaCode":"K00129","marketAreaName":"Great Lakes Area","facilityId":"MI0076","facilityName":"Detroit Central Hauling","siteId":"S04022","siteName":"Detroit Central Hauling","masCustomerUniqueId":null,"requestTrackingId":"PR250725283432","targetTrackingId":"a74fe"},"tpMetaData":null,"messages":null}]},"problem":null}';
    private static final String JSON_SUPPLIER_MESSAGE = '{"data":{"priceQuoteIdentifier":"Q210791","lineOfBusiness":"Roll Off","priceTypeCode":"New","customerCode":"HMD","customerName":"The Home Depot","locationCode":"HMD002718","serviceBaselineId":null,"equipmentCode":"OT","equipmentName":"Open Top","equipmentSizeCode":"YRDS-30","equipmentSizeName":"30 Yards","materialCode":"T","materialName":"Trash","countryCode":"USA","currencyCode":"USD","equipmentAvailabilityCode":"PERM","sourceSystem":"SFDC","isCostOnly":false,"suppliers":[{"costSource":"WM","priceSource":null,"supplierCode":null,"supplierName":null,"contractType":null,"wasteStreamCode":null,"wasteStreamName":null,"equipmentUOM":null,"zoneCode":null,"zoneName":null,"zoneDescription":null,"zoneNotes":null,"disposalFacilityType":null,"disposalFacilityName":null,"commercial":null,"rollOff":null,"serviceCharges":null,"wmMetaData":null,"tpMetaData":null,"messages":[{"code":"ER450","description":"Missing Disposal Facility. Reach out to the Market Area for Pricing"}]},{"costSource":"TP (68525)","priceSource":"Standard Pricing","supplierCode":"222540","supplierName":"DINVERNO GROUP LLC","contractType":"Open Market","wasteStreamCode":"Trash","wasteStreamName":"Trash","equipmentUOM":"Month","zoneCode":null,"zoneName":"PCT","zoneDescription":null,"zoneNotes":null,"disposalFacilityType":null,"disposalFacilityName":null,"commercial":{"pricingMethodPickupDescription":"Procured","pickupCost":140,"pickupPrice":140,"pickupUnitCost":140,"pickupUnitPrice":140,"extraPickupCost":90,"extraPickupPrice":152,"pickupRecordId":null,"extraPickupRecordId":null,"unitCost":140,"unitPrice":140,"originalCost":140,"originalExtraPickupCost":90,"estimatedWeightPerYard":null,"equipmentVolume":null},"rollOff":null,"serviceCharges":[{"code":"FU_C_PERM_OPEN","name":"Fuel Fee","componentCode":"ENS","componentName":"Energy Surcharge","actionCode":"EX","actionName":"Exclude","cost":null,"costValueType":null,"costUOM":null,"price":null,"priceValueType":null,"priceUOM":null}],"wmMetaData":null,"tpMetaData":{"zoneRank":null,"feeComment":null,"diversion":0,"scaleAvailability":null,"regulatoryFees":null},"messages":null}]},"problem":null}';
    private static final String JSON_API_ERROR_MESSAGE = '{"data":null,"problem":{"title":"Unprocessable Entity","status":422,"errors":[{"code":"ER10","message":"No cost/price information available"}]}}';
    private static final String JSON_VALID_ROLLOFF_DATA_TPMV = '{"data":{"priceQuoteIdentifier":"Q210791","lineOfBusiness":"Roll Off","priceTypeCode":"New","customerCode":"HMD","customerName":"The Home Depot","locationCode":"HMD002718","serviceBaselineId":null,"equipmentCode":"OT","equipmentName":"Open Top","equipmentSizeCode":"YRDS-30","equipmentSizeName":"30 Yards","materialCode":"T","materialName":"Trash","countryCode":"USA","currencyCode":"USD","equipmentAvailabilityCode":"PERM","sourceSystem":"SFDC","isCostOnly":false,"suppliers":[{"costSource":"TP (68525)","priceSource":"Standard Pricing","supplierCode":"222540","supplierName":"DINVERNO GROUP LLC","contractType":"Open Market","wasteStreamCode":"Trash","wasteStreamName":"Trash","equipmentUOM":"Tons","zoneCode":"457660","zoneName":"PRT","zoneDescription":null,"zoneNotes":null,"disposalFacilityType":null,"disposalFacilityName":null,"commercial":null,"rollOff":{"pricingMethodDisposalDescription":"Procured","pricingMethodHaulingDescription":"Procured","haulCost":264,"haulPrice":264,"disposalCost":40,"disposalPrice":40,"estimatedVolumePerHaul":null,"haulRecordId":null,"disposalRecordId":null,"originalHaulCost":264,"originalDisposalCost":40,"stepDisposals":null},"serviceCharges":[{"code":"TPC_RO_PERM_OPEN","name":"Trip","componentCode":"UNK","componentName":"Unknown","actionCode":"ADJ","actionName":"Adjust","cost":70,"costValueType":"Amount","costUOM":"Event","price":200,"priceValueType":"Amount","priceUOM":null}],"wmMetaData":null,"tpMetaData":{"zoneRank":10,"feeComment":"Test Rebate","diversion":0,"scaleAvailability":"Yes","regulatoryFees":null},"messages":null},{"costSource":"TP (68525)","priceSource":"Standard Pricing","supplierCode":"222541","supplierName":"DINVERNO GROUP LLC 1","contractType":"Open Market","wasteStreamCode":"Trash","wasteStreamName":"Trash","equipmentUOM":"Tons","zoneCode":"457660","zoneName":"PRT","zoneDescription":null,"zoneNotes":null,"disposalFacilityType":null,"disposalFacilityName":null,"commercial":null,"rollOff":{"pricingMethodDisposalDescription":"Procured","pricingMethodHaulingDescription":"Procured","haulCost":264,"haulPrice":264,"disposalCost":40,"disposalPrice":40,"estimatedVolumePerHaul":null,"haulRecordId":null,"disposalRecordId":null,"originalHaulCost":264,"originalDisposalCost":40,"stepDisposals":null},"serviceCharges":[{"code":"TPC_RO_PERM_OPEN","name":"Trip","componentCode":"UNK","componentName":"Unknown","actionCode":"ADJ","actionName":"Adjust","cost":70,"costValueType":"Amount","costUOM":"Event","price":200,"priceValueType":"Amount","priceUOM":null}],"wmMetaData":null,"tpMetaData":{"zoneRank":98,"feeComment":"Test Rebate","diversion":0,"scaleAvailability":"Yes","regulatoryFees":null},"messages":null},{"costSource":"TP (68525)","priceSource":"Standard Pricing","supplierCode":"222542","supplierName":"DINVERNO GROUP LLC 2","contractType":"Open Market","wasteStreamCode":"Trash","wasteStreamName":"Trash","equipmentUOM":"Tons","zoneCode":"457660","zoneName":"PRT","zoneDescription":null,"zoneNotes":null,"disposalFacilityType":null,"disposalFacilityName":null,"commercial":null,"rollOff":{"pricingMethodDisposalDescription":"Procured","pricingMethodHaulingDescription":"Procured","haulCost":264,"haulPrice":264,"disposalCost":40,"disposalPrice":40,"estimatedVolumePerHaul":null,"haulRecordId":null,"disposalRecordId":null,"originalHaulCost":264,"originalDisposalCost":40,"stepDisposals":null},"serviceCharges":[{"code":"TPC_RO_PERM_OPEN","name":"Trip","componentCode":"UNK","componentName":"Unknown","actionCode":"ADJ","actionName":"Adjust","cost":70,"costValueType":"Amount","costUOM":"Event","price":200,"priceValueType":"Amount","priceUOM":null}],"wmMetaData":null,"tpMetaData":{"zoneRank":null,"feeComment":"Test Rebate","diversion":0,"scaleAvailability":"Yes","regulatoryFees":null},"messages":null}]},"problem":null}';
    private static final String JSON_VALID_COMMERCIAL_DATA_MV = '{"data":{"priceQuoteIdentifier":"Q210578","lineOfBusiness":"Commercial","priceTypeCode":"New","customerCode":"HMD","customerName":"The Home Depot","locationCode":"HMD002718","serviceBaselineId":null,"equipmentCode":"DMP","equipmentName":"Dumpster","equipmentSizeCode":"YRDS-4","equipmentSizeName":"4 Yards","materialCode":"T","materialName":"Trash","countryCode":"USA","currencyCode":"USD","equipmentAvailabilityCode":"PERM","sourceSystem":"SFDC","isCostOnly":false,"suppliers":[{"costSource":"WM (a78a873f-aea7-43d7-90d6-06fe808794fe)","priceSource":"Standard Pricing","supplierCode":"205428","supplierName":"WM - CITY DISPOSAL SYSTEMS INC","contractType":"Open Market","wasteStreamCode":"MSW_CO","wasteStreamName":"Municipal Solid Waste","equipmentUOM":"Monthly","zoneCode":"GIS545664","zoneName":"Detroit Central - MSW FEL - 696 South to Detroit TS","zoneDescription":"Detroit Central - MSW FEL - 696 South to Detroit TS","zoneNotes":null,"disposalFacilityType":"S04264_Disposal","disposalFacilityName":"S04264_Disposal_Woodland Meadows Landfill_MI0091_MI0091_Woodland Meadows Landfill","commercial":{"pricingMethodPickupDescription":"Cost Plus","pickupCost":226.47,"pickupPrice":226.47,"pickupUnitCost":226.47,"pickupUnitPrice":226.47,"extraPickupCost":152,"extraPickupPrice":152,"pickupRecordId":null,"extraPickupRecordId":null,"unitCost":226.47,"unitPrice":226.47,"originalCost":226.47,"originalExtraPickupCost":152,"estimatedWeightPerYard":78.37,"equipmentVolume":4},"rollOff":null,"serviceCharges":[{"code":"ENV_C_PERM_OPEN","name":"Environmental Fee","componentCode":"ENV_FEE","componentName":"Environmental Fee","actionCode":"ADJ","actionName":"Adjust","cost":50,"costValueType":"Amount","costUOM":"Monthly","price":50,"priceValueType":"Amount","priceUOM":"Monthly"},{"code":"MNT_C_PERM_OPEN_R","name":"Minimum Tons Recycling","componentCode":"DSP","componentName":"Disposal","actionCode":"EX","actionName":"Exclude","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly"},{"code":"MNT_C_PERM_OPEN_T","name":"All Other Minimum Tonnage","componentCode":"DSP","componentName":"Disposal","actionCode":"EX","actionName":"Exclude","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly"}],"wmMetaData":{"equipmentCode":"4FL","equipmentName":"4 Yard FEL","masCompany":null,"masLibrary":"ARDTA.129A","maslob":"C","francisePricingLink":null,"greenPagesLink":null,"marketAreaCode":"K00129","marketAreaName":"Great Lakes Area","facilityId":"MI0076","facilityName":"Detroit Central Hauling","siteId":"S04022","siteName":"Detroit Central Hauling","masCustomerUniqueId":null,"requestTrackingId":"PR250725283432","targetTrackingId":"a78a873f-aea7-43d7-90d6-06fe808794fe"},"tpMetaData":null,"messages":null},{"costSource":"TP (68525)","priceSource":"Standard Pricing","supplierCode":"222540","supplierName":"DINVERNO GROUP LLC","contractType":"Open Market","wasteStreamCode":"Trash","wasteStreamName":"Trash","equipmentUOM":"Month","zoneCode":null,"zoneName":"PCT","zoneDescription":null,"zoneNotes":null,"disposalFacilityType":null,"disposalFacilityName":null,"commercial":{"pricingMethodPickupDescription":"Procured","pickupCost":140,"pickupPrice":140,"pickupUnitCost":140,"pickupUnitPrice":140,"extraPickupCost":90,"extraPickupPrice":152,"pickupRecordId":null,"extraPickupRecordId":null,"unitCost":140,"unitPrice":140,"originalCost":140,"originalExtraPickupCost":90,"estimatedWeightPerYard":null,"equipmentVolume":null},"rollOff":null,"serviceCharges":[{"code":"D_C_PERM_OPEN","name":"Delivery","componentCode":"UNK","componentName":"Unknown","actionCode":"ADJ","actionName":"Adjust","cost":70,"costValueType":"Amount","costUOM":"Event","price":139,"priceValueType":"Amount","priceUOM":null}],"wmMetaData":null,"tpMetaData":{"zoneRank":10,"feeComment":null,"diversion":0,"scaleAvailability":null,"regulatoryFees":null},"messages":null}]},"problem":null}';
    private static final String JSON_VALID_ROLLOFF_DATA_STEP = '{"data":{"priceQuoteIdentifier":"Q210791","lineOfBusiness":"Roll Off","priceTypeCode":"New","customerCode":"HMD","customerName":"The Home Depot","locationCode":"HMD002718","serviceBaselineId":null,"equipmentCode":"OT","equipmentName":"Open Top","equipmentSizeCode":"YRDS-30","equipmentSizeName":"30 Yards","materialCode":"T","materialName":"Trash","countryCode":"USA","currencyCode":"USD","equipmentAvailabilityCode":"PERM","sourceSystem":"SFDC","isCostOnly":false,"suppliers":[{"costSource":"WM","priceSource":"Standard Pricing","supplierCode":"3708","supplierName":"WMI OF FL, BROWARD","contractType":"Open Market","wasteStreamCode":"MSW_RO","wasteStreamName":"Municipal Solid Waste","equipmentUOM":"Tons","zoneCode":"GIS545655","zoneName":"Southern Sanitation","zoneDescription":"Southern Sanitation","zoneNotes":null,"disposalFacilityType":"N02806_Disposal","disposalFacilityName":"N02806_Disposal_Third Party Facility","commercial":null,"rollOff":{"pricingMethodDisposalDescription":"Cost Plus","pricingMethodHaulingDescription":"Cost Plus","haulCost":585.52,"haulPrice":null,"disposalCost":null,"disposalPrice":null,"estimatedVolumePerHaul":4,"haulRecordId":null,"disposalRecordId":null,"originalHaulCost":585.52,"originalDisposalCost":70.8,"stepDisposals":[{"priceUpTo":"2.50","priceRange":"0 UpTo 2.50","costUpTo":"2.50","costRange":"0 UpTo 2.50","cost":10,"price":10},{"priceUpTo":"2.50","priceRange":"0 UpTo 2.50","costUpTo":"2.50","costRange":"0 UpTo 2.50","cost":10,"price":10},{"priceUpTo":"2.50","priceRange":"0 UpTo 2.50","costUpTo":"2.50","costRange":"0 UpTo 2.50","cost":10,"price":10},{"priceUpTo":"99.00","priceRange":"2.50 UpTo 99.00","costUpTo":"99.00","costRange":"2.50 UpTo 99.00","cost":85.63,"price":85.63}]},"serviceCharges":[{"code":"CSC_RO_PERM_OPEN","name":"Container Service Charge","componentCode":"UNK","componentName":"Unknown","actionCode":"ADJ","actionName":"Adjust","cost":10,"costValueType":"Percent","costUOM": "Monthly","price":10,"priceValueType":"Percent","priceUOM":"Monthly"},{"code":"CWO_RO_PERM_OPEN","name":"Container Wash","componentCode":"UNK","componentName":"Unknown","actionCode":"ADJ","actionName":"Adjust","cost":200,"costValueType":"Amount","costUOM":null,"price":200,"priceValueType":"Amount","priceUOM":null},{"code":"D_RO_PERM_OPEN","name":"Delivery","componentCode":"UNK","componentName":"Unknown","actionCode":"ADJ","actionName":"Adjust","cost":139,"costValueType":"Amount","costUOM":null,"price":139,"priceValueType":"Amount","priceUOM":null}],"wmMetaData":{"equipmentCode":"30O","equipmentName":"30 Yard Open Top","masCompany":null,"masLibrary":"ARDTA.114A","maslob":"O","francisePricingLink":"Do Not Change/T/5/","greenPagesLink":null,"marketAreaCode":"K00114","marketAreaName":"WM of Florida","facilityId":"FL0028","facilityName":"Southern Sanitation","siteId":"S03930","siteName":"Southern Sanitation","masCustomerUniqueId":null,"requestTrackingId":"PR250825284488","targetTrackingId":"66dc2524-70bab03d7c6"},"tpMetaData":null,"messages":null}]},"problem":null}';

    @testSetup static void setup(){
        test.startTest();
        Profile adminProfile = TestDataFactory.getProfile(SYS_ADMIN);
        
        User usr = TestDataFactory.createUser(adminProfile);
        Database.insert(usr);  
        
        User bypassuser = TestDataFactory.createUser(adminProfile);
        bypassuser.FirstName = 'testuser#9999';
        bypassuser.Bypass_Validation__c = true;
        bypassuser.Genesys_Enabled__c = false;
        insert bypassuser;
        
        //Changes for SDT-39632
        Code_Switch__c qLValidationsetting = QuoteTestDataFactory.createCodeSwitch('New_Quote_Validation',false);
        Insert qLValidationsetting;
        
        System.runAs(usr){
            String username =UserInfo.getUserName();
            system.debug('Current user>> '+username);
            List<Opportunity> oppList = new List<Opportunity>();
            List<SBQQ__Quote__c> quoteList= new List<SBQQ__Quote__c>();
            List<Product2> prdList = new List<Product2>();    
            list<Account> acclist = new List<Account>();
            
            Account accParent = new Account(Name = 'Parent Account', phone = '9999999999', OwnerId = usr.id, AccountNumber='5678',
                                            RecordTypeid = TestDataFactory.getRecordType('Client','Account'), IsPricingEligible__c = true,Accounting_System__c='OAKWL'); 
            insert accParent;
            
            Account acc = new Account(Name = Constant_Util.KEYWORD_TEST, phone = '9999999999', OwnerId = usr.id, AccountNumber='1234',
                                        RecordTypeid = TestDataFactory.getRecordType('Client','Account'), IsPricingEligible__c = true, ParentId = accParent.Id, Type ='Location');
            acclist.add(acc);
            
            Account vendorAcc = new Account(Name = 'WM Vendor Account', phone = '9999999999', OwnerId = usr.id, AccountNumber='4321',
                                            RecordTypeid = TestDataFactory.getRecordType('Vendor','Account'));
            vendorAcc.AccountNumber = '3708';
            acclist.add(vendorAcc);
            
            Database.insert(acclist);
            
            list<Account> locationlist = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, acclist.get(0).id);
            locationlist[0].tz__Timezone_SFDC__c = 'America/Chicago';
            locationlist[0].IsPricingEligible__c = true;
            Database.insert(locationlist);
            
            list<Contact> conlist = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST,Constant_Util.CONSTANT_LAST, acclist.get(0), usr);
            Database.insert(conlist);
            
            //Inserting Account Position (Location_Position)
            Account_Position__c accLocPosition = new Account_Position__c(AccountId__c = acclist[0].Id,
                                                                            Container_Position__c = 'Test 2',
                                                                            AlternatePostalCode__c = '1234',
                                                                            AlternateCity__c = 'Test City',
                                                                            AlternateCountry__c = 'USA',
                                                                            AlternateState__c = 'NY',
                                                                            AlternateStreet__c = 'Day Hill Road');
            insert accLocPosition;
            
            //Inserting Case
            Case newServiceCase = TestDataFactory.newServiceCase(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0),usr,locationlist.get(0)); 
            newServiceCase.Service_Date__c = system.today() + 1;
            newServiceCase.SLA_Service_Date_Time__c = system.today() + 2;
            newServiceCase.Case_Type__c = 'New Service';
            newServiceCase.RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'New Service Case'].Id;  
            newServiceCase.Case_Sub_Type__c = 'Permanent';
            newServiceCase.Case_Reason__c = 'Existing Location';
            newServiceCase.LOB__c = 'Rolloff';
            newServiceCase.Status = 'Open';
            newServiceCase.Service_Occurrence_Type_Code__c = ON_CALL;
            newServiceCase.Material_Type__c = TRASH;
            
            Database.insert(newServiceCase);
            
            oppList.addAll(TestDataFactory.createOpportunity(1,'TestOpportunityTest',newServiceCase.Id,newServiceCase.Case_Sub_Type__c, newServiceCase.Location__c));
            insert oppList;
            System.Debug('@@@~Create Opp : ' + oppList);
            //test.stoptest();
                //test.startTest();
            quoteList.addAll(TestDataFactory.createQuoteRecords(oppList,acclist[0],conlist[0],Date.today(),false,true));
            quoteList[0].SBQQ__ShippingStreet__c = 'ABC';
            quoteList[0].SBQQ__ShippingCity__c = 'Test1';
            quoteList[0].SBQQ__ShippingCountry__c = 'USA';
            quoteList[0].SBQQ__ShippingState__c = 'NY';
            quoteList[0].SBQQ__ShippingPostalCode__c = '1234';
            quoteList[0].Duration__c = 'Permanent';
            try {
                insert quoteList;
            }
            catch(exception ex) {
                system.debug(ex.getstacktracestring());
            }
            test.stoptest();
            Product2 prodOpenTop = TestDataFactory.createProduct('Open Top',ROLLOFF, 'OT');
            prodOpenTop.Is_Pricing_Eligible__c = true;
            prdList.add(prodOpenTop);
            
            Product2 prodCompactor = TestDataFactory.createProduct('Compactor',EQUIPMENT, 'CMP');
            prodCompactor.Is_Pricing_Eligible__c = true;
            prdList.add(prodCompactor);
            
            Product2 prodDumpster = TestDataFactory.createProduct('Dumpster',COMMERCIAL, 'DMP');
            prodDumpster.Is_Pricing_Eligible__c = true;
            prdList.add(prodDumpster);
            
            Product2 prodNull= TestDataFactory.createProduct('Error',EQUIPMENT,'ERR');
            prodNull.Is_Pricing_Eligible__c = true;
            prdList.add(prodNull);
            
            Product2 prodPickup= TestDataFactory.createProduct('Pickup',SERVICES,'PCK');
            prdList.add(prodPickup);
            
            Product2 prodExPickup= TestDataFactory.createProduct('Extra Pickup',SERVICES,'PCK');
            prdList.add(prodExPickup);
            
            Product2 prodHaul= TestDataFactory.createProduct('Haul',SERVICES,'H');
            prdList.add(prodHaul);
            
            Product2 prodDisposal= TestDataFactory.createProduct('Disposal',SERVICES,'DSP');
            prdList.add(prodDisposal);
            
            Product2 prodDelivery= TestDataFactory.createProduct('Delivery','Surcharges and Fees','DLV');
            prdList.add(prodDelivery);
            
            Product2 prodLandfill= TestDataFactory.createProduct('Landfill Fee','Surcharges and Fees','LF');
            prdList.add(prodLandfill);
            
            Product2 prodRecycling= TestDataFactory.createProduct('Recycling','RollOff','REC');
            prdList.add(prodRecycling);
            
            Product2 prodTrash = TestDataFactory.createProduct('Trash','Waste Stream','T');
            prodTrash.Is_Pricing_Eligible__c = true;
            prdList.add(prodTrash);
            
            Product2 prodCardboard = TestDataFactory.createProduct('Cardboard','Waste Stream','C');
            prodCardboard.Is_Pricing_Eligible__c = true;
            prdList.add(prodCardboard);
            
            Database.insert(prdList);
            
            //RecurrsiveTriggerHandler.bypassValidationQuoteLine = true;

            //Add Pricing Creation Code
            List<Pricing_Request__c> createPRList = new List<Pricing_Request__c>();

            //Open Top Valid Data - Asset Management
            Pricing_Request__c pReq1 = TestDataFactory.createPricingRequestRecord(newServiceCase, acclist[0], locationlist[0], ROLLOFF, 'AM', '', JSON_VALID_ROLLOFF_DATA, usr);
            pReq1.Service_City__c = 'Test OT AM';
            pReq1.Cost_Source__c = 'WM US';//SDT46922
            createPRList.add(pReq1);

            //Dumpster Valid Data - Asset Management
            Pricing_Request__c pReq2 = TestDataFactory.createPricingRequestRecord(newServiceCase, acclist[0], locationlist[0], COMMERCIAL, 'AM', '', JSON_VALID_COMMERCIAL_DATA_MV, usr);
            pReq2.Service_City__c = 'Test DMP AM';
            createPRList.add(pReq2);
            
            
            //Green Valid Data - Asset Management
            Pricing_Request__c pReq3 = TestDataFactory.createPricingRequestRecord(newServiceCase, acclist[0], locationlist[0], COMMERCIAL, 'AM', '', GREENPAGE_JSON, usr);
            pReq3.Service_City__c = 'Test DMP GREEN';
            createPRList.add(pReq3);

            RecurrsiveTriggerHandler.invokeValidationforPricing = false;
            Database.insert(createPRList);
            
            List<SBQQ__QuoteLine__c> qlHdr = new List<SBQQ__QuoteLine__c>();
            //Bundle 1 - Open Top
            SBQQ__QuoteLine__c qlOT = TestDataFactory.createQuoteLineRecords(quoteList[0],prodOpenTop,'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
            qlOT.SBQQ__Bundle__c = TRUE;
            qlOT.SBQQ__RequiredBy__c = null;
            qlOT.Vendor__c = vendorAcc.Id;
            qlOT.SBQQ__Number__c = 1;
            qlOT.Location_Position_Name__c = accLocPosition.Id;
            qlHdr.add(qlOT);
            
            SBQQ.TriggerControl.disable();
            try 
            {
                insert qlHdr;
            } 
            finally {
                SBQQ.TriggerControl.enable();
            }
            //test.stoptest();
            //Update Pricing Request with Quote Line Id
            createPRList[0].Quote_Line_Bundle__c = qlHdr[0].Id;
            createPRList[0].Quote__c = quoteList[0].Id;
            UPDATE createPRList[0];

            List<SBQQ__QuoteLine__c> qlChild = new List<SBQQ__QuoteLine__c>();
            
            //Open Top Child Quote Line  --- Start
            SBQQ__QuoteLine__c qlOTT = TestDataFactory.createQuoteLineRecords(quoteList[0],prodTrash,'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',0,'DYS','PER',null,'DYS','Do Not Override','NBG');
            qlOTT.SBQQ__RequiredBy__c = qlOT.Id;
            qlOTT.SBQQ__Number__c = 2;
            //qlOTT.Vendor__c = vendorAcc.Id;
            qlChild.add(qlOTT);
            
            SBQQ__QuoteLine__c qlHaul = TestDataFactory.createQuoteLineRecords(quoteList[0],prodHaul,'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',0,'DYS','PER',null,'DYS','Do Not Override','NBG');
            qlHaul.SBQQ__RequiredBy__c = qlOT.Id;
            qlHaul.SBQQ__Number__c = 3;
            //qlHaul.Vendor__c = vendorAcc.Id;
            qlChild.add(qlHaul);
            
            SBQQ__QuoteLine__c qlDisposal = TestDataFactory.createQuoteLineRecords(quoteList[0],prodDisposal,'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',0,'DYS','PER',null,'DYS','Do Not Override','NBG');
            qlDisposal.SBQQ__RequiredBy__c = qlOT.Id;
            qlDisposal.SBQQ__Number__c = 4;
            //qlDisposal.Vendor__c = vendorAcc.Id;
            qlChild.add(qlDisposal);
            
            SBQQ__QuoteLine__c qlDelivery = TestDataFactory.createQuoteLineRecords(quoteList[0],prodDelivery,'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',0,'DYS','PER',null,'DYS','Do Not Override','NBG');
            qlDelivery.SBQQ__RequiredBy__c = qlOT.Id;
            qlDelivery.SBQQ__Number__c = 5;
            //qlDelivery.Vendor__c = vendorAcc.Id;
            qlChild.add(qlDelivery);
            //Open Top Child Quote Line  --- End
            

            //Bundle 2 - Dumpster
            SBQQ__QuoteLine__c qlDMP = TestDataFactory.createQuoteLineRecords(quoteList[0],prodDumpster,'PERM',1.00,'CLT','YRDS-4','SCH','W','1','PER',34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
            qlDMP.SBQQ__Bundle__c = TRUE;
            qlDMP.SBQQ__RequiredBy__c = null;
            qlDMP.Vendor__c = vendorAcc.Id;
            qlDMP.SBQQ__Number__c = 1;
            qlDMP.Location_Position_Name__c = accLocPosition.Id;
            
            SBQQ.TriggerControl.disable();
            try 
            {
                insert qlDMP;
            } 
            finally {
                SBQQ.TriggerControl.enable();
            }
            //Update Pricing Request with Quote Line Id
            createPRList[1].Quote_Line_Bundle__c = qlDMP.Id;
            createPRList[1].Quote__c = quoteList[0].Id;
            UPDATE createPRList[1];
            List<SBQQ__QuoteLine__c> qlChildDMP = new List<SBQQ__QuoteLine__c>();
            
            //Dumpster Child Quote Line  --- Start
            SBQQ__QuoteLine__c qlDMPT = TestDataFactory.createQuoteLineRecords(quoteList[0],prodTrash,'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',0,'DYS','PER',null,'DYS','Do Not Override','NBG');
            qlDMPT.SBQQ__RequiredBy__c = qlDMP.Id;
            qlDMPT.SBQQ__Number__c = 2;
            //qlOTT.Vendor__c = vendorAcc.Id;
            qlChildDMP.add(qlDMPT);
            
            SBQQ__QuoteLine__c qlPickup = TestDataFactory.createQuoteLineRecords(quoteList[0],prodPickup,'PERM',1.00,'CLT','YRDS-4','SCH','W','1','PER',0,'DYS','PER',null,'DYS','Do Not Override','NBG');
            qlPickup.SBQQ__RequiredBy__c = qlDMP.Id;
            qlPickup.SBQQ__Number__c = 3;
            //qlHaul.Vendor__c = vendorAcc.Id;
            qlChildDMP.add(qlPickup);
            
            SBQQ__QuoteLine__c qlExPickup = TestDataFactory.createQuoteLineRecords(quoteList[0],prodExPickup,'TEMP',1.00,'CLT','YRDS-4','OC','M','1','PER',0,'DYS','PER',null,'DYS','Do Not Override','NBG');
            qlExPickup.SBQQ__RequiredBy__c = qlDMP.Id;
            qlExPickup.SBQQ__Number__c = 4;
            //qlDisposal.Vendor__c = vendorAcc.Id;
            qlChildDMP.add(qlExPickup);
                
            //addded by av4 for soql 101
            List<Sbqq__QuoteLine__c> finalQlList = new List<SBQQ__Quoteline__c>();
            finalQlList.addall(qlChild);
            finalQlList.addall(qlChildDMP);
            SBQQ.TriggerControl.disable();
            try 
            {
                database.insert(finalQlList);
            } 
            finally {
                SBQQ.TriggerControl.enable();
            }
        }
    }
    
    //Test getPricingMultiVendorDetails Logic
    @isTest public static void testgetPricingMultiVendorDetails() 
    {
        User usr = [SELECT Id, Bypass_Validation__c, FirstName FROM User WHERE Bypass_Validation__c = true AND FirstName =: 'testuser#9999' LIMIT 1];
        System.runAs(usr){
            Account venId = [Select Id from Account Where Name = 'WM Vendor Account' Limit 1];
            SBQQ__Quote__c quote = [Select Id from SBQQ__Quote__c limit 1];
            Pricing_Request__c pReq = [Select Id,IsCaseError__c,Cost_Source__c,Quote__c,Quote_Line_Bundle__c,Case_Error_Message__c,APIRequestOutput__c,Zone_Type__c from Pricing_Request__c where Cost_Source__c ='WM US' limit 1];
            List<SBQQ__QuoteLine__c> list_QLI = new List<SBQQ__QuoteLine__c>();
            list_QLI = [SELECT Id, ProcurementErrorMessage__c, BundleProcuredStatus__c,
                        Pricing_API_Method__c, SBQQ__ProductName__c, SBQQ__Quote__c, SBQQ__ProductFamily__c,
                        SBQQ__RequiredBy__r.SBQQ__ProductFamily__c, SBQQ__UnitCost__c, 
                        SBQQ__RequiredBy__c
                        FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quote.Id and  SBQQ__RequiredBy__c = null ];
            
            for(SBQQ__QuoteLine__c ql : list_QLI){
                ql.SBQQ__UnitCost__c = 12000000;
                ql.Pricing_Request__c = pReq.id;
                ql.Availability_Flag__c = Pricing_Constant_Util.WM_AVAILABILITY_CONFIRMED;
                //ql.Pricing_Request__r.Cost_Source__c = 'WM US';
            }
            pReq.Quote__c = quote.id;
            pReq.Quote_Line_Bundle__c = list_QLI[0].id;
            pReq.Case_Error_Message__c = null;
            pReq.IsCaseError__c = false;
            pReq.APIRequestOutput__c = JSON_VALID_ROLLOFF_DATA;
            pReq.Zone_Type__c = 'Open Market';
            //   pReq.suppliers = null;
            
            SBQQ.TriggerControl.disable();
            try {
                update pReq;
            
                update list_QLI;
            } finally {
                SBQQ.TriggerControl.enable();
            }           
            
            Test.startTest();            
                PricingRequestMultiVendorSTPProcess.QuotePricingMVWrapper wrapperList = new PricingRequestMultiVendorSTPProcess.QuotePricingMVWrapper();
                wrapperList =  PricingRequestMultiVendorSTPProcess.getPricingMultiVendorDetails(quote.Id);
                
                system.assert(wrapperList != null);
            Test.stopTest();
        }
    }

    //Test getPricingMultiVendorDetails Step Rate Logic
    @isTest public static void testgetPricingMultiVendorDetails_Step()
    {
        User usr = [SELECT Id, Bypass_Validation__c, FirstName FROM User WHERE Bypass_Validation__c = true AND FirstName =: 'testuser#9999' LIMIT 1];
        System.runAs(usr){
            Account venId = [Select Id from Account Where Name = 'WM Vendor Account' Limit 1];
            SBQQ__Quote__c quote = [Select Id from SBQQ__Quote__c limit 1];
            Pricing_Request__c pReq = [Select Id,IsCaseError__c,Cost_Source__c,Quote__c,Quote_Line_Bundle__c,Case_Error_Message__c,APIRequestOutput__c,Zone_Type__c from Pricing_Request__c where Cost_Source__c ='WM US' limit 1];
            List<SBQQ__QuoteLine__c> list_QLI = new List<SBQQ__QuoteLine__c>();
            list_QLI = [SELECT Id, ProcurementErrorMessage__c, BundleProcuredStatus__c,
                        Pricing_API_Method__c, SBQQ__ProductName__c, SBQQ__Quote__c, SBQQ__ProductFamily__c,
                        SBQQ__RequiredBy__r.SBQQ__ProductFamily__c, SBQQ__UnitCost__c, 
                        SBQQ__RequiredBy__c
                        FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quote.Id and  SBQQ__RequiredBy__c = null ];
            
            for(SBQQ__QuoteLine__c ql : list_QLI){
                ql.SBQQ__UnitCost__c = 12000000;
                ql.Pricing_Request__c = pReq.id;
                ql.Availability_Flag__c = Pricing_Constant_Util.WM_AVAILABILITY_CONFIRMED;
                //ql.Pricing_Request__r.Cost_Source__c = 'WM US';
            }
            pReq.Quote__c = quote.id;
            pReq.Quote_Line_Bundle__c = list_QLI[0].id;
            pReq.Case_Error_Message__c = null;
            pReq.IsCaseError__c = false;
            pReq.Project_Request__c = true;
            pReq.APIRequestOutput__c = JSON_VALID_ROLLOFF_DATA_STEP;
            pReq.Zone_Type__c = 'Open Market';
            //   pReq.suppliers = null;
            
            SBQQ.TriggerControl.disable();
            try {
                update pReq;
            
                update list_QLI;
            } finally {
                SBQQ.TriggerControl.enable();
            }           
            
            Test.startTest();            
                PricingRequestMultiVendorSTPProcess.QuotePricingMVWrapper wrapperList = new PricingRequestMultiVendorSTPProcess.QuotePricingMVWrapper();
                wrapperList =  PricingRequestMultiVendorSTPProcess.getPricingMultiVendorDetails(quote.Id);
                
                system.assert(wrapperList != null);
            Test.stopTest();
        }
    }

    //Test getPricingMultiVendorDetails GreenPage - WM_Franchise_JSON Logic
    @isTest public static void testgetPricingMultiVendorDetails_GP_WF()
    {
        User usr = [SELECT Id, Bypass_Validation__c, FirstName FROM User WHERE Bypass_Validation__c = true AND FirstName =: 'testuser#9999' LIMIT 1];
        System.runAs(usr){
            Account venId = [Select Id from Account Where Name = 'WM Vendor Account' Limit 1];
            SBQQ__Quote__c quote = [Select Id from SBQQ__Quote__c limit 1];
            Pricing_Request__c pReq = [Select Id,IsCaseError__c,Cost_Source__c,Quote__c,Quote_Line_Bundle__c,Case_Error_Message__c,APIRequestOutput__c,Zone_Type__c from Pricing_Request__c where Cost_Source__c ='WM US' limit 1];
            List<SBQQ__QuoteLine__c> list_QLI = new List<SBQQ__QuoteLine__c>();
            list_QLI = [SELECT Id, ProcurementErrorMessage__c, BundleProcuredStatus__c,
                        Pricing_API_Method__c, SBQQ__ProductName__c, SBQQ__Quote__c, SBQQ__ProductFamily__c,
                        SBQQ__RequiredBy__r.SBQQ__ProductFamily__c, SBQQ__UnitCost__c, 
                        SBQQ__RequiredBy__c
                        FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quote.Id and  SBQQ__RequiredBy__c = null ];
            
            for(SBQQ__QuoteLine__c ql : list_QLI){
                ql.Pricing_Request__c = pReq.id;
            }
            string WM_Franchise_JSON = GREENPAGE_JSON.replace('@contractType', 'WM Franchise');
            pReq.Quote__c = quote.id;
            pReq.Quote_Line_Bundle__c = list_QLI[0].id;
            pReq.Case_Error_Message__c = null;
            pReq.IsCaseError__c = false;
            pReq.Project_Request__c = true;
            pReq.APIRequestOutput__c = WM_Franchise_JSON;
            pReq.Zone_Type__c = 'WM Franchise';
            //   pReq.suppliers = null;
            
            SBQQ.TriggerControl.disable();
            try {
                update pReq;
            
                update list_QLI;
            } finally {
                SBQQ.TriggerControl.enable();
            }           
            
            Test.startTest();            
                PricingRequestMultiVendorSTPProcess.QuotePricingMVWrapper wrapperList = new PricingRequestMultiVendorSTPProcess.QuotePricingMVWrapper();
                wrapperList =  PricingRequestMultiVendorSTPProcess.getPricingMultiVendorDetails(quote.Id);
                
                system.assert(wrapperList != null);
            Test.stopTest();
        }
    }

    //Test getPricingMultiVendorDetails GreenPage - Competitor_JSON Logic
    @isTest public static void testgetPricingMultiVendorDetails_GP_Competitor()
    {
        User usr = [SELECT Id, Bypass_Validation__c, FirstName FROM User WHERE Bypass_Validation__c = true AND FirstName =: 'testuser#9999' LIMIT 1];
        System.runAs(usr){
            Account venId = [Select Id from Account Where Name = 'WM Vendor Account' Limit 1];
            SBQQ__Quote__c quote = [Select Id from SBQQ__Quote__c limit 1];
            Pricing_Request__c pReq = [Select Id,IsCaseError__c,Cost_Source__c,Quote__c,Quote_Line_Bundle__c,Case_Error_Message__c,APIRequestOutput__c,Zone_Type__c from Pricing_Request__c where Cost_Source__c ='WM US' limit 1];
            List<SBQQ__QuoteLine__c> list_QLI = new List<SBQQ__QuoteLine__c>();
            list_QLI = [SELECT Id, ProcurementErrorMessage__c, BundleProcuredStatus__c,
                        Pricing_API_Method__c, SBQQ__ProductName__c, SBQQ__Quote__c, SBQQ__ProductFamily__c,
                        SBQQ__RequiredBy__r.SBQQ__ProductFamily__c, SBQQ__UnitCost__c, 
                        SBQQ__RequiredBy__c
                        FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quote.Id and  SBQQ__RequiredBy__c = null ];
            
            for(SBQQ__QuoteLine__c ql : list_QLI){
                ql.Pricing_Request__c = pReq.id;
            }
            string Competitor_JSON = GREENPAGE_JSON.replace('@contractType', 'Competitor');
            pReq.Quote__c = quote.id;
            pReq.Quote_Line_Bundle__c = list_QLI[0].id;
            pReq.Case_Error_Message__c = null;
            pReq.IsCaseError__c = false;
            pReq.Project_Request__c = true;
            pReq.APIRequestOutput__c = Competitor_JSON;
            pReq.Zone_Type__c = 'Competitor';
            //   pReq.suppliers = null;
            
            SBQQ.TriggerControl.disable();
            try {
                update pReq;
            
                update list_QLI;
            } finally {
                SBQQ.TriggerControl.enable();
            }           
            
            Test.startTest();            
                PricingRequestMultiVendorSTPProcess.QuotePricingMVWrapper wrapperList = new PricingRequestMultiVendorSTPProcess.QuotePricingMVWrapper();
                wrapperList =  PricingRequestMultiVendorSTPProcess.getPricingMultiVendorDetails(quote.Id);
                
                system.assert(wrapperList != null);
            Test.stopTest();
        }
    }

    //Test getPricingMultiVendorDetails GreenPage - Pre_Determined_Pricing_JSON Logic
    @isTest public static void testgetPricingMultiVendorDetails_GP_PDP()
    {
        User usr = [SELECT Id, Bypass_Validation__c, FirstName FROM User WHERE Bypass_Validation__c = true AND FirstName =: 'testuser#9999' LIMIT 1];
        System.runAs(usr){
            Account venId = [Select Id from Account Where Name = 'WM Vendor Account' Limit 1];
            SBQQ__Quote__c quote = [Select Id from SBQQ__Quote__c limit 1];
            Pricing_Request__c pReq = [Select Id,IsCaseError__c,Cost_Source__c,Quote__c,Quote_Line_Bundle__c,Case_Error_Message__c,APIRequestOutput__c,Zone_Type__c from Pricing_Request__c where Cost_Source__c ='WM US' limit 1];
            List<SBQQ__QuoteLine__c> list_QLI = new List<SBQQ__QuoteLine__c>();
            list_QLI = [SELECT Id, ProcurementErrorMessage__c, BundleProcuredStatus__c,
                        Pricing_API_Method__c, SBQQ__ProductName__c, SBQQ__Quote__c, SBQQ__ProductFamily__c,
                        SBQQ__RequiredBy__r.SBQQ__ProductFamily__c, SBQQ__UnitCost__c, 
                        SBQQ__RequiredBy__c
                        FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quote.Id and  SBQQ__RequiredBy__c = null ];
            
            for(SBQQ__QuoteLine__c ql : list_QLI){
                ql.Pricing_Request__c = pReq.id;
            }
            string Pre_Determined_Pricing_JSON = GREENPAGE_JSON.replace('@contractType', 'pre-determined pricing');
            pReq.Quote__c = quote.id;
            pReq.Quote_Line_Bundle__c = list_QLI[0].id;
            pReq.Case_Error_Message__c = null;
            pReq.IsCaseError__c = false;
            pReq.Project_Request__c = true;
            pReq.APIRequestOutput__c = Pre_Determined_Pricing_JSON;
            pReq.Zone_Type__c = 'pre-determined pricing';
            //   pReq.suppliers = null;
            
            SBQQ.TriggerControl.disable();
            try {
                update pReq;
            
                update list_QLI;
            } finally {
                SBQQ.TriggerControl.enable();
            }           
            
            Test.startTest();            
                PricingRequestMultiVendorSTPProcess.QuotePricingMVWrapper wrapperList = new PricingRequestMultiVendorSTPProcess.QuotePricingMVWrapper();
                wrapperList =  PricingRequestMultiVendorSTPProcess.getPricingMultiVendorDetails(quote.Id);
                
                system.assert(wrapperList != null);
            Test.stopTest();
        }
    }

    //Test getPricingMultiVendorDetails GreenPage - Third_Party_Agreement_JSON Logic
    @isTest public static void testgetPricingMultiVendorDetails_GP_TPA()
    {
        User usr = [SELECT Id, Bypass_Validation__c, FirstName FROM User WHERE Bypass_Validation__c = true AND FirstName =: 'testuser#9999' LIMIT 1];
        System.runAs(usr){
            Account venId = [Select Id from Account Where Name = 'WM Vendor Account' Limit 1];
            SBQQ__Quote__c quote = [Select Id from SBQQ__Quote__c limit 1];
            Pricing_Request__c pReq = [Select Id,IsCaseError__c,Cost_Source__c,Quote__c,Quote_Line_Bundle__c,Case_Error_Message__c,APIRequestOutput__c,Zone_Type__c from Pricing_Request__c where Cost_Source__c ='WM US' limit 1];
            List<SBQQ__QuoteLine__c> list_QLI = new List<SBQQ__QuoteLine__c>();
            list_QLI = [SELECT Id, ProcurementErrorMessage__c, BundleProcuredStatus__c,
                        Pricing_API_Method__c, SBQQ__ProductName__c, SBQQ__Quote__c, SBQQ__ProductFamily__c,
                        SBQQ__RequiredBy__r.SBQQ__ProductFamily__c, SBQQ__UnitCost__c, 
                        SBQQ__RequiredBy__c
                        FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quote.Id and  SBQQ__RequiredBy__c = null ];
            
            for(SBQQ__QuoteLine__c ql : list_QLI){
                ql.Pricing_Request__c = pReq.id;
            }
            string Third_Party_Agreement_JSON = GREENPAGE_JSON.replace('@contractType', 'third -party agreement');
            pReq.Quote__c = quote.id;
            pReq.Quote_Line_Bundle__c = list_QLI[0].id;
            pReq.Case_Error_Message__c = null;
            pReq.IsCaseError__c = false;
            pReq.Project_Request__c = true;
            pReq.APIRequestOutput__c = Third_Party_Agreement_JSON;
            pReq.Zone_Type__c = 'third -party agreement';
            //   pReq.suppliers = null;
            
            SBQQ.TriggerControl.disable();
            try {
                update pReq;
            
                update list_QLI;
            } finally {
                SBQQ.TriggerControl.enable();
            }           
            
            Test.startTest();            
                PricingRequestMultiVendorSTPProcess.QuotePricingMVWrapper wrapperList = new PricingRequestMultiVendorSTPProcess.QuotePricingMVWrapper();
                wrapperList =  PricingRequestMultiVendorSTPProcess.getPricingMultiVendorDetails(quote.Id);
                
                system.assert(wrapperList != null);
            Test.stopTest();
        }
    }

    //Test getPricingMultiVendorDetails Supplier ErrorMessage Logic
    @isTest public static void testgetPricingMultiVendorDetails_SM()
    {
        User usr = [SELECT Id, Bypass_Validation__c, FirstName FROM User WHERE Bypass_Validation__c = true AND FirstName =: 'testuser#9999' LIMIT 1];
        System.runAs(usr){
            Account venId = [Select Id from Account Where Name = 'WM Vendor Account' Limit 1];
            SBQQ__Quote__c quote = [Select Id from SBQQ__Quote__c limit 1];
            Pricing_Request__c pReq = [Select Id,IsCaseError__c,Cost_Source__c,Quote__c,Quote_Line_Bundle__c,Case_Error_Message__c,APIRequestOutput__c,Zone_Type__c from Pricing_Request__c where Cost_Source__c ='WM US' limit 1];
            List<SBQQ__QuoteLine__c> list_QLI = new List<SBQQ__QuoteLine__c>();
            list_QLI = [SELECT Id, ProcurementErrorMessage__c, BundleProcuredStatus__c,
                        Pricing_API_Method__c, SBQQ__ProductName__c, SBQQ__Quote__c, SBQQ__ProductFamily__c,
                        SBQQ__RequiredBy__r.SBQQ__ProductFamily__c, SBQQ__UnitCost__c, 
                        SBQQ__RequiredBy__c
                        FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quote.Id and  SBQQ__RequiredBy__c = null ];
            
            for(SBQQ__QuoteLine__c ql : list_QLI){
                ql.Pricing_Request__c = pReq.id;
            }
            pReq.Quote__c = quote.id;
            pReq.Quote_Line_Bundle__c = list_QLI[0].id;
            pReq.Case_Error_Message__c = null;
            pReq.IsCaseError__c = false;
            pReq.APIRequestOutput__c = JSON_SUPPLIER_MESSAGE;
            pReq.Zone_Type__c = '';
            //   pReq.suppliers = null;
            
            SBQQ.TriggerControl.disable();
            try {
                update pReq;
            
                update list_QLI;
            } finally {
                SBQQ.TriggerControl.enable();
            }           
            
            Test.startTest();            
                PricingRequestMultiVendorSTPProcess.QuotePricingMVWrapper wrapperList = new PricingRequestMultiVendorSTPProcess.QuotePricingMVWrapper();
                wrapperList =  PricingRequestMultiVendorSTPProcess.getPricingMultiVendorDetails(quote.Id);
                
                system.assert(wrapperList != null);
            Test.stopTest();
        }
    }

    //Test getPricingMultiVendorDetails API ErrorMessage Logic
    @isTest public static void testgetPricingMultiVendorDetails_APIError()
    {
        User usr = [SELECT Id, Bypass_Validation__c, FirstName FROM User WHERE Bypass_Validation__c = true AND FirstName =: 'testuser#9999' LIMIT 1];
        System.runAs(usr){
            Account venId = [Select Id from Account Where Name = 'WM Vendor Account' Limit 1];
            SBQQ__Quote__c quote = [Select Id from SBQQ__Quote__c limit 1];
            Pricing_Request__c pReq = [Select Id,IsCaseError__c,Cost_Source__c,Quote__c,Quote_Line_Bundle__c,Case_Error_Message__c,APIRequestOutput__c,Zone_Type__c from Pricing_Request__c where Cost_Source__c ='WM US' limit 1];
            List<SBQQ__QuoteLine__c> list_QLI = new List<SBQQ__QuoteLine__c>();
            list_QLI = [SELECT Id, ProcurementErrorMessage__c, BundleProcuredStatus__c,
                        Pricing_API_Method__c, SBQQ__ProductName__c, SBQQ__Quote__c, SBQQ__ProductFamily__c,
                        SBQQ__RequiredBy__r.SBQQ__ProductFamily__c, SBQQ__UnitCost__c, 
                        SBQQ__RequiredBy__c
                        FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quote.Id and  SBQQ__RequiredBy__c = null ];
            
            for(SBQQ__QuoteLine__c ql : list_QLI){
                ql.Pricing_Request__c = pReq.id;
            }
            pReq.Quote__c = quote.id;
            pReq.Quote_Line_Bundle__c = list_QLI[0].id;
            pReq.Case_Error_Message__c = null;
            pReq.IsCaseError__c = false;
            pReq.APIRequestOutput__c = JSON_API_ERROR_MESSAGE;
            pReq.Zone_Type__c = '';
            //   pReq.suppliers = null;
            
            SBQQ.TriggerControl.disable();
            try {
                update pReq;
            
                update list_QLI;
            } finally {
                SBQQ.TriggerControl.enable();
            }           
            
            Test.startTest();            
                PricingRequestMultiVendorSTPProcess.QuotePricingMVWrapper wrapperList = new PricingRequestMultiVendorSTPProcess.QuotePricingMVWrapper();
                wrapperList =  PricingRequestMultiVendorSTPProcess.getPricingMultiVendorDetails(quote.Id);
                
                system.assert(wrapperList != null);
            Test.stopTest();
        }
    }

    //Test getPricingMultiVendorDetails Case ErrorMessage Logic
    @isTest public static void testgetPricingMultiVendorDetails_CaseError()
    {
        User usr = [SELECT Id, Bypass_Validation__c, FirstName FROM User WHERE Bypass_Validation__c = true AND FirstName =: 'testuser#9999' LIMIT 1];
        System.runAs(usr){
            Account venId = [Select Id from Account Where Name = 'WM Vendor Account' Limit 1];
            SBQQ__Quote__c quote = [Select Id from SBQQ__Quote__c limit 1];
            Pricing_Request__c pReq = [Select Id,IsCaseError__c,Cost_Source__c,Quote__c,Quote_Line_Bundle__c,Case_Error_Message__c,APIRequestOutput__c,Zone_Type__c from Pricing_Request__c where Cost_Source__c ='WM US' limit 1];
            List<SBQQ__QuoteLine__c> list_QLI = new List<SBQQ__QuoteLine__c>();
            list_QLI = [SELECT Id, ProcurementErrorMessage__c, BundleProcuredStatus__c,
                        Pricing_API_Method__c, SBQQ__ProductName__c, SBQQ__Quote__c, SBQQ__ProductFamily__c,
                        SBQQ__RequiredBy__r.SBQQ__ProductFamily__c, SBQQ__UnitCost__c, 
                        SBQQ__RequiredBy__c
                        FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quote.Id and  SBQQ__RequiredBy__c = null ];
            
            for(SBQQ__QuoteLine__c ql : list_QLI){
                ql.Pricing_Request__c = pReq.id;
            }
            pReq.Quote__c = quote.id;
            pReq.Quote_Line_Bundle__c = list_QLI[0].id;
            pReq.Case_Error_Message__c = 'Invalid Container Mapping';
            pReq.IsCaseError__c = true;
            
            SBQQ.TriggerControl.disable();
            try {
                update pReq;
            
                update list_QLI;
            } finally {
                SBQQ.TriggerControl.enable();
            }           
            
            Test.startTest();            
                PricingRequestMultiVendorSTPProcess.QuotePricingMVWrapper wrapperList = new PricingRequestMultiVendorSTPProcess.QuotePricingMVWrapper();
                wrapperList =  PricingRequestMultiVendorSTPProcess.getPricingMultiVendorDetails(quote.Id);
                
                system.assert(wrapperList != null);
            Test.stopTest();
        }
    }

    //Test processMultiVendorPricingRequest - When have WM vendor Logic
    @isTest public static void testprocessMultiVendorPricingRequest_WM() 
    {
        User usr = [SELECT Id, Bypass_Validation__c, FirstName FROM User WHERE Bypass_Validation__c = true AND FirstName =: 'testuser#9999' LIMIT 1];
        System.runAs(usr){
            Account venId = [Select Id from Account Where Name = 'WM Vendor Account' Limit 1];
            SBQQ__Quote__c quote = [Select Id from SBQQ__Quote__c limit 1];
            Pricing_Request__c pReq = [Select Id,IsCaseError__c,Cost_Source__c,Quote__c,Quote_Line_Bundle__c,Case_Error_Message__c,APIRequestOutput__c,Zone_Type__c from Pricing_Request__c where Cost_Source__c ='WM US' limit 1];
            List<SBQQ__QuoteLine__c> list_QLI = new List<SBQQ__QuoteLine__c>();
            list_QLI = [SELECT Id, ProcurementErrorMessage__c, BundleProcuredStatus__c,
                        Pricing_API_Method__c, SBQQ__ProductName__c, SBQQ__Quote__c, SBQQ__ProductFamily__c,
                        SBQQ__RequiredBy__r.SBQQ__ProductFamily__c, SBQQ__UnitCost__c, 
                        SBQQ__RequiredBy__c
                        FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quote.Id and  SBQQ__RequiredBy__c = null ];
            
            for(SBQQ__QuoteLine__c ql : list_QLI){
                ql.SBQQ__UnitCost__c = 12000000;
                ql.Pricing_Request__c = pReq.id;
                ql.Availability_Flag__c = Pricing_Constant_Util.WM_AVAILABILITY_CONFIRMED;
                //ql.Pricing_Request__r.Cost_Source__c = 'WM US';
            }
            pReq.Quote__c = quote.id;
            pReq.Quote_Line_Bundle__c = list_QLI[0].id;
            pReq.Case_Error_Message__c = null;
            pReq.IsCaseError__c = false;
            pReq.APIRequestOutput__c = JSON_VALID_ROLLOFF_DATA;
            pReq.Zone_Type__c = 'Open Market';
            //   pReq.suppliers = null;
            
            SBQQ.TriggerControl.disable();
            try {
                update pReq;
            
                update list_QLI;
            } finally {
                SBQQ.TriggerControl.enable();
            }           
            
            Test.startTest();            
                List<PricingRequestMultiVendorSTPProcess.QuotePricingWrapper> wrapperList = new List<PricingRequestMultiVendorSTPProcess.QuotePricingWrapper>();
                wrapperList =  PricingRequestMultiVendorSTPProcess.processMultiVendorPricingRequest(quote.Id, true);
                
                system.assert(wrapperList != null);
            Test.stopTest();
        }
    }

    //Test processMultiVendorPricingRequest - When have only TP vendor Logic
    @isTest public static void testprocessMultiVendorPricingRequest_TP() 
    {
        User usr = [SELECT Id, Bypass_Validation__c, FirstName FROM User WHERE Bypass_Validation__c = true AND FirstName =: 'testuser#9999' LIMIT 1];
        System.runAs(usr){
            Account venId = [Select Id from Account Where Name = 'WM Vendor Account' Limit 1];
            SBQQ__Quote__c quote = [Select Id from SBQQ__Quote__c limit 1];
            Pricing_Request__c pReq = [Select Id,IsCaseError__c,Cost_Source__c,Quote__c,Quote_Line_Bundle__c,Case_Error_Message__c,APIRequestOutput__c,Zone_Type__c from Pricing_Request__c where Cost_Source__c ='WM US' limit 1];
            List<SBQQ__QuoteLine__c> list_QLI = new List<SBQQ__QuoteLine__c>();
            list_QLI = [SELECT Id, ProcurementErrorMessage__c, BundleProcuredStatus__c,
                        Pricing_API_Method__c, SBQQ__ProductName__c, SBQQ__Quote__c, SBQQ__ProductFamily__c,
                        SBQQ__RequiredBy__r.SBQQ__ProductFamily__c, SBQQ__UnitCost__c, 
                        SBQQ__RequiredBy__c
                        FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quote.Id and  SBQQ__RequiredBy__c = null ];
            
            for(SBQQ__QuoteLine__c ql : list_QLI){
                ql.SBQQ__UnitCost__c = 12000000;
                ql.Pricing_Request__c = pReq.id;
                ql.Availability_Flag__c = Pricing_Constant_Util.WM_AVAILABILITY_CONFIRMED;
                //ql.Pricing_Request__r.Cost_Source__c = 'WM US';
            }
            pReq.Quote__c = quote.id;
            pReq.Quote_Line_Bundle__c = list_QLI[0].id;
            pReq.Case_Error_Message__c = null;
            pReq.IsCaseError__c = false;
            pReq.APIRequestOutput__c = JSON_VALID_ROLLOFF_DATA_TPMV;
            pReq.Zone_Type__c = 'Open Market';
            //   pReq.suppliers = null;
            
            SBQQ.TriggerControl.disable();
            try {
                update pReq;
            
                update list_QLI;
            } finally {
                SBQQ.TriggerControl.enable();
            }           
            
            Test.startTest();            
                List<PricingRequestMultiVendorSTPProcess.QuotePricingWrapper> wrapperList = new List<PricingRequestMultiVendorSTPProcess.QuotePricingWrapper>();
                wrapperList =  PricingRequestMultiVendorSTPProcess.processMultiVendorPricingRequest(quote.Id, true);
                
                system.assert(wrapperList != null);
            Test.stopTest();
        }
    }

    //Test processMultiVendorPricingRequest - When have only WM vendor or Single vendor Logic
    @isTest public static void testprocessMultiVendorPricingRequest_WMO() 
    {
        User usr = [SELECT Id, Bypass_Validation__c, FirstName FROM User WHERE Bypass_Validation__c = true AND FirstName =: 'testuser#9999' LIMIT 1];
        System.runAs(usr){
            Account venId = [Select Id from Account Where Name = 'WM Vendor Account' Limit 1];
            SBQQ__Quote__c quote = [Select Id from SBQQ__Quote__c limit 1];
            Pricing_Request__c pReq = [Select Id,IsCaseError__c,Cost_Source__c,Quote__c,Quote_Line_Bundle__c,Case_Error_Message__c,APIRequestOutput__c,Zone_Type__c from Pricing_Request__c where Cost_Source__c ='WM US' limit 1];
            List<SBQQ__QuoteLine__c> list_QLI = new List<SBQQ__QuoteLine__c>();
            list_QLI = [SELECT Id, ProcurementErrorMessage__c, BundleProcuredStatus__c,
                        Pricing_API_Method__c, SBQQ__ProductName__c, SBQQ__Quote__c, SBQQ__ProductFamily__c,
                        SBQQ__RequiredBy__r.SBQQ__ProductFamily__c, SBQQ__UnitCost__c, 
                        SBQQ__RequiredBy__c
                        FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quote.Id and  SBQQ__RequiredBy__c = null ];
            
            for(SBQQ__QuoteLine__c ql : list_QLI){
                ql.SBQQ__UnitCost__c = 12000000;
                ql.Pricing_Request__c = pReq.id;
                ql.Availability_Flag__c = Pricing_Constant_Util.WM_AVAILABILITY_CONFIRMED;
                //ql.Pricing_Request__r.Cost_Source__c = 'WM US';
            }
            pReq.Quote__c = quote.id;
            pReq.Quote_Line_Bundle__c = list_QLI[0].id;
            pReq.Case_Error_Message__c = null;
            pReq.IsCaseError__c = false;
            pReq.APIRequestOutput__c = JSON_WM_ONLY;
            pReq.Zone_Type__c = 'Open Market';
            //   pReq.suppliers = null;
            
            SBQQ.TriggerControl.disable();
            try {
                update pReq;
            
                update list_QLI;
            } finally {
                SBQQ.TriggerControl.enable();
            }           
            
            Test.startTest();            
                List<PricingRequestMultiVendorSTPProcess.QuotePricingWrapper> wrapperList = new List<PricingRequestMultiVendorSTPProcess.QuotePricingWrapper>();
                wrapperList =  PricingRequestMultiVendorSTPProcess.processMultiVendorPricingRequest(quote.Id, true);
                
                system.assert(wrapperList != null);
            Test.stopTest();
        }
    }

    //Test processMultiVendorPricingRequest - When have Data == NULL
    @isTest public static void testprocessMultiVendorPricingRequest_APIError() 
    {
        User usr = [SELECT Id, Bypass_Validation__c, FirstName FROM User WHERE Bypass_Validation__c = true AND FirstName =: 'testuser#9999' LIMIT 1];
        System.runAs(usr){
            Account venId = [Select Id from Account Where Name = 'WM Vendor Account' Limit 1];
            SBQQ__Quote__c quote = [Select Id from SBQQ__Quote__c limit 1];
            Pricing_Request__c pReq = [Select Id,IsCaseError__c,Cost_Source__c,Quote__c,Quote_Line_Bundle__c,Case_Error_Message__c,APIRequestOutput__c,Zone_Type__c from Pricing_Request__c where Cost_Source__c ='WM US' limit 1];
            List<SBQQ__QuoteLine__c> list_QLI = new List<SBQQ__QuoteLine__c>();
            list_QLI = [SELECT Id, ProcurementErrorMessage__c, BundleProcuredStatus__c,
                        Pricing_API_Method__c, SBQQ__ProductName__c, SBQQ__Quote__c, SBQQ__ProductFamily__c,
                        SBQQ__RequiredBy__r.SBQQ__ProductFamily__c, SBQQ__UnitCost__c, 
                        SBQQ__RequiredBy__c
                        FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quote.Id and  SBQQ__RequiredBy__c = null ];
            
            for(SBQQ__QuoteLine__c ql : list_QLI){
                ql.SBQQ__UnitCost__c = 12000000;
                ql.Pricing_Request__c = pReq.id;
                ql.Availability_Flag__c = Pricing_Constant_Util.WM_AVAILABILITY_CONFIRMED;
                //ql.Pricing_Request__r.Cost_Source__c = 'WM US';
            }
            pReq.Quote__c = quote.id;
            pReq.Quote_Line_Bundle__c = list_QLI[0].id;
            pReq.Case_Error_Message__c = null;
            pReq.IsCaseError__c = false;
            pReq.APIRequestOutput__c = JSON_API_ERROR_MESSAGE;
            pReq.Zone_Type__c = 'Open Market';
            //   pReq.suppliers = null;
            
            SBQQ.TriggerControl.disable();
            try {
                update pReq;
            
                update list_QLI;
            } finally {
                SBQQ.TriggerControl.enable();
            }           
            
            Test.startTest();            
                List<PricingRequestMultiVendorSTPProcess.QuotePricingWrapper> wrapperList = new List<PricingRequestMultiVendorSTPProcess.QuotePricingWrapper>();
                wrapperList =  PricingRequestMultiVendorSTPProcess.processMultiVendorPricingRequest(quote.Id, true);
                
                system.assert(wrapperList != null);
            Test.stopTest();
        }
    }

    //Test processMultiVendorPricingRequest - When have Case Error
    @isTest public static void testprocessMultiVendorPricingRequest_CaseError() 
    {
        User usr = [SELECT Id, Bypass_Validation__c, FirstName FROM User WHERE Bypass_Validation__c = true AND FirstName =: 'testuser#9999' LIMIT 1];
        System.runAs(usr){
            Account venId = [Select Id from Account Where Name = 'WM Vendor Account' Limit 1];
            SBQQ__Quote__c quote = [Select Id from SBQQ__Quote__c limit 1];
            Pricing_Request__c pReq = [Select Id,IsCaseError__c,Cost_Source__c,Quote__c,Quote_Line_Bundle__c,Case_Error_Message__c,APIRequestOutput__c,Zone_Type__c from Pricing_Request__c where Cost_Source__c ='WM US' limit 1];
            List<SBQQ__QuoteLine__c> list_QLI = new List<SBQQ__QuoteLine__c>();
            list_QLI = [SELECT Id, ProcurementErrorMessage__c, BundleProcuredStatus__c,
                        Pricing_API_Method__c, SBQQ__ProductName__c, SBQQ__Quote__c, SBQQ__ProductFamily__c,
                        SBQQ__RequiredBy__r.SBQQ__ProductFamily__c, SBQQ__UnitCost__c, 
                        SBQQ__RequiredBy__c
                        FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quote.Id and  SBQQ__RequiredBy__c = null ];
            
            for(SBQQ__QuoteLine__c ql : list_QLI){
                ql.SBQQ__UnitCost__c = 12000000;
                ql.Pricing_Request__c = pReq.id;
                ql.Availability_Flag__c = Pricing_Constant_Util.WM_AVAILABILITY_CONFIRMED;
                //ql.Pricing_Request__r.Cost_Source__c = 'WM US';
            }
            pReq.Quote__c = quote.id;
            pReq.Quote_Line_Bundle__c = list_QLI[0].id;
            pReq.Case_Error_Message__c = 'Invalid Container Mapping';
            pReq.IsCaseError__c = true;
            
            
            SBQQ.TriggerControl.disable();
            try {
                update pReq;
            
                update list_QLI;
            } finally {
                SBQQ.TriggerControl.enable();
            }           
            
            Test.startTest();            
                List<PricingRequestMultiVendorSTPProcess.QuotePricingWrapper> wrapperList = new List<PricingRequestMultiVendorSTPProcess.QuotePricingWrapper>();
                wrapperList =  PricingRequestMultiVendorSTPProcess.processMultiVendorPricingRequest(quote.Id, true);
                
                system.assert(wrapperList != null);
            Test.stopTest();
        }
    }

    //Test processMultiVendorPricingRequest - When have Supplier Error Message
    @isTest public static void testprocessMultiVendorPricingRequest_SM() 
    {
        User usr = [SELECT Id, Bypass_Validation__c, FirstName FROM User WHERE Bypass_Validation__c = true AND FirstName =: 'testuser#9999' LIMIT 1];
        System.runAs(usr){
            Account venId = [Select Id from Account Where Name = 'WM Vendor Account' Limit 1];
            SBQQ__Quote__c quote = [Select Id from SBQQ__Quote__c limit 1];
            Pricing_Request__c pReq = [Select Id,IsCaseError__c,Cost_Source__c,Quote__c,Quote_Line_Bundle__c,Case_Error_Message__c,APIRequestOutput__c,Zone_Type__c from Pricing_Request__c where Cost_Source__c ='WM US' limit 1];
            List<SBQQ__QuoteLine__c> list_QLI = new List<SBQQ__QuoteLine__c>();
            list_QLI = [SELECT Id, ProcurementErrorMessage__c, BundleProcuredStatus__c,
                        Pricing_API_Method__c, SBQQ__ProductName__c, SBQQ__Quote__c, SBQQ__ProductFamily__c,
                        SBQQ__RequiredBy__r.SBQQ__ProductFamily__c, SBQQ__UnitCost__c, 
                        SBQQ__RequiredBy__c
                        FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quote.Id and  SBQQ__RequiredBy__c = null ];
            
            for(SBQQ__QuoteLine__c ql : list_QLI){
                ql.SBQQ__UnitCost__c = 12000000;
                ql.Pricing_Request__c = pReq.id;
                ql.Availability_Flag__c = Pricing_Constant_Util.WM_AVAILABILITY_CONFIRMED;
                //ql.Pricing_Request__r.Cost_Source__c = 'WM US';
            }
            pReq.Quote__c = quote.id;
            pReq.Quote_Line_Bundle__c = list_QLI[0].id;
            pReq.Case_Error_Message__c = null;
            pReq.IsCaseError__c = false;
            pReq.APIRequestOutput__c = JSON_SUPPLIER_MESSAGE;
            pReq.Zone_Type__c = 'Open Market';
            //   pReq.suppliers = null;
            
            SBQQ.TriggerControl.disable();
            try {
                update pReq;
            
                update list_QLI;
            } finally {
                SBQQ.TriggerControl.enable();
            }           
            
            Test.startTest();   
                Pricing_Request__c pReq1 = [Select Id,IsCaseError__c,Cost_Source__c,Quote__c,Quote_Line_Bundle__c,Case_Error_Message__c,APIRequestOutput__c,Zone_Type__c from Pricing_Request__c where Cost_Source__c ='WM US' limit 1];
                PricingRequestFieldsMetadata prResponse = new PricingRequestFieldsMetadata();
                prResponse = pReq1.APIRequestOutput__c != null ? PricingRequestFieldsMetadata.parse(pReq1.APIRequestOutput__c) : null;
                system.debug('@@@~~~pReq1.APIRequestOutput__c ' + pReq1.APIRequestOutput__c);
                system.debug('@@@~~~prResponse ' + prResponse);
                List<PricingRequestMultiVendorSTPProcess.QuotePricingWrapper> wrapperList = new List<PricingRequestMultiVendorSTPProcess.QuotePricingWrapper>();
                wrapperList =  PricingRequestMultiVendorSTPProcess.processMultiVendorPricingRequest(quote.Id, true);
                
                system.assert(wrapperList != null);
            Test.stopTest();
        }
    }

    //Test processMultiVendorPricingRequest - When have Disposal Step Rate
    @isTest public static void testprocessMultiVendorPricingRequest_Step() 
    {
        User usr = [SELECT Id, Bypass_Validation__c, FirstName FROM User WHERE Bypass_Validation__c = true AND FirstName =: 'testuser#9999' LIMIT 1];
        System.runAs(usr){
            Account venId = [Select Id from Account Where Name = 'WM Vendor Account' Limit 1];
            SBQQ__Quote__c quote = [Select Id from SBQQ__Quote__c limit 1];
            Pricing_Request__c pReq = [Select Id,IsCaseError__c,Cost_Source__c,Quote__c,Quote_Line_Bundle__c,Case_Error_Message__c,APIRequestOutput__c,Zone_Type__c from Pricing_Request__c where Cost_Source__c ='WM US' limit 1];
            List<SBQQ__QuoteLine__c> list_QLI = new List<SBQQ__QuoteLine__c>();
            list_QLI = [SELECT Id, ProcurementErrorMessage__c, BundleProcuredStatus__c,
                        Pricing_API_Method__c, SBQQ__ProductName__c, SBQQ__Quote__c, SBQQ__ProductFamily__c,
                        SBQQ__RequiredBy__r.SBQQ__ProductFamily__c, SBQQ__UnitCost__c, 
                        SBQQ__RequiredBy__c
                        FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quote.Id and  SBQQ__RequiredBy__c = null ];
            
            for(SBQQ__QuoteLine__c ql : list_QLI){
                ql.SBQQ__UnitCost__c = 12000000;
                ql.Pricing_Request__c = pReq.id;
                ql.Availability_Flag__c = Pricing_Constant_Util.WM_AVAILABILITY_CONFIRMED;
                //ql.Pricing_Request__r.Cost_Source__c = 'WM US';
            }
            pReq.Quote__c = quote.id;
            pReq.Quote_Line_Bundle__c = list_QLI[0].id;
            pReq.Case_Error_Message__c = null;
            pReq.IsCaseError__c = false;
            pReq.APIRequestOutput__c = JSON_VALID_ROLLOFF_DATA_STEP;
            pReq.Zone_Type__c = 'Open Market';
            //   pReq.suppliers = null;
            
            SBQQ.TriggerControl.disable();
            try {
                update pReq;
            
                update list_QLI;
            } finally {
                SBQQ.TriggerControl.enable();
            }           
            
            Test.startTest();            
                List<PricingRequestMultiVendorSTPProcess.QuotePricingWrapper> wrapperList = new List<PricingRequestMultiVendorSTPProcess.QuotePricingWrapper>();
                wrapperList =  PricingRequestMultiVendorSTPProcess.processMultiVendorPricingRequest(quote.Id, true);
                
                system.assert(wrapperList != null);
            Test.stopTest();
        }
    }

    //Test saveMultiVendorPricingRequest 
    @isTest public static void testsaveMultiVendorPricingRequest() 
    {
        User usr = [SELECT Id, Bypass_Validation__c, FirstName FROM User WHERE Bypass_Validation__c = true AND FirstName =: 'testuser#9999' LIMIT 1];
        System.runAs(usr){
            Account venId = [Select Id from Account Where Name = 'WM Vendor Account' Limit 1];
            SBQQ__Quote__c quote = [Select Id from SBQQ__Quote__c limit 1];
            Pricing_Request__c pReq = [Select Id,IsCaseError__c,Cost_Source__c,Quote__c,Quote_Line_Bundle__c,Case_Error_Message__c,APIRequestOutput__c,Zone_Type__c from Pricing_Request__c where Cost_Source__c ='WM US' limit 1];
            List<SBQQ__QuoteLine__c> list_QLI = new List<SBQQ__QuoteLine__c>();
            list_QLI = [SELECT Id, ProcurementErrorMessage__c, BundleProcuredStatus__c,
                        Pricing_API_Method__c, SBQQ__ProductName__c, SBQQ__Quote__c, SBQQ__ProductFamily__c,
                        SBQQ__RequiredBy__r.SBQQ__ProductFamily__c, SBQQ__UnitCost__c, 
                        SBQQ__RequiredBy__c
                        FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quote.Id and  SBQQ__RequiredBy__c = null ];
            
            for(SBQQ__QuoteLine__c ql : list_QLI){
                ql.SBQQ__UnitCost__c = 12000000;
                ql.Pricing_Request__c = pReq.id;
                ql.Availability_Flag__c = Pricing_Constant_Util.WM_AVAILABILITY_CONFIRMED;
                //ql.Pricing_Request__r.Cost_Source__c = 'WM US';
            }
            pReq.Quote__c = quote.id;
            pReq.Quote_Line_Bundle__c = list_QLI[0].id;
            pReq.Case_Error_Message__c = null;
            pReq.IsCaseError__c = false;
            pReq.APIRequestOutput__c = JSON_VALID_ROLLOFF_DATA;
            pReq.Zone_Type__c = 'Open Market';
            //   pReq.suppliers = null;
            
            SBQQ.TriggerControl.disable();
            try {
                update pReq;
            
                update list_QLI;
            } finally {
                SBQQ.TriggerControl.enable();
            }           
            
            Test.startTest();     
                string suppliersMap = '{"' + list_QLI[0].id + '":"3708"}';       
                string result =  PricingRequestMultiVendorSTPProcess.saveMultiVendorPricingRequest(quote.Id, suppliersMap);
                
                system.assert(result != null);
            Test.stopTest();
        }
    }
}