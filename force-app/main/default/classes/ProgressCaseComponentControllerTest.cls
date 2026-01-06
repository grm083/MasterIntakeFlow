@isTest
public class ProgressCaseComponentControllerTest {
    
    private static final string SYS_ADMIN = 'System Administrator';
    private static final string SPECIAL_INS ='Test Special Instructions';
    private static final string CHANNEL_INFO ='Test Channel Instructions';
    private static final string OTHER ='Other';
    private static final string TEST_NAME ='Test';
    private static final string NUMBER_145 ='145';
    private static final string REQ_INFO ='PSI ;PO NUMBER';
    private static final string SLA = 'Test SLA Instructions';
    private static final String LOCATION = 'Location';
    private static final String NUM_123 = '123';
    private static final String CONTACT_NOT_ONSITE = 'Contact Not Onsite';
    private static final String CONTACT = 'Contact';
    private static final String PICKUP = 'Pickup';
    private static final String EXTRA_PICKUP = 'Extra Pickup';
    private static final string COMMERCIAL = 'Commercial';
    private static final string REPAIRS = 'Repairs';
    private static final string COMPACTOR = 'COMPACTOR';
    
    /* @description : Apex method setup */
    /* method for setting up data*/ 
    @testSetup static void setup() {
        Profile adminProfile = TestDataFactory.getProfile(SYS_ADMIN);
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
            assetlist[0]. Supplier__c = acclist[1].Id;
            Database.insert(assetlist);
            
            list<Case> caselist = TestDataFactory.createCase(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                             usr, locationlist.get(0), assetlist.get(0));
            List<Case> myCaseList = TestDataFactory.createNewCase();
            list<Case> caselistForSameSlaDate = TestDataFactory.createCase(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                                           usr, locationlist.get(0), assetlist.get(0));
            caselist[0].Service_Date__c = system.today() + 1;
            caselist[0].SLA_Service_Date_Time__c = system.today() + 2;
            caselist[0].PurchaseOrder_Number__c =  Constant_Util.PO_VALUE_TEST;
            caselist[0].SLA_Override_Reason__c = REPAIRS ;
            caselist[0].Create_AM_and_PM_Pickups__c = true;    
            caselistForSameSlaDate[0].Service_Date__c = system.today() + 1;
            caselistForSameSlaDate[0].SLA_Service_Date_Time__c = caselistForSameSlaDate[0].Service_Date__c;
            caselistForSameSlaDate[0].PurchaseOrder_Number__c =  Constant_Util.PO_VALUE_TEST;
            caselistForSameSlaDate[0].SLA_Override_Reason__c = REPAIRS; 
            caselistForSameSlaDate[0].Create_AM_and_PM_Pickups__c = true;
            Database.insert(caselist);
            Database.insert(caselistForSameSlaDate);  
            List<WorkOrder> wrkOrderlst = TestDataFactory.createWorkOrder(acclist.get(0),conlist.get(0),caselist[0],assetlist.get(0));
            wrkOrderlst[0].Status = 'New';
            wrkOrderlst[0].Service_Date__c = system.today();
            wrkOrderlst[0].Customer_Location__c = caselist[0].Location__c;
            Database.insert(wrkOrderlst);
            
            List<WorkOrder> wrkOrderlst1 = TestDataFactory.createWorkOrder(acclist.get(0),conlist.get(0),caselist[0],assetlist.get(0));
            wrkOrderlst1[0].Status = 'New';
            wrkOrderlst1[0].Service_Date__c = system.today()-1;
            wrkOrderlst1[0].Customer_Location__c = caselist[0].Location__c;
            Database.insert(wrkOrderlst1);
        } 
    }
    
    /* @description : Apex method testBusinessRuleWithServiceApprovers when Multiple Mandatory Approver is true
*/
    @isTest public static void testBusinessRuleWithServiceApprovers(){
        //test class errors - SDT - 33363
        user currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(currentUser){
            List<Account> accList = [SELECT Id from Account LIMIT 49999];
            List<Contact> conlist = [SELECT Id from Contact where AccountId =: accList LIMIT 49999];
            List<product2> productlist = [SELECT Id from product2 LIMIT 49999];
            List<Asset> assetlist = [SELECT Id,Product2.ProductTypeSelected__c,Duration__c,Project_Code__c FROM Asset where AccountId =:accList AND 
                                     ContactId =:conlist AND product2Id =:productlist LIMIT 49999];
            List<Account> locationList =[Select Location_Type__c,RecordTypeid,ParentId from account where ParentId =:accList AND RecordType.DeveloperName=: LOCATION LIMIT 1];
            Case myCase = [SELECT Id,AssetId  from Case WHERE AccountId =:accList AND AssetId =:assetlist LIMIT 1];
            myCase.Status=Constant_Util.NEW_STATUS;
            //myCase.Case_Sub_Status__c= Constant_Util.PENDING_CUSTOMER_INFORMATION;
            myCase.SLA_Override_Reason__c = OTHER;
            myCase.SLA_Override_Comment__c=TEST_NAME;
            myCase.SlaStartDate = system.now().addHours(1);
            Database.update(myCase);
                       
            List<Business_Rule__c> brlist = TestDataFactory.createBusinessRule(Constant_Util.TEST_BUSINESS_RULE,accList.get(0),locationList.get(0));
            //brlist.get(0).RecordTypeId = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.APPROVAL).getRecordTypeId();
            
            //brlist.get(0).Active__c = true; 
            //brlist.get(0).Container__c=Constant_Util.EMPTY_STRING;
            //brlist.get(0).Schedule_Type__c=Constant_Util.EMPTY_STRING;
            //brlist.get(0).Project_Code__c=null;
            //brlist.get(0).AssetId__c = assetlist[0].id;
            //brlist.get(0).Multiple_Mandatory_Approvers__c=true;
            //brlist.get(0).Occurrence_Limit__c = 1;
            //brlist.get(0).Special_Instructions_Approval__c = 'Test Approval Instruction';
            //Business_Rule__c br = new Business_Rule__c();
            brlist.get(0).Container__c=Constant_Util.EMPTY_STRING;
            brlist.get(0).Schedule_Type__c=Constant_Util.EMPTY_STRING;
            brlist.get(0).Channel_Req__c=Constant_Util.EMPTY_STRING;
            brlist.get(0).Channel__c=Constant_Util.EMPTY_STRING;
            brlist.get(0).AccountId__c = accList.get(0).ID;
            brlist.get(0).locationid__c = locationList.get(0).ID;
            brlist.get(0).Active__c = True;
            brlist.get(0).Service__c = 'Extra Pickup';
            brlist.get(0).Request_Type__c = 'Pickup';
            brlist.get(0).AssetId__c = assetlist[0].id;
            brlist.get(0).RecordTypeId = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.APPROVAL).getRecordTypeId();
            brlist.get(0).Effective_Date__c = System.Today()-2;
            
            //brlist.add(br);
            Database.insert(brlist,true);
            
            list<Account_Title__c> acctitlelst = TestDataFactory.createAccountTitle(accList[0],TEST_NAME);
            Database.insert(acctitlelst);
            
            List<Service_Approver__c> serviceApproverList = TestDataFactory.createServiceApprover(brlist.get(0));
            serviceApproverList[0].Title__c = acctitlelst[0].Id; 
            
            Service_Approver__c sa = new Service_Approver__c(Business_Rule__c = brlist[0].id, Location__c =  brlist[0].locationid__c , Account__c = brlist[0].Accountid__c,
                                                             Recordtypeid = TestDataFactory.getRecordType('Email','Service_Approver__c'));
            sa.Email__c = 'test@test.com';
            serviceApproverList.add(sa);
            Service_Approver__c sa1 = new Service_Approver__c(Business_Rule__c = brlist[0].id, Location__c =  brlist[0].locationid__c , Account__c = brlist[0].Accountid__c,
                                                             Recordtypeid = TestDataFactory.getRecordType('Email','Service_Approver__c'));
            sa1.Email__c = 'testtest@test.com';
            serviceApproverList.add(sa1);
          
            Database.insert(serviceApproverList,false);
            
            test.startTest();
            ProgressCaseComponentController.getServiceApprovers(myCase.id);
            
            serviceApproverList[0].Requester_Only__c = false;
            serviceApproverList[1].Requester_Only__c = true;
            serviceApproverList[2].Requester_Only__c = true;
            Database.Update(serviceApproverList,false);
            ProgressCaseComponentController.getServiceApprovers(myCase.id);
            
            brlist.get(0).Multiple_Mandatory_Approvers__c=false;
            Database.update(brlist,true);
            ProgressCaseComponentController.getServiceApprovers(myCase.id);
            
            serviceApproverList[0].Requester_Only__c = true;
            serviceApproverList[1].Requester_Only__c = false;
            serviceApproverList[2].Requester_Only__c = true;
            Database.Update(serviceApproverList,false);
            ProgressCaseComponentController.getServiceApprovers(myCase.id);
            
            brlist.get(0).Active__c = false;
            Database.update(brlist,true);
            ProgressCaseComponentController.getServiceApprovers(myCase.id);
            test.stopTest();
            system.assert(brlist!=null);
            system.assert(myCase!=null);
        }
    }
    public static testmethod void openTest(){
        String rcdTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('Status Case').getRecordTypeId(); 
        Case cse = new Case(RecordTypeId = rcdTypeId);
        Database.insert(cse);
        test.startTest();
        ProgressCaseComponentController.openCase(cse.id);
        test.stopTest();
        system.assert([select id,status from case where id=:cse.id limit 1].Status == 'Open');
    }
    
    public static testmethod void closeTest(){
        String rcdTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('Status Case').getRecordTypeId(); 
        Case cse = new Case(RecordTypeId = rcdTypeId);
        Database.insert(cse);
        test.startTest();
        ProgressCaseComponentController.closeCase(cse.id);
        test.stopTest();
        system.assert([select id,status from case where id=:cse.id limit 1].Status == 'Closed');
    }
    
    public static testmethod void negativeTest(){
        String rcdTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('Status Case').getRecordTypeId(); 
        Case cse = new Case(RecordTypeId = rcdTypeId);
        test.startTest();
        ProgressCaseComponentController.openCase(cse.id);
        
        ProgressCaseComponentController.closeCase(cse.id);
        test.stopTest();
        system.assert(rcdTypeId!=null);
        
    }
    //SDT-9566 below two test methods
    public static testmethod void openStatus_SNP_PSIR_Test(){
         Id locationRecordTypeId = Schema.getGlobalDescribe().get(Constant_Util.ACCOUNT).getDescribe().getRecordTypeInfosByName().get(LOCATION).getRecordTypeId();
         Id clientRecordTypeId = Schema.getGlobalDescribe().get(Constant_Util.ACCOUNT).getDescribe().getRecordTypeInfosByName().get(Constant_Util.CLIENT).getRecordTypeId();
      	 test.startTest();
         List<Account> loc =[select id from account  where recordtypeid =: locationRecordTypeId limit 1 ];
         List<account> acc= [select id from account where recordtypeid =: clientRecordTypeId limit 1];
         String rcdTypeId = Schema.getGlobalDescribe().get(Constant_Util.OBJECT_CASE).getDescribe().getRecordTypeInfosByName().get(Constant_Util.STATUS_CASE).getRecordTypeId(); 
         Case cse = new Case(RecordTypeId = rcdTypeId,Client__c = acc[0].id, location__c=loc[0].id,Case_Type__c=Constant_Util.STATUS_CSTYPE,Source_System__c= Constant_Util.SOURCE_SALESFORCE,Case_Sub_Type__c=Constant_Util.SERVICE_NOT_PERFORMED);
         Database.insert(cse);
         ProgressCaseComponentController.openCase(cse.id);
         system.assert([select id,status from case where id=:cse.id limit 1].Status == Constant_Util.Case_Open_Status);
         system.assert([select id,status,Case_Sub_Status__c from case where id=:cse.id limit 1].Case_Sub_Status__c == Constant_Util.PENDING_SERVICE_ISSUE_RESOLUTION);
         test.stopTest();      
    }
    
     public static testmethod void openStatus_SNP_PVFU_Test(){
        String rcdTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('Status Case').getRecordTypeId(); 
        Case cse = new Case(RecordTypeId = rcdTypeId, Case_Type__c=Constant_Util.STATUS_CSTYPE,Source_System__c= Constant_Util.SOURCE_SALESFORCE,Case_Sub_Type__c='ETA');
        Database.insert(cse);
        test.startTest();
        ProgressCaseComponentController.openCase(cse.id);
        test.stopTest();
        system.assert([select id,status from case where id=:cse.id limit 1].Status == 'Open');
        system.assert([select id,status,Case_Sub_Status__c from case where id=:cse.id limit 1].Case_Sub_Status__c == Constant_Util.PENDING_VENDOR_FOLLOW_UP);
       
    }
}