@isTest(seeAllData = false)
public class GetDeclinedApproverLogDataTest 
{
    private static final string SYS_ADMIN = 'System Administrator';    
    
    @testSetup static void setup() {
        Profile adminProfile = TestDataFactory.getProfile(SYS_ADMIN);
        User usr = TestDataFactory.createUser(adminProfile);
        Database.insert(usr);  
        system.runAs(usr){
            //Changes for SDT-39632
            CodeSwitchTestData.CodeSwitchData();
            
            list<Account> acclist = TestDataFactory.createAccount(Constant_Util.KEYWORD_TEST, usr);
            Database.insert(acclist);
            list<Account> locationlist = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, acclist.get(0).id);
            locationlist[0].tz__Timezone_SFDC__c = 'America/Chicago';
            Database.insert(locationlist);
            list<Contact> conlist = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST,Constant_Util.CONSTANT_LAST, acclist.get(0), usr);
            Database.insert(conlist);
            
            //Inserting Case
            Case newServiceCase = TestDataFactory.newServiceCase(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0),usr,locationlist.get(0)); 
            newServiceCase.Service_Date__c = system.today() + 1;
            newServiceCase.SLA_Service_Date_Time__c = system.today() + 2;
            Database.insert(newServiceCase);
           
            // Inserting opportunity based on Case. 
            Opportunity opportunity = new Opportunity();
            opportunity.AccountId = newServiceCase.Location__c;
			opportunity.Name = '04425266';
           	opportunity.AccountId = newServiceCase.Location__c;
			opportunity.StageName = Constant_Util.PRODUCT_CONFIGURATION;
			opportunity.CloseDate = date.today() + 4;
			opportunity.Case__c = newServiceCase.Id;
			Database.insert(opportunity);
            
            //Inserting Quote based on Case and opportunity 
            SBQQ__Quote__c q = new SBQQ__Quote__c();
        	q.SBQQ__Opportunity2__c = opportunity.Id;
        	q.SBQQ__Account__c = newServiceCase.Location__c;
        	q.SBQQ__Primary__c = true;
            q.SBQQ__ExpirationDate__c = date.today() + 30;
       		q.SBQQ__StartDate__c = newServiceCase.Service_Date__c;
       		q.SBQQ__PrimaryContact__c = newServiceCase.ContactId;
            Database.insert(q);
            
            //Inserting product  for Open-Top
            list<product2> productlist = TestDataFactory.createCPQProduct(Constant_Util.KEYWORD_TEST);
			Database.insert(productlist);
                       
            //Inserting product feature ---
            SBQQ__ProductFeature__c featureOne = new SBQQ__ProductFeature__c();
            featureOne.Name = 'Waste Stream';
           	featureOne.SBQQ__MinOptionCount__c = 1;
			featureOne.SBQQ__MaxOptionCount__c = 1;
			featureOne.SBQQ__Number__c = 10;
			featureOne.SBQQ__ConfiguredSKU__c = productlist[0].id;
			featureOne.SBQQ__Category__c = 'Waste Stream';
			Database.insert(featureOne);
            
            //Inserting second product ---
            Product2 trash = new Product2();
			trash.Name = 'Trash';
			trash.ProductCode = 'T';
			trash.Family = 'Waste Stream';
			trash.IsActive = true;
            trash.SBQQ__ExcludeFromOpportunity__c = true;
			Database.insert(trash);
            
            //Inserting product  for Open-Top
            list<SBQQ__QuoteLine__c> line = TestDataFactory.createBundle(trash.id, q.Id, productlist[0].Id);
			Database.insert(line);
            
            list<SBQQ__QuoteLine__c> line1 = TestDataFactory.createBundle(productlist[0].Id, q.Id, trash.id);
            line1[0].SBQQ__RequiredBy__c = line[0].Id;
			Database.insert(line1);
                        
			//inserting Product Option --
			SBQQ__ProductOption__c option = new SBQQ__ProductOption__c();
			option.SBQQ__Number__c = 1;
			option.SBQQ__ConfiguredSKU__c = productlist[0].id;
			option.SBQQ__Quantity__c = 1;
			option.SBQQ__OptionalSKU__c = trash.id;
			option.SBQQ__Feature__c = featureOne.id;
			option.SBQQ__Bundled__c = true;
			Database.insert(option);
            
            //Inserting Approval Log
            Approval_log__c approvalLog = new Approval_log__c();
            approvalLog.CaseId__c = newServiceCase.Id;
            //approvalLog.BusinessRuleId__c = businesRuleID; 
            approvalLog.Approval_Description__c = 'Test Decline Status Log';
            approvalLog.Actual_Approver_Contact__c = conlist.get(0).Id;
            approvalLog.Actual_Approver__c = usr.Id;
            approvalLog.Quote__c = q.Id;
            approvalLog.Status__c = 'Declined';
            approvalLog.Approval_Comments__c = 'Test Decline Status Log';
            approvalLog.Decision_Date_Time__c = DateTime.now();
            Database.insert(approvalLog);
		} 
    }
    
    @isTest static void GetDeclinedApproverLogDataTest() 
    {
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
 
        system.runAs(currentuser){
        SBQQ__Quote__c quoteData = new SBQQ__Quote__c();
        quoteData = [SELECT Id FROM SBQQ__Quote__c limit 1];
           
        Test.startTest();
        GetDeclinedApproverLogData gd =new GetDeclinedApproverLogData();
        gd.quoteId = quoteData;
        gd.getApprovalData();
        Test.stopTest();
        }
    }
}