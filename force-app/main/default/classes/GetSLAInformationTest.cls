@isTest
public class GetSLAInformationTest {
    
    
     private static final String SYSTEM_ADMIN = 'System Administrator';
    private static final String TEST_NAME = 'Test';
    private static final String PICKUP = 'Pickup';
    private static final String EXTRA_PICKUP = 'Extra Pickup';
    private static final string COMMERCIAL = 'Commercial';
    private static final string SCHEDULED ='Scheduled';
    private static final string REPAIRS = 'Repairs';
    private static final string COMPACTOR = 'COMPACTOR';
    private static final string InActive_CORE = 'Inactive COMPACTOR';

       
     @testSetup static void setup() {
       Profile adminProfile = TestDataFactory.getProfile(SYSTEM_ADMIN);
        User usr = TestDataFactory.createUser(adminProfile);
        Database.insert(usr);  
        system.runAs(usr){
            list<Account> acclist = TestDataFactory.createAccount(Constant_Util.KEYWORD_TEST, usr);
            Database.insert(acclist);
            list<Account> locationlist = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, acclist.get(0).id);
            locationlist[0].tz__Timezone_SFDC__c = 'America/Chicago';
            Database.insert(locationlist);
            list<Contact> conlist = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST,Constant_Util.CONSTANT_LAST, acclist.get(0), usr);
            Database.insert(conlist);
            list<product2> productlist = TestDataFactory.createProduct(Constant_Util.KEYWORD_TEST);
            productlist[0].ProductTypeSelected__c = COMPACTOR;
            productlist[0].Family = COMMERCIAL;
            
            Database.insert(productlist);
            list<Asset> assetlist = TestDataFactory.createAsset(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                                productlist.get(0), usr, locationlist.get(0));
            assetlist[0].Supplier__c = acclist[1].Id;
            Database.insert(assetlist);
            list<Asset> assetlist1 = TestDataFactory.createAsset(InActive_CORE, acclist.get(0), conlist.get(0), 
                                                                productlist.get(0), usr, locationlist.get(0));
            assetlist1[0].Quantity__c = 1;
            assetlist1[0].Start_Date__c = System.today().addDays(-10);
            Database.insert(assetlist1);
            
            list<Asset>childassetlist = TestDataFactory.createChildAsset(Constant_Util.CONSTANT_FIRST);
            childassetlist[0].Supplier__c = acclist[1].Id;
            childassetlist[0].parentId = assetlist[0].Id;
            Database.insert(childassetlist);
            
             list<Case> caselist = TestDataFactory.createCase(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                             usr, locationlist.get(0), assetlist.get(0));
            List<Case> myCaseList = TestDataFactory.createNewCase();
            list<Case> caselistForSameSlaDate = TestDataFactory.createCase(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                                           usr, locationlist.get(0), assetlist.get(0));
            
            caselist[0].Status = Constant_Util.STATUS_NEW;
            caselist[0].SLA_Service_Date_Time__c = system.today() + 2;
            caselistForSameSlaDate[0].Service_Date__c = system.today() + 1;
            Database.insert(caselist);

        }}
    
    @isTest
    public static void TestMethod1()
    {
        List<DateTime> listDTTime;
        Test.startTest(); 
        Case c = [select Id, Status , location__r.tz__Timezone_SFDC__c,Close_Irrelevant_Case__c , Case_Close_Reason__c, Close_Pickup_Case__c from Case limit 1];
        //c.Location__r.tz__Timezone_SFDC__c = 'America/New_York';
        system.debug('casee----'+ c);

        GetSLAInformation.FlowInputsForSLA finput= new GetSLAInformation.FlowInputsForSLA();
       
        List<GetSLAInformation.FlowInputsForSLA> request= new  List<GetSLAInformation.FlowInputsForSLA>();
        finput.caseId = c.Id;
        
        request.add(finput);
         
    
  		listDTTime =  GetSLAInformation.getSLADateTime(request); 
        Test.StopTest();
        
        
    } 
    

}