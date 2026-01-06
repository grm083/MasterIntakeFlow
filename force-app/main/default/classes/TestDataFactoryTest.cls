/**
* @author Accenture
* @date 1/31/2019
* @description : Apex class TestDataFactoryTest 
**/

@isTest(SeeAllData=false)
public class TestDataFactoryTest {
    
    @isTest static void testData(){
        Profile p = TestDataFactory.getProfile('System Administrator');
        User usr = TestDataFactory.createUser(p);
        Database.insert(usr);
        
        system.runAs(usr){
            
            //Changes for SDT-39632
            CodeSwitchTestData.CodeSwitchData();
            
            list<Account> acclist = TestDataFactory.createAccount('test', usr);
            Database.insert(acclist);
            
            list<Account> acclist1 = TestDataFactory.createAccount('test', usr);
            Database.insert(acclist1);
            
            list<Account> acclist2 = TestDataFactory.createAccount('test', usr,'Client');
            Database.insert(acclist2);
            
            list<Account> locationlist = TestDataFactory.createLocation('Location', usr, acclist.get(0).id);
            Database.insert(locationlist);
            
            list<Contact> conlist = TestDataFactory.createContact('first', 'last', acclist.get(0), usr);
            Database.insert(conlist);
            
            list<Business_Rule__c> Businessrulelist = TestDataFactory.createBusinessRule('first', acclist.get(0), 
                                                                                         locationlist.get(0));
            Database.insert(Businessrulelist);
            
            
            
            list<Service_Approver__c> serviceApproverlist = TestDataFactory.createServiceApprover(Businessrulelist.get(0));
            Database.insert(serviceApproverlist);
            
            list<product2> productlist = TestDataFactory.createProduct('test');
            Database.insert(productlist);
            
            list<Asset> assetlist = TestDataFactory.createAsset('first', acclist.get(0), conlist.get(0), 
                                                                productlist.get(0), usr, locationlist.get(0));
            Database.insert(assetlist);
            //SDT-33637 - bulikify the case
            list<Case> casebulkify = new list<case>();
            
            list<Case> caselist = TestDataFactory.createCase('first', acclist.get(0), conlist.get(0), usr, 
                                                             locationlist.get(0), assetlist.get(0));
            //Database.insert(caselist);
            casebulkify.add(caselist[0]); //SDT-33637
            
            Case caseObj= TestDataFactory.newServiceCase('TestSiteTest', acclist.get(0), conlist.get(0), usr, locationlist.get(0));
            //insert caseObj;
             casebulkify.add(caseObj); //SDT-33637
            
            Case openCaseObj= TestDataFactory.newServiceCase('TestSiteTest', acclist.get(0), conlist.get(0), usr, locationlist.get(0));
            openCaseObj.Status = 'Open';
            //insert openCaseObj;
            casebulkify.add(openCaseObj); //SDT-33637
            insert casebulkify;
            
            list<Entitlement> entitlementlist = TestDataFactory.createEntitlement('test', locationlist.get(0));
            Database.insert(entitlementlist);
            
            list<Task> tasklist = TestDataFactory.createTask(caselist.get(0).id, usr);
            Database.insert(tasklist);
            
            list<Approval_Log__c> approvalLoglist = TestDataFactory.createApprovallog(caselist.get(0).id);
            Database.insert(approvalLoglist);
            
            
           
            
            
            List<Opportunity> oppList= TestDataFactory.createOpportunity(1,'TestOpportunityTest',caseObj.Id,caseObj.Case_Sub_Type__c, locationlist.get(0).Id);
			insert oppList;
            
            Product2 prodObj= TestDataFactory.createProduct('Pickup','Service','PCK');
            insert prodObj;
            
            Pricebookentry pbeObj= new Pricebookentry(Product2Id = prodObj.Id, Pricebook2Id = Test.getStandardPricebookId(), UnitPrice = 20);
    		insert pbeObj;
            
            List<SBQQ__Quote__c> quoteList = TestDataFactory.createQuoteRecords(1,oppList,acclist.get(0),conlist.get(0),Date.today(),false,false);
           	insert quoteList;
            
            List<SBQQ__QuoteLine__c> qlList= TestDataFactory.createQuoteLineRecords(1,quoteList[0],prodObj,'PERM',1.00,'CLT','YRDS-20','SCH','D','1','PER',34.00,'DYS','PER',56.00,'DYS','Do Not Override','NBG');
            insert qlList;

         

            Pricing_Request__c prObj = TestDataFactory.createPricingRequestRecord(openCaseObj, acclist[0], locationlist[0], 'Rolloff', 'PT', null, null, usr);
            insert prObj;
        }
    }
}