@isTest(seeAllData = false)
public class ExceptionDetailsServicesTest {
    
    private static final string SYS_ADMIN = 'System Administrator';
    private static final string NASYS_ADMIN = 'Standard Platform User';
    private static final string TRASH = 'Trash';
    private static final string ON_CALL = 'On-Call';
    private static final string ROLLOFF = 'Rolloff';
    private static final string COMMERCIAL = 'Commercial';
    private static final string SERVICES = 'Services';
    private static final string EQUIPMENT = 'Equipment';  
    private static final string OBJECTAPINAME = 'Pricing_Request__c';
    private static final string FIELDAPINAME = 'Material_Code__c';
    private static final string FIELDVALUE = 'Cardboard';
    private static final string NY_TIMEZONE = 'America/New_York';
    private static final string KROGER = 'kroger';
    private static final string PO_PSI_VALUE = 'PO Number;Profile Number';
    private static final string EXCEPTION_TYPE_CLIENT_INITIATED_CHANGE = 'CLTINITCHG';
    private static final string EXCEPTION_TYPE_OAKLEAF_INITIATED_CHANGE = 'OAKINITCHG';
    private static final string ASSERTION_FAILED_MSG = 'Assertion failed';
    
    
    @testSetup  
    static void setup(){
        test.startTest();
        insertProducts();
        List<Account> acctList = insertAccounts();
        //Changes related to SDT-39632
        //insertAccounts();
        List<Account> accList = new List<Account>();
        
        List<Opportunity> oppList3 = new List<Opportunity>();
        List<Product2> prdList = new List<Product2>();
        
        
        Profile adminProfile = TestDataFactory.getProfile(SYS_ADMIN);
        Profile nonadminProfile = TestDataFactory.getProfile(NASYS_ADMIN);
        
        User usr = TestDataFactory.createUser(adminProfile);
        usr.FirstName = 'Testuser#9999';
        usr.Bypass_Validation__c = true;
        Database.insert(usr);  
        
        User bypassuser = TestDataFactory.createUser(adminProfile);
        bypassuser.Bypass_Validation__c = true;
        insert bypassuser;
        
        User nausr = TestDataFactory.createUser(nonadminProfile);
        nausr.FirstName = 'StandardPlatform';
        nausr.Bypass_Validation__c = true;
        Database.insert(nausr); 
        
        //Changes for SDT-39632
        CodeSwitchTestData.CodeSwitchData();
        
        list<Contact> conlist = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST,Constant_Util.CONSTANT_LAST, acctList.get(1), usr);
        Database.insert(conlist);
        
        list<Case> caselist = new list<Case>(); 
        Case cs = new Case(Status ='New', Priority = 'Medium', Origin = 'Phone', ContactId = conlist[0].id, 
                           AccountId = acctList[0].Id, OwnerId = usr.id, Client__c = acctList[1].Id, Location__c = acctList[0].id, 
                           Case_Type__c = 'New Service', Case_Sub_Type__c = 'Permanent', Case_Reason__c = 'Existing Location',
                           SlaStartDate = system.today(),Recordtypeid = TestDataFactory.getRecordType('New Service Case','Case'));
        caselist.add(cs);
        
        insert caselist;
        
        Account accParent = new Account(Name = 'Parent Account', phone = '9999999999', OwnerId = usr.id, AccountNumber='5678',
                                        RecordTypeid = TestDataFactory.getRecordType('Client','Account'), IsPricingEligible__c = true); 
        insert accParent;
        
        Account acc = new Account(Name = Constant_Util.KEYWORD_TEST, phone = '9999999999', OwnerId = usr.id, AccountNumber='1234',
                                  RecordTypeid = TestDataFactory.getRecordType('Client','Account'), IsPricingEligible__c = true, ParentId = accParent.Id, Type ='Location');
        acclist.add(acc);
        
        
        Account vendorAcc = new Account(Name = 'WM Vendor Account', 
                                        phone = '9999999999',
                                        OwnerId = usr.id, 
                                        AccountNumber='4321',
                                        Status__c = 'Active',
                                        RecordTypeid = TestDataFactory.getRecordType('Vendor','Account'));
        acclist.add(vendorAcc);
        
        Database.insert(acclist);
        
        list<Account> locationlist1 = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, acclist.get(0).id);
        locationlist1[0].tz__Timezone_SFDC__c = 'America/Chicago';
        locationlist1[0].IsPricingEligible__c = true;
        Database.insert(locationlist1);
        
        Product2 prodOpenTop = TestDataFactory.createProduct('Open Top',EQUIPMENT, 'OT');
        prodOpenTop.Is_Pricing_Eligible__c = true;
        prdList.add(prodOpenTop);
        
        Product2 prodCompactor = TestDataFactory.createProduct('Compactor',EQUIPMENT, 'CMP');
        prodCompactor.Is_Pricing_Eligible__c = true;
        prdList.add(prodCompactor);
        
        Product2 prodDumpster = TestDataFactory.createProduct('Dumpster',EQUIPMENT, 'DMP');
        prodDumpster.Is_Pricing_Eligible__c = true;
        prdList.add(prodDumpster);
        
        //Changes related to SDT-39632
        Product2 trashCategory = new Product2(Name = 'Trash', Family = 'Waste Category', SBQQ__Component__c = TRUE, ProductCode = 'TRASH');
        prdList.add(trashCategory);
        Product2 trashStream = new Product2(Name = 'Trash', Family = 'Waste Stream', SBQQ__Component__c = TRUE, ProductCode = 'T');
        prdList.add(trashStream);  
        
        Database.insert(prdList);
        
        Case newModifyCase = TestDataFactory.newModifyExistingCase(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0),usr,locationlist1.get(0)); 
        newModifyCase.Service_Date__c = system.today() + 1;
        newModifyCase.SLA_Service_Date_Time__c = system.today() + 2;
        newModifyCase.RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Modify Existing Service Case'].Id;  
        newModifyCase.Case_Type__c = 'Change Service'; 
        newModifyCase.Case_Sub_Type__c = 'Increase'; 
        newModifyCase.Case_Reason__c = 'Size'; 
        newModifyCase.LOB__c = 'Rolloff';
        newModifyCase.Status = 'Open';
        newModifyCase.Service_Occurrence_Type_Code__c = ON_CALL;
        newModifyCase.Material_Type__c = TRASH;
        
        Database.insert(newModifyCase);
        
        oppList3.addAll(TestDataFactory.createOpportunity(2,'TestOpportunityTest2',newModifyCase.Id,/*newModifyCase.Case_Sub_Type__c*/ 'Permanent', newModifyCase.Location__c));
        insert oppList3;
        
        List<SBQQ__Quote__c> quoteList2  = new List<SBQQ__Quote__c>();
        quoteList2.addAll(TestDataFactory.createQuoteRecords(oppList3,acclist[0],conlist[0],Date.today(),false,true));
        quoteList2[0].SBQQ__ShippingStreet__c = 'ABC';
        quoteList2[0].SBQQ__ShippingCity__c = 'Test123';
        quoteList2[0].SBQQ__ShippingCountry__c = 'USA';
        quoteList2[0].SBQQ__ShippingState__c = 'NY';
        quoteList2[0].SBQQ__ShippingPostalCode__c = '1234';
        quoteList2[0].Duration__c = 'Permanent';
        quoteList2[0].SBQQ__Status__c = 'Draft';
        quoteList2[0].SBQQ__StartDate__c = system.today();
        insert quoteList2;
        
        //Inserting Account Position (Location_Position)
        Account_Position__c accLocPosition1 = new Account_Position__c(AccountId__c = acclist[0].Id,
                                                                      Container_Position__c = 'Test 2',
                                                                      AlternatePostalCode__c = '1234',
                                                                      AlternateCity__c = 'Test City',
                                                                      AlternateCountry__c = 'USA',
                                                                      AlternateState__c = 'NY',
                                                                      AlternateStreet__c = 'Day Hill Road');
        insert accLocPosition1;
        
        List<SBQQ__QuoteLine__c> qlHdr1 = new List<SBQQ__QuoteLine__c>();
        
        //Bundle 2 - Dumpster
        SBQQ__QuoteLine__c qlDMP1 = TestDataFactory.createQuoteLineRecords(quoteList2[0],prodDumpster,'PERM',1.00,'CLT','YRDS-4','SCH','M','1','PER',34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
        qlDMP1.SBQQ__Bundle__c = TRUE;
        qlDMP1.SBQQ__RequiredBy__c = null;
        qlDMP1.IsExtraPickup__c = true;
        qlDMP1.Location_Position_Name__c = accLocPosition1.Id;
        qlHdr1.add(qlDMP1);
        
        insert qlHdr1;
        
        //Changes related to SDT-39632
        List<SBQQ__QuoteLine__c> wcQlList = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c wCqLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = quoteList2[0].Id,
                                              SBQQ__Product__c = trashCategory.Id,
                                              SBQQ__RequiredBy__c = qlDMP1.Id);
                                                          
        SBQQ__QuoteLine__c wSqLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = quoteList2[0].Id,
                                              SBQQ__Product__c = trashStream.Id,
                                              SBQQ__RequiredBy__c = qlDMP1.Id);
        
        wcQlList.addAll(new List<SBQQ__QuoteLine__c>{wCqLine,wSqLine});
        insert wcQlList;
        
        Case pickupCase = QuoteTestDataFactory.createCase('Pickup Case','Pickup','Extra Pickup','', acctList[1],conlist[0], acctList[0]);
        Database.insert(pickupCase);
        
        Case pickupCase2 = QuoteTestDataFactory.createCase('New Service Case','New Service','Permanent','Existing Location', acctList[1],conlist[0], acctList[0]);
        Database.insert(pickupCase2);
        
        
        List<Opportunity> oppList = TestDataFactory.createOpportunity(1,'TestOpportunityTest',caselist[0].Id,caselist[0].Case_Sub_Type__c, acctList[0].Id); //PK
        oppList[0].Duration__c='Temporary';
        Database.insert(oppList);
        
        List<Opportunity> oppList2 = TestDataFactory.createOpportunity(1,'TestOpportunityTest',caselist[0].Id,caselist[0].Case_Sub_Type__c, acctList[0].Id); //PK
        oppList2[0].Duration__c='Temporary';
        Database.insert(oppList2);
        
        
        list<Account> locationlist = TestDataFactory.createLocation('Location', usr, acctList[0].id);
        Database.insert(locationlist);
        
        Test.stopTest();
        //insert Quote
        List<SBQQ__Quote__c> qListNew   = new List<SBQQ__Quote__c>();
        SBQQ__Quote__c draftQuote = new SBQQ__Quote__c();
        draftQuote.SBQQ__Account__c = acctList[0].id;
        draftQuote.SBQQ__Status__c = 'Draft';
        draftQuote.Duration__c = 'Temporary';
        draftQuote.SBQQ__StartDate__c = system.today();
        draftQuote.SBQQ__Opportunity2__c = oppList[0].Id;
        qListNew.add(draftQuote);
        
        SBQQ__Quote__c draftQuote1 = new SBQQ__Quote__c();
        draftQuote1.SBQQ__Account__c = acctList[2].id;
        draftQuote1.SBQQ__Status__c = 'Cost Configured';
        draftQuote1.Duration__c = 'Temporary';
        draftQuote1.SBQQ__StartDate__c = system.today();
        draftQuote1.SBQQ__Opportunity2__c = oppList2[0].Id;
        qListNew.add(draftQuote1);
        
        insert qListNew;
       
        List<SBQQ__QuoteLine__c> qlHdr = new List<SBQQ__QuoteLine__c>();
        //Bundle 1 - Open Top
        SBQQ__QuoteLine__c qlOT = TestDataFactory.createQuoteLineRecords(qListNew[0],prodOpenTop,'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
        qlOT.SBQQ__Bundle__c = TRUE;
        qlOT.SBQQ__RequiredBy__c = null;
        qlOT.Vendor__c = vendorAcc.Id;
        qlOT.IsExtraPickup__c = true;
        qlHdr.add(qlOT);
        
        //Bundle 2 - Dumpster
        SBQQ__QuoteLine__c qlDMP = TestDataFactory.createQuoteLineRecords(qListNew[0],prodDumpster,'PERM',1.00,'CLT','YRDS-4','SCH','M','1','PER',34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
        qlDMP.SBQQ__Bundle__c = TRUE;
        qlDMP.SBQQ__RequiredBy__c = null;
        qlDMP.Vendor__c = vendorAcc.Id;
        qlHdr.add(qlDMP);
    }
    
    /**
     * @description : this method inserts the products and returns the list.
     */
    public static List<Product2> insertProducts(){
        List<Product2> prodList = new List<Product2>();
        Product2 container = new Product2(Name = 'Open Top', Family = 'Equipment', ProductCode = 'OT', Bypass_Acorn_Integration__c=false);
        Product2 haulService = new Product2(Name = 'Haul', Family = 'Services', SBQQ__Component__c = TRUE, ProductCode = 'H',  Bypass_Acorn_Integration__c=false);
        Product2 managementFee = new Product2(Name = 'Management Fee', Family = 'Services', SBQQ__Component__c = TRUE, ProductCode = 'H',  Bypass_Acorn_Integration__c=false);
        Product2 deliveryService = new Product2(Name = 'Delivery', Family = 'Services', SBQQ__Component__c = TRUE, ProductCode = 'DLV',  Bypass_Acorn_Integration__c=false);
        Product2 trashCategory = new Product2(Name = 'Trash', Family = 'Waste Category', SBQQ__Component__c = TRUE, ProductCode = 'TRASH');
        Product2 trashStream = new Product2(Name = 'Trash', Family = 'Waste Stream', SBQQ__Component__c = TRUE, ProductCode = 'T');
        prodList.add(container);
        prodList.add(haulService);
        prodList.add(deliveryService);
        prodList.add(trashCategory);
        prodList.add(trashStream);
        prodList.add(managementFee);
        insert prodList;
        return prodList;
    }

    /**
     * @description : this method inserts the accounts and returns the list.
     */
    public static List<Account> insertAccounts(){
        List<Account> acctList = new List<Account>();
        RecordType customerType = [SELECT Id FROM RecordType WHERE Name = 'Client'];
        RecordType locationType = [SELECT Id FROM RecordType WHERE Name = 'Location'];
        RecordType vendorType = [SELECT Id FROM RecordType WHERE Name = 'Vendor'];
        
        //Changes related to SDT-39632
        Account customer = new Account(Name = 'Test Customer', RecordTypeId = locationType.Id,Status__c = 'Active');
        Account parentCustomer = new Account(Name = 'Test Parent', RecordTypeId = customerType.Id,AccountNumber = '81');
        Account childVendor = new Account(Name = 'Test Vendor', RecordTypeId = vendorType.Id,
                                          Status__c = 'Active', AccountNumber = '111266', Vendor_Business_Unit__c = '1');
        Account parentVendor = new Account(Name = 'Parent Vendor', RecordTypeId = vendorType.Id,
                                           Status__c = 'Active', AccountNumber = '8');
        Account wmVendor = new Account(Name = 'WM', RecordTypeId = vendorType.Id,
                                       Status__c = 'Active', AccountNumber = '8');
        Account wmFeeVendor = new Account(Name = 'WM Fee', RecordTypeId = vendorType.Id,
                                          Status__c = 'Active', AccountNumber = '8');     
        
        acctList.add(customer);
        acctList.add(parentCustomer);
        acctList.add(childVendor);
        acctList.add(parentVendor);
        acctList.add(wmVendor);
        acctList.add(wmFeeVendor);
        
        insert acctList;
        
        acctList[2].ParentId = acctList[3].id;
        acctList[0].ParentId = acctList[1].id;
        update acctList;
        
        return acctList;
    }
    
    
    @isTest static void copyExceptionEffectiveDateTest(){ 
          
        List<Account> vendorAcc = [Select id,Vendor_Business_Unit__c from Account where Name= 'WM Vendor Account' limit 1];        
        
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('New Service Case').getRecordTypeId();
        
        
        Product2 container = [SELECT id, Name, Family, ProductCode FROM Product2 WHERE name='Open Top' LIMIT 1];
        Product2 haulService = [SELECT Name, Family, SBQQ__Component__c, ProductCode FROM Product2 WHERE Name = 'Haul' LIMIT 1];
        
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
        testQuote = [SELECT id, SBQQ__Account__c, SBQQ__Status__c, Duration__c, SBQQ__StartDate__c,Case__c, SBQQ__Opportunity2__r.Case__c, SBQQ__Opportunity2__r.Case__r.RecordTypeId FROM SBQQ__Quote__c WHERE SBQQ__Status__c='Draft' AND Case__c != null AND SBQQ__Opportunity2__r.Case__r.RecordTypeId =:caseRecordTypeId];
        
        SBQQ__QuoteLine__c parentQL = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                             SBQQ__Product__c = container.Id,
                                                             Equipment_Size__c = 'YRDS-30',
                                                             Occurrence_Type__c='SOC');
        insert parentQL;
        
        List<SBQQ__QuoteLine__c> qLineList = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c qLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                          SBQQ__Product__c = haulService.Id,
                                                          SBQQ__RequiredBy__c = parentQL.Id,
                                                          Occurrence_Type__c='SOC');
        
        qLineList.add(qLine);
        
        
        
        Test.startTest();
        insert qLineList; 
        List<SBQQ__QuoteLine__c> lstQuoteLine = [Select id,Vendor__c,Exception_Type__c,Exception_Reason__c,Exception_Comments__c,Exception_Effective_Date__c,Exceptions_Effective_Date__c,SBQQ__RequiredBy__c,SBQQ__ProductCode__c from SBQQ__QuoteLine__c where SBQQ__Quote__c=: testQuote.Id limit 1];
        List<SBQQ__QuoteLine__c> qlListForQuote = [select Id,Exceptions_Effective_Date__c,Exception_Type__c,Exception_Reason__c,Exception_Comments__c from SBQQ__QuoteLine__c where SBQQ__Quote__c=: testQuote.Id];
        
        qlListForQuote[0].Vendor__c = vendorAcc[0].Id ;
        
        update qlListForQuote;
        Test.stopTest();
    
        ExceptionDetailsServices.copyExceptionEffectiveDateToExceptionsEffectiveDate(lstQuoteLine);   
        
        System.assertEquals(lstQuoteLine[0].Exceptions_Effective_Date__c, lstQuoteLine[0].Exception_Effective_Date__c, ASSERTION_FAILED_MSG);
    }
    
    
    // For Quote in Draft Status
    @isTest static void draftServicewithUCCTest(){
        
        User usr = [Select Id,User_categorization_code__c,FirstName from User where FirstName = 'Testuser#9999' LIMIT 1];
        usr.User_categorization_code__c = 'SPCOR';
        update usr;
        
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('New Service Case').getRecordTypeId();
        
        System.runAs(usr){
            SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
            testQuote = [SELECT id, SBQQ__Account__c, SBQQ__Status__c, Duration__c, SBQQ__StartDate__c,Case__c, SBQQ__Opportunity2__r.Case__c, SBQQ__Opportunity2__r.Case__r.RecordTypeId FROM SBQQ__Quote__c WHERE SBQQ__Status__c='Draft' AND Case__c != null AND SBQQ__Opportunity2__r.Case__r.RecordTypeId =:caseRecordTypeId];
            
            Product2 container = [SELECT id, Name, Family, ProductCode FROM Product2 WHERE name='Open Top' LIMIT 1];
            Product2 haulService = [SELECT Name, Family, SBQQ__Component__c, ProductCode FROM Product2 WHERE Name = 'Haul' LIMIT 1];
            
            SBQQ__QuoteLine__c parentQL = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                                 SBQQ__Product__c = container.Id,
                                                                 Equipment_Size__c = 'YRDS-30',
                                                                 Occurrence_Type__c='SOC');
            insert parentQL;
            
            List<SBQQ__QuoteLine__c> qLineList = new List<SBQQ__QuoteLine__c>();
            SBQQ__QuoteLine__c qLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                              SBQQ__Product__c = haulService.Id,
                                                              SBQQ__RequiredBy__c = parentQL.Id,
                                                              Occurrence_Type__c='SOC');
            
            qLineList.add(qLine);
            
            Test.startTest();
            insert qLineList; 
            Test.stopTest();
            
            List<SBQQ__QuoteLine__c> qlListForQuote = [select Id,Exceptions_Effective_Date__c,Exception_Type__c,Exception_Reason__c,Exception_Comments__c from SBQQ__QuoteLine__c where SBQQ__Quote__c=: testQuote.Id];
            
            System.assertEquals(qlListForQuote[0].Exceptions_Effective_Date__c, null, ASSERTION_FAILED_MSG);
            System.assertEquals(qlListForQuote[0].Exception_Comments__c, null, ASSERTION_FAILED_MSG);
            System.assertEquals(qlListForQuote[0].Exception_Type__c, null, ASSERTION_FAILED_MSG);
            System.assertEquals(qlListForQuote[0].Exception_Reason__c, null, ASSERTION_FAILED_MSG);    
        }
    }
    
    @isTest static void draftServicewithoutUCCTest(){
        User usr = [Select Id,User_categorization_code__c,FirstName from User where FirstName = 'Testuser#9999' LIMIT 1];
        usr.User_categorization_code__c = null;
        update usr;
        
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('New Service Case').getRecordTypeId();
        
        System.runAs(usr){
            SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
            testQuote = [SELECT id, SBQQ__Account__c, SBQQ__Status__c, Duration__c, SBQQ__StartDate__c,Case__c, SBQQ__Opportunity2__r.Case__c, SBQQ__Opportunity2__r.Case__r.RecordTypeId FROM SBQQ__Quote__c WHERE SBQQ__Status__c='Draft' AND Case__c != null AND SBQQ__Opportunity2__r.Case__r.RecordTypeId =:caseRecordTypeId];
            
            Product2 container = [SELECT id, Name, Family, ProductCode FROM Product2 WHERE name='Open Top' LIMIT 1];
            Product2 haulService = [SELECT Name, Family, SBQQ__Component__c, ProductCode FROM Product2 WHERE Name = 'Haul' LIMIT 1];
            
            SBQQ__QuoteLine__c parentQL = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                                 SBQQ__Product__c = container.Id,
                                                                 Equipment_Size__c = 'YRDS-30',
                                                                 Occurrence_Type__c='SOC');
            insert parentQL;
            
            List<SBQQ__QuoteLine__c> qLineList = new List<SBQQ__QuoteLine__c>();
            SBQQ__QuoteLine__c qLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                              SBQQ__Product__c = haulService.Id,
                                                              SBQQ__RequiredBy__c = parentQL.Id,
                                                              Occurrence_Type__c='SOC');
            
            qLineList.add(qLine);
            
            Test.startTest();
            insert qLineList; 
            Test.stopTest();
            
            List<SBQQ__QuoteLine__c> qlListForQuote = [select Id,Exception_Effective_Date__c,Exception_Type__c,Exception_Reason__c,Exception_Comments__c from SBQQ__QuoteLine__c where SBQQ__Quote__c=: testQuote.Id];  
            
            System.assertEquals(qlListForQuote[0].Exception_Effective_Date__c, null, ASSERTION_FAILED_MSG);
            System.assertEquals(qlListForQuote[0].Exception_Comments__c, null, ASSERTION_FAILED_MSG);
            System.assertEquals(qlListForQuote[0].Exception_Type__c, null, ASSERTION_FAILED_MSG);
            System.assertEquals(qlListForQuote[0].Exception_Reason__c, null, ASSERTION_FAILED_MSG);    
        }
    }
    
    @isTest static void draftMESwithUCCUpdateTest(){
        User usr = [Select Id,User_categorization_code__c,FirstName from User where FirstName = 'Testuser#9999' LIMIT 1];
        usr.User_categorization_code__c = 'SPCOR';
        update usr;
        
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Modify Existing Service Case').getRecordTypeId();
        
        System.runAs(usr){
            SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
            testQuote = [SELECT id, SBQQ__Account__c, SBQQ__Status__c, Duration__c, SBQQ__StartDate__c,Case__c, SBQQ__Opportunity2__r.Case__c, SBQQ__Opportunity2__r.Case__r.RecordTypeId FROM SBQQ__Quote__c WHERE SBQQ__Status__c='Draft' AND Case__c != null AND SBQQ__Opportunity2__r.Case__r.RecordTypeId =:caseRecordTypeId];
            
            Product2 container = [SELECT id, Name, Family, ProductCode FROM Product2 WHERE name='Open Top' LIMIT 1];
            Product2 haulService = [SELECT Name, Family, SBQQ__Component__c, ProductCode FROM Product2 WHERE Name = 'Haul' LIMIT 1];
            
            SBQQ__QuoteLine__c parentQL = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                                 SBQQ__Product__c = container.Id,
                                                                 Equipment_Size__c = 'YRDS-30',
                                                                 Occurrence_Type__c='SOC');
            insert parentQL;
            
            List<SBQQ__QuoteLine__c> qLineList = new List<SBQQ__QuoteLine__c>();
            SBQQ__QuoteLine__c qLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                              SBQQ__Product__c = haulService.Id,
                                                              SBQQ__RequiredBy__c = parentQL.Id,
                                                              Occurrence_Type__c='SOC');
            
            qLineList.add(qLine);
            
            Test.startTest();
            insert qLineList; 
            qLineList[0].Schedule_Frequency__c = 'W';
            update qLineList;
            Test.stopTest();
            
            List<SBQQ__QuoteLine__c> qlListForQuote = [select Id,Exceptions_Effective_Date__c,Exception_Type__c,Exception_Reason__c,Exception_Comments__c from SBQQ__QuoteLine__c where SBQQ__Quote__c=: testQuote.Id];
            
            System.assertEquals(qlListForQuote[0].Exceptions_Effective_Date__c, null, ASSERTION_FAILED_MSG);
            System.assertEquals(qlListForQuote[0].Exception_Comments__c, null, ASSERTION_FAILED_MSG);
            System.assertEquals(qlListForQuote[0].Exception_Type__c, null, ASSERTION_FAILED_MSG);
            System.assertEquals(qlListForQuote[0].Exception_Reason__c, null, ASSERTION_FAILED_MSG);    
        }
    }
    
    @isTest static void draftMESwithoutUCCUpdateTest(){
        User usr = [Select Id,User_categorization_code__c,FirstName from User where FirstName = 'Testuser#9999' LIMIT 1];
        usr.User_categorization_code__c = null;
        update usr;
        
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Modify Existing Service Case').getRecordTypeId();
        
        System.runAs(usr){
            SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
            testQuote = [SELECT id, SBQQ__Account__c, SBQQ__Status__c, Duration__c, SBQQ__StartDate__c,Case__c, SBQQ__Opportunity2__r.Case__c, SBQQ__Opportunity2__r.Case__r.RecordTypeId FROM SBQQ__Quote__c WHERE SBQQ__Status__c='Draft' AND Case__c != null AND SBQQ__Opportunity2__r.Case__r.RecordTypeId =:caseRecordTypeId];
            
            Product2 container = [SELECT id, Name, Family, ProductCode FROM Product2 WHERE name='Open Top' LIMIT 1];
            Product2 haulService = [SELECT Name, Family, SBQQ__Component__c, ProductCode FROM Product2 WHERE Name = 'Haul' LIMIT 1];
            
            SBQQ__QuoteLine__c parentQL = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                                 SBQQ__Product__c = container.Id,
                                                                 Equipment_Size__c = 'YRDS-30',
                                                                 Occurrence_Type__c='SOC');
            insert parentQL;
            
            List<SBQQ__QuoteLine__c> qLineList = new List<SBQQ__QuoteLine__c>();
            SBQQ__QuoteLine__c qLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                              SBQQ__Product__c = haulService.Id,
                                                              SBQQ__RequiredBy__c = parentQL.Id,
                                                              Occurrence_Type__c='SOC');
            
            qLineList.add(qLine);
            
            Test.startTest();
            insert qLineList; 
            qLineList[0].Schedule_Frequency__c = 'W';
            update qLineList;
            Test.stopTest();
            
            List<SBQQ__QuoteLine__c> qlListForQuote = [select Id,Exceptions_Effective_Date__c,Exception_Type__c,Exception_Reason__c,Exception_Comments__c from SBQQ__QuoteLine__c where SBQQ__Quote__c=: testQuote.Id];
            
            System.assertEquals(qlListForQuote[0].Exceptions_Effective_Date__c, null, ASSERTION_FAILED_MSG);
            System.assertEquals(qlListForQuote[0].Exception_Comments__c, null, ASSERTION_FAILED_MSG);
            System.assertEquals(qlListForQuote[0].Exception_Type__c, null, ASSERTION_FAILED_MSG);
            System.assertEquals(qlListForQuote[0].Exception_Reason__c, null, ASSERTION_FAILED_MSG);    
        }
    }
    
    
    
    @isTest static void draftServicewithoutUCCAddTest(){
        
        User usr = [Select Id,User_categorization_code__c,FirstName from User where FirstName = 'Testuser#9999' LIMIT 1];
        usr.User_categorization_code__c = null;
        update usr;
        
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('New Service Case').getRecordTypeId();
        
        System.runAs(usr){
            SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
            testQuote = [SELECT id, SBQQ__Account__c, SBQQ__Status__c, Duration__c, SBQQ__StartDate__c,Case__c, SBQQ__Opportunity2__r.Case__c, SBQQ__Opportunity2__r.Case__r.RecordTypeId FROM SBQQ__Quote__c WHERE SBQQ__Status__c='Draft' AND Case__c != null AND SBQQ__Opportunity2__r.Case__r.RecordTypeId =:caseRecordTypeId];
            
            Product2 container = [SELECT id, Name, Family, ProductCode FROM Product2 WHERE name='Open Top' LIMIT 1];
            Product2 haulService = [SELECT Name, Family, SBQQ__Component__c, ProductCode FROM Product2 WHERE Name = 'Haul' LIMIT 1];
            
            SBQQ__QuoteLine__c parentQL = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                                 SBQQ__Product__c = container.Id,
                                                                 Equipment_Size__c = 'YRDS-30',
                                                                 Occurrence_Type__c='SOC');
            insert parentQL;
            
            List<SBQQ__QuoteLine__c> qLineList = new List<SBQQ__QuoteLine__c>();
            SBQQ__QuoteLine__c qLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                              SBQQ__Product__c = haulService.Id,
                                                              SBQQ__RequiredBy__c = parentQL.Id,
                                                              Occurrence_Type__c='SOC');
            
            
            qLineList.add(qLine);
            
            Test.startTest();
            insert qLineList; 
            
            Test.stopTest();
            
            List<SBQQ__QuoteLine__c> qlListForQuote = [select Id,Exceptions_Effective_Date__c,Exception_Type__c,Exception_Reason__c,Exception_Comments__c from SBQQ__QuoteLine__c where SBQQ__Quote__c=: testQuote.Id];
            
            System.assertEquals(qlListForQuote[0].Exceptions_Effective_Date__c, null, ASSERTION_FAILED_MSG);
            System.assertEquals(qlListForQuote[0].Exception_Comments__c, null, ASSERTION_FAILED_MSG);
            System.assertEquals(qlListForQuote[0].Exception_Type__c, null, ASSERTION_FAILED_MSG);
            System.assertEquals(qlListForQuote[0].Exception_Reason__c, null, ASSERTION_FAILED_MSG);
        }
        
        
    }
    
    
    
    // For Quote in Procure Service
    @isTest static void procureServicewithUCCTest(){
        
        User usr = [Select Id,User_categorization_code__c,FirstName from User where FirstName = 'Testuser#9999' LIMIT 1];
        usr.User_categorization_code__c = 'SPCOR';
        update usr;
        
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('New Service Case').getRecordTypeId();
        
        System.runAs(usr){
            SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
            testQuote = [SELECT id, SBQQ__Account__c, SBQQ__Status__c, Duration__c, SBQQ__StartDate__c,Case__c, SBQQ__Opportunity2__r.Case__c, SBQQ__Opportunity2__r.Case__r.RecordTypeId FROM SBQQ__Quote__c WHERE SBQQ__Status__c='Draft' AND Case__c != null AND SBQQ__Opportunity2__r.Case__r.RecordTypeId =:caseRecordTypeId];
            testQuote.SBQQ__Status__c = Constant_Util.QUOTE_PRODUCT_CONFIGURED;
   
            
            Product2 container = [SELECT id, Name, Family, ProductCode FROM Product2 WHERE name='Open Top' LIMIT 1];
            Product2 haulService = [SELECT Name, Family, SBQQ__Component__c, ProductCode FROM Product2 WHERE Name = 'Haul' LIMIT 1];
            
            //Changes related to SDT-39632
            Product2 wCproduct = [SELECT Id,Name, Family, SBQQ__Component__c, ProductCode FROM Product2 WHERE Name = 'Trash' LIMIT 1];

            
            SBQQ__QuoteLine__c parentQL = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                                 SBQQ__Product__c = container.Id,
                                                                 Equipment_Size__c = 'YRDS-30',
                                                                 Occurrence_Type__c='SOC',
                                                                 Schedule_Frequency__c='W',
                                                                 Service_Days__c='M');//added sch freq and serv days
            insert parentQL;
            
            List<SBQQ__QuoteLine__c> qLineList = new List<SBQQ__QuoteLine__c>();
            SBQQ__QuoteLine__c qLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                              SBQQ__Product__c = haulService.Id,
                                                              SBQQ__RequiredBy__c = parentQL.Id,
                                                              Occurrence_Type__c='SOC',
                                                              Schedule_Frequency__c='W',
                                                              Service_Days__c='M');//added sch freq and serv days
            
            //Changes related to SDT-39632
            SBQQ__QuoteLine__c wCqLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                  SBQQ__Product__c = wCproduct.Id,
                                                  SBQQ__RequiredBy__c = parentQL.Id);
                        
            Test.startTest();
            qLineList.addAll(new List<SBQQ__QuoteLine__c>{qLine,wCqLine});
            insert qLineList;
            update  testQuote; //added
            Test.stopTest();
            
            List<SBQQ__QuoteLine__c> qlListForQuote = [select Id,Exceptions_Effective_Date__c,Exception_Type__c,Exception_Reason__c,Exception_Comments__c from SBQQ__QuoteLine__c where SBQQ__Quote__c=: testQuote.Id and SBQQ__RequiredBy__c != null];
            
            System.assertEquals(qlListForQuote[0].Exception_Type__c, Constant_Util.EXCEPTION_TYPE_OAKLEAF_INITIATED_CHANGE, ASSERTION_FAILED_MSG);
            System.assertEquals(qlListForQuote[0].Exception_Reason__c,  Constant_Util.EXCEPTION_REASON_DATA_ERROR_FIX, ASSERTION_FAILED_MSG);    
        }
    }       
    @isTest static void procureServicewithoutUCCTest(){
        
        
        User usr = [Select Id,User_categorization_code__c,FirstName from User where FirstName = 'Testuser#9999' LIMIT 1];
        usr.User_categorization_code__c = null;
        update usr;
        
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('New Service Case').getRecordTypeId();
        
        System.runAs(usr){
            SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
            testQuote = [SELECT id, SBQQ__Account__c, SBQQ__Status__c, Duration__c, SBQQ__StartDate__c,Case__c, SBQQ__Opportunity2__r.Case__c, SBQQ__Opportunity2__r.Case__r.RecordTypeId FROM SBQQ__Quote__c WHERE SBQQ__Status__c='Draft' AND Case__c != null AND SBQQ__Opportunity2__r.Case__r.RecordTypeId =:caseRecordTypeId];
            testQuote.SBQQ__Status__c = Constant_Util.QUOTE_PRODUCT_CONFIGURED;
          
           
            Product2 container = [SELECT id, Name, Family, ProductCode FROM Product2 WHERE name='Open Top' LIMIT 1];
            Product2 haulService = [SELECT Name, Family, SBQQ__Component__c, ProductCode FROM Product2 WHERE Name = 'Haul' LIMIT 1];
            
           //Changes related to SDT-39632
            Product2 wCproduct = [SELECT Id,Name, Family, SBQQ__Component__c, ProductCode FROM Product2 WHERE Name = 'Trash' LIMIT 1];            
            
            SBQQ__QuoteLine__c parentQL = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                                 SBQQ__Product__c = container.Id,
                                                                 Equipment_Size__c = 'YRDS-30',
                                                                 Occurrence_Type__c='SOC',
                                                                 Schedule_Frequency__c='W',
                                                                 Service_Days__c='M');//added sch freq and serv days
            insert parentQL;
            
            List<SBQQ__QuoteLine__c> qLineList = new List<SBQQ__QuoteLine__c>();
            SBQQ__QuoteLine__c qLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                              SBQQ__Product__c = haulService.Id,
                                                              SBQQ__RequiredBy__c = parentQL.Id,
                                                              Occurrence_Type__c='SOC',
                                                              Schedule_Frequency__c='W',
                                                              Service_Days__c='M');//added sch freq and serv days
            
            //Changes related to SDT-39632
            SBQQ__QuoteLine__c wCqLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                  SBQQ__Product__c = wCproduct.Id,
                                                  SBQQ__RequiredBy__c = parentQL.Id);
            
            Test.startTest();
            qLineList.addAll(new List<SBQQ__QuoteLine__c>{qLine,wCqLine});
            insert qLineList;
            update  testQuote; //added
            Test.stopTest();
            
            List<SBQQ__QuoteLine__c> qlListForQuote = [select Id,Exceptions_Effective_Date__c,Exception_Type__c,Exception_Reason__c,Exception_Comments__c from SBQQ__QuoteLine__c where SBQQ__Quote__c=: testQuote.Id and SBQQ__RequiredBy__c != null];

            System.assertEquals(qlListForQuote[0].Exception_Type__c, Constant_Util.EXCEPTION_TYPE_CLIENT_INITIATED_CHANGE, ASSERTION_FAILED_MSG);
            System.assertEquals(qlListForQuote[0].Exception_Reason__c, Constant_Util.EXCEPTION_REASON_NEW_SERVICE, ASSERTION_FAILED_MSG);    
        }
    }
    @isTest static void setRemovalQLExceptionDateTest(){
        
        
        User usr = [Select Id,User_categorization_code__c,FirstName from User where FirstName = 'Testuser#9999' LIMIT 1];
        usr.User_categorization_code__c = null;
        update usr;
        
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('New Service Case').getRecordTypeId();
        
        System.runAs(usr){
            SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
            testQuote = [SELECT id, SBQQ__Account__c, SBQQ__Status__c, Duration__c, SBQQ__StartDate__c,Case__c, SBQQ__Opportunity2__r.Case__c, SBQQ__Opportunity2__r.Case__r.RecordTypeId FROM SBQQ__Quote__c WHERE SBQQ__Status__c='Draft' AND Case__c != null AND SBQQ__Opportunity2__r.Case__r.RecordTypeId =:caseRecordTypeId];
            testQuote.SBQQ__Status__c = Constant_Util.QUOTE_PRODUCT_CONFIGURED;
          
           
            Product2 container = [SELECT id, Name, Family, ProductCode FROM Product2 WHERE name='Open Top' LIMIT 1];
            Product2 haulService = [SELECT Name, Family, SBQQ__Component__c, ProductCode FROM Product2 WHERE Name = 'Haul' LIMIT 1];
            
            //Changes related to SDT-39632
            Product2 wCproduct = [SELECT Id,Name, Family, SBQQ__Component__c, ProductCode FROM Product2 WHERE Name = 'Trash' LIMIT 1];  
            
            List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
            SBQQ__QuoteLine__c parentQL = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                                 SBQQ__Product__c = container.Id,
                                                                 Equipment_Size__c = 'YRDS-30',
                                                                 Occurrence_Type__c='SOC',
                                                                 Schedule_Frequency__c='W',
                                                                 Service_Days__c='M');//added sch freq and serv days
            insert parentQL;
            
            List<SBQQ__QuoteLine__c> qLineList = new List<SBQQ__QuoteLine__c>();
            SBQQ__QuoteLine__c qLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                              SBQQ__Product__c = haulService.Id,
                                                              SBQQ__RequiredBy__c = parentQL.Id,
                                                              Occurrence_Type__c='SOC',
                                                              Schedule_Frequency__c='W',
                                                              Service_Days__c='M');//added sch freq and serv days
            
            //Changes related to SDT-39632
            SBQQ__QuoteLine__c wCqLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                  SBQQ__Product__c = wCproduct.Id,
                                                  SBQQ__RequiredBy__c = parentQL.Id);
            
            Test.startTest();
            qLineList.addAll(new List<SBQQ__QuoteLine__c>{qLine,wCqLine});
            insert qLineList;
            update  testQuote; //added
            Test.stopTest();
            
            List<SBQQ__QuoteLine__c> qlListForQuote = [select Id,SBQQ__StartDate__c,Exceptions_Effective_Date__c,Exception_Type__c,Exception_Reason__c,Exception_Comments__c from SBQQ__QuoteLine__c where SBQQ__Quote__c=: testQuote.Id and SBQQ__RequiredBy__c != null];
            for(SBQQ__QuoteLine__c qlList : qlListForQuote){
                ExceptionDetailsServices.setExceptionDate(qlList);              
            }
            Date endDate = system.today();
            if(qlListForQuote.size()>0 && qlListForQuote[0]!=null){
  			ExceptionDetailsServices.setRemovalQLExceptionDate(qlListForQuote[0],endDate);
            }
            if(qLineList.size()>0 && qLineList[0]!=null){
            boolean reasonSet = ExceptionDetailsServices.setExceptionReason(qLineList[0], true);
            Assert.areEqual(reasonSet,true,'returns true if reason is set');
            }
           //  System.assertEquals(qlListForQuote[0].Exception_Reason__c, Constant_Util.EXCEPTION_REASON_NEW_SERVICE );    
        }
     }
         @isTest static void setExceptionReasonMethodTest(){
        
        
        User usr = [Select Id,User_categorization_code__c,FirstName from User where FirstName = 'Testuser#9999' LIMIT 1];
        usr.User_categorization_code__c = null;
        update usr;
        
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('New Service Case').getRecordTypeId();
        
        System.runAs(usr){
            SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
            testQuote = [SELECT id, SBQQ__Account__c, SBQQ__Status__c, Duration__c, SBQQ__StartDate__c,Case__c, SBQQ__Opportunity2__r.Case__c, SBQQ__Opportunity2__r.Case__r.RecordTypeId FROM SBQQ__Quote__c WHERE SBQQ__Status__c='Draft' AND Case__c != null AND SBQQ__Opportunity2__r.Case__r.RecordTypeId =:caseRecordTypeId];
            testQuote.SBQQ__Status__c = Constant_Util.QUOTE_PRODUCT_CONFIGURED;
          
           
            Product2 container = [SELECT id, Name, Family, ProductCode FROM Product2 WHERE name='Open Top' LIMIT 1];
            Product2 haulService = [SELECT Name, Family, SBQQ__Component__c, ProductCode FROM Product2 WHERE Name = 'Haul' LIMIT 1];
            
            //Changes related to SDT-39632
            Product2 wCproduct = [SELECT Id,Name, Family, SBQQ__Component__c, ProductCode FROM Product2 WHERE Name = 'Trash' LIMIT 1];            
            
            List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
            SBQQ__QuoteLine__c parentQL = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                                 SBQQ__Product__c = container.Id,
                                                                 Equipment_Size__c = 'YRDS-30',
                                                                 Occurrence_Type__c='SOC',
                                                                 Schedule_Frequency__c='W',
                                                                 Service_Days__c='M');//added sch freq and serv days
            insert parentQL;
            
            List<SBQQ__QuoteLine__c> qLineList = new List<SBQQ__QuoteLine__c>();
            SBQQ__QuoteLine__c qLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                              SBQQ__Product__c = haulService.Id,
                                                              SBQQ__RequiredBy__c = parentQL.Id,
                                                              Occurrence_Type__c='SOC',
                                                              Schedule_Frequency__c='W',
                                                              Service_Days__c='M');//added sch freq and serv days
                        //Changes related to SDT-39632
            SBQQ__QuoteLine__c wCqLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                  SBQQ__Product__c = wCproduct.Id,
                                                  SBQQ__RequiredBy__c = parentQL.Id);
            
            Test.startTest();
            qLineList.addAll(new List<SBQQ__QuoteLine__c>{qLine,wCqLine});
            insert qLineList;
            update  testQuote; //added
            Test.stopTest();
            Date endDate = system.today();
            if(qLineList.size()>0 && qLineList[0]!=null){
            boolean reasonSet = ExceptionDetailsServices.setExceptionReason(qLineList[0], false);
            Assert.areEqual(reasonSet,true,'returns true if reason is set');
            }  
        }
    }
}