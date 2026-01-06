/**
* @author Accenture
* @date 2/27/2020
* @description : Apex class HoverOverCardsCntrlTest 
**/
/* test class for HoverOverCardsCntrl*/
@isTest(seeAllData = false)
public class HoverOverCardsCntrlTest {
    private static final string SYS_ADMIN = 'System Administrator';
    private static final string KROGER = 'kroger';
    private static final string RITA = 'Rita';
    private static final string REPLY = 'Reply';
    private static final string PRODUCT = '8 yrd';
    private static final string TESTSUPPLIER = 'testsupplier';
    private static final string SUPPLIER = 'Vendor';
    private static final string ASSET_NAME = '8 yrd Dumpster';
    private static final string COMMERCIAL = 'Commercial';
    private static final string NY_TIMEZONE = 'America/New_York';
    private static final string COMPACTOR = 'COMPACTOR';
    private static final string CASE_NAME = 'First';
    private static final string PO_NUMBER = '1243';
/* set the test data*/
    @testSetup static void setup() {
        Profile p = TestDataFactory.getProfile(SYS_ADMIN);
        User usr = TestDataFactory.createUser(p);
        usr.bypass_validation__c = true;
        Database.insert(usr);
        
        system.runAs(usr){
            list<Account> acclist = TestDataFactory.createAccount(KROGER, usr,Constant_Util.CLIENT);
            acclist[0].AccountNumber = 'HMD';
            Database.insert(acclist);
            list<Account> locationlist = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, acclist.get(0).id);
            locationlist[0].tz__Timezone_SFDC__c = NY_TIMEZONE;
            locationlist[0].tz__UTF_Offset__c = -4;
            Database.insert(locationlist);
            
            list<Contact> conlist = TestDataFactory.createContact(RITA,REPLY, acclist.get(0), usr);
            Database.insert(conlist);
            list<product2> productlist = TestDataFactory.createProduct('Test Product');
            productlist[0].Family = COMMERCIAL;
            productlist[0].ProductTypeSelected__c = 'Dumpster';
            productlist[0].Equipment_Type__c = 'Dumpster';
            Database.insert(productlist);
                       
            list<Account> supplieracclist = TestDataFactory.createAccount(TESTSUPPLIER , usr, SUPPLIER);
            supplieracclist[0].AccountNumber = '600';
            Database.insert(supplieracclist);
            list<Asset> assetlist = TestDataFactory.createAsset('Test Asset' , acclist.get(0), conlist.get(0), 
                                                                productlist.get(0), usr, locationlist.get(0));
            List<Project_Code__c> pCodeList=TestDataFactory.createProjectCode(acclist.get(0).Id);
            Database.insert(pCodeList);
            assetlist[0].Supplier__c = supplieracclist[0].Id;
            assetlist[0].Project_Code__c = pCodeList[0].Id;
            assetlist[0].Occurrence_Type__c = 'Scheduled';
            assetlist[0].Start_Date__c = system.today()-1;
            Database.insert(assetlist);
            list<Asset> childAssetlist = TestDataFactory.createChildAsset('Test Child asset1');
            childAssetlist[0].Service_Type__c = Constant_Util.PICKUP_CSTYPE;
            childAssetlist[0].Occurrence_Type__c = 'Scheduled';
            childAssetlist[0].Cost__c = 87;
            childAssetlist[0].Price__c = 95;
            childAssetlist[0].Service_Header_Id__c = assetlist[0].Id;
            childAssetlist[0].Has_Extra_Pickup__c = true;
            childAssetlist[0].Start_Date__c = system.today()-1;
            childAssetlist[1].Service_Type__c = Constant_Util.PICKUP_CSTYPE;
            childAssetlist[1].Occurrence_Type__c = 'On-Call';
            childAssetlist[1].Cost__c = 87;
            childAssetlist[1].Price__c = 99;
            childAssetlist[1].Start_Date__c = system.today()-1;
            childAssetlist[1].Has_Extra_Pickup__c = false;
            childAssetlist[1].Service_Header_Id__c = assetlist[0].Id;
            Database.insert(childAssetlist);
            list<Case> caselist = TestDataFactory.createCase( CASE_NAME, acclist.get(0), conlist.get(0), 
                                                             usr, locationlist.get(0), assetlist.get(0));
            caselist[0].PurchaseOrder_Number__c =  PO_NUMBER;
            caselist[0].Case_Type__c = Constant_Util.PICKUP_CSTYPE;
            caselist[0].Case_Sub_Type__c = Constant_Util.EXTRA_PICKUP;
            Database.insert(caselist[0]);
            list<product2> productlist1 = TestDataFactory.createProduct('Test Product2');
            productlist1[0].Family = Constant_Util.ROLLOFF;
            productlist1[0].ProductTypeSelected__c = 'Open Top';
            productlist1[0].Equipment_Type__c = 'Open Top';
            Database.insert(productlist1);
            List<Project_Code__c> pCodeList1=TestDataFactory.createProjectCode(acclist.get(0).Id);
            pCodeList1[0].Duration__c = Constant_Util.PERMANENT;
            Database.insert(pCodeList1);
            list<Asset> assetlist1 = TestDataFactory.createAsset(ASSET_NAME , acclist.get(0), conlist.get(0), 
                                                                productlist1.get(0), usr, locationlist.get(0));
            assetlist1[0].Supplier__c = supplieracclist[0].Id;
            assetlist1[0].Project_Code__c = pCodeList1[0].Id;
            assetlist1[0].Duration__c = Constant_Util.PERMANENT;
            assetlist1[0].Start_Date__c = system.today()-1;
            assetlist1[0].Occurrence_Type__c = Constant_Util.ON_CALL;
            Database.insert(assetlist1,true);
            
            Asset childAsset = new Asset();
            childAsset.Name = 'Childasset';
            childAsset.Service_Type__c = 'Haul';
            childAsset.Occurrence_Type__c = 'On-Call';
            childAsset.Cost__c = 87;
            childAsset.Price__c = 99;
            childAsset.Start_Date__c = system.today()-1;
            childAsset.Duration__c = Constant_Util.PERMANENT;
            childAsset.Service_Header_Id__c = assetlist1[0].Id;
            childAsset.Has_Extra_Pickup__c = false;
            childAsset.Recordtypeid = TestDataFactory.getRecordType('Service Detail','Asset');
            
            list<Asset> childAssetlist1 = TestDataFactory.createChildAsset(ASSET_NAME);
            childAssetlist1[0].Service_Type__c = 'Haul';
            childAssetlist1[0].Occurrence_Type__c = 'On-Call';
            childAssetlist1[0].Cost__c = 87;
            childAssetlist1[0].Price__c = 99;
            childAssetlist1[0].Start_Date__c = system.today()-1;
            childAssetlist1[0].Duration__c = Constant_Util.PERMANENT;
            childAssetlist1[0].Service_Header_Id__c = assetlist1[0].Id;
            childAssetlist1[0].Has_Extra_Pickup__c = false;
            childAssetlist1[1].Service_Type__c = 'Disposal';
            childAssetlist1[1].Occurrence_Type__c = 'On-Call';
            childAssetlist1[1].Cost__c = 87;
            childAssetlist1[1].Duration__c = Constant_Util.PERMANENT;
            childAssetlist1[1].Price__c = 99;
            childAssetlist1[1].Start_Date__c = system.today()-1;
            childAssetlist1[1].Has_Extra_Pickup__c = false;
            childAssetlist1[1].Service_Header_Id__c = assetlist1[0].Id;
            childAssetlist1.add(childAsset);
            Database.insert(childAssetlist1);
            list<Case> caselist1 = TestDataFactory.createCase('Test Case 2', acclist.get(0), conlist.get(0), 
                                                             usr, locationlist.get(0), assetlist1.get(0));
            caselist1[0].PurchaseOrder_Number__c =  PO_NUMBER;
            caselist1[0].Case_Type__c = Constant_Util.PICKUP_CSTYPE;
            caselist1[0].Case_Sub_Type__c = Constant_Util.EMPTY_AND_RETURN;
            Database.insert(caselist1[0]);
        }
    }
    /* test method to check HoverCards*/
    @isTest static void hovercardsRolloff(){
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(currentuser){
        list<case> caselist = [select id, origin, contactid, Case_Type__c, Client__c, Location__c, Status,Asset.ProductFamily,
                               PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c,Contact_Title__c,assetid,PSI__c,PSI_Comments__c,
                               Service_Date__c,SLA_Service_Date_Time__c from case where Case_Sub_Type__c = 'Empty and Return' limit 1];  
        list<Asset> asslst = [select id,ProductFamily,product2.Family from Asset Limit 2 ];
        list<product2> prodlst = [select id,Family,ProductTypeSelected__c,Equipment_Type__c from product2 Limit 2 ];
        Test.startTest();
        HoverOverCardsCntrl.Wrapper wp = HoverOverCardsCntrl.getServiceDetails(caselist[0]);
        Test.stopTest();
        System.assertEquals(wp.disposalCost,'87.00');
        System.assertEquals(wp.haulCost,null);
        }
    }
     /* test method to check HoverCards*/
    @isTest static void hovercardsCommercial(){
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(currentuser){
        list<case> caselist = [select id, origin, contactid, Case_Type__c, Client__c, Location__c, Status,Asset.ProductFamily,
                               PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c,Contact_Title__c,assetid,PSI__c,PSI_Comments__c,
                               Service_Date__c,SLA_Service_Date_Time__c from case where Case_Sub_Type__c = 'Extra Pickup' limit 1];  
        list<Asset> asslst = [select id,ProductFamily,product2.Family from Asset Limit 2 ];
        list<product2> prodlst = [select id,Family,ProductTypeSelected__c,Equipment_Type__c from product2 Limit 2 ];
        Test.startTest();
        HoverOverCardsCntrl.Wrapper wp = HoverOverCardsCntrl.getServiceDetails(caselist[0]);
        Test.stopTest();
        System.assertEquals(wp.pickUpCost,'87.00');
        System.assertEquals(wp.extraPickUpPrice,'99.00');
        }
    }
	
	/* test method to check HoverCards*/
    @isTest static void hovercardsCommercialPickUp(){
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(currentuser){
        list<case> caselist = [select id, origin, contactid, Case_Type__c, Client__c, Location__c, Status,Asset.ProductFamily,
                               PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c,Contact_Title__c,assetid,PSI__c,PSI_Comments__c,
                               Service_Date__c,SLA_Service_Date_Time__c from case where Case_Sub_Type__c =: Constant_Util.EXTRA_PICKUP limit 1];  
        list<Asset> asslst = [select id,ProductFamily,product2.Family from Asset Limit 2 ];
        list<product2> prodlst = [select id,Family,ProductTypeSelected__c,Equipment_Type__c from product2 Limit 2 ];
        Test.startTest();
        HoverOverCardsCntrl.Wrapper wp = HoverOverCardsCntrl.getServiceDetails(caselist[0]);
        Test.stopTest();
        System.assertEquals(wp.pickUpCost,'87.00');
        System.assertEquals(wp.pickUpPrice,'95.00');
        }
    }
	
	  /* test method to check Wrapper Class */
	@isTest static void getHoverServiceDetailstest(){
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(currentuser){
        list<case> caselist = [select id, origin, contactid, Case_Type__c, Client__c, Location__c, Status,Asset.ProductFamily,
                               PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c,Contact_Title__c,assetid,PSI__c,PSI_Comments__c,
                               Service_Date__c,SLA_Service_Date_Time__c from case where Case_Sub_Type__c = 'Extra Pickup' limit 1];  
        list<Asset> asslst = [select id,ProductFamily,product2.Family from Asset Limit 2 ];
        list<product2> prodlst = [select id,Family,ProductTypeSelected__c,Equipment_Type__c from product2 Limit 2 ];
        Test.startTest();
        HoverOverCardsCntrl.Wrapper wp = HoverOverCardsCntrl.getHoverServiceDetails(caselist[0].id);
        Test.stopTest();
        System.assertEquals(wp.pickUpCost,'87.00');
        System.assertEquals(wp.extraPickUpPrice,'99.00');
        }
    }
}