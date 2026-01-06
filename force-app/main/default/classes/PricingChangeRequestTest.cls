@isTest(seeAllData=false)
global class PricingChangeRequestTest {
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
    private static final string COMMERCIAL = 'Commercial';
    private static final string OPEN_TOP = 'Open Top';
    private static final string DUMPSTER = 'Dumpster';
    private static final string New_Service_Case = 'New Service Case';
    private static final string New_Service = 'New Service';
    private static final string OPEN = 'Open';
    private static final string PERMANENT = 'PERM';
    private static final string ON_CALL = 'On-Call';
    private static final string SCHEDULED = 'Scheduled';
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
    private static final string NAISC_44 = '44';
    private static final string NAISC_49 = '49';
    private static final string NAISC_51 = '51';
    private static final string NAISC_1 = '1';
    private static final string ObjectApiName = 'Pricing_Request__c';
    private static final string FieldApiName = 'Material_Code__c';
    private static final string fieldValue = 'Cardboard';
    private static final string dp_FieldApiName = 'Container_Size__c';
    private static final string ControllingfieldValue = 'Open Top';
    private static final string DependentfieldValue = '30 Yards';
    private static final string json_Valid = '{\r\n  \"data\": {\r\n    \"priceQuoteIdentifier\": \"Q215\",\r\n    \"supplierCode\": \"8\",\r\n    \"supplierName\": \"WMI\",\r\n    \"customerCode\": \"HMD\",\r\n    \"customerName\": \"The Home Depot\",\r\n    \"locationCode\": \"HMD002706\",\r\n    \"costSource\": \"WM (SBS|RO|OT|30O|B02860|20200901|050638|5411)\",\r\n    \"pricingMethodDisposalCode\": \"1.0\",\r\n    \"pricingMethodDisposalDescription\": \"Market Based Pricing\",\r\n    \"pricingMethodHaulingCode\": \"1.0\",\r\n    \"pricingMethodHaulingDescription\": \"Market Based Pricing\",\r\n    \"haulCost\": 345.82,\r\n    \"disposalCost\": 30.71,\r\n    \"haulPrice\": null,\r\n    \"disposalPrice\": null,\r\n    \"equipmentUOM\": \"Tons\",\r\n    \"estimatedVolumePerHaul\": 4.00,\r\n    \"applyInvoiceFeesToDisposalCharges\": \"Y\",\r\n    \"applyInvoiceFeesToRentalCharges\": null,\r\n    \"dispositionType\": \"S04264_LF\",\r\n    \"dispositionName\": \"B02860|S04264_LF|129A_WDL|MSW_RO\",\r\n    \"transferSiteCode\": \"NA\",\r\n    \"businessUnit\": \"B02860\",\r\n    \"wasteStreamCode\": \"MSW_RO\",\r\n    \"wasteStreamName\": \"Municipal Solid Waste\",\r\n    \"equipmentCode\": \"30O\",\r\n    \"equipmentName\": \"30 Yard Open Top\",\r\n    \"materialName\": \"MSW - Unspecified\",\r\n    \"materialClassName\": \"MSW_MSWI_Municipal Solid Waste - Industrial\",\r\n    \"zoneCode\": \"GIS543763\",\r\n    \"zoneName\": \"Detroit Central - RO MSW - To Woodland\",\r\n    \"masLibrary\": \"129A_WDL\",\r\n    \"equipmentAvailabilityTypeCode\": \"TEMP\",\r\n    \"zoneContractType\": \"Open Market\",\r\n    \"francisePricingLink\": \"\",\r\n    \"greenPagesLink\": \"\",\r\n    \"serviceCharges\": [\r\n      {\r\n        \"code\": \"FU_RO_TEMP_OPEN\",\r\n        \"name\": \"Fuel Fee\",\r\n        \"componentTypeCode\": null,\r\n        \"componentTypeName\": null,\r\n        \"actionCode\": null,\r\n        \"actionName\": null,\r\n        \"cost\": 10.2100,\r\n        \"costValueType\": \"Percent\",\r\n        \"price\": null,\r\n        \"priceValueType\": null\r\n      },\r\n      {\r\n        \"code\": \"ENV_RO_TEMP_OPEN\",\r\n        \"name\": \"Environmental Fee\",\r\n        \"componentTypeCode\": null,\r\n        \"componentTypeName\": null,\r\n        \"actionCode\": null,\r\n        \"actionName\": null,\r\n        \"cost\": 17.5000,\r\n        \"costValueType\": \"Percent\",\r\n        \"price\": null,\r\n        \"priceValueType\": null\r\n      },\r\n      {\r\n        \"code\": \"RCR_RO_TEMP_OPEN\",\r\n        \"name\": \"Regulatory Cost Recovery\",\r\n        \"componentTypeCode\": null,\r\n        \"componentTypeName\": null,\r\n        \"actionCode\": null,\r\n        \"actionName\": null,\r\n        \"cost\": 3.6000,\r\n        \"costValueType\": \"Percent\",\r\n        \"price\": null,\r\n        \"priceValueType\": null\r\n      },\r\n      {\r\n        \"code\": \"CSC_RO_TEMP_OPEN\",\r\n        \"name\": \"Container Service Charge\",\r\n        \"componentTypeCode\": null,\r\n        \"componentTypeName\": null,\r\n        \"actionCode\": null,\r\n        \"actionName\": null,\r\n        \"cost\": 108.50,\r\n        \"costValueType\": \"Amount\",\r\n        \"price\": null,\r\n        \"priceValueType\": null\r\n      }\r\n    ]\r\n  },\r\n  \"problem\": null\r\n}';


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
            acclist.Add(acclist1);
            
            Account acclist2 = new Account(Name = Constant_Util.KEYWORD_TEST, phone = PHONE_NINE, OwnerId = usr.id,AccountNumber=ACC_NUMBER,
                                        RecordTypeid = recordTypeid, 
                                        IsPricingEligible__c = false, NAICS_Code__c = NAISC_44);
            acclist.Add(acclist2);

            Account acclist3 = new Account(Name = Constant_Util.KEYWORD_TEST, phone = PHONE_NINE, OwnerId = usr.id,AccountNumber=ACC_NUMBER,
                                        RecordTypeid = recordTypeid, 
                                        IsPricingEligible__c = true, NAICS_Code__c = NAISC_49);
            acclist.Add(acclist3);

            Account acclist4 = new Account(Name = Constant_Util.KEYWORD_TEST, phone = PHONE_NINE, OwnerId = usr.id,AccountNumber=ACC_NUMBER,
                                        RecordTypeid = recordTypeid, 
                                        IsPricingEligible__c = true, NAICS_Code__c = NAISC_1);
            acclist.Add(acclist4);

            Account acclist5 = new Account(Name = Constant_Util.KEYWORD_TEST, phone = PHONE_NINE, OwnerId = usr.id,AccountNumber=ACC_NUMBER,
                                        RecordTypeid = recordTypeid, 
                                        IsPricingEligible__c = false, NAICS_Code__c = NAISC_51);
            acclist.Add(acclist5);

            Account acclist6 = new Account(Name = Constant_Util.KEYWORD_TEST, phone = PHONE_NINE, OwnerId = usr.id,AccountNumber=ACC_NUMBER,
            RecordTypeid = recordTypeid,
            IsPricingEligible__c = false, NAICS_Code__c = null);
            acclist.Add(acclist6);

            Database.insert(acclist);
            
            list<Account> locationlist = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, acclist1.Id);
            System.debug('@@@@@@@@-Pricing Location 0 :' + locationlist);
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
            System.debug('@@@@@@@@-Pricing Location 1 :' + locationlist);
            
            list<Contact> conlist = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST,Constant_Util.CONSTANT_LAST, acclist1, usr);
            Database.insert(conlist);
            
            list<product2> productlist = TestDataFactory.createProduct(Constant_Util.KEYWORD_TEST);
            productlist[0].Equipment_Type__c = DUMPSTER;
            productlist[0].ProductTypeSelected__c = DUMPSTER;
            productlist[0].Family = COMMERCIAL;
            productlist[0].Container_Size__c = Yards_30;
            Database.insert(productlist);
            
            list<Asset> assetlist = TestDataFactory.createAsset(Constant_Util.CONSTANT_FIRST, acclist1, conlist.get(0), 
                                                                productlist.get(0), usr, locationlist.get(0));
            assetlist[0].Duration__c = 'Permanent';
            assetlist[0].Material_Type__c = 'Trash';
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
            caselist[0].Acorn_Issue_Id__c = 27930167;
            caselist[0].Tracking_Number__c = 'T8354994';
            Database.insert(caselist);
            System.debug('@@@@@@@@-Pricing Case Insert :' + caselist);

            List<Pricing_Request__c> pricingrqList = new List<Pricing_Request__c>();

            Pricing_Request__c pricingrq1 = new Pricing_Request__c();
            pricingrq1.Case__c = caselist[0].Id;
            pricingrq1.Account__c = acclist1.Id;
            pricingrq1.Location__c = locationlist[0].Id;
            pricingrq1.Service_Country__c = STR_COUNTRY_US;
            pricingrq1.Service_Postal_Code__c = STR_POSTAL_CODE;
            pricingrq1.Service_Baseline_ID__c = 99;
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
            pricingrq1.isAPIResult__c = false;
            pricingrq1.CreatedById = usr.Id;
            pricingrqList.Add(pricingrq1);
            

            Pricing_Request__c pricingrq2 = new Pricing_Request__c();
            pricingrq2.Case__c = caselist[0].Id;
            pricingrq2.Account__c = acclist1.Id;
            //pricingrq2.Location__c = locationlist[0].Id;
            pricingrq2.Service_Country__c = STR_COUNTRY_US;
            pricingrq2.Service_Baseline_ID__c = 99;
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
            pricingrq2.CreatedById = usr.Id;
            pricingrqList.Add(pricingrq2);

            Pricing_Request__c pricingrq3 = new Pricing_Request__c();
            pricingrq3.Case__c = caselist[0].Id;
            pricingrq3.Account__c = acclist1.Id;
            pricingrq3.Location__c = locationlist[0].Id;
            pricingrq3.Service_Baseline_ID__c = 99;
            pricingrq3.Location__c = locationlist[0].Id;
            pricingrq3.Service_Country__c = STR_COUNTRY_US;
            pricingrq3.Service_Postal_Code__c = STR_POSTAL_CODE;
            pricingrq3.Service_State__c = STR_STATE;
            pricingrq3.Service_City__c = STR_CITY;
            pricingrq3.Service_Street_Address__c = STR_STREET;
            pricingrq3.Line_of_Business__c = 'Commercial';
            pricingrq3.Container_Type__c = 'DMP';
            pricingrq3.Container_Size__c = 'YRDS-4';
            pricingrq3.Material_Code__c = 'T';
            pricingrq3.Quantity__c = 1;
            pricingrq3.Industry_Classification__c = '4445';
            pricingrq3.Schedule_or_On_Call__c = SCHEDULED;
            pricingrq3.Service_Type__c = PERMANENT;
            pricingrq3.isAPIResult__c = false;
            pricingrq3.Frequency_Type__c = 'Monthly';
            pricingrq3.Frequency_Count__c = '1';
            pricingrq3.CreatedById = usr.Id;
            pricingrqList.Add(pricingrq3);

            Pricing_Request__c pricingrq4 = new Pricing_Request__c();
            pricingrq4.Case__c = caselist[0].Id;
            pricingrq4.Account__c = acclist1.Id;
            //pricingrq4.Location__c = locationlist[0].Id;
            pricingrq4.Service_Baseline_ID__c = 99;
            pricingrq4.Service_Country__c = STR_COUNTRY_US;
            pricingrq4.Service_Postal_Code__c = STR_POSTAL_CODE;
            pricingrq4.Service_State__c = STR_STATE;
            pricingrq4.Service_City__c = STR_CITY;
            pricingrq4.Service_Street_Address__c = STR_STREET;
            pricingrq4.Line_of_Business__c = 'Commercial';
            pricingrq4.Container_Type__c = 'DMP';
            pricingrq4.Container_Size__c = 'YRDS-4';
            pricingrq4.Material_Code__c = 'T';
            pricingrq4.Quantity__c = 1;
            pricingrq4.Industry_Classification__c = '4445';
            pricingrq4.Schedule_or_On_Call__c = SCHEDULED;
            pricingrq4.Service_Type__c = PERMANENT;
            pricingrq4.isAPIResult__c = true;
            pricingrq4.Frequency_Type__c = 'EOW';
            pricingrq4.Frequency_Count__c = '0.5';
            pricingrq4.IsPriceChangeRequest__c = true;
            pricingrq4.CreatedById = usr.Id;
            pricingrqList.Add(pricingrq4);

            Database.insert(pricingrqList);
            //System.debug('@@@@@@@@-Pricing :' + pricingrqList);
        } 
    }
    /*@testmethodName- getAssteDetails
    *@description- Test getAssteDetails method to return Asset object
    */ 
    //positive test case
    // @isTest static void testGetAssteDetails(){
    //     List<user> currentuser = [select id, Bypass_Validation__c from user limit 1];
    //     system.runAs(currentuser.get(0)){
    //         Asset assetRecord = [Select Acorn_SBID__c,ProductFamily,Is_Active__c,Location__r.Status__c,Duration__c,
    //                             Equipment_Type__c,Material_Type__c FROM Asset LIMIT 1];
    //         Decimal baselineId = assetRecord.Acorn_SBID__c;
    //         Test.startTest();
    //         Asset returnedAsset = PricingChangeRequest.getAssteDetails(baselineId);
    //         Test.stopTest();
    //         System.assert(returnedAsset != null);
    //         System.assertEquals(returnedAsset.Material_Type__c,'Trash');

    //     }
    // }
    /*@testmethodName- getAssteDetails
    *@description- Test getAssteDetails method to return Asset object
    */ 
    //negative test case
    // @isTest static void testGetAssteDetails_NullorEmptybaselineId(){
    //     Asset returnedAsset = new Asset();
    //     List<user> currentuser = [select id, Bypass_Validation__c from user limit 1];
    //     system.runAs(currentuser.get(0)){
    //         Decimal baselineId = null;
    //         Test.startTest();
    //         returnedAsset = PricingChangeRequest.getAssteDetails(baselineId);
    //         System.assert(returnedAsset.Id==null);
    //         Decimal baselineId_empty;
    //         returnedAsset = PricingChangeRequest.getAssteDetails(baselineId_empty);
    //         Test.stopTest();
    //         System.assert(returnedAsset.Id==null);
    //     }
    // }


    /*@testmethodName- getPricingChangeDetail
    *@description- Test getPricingChangeDetail method if HTTPS callout is getting done
    */ 
    //positive test case
    @isTest static void testgetPricingChangeDetail(){
       //test class errors - SDT - 33363-re
        List<user> currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(currentuser.get(0)){
            // Set mock callout class
            Pricing_Request__c price = [select Id From Pricing_Request__c Where Location__c != null limit 1];
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new PricingAPIMock());
            // Call method to test.
            // This causes a fake response to be sent
            // from the class that implements HttpCalloutMock.
            List<String> response = PricingChangeRequest.getPricingChangeDetail(price.Id,false);
            Test.stopTest();
            System.assert(response != null);
        }
    }
      /*@testmethodName- getPricingChangeDetail
    *@description- Test getPricingChangeDetail method when the line of business is commercial
    */
    @isTest static void testgetPricingChangeDetail_ForCommercial(){
       //test class errors - SDT - 33363-re
        List<user> currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(currentuser.get(0)){
       
            Pricing_Request__c price = [select Id From Pricing_Request__c Where Location__c != null and Line_of_Business__c = 'Commercial' limit 1];
            Test.startTest();
            List<String> response =  PricingChangeRequest.getPricingChangeDetail(price.Id, false);
            Test.stopTest();
            system.assert(response != null);
        }   
    }

    //Mocking framework for http callout
    global class PricingAPIMock implements HttpCalloutMock {
        // Implement this interface method
        global HTTPResponse respond(HTTPRequest req) {
            String json = '{'+
            '    \"Data\": '+
            '        {'+
            '            \"priceQuoteIdentifier\": \"Q127\",'+
            '            \"supplierCode\": \"8\",'+
            '            \"supplierName\": \"WMI\",'+
            '            \"customerCode\": \"HMD\"'+
            '        }'+
            '    \"Problem\": null'+
            '}';
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(json);
            response.setStatusCode(200);
            return response;
        }
    }
}