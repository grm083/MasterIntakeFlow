/**
* @author 
* @date 
* @description : Apex class 
**/
@isTest(SeeAllData=false)
public class LinkEmailMessageToCaseBatchTest {
    
    /**
* @description set the test data
*/ 
    public static final String str_MESSAGE_ID ='Message-ID: <';
    public static final String str_REPLYTO_ID ='In-Reply-To: <';
        
    @testSetup static void setup() {
        /*Profile prf = TestDataFactory.getProfile(Constant_Util.SYSTEM_ADMINISTRATOR);
        User usr = TestDataFactory.createUser(prf);
        Database.insert(usr);*/ //Commented for SDT-33455 
        Boolean BypassValidation = true; //Modified for SDT-33455 
        Boolean GenesysEnabled = false; //Modified for SDT-33455
        User usr = TestDataFactory.getCSRUser(BypassValidation, GenesysEnabled); //Modified for SDT-33455 
        
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
            workOrderList[0].Acorn_WorkOrder_Number__c = + ' lOCatioN # FAM002508';
            Database.insert(workOrderList);
            
            String Subject = Constant_Util.KEYWORD_TEST + 'Work Order #W22263283';
            String Body = Constant_Util.KEYWORD_TEST + ' lOCatioN # FAM002508';
            List<EmailMessage> lstEM = new List<EmailMessage>();
            lstEM = TestDataFactory.createEmailMessage(Subject, Body, caselist.get(0));
             lstEM.get(0).FromAddress = 'Donotreply@wm.com' ;
            Database.insert(lstEM);
            
                     
            
        }
        
    }
    
      /**
    * @description test method for WONumber in the Subject
    */
    @isTest static void testEmailMessageWONumber(){
        //test class errors - SDT - 33363
        //User usr = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name ='System Administrator' limit 1];
//Querying CSR User.
        User usr = [SELECT Id, Bypass_Validation__c FROM User WHERE Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive = true LIMIT 1]; //Modified for SDT-33455           
        
        List<Case> lstCase = new List<Case>();
        lstCase = [SELECT Id,Email_Tracking_Number__c FROM Case LIMIT 49999];
        
        List<Account> lstLocation = new List<Account>();
        lstLocation = [SELECT Id,Name,Location_Code__c,ParentId FROM Account where 
                       RecordType.DeveloperName =: Constant_Util.LOCATION LIMIT 49999];
        
        system.runAs(usr){
            String Subject = Constant_Util.KEYWORD_TEST + 'Work Order #W22263283';
            String Body = Constant_Util.KEYWORD_TEST + 'W22263283';
//Modified for SDT-33455 Start
            List<Case> caseList = new List<Case>();
			case c = new case();
            caseList.add(c);
            insert caseList;
			//Modified for SDT-33455 End          
            List<EmailMessage> lstEM = new List<EmailMessage>();
            lstEM = createEmailMessageDetail(Subject, Body, caseList); //Modified for SDT-33455
            lstEM.get(0).In_Reply_To_ID__C = '1234552' ;
            lstEM.get(0).FromAddress = 'Donotreply@wm.com' ;
            Database.insert(lstEM);   
            Datetime testingday = Datetime.now().addHours(-1);
			Test.setCreatedDate(lstEM.get(0).Id, testingday);
             Test.startTest();
              
                String strJobName = 'LinkFailureEmailMessageToCaseBatch-:';
                String strSchedule = '0 30 * * * ?';
                System.schedule(strJobName, strSchedule, new LinkFailureEmailMessageToCaseBatch());
                Database.executeBatch(new LinkFailureEmailMessageToCaseBatch(), 200);
            Test.stopTest();
        }
    }
	
	@isTest static void testEmailMessageTrackingNumber(){
        //test class errors - SDT - 33363
        //User usr = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name ='System Administrator' limit 1];
//Querying CSR User.
        User usr = [SELECT Id, Bypass_Validation__c FROM User WHERE Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive = true LIMIT 1]; //Modified for SDT-33455           
        
        List<Case> lstCase = new List<Case>();
        lstCase = [SELECT Id,Email_Tracking_Number__c FROM Case LIMIT 49999];
        
        List<Account> lstLocation = new List<Account>();
        lstLocation = [SELECT Id,Name,Location_Code__c,ParentId FROM Account where 
                       RecordType.DeveloperName =: Constant_Util.LOCATION LIMIT 49999];
        
        system.runAs(usr){
            String Subject = Constant_Util.KEYWORD_TEST + 'Test T32646344';
            String Body = Constant_Util.KEYWORD_TEST + 'Demo';
            case c = new case();
            insert c;
            case c1 = new case();
            c1.Tracking_Number__c = 'T32646344';
            insert c1;
             Test.startTest(); //SDT-33637
            List<EmailMessage> lstEM = new List<EmailMessage>();
            lstEM = TestDataFactory.createEmailMessage(Subject, Body, c);
            lstEM.get(0).In_Reply_To_ID__C = '12345523' ;
            Insert lstEM;   
             Test.stopTest();  //SDT-33637
            Datetime testingday = Datetime.now().addHours(-1);
			Test.setCreatedDate(lstEM.get(0).Id, testingday);
            // Test.startTest(); //SDT-33637
              
                String strJobName = 'LinkFailureEmailMessageToCaseBatchh-:';
                String strSchedule = '0 30 * * * ?';
                System.schedule(strJobName, strSchedule, new TrackingNoEmailThreadToParentBatch());
                Database.executeBatch(new TrackingNoEmailThreadToParentBatch(), 200);
           // Test.stopTest();  //SDT-33637
        }
    }
	
//Modified for SDT-33455 Start
    /*
    * @vendor            TCS
    * @story             
    * @author            Manisha Patil
    * @description       This method will be used to builkefied the code for testEmailMessageWONumber method.
    * @param             none
    * @return            List of Email Message.
    */
    public static list<EmailMessage> createEmailMessageDetail(String Subject, String Body, List<Case> caseList){
        list<EmailMessage> emList = new list<EmailMessage>();
        if(caseList.size() > 0) {
            for(case cs : caseList) {
                EmailMessage objEM = new EmailMessage(Subject = Subject, TextBody = Body, ToAddress = 'test@test.com',
                                              FromAddress = 'testfrom@test.com', ParentId = cs.Id, Incoming = true);
                emList.add(objEM);
            }  
        }
        return emList;
    }
	//Modified for SDT-33455 End

}