@isTest(seeAllData =false)
public class QuoteOrderTriggerHelperTest {
    
    private static final string SYS_ADMIN = 'System Administrator';
    private static final string TRASH = 'Trash';
    private static final string ON_CALL = 'On-Call';
    private static final string ROLLOFF = 'Rolloff';
    private static final string COMMERCIAL = 'Commercial';
    private static final string SERVICES = 'Services';
    private static final string EQUIPMENT = 'Equipment';
          
    @testSetup static void createData() {
        Profile adminProfile = TestDataFactory.getProfile(SYS_ADMIN);
        
        User usr = TestDataFactory.createUser(adminProfile);
        Database.insert(usr); 
        
        //Changes for SDT-39632
        CodeSwitchTestData.CodeSwitchData();
        
         System.runAs(usr){
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
        System.Debug('@@@~Create Opp : ' + oppList);
        
        quoteList.addAll(TestDataFactory.createQuoteRecords(oppList,acclist[0],conlist[0],Date.today(),false,true));
        quoteList[0].SBQQ__ShippingStreet__c = 'ABC';
        quoteList[0].SBQQ__ShippingCity__c = 'Test1';
        quoteList[0].SBQQ__ShippingCountry__c = 'USA';
        quoteList[0].SBQQ__ShippingState__c = 'NY';
        quoteList[0].SBQQ__ShippingPostalCode__c = '1234';
        quoteList[0].Duration__c = 'Permanent';
        insert quoteList;
        system.debug('Quote ' +quoteList);

        Product2 prodOpenTop = TestDataFactory.createProduct('Open Top',ROLLOFF, 'OT');
        prodOpenTop.Is_Pricing_Eligible__c = true;
        prdList.add(prodOpenTop);
        Product2 prodDelivery= TestDataFactory.createProduct('Delivery','Surcharges and Fees','DLV');
        prdList.add(prodDelivery);
        Database.insert(prdList);
        List<SBQQ__QuoteLine__c> qlHdr = new List<SBQQ__QuoteLine__c>();
        //Bundle 1 - Open Top
        SBQQ__QuoteLine__c qlOT = TestDataFactory.createQuoteLineRecords(quoteList[0],prodOpenTop,'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
        qlOT.SBQQ__Bundle__c = TRUE;
        qlOT.SBQQ__RequiredBy__c = null;
        qlOT.Vendor__c = vendorAcc.Id;
        qlOT.SBQQ__Number__c = 1;
        //qlOT.Location_Position_Name__c = accLocPosition.Id;
        qlHdr.add(qlOT);
        
        insert qlHdr;
        
        List<SBQQ__QuoteLine__c> qlChild = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c qlDelivery = TestDataFactory.createQuoteLineRecords(quoteList[0],prodDelivery,'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',0,'DYS','PER',null,'DYS','Do Not Override','NBG');
        qlDelivery.SBQQ__RequiredBy__c = qlOT.Id;
        qlDelivery.SBQQ__Number__c = 5;
        //qlDelivery.Vendor__c = vendorAcc.Id;
        qlChild.add(qlDelivery);
        //Open Top Child Quote Line  --- End
        
        Database.insert(qlChild); 

        Quote_Order__c qo = new Quote_Order__c();
        qo.Quote_Line__c= qlOT.id;
        qo.Service_Quote_Line__c= qlDelivery.id;
        qo.Service_Type__c='Delivery';
        qo.Product_Type__c='Delivery';
        qo.Service_Date__c= Date.newInstance(2020, 13, 5);
        qo.Instructions__c= 'test1234';
        qo.Cust_Ref_Number__c='test12345';
        qo.Duration__c='PERM';
        qo.Occurrence_Type__c='OC';
        qo.Quantity__c = 20;
        insert qo;  
         }
    }   
    
     @isTest static void quoteLineTest(){ 
        
        test.startTest();
            List<Quote_Order__c> qoRec = [Select id,Cust_Ref_Number__c from Quote_Order__c limit 1];
            qoRec[0].Cust_Ref_Number__c = '123456';
            update qoRec[0];
                         
        test.stopTest();
        
    }

}