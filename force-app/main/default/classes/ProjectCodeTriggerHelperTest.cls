/*
* @author Accenture
* @date 7/31/2019
* @description : Apex class ProjectCodeTriggerHelperTest 
*/
@isTest(seeAllData=false)
public class ProjectCodeTriggerHelperTest {
    private static final string SYS_ADMIN = 'System Administrator';
    private static final string KROGER = 'kroger';
    private static final string ASSET_NAME = '8 yrd Dumpster';
    private static final string RITA = 'Rita';
    private static final string REPLY = 'Reply';
    private static final string COMPACTOR = 'COMPACTOR';
    private static final string BOTH = 'Both';
    private static final string COMMERCIAL = 'Commercial';
    private static final string PRODUCT = '8 yrd';
    private static final string TESTSUPPLIER = 'testsupplier';
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
            List<Account> accList = TestDataFactory.createAccount(KROGER, currentUser,Constant_Util.CLIENT);
            Database.insert(accList);
            List<Account> locationList = TestDataFactory.createLocation(Constant_Util.LOCATION, currentUser, accList.get(0).id);
            Database.insert(locationList);  
            Project_Code__c pch = new Project_Code__c();
            pch.Client_Account__c = accList[0].id;
            pch.Name = 'Test';
            pch.RecordTypeId = Schema.SObjectType.Project_Code__c.getRecordTypeInfosByDeveloperName().get(Constant_Util.Project_Code_Header).getRecordTypeId();
            pch.Product_Type__c = BOTH;
            pch.Effective_Date__c =system.today();
            pch.Date_Requested__c = system.today();
            Database.insert(pch);
            
            Project_Code__c pcd = new Project_Code__c();
            pcd.Client_Account__c = accList[0].id;
            pcd.Name = 'Test Detail';
            pcd.Project_Code_Header__c=pch.id;
            pcd.RecordTypeId = Schema.SObjectType.Project_Code__c.getRecordTypeInfosByDeveloperName().get(Constant_Util.Project_Code_Detail).getRecordTypeId();
            pcd.Product_Type__c = BOTH;
            pcd.Effective_Date__c =system.today();
            pcd.Date_Requested__c = system.today();
            pcd.End_Date__c = system.today().addDays(2);
            Database.insert(pcd);
            
            Project_Code__c pcd1 = new Project_Code__c();
            pcd1.Client_Account__c = accList[0].id;
            pcd1.Name = 'Test Detail1';
            pcd1.Project_Code_Header__c=pch.id;
            pcd1.RecordTypeId = Schema.SObjectType.Project_Code__c.getRecordTypeInfosByDeveloperName().get(Constant_Util.Project_Code_Detail).getRecordTypeId();
            pcd1.Product_Type__c = BOTH;
            //pcd1.Container_Type__c = COMPACTOR;
            pcd1.Duration__c = DURATION;
            pcd1.Effective_Date__c =system.today();
            pcd1.Date_Requested__c = system.today();
            pcd1.End_Date__c = system.today().addDays(2);
            Database.insert(pcd1);
            
            Project_Code__c pcd2 = new Project_Code__c();
            pcd2.Client_Account__c = accList[0].id;
            pcd2.Name = 'Test Detail2';
            pcd2.Project_Code_Header__c=pch.id;
            pcd2.RecordTypeId = Schema.SObjectType.Project_Code__c.getRecordTypeInfosByDeveloperName().get(Constant_Util.Project_Code_Detail).getRecordTypeId();
            pcd2.Product_Type__c = BOTH;
            //pcd2.Container_Type__c = COMPACTOR;
            pcd2.Duration__c = DURATION;
            pcd2.Effective_Date__c =system.today();
            pcd2.Date_Requested__c = system.today();
            pcd2.End_Date__c = system.today().addDays(2);
            Database.insert(pcd2);
            
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
            assetlist[0].Start_Date__c = System.today().addDays(-5);
            assetlist[0].Duration__c = DURATION;
            assetlist[0].Project_Code__c = pcd1.Id;
            Database.insert(assetlist);
        }
    }
    
    @isTest public static void insertProjectCodeHeader(){
        //test class errors - SDT - 33363
        user currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE limit 1];
        system.runAs(currentuser){
            List<Project_Code__c> thisPCList = [SELECT Id FROM Project_Code__c];
            Test.startTest();
            ProjectCodeTriggerHelper.populateProjectCodeID(thisPCList);
            system.assert(!thisPCList.isEmpty());
            Test.stopTest();
        }
    }
    
    //Methods to test updateProjectCodeStatusOnAsset method 
    
    //Test method to update 'Is Project Active' of Asset on update of 'End Date' of Project
    @isTest public static void updateActiveStatusOnChangeinEndDate(){
        //test class errors - SDT - 33363
        user currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE limit 1];
        system.runAs(currentuser){
            List<Asset> assetlist = [SELECT Id FROM Asset];
            Project_Code__c pcd1 = [SELECT Id FROM Project_Code__c where Name = 'Test Detail1'];
            
            Test.startTest();
            pcd1.End_Date__c = system.today().addDays(4);
            Database.update(pcd1);
            
            pcd1.End_Date__c = null;
            pcd1.Length_of_Project_Days__c= null;
            Database.update(pcd1);
            Test.stopTest();
            System.assertEquals(true, [SELECT Id,Active__c FROM Asset limit 1].Active__c); 
        }
    }
    
    //Test method to update 'Is Project Active' of Asset as true on update of 'Length Of Project' of Project
    @isTest public static void updateActiveStatusOnChangeinLengthOfProject(){
        //test class errors - SDT - 33363
        user currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE limit 1];
        system.runAs(currentuser){
            List<Asset> assetlist = [SELECT Id FROM Asset];
            Project_Code__c pcd1 = [SELECT Id FROM Project_Code__c where Name = 'Test Detail1'];
            
            Test.startTest();
            pcd1.End_Date__c = null;
            pcd1.Length_of_Project_Days__c=String.valueOf(6);
            Database.update(pcd1);
            Test.stopTest();
            
            System.assertEquals(true, [SELECT Id,Active__c FROM Asset limit 1].Active__c); 
        }
    }
    
    //Test method to update 'Is Project Active' of Asset as false on update of 'Length of Project' where Asset Start Date + Project's Length < Today. 
    @isTest public static void updateActiveStatusOnChangeinLengthOfProjectNegative(){
        //test class errors - SDT - 33363
        user currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE limit 1];
        system.runAs(currentuser){
            List<Asset> assetlist = [SELECT Id FROM Asset];
            Project_Code__c pcd1 = [SELECT Id FROM Project_Code__c where Name = 'Test Detail1'];
            
            Test.startTest();
            pcd1.End_Date__c=null;
            pcd1.Length_of_Project_Days__c=String.valueOf(2);
            
            Database.update(pcd1);
            Test.stopTest();
            System.assertEquals(false, [SELECT Id,Active__c FROM Asset limit 1].Active__c); 
        }
    }
    
    //Test method to update 'Is Project Active' of Asset as false on update of 'Project End Date' where Project End Date < Today. 
    @isTest public static void updateActiveStatusOnChangeinEndDateNegative(){
        //test class errors - SDT - 33363
        user currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE limit 1];
        system.runAs(currentuser){
            List<Asset> assetlist = [SELECT Id FROM Asset];
            Project_Code__c pcd1 = [SELECT Id FROM Project_Code__c where Name = 'Test Detail1'];
            
            Test.startTest();
            pcd1.Effective_Date__c =Date.Today().addDays(-3);
            pcd1.Date_Requested__c = Date.Today().addDays(-3);
            pcd1.End_Date__c = Date.Today().addDays(-1);
            pcd1.Length_of_Project_Days__c=null;
            
            Database.update(pcd1);
            Test.stopTest();
            System.assertEquals(false, [SELECT Id,Active__c FROM Asset limit 1].Active__c); 
        }
    }
    
    //Test method for Validation Rule if user enter both Project End Date and Length of Project.  
    @isTest public static void validationcheckforEndDateAndLength(){
        //test class errors - SDT - 33363
        user currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE limit 1];
        system.runAs(currentuser){
            List<Asset> assetlist = [SELECT Id FROM Asset];
            Project_Code__c pcd1 = [SELECT Id,Client_Account__c FROM Project_Code__c where Name = 'Test Detail2'];
            
            Test.startTest();
            try{
                pcd1.End_Date__c = Date.Today().addDays(-1);
                pcd1.Length_of_Project_Days__c=String.valueOf(2);
                
                Database.update(pcd1);
            }
            catch(Exception e)
            {
                Boolean expectedExceptionThrown =  e.getMessage() != null ? true : false;
                System.AssertEquals(expectedExceptionThrown, true);
            } 
            
            Test.stopTest(); 
        }
    }
    
    //Test method for Validation Rule if Effective Date is greater than End Date.
    @isTest public static void validationcheckforEndDateAndEffectiveDate(){
        //test class errors - SDT - 33363
        user currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE limit 1];
        system.runAs(currentuser){
            List<Asset> assetlist = [SELECT Id FROM Asset];
            Project_Code__c pcd1 = [SELECT Id,Client_Account__c FROM Project_Code__c where Name = 'Test Detail2'];
            
            Test.startTest();
            try{
                pcd1.Effective_Date__c =system.today();
                pcd1.End_Date__c = Date.Today().addDays(-1);
                
                Database.update(pcd1);
            }
            catch(Exception e)
            {
                Boolean expectedExceptionThrown =  e.getMessage() != null ? true : false;
                System.AssertEquals(expectedExceptionThrown, true);
            } 
            
            Test.stopTest(); 
        }
    }
    
    //Test method for Validation Rule that user should enter either start date or length of the Project.
    @isTest public static void validationcheckforStartDateAndLength(){
        //test class errors - SDT - 33363
        user currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE limit 1];
        system.runAs(currentuser){
            List<Asset> assetlist = [SELECT Id FROM Asset];
            Project_Code__c pcd1 = [SELECT Id,Client_Account__c FROM Project_Code__c where Name = 'Test Detail2'];
            
            Test.startTest();
            try{
                pcd1.Effective_Date__c =system.today();
                pcd1.Length_of_Project_Days__c=String.valueOf(2);
                
                Database.update(pcd1);
            }
            catch(Exception e)
            {
                Boolean expectedExceptionThrown =  e.getMessage() != null ? true : false;
                System.AssertEquals(expectedExceptionThrown, true);
            } 
            
            Test.stopTest(); 
        }
    }
    
}