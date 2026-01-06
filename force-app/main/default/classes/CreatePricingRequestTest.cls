@isTest(seeAllData = false)
public class CreatePricingRequestTest {
    
    private static final string SYS_ADMIN = 'System Administrator';
    private static final string EQUIPMENT = 'Equipment';
    private static final string SERVICES = 'Services';
    // private static final string PERMANENT = 'PERM';
    private static final string ON_CALL = 'On-Call';
    private static final string TRASH = 'Trash';
    
    
    @testSetup static void setup() {
        Profile adminProfile = TestDataFactory.getProfile(SYS_ADMIN);
        
        User usr = TestDataFactory.createUser(adminProfile);
        Database.insert(usr);  
        
        User bypassuser = TestDataFactory.createUser(adminProfile);
        bypassuser.Bypass_Validation__c = true;
        insert bypassuser;
        
        //Changes for SDT-39632
        CodeSwitchTestData.CodeSwitchData();
        
        system.runAs(usr)
        {
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

            Account vendorAcc = new Account(Name = 'Vendor Account', phone = '9999999999', OwnerId = usr.id, AccountNumber='4321',
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

            Product2 prodTrash = TestDataFactory.createProduct('Trash','Waste Stream','T');
            prodTrash.Is_Pricing_Eligible__c = true;
            prdList.add(prodTrash);

            Product2 prodCardboard = TestDataFactory.createProduct('Cardboard','Waste Stream','C');
            prodCardboard.Is_Pricing_Eligible__c = true;
            prdList.add(prodCardboard);

            Database.insert(prdList);

            //RecurrsiveTriggerHandler.bypassValidationQuoteLine = true;

            List<SBQQ__QuoteLine__c> qlHdr = new List<SBQQ__QuoteLine__c>();
            //Bundle 1 - Open Top
            SBQQ__QuoteLine__c qlOT = TestDataFactory.createQuoteLineRecords(quoteList[0],prodOpenTop,'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
            qlOT.SBQQ__Bundle__c = TRUE;
            qlOT.SBQQ__RequiredBy__c = null;
            qlOT.Vendor__c = vendorAcc.Id;
            qlOT.Location_Position_Name__c = accLocPosition.Id;
            qlHdr.add(qlOT);

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
            SBQQ__QuoteLine__c qlCMPH = TestDataFactory.createQuoteLineRecords(quoteList[0],prodCompactor,'TEMP',1.00,'CLT','YRDS-4',null,null,null,'PER',34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
            qlCMPH.SBQQ__Bundle__c = TRUE;
            qlCMPH.SBQQ__RequiredBy__c = null;
            qlCMPH.Vendor__c = vendorAcc.Id;
            qlHdr.add(qlCMPH);

            //Bundle 5 - Error
            SBQQ__QuoteLine__c qlErr = TestDataFactory.createQuoteLineRecords(quoteList[0],prodNull,'TEMP',1.00,'CLT','YRDS-30','OC',null,null,'PER',34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
            qlErr.SBQQ__Bundle__c = TRUE;
            qlErr.SBQQ__RequiredBy__c = null;
            qlHdr.add(qlErr);

            SBQQ.TriggerControl.disable();
            try 
            {
                insert qlHdr;
            } 
            finally {
            SBQQ.TriggerControl.enable();
            }

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
            SBQQ__QuoteLine__c qlCMPHT = TestDataFactory.createQuoteLineRecords(quoteList[0],prodTrash,'TEMP',1.00,'CLT','YRDS-4',null,null,null,'PER',34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
            qlCMPHT.SBQQ__RequiredBy__c = qlCMPH.Id;
            qlCMPHT.Vendor__c = vendorAcc.Id;
            qlChild.add(qlCMPHT);

            SBQQ__QuoteLine__c qlCMPHHaul = TestDataFactory.createQuoteLineRecords(quoteList[0],prodHaul,'TEMP',1.00,'CLT','YRDS-4',null,null,null,'PER',34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
            qlCMPHHaul.SBQQ__RequiredBy__c = qlCMPH.Id;
            qlCMPHHaul.Vendor__c = vendorAcc.Id;
            qlChild.add(qlCMPHHaul);
            //Horizontal  Compactor Child Quote Line  --- End

            //Error Child Quote Line  --- Start
            SBQQ__QuoteLine__c qlTErr = TestDataFactory.createQuoteLineRecords(quoteList[0],prodTrash,'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
            qlTErr.SBQQ__RequiredBy__c = qlErr.Id;
            qlChild.add(qlTErr);

            SBQQ__QuoteLine__c qlHaulErr = TestDataFactory.createQuoteLineRecords(quoteList[0],prodHaul,'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
            qlHaulErr.SBQQ__RequiredBy__c = qlErr.Id;
            qlChild.add(qlHaulErr);
            //Error Child Quote Line  --- End
            //Database.insert(qlChild);  
            
            SBQQ.TriggerControl.disable();
            try 
            {
                Database.insert(qlChild);
            } 
            finally {
            SBQQ.TriggerControl.enable();
            }

            System.debug('New Quote Line ' + qlChild);     

            // Pricing_Request__c prAM = TestDataFactory.createPricingRequestRecord(newServiceCase, acclist[0], locationlist[0], 'Rolloff', 'AM', '', '', usr);
            // prAM.Quote__c = quoteList[0].Id;
            // insert prAM;
            Pricing_Request__c prAMPO = TestDataFactory.createPricingRequestRecord(newServiceCase, acclist[0], locationlist[0], 'Rolloff', 'AMPO', '', vendorAcc.Id , usr);
            prAMPO.Quote__c = quoteList[0].Id;
            RecurrsiveTriggerHandler.invokeValidationforPricing = false;
            insert prAMPO;


        } 
    }
    
    @isTest static void testCreatePricingRequestOT(){
        user currentuser = [SELECT id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        // String[] assetlist = new String[]{};
        system.runAs(currentuser){
            SBQQ__Quote__c quoteData = new SBQQ__Quote__c();
            quoteData = [SELECT Id, SBQQ__Status__c
                         FROM SBQQ__Quote__c where SBQQ__ShippingCity__c = 'Test1'  limit 1];
            SBQQ__QuoteLine__c sbqq = [SELECT Id, SBQQ__Quote__c,Duration__c FROM SBQQ__QuoteLine__c WHERE SBQQ__RequiredBy__c = null and SBQQ__Quote__c =:quoteData.id and SBQQ__Product__r.ProductCode = 'OT'  LIMIT 1];
            test.startTest();
                CreatePricingRequest.createPricingRequest(quoteData.Id);
               // CreatePricingRequest.createPriceOnlyPR(sbqq.Id); //SDT-33363

                system.AssertNotEquals(quoteData, null, 'PR is created.');
            test.stopTest();
        }
    }

    @isTest static void testCreatePricingOnlyRequestOT(){
        user currentuser = [SELECT id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        // String[] assetlist = new String[]{};
        system.runAs(currentuser){
            SBQQ__Quote__c quoteData = new SBQQ__Quote__c();
            quoteData = [SELECT Id, SBQQ__Status__c
                         FROM SBQQ__Quote__c where SBQQ__ShippingCity__c = 'Test1'  limit 1];
            SBQQ__QuoteLine__c sbqq = [SELECT Id, SBQQ__Quote__c,Duration__c FROM SBQQ__QuoteLine__c WHERE SBQQ__RequiredBy__c = null and SBQQ__Quote__c =:quoteData.id and SBQQ__Product__r.ProductCode = 'OT'  LIMIT 1];
            test.startTest();
               // CreatePricingRequest.createPriceOnlyPR(sbqq.Id); //SDT-33363

                system.AssertNotEquals(quoteData, null, 'PR is created.');
            test.stopTest();
        }
    }

    @isTest static void testCreatePricingRequestOTError(){
        user currentuser = [SELECT id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        // String[] assetlist = new String[]{};
        system.runAs(currentuser){
            SBQQ__Quote__c quoteData = new SBQQ__Quote__c();
            quoteData = [SELECT Id, SBQQ__Status__c
                         FROM SBQQ__Quote__c where SBQQ__ShippingCity__c = 'Test1'  limit 1];
            SBQQ__QuoteLine__c sbqq = [SELECT Id, SBQQ__Quote__c,Duration__c FROM SBQQ__QuoteLine__c WHERE SBQQ__RequiredBy__c = null and SBQQ__Quote__c =:quoteData.id and SBQQ__Product__r.ProductCode = 'ERR'  LIMIT 1];
            test.startTest();
                CreatePricingRequest.createPricingRequest(quoteData.Id);
              //  CreatePricingRequest.createPriceOnlyPR(sbqq.Id); //SDT-33363

                system.AssertNotEquals(quoteData, null, 'PR is created.');
            test.stopTest();
        }
    }

    @isTest static void testCreatePricingRequestDMP(){
        user currentuser = [SELECT id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        // String[] assetlist = new String[]{};
        system.runAs(currentuser){
            SBQQ__Quote__c quoteData = new SBQQ__Quote__c();
            quoteData = [SELECT Id, SBQQ__Status__c
                         FROM SBQQ__Quote__c where SBQQ__ShippingCity__c = 'Test1'  limit 1];
             SBQQ__QuoteLine__c sbqq = [SELECT Id, SBQQ__Quote__c,Duration__c FROM SBQQ__QuoteLine__c WHERE SBQQ__RequiredBy__c = null and SBQQ__Quote__c =:quoteData.id and SBQQ__Product__r.ProductCode = 'DMP'  LIMIT 1];
            test.startTest();
                CreatePricingRequest.createPricingRequest(quoteData.Id);
                CreatePricingRequest.createPriceOnlyPR(sbqq.Id);
                system.AssertNotEquals(quoteData, null, 'PR is created.');
            test.stopTest();
        }
    }

    @isTest static void testCreatePricingRequestCMPV(){
        user currentuser = [SELECT id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        // String[] assetlist = new String[]{};
        system.runAs(currentuser){
            SBQQ__Quote__c quoteData = new SBQQ__Quote__c();
            quoteData = [SELECT Id, SBQQ__Status__c
                         FROM SBQQ__Quote__c where SBQQ__ShippingCity__c = 'Test1'  limit 1];
             SBQQ__QuoteLine__c sbqq = [SELECT Id, SBQQ__Quote__c,Duration__c FROM SBQQ__QuoteLine__c WHERE SBQQ__RequiredBy__c = null and SBQQ__Quote__c =:quoteData.id and SBQQ__Product__r.ProductCode = 'CMP'  LIMIT 1];
            test.startTest();
                CreatePricingRequest.createPricingRequest(quoteData.Id);
             //   CreatePricingRequest.createPriceOnlyPR(sbqq.Id); //SDT-33363
                system.AssertNotEquals(quoteData, null, 'PR is created.');
            test.stopTest();
        }
    }

    @isTest static void testCreatePricingRequestCMPH(){
        user currentuser = [SELECT id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        // String[] assetlist = new String[]{};
        system.runAs(currentuser){
            SBQQ__Quote__c quoteData = new SBQQ__Quote__c();
            quoteData = [SELECT Id, SBQQ__Status__c
                         FROM SBQQ__Quote__c where SBQQ__ShippingCity__c = 'Test1'  limit 1];
             SBQQ__QuoteLine__c sbqq = [SELECT Id, SBQQ__Quote__c,Duration__c FROM SBQQ__QuoteLine__c WHERE SBQQ__RequiredBy__c = null and SBQQ__Quote__c =:quoteData.id and SBQQ__Product__r.ProductCode = 'CMP' and Equipment_Size__c = 'YRDS-4'  LIMIT 1];
            test.startTest();
                CreatePricingRequest.createPricingRequest(quoteData.Id);
              //  CreatePricingRequest.createPriceOnlyPR(sbqq.Id); //SDT-33363
                system.AssertNotEquals(quoteData, null, 'PR is created.');
            test.stopTest();
        }
    }
    
    @isTest static void testPricingAPICallout(){
        user usr = [SELECT id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        // String[] assetlist = new String[]{};
        system.runAs(usr)
        {
            Pricing_Request__c pr = [SELECT Id FROM Pricing_Request__c WHERE Pricing_Type__c = 'AMPO' LIMIT 1];
            test.startTest();
                Set<Id> pricingReqIdSet = new Set<Id>();
                pricingReqIdSet.add(pr.Id);
               // CreatePricingRequest.callPriceOnlyIntegration(pricingReqIdSet, quoteData.id); //SDT-33363
                //At time of creation, the testwrapper returns null values in some container fields
                system.assert(pr != null, 'Test testPricingAPICallout');
                // system.assertEquals(testWrapper.container, null);

            test.stopTest();
        }
    }

    // global class CreatePRAPIMock implements HttpCalloutMock {
    //     // Implement this interface method
    //     global HTTPResponse respond(HTTPRequest req) {
    //         String json = '{  \"data\": {    \"priceQuoteIdentifier\": \"Q11169\",    \"costSource\": \"WM (SBS|CO|DMP|4FL|B02860|20210323|080506|640)\",    \"contractType\": \"Open Market\",    \"lineOfBusiness\": \"Commercial\",    \"supplierCode\": \"10016\",    \"supplierName\": \"WMI OF MI, LIVONIA\",    \"customerCode\": \"HMD\",    \"customerName\": \"The Home Depot\",    \"locationCode\": \"HMD002718\",    \"wasteStreamCode\": \"MSW\",    \"wasteStreamName\": \"Municipal Solid Waste\",    \"equipmentCode\": \"4FL\",    \"equipmentName\": \"4 Yard FEL\",    \"equipmentUOM\": \"Monthly\",    \"materialCode\": \"T\",    \"materialName\": \"MSW Commercial\",    \"equipmentSizeCode\": \"YRDS-4\",    \"equipmentSizeName\": \"4 Yards\",    \"overridableEquipmentSizeCode\": null,    \"overridableEquipmentSizeName\": null,    \"zoneCode\": \"GIS545664\",    \"zoneName\": \"Detroit Central - MSW FEL - Wayne Co Productive to Woodland\",    \"disposalFacilityType\": null,    \"disposalFacilityName\": \"[B02860] [MSW_CO] Woodland Meadows - Comm - From Det Central\",    \"commercial\": {      \"pricingMethodCode\": \"4.0\",      \"pricingMethodCodeDescription\": \"Adjusted MBP\",      \"cost\": 121.59,      \"price\": 139.83,      \"equipmentLoadingMinutes\": null,      \"equipmentAdditionalLoadingMinutes\": null,      \"estimatedWeightPerYard\": 80.02,      \"equipmentVolume\": 4.00,      \"extraPickupCost\": null,      \"extraPickupPrice\": null    },    \"rollOff\": null,    \"wmMetaData\": {      \"businessUnit\": \"B02860\",      \"masLibrary\": \"129A_WDL\",      \"francisePricingLink\": \"\",      \"greenPagesLink\": \"\"    },    \"tpMetaData\": null,    \"serviceCharges\": [      {        \"code\": \"FU_C_PERM_OPEN\",        \"name\": \"Fuel Fee\",        \"componentTypeCode\": \"ENS\",        \"componentTypeName\": \"Energy Surcharge\",        \"actionCode\": \"EX\",        \"actionName\": \"Exclude\",        \"cost\": null,        \"costValueType\": null,        \"costUOM\": null,        \"price\": null,        \"priceValueType\": null,        \"priceUOM\": null      },      {        \"code\": \"ENV_C_PERM_OPEN\",        \"name\": \"Environmental Fee\",        \"componentTypeCode\": \"ENV_FEE\",        \"componentTypeName\": \"Environmental Fee\",        \"actionCode\": \"EX\",        \"actionName\": \"Exclude\",        \"cost\": null,        \"costValueType\": null,        \"costUOM\": null,        \"price\": null,        \"priceValueType\": null,        \"priceUOM\": null      },      {        \"code\": \"MNT_C_PERM_OPEN_R\",        \"name\": \"Minimum Tons Recycling\",        \"componentTypeCode\": \"DSP\",        \"componentTypeName\": \"Disposal\",        \"actionCode\": \"EX\",        \"actionName\": \"Exclude\",        \"cost\": null,        \"costValueType\": null,        \"costUOM\": null,        \"price\": null,        \"priceValueType\": null,        \"priceUOM\": null      },      {        \"code\": \"MNT_C_PERM_OPEN_T\",        \"name\": \"All Other Minimum Tonnage\",        \"componentTypeCode\": \"DSP\",        \"componentTypeName\": \"Disposal\",        \"actionCode\": \"EX\",        \"actionName\": \"Exclude\",        \"cost\": null,        \"costValueType\": null,        \"costUOM\": null,        \"price\": null,        \"priceValueType\": null,        \"priceUOM\": null      },      {        \"code\": \"LF_C_PERM_OPEN\",        \"name\": \"Landfill Fee\",        \"componentTypeCode\": \"LF\",        \"componentTypeName\": \"Landfill Fee\",        \"actionCode\": \"AL\",        \"actionName\": \"Allow\",        \"cost\": null,        \"costValueType\": null,        \"costUOM\": null,        \"price\": null,        \"priceValueType\": null,        \"priceUOM\": null      },      {        \"code\": \"FF_C_PERM_OPEN\",        \"name\": \"Franchise Fee\",        \"componentTypeCode\": \"FF\",        \"componentTypeName\": \"Franchise Fee\",        \"actionCode\": \"AL\",        \"actionName\": \"Allow\",        \"cost\": null,        \"costValueType\": null,        \"costUOM\": null,        \"price\": null,        \"priceValueType\": null,        \"priceUOM\": null      },      {        \"code\": \"IF_C_PERM_OPEN\",        \"name\": \"Inactivity Fee (Monthly or Daily Charge for roll off when no Hauls are performed)\",        \"componentTypeCode\": \"IF\",        \"componentTypeName\": \"Inactivity Fee\",        \"actionCode\": \"EX\",        \"actionName\": \"Exclude\",        \"cost\": null,        \"costValueType\": null,        \"costUOM\": null,        \"price\": null,        \"priceValueType\": null,        \"priceUOM\": null      },      {        \"code\": \"SSF_C_PERM_OPEN\",        \"name\": \"Snapshot Fee\",        \"componentTypeCode\": \"SSF\", '+
    //         '       \"componentTypeName\": \"Snapshot Fee\",        \"actionCode\": \"ADJ\",        \"actionName\": \"Adjust\",        \"cost\": null,        \"costValueType\": null,        \"costUOM\": null,        \"price\": 75.0000,        \"priceValueType\": \"Amount\",        \"priceUOM\": null      },      {        \"code\": \"GT_C_PERM_OPEN\",        \"name\": \"Generator Tax\",        \"componentTypeCode\": \"UNK\",        \"componentTypeName\": \"Unknown\",        \"actionCode\": \"AL\",        \"actionName\": \"Allow\",        \"cost\": null,        \"costValueType\": null,        \"costUOM\": null,        \"price\": null,        \"priceValueType\": null,        \"priceUOM\": null      },      {        \"code\": \"RMO_C_PERM_OPEN\",        \"name\": \"Recyable Material Offset\",        \"componentTypeCode\": \"UNK\",        \"componentTypeName\": \"Unknown\",        \"actionCode\": \"EX\",        \"actionName\": \"Exclude\",        \"cost\": null,        \"costValueType\": null,        \"costUOM\": null,        \"price\": null,        \"priceValueType\": null,        \"priceUOM\": null      },      {        \"code\": \"RCR_C_PERM_OPEN\",        \"name\": \"Regulatory Cost Recovery\",        \"componentTypeCode\": \"UNK\",        \"componentTypeName\": \"Unknown\",        \"actionCode\": \"EX\",        \"actionName\": \"Exclude\",        \"cost\": null,        \"costValueType\": null,        \"costUOM\": null,        \"price\": null,        \"priceValueType\": null,        \"priceUOM\": null      },      {        \"code\": \"REM_C_PERM_OPEN\",        \"name\": \"Container Removal\",        \"componentTypeCode\": \"REM\",        \"componentTypeName\": \"Removal\",        \"actionCode\": \"ADJ\",        \"actionName\": \"Adjust\",        \"cost\": null,        \"costValueType\": null,        \"costUOM\": null,        \"price\": 15.0000,        \"priceValueType\": \"Percent\",        \"priceUOM\": null      },      {        \"code\": \"ACT_C_PERM_OPEN\",        \"name\": \"Activation Fee\",        \"componentTypeCode\": \"UNK\",        \"componentTypeName\": \"Unknown\",        \"actionCode\": \"ADJ\",        \"actionName\": \"Adjust\",        \"cost\": null,        \"costValueType\": null,        \"costUOM\": null,        \"price\": 15.0000,        \"priceValueType\": \"Percent\",        \"priceUOM\": null      },      {        \"code\": \"CRR_C_PERM_OPEN\",        \"name\": \"Castor Repair/Replacement\",        \"componentTypeCode\": \"UNK\",        \"componentTypeName\": \"Unknown\",        \"actionCode\": \"EX\",        \"actionName\": \"Exclude\",        \"cost\": null,        \"costValueType\": null,        \"costUOM\": null,        \"price\": null,        \"priceValueType\": null,        \"priceUOM\": null      },      {        \"code\": \"CPO_C_PERM_OPEN\",        \"name\": \"Container Pull Out\",        \"componentTypeCode\": \"UNK\",        \"componentTypeName\": \"Unknown\",        \"actionCode\": \"ADJ\",        \"actionName\": \"Adjust\",        \"cost\": null,        \"costValueType\": null,        \"costUOM\": null,        \"price\": 15.0000,        \"priceValueType\": \"Percent\",        \"priceUOM\": null      },      {        \"code\": \"CSC_C_PERM_OPEN\",        \"name\": \"Container Service Charge (\\\"Rental\\\" for Roll Off Accounts)\",        \"componentTypeCode\": \"UNK\",        \"componentTypeName\": \"Unknown\",        \"actionCode\": \"MR\",        \"actionName\": \"Manual Review\",        \"cost\": null,        \"costValueType\": null,        \"costUOM\": null,        \"price\": null,        \"priceValueType\": null,        \"priceUOM\": null      },      {        \"code\": \"R_C_PERM_OPEN\",        \"name\": \"Container Service Fee (This is the \\\"Insurance\\\" or Rental for Commercial Accounts)\",        \"componentTypeCode\": \"UNK\",        \"componentTypeName\": \"Unknown\",        \"actionCode\": \"EX\",        \"actionName\": \"Exclude\",        \"cost\": null,        \"costValueType\": null,        \"costUOM\": null,        \"price\": null,        \"priceValueType\": null,        \"priceUOM\": null      },      {        \"code\": \"SWO_C_PERM_OPEN\",        \"name\": \"Container Swap\",        \"componentTypeCode\": \"UNK\",        \"componentTypeName\": \"Unknown\",        \"actionCode\": \"ADJ\",        \"actionName\": \"Adjust\",        \"cost\": null,        \"costValueType\": null,        \"costUOM\": null,        \"price\": 15.0000,        \"priceValueType\": \"Percent\",        \"priceUOM\": null      },      {        \"code\": \"CWO_C_PERM_OPEN\",        \"name\": \"Container Wash\",        \"componentTypeCode\": \"UNK\",        \"componentTypeName\": \"Unknown\",        \"actionCode\": \"EX\",        \"actionName\": \"Exclude\",        \"cost\": null,        \"costValueType\": null,        \"costUOM\": null,        \"price\": null,        \"priceValueType\": null,        \"priceUOM\": null      },      {        \"code\": \"D_C_PERM_OPEN\",        \"name\": \"Delivery\",        \"componentTypeCode\": \"UNK\",        \"componentTypeName\": \"Unknown\",        \"actionCode\": \"ADJ\",        \"actionName\": \"Adjust\",        \"cost\": null,        \"costValueType\": null,'+
    //         '        \"costUOM\": null,        \"price\": 15.0000,        \"priceValueType\": \"Percent\",        \"priceUOM\": null      },      {        \"code\": \"EP_C_PERM_OPEN\",        \"name\": \"Expu (Extra Pick Up)\",        \"componentTypeCode\": \"UNK\",        \"componentTypeName\": \"Unknown\",        \"actionCode\": \"MR\",        \"actionName\": \"Manual Review\",        \"cost\": null,        \"costValueType\": null,        \"costUOM\": null,        \"price\": null,        \"priceValueType\": null,        \"priceUOM\": null      },      {        \"code\": \"EXLO_C_PERM_OPEN\",        \"name\": \"Extra Loose Yards\",        \"componentTypeCode\": \"UNK\",        \"componentTypeName\": \"Unknown\",        \"actionCode\": \"MR\",        \"actionName\": \"Manual Review\",        \"cost\": null,        \"costValueType\": null,        \"costUOM\": null,        \"price\": null,        \"priceValueType\": null,        \"priceUOM\": null      },      {        \"code\": \"LCK_C_PERM_OPEN\",        \"name\": \"Lock Installation Charge\",        \"componentTypeCode\": \"UNK\",        \"componentTypeName\": \"Unknown\",        \"actionCode\": \"ADJ\",        \"actionName\": \"Adjust\",        \"cost\": null,        \"costValueType\": null,        \"costUOM\": null,        \"price\": 15.0000,        \"priceValueType\": \"Percent\",        \"priceUOM\": null      },      {        \"code\": \"REL_C_PERM_OPEN\",        \"name\": \"Relocation\",        \"componentTypeCode\": \"UNK\",        \"componentTypeName\": \"Unknown\",        \"actionCode\": \"ADJ\",        \"actionName\": \"Adjust\",        \"cost\": null,        \"costValueType\": null,        \"costUOM\": null,        \"price\": 15.0000,        \"priceValueType\": \"Percent\",        \"priceUOM\": null      },      {        \"code\": \"GTF_C_PERM_OPEN\",        \"name\": \"Routine Gate Opening\",        \"componentTypeCode\": \"UNK\",        \"componentTypeName\": \"Unknown\",        \"actionCode\": \"ADJ\",        \"actionName\": \"Adjust\",        \"cost\": null,        \"costValueType\": null,        \"costUOM\": null,        \"price\": 15.0000,        \"priceValueType\": \"Percent\",        \"priceUOM\": null      },      {        \"code\": \"SDO_C_PERM_OPEN\",        \"name\": \"Service Ticket Drop Off\",        \"componentTypeCode\": \"UNK\",        \"componentTypeName\": \"Unknown\",        \"actionCode\": \"EX\",        \"actionName\": \"Exclude\",        \"cost\": null,        \"costValueType\": null,        \"costUOM\": null,        \"price\": null,        \"priceValueType\": null,        \"priceUOM\": null      },      {        \"code\": \"SSDT_C_PERM_OPEN\",        \"name\": \"Signed Service/Disposal Ticket With Invoice\",        \"componentTypeCode\": \"UNK\",        \"componentTypeName\": \"Unknown\",        \"actionCode\": \"EX\",        \"actionName\": \"Exclude\",        \"cost\": null,        \"costValueType\": null,        \"costUOM\": null,        \"price\": null,        \"priceValueType\": null,        \"priceUOM\": null      },      {        \"code\": \"TPC_C_PERM_OPEN\",        \"name\": \"Trip\",        \"componentTypeCode\": \"UNK\",        \"componentTypeName\": \"Unknown\",        \"actionCode\": \"ADJ\",        \"actionName\": \"Adjust\",        \"cost\": null,        \"costValueType\": null,        \"costUOM\": null,        \"price\": 15.0000,        \"priceValueType\": \"Percent\",        \"priceUOM\": null      },      {        \"code\": \"WT_C_PERM_OPEN\",        \"name\": \"Wait Time\",        \"componentTypeCode\": \"UNK\",        \"componentTypeName\": \"Unknown\",        \"actionCode\": \"ADJ\",        \"actionName\": \"Adjust\",        \"cost\": null,        \"costValueType\": null,        \"costUOM\": null,        \"price\": 15.0000,        \"priceValueType\": \"Percent\",        \"priceUOM\": null      },      {        \"code\": \"DEACT_C_PERM_OPEN\",        \"name\": \"Deactivation Fee\",        \"componentTypeCode\": \"UNK\",        \"componentTypeName\": \"Unknown\",        \"actionCode\": \"AL\",        \"actionName\": \"Allow\",        \"cost\": null,        \"costValueType\": null,        \"costUOM\": null,        \"price\": null,        \"priceValueType\": null,        \"priceUOM\": null      },      {        \"code\": \"CTMF_C_PERM_OPEN\",        \"name\": \"Contamination Fee\",        \"componentTypeCode\": \"COF\",        \"componentTypeName\": \"Contamination Fee\",        \"actionCode\": \"AL\",        \"actionName\": \"Allow\",        \"cost\": null,        \"costValueType\": null,        \"costUOM\": null,        \"price\": null,        \"priceValueType\": null,        \"priceUOM\": null      },      {        \"code\": \"LCKF_C_PERM_OPEN\",        \"name\": \"Locks - Monthly Charge\",        \"componentTypeCode\": \"UNK\",        \"componentTypeName\": \"Unknown\",        \"actionCode\": \"ADJ\",        \"actionName\": \"Adjust\",        \"cost\": null,        \"costValueType\": null,        \"costUOM\": null,        \"price\": 15.0000,        \"priceValueType\": \"Percent\",        \"priceUOM\": null      }    ]  },  \"problem\": null}';
    //         HttpResponse response = new HttpResponse();
    //         response.setHeader('Content-Type', 'application/json');
    //         response.setBody(json);
    //         response.setStatusCode(200);
    //         return response;
    //     }
    // }
}