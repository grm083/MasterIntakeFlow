/*
Author: Anup Dey
Story: SDT-20337
FC: Anmoal Bharti
Module: DT
Description: Test class to test the Close new service cases if Quote got exipred and if all quote of a related case if approved or declined then close that case.
---------------------------------------------------------------------------------------------------------------------
Story             Sprint             Coverage           Created By           Description
SDT-20337                            96 %         		Anup Dey          Test class for CloseNewServiceCaseBatch
*/
@isTest(seeAllData = false)
public class CloseNewServiceCaseBatchTest{

private static final string SYS_ADMIN = 'System Administrator';
private static final string ON_CALL = 'On-Call';
private static final string TRASH = 'Trash';
//private static Profile ADMIN_PROFILE = TestDataFactory.getProfile(SYS_ADMIN);
//private static User ADMIN_USER = TestDataFactory.createUser(ADMIN_PROFILE);
private static Integer BATCH_SIZE= 45; // Use batch size= 45 if 'Quote Status Change Flow' is active
    
  @testSetup
  static void setup(){
    
    List<Opportunity> oppList = new List<Opportunity>();
    List<SBQQ__Quote__c> quoteList= new List<SBQQ__Quote__c>();
    //List<SBQQ__QuoteLine__c> qlList= new List<SBQQ__QuoteLine__c>();
    List<Product2> prdList = new List<Product2>();    
    List<Case> caselist = new List<Case>();
	
    /*Profile ADMIN_PROFILE = TestDataFactory.getProfile(SYS_ADMIN);
    User ADMIN_USER = TestDataFactory.createUser(ADMIN_PROFILE);
    ADMIN_USER.Bypass_Validation__c = true;
    //setting up Genesys flag to false to by pass the Genesys flow
    ADMIN_USER.Genesys_Enabled__c = false;
    //insert ADMIN_USER; // Modified for SDT-33450
        Database.insert(ADMIN_USER);// Modified for SDT-33450 */ //Commented for SDT-33450 
        
        Boolean BypassValidation = true; //Modified for SDT-33450 
        Boolean GenesysEnabled = false; //Modified for SDT-33450
        User ADMIN_USER = TestDataFactory.getCSRUser(BypassValidation, GenesysEnabled); //Modified for SDT-33450 
	
    system.runAs(ADMIN_USER)
    {
        //Changes for SDT-39632
        CodeSwitchTestData.CodeSwitchData();
            
        List<Account> accParentList = new List<Account>(); //Modified for SDT-33450
        Account accParent = new Account(Name = 'Parent Account', phone = '9999999999', OwnerId = ADMIN_USER.id, AccountNumber='5678',
        RecordTypeid = TestDataFactory.getRecordType('Client','Account'), IsPricingEligible__c = true); 
        //insert accParent; //Commented for SDT-33450
            
            //Modified for SDT-33450 Start
            accParentList.add(accParent);
            Database.insert(accParentList);
            //Modified for SDT-33450 End

        Account acc = new Account(Name = Constant_Util.KEYWORD_TEST, phone = '9999999999', OwnerId = ADMIN_USER.id, AccountNumber='1234',
                    RecordTypeid = TestDataFactory.getRecordType('Client','Account'), IsPricingEligible__c = true, ParentId = accParent.Id);
        
        // Creating VR setting record
        TestDataFactory.CreateVRBatchSetting();
        
        List<Account> acclist = new List<Account>();
        acclist.add(acc);
        Database.insert(acclist);
        //System.debug('Create New Account : ' + acclist[0].Id + ' ' + acclist[0].IsPricingEligible__c);

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
newServiceCase.IsOpportunity_Created__c = true; //Commented for SDT-38462
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

    	//System.Debug('@@@~Create Opp : ' + oppList.size());

       
      // To Create new Quote 
    quoteList.addAll(TestDataFactory.createQuoteRecords(9,oppList,acclist[0],conlist[0],Date.today(),false,true));
    
   // 1st Quote with 'Draft' Status and future expiry date
   if(quoteList[0] != null)
    	quoteList[0].SBQQ__ExpirationDate__c = System.today() + 2;
   
   // 2nd Quote with 'Draft' Status with expiry date
   if(quoteList[1] != null) 
       quoteList[1].SBQQ__ExpirationDate__c = System.today() - 2;
   
   // 3rd> 1st Quote with 'Draft' Status and future expiry date
   if(quoteList[2] != null)
       quoteList[2].SBQQ__ExpirationDate__c = System.today() + 2;
   
   // 3rd> 2nd Quote with 'Approved' Status with expiry date
   if(quoteList[3] != null)
   {
      quoteList[3].SBQQ__Status__c = 'Approved';
      quoteList[3].SBQQ__Opportunity2__c = quoteList[2].SBQQ__Opportunity2__c;
      quoteList[3].SBQQ__ExpirationDate__c = System.today() -2;
   }
    
    // 4th > 1st Quote with 'Draft' Status with expiry date
   if(quoteList[4] != null) 
       quoteList[4].SBQQ__ExpirationDate__c = System.today() - 2;
    
     // 4th> 2nd Quote with 'Approved' Status with future expiry date
   if(quoteList[5] != null)
   {
      quoteList[5].SBQQ__Status__c = 'Approved';
      quoteList[5].SBQQ__Opportunity2__c = quoteList[4].SBQQ__Opportunity2__c;
      quoteList[5].SBQQ__ExpirationDate__c = System.today() + 2;
   }
        
    // 6th > 1st Quote with 'Draft' Status with future expiry date
   if(quoteList[6] != null) 
   {
       quoteList[6].SBQQ__Status__c = 'Approved';
       quoteList[6].SBQQ__ExpirationDate__c = System.today() + 2;
   }
        
   // 6th > 2nd Quote with 'Draft' Status with future expiry date
   if(quoteList[7] != null) 
   {
       quoteList[7].SBQQ__Status__c = 'Approved';
       quoteList[7].SBQQ__Opportunity2__c = quoteList[6].SBQQ__Opportunity2__c;
       quoteList[7].SBQQ__ExpirationDate__c = System.today() - 2;
   }
// Modified for SDT-33450 Start
            if(quoteList[8] != null) 
            {
                quoteList[8].SBQQ__Status__c = 'Submit for Approval';
                quoteList[8].SBQQ__ExpirationDate__c = System.today() - 1;
            }    
            // Modified for SDT-33450 End
    insert quoteList;
        
    //System.Debug('@@@~Create Quote : ' + quoteList.size());
    }
  }
  
  @isTest
  // method to execute CloseNewServiceCaseBatch
  static  void closeNewServiceCaseBatch(){
    user currentuser = [select id, Bypass_Validation__c from user where Bypass_Validation__c = true limit 1];
    Id batchId;
      System.runAs(currentuser){
	
        Test.startTest();
        CloseNewServiceCaseBatch objclosedbatch = new CloseNewServiceCaseBatch();
        batchId =Database.executeBatch(objclosedbatch,BATCH_SIZE);
        Test.stopTest();
      }

    /*Query the results*/
    System.AssertNotEquals(batchId,null,'batch executed');
  }
}