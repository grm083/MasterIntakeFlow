/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class IVRUtilityTest {

    private static final string COMPACTOR = 'COMPACTOR';
    private static final string COMMERCIAL = 'Commercial';
    @testSetup
    static void createData(){
        
        test.startTest();
        Profile p= TestDataFactory.getProfile('System Administrator');
        User usr= TestDataFactory.createUser(p);
        usr.Bypass_Validation__c = TRUE;
        usr.FirstName = 'testuser#9999';
        usr.Genesys_Enabled__c = FALSE;
        
        //Changes for SDT-39632
        CodeSwitchTestData.CodeSwitchData();
        
        insert usr; // insert user for the System Administrator
        List<Account> accList;
        List<Account> locationList = new List<Account>();
        List<Contact> conList;
        List<Case> caseList;
        System.runAs(usr){
            /*Creation of Products start 
            Following products have been created Open Top,Haul,Delivery,
            Trash Category,Trash Waste stream*/
            list<product2> productlist = TestDataFactory.createProduct(Constant_Util.KEYWORD_TEST);
            Product2 openTopContainer = new Product2(Name = 'Open Top', Family = 'Rolloff', ProductCode = 'OT',IsActive = TRUE);
            Product2 haulService = new Product2(Name = 'Haul', Family = 'Services', SBQQ__Component__c = TRUE, ProductCode = 'H',IsActive = TRUE);
            Product2 deliveryService = new Product2(Name = 'Delivery', Family = 'Services', SBQQ__Component__c = TRUE, ProductCode = 'DLV',IsActive = TRUE);
            Product2 trashCategory = new Product2(Name = 'Trash', Family = 'Waste Category', SBQQ__Component__c = TRUE, ProductCode = 'OTT',IsActive = TRUE);
            Product2 trashStream = new Product2(Name = 'Trash', Family = 'Waste Stream', SBQQ__Component__c = TRUE, ProductCode = 'T',IsActive = TRUE);
            productlist.add(openTopContainer);
            productlist.add(haulService);
            productlist.add(deliveryService);
            productlist.add(trashCategory);
            productlist.add(trashStream);
            insert productlist;
            /*Creation of Products End */

            /* Product option creation Start 
                Creating Product option for Open Top and Trash category and Trash waste stream.
                1.) Creted WasteCateogry Option with open top and trash Waste Category.
                2.) Created WasteStream option with waste category and waste stream.
            */
            List<SBQQ__ProductOption__c> productOptionList = new List<SBQQ__ProductOption__c>();
            SBQQ__ProductOption__c wasteCategoryOption = new SBQQ__ProductOption__c();
            wasteCategoryOption.SBQQ__ConfiguredSKU__c = openTopContainer.Id;
            wasteCategoryOption.SBQQ__OptionalSKU__c = trashCategory.Id;
            wasteCategoryOption.SBQQ__Number__c = 350;
            wasteCategoryOption.SBQQ__Quantity__c = 1;
            wasteCategoryOption.Occurrence_Type__c = 'OC';
            productOptionList.add(wasteCategoryOption);
            SBQQ__ProductOption__c wasteStreamOption = new SBQQ__ProductOption__c();
            wasteStreamOption.SBQQ__ConfiguredSKU__c = trashCategory.Id;
            wasteStreamOption.SBQQ__OptionalSKU__c = trashStream.Id;
            wasteStreamOption.SBQQ__Number__c = 350;
            wasteStreamOption.SBQQ__Quantity__c = 1;
            wasteStreamOption.Occurrence_Type__c = 'OC';
            productOptionList.add(wasteStreamOption);
            insert productOptionList;
            /* Product option creation END*/

            /* Location Creation Start */
            accList= TestDataFactory.createAccount('TestParentAccountTest', usr,'Client');
            accList[0].AccountNumber = 'ParentTest';
             insert accList;
            Account childlocation = new Account(
                Primary_Segment__c = null,
                ShippingStreet = 'ABC', 
                ShippingCity = 'Test1', 
                ShippingState = 'NY',
                ShippingPostalCode = '1234',
                Name = 'TestLocationAccountTest',
                AccountNumber = 'TestLocationAccountTest',
                Common_Name__c = 'TestLocationAccountTest',
                type = 'location',
                Phone = '9999999999',
                //OwnerId = usr.Id,
                RecordTypeId = TestDataFactory.getRecordType('Location', 'Account'), 
                ParentId = accList[0].Id,  
                Status__c = 'ACTIVE'
            );
            locationList.add(childlocation);
            insert locationList;
            /* Location Creation END */

            /* Contact Creation Start */
            conList= TestDataFactory.createContact('TestContactTest', 'TestContactTest', accList[0], usr);
            conList[0].Email= 'testemail'+ String.valueof(system.now().millisecond())+'@testorg1.com.wm';
            conList[0].Phone= '1890870468';
            insert conList;   
            /* Contact Creation Start */
        
            /* Case Creation Start */
            date startdate = system.today()+1;
            //String strStartDate = startdate.format('YYYY/dd/MM');
            list<Case> caselistnew = new list<Case>(); 
            Case cs = new Case(Comments = 'API Case Creation test',Status ='Draft', Delivery_Date__c = System.Today(),Removal_Date__c= system.today()+5, Priority = 'Medium', Origin = 'IVR Phone', ContactId = conList[0].id, 
                               AccountId =  locationList[0].Id, OwnerId = usr.id, Client__c =  accList[0].Id, Location__c =  locationList[0].id,Material_Type__c ='T',Service_Occurrence_Type_Code__c='OC',Equipment_Size_Code__c='YRDS-20',
                               Equipment_Type_Code__c='OT',Case_Type__c = 'New Service', Case_Sub_Type__c = 'Temporary', Case_Reason__c = 'Clean Up Internal',
                               Company_Category__c='Equipment Repair',CompanyCategoryCode__c='EPR',Empty_and_Return_Date__c = '2024-10-11',
                               SlaStartDate = system.today(),Recordtypeid = TestDataFactory.getRecordType('New Service Case','Case'));
            caselistnew.add(cs);
            insert caselistnew;
            /* Case Creation END */

            /* Opportunity Creation Start */
            List<Opportunity> oppList = TestDataFactory.createOpportunity(1,'TestOpportunityTest',caselistnew[0].Id,caselistnew[0].Case_Sub_Type__c, accList[0].Id);
            oppList[0].Duration__c='Temporary';
            Database.insert(oppList);
            /* Opportunity Creation END */

            /* Quote creation start */
            SBQQ__Quote__c draftQuote = new SBQQ__Quote__c();
            draftQuote.SBQQ__Account__c = locationList[0].id;
            draftQuote.SBQQ__Status__c = 'Draft';
            draftQuote.Duration__c = 'Temporary';
            draftQuote.SBQQ__StartDate__c = system.today();
            draftQuote.SBQQ__Opportunity2__c = oppList[0].Id;
            insert draftQuote;


            List<SBQQ__QuoteLine__c> parentQls = new List<SBQQ__QuoteLine__c>();
          SBQQ__QuoteLine__c parentQl= TestDataFactory.createQuoteLineRecords(draftQuote,openTopContainer,'TEMP',1.00,'CLT','YRDS-20','OC','D','1','PER',34.00,'DYS','PER',56.00,'DYS','Do Not Override','NBG');
          parentQl.LocationPositionName__c='Test Location';
          //parentQl.Location_Position_Name__c= accPosition.id;
          parentQl.SBQQ__StartDate__c= Date.today();
		  parentQl.SBQQ__EndDate__c= Date.today().addDays(25);
          parentQl.SBQQ__RequiredBy__c= null;
          parentQl.SBQQ__Number__c=0;
          //parentQl.Account__c = locationList[0].id;
          parentQl.MASLibrary__c = 'ARDTA.129A';
          parentQl.Duration__c = 'TEMP';
          parentQls.add(parentQl);
          insert parentQls;
            /* Quote creation END */
        }

        
    }


    @isTest
    public static void testcreateQuoteOrder(){
        List<Case> testCases = [select Id, Equipment_Type_Code__c, Case_Sub_Type__c, Material_Type__c, Equipment_Size_Code__c, Service_Occurrence_Type_Code__c,
                                SalesMeet_Quantity__c, Delivery_Date__c,Removal_Date__c, Company_Category__c, Quote_Only__c, Site_Contact__c,//CompanyCategoryCode__c,
                                Site_Contact_Phone__c, Offsite_Street_Address__c, Offsite_City__c, Offsite_State__c, 
                                Service_Date__c, Case_Reason__c, Reference_Number__c, Tracking_Number__c, Integrate_with_Acorn__c,
                                Case_Type__c, Case_Record_Type__c,PurchaseOrder_Number__c ,SalesMeet_Container_Position__c,Empty_and_Return_Date__c,
                                Offsite_Postal_Code__c from case where Case_Type__c = 'New Service'];
        List<SBQQ__Quote__c> quote = [select id from sbqq__Quote__c where SBQQ__Status__c ='Draft'];


        List<SBQQ__QuoteLine__c> qlList = [select id,SBQQ__Product__r.Name from SBQQ__Quoteline__c];
        // Map<String, SObject> caseDataMap = new Map<String, SObject>();
        // for (Case c : testCases) {
        //     caseDataMap.put(c.Id, c);
        // }
        // for(SBQQ__Quote__c q : quote){
        //     system.debug('Quote Id '+q.Id);
        //     caseDataMap.put(q.Id, q);
        // }
        Test.startTest();
        IVRUtility.createQuoteOrder(quote[0].id,qlList[0].id,testCases[0],qlList);
        Test.stopTest();
        
    }
    
        @isTest
    public static void testtaskandGenesysRouting(){
        List<Case> testCases = [select Id, Equipment_Type_Code__c, Case_Sub_Type__c, Material_Type__c, Equipment_Size_Code__c, Service_Occurrence_Type_Code__c,
                                SalesMeet_Quantity__c, Delivery_Date__c,Removal_Date__c, Company_Category__c, Quote_Only__c, Site_Contact__c,//CompanyCategoryCode__c,
                                Site_Contact_Phone__c, Offsite_Street_Address__c, Offsite_City__c, Offsite_State__c, 
                                Service_Date__c, Case_Reason__c, Reference_Number__c, Tracking_Number__c, Integrate_with_Acorn__c,
                                Case_Type__c, Case_Record_Type__c,PurchaseOrder_Number__c ,SalesMeet_Container_Position__c,Empty_and_Return_Date__c,
                                Offsite_Postal_Code__c from case where Case_Type__c = 'New Service'];

        Test.startTest();
        IVRUtility.taskandGenesysRouting(testCases,'TestClass','Exception testing from test class');
        Test.stopTest();
        
    }
    
            @isTest
    public static void testcreateAvailablity(){
		List<SBQQ__QuoteLine__c> qlList = [select id,SBQQ__Product__r.Name from SBQQ__Quoteline__c];
		
        Test.startTest();
        IVRUtility.createAvailablity(qlList[0].id);
        Test.stopTest();
        
    }
    
    
    


}