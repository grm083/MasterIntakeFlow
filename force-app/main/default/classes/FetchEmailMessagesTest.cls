/**
* @author 
* @date 9/23/2019
* @description : Apex class FetchEmailMessages
**/
@isTest(SeeAllData=false)
public class FetchEmailMessagesTest {
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
    
    @isTest static void testgetAllRelatedEmailTasks(){
        //test class errors - SDT - 33363
        User usr = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name ='System Administrator' limit 1];
        List<Case> lstCase = new List<Case>();
        lstCase = [Select Id from Case];
        
        system.runAs(usr){
             String Subject = Constant_Util.KEYWORD_TEST + ' lOCatioN # FAM002508';
            String Body = Constant_Util.KEYWORD_TEST  ;
            List<EmailMessage> lstEM = new List<EmailMessage>();
            lstEM = TestDataFactory.createEmailMessage(Subject, Body, lstCase.get(0));
			Test.startTest();
            Database.insert(lstEM);  
            FetchEmailMessages.getAllRelatedEmailTasks(lstEM.get(0).id);
			Test.stopTest();
            
        }
        
    }
    
       @isTest static void testgetSearchedEmailMessages(){
        //test class errors - SDT - 33363
        User usr = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name ='System Administrator' limit 1];
        List<Case> lstCase = new List<Case>();
        lstCase = [Select Id from Case];
        
        system.runAs(usr){
             String Subject = Constant_Util.KEYWORD_TEST + ' lOCatioN # FAM002508';
            String Body = Constant_Util.KEYWORD_TEST  ;
            List<EmailMessage> lstEM = new List<EmailMessage>();
            lstEM = TestDataFactory.createEmailMessage(Subject, Body, lstCase.get(0));
			Test.startTest();
            Database.insert(lstEM);
            FetchEmailMessages.getSearchedEmailMessages(1,1,'loc','2019-09-23','2019-09-24','test');
            FetchEmailMessages.getSearchedEmailMessages(1,1,'','2019-09-23','2019-09-24','test');
            FetchEmailMessages.getSearchedEmailMessages(1,1,'',null,'2019-09-24','test');
            FetchEmailMessages.getSearchedEmailMessages(1,1,'',null,null,'test');
			Test.stopTest();
            
        }
        
    }
    
     @isTest static void testgetSearchedEmailMessagesCount(){
        //test class errors - SDT - 33363
        User usr = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name ='System Administrator' limit 1];
        List<Case> lstCase = new List<Case>();
        lstCase = [Select Id from Case];
        
        system.runAs(usr){
             String Subject = Constant_Util.KEYWORD_TEST + ' lOCatioN # FAM002508';
            String Body = Constant_Util.KEYWORD_TEST  ;
            List<EmailMessage> lstEM = new List<EmailMessage>();
            lstEM = TestDataFactory.createEmailMessage(Subject, Body, lstCase.get(0));
			Test.startTest();
            Database.insert(lstEM);
            FetchEmailMessages.getSearchedEmailMessagesCount('loc','2019-09-23','2019-09-24','test');
             FetchEmailMessages.getSearchedEmailMessagesCount('','2019-09-23','2019-09-24','test');
            FetchEmailMessages.getSearchedEmailMessagesCount('',null,'2019-09-24','test');
              FetchEmailMessages.getSearchedEmailMessagesCount('',null,null,'test');
			Test.stopTest();
            
        }
        
    }

}