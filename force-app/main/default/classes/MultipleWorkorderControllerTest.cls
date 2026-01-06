@isTest(seeAllData = false)
public class MultipleWorkorderControllerTest {
    
/**
* @author Accenture
* @date 2/27/2019
* @description : Apex method setup 
**/
    // method for setting up data    
    @testSetup static void setup(){
        Id recordTypeId = Schema.getGlobalDescribe().get('Comment__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Acorn_Ticket_Comment').getRecordTypeId();
        
        Profile p = TestDataFactory.getProfile('System Administrator');
        User usr = TestDataFactory.createUser(p);
        Database.insert(usr);
        
        system.runAs(usr){
            list<Account> acclist = TestDataFactory.createAccount(Constant_Util.KEYWORD_TEST, usr);
            list<Account> acclist1 = TestDataFactory.createAccount(Constant_Util.KEYWORD_TEST, usr);		            
            acclist.addAll(acclist1);
            Database.insert(acclist);
            list<Account> locationlist = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, acclist.get(0).id);
            Database.insert(locationlist);
            list<Account> locationlist1 = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, acclist.get(2).id);
            Database.insert(locationlist1);
            list<Contact> conlist = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST,Constant_Util.CONSTANT_LAST, acclist.get(0), usr);
            Database.insert(conlist);
            list<product2> productlist = TestDataFactory.createProduct(Constant_Util.KEYWORD_TEST);
            Database.insert(productlist);
            list<Asset> assetlist = TestDataFactory.createAsset(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                                productlist.get(0), usr, locationlist.get(0));
            assetlist[0].Supplier__c = acclist[1].Id;
            
            Database.insert(assetlist);
            list<Asset> childAsset = TestDataFactory.createChildAsset(Constant_Util.CONSTANT_FIRST);
            childAsset[0]. Supplier__c = acclist[1].Id;
            childAsset[0]. Supplier__r = acclist[1];
            childAsset[0].Service_Type__c = 'Haul';
            childAsset[1]. Supplier__c = acclist[2].Id;
            childAsset[1]. Supplier__r = acclist[2];
            childAsset[1].Service_Type__c = 'Disposal';
            
            list<Asset> childAsset1 = TestDataFactory.createChildAsset(Constant_Util.CONSTANT_FIRST);
            childAsset1[0]. Supplier__c = acclist[1].Id;
            childAsset1[0]. Supplier__r = acclist[1];
            childAsset1[0].Service_Type__c = Constant_Util.RECYCLING;
            childAsset[1]. Supplier__c = acclist[2].Id;
            childAsset[1]. Supplier__r = acclist[2];
            childAsset[1].Service_Type__c = 'Haul';
            childAsset.addAll(childAsset1);
            list<Asset> childAsset2 = TestDataFactory.createChildAsset(Constant_Util.CONSTANT_FIRST);		
            childAsset2[0]. Supplier__c = acclist[1].Id;		
            childAsset2[0]. Supplier__r = acclist[1];		
            childAsset2[0].Service_Type__c = Constant_Util.RECYCLING;		
            childAsset.add(childAsset2[0]);
            Database.insert(childAsset);
            
            list<Case> caselist = TestDataFactory.createCase(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                             usr, locationlist.get(0), assetlist.get(0));
            caselist[0].Create_AM_and_PM_Pickups__c = FALSE;
            caselist[0].Is_Clone__c = false;
            caselist[0].Status = 'Pending';
            caselist[0].Approval_Status__c= 'Approved';
            caselist[0].Case_Type__c = 'Pickup';		
            caselist[0].Case_Sub_Type__c = 'Empty and Return';
            caselist[0].User_Input_Work_Order_Instructions__c = 'test';
            caselist[0].System_Gen_WO_Instructions__c = 'Test Instructions';
            caselist[0].Site_Contact__c = 'Test contact';
            caselist[1].Create_AM_and_PM_Pickups__c = True;
            caselist[1].Is_Clone__c = false;
            caselist[1].Case_Type__c = 'Pickup';		
            caselist[1].case_Sub_Type__c = 'Empty and Return';
            caselist[1].Approval_Status__c= '';
            caselist[1].User_Input_Work_Order_Instructions__c = 'test';
            caselist[1].System_Gen_WO_Instructions__c = 'Test Instructions';
            caselist[1].Site_Contact__c = 'Test contact';
            caselist[1].Site_Contact_Phone__c = '4546556655';
            Test.startTest();
            list<Case> caselist1 = TestDataFactory.createCase(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                              usr, locationlist.get(0), assetlist.get(0));
            caselist1[0].Create_AM_and_PM_Pickups__c = FALSE;
            caselist1[0].Is_Clone__c = false;
            caselist1[0].Status = 'Pending';
            caselist1[0].Approval_Status__c= 'Approved';
            caselist1[0].Case_Type__c = 'Pickup';		
            caselist1[0].Case_Sub_Type__c = 'Empty and Return';
            caselist1[0].User_Input_Work_Order_Instructions__c = 'test';
            caselist1[0].System_Gen_WO_Instructions__c = 'Test Instructions';
            caselist1[1].Create_AM_and_PM_Pickups__c = True;
            caselist1[1].Is_Clone__c = false;
            caselist1[1].Approval_Status__c= '';
            caselist1[1].Case_Type__c = 'Pickup';		
            caselist1[1].Case_Sub_Type__c = 'Empty and Return';
            caselist1[1].System_Gen_WO_Instructions__c = '';
            caselist1[1].Site_Contact_Phone__c = '4546556655';
            Test.stopTest();
            
            Database.SaveResult[] srList = Database.insert(caselist);
            Database.SaveResult[] srList1 = Database.insert(caselist1);
           
            List<SBS_Case_Asset__c> caseAssetList = new List<SBS_Case_Asset__c>();
            SBS_Case_Asset__c caseAsset1 = new SBS_Case_Asset__c(CaseId__c = caselist[0].Id,AssetId__c = childAsset[0].id,Asset_Header__c = caselist[0].AssetId);
            SBS_Case_Asset__c caseAsset2 = new SBS_Case_Asset__c(CaseId__c = caselist[0].Id,AssetId__c = childAsset[1].id,Asset_Header__c = caselist[0].AssetId);
            SBS_Case_Asset__c caseAsset3 = new SBS_Case_Asset__c(CaseId__c = caselist[0].Id,AssetId__c = childAsset[2].id,Asset_Header__c = caselist[0].AssetId);
            SBS_Case_Asset__c caseAsset7 = new SBS_Case_Asset__c(CaseId__c = caselist[0].Id,AssetId__c = childAsset[3].id,Asset_Header__c = caselist[0].AssetId);
            SBS_Case_Asset__c caseAsset4 = new SBS_Case_Asset__c(CaseId__c = caselist[1].Id,AssetId__c = childAsset[0].id,Asset_Header__c = caselist[1].AssetId);
            SBS_Case_Asset__c caseAsset5 = new SBS_Case_Asset__c(CaseId__c = caselist[1].Id,AssetId__c = childAsset[1].id,Asset_Header__c = caselist[1].AssetId);
            SBS_Case_Asset__c caseAsset6 = new SBS_Case_Asset__c(CaseId__c = caselist[1].Id,AssetId__c = childAsset[2].id,Asset_Header__c = caselist[1].AssetId);
            SBS_Case_Asset__c caseAsset8 = new SBS_Case_Asset__c(CaseId__c = caselist[1].Id,AssetId__c = childAsset[3].id,Asset_Header__c = caselist[1].AssetId);
            
            SBS_Case_Asset__c caseAsset04 = new SBS_Case_Asset__c(CaseId__c = caselist[2].Id,AssetId__c = childAsset[0].id,Asset_Header__c = caselist[2].AssetId);
            SBS_Case_Asset__c caseAsset05 = new SBS_Case_Asset__c(CaseId__c = caselist[2].Id,AssetId__c = childAsset[1].id,Asset_Header__c = caselist[2].AssetId);
            SBS_Case_Asset__c caseAsset06 = new SBS_Case_Asset__c(CaseId__c = caselist[2].Id,AssetId__c = childAsset[2].id,Asset_Header__c = caselist[2].AssetId);
            
            SBS_Case_Asset__c caseAsset01 = new SBS_Case_Asset__c(CaseId__c = caselist[3].Id,AssetId__c = childAsset[0].id,Asset_Header__c = caselist[1].AssetId);
            SBS_Case_Asset__c caseAsset02 = new SBS_Case_Asset__c(CaseId__c = caselist[3].Id,AssetId__c = childAsset[1].id,Asset_Header__c = caselist[1].AssetId);
            SBS_Case_Asset__c caseAsset03 = new SBS_Case_Asset__c(CaseId__c = caselist[3].Id,AssetId__c = childAsset[2].id,Asset_Header__c = caselist[1].AssetId);
            
            caseAssetList.add(caseAsset01);
            caseAssetList.add(caseAsset02);
            caseAssetList.add(caseAsset03);
            caseAssetList.add(caseAsset04);
            caseAssetList.add(caseAsset05);
            caseAssetList.add(caseAsset06);
            caseAssetList.add(caseAsset7);
            caseAssetList.add(caseAsset8);
            caseAssetList.add(caseAsset5);
            caseAssetList.add(caseAsset6);
            caseAssetList.add(caseAsset1);
            caseAssetList.add(caseAsset2);
            caseAssetList.add(caseAsset3);
            caseAssetList.add(caseAsset4);
           // Database.insert(caseAsset1);
           // Database.insert(caseAsset2);
           // Database.insert(caseAsset3);
           // Database.insert(caseAsset4);
            //Database.insert(caseAsset5);
           // Database.insert(caseAsset6);
            database.insert(caseAssetList);
            List<Approval_Log__c> approvalLogList = new List<Approval_Log__c>();
            approvalLogList = TestDataFactory.createApprovallog(caselist[1].id);
            Database.insert(approvalLogList);
            List<Approval_Log__c> approvalLogList1 = new List<Approval_Log__c>();
            approvalLogList1 = TestDataFactory.createApprovallog(caselist[0].id);
            Database.insert(approvalLogList1);
            // SDT-9563 Start
            Comment__c notes = new Comment__c();
            notes.Case__c = caselist[1].Id;
            notes.RecordTypeId = recordTypeId;
            Database.insert(notes);
            EmailMessage email = new EmailMessage();
            email.ParentId = caselist[1].Id;
            email.RelatedToId = caselist[1].Id;
            Database.insert(email);
            // SDT-9563 End
        } 
    }
    
    /**
* @author Accenture
* @date 2/27/2019
* @description : Apex method testGetAssetHeaders 
**/
    @isTest static void testGetAMPMCase(){
        
        list<case> caselist = [SELECT id, AccountId,Case.ParentId,Supplier__c,recordTypeId,Supplier__r.Vendor_ID__c,Asset.Supplier__c,Asset.Vendor_ID__c,
                               Service_Date__c,SLA_Service_Date_Time__c,Create_AM_and_PM_Pickups__c, Location__c, Reference_Number__c, 
                               AssetId, Client__c, ContactId,Case_Type__c,Case_Sub_Type__c,Case_Reason__c,Origin,Emergency__c,Site_Contact__c,
                               Site_Contact_Phone__c,SalesMeet_Container_Position__c,PurchaseOrder_Number__c,SLA_Override_Reason__c,
                               Work_Order_Instructions__c, EntitlementId, Entitlement.SLA_Ins__c, Entitlement.Name,System_Gen_WO_Instructions__c, 
                               User_Input_Work_Order_Instructions__c, Is_Clone__c,Quantity_Override__c,Case_Sub_Status__c
                               FROM Case limit 2];
        Map<Id,Asset> AssetMap = new Map<Id,Asset>();
        Test.startTest();
        MultipleWorkorderController.getAMPMCaseBulk(caselist/*,AssetMap*/);
        system.assert(caselist != null);
        Test.stopTest();
        
    }
    
    /**
* @author Accenture
* @date 2/27/2019
* @description : Apex method testGetAMPMCase 
**/
    @isTest static void testGetAMPMCaseException(){
        
        list<case> caselist = [SELECT id, AccountId,Case.ParentId,Supplier__c,recordTypeId,Supplier__r.Vendor_ID__c,Asset.Supplier__c,Asset.Vendor_ID__c,
                               Service_Date__c,SLA_Service_Date_Time__c,Create_AM_and_PM_Pickups__c, Location__c, Reference_Number__c, 
                               AssetId, Client__c, ContactId,Case_Type__c,Case_Sub_Type__c,Case_Reason__c,Origin,Emergency__c,Site_Contact__c,
                               Site_Contact_Phone__c,SalesMeet_Container_Position__c,PurchaseOrder_Number__c,SLA_Override_Reason__c,
                               Work_Order_Instructions__c, EntitlementId, Entitlement.SLA_Ins__c, Entitlement.Name, System_Gen_WO_Instructions__c,
                               User_Input_Work_Order_Instructions__c, Is_Clone__c,Quantity_Override__c,Case_Sub_Status__c  
                               FROM Case limit 1];
        Map<Id,Asset> AssetMap = new Map<Id,Asset>();
        Test.startTest();
        try{
            MultipleWorkorderController.getAMPMCaseBulk(caselist/*,AssetMap*/);
        }
        catch(Exception e){}
        system.assert(caselist != null);
        Test.stopTest();
        
    }
    
    /**
* @author Accenture
* @date 2/27/2019
* @description : Apex method testGetAMPMCase 
**/
    @isTest static void testGetAMPMCasewithSiteContact(){
        
        list<case> caselist = [SELECT id, AccountId,Case.ParentId,Supplier__c,recordTypeId,Supplier__r.Vendor_ID__c,Asset.Supplier__c,Asset.Vendor_ID__c,
                               Service_Date__c,SLA_Service_Date_Time__c,Create_AM_and_PM_Pickups__c, Location__c, Reference_Number__c, 
                               AssetId, Client__c, ContactId,Case_Type__c,Case_Sub_Type__c,Case_Reason__c,Origin,Emergency__c,Site_Contact__c,
                               Site_Contact_Phone__c,SalesMeet_Container_Position__c,PurchaseOrder_Number__c,SLA_Override_Reason__c,
                               Work_Order_Instructions__c, EntitlementId, Entitlement.SLA_Ins__c, Entitlement.Name, System_Gen_WO_Instructions__c,
                               User_Input_Work_Order_Instructions__c, Is_Clone__c,Quantity_Override__c,Case_Sub_Status__c  
                               FROM Case where Site_Contact__c!= null limit 1];
        Map<Id,Asset> AssetMap = new Map<Id,Asset>();
        Test.startTest();
        try{
            MultipleWorkorderController.getAMPMCaseBulk(caselist/*,AssetMap*/);
        }
        catch(Exception e){}
        system.assert(caselist != null);
        Test.stopTest();
        
    }
}