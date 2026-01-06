/***************************************
*Class Name : SystemObjectSelectorTest
*Author : TCS
*JIRA : SDT-40063
*Description : test class for SystemObjectSelector.
****************************************/
@isTest(seeAllData = false)
public class SystemObjectSelectorTest {
    private static final String TEST_NAME ='Test';
    private static final String TEMPLATE_NAME_CASE = 'Customer or Internal: Pickup Approval';
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
    @isTest static void getGroupIdTest(){
        test.startTest();
        SystemObjectSelector.getGroupId(TEST_NAME);
        test.stopTest();
    }
     @testSetup static void setup() {
        test.startTest();//
        List<User> testRunUserList = new List<User>();
        
        //Profile p = TestDataFactory.getProfile(SYS_ADMIN); //Commented for SDT-33448
        Profile p = TestDataFactory.getProfile(CUSTOMER_SERVICE);  //Modified for SDT-33448
        
        User usr = TestDataFactory.createUser(p);
        usr.FirstName = 'testuser##9999';
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
            
            List<Project_Code__c> pCodeList = TestDataFactory.createProjectCode(acclist.get(0).Id);
            Database.insert(pCodeList);
            
            List<Asset> assetlist = TestDataFactory.createAsset(ASSET_NAME, acclist.get(0), conlist.get(0), productlist.get(0), usr, locationlist.get(0));
            assetlist[0].Supplier__c = supplieracclist[0].Id;
            assetlist[0].Project_Code__c = pCodeList[0].Id; 
            Database.insert(assetlist);
            
            Date targetDate = Date.newInstance(Datetime.Now().year(), Datetime.Now().month(), Datetime.Now().day());
            Time targetTime = Time.newInstance(21, 0, 0, 0);
            Datetime currentDate = DateTime.newInstanceGmt(targetDate, targetTime);
            Date srvDatetime = currentDate.addDays(9).date();
            // This will return a caseList with 4 cases of Case Type = Pickup
            // and Case Sub Type = Extra Pickup
            List<Case> caselist = TestDataFactory.createCase(CASE_NAME, acclist.get(0), conlist.get(0), usr, locationlist.get(0), assetlist.get(0));
            
            caselist[0].PurchaseOrder_Number__c =  PO_NUMBER;
            caselist[0].Status = Constant_Util.PENDING;
            caselist[0].Case_Type__c = Constant_Util.PICKUP_CSTYPE;
            caselist[0].Case_Sub_Type__c = Constant_Util.EXTRA_PICKUP;
            caselist[0].Create_AM_and_PM_Pickups__c = true;
            caselist[1].RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Constant_Util.STATUS_CASE).getRecordTypeId();
            caselist[1].Case_Type__c = Constant_Util.STATUS_CSTYPE;
            caselist[1].Source_System__c = Constant_Util.ACORN;
            caselist[1].Status = Constant_Util.OPEN;
            caselist[1].Case_Sub_Type__c = Constant_Util.SERVICE_NOT_PERFORMED;
            caselist[1].Case_Reason__c = Constant_Util.CUSTOMER_REPORTED;
            caselist[1].Case_Sub_Status__c = Constant_Util.PENDING_SERVICE_INTEGRATION;

            //Create Case Record for Intake Pickup Case with New Status
            caselist[2].RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Constant_Util.Pickup_Case_Rec_Type).getRecordTypeId();
            caselist[2].Case_Type__c = Constant_Util.PICKUP_CSTYPE;
            caselist[2].Source_System__c = Constant_Util.SALESFORCE;
            caselist[2].Origin = 'Service Channel';
            caselist[2].Status = Constant_Util.STATUS_NEW;
            caselist[2].Service_Date__c = srvDatetime;
            
            try{
                Database.insert(caselist);
                //System.debug('Caselist+++'+caselist);
            } catch(Exception ex){
                system.debug('Exception while inserting case:::'+ex.getStackTraceString());
            }
            
            //Creation of Data for Custom Setting Sla_Calculation__c
            List<Sla_Calculation__c> sla = new List<Sla_Calculation__c>();
            
            Sla_Calculation__c slaNew = new Sla_Calculation__c();
            slaNew.Name = 'New Service';
            slaNew.Enabled__c= True;
            slaNew.Normalized_SLA__c = false;
            sla.add(slaNew);
            
            Sla_Calculation__c slaPickup = new Sla_Calculation__c();
            slaPickup.Name = 'Pickup';
            slaPickup.Enabled__c= True;
            slaPickup.Normalized_SLA__c = false;
            sla.add(slaPickup);
            
            Database.insert(sla,false);
            
            Generic_Values__mdt objGV = new Generic_Values__mdt();
            
            String objuser;
            objUser = [Select Id, Id__c, DeveloperName from Generic_Values__mdt where DeveloperName = 'Genesys_User'].Id__c;
            
            List<Case> caselist2 = TestDataFactory.createCase(CASE_NAME, acclist.get(0), conlist.get(0), usr, locationlist.get(0), assetlist.get(0));
            caselist2[0].OwnerId =  objuser;
            test.stopTest();//
            try{
                Database.insert(caselist2);
            } catch(Exception ex){
                system.debug('Exception while inserting case:::'+ex.getStackTraceString());
            }
            
            // BT Refactored to insert one Work Order Test List using returnWorkOrder
            // instead of multiple Database.insert() when using createWorkOrder
            List<WorkOrder> myWorkOrderTestList = new List<WorkOrder>();
            
            WorkOrder wo = TestDataFactory.returnWorkOrder(acclist.get(0),conlist.get(0),caselist[0],assetlist.get(0));
            wo.Status = WORK_COMPLETE;
            wo.Send_Status__c = DELIVERED;
            wo.Acorn_WorkOrder_Number__c = 'w1111';
            wo.Vendor_Account_Id__c =  supplieracclist[0].Id;
            myWorkOrderTestList.add(wo);
            
            WorkOrder wo1 = TestDataFactory.returnWorkOrder(acclist.get(0),conlist.get(0),caselist[0],assetlist.get(0));
            wo1.Status = SENT;
            wo1.Send_Status__c = SCHEDULED;
            wo1.Acorn_WorkOrder_Number__c = 'w1111';
            wo1.Vendor_Account_Id__c =  supplieracclist[0].Id;
            myWorkOrderTestList.add(wo1);
            
            WorkOrder wo2 = TestDataFactory.returnWorkOrder(acclist.get(0),conlist.get(0),caselist[0],assetlist.get(0));
            wo2.Status = CANCELLED;
            wo2.Send_Status__c = SCHEDULED;
            wo2.Acorn_WorkOrder_Number__c = 'w1111';
            wo2.Vendor_Account_Id__c =  supplieracclist[0].Id;
            myWorkOrderTestList.add(wo2);
            
            WorkOrder wo3 = TestDataFactory.returnWorkOrder(acclist.get(0),conlist.get(0),caselist[0],assetlist.get(0));
            wo3.Status = ACCEPTED;
            wo3.Send_Status__c = DELIVERED;
            wo3.Vendor_Service_Status__c = SCHEDULED;
            wo3.Acorn_WorkOrder_Number__c = 'w1111';
            wo3.Vendor_Account_Id__c =  supplieracclist[0].Id;
            myWorkOrderTestList.add(wo3);
            
            WorkOrder wo4 = TestDataFactory.returnWorkOrder(acclist.get(0), conlist.get(0), caselist[0], assetlist.get(0));
            wo4.Status = 'New';
            wo4.Is_Bypass__c = false;
            wo4.Service_Date__c = System.today();
            wo4.Customer_Location__c = caselist[0].Location__c;
            myWorkOrderTestList.add(wo4);
            
            WorkOrder wo5 = TestDataFactory.returnWorkOrder(acclist.get(0), conlist.get(0), caselist[0], assetlist.get(0));
            wo5.Status = SENT;
            wo5.Send_Status__c = FAILED;
            wo5.Acorn_WorkOrder_Number__c = 'w1111';
            wo5.Vendor_Account_Id__c =  supplieracclist[0].Id;
            myWorkOrderTestList.add(wo5);
            
            Database.insert(myWorkOrderTestList, false);
            
            // I'm not going to refactor everything, but this should be 1 insert - BT
            List<Task> tasklist = TestDataFactory.createTask(caselist.get(0).id, usr);
            Database.insert(tasklist);
            List<Task> tasklist2 = TestDataFactory.createTask(caselist.get(2).id, usr);
            Database.insert(tasklist2);
            
            List<Entitlement> entitlementlist = TestDataFactory.createEntitlement(NAME , locationlist.get(0));
            entitlementlist[1].service__c = Constant_Util.EXTRA_PICKUP;
            entitlementlist[0].service__c = Constant_Util.EXTRA_PICKUP;
            Database.insert(entitlementlist);
            
            List<Business_Rule__c> brlst = TestDataFactory.createBusinessRule(NAME, acclist.get(0),locationlist.get(0));
            brlst[0].Service__c = Constant_Util.EXTRA_PICKUP;
            brlst[0].Schedule_Type__c = Constant_Util.EMPTY_STRING;
            brlst[0].Container__c = Constant_Util.EMPTY_STRING;
            brlst[0].AssetId__c = assetlist[0].Id;
            brlst[0].RecordTypeid = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.REQUIRED_INFORMATION).getRecordTypeId();
            brlst[0].Required_Information__c = PO_PSI_VALUE; 
            Database.insert(brlst);
            
            list<Business_Rule__c> brlist = TestDataFactory.createBusinessRule(Constant_Util.CONSTANT_FIRST, acclist.get(0), locationlist.get(0));
            brlist[0].Service__c = Constant_Util.EXTRA_PICKUP;
            brlist[0].Schedule_Type__c = Constant_Util.EMPTY_STRING;
            brlist[0].Container__c = Constant_Util.EMPTY_STRING;
            brlist[0].AssetId__c = assetlist[0].Id;
            brlist[0].Is_Auto_Email__c=true;
            brlist[0].RecordTypeId = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.APPROVAL).getRecordTypeId();
            Database.insert(brlist);
            
            // Add spaces between different types of record creation statements
            list<Account_Title__c> titlelst = TestDataFactory.createAccountTitle(acclist.get(0),DISTRICT_MANAGER);
            Database.insert(titlelst, false);
            
            list<Service_Approver__c> serviceApproverlist = TestDataFactory.createServiceApprover(brlist[0]);
            serviceApproverlist[0].Title__c = titlelst[0].Id;
            Database.insert(serviceApproverlist, false);
            
            list<Service_Approver__c> serviceConApproverlist = TestDataFactory.createEmailServiceApprover(brlist[0]);
            serviceApproverlist[0].Active__c=true;
            Database.insert(serviceConApproverlist, false);
            
            List<WorkOrder> workorders = [SELECT Id, Acorn_WorkOrder_Number__c FROM WorkOrder WHERE Acorn_WorkOrder_Number__c != null LIMIT 5];
            
            List<Case> caselist3 = TestDataFactory.createCase( CASE_NAME, acclist.get(0), conlist.get(0), usr, locationlist.get(0), assetlist.get(0));
            caselist3[0].AssetId = assetlist[0].id;
            caselist3[0].Work_Order__c = workorders[0].id;
            
            insert caselist3;
            
            //SDT-31851
            List<Case> caselist4 = TestDataFactory.createCase( CASE_NAME, acclist.get(0), conlist.get(0), usr, locationlist.get(0), assetlist.get(0));
            caselist4[0].AssetId = assetlist[0].id;
            caselist4[0].Work_Order__c = workorders[0].id;
            //caselist4[0].Last_Agent_Id_ForTaskAssignment__c = UserInfo.getUserId();
            caselist4[0].Is_Multiple_Asset__c = false;
            insert caselist4;
            
            List<Approval_Log__c> applist = TestDataFactory.createApprovallog(caselist[0].id);
            applist[0].BusinessRuleId__c = brlist[0].Id;
            applist[0].CaseId__c = caselist[0].Id;  
            Database.Insert(applist);
            
            //added as a part of code review for test class error fix 
            List<Config_PO__c> cpList = new List<Config_PO__c>(); //Modified for SDT-33448           
            Config_PO__c cp = new Config_PO__c();
            cp.name = 'PO_Number_Digits';
            cp.POCharacters__c = 12;
            cpList.add(cp); //Modified for SDT-33448 
            insert cpList; //Modified for SDT-33448 
        } 
        
        // Create Email Template
        List<EmailTemplate> emailTemplateList = new List<EmailTemplate>();
        
        EmailTemplate singleCaseTemplate = new EmailTemplate();
        singleCaseTemplate.Name = 'Chat Now Automated Email';
        singleCaseTemplate.isActive = true;
        singleCaseTemplate.DeveloperName = DEVWOEMAILTEMPLATE;
        singleCaseTemplate.TemplateType = TEXT;
        singleCaseTemplate.FolderId = UserInfo.getUserId();
        
        emailTemplateList.add(singleCaseTemplate);
        
        insert(emailTemplateList);
        
    }
    @isTest static void getBusinessHoursIdTest(){
        test.startTest();
        SystemObjectSelector.getBusinessHoursId(TEST_NAME);
        test.stopTest();
    }
    @isTest static void getLoggedInUserProfileTest(){
        test.startTest();
        Profile p= TestDataFactory.getProfile('System Administrator');
        User usr= TestDataFactory.createUser(p);
        usr.Bypass_Validation__c = TRUE;
        usr.Genesys_Enabled__c = FALSE;
        insert usr;
        Set<Id> userIdSet = new Set<Id>();
        useridSet.add(usr.Id);
        
        list<case> caselist = [select id, origin, contactid, Case_Type__c, Client__c, Location__c,Status, Case_Sub_Status__c,
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c,Contact_Title__c,assetid,PSI__c,PSI_Comments__c,
                                   Service_Date__c,SLA_Service_Date_Time__c from case  where status =: Constant_Util.STATUS_NEW limit 1];
        Set<id> CseSet = new Set<id>();
        CseSet.add(caselist[0].Id);
        SystemObjectSelector.getLoggedInUserProfile(usr.Id);
        SystemObjectSelector.acornUserId(usr.Id);
        SystemObjectSelector.getUsersByIds(useridSet);
        SystemObjectSelector.getCasesByIds(CseSet);
        
        test.stopTest();
    }
    @isTest static void getEmailTemplateByNameTest(){
        test.startTest();
        SystemObjectSelector.getEmailTemplateByName(TEMPLATE_NAME_CASE);
        test.stopTest();
    }
}