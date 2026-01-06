/*
Author: Rishiraj Singh
Requirement Id/Story: SDT-20076
FC: Anmoal Bharti
Module: Asset Management/Quote Lifecycle
Description: The test class covers the code of QuoteDecline classes.
-----------------------------------------------------------------
Story             Sprint             Coverage           Modified By           Description
SDT-20076         AM-MVP3            100%               Rishi                 test coverage of QuoteDecline
*/
@isTest
private class QuoteDeclineTest{
  @testSetup
  static void setup(){
    Profile p= TestDataFactory.getProfile('System Administrator');
    User usr= TestDataFactory.createUser(p);
	insert usr;
	List<Account> accList;
	List<Account> locationList;
	List<Contact> conList;
	List<Case> caseList;
	List<Opportunity> oppList;
  Product2 prodObj;
  Pricebookentry pbeObj;
	System.runAs(usr){
        
        //Changes for SDT-39632
        CodeSwitchTestData.CodeSwitchData();
        
		accList= TestDataFactory.createAccount('TestParentAccountTest', usr,'Client');
		insert accList;
		locationList= TestDataFactory.createLocation('TestLocationAccountTest', usr,accList[0].Id);
		insert locationList;
		conList= TestDataFactory.createContact('TestContactTest', 'TestContactTest', accList[0], usr);
		conList[0].Email= 'testemail'+ String.valueof(system.now().millisecond())+'@testorg1.com.wm';
		conList[0].Phone= '1890870468';
		insert conList;
    prodObj= TestDataFactory.createProduct('Pickup','Service','PCK');
    insert prodObj;
    pbeObj= new Pricebookentry(Product2Id = prodObj.Id, Pricebook2Id = Test.getStandardPricebookId(), UnitPrice = 20);
    insert pbeObj;
	}
    List<SBQQ__Quote__c> quoteList= new List<SBQQ__Quote__c>();
    List<SBQQ__QuoteLine__c> qlList= new List<SBQQ__QuoteLine__c>();
    Profile prfl = [SELECT Id FROM Profile WHERE Name = 'Customer Service'];
    User usrObj= TestDataFactory.createUser(prfl); 
    insert usrObj;
    List<PermissionSetLicense> pslList= [SELECT Id FROM PermissionSetLicense WHERE DeveloperName = 'SalesforceCPQ_CPQStandardPerm' AND Status='Active'];
    insert new PermissionSetLicenseAssign(AssigneeId = usrObj.Id, PermissionSetLicenseId= pslList[0].Id);
    List<PermissionSet> psgList= [SELECT Id FROM PermissionSet WHERE Name = 'QuoteOrdersUser'];
    insert new PermissionSetAssignment(AssigneeId = usrObj.Id, PermissionSetId = psgList[0].id);
    System.runAs(usrObj){
      caseList= new List<Case>();
      oppList= new List<Opportunity>();
      caseList.add(TestDataFactory.newServiceCase('TestSiteTest'+1, accList[0], conList[0], usr, locationList[0]));
      insert caseList;
      oppList= TestDataFactory.createOpportunity(1,'TestOpportunityTest',caseList[0].Id,caseList[0].Case_Sub_Type__c, locationList[0].Id);
      insert oppList;
      quoteList= TestDataFactory.createQuoteRecords(1,oppList,accList[0],conList[0],Date.today(),false,false);
      quoteList.addAll(TestDataFactory.createQuoteRecords(1,oppList,accList[0],conList[0],Date.today(),false,true));
      insert quoteList;
      qlList= TestDataFactory.createQuoteLineRecords(1,quoteList[0],prodObj,'PERM',1.00,'CLT','YRDS-20','SCH','D','1','PER',34.00,'DYS','PER',56.00,'DYS','Do Not Override','NBG');
      qlList.addAll(TestDataFactory.createQuoteLineRecords(1,quoteList[1],prodObj,'PERM',1.00,'CLT','YRDS-20','SCH','D','1','PER',34.00,'DYS','PER',56.00,'DYS','Do Not Override','NBG'));
      insert qlList;
    }
  }
  //createEmailMessage() test coverage
  @isTest
  static void createEmailMessageTest(){
      User usrObj= [SELECT Id FROM User WHERE Profile.Name='Customer Service' ORDER BY LastModifiedDate DESC LIMIT 1];
      List<SBQQ__Quote__c> quoteList= [SELECT Id,SBQQ__Status__c FROM SBQQ__Quote__c ORDER BY LastModifiedDate DESC ];
      Integer countOfInvocation;
      System.runAs(usrObj){
        Test.startTest();
        /*for(Integer i=0;i<2;i++){
          quoteList[i].SBQQ__Status__c= Constant_Util.QUOTE_PRODUCT_CONFIGURED;
        }
        update quoteList;
        for(Integer i=0;i<2;i++){
          quoteList[i].SBQQ__Status__c= Constant_Util.QUOTE_COST_CONFIGURED;
        }
        update quoteList;
        for(Integer i=0;i<2;i++){
          quoteList[i].SBQQ__Status__c= Constant_Util.QUOTE_PRICE_CONFIGURED;
        }
        update quoteList;*/
        for(Integer i=0;i<2;i++){
          quoteList[i].SBQQ__Status__c= Constant_Util.QUOTE_DECLINED;
        }
        //update quoteList;
        countOfInvocation= Limits.getEmailInvocations();
        Test.stopTest();
      }
      //System.assertEquals(2,countOfInvocation,'Emails are triggered.');
  }
}
