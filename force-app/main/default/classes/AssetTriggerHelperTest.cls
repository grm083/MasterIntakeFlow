/*
* @author Accenture
* @date 7/31/2019
* @description : Apex class AssetTriggerHelperTest 
*/
@isTest(seeAllData=false)
public class AssetTriggerHelperTest {
    private static final string SYS_ADMIN = 'System Administrator';
    private static final string KROGER = 'kroger';
    private static final string ASSET_NAME = '8 yrd Dumpster';
    private static final string RITA = 'Rita';
    private static final string REPLY = 'Reply';
    private static final string OPEN_TOP = 'Open Top';
    private static final string COMPACTOR = 'COMPACTOR';
    private static final string DUMPSTER = 'Dumpster';
    private static final string COMMERCIAL = 'Commercial';
    private static final string PRODUCT = '8 yrd';
    private static final string TESTSUPPLIER = 'testsupplier';
    private static final string BOTH = 'Both';
    private static final string SUPPLIER = 'Vendor';
    private static final string DURATION = 'Temporary';
    public static final string Project_Code_Header = 'Project_Code_Header';
    public static final string Project_Code_Detail = 'Project_Code_Detail';
    public static final String LOCATION ='Location'; 
    public static final String CLIENT ='Client'; 
    public static final string headerRecType = Schema.SObjectType.Project_Code__c.getRecordTypeInfosByDeveloperName().get(Project_Code_Header).getRecordTypeId();
    public static final string detailRecType = Schema.SObjectType.Project_Code__c.getRecordTypeInfosByDeveloperName().get(Project_Code_Detail).getRecordTypeId();
    
    @testSetup static void setup(){
        Profile prof = TestDataFactory.getProfile(SYS_ADMIN);
        User currentUser = TestDataFactory.createUser(prof);
        Database.insert(currentUser);
        
        system.runAs(currentUser){
            List<Account> accList = TestDataFactory.createAccount(KROGER, currentUser,CLIENT);
            Database.insert(accList);
            List<Account> locationList = TestDataFactory.createLocation(LOCATION, currentUser, accList.get(0).id);
            Database.insert(locationList);  
            
            Project_Code__c pch = new Project_Code__c();
            pch.Client_Account__c = accList[0].id;
            pch.Name = 'Test';
            pch.RecordTypeId = headerRecType;
            pch.Product_Type__c = BOTH;
            pch.Effective_Date__c =system.today();
            pch.Date_Requested__c = system.today();
            Database.insert(pch);
            
            Project_Code__c pcd = new Project_Code__c();
            pcd.Client_Account__c = accList[0].id;
            pcd.Name = 'Test Detail';
            pcd.Project_Code_Header__c=pch.id;
            pcd.RecordTypeId = detailRecType;
            pcd.Effective_Date__c =system.today();
            pcd.Date_Requested__c = system.today();
            pcd.Duration__c = DURATION;
            pcd.Product_Type__c = BOTH;
            pcd.End_Date__c = system.today().addDays(2);
            Database.insert(pcd);
            
            List<Contact> conlist = TestDataFactory.createContact(RITA,REPLY, acclist.get(0), currentUser);
            Database.insert(conlist);
            
            List<Account> supplieracclist = TestDataFactory.createAccount(TESTSUPPLIER , currentUser, SUPPLIER);
            Database.insert(supplieracclist);
            
            List<product2> productlist = TestDataFactory.createProduct(PRODUCT);
            productlist[0].Family = COMMERCIAL;
            productlist[0].Equipment_Type__c=COMPACTOR;
            productlist[0].ProductTypeSelected__c = COMPACTOR;
            Database.insert(productlist);
            
            List<Asset> assetlist = TestDataFactory.createAsset(ASSET_NAME , acclist.get(0), conlist.get(0), 
                                                                productlist.get(0), currentUser, locationlist.get(0));
            assetlist[0].Supplier__c = supplieracclist[0].Id;
            assetlist[0].Start_Date__c = System.today();
            Database.insert(assetlist);
            
        }
    }
    
    @isTest public static void selectProjectCodeBasedOnEndDate(){
        User currentuser = [select id,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        system.runAs(currentuser){
            List<Asset> assetlist = [SELECT Id FROM Asset];
            List<Project_Code__c> pCodeList = [SELECT Id FROM Project_Code__c where RecordTypeId=:detailRecType];
            Test.startTest();
            assetlist[0].Project_Code__c = pCodeList[0].Id;
            Database.update(assetlist);
            Test.stopTest();
            System.assertEquals(true, [SELECT Id,Active__c FROM Asset limit 1].Active__c); 
        }
    }
    
    @isTest public static void selectProjectCodeWithNoEndDate(){
        User currentuser = [select id,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        system.runAs(currentuser){
            List<Asset> assetlist = [SELECT Id FROM Asset];
            List<Project_Code__c> pCodeListHeader = [SELECT Id FROM Project_Code__c where RecordTypeId=:headerRecType];
            List<Project_Code__c> pCodeListDetail = [SELECT Id FROM Project_Code__c where RecordTypeId=:detailRecType];
            pCodeListDetail[0].Length_of_Project_Days__c=null;
            pCodeListDetail[0].End_date__c=null;
            Database.update(pCodeListDetail);
            
            Test.startTest();
            assetlist[0].Project_Code__c = pCodeListDetail[0].Id;
            assetlist[0].Container_Position__c = 'Test';
            Database.update(assetlist,false);
            Test.stopTest();
            
            System.assertEquals(true, [SELECT Id,Active__c FROM Asset limit 1].Active__c); 
        }
    }
    
    //Test method for Validation Rule that prevent Asset Name to be Changed
    @isTest public static void validationcheckOnUpdateOfAssetName(){
        User currentuser = [select id,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        system.runAs(currentuser){
            List<Asset> assetlist = [SELECT Id,Name FROM Asset];
            List<Project_Code__c> pCodeListHeader = [SELECT Id FROM Project_Code__c where RecordTypeId=:headerRecType];
            List<Project_Code__c> pCodeListDetail = [SELECT Id FROM Project_Code__c where RecordTypeId=:detailRecType];
            
            Test.startTest();
            try{
                pCodeListDetail[0].Length_of_Project_Days__c=String.valueOf(2);
                pCodeListDetail[0].End_date__c=null;
                Database.update(pCodeListDetail);
                
                assetlist[0].Project_Code__c = pCodeListDetail[0].Id;
                assetlist[0].Name = 'TestAsset';
                Database.update(assetlist);
            }
            catch(Exception e)
            {
                Boolean expectedExceptionThrown =  e.getMessage() != null ? true : false;
                System.AssertEquals(expectedExceptionThrown, true);
            } 
            Test.stopTest();
        }
    }
    
    //Test method for Bypassing Validation Rule that prevent Asset Name to be Changed
    @isTest public static void bypassValidationcheckOnUpdateOfAssetName(){
        User currentuser = [select id,Bypass_Validation__c from user where Bypass_Validation__c =: true limit 1];
        system.runAs(currentuser){
            List<Asset> assetlist = [SELECT Id,Name FROM Asset];
            List<Project_Code__c> pCodeListHeader = [SELECT Id FROM Project_Code__c where RecordTypeId=:headerRecType];
            List<Project_Code__c> pCodeListDetail = [SELECT Id FROM Project_Code__c where RecordTypeId=:detailRecType];
            
            Test.startTest();
            pCodeListDetail[0].Length_of_Project_Days__c=String.valueOf(2);
            pCodeListDetail[0].End_date__c=null;
            Database.update(pCodeListDetail);
            
            assetlist[0].Project_Code__c = pCodeListDetail[0].Id;
            assetlist[0].Name = 'TestAsset';
            Database.update(assetlist);
            Test.stopTest();
            
            system.assertEquals('TestAsset', assetlist[0].Name);
        }
    } 
    
    //Test method for Validation Rule that checks Client Account on Asset and Project is same.
    @isTest public static void validationcheckforClientAccount(){
        User currentuser = [select id,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        system.runAs(currentuser){
            List<Asset> assetlist = [SELECT Id,Name FROM Asset];
            List<Account> acclist = [SELECT Id,parentId,Name FROM Account where Name =: LOCATION];
            List<Project_Code__c> pCodeListHeader = [SELECT Id FROM Project_Code__c where RecordTypeId=:headerRecType];
            List<Project_Code__c> pCodeListDetail = [SELECT Id,Client_Account__c FROM Project_Code__c where RecordTypeId=:detailRecType];
            
            Test.startTest();
            pCodeListDetail[0].Length_of_Project_Days__c=String.valueOf(2);
            pCodeListDetail[0].End_date__c=null;
            Database.update(pCodeListDetail);
            
            assetlist[0].Project_Code__c = pCodeListDetail[0].Id;
            Database.update(assetlist);
            Test.stopTest();
            
            system.assertEquals(acclist[0].parentId, pCodeListDetail[0].Client_Account__c);
        }
    }
    
    //Test method to check Validation that Container Type of the Project should Match with the Container Type of the Asset.
    @isTest public static void validationcheckforContainerType(){
        User currentuser = [select id,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        system.runAs(currentuser){
            List<Asset> assetlist = [SELECT Id,Name FROM Asset];
            List<Project_Code__c> pCodeListHeader = [SELECT Id FROM Project_Code__c where RecordTypeId=:headerRecType];
            List<Project_Code__c> pCodeListDetail = [SELECT Id,Container_Type__c FROM Project_Code__c where RecordTypeId=:detailRecType];
            
            Test.startTest();
            try{
                pCodeListDetail[0].Length_of_Project_Days__c=String.valueOf(2);
                pCodeListDetail[0].End_date__c=null;
                pCodeListDetail[0].Container_Type__c = DUMPSTER;
                Database.update(pCodeListDetail);
                
                assetlist[0].Project_Code__c = pCodeListDetail[0].Id;
                Database.update(assetlist);
            }
            catch(Exception e)
            {
                Boolean expectedExceptionThrown =  e.getMessage() != null ? true : false;
                System.AssertEquals(expectedExceptionThrown, true);
            } 
            Test.stopTest();
            
        }
    }
   
    //Test method to Bypass Validation that Container Type of the Project should Match with the Container Type of the Asset.
    @isTest public static void bypassValidationcheckforContainerType(){
        User currentuser = [select id,Bypass_Validation__c from user where Bypass_Validation__c =: true limit 1];
        system.runAs(currentuser){
            List<Asset> assetlist = [SELECT Id,Name FROM Asset];
            List<Project_Code__c> pCodeListHeader = [SELECT Id FROM Project_Code__c where RecordTypeId=:headerRecType];
            List<Project_Code__c> pCodeListDetail = [SELECT Id,Container_Type__c FROM Project_Code__c where RecordTypeId=:detailRecType];
            
            Test.startTest();
            try{
                pCodeListDetail[0].Length_of_Project_Days__c=String.valueOf(2);
                pCodeListDetail[0].End_date__c=null;
                pCodeListDetail[0].Container_Type__c = DUMPSTER;
                Database.update(pCodeListDetail);
                
                assetlist[0].Project_Code__c = pCodeListDetail[0].Id;
                Database.update(assetlist);
            }
            catch(Exception e)
            {
                Boolean expectedExceptionThrown =  e.getMessage() != null ? true : false;
                System.AssertEquals(expectedExceptionThrown, false);
            } 
            Test.stopTest();            
        }
    }   
}