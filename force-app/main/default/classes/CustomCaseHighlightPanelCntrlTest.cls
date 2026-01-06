@isTest(seeAllData = false)
public class CustomCaseHighlightPanelCntrlTest {
    private static final string OTHER ='Other';
    private static final String LOCATION = 'Location';
    private static final string TEST_NAME ='Test';
    private static final String NUM_123 = '123';
    private static final string REQ_INFO ='PSI ;PO NUMBER;Company Category'; //SDT-33363(3)
    private static final String CONTACT_NOT_ONSITE = 'Contact Not Onsite';
    private static final string COMPACTOR = 'COMPACTOR';
    private static final string COMMERCIAL = 'Commercial';
    private static final String PICKUP = 'Pickup';
    
    // method for setting up data    
    @testSetup static void setup() {
        Profile p = TestDataFactory.getProfile('System Administrator');
		User usr = TestDataFactory.createUser(p);
        Database.insert(usr);  
        system.runAs(usr){
            list<Account> acclist = TestDataFactory.createAccount(Constant_Util.KEYWORD_TEST, usr);
            Database.insert(acclist);
            list<Account> locationlist = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, acclist.get(0).id);
            Database.insert(locationlist);
            list<Contact> conlist = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST,Constant_Util.CONSTANT_LAST, acclist.get(0), usr);
            Database.insert(conlist);
            list<product2> productlist = TestDataFactory.createProduct(Constant_Util.KEYWORD_TEST);
            productlist[0].ProductTypeSelected__c = COMPACTOR;
            productlist[0].Family = COMMERCIAL;
            Database.insert(productlist);
            list<Asset> assetlist = TestDataFactory.createAsset(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                                productlist.get(0), usr, locationlist.get(0));
            Database.insert(assetlist);
            list<Case> caselist = TestDataFactory.createCase(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                             usr, locationlist.get(0), assetlist.get(0));
            caselist[0].Service_Date__c = system.today() + 1;
            caselist[0].Case_Sub_Status__c = Constant_Util.INTEGRATION_ERROR;
            Database.insert(caselist);
        }
    }
    
@isTest static void isAssetMandatoryTest(){
	user currentuser = [select id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
	system.runAs(currentuser){
		list<case> caselist = [select id, origin, contactid, Case_Type__c, Client__c, Location__c,
		PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
		Service_Date__c,SLA_Service_Date_Time__c from case limit 1];
		
		POProfileDisable__mdt poProfile = [Select id,CaseType__c,IsEnable__c from POProfileDisable__mdt];
        
		Id caseRecId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Constant_Util.SERVICE_REQUEST_CASE).getRecordTypeId();
		caselist[0].RecordTypeId = caseRecId;
		caselist[0].Case_Type__c = Constant_Util.ADD;
		caselist[0].Case_Sub_Type__c = 'Equipment';
		caselist[0].Case_Reason__c = 'Compactor';
		Database.update(caselist);
		Test.startTest();
		CustomCaseHighlightPanelCntrl.Wrapper wrap = CustomCaseHighlightPanelCntrl.getCaseHighlightDetails(caselist[0].id);
		system.assert(!wrap.isAssetMandatory);
		Test.stopTest();
	}
}
    
    @isTest static void getCaseHighlightDetailsTest(){
        user currentuser = [select id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        system.runAs(currentuser){
            list<case> caselist = [select id, origin, contactid, Case_Type__c, Client__c, Location__c, 
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                   Service_Date__c,SLA_Service_Date_Time__c from case limit 1];
            
            caselist[0].RecordTypeId = TestDataFactory.getRecordType(Constant_Util.New_Service_Case, 'Case');
            caselist[0].Case_Type__c = 'New Service';
            caselist[0].Case_Sub_Type__c = 'Permanent';
            caselist[0].Case_Reason__c = 'Existing Location';
            caselist[0].Status = 'New';
            caselist[0].assetid = null;
            update caselist[0];
            
            list<Business_Rule__c> brlist = new list<Business_Rule__c>();
            Business_Rule__c brObj = new Business_Rule__c();
            brObj.Accountid__c = caselist[0].Client__c;
            brObj.LocationId__c = caselist[0].Location__c;
            brObj.Request_Type__c = 'New Service';
            brObj.Service__c = 'Permanent';
            brObj.RecordTypeid = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.REQUIRED_INFORMATION).getRecordTypeId();
            brObj.Required_Information__c = 'PO Number'; 
            brObj.Effective_Date__c = System.today()-1;
            brObj.Active__c=True;
            brlist.add(brObj);
            Database.insert(brlist);
            
            Test.startTest();   
            CustomCaseHighlightPanelCntrl.Wrapper wrap = CustomCaseHighlightPanelCntrl.getCaseHighlightDetails(caselist[0].id);
            system.assert(wrap != null);
            Test.stopTest();
        }
    }
    
    @isTest public static void testBusinessRulePo(){
        User currentUser = [select id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        system.runAs(currentUser){
        List<Account> accList = [SELECT Id from Account LIMIT 49999];
        List<Contact> conlist = [SELECT Id from Contact where AccountId =: accList LIMIT 49999];
        List<product2> productlist = [SELECT Id from product2 LIMIT 49999];
        List<Asset> assetlist = [SELECT Id,Product2.ProductTypeSelected__c,Duration__c,Project_Code__c FROM Asset where AccountId =:accList AND 
                                 ContactId =:conlist AND product2Id =:productlist LIMIT 49999];
        List<Account> locationList =[Select Location_Type__c,RecordTypeid,ParentId from account where ParentId =:accList AND RecordType.DeveloperName=: LOCATION LIMIT 1];
       	Case myCase = [SELECT Id,AssetId  from Case WHERE AccountId =:accList AND AssetId =:assetlist LIMIT 1];
        myCase.PurchaseOrder_Number__c=Constant_Util.EMPTY_STRING;
        myCase.Override_PO_Create_Task__c=false;
        myCase.SLA_Override_Reason__c = OTHER;
        myCase.SLA_Override_Comment__c=TEST_NAME;
        myCase.SlaStartDate = system.now().addHours(1);
        Database.update(myCase);
        List<Business_Rule__c> brlist = TestDataFactory.createBusinessRule(Constant_Util.TEST_BUSINESS_RULE,accList.get(0),locationList.get(0));
        brlist.get(0).RecordTypeId = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.REQUIRED_INFORMATION).getRecordTypeId();
        brlist[0].Required_Information__c = Constant_Util.PO_NUMBER;
        brlist[0].Effective_Date__c = System.today() - 1;
        brlist[0].End_Date__c = system.today() + 5;
        brlist[0].Active__c = true; 
      	brlist[0].Container__c=Constant_Util.EMPTY_STRING;
        brlist[0].Schedule_Type__c=Constant_Util.EMPTY_STRING;
        brlist[0].Project__c=Constant_Util.EMPTY_STRING;
        brlist[0].AssetId__c = assetlist[0].id;
        Database.insert(brlist,true);
        test.startTest();
        CustomCaseHighlightPanelCntrl.getCaseHighlightDetails(myCase.id);
        test.stopTest();
        system.assert(brlist!=null);
        system.assert(myCase!=null);
        }
    }

	     /*  SDT-33363 - commented as profile value is made inactive in required information record type
     @isTest public static void testBusinessRuleProfile(){
        User currentUser = [select id, Bypass_Validation__c from user LIMIT 1];
        system.runAs(currentUser){
        List<Account> accList = [SELECT Id from Account LIMIT 49999];
        List<Contact> conlist = [SELECT Id from Contact where AccountId =: accList LIMIT 49999];
        List<product2> productlist = [SELECT Id from product2 LIMIT 49999];
        List<Asset> assetlist = [SELECT Id,Product2.ProductTypeSelected__c,Duration__c,Project_Code__c FROM Asset where AccountId =:accList AND 
                                 ContactId =:conlist AND product2Id =:productlist LIMIT 49999];
        List<Account> locationList =[Select Location_Type__c,RecordTypeid,ParentId from account where ParentId =:accList AND RecordType.DeveloperName=: LOCATION LIMIT 1];
       	Case myCase = [SELECT Id,AssetId  from Case WHERE AccountId =:accList AND AssetId =:assetlist LIMIT 1];
        myCase.Profile_Number__c=Constant_Util.EMPTY_STRING;
        myCase.Override_Profile_Number_Task__c=false;
        myCase.SLA_Override_Reason__c = OTHER;
        myCase.SLA_Override_Comment__c=TEST_NAME;
        myCase.SlaStartDate = system.now().addHours(1);
        Database.update(myCase);
        List<Business_Rule__c> brlist = TestDataFactory.createBusinessRule(Constant_Util.TEST_BUSINESS_RULE,accList.get(0),locationList.get(0));
        brlist.get(0).RecordTypeId = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.REQUIRED_INFORMATION).getRecordTypeId();
        brlist[0].Required_Information__c = Constant_Util.PROFILE_NUMBER;
        brlist[0].Effective_Date__c = System.today() - 1;
        brlist[0].End_Date__c = system.today() + 5;
        brlist[0].Active__c = true; 
      	brlist[0].Container__c=Constant_Util.EMPTY_STRING;
        brlist[0].Schedule_Type__c=Constant_Util.EMPTY_STRING;
        brlist[0].Project__c=Constant_Util.EMPTY_STRING;
        brlist[0].AssetId__c = assetlist[0].id;
        Database.insert(brlist,true);
        test.startTest();
        CustomCaseHighlightPanelCntrl.getCaseHighlightDetails(myCase.id);  
        test.stopTest();
        system.assert(brlist!=null);
        system.assert(myCase!=null);
        }
    } */
    
    @isTest public static void testBusinessRulePSI(){
        
        User currentUser = [select id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        system.runAs(currentUser){
            List<Account> accList = [SELECT Id from Account LIMIT 49999];
            List<Contact> conlist = [SELECT Id from Contact where AccountId =: accList LIMIT 49999];
            List<product2> productlist = [SELECT Id from product2 LIMIT 49999];
            List<Asset> assetlist = [SELECT Id,Product2.ProductTypeSelected__c,Duration__c,Project_Code__c FROM Asset where AccountId =:accList AND 
                                     ContactId =:conlist AND product2Id =:productlist LIMIT 49999];
            List<Account> locationList =[Select Location_Type__c,RecordTypeid,ParentId from account where ParentId =:accList AND RecordType.DeveloperName=: LOCATION LIMIT 1];
            Case myCase = [SELECT Id,AssetId,Status,AccountId,PSI_Comments__c,PSI_Override_Reason__c,PSI__c from Case WHERE AccountId =:accList AND AssetId =:assetlist AND ContactId =:conlist LIMIT 1];
            SBS_Case_Asset__c sbsCaseAsset = new SBS_Case_Asset__c ( AssetId__c = assetlist[0].id ,CaseId__c= myCase.id);
            Database.insert(sbsCaseAsset,true);
            myCase.Status=Constant_Util.STATUS_New;
            myCase.Case_Sub_type__c = Constant_Util.EXTRA_PICKUP;
            myCase.PurchaseOrder_Number__c =  Constant_Util.EMPTY_STRING;
            myCase.Override_PO_Create_Task__c =false;
            Database.update(myCase);
            List<Business_Rule__c> brlist = TestDataFactory.createBusinessRule(Constant_Util.TEST_BUSINESS_RULE,accList.get(0),locationList.get(0));
            brlist.get(0).RecordTypeId = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.REQUIRED_INFORMATION).getRecordTypeId();
            brlist.get(0).Required_Information__c = Constant_Util.PO_NUMBER;
            brlist.get(0).Effective_Date__c = System.today() - 1;
            brlist.get(0).End_Date__c = system.today() + 5;
            brlist.get(0).Active__c = true; 
            brlist.get(0).Service__c = Constant_Util.EXTRA_PICKUP;
            brlist.get(0).Container__c=Constant_Util.EMPTY_STRING;
            brlist.get(0).Schedule_Type__c=Constant_Util.EMPTY_STRING;
            brlist.get(0).Project_Code__c=null;
            brlist.get(0).AssetId__c = myCase.AssetId;
            Database.insert(brlist,true);
            test.startTest();
            CustomCaseHighlightPanelCntrl.getCaseHighlightDetails(myCase.id);  
            brlist.get(0).Required_Information__c = Constant_Util.PSI;
            Database.update(brlist,true);
            CustomCaseHighlightPanelCntrl.getCaseHighlightDetails(myCase.id);  
            myCase.PSI_Override_Reason__c = Constant_Util.OTHER_API;
            myCase.PSI_Comments__c = Constant_Util.EMPTY_STRING;
            myCase.Override_PO_Create_Task__c =true;
            myCase.Case_Type__c= PICKUP;
            
            Database.update(myCase,true);
            brlist.get(0).Required_Information__c = REQ_INFO;
            Database.update(brlist,true);
            CustomCaseHighlightPanelCntrl.getCaseHighlightDetails(myCase.id);  
            myCase.Case_Type__c= PICKUP;
            myCase.PSI_Comments__c = TEST_NAME;
            myCase.PSI__c = 8;
            
            myCase.PSI_Override_Reason__c = CONTACT_NOT_ONSITE;
            Database.update(myCase,true);
            CustomCaseHighlightPanelCntrl.getCaseHighlightDetails(myCase.id); 
	    CustomCaseHighlightPanelCntrl.updateBRonCase(myCase.id,brlist[0].Id,'PO Number;Profile Number'); 
            Test.stopTest();
            system.assert(myCase.PSI__c!=null);
    }

    } 
    @isTest static void getCapacityEligibilty_Test()
    {
        List<Case> cselist = [SELECT id FROM CASE LIMIT 1];
        Boolean  result = CustomCaseHighlightPanelCntrl.getCapacityEligibilty(cselist.get(0).id);
        system.assert(result==false);
    }
	
    @isTest static void getQueue_Test()
    {
        String  result = CustomCaseHighlightPanelCntrl.getQueueName('123456');
        System.assert(result != '');
    }
    //SDT 39047
    @isTest static void isBillingTest(){
        
	user currentuser = [select id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
	system.runAs(currentuser){
		list<case> caselist = [select id, origin, contactid, Case_Type__c, Client__c, Location__c,
		PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
		Service_Date__c,SLA_Service_Date_Time__c from case limit 1];
		Id caseRecId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Standard Case').getRecordTypeId();
        BillingService billing = new BillingService();
		caselist[0].RecordTypeId = caseRecId;
		caselist[0].Case_Type__c = billing.CASE_TYPE_BILLING;
		caselist[0].Case_Sub_Type__c = billing.CASE_SUB_TYPE_Invoice_Charge_Dispute;
		caselist[0].Case_Reason__c = 'Customer Short Pay';
		Database.update(caselist);
		Test.startTest();
		CustomCaseHighlightPanelCntrl.Wrapper wrap = CustomCaseHighlightPanelCntrl.getCaseHighlightDetails(caselist[0].id);
        system.assertEquals(wrap.isAssetMandatory,true, 'data filled');
		Test.stopTest();
	}
}
}