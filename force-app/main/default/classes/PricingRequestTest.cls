@isTest(seeAllData=false)
global class PricingRequestTest {
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

    // private static final string NAISC_Null = null;
    
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
            pricingrq4.isAPIResult__c = false;
            pricingrq4.Frequency_Type__c = 'Weekly';
            pricingrq4.Frequency_Count__c = '0.5';
            pricingrq4.CreatedById = usr.Id;
            pricingrqList.Add(pricingrq4);

            Database.insert(pricingrqList);
            //System.debug('@@@@@@@@-Pricing :' + pricingrqList);
        } 
    }
    /*@testmethodName- getCaseDetails
    *@description- Test getCaseDetails method to return Case object
    */  
    @isTest static void testCaseDetails() {
    //test class errors - SDT - 33363
        List<user> currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
    
        system.runAs(currentuser.get(0)){
        
            Case c = [select Id, Status__c from Case limit 1];

            Test.startTest();
            case case_resp = PricingRequest.getCaseDetails(c.Id);
            case case_resp1 = PricingRequest.getCaseDetailsById(c.Id);
            Test.stopTest();
            System.assert(case_resp != null);
            System.assert(case_resp1 != null);
        }
    }
    /*@testmethodName- getCaseDetails
    *@description- Test getCaseDetails method to handle expection
    */ 
    @isTest static void testCaseDetailsNull() {
    //test class errors - SDT - 33363
        List<user> currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
    
        system.runAs(currentuser.get(0)){
        
            // Case c = [select Id, Status__c from Case limit 1];
            Test.startTest();
            case case_resp = PricingRequest.getCaseDetails(null);
            Test.stopTest();
            System.assert(case_resp.ID == null);
        }
    }
    /*@testmethodName- getAccountAddress
    *@description- Test getAccountAddress method to return Account object
    */ 
    @isTest static void testAccountAddress() {
        //test class errors - SDT - 33363
        List<user> currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
    
        system.runAs(currentuser.get(0)){
            List<Account> acc = [select Id from Account limit 2];
            
            List<Account> loc = [select Id from Account Where ParentId =: acc[0].Id limit 2];
            
            Test.startTest();
            Account acc_resp = PricingRequest.getAccountAddress(loc[0].id);
            Test.stopTest();
            System.assert(acc_resp != null);
            System.assertEquals(acc_resp.ShippingCity, 'Test City');
        }
    }
    /*@testmethodName- getAccountAddress
    *@description- Test getAccountAddress method to handle expection
    */ 
    @isTest static void testAccountAddress_Null() {
        //test class errors - SDT - 33363
        List<user> currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
    
        system.runAs(currentuser.get(0)){
            List<Account> acc = [select Id from Account limit 2];
            
            List<Account> loc = [select Id from Account Where ParentId =: acc[0].Id limit 2];
            
            Test.startTest();
            Account acc_resp = PricingRequest.getAccountAddress(null);
            Test.stopTest();
            System.assert(acc_resp == null);
        }
    }
    /*@testmethodName- insertCaseComment
    *@description- Test insertCaseComment method to insert in Commect__c object
    */ 
    // @isTest static void testcaseComment(){
    //     //test class errors - SDT - 33363
    //     List<user> currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
    //     system.runAs(currentuser.get(0)){
              
    //         Case case1 = [select Id, caseNumber from Case limit 1];
    //         Test.startTest();
    //         PricingRequest.insertCaseComment('This is a new comment', case1.Id, case1.caseNumber ); 
    //         Comment__c com = [select Id, Comment__c, Case_Number__c, Case__c from Comment__c Where Case__c =: case1.Id  limit 1];
    //         Test.stopTest();
    //         System.assert(com != null);
    //         System.assertEquals(com.Comment__c, 'This is a new comment');
    //     }
    // }
    /*@testmethodName- insertCaseComment
    *@description- Test insertCaseComment method to handle expection
    */ 
    // @isTest static void testcaseComment_Invalid(){
    //     //test class errors - SDT - 33363
    //     List<user> currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
    //     system.runAs(currentuser.get(0)){
        
    //         Case case1 = [select Id, caseNumber from Case limit 1];
    //         List<Account> acc = [select Id from Account limit 2];

    //         Test.startTest();
    //         PricingRequest.insertCaseComment('This is a new comment', acc[0].Id , case1.caseNumber); 
    //         //Comment__c com = [select Id, Comment__c, Case_Number__c, Case__c from Comment__c Where Case__c =: case1.Id  limit 1];
    //         Test.stopTest();
    //         //System.assert(com == null);
    //     }
    // }
    /*@testmethodName- getNAICSCode
    *@description- Test getNAICSCode method to return desire NAIC code
    */ 
    @isTest static void testNAICSCode_31(){
        //test class errors - SDT - 33363
        List<user> currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(currentuser.get(0)){
            List<Account> acc = [select Id, NAICS_Code__c from Account Where NAICS_Code__c = '31' limit 10];
            Test.startTest();
            String accNAICS = PricingRequest.getNAICSCode(acc[0].Id);
            Test.stopTest();
            system.assert(accNAICS != null);
            system.assertEquals(accNAICS, '313233');
        }
    }
    /*@testmethodName- getNAICSCode
    *@description- Test getNAICSCode method to return desire NAIC code
    */ 
    @isTest static void testNAICSCode_44(){
        //test class errors - SDT - 33363
        List<user> currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(currentuser.get(0)){
            List<Account> acc = [select Id, NAICS_Code__c from Account Where NAICS_Code__c = '44'  limit 10];
        
            Test.startTest();
            String accNAICS = PricingRequest.getNAICSCode(acc[0].Id);
            Test.stopTest();
            system.assert(accNAICS != null);
            system.assertEquals(accNAICS, '4445');
        }
    }
    /*@testmethodName- getNAICSCode
    *@description- Test getNAICSCode method to return desire NAIC code
    */ 
    @isTest static void testNAICSCode_49(){
        //test class errors - SDT - 33363
        List<user> currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(currentuser.get(0)){
            List<Account> acc = [select Id, NAICS_Code__c from Account Where NAICS_Code__c = '49'  limit 10];
        
            Test.startTest();
            String accNAICS = PricingRequest.getNAICSCode(acc[0].Id);
            Test.stopTest();
            system.assert(accNAICS != null);
            system.assertEquals(accNAICS, '4849');
        }
    }
    /*@testmethodName- getNAICSCode
    *@description- Test getNAICSCode method to return desire NAIC code
    */ 
    @isTest static void testNAICSCode_51(){
        //test class errors - SDT - 33363
        List<user> currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(currentuser.get(0)){
            List<Account> acc = [select Id, NAICS_Code__c from Account Where NAICS_Code__c = '51'  limit 10];
        
            Test.startTest();
            String accNAICS = PricingRequest.getNAICSCode(acc[0].Id);
            Test.stopTest();
            system.assert(accNAICS != null);
            system.assertEquals(accNAICS, '51');
        }
    }
    /*@testmethodName- getNAICSCode
    *@description- Test getNAICSCode method to handle expection when NAIC code lenght is one
    */ 
    @isTest static void testNAICSCode_1(){
        //test class errors - SDT - 33363
        List<user> currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(currentuser.get(0)){
            List<Account> acc = [select Id, NAICS_Code__c from Account Where NAICS_Code__c = '1'  limit 10];
        
            Test.startTest();
            String accNAICS = PricingRequest.getNAICSCode(acc[0].Id);
            Test.stopTest();
            system.assert(accNAICS == null);
        }
    }
    /*@testmethodName- getNAICSCode
    *@description- Test getNAICSCode method to handle expection when account not exists
    */ 
    @isTest static void testNAICSCode_Null(){
        //test class errors - SDT - 33363
        List<user> currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(currentuser.get(0)){
            List<Account> acc = [select Id, NAICS_Code__c from Account Where NAICS_Code__c = null  limit 10];

            Test.startTest();
            String accNAICS = PricingRequest.getNAICSCode(acc[0].Id);
            Test.stopTest();
            system.assertEquals(accNAICS, '99');
        }
    }
    /*@testmethodName- checkPricingEligibility
    *@description- Test checkPricingEligibility method to return result
    */ 
    @isTest static void testcheckPricingEligibility_True(){
       //test class errors - SDT - 33363
        List<user> currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
       system.runAs(currentuser.get(0)){
       
            list<Account> acc = [select Id From Account where IsPricingEligible__c = true limit 10];
            Test.startTest();

            Boolean isValid = PricingRequest.checkPricingEligibility(acc[0].id);
            Test.stopTest();
            system.assert(isValid!=null);
            system.assertEquals(isValid, true);
       }
    }
    /*@testmethodName- checkPricingEligibility
    *@description- Test checkPricingEligibility method to return result
    */ 
    @isTest static void testcheckPricingEligibility_false(){
        //test class errors - SDT - 33363
        List<user> currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(currentuser.get(0)){
       
            list<Account> acc = [select Id From Account Where IsPricingEligible__c = false limit 10];
            Test.startTest();

            Boolean isValid = PricingRequest.checkPricingEligibility(null);
            
            Test.stopTest();
            system.assert(isValid!=null);
            system.assertEquals(isValid, false);
        }
    }
    /*@testmethodName- getRequestNumber
    *@description- Test getRequestNumber method to return Wrapper class
    */ 
    @isTest static void testRequestNumber(){
        //test class errors - SDT - 33363
        List<user> currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(currentuser.get(0)){
       
            List<Pricing_Request__c> price = [select Id From Pricing_Request__c limit 10];

            Case c = [Select Id From Case Limit 1];
            Test.startTest();
            PricingRequest.Wrapper wrapperClass = PricingRequest.getRequestNumber(price[0].Id);
            
            Test.stopTest();
            system.assert(wrapperClass != null);
            system.assert(wrapperClass.priReq != null);
            system.assertEquals(wrapperClass.priReq.Case__c, c.Id);
        }
    }
    /*@testmethodName- getRequestNumber
    *@description- Test getRequestNumber method to handle expection
    */
    @isTest static void testRequestNumberNull(){
        //test class errors - SDT - 33363
        List<user> currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(currentuser.get(0)){
       
            Test.startTest();
            PricingRequest.Wrapper wrapperClass = PricingRequest.getRequestNumber(null);
            
            Test.stopTest();
            system.assert(wrapperClass != null);
            system.assert(wrapperClass.priReq == null);
        }
    }
    /*@testmethodName- getPricingRecord
    *@description- Test getPricingRecord method to return Wrapper class
    */ 
    @isTest static void testPricingRecord(){
        //test class errors - SDT - 33363
        List<user> currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(currentuser.get(0)){
       
            List<Pricing_Request__c> price = [select Id From Pricing_Request__c limit 10];

            Case c = [Select Id From Case Limit 1];
            Test.startTest();
            Pricing_Request__c priceReq = PricingRequest.getPricingRecord(price[0].Id);
            
            Test.stopTest();
            system.assert(priceReq != null);
            system.assertEquals(priceReq.Case__c, c.Id);
        }
    }
    /*@testmethodName- getPricingRecord
    *@description- Test getPricingRecord method to handle expection
    */
    @isTest static void testPricingRecordNull(){
        //test class errors - SDT - 33363
        List<user> currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(currentuser.get(0)){
       
            Test.startTest();
            Pricing_Request__c priceReq = PricingRequest.getPricingRecord(null);
            
            Test.stopTest();
            system.assert(priceReq == null);
        }
    }
    /*@testmethodName- updatePriceRequest
    *@description- Test updatePriceRequest method to validate updation in pricing object
    */
    // @isTest static void testupdatePriceRequest(){
    //     //test class errors - SDT - 33363
    //     List<user> currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
    //     system.runAs(currentuser.get(0)){
       
    //         List<Pricing_Request__c> price = [select Id From Pricing_Request__c limit 10];
    //         Case c = [Select Id, Acorn_Issue_Id__c, CaseNumber, Tracking_Number__c From Case Limit 1];

    //         Test.startTest();
    //         PricingRequest.updatePriceRequest(price[0].Id, c.Id, true, c.Acorn_Issue_Id__c, c.CaseNumber, c.Tracking_Number__c);

    //         Pricing_Request__c preq = [select Id, PriceCaseComment__c From Pricing_Request__c Where Id =: price[0].Id];
    //         Test.stopTest();
    //         system.assert(preq != null);
    //         system.assertEquals(preq.PriceCaseComment__c, true);
    //     }
    // }
    /*@testmethodName- updatePriceRequest
    *@description- Test updatePriceRequest method to handle expection
    */
    // @isTest static void testupdatePriceRequestNull(){
    //     //test class errors - SDT - 33363
    //     List<user> currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
    //     system.runAs(currentuser.get(0)){
       
    //         List<Pricing_Request__c> price = [select Id From Pricing_Request__c limit 10];
    //         Case c = [Select Id, Acorn_Issue_Id__c, CaseNumber, Tracking_Number__c From Case Limit 1];

    //         Test.startTest();
    //         PricingRequest.updatePriceRequest(price[0].Id, c.Id, null, c.Acorn_Issue_Id__c, c.CaseNumber, c.Tracking_Number__c);

    //         Pricing_Request__c preq = [select Id, PriceCaseComment__c From Pricing_Request__c Where Id =: price[0].Id];
            
    //         Test.stopTest();
    //         system.assert(preq != null);
    //         system.assertEquals(preq.PriceCaseComment__c, false);
    //     }   
    // }
    /*@testmethodName- getFieldDetails
    *@description- Test getFieldDetails method to get PricingRequestOutputField__mdt object
    */
    @isTest static void testOutputFieldDetails(){
        //test class errors - SDT - 33363
        List<user> currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(currentuser.get(0)){

            Test.startTest();
            List<PricingRequestOutputField__mdt> formFields = PricingRequest.getFieldDetails('Account');

            Test.stopTest();
            system.assert(formFields != null);
        }   
    }
    /*@testmethodName- getPricingDetail
    *@description- Test getPricingDetail method to get API response by Customer API
    */
    @isTest static void testPricingDetail_ByCustomer(){
        //test class errors - SDT - 33363
        List<user> currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(currentuser.get(0)){
       
            Pricing_Request__c price = [select Id From Pricing_Request__c Where Location__c = null limit 1];

            Test.startTest();
            List<String> response =  PricingRequest.getPricingDetail(price.Id, false);
            Test.stopTest();
            system.assert(response != null);
        }   
    }
    /*@testmethodName- getPricingDetail
    *@description- Test getPricingDetail method to get API response by Location API
    */
    @isTest static void testPricingDetail_ByLocation(){
        //test class errors - SDT - 33363
        List<user> currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(currentuser.get(0)){
       
            Pricing_Request__c price = [select Id From Pricing_Request__c Where Location__c != null limit 1];

            Test.startTest();
            List<String> response =  PricingRequest.getPricingDetail(price.Id, false);
            Test.stopTest();
            system.assert(response != null);
        }   
    }
    /*@testmethodName- getPricingDetail
    *@description- Test getPricingDetail method to get API response by Location API for Rolloff
    */
    @isTest static void testPricingDetail_ForRollOff(){
        //test class errors - SDT - 33363
        List<user> currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(currentuser.get(0)){
       
            Pricing_Request__c price = [select Id From Pricing_Request__c Where Location__c != null and Line_of_Business__c = 'Rolloff' limit 1];

            Test.startTest();
            List<String> response =  PricingRequest.getPricingDetail(price.Id, false);
            Test.stopTest();
            system.assert(response != null);
        }   
    }
    /*@testmethodName- getPricingDetail
    *@description- Test getPricingDetail method to get API response by Location API for Commercial
    */
    @isTest static void testPricingDetail_ForCommercial(){
        //test class errors - SDT - 33363
        List<user> currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(currentuser.get(0)){
       
            Pricing_Request__c price = [select Id From Pricing_Request__c Where Location__c != null and Line_of_Business__c = 'Commercial' limit 1];

            Test.startTest();
            List<String> response =  PricingRequest.getPricingDetail(price.Id, false);
            Test.stopTest();
            system.assert(response != null);
        }   
    }
    /*@testmethodName- getPricingDetail
    *@description- Test getPricingDetail method to get API response by Location API for Commercial
    */
    @isTest static void testPricingDetail_ForCommercialWeekly(){
        //test class errors - SDT - 33363
        List<user> currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(currentuser.get(0)){
       
            Pricing_Request__c price = [select Id From Pricing_Request__c Where Location__c = null and Line_of_Business__c = 'Commercial' and Frequency_Type__c = 'Weekly'  limit 1];

            Test.startTest();
            List<String> response =  PricingRequest.getPricingDetail(price.Id, false);
            Test.stopTest();
            system.assert(response != null);
        }   
    }
    @isTest static void testPricingDetail_Invalid(){
        //test class errors - SDT - 33363
        List<user> currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(currentuser.get(0)){
       
            Pricing_Request__c price = [select Id From Pricing_Request__c Where Location__c != null limit 1];
            Case c = [Select Id From Case Limit 1];

            Test.startTest();
            List<String> response =  PricingRequest.getPricingDetail(c.Id, false);
            Test.stopTest();
            system.assert(response != null);
        }   
    }
    /*@testmethodName- validatePicklist
    *@description- Test validatePicklist method to get Picklist value
    */
    // @isTest static void testPicklist(){
    //     List<user> currentuser = [select id, Bypass_Validation__c from user limit 1];
    //     system.runAs(currentuser.get(0)){
       
    //         Test.startTest();
    //         PricingRequest.picklistWrapper picklistWpr =  PricingRequest.validatePicklist(ObjectApiName, FieldApiName, fieldValue);

    //         Test.stopTest();
    //         system.assert(picklistWpr != null);
    //         system.assertEquals(picklistWpr.isvalid, true);
    //     }   
    // }
    /*@testmethodName- validatePicklist
    *@description- Test validatePicklist method to handle exception
    */
    // @isTest static void testPicklist_InValid(){
    //     List<user> currentuser = [select id, Bypass_Validation__c from user limit 1];
    //     system.runAs(currentuser.get(0)){
       
    //         Test.startTest();
    //         PricingRequest.picklistWrapper picklistWpr =  PricingRequest.validatePicklist(ObjectApiName, null, fieldValue);

    //         Test.stopTest();
    //         system.assert(picklistWpr != null);
    //         system.assertEquals(picklistWpr.isvalid, false);
    //     }   
    // }
    /*@testmethodName- validateDependentPicklist
    *@description- Test validateDependentPicklist method to get Dependent Picklist value
    */
    // @isTest static void testDependentPicklist(){
    //     List<user> currentuser = [select id, Bypass_Validation__c from user limit 1];
    //     system.runAs(currentuser.get(0)){
       
    //         Test.startTest();
    //         PricingRequest.picklistWrapper picklistWpr =  PricingRequest.validateDependentPicklist(ObjectApiName, dp_FieldApiName, ControllingfieldValue, DependentfieldValue);

    //         Test.stopTest();
    //         system.assert(picklistWpr != null);
    //         system.assertEquals(picklistWpr.isvalid, true);
    //     }   
    // }
    /*@testmethodName- validateDependentPicklist
    *@description- Test validateDependentPicklist method to handle exception
    */
    // @isTest static void testDependentPicklist_InValid(){
    //     List<user> currentuser = [select id, Bypass_Validation__c from user limit 1];
    //     system.runAs(currentuser.get(0)){
       
    //         Test.startTest();
    //         PricingRequest.picklistWrapper picklistWpr =  PricingRequest.validateDependentPicklist(ObjectApiName, dp_FieldApiName, 'Test', DependentfieldValue);

    //         Test.stopTest();
    //         system.assert(picklistWpr != null);
    //         system.assertEquals(picklistWpr.isvalid, false);
    //     }   
    // }
    /*@testmethodName- saveReportingFields
    *@description- Test saveReportingFields method 
    */
    @isTest static void testsaveReportingFields(){
        //test class errors - SDT - 33363
        List<user> currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(currentuser.get(0)){
    
            Pricing_Request__c priceReq = [select Id From Pricing_Request__c Where Location__c != null limit 1];

            Test.startTest();
            PricingRequest.saveReportingFields(priceReq, json_Valid);
            Test.stopTest();
            system.assert(priceReq.isAPIResult__c == true);
        }   
    }
    @isTest static void testPricingDetail_Callout() {
        // Set mock callout class 
        Pricing_Request__c price = [select Id From Pricing_Request__c Where Location__c != null limit 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PricingAPIMock());
        
        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        List<String> res = PricingRequest.getPricingDetail(price.Id, false);
        
        Test.stopTest();
        System.assert(res != null);
    }

    @isTest static void testPriceOnlyDetail_Callout() {
        // Set mock callout class 
        Pricing_Request__c price = [select Id From Pricing_Request__c Where Location__c != null limit 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PricingAPIMock());
        
        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        String res = PricingRequest.getPriceOnlyDetail(price.Id, false);
        
        Test.stopTest();
        System.assert(res != null);
    }

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