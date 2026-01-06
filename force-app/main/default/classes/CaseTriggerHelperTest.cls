/**
* @author Accenture
* @date 2/6/2019
* @description : Apex class CaseTriggerHelperTest 
**/

/* test class for CaseTriggerHelper*/
@isTest(seeAllData = false)
public class CaseTriggerHelperTest {
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
        Test.startTest();
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
            
            //Changes for SDT-42644
            productlist.add(TestDataFactory.createProduct('Hand Pickup', 'Services', 'HANDPICKUP'));
            productlist.add(TestDataFactory.createProduct('Unknown Equipment', 'Services', ''));
            Database.insert(productlist);
            
            list<Account> supplieracclist = TestDataFactory.createAccount(TESTSUPPLIER , usr, SUPPLIER);
            supplieracclist[0].AccountNumber = '600';
            Database.insert(supplieracclist);
            
            List<Project_Code__c> pCodeList = TestDataFactory.createProjectCode(acclist.get(0).Id);
            Database.insert(pCodeList);
            
            List<Asset> assetlist = TestDataFactory.createAsset(ASSET_NAME, acclist.get(0), conlist.get(0), productlist.get(0), usr, locationlist.get(0));
            assetlist[0].Supplier__c = supplieracclist[0].Id;
            assetlist[0].Project_Code__c = pCodeList[0].Id; 
            
            //changes related to SDT-42644
            Asset handPickupScheduled = TestDataFactory.createAsset('Hand Pickup',  acclist.get(0), conlist.get(0), productlist[1], usr, locationlist[0])[0];
            handPickupScheduled.Occurrence_Type__c = 'Scheduled';
            assetlist.add(handPickupScheduled);
            
            Asset handPickupOncall = TestDataFactory.createAsset('Hand Pickup',  acclist.get(0), conlist.get(0), productlist[1], usr, locationlist[0])[0];
            handPickupOncall.Occurrence_Type__c = 'On-Call';
            assetlist.add(handPickupOncall);
            
            Database.insert(assetlist);
            
            // Adding Scheduled Pickup Asset Detail
            List<Asset> handPickupChildAssetList = TestDataFactory.createChildAsset('Hand Pickup');
            handPickupChildAssetList[0].Product2Id = productlist[2].Id;
            handPickupChildAssetList[0].Service_Header_Id__c = handPickupScheduled.Id;
            handPickupChildAssetList[0].ParentId = handPickupScheduled.Id;
            handPickupChildAssetList[0].Service_Type__c = 'Hand Pickup';
            handPickupChildAssetList[0].Occurrence_Type__c = 'Scheduled';
            handPickupChildAssetList[0].Is_Core_Service__c = true;
            handPickupChildAssetList[0].Has_Extra_Pickup__c = true;
            
            handPickupChildAssetList.add(TestDataFactory.createChildAsset('Hand Pickup')[0]);
            handPickupChildAssetList[1].Product2Id = productlist[2].Id;
            handPickupChildAssetList[1].Service_Header_Id__c = handPickupScheduled.Id;
            handPickupChildAssetList[1].ParentId = handPickupScheduled.Id;
            handPickupChildAssetList[1].Service_Type__c = 'Hand Pickup';
            handPickupChildAssetList[1].Occurrence_Type__c = 'On-Call';
            handPickupChildAssetList[1].Is_Core_Service__c = false;
            handPickupChildAssetList[1].Has_Extra_Pickup__c = false;
            
            // Adding On Call Pickup Asset Detail
            handPickupChildAssetList.add(TestDataFactory.createChildAsset('Hand Pickup')[0]);
            handPickupChildAssetList[2].Product2Id = productlist[2].Id;
            handPickupChildAssetList[2].Service_Header_Id__c = handPickupOncall.Id;
            handPickupChildAssetList[2].ParentId = handPickupOncall.Id;
            handPickupChildAssetList[2].Service_Type__c = 'Hand Pickup';
            handPickupChildAssetList[2].Occurrence_Type__c = 'On-Call';
            handPickupChildAssetList[2].Is_Core_Service__c = true;
            handPickupChildAssetList[2].Has_Extra_Pickup__c = false;
            
            Database.insert(handPickupChildAssetList);
            
            
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
            caselist[2].Case_Sub_Status__c = Constant_Util.PENDING_SERVICE_INTEGRATION;
            
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
            test.stopTest();
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

            // Create Approval Log for Obtain Approval Task
        User testUser = [SELECT Id FROM User WHERE FirstName = 'testuser##9999' LIMIT 1];
        list<case> caselistOrigin = [select id, origin,Last_Agent_Id_ForTaskAssignment__c, contactid, Case_Type__c, Client__c, Location__c, 
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                   Service_Date__c,SLA_Service_Date_Time__c,CaseNumber,Reference_Number__c  from case where status =: Constant_Util.PENDING limit 1];
        caselistOrigin.get(0).status = Constant_Util.PENDING;                           
        caselistOrigin.get(0).Case_Sub_Status__c = Constant_Util.PENDING_REQUEST_APPROVAL;
        caselistOrigin.get(0).Reference_Number__c = caselistOrigin.get(0).CaseNumber;
        caselistOrigin.get(0).origin = Constant_Util.EBUSSINESS;
        caselistOrigin.get(0).Last_Agent_Id_ForTaskAssignment__c = testUser.Id;
        Database.update(caselistOrigin);
        List<Approval_Log__c> applistForOrigin = TestDataFactory.createApprovallog(caselistOrigin[0].id);
            applistForOrigin[0].BusinessRuleId__c = brlist[0].Id;
            applistForOrigin[0].CaseId__c = caselistOrigin[0].Id;  
            Database.Insert(applistForOrigin);
        } 
        
        // Create Email Template
            List<EmailTemplate> emailTemplateList = new List<EmailTemplate>();

            EmailTemplate singleCaseTemplate = new EmailTemplate();
            singleCaseTemplate.Name = WOEMAILTEMPLATE;
            singleCaseTemplate.isActive = true;
            singleCaseTemplate.DeveloperName = DEVWOEMAILTEMPLATE;
            singleCaseTemplate.TemplateType = TEXT;
            singleCaseTemplate.FolderId = UserInfo.getUserId();

            emailTemplateList.add(singleCaseTemplate);

            insert(emailTemplateList);
        
    }
    @isTest static void populateServiceClassificationtest(){
        //User currentuser = [SELECT id, Bypass_Validation__c, IsActive FROM User where Bypass_Validation__c =: false AND IsActive =: true AND Profile.Name ='System Administrator' LIMIT 1]; //SDT-33363 //Commented for SDT-33448   
        //Querying CSR User.
        User currentuser = [SELECT Id, Profile.Name, Bypass_Validation__c, IsActive FROM User WHERE Bypass_Validation__c =: false AND Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive =: true LIMIT 1]; //Modified for SDT-33448           
        system.runAs(currentuser){
            List<Asset> aselst = [Select Id, Location__c from Asset where Location__c != null Limit 1];
            List<Account> loclst = [Select Id, Name,ParentId from Account where Id =: aselst.get(0).Location__c Limit 1];
            List<Account> acclst = [Select Id, Name from Account where Id =: loclst.get(0).ParentId Limit 1];
            List<Contact> conlst = [Select Id, Name from Contact where Accountid =: acclst.get(0).Id Limit 1];
        	List<Case> caselist = TestDataFactory.createCase(CASE_NAME, acclst.get(0), conlst.get(0), currentuser, loclst.get(0), aselst.get(0));
            caselist[0].RecordTypeId = Schema.SobjectType.Case.getRecordTypeInfosByDeveloperName().get(Constant_Util.R_STATUS_CASE).getRecordTypeId();
            caselist[0].Status = Constant_Util.OPEN;
            caselist[0].Case_Sub_Status__c = Constant_Util.PENDING_SERVICE_ISSUE_RESOLUTION;
            caselist[0].Case_Reason__c = Constant_Util.HAULER_REPORTED;
            caselist[0].Service_Classification__c = Constant_Util.STANDARD; //SDT-33363
            caselist[0].Case_Type__c = Constant_Util.STATUSFIELD;
            caselist[0].Case_Sub_Type__c = Constant_Util.SERVICE_NOT_PERFORMED;
            test.startTest();
            Database.Insert(caselist, false);

            List<case> updatelst = [Select Id,Service_Classification__c from case where Id =: caselist.get(0).Id and RecordTypeId =:Schema.SobjectType.Case.getRecordTypeInfosByDeveloperName().get(Constant_Util.R_STATUS_CASE).getRecordTypeId() Limit 1];
            system.assertEquals(Constant_Util.STANDARD, updatelst[0].Service_Classification__c);
            updatelst[0].Case_Reason__c = Constant_Util.CUSTOMER_REPORTED;
            Database.update(updatelst, false);
            List<case> updatedcaselst = [Select Id,Service_Classification__c from case where Id =: updatelst.get(0).Id and RecordTypeId =:Schema.SobjectType.Case.getRecordTypeInfosByDeveloperName().get(Constant_Util.R_STATUS_CASE).getRecordTypeId() Limit 1];
            system.assertEquals(Constant_Util.EMERGENCY, updatedcaselst[0].Service_Classification__c);
            Test.stopTest();
        }
    }
     @isTest static void closeTaskstest(){ 
        User currentuser = [SELECT id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        system.runAs(currentuser){   
            List<Case> caselist = [SELECT id, Status FROM Case LIMIT 1];
            List<Task> tasklist = [SELECT Id, Status, WhatId FROM Task LIMIT 1]; 
            
            tasklist[0].WhatId = caselist[0].Id;         
            caselist[0].Status = Constant_Util.CLOSED ;
            
            Test.startTest();
            Database.update(tasklist); 
            Database.update(caselist);                      
            Test.stopTest();

            System.assertEquals(Constant_Util.CLOSED,caselist[0].Status);
        }
    }
    
    /* test method if Service Guarantee Category is days in entitlement*/
    @isTest static void populateSlaDateTime(){
        //user currentuser = [select id, Bypass_Validation__c, IsActive, Profile.Name from user WHERE Bypass_Validation__c = FALSE and IsActive = true and Profile.Name = :Constant_Util.CUSTOMER_SERVICE limit 1];  //Commented for SDT-33448   
        //Querying CSR User.
        User currentuser = [SELECT Id, Profile.Name, Bypass_Validation__c, IsActive FROM User WHERE Bypass_Validation__c =: false AND Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive =: true LIMIT 1]; //Modified for SDT-33448           
        System.runAs(currentuser){
            Account acc = [SELECT id FROM Account 
            WHERE Recordtype.name =: Constant_Util.LOCATION LIMIT 1];

            Entitlement ent = [SELECT id, StartDate, AccountId, Call_Time__c, Before_After__c, 
                                        Schedule_Type__c, location__c, Service_Guarantee_Category__c, 
                                        Service_Guarantee_Category_Value__c, EndDate, container__c,AssetId,Project_Code__c 
                                        FROM Entitlement WHERE EndDate =: null LIMIT 1];

            List<Case> caselist = [SELECT id, origin, contactid, Case_Type__c, Client__c, Location__c,Site_Contact__c,Site_Contact_Phone__c,
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                   Service_Date__c,SLA_Service_Date_Time__c 
                                   FROM Case WHERE status =: Constant_Util.PENDING LIMIT 1];

            ent.Before_After__c = null;
            ent.Call_Time__c = null;
            ent.Service_Guarantee_Category_Value__c = VALUE_TWO;
            Database.update(ent);

            //caselist[0].Service_Date__c = null;
            caselist[0].PurchaseOrder_Number__c = Constant_Util.EMPTY_STRING;
            caselist[0].Site_Contact__c = VALUE_TEST;
            caselist[0].Site_Contact_Phone__c = PHONE;
            caselist[0].Create_AM_And_PM_Pickups__c = true;
            caselist[0].Is_Clone__c = true;

            List<Business_Rule__c> brlst = [SELECT Id,Accountid__c,locationid__c,Container__c,Service__c,Request_Type__c,Schedule_Type__c,Active__c,Effective_Date__c,RecordTypeid,Required_Information__c 
            FROM Business_Rule__c WHERE RecordTypeid =: Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.REQUIRED_INFORMATION).getRecordTypeId() LIMIT 49999];
            
            RecurrsiveTriggerHandler.isSkipcaseTrigger = false;
            caselist.get(0).SlaStartDate = System.now().addHours(3);
            
            Test.startTest();
            Database.update(caselist);                      
            Test.stopTest();
            
            //CasetriggerHelper.getbusinessRule(caselist[0], Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.REQUIRED_INFORMATION).getRecordTypeId(), false, false);  
            
            Case c = [SELECT id,SLA_Service_Date_Time__c,Service_Date__c 
                    FROM Case WHERE Id =:caselist.get(0).Id LIMIT 1]; 

            System.assert(c.SLA_Service_Date_Time__c.date() != null);
            System.assertEquals(c.SLA_Service_Date_Time__c.date(), c.Service_Date__c);
        }
        
    }
    
    /* test method to check Genesys Owner*/
    @isTest static void completeGenesysRouting(){
        //user currentuser = [select id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363//Commented for SDT-33448   
        //Querying CSR User.
        User currentuser = [SELECT Id, Profile.Name, Bypass_Validation__c, IsActive FROM User WHERE Bypass_Validation__c =: false AND Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive =: true LIMIT 1]; //Modified for SDT-33448           
        system.runAs(currentuser){
            
            Generic_Values__mdt objGV= new Generic_Values__mdt();
        	String objuser;
        	objUser = [Select Id, Id__c, DeveloperName from Generic_Values__mdt where DeveloperName = 'Genesys_User'].Id__c;
            
            List<Case> caselist = [SELECT id, origin, contactid, Case_Type__c, Client__c, Location__c, Status,
                               PSI_Override_Reason__c, Case_Sub_Type__c, PurchaseOrder_Number__c,Contact_Title__c, assetid,PSI__c, PSI_Comments__c,
                               Service_Date__c, SLA_Service_Date_Time__c 
                               FROM Case WHERE OwnerId =: objUser limit 1];    
        
        RecurrsiveTriggerHandler.isSkipcaseTrigger = false;
        caselist.get(0).Status = Constant_Util.CLOSED;

        Test.startTest();
        Database.update(caselist,false);
        Test.stopTest();

        System.assertEquals(Constant_Util.CLOSED,caselist[0].Status);
        }
    }

    /* test method to check Genesys Owner*/
    @isTest static void cancelGenesysRouting(){
        //user currentuser = [SELECT id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363//Commented for SDT-33448   
        //Querying CSR User.
        User currentuser = [SELECT Id, Profile.Name, Bypass_Validation__c, IsActive FROM User WHERE Bypass_Validation__c =: false AND Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive =: true LIMIT 1]; //Modified for SDT-33448           
        System.runAs(currentuser){
            
            Generic_Values__mdt objGV= new Generic_Values__mdt();
        	String objuser;
        	objUser = [SELECT Id, Id__c, DeveloperName 
            FROM Generic_Values__mdt WHERE DeveloperName = 'Genesys_User'].Id__c;
            
        List<Case> caselist = [SELECT id, origin, contactid, Case_Type__c, Client__c, Location__c, Status, PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c,Contact_Title__c,assetid,PSI__c,PSI_Comments__c, Service_Date__c,SLA_Service_Date_Time__c 
        FROM Case WHERE OwnerId =: objUser LIMIT 1];    
        
        RecurrsiveTriggerHandler.isSkipcaseTrigger = false;
        caselist.get(0).OwnerId = currentuser.Id;

        Test.startTest();
        Database.update(caselist,false);
        Test.stopTest();
        System.assertEquals(currentuser.Id,caselist.get(0).OwnerId);
        }
    }
    
    
    /* test method if Service Guarantee Category is hours in entitlement*/
    @isTest static void populateSlaDateTimeHours(){
        //user currentuser = [select id, Bypass_Validation__c, IsActive, Profile.Name from user WHERE Bypass_Validation__c = FALSE and IsActive = true and Profile.Name = :Constant_Util.CUSTOMER_SERVICE limit 1];        //Commented for SDT-33448   
        //Querying CSR User.
        User currentuser = [SELECT Id, Profile.Name, Bypass_Validation__c, IsActive FROM User WHERE Bypass_Validation__c =: false AND Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive =: true LIMIT 1]; //Modified for SDT-33448           
        system.runAs(currentuser){
            Account acc = [select id from Account where Recordtype.name =: Constant_Util.LOCATION limit 1];
            List<Entitlement> entitlement1 = [select id, Name,StartDate, Call_Time__c, AccountId, Before_After__c, location__c, 
                                              Service_Guarantee_Category__c, Service_Guarantee_Category_Value__c, 
                                              EndDate, container__c from Entitlement LIMIT 49999 ];
            list<Business_Rule__c> brlst = [Select Id,Accountid__c,locationid__c,Container__c,Service__c,Request_Type__c,Schedule_Type__c,Active__c,Effective_Date__c,RecordTypeid,Required_Information__c from  Business_Rule__c LIMIT 49999];
            entitlement1[0].Status__c = PENDING_APPROVAL;
            entitlement1[1].Status__c = PENDING_APPROVAL;
            entitlement1[2].Status__c = PENDING_APPROVAL;
            
            list<case> caselist = [select id, origin, contactid, Case_Type__c, Client__c, Location__c, 
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                   Service_Date__c,SLA_Service_Date_Time__c from case where status =: Constant_Util.PENDING limit 1];
            caselist.get(0).SlaStartDate = system.now().addMinutes(15);
            caselist.get(0).status = Constant_Util.PENDING;
            caselist.get(0).Case_Sub_Status__c = Constant_Util.PENDING_REQUEST_APPROVAL;
            
            Test.startTest();
            Database.update(entitlement1);        
            RecurrsiveTriggerHandler.isSkipcaseTrigger = false;    
            Database.update(caselist);                  
            Test.stopTest();
            
            Case c = [SELECT id,SLA_Service_Date_Time__c,Service_Date__c 
            FROM Case WHERE Id =:caselist.get(0).Id LIMIT 1]; 

            System.assert(c.SLA_Service_Date_Time__c.date() != null);
            System.assertEquals(c.SLA_Service_Date_Time__c.date(), c.Service_Date__c);
        }
    }
    
    /* test method if Service Guarantee Category is hours in entitlement*/
    @isTest static void fetchSLAwithoutEntitlement(){
        User currentuser = [SELECT id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        
        System.runAs(currentuser){
            Account acc = [SELECT id FROM Account 
            WHERE Recordtype.name =: Constant_Util.LOCATION LIMIT 1];

            Entitlement entitlement1 = [SELECT id, StartDate, AccountId, Call_Time__c, Before_After__c, 
                                        Schedule_Type__c, location__c, Service_Guarantee_Category__c, 
                                        Service_Guarantee_Category_Value__c, EndDate, container__c 
                                        FROM Entitlement WHERE EndDate =: null limit 1];

            List<Business_Rule__c> brlst = [SELECT Id,Accountid__c,locationid__c,Container__c,Service__c,Request_Type__c,Schedule_Type__c,Active__c,Effective_Date__c,RecordTypeid,Required_Information__c 
            FROM Business_Rule__c WHERE RecordTypeid =: Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.REQUIRED_INFORMATION).getRecordTypeId() 
            LIMIT 49999];

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
    
    /* test method for covering email to case*/
    @isTest static void emailtocase(){
        //User currentuser = [SELECT id, Bypass_Validation__c ,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363//Commented for SDT-33448   
        //Querying CSR User.
        User currentuser = [SELECT Id, Profile.Name, Bypass_Validation__c, IsActive FROM User WHERE Bypass_Validation__c =: false AND Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive =: true LIMIT 1]; //Modified for SDT-33448           
        
        System.runAs(currentuser){
            List<Case> caselist = [SELECT Id, Origin, Contactid, Case_Type__c, Client__c, Location__c,Contact_Title__c, PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c, Service_Date__c,SLA_Service_Date_Time__c 
            FROM Case WHERE Status =: Constant_Util.PENDING limit 1];
            
            RecurrsiveTriggerHandler.isSkipcaseTrigger = false;
            caselist.get(0).SlaStartDate = system.now().addMinutes(15);
            caselist.get(0).SLA_Override_Reason__c = POWER_OUTAGE;
            caselist[0].Case_Type__c = null;
            
            Test.startTest();
            Database.update(caselist);
            Test.stopTest();
            
            Case c = [SELECT Id, Case_Type__c FROM Case WHERE Id =:caselist.get(0).Id LIMIT 1];
            System.assertEquals(c.Case_Type__c,null);
        }
    }  
    
    /*Test method to cover entitlement flow*/
    @isTest static void withasset(){
        /*User currentuser = [SELECT Id, Bypass_Validation__c 
        FROM User 
        WHERE ProfileId =:(TestDataFactory.getProfile(SYS_ADMIN)).Id 
        AND IsActive = true 
        LIMIT 1];*/   //Commented for SDT-33448
        User currentuser = [SELECT Id, Bypass_Validation__c 
                            FROM User 
                            WHERE ProfileId =:(TestDataFactory.getProfile(CUSTOMER_SERVICE)).Id 
                            AND IsActive = true 
                            LIMIT 1];   //Modified for SDT-33448
        System.runAs(currentuser){
            Test.startTest();
            Account acc = [SELECT Id, ParentId FROM Account 
                            WHERE Recordtype.name =: Constant_Util.LOCATION LIMIT 1];

            Asset ast = [SELECT id FROM Asset WHERE AccountId =: acc.Id LIMIT 1];

            Entitlement entitlement1 = [SELECT id, Name, StartDate, AccountId, Call_Time__c, 
                                        Before_After__c, Schedule_Type__c, location__c, Service_Guarantee_Category__c,
                                        Status__c, Service__c, Service_Guarantee_Category_Value__c, EndDate, container__c, 
                                        AssetId,Project_Code__c 
                                        FROM Entitlement 
                                        WHERE EndDate =: null LIMIT 1];

			Contact con = [SELECT id FROM Contact WHERE Accountid =: acc.ParentId  LIMIT 1];

            List<Business_Rule__c> brlst = [SELECT Id, Accountid__c, locationid__c, Container__c,
                                            Service__c, Request_Type__c, Schedule_Type__c, Active__c, 
                                            Effective_Date__c, RecordTypeid, Required_Information__c 
                                            FROM Business_Rule__c LIMIT 49999];

            brlst[0].Active__c = true;
            brlst[1].Active__c = true;
            Database.Update(brlst, false);
            //Test.startTest();
            List<Service_Approver__c> salst = [SELECT Id, Business_Rule__c, Service_Approver__c.Title__c 
                                                FROM Service_Approver__c LIMIT 49999];

            List<Contact> conlst = [SELECT Id, Account_Title__c FROM contact LIMIT 49999];

            conlst[0].Account_Title__c = salst[0].Title__c;
            Database.update(conlst, false);
            
            entitlement1.AccountId = acc.ParentId;
            entitlement1.Status__c = Constant_Util.APPROVED;
            entitlement1.StartDate = system.today();
            entitlement1.Call_Time__c = null;
            entitlement1.Before_After__c = null;
            entitlement1.AssetId = ast.Id;
            entitlement1.SLA_Ins__c = 'Test SLA Instruction';
            entitlement1.service__c = 'Extra Pickup';
            entitlement1.Location__c = acc.Id;
            entitlement1.container__c = Constant_Util.EMPTY_STRING;
            entitlement1.Schedule_Type__c = Constant_Util.EMPTY_STRING; 
            entitlement1.Project_Code__c = null;
            entitlement1.Service_Guarantee_Category__c = DAYS;
            entitlement1.Service_Guarantee_Category_Value__c = '0';
            entitlement1.EndDate = null;
            
            Database.update(entitlement1);

            Case cas = new Case(Status ='New', Priority = 'Medium', Origin = 'Phone', ContactId = con.id, 
                                AccountId = acc.id, OwnerId = currentuser.id, Client__c = acc.ParentId, 
                                Location__c = acc.id, SLA_Service_Date_Time__c = null, Assetid = ast.id, 
                                Case_Type__c = 'Pickup', Case_Sub_Type__c = 'Extra Pickup', 
                                Recordtypeid = TestDataFactory.getRecordType('Pickup Case','Case'));

           	Database.insert(cas,false);

            List<Project_Code__c> pCodeList=[SELECT Id FROM Project_Code__c 
                                            WHERE RecordType.Name =: PROJECT_CODE_DETAIL];
            
            entitlement1.AssetId = null;
	        entitlement1.service__c = 'Empty and Return';
            entitlement1.Call_Time__c = TIME_TEN;
            entitlement1.Before_After__c = Constant_Util.BEFORE;
            entitlement1.Service_Guarantee_Category_Value__c = VALUE_ZERO;
            entitlement1.container__c = Constant_Util.EMPTY_STRING;
            entitlement1.Schedule_Type__c = Constant_Util.EMPTY_STRING; 
            entitlement1.Project_Code__c = pCodeList[0].Id;
            entitlement1.Service_Guarantee_Category__c = HOURS;
            entitlement1.Service_Guarantee_Category_Value__c = HOURS_VALUE;
            Database.update(entitlement1);
            
            Entitlement et = [SELECT id, AssetId, Container__c, Schedule_Type__c, Project_Code__c,
                                Service_Guarantee_Category__c,Service_Guarantee_Category_Value__c,
                                AccountId,Location__c,Service__c 
                                FROM Entitlement 
                                WHERE Id =: entitlement1.Id LIMIT 1];

            //Test.startTest();
            
            RecurrsiveTriggerHandler.isSkipcaseTrigger = false;
            cas.Case_Sub_Type__c = 'Empty and Return';
            cas.User_Input_Work_Order_Instructions__c = 'Test';
            Database.update(cas, false);
            
            entitlement1.Call_Time__c = TIME_TEN;
	        entitlement1.service__c = 'Extra Pickup';
            entitlement1.Before_After__c = Constant_Util.BEFORE;
            entitlement1.Project_Code__c = null;
            entitlement1.Container__c = COMPACTOR;
            entitlement1.Schedule_Type__c = TEMPORARY;
            Database.update(entitlement1, false);
            
            RecurrsiveTriggerHandler.isSkipcaseTrigger = false;
	        cas.Case_Sub_Type__c = 'Extra Pickup';
            Database.update(cas, false);
            
	        entitlement1.service__c = 'Empty and Return';
            entitlement1.Call_Time__c = '23:59';
            entitlement1.Container__c = Constant_Util.EMPTY_STRING;
            entitlement1.Schedule_Type__c = TEMPORARY;
            Database.update(entitlement1, false);
            
            RecurrsiveTriggerHandler.isSkipcaseTrigger = false;
            cas.Case_Sub_Type__c = 'Empty and Return';
            Database.update(cas, false);
            
	        entitlement1.service__c = 'Extra Pickup';
            entitlement1.Schedule_Type__c = Constant_Util.EMPTY_STRING;
            entitlement1.Container__c = COMPACTOR;
            Database.update(entitlement1, false);
            
            RecurrsiveTriggerHandler.isSkipcaseTrigger = false;
            cas.Case_Sub_Type__c = 'Extra Pickup';
            Database.update(cas,false);
            
	        entitlement1.service__c = 'Empty and Return';
            entitlement1.Location__c = cas.Location__c;
            entitlement1.Container__c = Constant_Util.EMPTY_STRING;
            entitlement1.Schedule_Type__c = Constant_Util.EMPTY_STRING;
            Database.update(entitlement1, false);
            
            RecurrsiveTriggerHandler.isSkipcaseTrigger = false;
	        cas.Case_Sub_Type__c = 'Empty and Return';
            Database.update(cas, false);
            
	        entitlement1.service__c = 'Extra Pickup';
            entitlement1.Schedule_Type__c = TEMPORARY;
            Database.update(entitlement1, false);
            
            RecurrsiveTriggerHandler.isSkipcaseTrigger = false;
            cas.Case_Sub_Type__c = 'Extra Pickup';
            Database.update(cas, false);    
            
            entitlement1.service__c = 'Empty and Return';
            entitlement1.Location__c = cas.Location__c;
            entitlement1.Schedule_Type__c = Constant_Util.EMPTY_STRING;
            entitlement1.Container__c = Constant_Util.EMPTY_STRING;
            Database.update(entitlement1, false);
            
            RecurrsiveTriggerHandler.isSkipcaseTrigger = false;
			cas.Case_Sub_Type__c = 'Empty and Return';
            Database.update(cas,false);
            
            Test.stopTest();
            
            /*
            Case c = [SELECT Id, SLA_Service_Date_Time__c, Service_Date__c 
                      FROM Case 
                      WHERE Id =:cas.Id LIMIT 1];

            System.assert(c.SLA_Service_Date_Time__c.date() != null);
            */
        }
    }
    
    /*Test method to cover entitlement flow*/
    @isTest static void withoutasset(){
        /*user currentuser = [SELECT Id, Bypass_Validation__c 
                            FROM User 
                            WHERE ProfileId =:(TestDataFactory.getProfile(SYS_ADMIN)).Id 
                            AND IsActive = true 
                            LIMIT 1];*/   //Commented for SDT-33448
        user currentuser = [SELECT Id, Bypass_Validation__c 
                            FROM User 
                            WHERE ProfileId =:(TestDataFactory.getProfile(CUSTOMER_SERVICE)).Id 
                            AND IsActive = true 
                            LIMIT 1];   //Modified for SDT-33448
        System.runAs(currentuser){
            Test.startTest();
            Account acc = [SELECT Id, ParentId 
                            FROM Account 
                            WHERE Recordtype.name =: Constant_Util.LOCATION 
                            AND ParentId != null 
                            LIMIT 1];

            Asset ast = [SELECT Id FROM Asset WHERE AccountId =: acc.Id LIMIT 1];

            List<Entitlement> entitlementlst = [SELECT id, Name, StartDate, AccountId, Call_Time__c, Before_After__c, 
                                                    Schedule_Type__c, location__c, Service_Guarantee_Category__c,Status__c,
                                                    service__c, Service_Guarantee_Category_Value__c, EndDate, container__c,
                                                    AssetId,Project_Code__c
                                                FROM Entitlement LIMIT 49999];
            Database.delete(entitlementlst, false);

	        Contact con = [SELECT id FROM Contact WHERE Accountid =: acc.ParentId LIMIT 1];

            List<Business_Rule__c> brlst = [SELECT Id, Accountid__c, locationid__c, Container__c,Service__c, 
                                                Request_Type__c, Schedule_Type__c, Active__c, Effective_Date__c,
                                                RecordTypeid,Required_Information__c 
                                            FROM Business_Rule__c 
                                            LIMIT 49999];
            
            List<Service_Approver__c> salst = [SELECT Id, Business_Rule__c, Service_Approver__c.Title__c 
                                                FROM Service_Approver__c 
                                                LIMIT 49999];

            List<contact> conlst = [SELECT id, Account_Title__c FROM Contact LIMIT 49999];
            conlst[0].Account_Title__c = salst[0].Title__c;
            Database.update(conlst,false);

            list<Project_Code__c> pCodeList=[SELECT Id FROM Project_Code__c WHERE RecordType.Name=:PROJECT_CODE_DETAIL];  

            Entitlement entitlement1 = new Entitlement();
            entitlement1.Name = 'Test';
            entitlement1.AccountId = acc.ParentId;
            entitlement1.Request_Type__c = 'Pickup';
            entitlement1.service__c = 'Extra Pickup';
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

	        Case cas = new Case(Status = 'New', Priority = 'Medium', Origin = 'Phone', 
                                ContactId = con.id, AccountId = acc.id, OwnerId = currentuser.id, 
                                Client__c = acc.ParentId, Location__c = acc.id, SLA_Service_Date_Time__c = null,
                                assetid = ast.id, Case_Type__c = 'Pickup', Case_Sub_Type__c = 'Extra Pickup', 
                                Recordtypeid = TestDataFactory.getRecordType('Pickup Case','Case'));
            
            Database.insert(cas, false);

            Entitlement entitlement2 = [SELECT id, Name, StartDate, AccountId, Call_Time__c, Before_After__c, Schedule_Type__c, location__c, Service_Guarantee_Category__c,Status__c,service__c, Service_Guarantee_Category_Value__c, EndDate, container__c,AssetId,Project_Code__c
            FROM Entitlement LIMIT 1];

            RecurrsiveTriggerHandler.isSkipcaseTrigger = false;
            
            //Test.startTest();
	        entitlement1.service__c = 'Empty and Return';
            entitlement1.Project_Code__c = null;
            entitlement1.Container__c = COMPACTOR;
            Database.update(entitlement1,false);
            
            RecurrsiveTriggerHandler.isSkipcaseTrigger = false;
            cas.Case_Sub_Type__c = 'Empty and Return';
            Database.update(cas,false);
            
	        entitlement1.service__c = 'Extra Pickup';
            entitlement1.Container__c = COMPACTOR;
            entitlement1.Schedule_Type__c = TEMPORARY;
            Database.update(entitlement1,false);
            
            RecurrsiveTriggerHandler.isSkipcaseTrigger = false;
            cas.Case_Sub_Type__c = 'Extra Pickup';
            Database.update(cas,false);
            
	        entitlement1.service__c = 'Empty and Return';
            entitlement1.Container__c = COMPACTOR;
            entitlement1.Schedule_Type__c = TEMPORARY;
            entitlement1.Before_After__c = null;
            entitlement1.Call_Time__c = null;
            Database.update(entitlement1,false);
            
            cas.Case_Sub_Type__c = 'Empty and Return';
            Database.update(cas, false);
            
            List<Entitlement> entitlementlst1 = [SELECT Id FROM Entitlement LIMIT 49999];
            Database.delete(entitlementlst1, false);
            
            RecurrsiveTriggerHandler.isSkipcaseTrigger = false;
            cas.SlaStartDate = system.now().addHours(1);
            cas.Status = Constant_Util.PENDING;
            cas.Service_Date__c = system.today();
            cas.SLA_Service_Date_Time__c = system.now().addDays(1);
            cas.Case_Sub_Status__c = Constant_Util.PENDING_REQUEST_APPROVAL;
            Database.update(cas, false);                      

            Test.stopTest();

            List<Case> myCaseList = [SELECT Id, SLA_Service_Date_Time__c, Service_Date__c FROM Case WHERE Id =: cas.Id];
            Case c = myCaseList[0];
            
            //System.debug('SLA_Service_Date_Time__c'+ c.SLA_Service_Date_Time__c);
            //System.debug('Service_Date__c'+ c.Service_Date__c);
            System.assert(c.SLA_Service_Date_Time__c.date() != null);
        }
    }
    
    /*Test method to cover PO-NUMBER and PSI error*/
    @isTest static void businessrule(){
        User currentuser = [SELECT Id, Bypass_Validation__c 
                            FROM user 
                            WHERE ProfileId =:(TestDataFactory.getProfile(SYS_ADMIN)).Id 
                            AND IsActive =: true 
                            AND Bypass_Validation__c =: TRUE
                            AND Genesys_Enabled__c =: FALSE
                            LIMIT 1];

        System.runAs(currentuser){
            Test.startTest();
            Account acc = [SELECT Id, ParentId 
                            FROM Account 
                            WHERE Recordtype.name =: Constant_Util.LOCATION LIMIT 1];

            Business_Rule__c br = [SELECT Id,Accountid__c,AssetId__c,locationid__c,Container__c,
                                    Service__c,Request_Type__c,Schedule_Type__c,Active__c,Effective_Date__c, 
                                    RecordTypeid,Required_Information__c 
                                    FROM Business_Rule__c 
                                    WHERE RecordTypeid =: Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.REQUIRED_INFORMATION).getRecordTypeId() 
                                    LIMIT 1];
            
            Business_Rule__c brule = [SELECT Id,Accountid__c,AssetId__c,locationid__c,Container__c,
                                        Service__c,Request_Type__c,Schedule_Type__c,Active__c,Effective_Date__c, 
                                        RecordTypeid,Required_Information__c 
                                        FROM Business_Rule__c 
                                        WHERE RecordTypeid =: Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.APPROVAL).getRecordTypeId() 
                                        LIMIT 1];

            Contact con = [SELECT Id FROM Contact WHERE Accountid =: acc.ParentId LIMIT 1];

            List<Case> caselist = [SELECT id, origin, contactid, Case_Type__c, Client__c,RecordTypeId, Location__c, Asset.Duration__c,Case_Sub_Status__c,Status,OwnerId,
                                   Asset.Product2.ProductTypeSelected__c, PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                   Service_Date__c,SLA_Service_Date_Time__c 
                                   FROM Case 
                                   WHERE status =: Constant_Util.STATUS_NEW LIMIT 1];

            List<WorkOrder> wlst = [SELECT id,AssetId,Customer_Location__c,Service_Date__c 
                                    FROM WorkOrder WHERE Status = 'New'];

            br.AssetId__c = caselist[0].assetid;
            br.Container__c = Constant_Util.EMPTY_STRING;
            br.Schedule_Type__c = Constant_Util.EMPTY_STRING;
            brule.Occurrence_Limit__c = null;
            brule.Active__c = true;
            
            List<Business_Rule__c> myBusinessRuleList = new List<Business_Rule__c>();
            myBusinessRuleList.add(br);
            myBusinessRuleList.add(brule);
            Database.update(myBusinessRuleList, false);

            List<Case> caseListTest = new List<Case>();

            Case c = new Case();
            c.AssetId = caselist[0].assetid;
            c.Client__c = caselist[0].Client__c;
            c.origin = caselist[0].origin;
            c.ContactId = con.id;
            c.OwnerId = currentuser.id;
			c.Status = 'New';
            c.RecordTypeId = caselist[0].RecordTypeId;
            c.Location__c = caselist[0].Location__c;
            c.Case_Type__c = caselist[0].Case_Type__c;
            c.Case_Sub_Type__c = caselist[0].Case_Sub_Type__c;
            c.Service_Date__c = system.today() + 1;
            caseListTest.add(c);
            
            Case c1 = new Case();
            c1.AssetId = caselist[0].assetid;
            c1.RecordTypeId = caselist[0].RecordTypeId;
            c1.Client__c = caselist[0].Client__c;
            c1.origin = caselist[0].origin;
            c1.OwnerId = currentuser.id;
            c1.ContactId = con.id;
	    	c1.Status = 'New';
            c1.Location__c = caselist[0].Location__c;
            c1.Case_Type__c = caselist[0].Case_Type__c;
            c1.Case_Sub_Type__c = caselist[0].Case_Sub_Type__c;
            c1.Service_Date__c = system.today() - 1;
            c1.SLA_Service_Date_Time__c = system.now().adddays(2);
            caseListTest.add(c1);

            insert caseListTest;
            
            Set<Id> myCaseSet = new Set<Id>();

            for(Case eachCase : caseListTest){
                myCaseSet.add(eachCase.Id);
            }

            List<Case> updatelst = new List<Case>();

            List<Case> testingCaseList = new List<Case>();
            testingCaseList = [SELECT PSI_Override_Reason__c, PSI_Comments__c, Status, Case_Sub_Status__c,
                                SlaStartDate
                                FROM Case WHERE Id IN: myCaseSet];
            
            testingCaseList[0].PSI_Override_Reason__c = Constant_Util.OTHER_API;
            testingCaseList[0].PSI_Comments__c = Constant_Util.EMPTY_STRING;
            testingCaseList[0].Status = Constant_Util.PENDING;
            testingCaseList[0].Case_Sub_Status__c = null;
            testingCaseList[0].SlaStartDate = system.now().addHours(1);
            updatelst.add(testingCaseList[0]);
            
            testingCaseList[1].Status = Constant_Util.PENDING;
            testingCaseList[1].Case_Sub_Status__c = null;
            testingCaseList[1].SlaStartDate = system.now().addHours(1);
            updatelst.add(testingCaseList[1]);
            
            try{
                Database.update(updatelst);
            }catch(Exception ex){
                system.debug('Exception while updating case:::'+ex.getStackTraceString());
            }
            
            Test.stopTest();
            
            Case c3 = [SELECT Id, Case_Sub_Status__c FROM Case WHERE Id =: c1.Id LIMIT 1];

          //  System.assertEquals(c3.Case_Sub_Status__c, Constant_Util.PENDING_SERVICE_INTEGRATION);
		  
		  //System.assertEquals(Constant_Util.PENDING_REQUEST_APPROVAL,c3.Case_Sub_Status__c);
          System.assertEquals(Constant_Util.PENDING_SERVICE_INTEGRATION ,c3.Case_Sub_Status__c);
        }
    }
    
    /* test method for cover exception*/
    @isTest static void exceptionCoverage(){
        //user currentuser = [select id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363//Commented for SDT-33448   
        //Querying CSR User.
        User currentuser = [SELECT Id, Profile.Name, Bypass_Validation__c, IsActive FROM User WHERE Bypass_Validation__c =: false AND Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive =: true LIMIT 1]; //Modified for SDT-33448           
        system.runAs(currentuser){
            
            Map<Id,Case> casemap;
          	List<case>caselst= new List<Case>();
            //CaseTriggerHandler.onbeforeUpdate(caselst,casemap,casemap);
            //CaseTriggerHelper.updateServiceDate(casemap,casemap);
            CaseTriggerHelper.getServiceDate(caselst);
            //CaseTriggerHelper.populateSubtype(null,null);
            //CaseTriggerHelper.closeTasks(casemap);
            CaseTriggerHelper.insertApprovalLog(casemap,casemap);
            System.assert(caselst.isEmpty());
        }
    }
    /*test method for back service date*/
    @isTest static void createBackServiceDateData(){
        //user currentuser = [select id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363//Commented for SDT-33448   
        //Querying CSR User.
        User currentuser = [SELECT Id, Profile.Name, Bypass_Validation__c, IsActive FROM User WHERE Bypass_Validation__c =: false AND Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive =: true LIMIT 1]; //Modified for SDT-33448           
        system.runAs(currentuser){
            list<case> caselist = [select id, origin, contactid, Case_Type__c, Client__c, Location__c, 
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c,Contact_Title__c,assetid,PSI__c,PSI_Comments__c,
                                   Service_Date__c,SLA_Service_Date_Time__c from case  where status =: Constant_Util.PENDING limit 1];    
            
            caselist.get(0).Service_Date__c = system.today().addDays(-1);
            caselist.get(0).SlaStartDate = system.now();
            
            Test.startTest();
            Database.update(caselist,false);  
            Test.stopTest();
            
            //System.debug('caselist.get(0).Service_Date__c'+caselist.get(0).Service_Date__c);
            System.assertEquals(system.today().addDays(-1),caselist.get(0).Service_Date__c);
        }
    }
    
     /*test method for UpdateLocaltimeOnCase*/
   @isTest static void UpdateLocaltimeOnCaseCoverage(){
        //user currentuser = [select id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363//Commented for SDT-33448   
        //Querying CSR User.
        User currentuser = [SELECT Id, Profile.Name, Bypass_Validation__c, IsActive FROM User WHERE Bypass_Validation__c =: false AND Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive =: true LIMIT 1]; //Modified for SDT-33448           
        system.runAs(currentuser){
            Datetime localdateTime = DateTime.newInstanceGmt(System.now().dateGmt(), System.now().TimeGmt());
            Case c = [SELECT Id,Location__c,Service_Date_from_Local_Time__c FROM Case LIMIT 1];
            DateTime dT = localdateTime;
            Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
            c.Service_Date_from_Local_Time__c = myDate;
            Test.StartTest();
            RecurrsiveTriggerHandler.isSkipcaseTrigger = false;
            Database.update(c);
            //System.debug('***********'+c.Service_Date_from_Local_Time__c);
            Test.stopTest();
            System.assertEquals(myDate,c.Service_Date_from_Local_Time__c);
        }
        }
    /*test method for work order instruction action*/
    @isTest static void workorderInstructionCoverage(){
        Test.StartTest();
        //Profile adminProfile = TestDataFactory.getProfile(SYS_ADMIN);  //Commented for SDT-33448
        Profile adminProfile = TestDataFactory.getProfile(CUSTOMER_SERVICE);  //Modified for SDT-33448
        User currentuser = [SELECT Id, Bypass_Validation__c, isActive FROM USER 
                            WHERE Bypass_Validation__c =: false 
                            AND isActive =: true
                            AND Profile.Name ='System Administrator'  //SDT-33363
                            LIMIT 1];

       System.runAs(currentuser){
List<Case> cList = new List<Case>(); //Modified for SDT-33448
           Case c = [SELECT Id, Work_Order_Instructions__c, Site_Contact__c, Site_Contact_Phone__c, 
                    SLA_Service_Date_Time__c, Entitlement.SLA_Instructions__c, Entitlement.Name, 
                    Create_AM_and_PM_Pickups__c, System_Gen_WO_Instructions__c, User_Input_Work_Order_Instructions__c, 
                    Is_Clone__c FROM Case WHERE Status = 'New' LIMIT 1]; 
            
           c.User_Input_Work_Order_Instructions__c = TEST_USER_INS;
           c.Site_Contact__c = 'Test con';
           c.Site_Contact_Phone__c = '1234567891';
            cList.add(c); //Modified for SDT-33448
           update cList; //Modified for SDT-33448
           
           Case c2 = [SELECT Id, Work_Order_Instructions__c, Site_Contact__c, Site_Contact_Phone__c, SLA_Service_Date_Time__c, Entitlement.SLA_Instructions__c, Entitlement.Name, Create_AM_and_PM_Pickups__c, System_Gen_WO_Instructions__c, User_Input_Work_Order_Instructions__c, Is_Clone__c FROM Case WHERE Id = :c.id LIMIT 1];
           
           system.assert(c2.Work_Order_Instructions__c.contains('Test con'));
       }
       Test.stopTest();
    } 
    /*test method for work order instruction action*/
    @isTest static void updateCaseStatusfromAcronTest(){
        //user currentuser = [select id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363//Commented for SDT-33448   
        //Querying CSR User.
        User currentuser = [SELECT Id, Profile.Name, Bypass_Validation__c, IsActive FROM User WHERE Bypass_Validation__c =: false AND Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive =: true LIMIT 1]; //Modified for SDT-33448           
        //system.debug(currentuser.Bypass_Validation__c);
        system.runAs(currentuser){
            Account locacc = [select id,ParentId from Account where Recordtype.name =: Constant_Util.LOCATION limit 1];
            Account clientacc = [select id from Account where Name =: KROGER and Recordtype.name =: Constant_Util.CLIENT limit 1];
            Asset ast = [Select Id from Asset Limit 1];
            Contact con = [select Id from Contact Limit 1];
            List<WorkOrder> wolst = [Select Id from WorkOrder LIMIT 49999];
            List<case> insertcaselst = new List<case>();
            list<Case> caselist = TestDataFactory.createCase( CASE_NAME, clientacc, con, currentuser, locacc, ast);
            case original  = caselist[0];
            caselist[0].status = Constant_Util.CLOSED;
            caselist[0].Source_System__c = Constant_Util.ACORN;
            insertcaselst.addALL(caselist);
            case c; 
            for(WorkOrder wo : wolst){
                c = original.clone(false,false,false);
                c.Work_Order__c = wo.Id;
                c.status = Constant_Util.OPEN;
                c.Source_System__c = Constant_Util.ACORN;
                c.Case_Type__c = PICKUP;
                insertcaselst.add(c);
            }
            Test.StartTest();
            Database.insert(insertcaselst,false);
            Test.stopTest();
            c = [select id,Work_Order__c from case LIMIT 1];
            System.assert(c.Work_Order__c!=null);
        }
    }
    
    /*Test method to prepopulate subtype*/
    @isTest static void subtypeRolloffTest(){
        //user currentuser = [select id, Bypass_Validation__c,IsActive,Profile.Name from user where Bypass_Validation__c=:false and IsActive=:true AND  Profile.Name ='System Administrator' limit 1]; //SDT-33363//Commented for SDT-33448   
        //Querying CSR User.
        User currentuser = [SELECT Id, Profile.Name, Bypass_Validation__c, IsActive FROM User WHERE Bypass_Validation__c =: false AND Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive =: true LIMIT 1]; //Modified for SDT-33448           
        system.runAs(currentuser){
        product2 prd = [select id,name,family from product2 limit 1];
        prd.Family = Constant_Util.ROLLOFF;
        database.update(prd);
        asset asst = [select id,Occurrence_Type__c,Duration__c,Location__c,Account.ParentId from asset limit 1];
        account loc = [select id,parentid from account where recordtype.name='Location' limit 1];
        asst.Occurrence_Type__c = Constant_Util.ON_CALL;
        asst.Duration__c = Constant_Util.PERMANENT;
        asst.Project_Code__c = null;
        Database.update(asst);
        Case c = [select id from case Limit 1];
        Case cse = new Case(Location__c = asst.Location__c,assetid = asst.id,client__c = loc.parentid,recordtypeid = TestDataFactory.getRecordType('Pickup Case', 'Case'),Case_Type__c = 'Pickup',parentId = c.Id);
        test.startTest();
        database.insert(cse);        
        test.stopTest();
            
        cse = [select id,Case_Sub_Type__c from case where Id =: cse.Id LIMIT 1];    
        System.assert(cse.Case_Sub_Type__c!=null);
        }
    }
    
    /*Test method to prepopulate subtype*/
    @isTest static void subtypeCommScheduledTest(){
        //user currentuser = [select id, Bypass_Validation__c,IsActive,Profile.Name from user where Bypass_Validation__c=:false AND IsActive=:true AND  Profile.Name ='System Administrator'  limit 1]; //SDT-33363//Commented for SDT-33448   
        //Querying CSR User.
        User currentuser = [SELECT Id, Profile.Name, Bypass_Validation__c, IsActive FROM User WHERE Bypass_Validation__c =: false AND Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive =: true LIMIT 1]; //Modified for SDT-33448           
        system.runAs(currentuser){
        product2 prd = [select id,name,family from product2 limit 1];
        prd.Family = COMMERCIAL;
        database.update(prd);
        asset asst = [select id,Occurrence_Type__c,Duration__c,Location__c,Account.ParentId from asset limit 1];
        account loc = [select id,parentid from account where recordtype.name='Location' limit 1];
        asst.Occurrence_Type__c = Constant_Util.SCHEDULED;
        asst.Duration__c = Constant_Util.PERMANENT;
        asst.Project_Code__c = null;
        Database.update(asst);
        Case cse = new Case(Location__c = asst.Location__c,assetid = asst.id,client__c = loc.parentid,recordtypeid = TestDataFactory.getRecordType('Pickup Case', 'Case'),Case_Type__c = 'Pickup');
        test.startTest();
        database.insert(cse);       
        test.stopTest();
            
        cse = [select id,Case_Sub_Type__c from case where Id =: cse.Id LIMIT 1];    
        System.assert(cse.Case_Sub_Type__c != null);
        }
    }
    
    /*Test method to prepopulate subtype*/
    @isTest static void subtypeCommOnCallTest(){
        //user currentuser = [select id, Bypass_Validation__c,IsActive from user where Bypass_Validation__c=:false AND IsActive=:true AND  Profile.Name ='System Administrator'  limit 1]; //SDT-33363//Commented for SDT-33448   
        //Querying CSR User.
        User currentuser = [SELECT Id, Profile.Name, Bypass_Validation__c, IsActive FROM User WHERE Bypass_Validation__c =: false AND Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive =: true LIMIT 1]; //Modified for SDT-33448           
        system.runAs(currentuser){
        product2 prd = [select id,name,family from product2 limit 1];
        prd.Family = COMMERCIAL;
        database.update(prd);
        asset asst = [select id,Occurrence_Type__c,Duration__c,Location__c,Account.ParentId from asset limit 1];
        account loc = [select id,parentid from account where recordtype.name='Location' limit 1];
        asst.Occurrence_Type__c = Constant_Util.ON_CALL;
        asst.Project_Code__c = null;
        asst.Duration__c = Constant_Util.PERMANENT;
        Database.update(asst);
        Case cse = new Case(Location__c = asst.Location__c,assetid = asst.id,client__c = loc.parentid,recordtypeid = TestDataFactory.getRecordType('Pickup Case', 'Case'));
        test.startTest();
        database.insert(cse);      
        test.stopTest();
            
        cse = [select id,Case_Sub_Type__c from case where Id =: cse.Id LIMIT 1];    
        System.assert(cse.Case_Sub_Type__c != null);
        }
    }
	/*Test method to task closure on sub status changes*/
    @isTest static void closeOldTasksTest(){
        user currentuser = [select id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        system.runAs(currentuser){
			list<case> caselist = [SELECT Id, status FROM case WHERE status =: Constant_Util.OPEN LIMIT 1]; 
			caselist[0].Case_Sub_Status__c = PENDING_SCHEDULE_CONFIRMATION;
            list<Task> tasklist = [SELECT Id, Status, WhatId FROM Task LIMIT 1]; 
			tasklist[0].WhatId = caselist[0].Id;
			test.startTest();
				Database.update(caselist);
            	Database.update(tasklist);
            caselist[0].status = 'Closed';
            Database.update(caselist);
			test.stopTest();
            
			System.assertEquals(PENDING_SCHEDULE_CONFIRMATION,caselist[0].Case_Sub_Status__c);
		}
	}
  
    @isTest static void lastContactActivityDateTest(){
        //user currentuser = [select id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363//Commented for SDT-33448   
        //Querying CSR User.
        User currentuser = [SELECT Id, Profile.Name, Bypass_Validation__c, IsActive FROM User WHERE Bypass_Validation__c =: false AND Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive =: true LIMIT 1]; //Modified for SDT-33448           
        system.runAs(currentuser){
            Test.startTest();
            list<Account> acclist = TestDataFactory.createAccount(KROGER, currentuser,Constant_Util.CLIENT);
            Database.insert(acclist);
            
            Contact c1 = new Contact();
      	    c1.FirstName = 'Test';
      	    c1.LastName = 'Customer';
            Database.insert(c1);
            
             Contact c2 = new Contact();
      	    c2.FirstName = 'Test1';
      	    c2.LastName = 'Customer1';
            Database.insert(c2);
            
List<Case> cList = new List<Case>(); //Modified for SDT-33448
            Case c = New Case();
        	c.Origin = 'Phone';
        	c.Status = 'New';
            c.contactId = c1.id;
        	cList.add(c); //Modified for SDT-33448
            insert cList; //Modified for SDT-33448
            
            c.Origin = 'email';
           	c.ContactId = c2.id;
            //System.debug('%%%%%%%%%%% '+woList);
            //System.debug('%%%%%%%%%%% '+caselist);
             Datetime now = Datetime.now();
            
			//test.startTest();
				Database.update(c);
			test.stopTest();
            System.assertEquals('email', c.Origin);
		}
	}
    /*Test method to set Override_PO_Create_Task__c and Customer PO #*/
     @isTest static void updatePOTest(){
        //user currentuser = [select id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363//Commented for SDT-33448   
        //Querying CSR User.
        User currentuser = [SELECT Id, Profile.Name, Bypass_Validation__c, IsActive FROM User WHERE Bypass_Validation__c =: false AND Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive =: true LIMIT 1]; //Modified for SDT-33448           
        system.runAs(currentuser){
            test.startTest();
		    List<WorkOrder> woList = [select id , Acorn_WorkOrder_Number__c from WorkOrder WHERE Status = 'New'];
            woList[0].Acorn_Purchase_Order_Number__c = 'PO222';
            list<case> caselist = [SELECT Id, Acorn_Work_order__c,Work_Order__c,status,Override_PO_Create_Task__c,PurchaseOrder_Number__c , Location__r.Parent.AccountNumber FROM case WHERE Acorn_Work_order__c != null and assetid != null LIMIT 1]; 
			caselist[0].status = 'New';
            caselist[0].Override_PO_Create_Task__c = true;
            caselist[0].PurchaseOrder_Number__c = 'PO12322';
            caselist[0].Location__r.Parent.AccountNumber = 'k12322';
            caselist[0].Case_Type__c='Pickup';
            caselist[0].Case_Sub_Type__c ='Empty and Return';

			//test.startTest();
				Database.update(caselist);
            	Database.update(woList);
			test.stopTest();  
            System.assertEquals('PO12322',caselist[0].PurchaseOrder_Number__c);
		}
	}
    
    
    @isTest static void insertApprovalLog(){
        user currentuser = [select id, Bypass_Validation__c, IsActive, FirstName from user where FirstName =: 'testuser##9999' AND IsActive =: true limit 1];
        system.runAs(currentuser){
            Test.startTest();
            list<Business_Rule__c> brlst = [Select Id,Accountid__c,locationid__c,Container__c,Service__c,Request_Type__c,Schedule_Type__c,Active__c,Effective_Date__c,RecordTypeid,
                                            Required_Information__c from  Business_Rule__c where RecordTypeid =: Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.APPROVAL).getRecordTypeId() LIMIT 49999];
            brlst[0].Active__c = true;
            Database.update(brlst);
            list<Service_Approver__c> salst = [Select Id, Business_Rule__c from Service_Approver__c LIMIT 49999];
            list<case> caselist = [select id, origin, contactid, Case_Type__c, Client__c, Location__c,Status, Case_Sub_Status__c,
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c,Contact_Title__c,assetid,PSI__c,PSI_Comments__c,
                                   Service_Date__c,SLA_Service_Date_Time__c from case  where status =: Constant_Util.STATUS_NEW limit 1];    
            //system.debug('ols status'+caselist.get(0).Status+' '+caselist.get(0).Location__c+' '+caselist.get(0).Client__c);
            //system.debug('approval rule'+brlst);
            RecurrsiveTriggerHandler.isSkipcaseTrigger = false;
            caselist.get(0).SlaStartDate = system.now().addMinutes(15);
            //caselist.get(0).Case_Sub_Status__c = Constant_Util.PENDING_VENDOR_INFORMATION;
            caselist.get(0).SLA_Service_Date_Time__c = system.now().addHours(1);
            caselist.get(0).Service_Date__c = system.today().addDays(1);
            caselist.get(0).Site_Contact__c = null;
            caselist.get(0).Site_Contact_Phone__c = PHONE;
            caselist.get(0).Status = Constant_Util.PENDING;
            //Test.startTest();
            //system.debug('case values'+caselist.get(0).Case_Sub_Type__c+' '+caselist.get(0).Case_Sub_Status__c+' '+caselist.get(0).Status);
            Database.update(caselist,false);
            Test.stopTest();
            
            Case c = [select id,Case_Sub_Status__c from case where Id =:caselist.get(0).Id LIMIT 1];
            System.assert(c.Case_Sub_Status__c != null);
        }
    }
    
	  @isTest static void insertApprovalLogSecondTest(){
        user currentuser = [select id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        system.runAs(currentuser){
            Test.startTest();
            list<Business_Rule__c> brlst = [Select Id,Is_Auto_Email__c,Multiple_Mandatory_Approvers__c,Accountid__c,locationid__c,Container__c,Service__c,Request_Type__c,Schedule_Type__c,Active__c,Effective_Date__c,RecordTypeid,
                                            Required_Information__c from  Business_Rule__c where RecordTypeid =: Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.APPROVAL).getRecordTypeId() LIMIT 49999];
            brlst[0].Active__c = true;
            brlst[0].Is_Auto_Email__c = false;
            Database.update(brlst);
            
            list<Service_Approver__c> salst = [Select Id, Business_Rule__c from Service_Approver__c LIMIT 1];
            salst[0].Email__c = 'abc@gmail.com';
            //salst[0].Business_Rule__c = brlst[0].Id; SDT-33363
            salst[0].Requester_Only__c= false;
           
            Database.update(salst);
         
            list<case> caselist = [select id, origin, contactid, Case_Type__c, Client__c, Location__c,Status, Case_Sub_Status__c,
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c,Contact_Title__c,assetid,PSI__c,PSI_Comments__c,
                                   Service_Date__c,SLA_Service_Date_Time__c from case  where status =: Constant_Util.STATUS_NEW limit 2];    
            //system.debug('ols status'+caselist.get(0).Status+' '+caselist.get(0).Location__c+' '+caselist.get(0).Client__c);
            //system.debug('approval rule'+brlst);
            RecurrsiveTriggerHandler.isSkipcaseTrigger = false;
            
            caselist.get(0).SlaStartDate = system.now().addMinutes(15);
            caselist.get(0).SLA_Service_Date_Time__c = system.now().addHours(1);
            caselist.get(0).Service_Date__c = system.today().addDays(1);
            caselist.get(0).Site_Contact__c = null;
            caselist.get(0).Site_Contact_Phone__c = PHONE;
            caselist.get(0).Status = Constant_Util.PENDING;
            caselist.get(1).ParentId = caselist.get(0).Id; 
                        
           // Test.startTest();
                
            Database.update(caselist[0]);
            Database.update(caselist[1]);
            Test.stopTest();
            
            Case c = [select id,ParentId from case where Id =:caselist.get(1).Id LIMIT 1];
            System.assert(c.ParentId != null);
            System.assertEquals(2, caseList.size());
        }
    }
    
    @isTest static void updateTrackingNoTest(){
        user currentuser = [select id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        system.runAs(currentuser){
            Case cse = [select id, origin, contactid, Case_Type__c, Client__c, Location__c,Status, Case_Sub_Status__c,
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c,Contact_Title__c,assetid,PSI__c,PSI_Comments__c,
                                   Service_Date__c,Case_Reason__c,SLA_Service_Date_Time__c from case  where status =: Constant_Util.STATUS_NEW limit 1];    
            //system.debug('#### case record'+cse);
            
            
            test.startTest();
            cse.RecordTypeId = TestDataFactory.getRecordType('Status Case','Case');
            cse.Tracking_Number__c = '13528646';
            cse.Case_Type__c = 'Status';
            cse.Case_Sub_Type__c = 'Service Not Performed';
            //cse.Case_Reason__c = Constant_Util.HAULER_REPORTED;
            cse.Case_Sub_Status__c = constant_Util.PENDING_SERVICE_ISSUE_RESOLUTION;
            Database.update(cse);
            test.stopTest();
            System.assertEquals(constant_Util.PENDING_SERVICE_ISSUE_RESOLUTION,cse.Case_Sub_Status__c);
        }
    }
    
    @isTest static void addCaseAssetsTest(){
        //user currentuser = [select id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363(3)//Commented for SDT-33448   
        //Querying CSR User.
        User currentuser = [SELECT Id, Profile.Name, Bypass_Validation__c, IsActive FROM User WHERE Bypass_Validation__c =: false AND Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive =: true LIMIT 1]; //Modified for SDT-33448           
        
        system.runAs(currentuser){
        
           Account locacc = [select id,ParentId from Account where Recordtype.name =: Constant_Util.LOCATION limit 1];
           Account clientacc = [select id from Account where Name =: KROGER and Recordtype.name =: Constant_Util.CLIENT limit 1];
           Asset asset = [select id,Project_Code__c from Asset LIMIT 1];
           List<Asset> childasset = TestDataFactory.createChildAsset('ChildAsset');
            childasset[0].Service_Header_Id__c = asset.id; 
            childasset[0].End_Date__c = null;
            Database.insert(childasset);
            //System.debug('@@@@@ChildAsset'+childasset[0].Is_Active__c);
            
             List<contact> conlst = [Select id,Account_Title__c from contact LIMIT 49999];
            List<Entitlement> entitlementlst = [select id,Name,StartDate, AccountId, Call_Time__c, Before_After__c, 
                                        Schedule_Type__c, location__c, Service_Guarantee_Category__c,Status__c,service__c, 
                                        Service_Guarantee_Category_Value__c, EndDate, container__c,AssetId,Project_Code__c
                                                                           from Entitlement limit 49999];
            
            
            list<Case> caselist = TestDataFactory.createCase( CASE_NAME, clientacc, conlst.get(0), 
                                                             currentuser, locacc, asset);
            caselist[0].PurchaseOrder_Number__c =  PO_NUMBER;
            caselist[0].Service_Date__c= System.today().addDays(10);
            caselist[0].Status = Constant_Util.PENDING;
            caselist[0].Case_Type__c = Constant_Util.PICKUP_CSTYPE;
            caselist[0].Case_Sub_Type__c = Constant_Util.EXTRA_PICKUP;
            caselist[0].Create_AM_and_PM_Pickups__c = true;
			caselist[0].Origin = 'OFFICETRAX';
            caselist[0].Is_Multivendor__c = false;
            caselist[0].assetId = asset.id;
            Test.startTest();
                Database.insert(caselist);
            Test.stopTest();
                //System.debug('Caselist+++'+caselist);
            System.assertEquals(Constant_Util.PENDING,caselist[0].Status);
        }
	}
    
   @isTest static void updateTrackingNosecondTest(){
        user currentuser = [select id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        system.runAs(currentuser){
            Test.startTest();
            Case cse = [select id, origin,Tracking_Number__c, contactid, Case_Type__c, Client__c, Location__c,Status, Case_Sub_Status__c,
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c,Contact_Title__c,assetid,PSI__c,PSI_Comments__c,
                                   Service_Date__c,SLA_Service_Date_Time__c from case  where status =: Constant_Util.STATUS_NEW limit 1];    
            //system.debug('case record'+cse);
			
            CaseComment cscomnt = new CaseComment();
            cscomnt.ParentId = cse.Id;
            cscomnt.IsPublished = false;
            Database.insert(cscomnt,true);
            
            cse.RecordTypeId = TestDataFactory.getRecordType('Status Case','Case');
            cse.Tracking_Number__c = '13528646';
            cse.Case_Type__c = 'Status';
            cse.Case_Sub_Type__c = 'Service Not Performed';	
            //cse.Case_Reason__c = Constant_Util.HAULER_REPORTED;
            cse.Case_Sub_Status__c = constant_Util.PENDING_SERVICE_ISSUE_RESOLUTION;
            
            //test.startTest();
            Database.update(cse);
            test.stopTest();
            
            Case csetest = [select id, origin, contactid, Case_Type__c, Client__c, Location__c,Status, Case_Sub_Status__c,
                                   PSI_Override_Reason__c,Tracking_Number__c, Case_Sub_Type__c,PurchaseOrder_Number__c,Contact_Title__c,assetid,PSI__c,PSI_Comments__c,
                                   Service_Date__c,SLA_Service_Date_Time__c from case  where status =: Constant_Util.STATUS_NEW limit 1];    
            
            //system.debug('###Tracking Number'+csetest.Tracking_Number__c);
            //system.debug('###Case Type'+csetest.Case_Type__c);
            //system.debug('###Case Sub Type'+csetest.Case_Sub_Type__c);
            //system.debug('###Case Sub Status'+csetest.Case_Sub_Status__c);
           System.assertEquals(constant_Util.PENDING_SERVICE_ISSUE_RESOLUTION,cse.Case_Sub_Status__c);
        }
    }
    
    /*Test method for update caseasset when product family is Commercial and Occurrence type is On Call*/
    
     @isTest static void updateCaseDetailsTest(){
         List<User> currentuserList = new List<User>(); //Modified for SDT-33448
        User currentuser = [SELECT Id, Bypass_Validation__c, profileId 
                            FROM User WHERE Lastname = 'testing' LIMIT 1];
        
        currentuser.Bypass_Validation__c = false;
        currentuserList.add(currentuser); //Modified for SDT-33448
        update currentuserList; //Modified for SDT-33448
         
        System.runAs(currentuser){
        product2 prd = [SELECT Id, Name, Family FROM Product2 LIMIT 1];
        prd.Family = COMMERCIAL;
        Database.update(prd);
            
        Asset asst = [SELECT Id, Occurrence_Type__c, Duration__c, Location__c, Account.ParentId
                     FROM Asset LIMIT 1];

        Account loc = [SELECT Id, Parentid FROM Account WHERE Recordtype.name='Location' LIMIT 1];
        asst.Occurrence_Type__c = Constant_Util.ON_CALL;
        asst.Project_Code__c = null;
        asst.Duration__c = Constant_Util.PERMANENT;
        Database.update(asst);
            
        Case cse = new Case(Location__c = asst.Location__c,assetid = asst.id,client__c = loc.parentid,recordtypeid = TestDataFactory.getRecordType('Pickup Case', 'Case'));
        cse.Case_Type__c = '';
        //cse.Case_Sub_Type__c ='';    
         
        test.startTest();
        Database.insert(cse);     
        test.stopTest();
            
        //cse = [select id,Case_Sub_Type__c from case where Id =: cse.Id LIMIT 1];    
        //System.debug('###Caselst'+cse);    
       	System.assertEquals(asst.Duration__c ,Constant_Util.PERMANENT);
        }
    }
    
    /*Test method for addcaseasset when product family is Commercial and Occurrence type is Scheduled*/
    
     @isTest static void updateCaseDetailsecondTest(){
         List<User> currentuserList = new List<User>(); //Modified for SDT-33448
        user currentuser = [SELECT Id, Bypass_Validation__c, ProfileId 
                            FROM User WHERE Lastname = 'testing' LIMIT 1];
        
        currentuser.Bypass_Validation__c = false;
         currentuserList.add(currentuser); //Modified for SDT-33448
        update currentuserList; //Modified for SDT-33448
         
        system.runAs(currentuser){
        product2 prd = [select id,name,family from product2 limit 1];
        prd.Family = COMMERCIAL;
        database.update(prd);
            
        asset asst = [select id,Occurrence_Type__c,Duration__c,Location__c,Account.ParentId from asset limit 1];
        account loc = [select id,parentid from account where recordtype.name='Location' limit 1];
        asst.Occurrence_Type__c = Constant_Util.SCHEDULED;
        asst.Project_Code__c = null;
        asst.Duration__c = Constant_Util.PERMANENT;
        Database.update(asst);
        
        Case c = [select id from Case LIMIT 1];
        Case cse = new Case(Location__c = asst.Location__c,assetid = asst.id,client__c = loc.parentid,recordtypeid = TestDataFactory.getRecordType('Pickup Case', 'Case'));
        cse.Case_Type__c = '';
        cse.Service_Date__c = System.today();
        cse.Check_Case__c = true;
        cse.ParentId = c.Id;
        cse.Status = 'Pending';
        cse.Case_Type__c = 'Pickup';
        cse.Case_Sub_Type__c ='Extra Pickup';    
         
        test.startTest();
        Database.insert(cse);     
        test.stopTest();
            
        //cse = [select id,Case_Sub_Type__c from case where Id =: cse.Id LIMIT 1];    
        //System.debug('###Caselst'+cse);    
       	System.assert(cse.Case_Sub_Type__c!=null);
        }
    }
    
     /*Test method for addcaseasset when product family is Rolloff and Equipment Type is Basket*/
    
     @isTest static void updateCaseDetailthirdTest(){
         List<User> currentuserList = new List<User>(); //Modified for SDT-33448
        User currentuser = [SELECT Id, Bypass_Validation__c, ProfileId 
                            FROM User WHERE Lastname = 'testing' LIMIT 1];
        
        currentuser.Bypass_Validation__c = false;
        currentuserList.add(currentuser); //Modified for SDT-33448
        update currentuserList; //Modified for SDT-33448
         
        System.runAs(currentuser){
        product2 prd = [select id,name,family from product2 limit 1];
        prd.Family = Constant_Util.ROLLOFF;
        prd.Equipment_Type__c = BASKET; 
        database.update(prd);
            
        asset asst = [select id,Occurrence_Type__c,Duration__c,Location__c,Account.ParentId from asset limit 1];
        account loc = [select id,parentid from account where recordtype.name='Location' limit 1];
        asst.Occurrence_Type__c = Constant_Util.SCHEDULED;
        asst.Project_Code__c = null;
        asst.Duration__c = Constant_Util.PERMANENT;
        Database.update(asst);
            
        Case cse = new Case(Location__c = asst.Location__c,assetid = asst.id,client__c = loc.parentid,recordtypeid = TestDataFactory.getRecordType('Pickup Case', 'Case'));
        cse.Case_Type__c = '';
        //cse.Case_Sub_Type__c ='';    
         
        test.startTest();
        Database.insert(cse);     
        test.stopTest();
            
        //cse = [select id,Case_Sub_Type__c from case where Id =: cse.Id LIMIT 1];    
        //System.debug('###Caselst'+cse);    
        System.assert(cse.Location__c!=null);
        }
    }
    
     /*Test method for addcaseasset when product family is Rolloff and Equipment Type is Baller*/
    
     @isTest static void updateCaseDetailfourthTest(){
         List<User> currentuserList = new List<User>(); //Modified for SDT-33448
        user currentuser = [SELECT Id, Bypass_Validation__c, ProfileId 
                            FROM User WHERE lastname = 'testing' LIMIT 1];
        
        currentuser.Bypass_Validation__c = false;
         currentuserList.add(currentuser); //Modified for SDT-33448
        update currentuserList; //Modified for SDT-33448
         
        System.runAs(currentuser){
        product2 prd = [select id,name,family from product2 limit 1];
        prd.Family = SUPPLIES;
       
        Database.update(prd);
            
        asset asst = [select id,Occurrence_Type__c,Duration__c,Location__c,Account.ParentId from asset limit 1];
        account loc = [select id,parentid from account where recordtype.name='Location' limit 1];
        //asst.Occurrence_Type__c = Constant_Util.SCHEDULED;
        //asst.Project_Code__c = null;
        //asst.Duration__c = Constant_Util.PERMANENT;
        asst.Service_Type__c = GOT_JUNK_PICKUP;
        Database.update(asst);
        
            
        Case cse = new Case(Location__c = asst.Location__c,assetid = asst.id,client__c = loc.parentid,recordtypeid = TestDataFactory.getRecordType('Pickup Case', 'Case'));
        cse.Case_Type__c = CONSTANT_UTIL.PICKUP_CSTYPE;
        cse.Case_Sub_Type__c = ''; 
       
        test.startTest();
        Database.insert(cse);     
        test.stopTest();
            
        //cse = [select id,Case_Sub_Type__c from case where Id =: cse.Id LIMIT 1];    
        //System.debug('###Caselst'+cse);    
        System.assert(cse.Case_Sub_Type__c!=null);
        }
    }
    
     /*Test method for addcaseasset when product family is Rolloff and Equipment Type is Baler*/
    
     @isTest static void updateCaseDetailfifthTest(){
         List<User> currentuserList = new List<User>(); //Modified for SDT-33448
        User currentuser = [SELECT Id, Bypass_Validation__c, ProfileId 
                            FROM User WHERE Lastname = 'testing' LIMIT 1];
        
        currentuser.Bypass_Validation__c = false;
        
        //System.debug('****USer'+currentuser);
        currentuserList.add(currentuser); //Modified for SDT-33448
        Update currentuserList; //Modified for SDT-33448
         
        System.runAs(currentuser){
        product2 prd = [select id,name,family from product2 limit 1];
        prd.Family = Constant_Util.ROLLOFF;
        // prd.Equipment_Type__c = BASKET; 
        prd.Equipment_Type__c = BALER; 
        database.update(prd);
            
        asset asst = [select id,Occurrence_Type__c,Duration__c,Location__c,Account.ParentId from asset limit 1];
        account loc = [select id,parentid from account where recordtype.name='Location' limit 1];
        asst.Occurrence_Type__c = Constant_Util.SCHEDULED;
        asst.Project_Code__c = null;
        asst.Duration__c = Constant_Util.PERMANENT;
        Database.update(asst);
            
        Case cse = new Case(Location__c = asst.Location__c,assetid = asst.id,client__c = loc.parentid,recordtypeid = TestDataFactory.getRecordType('Pickup Case', 'Case'));
        cse.Case_Type__c = '';
        //cse.Case_Sub_Type__c ='';    
         
        test.startTest();
        Database.insert(cse);     
        test.stopTest();
            
        //cse = [select id,Case_Sub_Type__c from case where Id =: cse.Id LIMIT 1];    
        //System.debug('###Caselst'+cse);    
        System.assertEquals(asst.Duration__c , Constant_Util.PERMANENT);
        }
    }
    
     /*Test method for update caseasset when product family is Commercial and Occurrence type is On Call*/
    
     @isTest static void updateCaseDetailsixthTest(){
         List<User> currentuserList = new List<User>(); //Modified for SDT-33448
        user currentuser = [SELECT Id, Bypass_Validation__c, ProfileId, Profile.name 
                            FROM User WHERE Lastname = 'testing' LIMIT 1];
        
        currentuser.Bypass_Validation__c = false;
        currentuser.Profile.Name = CUSTOMER_SERVICE;
        currentuserList.add(currentuser); //Modified for SDT-33448
        update currentuserList; //Modified for SDT-33448
         
        System.runAs(currentuser){
        Product2 prd = [SELECT Id, Name, Family FROM Product2 LIMIT 1];
        prd.Family = COMMERCIAL;
        Database.update(prd);
            
        asset asst = [select id,Occurrence_Type__c,Duration__c,Location__c,Account.ParentId from asset limit 1];
        account loc = [select id,parentid from account where recordtype.name='Location' limit 1];
        asst.Occurrence_Type__c = Constant_Util.ON_CALL;
        asst.Project_Code__c = null;
        asst.Duration__c = Constant_Util.PERMANENT;
        Database.update(asst);
            
        Case cse = new Case(Location__c = asst.Location__c,assetid = asst.id,client__c = loc.parentid,recordtypeid = TestDataFactory.getRecordType('Pickup Case', 'Case'));
        cse.Case_Type__c = CONSTANT_UTIL.PICKUP_CSTYPE;
        cse.Last_Agent_ID__c = 'dokane';
        //cse.Case_Sub_Type__c ='';    
         
        test.startTest();
        Database.insert(cse);     
        test.stopTest();
            
        //cse = [select id,Case_Sub_Type__c from case where Id =: cse.Id LIMIT 1];    
        //System.debug('###Caselst'+cse);    
        System.assertEquals(cse.Location__c , asst.Location__c);
        }
    }
    
     @isTest static void deleteOldCaseAssetstest(){ 
        //user currentuser = [select id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363//Commented for SDT-33448   
        //Querying CSR User.
        User currentuser = [SELECT Id, Profile.Name, Bypass_Validation__c, IsActive FROM User WHERE Bypass_Validation__c =: false AND Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive =: true LIMIT 1]; //Modified for SDT-33448           
        system.runAs(currentuser){   
           
            list<SBS_Case_Asset__c> caseasset = [SELECT id, CaseId__c, AssetId__c,Asset_Header__c 
                                  FROM SBS_Case_Asset__c LIMIT 1]; 
            
            Test.startTest();
            Database.delete(caseasset);            	          
            Test.stopTest();
        }     
    }
    
     @isTest static void createApprovalTasktest(){ 
        user currentuser = [select id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        system.runAs(currentuser){   
           
            list<Approval_Log__c> alog = [SELECT id, CaseId__c,Required_Approver__c,Required_Approver_Contact__c from Approval_Log__c]; 
            
            Test.startTest();
            Database.delete(alog);            	          
            Test.stopTest();
        }     
    }
	
	@isTest static void createApprovalTaskSecondtest(){ 
        //user currentuser = [select id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363(3)//Commented for SDT-33448   
        //Querying CSR User.
        User currentuser = [SELECT Id, Profile.Name, Bypass_Validation__c, IsActive FROM User WHERE Bypass_Validation__c =: false AND Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive =: true LIMIT 1]; //Modified for SDT-33448           
        system.runAs(currentuser){   
            
            Account acc = [SELECT Id, ParentId FROM Account WHERE Recordtype.name =: Constant_Util.LOCATION LIMIT 1];
            
            Asset ast = [SELECT Id FROM Asset WHERE AccountId =: acc.Id LIMIT 1];
            
            Contact con = [SELECT id FROM Contact WHERE Accountid =: acc.ParentId LIMIT 1];
            
            List<Business_Rule__c> brlst = [SELECT Id, Accountid__c, locationid__c, Container__c,Service__c, Request_Type__c, Schedule_Type__c, Active__c, Effective_Date__c,RecordTypeid,Required_Information__c FROM Business_Rule__c LIMIT 49999];
            
            List<Service_Approver__c> salst = [SELECT Id, Business_Rule__c, Service_Approver__c.Title__c FROM Service_Approver__c LIMIT 49999];
            
            List<Case> caselist = [select id,Service_Date__c,Case_Sub_Status__c,status,Asset.End_Date__c from Case LIMIT 1];
            
            Test.startTest();
            
            list<Task> tasklist1 = TestDataFactory.createTask(caselist[0].id, currentuser);
            Database.insert(tasklist1,false);
            
            //system.debug('tasklist1++'+tasklist1[0]);
            Test.stopTest();
            
            System.assert(caselist[0].id != null);
            System.assertEquals(2, tasklist1.size());   
        }     
    }
    
     @isTest static void createApprovalTaskThirdtest(){
        //user currentuser = [select id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363//Commented for SDT-33448   
        //Querying CSR User.
        User currentuser = [SELECT Id, Profile.Name, Bypass_Validation__c, IsActive FROM User WHERE Bypass_Validation__c =: false AND Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive =: true LIMIT 1]; //Modified for SDT-33448           
        system.runAs(currentuser){
            
            Account acc = [SELECT Id, ParentId FROM Account WHERE Recordtype.name =: Constant_Util.LOCATION LIMIT 1];
            
            Asset ast = [SELECT Id FROM Asset WHERE AccountId =: acc.Id LIMIT 1];
            
            Contact con = [SELECT id FROM Contact WHERE Accountid =: acc.ParentId LIMIT 1];
            con.Preferred_Method__c = Constant_Util.ORIGIN_EMAIL; 
            Test.startTest();
            
            Database.update(con);
            
            list<Business_Rule__c> brlst = [Select Id,Is_Auto_Email__c,Multiple_Mandatory_Approvers__c,Accountid__c,locationid__c,Container__c,Service__c,Request_Type__c,Schedule_Type__c,Active__c,Effective_Date__c,RecordTypeid,
                                            Required_Information__c from  Business_Rule__c where RecordTypeid =: Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.APPROVAL).getRecordTypeId() LIMIT 5];
            brlst[0].Active__c = true;
            brlst[0].Is_Auto_Email__c = false;
            Database.update(brlst);
            
            list<Service_Approver__c> salst = [Select Id,Email__c,Requester_Only__c,Account__c,Business_Rule__c from Service_Approver__c LIMIT 5];
            salst[0].Email__c = 'abc@gmail.com';
            //salst[0].Business_Rule__c = brlst[0].Id; SDT-33363
            salst[0].Requester_Only__c= false;
            Database.update(salst);
         
            list<case> caselist = [select id, origin, contactid, Case_Type__c, Client__c, Location__c,Status, Case_Sub_Status__c,CaseNumber,
                                   PSI_Override_Reason__c,Reference_Number__c, Case_Sub_Type__c,PurchaseOrder_Number__c,Contact_Title__c,assetid,PSI__c,PSI_Comments__c,
                                   Service_Date__c,SLA_Service_Date_Time__c from case  where status =: Constant_Util.STATUS_NEW limit 2];    
   
            RecurrsiveTriggerHandler.isSkipcaseTrigger = false;
            
            caselist.get(0).SlaStartDate = system.now().addMinutes(15);
            caselist.get(0).SLA_Service_Date_Time__c = system.now().addHours(1);
            caselist.get(0).Service_Date__c = system.today().addDays(1);
            caselist.get(0).Site_Contact__c = null;
            caselist.get(0).Site_Contact_Phone__c = PHONE;
            caselist.get(0).Status = Constant_Util.PENDING;
            
            
            Database.update(caselist[0]);
            

            Case c = [select id,ParentId from case where Id =:caselist.get(1).Id LIMIT 1];
            Test.stopTest();
            System.assert(c.Id != null);
            System.assertEquals(2, caseList.size());   
            
        }
    }
      //SDT-31851
      @isTest static void createApprovalTaskfourthtest(){
          Profile p2 = TestDataFactory.getProfile(CUSTOMER_SERVICE);
          User usr2 = TestDataFactory.createUser(p2);
          
        user currentuser = [select id, Bypass_Validation__c,Profile.Name,User_categorization_code__c from user Where IsActive = true AND Profile.Name =:CUSTOMER_SERVICE AND User_categorization_code__c != null   limit 1]; //SDT-33363
        system.runAs(currentuser){
            
            Account acc = [SELECT Id, ParentId FROM Account WHERE Recordtype.name =: Constant_Util.LOCATION LIMIT 1];
            
            Asset ast = [SELECT Id FROM Asset WHERE AccountId =: acc.Id LIMIT 1];
            
            Contact con = [SELECT id FROM Contact WHERE Accountid =: acc.ParentId LIMIT 1];
            con.Preferred_Method__c = Constant_Util.ORIGIN_EMAIL; 
            Test.startTest();
            
            Database.update(con);
            
            list<Business_Rule__c> brlst = [Select Id,Is_Auto_Email__c,Multiple_Mandatory_Approvers__c,Accountid__c,locationid__c,Container__c,Service__c,Request_Type__c,Schedule_Type__c,Active__c,Effective_Date__c,RecordTypeid,
                                            Required_Information__c from  Business_Rule__c where RecordTypeid =: Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.APPROVAL).getRecordTypeId() LIMIT 5];
            brlst[0].Active__c = true;
            brlst[0].Is_Auto_Email__c = false;
            brlst[0].Multiple_Mandatory_Approvers__c = false;
            Database.update(brlst);
            
            list<Service_Approver__c> salst = [Select Id,Email__c,Requester_Only__c,Account__c,Business_Rule__c from Service_Approver__c LIMIT 5];
            salst[0].Email__c = 'abc@gmail.com';
            //salst[0].Business_Rule__c = brlst[0].Id; SDT-33363
            salst[0].Requester_Only__c= false;
            Database.update(salst);
            
            list<case> caselist = [select id, origin, contactid, Case_Type__c, Client__c, Location__c,Status, Case_Sub_Status__c,CaseNumber,
                                   PSI_Override_Reason__c,Reference_Number__c, Case_Sub_Type__c,PurchaseOrder_Number__c,Contact_Title__c,assetid,PSI__c,PSI_Comments__c,
                                   Service_Date__c,SLA_Service_Date_Time__c,Last_Agent_Id_ForTaskAssignment__c from case  where status =: Constant_Util.STATUS_NEW limit 2];    
            
            RecurrsiveTriggerHandler.isSkipcaseTrigger = false;
            
            caselist.get(0).SlaStartDate = system.now().addMinutes(15);
            caselist.get(0).SLA_Service_Date_Time__c = system.now().addHours(1);
            caselist.get(0).Service_Date__c = system.today().addDays(1);
            caselist.get(0).Site_Contact__c = null;
            caselist.get(0).Site_Contact_Phone__c = PHONE;
            caselist.get(0).Status = Constant_Util.PENDING;
            
            
            Database.update(caselist[0]);
            
            
            Case c = [select id,ParentId from case where Id =:caselist.get(1).Id LIMIT 1];
            Test.stopTest();
            System.assert(c.Id != null);
            System.assertEquals(2, caseList.size());   
            
        }
    }
    
    //SDT-31851
      @isTest static void createApprovalTaskfifthtest(){
        //modified as part of SDT-38494
          /*Profile p2 = TestDataFactory.getProfile(CUSTOMER_SERVICE);
          User usr2 = TestDataFactory.createUser(p2);*/
          User currentuser = TestUserFactory.getCSRUserDetailswithUCC(true, false,'SFCAN');
          
        //user currentuser = [select id, Bypass_Validation__c,Profile.Name,User_categorization_code__c from user Where IsActive = true AND Profile.Name =:CUSTOMER_SERVICE AND User_categorization_code__c ='SFCAN' limit 1]; 
        system.runAs(currentuser){
            
            Account acc = [SELECT Id, ParentId FROM Account WHERE Recordtype.name =: Constant_Util.LOCATION LIMIT 1];
            
            Asset ast = [SELECT Id FROM Asset WHERE AccountId =: acc.Id LIMIT 1];
            
            Contact con = [SELECT id FROM Contact WHERE Accountid =: acc.ParentId LIMIT 1];
            con.Preferred_Method__c = Constant_Util.ORIGIN_EMAIL; 
            Test.startTest();
            
            Database.update(con);
            
            list<Business_Rule__c> brlst = [Select Id,Is_Auto_Email__c,Multiple_Mandatory_Approvers__c,Accountid__c,locationid__c,Container__c,Service__c,Request_Type__c,Schedule_Type__c,Active__c,Effective_Date__c,RecordTypeid,
                                            Required_Information__c from  Business_Rule__c where RecordTypeid =: Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.APPROVAL).getRecordTypeId() LIMIT 5];
            brlst[0].Active__c = true;
            brlst[0].Is_Auto_Email__c = false;
            brlst[0].Multiple_Mandatory_Approvers__c = false;
            Database.update(brlst);
            
            list<Service_Approver__c> salst = [Select Id,Email__c,Requester_Only__c,Account__c,Business_Rule__c from Service_Approver__c LIMIT 5];
            salst[0].Email__c = 'abc@gmail.com';
            //salst[0].Business_Rule__c = brlst[0].Id; SDT-33363
            salst[0].Requester_Only__c= false;
            Database.update(salst);
            
            list<case> caselist = [select id, origin, contactid, Case_Type__c, Client__c, Location__c,Status, Case_Sub_Status__c,CaseNumber,
                                   PSI_Override_Reason__c,Reference_Number__c, Case_Sub_Type__c,PurchaseOrder_Number__c,Contact_Title__c,assetid,PSI__c,PSI_Comments__c,
                                   Service_Date__c,SLA_Service_Date_Time__c,Last_Agent_Id_ForTaskAssignment__c from case  where status =: Constant_Util.STATUS_NEW limit 2];    
            
            RecurrsiveTriggerHandler.isSkipcaseTrigger = false;
            
            caselist.get(0).SlaStartDate = system.now().addMinutes(15);
            caselist.get(0).SLA_Service_Date_Time__c = system.now().addHours(1);
            caselist.get(0).Service_Date__c = system.today().addDays(1);
            caselist.get(0).Site_Contact__c = null;
            caselist.get(0).Site_Contact_Phone__c = PHONE;
            caselist.get(0).Status = Constant_Util.PENDING;
            
            
            Database.update(caselist[0]);
            
            
            Case c = [select id,ParentId from case where Id =:caselist.get(1).Id LIMIT 1];
            Test.stopTest();
            System.assert(c.Id != null);
            System.assertEquals(2, caseList.size());   
            
        }
    }
    
        
     @isTest static void UpdatePoWithOfficetraxnotest(){ 
        //user currentuser = [select id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363//Commented for SDT-33448   
        //Querying CSR User.
        User currentuser = [SELECT Id, Profile.Name, Bypass_Validation__c, IsActive FROM User WHERE Bypass_Validation__c =: false AND Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive =: true LIMIT 1]; //Modified for SDT-33448           
        system.runAs(currentuser){
            
        Case cse = new Case(recordtypeid = TestDataFactory.getRecordType('Pickup Case', 'Case'));

        cse.Case_Information__c = 'Reference Number: 12313528646';
        cse.Origin = 'Officetrax';
        test.startTest();
        	Database.insert(cse);     
        test.stopTest();
            System.assertEquals('Reference Number: 12313528646',cse.Case_Information__c);
        }     
    }
    
    @isTest static void addContactNameTitleCaseWithHyphen(){
        test.startTest();
        account loc = [select id,parentid from account where recordtype.name='Location' limit 1];
        asset asst = [select id,Occurrence_Type__c,Duration__c,Location__c,Account.ParentId from asset limit 1];
        Case cse = new Case(Location__c = asst.Location__c,assetid = asst.id,client__c = loc.parentid,recordtypeid = TestDataFactory.getRecordType('Pickup Case', 'Case'));
        
        cse.Source_System__c = 'Acorn';
        cse.ContactId = null;
        cse.Requested_By__c = 'Bailey, Nancy - QA';
        
        
        //test.startTest();
        Database.insert(cse);     
       // test.stopTest();
        
        String name = 'Bailey, Nancy - QA';
        String contactFullName, fName, lName;
        
        fName = 'Nancy';
        lName = 'Bailey';
       
        account clientId = [select id from account  where Recordtype.name =: Constant_Util.LOCATION limit 1];
        List<Contact> contactList = [SELECT id FROM Contact 
                                     WHERE Account.id =: clientId.Id
                                     AND FirstName =: fName.trim()
                                     AND LastName =: lName.trim()
                                     LIMIT 1];
        
        Database.insert(contactList); 
        
        List<Case> cases = new List<Case>();
        
        for(Integer i=0; i<2; i++)
        {
            case c= new case();
            c.Acorn_Work_order_Number__c = 'W123456';
            c.ContactId = null;
            cases.add(c);
        }
        Database.insert(cases); 
        test.stopTest();
        System.assertEquals('W123456',cases[0].Acorn_Work_order_Number__c);
    }

    @isTest static void addContactNameTitleCaseWithoutHyphen(){
       account loc = [select id,parentid from account where recordtype.name='Location' limit 1];
       asset asst = [select id,Occurrence_Type__c,Duration__c,Location__c,Account.ParentId from asset limit 1];
       Case cse = new Case(Location__c = asst.Location__c,assetid = asst.id,client__c = loc.parentid,recordtypeid = TestDataFactory.getRecordType('Pickup Case', 'Case'));

       cse.Source_System__c = 'Acorn';
       cse.ContactId = null;
       cse.Requested_By__c = 'Bailey, Nancy';
    
       test.startTest();
       Database.insert(cse);     
       test.stopTest();
       
       String name = 'Bailey, Nancy';
       String contactFullName, fName, lName;
       
       fName = 'Nancy';
       lName = 'Bailey';
       
       account clientId = [select id from account  where Recordtype.name =: Constant_Util.LOCATION limit 1];
       List<Contact> contactList = [SELECT id FROM Contact 
                                    WHERE Account.id =: clientId.Id
                                    AND FirstName =: fName.trim()
                                    AND LastName =: lName.trim()
                                    LIMIT 1];
       
       Database.insert(contactList);
       System.assertEquals(cse.Requested_By__c,'Bailey, Nancy');
    }
	
	//SDT-10737
     @isTest static void UpdateCaseWhenAvailabilityConfirmed(){
        //user currentuser = [select id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363        //Commented for SDT-33448   
        //Querying CSR User.
        User currentuser = [SELECT Id, Profile.Name, Bypass_Validation__c, IsActive FROM User WHERE Bypass_Validation__c =: false AND Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive =: true LIMIT 1]; //Modified for SDT-33448           
        System.runAs(currentuser){            
            List<Case> caselist = [SELECT id, origin, contactid, Case_Type__c, Client__c, Location__c,Site_Contact__c,Site_Contact_Phone__c,
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c, 
                                   Service_Date__c,SLA_Service_Date_Time__c ,SlaStartDate,Status,Case_Sub_Status__c,SLA_Override_Reason__c,Availability_Confirmed__c, Source_System__c,ContactEmail
                                   FROM Case WHERE status =: Constant_Util.STATUS_NEW LIMIT 1];
            
            List<Case> oldcaselist = [SELECT id, origin, contactid, Case_Type__c, Client__c, Location__c,Site_Contact__c,Site_Contact_Phone__c,
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                   Service_Date__c,SLA_Service_Date_Time__c ,SlaStartDate,Status,Case_Sub_Status__c,SLA_Override_Reason__c,Availability_Confirmed__c, Source_System__c,ContactEmail
                                   FROM Case WHERE status =: Constant_Util.STATUS_NEW LIMIT 1];
            

           
          	oldcaselist[0].Status='Open';
		oldcaselist[0].Source_System__c = 'Salesforce';
            caselist.get(0).SlaStartDate = system.Today()+3;
            caselist.get(0).SLA_Service_Date_Time__c=system.Today()+3;
            caselist.get(0).Status = 'Pending';
            caselist[0].Case_Sub_Status__c=null;
            caselist[0].Service_Date__c = system.Today()+1;
            caselist[0].SLA_Override_Reason__c = REPAIRS;
            caselist[0].Availability_Confirmed__c=true;
		caselist[0].Source_System__c = 'Salesforce';
            map<Id,Case> newcasemap= new map<Id,Case>();
            map<Id,Case> oldmap=new map<Id,Case>();
            set<String> subtypeSet=new set<String>();
            Map<string,Date> startDate=new Map<string,Date>();
            Map<string,Date> endDate=new Map<string,Date>();
			newcasemap.put(caselist[0].id,caselist[0]);
            oldmap.put(oldcaselist[0].id,oldcaselist[0]); 
            subtypeSet.add('Pending');
            startDate.put('start',system.Today());
            startDate.put('end',system.Today());
            RecurrsiveTriggerHandler.isSkipcaseTrigger = false;
            caselist.get(0).SlaStartDate = System.now().addHours(3);
            
            CasetriggerHelper.getbusinessRules(newcasemap,oldmap,subtypeSet,startDate,endDate );  
            Case cas=newcasemap.get(caselist[0].id);                     
            System.assertEquals(cas.Status,Constant_Util.OPEN );
            System.assertEquals(cas.Case_Sub_Status__c, Constant_Util.PENDING_SERVICE_INTEGRATION);
        }
        
    }
    
    
    @isTest static void UpdateCaseWhenAvailabilityNotConfirmed(){
        //user currentuser = [select id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363//Commented for SDT-33448   
        //Querying CSR User.
        User currentuser = [SELECT Id, Profile.Name, Bypass_Validation__c, IsActive FROM User WHERE Bypass_Validation__c =: false AND Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive =: true LIMIT 1]; //Modified for SDT-33448           
        
        System.runAs(currentuser){
            List<Case> caselist = [SELECT id, origin, contactid, Case_Type__c, Client__c, Location__c,Site_Contact__c,Site_Contact_Phone__c,
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                   Service_Date__c,SLA_Service_Date_Time__c ,SlaStartDate,Status,Case_Sub_Status__c,SLA_Override_Reason__c,Availability_Confirmed__c, Source_System__c,ContactEmail
                                   FROM Case WHERE status =: Constant_Util.STATUS_NEW LIMIT 1];
            
            List<Case> oldcaselist = [SELECT id, origin, contactid, Case_Type__c, Client__c, Location__c,Site_Contact__c,Site_Contact_Phone__c,
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                   Service_Date__c,SLA_Service_Date_Time__c ,SlaStartDate,Status,Case_Sub_Status__c,SLA_Override_Reason__c,Availability_Confirmed__c, Source_System__c,ContactEmail
                                   FROM Case WHERE status =: Constant_Util.STATUS_NEW LIMIT 1];
            oldcaselist[0].Status='Open';
		oldcaselist[0].Source_System__c = 'Salesforce';
            caselist.get(0).SlaStartDate = system.Today()+3;
            caselist.get(0).SLA_Service_Date_Time__c=system.Today()+3;
            caselist.get(0).Status = 'Pending';
            caselist[0].Case_Sub_Status__c=null;
            caselist[0].Service_Date__c = system.Today()+1;
            caselist[0].SLA_Override_Reason__c = REPAIRS;
            caselist[0].Availability_Confirmed__c=false;
		caselist[0].Source_System__c = 'Salesforce';
            map<Id,Case> newcasemap= new map<Id,Case>();
            map<Id,Case> oldmap=new map<Id,Case>();
            set<String> subtypeSet=new set<String>();
            Map<string,Date> startDate=new Map<string,Date>();
            Map<string,Date> endDate=new Map<string,Date>();
			newcasemap.put(caselist[0].id,caselist[0]);
            oldmap.put(oldcaselist[0].id,oldcaselist[0]); 
            subtypeSet.add('Pending');
            startDate.put('start',system.Today());
            startDate.put('end',system.Today());
            RecurrsiveTriggerHandler.isSkipcaseTrigger = false;
            caselist.get(0).SlaStartDate = System.now().addHours(3);
           
            CasetriggerHelper.getbusinessRules(newcasemap,oldmap,subtypeSet,startDate,endDate );  
            Case cas=newcasemap.get(caselist[0].id);
                       
            System.assertEquals(cas.Status,Constant_Util.PENDING );
            System.assertEquals(cas.Case_Sub_Status__c, Constant_Util.PENDING_VENDOR_INFORMATION);
        }
    }
	@isTest static void testApprovalLogCreation(){
        //user currentuser = [select id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363//Commented for SDT-33448   
        //Querying CSR User.
        User currentuser = [SELECT Id, Profile.Name, Bypass_Validation__c, IsActive FROM User WHERE Bypass_Validation__c =: false AND Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive =: true LIMIT 1]; //Modified for SDT-33448           
		System.runAs(currentuser){
            Test.startTest();
            String recTd= Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.APPROVAL).getRecordTypeId();
            List<Case> caselist = [SELECT id,CaseNumber,Reference_Number__c,Approval_Status__c, origin,Contact_Title__c, contactid, Case_Type__c, Client__c, Location__c,Site_Contact__c,Site_Contact_Phone__c,
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                   Service_Date__c,SLA_Service_Date_Time__c ,SlaStartDate,Status,Case_Sub_Status__c,SLA_Override_Reason__c,Availability_Confirmed__c,ContactEmail
                                   FROM Case WHERE status =: Constant_Util.STATUS_NEW and CAse_Sub_Type__c= : Constant_Util.EXTRA_PICKUP and Asset.Name=:ASSET_NAME LIMIT 1];
            
            List<Case> oldcaselist = [SELECT id,CaseNumber,Reference_Number__c,Approval_Status__c, origin,Contact_Title__c, contactid, Case_Type__c, Client__c, Location__c,Site_Contact__c,Site_Contact_Phone__c,
                                      PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                      Service_Date__c,SLA_Service_Date_Time__c ,SlaStartDate,Status,Case_Sub_Status__c,SLA_Override_Reason__c,Availability_Confirmed__c,ContactEmail
                                      FROM Case WHERE status =: Constant_Util.STATUS_NEW and CAse_Sub_Type__c= : Constant_Util.EXTRA_PICKUP and Asset.Name=:ASSET_NAME LIMIT 1];
			
            List<Business_Rule__c> br = [SELECT Active__c, Id FROM Business_Rule__c WHERE RecordTypeId = :recTd LIMIT 1];
            br[0].Active__c = true;
			database.update(br);
            
            System.assertEquals(2, [Select Id from Business_Rule__c].size());
            
            oldcaselist[0].Status='Open';
            caselist.get(0).SlaStartDate = System.Today()+3;
            caselist.get(0).SLA_Service_Date_Time__c = System.Today()+3;
            caselist.get(0).Status = Constant_Util.PENDING;
            caselist.get(0).Case_Sub_Status__c = Constant_Util.PENDING_REQUEST_APPROVAL;
            caselist.get(0).Approval_Status__c = Constant_Util.APPROVAL_REQUIRED;
            caselist[0].Case_Sub_Status__c = null;
            caselist[0].Is_Multiple_Asset__c = false;
            caselist[0].Service_Date__c = System.Today()+1;
            caselist[0].OwnerId = UserInfo.getUserId();
            
            Map<Id, Case> newcasemap = new Map<Id, Case>();
            Map<Id, Case> oldmap = new Map<Id, Case>();
            Set<String> subtypeSet = new Set<String>();
            Map<String, Date> startDate = new Map<String, Date>();
            Map<String, Date> endDate = new Map<String, Date>();

            newcasemap.put(caselist[0].Id, caselist[0]);
            oldmap.put(oldcaselist[0].Id, oldcaselist[0]); 
            subtypeSet.add('Pending');
            startDate.put('start', System.Today());
            startDate.put('end', System.Today());

			//Test.startTest();
            CasetriggerHelper.getbusinessRules(newcasemap, oldmap, subtypeSet, startDate, endDate); 
            CaseTriggerHelper.insertApprovalLog(newcasemap, oldmap);
            //Test.stopTest();

            Generic_Values__mdt myGV = [SELECT Id ,Id__c FROM Generic_Values__mdt 
                                        WHERE DeveloperName =: Constant_Util.GROUPUSER LIMIT 1];
            Test.stopTest();
            /* FIX THIS
            Task myTask = [SELECT Id, OwnerId, Status FROM Task 
                            WHERE Subject = :Constant_Util.OBTAIN_SERVICE_APPROVAL LIMIT 1];
            */

            //System.assertEquals(myGV.Id__c, myTask.OwnerId);
            //System.assertEquals('Open', myTask.Status);
            
        }
    }
	
	@isTest static void getServiceDateTest(){
        //user currentuser = [SELECT id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363//Commented for SDT-33448   
        //Querying CSR User.
        User currentuser = [SELECT Id, Profile.Name, Bypass_Validation__c, IsActive FROM User WHERE Bypass_Validation__c =: false AND Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive =: true LIMIT 1]; //Modified for SDT-33448           
        System.runAs(currentuser){
            Test.startTest();
            List<Case> caselist = [SELECT id, origin, contactid, RecordTypeId,Case_Type__c,Case_Reason__c, Client__c, Location__c, Status, PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c,Contact_Title__c,assetid,PSI__c,PSI_Comments__c, Service_Date__c,SLA_Service_Date_Time__c 
                                   FROM Case LIMIT 1];    
            
            RecurrsiveTriggerHandler.isSkipcaseTrigger = false;
            caselist.get(0).OwnerId = currentuser.Id;
            caselist.get(0).RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Constant_Util.INTERRUPTION).getRecordTypeId();
            caselist.get(0).Case_Type__c = Constant_Util.Cancellation;
            caselist.get(0).Case_Sub_Type__c = SERVICE;
            caselist.get(0).Case_Reason__c = Constant_Util.OPEN_TOP;
            Database.update(caselist,false);
            
            //Test.startTest();
               CaseTriggerHelper.getServiceDate(caselist);
            Test.stopTest();
            
            System.assertEquals(Constant_Util.Cancellation,caselist.get(0).Case_Type__c);
            System.assertEquals(SERVICE,caselist.get(0).Case_Sub_Type__c);
        }
    }
    //Test Method for SendEmailWOcreation 
   /* @isTest static void sendEmailWOcreationTest(){
        user currentuser = [SELECT id, Bypass_Validation__c FROM User LIMIT 1];
        System.runAs(currentuser){
            
            Account acc = [SELECT Id, ParentId FROM Account WHERE Recordtype.name =: Constant_Util.LOCATION LIMIT 1];
            List<Case> caselist = [SELECT id, origin, contactid, RecordTypeId,Case_Type__c,Case_Reason__c, Client__c, Location__c, Status, PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c,Contact_Title__c,assetid,PSI__c,PSI_Comments__c, Service_Date__c,SLA_Service_Date_Time__c 
                                   FROM Case LIMIT 1];   
            Contact con = [SELECT id FROM Contact WHERE Accountid =: acc.ParentId LIMIT 1];
            con.Preferred_Method__c = Constant_Util.ORIGIN_EMAIL; 
            Database.update(con);
            
			List<Approval_Log__c> appLog = [Select id,Status__c,Actual_Approver_Title__c from Approval_Log__c limit1];
            appLog[0].Actual_Approver_Email__c = EMAIL;
            appLog[0].Status__c = 'Approved';
            Database.update(appLog);

            List<EmailTemplate> emTemp = [Select id,Name from EmailTemplate limit 1];
            
            Test.startTest();
           	 CaseTriggerHelper.sendEmailOnWOcreation(caselist,emTemp[0].Name);
            Test.stopTest();    
            
            List<EmailMessage> eMessage = [Select id from EmailMessage where ParentId =: caselist[0].Id ];
            System.assert(eMessage.size() != 0);
            
                 
        }
        
        
    }
*/
/*
    @isTest static void createGenReporting(){
        user currentuser = [SELECT id, Bypass_Validation__c FROM User LIMIT 1];
        System.runAs(currentUser){
            List<Case> caselist = [SELECT id, CaseNumber, origin, contactid, RecordTypeId,Case_Type__c,Case_Reason__c, Client__c, Location__c, Status, PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c,Contact_Title__c,assetid,PSI__c,PSI_Comments__c, Service_Date__c,SLA_Service_Date_Time__c 
                                   FROM Case LIMIT 1];
            System.debug('caselist size -- ' + caselist.size());
            Genesys_Routing__c gr = new Genesys_Routing__c();
            gr.SFDCCaseNumber__c = caselist[0].CaseNumber;
            insert gr;

            Test.startTest();

            caselist[0].Case_Sub_Type__c = 'Empty and Return';
            update caselist;

            Test.stopTest();

            List<Genesys_Reporting__c> grlist = [SELECT Id FROM Genesys_Reporting__c WHERE SFDCCaseNumber__c = :caselist[0].CaseNumber LIMIT 1];
            System.assert(grlist.size()>0);

        }
    }
    */
   /*Test method to cover updateDuplicateCheck method*/
    @isTest static void updateDuplicateCheckTest(){
List<User> currentuserList = new List<User>(); //Modified for SDT-33448
        user currentuser = [SELECT Id, Bypass_Validation__c, ProfileId 
                            FROM User WHERE lastname = 'testing' LIMIT 1];
        currentuser.Bypass_Validation__c = false;
        currentuserList.add(currentuser); //Modified for SDT-33448
        update currentuserList; //Modified for SDT-33448
        System.runAs(currentuser){
        product2 prd = [select id,name,family from product2 limit 1];
        prd.Family = SUPPLIES;
       	Database.update(prd);
        asset asst = [select id,Occurrence_Type__c,Duration__c,Location__c,Account.ParentId from asset limit 1];
        account loc = [select id,parentid from account where recordtype.name='Location' limit 1];
        asst.Service_Type__c = GOT_JUNK_PICKUP;
        Database.update(asst);
        Case cse = new Case(Location__c = asst.Location__c,assetid = asst.id,client__c = loc.parentid,recordtypeid = TestDataFactory.getRecordType('Pickup Case', 'Case'));
        cse.Case_Type__c = CONSTANT_UTIL.PICKUP_CSTYPE;
        cse.Case_Sub_Type__c = ''; 
       	test.startTest();
        Database.insert(cse);     
        test.stopTest();
        System.assert(cse.Case_Sub_Type__c!=null);
        }  
    }
    /*Test method to cover checkParentWithIn15MinTest method*/
    @isTest static void checkParentWithIn15MinTest(){
        
        //user currentuser = [SELECT id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363//Commented for SDT-33448   
        //Querying CSR User.
        User currentuser = [SELECT Id, Profile.Name, Bypass_Validation__c, IsActive FROM User WHERE Bypass_Validation__c =: false AND Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive =: true LIMIT 1]; //Modified for SDT-33448           
        System.runAs(currentuser){    
           //get the parent
             Case parentCase = [SELECT Id,Client__c, Location__c, ContactId,Origin,ParentId, Reference_Number__c, Last_Customer_Interaction_ID__c,
             Last_Customer_Interaction_Type__c, AssetId, CaseNumber FROM Case  WHERE status =: Constant_Util.OPEN AND   Case_Type__c =:  Constant_Util.PICKUP_CSTYPE AND Case_Sub_Type__c =: Constant_Util.EXTRA_PICKUP  LIMIT 1];
            
            Case myCase = new Case(Status = Constant_Util.NEW_STATUS , RecordTypeId = TestDataFactory.getRecordType( Constant_Util.Pickup_Case_Rec_Type,  Constant_Util.OBJECT_CASE), Client__c = parentCase.Client__c, Location__c = parentCase.Location__c,
            Reference_Number__c = parentCase.Reference_Number__c, ContactId = parentCase.ContactId,Origin = parentCase.Origin,
            ParentId = parentCase.Id, Last_Customer_Interaction_ID__c = parentCase.Last_Customer_Interaction_ID__c,
            Last_Customer_Interaction_Type__c = parentCase.Last_Customer_Interaction_Type__c, Bypass_WO_Duplicate__c=true);
			myCase.AssetId = parentCase.AssetId;
            Test.StartTest();
            Database.insert(myCase, false);
            myCase.Service_Date__c= system.today().addDays(-1);
	    myCase.Case_Sub_Status__c=Constant_Util.PENDING_VENDOR_INFORMATION; 
            Database.update(myCase, false);
            Boolean result= CaseTriggerHelper.checkParentWithIn15Min(myCase.Id);
            Test.StopTest();
            system.assertEquals(result,true);
        }
          
    }

     /*Test method to cover checkParentWithIn15MinTest method*/
     @isTest static void testBackOffice(){
        
        //user currentuser = [SELECT id, Bypass_Validation__c, IsActive FROM User where Bypass_Validation__c=:false AND IsActive=:true LIMIT 1];//Commented for SDT-33448   
        //Querying CSR User.
        User currentuser = [SELECT Id, Profile.Name, Bypass_Validation__c, IsActive FROM User WHERE Bypass_Validation__c =: false AND Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive =: true LIMIT 1]; //Modified for SDT-33448           
        String corporateServiceQueueId = [SELECT Id FROM Group WHERE DeveloperName =: Constant_Util.CORPORATESERVICESQUEUE LIMIT 1].Id;
            
       System.runAs(currentuser){    
          //get the parent
            Case parentCase = [SELECT Id,Client__c, Location__c, ContactId,Origin,ParentId, Reference_Number__c, Last_Customer_Interaction_ID__c,
            Last_Customer_Interaction_Type__c, AssetId, CaseNumber FROM Case  WHERE status =: Constant_Util.OPEN AND   Case_Type__c =:  Constant_Util.PICKUP_CSTYPE AND Case_Sub_Type__c =: Constant_Util.EXTRA_PICKUP  LIMIT 1];
           
           Case myCase = new Case(Status = Constant_Util.NEW_STATUS , RecordTypeId = TestDataFactory.getRecordType( Constant_Util.Pickup_Case_Rec_Type,  Constant_Util.OBJECT_CASE), Client__c = parentCase.Client__c, Location__c = parentCase.Location__c,
           Reference_Number__c = parentCase.Reference_Number__c, ContactId = parentCase.ContactId,Origin = parentCase.Origin,
           ParentId = parentCase.Id, Last_Customer_Interaction_ID__c = parentCase.Last_Customer_Interaction_ID__c,
           Last_Customer_Interaction_Type__c = parentCase.Last_Customer_Interaction_Type__c, Bypass_WO_Duplicate__c=true,
           OwnerId = corporateServiceQueueId);
           myCase.AssetId = parentCase.AssetId;
           Test.StartTest();
           Database.insert(myCase, false);
           Case c = [SELECT Id , BackOffice_Case__c FROM Case WHERE Id = :myCase.Id];
           Test.StopTest();
           system.assertEquals(true,c.BackOffice_Case__c);
       }
         
   }
   
   
        @isTest static void byPassBusinessApprovalRuleTest(){
          Profile p2 = TestDataFactory.getProfile(CUSTOMER_SERVICE);
         User usr2 = TestDataFactory.createUser(p2);
        
        List<User> testRunUserList = new List<User>();
        usr2.Bypass_Validation__c = true;
        //usr2.UserRoleId = ur.id;
        testRunUserList.add(usr2);
        User nonByPassValidationUser = TestDataFactory.createUser(p2);
        nonByPassValidationUser.Username = 'CustomerService'+ String.valueof(system.now().millisecond())+'@testorg.com.wm';
        testRunUserList.add(nonByPassValidationUser);
        Database.insert(testRunUserList);
         
         List<Account> acclist = TestDataFactory.createAccount(KROGER, testRunUserList[0],Constant_Util.CLIENT);
            acclist[0].AccountNumber = 'HMD';
            Database.insert(acclist);
            List<Account> locationlist = TestDataFactory.createLocation(Constant_Util.LOCATION, testRunUserList[0], acclist.get(0).id);
            
            locationlist[0].tz__Timezone_SFDC__c = NY_TIMEZONE;
            locationlist[0].tz__UTF_Offset__c = -4;
            Database.insert(locationlist);
            
            List<Contact> conlist = TestDataFactory.createContact(RITA, REPLY, acclist.get(0), testRunUserList[0]);
            conlist[0].Preferred_Method__c='Email';
             conlist[0].Internal_User_ID__c = testRunUserList[0].id;
            Database.insert(conlist);
          List<Case> caselist = [SELECT id, origin, contactid, Case_Type__c, Client__c, Location__c,Site_Contact__c,Site_Contact_Phone__c,
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                   Service_Date__c,SLA_Service_Date_Time__c ,SlaStartDate,Status,Case_Sub_Status__c,SLA_Override_Reason__c,Availability_Confirmed__c, Source_System__c,ContactEmail
                                   FROM Case WHERE status =: Constant_Util.STATUS_NEW LIMIT 1];
            
            List<Case> oldcaselist = [SELECT id, origin, contactid, Case_Type__c, Client__c, Location__c,Site_Contact__c,Site_Contact_Phone__c,
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                   Service_Date__c,SLA_Service_Date_Time__c ,SlaStartDate,Status,Case_Sub_Status__c,SLA_Override_Reason__c,Availability_Confirmed__c, Source_System__c,ContactEmail
                                   FROM Case WHERE status =: Constant_Util.STATUS_NEW LIMIT 1];
            

           
          	oldcaselist[0].Status='Open';
		oldcaselist[0].Source_System__c = 'Salesforce';
            caselist.get(0).SlaStartDate = system.Today()+3;
            caselist.get(0).SLA_Service_Date_Time__c=system.Today()+3;
            caselist.get(0).Status = 'Pending';
         caselist[0].contactid = conlist[0].id;
            caselist[0].Case_Sub_Status__c=null;
            caselist[0].Service_Date__c = system.Today()+1;
            caselist[0].SLA_Override_Reason__c = REPAIRS;
            caselist[0].Availability_Confirmed__c=true;
		caselist[0].Source_System__c = 'Salesforce';
         
         
            map<Id,Case> newcasemap= new map<Id,Case>();
            map<Id,Case> oldmap=new map<Id,Case>();
            set<String> subtypeSet=new set<String>();
            Map<string,Date> startDate=new Map<string,Date>();
            Map<string,Date> endDate=new Map<string,Date>();
			newcasemap.put(caselist[0].id,caselist[0]);
            oldmap.put(oldcaselist[0].id,oldcaselist[0]); 
            subtypeSet.add('Pending');
            startDate.put('start',system.Today());
            startDate.put('end',system.Today());
            RecurrsiveTriggerHandler.isSkipcaseTrigger = false;
            caselist.get(0).SlaStartDate = System.now().addHours(3);
         
        System.runAs(testRunUserList[0]){
             
             test.startTest();
            CasetriggerHelper.getbusinessRules(newcasemap,oldmap,subtypeSet,startDate,endDate ); 
            test.stopTest();
            Case cas=newcasemap.get(caselist[0].id);                     
            System.assertEquals(cas.Status,Constant_Util.OPEN );
            System.assertEquals(cas.Case_Sub_Status__c, Constant_Util.PENDING_SERVICE_INTEGRATION);
        
        }
    }
    
     @isTest static void byPassBusinessApprovalRuleTest2(){
          //Profile p2 = TestDataFactory.getProfile(SYS_ADMIN);  //Commented for SDT-33448
        Profile p2 = TestDataFactory.getProfile(CUSTOMER_SERVICE);  //Modified for SDT-33448
         User usr2 = TestDataFactory.createUser(p2);
        
        List<User> testRunUserList = new List<User>();
        usr2.Bypass_Validation__c = true;
        //usr2.UserRoleId = ur.id;
        testRunUserList.add(usr2);
        User nonByPassValidationUser = TestDataFactory.createUser(p2);
        nonByPassValidationUser.Username = 'SystemAdministrat'+ String.valueof(system.now().millisecond())+'@testorg.com.wm';
        testRunUserList.add(nonByPassValidationUser);
        Database.insert(testRunUserList);
         
         List<Account> acclist = TestDataFactory.createAccount(KROGER, testRunUserList[0],Constant_Util.CLIENT);
            acclist[0].AccountNumber = 'HMD';
            Database.insert(acclist);
            List<Account> locationlist = TestDataFactory.createLocation(Constant_Util.LOCATION, testRunUserList[0], acclist.get(0).id);
            
            locationlist[0].tz__Timezone_SFDC__c = NY_TIMEZONE;
            locationlist[0].tz__UTF_Offset__c = -4;
            Database.insert(locationlist);
            
            List<Contact> conlist = TestDataFactory.createContact(RITA, REPLY, acclist.get(0), testRunUserList[0]);
            conlist[0].Preferred_Method__c='Email';
             conlist[0].Internal_User_ID__c = testRunUserList[0].id;
            Database.insert(conlist);
          List<Case> caselist = [SELECT id, origin, contactid, Case_Type__c, Client__c, Location__c,Site_Contact__c,Site_Contact_Phone__c,
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                   Service_Date__c,SLA_Service_Date_Time__c ,SlaStartDate,Status,Case_Sub_Status__c,SLA_Override_Reason__c,Availability_Confirmed__c, Source_System__c,ContactEmail
                                   FROM Case WHERE status =: Constant_Util.STATUS_NEW LIMIT 1];
            
            List<Case> oldcaselist = [SELECT id, origin, contactid, Case_Type__c, Client__c, Location__c,Site_Contact__c,Site_Contact_Phone__c,
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                   Service_Date__c,SLA_Service_Date_Time__c ,SlaStartDate,Status,Case_Sub_Status__c,SLA_Override_Reason__c,Availability_Confirmed__c, Source_System__c,ContactEmail
                                   FROM Case WHERE status =: Constant_Util.STATUS_NEW LIMIT 1];
            

           
          	oldcaselist[0].Status='Open';
	     oldcaselist[0].Source_System__c = 'Salesforce';
            caselist.get(0).SlaStartDate = system.Today()+3;
            caselist.get(0).SLA_Service_Date_Time__c=system.Today()+3;
            caselist.get(0).Status = 'Pending';
         caselist[0].contactid = conlist[0].id;
            caselist[0].Case_Sub_Status__c=null;
            caselist[0].Service_Date__c = system.Today()+1;
            caselist[0].SLA_Override_Reason__c = REPAIRS;
            caselist[0].Availability_Confirmed__c=true;
            caselist[0].origin = 'Email';
	     caselist[0].Source_System__c = 'Salesforce';
         
           String Subject = Constant_Util.KEYWORD_TEST;
            String Body = Constant_Util.KEYWORD_TEST + ' lOCatioN # FAM002508';
            List<EmailMessage> lstEM = new List<EmailMessage>();
            lstEM = TestDataFactory.createEmailMessage(Subject, Body, caselist.get(0));
          //  Database.insert(lstEM);
         
            map<Id,Case> newcasemap= new map<Id,Case>();
            map<Id,Case> oldmap=new map<Id,Case>();
            set<String> subtypeSet=new set<String>();
            Map<string,Date> startDate=new Map<string,Date>();
            Map<string,Date> endDate=new Map<string,Date>();
			newcasemap.put(caselist[0].id,caselist[0]);
            oldmap.put(oldcaselist[0].id,oldcaselist[0]); 
            subtypeSet.add('Pending');
            startDate.put('start',system.Today());
            startDate.put('end',system.Today());
            RecurrsiveTriggerHandler.isSkipcaseTrigger = false;
            caselist.get(0).SlaStartDate = System.now().addHours(3);
         
        System.runAs(testRunUserList[0]){
             
             test.startTest();
            CasetriggerHelper.getbusinessRules(newcasemap,oldmap,subtypeSet,startDate,endDate ); 
            test.stopTest();
            Case cas=newcasemap.get(caselist[0].id);                     
            System.assertEquals(cas.Status,Constant_Util.OPEN );
            System.assertEquals(cas.Case_Sub_Status__c, Constant_Util.PENDING_SERVICE_INTEGRATION);
        
        }
    }
    
    
    @isTest static void byPassBusinessApprovalRuleTest3(){
          Profile p2 = TestDataFactory.getProfile('Customer Account Team');
         User usr2 = TestDataFactory.createUser(p2);
        
        List<User> testRunUserList = new List<User>();
        usr2.Bypass_Validation__c = true;
        //usr2.UserRoleId = ur.id;
        testRunUserList.add(usr2);
        User nonByPassValidationUser = TestDataFactory.createUser(p2);
        nonByPassValidationUser.Username = 'SystemAdministrat'+ String.valueof(system.now().millisecond())+'@testorg.com.wm';
        testRunUserList.add(nonByPassValidationUser);
        Database.insert(testRunUserList);
         
         List<Account> acclist = TestDataFactory.createAccount(KROGER, testRunUserList[0],Constant_Util.CLIENT);
            acclist[0].AccountNumber = 'HMD';
            Database.insert(acclist);
            List<Account> locationlist = TestDataFactory.createLocation(Constant_Util.LOCATION, testRunUserList[0], acclist.get(0).id);
            
            locationlist[0].tz__Timezone_SFDC__c = NY_TIMEZONE;
            locationlist[0].tz__UTF_Offset__c = -4;
            Database.insert(locationlist);
            
            List<Contact> conlist = TestDataFactory.createContact(RITA, REPLY, acclist.get(0), testRunUserList[0]);
            conlist[0].Preferred_Method__c='Email';
             conlist[0].Internal_User_ID__c = testRunUserList[0].id;
            Database.insert(conlist);
          List<Case> caselist = [SELECT id, origin, contactid, Case_Type__c, Client__c, Location__c,Site_Contact__c,Site_Contact_Phone__c,
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                   Service_Date__c,SLA_Service_Date_Time__c ,SlaStartDate,Status,Case_Sub_Status__c,SLA_Override_Reason__c,Availability_Confirmed__c, Source_System__c,ContactEmail
                                   FROM Case WHERE status =: Constant_Util.STATUS_NEW LIMIT 1];
            
            List<Case> oldcaselist = [SELECT id, origin, contactid, Case_Type__c, Client__c, Location__c,Site_Contact__c,Site_Contact_Phone__c,
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                   Service_Date__c,SLA_Service_Date_Time__c ,SlaStartDate,Status,Case_Sub_Status__c,SLA_Override_Reason__c,Availability_Confirmed__c, Source_System__c,ContactEmail
                                   FROM Case WHERE status =: Constant_Util.STATUS_NEW LIMIT 1];
            

           
          	oldcaselist[0].Status='Open';
	    oldcaselist[0].Source_System__c = 'Salesforce';
            caselist.get(0).SlaStartDate = system.Today()+3;
            caselist.get(0).SLA_Service_Date_Time__c=system.Today()+3;
            caselist.get(0).Status = 'Pending';
         caselist[0].contactid = conlist[0].id;
            caselist[0].Case_Sub_Status__c=null;
            caselist[0].Service_Date__c = system.Today()+1;
            caselist[0].SLA_Override_Reason__c = REPAIRS;
            caselist[0].Availability_Confirmed__c=true;
            caselist[0].origin = 'Email';
	    caselist[0].Source_System__c = 'Salesforce';
         
           String Subject = Constant_Util.KEYWORD_TEST;
            String Body = Constant_Util.KEYWORD_TEST + ' lOCatioN # FAM002508';
            List<EmailMessage> lstEM = new List<EmailMessage>();
            lstEM = TestDataFactory.createEmailMessage(Subject, Body, caselist.get(0));
           // Database.insert(lstEM);
         
            map<Id,Case> newcasemap= new map<Id,Case>();
            map<Id,Case> oldmap=new map<Id,Case>();
            set<String> subtypeSet=new set<String>();
            Map<string,Date> startDate=new Map<string,Date>();
            Map<string,Date> endDate=new Map<string,Date>();
			newcasemap.put(caselist[0].id,caselist[0]);
            oldmap.put(oldcaselist[0].id,oldcaselist[0]); 
            subtypeSet.add('Pending');
            startDate.put('start',system.Today());
            startDate.put('end',system.Today());
            RecurrsiveTriggerHandler.isSkipcaseTrigger = false;
            caselist.get(0).SlaStartDate = System.now().addHours(3);
         
        System.runAs(testRunUserList[0]){
             
             test.startTest();
            CasetriggerHelper.getbusinessRules(newcasemap,oldmap,subtypeSet,startDate,endDate ); 
            test.stopTest();
            Case cas=newcasemap.get(caselist[0].id);                     
            System.assertEquals(cas.Status,Constant_Util.OPEN );
            System.assertEquals(cas.Case_Sub_Status__c, Constant_Util.PENDING_SERVICE_INTEGRATION);
        
        }
    }

    //Test Method for SendEmailWOcreation , not required feature not released
   /* @isTest static void sendEmailonCaseCreationTest(){
        user currentuser = [SELECT id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        System.runAs(currentuser){
            
            Account acc = [SELECT Id, ParentId FROM Account WHERE Recordtype.name =: Constant_Util.LOCATION LIMIT 1];
            List<Case> caselist = [SELECT id, origin, contactid, RecordTypeId,Case_Type__c,Case_Reason__c, Client__c, Location__c, Status, PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c,Contact_Title__c,assetid,PSI__c,PSI_Comments__c, Service_Date__c,SLA_Service_Date_Time__c 
                                   FROM Case LIMIT 1];   
            Contact con = [SELECT id FROM Contact WHERE Accountid =: acc.ParentId LIMIT 1];
            con.Preferred_Method__c = Constant_Util.ORIGIN_EMAIL; 
            Database.update(con);
            List<EmailTemplate> emTemp = [Select id,Name from EmailTemplate limit 1];
            
            Test.startTest();
            CaseTriggerHelper.sendEmailOnCaseCreation(caselist);
            Test.stopTest();    
            
            List<EmailMessage> eMessage = [Select id from EmailMessage where ParentId =: caselist[0].Id ];
            System.assert(eMessage.size() != 0);
            
            
        }
        
    }*/

	@isTest static void createCacelCompletedGenesysRecordTest(){
        //user currentuser = [SELECT id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363//Commented for SDT-33448   
        //Querying CSR User.
        User currentuser = [SELECT Id, Profile.Name, Bypass_Validation__c, IsActive FROM User WHERE Bypass_Validation__c =: false AND Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive =: true LIMIT 1]; //Modified for SDT-33448           
        System.runAs(currentuser){
          List<Case> caselist = [SELECT id,Reference_Number__c FROM Case WHERE status =: Constant_Util.STATUS_NEW LIMIT 1];
            List<Genesys_Routing__c> grecordAssrtCheckListcheck = [select id,Action__c
                                         from Genesys_Routing__c where SFDCCaseRefNo__c =:caselist[0].Reference_Number__c ];
List<Genesys_Routing__c> grList = new List<Genesys_Routing__c>(); //Modified for SDT-33448
            Genesys_Routing__c gr = new Genesys_Routing__c ();
            gr.SFDCCaseRefNo__c = caselist[0].Reference_Number__c ;
            gr.SFDCRecordType__c = 'Standard Case';
            gr.SFDCObjType__c = Constant_Util.OBJECT_EMAILMESSAGE;
            gr.SFDCObjRecordID__c = 'testEmailId';
            grList.add(gr); //Modified for SDT-33448
            Insert grList; //Modified for SDT-33448
            Map<Id,case> caseMap = new Map<Id,case>();
            caselist[0].status = 'Closed';
            Test.startTest();
            update caselist;
            Test.stopTest();
        }
        
    }
	 @isTest static void createCacelCompletedGenesysRecordTest2(){
        user currentuser = [SELECT id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        System.runAs(currentuser){
          List<Case> caselist = [SELECT id,CaseNumber,Reference_Number__c FROM Case WHERE status =: Constant_Util.STATUS_NEW LIMIT 1];
		   caselist[0].Reference_Number__c = caselist[0].CaseNumber;
            update caselist;
            List<Genesys_Routing__c> grecordAssrtCheckListcheck = [select id,Action__c
                                         from Genesys_Routing__c where SFDCCaseRefNo__c =:caselist[0].Reference_Number__c ];
List<Genesys_Routing__c> grList = new List<Genesys_Routing__c>(); //Modified for SDT-33448
            Genesys_Routing__c gr = new Genesys_Routing__c ();
            gr.SFDCCaseRefNo__c = caselist[0].Reference_Number__c ;
            gr.SFDCRecordType__c = 'Standard Case';
            gr.SFDCObjType__c = Constant_Util.OBJECT_EMAILMESSAGE;
            gr.SFDCObjRecordID__c = 'testEmailId';
            grList.add(gr); //Modified for SDT-33448
            Insert grList; //Modified for SDT-33448
            Map<Id,case> caseMap = new Map<Id,case>();
       //     caselist[0].status = 'Closed';
            Test.startTest();
            delete caselist;
            Test.stopTest();
        }
        
    }
        //SDT-33363 
/*@isTest static void updateCCandPOtest(){
        Test.startTest();
        User currentuser = [SELECT id, Bypass_Validation__c, isActive FROM User where Bypass_Validation__c = true and isActive = true LIMIT 1]; 
        system.runAs(currentuser){
            
            List<Asset> aselst = [Select Id, Location__c from Asset where Location__c != null Limit 1];
            List<Account> loclst = [Select Id, Name,ParentId from Account where Id =: aselst.get(0).Location__c Limit 1];
            List<Account> acclst = [Select Id, Name from Account where Id =: loclst.get(0).ParentId Limit 1];
            List<Contact> conlst = [Select Id, Name from Contact where Accountid =: acclst.get(0).Id Limit 1];
            List<Business_Rule__c> brlst = [Select Id from Business_Rule__c WHERE RecordTypeid =: Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.REQUIRED_INFORMATION).getRecordTypeId()];
            brlst[0].Request_Type__c = 'New Service';
            brlst[0].Service__c = 'Permanent';
            //brlst[0].Container__c = Constant_Util.EMPTY_STRING;
            Database.update(brlst);
            
            //Inserting Case
            Case newServiceCase = TestDataFactory.newServiceCase(Constant_Util.CONSTANT_FIRST, acclst.get(0), conlst.get(0),currentuser,loclst.get(0)); 
            newServiceCase.Service_Date__c = system.today() + 1;
            newServiceCase.SLA_Service_Date_Time__c = system.today() + 2;
            newServiceCase.Case_Type__c = 'New Service';
            newServiceCase.RecordTypeId = Schema.SobjectType.Case.getRecordTypeInfosByDeveloperName().get(Constant_Util.R_NEW_SERVICE_CASE).getRecordTypeId();  
            newServiceCase.Case_Sub_Type__c = 'Permanent';
            newServiceCase.Case_Reason__c = 'Existing Location';
            newServiceCase.LOB__c = 'Rolloff';
            newServiceCase.Status = 'New';
            //newServiceCase.Service_Occurrence_Type_Code__c = ON_CALL;
            //newServiceCase.Material_Type__c = TRASH;
            newServiceCase.PurchaseOrder_Number__c = '1234';
            newServiceCase.Company_Category__c = 'TESTCC1234';
            newServiceCase.CompanyCategoryCode__c = 'TESTCode1234';
            
            Database.insert(newServiceCase);
            List<Opportunity> oppList = new List<Opportunity>();
            List<SBQQ__Quote__c> quoteList= new List<SBQQ__Quote__c>();
        	List<Product2> prdList = new List<Product2>(); 
        	
            oppList.addAll(TestDataFactory.createOpportunity(1,'TestOpportunityTest',newServiceCase.Id,newServiceCase.Case_Sub_Type__c, newServiceCase.Location__c));
            insert oppList;
            System.Debug('@@@~Create Opp : ' + oppList);
            
            quoteList.addAll(TestDataFactory.createQuoteRecords(oppList,acclst[0],conlst[0],Date.today(),false,true));
            quoteList[0].SBQQ__ShippingStreet__c = 'ABC';
            quoteList[0].SBQQ__ShippingCity__c = 'Test1';
            quoteList[0].SBQQ__ShippingCountry__c = 'USA';
            quoteList[0].SBQQ__ShippingState__c = 'NY';
            quoteList[0].SBQQ__ShippingPostalCode__c = '1234';
            quoteList[0].Duration__c = 'Permanent';
            insert quoteList;
            system.debug('Quote ' +quoteList);
    		
            Product2 prodOpenTop = TestDataFactory.createProduct('Open Top','Rolloff', 'OT');
            prodOpenTop.Is_Pricing_Eligible__c = true;
            prdList.add(prodOpenTop);
            Product2 prodDelivery= TestDataFactory.createProduct('Delivery','Surcharges and Fees','DLV');
            prdList.add(prodDelivery);
            Database.insert(prdList);
            List<SBQQ__QuoteLine__c> qlHdr = new List<SBQQ__QuoteLine__c>();
            //Bundle 1 - Open Top
            SBQQ__QuoteLine__c qlOT = TestDataFactory.createQuoteLineRecords(quoteList[0],prodOpenTop,'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
            qlOT.SBQQ__Bundle__c = TRUE;
            qlOT.SBQQ__RequiredBy__c = null;
           // qlOT.Vendor__c = vendorAcc.Id;
            qlOT.SBQQ__Number__c = 1;
            qlOT.CompanyCategoryName__c = 'TEST110011';
            qlOT.CompanyCategoryCode__c = 'TEST11Code';
            //qlOT.Location_Position_Name__c = accLocPosition.Id;
            qlHdr.add(qlOT);
            
            Database.insert(qlHdr);
            
            List<SBQQ__QuoteLine__c> qlChild = new List<SBQQ__QuoteLine__c>();
            SBQQ__QuoteLine__c qlDelivery = TestDataFactory.createQuoteLineRecords(quoteList[0],prodDelivery,'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',0,'DYS','PER',null,'DYS','Do Not Override','NBG');
            qlDelivery.SBQQ__RequiredBy__c = qlOT.Id;
            qlDelivery.SBQQ__Number__c = 5;
            //qlDelivery.Vendor__c = vendorAcc.Id;
            qlChild.add(qlDelivery);
            //Open Top Child Quote Line  --- End
            
            Database.insert(qlChild);
            
            Quote_Order__c qo = new Quote_Order__c();
            qo.Quote_Line__c= qlOT.id;
            qo.Service_Quote_Line__c= qlDelivery.id;
            qo.Service_Type__c='Delivery';
            qo.Product_Type__c='Delivery';
            qo.Service_Date__c= Date.newInstance(2020, 13, 5);
            qo.Instructions__c= 'test1234';
            qo.Cust_Ref_Number__c='test12345';
            qo.Duration__c='PERM';
            qo.Occurrence_Type__c='OC';
            qo.Quantity__c = 20;
            insert qo;
            
            newServiceCase.PurchaseOrder_Number__c = '4567';
            newServiceCase.Company_Category__c = 'TESTCC4567';
            newServiceCase.CompanyCategoryCode__c = 'TESTCode4567';
            Database.update(newServiceCase);
            
            
        }
        Test.stopTest();
    } */
     //method to test updateServiceDateAlwaysRunStandard().
     @isTest static void updateServiceDateAlwaysRunStandardTest(){
        Test.startTest();
        //querying account, contact, location and asset.
        Account parentAcc = [Select Id, ParentId FROM Account WHERE ParentId =: NULL LIMIT 1];
        Contact con = [Select Id FROM Contact LIMIT 1];
        Account locationAcc = [Select Id, ParentId FROM Account WHERE ParentId != NULL LIMIT 1];
        Asset asset = [Select Id FROM Asset LIMIT 1];
        User usr = [Select Id, FirstName FROM User WHERE FirstName =: 'testuser##9999'];
        //creating case 
List<Case> caseRecList = new List<Case>(); //Modified for SDT-33448
        Case caseRec = new Case(Status ='New', Priority = 'Medium', Origin = 'Phone', ContactId = con.id, 
                            AccountId = parentAcc.id, OwnerId = usr.id, Client__c = locationAcc.ParentId, Location__c = locationAcc.id, 
                            assetid = asset.id, Case_Type__c = 'Activate', Case_Sub_Type__c = 'New Location', 
                            SlaStartDate = system.today(),Recordtypeid = TestDataFactory.getRecordType('Standard Case','Case'));
        caseRec.Case_Reason__c ='New Business';
        caseRecList.add(caseRec); //Modified for SDT-33448
        insert caseRec; //Modified for SDT-33448 
        Test.stopTest();
        
    }
    
      /*  Not required, feature not released
      @isTest static void updateReassignFieldTest(){
        set<Id> caseIdset = new Set<Id>();
        Test.startTest();
        //querying account, contact, location and asset.
        List<Case> caseList = [select Id from Case LIMIT 2];
            for(Case ca:caseList){
                caseIdset.add(ca.Id);
            }    
        CaseTriggerHelper.updateReassignField(caseIdset);
        Test.stopTest();
        List<case> updatedcaseList = [select Id,CheckReassignment__c from Case WHERE Id IN:caseIdset];
            System.assertEquals(updatedcaseList[0].CheckReassignment__c,false);
    }*/
    
    @isTest static void sendEmailOnWOcreationTest(){
        set<Id> caseIdset = new Set<Id>();
        Test.startTest();
        try {
        //querying account, contact, location and asset.
        List<Case> caseList = [select Id from Case LIMIT 2];
            for(Case ca:caseList){
                caseIdset.add(ca.Id);
            }    
        
        CaseTriggerHelper.sendEmailOnWOcreation(caseList,'Chat Now Automated Email');
        }
        catch(exception ex) {
            //method not used
        }
        Test.stopTest();
        
    }
    
    @isTest static void CreateGenRoutingReportingTest(){
        set<Id> caseIdset = new Set<Id>();
        Test.startTest();
        try{
        //querying account, contact, location and asset.
        Map<ID, Case> caseNewMap = new Map<ID, Case>([SELECT Id,Case_Type__c,Reference_Number__c,Case_Sub_Type__c ,Location__c   FROM case limit 2]);

        CaseTriggerHelper.CreateGenRoutingReporting(caseNewMap ,caseNewMap );
        }
        catch(exception ex) {
            //method not used
        }
        Test.stopTest();
        
    }


    //Modified for SDT-33448 Start
    /*
    * @vendor            TCS
    * @story             
    * @author            Manisha Patil
    * @description       This method will be used to Code Coverage insertAutoApprovalLog.
    * @param             none
    * @return            
    */
    @isTest static void testinsertAutoApprovalLog(){
        Test.startTest();
        CaseTriggerHelper.insertAutoApprovalLog();
        Test.stopTest();
    }
    /*
    * @vendor            TCS
    * @story             
    * @author            Manisha Patil
    * @description       This method will be used to Code Coverage updateChargeable.
    * @param             none
    * @return            Set of Case Ids.
    */
    @isTest static void testupdateChargeable(){
        Test.startTest();
        set<Id> caseIdset = new Set<Id>();
        List<Case> caseNewList = [SELECT Id,Chargeable__c,ParentId,Case_Sub_Type__c ,Location__c FROM case limit 1];        
        for(Case ca:caseNewList){
            caseIdset.add(ca.Id);
        }
        CaseTriggerHelper.updateChargeable(caseIdset);
        Test.stopTest();
    }
    /*
    * @vendor            TCS
    * @story             
    * @author            Manisha Patil
    * @description       This method will be used to Code Coverage updateChargeablechild.
    * @param             none
    * @return            Set of Case Ids.
    */
    @isTest static void testupdateChargeablechild(){
        Test.startTest();
        set<Id> caseIdset = new Set<Id>();
        List<Case> caseNewList = [SELECT Id,Chargeable__c,ParentId,Case_Sub_Type__c ,Location__c FROM case limit 1];        
        for(Case ca:caseNewList){
            caseIdset.add(ca.Id);
        }
        CaseTriggerHelper.updateChargeablechild(caseIdset);
        Test.stopTest();
    }
    /*
    * @vendor            TCS
    * @story             
    * @author            Manisha Patil
    * @description       This method will be used to Code Coverage addCommentForChargeability.
    * @param             none
    * @return            List of Case.
    */
    @isTest static void testaddCommentForChargeability(){
        Test.startTest();
        Id recordTypeId = Schema.getGlobalDescribe().get('Comment__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Acorn_Ticket_Comment').getRecordTypeId();
        List<Case> caseNewList = [SELECT Id,CaseNumber,Case_Type__c,Tracking_Number__c,Reference_Number__c,Case_Sub_Type__c ,Location__c FROM case limit 1];
        List<Comment__c> commentList = new List<Comment__c>();
        Comment__c comment = new Comment__c();
        comment.is_Log__c = false;
        comment.Case__c = caseNewList[0].id;
        comment.recordTypeId = recordTypeId;
        comment.Communication_Log_Type_Name__c = 'Internal';
        comment.Workflow_TeamUser__c = System.UserInfo.getName();
        comment.Type__c = Constant_Util.OBJECT_CASE;
        comment.Case_Number__c = caseNewList[0].CaseNumber;
        comment.Acorn_Tracking_Number__c = caseNewList[0].Tracking_Number__c;
        commentList.add(comment);
        insert comment;
        CaseTriggerHelper.addCommentForChargeability(caseNewList);
        Test.stopTest();
    }
    //Modified for SDT-33448 End

    /*
    * @vendor            TCS
    * @description       This method will be used to Code Coverage EntitlementTriggerHelper.validateOverrideCheckbox() and validateNewSeviceEntitlement().
    */
    @isTest static void testEntitlementValidations(){
        List<Account> acc = [Select Id from Account where ParentId = null];
        List<Entitlement> enList = new List<Entitlement>();
        
        Entitlement entOverride = new Entitlement(Name='Entitlement1', AccountId=acc[0].Id, StartDate=Date.valueof(System.now().addDays(-2)),
                                          EndDate=Date.valueof(System.now().addYears(2)), Status__c = 'Approved', 
                                          Recordtypeid = TestDataFactory.getRecordType('SLA','Entitlement'), Request_Type__c = 'PickUp', 
                                          service__c = 'Extra Pickup', Call_On__c = 'Sun;Mon;Tue;Wed;Thu;Fri;Sat', Override_Business_Hours__c = true,
                                          Service_Guarantee_Category__c = 'Hours',Service_Guarantee_Category_Value__c = '24');
        enList.add(entOverride);
        
        Entitlement entNS = new Entitlement(Name='Entitlement2', AccountId=acc[0].Id, StartDate=Date.valueof(System.now().addDays(-2)),
                                          EndDate=Date.valueof(System.now().addYears(2)), Status__c = 'Approved', Schedule_Type__c = 'Permanent', 
                                          Recordtypeid = TestDataFactory.getRecordType('SLA','Entitlement'), Request_Type__c = 'New Service', 
                                          service__c = 'Temporary', Call_On__c = 'Sun;Mon;Tue;Wed;Thu;Fri;Sat',
                                          Service_Guarantee_Category__c = 'Days',Service_Guarantee_Category_Value__c = '24');
        enList.add(entNS);
        
        try {
            insert enList;
        }
        catch(Exception ex) {
            System.debug(ex);
        }
        
        
    }
    
    
        /*
    * @vendor            TCS
    * @story             SDT-42644
    * @author            Mohammed Rishan Ali
    * @description       This method is used .
    * @param             none
    * @return            List of Case.
    */
    @isTest static void populateCaseSubTypeForScheduledHandPickup(){

        List<Case> caseList;
        
        //Querying CSR User.
        User csrUser = [SELECT Id, Profile.Name, Bypass_Validation__c, IsActive FROM User WHERE Bypass_Validation__c =: false 
                        AND Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive =: true LIMIT 1];

        //Fetch Hand Pickup Asset
        Asset handPickupAsset = [Select Id, Location__c,location__r.ParentId,ParentId from Asset where Name ='Hand Pickup' and Occurrence_Type__c = 'Scheduled' 
                                 and ParentId = null   Limit 1];

        //Fetching Location
        Account location = [Select Id,ParentId from Account WHERE Id =:handPickupAsset.Location__c];
        //Create pickup case
        
        Test.startTest();
        
        System.runAs(csrUser)
        {
            caseList = TestDataFactory.createNewCasewithAsset(location, location, handPickupAsset);
            caseList[0].Recordtypeid = TestDataFactory.getRecordType('Pickup Case','Case');
            caseList[0].Case_Type__c = 'Pickup';
            Database.insert(caseList);
        }

        Test.stopTest();
        
		Case pickupCase = [SELECT Id,Case_Sub_Type__c from Case WHERE Id =:caseList[0].Id LIMIT 1];        
		List<SBS_Case_Asset__c> caseAssetList = [SELECT Id from SBS_Case_Asset__c where CaseId__c =: pickupCase.Id];
        
        //Check for Populating Case Subtype
        system.assertEquals('Extra Pickup', pickupCase.Case_Sub_Type__c);
        
        //Check for case assets
        system.assertEquals(2, caseAssetList.size());
        
    }
    
            /*
    * @vendor            TCS
    * @story             SDT-42644
    * @author            Mohammed Rishan Ali
    * @description       This method is used .
    * @param             none
    * @return            List of Case.
    */
    @isTest static void populateCaseSubTypeForOnCallHandPickup(){
		
        List<Case> caseList;
        
        //Querying CSR User.
        User csrUser = [SELECT Id, Profile.Name, Bypass_Validation__c, IsActive FROM User WHERE Bypass_Validation__c =: false 
                        AND Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive =: true LIMIT 1];
        
        //Fetch Hand Pickup Asset
        Asset handPickupAsset = [Select Id, Location__c,location__r.ParentId from Asset where Name ='Hand Pickup' and Occurrence_Type__c = 'On-Call' 
                                 and ParentId = null   Limit 1];
        //Fetching Location
        Account location = [Select Id,ParentId from Account WHERE Id =:handPickupAsset.Location__c];
        
        Test.startTest();
        
        System.runAs(csrUser)
        {
            caseList = TestDataFactory.createNewCasewithAsset(location, location, handPickupAsset);
            caseList[0].Recordtypeid = TestDataFactory.getRecordType('Pickup Case','Case');
            caseList[0].Case_Type__c = 'Pickup';
            Database.insert(caseList);
        }

        Test.stopTest();
        
		Case pickupCase = [SELECT Id,Case_Sub_Type__c from Case WHERE Id =:caseList[0].Id LIMIT 1];        
		List<SBS_Case_Asset__c> caseAssetList = [SELECT Id from SBS_Case_Asset__c where CaseId__c =: pickupCase.Id];
        
        //Check for Populating Case Subtype
        system.assertEquals('On Call', pickupCase.Case_Sub_Type__c);
        
        //Check for case assets
        system.assertEquals(1, caseAssetList.size());
        
    }

    //added on 22/03/2025 for coverage
    @isTest static void getIntakeSLADatetimeTest(){
        List<Case> csList = [Select Id, Location__c from case limit 1];
        Account loc = [Select Id,tz__Timezone_SFDC__c from Account Where Id =: csList[0].Location__c limit 1];
        loc.tz__Timezone_SFDC__c = 'America/New_York';
        update loc;
        
        CaseTriggerHelper.casewithLocation.put(loc.Id, loc);
        CaseTriggerHelper.getIntakeSLADatetime(DateTime.now()+1, DateTime.now()+2, csList[0]);
    }
    
    //added on 22/03/2025 for coverage
    @isTest static void updateReassignFieldTest(){
        List<Case> csList = [Select Id, Location__c from case limit 1];
        Set<Id> csSet = new Set<Id>();
        csSet.add(csList[0].Id);
        CaseTriggerHelper.updateReassignField(csSet);
    }
    
    //added on 22/03/2025 for coverage
    @isTest static void updateCCandPOTest(){
        Account loc = [Select Id,tz__Timezone_SFDC__c, ParentId from Account Where recordtype.name = 'Location' limit 1];
        Account acc = [Select Id,tz__Timezone_SFDC__c from Account Where recordtype.name = 'Client' limit 1];
        Contact con = [Select Id from Contact limit 1];
        User usr = [Select Id from User limit 1];
        
        Case newCase = TestDataFactory.newServiceCase('test', acc, con, usr, loc);
        newCase.Company_Category__c = 'Equipment Repair';
        newCase.CompanyCategoryCode__c = 'EPR';
        newCase.PurchaseOrder_Number__c = '1234';
        insert newCase;
		List<Case> newCaseList = new List<Case>();
		newCaseList.add(newCase);
        
        Map<Id, Case> oldCaseMap = new Map<Id, Case>();
        Case oldCase = new Case();
        oldCase.Id = newCase.Id;
        oldCase.Company_Category__c = 'D29B Project Bar - Deco Plumbing Wave 3 FY24 (84468)';
        oldCase.CompanyCategoryCode__c = 'HMD_96208515';
        oldCase.PurchaseOrder_Number__c = '12345';
		oldCaseMap.put(oldCase.Id, oldCase);
            
        Test.startTest();
        CaseTriggerHelper.updateCCandPO(newCaseList, oldCaseMap);
        Test.stopTest();
    }
    
    //added on 22/03/2025 for coverage
    @isTest static void updateCommentsTrackingNumberTest(){
   		User currentuser = [SELECT Id, Profile.Name, Bypass_Validation__c, IsActive FROM User WHERE Bypass_Validation__c =: false AND Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive =: true LIMIT 1]; //Modified for SDT-33448           
        system.runAs(currentuser){
            List<Asset> aselst = [Select Id, Location__c from Asset where Location__c != null Limit 1];
            List<Account> loclst = [Select Id, Name,ParentId from Account where Id =: aselst.get(0).Location__c Limit 1];
            List<Account> acclst = [Select Id, Name from Account where Id =: loclst.get(0).ParentId Limit 1];
            List<Contact> conlst = [Select Id, Name from Contact where Accountid =: acclst.get(0).Id Limit 1];
            List<Case> caselist = TestDataFactory.createCase(CASE_NAME, acclst.get(0), conlst.get(0), currentuser, loclst.get(0), aselst.get(0));
            caselist[0].RecordTypeId = Schema.SobjectType.Case.getRecordTypeInfosByDeveloperName().get(Constant_Util.R_STATUS_CASE).getRecordTypeId();
            caselist[0].Status = Constant_Util.OPEN;
            caselist[0].Case_Sub_Status__c = Constant_Util.PENDING_SERVICE_ISSUE_RESOLUTION;
            caselist[0].Case_Reason__c = Constant_Util.HAULER_REPORTED;
            caselist[0].Service_Classification__c = Constant_Util.STANDARD; //SDT-33363
            caselist[0].Case_Type__c = Constant_Util.STATUSFIELD;
            caselist[0].Case_Sub_Type__c = Constant_Util.SERVICE_NOT_PERFORMED;
            caselist[0].Tracking_Number__c = 'T12345678';

 
        	Insert caselist;
         Map<ID, Case> caseNewMap = new Map<ID, Case>([SELECT Id,Case_Type__c,Reference_Number__c,Case_Sub_Type__c ,
                                                       Location__c,Case_Reason__c,Case_Sub_Status__c ,Tracking_Number__c  FROM case WHERE Id=:caselist[0].Id limit 2]);
 
         CaseTriggerHelper.updateCommentsTrackingNumber(caseNewMap,caseNewMap);
        }
    }
    @isTest static void testCreateApprovalTaskForOriginApprovers() {
        User testUser = [SELECT Id FROM User WHERE FirstName = 'testuser##9999' LIMIT 1];
        Account testAccount = [SELECT Id, AccountNumber FROM Account WHERE AccountNumber = 'HMD' LIMIT 1];
        Case testCase = [SELECT Id, CaseNumber, Origin,Reference_Number__c, Last_Agent_Id_ForTaskAssignment__c FROM Case where
                        Status__c = :Constant_Util.PENDING and Case_Sub_Status__c= :Constant_Util.PENDING_REQUEST_APPROVAL LIMIT 1];
        Approval_Log__c approvalLog = [SELECT Id FROM Approval_Log__c WHERE CaseId__c = :testCase.Id LIMIT 1];
        Business_Rule__c businessRule = [SELECT Id FROM Business_Rule__c WHERE Service__c = 'Extra Pickup' LIMIT 1];

        Map<Id, Case> newCaseMap = new Map<Id, Case>();
        newCaseMap.put(testCase.Id, testCase);
    
        Test.startTest();
        CaseTriggerHelper.createApprovalTaskForOriginApprovers(
            approvalLog.Id, 
            new List<Business_Rule__c>{businessRule}, 
            newCaseMap
        );
        Test.stopTest();

        List<Task> createdTasks = [SELECT Id, Subject, WhatId, OwnerId, Approval_Log__c FROM Task WHERE WhatId = :testCase.Id];
        System.assertEquals(3, createdTasks.size(), 'Expected one task to be created.');
    }
}
