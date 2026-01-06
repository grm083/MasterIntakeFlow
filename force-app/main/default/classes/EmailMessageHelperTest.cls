/**
* @author Ayushi Sharma
* @date 2/28/2019
* @description : Apex class EmailMessageHelper
**/
@isTest(SeeAllData=false)
public class EmailMessageHelperTest {
    
    private static final string TESTSUBJECT = 'test Subject';
    
    /**
* @description set the test data
*/ 
    @testSetup static void setup() {
        Profile p = TestDataFactory.getProfile(Constant_Util.SYSTEM_ADMINISTRATOR);
        User usr = TestDataFactory.createUser(p);
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
            AccountContactRelation acr = new AccountContactRelation (ContactId = conlist.get(0).Id, 
                                                                     AccountId = locationlist.get(0).Id);
            Database.insert(acr);
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
            caselist[0].Location__c = null;
            caselist[0].AssetId = null;
            Database.insert(caselist);
            
            IndicoEmailMessageFilter__c indicoEmailType = new IndicoEmailMessageFilter__c();
            indicoEmailType.Name = 'IndicoEmail';
            indicoEmailType.FilterConditionColumnName__c = 'All';
            indicoEmailType.FilterConditionValue__c = 'cct_sbs_test_17@wm.com';
            indicoEmailType.Type__c = 'WMPORTALS';
            Database.insert(indicoEmailType);
        }
        
    }
    
    /**
* @description test method for Pattern in the TextBody
*/
    @isTest static void testEmailMessageBody(){
        User usr = [SELECT id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        
        List<Case> lstCase = new List<Case>();
        lstCase = [Select Id from Case];
        
        List<Account> lstLocation = new List<Account>();
        lstLocation = [select Id,Name,Location_Code__c,ParentId from Account where 
                       RecordType.DeveloperName =: Constant_Util.LOCATION];
        
        system.runAs(usr){
            String Subject = Constant_Util.KEYWORD_TEST;
            String Body = Constant_Util.KEYWORD_TEST + ' T28356275 # lOCatioN # FAM002508';
            List<EmailMessage> lstEM = new List<EmailMessage>();
            lstCase.get(0).Email_Tracking_Number__c = 'T28356275';
            Database.update(lstCase.get(0));
            lstEM = TestDataFactory.createEmailMessage(Subject, Body, lstCase.get(0));
            Database.insert(lstEM);    
        }
    }
    
    /**
* @description test method for Pattern in the Subject
*/
    @isTest static void testEmailMessageSubject(){
        User usr = [SELECT id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        List<Case> lstCase = new List<Case>();
        lstCase = [Select Id from Case];
        
        system.runAs(usr){
            String Subject = Constant_Util.KEYWORD_TEST + ' T28356275 # lOCatioN # FAM002508';
            String Body = Constant_Util.KEYWORD_TEST  ;
            List<EmailMessage> lstEM = new List<EmailMessage>();
            lstEM = TestDataFactory.createEmailMessage(Subject, Body, lstCase.get(0));
            
            Database.insert(lstEM);    
        }
    }
    
    /**
* @description test method for Pattern in the Subject
*/
    @isTest static void testEmailConfirmServiceMessageSubject(){
        User usr = [SELECT id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        List<Case> lstCase = new List<Case>();
        lstCase = [Select Id from Case];
        
        system.runAs(usr){
            String Subject = Constant_Util.SERVICE_NOT_PERFORMED ;
            String Body = 'Testing Email Subj';
            List<EmailMessage> lstEM = new List<EmailMessage>();
            lstEM = TestDataFactory.createEmailMessage(Subject, Body, lstCase.get(0));
            lstEM[0].Incoming = true;
            Database.insert(lstEM);
        }
        List<EmailMessage> testEm = [SELECT Id, Subject, Bypass_Genesys_Task__c FROM EmailMessage WHERE Subject =: Constant_Util.SERVICE_NOT_PERFORMED];
        System.assert(!testEm[0].Bypass_Genesys_Task__c);
    }
    
    
    
    /**
* @description test method for Pattern in the Subject
*/
    @isTest static void testMultipleLocationCode(){
        User usr = [SELECT id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        List<Case> lstCase = new List<Case>();
        lstCase = [Select Id from Case];
        
        system.runAs(usr){
            String Subject = Constant_Util.KEYWORD_TEST + ' W28356275 lOCatioN # FAM002508';
            String Body = Constant_Util.KEYWORD_TEST + ' lOCatioN # FAM002509  lOCatioN # FAM002510';
            List<EmailMessage> lstEM = new List<EmailMessage>();
            lstEM = TestDataFactory.createEmailMessage(Subject, Body, lstCase.get(0));
            Database.insert(lstEM);    
        } 
    }
    
    /**
* @description test method for Pattern in the TextBody
*/
    @isTest static void testEmailMessageNoLocationCode(){
        try{
            User usr = [Select id from User limit 1];
            List<Case> lstCase = new List<Case>();
            lstCase = [Select Id from Case];
            
            system.runAs(usr){
                String Subject = Constant_Util.KEYWORD_TEST;
                String Body = Constant_Util.KEYWORD_TEST;
                List<EmailMessage> lstEM = new List<EmailMessage>();
                lstEM = TestDataFactory.createEmailMessage(Subject, Body, lstCase.get(0));
                Database.insert(lstEM,false); 
                
            }
        }
        Catch(Exception ex){}
    }
    
    /**
* @description test method for Pattern in the TextBody
*/
    @isTest static void testExceptions(){
        User usr = [SELECT id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        List<Case> lstCase = new List<Case>();
        lstCase = [Select Id from Case];
        
        system.runAs(usr){            
            List<EmailMessage> lstEM = new List<EmailMessage>();   
            Database.insert(lstEM);    
        }
        
    }
    /*
* Test method for delete prevention
*/
    
    @isTest static void testPreventDelete(){
        Profile p = TestDataFactory.getProfile(Constant_Util.CUSTOMER_SERVICE);
        //List <Profile> p = [SELECT Id, Name FROM Profile];
        User u = TestDataFactory.createUser(p);
        u.IsActive = true;
        Database.insert(u);
        List<Case> cases = [SELECT Id FROM Case LIMIT 1];
        EmailMessage em = new EmailMessage();
        em.CreatedById = u.id;
        em.parentId = cases[0].id;
        Database.insert(em);
        
        Test.startTest();
        System.runAs(u){
            System.debug('User Prof Id ' + UserInfo.getProfileId());
            System.debug('adminId ' + u.profileId);
            System.debug('admin Id prof name ' + u.profile.Name);
            System.debug('profile name ' + p);
            try{
                delete em;
            }
            catch(DMLException e){
                System.assert(e.getMessage().contains('You do not have the ability to delete Email Message records'));
            }
        }
        Test.stopTest();
        
    }
    
    @isTest static void testEmailMessageHeaderReplyToID(){
        Profile p = TestDataFactory.getProfile(Constant_Util.CUSTOMER_SERVICE);
        //List <Profile> p = [SELECT Id, Name FROM Profile];
        User u = TestDataFactory.createUser(p);
        u.IsActive = true;
        Database.insert(u);
        
        List<EmailMessage> emailMsg = new List<EmailMessage>();
        
        List<Case> cases = [SELECT Id FROM Case LIMIT 1];
        EmailMessage em = new EmailMessage();
        em.CreatedById = u.id;
        em.parentId = cases[0].id;
        em.Headers = 'In-Reply-To: < @ aaaa>';
        em.TextBody ='ref:@@@'; 
        emailMsg.add(em); 
        System.runAs(u){
            Test.startTest();
            Database.insert(emailMsg);
            EmailMessageTriggerHelper.handleClosedCaseMessage(emailMsg);
            Test.stopTest();
        }
    }
    
    @isTest static void testEmailMessageHeaderMessageID(){
        Profile p = TestDataFactory.getProfile(Constant_Util.CUSTOMER_SERVICE);
        //List <Profile> p = [SELECT Id, Name FROM Profile];
        User u = TestDataFactory.createUser(p);
        u.IsActive = true;
        Database.insert(u);
        
        List<EmailMessage> emailMsg = new List<EmailMessage>();
        
        List<Case> cases = [SELECT Id FROM Case LIMIT 1];
        EmailMessage em = new EmailMessage();
        em.CreatedById = u.id;
        em.parentId = cases[0].id;
        em.Subject = 'Test Test';
        em.Headers = 'Message-ID: <@aaaa>';      
        emailMsg.add(em); 
        
        Test.startTest();
        Database.insert(emailMsg);
        EmailMessageTriggerHelper.handleClosedCaseMessage(emailMsg);           
        Test.stopTest();
        
    }    
    
    @isTest static void EmailsWithReferenceNoTest(){
        Profile p = TestDataFactory.getProfile(Constant_Util.CUSTOMER_SERVICE);
        //List <Profile> p = [SELECT Id, Name FROM Profile];
        User u = TestDataFactory.createUser(p);
        u.IsActive = true;
        Database.insert(u);
        
        List<Case> cases = [SELECT Id,Status FROM Case where status = 'Closed' LIMIT 1]; 
        system.debug('cases :: '+ cases);
    }
    
    
    @isTest static void EmailsWithReferenceNoTest1(){
        Profile p = TestDataFactory.getProfile(Constant_Util.CUSTOMER_SERVICE);
        //List <Profile> p = [SELECT Id, Name FROM Profile];
        User u = TestDataFactory.createUser(p);
        u.IsActive = true;
        Database.insert(u);
        List<Case> cases = [SELECT Id,Status FROM Case where status = 'Closed' LIMIT 1]; 
        system.debug('cases :: '+ cases);         
    }
    
    @isTest static void DeleteCasesTest(){
        Profile p = TestDataFactory.getProfile(Constant_Util.CUSTOMER_SERVICE);
        //List <Profile> p = [SELECT Id, Name FROM Profile];
        User u = TestDataFactory.createUser(p);
        u.IsActive = true;
        Database.insert(u);
        List<Case> cases = [SELECT Id FROM Case];
        cases[0].Status = Constant_Util.NEW_STATUS; 
        cases[1].Status = Constant_Util.NEW_STATUS;
        cases[2].Status = Constant_Util.NEW_STATUS;
        cases[3].Status = Constant_Util.NEW_STATUS;
        System.debug('^^^^Cases to be deleted'+cases);
        Database.update(cases);
        
        EmailMessage em = new EmailMessage();
        em.CreatedById = u.id;
        em.parentId = cases[0].id;
        
        Database.insert(em);
        
        Test.startTest();
        
        delete cases;
        
        
        Test.stopTest();
    }
    
    @isTest static void checkIndicoEmailMessageTest(){
        
        User usr = [SELECT id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        List<Case> lstCase = new List<Case>();
        lstCase = [Select Id from Case];
        
        IndicoEmailMessageFilter__c inEmail = [Select id,Name,FilterConditionColumnName__c,FilterConditionValue__c,Type__c from IndicoEmailMessageFilter__c ];
        
        system.runAs(usr){
            String Subject = TESTSUBJECT;
            String Body = 'Testing Email Subj';
            List<EmailMessage> lstEM = new List<EmailMessage>();
            EmailMessage objEM = new EmailMessage(Subject = Subject, TextBody = Body, ToAddress = 'cct_sbs_test_17@wm.com',
                                                  FromAddress = 'testfrom@test.com', ParentId = lstCase[0].Id);
            lstEM.add(objEM);
            //lstEM[0].isIndicoEligible__c = true;
            Database.insert(lstEM);
            System.debug('####objEM'+objEM);
            
            test.startTest();
            EmailMessageTriggerHelper.checkIndicoEmailMessage(lstEM);
            objEM.isIndicoEligible__c = true;
            Database.update(objEM);
            test.stopTest();
        } 
        
        List<SFDCEmailMessage__c> sfdcEmsg = [Select id from SFDCEmailMessage__c where SFDCEmailMessageParentId__c =: lstCase[0].Id];
        
        System.assert(sfdcEmsg != null);
    }
    
    @isTest static void testEmailMessageFromAddress(){
        User usr = [SELECT id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        
        List<Case> lstCase = new List<Case>();
        lstCase = [Select Id from Case];
        
        List<Account> lstLocation = new List<Account>();
        lstLocation = [select Id,Name,Location_Code__c,ParentId from Account where 
                       RecordType.DeveloperName =: Constant_Util.LOCATION];
        
        system.runAs(usr){
            String Subject = System.Label.Label_EMAILSUBJECT;
            String Body = Constant_Util.KEYWORD_TEST + ' lOCatioN # FAM002508';
            List<EmailMessage> lstEM = new List<EmailMessage>();
            lstEM = TestDataFactory.createEmailMessage(Subject, Body, lstCase.get(0));
            lstEM[0].FromAddress = System.Label.Label_EmailFrom_Indico;
            Database.insert(lstEM);    
        }
    }
    @isTest static void testsentChatNowAutoReply(){
        User usr = [SELECT id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        List<Case> lstCase = new List<Case>();
        lstCase = [Select Id from Case];
        system.runAs(usr){
            String Subject = Constant_Util.SERVICE_NOT_PERFORMED ;
            String Body = 'Testing Email Subj';
            List<EmailMessage> lstEM = new List<EmailMessage>();
            lstEM = TestDataFactory.createEmailMessage(Subject, Body, lstCase.get(0));
            lstEM[0].Incoming = true;
            lstEM[0].FromAddress = 'test@testdoaminsstest.com';
            Test.startTest();
            Database.insert(lstEM);
            Test.stopTest();
            //  EmailMessageTriggerHelper.sentChatNowAutoReply(lstEM);
            
            
        }
    }
    @isTest static void testreopenCaseEmail(){
        User usr = [SELECT id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        
        List<Case> lstCase = new List<Case>();
        lstCase = [Select Id from Case];
        
        List<Account> lstLocation = new List<Account>();
        lstLocation = [select Id,Name,Location_Code__c,ParentId from Account where 
                       RecordType.DeveloperName =: Constant_Util.LOCATION];
        
        system.runAs(usr){
            String Subject = Constant_Util.KEYWORD_TEST;
            String Body = Constant_Util.KEYWORD_TEST + ' T28356275 # lOCatioN # FAM002508';
            List<EmailMessage> lstEM = new List<EmailMessage>();
            lstCase.get(0).Email_Tracking_Number__c = 'T28356275';
            lstCase.get(0).Tracking_Number__c = 'T28356275';
            lstCase.get(0).status = 'Closed';
            Database.update(lstCase.get(0));
            lstEM = TestDataFactory.createEmailMessage(Subject, Body, lstCase.get(0));
            Database.insert(lstEM);    
        }
    }
    
    @isTest
    static void testCreateSFDCEmailMessageForIndico() {
        String filterConditionValue = 'ref:@@@';
        IndicoEmailMessageFilter__c indicoFilter = new IndicoEmailMessageFilter__c(
            Name = 'Test Filter',
            Type__c = 'Customer_Service',
            FilterConditionValue__c = filterConditionValue
        );
        insert indicoFilter;
        
        Case testCase = new Case(
            Status = 'New',
            Subject = 'Test Case',
            Reference_Number__c = 'REF123456'
        );
        insert testCase;
        
        testCase = [SELECT Id, CaseNumber, Reference_Number__c FROM Case WHERE Id = :testCase.Id];
        
        EmailMessage em1 = new EmailMessage();
        em1.Id = '02sVF000004QVU5YAO';
        em1.FromAddress = 'test1@example.com';
        em1.ToAddress = 'support@example.com';
        em1.CcAddress = 'manager@example.com';
        em1.Subject = 'Test Subject 1';
        em1.TextBody = filterConditionValue;
        
        EmailMessage em2 = new EmailMessage();
        em2.Id = '02sVF000004QYzpYAG';
        em2.FromAddress = 'test2@example.com';
        em2.ToAddress = 'support@example.com';
        em2.Subject = 'Test Subject 2';
        em2.TextBody = filterConditionValue;
        
        em1.Parent = testCase;
        em2.Parent = testCase;
        
        Map<Id, EmailMessage> emailMap = new Map<Id, EmailMessage>();
        emailMap.put(em1.Id, em1);
        emailMap.put(em2.Id, em2);
        
        EmailMessageTriggerHelper.indicoFilterConditionColValue = filterConditionValue;
        
        Test.startTest();
        EmailMessageTriggerHelper.createSFDCEmailMessageForIndico(emailMap);
        Test.stopTest();
        
        List<SFDCEmailMessage__c> createdMessages = [
            SELECT Id, EmailMessageId__c, SFDCEmailMessageFromAddress__c, 
            SFDCEmailMessageToAddress__c, SFDCEmailMessageSubject__c,
            SFDCEmailMessageTextBody__c, SFDCEmailMessageType__c,
            SFDCEmailMessageParentCaseNumber__c, SFDCEmailMessageParentReferenceNumber__c
            FROM SFDCEmailMessage__c
        ];
        
        System.assertEquals(2, createdMessages.size(), 'Should create 2 SFDCEmailMessage records');
        
        SFDCEmailMessage__c msg1 = createdMessages[0];
        System.assertEquals(em1.Id, msg1.EmailMessageId__c, 'EmailMessage ID should match');
        System.assertEquals(em1.FromAddress, msg1.SFDCEmailMessageFromAddress__c, 'FromAddress should match');
        System.assertEquals(em1.ToAddress, msg1.SFDCEmailMessageToAddress__c, 'ToAddress should match');
        System.assertEquals(em1.Subject, msg1.SFDCEmailMessageSubject__c, 'Subject should match');
        System.assertEquals('Customer_Service', msg1.SFDCEmailMessageType__c, 'Type should match filter');
        System.assertEquals(testCase.CaseNumber, msg1.SFDCEmailMessageParentCaseNumber__c, 'CaseNumber should match');
        System.assertEquals(testCase.Reference_Number__c, msg1.SFDCEmailMessageParentReferenceNumber__c, 'Reference Number should match');
    }    
}