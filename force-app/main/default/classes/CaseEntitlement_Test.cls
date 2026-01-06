@isTest(seeAllData = false)
public class CaseEntitlement_Test {
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
    private static final string PO_PSI_VALUE = 'PO Number;PSI';
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
    private static final String BEFORE = 'Before'; 
    private static final string POWER_OUTAGE = 'Power Outage';
    private static final string TIME_TEN = '10:00';
    private static final string VALUE_ZERO = '0';
    private static final string TEST_SLA_INS = 'Test SLA Instructions';
    private static final string TEST_USER_INS = 'Test User input instructions';
    private static final string PENDING_SCHEDULE_CONFIRMATION = 'Pending Schedule Confirmation';
    private static final string PROJECT_CODE_EHEADER = 'Project Code Header';
    private static final string PROJECT_CODE_DETAIL= 'Project Code Detail';
    private static final string BASKET = 'Basket';
    private static final string BALER = 'Baler';
    private static final string GOT_JUNK_PICKUP = 'Got Junk Pickup';
    private static final string SUPPLIES = 'Supplies';
    private static final string CUSTOMER_SERVICE = 'Customer Service';
    private static final string SERVICE = 'Service';
    private static final string STANDARD = 'Standard Case';
    private static final string GENERAL = 'General';
    private static final string OTHER = 'Other';
    private static final string WOEMAILTEMPLATE = 'Customer: Request Approved_VF';
    private static final string DEVWOEMAILTEMPLATE = 'Customer_Request_Approved_Vf';
    private static final string TEXT = 'text';
    private static final string EQUIPMENT_QUESTIONS = 'Equipment Questions';
    private static final string SERVICE_DAYS_UNKNOWN = 'Service Days Unknown';
    private static final string APPROVED = 'Approved';    
    private static final string EMAIL = 'test@wm.com';
    
    /* set the test data*/
    @testSetup static void setup() {
        List<User> testRunUserList = new List<User>();
        
        Profile p = TestDataFactory.getProfile(SYS_ADMIN);
        
        User usr = TestDataFactory.createUser(p);
        usr.Bypass_Validation__c = true;
        testRunUserList.add(usr);
        
        User nonByPassValidationUser = TestDataFactory.createUser(p);
        nonByPassValidationUser.Username = 'SystemAdmin'+ String.valueof(system.now().millisecond())+'@testorg.com.wm';
        testRunUserList.add(nonByPassValidationUser);
        Database.insert(testRunUserList);
        
        System.runAs(usr){
            List<Account> acclist = TestDataFactory.createAccount(KROGER, usr,Constant_Util.CLIENT);
            acclist[0].AccountNumber = 'HMD';
            
            Database.insert(acclist);
            
            List<Account> locationlist = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, acclist.get(0).id);
            
            locationlist[0].tz__Timezone_SFDC__c = NY_TIMEZONE;
            locationlist[0].tz__UTF_Offset__c = -4;
            Database.insert(locationlist);
            
            List<Contact> conlist = TestDataFactory.createContact(RITA, REPLY, acclist.get(0), usr);
            conlist[0].Preferred_Method__c='Email';
            Database.insert(conlist);
            
            List<product2> productlist = TestDataFactory.createProduct(PRODUCT);
            productlist[0].Family = COMMERCIAL;
            productlist[0].ProductTypeSelected__c = COMPACTOR;
            Database.insert(productlist);
            
            list<Account> supplieracclist = TestDataFactory.createAccount(TESTSUPPLIER , usr, SUPPLIER);
            supplieracclist[0].AccountNumber = '600';
            Database.insert(supplieracclist);
            system.debug('**********8supplieracclist: '+supplieracclist);
            
            List<Project_Code__c> pCodeList = TestDataFactory.createProjectCode(acclist.get(0).Id);
            Database.insert(pCodeList);
            system.debug('**********pCodeList: '+pCodeList);
            List<Asset> assetlist = TestDataFactory.createAsset(ASSET_NAME, acclist.get(0), conlist.get(0), productlist.get(0), usr, locationlist.get(0));
            assetlist[0].Supplier__c = supplieracclist[0].Id;
            assetlist[0].Project_Code__c = pCodeList[0].Id; 
            system.debug('**********assetlist: '+assetlist);
            Database.insert(assetlist);
            
            Generic_Values__mdt objGV = new Generic_Values__mdt();
            
            String objuser;
            objUser = [Select Id, Id__c, DeveloperName from Generic_Values__mdt where DeveloperName = 'Genesys_User'].Id__c;
            
            List<Case> caselist2 = TestDataFactory.createCase(CASE_NAME, acclist.get(0), conlist.get(0), usr, locationlist.get(0), assetlist.get(0));
            caselist2[0].OwnerId =  objuser;
            
            try{
                Database.insert(caselist2);
            } catch(Exception ex){
                system.debug('Exception while inserting case:::'+ex.getStackTraceString());
            }
            
            List<Entitlement> entitlementlist = TestDataFactory.createEntitlement(NAME , locationlist.get(0));
            entitlementlist[1].service__c = Constant_Util.EXTRA_PICKUP;
            entitlementlist[0].service__c = Constant_Util.EXTRA_PICKUP;
            Database.insert(entitlementlist);
        } 
    }
    @isTest static void fetchSLAwithoutEntitlement(){
        User currentuser = [SELECT id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        
        System.runAs(currentuser){
            Account acc = [SELECT id FROM Account 
                           WHERE Recordtype.name =: Constant_Util.LOCATION LIMIT 1];
            
            Entitlement entitlement1 = [SELECT id, StartDate,AssetId, AccountId, Call_Time__c, Before_After__c, 
                                        Schedule_Type__c, location__c, Service_Guarantee_Category__c, 
                                        Service_Guarantee_Category_Value__c, EndDate, container__c 
                                        FROM Entitlement WHERE EndDate =: null limit 1];
            
            system.debug('******entitlement1: '+entitlement1);
            
            entitlement1.StartDate = system.today();
            entitlement1.Call_Time__c = null;
            entitlement1.Before_After__c = null;
            entitlement1.container__c = Constant_Util.EMPTY_STRING;
            entitlement1.Schedule_Type__c = Constant_Util.EMPTY_STRING; 
            entitlement1.Service_Guarantee_Category__c = DAYS;
            entitlement1.Service_Guarantee_Category_Value__c = '5';
            entitlement1.EndDate = null;
            
            List<Case> caselist = [SELECT Id, Origin, Contactid, Case_Type__c, Client__c, Location__c, 
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                   Service_Date__c,SLA_Service_Date_Time__c 
                                   FROM Case WHERE Status =: Constant_Util.STATUS_NEW LIMIT 1];
            system.debug('*******caselist: '+caselist);
            CaseEntitlement.getCaseEntitlement(caselist[0].Id);
            caselist.get(0).SlaStartDate = DateTime.newInstance(2019, 11, 21, 3, 3, 3);
            caselist.get(0).Status = 'Pending';
            caselist[0].Service_Date__c = system.Today()+1;
            caselist[0].SLA_Override_Reason__c = REPAIRS;
            
            Test.startTest();
            Database.update(entitlement1);
            RecurrsiveTriggerHandler.isSkipcaseTrigger = false;
            Database.update(caselist);         
            Test.stopTest();
            
            System.assert(caselist[0].Service_Date__c!=null);
        }
    }
    @isTest static void fetchSLAwithoutEntitlement2(){
        Account acc =[SELECT id,ParentId from Account WHERE name='kroger' LIMIT 1];
        Contact conlist = [SELECT id,Account.ParentId FROM contact WHERE AccountId = :acc.Id LIMIT 1];
        User usr =[SELECT Id FROM User limit 1];
        Account Locacc =[SELECT id,ParentId from Account WHERE recordtype.Name = 'Location' LIMIT 1];
        Asset assetRec = [SELECT Id FROM Asset WHERE name='8 yrd Dumpster'];
        
        
        List<Case> caselist2 = TestDataFactory.createCase('TestCase2', acc, conlist, usr, Locacc, assetRec);
        caselist2[0].OwnerId =  usr.Id;
        caselist2[0].Recordtypeid = TestDataFactory.getRecordType('New Service Case','Case');
        caselist2[0].Case_Type__c = Constant_Util.NEW_SERVICE;
        caselist2[0].Case_Sub_Type__c = Constant_Util.PERMANENT;
        caselist2[0].Case_Reason__c = 'Location Opening';
        system.debug('*****caselist2: '+caselist2);
        try{
            Database.insert(caselist2[0]);
        } catch(Exception ex){
            system.debug('Exception while inserting case:::'+ex.getStackTraceString());
            system.debug('Exception while inserting case:::'+ex.getMessage());
        }
        CaseEntitlement.getCaseEntitlement(caselist2[0].Id);
    }
    @isTest static void fetchSLAwithoutEntitlement_EntitleMentwithAsset(){
        Account acc =[SELECT id,ParentId from Account WHERE name='kroger' LIMIT 1];
        Contact conlist = [SELECT id,Account.ParentId FROM contact WHERE AccountId = :acc.Id LIMIT 1];
        User usr =[SELECT Id FROM User limit 1];
        Account Locacc =[SELECT id,ParentId from Account WHERE recordtype.Name = 'Location' LIMIT 1];
        Asset assetRec = [SELECT Id FROM Asset WHERE name='8 yrd Dumpster'];
        
        //List<Entitlement> entitlementlist = TestDataFactory.createEntitlement(NAME , Locacc);
        List < Entitlement > entitlementlist = new List < Entitlement >();
        Entitlement ent1 = new Entitlement(Name='Entitlement2', AccountId=Locacc.ParentId, Status__c = 'Approved', 
                                          Recordtypeid = TestDataFactory.getRecordType('SLA','Entitlement'), Request_Type__c = 'PickUp', 
                                          service__c = Constant_Util.EXTRA_PICKUP,AssetId = assetRec.Id, Call_On__c = 'Sun;Mon;Tue;Wed;Thu;Fri;Sat',StartDate = Date.valueof(system.now().addDays(-1)),Call_Time__c = '10:00',
                                          Before_After__c = 'Before',location__c = Locacc.id,
                                          Service_Guarantee_Category__c = 'Days',Service_Guarantee_Category_Value__c = '1',EndDate = null);
        Entitlement ent2 = new Entitlement(Name='Entitlement2', AccountId=Locacc.ParentId, Status__c = 'Approved', 
                                          Recordtypeid = TestDataFactory.getRecordType('SLA','Entitlement'), Request_Type__c = 'PickUp', 
                                          service__c = Constant_Util.EXTRA_PICKUP,AssetId = assetRec.Id, Call_On__c = 'Sun;Mon;Tue;Wed;Thu;Fri;Sat',StartDate = Date.valueof(system.now().addDays(-1)),Call_Time__c = '10:00',
                                          Before_After__c = 'After',location__c = Locacc.id,
                                          Service_Guarantee_Category__c = 'Days',Service_Guarantee_Category_Value__c = '1',EndDate = null);
        
        entitlementlist.add(ent1);
        entitlementlist.add(ent2);
        Database.insert(entitlementlist);        
        List<Case> caselist2 = TestDataFactory.createCase('TestCase2', acc, conlist, usr, Locacc, assetRec);
        caselist2[0].OwnerId =  usr.Id;
        system.debug('*****caselist2: '+caselist2);
        try{
            Database.insert(caselist2[0]);
        } catch(Exception ex){
            system.debug('Exception while inserting case:::'+ex.getStackTraceString());
            system.debug('Exception while inserting case:::'+ex.getMessage());
        }
        CaseEntitlement.getCaseEntitlement(caselist2[0].Id);
    }
    @isTest static void fetchSLAwithoutEntitlement_EntitleMentwithProjectCode(){
        Account acc =[SELECT id,ParentId from Account WHERE name='kroger' LIMIT 1];
        Contact conlist = [SELECT id,Account.ParentId FROM contact WHERE AccountId = :acc.Id LIMIT 1];
        User usr =[SELECT Id FROM User limit 1];
        Account Locacc =[SELECT id,ParentId from Account WHERE recordtype.Name = 'Location' LIMIT 1];
        Asset assetRec = [SELECT Id FROM Asset WHERE name='8 yrd Dumpster'];
        List < Asset > AssetRecList = [SELECT Id,Project_Code__c FROM Asset ];
        system.debug('***AssetRecList: '+AssetRecList);
        List < Project_Code__c > projectCodeList =[SELECT id,Client_Account__c,Name,Date_Requested__c,
                                                   Container_Type__c,Effective_Date__c 
                                                   FROM Project_Code__c];
        system.debug('***projectCodeList: '+projectCodeList);
        List < Entitlement > entitlementlist = new List < Entitlement >();
        Entitlement ent1 = new Entitlement(Name='Entitlement2',Project_Code__c=projectCodeList[0].Id, AccountId=Locacc.ParentId, Status__c = 'Approved', 
                                          Recordtypeid = TestDataFactory.getRecordType('SLA','Entitlement'), Request_Type__c = 'PickUp', 
                                          service__c = Constant_Util.EXTRA_PICKUP, Call_On__c = 'Sun;Mon;Tue;Wed;Thu;Fri;Sat',StartDate = Date.valueof(system.now().addDays(-1)),Call_Time__c = '10:00',
                                          Before_After__c = 'Before',location__c = Locacc.id,
                                          Service_Guarantee_Category__c = 'Days',Service_Guarantee_Category_Value__c = '1',EndDate = null);
        Entitlement ent2 = new Entitlement(Name='Entitlement2', Project_Code__c=projectCodeList[0].Id,AccountId=Locacc.ParentId, Status__c = 'Approved', 
                                          Recordtypeid = TestDataFactory.getRecordType('SLA','Entitlement'), Request_Type__c = 'PickUp', 
                                          service__c = Constant_Util.EXTRA_PICKUP, Call_On__c = 'Sun;Mon;Tue;Wed;Thu;Fri;Sat',StartDate = Date.valueof(system.now().addDays(-1)),Call_Time__c = '10:00',
                                          Before_After__c = 'After',location__c = Locacc.id,
                                          Service_Guarantee_Category__c = 'Days',Service_Guarantee_Category_Value__c = '1',EndDate = null);
        
        entitlementlist.add(ent1);
        entitlementlist.add(ent2);
        Database.insert(entitlementlist);        
        List<Case> caselist2 = TestDataFactory.createCase('TestCase2', acc, conlist, usr, Locacc, AssetRecList[0]);
        caselist2[0].OwnerId =  usr.Id;
        system.debug('*****caselist2: '+caselist2);
        try{
            Database.insert(caselist2[0]);
        } catch(Exception ex){
            system.debug('Exception while inserting case:::'+ex.getStackTraceString());
            system.debug('Exception while inserting case:::'+ex.getMessage());
        }
        CaseEntitlement.getCaseEntitlement(caselist2[0].Id);
    }
     @isTest static void fetchSLAwithoutEntitlement_EntitleMentwithProjectCodeBlankLocation(){
        Account acc =[SELECT id,ParentId from Account WHERE name='kroger' LIMIT 1];
        Contact conlist = [SELECT id,Account.ParentId FROM contact WHERE AccountId = :acc.Id LIMIT 1];
        User usr =[SELECT Id FROM User limit 1];
        Account Locacc =[SELECT id,ParentId from Account WHERE recordtype.Name = 'Location' LIMIT 1];
        Asset assetRec = [SELECT Id FROM Asset WHERE name='8 yrd Dumpster'];
        List < Asset > AssetRecList = [SELECT Id,Project_Code__c FROM Asset ];
        system.debug('***AssetRecList: '+AssetRecList);
        List < Project_Code__c > projectCodeList =[SELECT id,Client_Account__c,Name,Date_Requested__c,
                                                   Container_Type__c,Effective_Date__c 
                                                   FROM Project_Code__c];
        system.debug('***projectCodeList: '+projectCodeList);
        List < Entitlement > entitlementlist = new List < Entitlement >();
        Entitlement ent1 = new Entitlement(Name='Entitlement2',Project_Code__c=projectCodeList[0].Id, AccountId=Locacc.ParentId, Status__c = 'Approved', 
                                          Recordtypeid = TestDataFactory.getRecordType('SLA','Entitlement'), Request_Type__c = 'PickUp', 
                                          service__c = Constant_Util.EXTRA_PICKUP, Call_On__c = 'Sun;Mon;Tue;Wed;Thu;Fri;Sat',StartDate = Date.valueof(system.now().addDays(-1)),Call_Time__c = '10:00',
                                          Before_After__c = 'Before',
                                          Service_Guarantee_Category__c = 'Days',Service_Guarantee_Category_Value__c = '1',EndDate = null);
        Entitlement ent2 = new Entitlement(Name='Entitlement2', Project_Code__c=projectCodeList[0].Id,AccountId=Locacc.ParentId, Status__c = 'Approved', 
                                          Recordtypeid = TestDataFactory.getRecordType('SLA','Entitlement'), Request_Type__c = 'PickUp', 
                                          service__c = Constant_Util.EXTRA_PICKUP, Call_On__c = 'Sun;Mon;Tue;Wed;Thu;Fri;Sat',StartDate = Date.valueof(system.now().addDays(-1)),Call_Time__c = '10:00',
                                          Before_After__c = 'After',
                                          Service_Guarantee_Category__c = 'Days',Service_Guarantee_Category_Value__c = '1',EndDate = null);
        
        entitlementlist.add(ent1);
        entitlementlist.add(ent2);
        Database.insert(entitlementlist);        
        List<Case> caselist2 = TestDataFactory.createCase('TestCase2', acc, conlist, usr, Locacc, AssetRecList[0]);
        caselist2[0].OwnerId =  usr.Id;
        system.debug('*****caselist2: '+caselist2);
        try{
            Database.insert(caselist2[0]);
        } catch(Exception ex){
            system.debug('Exception while inserting case:::'+ex.getStackTraceString());
            system.debug('Exception while inserting case:::'+ex.getMessage());
        }
        CaseEntitlement.getCaseEntitlement(caselist2[0].Id);
    }
    @isTest static void fetchSLAwithoutEntitlement_EntitleMentwithLocationContainer(){
        Account acc =[SELECT id,ParentId from Account WHERE name='kroger' LIMIT 1];
        Contact conlist = [SELECT id,Account.ParentId FROM contact WHERE AccountId = :acc.Id LIMIT 1];
        User usr =[SELECT Id FROM User limit 1];
        Account Locacc =[SELECT id,ParentId from Account WHERE recordtype.Name = 'Location' LIMIT 1];
        Asset assetRec = [SELECT Id FROM Asset WHERE name='8 yrd Dumpster'];
        List < Asset > AssetRecList = [SELECT Id,Project_Code__c FROM Asset ];
        system.debug('***AssetRecList: '+AssetRecList);
        List < Project_Code__c > projectCodeList =[SELECT id,Client_Account__c,Name,Date_Requested__c,
                                                   Container_Type__c,Effective_Date__c 
                                                   FROM Project_Code__c];
        system.debug('***projectCodeList: '+projectCodeList);
        List < Entitlement > entitlementlist = new List < Entitlement >();
        Entitlement ent1 = new Entitlement(Name='Entitlement2', AccountId=Locacc.ParentId, Status__c = 'Approved', 
                                          Recordtypeid = TestDataFactory.getRecordType('SLA','Entitlement'), Request_Type__c = 'PickUp', 
                                          service__c = Constant_Util.EXTRA_PICKUP, Call_On__c = 'Sun;Mon;Tue;Wed;Thu;Fri;Sat',StartDate = Date.valueof(system.now().addDays(-1)),Call_Time__c = '10:00',
                                          Before_After__c = 'Before',Schedule_Type__c = 'Temporary',location__c = Locacc.id,Container__c='Compactor',
                                          Service_Guarantee_Category__c = 'Days',Service_Guarantee_Category_Value__c = '1',EndDate = null);
        Entitlement ent2 = new Entitlement(Name='Entitlement2', AccountId=Locacc.ParentId, Status__c = 'Approved', 
                                          Recordtypeid = TestDataFactory.getRecordType('SLA','Entitlement'), Request_Type__c = 'PickUp', 
                                          service__c = Constant_Util.EXTRA_PICKUP, Call_On__c = 'Sun;Mon;Tue;Wed;Thu;Fri;Sat',StartDate = Date.valueof(system.now().addDays(-1)),Call_Time__c = '10:00',
                                          Before_After__c = 'After',Schedule_Type__c = 'Temporary',location__c = Locacc.id,Container__c='Compactor',
                                          Service_Guarantee_Category__c = 'Days',Service_Guarantee_Category_Value__c = '1',EndDate = null);
        
        entitlementlist.add(ent1);
        entitlementlist.add(ent2);
        Database.insert(entitlementlist);        
        List<Case> caselist2 = TestDataFactory.createCase('TestCase2', acc, conlist, usr, Locacc, AssetRecList[0]);
        caselist2[0].OwnerId =  usr.Id;
        system.debug('*****caselist2: '+caselist2);
        try{
            Database.insert(caselist2[0]);
        } catch(Exception ex){
            system.debug('Exception while inserting case:::'+ex.getStackTraceString());
            system.debug('Exception while inserting case:::'+ex.getMessage());
        }
        CaseEntitlement.getCaseEntitlement(caselist2[0].Id);
    }
    
}