@isTest(seealldata = false)
public class QuoteApprovalTestForSoql {
    
    /*
* @MethodName    : setup
* @Author        : 
* @Vendor		 : TCS
* @description	 : This method will be used to setup inital required data to test QuoteApproval class.
*/
    public static String JSON_VALID_ROLLOFF_DATA = '{"data":{"priceQuoteIdentifier":"Q11837","costSource":"WM (SBS|RO|OT|30O|B02860|20211019|025300|5810)","contractType":"Open Market","lineOfBusiness":"Roll Off","supplierCode":"10016","supplierName":"WMI OF MI, LIVONIA","customerCode":"HMD","customerName":"The Home Depot","locationCode":"HMD002718","wasteStreamCode":"MSW_RO","wasteStreamName":"Municipal Solid Waste","equipmentCode":"30O","equipmentName":"30 Yard Open Top","equipmentUOM":"Tons","materialCode":"T","materialName":"MSW - Unspecified","equipmentSizeCode":"YRDS-30","equipmentSizeName":"30 Yards","overridableEquipmentSizeCode":null,"overridableEquipmentSizeName":null,"zoneCode":"GIS543320","zoneName":"Detroit Central - RO MSW - To Woodland 1","disposalFacilityType":"S04264_LF","disposalFacilityName":"B02860|S04264_LF|129A_WDL|MSW_RO","commercial":null,"rollOff":{"pricingMethodDisposalCode":"1.0","pricingMethodDisposalDescription":"Market Based Pricing","pricingMethodHaulingCode":"1.0","pricingMethodHaulingDescription":"Market Based Pricing","haulCost":410.59,"haulPrice":null,"disposalCost":30.42,"disposalPrice":null,"estimatedVolumePerHaul":4,"applyInvoiceFeesToDisposalCharges":"Y","applyInvoiceFeesToRentalCharges":null,"travelTimePerHaul":126.68,"landfillMinutes":25,"transferSiteCode":"NA","equipmentAvailabilityTypeCode":"TEMP","materialClassName":"MSW_MSWI_Municipal Solid Waste - Industrial","equipmentLoadingMinutes":20,"equipmentAdditionalLoadingMinutes":null,"stepDisposals":null},"wmMetaData":{"businessUnit":"B02860","masLibrary":"129A_WDL","francisePricingLink":"","greenPagesLink":"","marketArea":"WM of Michigan Ohio Indiana"},"tpMetaData":null,"serviceCharges":[{"code":"FU_RO_TEMP_OPEN","name":"Fuel Fee","componentTypeCode":"ENS","componentTypeName":"Energy Surcharge","actionCode":"EX","actionName":"Exclude","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly"},{"code":"ENV_RO_TEMP_OPEN","name":"Environmental Fee","componentTypeCode":"ENV_FEE","componentTypeName":"Environmental Fee","actionCode":"EX","actionName":"Exclude","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly"},{"code":"RCR_RO_TEMP_OPEN","name":"Regulatory Cost Recovery","componentTypeCode":"UNK","componentTypeName":"Unknown","actionCode":"EX","actionName":"Exclude","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly"},{"code":"CSC_RO_TEMP_OPEN","name":"Container Service Charge","componentTypeCode":"UNK","componentTypeName":"Unknown","actionCode":"EX","actionName":"Exclude","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly"},{"code":"D_RO_TEMP_OPEN","name":"Delivery","componentTypeCode":"UNK","componentTypeName":"Unknown","actionCode":"EX","actionName":"Exclude","cost":0,"costValueType":"Amount","costUOM":"Monthly","price":0,"priceValueType":"Amount","priceUOM":"Monthly"}]},"problem":null}';
	public static final string SYS_ADMIN = 'System Administrator';
    public static final String AAV_API_REQUEST_OUTPUT = '{"data": {"requestedDate": "2023-09-04","lineOfBusiness": "Roll Off","customerCode": "HMD","customerName": "The Home Depot","locationCode": "HMD006959","materialCode": "T","materialName": "Trash","countryCode": "USA","suppliers": [{"availabilitySource": "WM","supplierCode": null,"supplierName": null,"contractType": "Competitor","wasteStreamCode": "MSW","wasteStreamName": "Municipal Solid Waste","zoneCode": "GIS624853","zoneName": "Non WM Franchise - Bainbridge - CM MSW","wmMetaData": {"marketAreaCode": "K00126","marketAreaName": "WM of South Atlantic","facilityId": "GA0075","facilityName": "Albany Hauling","siteId": "S10284","siteName": "Albany Hauling"},"tpMetaData": null,"deliveryDays": null,"serviceDays": null,"deliveries": null,"outages": null,"messages": [{"code": "ER400","description": "WM Schedule information not available due to Competitor / Franchise Contract Type"}]}],"messages": []},"problem": null}';

    @testSetup
    public static void setup() {
       /* Set<String> permissionsetNames = new Set<String>{'Customer_Service_Reporting_User','Governance_Team','Merge_Access_for_Non_Admin_Users',
            'Price_Accessibility_Permission_Set','Pricing_Access', 'CPQ_Extended_License'};    
                List<PermissionSetLicense> pslList= [SELECT Id FROM PermissionSetLicense WHERE DeveloperName = 'SalesforceCPQ_CPQStandardPerm' AND Status='Active'];
        
        
        //fetching Customer Service profile 
        Profile CustomerServieUser = TestDataFactory.getProfile(Constant_Util.CUSTOMER_SERVICE);
        //creating a CSR user
        User CSRUser = TestDataFactory.createUser(CustomerServieUser);
        Insert CSRUser;
        //Assigning permissionset license
        insert new PermissionSetLicenseAssign(AssigneeId = CSRUser.Id, PermissionSetLicenseId= pslList[0].Id);
        //assigning permission sets
        QuoteTestDataFactory.assignPermissionSet(permissionsetNames, CSRUser);
        
        //System.debug(customerServiceUser); */
        
        //Changes for SDT-39632
        CodeSwitchTestData.CodeSwitchData();
        
        Profile adminProfile = TestDataFactory.getProfile(SYS_ADMIN);
        User CSRUser = TestDataFactory.createUser(adminProfile);
        CSRUser.FirstName = 'testuser#9999';
        CSRUser.Bypass_Validation__c = false;
        CSRUser.Genesys_Enabled__c = false;
        Database.insert(CSRUser);
        System.runAs(CSRUser){
            Test.startTest();
            
            //create parent account
            Account parentAccount = QuoteTestDataFactory.createParentAccountRecord('Test Parent Account', '10', ConstantClass.RecordType_Client, CSRUser);
            QuoteTestDataFactory.insertAccount(parentAccount);
            
            //create location account
            Account locationAccount = QuoteTestDataFactory.createLocationAccount('location account', parentAccount.Id, CSRUser);
            QuoteTestDataFactory.insertAccount(locationAccount);
            
            //Create vendor account 
            Id vendorRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(ConstantClass.RecordType_Vendor).getRecordTypeId();
            Account parentVendor = new Account(Name = 'Parent Vendor', RecordTypeId = vendorRecordtypeId,
                                               Status__c = ConstantClass.FieldStatus_Active, AccountNumber = '8'); 
            QuoteTestDataFactory.insertAccount(parentVendor);
            
            //create child vendor account
            Account childVendor = QuoteTestDataFactory.createVendorAccountwithParent('child Vendor', parentVendor.Id, CSRUser);
            QuoteTestDataFactory.insertAccount(childVendor);
            
            //create title for contact
            Account_Title__c titleOfQuoteContact = QuoteTestDataFactory.createAccountTitle('Not Manager',parentAccount);
            QuoteTestDataFactory.insertAccountTitle(titleOfQuoteContact);
            
            //create department for contact
            Department__c quoteContactDept = QuoteTestDataFactory.createDepartment('department for quotecontact',parentAccount);
            QuoteTestDataFactory.insertDepartment(quoteContactDept);
            
            //creating contact
            Contact quoteContact = QuoteTestDataFactory.createContactRecord('Quote contact', parentAccount.Id, CSRUser);
            quoteContact.Email = 'testclass123@abc.com';
            quoteContact.Account_Title__c = titleOfQuoteContact.Id;
            quoteContact.Account_Department__c = quoteContactDept.Id;
            QuoteTestDataFactory.insertContact(quoteContact);
            
            //creating contact for contact approver
            Contact approverContact = QuoteTestDataFactory.createContactRecord('approver contact', parentAccount.Id, CSRUser);
            approverContact.Email = 'testclass1234@abc.com';
            approverContact.Account_Title__c = titleOfQuoteContact.Id;
            approverContact.Account_Department__c = quoteContactDept.Id;
            QuoteTestDataFactory.insertContact(approverContact);
            
            
            //creating case
            //JSON string for Case
            
            String caseJSON = '{"IsDeleted": false,"Status": "Closed","Priority": "Medium","IsEscalated": false,"CurrencyIsoCode": "USD","IsClosedOnCreate": false,"IsStopped": false,"MilestoneStatus": "","tz__Local_Time_24_Short__c": "10:44 EDT","tz__Local_Time_24__c": "06/05/2023 10:44 EDT","tz__Local_Time_Short__c": "10:44 AM EDT","tz__Local_Time__c": "06/05/2023 10:44 AM EDT","tz__Timezone_Formula__c": "EDT","tz__Timezone_Full__c": "Eastern Daylight Time","tz__UTC_Offset_Formula__c": -4,"Case_Sub_Type__c": "Temporary","Case_Type__c": "New Service","Acorn_Ticket_Not_Matched__c": false,"BackOffice_Case__c": false,"Bypass_WO_Duplicate__c": false,"Case_Reason__c": "Clean Up External","CheckBackDatedCase__c": false,"Contact_Title__c": "dev","Create_AM_and_PM_Pickups__c": false,"Emergency__c": false,"Exclude_Holidays__c": true,"Exclude_Saturdays__c": true,"Exclude_Sundays__c": true,"Friday__c": false,"Ignore_Duplicate__c": false,"Integrate_with_Acorn__c": false'
                +',"Is_Clone__c": false,"Is_Electrical_Workers__c": false,"Is_Info_Task_Created__c": false,"Is_Monitored__c": false,"Is_Multiple_Case_Allowed__c": false,"Is_Multivendor__c": false,"Is_PSI_Required__c": false,"Is_Recreated__c": false,"Is_With_Lock__c": false,"Is_With_Wheel__c": false,"Is_the_compactor_leaking__c": false,"LOB__c": "Commercial","Locally_Billed__c": false,"Mark_to_delete__c": false,"Monday__c": false,"No_Price__c": false,"No_Service_Evidence__c": false,"Offsite_Address__c": false,"Override_PO_Create_Task__c": false,"PSI_Required__c": false,"Product_Information__c": "-","PurchaseOrder_Required__c": false,"Quote_Only__c": false,"Recently_Modified__c": false,"SLA_Service_DateTime__c": "06/06/2023 8:00 PM CST","SLA_Service_Date_Time__c": "2023-06-07T02:00:00.000+0000","SLA_Violation__c": false,"SalesMeet_WM_Capacity__c": false,"Same_Next_Day__c": false,"Saturday__c": false,"Service_Date_Time_Formula__c": "2023-06-01T00:00:00.000+0000","Service_Date__c": "2023-06-01","Source_System__c": "Salesforce","Sunday__c": false,"Suppress_Auto_Response__c": false,"Tech_Location_Details__c": "1333 WESTERN AVE<br>Chicago Heights, Illinois<br>60411, United States","Temp_Asset_needed__c": false,"Thursday__c": false'
                +',"Time_Testing_Temp__c": "2023-06-05T13:49:36.000+0000","Tuesday__c": false,"VCC_Complete__c": false,"Wednesday__c": false,"X10_mins_Delay__c": "2023-05-29T09:27:20.000+0000","X5_mins_Delay__c": "2023-05-29T09:12:24.000+0000","isApproved__c": false,"isRejected__c": false,"isWorkOrderCreated__c": true,"Due_Date_Time_for_CSC_Location__c": "2023-06-03T17:00:00.000+0000","Due_Date_Time_for_CSC__c": "2023-06-02T17:00:00.000+0000","Due_Date_Time_for_OSC__c": "2023-06-01T21:00:00.000+0000","Service_Date_for_CSC__c": "2023-06-02","Service_Date_for_OSC__c": "2023-05-25","Check_Case__c": false,"Close_Irrelevant_Case__c": false,"Close_Pickup_Case__c": false,"Case_Record_Type__c": "New Service Case","Case_Subtype_Email_Format__c": "Temporary","Is_Multiple_Asset__c": false,"Onsite_Contact_Phone_Email_Format__c": "()--","Quote_Only_Email_Format__c": "No","Service_Date_from_Local_Time__c": "2023-05-29","Show_Multiple_Asset_Cases__c": false,"Task_Count__c": 0,"Override_Profile_Number_Task__c": false,"Contact_Title_Email_Form__c": "Dev","Availability_Checked__c": false,"Availability_Confirmed__c": false,"isMultiCalendarChecked__c": false,"Is_From_ScreenPop__c": false,"Is_Case_CSC_Created__c": false,"Is_Case_OSC_Created__c": false,"Location_Name_Email_Temp__c": "Kroger","Wm_Vendor_Email_Temp__c": false,"Is_MultiCase_TaskBundling__c": false,"Master_Intake_Complete__c": true,"Customer_Code__c": "KRG","isIndicoCaseUpdate__c": false,"Is_Multiple_Case_Per_ServiceDT__c": false,"LocationOffset__c": -4,"LocationTimezone__c": "EDT","Premium_Delivery_Eligible__c": false,"CPQ_New_Service__c": true,"IsOpportunity_Created__c": true,"Is_ByPassWO__c": false,"Test__c": "1333 WESTERN AVEChicago Heights, Illinois60411, United States","ShowArchivedEmail__c": false,"CloseTime__c": 7,"IsAutoReplySent__c": false  }';
            //Converting the string into Case object and keeping it into a list.
            Case caseObj = (Case) JSON.deserialize(caseJSON, Case.class);
            caseObj.Case_Type__c = 'New Service';
            caseObj.ContactId = quoteContact.Id;
            caseObj.Client__c = locationAccount.ParentId;
            caseObj.Location__c = locationAccount.Id;
            caseObj.Origin = 'Email';
            caseObj.SuppliedEmail = 'testclass123@abc.com';
            caseObj.RecordTypeId = QuoteTestDataFactory.getRecordType(ConstantClass.RecordType_NewServiceCase,'Case');          
            
            List<Case> caseObjList = new List<Case>();
            caseObjList.add(caseObj);
            //Inserting the Case object list into org
            QuoteTestDataFactory.insertCases(caseObjList); 
            
            //creating products
            List<Product2> productList = new List<Product2>();
            
            Product2 openTop = QuoteTestDataFactory.createProductRecord('Open Top', 'Rolloff', 'OT');
            openTop.ProductConfigurationType__c = 'Bundle';
            productList.add(openTop);
            
            Product2 trash = QuoteTestDataFactory.createProductRecord('Trash', 'Waste Category', 'OTT');
            productList.add(trash);
            
            Product2 disposal = QuoteTestDataFactory.createProductRecord('Disposal', 'Rolloff', 'DSP');
            productList.add(disposal);
            
            Product2 containerServiceCharge = QuoteTestDataFactory.createProductRecord('Container Service Charge', 'Services', 'CSC');
            productList.add(containerServiceCharge);
            
            Product2 delivery = QuoteTestDataFactory.createProductRecord('Delivery', 'RollOff', 'DLV');
            productList.add(delivery);
            
            Product2 haulService = QuoteTestDataFactory.createProductRecord('Haul', 'Services', 'H');
            productList.add(haulService);
            
            Product2 trash2 = QuoteTestDataFactory.createProductRecord('Trash', 'Waste Stream', 'T');
            productList.add(trash2);
            
            QuoteTestDataFactory.insertProducts(productList);
            
            //creating Opportunity
            Opportunity opp = QuoteTestDataFactory.createOpportunity(1, ConstantClass.FieldStageName_Proposal, 'OpportunityForCase', caseObj.Id, ConstantClass.FieldSubType_Temporary, locationAccount.Id);  
            opp.Duration__c = constantclass.FieldSubType_Temporary;
            QuoteTestDataFactory.insertOpportunity(opp);
            
            //creating Business rule
            Business_Rule__c businessRuleForApproval = QuoteTestDataFactory.createBusinessRule(parentAccount, locationAccount, ConstantClass.RecordType_Approval);
            businessRuleForApproval.Container__c = '';
            businessRuleForApproval.Is_Auto_Email__c = true;//added
            businessRuleForApproval.Schedule_Type__c ='';
            businessRuleForApproval.Channel__c = '';
            businessRuleForApproval.Channel_Req__c = '';
            QuoteTestDataFactory.insertBusinessRule(businessRuleForApproval);
            
            
            //create quote
            SBQQ__Quote__c quoteForTesting = QuoteTestDataFactory.createQuoteRecords(opp, locationAccount, quoteContact);
            //quoteForTesting.SBQQ__StartDate__c= system.today();
            List<SBQQ__Quote__c> quoteListForTesting = new List<SBQQ__Quote__c>();
            quoteListForTesting.add(quoteForTesting);
            QuoteTestDataFactory.insertQuotes(quoteListForTesting); 
            
            //create pricing request
            Pricing_Request__c pricingRequest = TestDataFactory.createPricingRequestRecord(caseObj, parentAccount, locationAccount,
                                                                                           Constant_Util.ROLLOFF, 'AM', '', 
                                                                                           JSON_VALID_ROLLOFF_DATA, CSRUser);
            
            //QuoteLine Creation open top
            SBQQ__QuoteLine__c quotelineForContainer = QuoteTestDataFactory.createQuoteLineRecords(quoteForTesting,openTop,
                                                                                                   'TEMP',1.00,'CLT','YRDS-30',
                                                                                                   'OC','M','1','PER',34.00,'DYS',
                                                                                                   'PER',null,'DYS','Do Not Override','NBG');
            quotelineForContainer.SBQQ__Bundle__c = TRUE;
            quotelineForContainer.SBQQ__RequiredBy__c = null;
            quotelineForContainer.Vendor__c = childVendor.Id;
            QuoteTestDataFactory.insertQuoteLine(quotelineForContainer);
            //System.debug(quotelineForContainer.Id);     
            
            //Querying the inserted quoteline
            SBQQ__QuoteLine__c insertedContainerQuoteLine = [Select Id, SBQQ__Product__c from SBQQ__QuoteLine__c 
                                                             Where SBQQ__Product__c=:openTop.Id LIMIT 1];
            
            List<SBQQ__QuoteLine__c> childQuotelineList = new List<SBQQ__QuoteLine__c>();
            //haul
            SBQQ__QuoteLine__c quotelineForHaulService = QuoteTestDataFactory.createQuoteLineRecords(quoteForTesting, haulService,'TEMP',1.00,'CLT',
                                                                                                     'YRDS-30','OC','M','1','PER',34.00,'DYS','PER',
                                                                                                     563.47,'DYS','Do Not Override','NBG');
            quotelineForHaulService.SBQQ__RequiredBy__c =  insertedContainerQuoteLine.Id;
            quotelineForHaulService.Vendor__c = parentVendor.Id;
            quotelineForHaulService.SBQQ__UnitCost__c = 300;
            quotelineForHaulService.CostModelType__c='PER';
            quotelineForHaulService.MASLibrary__c='ARDTA.180';
            quotelineForHaulService.MASCompany__c='test mas company'; 
            quotelineForHaulService.Cost_Unit_of_Measure__c= 'BNDL';
            quotelineForHaulService.Vendor__c = childVendor.Id;
            childQuotelineList.add(quotelineForHaulService);
            
            SBQQ__QuoteLine__c quotelineForTrashWC = QuoteTestDataFactory.createQuoteLineRecords(quoteForTesting, trash,'TEMP',1.00,'CLT',
                                                                                                 'YRDS-30','OC','M','1','PER',34.00,'DYS','PER',
                                                                                                 563.47,'DYS','Do Not Override','NBG');
            quotelineForTrashWC.SBQQ__RequiredBy__c =  insertedContainerQuoteLine.Id;
            quotelineForTrashWC.Vendor__c = parentVendor.Id;
            quotelineForTrashWC.SBQQ__UnitCost__c = 2;
            quotelineForTrashWC.CostModelType__c='PER';
            quotelineForTrashWC.MASLibrary__c='ARDTA.180';
            quotelineForTrashWC.MASCompany__c='test mas company'; 
            quotelineForTrashWC.Cost_Unit_of_Measure__c= 'BNDL';
            quotelineForTrashWC.Vendor__c = childVendor.Id;

            childQuotelineList.add(quotelineForTrashWC);
            
            
            
            
            //quoteline for trash waste stream
            SBQQ__QuoteLine__c quotelineForDisposal = QuoteTestDataFactory.createQuoteLineRecords(quoteForTesting, disposal,'TEMP',1.00,'CLT',
                                                                                                  'YRDS-30','OC','M','1','PER',34.00,'DYS','PER',
                                                                                                  563.47,'DYS','Do Not Override','NBG');
            quotelineForDisposal.SBQQ__RequiredBy__c =  insertedContainerQuoteLine.Id;
            quotelineForDisposal.Vendor__c = parentVendor.Id;
            quotelineForDisposal.SBQQ__UnitCost__c = 2;
            quotelineForDisposal.CostModelType__c='PER';
            quotelineForDisposal.MASLibrary__c='ARDTA.180';
            quotelineForDisposal.MASCompany__c='test mas company'; 
            quotelineForDisposal.Cost_Unit_of_Measure__c= 'BNDL';
            quotelineForDisposal.Vendor__c = childVendor.Id;
            childQuotelineList.add(quotelineForDisposal);
            
            //quoteline for container service charge
            SBQQ__QuoteLine__c quotelineForCSC = QuoteTestDataFactory.createQuoteLineRecords(quoteForTesting, containerServiceCharge,'TEMP',1.00,'CLT',
                                                                                             'YRDS-30','OC','M','1','PER',34.00,'DYS','PER',
                                                                                             563.47,'DYS','Do Not Override','NBG');
            quotelineForCSC.SBQQ__RequiredBy__c =  insertedContainerQuoteLine.Id;
            quotelineForCSC.Vendor__c = parentVendor.Id;
            quotelineForCSC.SBQQ__UnitCost__c = 2;
            quotelineForCSC.CostModelType__c='PER';
            quotelineForCSC.MASLibrary__c='ARDTA.180';
            quotelineForCSC.MASCompany__c='test mas company'; 
            quotelineForCSC.Cost_Unit_of_Measure__c= 'BNDL';
            quotelineForCSC.Vendor__c = childVendor.Id;
            childQuotelineList.add(quotelineForCSC);
            
            //quoteline for delivery
            SBQQ__QuoteLine__c quotelineFordelivery = QuoteTestDataFactory.createQuoteLineRecords(quoteForTesting, delivery,'TEMP',1.00,'CLT',
                                                                                                  'YRDS-30','OC','M','1','PER',34.00,'DYS','PER',
                                                                                                  563.47,'DYS','Do Not Override','NBG');
            quotelineFordelivery.SBQQ__RequiredBy__c =  insertedContainerQuoteLine.Id;
            quotelineFordelivery.Vendor__c = parentVendor.Id;
            quotelineFordelivery.SBQQ__UnitCost__c = 2;
            quotelineFordelivery.CostModelType__c='PER';
            quotelineFordelivery.MASLibrary__c='ARDTA.180';
            quotelineFordelivery.MASCompany__c='test mas company'; 
            quotelineFordelivery.Cost_Unit_of_Measure__c= 'BNDL';
            quotelineFordelivery.Vendor__c = childVendor.Id;
            childQuotelineList.add(quotelineFordelivery);
            //ADDED
            if(SBQQ.TriggerControl.isEnabled()){
                SBQQ.TriggerControl.disable();
            }
            insert(childQuotelineList);

            //inserting AAV
            AAV_Asset_Availability__c aavObj = new AAV_Asset_Availability__c();
            aavObj.AAV_Location__c = locationAccount.Id;
            aavObj.AAV_APIRequestOutput__c = AAV_API_REQUEST_OUTPUT;
            aavObj.AAV_Quote_Line__c = quotelineForContainer.Id;
			insert aavObj;
            Test.stopTest();

            
            //quoteline for trash waste stream
            SBQQ__QuoteLine__c quotelineForTrashWS = QuoteTestDataFactory.createQuoteLineRecords(quoteForTesting, trash2,'TEMP',1.00,'CLT',
                                                                                                 'YRDS-30','OC','M','1','PER',34.00,'DYS','PER',
                                                                                                 563.47,'DYS','Do Not Override','NBG');
            quotelineForTrashWS.SBQQ__RequiredBy__c =  quotelineForTrashWC.Id;
            quotelineForTrashWS.Vendor__c = parentVendor.Id;
            quotelineForTrashWS.SBQQ__UnitCost__c = 2;
            quotelineForTrashWS.CostModelType__c='PER';
            quotelineForTrashWS.MASLibrary__c='ARDTA.180';
            quotelineForTrashWS.MASCompany__c='test mas company'; 
            quotelineForTrashWS.Cost_Unit_of_Measure__c= 'BNDL';
            quotelineForTrashWS.Vendor__c = childVendor.Id;

            insert(quotelineForTrashWS);
            
            Quote_Order__c quoteOrder = new Quote_Order__c();
            quoteOrder.Service_Type__c = 'Delivery';
            quoteOrder.Quote_Line__c = insertedContainerQuoteLine.Id;
            quoteOrder.Product_Type__c = 'Delivery';
            quoteOrder.Service_Quote_Line__c = quotelineFordelivery.Id;
            
            insert(quoteOrder);

            List<Service_Approver__c> serviceApprovers = new List<Service_Approver__c>();
            //inserting email approver
            Service_Approver__c serviceApproverEmail = QuoteTestDataFactory.createServiceApprover(businessRuleForApproval, ConstantClass.RecordType_Email);
            serviceApproverEmail.Active__c = false;
            serviceApproverEmail.Email__c = quoteContact.Email;
            serviceApprovers.add(serviceApproverEmail);
            
            //inserting email approver
            Service_Approver__c serviceApproverContact1 = QuoteTestDataFactory.createServiceApprover(businessRuleForApproval, ConstantClass.RecordType_Contact);
            serviceApproverContact1.Active__c = true;
            serviceApproverContact1.Approver_Contact__c = approverContact.Id;
            serviceApprovers.add(serviceApproverContact1);
            
            //inserting email approver
            Service_Approver__c serviceApproverContact2 = QuoteTestDataFactory.createServiceApprover(businessRuleForApproval, ConstantClass.RecordType_Contact);
            serviceApproverContact2.Active__c = true;
            serviceApprovers.add(serviceApproverContact2);
            
            //inserting email approver
            Service_Approver__c serviceApproverContact3 = QuoteTestDataFactory.createServiceApprover(businessRuleForApproval, ConstantClass.RecordType_Contact);
            serviceApproverContact3.Active__c = true;
            serviceApprovers.add(serviceApproverContact3);
            
            Database.insert(serviceApprovers);
            
            //commented by av4 on 28/12/2023
            //adding stp criteria
            /*String StpJson = '{"IsDeleted": false,"Name": "New OT Temp OC Trash","CurrencyIsoCode": "USD","Service_Type__c": "New Service Case",'
                +'"Customer_Included_Canada__c": true,"Customer_All_Canada__c": true,"Duration__c": "TEMP;PERM","Customer_All__c": true,'
                +'"Customer_Included__c": true,"Frequency__c": "OC","Equipment__c": "Open Top","Parent_V__c": "8","Active__c": true,'
                +'"Material__c": "Trash"  }';
            
            STP_Criteria__c criteria = (STP_Criteria__c) JSON.deserialize(StpJson, STP_Criteria__c.class);
            criteria.Parent_VID__c = '8';
            criteria.Customer_Canada__c = null ;
            criteria.Customer_All_Canada__c = true; 
            criteria.Customer_Included_Canada__c = true;
            criteria.recordTypeId = QuoteTestDataFactory.getRecordType('STP Eligibility', 'STP_Criteria__c'); 
            insert(criteria);*/
            
            STP_Criteria__c criteria = QuoteTestDataFactory.createSTPCriteriaWithAllParam(null, true, true, 'TEMP', 'Open Top', 'OC', 'Trash', 
                                                                                          'New Service Case', true, '8', 'K00126', null, 
                                                                                          true, true, 'Full STP', true, false, true, true, '', 'Any');
            insert(criteria);
            
            
            
        }
        
    }
    
    /*
* @MethodName    autoApprovalForBREmail
* @Author        
* @Vendor		  TCS
* @descriptionChecking whether the quote status moves to 'Approved' when the approver(Email) 
* is same. 
*/
    @isTest static void autoApprovalForBREmail(){
        test.startTest();
        User usr = [Select Id, FirstName FROM User WHERE FirstName =: 'testuser#9999' LIMIT 1];
        System.runAs(usr) {
        SBQQ__Quote__c quoteForTesting = new SBQQ__Quote__c();
        //querying inserted test quote
        quoteForTesting =[SELECT Id,SBQQ__Status__c FROM SBQQ__Quote__c 
                          WHERE SBQQ__Status__c =:ConstantClass.FieldStatus_Draft]; 
        
        //updating the quote staus to Product Configured.
        /*quoteForTesting.SBQQ__Status__c = ConstantClass.FieldStatus_ProductConfigured;
        update quoteForTesting;*/
        
        //updating the quote staus to Cost Configured.
        /*quoteForTesting = [SELECT id,Priority__c, SBQQ__Account__c, SBQQ__Status__c, Duration__c, SBQQ__StartDate__c 
                           FROM SBQQ__Quote__c WHERE SBQQ__Status__c=: ConstantClass.FieldStatus_ProductConfigured LIMIT 1];*/
        quoteForTesting.SBQQ__Status__c=ConstantClass.FieldStatus_PriceConfigured;
        quoteForTesting.Priority__c = 'P3';
        if(SBQQ.TriggerControl.isEnabled()){
                SBQQ.TriggerControl.disable();
            }
        update quoteForTesting; 

        //querying Email Service Approver
        Id recordTypeId = QuoteTestDataFactory.getRecordType(ConstantClass.RecordType_Email, 'Service_Approver__c');
        Service_Approver__c serviceApproverEmail = [Select Id, Active__c from Service_Approver__c 
                                                    Where RecordTypeId =: recordTypeId];
        serviceApproverEmail.Active__c = True;
        update serviceApproverEmail;
                
        test.stopTest();
        //updating the quote staus to Price Configured.
        //quoteForTesting.SBQQ__Status__c= ConstantClass.FieldStatus_PriceConfigured; 
        STPRuleExecution.executeRules(quoteForTesting.Id, 'Full STP');
        
        //Bypassing RecursiveTriggerHandler class for trigger and updating.
        RecurrsiveTriggerHandler.isSkipQuoteTrigger = true;
                
        SBQQ__Quote__c updatedQuote = [select Id,SBQQ__Status__c from SBQQ__Quote__c where Id =:quoteForTesting.Id];
        system.debug(updatedQuote);
        System.assertEquals(ConstantClass.FieldStatus_Approved, updatedQuote.SBQQ__Status__c);  
        }
        
    }  

    
}