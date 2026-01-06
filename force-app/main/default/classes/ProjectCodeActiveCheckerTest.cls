/*************************************************************
@Name: ProjectCodeActiveCheckerTest
@Author: Satyabrata
@CreateDate: 31/07/2019
@Description: Test class of ProjectCodeActiveChecker
**************************************************************/

@isTest(seeAllData=false)
public class ProjectCodeActiveCheckerTest {
	
    private static final string KROGER = 'kroger';
    private static final string ASSET_NAME = '8 yrd Dumpster';
	private static final string RITA = 'Rita';
    private static final string REPLY = 'Reply';
    private static final string COMPACTOR = 'COMPACTOR';
    private static final string COMMERCIAL = 'Commercial';
    private static final string PRODUCT = '8 yrd';
    private static final string TESTSUPPLIER = 'testsupplier';
    private static final string SUPPLIER = 'Vendor';
	public static final String LOCATION ='Location'; 
	public static final String CLIENT ='Client';
    
       
    @testSetup static void setup() {
        Profile p = TestDataFactory.getProfile('System Administrator');
        User usr = TestDataFactory.createUser(p);
        Database.insert(usr);
        
        system.runAs(usr){
			List<Account> accList = TestDataFactory.createAccount(KROGER, usr,CLIENT);
            Database.insert(accList);
			List<Account> locationList = TestDataFactory.createLocation(LOCATION, usr, accList.get(0).id);
            Database.insert(locationList);
            List<Contact> conlist = TestDataFactory.createContact(RITA,REPLY, acclist.get(0), usr);
            Database.insert(conlist);
			List<Account> supplieracclist = TestDataFactory.createAccount(TESTSUPPLIER , usr, SUPPLIER);
            Database.insert(supplieracclist);
            List<product2> productlist = TestDataFactory.createProduct(PRODUCT);
            productlist[0].Family = COMMERCIAL;
			productlist[0].ProductTypeSelected__c = COMPACTOR;
            Database.insert(productlist);
            List<Asset> assetlist = TestDataFactory.createAsset(ASSET_NAME , acclist.get(0), conlist.get(0), 
                                                                productlist.get(0), usr, locationlist.get(0));
			assetlist[0].active__c=true;
            System.debug(Date.today().addDays(-1));
            assetlist[0].End_Date_Based_on_Project_code__c=Date.today().addDays(-1);
			Database.insert(assetlist);
        }
    }
    
	@isTest static void testProjectCodeActiveCheckScheduler() {
        //test class errors - SDT - 33363
        List<user> currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name ='System Administrator' limit 1];
       
        system.runAs(currentuser.get(0)){
            Database.BatchableContext dbc;
            Date datecheck = Date.today().addDays(-1);
            System.assertEquals(1,[Select COUNT(Id) from Asset where Active__c=true and End_Date_Based_on_Project_code__c=:datecheck].SIZE());
	    String cronexp = '0 0 0 24 5 ? *';
            Test.startTest();
            	ProjectCodeActiveChecker b = new ProjectCodeActiveChecker();
            	System.schedule('Test Scheduled Job', cronExp, b);
            	b.execute(dbc,[select Id,Project_Code__c,Active__c,End_Date_Based_on_Project_code__c from Asset]);
			Test.stopTest();
            List<AsyncApexJob> jobsScheduled = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'ScheduledApex'];
    		System.assertEquals(1, jobsScheduled.size(), 'scheduled job');
    		System.assertEquals('ProjectCodeActiveChecker', jobsScheduled[0].ApexClass.Name, 'scheduled job found');
            }
    }
    
}