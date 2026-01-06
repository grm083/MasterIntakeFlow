/*
* @Name          RemovalQuoteLineHandlerTest
* @Author        Seema Dhikale
* @Vendor		 TCS
* @Date          08/01/2024
* @description	 This class will be used as Test class for RemovalQuoteLineHandler, initially created for story SDT-32952
*/
@isTest (SeeAllData = FALSE)
public class RemovalQuoteLineHandlerTest {
    private static final string SYS_ADMIN = 'System Administrator';
    private static final string ON_CALL = 'On-Call';
    private static final string TRASH = 'Trash';
    private static final string ROLLOFF = 'Rolloff';
    @testSetup static void createData() {
        Profile adminProfile = TestDataFactory.getProfile(SYS_ADMIN);
        User usr = TestDataFactory.createUser(adminProfile);
        usr.Bypass_Validation__c = true;
        usr.Genesys_Enabled__c = true;
        Database.insert(usr); 
        TestUserFactory.getCSRUserDetails(true, false);
        System.runAs(usr){
            
            //Changes for SDT-39632
            CodeSwitchTestData.CodeSwitchData();
            
            list<Account> acclist = new List<Account>();
            List<Opportunity> oppList = new List<Opportunity>();
            List<SBQQ__Quote__c> quoteList= new List<SBQQ__Quote__c>();
            List<Product2> prdList = new List<Product2>(); 
            
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
            quoteList[0].Duration__c = 'Temporary';
            insert quoteList;
            
            
            Product2 prodOpenTop = TestDataFactory.createProduct('Open Top',Constant_Util.COMMERCIAL, 'OT');
            prodOpenTop.Is_Pricing_Eligible__c = true;
            prdList.add(prodOpenTop);
            
            Database.insert(prdList);
            
            List<Asset> assetlist = TestDataFactory.createAsset('8 yrd Dumpster', acclist.get(0), conlist.get(0), prdList.get(0), usr, locationlist.get(0));
            Database.insert(assetlist);
            
            List<SBQQ__QuoteLine__c> qlHdr = new List<SBQQ__QuoteLine__c>();
            SBQQ__QuoteLine__c qlOT = TestDataFactory.createQuoteLineRecords(quoteList[0],prodOpenTop,'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
            qlOT.SBQQ__Bundle__c = TRUE;
            qlOT.SBQQ__RequiredBy__c = null;
            qlOT.Vendor__c = vendorAcc.Id;
            qlOT.SBQQ__EndDate__c=System.today();
            qlOT.AssetId__c = assetlist[0].Id;
            qlOT.SBQQ__Number__c = 1;
            qlHdr.add(qlOT);
            insert qlHdr;
        }
    }
    
    /*
* @MethodName    : testSetDatesForRemovalQL
* @description	  : Test if setDatesForRemovalQL method is able to set the needed dates of QuoteLines .
* @return        : void
*/
    @isTest
    static void testSetDatesForRemovalQL(){
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Customer Service'];
        //modified by av4 as part of SDT-38494
        //User usrObj= [select id from user where profileId=:p.Id and IsActive=true limit 1];
        User usrObj= [select id from user where LastName =: 'TestingForApproval' limit 1];
        System.runAs(usrObj){
            Set<Id> quoteIdSet = new Set<Id>(New Map<Id, SBQQ__Quote__c>([SELECT Id FROM SBQQ__Quote__c WHERE Duration__c = 'Temporary']).keySet());
            Test.startTest();
            List<SBQQ__QuoteLine__c> quoteLines = QuoteLineSelector.getQuoteLinesByQuoteIdList(quoteIdSet);
            Date removalLineDate = System.today();
            RemovalQuoteLineHandler.setDatesForRemovalQL(quoteLines[0],removalLineDate);
            Assert.areEqual(quoteLines[0].SBQQ__EndDate__c,removalLineDate,'removalLineDate should be copied on quoteLines SBQQ__EndDate__c');
            Assert.areEqual(quoteLines[0].SBQQ__StartDate__c,removalLineDate,'removalLineDate should be copied on quoteLines SBQQ__StartDate__c');
            Assert.areEqual(quoteLines[0].Exceptions_Effective_Date__c,removalLineDate,'removalLineDate should be copied on quoteLines Exceptions_Effective_Date__c');
            Test.stopTest();
        }
    }
    /*
* @MethodName    : testcheckIfBundleQLHasEnddateBeforeInsert
* @description	  : Test if checkIfBundleQLHasEnddateBeforeInsert method is able to insert QuoteLines with and without end date.
* @return        : void
*/
    @isTest
    static void testcheckIfBundleQLHasEnddateBeforeInsert(){
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Customer Service'];
        //modified by av4 as part of SDT-38494
        //User usrObj= [select id from user where profileId=:p.Id and IsActive=true limit 1];
        User usrObj= [select id from user where LastName =: 'TestingForApproval' limit 1];
        System.runAs(usrObj){
            SBQQ__Quote__c quote = [SELECT Id,SBQQ__Account__c,SBQQ__StartDate__c FROM SBQQ__Quote__c WHERE Duration__c = 'Temporary'];
            Product2 prodOpenTop = [SELECT Id,name FROM Product2 WHERE Name = 'Open Top'];
            Test.startTest();
            List<SBQQ__QuoteLine__c> quoteLines = QuoteLineSelector.getQuoteLineList(quote.Id);
            quoteLines[0].SBQQ__EndDate__c = System.today();
            update quoteLines[0];
            
            SBQQ__QuoteLine__c qlRemoval = TestDataFactory.createQuoteLineRecords(quote,prodOpenTop,'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
            qlRemoval.SBQQ__Bundle__c = TRUE;
            qlRemoval.SBQQ__RequiredBy__c = quoteLines[0].id;
            qlRemoval.SBQQ__EndDate__c = System.today();
            qlRemoval.SBQQ__Number__c = 1;
            RemovalQuoteLineHandler.checkIfBundleQLHasEnddateBeforeInsert(qlRemoval);
            assert.isNotNull(qlRemoval.id,'When quoteline has SBQQ__EndDate__c it should get inserted');
            Test.stopTest();
        }
    }
    /*
* @MethodName    : testcheckIfBundleQLHasEnddateBeforeInsert
* @description	  : Test if checkIfBundleQLHasEnddateBeforeInsert method is able to insert QuoteLines with and without end date.
* @return        : void
*/
    @isTest
    static void testIsTempCommercialContainer(){
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Customer Service'];
        //modified by av4 as part of SDT-38494
        //User usrObj= [select id from user where profileId=:p.Id and IsActive=true limit 1];
        User usrObj= [select id from user where LastName =: 'TestingForApproval' limit 1];
        System.runAs(usrObj){
            SBQQ__Quote__c quote = [SELECT Id,SBQQ__Account__c,SBQQ__StartDate__c FROM SBQQ__Quote__c WHERE Duration__c = 'Temporary'];
            Product2 prodOpenTop = [SELECT Id FROM Product2 WHERE Name = 'Open Top'];
            Test.startTest();
            List<SBQQ__QuoteLine__c> quoteLines = QuoteLineSelector.getQuoteLineList(quote.Id);
            quoteLines[0].SBQQ__EndDate__c = System.today();
            update quoteLines[0];
            Map<Id, SBQQ__QuoteLine__c> parentQuoteLineMap = new Map<Id, SBQQ__QuoteLine__c>();
            SBQQ__QuoteLine__c qlRemoval = TestDataFactory.createQuoteLineRecords(quote,prodOpenTop,'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
            qlRemoval.SBQQ__Bundle__c = TRUE;
            qlRemoval.SBQQ__RequiredBy__c = quoteLines[0].id;
            qlRemoval.SBQQ__Number__c = 1;
            insert qlRemoval;
            for(SBQQ__QuoteLine__c quoteLine : quoteLines){
                parentQuoteLineMap.put(quoteLine.Id, quoteLine);
            }
            parentQuoteLineMap.put(qlRemoval.Id, qlRemoval);
            boolean isTempCommercialRemovalLine = false;
            isTempCommercialRemovalLine = RemovalQuoteLineHandler.isTempCommercialContainer(qlRemoval,parentQuoteLineMap);
            assert.areEqual(isTempCommercialRemovalLine,true,'It should return true for Temporary commercial removal line');
            Test.stopTest();
        }
    }
}