@isTest(seeAllData = false)
public class Compactor_UtilityTest 
{
    /* Author : TCS
	 * Date: 6-Oct-2023
	 * Use of Class : This class will be ue as an Utility class for Compactor product related functional utility
    */
    
	// method for setting up data
    @testSetup
    static void createData() 
    {
        List<Product2> prodList= new List<Product2>();
        List<Account> accList;
		List<Account> locationList;
		List<Contact> conList;
		List<Case> caseList;
        List<Opportunity> oppList;
        Account_Position__c accPosition;
        List<SBQQ__Quote__c> quoteList= new List<SBQQ__Quote__c>();
        
        Profile p= TestDataFactory.getProfile('System Administrator');
		User usr= TestDataFactory.createUser(p);
		insert usr;
        
        System.runAs(usr)
        {
			Product2 productVerticalCompactor = TestDataFactory.createProduct('Compactor - Vertical','Equipment','VTC');
            productVerticalCompactor.Bypass_Acorn_Integration__c= false;
            productVerticalCompactor.Family= 'Commercial';
            
            Product2 productDelivery = TestDataFactory.createProduct('Delivery','Services','DLV');

			prodList.add(productVerticalCompactor);
            prodList.add(productDelivery);
            
			insert prodList;
        
            accList= TestDataFactory.createAccount('TestParentAccountTest', usr,'Client');
            accList[0].AccountNumber = 'ParentTest';
            List<Account> accList12 = TestDataFactory.createAccount('TestVendorAccountTest', usr,'Vendor');
            accList12[0].Vendor_Business_Unit__c = '2860';
            accList.addAll(accList12);
			insert accList;
			locationList= TestDataFactory.createLocation('TestLocationAccountTest', usr,accList[0].Id);
            locationList[0].AccountNumber = 'ChildTest';
            locationList[0].type = 'location';
			insert locationList;
            accPosition = new Account_Position__c();
            accPosition.AccountId__c = locationList[0].Id;
            accPosition.Container_Position__c = 'TestingPosition1';
            insert accPosition;
			conList= TestDataFactory.createContact('TestContactTest', 'TestContactTest', accList[0], usr);
			conList[0].Email= 'testemail'+ String.valueof(system.now().millisecond())+'@testorg1.com.wm';
			conList[0].Phone= '1890870468';
			insert conList;
            
            caseList= new List<Case>();
            oppList= new List<Opportunity>();
            caseList.add(TestDataFactory.newServiceCase('TestSiteTest'+1, accList[0], conList[0], usr, locationList[0]));
            caseList[0].Service_Date__c= System.today();
            insert caseList;
            oppList= TestDataFactory.createOpportunity(1,'TestOpportunityTest', caseList[0].Id, caseList[0].Case_Sub_Type__c, locationList[0].Id);
            oppList[0].Duration__c='Temporary';
            insert oppList;
            quoteList= TestDataFactory.createQuoteRecords(1,oppList,locationList[0],conList[0],Date.today(),false,false);
            quoteList[0].SBQQ__Status__c='Draft';
            insert quoteList;
        }
    }
    
    @isTest static void testretrieveCompactorVerticalEquivalentProduct() 
    {
		Product2 productVTC = [SELECT Id FROM Product2 WHERE Name = 'Compactor - Vertical' LIMIT 1];
        SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        SBQQ__QuoteLine__c testQuoteLine = new SBQQ__QuoteLine__c();
        testQuoteLine.SBQQ__Product__c = productVTC.Id;
       	testQuoteLine.SBQQ__Quote__c = quote.Id;
		INSERT testQuoteLine;
        test.startTest();
        SBQQ__QuoteLine__c testQuoteLine1 = [SELECT Id, SBQQ__Product__c, SBQQ__Product__r.Name FROM SBQQ__QuoteLine__c LIMIT 1];
        String productName = Compactor_Utility.retrieveCompactorVerticalEquivalentProduct(testQuoteLine1);
        System.assertEquals(productName, Pricing_Constant_Util.VERTICAL_COMPACTOR);
        test.stopTest();
    }
}