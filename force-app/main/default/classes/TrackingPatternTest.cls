/*************************************************************
@Name: TrackingPatternTest
@Author: Ganesh ram S
@CreateDate: 16/05/2019
@Description: Test class for TrackingPattern
**************************************************************/
@isTest(SeeAllData=false)
public class TrackingPatternTest {

     Public static String Location_ID1 = 'FAM002508';
     Public static String Location_ID2 = 'FAM002509';
     Public static String Account_Name = 'testsupplier';
     Public static String SUPPLIER = 'Vendor';
     private static final string SYS_ADMIN = 'System Administrator';
     
    /**
    * @description Method to set the test data
    */ 
    @testSetup static void setup() {
        Profile p = TestDataFactory.getProfile(Constant_Util.SYSTEM_ADMINISTRATOR);
        User usr = TestDataFactory.createUser(p);
        Database.insert(usr);
        
        system.runAs(usr){
            list<Account> acclist = TestDataFactory.createAccount(Constant_Util.KEYWORD_TEST, usr);
            Database.insert(acclist);
            list<Account> locationlist = TestDataFactory.createLocation(Location_ID1, usr, acclist.get(0).id);
            Database.insert(locationlist);
            list<Account> locationlist2 = TestDataFactory.createLocation(Location_ID2, usr, acclist.get(0).id);
            Database.insert(locationlist2);
            list<Contact> conlist = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST, 
                                                                Constant_Util.CONSTANT_LAST, acclist.get(0), usr);
            Database.insert(conlist);
            AccountContactRelation acr = new AccountContactRelation (ContactId = conlist.get(0).Id, 
                                                                     AccountId = locationlist.get(0).Id);
            Database.insert(acr);
            //create product
            list<product2> productlist = TestDataFactory.createProduct(Constant_Util.KEYWORD_TEST);
            Database.insert(productlist);
            
            //create vendor
            list<Account> supplieracclist = TestDataFactory.createAccount(Account_Name, usr,SUPPLIER);
            Database.insert(supplieracclist);
            
            //create asset
            list<Asset> assetlist = TestDataFactory.createAsset(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                                productlist.get(0), usr, locationlist.get(0));
            assetlist[0].Supplier__c = supplieracclist.get(0).Id;
            Database.insert(assetlist);
            
            //create case
            
            list<Case> caselist = TestDataFactory.createCase(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                             usr, locationlist.get(0), assetlist.get(0));
            caselist.get(0).Email_Tracking_Number__c = 'T22263283';
            caselist.get(0).Source_System__c = 'Acorn';
            caselist.get(0).Status = 'New';
            caselist.get(0).RecordTypeid = TestDataFactory.getRecordType('Integration Case','Case');
            Database.insert(caselist);
            
            list<Case> caselist2 = TestDataFactory.createCase(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                             usr, locationlist.get(0), assetlist.get(0));
            caselist2.get(0).Email_Tracking_Number__c = 'T22263283';
            caselist2.get(0).Source_System__c = 'Acorn';
            caselist2.get(0).Status = 'New';
            caselist2.get(0).RecordTypeid = TestDataFactory.getRecordType('Integration Case','Case');
            Database.insert(caselist2);
            
            String Subject = Constant_Util.KEYWORD_TEST;
            String Body = Constant_Util.KEYWORD_TEST + ' lOCatioN ';
            List<EmailMessage> lstEM = new List<EmailMessage>();
            lstEM = TestDataFactory.createEmailMessage(Subject, Body, caselist.get(0));
            Database.insert(lstEM); 
            
        }
        
    }

   /**
    * @description test method for trackingNumberCheck function
    */
    @isTest static void testtrackingNumberCheck(){
        User usr = [Select id from User where Profile.Name =:SYS_ADMIN and IsActive = true  limit 1];
        //Changes related to SDT - 37977 - start 
        Test.startTest();
        //Changes related to SDT - 37977 - end
        List<Case> lstCase = new List<Case>();
        lstCase = [Select Id,Tracking_Number__c,Routing_Counter__c,Email_Tracking_Number__c from Case ];
        
        system.runAs(usr){
           TrackingPattern.emailMessage(lstCase); 
            lstCase = [Select Id,Tracking_Number__c,Routing_Counter__c from Case limit 1];
            //Changes related to SDT - 37977 - start  
        Test.stopTest();
        //Changes related to SDT - 37977 - end
           System.assertEquals(lstCase.size(),1);
        }
    }
    
     /**
    * @description test method for Pattern in the TextBody
    */
    @isTest static void testtrackingNumberCheckforUpdate(){
        //test class errors - SDT - 33363
        User usr = [Select id from User where Profile.Name =:SYS_ADMIN and IsActive = true  limit 1];
        
        List<Case> lstCase = new List<Case>();
        lstCase = [Select Id,Tracking_Number__c,Routing_Counter__c,Email_Tracking_Number__c from Case limit 1];
        lstCase.get(0).Routing_Counter__c = 0;
        lstCase.get(0).Tracking_Number__c = '';
        update lstCase ;
        system.runAs(usr){
		Test.startTest();
           TrackingPattern.emailMessage(lstCase); 
            lstCase = [Select Id from Case where Routing_Counter__c = 1 ];
			Test.stopTest();
            
           //System.assertEquals(lstCase.size(),1);
        }
    }
    
    /**
    * @description test method for Pattern in the TextBody
    */
    @isTest static void testtrackingNumberCheckforException(){
        //test class errors - SDT - 33363
        User usr = [Select id from User where Profile.Name =:SYS_ADMIN and IsActive = true  limit 1];
        
        List<Case> lstCase = new List<Case>();
       // List<Case> integrationCase
        lstCase = [Select Id from Case];
        
        system.runAs(usr){
            Test.startTest(); //SDT-39054
           TrackingPattern.emailMessage(lstCase);    
           Test.stopTest();
        }
    }
    
}