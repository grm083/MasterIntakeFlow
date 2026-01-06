@isTest(seeAllData =false)
public class QuoteLineTriggerHelperTest {
  
     private static final string SYS_ADMIN = 'System Administrator';
    private static final string TRASH = 'Trash';
    private static final string ON_CALL = 'On-Call';
    private static final string ROLLOFF = 'Rolloff';
    private static final string COMMERCIAL = 'Commercial';
    private static final string SERVICES = 'Services';
    private static final string EQUIPMENT = 'Equipment';

    private static final string ObjectApiName = 'Pricing_Request__c';
    private static final string FieldApiName = 'Material_Code__c';
    private static final string fieldValue = 'Cardboard';
    //SDT-29645
    public static final String AAV_API_REQUEST_OUTPUT = '{"data": {"requestedDate": "2023-09-04","lineOfBusiness": "Roll Off","customerCode": "HMD","customerName": "The Home Depot","locationCode": "HMD006959","materialCode": "T","materialName": "Trash","countryCode": "USA","suppliers": [{"availabilitySource": "WM","supplierCode": null,"supplierName": null,"contractType": "Competitor","wasteStreamCode": "MSW","wasteStreamName": "Municipal Solid Waste","zoneCode": "GIS624853","zoneName": "Non WM Franchise - Bainbridge - CM MSW","wmMetaData": {"marketAreaCode": "K00126","marketAreaName": "WM of South Atlantic","facilityId": "GA0075","facilityName": "Albany Hauling","siteId": "S10284","siteName": "Albany Hauling"},"tpMetaData": null,"deliveryDays": null,"serviceDays": null,"deliveries": null,"outages": null,"messages": [{"code": "ER400","description": "WM Schedule information not available due to Competitor / Franchise Contract Type"}]}],"messages": []},"problem": null}';
 	public static String JSON_VALID_ROLLOFF_DATA = '{"data":{"priceQuoteIdentifier":"Q11837","costSource":"WM (SBS|RO|OT|30O|B02860|20211019|025300|5810)","contractType":"Open Market","lineOfBusiness":"Roll Off","supplierCode":"10016","supplierName":"WMI OF MI, LIVONIA","customerCode":"HMD","customerName":"The Home Depot","locationCode":"HMD002718","wasteStreamCode":"MSW_RO","wasteStreamName":"Municipal Solid Waste","equipmentCode":"30O","equipmentName":"30 Yard Open Top","equipmentUOM":"Tons","materialCode":"T","materialName":"MSW - Unspecified","equipmentSizeCode":"YRDS-30","equipmentSizeName":"30 Yards","overridableEquipmentSizeCode":null,"overridableEquipmentSizeName":null,"zoneCode":"GIS543320","zoneName":"Detroit Central - RO MSW - To Woodland 1","disposalFacilityType":"S04264_LF","disposalFacilityName":"B02860|S04264_LF|129A_WDL|MSW_RO","commercial":null,"rollOff":{"pricingMethodDisposalCode":"1.0","pricingMethodDisposalDescription":"Market Based Pricing","pricingMethodHaulingCode":"1.0","pricingMethodHaulingDescription":"Market Based Pricing","haulCost":410.59,"haulPrice":null,"disposalCost":30.42,"disposalPrice":null,"estimatedVolumePerHaul":4,"applyInvoiceFeesToDisposalCharges":"Y","applyInvoiceFeesToRentalCharges":null,"travelTimePerHaul":126.68,"landfillMinutes":25,"transferSiteCode":"NA","equipmentAvailabilityTypeCode":"TEMP","materialClassName":"MSW_MSWI_Municipal Solid Waste - Industrial","equipmentLoadingMinutes":20,"equipmentAdditionalLoadingMinutes":null,"stepDisposals":null},"wmMetaData":{"businessUnit":"B02860","masLibrary":"129A_WDL","francisePricingLink":"","greenPagesLink":"","marketArea":"WM of Michigan Ohio Indiana"},"tpMetaData":null,"serviceCharges":[{"code":"FU_RO_TEMP_OPEN","name":"Fuel Fee","componentTypeCode":"ENS","componentTypeName":"Energy Surcharge","actionCode":"EX","actionName":"Exclude","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly"},{"code":"ENV_RO_TEMP_OPEN","name":"Environmental Fee","componentTypeCode":"ENV_FEE","componentTypeName":"Environmental Fee","actionCode":"EX","actionName":"Exclude","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly"},{"code":"RCR_RO_TEMP_OPEN","name":"Regulatory Cost Recovery","componentTypeCode":"UNK","componentTypeName":"Unknown","actionCode":"EX","actionName":"Exclude","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly"},{"code":"CSC_RO_TEMP_OPEN","name":"Container Service Charge","componentTypeCode":"UNK","componentTypeName":"Unknown","actionCode":"EX","actionName":"Exclude","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly"},{"code":"D_RO_TEMP_OPEN","name":"Delivery","componentTypeCode":"UNK","componentTypeName":"Unknown","actionCode":"EX","actionName":"Exclude","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly"}]},"problem":null}';
    public static String facilityId = '123';          
    @testSetup static void setup(){
     test.startTest();   
     Profile adminProfile = TestDataFactory.getProfile(SYS_ADMIN);
        
        User usr = TestDataFactory.createUser(adminProfile);
		usr.FirstName = 'Testuser#9999';
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
            
            // Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Vendor').getRecordTypeId();

            Account accParent = new Account(Name = 'Parent Account', phone = '9999999999', OwnerId = usr.id, AccountNumber='5678',
             RecordTypeid = TestDataFactory.getRecordType('Client','Account'), IsPricingEligible__c = true); 
            insert accParent;

            Account acc = new Account(Name = Constant_Util.KEYWORD_TEST, phone = '9999999999', OwnerId = usr.id, AccountNumber='1234',
                RecordTypeid = TestDataFactory.getRecordType('Client','Account'), IsPricingEligible__c = true, ParentId = accParent.Id, Type ='Location');
            acclist.add(acc);

            Account vendorAcc = new Account(Name = 'WM Vendor Account',Vendor_Business_Unit__c= '286',phone = '9999999999', OwnerId = usr.id, AccountNumber='4321',
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
			
			quoteList.addAll(TestDataFactory.createQuoteRecords(oppList,acclist[0],conlist[0],Date.today(),false,true));
            quoteList[1].SBQQ__ShippingStreet__c = 'ABC';
            quoteList[1].SBQQ__ShippingCity__c = 'Test1';
            quoteList[1].SBQQ__ShippingCountry__c = 'USA';
            quoteList[1].SBQQ__ShippingState__c = 'NY';
            quoteList[1].SBQQ__ShippingPostalCode__c = '1234';
            quoteList[1].Duration__c = 'Permanent';
            quoteList[1].SBQQ__Status__c = 'Product Configured';
			
			
            //added for error
            //quoteList[0].Action_Type__c = 'Escalation';
            //quoteList[0].Action_Reason__c = '';
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

            Product2 prodCardboard = TestDataFactory.createProduct('Cardboard','Waste Stream','C');
            prodCardboard.Is_Pricing_Eligible__c = true;
            prdList.add(prodCardboard);

            Database.insert(prdList);

            RecurrsiveTriggerHandler.bypassValidationQuoteLine = true;

            List<SBQQ__QuoteLine__c> qlHdr = new List<SBQQ__QuoteLine__c>();
            //Bundle 1 - Open Top
            SBQQ__QuoteLine__c qlOT = TestDataFactory.createQuoteLineRecords(quoteList[0],prodOpenTop,'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
            qlOT.SBQQ__Bundle__c = TRUE;
            qlOT.SBQQ__RequiredBy__c = null;
            qlOT.Vendor__c = vendorAcc.Id;
            qlOT.IsExtraPickup__c = true;
            qlOT.Location_Position_Name__c = accLocPosition.Id;
            qlHdr.add(qlOT);
			
			SBQQ__QuoteLine__c qlOT2 = TestDataFactory.createQuoteLineRecords(quoteList[1],prodOpenTop,'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
            qlOT2.SBQQ__Bundle__c = TRUE;
            qlOT2.SBQQ__RequiredBy__c = null;
            qlOT2.Vendor__c = vendorAcc.Id;
            qlOT2.IsExtraPickup__c = true;
            qlOT2.Location_Position_Name__c = accLocPosition.Id;
            qlHdr.add(qlOT2);

            //Bundle 2 - Dumpster
            SBQQ__QuoteLine__c qlDMP = TestDataFactory.createQuoteLineRecords(quoteList[0],prodDumpster,'PERM',1.00,'CLT','YRDS-4','SCH','M','1','PER',34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
            qlDMP.SBQQ__Bundle__c = TRUE;
            qlDMP.SBQQ__RequiredBy__c = null;
            qlDMP.Vendor__c = vendorAcc.Id;
            qlHdr.add(qlDMP);

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
	        test.stopTest();
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

            
            //Dumpster Child Quote Line  --- Start
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
            SBQQ__QuoteLine__c qlCMPT = TestDataFactory.createQuoteLineRecords(quoteList[0],prodTrash,'TEMP',1.00,'CLT','YRDS-20','OC',null,null,'PER',34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
            qlCMPT.SBQQ__RequiredBy__c = qlCMPV.Id;
            qlCMPT.Vendor__c = vendorAcc.Id;
            qlChild.add(qlCMPT);

            SBQQ__QuoteLine__c qlCMPHaul = TestDataFactory.createQuoteLineRecords(quoteList[0],prodHaul,'TEMP',1.00,'CLT','YRDS-20','OC',null,null,'PER',34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
            qlCMPHaul.SBQQ__RequiredBy__c = qlCMPV.Id;
            qlCMPHaul.Vendor__c = vendorAcc.Id;
            qlChild.add(qlCMPHaul);
            //Vertical  Compactor Child Quote Line  --- End

            //Horizontal Compactor Child Quote Line  --- Start
            SBQQ__QuoteLine__c qlCMPHT = TestDataFactory.createQuoteLineRecords(quoteList[0],prodTrash,'TEMP',1.00,'CLT','YRDS-4',null,null,null,'PER',0,'MTH','PER',35.0,'MTH','Do Not Override','NBG');
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

            // SBQQ__QuoteLine__c qlCMPHEPCK = TestDataFactory.createQuoteLineRecords(quoteList[0],prodExPickup,'TEMP',1.00,'CLT','YRDS-4',null,null,null,'PER',0,'MTH','PER',35.0,'MTH','Do Not Override','NBG');
            // qlCMPHEPCK.SBQQ__RequiredBy__c = qlCMPH.Id;
            // qlCMPHEPCK.Vendor__c = vendorAcc.Id;
            // qlChild.add(qlCMPHEPCK);
            //Horizontal  Compactor Child Quote Line  --- End

            Database.insert(qlChild);  

			List<SBQQ__QuoteLine__c> qlChild2 = new List<SBQQ__QuoteLine__c>();
			
			SBQQ__QuoteLine__c qlOTT2 = TestDataFactory.createQuoteLineRecords(quoteList[1],prodTrash,'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
            qlOTT2.SBQQ__RequiredBy__c = qlOT2.Id;
            qlOTT2.Vendor__c = vendorAcc.Id;
            qlChild2.add(qlOTT2);
			insert qlChild2;
             //SDT-29645 create pricing request
            Pricing_Request__c pricingRequest = TestDataFactory.createPricingRequestRecord(newServiceCase, acclist.get(0), locationlist[0],
                                                                                           'Rolloff', 'AM', '', 
                                                                                           JSON_VALID_ROLLOFF_DATA, usr);
            pricingRequest.zone_Type__c = 'Open Market';
            pricingRequest.Facility_Id__c = facilityId;
            pricingRequest.Facility_Name__c = 'test';
            pricingRequest.Site_Id__c = '123';
            pricingRequest.Site_Name__c = 'test';
            Insert pricingRequest;
            
            List<Quote_Line_History_Tracking__c> deletedQuoteLineList = new List<Quote_Line_History_Tracking__c>();
                Quote_Line_History_Tracking__c history = new Quote_Line_History_Tracking__c();
				   history.Action__c = 'Deleted';
				   history.Quote_Line__c = qlChild2[0].Id;
				   history.Quote_Line_Number__c = qlChild2[0].Name;
				   history.Quote_Number__c = qlChild2[0].SBQQ__Quote__r.Name;
				   history.Quote_Id__c= qlChild2[0].SBQQ__Quote__c;
				   history.Product_Name__c = qlChild2[0].SBQQ__Product__r.Name;
				   history.User_Name__c = qlChild2[0].LastModifiedBy.Name;
				   
				   deletedQuoteLineList.add(history);
				   
				    Quote_Line_History_Tracking__c history2 = new Quote_Line_History_Tracking__c();
				   history2.Action__c = 'Added';
				   history2.Quote_Line__c = qlChild2[0].Id;
				   history2.Quote_Line_Number__c = qlChild2[0].Name;
				   history2.Quote_Number__c = qlChild2[0].SBQQ__Quote__r.Name;
				   history2.Quote_Id__c= qlChild2[0].SBQQ__Quote__c;
				   history2.Product_Name__c = qlChild2[0].SBQQ__Product__r.Name;
				   history2.User_Name__c = qlChild2[0].LastModifiedBy.Name;
           
			 deletedQuoteLineList.add(history2);
			 insert deletedQuoteLineList;
			
                     MAS_Setup_Detail__c mas = new MAS_Setup_Detail__c();
        mas.MAS_Line_of_Business__c = 'O';
        mas.MAS_Library__c = 'ARDTA.129A';
        mas.Business_Unit_Number__c = '286';
        mas.MAS_Company_Code__c = '286';
            //SDT-29645
            mas.Valid_For_New_Service__c = true;
            mas.Facility_Id__c = facilityId;
        insert mas;
    }
    }   
    
     @isTest static void quoteLineTest(){ 
    	
        test.startTest();
            List<Account> vendorAcc = [Select id,Vendor_Business_Unit__c from Account where Name= 'WM Vendor Account' limit 1];
            System.debug('####vendorAcc'+vendorAcc);
       		List<MAS_Setup_Detail__c> masLst = [Select id,MAS_Line_of_Business__c,MAS_Company_Code__c,MAS_Library__c,Business_Unit_Number__c from MAS_Setup_Detail__c where MAS_Company_Code__c = '286'];
            List<SBQQ__QuoteLine__c> lstQuoteLine = [Select id,Vendor__c,SBQQ__RequiredBy__c from SBQQ__QuoteLine__c where SBQQ__RequiredBy__c = null limit 1];
        	System.debug('lstQuoteLine'+lstQuoteLine[0].SBQQ__RequiredBy__c);
            lstQuoteLine[0].Vendor__c = vendorAcc[0].Id ;
            update lstQuoteLine;
         
         Set<id> sqlID = new Set<id>();
         
         for(SBQQ__QuoteLine__c sbl : lstQuoteLine){
             
             sqlID.add(sbl.Id);
         }
         
         //QuoteLineTriggerHelper.updateCompanyCode(lstQuoteLine,sqlID);
                         
        test.stopTest();
        //lstQuoteLine.Vendor__c = vendorAcc.Id;
        //update lstQuoteLine;
    }
       @isTest static void createApprovalLogTest(){
           test.startTest();
        		quoteLineTestData();
           test.stopTest();
    }
        //test
      @isTest static void frameICCqLineTest(){
           test.startTest();
           Account accParent = [Select Id, Name FROM Account WHERE Name =: 'Parent Account' LIMIT 1];
           List<Account> location = [Select Id, AccountNumber, ParentId FROM Account WHERE AccountNumber =: Constant_Util.LOCATION LIMIT 1];
           Account vendorAcc = [Select Id, Name FROM Account WHERE Name =: 'WM Vendor Account' LIMIT 1];
           Contact con = [Select Id from Contact limit 1];
           User usr = [Select Id, FirstName from User WHERE FirstName = 'Testuser#9999' LIMIT 1];
           Opportunity opp = [Select Id from Opportunity LIMIT 1];
           Product2 prodOpenTop = [Select Id, Name FROM Product2 WHERE Name =: 'Open Top' LIMIT 1];
           Product2 prodDumpster = [Select Id, Name FROM Product2 WHERE Name =: 'Dumpster' LIMIT 1];
           //creating case with recordtype Pickup Case
            Case pickUpCase = QuoteTestDataFactory.createCase(ConstantClass.RecordType_PickUpCase,
                                                              Constant_Util.PICKUP_CSTYPE,Constant_Util.EMPTY_AND_RETURN, 'Contaminated',
                                                              accParent, con, location[0]);
            Database.insert(pickUpCase);
          
          SBQQ__Quote__c newQuote = QuoteTestDataFactory.createQuoteRecords(opp, location[0], con);
            newQuote.SBQQ__ShippingStreet__c = 'ABC';
            newQuote.SBQQ__ShippingCity__c = 'Test1';
            newQuote.SBQQ__ShippingCountry__c = 'USA';
            newQuote.SBQQ__ShippingState__c = 'NY';
            newQuote.SBQQ__ShippingPostalCode__c = '1234';
            newQuote.Duration__c = 'Permanent';
            insert newQuote;
          
          //creating asset
          list<Asset> assetlist = TestDataFactory.createAsset(Constant_Util.CONSTANT_FIRST, accParent, con, 
                                                                prodOpenTop, usr, location[0]);
            List<Project_Code__c> pCodeList=TestDataFactory.createProjectCode(accParent.Id);
            Database.insert(pCodeList);
            //assetlist[0].Project_Code__c = pCodeList[0].Id;
            assetlist[0].End_Date__c = system.today() - 2;
            Database.insert(assetlist);
          
          //QuoteLine Creation
          //Bundle 1 - Open Top
            SBQQ__QuoteLine__c qlOT = TestDataFactory.createQuoteLineRecords(newQuote,prodOpenTop,'TEMP',1.00,'CLT','YRDS-30','SOC','M','1','PER',34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
            qlOT.SBQQ__Bundle__c = TRUE;
            qlOT.Schedule_Frequency__c = 'W';
            qlOT.Service_Days__c = 'M';
            qlOT.SBQQ__RequiredBy__c = null;
            qlOT.Vendor__c = vendorAcc.Id;
            qlOT.IsExtraPickup__c = true;
            qloT.AssetId__c = assetlist[0].Id;
            insert qloT;
          //Bundle 2 - Dumpster
            SBQQ__QuoteLine__c qlDMP = TestDataFactory.createQuoteLineRecords(newQuote,prodDumpster,'PERM',1.00,'CLT','YRDS-4','OC','M','W','PER',34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
            qlDMP.SBQQ__Bundle__c = TRUE;
            qlDMP.SBQQ__RequiredBy__c = null;
            qlDMP.Vendor__c = vendorAcc.Id;
            insert qlDMP;
          
           test.stopTest();
    } 
    
    //test
     /* @isTest static void frameICCqLineTest(){
           test.startTest();
           Account accParent = [Select Id, Name FROM Account WHERE Name =: 'Parent Account' LIMIT 1];
           List<Account> location = [Select Id, AccountNumber, ParentId FROM Account WHERE AccountNumber =: Constant_Util.LOCATION LIMIT 1];
           Account vendorAcc = [Select Id, Name FROM Account WHERE Name =: 'WM Vendor Account' LIMIT 1];
           Contact con = [Select Id from Contact limit 1];
           User usr = [Select Id, FirstName from User WHERE FirstName = 'Testuser#9999' LIMIT 1];
           Opportunity opp = [Select Id from Opportunity LIMIT 1];
           Product2 prodOpenTop = [Select Id, Name FROM Product2 WHERE Name =: 'Open Top' LIMIT 1];
           Product2 prodDumpster = [Select Id, Name FROM Product2 WHERE Name =: 'Dumpster' LIMIT 1];
           //creating case with recordtype Pickup Case
            Case pickUpCase = QuoteTestDataFactory.createCase(ConstantClass.RecordType_PickUpCase,
                                                              Constant_Util.PICKUP_CSTYPE,Constant_Util.EMPTY_AND_RETURN, 'Contaminated',
                                                              accParent, con, location[0]);
            Database.insert(pickUpCase);
          
          SBQQ__Quote__c newQuote = QuoteTestDataFactory.createQuoteRecords(opp, location[0], con);
            newQuote.SBQQ__ShippingStreet__c = 'ABC';
            newQuote.SBQQ__ShippingCity__c = 'Test1';
            newQuote.SBQQ__ShippingCountry__c = 'USA';
            newQuote.SBQQ__ShippingState__c = 'NY';
            newQuote.SBQQ__ShippingPostalCode__c = '1234';
            newQuote.Duration__c = 'Permanent';
            insert newQuote;
          
          //creating asset
          list<Asset> assetlist = TestDataFactory.createAsset(Constant_Util.CONSTANT_FIRST, accParent, con, 
                                                                prodOpenTop, usr, location[0]);
            List<Project_Code__c> pCodeList=TestDataFactory.createProjectCode(accParent.Id);
            Database.insert(pCodeList);
            //assetlist[0].Project_Code__c = pCodeList[0].Id;
            assetlist[0].End_Date__c = system.today() - 2;
            Database.insert(assetlist);
          
          //QuoteLine Creation
          //Bundle 1 - Open Top
            SBQQ__QuoteLine__c qlOT = TestDataFactory.createQuoteLineRecords(newQuote,prodOpenTop,'TEMP',1.00,'CLT','YRDS-30','SOC','M','1','PER',34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
            qlOT.SBQQ__Bundle__c = TRUE;
            qlOT.Schedule_Frequency__c = 'W';
            qlOT.Service_Days__c = 'M';
            qlOT.SBQQ__RequiredBy__c = null;
            qlOT.Vendor__c = vendorAcc.Id;
            qlOT.IsExtraPickup__c = true;
            qloT.AssetId__c = assetlist[0].Id;
            insert qloT;
          //Bundle 2 - Dumpster
            SBQQ__QuoteLine__c qlDMP = TestDataFactory.createQuoteLineRecords(newQuote,prodDumpster,'PERM',1.00,'CLT','YRDS-4','OC','M','W','PER',34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
            qlDMP.SBQQ__Bundle__c = TRUE;
            qlDMP.SBQQ__RequiredBy__c = null;
            qlDMP.Vendor__c = vendorAcc.Id;
            insert qlDMP;
          
           test.stopTest();
    } */
    
    //test
    @isTest static void assignExtraPickUpTest() {
        test.startTest();
        List<Product2> productList = [Select Id FROM Product2 LIMIT 2]; 
        SBQQ__QuoteLine__c pQline = [Select Id, SBQQ__Quote__c, Account__c, CurrencyIsoCode, SBQQ__StartDate__c, Exception_Effective_Date__c, Exceptions_Effective_Date__c, Exception_Type__c, Exception_Reason__c, Exception_Comments__c, Duration__c, sCode__c, Equipment_Size__c FROM SBQQ__QuoteLine__c LIMIT 1];
        id ePickUpId = [Select Id FROM Product2 LIMIT 1][0].Id;
        decimal nextNumber = 12345;
        //creating product option
        SBQQ__ProductOption__c sbqq = new SBQQ__ProductOption__c();
          sbqq.SBQQ__ConfiguredSKU__c = productList[0].Id;
          sbqq.SBQQ__OptionalSKU__c = productList[1].Id;
          sbqq.SBQQ__Number__c = 350;
          sbqq.SBQQ__Quantity__c = 1;
          sbqq.Occurrence_Type__c = 'SCH';
          sbqq.CostModelType__c = 'PER';
          sbqq.Cost_Unit_of_Measure__c = 'MTH';
          sbqq.PriceUOM__c = 'MTH';
          sbqq.Schedule_Frequency__c = 'W';
          sbqq.Frequency_Interval__c = '1';
        insert sbqq;
        
        SBQQ__ProductOption__c productOptionEP = [Select Id, Cost_Unit_of_Measure__c, PriceUOM__c FROM SBQQ__ProductOption__c LIMIT 1];
        
        //SDT36176
        //QuoteLineTriggerHelper.assignExtraPickUp(pQline, productOptionEP.Id, sbqq.Id, nextNumber, productOptionEP);
        ExtraPickupHandler.assignExtraPickUp(pQline, productOptionEP.Id, sbqq.Id, nextNumber, productOptionEP);
        test.stoptest();
    }
    
    
    //test
    @isTest static void getDateTimeInGMTForGivenDateTimeTest() {
        DateTime objGivenDT = DateTime.newInstance(1999, 2, 11, 8, 6, 16);
        String objDateTimeGMT = (QuoteLineTriggerHelper.getDateTimeInGMTForGivenDateTime(objGivenDT)).format();
        //System.assertEquals('11/2/1999 5:30 pm', objDateTimeGMT);
        
    }
    
         //test
    @isTest static void setExceptionsEffectiveDateTest() {
    Test.startTest();
        try {
     List<Account> location = [Select Id, AccountNumber, ParentId FROM Account WHERE AccountNumber =: Constant_Util.LOCATION LIMIT 1];
     Contact con = [Select Id from Contact limit 1];
     Opportunity opp = [Select Id from Opportunity LIMIT 1];
        Product2 prodOpenTop = [Select Id, Name FROM Product2 WHERE Name =: 'Open Top' LIMIT 1];
     QuoteLineTriggerHelper quoteLineObj = new QuoteLineTriggerHelper();
     SBQQ__Quote__c newQuote = QuoteTestDataFactory.createQuoteRecords(opp, location[0], con);
      newQuote.Alternate_Description__c = 'testAlternateDescription';
        newQuote.Alternate_Service_Provided__c = TRUE;
      insert newQuote;
     //List<SBQQ__QuoteLine__c > quoteLineNewList = [Select id,Exceptions_Effective_Date__c,SBQQ__Quote__c  from SBQQ__QuoteLine__c where SBQQ__Quote__c  != null LIMIT 1];
     // quoteLineNewList[0].SBQQ__Quote__c = newQuote.Id;
       //Bundle 1 - Open Top
            SBQQ__QuoteLine__c qlOT = TestDataFactory.createQuoteLineRecords(newQuote,prodOpenTop,'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
            qlOT.SBQQ__Bundle__c = TRUE;
            qlOT.SBQQ__RequiredBy__c = null;
            //qlOT.Vendor__c = vendorAcc.Id;
            qlOT.IsExtraPickup__c = true;
        	//qlOT.Is_Substituted_Container__c = TRUE;
            //qlOT.Location_Position_Name__c = accLocPosition.Id;
           insert qloT;
        
       //quoteLineObj.updateSubsContainer(newQuote.id);
        
        SBQQ__QuoteLine__c insertedQL = [Select id,Exceptions_Effective_Date__c,SBQQ__Quote__c  from SBQQ__QuoteLine__c where Id  =: qloT.Id LIMIT 1];
        List<SBQQ__QuoteLine__c > quoteLineNewList = new List<SBQQ__QuoteLine__c >();
        quoteLineNewList.add(insertedQL);
        //QuoteLineTriggerHelper.setExceptionsEffectiveDate(quoteLineNewList);
        }
        catch(exception ex) {
            system.debug(ex);
        }
        
        Test.stopTest();
    } 
    
    
    //test
    @isTest static void strTosetTest() {
        String str = 'For123testing12testing555';
        String splitByChar = 't';
        
        Set<string> fSet = QuoteLineTriggerHelper.strToset(str, splitByChar);
        System.assertEquals(4, fSet.size());
    }
    
    //test
    @isTest static void setToStrTest() {
        Set<string> setStr = new Set<String>{'For123', 'es', 'ing12', 'ing555'};
        String splitByChar = 't';
        
        string fStr = QuoteLineTriggerHelper.setToStr(setStr, splitByChar);
        System.assertEquals('For123testing12ting555', fStr);
    }
    
   
    @istest static void beforeDeleteTest() {
		List<Quote_Line_History_Tracking__c> qlhRecord = new List<Quote_Line_History_Tracking__c>();
		qlhRecord = [Select id,Quote_Line_Number__c from Quote_Line_History_Tracking__c];
        
        
        List<SBQQ__QuoteLine__c > quoteLineNewList = [Select id,Exceptions_Effective_Date__c,SBQQ__Quote__c  from SBQQ__QuoteLine__c LIMIT 1];
        delete quoteLineNewList;
        List<SBQQ__QuoteLine__c > quoteLineNewList2 = [Select id,Exceptions_Effective_Date__c,SBQQ__Quote__c  from SBQQ__QuoteLine__c where SBQQ__Quote__r.SBQQ__Status__c = 'Product Configured' LIMIT 1];
        delete quoteLineNewList2;
    }

    private static void quoteLineTestData(){
        

        SBQQ__QuoteLine__c qql = [Select id,IsExtraPickup__c ,SBQQ__Quote__r.SBQQ__Account__c ,Account__C, SBQQ__StartDate__c, SBQQ__EndDate__c,
                                  SBQQ__Quote__r.SBQQ__StartDate__c, SBQQ__Quote__r.SBQQ__EndDate__c, Duration__c, SBQQ__Quote__r.Duration__c,
                                  Material_Type__c
                                  From SBQQ__QuoteLine__c limit 1 ];
                                  
        system.assertEquals(True, qql.IsExtraPickup__c);
        //SBQQ__QuoteLine__c quoteLine1 = [Select id,SBQQ__Quote__r.SBQQ__Account__c ,Account__C  from SBQQ__QuoteLine__c where id=:ql.Id ];
       system.assertEquals(qql.Account__C,qql.SBQQ__Quote__r.SBQQ__Account__c);
        system.assertEquals(qql.SBQQ__StartDate__c, qql.SBQQ__Quote__r.SBQQ__StartDate__c);
        system.assertEquals(qql.SBQQ__EndDate__c, qql.SBQQ__Quote__r.SBQQ__EndDate__c);
        //system.assertEquals(qql.Duration__c, 'TEMP');
        System.debug('@@@qql.Duration__c'+qql.Duration__c);
       // system.assertEquals(qql.Material_Type__c, prod4.Name);
        SBQQ__QuoteLine__c extraPickupQL = [Select id,IsExtraPickup__c from SBQQ__QuoteLine__c where SBQQ__ProductName__c ='Extra Pickup'];
       system.debug('***********&&&&&&&&&&&@@@@@@@@@@@@extraPickupQL: '+extraPickupQL);
        delete extraPickupQL;
    }
    
    /*
     * @MethodName : testUpdateMASDetailsToQuoteLines
     * @description : This method will test whether code is able to set MAS details on QuoteLines for SDT-29645
     * @return  : void
     */
    @isTest
    public static void testUpdateMASDetailsToQuoteLines(){
        test.startTest();
        Set<Id> qlIdSet = new Set<Id>();
        Map<Id, SBQQ__QuoteLine__c> mapOfOldQls = new Map<Id, SBQQ__QuoteLine__c>();
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN and FirstName = 'Testuser#9999' and IsActive = true LIMIT 1];
        System.runAs(adminUser){
        
            SBQQ__Quote__c testQuote = [SELECT Id, Name, SBQQ__Account__r.Name, Case__c, SBQQ__Opportunity2__r.Case__c, SBQQ__Account__r.Parent.AccountNumber,SBQQ__StartDate__c
                                    FROM SBQQ__Quote__c WHERE SBQQ__Account__r.Name =: Constant_Util.KEYWORD_TEST LIMIT 1];
            
            Product2 openTop = [Select Id, Family from Product2 where Name = 'Open Top'];
            openTop.Family = ROLLOFF;
            update openTop;
            Product2 dumpster = [Select Id, Family from Product2 where Name = 'Dumpster'];
            dumpster.Family = COMMERCIAL;
            update dumpster;
            Account locationAccount = [Select Id, Name from Account where Name =: Constant_Util.LOCATION limit 1];
            Pricing_Request__c pricingRequest = [Select Id from Pricing_Request__c where Line_of_Business__c = 'Rolloff'];
            List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
            SBQQ__QuoteLine__c qlOT =  [Select id, Vendor__c,Vendor__r.Id, Pricing_Request__c,SBQQ__Product__c,SBQQ__Product__r.Family, MASLibrary__c from SBQQ__QuoteLine__c where 
                                                   SBQQ__RequiredBy__c = null and SBQQ__Product__r.Name = 'Open Top' and
                                                   SBQQ__Quote__c =: testQuote.Id limit 1];
            SBQQ__QuoteLine__c qlDMP =  [Select id, Vendor__c,Vendor__r.Id, Pricing_Request__c,SBQQ__Product__c,SBQQ__Product__r.Family, MASLibrary__c from SBQQ__QuoteLine__c where 
                                                   SBQQ__RequiredBy__c = null and SBQQ__Product__r.Name = 'Dumpster' and
                                                   SBQQ__Quote__c =: testQuote.Id limit 1];
            
            RecurrsiveTriggerHandler.bypassValidationQuoteLine = true;
            RecurrsiveTriggerHandler.isSkipValidateQLCostPrice =true;
            QuoteLineTriggerHelper.extrapickUpRecursion = false;
            SBQQ.TriggerControl.disable();
            qlOT.SBQQ__Product__c = openTop.Id;
            qlOT.Pricing_Request__c = pricingRequest.Id;
            qlOT.Vendor__c = null;
            qlDMP.SBQQ__Product__c = dumpster.Id;
            update qlOT;
            //update qlDMP;
            
            //Adding Availablity 
                AAV_Asset_Availability__c aavObj = new AAV_Asset_Availability__c();
                aavObj.AAV_Location__c = locationAccount.Id;
                aavObj.AAV_APIRequestOutput__c = AAV_API_REQUEST_OUTPUT;
                aavObj.AAV_Quote_Line__c = qlOT.Id;

                insert aavObj;
            Account vendorAcc = [Select id,Name,FacilityCode__c from Account where 
                                   Id =: qlDMP.Vendor__r.Id  AND Status__c = 'Active' AND RecordType.Name = 'Vendor'
                                 LIMIT 1];
        
        	vendorAcc.FacilityCode__c = facilityId;
        	update vendorAcc;
            
            quoteLines.add(qlOT);
            quoteLines.add(qlDMP);
            for(SBQQ__QuoteLine__c ql : quoteLines){
                //system.debug('SBQQ__Product__r.Family :: '+ ql.SBQQ__Product__r.Family);
                qlIdSet.add(ql.Id);
                mapOfOldQls.put(ql.Id, ql);
                String lineOfBusiness = '';
                /*
                if(ql.SBQQ__Product__r.Family == Constant_Util.ROLLOFF){
                    lineOfBusiness = 'O';
                }
                else if(ql.SBQQ__Product__r.Family == Constant_Util.COMMERCIAL){
                    lineOfBusiness = 'C';
                }
                List<MAS_Setup_Detail__c> masSetupDetail = [SELECT id,Business_Unit_Number__c, MAS_Line_of_Business__c,MAS_Library__c, MAS_Company_Code__c,Facility_Id__c, Facility_Name__c, Site_Id__c, Site_Name__c 
                                                    FROM MAS_Setup_Detail__c where 
                                                    (Facility_Id__c =: ql.Vendor__r.FacilityCode__c and 
                                                    Valid_For_New_Service__c = true and 
                                                    MAS_Line_of_Business__c =:lineOfBusiness  )  ];
        system.debug('MAS Details '+ masSetupDetail);
                system.debug('masSetupDetail[0].MAS_Library__c, masSetupDetail[0].MAS_Company_Code__c '+ 
                            masSetupDetail[0].MAS_Library__c + ' ' + masSetupDetail[0].MAS_Company_Code__c);*/
            }
            QuoteLineTriggerHelper.updateMASDetailsToQuoteLines(mapOfOldQls,qlIdSet);
            List<SBQQ__QuoteLine__c> newQuoteLines = [Select id, Vendor__c, MASLibrary__c from SBQQ__QuoteLine__c where SBQQ__RequiredBy__c = null limit 1];
            //System.assertEquals(null,newQuoteLines[0].MASLibrary__c, 'MASLibrary__c is null');
        }
        test.stopTest();
    }
    /*
     * @MethodName : nullifyUOMforScheduledPickupTest
     * @description : SDT 40078 This method will test whether code is able to nullify PriceUOM__c, Cost_Unit_of_Measure__c  when service changes from on call to schedule
     * @return  : void
     */
    private static final string EOM_EVENT = 'EV';
    private static final string OCCURENCE_TYPE_ONCALL = 'OC';
    private static final string SCHEDULED_TYPE = 'SCH';
    @isTest static void nullifyUOMforScheduledPickupTest() {
        
        SBQQ__Quote__c testQuote = [SELECT Id, Case__c,SBQQ__Type__c,SBQQ__Opportunity2__r.Case__c, SBQQ__Account__r.Parent.AccountNumber,SBQQ__StartDate__c
        FROM SBQQ__Quote__c WHERE SBQQ__Status__c = 'Draft' AND Case__c != null ORDER BY CreatedDate DESC LIMIT 1];
        if(SBQQ.TriggerControl.isEnabled()){
            SBQQ.TriggerControl.disable();
        }
        testQuote.SBQQ__Type__c=Constant_Util.KEYWORD_EXCEPTION;
        update testQuote;
        List<SBQQ__QuoteLine__c> quoteLines = [SELECT Id, name,Occurrence_Type__c, PriceUOM__c, Cost_Unit_of_Measure__c,SBQQ__Quote__r.SBQQ__Type__c
                                              FROM SBQQ__QuoteLine__c
                                              WHERE SBQQ__Quote__c=:testQuote.id and Occurrence_Type__c=:OCCURENCE_TYPE_ONCALL
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
            ql.Occurrence_Type__c = SCHEDULED_TYPE;
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
     * @Method Name    : testSetDoNotExtendService
     * @author         : Digdershika Ojha
     * @description    : Test default value quote line field service action
     * @param          : Not Applicable
     * @return         : void
	 */    
    @isTest
    public static void testSetDoNotExtendService(){
        User csrUser = TestUserFactory.getCSRUserDetails(true, false);
        test.startTest();
        System.runAs(csrUser){            
        
        try {
            List<Account> vendorAcc = [Select Id,Vendor_Business_Unit__c from Account where Name= 'WM Vendor Account' limit 1];
            Product2 prodContaminationFee= TestDataFactory.createProduct('Contamination Fee',SERVICES,'COF');
            insert prodContaminationFee;
            
            SBQQ__Quote__c quote = [Select Id,SBQQ__Account__c,SBQQ__StartDate__c from SBQQ__Quote__c where SBQQ__Type__c = 'Exception' LIMIT 1];
            SBQQ__QuoteLine__c qlOT = [Select id,SBQQ__Quote__c from SBQQ__QuoteLine__c where SBQQ__RequiredBy__c = null
                                             and SBQQ__Product__r.Name = 'Open Top' and SBQQ__Quote__r.Id =: quote.Id LIMIT 1];
            SBQQ__QuoteLine__c qlConFee = TestDataFactory.createQuoteLineRecords(quote,prodContaminationFee,'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
            qlConFee.SBQQ__RequiredBy__c = qlOT.Id;
            qlConFee.Vendor__c = vendorAcc[0].Id;
            insert qlConFee;
            
            List<SBQQ__QuoteLine__c> qlContaminationFee = [Select id,Service_Action__c from SBQQ__QuoteLine__c where SBQQ__RequiredBy__c != null
                                             and SBQQ__Product__r.Name = 'Contamination Fee' and SBQQ__Quote__r.Id =: quote.Id LIMIT 1];
            
			System.assertEquals(qlContaminationFee.size(), 1,'Contaimination fee quote line not inserted');
            System.assertEquals(qlContaminationFee[0].Service_Action__c, Constant_Util.SERVICE_ACTION_DO_NOT_EXTEND_SERVICE, 'Default value not set for service Action');
        }
        catch(exception ex) {
            system.debug(ex);
        }
        }
        test.stopTest();
    }

//40723
public static void testNewServiceQuoteUpdate(){

SBQQ__QuoteLine__c quoteLineList=[SELECT Id from SBQQ__QuoteLine__c where SBQQ__RequiredBy__c=:NULL LIMIT 1];
quoteLineList.Vendor_Commit_Date__c=system.today()-20;
update quoteLineList;
quoteLineList.Vendor_Commit_Date__c=system.today()+20;
update quoteLineList;
}

}
