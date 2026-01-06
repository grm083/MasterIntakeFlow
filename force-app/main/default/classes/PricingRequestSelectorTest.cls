/*
* @Name          PricingRequestSelectorTest
* @Author        Digdershika Ojha
* @Vendor		 TCS
* @Date          25/07/2023
* @description	  This class will be used as Test class for PricingRequestSelector, initially created for story SDT-31298
*/
@isTest (SeeAllData = FALSE)
public class PricingRequestSelectorTest {
    private static final string SYS_ADMIN = 'System Administrator';
    private static final string TRASH = 'Trash';
    private static final string ON_CALL = 'On-Call';
    private static final string ROLLOFF = 'Rolloff';
    private static final string COMMERCIAL = 'Commercial';
    private static final string SERVICES = 'Services';
    private static final string EQUIPMENT = 'Equipment';
    private static final string FieldApiName = 'Material_Code__c';
    private static final String JSON_VALID_ROLLOFF_DATA = '{"data":{"priceQuoteIdentifier":"Q11837","costSource":"WM (SBS|RO|OT|30O|B02860|20211019|025300|5810)","contractType":"Open Market","lineOfBusiness":"Roll off","supplierCode":"10016","supplierName":"WMI OF MI, LIVONIA","customerCode":"HMD","customerName":"The Home Depot","locationCode":"HMD002718","wasteStreamCode":"MSW_RO","wasteStreamName":"Municipal Solid Waste","equipmentCode":"30O","equipmentName":"30 Yard Open Top","equipmentUOM":"Tons","materialCode":"T","materialName":"MSW - Unspecified","equipmentSizeCode":"YRDS-30","equipmentSizeName":"30 Yards","overridableEquipmentSizeCode":null,"overridableEquipmentSizeName":null,"zoneCode":"GIS543320","zoneName":"Detroit Central - RO MSW - To Woodland 1","disposalFacilityType":"S04264_LF","disposalFacilityName":"B02860|S04264_LF|129A_WDL|MSW_RO","commercial":null,"rollOff":{"pricingMethodDisposalCode":"1.0","pricingMethodDisposalDescription":"Market Based Pricing","pricingMethodHaulingCode":"1.0","pricingMethodHaulingDescription":"Market Based Pricing","haulCost":410.59,"haulPrice":null,"disposalCost":30.42,"disposalPrice":null,"estimatedVolumePerHaul":4,"applyInvoiceFeesToDisposalCharges":"Y","applyInvoiceFeesToRentalCharges":null,"travelTimePerHaul":126.68,"landfillMinutes":25,"transferSiteCode":"NA","equipmentAvailabilityTypeCode":"TEMP","materialClassName":"MSW_MSWI_Municipal Solid Waste - Industrial","equipmentLoadingMinutes":20,"equipmentAdditionalLoadingMinutes":null,"stepDisposals":null},"wmMetaData":{"businessUnit":"B02860","masLibrary":"129A_WDL","francisePricingLink":"","greenPagesLink":"","marketArea":"WM of Michigan Ohio Indiana"},"tpMetaData":null,"serviceCharges":[{"code":"FU_RO_TEMP_OPEN","name":"Fuel Fee","componentTypeCode":"ENS","componentTypeName":"Energy Surcharge","actionCode":"EX","actionName":"Exclude","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly"},{"code":"ENV_RO_TEMP_OPEN","name":"Environmental Fee","componentTypeCode":"ENV_FEE","componentTypeName":"Environmental Fee","actionCode":"EX","actionName":"Exclude","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly"},{"code":"RCR_RO_TEMP_OPEN","name":"Regulatory Cost Recovery","componentTypeCode":"UNK","componentTypeName":"Unknown","actionCode":"EX","actionName":"Exclude","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly"},{"code":"CSC_RO_TEMP_OPEN","name":"Container Service Charge","componentTypeCode":"UNK","componentTypeName":"Unknown","actionCode":"EX","actionName":"Exclude","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly"},{"code":"D_RO_TEMP_OPEN","name":"Delivery","componentTypeCode":"UNK","componentTypeName":"Unknown","actionCode":"EX","actionName":"Exclude","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly"}]},"problem":null}';
    private static String PT_VALUE = 'Pricing MulltiVendor PT Switch';
    private static String AM_VALUE = 'Pricing MulltiVendor AM Switch';   
    /*
	 * @MethodName    setup
	 * @description	  This method will be used to setup inital required data to test prcingRequest queries
	 * @return		  void
	 */
	@testSetup static void setup(){
        Profile adminProfile = TestDataFactory.getProfile(SYS_ADMIN);
        
        User usr = TestDataFactory.createUser(adminProfile);
        Database.insert(usr);  
        
        User bypassuser = TestDataFactory.createUser(adminProfile);
        bypassuser.Bypass_Validation__c = true;
        insert bypassuser;

        //Changes for SDT-39632
        CodeSwitchTestData.CodeSwitchData();

        System.runAs(usr){
            List<Opportunity> oppList = new List<Opportunity>();
            List<SBQQ__Quote__c> quoteList= new List<SBQQ__Quote__c>();
            List<Product2> prdList = new List<Product2>();    
            list<Account> acclist = new List<Account>();

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

            Product2 prodHaul= TestDataFactory.createProduct('Haul',SERVICES,'H');
            prdList.add(prodHaul);

            Product2 prodDisposal= TestDataFactory.createProduct('Disposal',SERVICES,'DSP');
            prdList.add(prodDisposal);

            Product2 prodDelivery= TestDataFactory.createProduct('Delivery',SERVICES,'DLV');
            prdList.add(prodDelivery);

            Product2 prodTrash = TestDataFactory.createProduct('Trash','Waste Stream','T');
            prodTrash.Is_Pricing_Eligible__c = true;
            prdList.add(prodTrash);

            Database.insert(prdList);

            RecurrsiveTriggerHandler.bypassValidationQuoteLine = true;

            List<SBQQ__QuoteLine__c> qlHdr = new List<SBQQ__QuoteLine__c>();
            //Bundle 1 - Open Top
            SBQQ__QuoteLine__c qlOT = TestDataFactory.createQuoteLineRecords(quoteList[0],prodOpenTop,'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
            qlOT.SBQQ__Bundle__c = TRUE;
            qlOT.SBQQ__RequiredBy__c = null;
            qlOT.Vendor__c = vendorAcc.Id;
            qlOT.Location_Position_Name__c = accLocPosition.Id;
            qlHdr.add(qlOT);
            insert qlHdr;

            List<SBQQ__QuoteLine__c> qlChild = new List<SBQQ__QuoteLine__c>();

            //Open Top Child Quote Line  --- Start
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

            Database.insert(qlChild);      

            
            //Open Top Valid Data - Asset Management Price Only
            Pricing_Request__c pReq1 = TestDataFactory.createPricingRequestRecord(newServiceCase, acclist[0], locationlist[0], ROLLOFF, 'AMPO', '', JSON_VALID_ROLLOFF_DATA, usr);
            pReq1.Service_City__c = 'Test OT AMPO';
            pReq1.Quote__c = quoteList[0].Id;
            insert pReq1;
		
	    Code_Switch__c ptsetting = new Code_Switch__c();
            ptsetting.Name = PT_VALUE;
            ptsetting.Switch_Off__c  = false;
            insert ptsetting;
            
            Code_Switch__c amsetting = new Code_Switch__c();
            amsetting.Name = AM_VALUE;
            amsetting.Switch_Off__c  = false;
            insert amsetting;
           }
    }
    /*
     * @MethodName    : testGetPricingList
     * @description	  : Test if getPricingList method is able to fetch the Pricing_Request__c records for matching quote and limit counts
     * @return        : void
     */
     @isTest
     static void testGetPricingList(){
         Test.startTest();
         SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c limit 1];
         list<Pricing_Request__c> pricingReqList = PricingRequestSelector.getPricingList(quote.Id, 1);
         //system.assertEquals(1,pricingReqList.size(),'Expected record size is 1');
         Test.stopTest();
         
     }
    /*
     * @MethodName    : testGetPricingRequestListById
     * @description	  : Test if getPricingRequestListById method is able to fetch the Pricing_Request__c records for set of pricing requests Ids
     * @return        : void
     */
     @isTest
     static void testGetPricingRequestListById(){
         Test.startTest();
         Set<Id> pricingIdSet = new Set<Id>(New Map<Id, Pricing_Request__c>([SELECT Id FROM Pricing_Request__c limit 1]).keySet());
         list<Pricing_Request__c> pricingReqList = PricingRequestSelector.getPricingRequestListById(pricingIdSet);
         //system.assertEquals(1,pricingReqList.size(),'Expected record size is 1');
         Test.stopTest();
     }
	
	@isTest
     static void testgetPricingRequestList(){
         Test.startTest();
         SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c limit 1];
         list<Pricing_Request__c> pricingReqList = PricingRequestSelector.getStandardPricingRequestList(quote.Id);
         list<SBQQ__QuoteLine__c> quoteLineList = PricingRequestSelector.getQuoteLineList(quote.Id);
         list<Pricing_Request__c> standardPricingReqList = PricingRequestSelector.getStandardPricingRequestList(quote.Id,1);
         Test.stopTest();
     }
    
    @isTest
     static void testisPricingMulltiVendorPTSwitchON(){
         Test.startTest();
         boolean pricingMultiVendorPTSwitch = PricingRequestSelector.isPricingMulltiVendorPTSwitchON();
         Test.stopTest();
     }
    @isTest
     static void testisPricingMulltiVendorAMSwitchON(){
         Test.startTest();
         boolean pricingMultiVendorAMSwitch = PricingRequestSelector.isPricingMulltiVendorAMSwitchON();
         Test.stopTest();
     }
}
