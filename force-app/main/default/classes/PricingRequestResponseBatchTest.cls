@isTest(seeAllData=false)
global class PricingRequestResponseBatchTest {
    private static final string SYS_ADMIN = 'System Administrator';
    private static final string SPECIAL_INS ='Test Special Instructions';
    private static final string CHANNEL_INFO ='Test Channel Instructions';
    private static final string OTHER ='Other';
    private static final string TEST_NAME ='Test';
    private static final String LOCATION = 'Location';
    private static final String NUM_123 = '123';
    private static final String ACC_NUMBER = '1236';
    private static final String CONTACT_NOT_ONSITE = 'Contact Not Onsite';
    private static final String CONTACT = 'Contact';
    private static final string ROLL_OFF = 'Rolloff';
    private static final string OPEN_TOP = 'Open Top';
    private static final string New_Service_Case = 'New Service Case';
    private static final string New_Service = 'New Service';
    private static final string OPEN = 'Open';
    private static final string PERMANENT = 'PERM';
    private static final string ON_CALL = 'On-Call';
    private static final string TRASH = 'Trash';
    private static final string Yards_30 = '30 Yards';
    private static final string PHONE_NINE = '9999999999';
    private static final string STR_PHONE_THREE = '3333333333';
	private static final string STR_STATUS = 'Active';
	private static final string STR_PHONE_ONE = '1111111111';
	private static final string STR_ACCOUNT_NUMBER = 'Location';
	private static final string STR_COUNTRY_US = 'United States';
	private static final string STR_POSTAL_CODE = '01234';
	private static final string STR_STATE = 'Florida';
	private static final string STR_CITY = 'Test City';
	private static final string STR_STREET = 'Test Street';
    private static final string NAISC_31 = '31';
    private static final string json_Valid = '{\r\n  \"data\": {\r\n    \"priceQuoteIdentifier\": \"Q215\",\r\n    \"supplierCode\": \"8\",\r\n    \"supplierName\": \"WMI\",\r\n    \"customerCode\": \"HMD\",\r\n    \"customerName\": \"The Home Depot\",\r\n    \"locationCode\": \"HMD002706\",\r\n    \"costSource\": \"WM (SBS|RO|OT|30O|B02860|20200901|050638|5411)\",\r\n    \"pricingMethodDisposalCode\": \"1.0\",\r\n    \"pricingMethodDisposalDescription\": \"Market Based Pricing\",\r\n    \"pricingMethodHaulingCode\": \"1.0\",\r\n    \"pricingMethodHaulingDescription\": \"Market Based Pricing\",\r\n    \"haulCost\": 345.82,\r\n    \"disposalCost\": 30.71,\r\n    \"haulPrice\": null,\r\n    \"disposalPrice\": null,\r\n    \"equipmentUOM\": \"Tons\",\r\n    \"estimatedVolumePerHaul\": 4.00,\r\n    \"applyInvoiceFeesToDisposalCharges\": \"Y\",\r\n    \"applyInvoiceFeesToRentalCharges\": null,\r\n    \"dispositionType\": \"S04264_LF\",\r\n    \"dispositionName\": \"B02860|S04264_LF|129A_WDL|MSW_RO\",\r\n    \"transferSiteCode\": \"NA\",\r\n    \"businessUnit\": \"B02860\",\r\n    \"wasteStreamCode\": \"MSW_RO\",\r\n    \"wasteStreamName\": \"Municipal Solid Waste\",\r\n    \"equipmentCode\": \"30O\",\r\n    \"equipmentName\": \"30 Yard Open Top\",\r\n    \"materialName\": \"MSW - Unspecified\",\r\n    \"materialClassName\": \"MSW_MSWI_Municipal Solid Waste - Industrial\",\r\n    \"zoneCode\": \"GIS543763\",\r\n    \"zoneName\": \"Detroit Central - RO MSW - To Woodland\",\r\n    \"masLibrary\": \"129A_WDL\",\r\n    \"equipmentAvailabilityTypeCode\": \"TEMP\",\r\n    \"zoneContractType\": \"Open Market\",\r\n    \"francisePricingLink\": \"\",\r\n    \"greenPagesLink\": \"\",\r\n    \"serviceCharges\": [\r\n      {\r\n        \"code\": \"FU_RO_TEMP_OPEN\",\r\n        \"name\": \"Fuel Fee\",\r\n        \"componentTypeCode\": null,\r\n        \"componentTypeName\": null,\r\n        \"actionCode\": null,\r\n        \"actionName\": null,\r\n        \"cost\": 10.2100,\r\n        \"costValueType\": \"Percent\",\r\n        \"price\": null,\r\n        \"priceValueType\": null\r\n      },\r\n      {\r\n        \"code\": \"ENV_RO_TEMP_OPEN\",\r\n        \"name\": \"Environmental Fee\",\r\n        \"componentTypeCode\": null,\r\n        \"componentTypeName\": null,\r\n        \"actionCode\": null,\r\n        \"actionName\": null,\r\n        \"cost\": 17.5000,\r\n        \"costValueType\": \"Percent\",\r\n        \"price\": null,\r\n        \"priceValueType\": null\r\n      },\r\n      {\r\n        \"code\": \"RCR_RO_TEMP_OPEN\",\r\n        \"name\": \"Regulatory Cost Recovery\",\r\n        \"componentTypeCode\": null,\r\n        \"componentTypeName\": null,\r\n        \"actionCode\": null,\r\n        \"actionName\": null,\r\n        \"cost\": 3.6000,\r\n        \"costValueType\": \"Percent\",\r\n        \"price\": null,\r\n        \"priceValueType\": null\r\n      },\r\n      {\r\n        \"code\": \"CSC_RO_TEMP_OPEN\",\r\n        \"name\": \"Container Service Charge\",\r\n        \"componentTypeCode\": null,\r\n        \"componentTypeName\": null,\r\n        \"actionCode\": null,\r\n        \"actionName\": null,\r\n        \"cost\": 108.50,\r\n        \"costValueType\": \"Amount\",\r\n        \"price\": null,\r\n        \"priceValueType\": null\r\n      }\r\n    ]\r\n  },\r\n  \"problem\": null\r\n}';
    private static final string json_BadRequest = '{\r\n  \"data\": null,\r\n  \"problem\": {\r\n    \"title\": \"Bad Request\",\r\n    \"status\": 400,\r\n    \"errors\": [\r\n      {\r\n        \"code\": \"400\",\r\n        \"message\": \"Partner access denied\"\r\n      }\r\n    ]\r\n  }\r\n}';
    //private static final string json_Invalid = '{\r\n  \"data\": {\r\n    \"priceQuoteIdentifier_1\": \"Q215\",\r\n    \"supplierCode\": \"8\",\r\n    \"supplierName\": \"WMI\",\r\n    \"customerCode\": \"HMD\",\r\n    \"customerName\": \"The Home Depot\",\r\n    \"locationCode\": \"HMD002706\",\r\n    \"costSource\": \"WM (SBS|RO|OT|30O|B02860|20200901|050638|5411)\",\r\n    \"pricingMethodDisposalCode\": \"1.0\",\r\n    \"pricingMethodDisposalDescription\": \"Market Based Pricing\",\r\n    \"pricingMethodHaulingCode\": \"1.0\",\r\n    \"pricingMethodHaulingDescription\": \"Market Based Pricing\",\r\n    \"haulCost\": \"Market Based Pricing\",\r\n    \"disposalCost\": 30.71,\r\n    \"haulPrice\": null,\r\n    \"disposalPrice\": null,\r\n    \"equipmentUOM\": \"Tons\",\r\n    \"estimatedVolumePerHaul\": 4.00,\r\n    \"applyInvoiceFeesToDisposalCharges\": \"Y\",\r\n    \"applyInvoiceFeesToRentalCharges\": null,\r\n    \"dispositionType\": \"S04264_LF\",\r\n    \"dispositionName\": \"B02860|S04264_LF|129A_WDL|MSW_RO\",\r\n    \"transferSiteCode\": \"NA\",\r\n    \"businessUnit\": \"B02860\",\r\n    \"wasteStreamCode\": \"MSW_RO\",\r\n    \"wasteStreamName\": \"Municipal Solid Waste\",\r\n    \"equipmentCode\": \"30O\",\r\n    \"equipmentName\": \"30 Yard Open Top\",\r\n    \"materialName\": \"MSW - Unspecified\",\r\n    \"materialClassName\": \"MSW_MSWI_Municipal Solid Waste - Industrial\",\r\n    \"zoneCode\": \"GIS543763\",\r\n    \"zoneName\": \"Detroit Central - RO MSW - To Woodland\",\r\n    \"masLibrary\": \"129A_WDL\",\r\n    \"equipmentAvailabilityTypeCode\": \"TEMP\",\r\n    \"zoneContractType\": \"Open Market\",\r\n    \"francisePricingLink\": \"\",\r\n    \"greenPagesLink\": \"\",\r\n    \"serviceCharges\": [\r\n      {\r\n        \"code\": \"FU_RO_TEMP_OPEN\",\r\n        \"name\": \"Fuel Fee\",\r\n        \"componentTypeCode\": null,\r\n        \"componentTypeName\": null,\r\n        \"actionCode\": null,\r\n        \"actionName\": null,\r\n        \"cost\": 10.2100,\r\n        \"costValueType\": \"Percent\",\r\n        \"price\": null,\r\n        \"priceValueType\": null\r\n      },\r\n      {\r\n        \"code\": \"ENV_RO_TEMP_OPEN\",\r\n        \"name\": \"Environmental Fee\",\r\n        \"componentTypeCode\": null,\r\n        \"componentTypeName\": null,\r\n        \"actionCode\": null,\r\n        \"actionName\": null,\r\n        \"cost\": 17.5000,\r\n        \"costValueType\": \"Percent\",\r\n        \"price\": null,\r\n        \"priceValueType\": null\r\n      },\r\n      {\r\n        \"code\": \"RCR_RO_TEMP_OPEN\",\r\n        \"name\": \"Regulatory Cost Recovery\",\r\n        \"componentTypeCode\": null,\r\n        \"componentTypeName\": null,\r\n        \"actionCode\": null,\r\n        \"actionName\": null,\r\n        \"cost\": 3.6000,\r\n        \"costValueType\": \"Percent\",\r\n        \"price\": null,\r\n        \"priceValueType\": null\r\n      },\r\n      {\r\n        \"code\": \"CSC_RO_TEMP_OPEN\",\r\n        \"name\": \"Container Service Charge\",\r\n        \"componentTypeCode\": null,\r\n        \"componentTypeName\": null,\r\n        \"actionCode\": null,\r\n        \"actionName\": null,\r\n        \"cost\": 108.50,\r\n        \"costValueType\": \"Amount\",\r\n        \"price\": null,\r\n        \"priceValueType\": null\r\n      }\r\n    ]\r\n  },\r\n  \"problem\": null\r\n}';
    private static final string json_Invalid = '----';

    /* @description : Apex method setup */
    /* method for setting up data*/ 
    @testSetup static void setup() {
        Profile adminProfile = TestDataFactory.getProfile(SYS_ADMIN);
        User usr = TestDataFactory.createUser(adminProfile);
        Database.insert(usr);  
        system.runAs(usr)
        {
            List<Account> acclist = new List<Account>();
            Id recordTypeid = TestDataFactory.getRecordType('Client','Account');
            Account acclist1 = new Account(Name = Constant_Util.KEYWORD_TEST, phone = PHONE_NINE, OwnerId = usr.id,AccountNumber=ACC_NUMBER,
                                        RecordTypeid = recordTypeid, 
                                        IsPricingEligible__c = true, NAICS_Code__c = NAISC_31);
            // acclist1[0].IsPricingEligible__c = true;
            // acclist1[0].NAICS_Code__c = NAISC_31;
            acclist.Add(acclist1);
            
            Database.insert(acclist);
            
            list<Account> locationlist = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, acclist1.Id);
            locationlist[0].Phone = STR_PHONE_ONE;
            locationlist[0].AccountNumber = STR_ACCOUNT_NUMBER;
            locationlist[0].Status__c = STR_STATUS;
            locationlist[0].ShippingCountry = STR_COUNTRY_US;
            locationlist[0].ShippingPostalCode = STR_POSTAL_CODE;
            locationlist[0].ShippingState = STR_STATE;
            locationlist[0].ShippingCity = STR_CITY;
            locationlist[0].ShippingStreet = STR_STREET;
            locationlist[0].ParentId = acclist1.id;
            Database.insert(locationlist);
            
            list<Contact> conlist = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST,Constant_Util.CONSTANT_LAST, acclist1, usr);
            Database.insert(conlist);
            
            list<product2> productlist = TestDataFactory.createProduct(Constant_Util.KEYWORD_TEST);
            productlist[0].ProductTypeSelected__c = OPEN_TOP;
            productlist[0].Family = ROLL_OFF;
            productlist[0].Container_Size__c = Yards_30;
            Database.insert(productlist);
            
            list<Asset> assetlist = TestDataFactory.createAsset(Constant_Util.CONSTANT_FIRST, acclist1, conlist.get(0), 
                                                                productlist.get(0), usr, locationlist.get(0));
            Database.insert(assetlist);
                        
            list<Case> caselist = TestDataFactory.createCase(Constant_Util.CONSTANT_FIRST, acclist1, conlist.get(0), 
                                                             usr, locationlist.get(0), assetlist.get(0));
            List<Case> myCaseList = TestDataFactory.createNewCase();
            caselist[0].RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'New Service Case'].Id;
            caselist[0].Case_Type__c = 'New Service';
            caselist[0].Case_Sub_Type__c = 'Permanent';
            caselist[0].Case_Reason__c = 'Existing Location';
            caselist[0].LOB__c = 'Rolloff';
            caselist[0].Status = 'Open';
            caselist[0].Service_Occurrence_Type_Code__c = ON_CALL;
            caselist[0].Material_Type__c = TRASH;
            Database.insert(caselist);

            list<Case> caselist1 = TestDataFactory.createCase(Constant_Util.CONSTANT_FIRST, acclist1, conlist.get(0), 
                                                             usr, locationlist.get(0), assetlist.get(0));
            caselist1[0].RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'New Service Case'].Id;
            caselist1[0].Case_Type__c = 'New Service';
            caselist1[0].Case_Sub_Type__c = 'Permanent';
            caselist1[0].Case_Reason__c = 'Existing Location';
            caselist1[0].LOB__c = 'Rolloff';
            caselist1[0].Status = 'Open';
            caselist1[0].Service_Occurrence_Type_Code__c = ON_CALL;
            caselist1[0].Material_Type__c = TRASH;
            Database.insert(caselist1);

            List<Pricing_Request__c> pricingrqList = new List<Pricing_Request__c>();

            Pricing_Request__c pricingrq1 = new Pricing_Request__c();
            pricingrq1.Case__c = caselist[0].Id;
            pricingrq1.Account__c = acclist1.Id;
            pricingrq1.Location__c = locationlist[0].Id;
            pricingrq1.Service_Country__c = STR_COUNTRY_US;
            pricingrq1.Service_Postal_Code__c = STR_POSTAL_CODE;
            pricingrq1.Service_State__c = STR_STATE;
            pricingrq1.Service_City__c = STR_CITY;
            pricingrq1.Service_Street_Address__c = STR_STREET;
            pricingrq1.Line_of_Business__c = 'Rolloff';
            pricingrq1.Container_Type__c = 'OT';
            pricingrq1.Container_Size__c = 'YRDS-30';
            pricingrq1.Material_Code__c = 'T';
            pricingrq1.Quantity__c = 1;
            pricingrq1.Industry_Classification__c = '4445';
            pricingrq1.Schedule_or_On_Call__c = ON_CALL;
            pricingrq1.Service_Type__c = PERMANENT;
            pricingrq1.APIRequestOutput__c = json_Valid;
            pricingrq1.CreatedById = usr.Id;
            pricingrqList.Add(pricingrq1);
            

            Pricing_Request__c pricingrq2 = new Pricing_Request__c();
            pricingrq2.Case__c = caselist[0].Id;
            pricingrq2.Account__c = acclist1.Id;
            pricingrq2.Location__c = locationlist[0].Id;
            pricingrq2.Service_Country__c = STR_COUNTRY_US;
            pricingrq2.Service_Postal_Code__c = STR_POSTAL_CODE;
            pricingrq2.Service_State__c = STR_STATE;
            pricingrq2.Service_City__c = STR_CITY;
            pricingrq2.Service_Street_Address__c = STR_STREET;
            pricingrq2.Line_of_Business__c = 'Rolloff';
            pricingrq2.Container_Type__c = 'CMP';
            pricingrq2.Container_Size__c = 'YRDS-35';
            pricingrq2.Material_Code__c = 'C&D';
            pricingrq2.Quantity__c = 1;
            pricingrq2.Industry_Classification__c = '4445';
            pricingrq2.Schedule_or_On_Call__c = ON_CALL;
            pricingrq2.Service_Type__c = PERMANENT;
            pricingrq2.APIRequestOutput__c = json_BadRequest;
            pricingrq2.CreatedById = usr.Id;
            pricingrqList.Add(pricingrq2);

            Pricing_Request__c pricingrq3 = new Pricing_Request__c();
            pricingrq3.Case__c = caselist[0].Id;
            pricingrq3.Account__c = acclist1.Id;
            pricingrq3.Location__c = locationlist[0].Id;
            pricingrq3.Service_Country__c = STR_COUNTRY_US;
            pricingrq3.Service_Postal_Code__c = STR_POSTAL_CODE;
            pricingrq3.Service_State__c = STR_STATE;
            pricingrq3.Service_City__c = STR_CITY;
            pricingrq3.Service_Street_Address__c = STR_STREET;
            pricingrq3.Line_of_Business__c = 'Rolloff';
            pricingrq3.Container_Type__c = 'CMP';
            pricingrq3.Container_Size__c = 'YRDS-35';
            pricingrq3.Material_Code__c = 'C&D';
            pricingrq3.Quantity__c = 1;
            pricingrq3.Industry_Classification__c = '4445';
            pricingrq3.Schedule_or_On_Call__c = ON_CALL;
            pricingrq3.Service_Type__c = PERMANENT;
            pricingrq3.APIRequestOutput__c = json_Invalid;
            pricingrq3.CreatedById = usr.Id;
            pricingrqList.Add(pricingrq3);

            Pricing_Request__c pricingrq4 = new Pricing_Request__c();
            pricingrq4.Case__c = caselist[0].Id;
            pricingrq4.Account__c = acclist1.Id;
            pricingrq4.Location__c = locationlist[0].Id;
            pricingrq4.Service_Country__c = STR_COUNTRY_US;
            pricingrq4.Service_Postal_Code__c = STR_POSTAL_CODE;
            pricingrq4.Service_State__c = STR_STATE;
            pricingrq4.Service_City__c = STR_CITY;
            pricingrq4.Service_Street_Address__c = STR_STREET;
            pricingrq4.Line_of_Business__c = 'Rolloff';
            pricingrq4.Container_Type__c = 'CMP';
            pricingrq4.Container_Size__c = 'YRDS-35';
            pricingrq4.Material_Code__c = 'C&D';
            pricingrq4.Quantity__c = 1;
            pricingrq4.Industry_Classification__c = '4445';
            pricingrq4.Schedule_or_On_Call__c = ON_CALL;
            pricingrq4.Service_Type__c = PERMANENT;
            pricingrq4.APIRequestOutput__c = '';
            pricingrq4.CreatedById = usr.Id;
            pricingrqList.Add(pricingrq4);

            Pricing_Request__c pricingrq5 = new Pricing_Request__c();
            pricingrq5.Case__c = caselist1[0].Id;
            pricingrq5.Account__c = acclist1.Id;
            pricingrq5.Location__c = locationlist[0].Id;
            pricingrq5.Service_Country__c = STR_COUNTRY_US;
            pricingrq5.Service_Postal_Code__c = STR_POSTAL_CODE;
            pricingrq5.Service_State__c = STR_STATE;
            pricingrq5.Service_City__c = STR_CITY;
            pricingrq5.Service_Street_Address__c = STR_STREET;
            pricingrq5.Line_of_Business__c = 'Rolloff';
            pricingrq5.Container_Type__c = 'OT';
            pricingrq5.Container_Size__c = 'YRDS-30';
            pricingrq5.Material_Code__c = 'T';
            pricingrq5.Quantity__c = 1;
            pricingrq5.Industry_Classification__c = '4445';
            pricingrq5.Schedule_or_On_Call__c = ON_CALL;
            pricingrq5.Service_Type__c = PERMANENT;
            pricingrq5.APIRequestOutput__c = json_Valid;
            pricingrq5.CreatedById = usr.Id;
            pricingrqList.Add(pricingrq5);

            Database.insert(pricingrqList);

            Case c = new Case();
            c.Id = caselist1[0].Id;
            c.Status = 'Closed';
            Database.update(c);
        } 
    }

    /* test method */
    @isTest static void PricingRequestResponseTest(){
        //test class errors - SDT - 33363
        List<user> currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(currentuser.get(0)){
            //String cronexp = '0 0 0 24 5 ? *';
            
            Test.startTest();
                //String jobId = System.schedule('Test BatchCreateUnspecifiedContacts',  cronexp, new BatchCreateUnspecifiedContacts());
                   Database.ExecuteBatch(new PricingRequestResponseBatch(), 200);
            Test.stopTest();
        }
    }
}