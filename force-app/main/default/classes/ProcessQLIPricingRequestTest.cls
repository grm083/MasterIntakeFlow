@isTest(seeAllData=false)
global class ProcessQLIPricingRequestTest {

    private static final string SYS_ADMIN = 'System Administrator';
    private static final string TRASH = 'Trash';
    private static final string ON_CALL = 'On-Call';
    private static final string ROLLOFF = 'Rolloff';
    private static final string COMMERCIAL = 'Commercial';
    private static final string SERVICES = 'Services';
    private static final string EQUIPMENT = 'Equipment';
    private static final string FieldApiName = 'Material_Code__c';
    private static final String JSON_VALID_ROLLOFF_DATA = '{"data":{"priceQuoteIdentifier":"Q11837","costSource":"WM (SBS|RO|OT|30O|B02860|20211019|025300|5810)","contractType":"Open Market","lineOfBusiness":"Roll Off","supplierCode":"10016","supplierName":"WMI OF MI, LIVONIA","customerCode":"HMD","customerName":"The Home Depot","locationCode":"HMD002718","wasteStreamCode":"MSW_RO","wasteStreamName":"Municipal Solid Waste","equipmentCode":"30O","equipmentName":"30 Yard Open Top","equipmentUOM":"Tons","materialCode":"T","materialName":"MSW - Unspecified","equipmentSizeCode":"YRDS-30","equipmentSizeName":"30 Yards","overridableEquipmentSizeCode":null,"overridableEquipmentSizeName":null,"zoneCode":"GIS543320","zoneName":"Detroit Central - RO MSW - To Woodland 1","disposalFacilityType":"S04264_LF","disposalFacilityName":"B02860|S04264_LF|129A_WDL|MSW_RO","commercial":null,"rollOff":{"pricingMethodDisposalCode":"1.0","pricingMethodDisposalDescription":"Market Based Pricing","pricingMethodHaulingCode":"1.0","pricingMethodHaulingDescription":"Market Based Pricing","haulCost":410.59,"haulPrice":null,"disposalCost":30.42,"disposalPrice":null,"estimatedVolumePerHaul":4,"applyInvoiceFeesToDisposalCharges":"Y","applyInvoiceFeesToRentalCharges":null,"travelTimePerHaul":126.68,"landfillMinutes":25,"transferSiteCode":"NA","equipmentAvailabilityTypeCode":"TEMP","materialClassName":"MSW_MSWI_Municipal Solid Waste - Industrial","equipmentLoadingMinutes":20,"equipmentAdditionalLoadingMinutes":null,"stepDisposals":null},"wmMetaData":{"businessUnit":"B02860","masLibrary":"129A_WDL","francisePricingLink":"","greenPagesLink":"","marketArea":"WM of Michigan Ohio Indiana"},"tpMetaData":null,"serviceCharges":[{"code":"FU_RO_TEMP_OPEN","name":"Fuel Fee","componentTypeCode":"ENS","componentTypeName":"Energy Surcharge","actionCode":"EX","actionName":"Exclude","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly"},{"code":"ENV_RO_TEMP_OPEN","name":"Environmental Fee","componentTypeCode":"ENV_FEE","componentTypeName":"Environmental Fee","actionCode":"EX","actionName":"Exclude","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly"},{"code":"RCR_RO_TEMP_OPEN","name":"Regulatory Cost Recovery","componentTypeCode":"UNK","componentTypeName":"Unknown","actionCode":"EX","actionName":"Exclude","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly"},{"code":"CSC_RO_TEMP_OPEN","name":"Container Service Charge","componentTypeCode":"UNK","componentTypeName":"Unknown","actionCode":"EX","actionName":"Exclude","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly"},{"code":"D_RO_TEMP_OPEN","name":"Delivery","componentTypeCode":"UNK","componentTypeName":"Unknown","actionCode":"EX","actionName":"Exclude","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly"}]},"problem":null}';
    private static final String JSON_VALID_COMMERCIAL_DATA = '{"data":{"priceQuoteIdentifier":"Q11839","costSource":"WM (SBS|CO|DMP|4FY|B02433|20211019|030423|5192)","contractType":"Open Market","lineOfBusiness":"Commercial","supplierCode":"12603|214136|2620","supplierName":"WMI - A FIORE & SON OF NEWARK|WMI OF NJ, ELIZABETH|WM - NJ-NORTH - 2433","customerCode":"HMD","customerName":"The Home Depot","locationCode":"HMD005826","wasteStreamCode":"REC","wasteStreamName":"Recycling","equipmentCode":"4FY","equipmentName":"4 Yard FEL Recycling","equipmentUOM":"Monthly","materialCode":"C","materialName":"Cardboard - OCC","equipmentSizeCode":"YRDS-4","equipmentSizeName":"4 Yards","overridableEquipmentSizeCode":null,"overridableEquipmentSizeName":null,"zoneCode":"GIS513947","zoneName":"UCFLRY","disposalFacilityType":"S02938_MRF","disposalFacilityName":"[B02433] [Recycle_SSRY_CO] Julia Street Recycling","commercial":{"pricingMethodCode":"2.0","pricingMethodCodeDescription":"Cost Plus","cost":32.28,"price":37.12,"equipmentLoadingMinutes":null,"equipmentAdditionalLoadingMinutes":null,"estimatedWeightPerYard":30,"equipmentVolume":4,"extraPickupCost":null,"extraPickupPrice":null},"rollOff":null,"wmMetaData":{"businessUnit":"B02433","masLibrary":"152A_ELC","francisePricingLink":"","greenPagesLink":"","marketArea":"WM of Greater Mid Atlantic"},"tpMetaData":null,"serviceCharges":[{"code":"FU_C_PERM_OPEN","name":"Fuel Fee","componentTypeCode":"ENS","componentTypeName":"Energy Surcharge","actionCode":"EX","actionName":"Exclude","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly"},{"code":"ENV_C_PERM_OPEN","name":"Environmental Fee","componentTypeCode":"ENV_FEE","componentTypeName":"Environmental Fee","actionCode":"EX","actionName":"Exclude","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly"},{"code":"RCR_C_PERM_OPEN","name":"Regulatory Cost Recovery","componentTypeCode":"UNK","componentTypeName":"Unknown","actionCode":"EX","actionName":"Exclude","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly"},{"code":"CSC_C_PERM_OPEN","name":"Container Service Charge","componentTypeCode":"UNK","componentTypeName":"Unknown","actionCode":"MR","actionName":"Manual Review","cost":null,"costValueType":null,"costUOM":null,"price":null,"priceValueType":null,"priceUOM":null},{"code":"D_C_PERM_OPEN","name":"Delivery","componentTypeCode":"UNK","componentTypeName":"Unknown","actionCode":"ADJ","actionName":"Adjust","cost":100,"costValueType":"Amount","costUOM":null,"price":115,"priceValueType":"Amount","priceUOM":null}]},"problem":null}';
    private static final String JSON_INVALID_DATA = '{"data":null,"problem":{"title":"Bad Request","status":400,"errors":[{"code":null,"message":"No cost price information available."}]}}';
    private static final String JSON_INVALID_DATA_PROS = '{"data":null,"problem":{"title":"Bad Request","status":400,"errors":[{"code":"NAC","message":"WM PROS cannot derive zone coordinates for this location. Please review the location address, correct & resubmit or process this request manually."}]}}';
    private static final String JSON_ROLLOFF_COMPACTOR_DATA = '{"data":{"priceQuoteIdentifier":"Q11840","costSource":"WM (SBS|RO|CMP|25C|B02433|20211019|030955|1913)","contractType":"Open Market","lineOfBusiness":"Roll Off","supplierCode":"12603|214136|2620","supplierName":"WMI - A FIORE & SON OF NEWARK|WMI OF NJ, ELIZABETH|WM - NJ-NORTH - 2433","customerCode":"HMD","customerName":"The Home Depot","locationCode":"HMD005826","wasteStreamCode":"MSW_RO","wasteStreamName":"Municipal Solid Waste","equipmentCode":"25C","equipmentName":"25 Yard Compactor","equipmentUOM":"Tons","materialCode":"T","materialName":"MSW - Unspecified","equipmentSizeCode":"YRDS-25","equipmentSizeName":"25 Yards","overridableEquipmentSizeCode":null,"overridableEquipmentSizeName":null,"zoneCode":"GIS512254","zoneName":"UCROMSW","disposalFacilityType":"S07379_LF","disposalFacilityName":"B02433|S07379_LF|S02938_TS|132A_FMW|MSW_RO","commercial":null,"rollOff":{"pricingMethodDisposalCode":"1.0","pricingMethodDisposalDescription":"Market Based Pricing","pricingMethodHaulingCode":"2.0","pricingMethodHaulingDescription":"Cost Plus","haulCost":285,"haulPrice":327.75,"disposalCost":109.71,"disposalPrice":126.17,"estimatedVolumePerHaul":6,"applyInvoiceFeesToDisposalCharges":"Y","applyInvoiceFeesToRentalCharges":null,"travelTimePerHaul":15.52,"landfillMinutes":23,"transferSiteCode":"S02938_TS","equipmentAvailabilityTypeCode":"PERM","materialClassName":"MSW_MSWI_Municipal Solid Waste - Industrial","equipmentLoadingMinutes":20,"equipmentAdditionalLoadingMinutes":null,"stepDisposals":null},"wmMetaData":{"businessUnit":"B02433","masLibrary":"132A_FMW","francisePricingLink":"","greenPagesLink":"","marketArea":"WM of Greater Mid Atlantic"},"tpMetaData":null,"serviceCharges":[{"code":"FU_RO_PERM_OPEN","name":"Fuel Fee","componentTypeCode":"ENS","componentTypeName":"Energy Surcharge","actionCode":"EX","actionName":"Exclude","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly"},{"code":"ENV_RO_PERM_OPEN","name":"Environmental Fee","componentTypeCode":"ENV_FEE","componentTypeName":"Environmental Fee","actionCode":"EX","actionName":"Exclude","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly"},{"code":"RCR_RO_PERM_OPEN","name":"Regulatory Cost Recovery","componentTypeCode":"UNK","componentTypeName":"Unknown","actionCode":"EX","actionName":"Exclude","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly"},{"code":"CSC_RO_PERM_OPEN","name":"Container Service Charge","componentTypeCode":"UNK","componentTypeName":"Unknown","actionCode":"AL","actionName":"Allow","cost":192.04,"costValueType":"Amount","costUOM":null,"price":192.04,"priceValueType":"Amount","priceUOM":null},{"code":"D_RO_PERM_OPEN","name":"Delivery","componentTypeCode":"UNK","componentTypeName":"Unknown","actionCode":"ADJ","actionName":"Adjust","cost":100,"costValueType":"Amount","costUOM":null,"price":115,"priceValueType":"Amount","priceUOM":null}]},"problem":null}';
    private static final String JSON_WM_FRANCHISE= '{"data":{"priceQuoteIdentifier":"Q113998","costSource":"WM ()","contractType":"wm franchise","lineOfBusiness":"Roll Off","supplierCode":null,"supplierName":null,"customerCode":"HMD","customerName":"The Home Depot","locationCode":"HMD001048","wasteStreamCode":"MSW","wasteStreamName":"Municipal Solid Waste","equipmentCode":"OT","equipmentName":"Open Top","equipmentUOM":null,"materialCode":"T","materialName":"","equipmentSizeCode":"YRDS-30","equipmentSizeName":"30 Yards","overridableEquipmentSizeCode":null,"overridableEquipmentSizeName":null,"zoneCode":"GIS544488","zoneName":"LA, City of - Non WM Franchise - Athens","disposalFacilityType":null,"disposalFacilityName":null,"commercial":null,"rollOff":null,"wmMetaData":{"businessUnit":null,"masLibrary":null,"francisePricingLink":"http://greenpagesadmin.wm.com/eAgent/iq/Ellington/request.do?create=kb:Southern California&view()=r[case013b74a0-a9fc-11de-e73d-000000000000]","greenPagesLink":""},"tpMetaData":null,"serviceCharges":null},"problem":null}';
    private static final String JSON_COMPITITOR= '{"data":{"priceQuoteIdentifier":"Q113998","costSource":"WM ()","contractType":"competitor","lineOfBusiness":"Roll Off","supplierCode":null,"supplierName":null,"customerCode":"HMD","customerName":"The Home Depot","locationCode":"HMD001048","wasteStreamCode":"MSW","wasteStreamName":"Municipal Solid Waste","equipmentCode":"OT","equipmentName":"Open Top","equipmentUOM":null,"materialCode":"T","materialName":"","equipmentSizeCode":"YRDS-30","equipmentSizeName":"30 Yards","overridableEquipmentSizeCode":null,"overridableEquipmentSizeName":null,"zoneCode":"GIS544488","zoneName":"LA, City of - Non WM Franchise - Athens","disposalFacilityType":null,"disposalFacilityName":null,"commercial":null,"rollOff":null,"wmMetaData":{"businessUnit":null,"masLibrary":null,"francisePricingLink":"http://greenpagesadmin.wm.com/eAgent/iq/Ellington/request.do?create=kb:Southern California&view()=r[case013b74a0-a9fc-11de-e73d-000000000000]","greenPagesLink":""},"tpMetaData":null,"serviceCharges":null},"problem":null}';
    private static final String JSON_PDPRICING= '{"data":{"priceQuoteIdentifier":"Q113998","costSource":"WM ()","contractType":"pre-determined pricing","lineOfBusiness":"Roll Off","supplierCode":null,"supplierName":null,"customerCode":"HMD","customerName":"The Home Depot","locationCode":"HMD001048","wasteStreamCode":"MSW","wasteStreamName":"Municipal Solid Waste","equipmentCode":"OT","equipmentName":"Open Top","equipmentUOM":null,"materialCode":"T","materialName":"","equipmentSizeCode":"YRDS-30","equipmentSizeName":"30 Yards","overridableEquipmentSizeCode":null,"overridableEquipmentSizeName":null,"zoneCode":"GIS544488","zoneName":"LA, City of - Non WM Franchise - Athens","disposalFacilityType":null,"disposalFacilityName":null,"commercial":null,"rollOff":null,"wmMetaData":{"businessUnit":null,"masLibrary":null,"francisePricingLink":"http://greenpagesadmin.wm.com/eAgent/iq/Ellington/request.do?create=kb:Southern California&view()=r[case013b74a0-a9fc-11de-e73d-000000000000]","greenPagesLink":""},"tpMetaData":null,"serviceCharges":null},"problem":null}';
    private static final String JSON_TPAGREEMENT= '{"data":{"priceQuoteIdentifier":"Q113998","costSource":"WM ()","contractType":"third -party agreement","lineOfBusiness":"Roll Off","supplierCode":null,"supplierName":null,"customerCode":"HMD","customerName":"The Home Depot","locationCode":"HMD001048","wasteStreamCode":"MSW","wasteStreamName":"Municipal Solid Waste","equipmentCode":"OT","equipmentName":"Open Top","equipmentUOM":null,"materialCode":"T","materialName":"","equipmentSizeCode":"YRDS-30","equipmentSizeName":"30 Yards","overridableEquipmentSizeCode":null,"overridableEquipmentSizeName":null,"zoneCode":"GIS544488","zoneName":"LA, City of - Non WM Franchise - Athens","disposalFacilityType":null,"disposalFacilityName":null,"commercial":null,"rollOff":null,"wmMetaData":{"businessUnit":null,"masLibrary":null,"francisePricingLink":"http://greenpagesadmin.wm.com/eAgent/iq/Ellington/request.do?create=kb:Southern California&view()=r[case013b74a0-a9fc-11de-e73d-000000000000]","greenPagesLink":""},"tpMetaData":null,"serviceCharges":null},"problem":null}';
    private static final String JSON_SUBSTITUTE_SIZE= '{"data":{"priceQuoteIdentifier":"Q11843","costSource":"WM (SBS|RO|OT|30O|B00073|20211019|032658|1469)","contractType":"Open Market","lineOfBusiness":"Roll Off","supplierCode":"200119|213220","supplierName":"WASTE MANAGEMENT OF ATLANTA NORTH|WMI OF GA - ATLANTA HAULING","customerCode":"HMD","customerName":"The Home Depot","locationCode":"HMD000100","wasteStreamCode":"MSW_RO","wasteStreamName":"Municipal Solid Waste","equipmentCode":"30O","equipmentName":"30 Yard Open Top","equipmentUOM":"Tons","materialCode":"T","materialName":"MSW - Unspecified","equipmentSizeCode":"YRDS-35","equipmentSizeName":"35 Yards","overridableEquipmentSizeCode":"YRDS-30","overridableEquipmentSizeName":"30 Yards","zoneCode":"GIS526480","zoneName":"B0073 ZOOGR - EAST COBB FULTON MSW TO PA","disposalFacilityType":"S03261_LF","disposalFacilityName":"B00073|S03261_LF|S03275_TS|126A_PLT|MSW_RO","commercial":null,"rollOff":{"pricingMethodDisposalCode":"4.0","pricingMethodDisposalDescription":"Adjusted MBP","pricingMethodHaulingCode":"1.0","pricingMethodHaulingDescription":"Market Based Pricing","haulCost":207.01,"haulPrice":null,"disposalCost":45.05,"disposalPrice":null,"estimatedVolumePerHaul":3,"applyInvoiceFeesToDisposalCharges":"Y","applyInvoiceFeesToRentalCharges":null,"travelTimePerHaul":18.68,"landfillMinutes":13,"transferSiteCode":"S03275_TS","equipmentAvailabilityTypeCode":"TEMP","materialClassName":"MSW_MSWI_Municipal Solid Waste - Industrial","equipmentLoadingMinutes":10,"equipmentAdditionalLoadingMinutes":null,"stepDisposals":null},"wmMetaData":{"businessUnit":"B00073","masLibrary":"126A_PLT","francisePricingLink":"","greenPagesLink":"","marketArea":"WM of South Atlantic"},"tpMetaData":null,"serviceCharges":[{"code":"CSC_RO_TEMP_OPEN","name":"Container Service Charge","componentTypeCode":"UNK","componentTypeName":"Unknown","actionCode":"EX","actionName":"Exclude","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly"},{"code":"D_RO_TEMP_OPEN","name":"Delivery","componentTypeCode":"UNK","componentTypeName":"Unknown","actionCode":"EX","actionName":"Exclude","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly"}]},"problem":null}';
    // Change for SDT-20689
    private static final String JSON_VALID_ROLLOFF_DATA_MV = '{"data":{"priceQuoteIdentifier":"Q210791","lineOfBusiness":"Roll Off","priceTypeCode":"New","customerCode":"HMD","customerName":"The Home Depot","locationCode":"HMD002718","serviceBaselineId":null,"equipmentCode":"OT","equipmentName":"Open Top","equipmentSizeCode":"YRDS-30","equipmentSizeName":"30 Yards","materialCode":"T","materialName":"Trash","countryCode":"USA","currencyCode":"USD","equipmentAvailabilityCode":"PERM","sourceSystem":"SFDC","isCostOnly":false,"suppliers":[{"costSource":"WM","priceSource":"Standard Pricing","supplierCode":"3708","supplierName":"WMI OF FL, BROWARD","contractType":"Open Market","wasteStreamCode":"MSW_RO","wasteStreamName":"Municipal Solid Waste","equipmentUOM":"Tons","zoneCode":"GIS545655","zoneName":"Southern Sanitation","zoneDescription":"Southern Sanitation","zoneNotes":null,"disposalFacilityType":"N02806_Disposal","disposalFacilityName":"N02806_Disposal_Third Party Facility","commercial":null,"rollOff":{"pricingMethodDisposalDescription":"Cost Plus","pricingMethodHaulingDescription":"Cost Plus","haulCost":585.52,"haulPrice":null,"disposalCost":70.8,"disposalPrice":70.8,"estimatedVolumePerHaul":4,"haulRecordId":null,"disposalRecordId":null,"originalHaulCost":585.52,"originalDisposalCost":70.8,"stepDisposals":null},"serviceCharges":[{"code":"DLV_C_PERM_OPEN_T","name":"Delivery","componentCode":"DLV","componentName":"Delivery","actionCode":"ADJ","actionName":"Adjust","cost":50,"costValueType":"Amount","costUOM":"Monthly","price":50,"priceValueType":"Amount","priceUOM":"Monthly"},{"code":"MNT_C_PERM_OPEN_T","name":"All Other Minimum Tonnage","componentCode":"DSP","componentName":"Disposal","actionCode":"ADJ","actionName":"Adjust","cost":50,"costValueType":"Amount","costUOM":"Monthly","price":50,"priceValueType":"Amount","priceUOM":"Monthly"},{"code":"CSC_RO_PERM_OPEN","name":"Container Service Charge","componentCode":"UNK","componentName":"Unknown","actionCode":"ADJ","actionName":"Adjust","cost":10,"costValueType":"Amount","costUOM":null,"price":10,"priceValueType":"Amount","priceUOM":null},{"code":"CWO_RO_PERM_OPEN","name":"Container Wash","componentCode":"UNK","componentName":"Unknown","actionCode":"ADJ","actionName":"Adjust","cost":200,"costValueType":"Amount","costUOM":null,"price":200,"priceValueType":"Amount","priceUOM":null},{"code":"D_RO_PERM_OPEN","name":"Delivery","componentCode":"UNK","componentName":"Unknown","actionCode":"ADJ","actionName":"Adjust","cost":139,"costValueType":"Amount","costUOM":null,"price":139,"priceValueType":"Amount","priceUOM":null}],"wmMetaData":{"equipmentCode":"30O","equipmentName":"30 Yard Open Top","masCompany":null,"masLibrary":"ARDTA.114A","maslob":"O","francisePricingLink":"Do Not Change/T/5/","greenPagesLink":null,"marketAreaCode":"K00114","marketAreaName":"WM of Florida","facilityId":"FL0028","facilityName":"Southern Sanitation","siteId":"S03930","siteName":"Southern Sanitation","masCustomerUniqueId":null,"requestTrackingId":"PR250825284488","targetTrackingId":"66dc2524-70bab03d7c6"},"tpMetaData":null,"messages":null},{"costSource":"TP (68525)","priceSource":"Standard Pricing","supplierCode":"222540","supplierName":"DINVERNO GROUP LLC","contractType":"Open Market","wasteStreamCode":"Trash","wasteStreamName":"Trash","equipmentUOM":"Tons","zoneCode":"457660","zoneName":"PRT","zoneDescription":null,"zoneNotes":null,"disposalFacilityType":null,"disposalFacilityName":null,"commercial":null,"rollOff":{"pricingMethodDisposalDescription":"Procured","pricingMethodHaulingDescription":"Procured","haulCost":264,"haulPrice":264,"disposalCost":40,"disposalPrice":40,"estimatedVolumePerHaul":null,"haulRecordId":null,"disposalRecordId":null,"originalHaulCost":264,"originalDisposalCost":40,"stepDisposals":null},"serviceCharges":[{"code":"TPC_RO_PERM_OPEN","name":"Trip","componentCode":"UNK","componentName":"Unknown","actionCode":"ADJ","actionName":"Adjust","cost":70,"costValueType":"Amount","costUOM":"Event","price":200,"priceValueType":"Amount","priceUOM":null},{"code":"REL_RO_PERM_OPEN","name":"Relocation","componentCode":"UNK","componentName":"Unknown","actionCode":"ADJ","actionName":"Adjust","cost":70,"costValueType":"Amount","costUOM":"Event","price":206,"priceValueType":"Amount","priceUOM":null},{"code":"D_RO_PERM_OPEN","name":"Delivery","componentCode":"UNK","componentName":"Unknown","actionCode":"AL","actionName":"Allow","cost":70,"costValueType":"Amount","costUOM":"Event","price":70,"priceValueType":"Amount","priceUOM":"Event"}],"wmMetaData":null,"tpMetaData":{"zoneRank":10,"feeComment":"Test Rebate","diversion":0,"scaleAvailability":"Yes","regulatoryFees":null},"messages":null}]},"problem":null}';
   
    @testSetup static void setup(){
        test.starttest();
        Profile adminProfile = TestDataFactory.getProfile(SYS_ADMIN);
        
        User usr = TestDataFactory.createUser(adminProfile);
        Database.insert(usr);  
        
        User bypassuser = TestDataFactory.createUser(adminProfile);
        bypassuser.FirstName = 'testuser#9999';
        bypassuser.Bypass_Validation__c = true;
        insert bypassuser;


        System.runAs(usr){
            List<Opportunity> oppList = new List<Opportunity>();
            List<SBQQ__Quote__c> quoteList= new List<SBQQ__Quote__c>();
            List<Product2> prdList = new List<Product2>();    
            list<Account> acclist = new List<Account>();
            
            //Testing for SDT-39632 - Not to be added in PR
            Code_Switch__c setting = new Code_Switch__c();
            setting.Name = 'Haul_Away';
            setting.Switch_Off__c =false ;
            insert setting;
            //Changes for SDT-39632
            Code_Switch__c qLValidationsetting = QuoteTestDataFactory.createCodeSwitch('New_Quote_Validation',false);
            Insert qLValidationsetting;

            //Change for SDT-20689
            Code_Switch__c multiVendorPricing = QuoteTestDataFactory.createCodeSwitch('Pricing MulltiVendor AM Switch',true);
            Insert multiVendorPricing;

            Account accParent = new Account(Name = 'Parent Account', phone = '9999999999', OwnerId = usr.id, AccountNumber='5678',
             RecordTypeid = TestDataFactory.getRecordType('Client','Account'), IsPricingEligible__c = true); 
            insert accParent;

            Account acc = new Account(Name = Constant_Util.KEYWORD_TEST, phone = '9999999999', OwnerId = usr.id, AccountNumber='1234',
                RecordTypeid = TestDataFactory.getRecordType('Client','Account'), IsPricingEligible__c = true, ParentId = accParent.Id, Type ='Location');
            acclist.add(acc);

            Account vendorAcc = new Account(Name = 'WM Vendor Account', phone = '9999999999', OwnerId = usr.id, AccountNumber='4321',
             RecordTypeid = TestDataFactory.getRecordType('Vendor','Account'));
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
            
            quoteList.addAll(TestDataFactory.createQuoteRecords(oppList,acclist[0],conlist[0],Date.today(),false,true));
            quoteList[0].SBQQ__ShippingStreet__c = 'ABC';
            quoteList[0].SBQQ__ShippingCity__c = 'Test1';
            quoteList[0].SBQQ__ShippingCountry__c = 'USA';
            quoteList[0].SBQQ__ShippingState__c = 'NY';
            quoteList[0].SBQQ__ShippingPostalCode__c = '1234';
            quoteList[0].Duration__c = 'Permanent';
            insert quoteList;

            Product2 prodOpenTop = TestDataFactory.createProduct('Open Top',EQUIPMENT, 'OT');
            prodOpenTop.Is_Pricing_Eligible__c = true;
            prdList.add(prodOpenTop);

            Product2 prodCompactor = TestDataFactory.createProduct('Compactor',EQUIPMENT, 'CMP');
            prodCompactor.Is_Pricing_Eligible__c = true;
            prdList.add(prodCompactor);

            Product2 prodDumpster = TestDataFactory.createProduct('Dumpster',EQUIPMENT, 'DMP');
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

            Product2 prodDelivery= TestDataFactory.createProduct('Delivery',SERVICES,'DLV');
            prdList.add(prodDelivery);

            Product2 prodTrash = TestDataFactory.createProduct('Trash','Waste Stream','T');
            prodTrash.Is_Pricing_Eligible__c = true;
            prdList.add(prodTrash);

            //Addition for S11 test class errors
            Product2 trashWC = TestDataFactory.createProduct('Trash','Waste Category','TW');
            prdList.add(trashWC);

            Product2 prodCardboard = TestDataFactory.createProduct('Cardboard','Waste Stream','C');
            prodCardboard.Is_Pricing_Eligible__c = true;
            prdList.add(prodCardboard);

            //Addition for S11 test class errors
            Product2 CardboardWC = TestDataFactory.createProduct('Cardboard','Waste Category','CARDBOARD');
            prdList.add(CardboardWC);

            Database.insert(prdList);

            //RecurrsiveTriggerHandler.bypassValidationQuoteLine = true;

            List<SBQQ__QuoteLine__c> qlHdr = new List<SBQQ__QuoteLine__c>();
            //Bundle 2 - Dumpster
            SBQQ__QuoteLine__c qlDMP = TestDataFactory.createQuoteLineRecords(quoteList[0],prodDumpster,'PERM',1.00,'CLT','YRDS-4','SCH','M','1','PER',34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
            qlDMP.SBQQ__Bundle__c = TRUE;
            qlDMP.SBQQ__RequiredBy__c = null;
            qlDMP.Vendor__c = vendorAcc.Id;
            qlHdr.add(qlDMP);

            //Bundle 1 - Open Top
            SBQQ__QuoteLine__c qlOT = TestDataFactory.createQuoteLineRecords(quoteList[0],prodOpenTop,'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
            qlOT.SBQQ__Bundle__c = TRUE;
            qlOT.SBQQ__RequiredBy__c = null;
            qlOT.Vendor__c = vendorAcc.Id;
            qlOT.Location_Position_Name__c = accLocPosition.Id;
            qlHdr.add(qlOT);


            //Bundle 3 - Vertical Compactor
            SBQQ__QuoteLine__c qlCMPV = TestDataFactory.createQuoteLineRecords(quoteList[0],prodCompactor,'TEMP',1.00,'CLT','YRDS-20','OC',null,null,'PER',34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
            qlCMPV.SBQQ__Bundle__c = TRUE;
            qlCMPV.SBQQ__RequiredBy__c = null;
            qlCMPV.Vendor__c = vendorAcc.Id;
            qlHdr.add(qlCMPV);

            //Bundle 4 - Horizontal Compactor
            SBQQ__QuoteLine__c qlCMPH = TestDataFactory.createQuoteLineRecords(quoteList[0],prodCompactor,'TEMP',1.00,'CLT','YRDS-4',null,null,null,'PER',0,'MTH','PER',35.0,'MTH','Do Not Override','NBG');
            qlCMPH.SBQQ__Bundle__c = TRUE;
            qlCMPH.SBQQ__RequiredBy__c = null;
            qlCMPH.Vendor__c = vendorAcc.Id;
            qlHdr.add(qlCMPH);

            insert qlHdr;

            test.stoptest();

            List<SBQQ__QuoteLine__c> qlChild = new List<SBQQ__QuoteLine__c>();

            //Open Top Child Quote Line  --- Start
            //Addition for S11 test class errors	
            SBQQ__QuoteLine__c qlOTT = TestDataFactory.createQuoteLineRecords(quoteList[0],prodTrash,'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
            qlOTT.SBQQ__RequiredBy__c = qlOT.Id;
            qlOTT.Vendor__c = vendorAcc.Id;
            qlChild.add(qlOTT);

            SBQQ__QuoteLine__c qlHaul = TestDataFactory.createQuoteLineRecords(quoteList[0],prodHaul,'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
            qlHaul.SBQQ__RequiredBy__c = qlOT.Id;
            qlHaul.Vendor__c = vendorAcc.Id;
            qlChild.add(qlHaul);

            SBQQ__QuoteLine__c qlDisposal = TestDataFactory.createQuoteLineRecords(quoteList[0],prodDisposal,'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
            qlDisposal.SBQQ__RequiredBy__c = qlOT.Id;
            qlDisposal.Vendor__c = vendorAcc.Id;
            qlChild.add(qlDisposal);

            SBQQ__QuoteLine__c qlDelivery = TestDataFactory.createQuoteLineRecords(quoteList[0],prodDelivery,'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
            qlDelivery.SBQQ__RequiredBy__c = qlOT.Id;
            qlDelivery.Vendor__c = vendorAcc.Id;
            qlChild.add(qlDelivery);
            //Open Top Child Quote Line  --- End

            
            //Dumpster Child Quote Line  --- Start
            ////Addition for S11 test class errors- cardboard wc instead of ws
            SBQQ__QuoteLine__c qlDMPC = TestDataFactory.createQuoteLineRecords(quoteList[0],prodCardboard,'PERM',1.00,'CLT','YRDS-4','SCH','W','1','PER',34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
            qlDMPC.SBQQ__RequiredBy__c = qlDMP.Id;
            qlDMPC.Vendor__c = vendorAcc.Id;
            qlChild.add(qlDMPC);

            SBQQ__QuoteLine__c qlPCK = TestDataFactory.createQuoteLineRecords(quoteList[0],prodPickup,'PERM',1.00,'CLT','YRDS-4','SCH','','','PER',34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
            qlPCK.SBQQ__RequiredBy__c = qlDMP.Id;
            qlPCK.Vendor__c = vendorAcc.Id;
            qlChild.add(qlPCK);
            
            SBQQ__QuoteLine__c qlEPCK = TestDataFactory.createQuoteLineRecords(quoteList[0],prodExPickup,'PERM',1.00,'CLT','YRDS-4','SCH','','','PER',34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
            qlEPCK.SBQQ__RequiredBy__c = qlDMP.Id;
            qlEPCK.Vendor__c = vendorAcc.Id;
            qlChild.add(qlEPCK);
            //Dumpster Child Quote Line  --- End

            //Vertical Compactor Child Quote Line  --- Start
            //Addition for S11 test class errors- trash wc instead of ws
            SBQQ__QuoteLine__c qlCMPT = TestDataFactory.createQuoteLineRecords(quoteList[0],trashWC,'TEMP',1.00,'CLT','YRDS-20','OC',null,null,'PER',34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
            qlCMPT.SBQQ__RequiredBy__c = qlCMPV.Id;
            qlCMPT.Vendor__c = vendorAcc.Id;
            qlChild.add(qlCMPT);

            SBQQ__QuoteLine__c qlCMPHaul = TestDataFactory.createQuoteLineRecords(quoteList[0],prodHaul,'TEMP',1.00,'CLT','YRDS-20','OC',null,null,'PER',34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
            qlCMPHaul.SBQQ__RequiredBy__c = qlCMPV.Id;
            qlCMPHaul.Vendor__c = vendorAcc.Id;
            qlChild.add(qlCMPHaul);
            //Vertical  Compactor Child Quote Line  --- End

            //Horizontal Compactor Child Quote Line  --- Start
            //Addition for S11 test class errors- trash wc instead of ws
            SBQQ__QuoteLine__c qlCMPHT = TestDataFactory.createQuoteLineRecords(quoteList[0],trashWC,'TEMP',1.00,'CLT','YRDS-4',null,null,null,'PER',0,'MTH','PER',35.0,'MTH','Do Not Override','NBG');
            qlCMPHT.SBQQ__RequiredBy__c = qlCMPH.Id;
            qlCMPHT.Vendor__c = vendorAcc.Id;
            qlChild.add(qlCMPHT);

            SBQQ__QuoteLine__c qlCMPHHaul = TestDataFactory.createQuoteLineRecords(quoteList[0],prodHaul,'TEMP',1.00,'CLT','YRDS-4',null,null,null,'PER',0,'MTH','PER',35.0,'MTH','Do Not Override','NBG');
            qlCMPHHaul.SBQQ__RequiredBy__c = qlCMPH.Id;
            qlCMPHHaul.Vendor__c = vendorAcc.Id;
            qlChild.add(qlCMPHHaul);

            SBQQ__QuoteLine__c qlCMPHPCK = TestDataFactory.createQuoteLineRecords(quoteList[0],prodPickup,'TEMP',1.00,'CLT','YRDS-4',null,null,null,'PER',0,'MTH','PER',35.0,'MTH','Do Not Override','NBG');
            qlCMPHPCK.SBQQ__RequiredBy__c = qlCMPH.Id;
            qlCMPHPCK.Vendor__c = vendorAcc.Id;
            qlChild.add(qlCMPHPCK);

            //Horizontal  Compactor Child Quote Line  --- End

            Database.insert(qlChild);      

            //System.debug('New Quote Line ' + qlChild);     

            List<Pricing_Request__c> createPRList = new List<Pricing_Request__c>();

            //Open Top Valid Data - Asset Management
            Pricing_Request__c pReq1 = TestDataFactory.createPricingRequestRecord(newServiceCase, acclist[0], locationlist[0], ROLLOFF, 'AM', '', JSON_VALID_ROLLOFF_DATA, usr);
            pReq1.Service_City__c = 'Test OT AM';
            createPRList.add(pReq1);

            //Dumpster Valid Data - Asset Management
            Pricing_Request__c pReq2 = TestDataFactory.createPricingRequestRecord(newServiceCase, acclist[0], locationlist[0], COMMERCIAL, 'AM', '', JSON_VALID_COMMERCIAL_DATA, usr);
            pReq2.Service_City__c = 'Test DMP AM';
            createPRList.add(pReq2);

            //Open Top Valid Data - Asset Management Price Only
            Pricing_Request__c pReq3 = TestDataFactory.createPricingRequestRecord(newServiceCase, acclist[0], locationlist[0], ROLLOFF, 'AMPO', '', JSON_VALID_ROLLOFF_DATA, usr);
            pReq3.Service_City__c = 'Test OT AMPO';
            createPRList.add(pReq3);

            //Dumpster Valid Data - Asset Management Price Only
            Pricing_Request__c pReq4 = TestDataFactory.createPricingRequestRecord(newServiceCase, acclist[0], locationlist[0], COMMERCIAL, 'AMPO', '', JSON_VALID_COMMERCIAL_DATA, usr);
            pReq4.Service_City__c = 'Test DMP AMPO';
            createPRList.add(pReq4);

            //Open Top - Invalid data "No Cost" Message
            Pricing_Request__c pReq5 = TestDataFactory.createPricingRequestRecord(newServiceCase, acclist[0], locationlist[0], ROLLOFF, 'AM', '', JSON_INVALID_DATA, usr);
            pReq5.isAPIResult__c =false;
            pReq5.Service_City__c = 'Test AM Invalid Data';
            createPRList.add(pReq5);

            //Open Top - Invalid data "PROS" Message
            Pricing_Request__c pReq6 = TestDataFactory.createPricingRequestRecord(newServiceCase, acclist[0], locationlist[0], ROLLOFF, 'AM', '', JSON_INVALID_DATA_PROS, usr);
            pReq6.isAPIResult__c =false;
            pReq6.Service_City__c = 'Test AM Invalid Pros';
            createPRList.add(pReq6);

            //Vertical Compactor - Valid data
            Pricing_Request__c pReq7 = TestDataFactory.createPricingRequestRecord(newServiceCase, acclist[0], locationlist[0], ROLLOFF, 'AM', '', JSON_ROLLOFF_COMPACTOR_DATA, usr);
            pReq7.Container_Type__c = 'CMP';
            pReq7.Container_Size__c = 'YRDS-20';
            createPRList.add(pReq7);

            //Open Top - Data for  "WM FRANCHISE" Message
            Pricing_Request__c pReq8 = TestDataFactory.createPricingRequestRecord(newServiceCase, acclist[0], locationlist[0], ROLLOFF, 'AM', '', JSON_WM_FRANCHISE, usr);
            pReq8.Zone_Type__c = 'wm franchise';
            createPRList.add(pReq8);

            //Open Top - Data for  "COMPITITOR" Message
            Pricing_Request__c pReq9 = TestDataFactory.createPricingRequestRecord(newServiceCase, acclist[0], locationlist[0], ROLLOFF, 'AM', '', JSON_COMPITITOR, usr);
            pReq9.Zone_Type__c = 'competitor';
            createPRList.add(pReq9);

            //Open Top - Data for  "Third_Party_Agreement" Message
            Pricing_Request__c pReq10 = TestDataFactory.createPricingRequestRecord(newServiceCase, acclist[0], locationlist[0], ROLLOFF, 'AM', '', JSON_TPAGREEMENT, usr);
            pReq10.Zone_Type__c = 'third -party agreement';
            createPRList.add(pReq10);

            //Open Top - Data for  "Pre_Determined_Pricing" Message
            Pricing_Request__c pReq11 = TestDataFactory.createPricingRequestRecord(newServiceCase, acclist[0], locationlist[0], ROLLOFF, 'AM', '', JSON_PDPRICING, usr);
            pReq11.Zone_Type__c = 'pre-determined pricing';
            createPRList.add(pReq11);

            //Open Top AM - Data for  "Substitute Container Size" Message
            Pricing_Request__c pReq12 = TestDataFactory.createPricingRequestRecord(newServiceCase, acclist[0], locationlist[0], ROLLOFF, 'AM', '', JSON_SUBSTITUTE_SIZE, usr);
            pReq12.Service_City__c = 'Test AM Substitute';
            createPRList.add(pReq12);

            //Open Top AMPO - Data for  "Substitute Container Size" Message
            Pricing_Request__c pReq13 = TestDataFactory.createPricingRequestRecord(newServiceCase, acclist[0], locationlist[0], ROLLOFF, 'AMPO', '', JSON_SUBSTITUTE_SIZE, usr);
            pReq13.Service_City__c = 'Test AMPO Substitute';
            createPRList.add(pReq13);

            //Open Top - Data for  "WM FRANCHISE" Message
            Pricing_Request__c pReq14 = TestDataFactory.createPricingRequestRecord(newServiceCase, acclist[0], locationlist[0], ROLLOFF, 'AMPO', '', JSON_WM_FRANCHISE, usr);
            pReq14.Zone_Type__c = 'wm franchise';
            createPRList.add(pReq14);

            //Open Top - Data for  "COMPITITOR" Message
            Pricing_Request__c pReq15 = TestDataFactory.createPricingRequestRecord(newServiceCase, acclist[0], locationlist[0], ROLLOFF, 'AMPO', '', JSON_COMPITITOR, usr);
            pReq15.Zone_Type__c = 'competitor';
            createPRList.add(pReq15);

            //Open Top - Data for  "Third_Party_Agreement" Message
            Pricing_Request__c pReq16 = TestDataFactory.createPricingRequestRecord(newServiceCase, acclist[0], locationlist[0], ROLLOFF, 'AMPO', '', JSON_TPAGREEMENT, usr);
            pReq16.Zone_Type__c = 'third -party agreement';
            createPRList.add(pReq16);

            //Open Top - Data for  "Pre_Determined_Pricing" Message
            Pricing_Request__c pReq17 = TestDataFactory.createPricingRequestRecord(newServiceCase, acclist[0], locationlist[0], ROLLOFF, 'AMPO', '', JSON_PDPRICING, usr);
            pReq17.Zone_Type__c = 'pre-determined pricing';
            createPRList.add(pReq17);
            
            //Open Top - Invalid data "No Cost" Message
            Pricing_Request__c pReq18 = TestDataFactory.createPricingRequestRecord(newServiceCase, acclist[0], locationlist[0], ROLLOFF, 'AMPO', '', JSON_INVALID_DATA, usr);
            pReq18.isAPIResult__c =false;
            pReq18.Service_City__c = 'Test AMPO Invalid Data';
            createPRList.add(pReq18);

            //Open Top - Invalid data "PROS" Message
            Pricing_Request__c pReq19 = TestDataFactory.createPricingRequestRecord(newServiceCase, acclist[0], locationlist[0], ROLLOFF, 'AMPO', '', JSON_INVALID_DATA_PROS, usr);
            pReq19.isAPIResult__c =false;
            pReq19.Service_City__c = 'Test AMPO Invalid Pros';
            createPRList.add(pReq19);
            Database.insert(createPRList);

        }
    }
    @isTest static void testgetQuotePricingDetail(){
        User usr = [SELECT Id, Bypass_Validation__c FROM User WHERE Bypass_Validation__c = true LIMIT 1];

        System.runAs(usr){
            SBQQ__Quote__c quoteData = [SELECT Id FROM SBQQ__Quote__c limit 1];
            List<Pricing_Request__c> prData = [SELECT Id, Quote__c, Quote_Line_Bundle__c, APIRequestOutput__c FROM Pricing_Request__c WHERE Pricing_Type__c = 'AM' LIMIT 1];
            List<SBQQ__QuoteLine__c> qlData = [SELECT Id FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quoteData.Id AND SBQQ__RequiredBy__c = NULL AND (SBQQ__ProductCode__c = 'OT' OR SBQQ__ProductCode__c = 'DMP') LIMIT 2];

            Test.startTest();
                prData[0].Quote__c = quoteData.id;
                prData[0].Quote_Line_Bundle__c = qlData[0].id;                
                update prData;

                List<PricingRequestSTPProcess.QuotePricingWrapper> qlipwrapper = ProcessQLIPricingRequest.getQuotePricingDetail(quoteData.id);
            
                system.assert(qlipwrapper != null);
            Test.stopTest();
        }
    }
    @isTest static void testgetPricingResponseStatus_MV(){
        User usr = [SELECT Id, Bypass_Validation__c FROM User WHERE Bypass_Validation__c = true LIMIT 1];

        System.runAs(usr){
            SBQQ__Quote__c quoteData = [SELECT Id FROM SBQQ__Quote__c limit 1];
            List<Pricing_Request__c> prData = [SELECT Id, Quote__c, Quote_Line_Bundle__c, APIRequestOutput__c FROM Pricing_Request__c WHERE Pricing_Type__c = 'AM' LIMIT 1];
            List<SBQQ__QuoteLine__c> qlData = [SELECT Id FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quoteData.Id AND SBQQ__RequiredBy__c = NULL AND (SBQQ__ProductCode__c = 'OT' OR SBQQ__ProductCode__c = 'DMP') LIMIT 2];

            Test.startTest();
                Code_Switch__c multiVendorPricingSwitch = QuoteTestDataFactory.createCodeSwitch('Pricing MulltiVendor AM Switch', false);
                Insert multiVendorPricingSwitch;
                prData[0].Quote__c = quoteData.id;
                prData[0].Quote_Line_Bundle__c = qlData[0].id;
                // prData[1].Quote__c = quoteData.id;
                // prData[1].Quote_Line_Bundle__c = qlData[1].id;
                prData[0].Vendor_Code__c = '3708';
                prData[0].APIRequestOutput__c = JSON_VALID_ROLLOFF_DATA_MV;
                prData[0].Zone_Type__c = 'Open Market';
                update prData;

                List<ProcessQLIPricingRequest.QLIPricingWrapper> qlipwrapper = ProcessQLIPricingRequest.getPricingResponseStatus(quoteData.id);
            
                system.assert(qlipwrapper != null);
            Test.stopTest();
        }
    }
    @isTest static void testgetPricingResponseStatus_WMFranchise(){
        User usr = [SELECT Id, Bypass_Validation__c FROM User WHERE Bypass_Validation__c = true LIMIT 1];

        System.runAs(usr){
            SBQQ__Quote__c quoteData = [SELECT Id FROM SBQQ__Quote__c limit 1];
            List<Pricing_Request__c> prData = [SELECT Id, Quote__c, Quote_Line_Bundle__c, APIRequestOutput__c FROM Pricing_Request__c WHERE Pricing_Type__c = 'AM' LIMIT 1];
            List<SBQQ__QuoteLine__c> qlData = [SELECT Id FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quoteData.Id AND SBQQ__RequiredBy__c = NULL AND (SBQQ__ProductCode__c = 'OT' OR SBQQ__ProductCode__c = 'DMP') LIMIT 2];

            Test.startTest();
                prData[0].Quote__c = quoteData.id;
                prData[0].Quote_Line_Bundle__c = qlData[0].id;
                prData[0].Pricing_Type__c = 'AMPO';
                prData[0].Vendor_Code__c = '3708';
                prData[0].APIRequestOutput__c = JSON_WM_FRANCHISE;
                prData[0].Zone_Type__c = 'wm franchise';
                update prData;

                List<ProcessQLIPricingRequest.QLIPricingWrapper> qlipwrapper = ProcessQLIPricingRequest.getPricingResponseStatusMultiVendor(quoteData.id);
            
                system.assert(qlipwrapper != null);
            Test.stopTest();
        }
    }
    @isTest static void testgetPricingResponseStatus_Competitor(){
        User usr = [SELECT Id, Bypass_Validation__c FROM User WHERE Bypass_Validation__c = true LIMIT 1];

        System.runAs(usr){
            SBQQ__Quote__c quoteData = [SELECT Id FROM SBQQ__Quote__c limit 1];
            List<Pricing_Request__c> prData = [SELECT Id, Quote__c, Quote_Line_Bundle__c, APIRequestOutput__c FROM Pricing_Request__c WHERE Pricing_Type__c = 'AM' LIMIT 1];
            List<SBQQ__QuoteLine__c> qlData = [SELECT Id FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quoteData.Id AND SBQQ__RequiredBy__c = NULL AND (SBQQ__ProductCode__c = 'OT' OR SBQQ__ProductCode__c = 'DMP') LIMIT 2];

            Test.startTest();
                prData[0].Quote__c = quoteData.id;
                prData[0].Quote_Line_Bundle__c = qlData[0].id;
                prData[0].Pricing_Type__c = 'AMPO';
                prData[0].Vendor_Code__c = '3708';
                prData[0].APIRequestOutput__c = JSON_COMPITITOR;
                prData[0].Zone_Type__c = 'competitor';
                update prData;

                List<ProcessQLIPricingRequest.QLIPricingWrapper> qlipwrapper = ProcessQLIPricingRequest.getPricingResponseStatusMultiVendor(quoteData.id);
            
                system.assert(qlipwrapper != null);
            Test.stopTest();
        }
    }
    @isTest static void testgetPricingResponseStatus_PDPRICING(){
        User usr = [SELECT Id, Bypass_Validation__c FROM User WHERE Bypass_Validation__c = true LIMIT 1];

        System.runAs(usr){
            SBQQ__Quote__c quoteData = [SELECT Id FROM SBQQ__Quote__c limit 1];
            List<Pricing_Request__c> prData = [SELECT Id, Quote__c, Quote_Line_Bundle__c, APIRequestOutput__c FROM Pricing_Request__c WHERE Pricing_Type__c = 'AM' LIMIT 1];
            List<SBQQ__QuoteLine__c> qlData = [SELECT Id FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quoteData.Id AND SBQQ__RequiredBy__c = NULL AND (SBQQ__ProductCode__c = 'OT' OR SBQQ__ProductCode__c = 'DMP') LIMIT 2];

            Test.startTest();
                prData[0].Quote__c = quoteData.id;
                prData[0].Quote_Line_Bundle__c = qlData[0].id;
                prData[0].Pricing_Type__c = 'AMPO';
                prData[0].Vendor_Code__c = '3708';
                prData[0].APIRequestOutput__c = JSON_PDPRICING;
                prData[0].Zone_Type__c = 'pre-determined pricing';
                update prData;

                List<ProcessQLIPricingRequest.QLIPricingWrapper> qlipwrapper = ProcessQLIPricingRequest.getPricingResponseStatusMultiVendor(quoteData.id);
            
                system.assert(qlipwrapper != null);
            Test.stopTest();
        }
    }
    @isTest static void testgetPricingResponseStatus_TPAGREEMENT(){
        User usr = [SELECT Id, Bypass_Validation__c FROM User WHERE Bypass_Validation__c = true LIMIT 1];

        System.runAs(usr){
            SBQQ__Quote__c quoteData = [SELECT Id FROM SBQQ__Quote__c limit 1];
            List<Pricing_Request__c> prData = [SELECT Id, Quote__c, Quote_Line_Bundle__c, APIRequestOutput__c FROM Pricing_Request__c WHERE Pricing_Type__c = 'AM' LIMIT 1];
            List<SBQQ__QuoteLine__c> qlData = [SELECT Id FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quoteData.Id AND SBQQ__RequiredBy__c = NULL AND (SBQQ__ProductCode__c = 'OT' OR SBQQ__ProductCode__c = 'DMP') LIMIT 2];

            Test.startTest();
                prData[0].Quote__c = quoteData.id;
                prData[0].Quote_Line_Bundle__c = qlData[0].id;
                prData[0].Pricing_Type__c = 'AMPO';
                prData[0].Vendor_Code__c = '3708';
                prData[0].APIRequestOutput__c = JSON_TPAGREEMENT;
                prData[0].Zone_Type__c = 'third -party agreement';
                update prData;

                List<ProcessQLIPricingRequest.QLIPricingWrapper> qlipwrapper = ProcessQLIPricingRequest.getPricingResponseStatusMultiVendor(quoteData.id);
            
                system.assert(qlipwrapper != null);
            Test.stopTest();
        }
    }
    @isTest static void testgetPricingResponseStatus_APIError(){
        User usr = [SELECT Id, Bypass_Validation__c FROM User WHERE Bypass_Validation__c = true LIMIT 1];

        System.runAs(usr){
            SBQQ__Quote__c quoteData = [SELECT Id FROM SBQQ__Quote__c limit 1];
            List<Pricing_Request__c> prData = [SELECT Id, Quote__c, Quote_Line_Bundle__c, APIRequestOutput__c FROM Pricing_Request__c WHERE Pricing_Type__c = 'AM' LIMIT 1];
            List<SBQQ__QuoteLine__c> qlData = [SELECT Id FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quoteData.Id AND SBQQ__RequiredBy__c = NULL AND (SBQQ__ProductCode__c = 'OT' OR SBQQ__ProductCode__c = 'DMP') LIMIT 2];

            Test.startTest();
                prData[0].Quote__c = quoteData.id;
                prData[0].Quote_Line_Bundle__c = qlData[0].id;
                prData[0].Pricing_Type__c = 'AMPO';
                prData[0].isAPIResult__c = false;
                update prData;

                List<ProcessQLIPricingRequest.QLIPricingWrapper> qlipwrapper = ProcessQLIPricingRequest.getPricingResponseStatusMultiVendor(quoteData.id);
            
                system.assert(qlipwrapper != null);
            Test.stopTest();
        }
    }
    @isTest static void testgetPricingResponseStatus(){
        User usr = [SELECT Id, Bypass_Validation__c FROM User WHERE Bypass_Validation__c = true LIMIT 1];

        System.runAs(usr){
            SBQQ__Quote__c quoteData = [SELECT Id FROM SBQQ__Quote__c limit 1];
            List<Pricing_Request__c> prData = [SELECT Id, Quote__c, Quote_Line_Bundle__c FROM Pricing_Request__c WHERE Pricing_Type__c = 'AM'];
            List<SBQQ__QuoteLine__c> qlData = [SELECT Id FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quoteData.Id AND SBQQ__RequiredBy__c = NULL AND (SBQQ__ProductCode__c = 'OT' OR SBQQ__ProductCode__c = 'DMP') LIMIT 2];

            Test.startTest();
                prData[0].Quote__c = quoteData.id;
                prData[0].Quote_Line_Bundle__c = qlData[0].id;
                prData[1].Quote__c = quoteData.id;
                prData[1].Quote_Line_Bundle__c = qlData[1].id;
                update prData;

                List<ProcessQLIPricingRequest.QLIPricingWrapper> qlipwrapper = ProcessQLIPricingRequest.getPricingResponseStatus(quoteData.id);
            
                system.assert(qlipwrapper != null);
            Test.stopTest();
        }
    }
    @isTest static void testgetPricingResponseStatusError(){
        User usr = [SELECT Id, Bypass_Validation__c FROM User WHERE Bypass_Validation__c = true LIMIT 1];

        System.runAs(usr){
            SBQQ__Quote__c quoteData = [SELECT Id FROM SBQQ__Quote__c limit 1];
            Pricing_Request__c prData = [SELECT Id, Quote__c, Quote_Line_Bundle__c, APIRequestOutput__c FROM Pricing_Request__c WHERE Pricing_Type__c = 'AM' AND Service_City__c = 'Test AM Invalid Pros' LIMIT 1];
            SBQQ__QuoteLine__c qlData = [SELECT Id FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quoteData.Id AND SBQQ__RequiredBy__c = NULL AND SBQQ__ProductCode__c = 'OT' LIMIT 2];

            Test.startTest();
                prData.Quote__c = quoteData.id;
                prData.Quote_Line_Bundle__c = qlData.id;
                prData.Quote_Line_Bundle__c = qlData.id;
                
                update prData;

                List<ProcessQLIPricingRequest.QLIPricingWrapper> qlipwrapper = ProcessQLIPricingRequest.getPricingResponseStatus(quoteData.id);
            
                system.assert(qlipwrapper != null);
            Test.stopTest();
        }
    }
    @isTest static void testPricingResponseStatusWMFranchise(){
        User usr = [SELECT Id, Bypass_Validation__c FROM User WHERE Bypass_Validation__c = true LIMIT 1];
        System.runAs(usr){
            SBQQ__Quote__c quoteData = [SELECT Id FROM SBQQ__Quote__c limit 1];
            SBQQ__QuoteLine__c qlData = [SELECT Id FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quoteData.Id AND SBQQ__ProductCode__c = 'OT' LIMIT 1];            
            Pricing_Request__c prData = [SELECT Id, Quote_Line_Bundle__c FROM Pricing_Request__c WHERE Pricing_Type__c = 'AM' AND Zone_Type__c = 'wm franchise' LIMIT 1];
                    
            Test.startTest();
                prData.Quote__c = quoteData.id;
                prData.Quote_Line_Bundle__c = qlData.id;
                update prData;    

                List<ProcessQLIPricingRequest.QLIPricingWrapper> qlipwrapper = ProcessQLIPricingRequest.getPricingResponseStatus(quoteData.id);
           
                system.assert(qlipwrapper != null);
            Test.stopTest();
        }
    }
    @isTest static void testPricingResponseStatusCompetitor(){
        User usr = [SELECT Id, Bypass_Validation__c FROM User WHERE Bypass_Validation__c = true LIMIT 1];
        System.runAs(usr){
            SBQQ__Quote__c quoteData = [SELECT Id FROM SBQQ__Quote__c limit 1];
            SBQQ__QuoteLine__c qlData = [SELECT Id FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quoteData.Id AND SBQQ__ProductCode__c = 'OT' LIMIT 1];            
            Pricing_Request__c prData = [SELECT Id, Quote_Line_Bundle__c FROM Pricing_Request__c WHERE Pricing_Type__c = 'AM' AND Zone_Type__c = 'competitor' LIMIT 1];
                    
            Test.startTest();
                prData.Quote__c = quoteData.id;
                prData.Quote_Line_Bundle__c = qlData.id;
                update prData;    

                List<ProcessQLIPricingRequest.QLIPricingWrapper> qlipwrapper = ProcessQLIPricingRequest.getPricingResponseStatus(quoteData.id);
           
                system.assert(qlipwrapper != null);
            Test.stopTest();
        }
    }
    @isTest static void testPricingResponseStatus3P(){
        User usr = [SELECT Id, Bypass_Validation__c FROM User WHERE Bypass_Validation__c = true LIMIT 1];
        System.runAs(usr){
            SBQQ__Quote__c quoteData = [SELECT Id FROM SBQQ__Quote__c limit 1];
            SBQQ__QuoteLine__c qlData = [SELECT Id FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quoteData.Id AND SBQQ__ProductCode__c = 'OT' LIMIT 1];            
            Pricing_Request__c prData = [SELECT Id, Quote_Line_Bundle__c FROM Pricing_Request__c WHERE Pricing_Type__c = 'AM' AND Zone_Type__c = 'third -party agreement' LIMIT 1];
                    
            Test.startTest();
                prData.Quote__c = quoteData.id;
                prData.Quote_Line_Bundle__c = qlData.id;
                update prData;    

                List<ProcessQLIPricingRequest.QLIPricingWrapper> qlipwrapper = ProcessQLIPricingRequest.getPricingResponseStatus(quoteData.id);
           
                system.assert(qlipwrapper != null);
            Test.stopTest();
        }
    }
    @isTest static void testPricingResponseStatusPDP(){
        User usr = [SELECT Id, Bypass_Validation__c FROM User WHERE Bypass_Validation__c = true LIMIT 1];
        System.runAs(usr){
            SBQQ__Quote__c quoteData = [SELECT Id FROM SBQQ__Quote__c limit 1];
            SBQQ__QuoteLine__c qlData = [SELECT Id FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quoteData.Id AND SBQQ__ProductCode__c = 'OT' LIMIT 1];            
            Pricing_Request__c prData = [SELECT Id, Quote_Line_Bundle__c FROM Pricing_Request__c WHERE Pricing_Type__c = 'AM' AND Zone_Type__c = 'pre-determined pricing' LIMIT 1];
                    
            Test.startTest();
                prData.Quote__c = quoteData.id;
                prData.Quote_Line_Bundle__c = qlData.id;
                update prData;    

                List<ProcessQLIPricingRequest.QLIPricingWrapper> qlipwrapper = ProcessQLIPricingRequest.getPricingResponseStatus(quoteData.id);
           
                system.assert(qlipwrapper != null);
            Test.stopTest();
        }
    }
    @isTest static void testgetQuotePriceOnlyDetailRollOff(){
        User usr = [SELECT Id, Bypass_Validation__c FROM User WHERE Bypass_Validation__c = true LIMIT 1];       

        System.runAs(usr){
            SBQQ__Quote__c quoteData = [SELECT Id FROM SBQQ__Quote__c limit 1];
            SBQQ__QuoteLine__c qlData = [SELECT Id FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quoteData.Id AND SBQQ__ProductCode__c = 'OT' LIMIT 1];
            Pricing_Request__c prData = [SELECT Id, Quote_Line_Bundle__c FROM Pricing_Request__c WHERE Pricing_Type__c = 'AMPO' AND Service_City__c = 'Test OT AMPO' LIMIT 1];
            
            Test.startTest();
                prData.Quote__c = quoteData.id;
                prData.Quote_Line_Bundle__c = qlData.id;
                update prData;

                Test.setMock(HttpCalloutMock.class, new ProcessQLIAPIMock());
                List<ProcessQLIPricingRequest.QuotePricingWrapper> qlipwrapper = ProcessQLIPricingRequest.getQuotePriceOnlyDetail(prData.Quote_Line_Bundle__c);
            
                system.assert(qlipwrapper != null);
            Test.stopTest();
        }
    }

    @isTest static void testgetQuotePriceOnlyDetailCommercial(){
        User usr = [SELECT Id, Bypass_Validation__c FROM User WHERE Bypass_Validation__c = true LIMIT 1];
        System.runAs(usr){
            SBQQ__Quote__c quoteData = [SELECT Id FROM SBQQ__Quote__c limit 1];
            SBQQ__QuoteLine__c qlData = [SELECT Id FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quoteData.Id AND SBQQ__ProductCode__c = 'DMP' LIMIT 1];            
            Pricing_Request__c prData = [SELECT Id, Quote_Line_Bundle__c FROM Pricing_Request__c WHERE Pricing_Type__c = 'AMPO' AND Service_City__c = 'Test DMP AMPO' LIMIT 1];
            Test.startTest();
                prData.Quote__c = quoteData.id;
                prData.Quote_Line_Bundle__c = qlData.id;
                update prData;

                Test.setMock(HttpCalloutMock.class, new ProcessQLIAPIMock());
                List<ProcessQLIPricingRequest.QuotePricingWrapper> qlipwrapper = ProcessQLIPricingRequest.getQuotePriceOnlyDetail(prData.Quote_Line_Bundle__c);            
                system.assert(qlipwrapper != null);
            Test.stopTest();
        }
    }
    @isTest static void testgetQuotePriceOnlyDetailSubstitute(){
        User usr = [SELECT Id, Bypass_Validation__c FROM User WHERE Bypass_Validation__c = true LIMIT 1];
        System.runAs(usr){
            SBQQ__Quote__c quoteData = [SELECT Id FROM SBQQ__Quote__c limit 1];
            SBQQ__QuoteLine__c qlData = [SELECT Id FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quoteData.Id AND SBQQ__ProductCode__c = 'OT' LIMIT 1];
            Pricing_Request__c prData = [SELECT Id, Quote__c, Quote_Line_Bundle__c FROM Pricing_Request__c WHERE Pricing_Type__c = 'AMPO' AND Service_City__c = 'Test AMPO Substitute' LIMIT 1];

            Test.startTest();
                prData.Quote__c = quoteData.id;
                prData.Quote_Line_Bundle__c = qlData.id;
                update prData;

                List<ProcessQLIPricingRequest.QuotePricingWrapper> qlipwrapper = ProcessQLIPricingRequest.getQuotePriceOnlyDetail(prData.Quote_Line_Bundle__c);
            
                system.assert(qlipwrapper != null);
            Test.stopTest();
        }
    }

    @isTest static void testPriceOnlyWMFranchise(){
        User usr = [SELECT Id, Bypass_Validation__c FROM User WHERE Bypass_Validation__c = true LIMIT 1];
        System.runAs(usr){
            SBQQ__Quote__c quoteData = [SELECT Id FROM SBQQ__Quote__c limit 1];
            SBQQ__QuoteLine__c qlData = [SELECT Id FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quoteData.Id AND SBQQ__ProductCode__c = 'OT' LIMIT 1];            
            Pricing_Request__c prData = [SELECT Id, Quote_Line_Bundle__c FROM Pricing_Request__c WHERE Pricing_Type__c = 'AMPO' AND Zone_Type__c = 'wm franchise' LIMIT 1];
                    
            Test.startTest();
                prData.Quote__c = quoteData.id;
                prData.Quote_Line_Bundle__c = qlData.id;
                update prData;    

                List<ProcessQLIPricingRequest.QuotePricingWrapper> qlipwrapper = ProcessQLIPricingRequest.getQuotePriceOnlyDetail(prData.Quote_Line_Bundle__c);
           
                system.assert(qlipwrapper != null);
            Test.stopTest();
        }
    }

    @isTest static void testPriceOnlyCompititor(){
        User usr = [SELECT Id, Bypass_Validation__c FROM User WHERE Bypass_Validation__c = true LIMIT 1];
        System.runAs(usr){
            SBQQ__Quote__c quoteData = [SELECT Id FROM SBQQ__Quote__c limit 1];
            SBQQ__QuoteLine__c qlData = [SELECT Id FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quoteData.Id AND SBQQ__ProductCode__c = 'OT' LIMIT 1];            
            Pricing_Request__c prData = [SELECT Id, Quote_Line_Bundle__c FROM Pricing_Request__c WHERE Pricing_Type__c = 'AMPO' AND Zone_Type__c = 'competitor' LIMIT 1];
                        
            Test.startTest();
                prData.Quote__c = quoteData.id;
                prData.Quote_Line_Bundle__c = qlData.id;
                update prData;    

                List<ProcessQLIPricingRequest.QuotePricingWrapper> qlipwrapper = ProcessQLIPricingRequest.getQuotePriceOnlyDetail(prData.Quote_Line_Bundle__c);
            
                system.assert(qlipwrapper != null);
            Test.stopTest();
        }
    }

    @isTest static void testPriceOnly3P(){
        User usr = [SELECT Id, Bypass_Validation__c FROM User WHERE Bypass_Validation__c = true LIMIT 1];
        System.runAs(usr){
            SBQQ__Quote__c quoteData = [SELECT Id FROM SBQQ__Quote__c limit 1];
            SBQQ__QuoteLine__c qlData = [SELECT Id FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quoteData.Id AND SBQQ__ProductCode__c = 'OT' LIMIT 1];            
            Pricing_Request__c prData = [SELECT Id, Quote_Line_Bundle__c FROM Pricing_Request__c WHERE Pricing_Type__c = 'AMPO' AND Zone_Type__c = 'third -party agreement' LIMIT 1];
                        
            Test.startTest();
                prData.Quote__c = quoteData.id;
                prData.Quote_Line_Bundle__c = qlData.id;
                update prData;    

                List<ProcessQLIPricingRequest.QuotePricingWrapper> qlipwrapper = ProcessQLIPricingRequest.getQuotePriceOnlyDetail(prData.Quote_Line_Bundle__c);
            
                system.assert(qlipwrapper != null);
            Test.stopTest();
        }
    }
    @isTest static void testPriceOnlyPDP(){
        User usr = [SELECT Id, Bypass_Validation__c FROM User WHERE Bypass_Validation__c = true LIMIT 1];
        System.runAs(usr){
            SBQQ__Quote__c quoteData = [SELECT Id FROM SBQQ__Quote__c limit 1];
            SBQQ__QuoteLine__c qlData = [SELECT Id FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quoteData.Id AND SBQQ__ProductCode__c = 'OT' LIMIT 1];            
            Pricing_Request__c prData = [SELECT Id, Quote_Line_Bundle__c FROM Pricing_Request__c WHERE Pricing_Type__c = 'AMPO' AND Zone_Type__c = 'pre-determined pricing' LIMIT 1];
                        
            Test.startTest();
                prData.Quote__c = quoteData.id;
                prData.Quote_Line_Bundle__c = qlData.id;
                update prData;    

                List<ProcessQLIPricingRequest.QuotePricingWrapper> qlipwrapper = ProcessQLIPricingRequest.getQuotePriceOnlyDetail(prData.Quote_Line_Bundle__c);
            
                system.assert(qlipwrapper != null);
            Test.stopTest();
        }
    }
    @isTest static void testPriceOnlyError(){
        User usr = [SELECT Id, Bypass_Validation__c FROM User WHERE Bypass_Validation__c = true LIMIT 1];
        System.runAs(usr){
            SBQQ__Quote__c quoteData = [SELECT Id FROM SBQQ__Quote__c limit 1];
            SBQQ__QuoteLine__c qlData = [SELECT Id FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quoteData.Id AND SBQQ__ProductCode__c = 'OT' LIMIT 1];            
            Pricing_Request__c prData = [SELECT Id, Quote_Line_Bundle__c FROM Pricing_Request__c WHERE Pricing_Type__c = 'AMPO' AND Service_City__c = 'Test AMPO Invalid Data' LIMIT 1];
                    
            Test.startTest();
                prData.Quote__c = quoteData.id;
                prData.Quote_Line_Bundle__c = qlData.id;
                update prData;    

                List<ProcessQLIPricingRequest.QuotePricingWrapper> qlipwrapper = ProcessQLIPricingRequest.getQuotePriceOnlyDetail(prData.Quote_Line_Bundle__c);
           
                system.assert(qlipwrapper != null);
            Test.stopTest();
        }
    }
    @isTest static void testPriceOnlyCaseError(){
        User usr = [SELECT Id, Bypass_Validation__c FROM User WHERE Bypass_Validation__c = true LIMIT 1];
        System.runAs(usr){
            SBQQ__Quote__c quoteData = [SELECT Id FROM SBQQ__Quote__c limit 1];
            SBQQ__QuoteLine__c qlData = [SELECT Id FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quoteData.Id AND SBQQ__ProductCode__c = 'OT' LIMIT 1];            
            Pricing_Request__c prData = [SELECT Id, Quote_Line_Bundle__c FROM Pricing_Request__c WHERE Pricing_Type__c = 'AMPO' AND Service_City__c = 'Test AMPO Invalid Pros' LIMIT 1];
                    
            Test.startTest();
                prData.Quote__c = quoteData.id;
                prData.Quote_Line_Bundle__c = qlData.id;
                prData.IsCaseError__c = true;
                update prData;    

                List<ProcessQLIPricingRequest.QuotePricingWrapper> qlipwrapper = ProcessQLIPricingRequest.getQuotePriceOnlyDetail(prData.Quote_Line_Bundle__c);
           
                system.assert(qlipwrapper != null);
            Test.stopTest();
        }
    }
    @isTest static void acceptQLIPricingRequestSuccess(){
        User usr = [SELECT Id, Bypass_Validation__c FROM User WHERE Bypass_Validation__c = true LIMIT 1];

        list<ProcessQLIPricingRequest.QuotePricingWrapper> wrapperList = new list<ProcessQLIPricingRequest.QuotePricingWrapper>();
        List<ProcessQLIPricingRequest.ServiceCharges> sclst = new List<ProcessQLIPricingRequest.ServiceCharges>();

        SBQQ__Quote__c quoteData = [SELECT Id FROM SBQQ__Quote__c limit 1];
        SBQQ__QuoteLine__c qlData = [SELECT Id FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quoteData.Id AND SBQQ__ProductCode__c = 'OT' LIMIT 1];            
        Pricing_Request__c pr = [SELECT Id, Quote_Line_Bundle__c, Quote__c, APIRequestOutput__c,Service_City__c, Vendor_Code__c FROM Pricing_Request__c WHERE Service_City__c = 'Test OT AMPO' LIMIT 1];
        system.debug('@@@@@@ PR :' +pr);
        ProcessQLIPricingRequest.QuotePricingWrapper qpWrapper1 = new ProcessQLIPricingRequest.QuotePricingWrapper();
        qpWrapper1.QuoteID = quoteData.Id; //pr.Quote__c;
        qpWrapper1.BundleID = 'Q-1234';
        qpWrapper1.BundleLink = qlData.Id; //pr.Quote_Line_Bundle__c;
        qpWrapper1.PricingReqId = 'PR12345678';
        qpWrapper1.PricingRequestLink = pr.Id;
        qpWrapper1.ProductName = 'Open Top 30 Yard Temp';
 
        ProcessQLIPricingRequest.ProductDetail pd1 = new ProcessQLIPricingRequest.ProductDetail();
        pd1.StartDate = '08/02/2021';
        pd1.EndDate = '08/31/2021';
        pd1.SourceCode = 'WM';
        pd1.VendorCode = pr.Vendor_Code__c;
        pd1.Vendor = 'WMI of Livonia';
        pd1.BusinessUnit = 'B02860';
        pd1.RateTypeHaul = 'Adjusted MBP';
        pd1.RateTypeDisposal = 'Market Based Pricing';
        pd1.RateTypePickup = 'Market Based Pricing';
        pd1.EquipmentSize = '30 Yards';
        pd1.OriginalEquipmentSize = '20 Yards';
 
        ProcessQLIPricingRequest.ServiceCharges sc1 = new ProcessQLIPricingRequest.ServiceCharges();
        sc1.ServiceName = 'Haul';
        sc1.CostUOM = 'Tons';
        sc1.CostUOMCode = 'TN';
        sc1.Cost = 50;
        sc1.PriceUOM = 'Tons';
        sc1.PriceUOMCode = 'TN';
        sc1.Price = 75;
        sc1.IsSteppedRate = false;
        sc1.IsSteppedRateCost = false;
        sc1.IsSteppedRatePrice = false;
        sclst.Add(sc1);
 
        ProcessQLIPricingRequest.ServiceCharges sc2 = new ProcessQLIPricingRequest.ServiceCharges();
        sc2.ServiceName = 'Disposal';
        sc2.CostUOM = 'Tons';
        sc2.CostUOMCode = 'TN';
        sc2.Cost = 55;
        sc2.PriceUOM = 'Tons';
        sc2.PriceUOMCode = 'TN';
        sc2.Price = 95;
        sc2.IsSteppedRate = false;
        sclst.Add(sc2);
 
        ProcessQLIPricingRequest.ServiceCharges sc3 = new ProcessQLIPricingRequest.ServiceCharges();
        sc3.ServiceName = 'Container Service Charge';
        sc3.CostUOM = 'Tons';
        sc3.CostUOMCode = 'TN';
        sc3.Cost = 55;
        sc3.PriceUOM = 'Tons';
        sc3.PriceUOMCode = 'TN';
        sc3.Price = 85;
        sc3.IsSteppedRate = false;
        sclst.Add(sc3);

        ProcessQLIPricingRequest.ServiceCharges sc4 = new ProcessQLIPricingRequest.ServiceCharges();
        sc4.ServiceName = 'Pickup';
        sc4.CostUOM = 'Tons';
        sc4.CostUOMCode = 'TN';
        sc4.Cost = 55;
        sc4.PriceUOM = 'Tons';
        sc4.PriceUOMCode = 'TN';
        sc4.Price = 95;
        sc4.IsSteppedRate = false;
        sclst.Add(sc4);

        ProcessQLIPricingRequest.ServiceCharges sc5 = new ProcessQLIPricingRequest.ServiceCharges();
        sc5.ServiceName = 'Delivery';
        sc5.CostValueType = 'Percent';
        sc5.CostUOM = 'Tons';
        sc5.CostUOMCode = 'TN';
        sc5.Cost = 55;
        sc5.PriceValueType = 'Percent';
        sc5.PriceUOM = 'Tons';
        sc5.PriceUOMCode = 'TN';
        sc5.Price = 95;
        sc5.IsSteppedRate = false;
        sclst.Add(sc5);

        ProcessQLIPricingRequest.ServiceCharges sc6 = new ProcessQLIPricingRequest.ServiceCharges();
        sc6.ServiceName = 'Environment Fee';
        sc6.CostValueType = 'Amount';
        sc6.CostUOM = 'Tons';
        sc6.CostUOMCode = 'TN';
        sc6.Cost = 55;
        sc6.PriceValueType = 'Amount';
        sc6.PriceUOM = 'Tons';
        sc6.PriceUOMCode = 'TN';
        sc6.Price = 95;
        sc6.IsSteppedRate = false;
        sclst.Add(sc6);
 
        pd1.ServiceCharges = sclst;
        qpWrapper1.ProductDetails = pd1;
        wrapperList.Add(qpWrapper1);
 
        System.runAs(usr){
            Test.startTest();
                ProcessQLIPricingRequest.acceptQLIPricingRequest(wrapperList , true);
                ProcessQLIPricingRequest.acceptQLIPricingRequest(wrapperList , false);
                system.assert(wrapperList != null);

            Test.stopTest();
        }
    }

    global class ProcessQLIAPIMock implements HttpCalloutMock {
        // Implement this interface method
        global HTTPResponse respond(HTTPRequest req) {
            // String json = '{'+
            // '    \"Data\": '+
            // '        {'+
            // '            \"priceQuoteIdentifier\": \"Q127\",'+
            // '            \"supplierCode\": \"8\",'+
            // '            \"supplierName\": \"WMI\",'+
            // '            \"customerCode\": \"HMD\"'+
            // '        }'+
            // '    \"Problem\": null'+
            // '}';

            String json = '{  \"data\": {    \"priceQuoteIdentifier\": \"Q11169\",    \"costSource\": \"WM (SBS|CO|DMP|4FL|B02860|20210323|080506|640)\",    \"contractType\": \"Open Market\",    \"lineOfBusiness\": \"Commercial\",    \"supplierCode\": \"10016\",    \"supplierName\": \"WMI OF MI, LIVONIA\",    \"customerCode\": \"HMD\",    \"customerName\": \"The Home Depot\",    \"locationCode\": \"HMD002718\",    \"wasteStreamCode\": \"MSW\",    \"wasteStreamName\": \"Municipal Solid Waste\",    \"equipmentCode\": \"4FL\",    \"equipmentName\": \"4 Yard FEL\",    \"equipmentUOM\": \"Monthly\",    \"materialCode\": \"T\",    \"materialName\": \"MSW Commercial\",    \"equipmentSizeCode\": \"YRDS-4\",    \"equipmentSizeName\": \"4 Yards\",    \"overridableEquipmentSizeCode\": null,    \"overridableEquipmentSizeName\": null,    \"zoneCode\": \"GIS545664\",    \"zoneName\": \"Detroit Central - MSW FEL - Wayne Co Productive to Woodland\",    \"disposalFacilityType\": null,    \"disposalFacilityName\": \"[B02860] [MSW_CO] Woodland Meadows - Comm - From Det Central\",    \"commercial\": {      \"pricingMethodCode\": \"4.0\",      \"pricingMethodCodeDescription\": \"Adjusted MBP\",      \"cost\": 121.59,      \"price\": 139.83,      \"equipmentLoadingMinutes\": null,      \"equipmentAdditionalLoadingMinutes\": null,      \"estimatedWeightPerYard\": 80.02,      \"equipmentVolume\": 4.00,      \"extraPickupCost\": null,      \"extraPickupPrice\": null    },    \"rollOff\": null,    \"wmMetaData\": {      \"businessUnit\": \"B02860\",      \"masLibrary\": \"129A_WDL\",      \"francisePricingLink\": \"\",      \"greenPagesLink\": \"\"    },    \"tpMetaData\": null,    \"serviceCharges\": [      {        \"code\": \"FU_C_PERM_OPEN\",        \"name\": \"Fuel Fee\",        \"componentTypeCode\": \"ENS\",        \"componentTypeName\": \"Energy Surcharge\",        \"actionCode\": \"EX\",        \"actionName\": \"Exclude\",        \"cost\": null,        \"costValueType\": null,        \"costUOM\": null,        \"price\": null,        \"priceValueType\": null,        \"priceUOM\": null      },      {        \"code\": \"ENV_C_PERM_OPEN\",        \"name\": \"Environmental Fee\",        \"componentTypeCode\": \"ENV_FEE\",        \"componentTypeName\": \"Environmental Fee\",        \"actionCode\": \"EX\",        \"actionName\": \"Exclude\",        \"cost\": null,        \"costValueType\": null,        \"costUOM\": null,        \"price\": null,        \"priceValueType\": null,        \"priceUOM\": null      },      {        \"code\": \"MNT_C_PERM_OPEN_R\",        \"name\": \"Minimum Tons Recycling\",        \"componentTypeCode\": \"DSP\",        \"componentTypeName\": \"Disposal\",        \"actionCode\": \"EX\",        \"actionName\": \"Exclude\",        \"cost\": null,        \"costValueType\": null,        \"costUOM\": null,        \"price\": null,        \"priceValueType\": null,        \"priceUOM\": null      },      {        \"code\": \"MNT_C_PERM_OPEN_T\",        \"name\": \"All Other Minimum Tonnage\",        \"componentTypeCode\": \"DSP\",        \"componentTypeName\": \"Disposal\",        \"actionCode\": \"EX\",        \"actionName\": \"Exclude\",        \"cost\": null,        \"costValueType\": null,        \"costUOM\": null,        \"price\": null,        \"priceValueType\": null,        \"priceUOM\": null      },      {        \"code\": \"LF_C_PERM_OPEN\",        \"name\": \"Landfill Fee\",        \"componentTypeCode\": \"LF\",        \"componentTypeName\": \"Landfill Fee\",        \"actionCode\": \"AL\",        \"actionName\": \"Allow\",        \"cost\": null,        \"costValueType\": null,        \"costUOM\": null,        \"price\": null,        \"priceValueType\": null,        \"priceUOM\": null      },      {        \"code\": \"FF_C_PERM_OPEN\",        \"name\": \"Franchise Fee\",        \"componentTypeCode\": \"FF\",        \"componentTypeName\": \"Franchise Fee\",        \"actionCode\": \"AL\",        \"actionName\": \"Allow\",        \"cost\": null,        \"costValueType\": null,        \"costUOM\": null,        \"price\": null,        \"priceValueType\": null,        \"priceUOM\": null      },      {        \"code\": \"IF_C_PERM_OPEN\",        \"name\": \"Inactivity Fee (Monthly or Daily Charge for roll off when no Hauls are performed)\",        \"componentTypeCode\": \"IF\",        \"componentTypeName\": \"Inactivity Fee\",        \"actionCode\": \"EX\",        \"actionName\": \"Exclude\",        \"cost\": null,        \"costValueType\": null,        \"costUOM\": null,        \"price\": null,        \"priceValueType\": null,        \"priceUOM\": null      },      {        \"code\": \"SSF_C_PERM_OPEN\",        \"name\": \"Snapshot Fee\",        \"componentTypeCode\": \"SSF\", '+
            '       \"componentTypeName\": \"Snapshot Fee\",        \"actionCode\": \"ADJ\",        \"actionName\": \"Adjust\",        \"cost\": null,        \"costValueType\": null,        \"costUOM\": null,        \"price\": 75.0000,        \"priceValueType\": \"Amount\",        \"priceUOM\": null      },      {        \"code\": \"GT_C_PERM_OPEN\",        \"name\": \"Generator Tax\",        \"componentTypeCode\": \"UNK\",        \"componentTypeName\": \"Unknown\",        \"actionCode\": \"AL\",        \"actionName\": \"Allow\",        \"cost\": null,        \"costValueType\": null,        \"costUOM\": null,        \"price\": null,        \"priceValueType\": null,        \"priceUOM\": null      },      {        \"code\": \"RMO_C_PERM_OPEN\",        \"name\": \"Recyable Material Offset\",        \"componentTypeCode\": \"UNK\",        \"componentTypeName\": \"Unknown\",        \"actionCode\": \"EX\",        \"actionName\": \"Exclude\",        \"cost\": null,        \"costValueType\": null,        \"costUOM\": null,        \"price\": null,        \"priceValueType\": null,        \"priceUOM\": null      },      {        \"code\": \"RCR_C_PERM_OPEN\",        \"name\": \"Regulatory Cost Recovery\",        \"componentTypeCode\": \"UNK\",        \"componentTypeName\": \"Unknown\",        \"actionCode\": \"EX\",        \"actionName\": \"Exclude\",        \"cost\": null,        \"costValueType\": null,        \"costUOM\": null,        \"price\": null,        \"priceValueType\": null,        \"priceUOM\": null      },      {        \"code\": \"REM_C_PERM_OPEN\",        \"name\": \"Container Removal\",        \"componentTypeCode\": \"REM\",        \"componentTypeName\": \"Removal\",        \"actionCode\": \"ADJ\",        \"actionName\": \"Adjust\",        \"cost\": null,        \"costValueType\": null,        \"costUOM\": null,        \"price\": 15.0000,        \"priceValueType\": \"Percent\",        \"priceUOM\": null      },      {        \"code\": \"ACT_C_PERM_OPEN\",        \"name\": \"Activation Fee\",        \"componentTypeCode\": \"UNK\",        \"componentTypeName\": \"Unknown\",        \"actionCode\": \"ADJ\",        \"actionName\": \"Adjust\",        \"cost\": null,        \"costValueType\": null,        \"costUOM\": null,        \"price\": 15.0000,        \"priceValueType\": \"Percent\",        \"priceUOM\": null      },      {        \"code\": \"CRR_C_PERM_OPEN\",        \"name\": \"Castor Repair/Replacement\",        \"componentTypeCode\": \"UNK\",        \"componentTypeName\": \"Unknown\",        \"actionCode\": \"EX\",        \"actionName\": \"Exclude\",        \"cost\": null,        \"costValueType\": null,        \"costUOM\": null,        \"price\": null,        \"priceValueType\": null,        \"priceUOM\": null      },      {        \"code\": \"CPO_C_PERM_OPEN\",        \"name\": \"Container Pull Out\",        \"componentTypeCode\": \"UNK\",        \"componentTypeName\": \"Unknown\",        \"actionCode\": \"ADJ\",        \"actionName\": \"Adjust\",        \"cost\": null,        \"costValueType\": null,        \"costUOM\": null,        \"price\": 15.0000,        \"priceValueType\": \"Percent\",        \"priceUOM\": null      },      {        \"code\": \"CSC_C_PERM_OPEN\",        \"name\": \"Container Service Charge (\\\"Rental\\\" for Roll Off Accounts)\",        \"componentTypeCode\": \"UNK\",        \"componentTypeName\": \"Unknown\",        \"actionCode\": \"MR\",        \"actionName\": \"Manual Review\",        \"cost\": null,        \"costValueType\": null,        \"costUOM\": null,        \"price\": null,        \"priceValueType\": null,        \"priceUOM\": null      },      {        \"code\": \"R_C_PERM_OPEN\",        \"name\": \"Container Service Fee (This is the \\\"Insurance\\\" or Rental for Commercial Accounts)\",        \"componentTypeCode\": \"UNK\",        \"componentTypeName\": \"Unknown\",        \"actionCode\": \"EX\",        \"actionName\": \"Exclude\",        \"cost\": null,        \"costValueType\": null,        \"costUOM\": null,        \"price\": null,        \"priceValueType\": null,        \"priceUOM\": null      },      {        \"code\": \"SWO_C_PERM_OPEN\",        \"name\": \"Container Swap\",        \"componentTypeCode\": \"UNK\",        \"componentTypeName\": \"Unknown\",        \"actionCode\": \"ADJ\",        \"actionName\": \"Adjust\",        \"cost\": null,        \"costValueType\": null,        \"costUOM\": null,        \"price\": 15.0000,        \"priceValueType\": \"Percent\",        \"priceUOM\": null      },      {        \"code\": \"CWO_C_PERM_OPEN\",        \"name\": \"Container Wash\",        \"componentTypeCode\": \"UNK\",        \"componentTypeName\": \"Unknown\",        \"actionCode\": \"EX\",        \"actionName\": \"Exclude\",        \"cost\": null,        \"costValueType\": null,        \"costUOM\": null,        \"price\": null,        \"priceValueType\": null,        \"priceUOM\": null      },      {        \"code\": \"D_C_PERM_OPEN\",        \"name\": \"Delivery\",        \"componentTypeCode\": \"UNK\",        \"componentTypeName\": \"Unknown\",        \"actionCode\": \"ADJ\",        \"actionName\": \"Adjust\",        \"cost\": null,        \"costValueType\": null,'+
            '        \"costUOM\": null,        \"price\": 15.0000,        \"priceValueType\": \"Percent\",        \"priceUOM\": null      },      {        \"code\": \"EP_C_PERM_OPEN\",        \"name\": \"Expu (Extra Pick Up)\",        \"componentTypeCode\": \"UNK\",        \"componentTypeName\": \"Unknown\",        \"actionCode\": \"MR\",        \"actionName\": \"Manual Review\",        \"cost\": null,        \"costValueType\": null,        \"costUOM\": null,        \"price\": null,        \"priceValueType\": null,        \"priceUOM\": null      },      {        \"code\": \"EXLO_C_PERM_OPEN\",        \"name\": \"Extra Loose Yards\",        \"componentTypeCode\": \"UNK\",        \"componentTypeName\": \"Unknown\",        \"actionCode\": \"MR\",        \"actionName\": \"Manual Review\",        \"cost\": null,        \"costValueType\": null,        \"costUOM\": null,        \"price\": null,        \"priceValueType\": null,        \"priceUOM\": null      },      {        \"code\": \"LCK_C_PERM_OPEN\",        \"name\": \"Lock Installation Charge\",        \"componentTypeCode\": \"UNK\",        \"componentTypeName\": \"Unknown\",        \"actionCode\": \"ADJ\",        \"actionName\": \"Adjust\",        \"cost\": null,        \"costValueType\": null,        \"costUOM\": null,        \"price\": 15.0000,        \"priceValueType\": \"Percent\",        \"priceUOM\": null      },      {        \"code\": \"REL_C_PERM_OPEN\",        \"name\": \"Relocation\",        \"componentTypeCode\": \"UNK\",        \"componentTypeName\": \"Unknown\",        \"actionCode\": \"ADJ\",        \"actionName\": \"Adjust\",        \"cost\": null,        \"costValueType\": null,        \"costUOM\": null,        \"price\": 15.0000,        \"priceValueType\": \"Percent\",        \"priceUOM\": null      },      {        \"code\": \"GTF_C_PERM_OPEN\",        \"name\": \"Routine Gate Opening\",        \"componentTypeCode\": \"UNK\",        \"componentTypeName\": \"Unknown\",        \"actionCode\": \"ADJ\",        \"actionName\": \"Adjust\",        \"cost\": null,        \"costValueType\": null,        \"costUOM\": null,        \"price\": 15.0000,        \"priceValueType\": \"Percent\",        \"priceUOM\": null      },      {        \"code\": \"SDO_C_PERM_OPEN\",        \"name\": \"Service Ticket Drop Off\",        \"componentTypeCode\": \"UNK\",        \"componentTypeName\": \"Unknown\",        \"actionCode\": \"EX\",        \"actionName\": \"Exclude\",        \"cost\": null,        \"costValueType\": null,        \"costUOM\": null,        \"price\": null,        \"priceValueType\": null,        \"priceUOM\": null      },      {        \"code\": \"SSDT_C_PERM_OPEN\",        \"name\": \"Signed Service/Disposal Ticket With Invoice\",        \"componentTypeCode\": \"UNK\",        \"componentTypeName\": \"Unknown\",        \"actionCode\": \"EX\",        \"actionName\": \"Exclude\",        \"cost\": null,        \"costValueType\": null,        \"costUOM\": null,        \"price\": null,        \"priceValueType\": null,        \"priceUOM\": null      },      {        \"code\": \"TPC_C_PERM_OPEN\",        \"name\": \"Trip\",        \"componentTypeCode\": \"UNK\",        \"componentTypeName\": \"Unknown\",        \"actionCode\": \"ADJ\",        \"actionName\": \"Adjust\",        \"cost\": null,        \"costValueType\": null,        \"costUOM\": null,        \"price\": 15.0000,        \"priceValueType\": \"Percent\",        \"priceUOM\": null      },      {        \"code\": \"WT_C_PERM_OPEN\",        \"name\": \"Wait Time\",        \"componentTypeCode\": \"UNK\",        \"componentTypeName\": \"Unknown\",        \"actionCode\": \"ADJ\",        \"actionName\": \"Adjust\",        \"cost\": null,        \"costValueType\": null,        \"costUOM\": null,        \"price\": 15.0000,        \"priceValueType\": \"Percent\",        \"priceUOM\": null      },      {        \"code\": \"DEACT_C_PERM_OPEN\",        \"name\": \"Deactivation Fee\",        \"componentTypeCode\": \"UNK\",        \"componentTypeName\": \"Unknown\",        \"actionCode\": \"AL\",        \"actionName\": \"Allow\",        \"cost\": null,        \"costValueType\": null,        \"costUOM\": null,        \"price\": null,        \"priceValueType\": null,        \"priceUOM\": null      },      {        \"code\": \"CTMF_C_PERM_OPEN\",        \"name\": \"Contamination Fee\",        \"componentTypeCode\": \"COF\",        \"componentTypeName\": \"Contamination Fee\",        \"actionCode\": \"AL\",        \"actionName\": \"Allow\",        \"cost\": null,        \"costValueType\": null,        \"costUOM\": null,        \"price\": null,        \"priceValueType\": null,        \"priceUOM\": null      },      {        \"code\": \"LCKF_C_PERM_OPEN\",        \"name\": \"Locks - Monthly Charge\",        \"componentTypeCode\": \"UNK\",        \"componentTypeName\": \"Unknown\",        \"actionCode\": \"ADJ\",        \"actionName\": \"Adjust\",        \"cost\": null,        \"costValueType\": null,        \"costUOM\": null,        \"price\": 15.0000,        \"priceValueType\": \"Percent\",        \"priceUOM\": null      }    ]  },  \"problem\": null}';
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(json);
            response.setStatusCode(200);
            return response;
        }
    }
    @isTest static void testCreatePricingOnlyRequest(){
        User usr = [SELECT Id, Bypass_Validation__c, FirstName FROM User WHERE Bypass_Validation__c =: true AND FirstName =: 'testuser#9999' LIMIT 1];
        //Addition for S11 test class error -start
        Product2 trashWS = [SELECT Id,Name,Family,ProductCode FROM Product2 WHERE ProductCode ='T'];
        List<SBQQ__Quote__c> quoteList = [SELECT Id,SBQQ__ShippingCity__c,SBQQ__Account__c,SBQQ__StartDate__c 
                                          From SBQQ__Quote__c WHERE SBQQ__ShippingCity__c = 'Test1' LIMIT 1];
        //Addition for S11 test class error -end
        System.runAs(usr){
            Test.startTest();
            SBQQ__QuoteLine__c qlData = [SELECT Id FROM SBQQ__QuoteLine__c WHERE SBQQ__ProductCode__c ='CMP' AND 
                                         Equipment_Size__c = 'YRDS-4' limit 1];
            //Addition for S11 test class error -start
            List<SBQQ__QuoteLine__c>  qlTrashWC = [select Id,Vendor__c,SBQQ__Quote__c,SBQQ__ProductCode__c,SBQQ__RequiredBy__r.SBQQ__ProductCode__c 
                                                   FROM SBQQ__QuoteLine__c 
                                                   where SBQQ__ProductFamily__c = 'Waste Category' AND SBQQ__ProductCode__c='TW' 
                                                   AND SBQQ__RequiredBy__c =:qlData.Id LIMIT 1];
            
            SBQQ__QuoteLine__c qlTrashWS = TestDataFactory.createQuoteLineRecords(quoteList[0],trashWS,'TEMP',1.00,'CLT','YRDS-20','OC',null,null,'PER',34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
            qlTrashWS.SBQQ__RequiredBy__c = qlTrashWC[0].Id;
            qlTrashWS.Vendor__c = qlTrashWC[0].Vendor__c;
            Database.insert(qlTrashWS);
            //Addition for S11 test class error -end

                ProcessQLIPricingRequest.CreatePricingOnlyRequest(qlData.id,'OTH','Test Description');
                SBQQ__QuoteLine__c qc = [SELECT Id, Price_Only_Reason__c FROM SBQQ__QuoteLine__c where id =: qlData.id limit 1];
                system.assert(qc.Price_Only_Reason__c == 'OTH');
            Test.stopTest();
        }
    }
    @isTest static void testgetPriceOnlyReasonList(){
        User usr = [SELECT Id, Bypass_Validation__c FROM User WHERE Bypass_Validation__c = true LIMIT 1];
        Map<String,String> PriceOnlyReason = new Map<String,String>();
        ProcessQLIPricingRequest.QuotePricingWrapper wrapper =new ProcessQLIPricingRequest.QuotePricingWrapper();
        System.runAs(usr){
            Test.startTest();
            wrapper = ProcessQLIPricingRequest.getPriceOnlyReasonList();
                if(wrapper != null){
                    PriceOnlyReason =  wrapper.PriceOnlyReason;
                }
                system.assert(PriceOnlyReason != null);
            Test.stopTest();
        }
    }    
}