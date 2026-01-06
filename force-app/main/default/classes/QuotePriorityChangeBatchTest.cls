/*
Author: Anup Dey
Story: SDT-22548
Description: Update quotes priority based on Quote Start date
---------------------------------------------------------------------------------------------------------------------
Story             Sprint             Coverage           Created By           Description
SDT-22548                            95%         		Anup Dey          Test class for QuotePriorityChangeBatch
*/
@isTest(seeAllData = false)
public class QuotePriorityChangeBatchTest {
    private static final string SYS_ADMIN = 'System Administrator';
    private static Integer BATCHSIZE= 45;
    private static final string ON_CALL = 'On-Call';
    private static final string TRASH = 'Trash';

    @testSetup
    static void setup(){
        List<Opportunity> oppList = new List<Opportunity>();
        List<SBQQ__Quote__c> quoteList= new List<SBQQ__Quote__c>();
        List<Product2> prdList = new List<Product2>();    
        List<Case> caselist = new List<Case>();

        Profile ADMIN_PROFILE = TestDataFactory.getProfile(SYS_ADMIN);
        User ADMIN_USER = TestDataFactory.createUser(ADMIN_PROFILE);
        ADMIN_USER.Bypass_Validation__c = true;
        //setting up Genesys flag to false to by pass the Genesys flow
        ADMIN_USER.Genesys_Enabled__c = false;
        insert ADMIN_USER;
        
        //Changes for SDT-39632
        CodeSwitchTestData.CodeSwitchData();
        
        system.runAs(ADMIN_USER)
        {
            Account accParent = new Account(Name = 'Parent Account', phone = '9999999999', OwnerId = ADMIN_USER.id, AccountNumber='5678',
            RecordTypeid = TestDataFactory.getRecordType('Client','Account'), IsPricingEligible__c = true); 
            insert accParent;

            Account acc = new Account(Name = Constant_Util.KEYWORD_TEST, phone = '9999999999', OwnerId = ADMIN_USER.id, AccountNumber='1234',
                        RecordTypeid = TestDataFactory.getRecordType('Client','Account'), IsPricingEligible__c = true, ParentId = accParent.Id);
            
            // Creating VR setting record
            TestDataFactory.CreateVRBatchSetting();
            
            List<Account> acclist = new List<Account>();
            acclist.add(acc);
            Database.insert(acclist);
            System.debug('Create New Account : ' + acclist[0].Id + ' ' + acclist[0].IsPricingEligible__c);

            list<Account> locationlist = TestDataFactory.createLocation(Constant_Util.LOCATION, ADMIN_USER, acclist.get(0).id);
            locationlist[0].tz__Timezone_SFDC__c = 'America/Chicago';
            locationlist[0].IsPricingEligible__c = true;
            Database.insert(locationlist);

            Account vendorAcc = new Account(Name = 'Vendor Account', phone = '9999999999', OwnerId = ADMIN_USER.id, AccountNumber='4321',
            RecordTypeid = TestDataFactory.getRecordType('Vendor','Account'));
            list<Account> venAcclist = new list<Account>();
            venAcclist.add(vendorAcc);
            Database.insert(venAcclist);
            
            // To Create new Contact
            list<Contact> conlist = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST,Constant_Util.CONSTANT_LAST, acclist.get(0), ADMIN_USER);
            Database.insert(conlist);
            
            RecordType recordType= [SELECT Id FROM RecordType WHERE Name = 'New Service Case'];
            
            for( Integer i=0 ; i< 9 ; i++ ) {
            Case newServiceCase = TestDataFactory.newServiceCase(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0),ADMIN_USER,locationlist.get(0)); 
            newServiceCase.Service_Date__c = system.today() + 1;
            newServiceCase.SLA_Service_Date_Time__c = system.today() + 2;
            newServiceCase.Case_Type__c = 'New Service';
            newServiceCase.RecordTypeId = recordType.Id;  
            newServiceCase.Case_Sub_Type__c = 'Permanent';
            newServiceCase.Case_Reason__c = 'Existing Location';
            newServiceCase.LOB__c = 'Rolloff';
            newServiceCase.Status = 'Open';
            newServiceCase.Service_Occurrence_Type_Code__c = ON_CALL;
            newServiceCase.Material_Type__c = TRASH;
            caselist.add(newServiceCase);
            }
            
            // To Create new Case
            Database.insert(caselist);
            
            for( Integer j=0 ; j<caselist.size() ; j++ )
            {
                oppList.addAll(TestDataFactory.createOpportunity(1,'TestOpportunityTest' + j,caselist[j].Id,caselist[j].Case_Sub_Type__c, caselist[j].Location__c));
            }
            // To Create new Opportunity
            insert oppList;

            System.Debug('@@@~Create Opp : ' + oppList.size());

        
            // To Create new Quote 
            quoteList.addAll(TestDataFactory.createQuoteRecords(9 ,oppList,acclist[0],conlist[0],Date.today(),false,true));
            system.debug('quoteList size'+ quoteList.size());
            // 1st Quote with 'Draft' status and current start date
            if(quoteList[0] != null)
            {
                quoteList[0].SBQQ__StartDate__c = System.today();
            }
            // 2nd Quote with 'Procure Service' Status with start date is next business day
            if(quoteList[1] != null) 
            {
                quoteList[1].SBQQ__Status__c = 'Product Configured';
                quoteList[1].SBQQ__StartDate__c = System.today()+1;
            }

            // 3rd Quote with 'Configure Price' Status and start date is today + 3
            if(quoteList[2] != null)
            {
                quoteList[2].SBQQ__Status__c = 'Cost Configured';
                quoteList[2].SBQQ__StartDate__c = System.today()+3;
            }
            
            // 4th Quote with 'Submit for Approval' Status and start date is today + 13
            if(quoteList[3] != null)
            {
                quoteList[3].SBQQ__Status__c = 'Price Configured';
                quoteList[3].SBQQ__StartDate__c = System.today()+13;
            }
            // 5th Quote with 'Declined' Status and start date is today + 13
            if(quoteList[4] != null)
            {
                quoteList[4].SBQQ__Status__c = 'Declined';
                quoteList[4].SBQQ__StartDate__c = System.today()+10;
            }

            // 6th Quote with 'Approved' Status and start date is today + 13
            if(quoteList[5] != null)
            {
                quoteList[5].SBQQ__Status__c = 'Approved';
                quoteList[5].SBQQ__StartDate__c = System.today()+5;
            }
            insert quoteList;
        
            System.Debug('@@@~Create Quote : ' + quoteList.size());
        }
    }

    @isTest
    // method to execute QuotePriorityChangeBatch
    static void QuotePriorityBatchTest() {
        user currentuser = [select id, Bypass_Validation__c from user where Bypass_Validation__c = true limit 1];
        Id batchId;
          System.runAs(currentuser){
        
            Test.startTest();
            QuotePriorityChangeBatch objquotePriority = new QuotePriorityChangeBatch();
            batchId =Database.executeBatch(objquotePriority,BATCHSIZE);
            Test.stopTest();
          }
    
        /*Query the results*/
        System.AssertNotEquals(batchId,null,'batch executed');
    }

    @isTest
    // method to execute QuotePriorityChangeBatch
    static void QuotePriorityWithTestIdsBatchTest() {
        user currentuser = [select id, Bypass_Validation__c from user where Bypass_Validation__c = true limit 1];
        SBQQ__Quote__c quote = [SELECT Id, RecordType.Name, SBQQ__Status__c, SBQQ__StartDate__c, Priority__c from SBQQ__Quote__c limit 1];
        
        Id batchId;
          System.runAs(currentuser){
        
            Test.startTest();
            QuotePriorityChangeBatch objquotePriority = new QuotePriorityChangeBatch();
            Set<Id> ids = new Set<Id>();
            ids.add(quote.Id);
            objquotePriority.testIds =ids;
            batchId =Database.executeBatch(objquotePriority,BATCHSIZE);
            Test.stopTest();
          }
    
        /*Query the results*/
        System.AssertNotEquals(batchId,null,'batch executed');
    }
}