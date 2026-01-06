/*************************************************************
@Name: QuoteCreationHandlerTest
@Author: TCS (Abhishek Patel)
@CreateDate: 08/11/24
@Description: Test class for the QuoteCreationHandler class
**************************************************************/
@IsTest
public class QuoteCreationHandlerTest {
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
        insert usr; // insert user for the System Administrator
        List<Account> accList;
        List<Account> locationList;
        List<Contact> conList;
        List<Case> caseList;
        
        System.runAs(usr){
            Id pricebookId = Test.getStandardPricebookId();
                       
            //Changes for SDT-39632
            CodeSwitchTestData.CodeSwitchData();
            
            list<product2> productlist = TestDataFactory.createProduct(Constant_Util.KEYWORD_TEST);
            productlist[0].ProductTypeSelected__c = COMPACTOR;
            productlist[0].Family = COMMERCIAL;
            
            Product2 container = new Product2(Name = 'Open Top', Family = 'Equipment', ProductCode = 'OT');
            Product2 haulService = new Product2(Name = 'Haul', Family = 'Services', SBQQ__Component__c = TRUE, ProductCode = 'H');
            Product2 deliveryService = new Product2(Name = 'Delivery', Family = 'Services', SBQQ__Component__c = TRUE, ProductCode = 'DLV');
            Product2 trashCategory = new Product2(Name = 'Trash', Family = 'Waste Category', SBQQ__Component__c = TRUE, ProductCode = 'TRASH');
            Product2 trashStream = new Product2(Name = 'Trash', Family = 'Waste Stream', SBQQ__Component__c = TRUE, ProductCode = 'T');
            productlist.add(container);
            productlist.add(haulService);
            productlist.add(deliveryService);
            productlist.add(trashCategory);
            productlist.add(trashStream);
            insert productlist;
            
            List<PricebookEntry> standardPriceList = new List<PricebookEntry>();// Modified for SDT-33453
            PricebookEntry standardPrice = new PricebookEntry(
                Pricebook2Id = pricebookId, Product2Id = productlist[0].Id,
                UnitPrice = 10000, IsActive = true);
            standardPriceList.add(standardPrice);// Modified for SDT-33453
            Database.insert(standardPriceList);// Modified for SDT-33453
            
            List<Pricebook2> customPBList = new List<Pricebook2>();// Modified for SDT-33453
            Pricebook2 customPB = new Pricebook2(Name='Standard Price Book', isActive=true);
            customPBList.add(customPB);// Modified for SDT-33453
            Database.insert(customPBList);// Modified for SDT-33453
            
            List<PricebookEntry> customPriceList = new List<PricebookEntry>();// Modified for SDT-33453
            PricebookEntry customPrice = new PricebookEntry(
                Pricebook2Id = customPB.Id, Product2Id = productlist[0].Id,
                UnitPrice = 12000, IsActive = true);
            customPriceList.add(customPrice);// Modified for SDT-33453
            Database.insert(customPriceList);// Modified for SDT-33453
            accList= TestDataFactory.createAccount('TestParentAccountTest', usr,'Client');
            accList[0].AccountNumber = 'ParentTest';
            List<Account> accList12 = TestDataFactory.createAccount('TestVendorAccountTest', usr,'Vendor');
            accList12[0].Vendor_Business_Unit__c = '2860';
            accList.addAll(accList12);
            insert accList;
            // locationList= TestDataFactory.createLocation('TestLocationAccountTest', usr,accList[0].Id);
            Account location1 = new Account(
                Primary_Segment__c = null,
                ShippingStreet = 'ABC', 
                ShippingCity = 'Test1', 
                ShippingState = 'NY',
                ShippingPostalCode = '1234',
                Name = 'TestLocationAccountTest',
                AccountNumber = 'TestLocationAccountTest',
                Common_Name__c = 'TestLocationAccountTest',
                Phone = '9999999999',
                OwnerId = usr.Id,
                RecordTypeId = TestDataFactory.getRecordType('Location', 'Account'), 
                ParentId = accList[0].Id,  
                Status__c = 'ACTIVE'
            );
            locationList = new List<Account>{location1};
                locationList[0].AccountNumber = 'ChildTest';
            locationList[0].type = 'location';
            insert locationList;
            conList= TestDataFactory.createContact('TestContactTest', 'TestContactTest', accList[0], usr);
            conList[0].Email= 'testemail'+ String.valueof(system.now().millisecond())+'@testorg1.com.wm';
            conList[0].Phone= '1890870468';
            insert conList;    
        }
        
        Profile prfl = [SELECT Id FROM Profile WHERE Name = 'Customer Service'];
        User usrObj= TestDataFactory.createUser(prfl); 
        usrObj.FirstName = 'testUser#99997';
        usrObj.Bypass_Validation__c = TRUE;
        usrObj.Genesys_Enabled__c = FALSE;
        insert usrObj;
        
        List<PermissionSetLicense> pslList= [SELECT Id FROM PermissionSetLicense WHERE DeveloperName = 'SalesforceCPQ_CPQStandardPerm' AND Status='Active'];
        insert new PermissionSetLicenseAssign(AssigneeId = usrObj.Id, PermissionSetLicenseId= pslList[0].Id);
        List<PermissionSet> psgList= [SELECT Id FROM PermissionSet WHERE Name = 'QuoteOrdersUser'];
        insert new PermissionSetAssignment(AssigneeId = usrObj.Id, PermissionSetId = psgList[0].id);
        
        System.runAs(usrObj){
            list<Case> caselistnew = new list<Case>(); 
            Case cs = new Case(Comments = 'API Case Creation test',Status ='Draft', Delivery_Date__c = System.Today(), Priority = 'Medium', Origin = 'IVR Phone', ContactId = conList[0].id, 
                               AccountId =  locationList[0].Id, OwnerId = usr.id, Client__c =  accList[0].Id, Location__c =  locationList[0].id, 
                               Case_Type__c = 'New Service', Case_Sub_Type__c = 'Temporary', Case_Reason__c = 'Clean Up Internal',
                               SlaStartDate = system.today(),Recordtypeid = TestDataFactory.getRecordType('New Service Case','Case'));
            caselistnew.add(cs);
            insert caselistnew;
        }
        
        
    }
    
    @isTest
    public static void testQuoteCreationHandlerExecute(){
        List<Case> testCases = [select Id, Equipment_Type_Code__c, Case_Sub_Type__c, Material_Type__c, Equipment_Size_Code__c, Service_Occurrence_Type_Code__c,
                                SalesMeet_Quantity__c, Delivery_Date__c, Company_Category__c, Quote_Only__c, Site_Contact__c, 
                                Site_Contact_Phone__c, Offsite_Street_Address__c, Offsite_City__c, Offsite_State__c, 
                                Service_Date__c, Case_Reason__c, Reference_Number__c, Tracking_Number__c, Integrate_with_Acorn__c,
                                Case_Type__c, Case_Record_Type__c, 
                                Offsite_Postal_Code__c from case where Case_Type__c = 'New Service'];
        Map<String, SObject> caseDataMap = new Map<String, SObject>();
        for (Case c : testCases) {
            caseDataMap.put(c.Id, c);
        }
        System.debug('Abhishek -> caseDataMap ' + caseDataMap.values());
        Test.startTest();
        Map<String, SObject> resultMap = QuoteCreationHandler.execute(caseDataMap);
        //Id quoteId = GetCaseInformation.createOppQuote(testCases[0].Id);
        // System.debug('Abhishek -> resultmap ' + JSON.serialize(resultMap));
        // System.assertNotEquals(resultMap, null, 'Checking Null part');
        Test.stopTest();
        
    }
    
    @isTest
    public static void testQuoteCreationHandlerExecuteException(){
        List<Case> testCases = [select Id, Equipment_Type_Code__c, Case_Sub_Type__c, Material_Type__c, Equipment_Size_Code__c, Service_Occurrence_Type_Code__c,
                                SalesMeet_Quantity__c, Delivery_Date__c, Company_Category__c, Quote_Only__c, Site_Contact__c, 
                                Site_Contact_Phone__c, Offsite_Street_Address__c, Offsite_City__c, Offsite_State__c, Offsite_Postal_Code__c from case where Case_Type__c = 'New Service'];
        Map<String, SObject> caseDataMap = new Map<String, SObject>();
        List<case> case1 = new List<case>();
       	for (Case c : testCases) {
            c.Location__c = null;
            caseDataMap.put(c.Id, c);
            case1.add(c);
        }
        update case1;
		Test.startTest();
        Map<String, SObject> resultMap = QuoteCreationHandler.execute(caseDataMap);
		Test.stopTest();
    }    
}