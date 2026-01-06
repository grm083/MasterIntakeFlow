/* 
* Apex Class : AcornWODetailsCtrlTest
* Description : This class is used for AcornWODetailsController
* Developer : Arvind Kumar
* Date : 01/July/2021
*/
@isTest(seeAllData=false)
public class AcornWODetailsCtrlTest {
    @testSetup static void setup()  {
        
        //Changes for SDT-39632
        CodeSwitchTestData.CodeSwitchData();

        Account acc1 = new Account(Name = 'Test');
        insert acc1;
        
        Account acc2 = new Account(Name = 'Test2', ParentId = acc1.Id);
        insert acc2;
        
        Id cseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('New Service Case').getRecordTypeId();
        
        Case cse = new Case(Accountid = acc2.id,Case_Sub_Type__c = 'Permanent',Case_Reason__c = 'Existing Location',Case_Type__c = 'New Service',recordtypeId = cseRecordTypeId);
        insert cse;
        
        Product2 prod = new Product2(Name = 'Extra Pickup');
        insert prod;
        
        Product2 prod2 = new Product2(Name = 'Pickup');
        insert prod2;
        Opportunity opp = new Opportunity(Name = 'Test Opp',Case__c = cse.Id,StageName = 'Proposal',CloseDate = system.today());
        insert opp;
        
        Business_Rule__c businessrule = new Business_Rule__c(Accountid__c = acc1.id, 
                                                             Container__c = 'Equipment', Service__c = 'Permanent', 
                                                             Request_Type__c = 'New Service', Schedule_Type__c = 'Permanent',
                                                             Active__c = true,Effective_Date__c = System.today() - 1,
                                                             Channel_Req__c= 'Test Channel Requirements',Channel__c = 'WM Portal',
                                                             RecordTypeid = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get('Approval').getRecordTypeId() );
        insert businessrule;       
        
        //Quote Creation
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.SBQQ__Account__c = acc2.Id;
        quote.SBQQ__Status__c = 'Draft';
        quote.SBQQ__Opportunity2__c = opp.Id;
        quote.SBQQ__StartDate__c = system.today();
        quote.Business_Rule__c = businessrule.Id;
      
        insert quote;
        
        //QuoteLine Creation
        SBQQ__QuoteLine__c ql = new SBQQ__QuoteLine__c();
        ql.SBQQ__Quote__c =  quote.Id;
        ql.SBQQ__Product__c = prod2.Id;
        ql.Equipment_Size__c = 'GALS-40';
        insert ql;
        
        SBQQ__QuoteLine__c ql1 = new SBQQ__QuoteLine__c();
        ql1.SBQQ__Quote__c =  quote.Id;
        ql1.SBQQ__Product__c = prod.Id;
        ql1.Equipment_Size__c = 'GALS-40';
        
        insert ql1;
          
        Service_Approver__c serviceApprover = new Service_Approver__c(Business_Rule__c = businessrule.id, Account__c = businessrule.Accountid__c,
                                                                      Email__c = 'sbhatia@wm.com' ,Active__c = true,
                                                                      Recordtypeid = Schema.SObjectType.Service_Approver__c.getRecordTypeInfosByName().get('Email').getRecordTypeId());
        
        insert serviceApprover;   
        
        
    } 
    
    @isTest static void updateWODetailsTest(){
        Test.startTest();
        List<SBQQ__Quote__c> quoteList = [Select Id, Acorn_Work_Order_Details__c from SBQQ__Quote__c];
        quoteList[0].Acorn_Work_Order_Details__c = 'Test String';
        update quoteList[0];
        AcornWODetailsController.getWorkOrderDetails(quoteList[0].Id);
        system.assertEquals('Test String', quoteList[0].Acorn_Work_Order_Details__c);
        Test.stopTest();
        
    }

}