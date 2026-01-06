/**
* @author Ayushi Sharma
* @date 2/28/2019
* @description : Apex class EmailMessageHelper
**/
@isTest(SeeAllData=false)
public class EmailMessageTest {
    
    /**
* @description set the test data
*/ 
    public static final String str_MESSAGE_ID ='Message-ID: <';
    public static final String str_REPLYTO_ID ='In-Reply-To: <';
        
    @testSetup static void setup() {
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
            caselist.get(0).AccountId = acclist.get(0).id ;
            Database.insert(caselist.get(0)); 
            
            list<Case> caselist2 = TestDataFactory.createCase(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                             usr, locationlist.get(0), assetlist.get(0));
            caselist2.get(0).AccountId = acclist.get(0).id ;
            Database.insert(caselist2.get(3)); 
            
            //create Workorder
            List<WorkOrder> workOrderList = TestDataFactory.createWorkOrder(acclist.get(0), conlist.get(0), caselist.get(0), 
                                                                            assetlist.get(0)); 
            workOrderList[0].Acorn_WorkOrder_Number__c = 'W22263283';
            Database.insert(workOrderList);
            
            String Subject = Constant_Util.KEYWORD_TEST;
            String Body = Constant_Util.KEYWORD_TEST + ' lOCatioN # FAM002508';
            List<EmailMessage> lstEM = new List<EmailMessage>();
            lstEM = TestDataFactory.createEmailMessage(Subject, Body, caselist.get(1));
            Database.insert(lstEM);
            
            //create task
            list<Task> tasklist = TestDataFactory.createTask(caselist[0].id,usr);
            Database.insert(tasklist);          
            
        }
        
    }
    
    /**
* @description test method for Pattern in the TextBody
*/
    @isTest static void testEmailMessageBody(){
        //test class errors - SDT - 33363
        User usr = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name ='System Administrator' limit 1];
        
        List<Case> lstCase = new List<Case>();
        List<Case> updateCase = new List<Case>();
        lstCase = [Select Id from Case LIMIT 49999];
        lstCase[0].Status = 'New';
        updateCase.add(lstCase[0]);
        update updateCase;
        List<Account> lstLocation = new List<Account>();
        lstLocation = [select Id,Name,Location_Code__c,ParentId from Account where 
                       RecordType.DeveloperName =: Constant_Util.LOCATION LIMIT 49999];
        
        system.runAs(usr){
            Test.startTest();
            String Subject = Constant_Util.KEYWORD_TEST;
            //String Body = Constant_Util.KEYWORD_TEST + ' lOCatioN # FAM002508';
            String Body = Constant_Util.KEYWORD_TEST + 'T22263283';
            List<EmailMessage> lstEM = new List<EmailMessage>();
            lstEM = TestDataFactory.createEmailMessage(Subject, Body, lstCase.get(0));
            lstEM.get(0).FromAddress  = 'ayushi.l.sharma@accenture.com';
            lstEM.get(0).Incoming = true ;
            Database.insert(lstEM);
            Test.stopTest();    
        }
    }
    
    /**
* @description test method for Pattern in the TextBody
*/
    @isTest static void testEmailMessageTN(){
        //test class errors - SDT - 33363
        User usr = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name ='System Administrator' limit 1];
        
        List<Case> lstCase = new List<Case>();
        List<Case> updateCase = new List<Case>();
        lstCase = [Select Id, Email_Tracking_Number__c, Status from Case LIMIT 49999];
        lstCase[0].Status = 'New';
        lstCase[0].Email_Tracking_Number__c ='T22263283';
        updateCase.add(lstCase[0]);
        update updateCase;
        List<Account> lstLocation = new List<Account>();
        lstLocation = [select Id,Name,Location_Code__c,ParentId from Account where 
                       RecordType.DeveloperName =: Constant_Util.LOCATION LIMIT 49999];
        
        system.runAs(usr){
            Test.startTest();
            String Subject = Constant_Util.KEYWORD_TEST;
            //String Body = Constant_Util.KEYWORD_TEST + ' lOCatioN # FAM002508';
            String Body = Constant_Util.KEYWORD_TEST + 'T22263283';
            List<EmailMessage> lstEM = new List<EmailMessage>();
            lstEM = TestDataFactory.createEmailMessage(Subject, Body, lstCase.get(0));
            lstEM.get(0).FromAddress  = 'ayushi.l.sharma@accenture.com';
            lstEM.get(0).Incoming = true ;
            Database.insert(lstEM);
            Test.stopTest();    
        }
    }
    
    /**
* @description test method for Pattern in the TextBody
*/
    @isTest static void testEmailMessageTrackingNumber(){
        //test class errors - SDT - 33363
        User usr = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name ='System Administrator' limit 1];
        
        List<Case> lstCase = new List<Case>();
        lstCase = [Select Id,Email_Tracking_Number__c from Case LIMIT 49999];
        lstCase[0].Email_Tracking_Number__c = 'T22263283';
        update lstCase;
        
        List<Account> lstLocation = new List<Account>();
        lstLocation = [select Id,Name,Location_Code__c,ParentId from Account where 
                       RecordType.DeveloperName =: Constant_Util.LOCATION LIMIT 49999];
        
        system.runAs(usr){
            Test.startTest();
            String Subject = Constant_Util.KEYWORD_TEST;
            //String Body = Constant_Util.KEYWORD_TEST + ' lOCatioN # FAM002508';
            String Body = Constant_Util.KEYWORD_TEST + 'T22263283';
            List<EmailMessage> lstEM = new List<EmailMessage>();
            lstEM = TestDataFactory.createEmailMessage(Subject, Body, lstCase.get(0));
            lstEM.get(0).FromAddress  = 'ayushi.l.sharma@accenture.com';
            lstEM.get(0).Incoming = true ;
            lstEM.get(0).In_Reply_To_ID__C = '12345' ;
            Database.insert(lstEM);   
            Test.stopTest(); 
        }
    }
    
    /**
* @description test method for Pattern in the TextBody
*/
    @isTest static void testEmailMessageTNClosedCase(){
        //test class errors - SDT - 33363
        User usr = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name ='System Administrator' limit 1];
        
        List<Case> lstCase = new List<Case>();
        lstCase = [Select Id,Email_Tracking_Number__c, Status from Case LIMIT 49999];
        lstCase[0].Email_Tracking_Number__c = 'T22263283';
        lstCase[0].Status = 'Closed';
        update lstCase;
        
        List<Account> lstLocation = new List<Account>();
        lstLocation = [select Id,Name,Location_Code__c,ParentId from Account where 
                       RecordType.DeveloperName =: Constant_Util.LOCATION LIMIT 49999];
        
        system.runAs(usr){
            String Subject = Constant_Util.KEYWORD_TEST;
            //String Body = Constant_Util.KEYWORD_TEST + ' lOCatioN # FAM002508';
            String Body = Constant_Util.KEYWORD_TEST + 'T22263283';
            List<EmailMessage> lstEM = new List<EmailMessage>();
            lstEM = TestDataFactory.createEmailMessage(Subject, Body, lstCase.get(0));
            lstEM.get(0).FromAddress  = 'ayushi.l.sharma@accenture.com';
            lstEM.get(0).Incoming = true ;
            Test.startTest();
            	Database.insert(lstEM);
            Test.stopTest();
        }
    }
    
    /**
* @description test method for Pattern in the Subject
*/
    @isTest static void testEmailMessageSubject(){
        //test class errors - SDT - 33363
        User usr = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name ='System Administrator' limit 1];
        List<Case> lstCase = new List<Case>();
        lstCase = [Select Id from Case LIMIT 49999];
        
        system.runAs(usr){
		    Test.startTest();
            String Subject = Constant_Util.KEYWORD_TEST + ' lOCatioN # FAM002508';
            String Body = Constant_Util.KEYWORD_TEST  ;
            List<EmailMessage> lstEM = new List<EmailMessage>();
            lstEM = TestDataFactory.createEmailMessage(Subject, Body, lstCase.get(0));
            Database.insert(lstEM);
			Test.stopTest();
        }
    }
    
    /**
* @description test Delete EmailMessage
*/
    @isTest static void testEmailMessageDelete(){
        //test class errors - SDT - 33363
        User usr = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name ='System Administrator' limit 1];
        List<Case> lstCase = new List<Case>();
        lstCase = [Select Id from Case LIMIT 49999];
        
        system.runAs(usr){
            String Subject = Constant_Util.KEYWORD_TEST + ' lOCatioN';
            String Body = Constant_Util.KEYWORD_TEST  ;
            List<EmailMessage> lstEM = new List<EmailMessage>();
            lstEM = TestDataFactory.createEmailMessage(Subject, Body, lstCase.get(0));
			 Test.startTest(); 
            Database.insert(lstEM); 
            
            
            try
            {
                delete lstEM;       
            }
            catch(Exception e)
            {
                Boolean expectedExceptionThrown =  e.getMessage().contains(('You do not have the ability to delete Email Message records.  Please see your System Administrator.')) ? true : false;
                System.AssertEquals(expectedExceptionThrown, true);                
            }
            Test.stopTest();   
        }
    }
    
    @isTest static void testEmailMessageSubjectServiceConfirmed(){
        //test class errors - SDT - 33363
        User usr = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name ='System Administrator' limit 1];
        List<Case> lstCase = new List<Case>();
        lstCase = [Select Id from Case LIMIT 49999];
        
        system.runAs(usr){
            Test.startTest(); 
            String Subject = Constant_Util.SERVICE_CONFIRMED;
            String Body = Constant_Util.KEYWORD_TEST  ;
            List<EmailMessage> lstEM = new List<EmailMessage>();
            lstEM = TestDataFactory.createEmailMessage(Subject, Body, lstCase.get(0));
            Database.insert(lstEM);    
            Test.stopTest(); 
        }
    }
    
    @isTest static void testEmailMessageSubjectSERVICE_NOT_PERFORMED(){
        //test class errors - SDT - 33363
        User usr = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name ='System Administrator' limit 1];
        List<Case> lstCase = new List<Case>();
        lstCase = [Select Id from Case LIMIT 49999];
        
        system.runAs(usr){
            Test.startTest(); 
            String Subject = Constant_Util.SERVICE_NOT_PERFORMED;
            String Body = Constant_Util.KEYWORD_TEST  ;
            List<EmailMessage> lstEM = new List<EmailMessage>();
            lstEM = TestDataFactory.createEmailMessage(Subject, Body, lstCase.get(0));
            Database.insert(lstEM);    
            Test.stopTest(); 
        }
    }
    
    
    /**
* @description test method for Pattern in the Subject
*/
    @isTest static void testMultipleLocationCode(){
        //test class errors - SDT - 33363
        User usr = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name ='System Administrator' limit 1];
        List<Case> lstCase = new List<Case>();
        lstCase = [Select Id from Case LIMIT 49999];
        
        system.runAs(usr){
            Test.startTest(); 
            String Subject = Constant_Util.KEYWORD_TEST + ' lOCatioN # FAM002508';
            String Body = Constant_Util.KEYWORD_TEST + ' lOCatioN # FAM002509  lOCatioN # FAM002510';
            List<EmailMessage> lstEM = new List<EmailMessage>();
            lstEM = TestDataFactory.createEmailMessage(Subject, Body, lstCase.get(0));
            Database.insert(lstEM);    
            Test.stopTest(); 
        } 
    }
    
    /**
* @description test method for Pattern in the TextBody
*/
    @isTest static void testEmailMessageNoLocationCode(){
        try{
            //test class errors - SDT - 33363
        User usr = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name ='System Administrator' limit 1];
            List<Case> lstCase = new List<Case>();
            lstCase = [Select Id from Case LIMIT 49999];
            
            system.runAs(usr){
                Test.startTest(); 
                String Subject = Constant_Util.KEYWORD_TEST;
                String Body = Constant_Util.KEYWORD_TEST;
                List<EmailMessage> lstEM = new List<EmailMessage>();
                lstEM = TestDataFactory.createEmailMessage(Subject, Body, lstCase.get(0));
                Database.insert(lstEM,false); 
                Test.stopTest(); 
                
            }
        }
        Catch(Exception ex){}
    }
    
    /**
* @description test method for Email mesage Closed with the reference No
*/
    @isTest static void testEMClosedWithReferenceNo(){
        try{
            //test class errors - SDT - 33363
        User usr = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name ='System Administrator' limit 1];
            List<Case> lstCase = new List<Case>();
            lstCase = [Select Id from Case LIMIT 49999];    
            String Header = 'Message-ID: <1234574MB0022227D61A03821A797F3F8F6550@COM> In-Reply-To: <4321574MB0022227D61A03821A797F3F8F6550@COM>';
            String Header2 = 'Message-ID: <1234574MB0022227D61A03821A797F3F8F6888@COM> In-Reply-To: <1234574MB0022227D61A03821A797F3F8F6550@COM>';
            system.runAs(usr){
                
                String Subject = Constant_Util.KEYWORD_TEST;
                String Body = 'ref: ';
                List<EmailMessage> lstEM = new List<EmailMessage>();
                lstEM = TestDataFactory.createEmailMessageWithHeader(Subject, Body, lstCase.get(0), Header);
				Test.startTest();
                Database.insert(lstEM,false);
                
                List<EmailMessage> lstEM3 = new List<EmailMessage>();
                Case objCase = new Case(id = lstCase.get(0).id, Status = 'Closed');
              
                	update objCase;
                Test.stopTest();
                
               // System.debug('^^^^ Case' + objCase);
                lstEM3 = [select id,ParentId,Subject,Incoming,Message_ID__c, In_Reply_To_ID__c,Parent.CaseNumber from EmailMessage LIMIT 49999];
                //System.debug('^^^^ EM' + lstEM3);
                List<EmailMessage> lstEM2 = new List<EmailMessage>();
                lstEM2 = TestDataFactory.createEmailMessageWithHeader(Subject, Body, lstCase.get(0), Header2);
                Database.insert(lstEM2,false); 
                //System.debug('^^^^ EM2' + lstEM2);        
                
            }
        }
        Catch(Exception ex){}
    }
    
    /**
* @description test method for Email mesage Closed without the reference No
*/
    @isTest static void testEMClosedWithoutReferenceNo(){
        try{
            //test class errors - SDT - 33363
        User usr = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name ='System Administrator' limit 1];
            List<Case> lstCase = new List<Case>();
            lstCase = [Select Id from Case LIMIT 49999];    
            String Header = 'Message-ID: <1234574MB0022227D61A03821A797F3F8F6550@COM> In-Reply-To: <4321574MB0022227D61A03821A797F3F8F6550@COM>';
            String Header2 = 'Message-ID: <1234574MB0022227D61A03821A797F3F8F6888@COM> In-Reply-To: <1234574MB0022227D61A03821A797F3F8F6550@COM>';
            system.runAs(usr){
                Test.startTest(); 
                String Subject = Constant_Util.KEYWORD_TEST;
                String Body = 'ref: ';
                List<EmailMessage> lstEM = new List<EmailMessage>();
                lstEM = TestDataFactory.createEmailMessageWithHeader(Subject, Body, lstCase.get(0), Header);
                Database.insert(lstEM,false);
                
                List<EmailMessage> lstEM3 = new List<EmailMessage>();
                lstEM3 = [select id,ParentId,Subject,Incoming,Message_ID__c, In_Reply_To_ID__c,Parent.CaseNumber from EmailMessage LIMIT 49999];
               // System.debug('^^^^ EM' + lstEM3);
                List<EmailMessage> lstEM2 = new List<EmailMessage>();
                lstEM2 = TestDataFactory.createEmailMessageWithHeader(Subject, Body, lstCase.get(0), Header2);
                lstEM2.get(0).Message_ID__c = 'BYAP114MB075863C58EF6C7459466EA5BDD250';
                Database.insert(lstEM2,false); 
                //System.debug('^^^^ EM2' + lstEM2);   
                Test.stopTest(); 
                
            }
        }
        Catch(Exception ex){}
    }
    
    /**
* @description test method for Email mesage without the reference No
*/
    @isTest static void testEMWithReferenceNo(){
        try{
            //test class errors - SDT - 33363
        User usr = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name ='System Administrator' limit 1];
            List<Case> lstCase = new List<Case>();
            
            lstCase = [Select Id,Status from Case LIMIT 1];
            lstCase[0].status = 'Closed';
            Test.startTest();
            	Database.update(lstCase);
            Test.stopTest();
            
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
        //test class errors - SDT - 33363
        User usr = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name ='System Administrator' limit 1];
        List<Case> lstCase = new List<Case>();
        lstCase = [Select Id from Case LIMIT 49999];
        
        system.runAs(usr){         
            Test.startTest();    
            List<EmailMessage> lstEM = new List<EmailMessage>();   
            Database.insert(lstEM);    
            Test.stopTest(); 
        }
    }
    
  /*   @isTest static void testEmailMessageHeaderReplyToID(){
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
        
        Test.startTest();
            Database.insert(emailMsg);
         	EmailMessageTriggerHelper.handleClosedCaseMessage(emailMsg);
        Test.stopTest();

    }*/
 
   
     @isTest static void DeleteCasesTest(){
        Profile p = TestDataFactory.getProfile(Constant_Util.CUSTOMER_SERVICE);
		//List <Profile> p = [SELECT Id, Name FROM Profile];
		User u = TestDataFactory.createUser(p);
        u.IsActive = true;
        Database.insert(u);
        List<Case> cases = [SELECT Id,status FROM Case];
        cases[0].Status = Constant_Util.NEW_STATUS; 
        cases[1].Status = Constant_Util.NEW_STATUS;
        
        System.debug('^^^^Cases to be deleted'+cases);
        Database.update(cases);
         
        EmailMessage em = new EmailMessage();
        em.CreatedById = u.id;
        em.parentId = cases[0].id;
         //Changes related to SDT - 37977 - start
        Test.startTest();
        Database.insert(em);
        //Test.startTest();
        //Changes related to SDT - 37977 - end
        		delete cases;
            
        
        Test.stopTest();
    }
    
     @isTest static void testEMWithReferenceNoSecond(){
        try{ 
            //test class errors - SDT - 33363
        User usr = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name ='System Administrator' limit 1];
            
            List<Case> lstCase = new List<Case>();
            lstCase = [Select Id,Status from Case LIMIT 1];
            lstCase[0].status = 'Closed';
            Test.startTest();
            	Database.update(lstCase);
            Test.stopTest();
              
                String Header = 'Message-ID: <1234574MB0022227D61A03821A797F3F8F6550@COM> In-Reply-To: <4321574MB0022227D61A03821A797F3F8F6550@COM>';
                system.runAs(usr){
                String Subject = Constant_Util.KEYWORD_TEST;
                String Body = 'ref: ';
                List<EmailMessage> lstEM = new List<EmailMessage>();
                lstEM = TestDataFactory.createEmailMessageWithHeader(Subject, Body, lstCase.get(0), Header);
                Database.insert(lstEM,false);
               
            }
        }
        Catch(Exception ex){}
    }
     
    /**
    * @description test method for WONumber in the TextBody/Subject
    */
    @isTest static void testEmailMessageWONumber(){
        //test class errors - SDT - 33363
        User usr = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name ='System Administrator' limit 1];
        
        List<Case> lstCase = new List<Case>();
        lstCase = [SELECT Id,Email_Tracking_Number__c FROM Case LIMIT 49999];
        
        List<Account> lstLocation = new List<Account>();
        lstLocation = [SELECT Id,Name,Location_Code__c,ParentId FROM Account where 
                       RecordType.DeveloperName =: Constant_Util.LOCATION LIMIT 49999];
        
        system.runAs(usr){
            String Subject = Constant_Util.KEYWORD_TEST;
            String Body = Constant_Util.KEYWORD_TEST + 'W22263283';
            List<EmailMessage> lstEM = new List<EmailMessage>();
            lstEM = TestDataFactory.createEmailMessage(Subject, Body, lstCase.get(0));
            lstEM.get(0).In_Reply_To_ID__C = '1234552' ;
			Test.startTest();
            Database.insert(lstEM);    
			Test.stopTest();
        }
    }
	/**
    * @description test method for WONumber in the TextBody/Subject
    */
    @isTest static void testEMWithoutExistingWONumber(){
        //test class errors - SDT - 33363
        User usr = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name ='System Administrator' limit 1];
        
        List<Case> lstCase = new List<Case>();
        lstCase = [SELECT Id FROM Case LIMIT 49999];
        
        List<Account> lstLocation = new List<Account>();
        lstLocation = [SELECT Id,Name,Location_Code__c,ParentId FROM Account where 
                       RecordType.DeveloperName =: Constant_Util.LOCATION LIMIT 49999];
        
        system.runAs(usr){
            String Subject = Constant_Util.KEYWORD_TEST;
            String Body = Constant_Util.KEYWORD_TEST + 'W11100283';
            List<EmailMessage> lstEM = new List<EmailMessage>();
            lstEM = TestDataFactory.createEmailMessage(Subject, Body, lstCase.get(0));
            lstEM.get(0).In_Reply_To_ID__C = '12345' ;
            Database.insert(lstEM);    
        }
    }
}