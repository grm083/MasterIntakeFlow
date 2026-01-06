@isTest(seeAllData = false)
public class QuoteActionsControllerTest {
    private static final string SYS_ADMIN = 'System Administrator';
    private static final String ACC_NUMBER = '1236';
    private static final string PHONE_NINE = '9999999999';
    private static final string NAISC_31 = '31';
    private static final string STR_STATUS = 'Active';
    private static final string STR_PHONE_ONE = '1111111111';
    private static final string STR_ACCOUNT_NUMBER = 'Location';
    private static final string STR_COUNTRY_US = 'United States';
    private static final string STR_POSTAL_CODE = '01234';
    private static final string STR_STATE = 'Florida';
    private static final string STR_CITY = 'Test City';
    private static final string STR_STREET = 'Test Street';
    @testSetup static void setup(){
        Profile prof = TestDataFactory.getProfile(SYS_ADMIN);
        User currentUser = TestDataFactory.createUser(prof);
        Database.insert(currentUser);
        
        //Changes for SDT-39632
        CodeSwitchTestData.CodeSwitchData();
        
        system.runAs(currentUser){
            List<Account> acclist = new List<Account>();
            Id recordTypeid = TestDataFactory.getRecordType('Client','Account');
            Account acclist1 = new Account(Name = Constant_Util.KEYWORD_TEST, phone = PHONE_NINE, OwnerId = currentUser.id,AccountNumber=ACC_NUMBER,
                                        RecordTypeid = recordTypeid, 
                                        IsPricingEligible__c = true, NAICS_Code__c = NAISC_31);
            acclist.Add(acclist1);
            
            Database.insert(acclist);
            
            list<Account> locationlist = TestDataFactory.createLocation(Constant_Util.LOCATION, currentUser, acclist1.Id);
            locationlist[0].Phone = STR_PHONE_ONE;
            locationlist[0].AccountNumber = STR_ACCOUNT_NUMBER;
            locationlist[0].Status__c = STR_STATUS;
            locationlist[0].ShippingCountry = STR_COUNTRY_US;
            locationlist[0].ShippingPostalCode = STR_POSTAL_CODE;
            locationlist[0].ShippingState = STR_STATE;
            locationlist[0].ShippingCity = STR_CITY;
            locationlist[0].ShippingStreet = STR_STREET;
            locationlist[0].ParentId = acclist1.id;
            Database.insert(locationlist);
            
            list<Contact> conlist = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST,Constant_Util.CONSTANT_LAST, acclist1, currentUser);
            Database.insert(conlist);
            Id caseRecordId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('New Service Case').getRecordTypeId();
            Case myCase = new Case(Site_Contact__c = 'xyz', Status ='New', Priority = 'Medium', Origin = 'Phone', ContactId = conlist[0].id, 
                            AccountId = acclist1.id, OwnerId = currentUser.id, Client__c = locationlist[0].ParentId, Location__c = locationlist[0].id, 
                            Case_Type__c = 'New Service', Case_Sub_Type__c = 'Temporary',Case_Reason__c = 'Baler Repair', 
                            SlaStartDate = System.today(), Recordtypeid = caseRecordId);
            Database.insert(myCase);
            Opportunity objOpp= new Opportunity(Name='ABSC',AccountId=acclist1.id,OwnerId=currentUser.id,StageName='Qualification',Probability=10,Amount=0.00,Case__c=myCase.id, CloseDate=System.today()+15);
            Database.insert(objOpp);
           	SBQQ__Quote__c objQuote= new SBQQ__Quote__c(SBQQ__Account__c=locationlist[0].Id,SBQQ__PrimaryContact__c=conlist[0].Id, SBQQ__Opportunity2__c=objOpp.id, SBQQ__Status__c='Draft', SBQQ__StartDate__c=System.today());
            Database.insert(objQuote);
        }
    }
	public static testmethod void quoteActionsCtrlrMethod(){
        Case c= [Select Id From Case LIMIT 1];
        List<SBQQ__Quote__c> listQuote= [Select id From SBQQ__Quote__c LIMIT 10];
        Test.startTest();
        SBQQ__Quote__c q = QuoteActionsController.getQuote(listQuote[0].id);
        String str1 = QuoteActionsController.goToCase(listQuote[0].id);
        Test.stopTest();
        System.assertEquals(listQuote.size(), 1);
        System.assertEquals(str1, c.id);
    }
}