/*************************************************************
@Name: GetToAddressTest
@Author: Ayushi
@CreateDate: 12/8/2019
@Description: Test class of GetToAddress
@UsedBy: 
**************************************************************/
@isTest
public class GetToAddressTest {

    /**
* @description set the test data
*/ 
    @testSetup static void setup(){
        Profile prf = TestDataFactory.getProfile(Constant_Util.SYSTEM_ADMINISTRATOR);
        User usr = TestDataFactory.createUser(prf);
        Database.insert(usr);
        
        system.runAs(usr){
            
            
            list<Account> acclist = TestDataFactory.createAccount(Constant_Util.KEYWORD_TEST, usr);
            Database.insert(acclist);
            list<Account> locationlist = TestDataFactory.createLocation('FAM002508', usr, acclist.get(0).id);
            Database.insert(locationlist);
            list<Account> locationlist2 = TestDataFactory.createLocation('FAM002509', usr, acclist.get(0).id);
            Database.insert(locationlist2);
            list<Contact> conlist = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST, 
                                                                  Constant_Util.CONSTANT_LAST, acclist.get(0), usr);
            Database.insert(conlist);
         
            //create product
            list<product2> productlist = TestDataFactory.createProduct(Constant_Util.KEYWORD_TEST);
            Database.insert(productlist);
            
            //create vendor
            list<Account> supplieracclist = TestDataFactory.createAccount('testsupplier', usr,'Vendor');
            Database.insert(supplieracclist);
            
            //create asset
            list<Asset> assetlist = TestDataFactory.createAsset(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                                productlist.get(0), usr, locationlist.get(0));
            assetlist[0].Supplier__c = supplieracclist.get(0).Id;
            Database.insert(assetlist);
            
            //create case
            list<Case> caselist = TestDataFactory.createCase(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                             usr, locationlist.get(0), assetlist.get(0));
            caselist.get(0).AccountId = acclist.get(0).id ;
            Database.insert(caselist.get(0)); 
            
            String Subject = Constant_Util.KEYWORD_TEST;
            String Body = Constant_Util.KEYWORD_TEST + ' lOCatioN # FAM002508';
            List<EmailMessage> lstEM = new List<EmailMessage>();
            lstEM = TestDataFactory.createEmailMessage(Subject, Body, caselist.get(0));
            Database.insert(lstEM);
            //create task
            list<Task> tasklist = TestDataFactory.createTask(caselist[0].id,usr);
            Database.insert(tasklist);  
        }
    }
    
    //Method to test split string   
    public static testMethod void testSplitString() {
        OrgWideEmailAddress org = new OrgWideEmailAddress();
        org =  [SELECT Id,Address,CreatedDate from OrgWideEmailAddress limit 1];
        Profile p = TestDataFactory.getProfile('System Administrator');
        User usr = TestDataFactory.createUser(p);
        Database.insert(usr);
        List<OrgWideEmailAddress> lstOrg = new List<OrgWideEmailAddress>();
        lstOrg = [SELECT Id,Address,CreatedDate from OrgWideEmailAddress order by CreatedDate];
        List<Case> lstCase = new List<Case>();
        lstCase = [Select Id from Case];
        
        system.runAs(usr){
            List<string> inputStrLst = new List<string>();
            String Subject = Constant_Util.KEYWORD_TEST + ' lOCatioN # FAM002508';
            String Body = Constant_Util.KEYWORD_TEST  ;
            List<EmailMessage> lstEM = new List<EmailMessage>();
            lstEM = TestDataFactory.createEmailMessage(Subject, Body, lstCase.get(0));
            lstEM[0].Toaddress = org.Address;
			 Test.startTest();
            Database.insert(lstEM);  
            	GetToAddress.getName(lstEM);
            Test.stopTest();
            
        }
    }
    
    //Method to test split string   
    public static testMethod void testgetToAddress() {
        Profile p = TestDataFactory.getProfile('System Administrator');
        User usr = TestDataFactory.createUser(p);
        Database.insert(usr);
        List<Case> lstCase = new List<Case>();
        lstCase = [Select Id from Case];
        OrgWideEmailAddress org = new OrgWideEmailAddress();
        org =  [SELECT Id,Address,CreatedDate from OrgWideEmailAddress limit 1];
        
        system.runAs(usr){
            List<string> inputStrLst = new List<string>();
            String Subject = Constant_Util.KEYWORD_TEST + ' lOCatioN # FAM002508';
            String Body = Constant_Util.KEYWORD_TEST  ;
            List<EmailMessage> lstEM = new List<EmailMessage>();
            lstEM = TestDataFactory.createEmailMessage(Subject, Body, lstCase.get(0));
            lstEM[0].ccAddress = org.Address;
			Test.startTest();
            Database.insert(lstEM); 
            
            	GetToAddress.getName(lstEM);
            Test.stopTest();
            
        }
    }
}