/**
* @author Accenture
* @date 2/27/2019
* @description : Apex class AssetHeadersForCaseControllerTest 
**/
@isTest(seeAllData = false)
public class AssetHeadersForCaseControllerTest {

/**
* @author Accenture
* @date 2/27/2019
* @description : Apex method setup 
**/
// method for setting up data    
    @testSetup static void setup() {
        Profile p = TestDataFactory.getProfile('System Administrator');
		User usr = TestDataFactory.createUser(p);
        //User usr = TestDataFactory.createUser();
        Database.insert(usr);  
        system.runAs(usr){
            list<Account> acclist = TestDataFactory.createAccount(Constant_Util.KEYWORD_TEST, usr);
            Database.insert(acclist);
            list<Account> locationlist = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, acclist.get(0).id);
            Database.insert(locationlist);
            list<Contact> conlist = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST,Constant_Util.CONSTANT_LAST, acclist.get(0), usr);
            Database.insert(conlist);
            list<product2> productlist = TestDataFactory.createProduct(Constant_Util.KEYWORD_TEST);
			productlist[0].Family = 'Rolloff';
            Database.insert(productlist);
            list<Asset> assetlist = TestDataFactory.createAsset(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                                productlist.get(0), usr, locationlist.get(0));
            assetlist[0]. Supplier__c = acclist[1].Id;
            Database.insert(assetlist);
            Asset srvcDetail = TestDataFactory.createChildAsset('Test Asset')[0];
            srvcDetail.Service_Header_Id__c	 = assetlist[0].Id;
            srvcDetail.Is_Core_Service__c = true;
            srvcDetail.ParentId = assetlist[0].Id;
            Database.Insert(srvcDetail);
            Test.startTest();
            list<Case> caselist = TestDataFactory.createCase(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                             usr, locationlist.get(0), assetlist.get(0));
            caselist[0].Service_Date__c = system.today() + 1;
            caselist[0].PurchaseOrder_Number__c =  Constant_Util.PO_VALUE_TEST;
            Database.insert(caselist);
            list<Case> testCaselist = TestDataFactory.createCase(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                             usr, locationlist.get(0), assetlist.get(0));
            testCaselist[0].Reference_Number__c = caselist[0].CaseNumber;
            testCaselist[0].Is_Multiple_Asset__c = true;
            testCaselist[0].AssetId = assetlist[0].Id;
            testCaselist[0].Origin = 'Officetrax';
            Database.insert(testCaselist);
            Test.stopTest();
        } 
        
    }
/**
* @author Accenture
* @date 2/27/2019
* @description : Apex method testGetAssetHeaders 
**/
    @isTest static void testGetAssetHeaders(){
        user currentuser = [select id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        system.runAs(currentuser){
            list<case> caselist = [select id, origin, contactid, Case_Type__c, Client__c, Location__c, 
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                   Service_Date__c,SLA_Service_Date_Time__c from case limit 1];
            caselist[0].Is_Multiple_Asset__c = true;
            Database.update(caselist[0]);
	     //SDT- 33363
            //Case childcase = caselist[0].clone(false, false, false, false);
            //database.insert(childcase);
            Test.startTest();
            List<AssetHeadersForCaseController.DataWrapper> assetHeaders = AssetHeadersForCaseController.getAssetHeaders(caselist[0].id);
            system.assert(assetHeaders != null);
            Test.stopTest();
        }
    }
    
/**
* @author Accenture
* @date 2/27/2019
* @description : Apex method testSaveOrReplaceAssetHeaderSuccess 
**/
     @isTest static void testSaveOrReplaceAssetHeaderSuccess(){
        string[] assetlist = new String[]{};
            Cache.SessionPartition sessionPart = Cache.Session.getPartition(Constant_UTIL.MULTI_ASSET_PARTITION);    
        user currentuser = [select id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        system.runAs(currentuser){
            list<case> caselist = [select id, Reference_Number__c,origin, contactid, Case_Type__c, Client__c, Location__c, 
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                   Service_Date__c,SLA_Service_Date_Time__c from case limit 1];
            System.assertEquals(1, [SELECT Id from case where Reference_Number__c= :caselist[0].Reference_Number__c].size());
            list<Asset> assets = [select id,name from Asset limit 2];
            Test.startTest();   
            String caseStatus = AssetHeadersForCaseController.getStatusForCase(caselist[0].id);
            system.assertEquals(Constant_UTIL.STATUS_NEW,caseStatus);
            AssetHeadersForCaseController.replaceAssetHeader(caselist[0].id,assets[0].id,new String[]{});	//TCS-pkulkarn-SDT-42417-SDT-42734-Added a null string as 3rd parameter (instead of null) to fix test class error
            System.assertEquals(1, [SELECT Id from case where Reference_Number__c= :caselist[0].Reference_Number__c].size());
            System.assertEquals(assets[0].id, [SELECT AssetId from case where Reference_Number__c= :caselist[0].Reference_Number__c].AssetId);
            System.assertEquals(null,sessionPart.get(caselist[0].Id));
            Test.stopTest();
        }
    }
    
/**
* @author Accenture
* @date 2/27/2019
* @description : Apex method testSaveAssetHeaderFailure 
**/
    @isTest static void testSaveAssetHeaderFailure(){
        string[] assetlist = new String[]{};
            user currentuser = [select id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        system.runAs(currentuser){
            list<Account> acclist = [select id, name from account limit 1];
            list<Asset> childAssetlist = TestDataFactory.createChildAsset(Constant_Util.TEST_ASSET);
            childAssetlist[0]. Supplier__c = null;
            Database.insert(childAssetlist);
            list<case> caselistTest = [select id, origin, contactid, Case_Type__c, Client__c, Location__c, 
                                       PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                       Service_Date__c,SLA_Service_Date_Time__c from case limit 1];
            assetlist.add(childAssetlist[0].id);
            Test.startTest(); 
            try{
                AssetHeadersForCaseController.replaceAssetHeader(caselistTest[0].id,childAssetlist[0].id,new String[]{});
            }
            catch(Exception ex){
                system.assert(ex != null);
            }
            Test.stopTest();
        }
    }
	
	 @isTest static void showMutipleAssetCasesInfoTest(){
        user currentuser = [select id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        system.runAs(currentuser){
            list<case> caselist = [select id,status,Is_Multiple_Asset__c,CaseNumber,ParentId,origin, contactid, Case_Type__c, Client__c, Location__c, 
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                   Service_Date__c,SLA_Service_Date_Time__c from case limit 2];
            caselist[0].Is_Multiple_Asset__c = true;           
            caselist[1].Service_Date__c = System.today() - 1;
            caselist[1].ParentId = caselist[0].Id; 
            caselist[1].Is_Multiple_Asset__c = true;
            caselist[1].Reference_Number__c = caselist[0].CaseNumber;
            
            Database.update(caselist[0]);
            Database.update(caselist[1]);
           
            list<Asset> assets = [select id,name from Asset limit 2];
            list<Account> acclist = [select id, name from account limit 1];
            List<Account> locationList =[Select Location_Type__c,RecordTypeid,ParentId from account where ParentId =:acclist AND RecordType.DeveloperName=: Constant_Util.LOCATION LIMIT 1];
            
     
            List<Business_Rule__c> brlist = TestDataFactory.createBusinessRule(Constant_Util.TEST_BUSINESS_RULE,accList.get(0),locationList.get(0));
            brlist.get(0).RecordTypeId = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.APPROVAL).getRecordTypeId();
        
            brlist.get(0).Active__c = true; 
            brlist.get(0).Container__c=Constant_Util.EMPTY_STRING;
            brlist.get(0).Schedule_Type__c=Constant_Util.EMPTY_STRING;
            brlist.get(0).Project_Code__c=null;
            brlist.get(0).AssetId__c = assets[0].id;
            brlist.get(0).Multiple_Mandatory_Approvers__c=true;
            brlist.get(0).Occurrence_Limit__c = 1;
            brlist.get(0).Special_Instructions_Approval__c = 'Test Approval Ins';
            Database.insert(brlist,true);
            
            list<Task> tasklist = TestDataFactory.createTask(caselist.get(0).id,currentuser);
            tasklist[0].RecordTypeId = TestDataFactory.getRecordType(Constant_Util.APPROVALS,Constant_Util.OBJECT_TASK);
            tasklist[0].Process__c = Constant_Util.OBTAIN_SERVICE_APPROVAL;
            tasklist[0].status = Constant_Util.OPEN;
            tasklist[0].whatid = caselist[1].id;
            Database.insert(tasklist);
            
            Test.startTest();
            AssetHeadersForCaseController.showMutipleAssetCasesInfo(caselist[0].CaseNumber,caselist[0].id,caselist[1].ParentId,8);
            system.assert(caselist != null);
            Test.stopTest();
        }
    }
    
    /**
* @author Accenture
* @date 7/2/2019
* @description : Apex method showMutipleAssetCasesTest 
**/
    @isTest static void showMutipleAssetCasesTest(){
        user currentuser = [select id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        system.runAs(currentuser){
        list<case> caselist = [select id, origin, contactid, Case_Type__c, Client__c, Location__c, 
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                   Service_Date__c,SLA_Service_Date_Time__c from case limit 1];
        Test.startTest();
        List<Case> testCaseList = AssetHeadersForCaseController.showMutipleAssetCases(caselist[0].id);
        system.assert(testCaseList != null);
        Test.stopTest();
        }
    }
    
    /**
* @author Accenture
* @date 7/2/2019
* @description : Apex method multipleAssetCaseTest 
**/
    @isTest static void multipleAssetCaseTest(){
        string[] assetlist = new String[]{};
            Cache.SessionPartition sessionPart = Cache.Session.getPartition(Constant_UTIL.MULTI_ASSET_PARTITION);
        user currentuser = [select id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        system.runAs(currentuser){
            list<case> caselist = [select id,Reference_Number__c, ParentId, origin, contactid, Case_Type__c, Client__c, Location__c, 
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                   Service_Date__c,SLA_Service_Date_Time__c from case limit 1];
            list<Asset> assets = [select id,name from Asset limit 2];
            assetlist.add(assets[0].id);
            Test.startTest();
            AssetHeadersForCaseController.replaceAssetHeader(caselist[0].id,null,assetlist);
            System.assertEquals(1, [SELECT Id from case where Reference_Number__c= :caselist[0].Reference_Number__c].size());
            List<AssetHeadersForCaseController.DataWrapper> assetHeaders = AssetHeadersForCaseController.getAssetHeaders(caselist[0].id);
            System.assertEquals(assetlist,sessionPart.get(caselist[0].Id));
            Test.stopTest();
        }
    }
    
     @isTest static void multipleAssetCaseTestWithoutPriorAsset(){
        string[] assetlist = new String[]{};
            Cache.SessionPartition sessionPart = Cache.Session.getPartition(Constant_UTIL.MULTI_ASSET_PARTITION);
        user currentuser = [select id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        system.runAs(currentuser){
            list<case> caselist = [select id,Reference_Number__c, ParentId, origin, contactid, Case_Type__c, Client__c, Location__c, 
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                   Service_Date__c,SLA_Service_Date_Time__c from case limit 1];
            list<Asset> assets = [select id,name from Asset limit 2];
            caselist[0].assetId=null;
            update caselist;
            System.assertEquals(null, [SELECT AssetId from case where Reference_Number__c= :caselist[0].Reference_Number__c].AssetId);
            assetlist.add(assets[1].id);
            System.assertEquals(null,sessionPart.get(caselist[0].Id)); 
            Test.startTest();   
            AssetHeadersForCaseController.replaceAssetHeader(caselist[0].id,assets[0].id,assetlist);
            System.assertEquals(1, [SELECT Id from case where Reference_Number__c= :caselist[0].Reference_Number__c].size());
            System.assertEquals(assets[0].id, [SELECT Id,AssetId from case where Reference_Number__c= :caselist[0].Reference_Number__c].AssetId);
            System.assertEquals(assetlist,sessionPart.get(caselist[0].Id));
            Test.stopTest();
        }
    }
    
 /**
* @author Accenture
* @date 7/2/2019
* @description : Apex method multipleAssetCaseTest 
**/
    @isTest static void moveToNextRelatedAssetCaseTest(){
        user currentuser = [select id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        system.runAs(currentuser){
        list<case> caselist = [select id, origin, contactid, Case_Type__c, Client__c, Location__c, 
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                   Service_Date__c,SLA_Service_Date_Time__c from case limit 1];
        Test.startTest();   
        String status = AssetHeadersForCaseController.moveToNextRelatedAssetCase(caselist[0].id);
        system.assert(status != null);
        Test.stopTest();
        }
    }
    
    @isTest static void getCaseDetailsTest(){
        user currentuser = [select id,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        system.runAs(currentuser){
        list<case> caselist = [SELECT id, origin, contactid, Case_Type__c, Client__c, Location__c, 
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                   Service_Date__c, Show_Multiple_Asset_Cases__c, SLA_Service_Date_Time__c
                                FROM Case LIMIT 1];
        Test.startTest();   
        Case cse = AssetHeadersForCaseController.getCaseDetails(caselist[0].id);
        system.assert(cse != null);
        Test.stopTest();
        }
    }    
    
     @isTest static void testDisableCheck(){
        user currentuser = [SELECT id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        system.runAs(currentuser){
            List<Case> caselist = [SELECT Id, Status, Show_Multiple_Asset_Cases__c, AssetId,Origin 
                                   FROM Case LIMIT 1];
            Test.startTest();   
            List <Case> cse = AssetHeadersForCaseController.disableCheck(caselist[0].id); 
            Test.stopTest();

            system.assertEquals(cse[0].Show_Multiple_Asset_Cases__c, caselist[0].Show_Multiple_Asset_Cases__c);
            system.assert(cse != null);
        }
    }
}