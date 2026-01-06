/**
* @author Accenture
* @date 2/8/2019
* @description : Apex class ReqInfoServiceApproversTest 
test class for ReqInfoServiceApprovers
**/
@isTest(seeAllData = false)
public class ReqInfoServiceApproversTest {
    private static final string SYS_ADMIN = 'System Administrator';
    private static final string PRODUCT = '8 yrd';
    private static final string KROGER = 'kroger';
    private static final string RITA = 'Rita';
    private static final string REPLY = 'Reply';
    private static final string TESTSUPPLIER = 'testsupplier';
    private static final string SUPPLIER = 'Vendor';
    private static final string ASSET_NAME = '8 yrd Dumpster';
    private static final string CASE_NAME = 'First';
    private static final string PO_NUMBER = '1243';
    private static final string PICKUP = 'Pickup';
    private static final string EMPTY_AND_DO_NOT_RETURN = 'Empty and Do NOT Return';
    private static final string NAME = 'test';
    private static final string NAME1 = 'test1';
    private static final string CHANNEL_INFO ='Test Channel Instructions';
    private static final string PO_PSI_VALUE = 'PO Number;PSI';  //SDT-33363
    private static final string ENTITLEMENT2 = 'Entitlement2';
    private static final string TIME_VALUE = '23:59';
    private static final string DAYS = 'Days';
    private static final string DAYS_VALUE = '1';
    private static final string PENDING_APPROVAL = 'Pending Approval';
    private static final string REPAIRS = 'Repairs';
    private static final string PROJECT_VALUE = '123';
    private static final string HOURS = 'Hours';
    private static final string HOURS_VALUE = '12';
    private static final string COMPACTOR = 'COMPACTOR';
    private static final string TEMPORARY = 'Temporary';
    private static final string DISTRICT_MANAGER = 'District Manager';
    private static final string SENT = 'Sent';
    private static final string FAILED = 'Failed (Send Manually)';
    private static final string COMMERCIAL = 'Commercial';
    private static final string NY_TIMEZONE = 'America/New_York';
    private static final string WORK_COMPLETE = 'Work Complete';
    private static final string DELIVERED = 'Delivered';
    private static final string SCHEDULED = 'Scheduled';
    private static final string ACCEPTED = 'Accepted';
    private static final string CANCELLED = 'Cancelled';
    private static final string VALUE_TWO = '2';
    private static final string VALUE_TEST = 'Test';
    private static final string PHONE = '0123456789';
    private static final string TESTING = 'testing';
    private static final string POWER_OUTAGE = 'Power Outage';
    private static final string TIME_TEN = '10:00';
    private static final string VALUE_ZERO = '0';
    private static final string TEST_SLA_INS = 'Test SLA Instructions';
    private static final string TEST_USER_INS = 'Test User input instructions';
	private static final string PENDING_SCHEDULE_CONFIRMATION = 'Pending Schedule Confirmation';
    private static final string PROJECT_CODE_DETAIL= 'Project Code Detail';
      /**
* @author Accenture
* @date 2/27/2019
* @description : Apex method setup 
**/
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
            list<product2> productlist = TestDataFactory.createProduct(PRODUCT);
            productlist[0].Family = COMMERCIAL;
            productlist[0].ProductTypeSelected__c = COMPACTOR;
            Database.insert(productlist);
            list<Account> supplieracclist = TestDataFactory.createAccount(TESTSUPPLIER , usr, SUPPLIER);
            supplieracclist[0].AccountNumber = '600';
            Database.insert(supplieracclist);
            list<Asset> assetlist = TestDataFactory.createAsset(ASSET_NAME , acclist.get(0), conlist.get(0), 
                                                                productlist.get(0), usr, locationlist.get(0));
            List<Project_Code__c> pCodeList=TestDataFactory.createProjectCode(acclist.get(0).Id);
            Database.insert(pCodeList);
            assetlist[0].Supplier__c = supplieracclist[0].Id;
            assetlist[0].Project_Code__c = pCodeList[0].Id; 
            Database.insert(assetlist);
            list<Case> caselist = TestDataFactory.createCase( CASE_NAME, acclist.get(0), conlist.get(0), 
                                                             usr, locationlist.get(0), assetlist.get(0));
            caselist[0].PurchaseOrder_Number__c =  PO_NUMBER;
            caselist[0].Status = Constant_Util.PENDING;
            caselist[0].Case_Type__c = Constant_Util.PICKUP_CSTYPE;
            caselist[0].Case_Sub_Type__c = Constant_Util.EXTRA_PICKUP;
            caselist[0].Create_AM_and_PM_Pickups__c = true;
			caselist[2].Case_Sub_Status__c = Constant_Util.PENDING_SERVICE_INTEGRATION;
            Database.insert(caselist);
            
            list<Entitlement> entitlementlist = TestDataFactory.createEntitlement(NAME , locationlist.get(0));
            entitlementlist[1].service__c = Constant_Util.EXTRA_PICKUP;
            entitlementlist[0].service__c = Constant_Util.EXTRA_PICKUP;
            Database.insert(entitlementlist);
            System.debug('Entitlement++'+entitlementlist);
            
            list<Business_Rule__c> brlst1 = TestDataFactory.createBusinessRule(NAME,acclist.get(0),locationlist.get(0));
            brlst1[0].Service__c = Constant_Util.EXTRA_PICKUP;
            brlst1[0].Schedule_Type__c = Constant_Util.EMPTY_STRING;
            brlst1[0].Container__c = Constant_Util.EMPTY_STRING;
            brlst1[0].AssetId__c = assetlist[0].Id;
            brlst1[0].RecordTypeid = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.BUSINESS_NOTIFICATION).getRecordTypeId();
            brlst1[0].Special_Ins__c =  NAME1;
            brlst1[0].Channel_Req__c =  null;
            brlst1[0].Channel__c =  null;
            Database.insert(brlst1);
            
            list<Business_Rule__c> brlst2 = TestDataFactory.createBusinessRule(NAME,acclist.get(0),locationlist.get(0));
            brlst2[0].Service__c = Constant_Util.EXTRA_PICKUP;
            brlst2[0].Schedule_Type__c = Constant_Util.EMPTY_STRING;
            brlst2[0].Container__c = Constant_Util.EMPTY_STRING;
            brlst2[0].AssetId__c = assetlist[0].Id;
            brlst2[0].RecordTypeid = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.BUSINESS_NOTIFICATION).getRecordTypeId();
            brlst2[0].Channel_Req__c =  CHANNEL_INFO;
            brlst2[0].Channel__c =  'WM Portal';            
            Database.DMLOptions dmlOpts = new Database.DMLOptions();
            dmlOpts.DuplicateRuleHeader.allowSave = false;
            Database.insert(brlst2, dmlOpts);
            //Database.insert(brlst2);
            
            list<Business_Rule__c> brlst = TestDataFactory.createBusinessRule(NAME,acclist.get(0),locationlist.get(0));
            brlst[0].Service__c = Constant_Util.EXTRA_PICKUP;
            brlst[0].Schedule_Type__c = Constant_Util.EMPTY_STRING;
            brlst[0].Container__c = Constant_Util.EMPTY_STRING;
            brlst[0].AssetId__c = assetlist[0].Id;
            brlst[0].RecordTypeid = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.REQUIRED_INFORMATION).getRecordTypeId();
            brlst[0].Required_Information__c = PO_PSI_VALUE; 
            Database.insert(brlst);
            
            list<Business_Rule__c> brlist = TestDataFactory.createBusinessRule(Constant_Util.CONSTANT_FIRST, acclist.get(0), 
                                                                               locationlist.get(0));
            brlist[0].Service__c = Constant_Util.EXTRA_PICKUP;
            brlist[0].Schedule_Type__c = Constant_Util.EMPTY_STRING;
            brlist[0].Container__c = Constant_Util.EMPTY_STRING;
            brlist[0].AssetId__c = assetlist[0].Id;
            brlist[0].RecordTypeId = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.APPROVAL).getRecordTypeId();
            Database.insert(brlist);
            list<Account_Title__c> titlelst = TestDataFactory.createAccountTitle(acclist.get(0),DISTRICT_MANAGER);
            Database.insert(titlelst,false);
            list<Service_Approver__c> serviceApproverlist = TestDataFactory.createServiceApprover(brlist[0]);
            serviceApproverlist[0].Title__c = titlelst[0].Id;
            Database.insert(serviceApproverlist,false);
        }  
    }
    /*Test method to cover entitlement flow and Service Approvers*/
    @isTest static void withasset(){
        //test class errors - SDT - 33363
        user currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];

        
        system.runAs(currentuser){
            Account acc = [select id from Account where Recordtype.name =: Constant_Util.LOCATION limit 1];
            Asset asset = [select id from Asset LIMIT 1];
            Entitlement entitlement1 = [select id,Name,StartDate, AccountId, Call_Time__c, Before_After__c, 
                                        Schedule_Type__c, location__c, Service_Guarantee_Category__c,Status__c,service__c, 
                                        Service_Guarantee_Category_Value__c, EndDate, container__c,AssetId,Project_Code__c
                                        from Entitlement where EndDate =: null limit 1];
            system.debug('entitlement1++++'+entitlement1);
            list<Business_Rule__c> brlst = [Select Id,Accountid__c,locationid__c,Container__c,Service__c,Request_Type__c,Schedule_Type__c,Active__c,Effective_Date__c,RecordTypeid,
                                            Required_Information__c from  Business_Rule__c LIMIT 49999];
            brlst[0].Active__c = true;
            brlst[1].Active__c = true;
            brlst[2].Active__c = true;
            //brlst[3].Active__c = true;
            Database.Update(brlst,false);
            list<Service_Approver__c> salst = [Select Id, Business_Rule__c,Service_Approver__c.Title__c from Service_Approver__c LIMIT 49999];
            List<contact> conlst = [Select id,Account_Title__c from contact LIMIT 49999];
            conlst[0].Account_Title__c = salst[0].Title__c;
            Database.update(conlst,false);
            
            entitlement1.StartDate = system.today();
            entitlement1.Call_Time__c = null;
            entitlement1.Before_After__c = null;
            entitlement1.AssetId = asset.Id;
            entitlement1.Location__c = acc.Id;
            entitlement1.container__c = Constant_Util.EMPTY_STRING;
            entitlement1.Schedule_Type__c = Constant_Util.EMPTY_STRING; 
            entitlement1.Project_Code__c = null;
            entitlement1.SLA_Ins__c = TEST_SLA_INS;
            entitlement1.Service_Guarantee_Category__c = DAYS;
            entitlement1.Service_Guarantee_Category_Value__c = DAYS_VALUE;
            entitlement1.EndDate = null;
            
            Database.update(entitlement1);
            list<case> caselist = [select id, origin, contactid, Case_Type__c, Client__c, Location__c, Asset.Duration__c,Case_Sub_Status__c,Status,
                                   Asset.Product2.ProductTypeSelected__c, PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                   Service_Date__c,SlaStartDate,SLA_Service_Date_Time__c from case  where status =: Constant_Util.PENDING limit 1];
            list<Project_Code__c> pCodeList=[SELECT Id from Project_Code__c where RecordType.Name=:PROJECT_CODE_DETAIL];
            
            ReqInfoServiceApprovers.getInfo(caselist);
            
            entitlement1.AssetId = null;
            entitlement1.Call_Time__c = TIME_TEN;
            entitlement1.Before_After__c = Constant_Util.BEFORE;
            entitlement1.Service_Guarantee_Category_Value__c = VALUE_ZERO;
            entitlement1.container__c = Constant_Util.EMPTY_STRING;
            entitlement1.Schedule_Type__c = Constant_Util.EMPTY_STRING; 
            entitlement1.Project_Code__c = pCodeList[0].Id;
            entitlement1.Service_Guarantee_Category__c = HOURS;
            entitlement1.Service_Guarantee_Category_Value__c = HOURS_VALUE;
            Database.update(entitlement1);
            
            Test.startTest();
            ReqInfoServiceApprovers.getInfo(caselist);
            
            entitlement1.Call_Time__c = TIME_TEN;
            entitlement1.Before_After__c = Constant_Util.BEFORE;
            entitlement1.Project_Code__c = null;
            entitlement1.Container__c = COMPACTOR;
            entitlement1.Schedule_Type__c = TEMPORARY;
            Database.update(entitlement1,false);
            
            ReqInfoServiceApprovers.getInfo(caselist);
            
            entitlement1.Call_Time__c = '23:59';
            entitlement1.Container__c = Constant_Util.EMPTY_STRING;
            entitlement1.Schedule_Type__c = TEMPORARY;
            Database.update(entitlement1,false);
            
            ReqInfoServiceApprovers.getInfo(caselist);
            
            entitlement1.Schedule_Type__c = Constant_Util.EMPTY_STRING;
            entitlement1.Container__c = COMPACTOR;
            Database.update(entitlement1,false);
            
            ReqInfoServiceApprovers.getInfo(caselist);
            
            entitlement1.Location__c = acc.Id;
            entitlement1.Schedule_Type__c = Constant_Util.EMPTY_STRING;
            entitlement1.Container__c = Constant_Util.EMPTY_STRING;
            Database.update(entitlement1,false);
            
            ReqInfoServiceApprovers.getInfo(caselist);
            
            entitlement1.Location__c = null;
            entitlement1.Container__c = Constant_Util.EMPTY_STRING;
            Database.update(entitlement1,false);
            
            ReqInfoServiceApprovers.getInfo(caselist);
            
            entitlement1.Schedule_Type__c = TEMPORARY;
            Database.update(entitlement1,false);
            
            ReqInfoServiceApprovers.getInfo(caselist);
            Test.stopTest();
        }
    }
    
    /*Test method to cover entitlement flow and Service Approvers*/
    @isTest static void withoutasset(){
        //test class errors - SDT - 33363
        user currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        
        system.runAs(currentuser){
            Account acc = [select id from Account where Recordtype.name =: Constant_Util.LOCATION limit 1];
            Asset asset = [select id,Project_Code__c from Asset LIMIT 1];
            List<Entitlement> entitlementlst = [select id,Name,StartDate, AccountId, Call_Time__c, Before_After__c, 
                                        Schedule_Type__c, location__c, Service_Guarantee_Category__c,Status__c,service__c, 
                                        Service_Guarantee_Category_Value__c, EndDate, container__c,AssetId,Project_Code__c
                                        from Entitlement limit 49999];
            Database.delete(entitlementlst,false);
            list<Business_Rule__c> brlst = [Select Id,Accountid__c,Channel__c,locationid__c,Container__c,Service__c,Request_Type__c,Schedule_Type__c,Active__c,Effective_Date__c,RecordTypeid,
                                            Required_Information__c from  Business_Rule__c where RecordTypeid =: TestDataFactory.getRecordType(Constant_Util.BUSINESS_NOTIFICATION,'Business_Rule__c') LIMIT 49999];
            Business_Rule__c channelBr = new Business_Rule__c();
            for(Business_Rule__c b : brlst){
                if(b.Channel__c !=null){
                    channelBr = b;
                }
            }
            if(channelBr != null && channelBr.Id != null){
                Database.delete(channelBr);
            }
            Business_Rule__c br = [Select Id,Accountid__c,locationid__c,Container__c,Service__c,Request_Type__c,Schedule_Type__c,Active__c,Effective_Date__c,RecordTypeid,
                                            Required_Information__c from  Business_Rule__c where RecordType.DeveloperName = 'Approval' LIMIT 49999];
            br.Active__c = true;
            br.Multiple_Mandatory_Approvers__c = true;
            Database.update(br,false);
            list<Service_Approver__c> salst = [Select Id, Business_Rule__c,Service_Approver__c.Title__c from Service_Approver__c LIMIT 49999];
            List<contact> conlst = [Select id,Account_Title__c from contact LIMIT 49999];
            conlst[0].Account_Title__c = salst[0].Title__c;
            Database.update(conlst,false);
            
            list<case> caselist = [select id, origin, SlaStartDate,contactid, Case_Type__c, Client__c, Location__c, Asset.Duration__c,Case_Sub_Status__c,Status,
                                   Asset.Product2.ProductTypeSelected__c, PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                   Service_Date__c,SLA_Service_Date_Time__c from case  where status =: Constant_Util.PENDING limit 1];
            list<Project_Code__c> pCodeList=[SELECT Id from Project_Code__c where RecordType.Name=:PROJECT_CODE_DETAIL];            
            Entitlement entitlement1 = new Entitlement();
            entitlement1.Name = 'Test';
            entitlement1.AccountId = caselist[0].Client__c;
            entitlement1.Request_Type__c = caselist[0].Case_Type__c;
            entitlement1.service__c = caselist[0].Case_Sub_Type__c;
            entitlement1.AssetId = null;
            entitlement1.StartDate = system.today() - 1;
            entitlement1.EndDate = null;
            entitlement1.Call_On__c = 'Sun;Mon;Tue;Wed;Thu;Fri;Sat';
            entitlement1.Status__c = Constant_Util.APPROVED;
            entitlement1.Project_Code__c = pCodeList[0].Id;
            entitlement1.Container__c = Constant_Util.EMPTY_STRING;
            entitlement1.Schedule_Type__c = Constant_Util.EMPTY_STRING;
            entitlement1.Location__c = null;
            entitlement1.Service_Guarantee_Category__c = 'Days';
            entitlement1.Service_Guarantee_Category_Value__c = '2';
            entitlement1.Call_Time__c = null;
            Database.insert(entitlement1,false);
            Entitlement entitlement2 = [select id,Name,StartDate, AccountId, Call_Time__c, Before_After__c, 
                                        Schedule_Type__c, location__c, Service_Guarantee_Category__c,Status__c,service__c, 
                                        Service_Guarantee_Category_Value__c, EndDate, container__c,AssetId,Project_Code__c
                                        from Entitlement limit 1];
            ReqInfoServiceApprovers.getInfo(caselist);
            
            Test.startTest();
            entitlement1.Project_Code__c = null;
            entitlement1.Container__c = COMPACTOR;
            Database.update(entitlement1,false);
            
           	ReqInfoServiceApprovers.getInfo(caselist);
            
            entitlement1.Container__c = COMPACTOR;
            entitlement1.Schedule_Type__c = TEMPORARY;
            Database.update(entitlement1,false);
            
            ReqInfoServiceApprovers.getInfo(caselist);
            
            entitlement1.Container__c = COMPACTOR;
            entitlement1.Schedule_Type__c = TEMPORARY;
            entitlement1.Before_After__c = null;
            entitlement1.Call_Time__c = null;
            Database.update(entitlement1,false);
            
            ReqInfoServiceApprovers.getInfo(caselist);
            
            List<Entitlement> entitlementlst1 = [select id from Entitlement LIMIT 49999];
            Delete entitlementlst1;
            
           	ReqInfoServiceApprovers.getInfo(caselist);
            Test.stopTest();
        }
    }
}