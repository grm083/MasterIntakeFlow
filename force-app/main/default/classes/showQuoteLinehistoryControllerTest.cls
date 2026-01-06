/*
* @Name          showQuoteLinehistoryControllerTest
* @Author        Rajan
* @Vendor        TCS
* @Date          15/04/2024
* @description    SDT-36179
*/
@isTest (SeeAllData = FALSE)
public class showQuoteLinehistoryControllerTest {
    private static final string SYS_ADMIN = 'System Administrator';
    private static final string TRASH = 'Trash';
    private static final string ON_CALL = 'On-Call';
    private static final string ROLLOFF = 'Rolloff';
    private static final string COMMERCIAL = 'Commercial';
    private static final string SERVICES = 'Services';
    private static final string EQUIPMENT = 'Equipment';
    private static final string FieldApiName = 'Material_Code__c';
    /*
     * @MethodName    setup
     * @Author        Rajan
     * @Vendor        TCS
     * @description   This method will be used to setup inital required data to test getQuoteLinesByQuoteIdList method
     * @return        void
     */
    @testSetup static void setup(){
        
        Profile adminProfile = TestDataFactory.getProfile(SYS_ADMIN);
        
        User usr = TestDataFactory.createUser(adminProfile);
        Database.insert(usr);  
        
        User bypassuser = TestDataFactory.createUser(adminProfile);
        bypassuser.Bypass_Validation__c = true;
        insert bypassuser;


        System.runAs(usr){
            List<Opportunity> oppList = new List<Opportunity>();
            List<SBQQ__Quote__c> quoteList= new List<SBQQ__Quote__c>();
            List<Product2> prdList = new List<Product2>();    
            list<Account> acclist = new List<Account>();
        
            //Changes for SDT-39632
            CodeSwitchTestData.CodeSwitchData();

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

            List<SBQQ__QuoteLine__c> qlChild = new List<SBQQ__QuoteLine__c>();

            SBQQ__QuoteLine__c qlOTT = TestDataFactory.createQuoteLineRecords(quoteList[0],prodTrash,'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',0,'DYS','PER',null,'DYS','Do Not Override','NBG');
            qlOTT.SBQQ__RequiredBy__c = qlOT.Id;
            qlOTT.SBQQ__Number__c = 2;
            qlChild.add(qlOTT);

            SBQQ__QuoteLine__c qlHaul = TestDataFactory.createQuoteLineRecords(quoteList[0],prodHaul,'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',0,'DYS','PER',null,'DYS','Do Not Override','NBG');
            qlHaul.SBQQ__RequiredBy__c = qlOT.Id;
            qlHaul.SBQQ__Number__c = 3;
            qlChild.add(qlHaul);

            SBQQ__QuoteLine__c qlDisposal = TestDataFactory.createQuoteLineRecords(quoteList[0],prodDisposal,'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',0,'DYS','PER',null,'DYS','Do Not Override','NBG');
            qlDisposal.SBQQ__RequiredBy__c = qlOT.Id;
            qlDisposal.SBQQ__Number__c = 4;
            qlChild.add(qlDisposal);

            SBQQ__QuoteLine__c qlDelivery = TestDataFactory.createQuoteLineRecords(quoteList[0],prodDelivery,'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',0,'DYS','PER',null,'DYS','Do Not Override','NBG');
            qlDelivery.SBQQ__RequiredBy__c = qlOT.Id;
            qlDelivery.SBQQ__Number__c = 5;
            qlChild.add(qlDelivery);
    
            SBQQ.TriggerControl.disable();
            try 
            {
                Database.insert(qlChild);
            } 
            finally {
            SBQQ.TriggerControl.enable();
            }

        }
    }
    
        /*
         * @MethodName    : getQuoteLineHistoriesTest
         * @description   : SDT-36179
         */
        @isTest
        static void getQuoteLineHistoriesTest(){
            List<SBQQ__Quote__c> quoteList;
            Test.startTest();
            
            
            //addition for test class errors
            quoteList= [SELECT Id FROM SBQQ__Quote__c WHERE Duration__c = 'Permanent'];
            ShowQuoteLineHistoryController.getQuoteLineHistories(quoteList[0].Id);
           
            Test.stopTest();
        }
    

}