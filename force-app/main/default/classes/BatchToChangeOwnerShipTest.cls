/*************************************************************
@Name: BatchToChangeOwnerShipTest
@Author: WM
@CreateDate: 08/06/2020
@Description: Test class of BatchToChangeOwnerShip
**************************************************************/
@isTest
public class BatchToChangeOwnerShipTest {
    
    private static final string SYS_ADMIN = 'System Administrator';
    private static final string PRODUCT = '8 yrd';
    private static final string KROGER = 'kroger';
    private static final string RITA = 'Rita';
    private static final string REPLY = 'Reply';
    private static final string TESTSUPPLIER = 'testsupplier';
    private static final string SUPPLIER = 'Vendor';
    private static final string ASSET_NAME = '8 yrd Dumpster';
    private static final string CASE_NAME = 'First';       
    private static final string EMPTY_AND_DO_NOT_RETURN = 'Empty and Do NOT Return';
    private static final string NAME = 'test';
    private static final string NAME1 = 'test1';   
    private static final string PENDING_APPROVAL = 'Pending Approval';
    private static final string REPAIRS = 'Repairs';
    private static final string PROJECT_VALUE = '123';
    private static final string COMPACTOR = 'COMPACTOR';       
    private static final string COMMERCIAL = 'Commercial';
    private static final string NY_TIMEZONE = 'America/New_York';
    
    // method for setting up data    
    @testSetup static void setup() {
        List<User> testRunUserList = new List<User>();
        
        Profile p = TestDataFactory.getProfile(SYS_ADMIN);
        
        User usr = TestDataFactory.createUser(p);
        usr.Bypass_Validation__c = true;
        testRunUserList.add(usr);
        
        System.runAs(usr){
            List<Account> acclist = TestDataFactory.createAccount(KROGER, usr,Constant_Util.CLIENT);
            acclist[0].AccountNumber = 'HMD';
            
            Database.insert(acclist);
            
            List<Account> locationlist = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, acclist.get(0).id);
            
            locationlist[0].tz__Timezone_SFDC__c = NY_TIMEZONE;
            locationlist[0].tz__UTF_Offset__c = -4;
            Database.insert(locationlist);
            
            List<Contact> conlist = TestDataFactory.createContact(RITA, REPLY, acclist.get(0), usr);
            Database.insert(conlist);
            
            List<product2> productlist = TestDataFactory.createProduct(PRODUCT);
            productlist[0].Family = COMMERCIAL;
            productlist[0].ProductTypeSelected__c = COMPACTOR;
            Database.insert(productlist);
            
            list<Account> supplieracclist = TestDataFactory.createAccount(TESTSUPPLIER , usr, SUPPLIER);
            supplieracclist[0].AccountNumber = '600';
            Database.insert(supplieracclist);
            
            List<Project_Code__c> pCodeList = TestDataFactory.createProjectCode(acclist.get(0).Id);
            Database.insert(pCodeList);
            
            List<Asset> assetlist = TestDataFactory.createAsset(ASSET_NAME, acclist.get(0), conlist.get(0), productlist.get(0), usr, locationlist.get(0));
            assetlist[0].Supplier__c = supplieracclist[0].Id;
            assetlist[0].Project_Code__c = pCodeList[0].Id; 
            Database.insert(assetlist);
            
            List<Case> caselist = TestDataFactory.createCase(CASE_NAME, acclist.get(0), conlist.get(0), usr, locationlist.get(0), assetlist.get(0));
            Database.insert(caselist);               
        }
    }      
    
    @isTest static void batchToChangeOwnerShipTest(){
        String groupUser;
        String gnsysUser;
        groupUser = [SELECT Id, Id__c, DeveloperName 
                     FROM Generic_Values__mdt WHERE DeveloperName = 'Group_User'].Id__c;
        
        gnsysUser = [SELECT Id, Id__c, DeveloperName 
                     FROM Generic_Values__mdt WHERE DeveloperName = 'Genesys_User'].Id__c;
        
        List<Contact> ctlist =  [Select id,AccountId,name from Contact limit 1];
        
        List<Case>cslst = [Select Id,Origin,CreatedDate,Contact.Account.RecordtypeId,OwnerId,ContactId,status,RecordType.Name,CaseNumber,Case_Reason__c,Reference_Number__c,Case_Sub_Type__c,Case_Type__c,Last_Agent_ID__c,Location__c,Supplier__c,Client__c,Client__r.Customer_Code__c,Client__r.Primary_Segment__c,Client__r.ParentId,Client__r.Vendor_ID__c,Location__r.tz__Timezone__c,Location__r.Location_Code__c,Supplier__r.Name,Supplier__r.Vendor_ID__c,Subject,Supplier__r.ParentId,Supplier__r.Parent.Vendor_ID__c,Supplier__r.Parent.Name,Supplier__r.Parent.ParentId,AssetId,Asset.Project_Code__c,Asset.Project_Code__r.Active__c, Asset.Active__c from Case limit 4];
        
        cslst[0].status = 'New';
        cslst[0].Origin = 'Email';
        cslst[0].Ownerid = groupUser;
        cslst[1].status = 'New';
        cslst[1].Origin = 'Email';
        cslst[1].Ownerid = groupUser;
        cslst[2].status = 'New';
        cslst[2].Origin = 'Email';
        cslst[2].Ownerid = groupUser;
        update cslst;
        
        String Subject = Constant_Util.KEYWORD_TEST;
        String Body = Constant_Util.KEYWORD_TEST + ' lOCatioN # FAM002508';
        List<EmailMessage> lstEM = new List<EmailMessage>();
        lstEM = TestDataFactory.createEmailMessage(Subject, Body, cslst.get(0));
        lstEM[0].ParentId = cslst[0].id;
        lstEM[0].ToAddress = 'a@wm.com';
        lstEM[0].FromAddress = 'ab@wm.com';
        Database.insert(lstEM);
                
        Database.BatchableContext dbc;
        
        String cronexp = '0 0 0 * * ?';
        BatchToChangeOwnerShip b = new BatchToChangeOwnerShip();
        b.execute(dbc,cslst);
        Database.executeBatch(b);
        
        Test.startTest();
        
        String jobId = System.schedule('BatchToChangeOwnerShip',  cronexp, new BatchToChangeOwnerShip());
        CronTrigger cronTrgr = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId Limit 1];
        
        Test.stopTest();
        
        System.assertEquals(0, cronTrgr.TimesTriggered);
        
        List<Genesys_Routing__c> grlst = [select id from Genesys_Routing__c limit 1];
        System.assert(grlst !=null);
        
        List<Case> cslist = [select Id,Origin,CreatedDate,Contact.Account.RecordtypeId,OwnerId,ContactId,status,RecordType.Name,CaseNumber,Case_Reason__c,Reference_Number__c,Case_Sub_Type__c,Case_Type__c,Last_Agent_ID__c,Location__c,Supplier__c,Client__c,Client__r.Customer_Code__c,Client__r.Primary_Segment__c,Client__r.ParentId,Client__r.Vendor_ID__c,Location__r.tz__Timezone__c,Location__r.Location_Code__c,Supplier__r.Name,Supplier__r.Vendor_ID__c,Subject,Supplier__r.ParentId,Supplier__r.Parent.Vendor_ID__c,Supplier__r.Parent.Name,Supplier__r.Parent.ParentId,AssetId,Asset.Project_Code__c,Asset.Project_Code__r.Active__c, Asset.Active__c from Case limit 1];
        System.assert(cslist[0].Ownerid == gnsysUser);
		
		System.abortJob(cronTrgr.id);
        
        
    }
}