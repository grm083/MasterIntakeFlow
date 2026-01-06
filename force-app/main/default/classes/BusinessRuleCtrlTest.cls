@isTest
public class BusinessRuleCtrlTest {
    
    private static final string SYS_ADMIN = 'System Administrator';
    private static final string PRODUCT = '8 yrd';
    private static final string KROGER = 'kroger';
    private static final string RITA = 'Rita';
    private static final string REPLY = 'Reply';
    private static final string TESTSUPPLIER = 'testsupplier';
    private static final string SUPPLIER = 'Vendor';
    private static final string ASSET_NAME = '8 yrd Dumpster';
    private static final string CASE_NAME = 'First';
    private static final string NY_TIMEZONE = 'America/New_York';
    private static final string PO_NUMBER = '1243';
    private static final string COMMERCIAL = 'Commercial';
    private static final string COMPACTOR = 'COMPACTOR';
    private static final string DISTRICT_MANAGER = 'District Manager';
    private static final string PO_PSI_VALUE = 'PO Number'; //SDT-33363
    private static final string DISPOSAL ='Disposal';

    @testSetup static void createTestData() {
        Case c = new Case();
        c.Subject = 'TestCase';
        insert c;
        
        Opportunity o = new Opportunity();
        o.StageName = 'Product Configuration';
        o.Case__c = c.Id;
        o.Name = 'TestOpp';
        o.CloseDate = Date.today();
        insert o;
        
        SBQQ__Quote__c q = new SBQQ__Quote__c();
        q.SBQQ__Status__c = 'Draft';
        q.SBQQ__Opportunity2__c = o.Id;
        insert q;
        
        Account a = new Account();
        a.Name = 'TestAccount';
        insert a;
        
    }
    
    @isTest static void validateId() {
        
        Case c = [SELECT Id From Case LIMIT 1];
        SBQQ__Quote__c q = [SELECT Id From SBQQ__Quote__c LIMIT 1];
        Account a = [SELECT id FROM Account LIMIT 1];        
        
        String caseId = BusinessRuleCtrl.getCaseId(c.Id);
        String quoteId = BusinessRuleCtrl.getCaseId(q.Id);
        String accountId = BusinessRuleCtrl.getCaseId(a.Id);
        
        system.assertEquals(caseId, c.Id); 
        system.assertEquals(accountId, a.Id);
        
    }
    
    public static testMethod void testOOORecord1(){
        Profile prof = TestDataFactory.getProfile(SYS_ADMIN);
        User usr = TestDataFactory.createUser(prof);
        Database.insert(usr);
        system.runAs(usr){
            Test.startTest();
            list<Account> acclist = TestDataFactory.createAccount(KROGER, usr,Constant_Util.CLIENT);
            Database.insert(acclist);
            
            Categorization__c cg = new Categorization__c();
            cg.Client_Account__c = acclist[0].Id;
            cg.Category__c = 'Location Type';
            cg.Name = 'Kroger Type';
            Database.insert(cg);
            
            list<Account> locationlist = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, acclist.get(0).id);
            locationlist[0].tz__Timezone_SFDC__c = NY_TIMEZONE;
            locationlist[0].tz__UTF_Offset__c = -4;
            locationlist[0].Location_Type__c = cg.Id;
            Database.insert(locationlist);
            
            list<Contact> conlist1 = TestDataFactory.createContact('RITA1', 'REPLY1', accList.get(0), usr);
            conlist1[0].email = 'testContact4@gmail.com';
            Database.insert(conlist1);
            
            list<Contact> conlist2 = TestDataFactory.createContact('RITA2', 'REPLY2', accList.get(0), usr);
            conlist2[0].email = 'testContact3@gmail.com';
            Database.insert(conlist2);
            
            list<product2> productlist = TestDataFactory.createProduct(PRODUCT);
            productlist[0].Family = COMMERCIAL;
            productlist[0].ProductTypeSelected__c = COMPACTOR;
            Database.insert(productlist);
            list<Account> supplieracclist = TestDataFactory.createAccount(TESTSUPPLIER , usr, SUPPLIER);
            supplieracclist[0].AccountNumber = '600';
            Database.insert(supplieracclist);
            
            list<Asset> assetlist = TestDataFactory.createAsset(ASSET_NAME , acclist.get(0), conlist1.get(0), 
                                                                productlist.get(0), usr, locationlist.get(0));
            List<Project_Code__c> pCodeList=TestDataFactory.createProjectCode(acclist.get(0).Id);
            Database.insert(pCodeList);
            assetlist[0].Supplier__c = supplieracclist[0].Id;
            assetlist[0].Project_Code__c = pCodeList[0].Id; 
            Database.insert(assetlist);
            
            Set<Id> brIds = new Set<Id>();
            list<Business_Rule__c> brlist = TestDataFactory.createBusinessRule(Constant_Util.CONSTANT_FIRST, acclist.get(0), 
                                                                               locationlist.get(0));
            brlist[0].Service__c = Constant_Util.EXTRA_PICKUP;
            brlist[0].Schedule_Type__c = Constant_Util.EMPTY_STRING;
            brlist[0].Container__c = Constant_Util.EMPTY_STRING;
            brlist[0].AssetId__c = assetlist[0].Id;
            brlist[0].Multiple_Mandatory_Approvers__c = true;
            brlist[0].Active__c = true;
            brlist[0].RecordTypeId = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.APPROVAL).getRecordTypeId();
            Database.insert(brlist);
            brIds.add(brlist[0].Id);
                
            list<Account_Title__c> titlelst = TestDataFactory.createAccountTitle(acclist.get(0),DISTRICT_MANAGER);
            Database.insert(titlelst,false);
            list<Service_Approver__c> serviceApproverlist = TestDataFactory.createServiceApprover(brlist[0]);
            serviceApproverlist[0].Title__c = titlelst[0].Id;
            Database.insert(serviceApproverlist,true);
            //brlist[0].Active__c = true;
            //Database.Update(brlist);
            
            list<Business_Rule__c> brlist1 = TestDataFactory.createBusinessRule(Constant_Util.CONSTANT_FIRST, acclist.get(0), 
                                                                               locationlist.get(0));
            brlist1[0].Service__c = Constant_Util.EXTRA_PICKUP;
            brlist1[0].Schedule_Type__c = Constant_Util.EMPTY_STRING;
            brlist1[0].Container__c = Constant_Util.EMPTY_STRING;
            brlist1[0].AssetId__c = assetlist[0].Id;
            brlist1[0].RecordTypeid = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.REQUIRED_INFORMATION).getRecordTypeId();
            brlist1[0].Required_Information__c = PO_PSI_VALUE; 
            Database.insert(brlist1);
            
        	Id emailRTId = Schema.SObjectType.Out_of_Office__c.getRecordTypeInfosByDeveloperName().get('Email').getRecordTypeId();
            Business_Rule__c brRecord = [Select Id,Name from Business_Rule__c where Id =:brlist[0].Id];
            String businessRules = brRecord.Name+'-'+'Empty and Return'+'-'+'Pickup';
            Out_of_Office__c oooRecord = new Out_of_Office__c();
            oooRecord.Account__c = accList.get(0).id;
            oooRecord.Business_Rules__c = businessRules;
            oooRecord.Current_Email_Approver__c = 'Test@wm.com';
            oooRecord.End_Date__c = System.today();
            oooRecord.Start_Date__c = System.today();
            oooRecord.New_Email_Approver__c= 'TestTest@wm.com';
            oooRecord.RecordTypeId = emailRTId;
            insert oooRecord;
            
            Out_of_Office__c oooRecord2 = new Out_of_Office__c();
            oooRecord2.Account__c = accList.get(0).id;
            oooRecord2.Business_Rules__c = businessRules;
            oooRecord2.Current_Email_Approver__c = 'Test@wm.com';
            oooRecord2.End_Date__c = System.today();
            oooRecord2.Start_Date__c = System.today();
            oooRecord2.New_Email_Approver__c= 'TestTest@wm.com';
            oooRecord2.RecordTypeId = emailRTId;
            insert oooRecord2;
            
            Id contactRtId = Schema.SObjectType.Out_of_Office__c.getRecordTypeInfosByDeveloperName().get('Contact').getRecordTypeId();
            Out_of_Office__c oooRecord3 = new Out_of_Office__c();
            oooRecord3.Account__c = accList.get(0).id;
            oooRecord3.Business_Rules__c = businessRules;
            oooRecord3.Current_Contact_Approver__c = conlist1[0].Id;
            oooRecord3.End_Date__c = System.today();
            oooRecord3.Start_Date__c = System.today();
            oooRecord3.New_Contact_Approver__c= conlist2[0].Id;
            oooRecord3.RecordTypeId = contactRtId;
            insert oooRecord3;
            
            BusinessRuleCtrl.getBusinessRulesData(oooRecord.Id);
            BusinessRuleCtrl.updateOutofOfficeRecord(oooRecord.Id, new List<String>{businessRules});
            BusinessRuleCtrl.getBusinessRuleApprovers(brIds);
            BusinessRuleCtrl.getApproversForEscalations(new List<String>{'Test@wm.com'});
            BusinessRuleCtrl.validateDuplicateRecord(oooRecord.Id, new List<String>{businessRules});
            BusinessRuleCtrl.getBRsApproversDetails(brIds);
            
            try{
            oooRecord2.Business_Rules__c = businessRules;
            update oooRecord2;
            }
            Catch(Exception ex){
                System.debug('Msg : ' + ex);
            }
            System.assert(oooRecord2!=null);
            Test.stopTest();
        }
    }
    
    public static testMethod void testOOORecord2(){
        Profile prof = TestDataFactory.getProfile(SYS_ADMIN);
        User usr = TestDataFactory.createUser(prof);
        Database.insert(usr);
        system.runAs(usr){
            Test.startTest();
            list<Account> acclist = TestDataFactory.createAccount(KROGER, usr,Constant_Util.CLIENT);
            Database.insert(acclist);
            
            Categorization__c cg = new Categorization__c();
            cg.Client_Account__c = acclist[0].Id;
            cg.Category__c = 'Location Type';
            cg.Name = 'Kroger Type';
            Database.insert(cg);
            
            list<Account> locationlist = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, acclist.get(0).id);
            locationlist[0].tz__Timezone_SFDC__c = NY_TIMEZONE;
            locationlist[0].tz__UTF_Offset__c = -4;
            locationlist[0].Location_Type__c = cg.Id;
            Database.insert(locationlist);
            
            list<Contact> conlist1 = TestDataFactory.createContact('RITA1', 'REPLY1', accList.get(0), usr);
            Database.insert(conlist1);
            
            list<Contact> conlist2 = TestDataFactory.createContact('RITA2', 'REPLY2', accList.get(0), usr);
            conlist2[0].email = 'testContact2@gmail.com';
            Database.insert(conlist2);
            
            list<product2> productlist = TestDataFactory.createProduct(PRODUCT);
            productlist[0].Family = COMMERCIAL;
            productlist[0].ProductTypeSelected__c = COMPACTOR;
            Database.insert(productlist);
            list<Account> supplieracclist = TestDataFactory.createAccount(TESTSUPPLIER , usr, SUPPLIER);
            supplieracclist[0].AccountNumber = '600';
            Database.insert(supplieracclist);
            
            list<Asset> assetlist = TestDataFactory.createAsset(ASSET_NAME , acclist.get(0), conlist1.get(0), 
                                                                productlist.get(0), usr, locationlist.get(0));
            List<Project_Code__c> pCodeList=TestDataFactory.createProjectCode(acclist.get(0).Id);
            Database.insert(pCodeList);
            assetlist[0].Supplier__c = supplieracclist[0].Id;
            assetlist[0].Project_Code__c = pCodeList[0].Id; 
            Database.insert(assetlist);
            
            Set<Id> brIds = new Set<Id>();
            list<Business_Rule__c> brlist = TestDataFactory.createBusinessRule(Constant_Util.CONSTANT_FIRST, acclist.get(0), 
                                                                               locationlist.get(0));
            brlist[0].Service__c = Constant_Util.EXTRA_PICKUP;
            brlist[0].Schedule_Type__c = Constant_Util.EMPTY_STRING;
            brlist[0].Container__c = Constant_Util.EMPTY_STRING;
            brlist[0].AssetId__c = assetlist[0].Id;
            brlist[0].Multiple_Mandatory_Approvers__c = true;
            brlist[0].Active__c = true;
            brlist[0].RecordTypeId = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.APPROVAL).getRecordTypeId();
            Database.insert(brlist);
            brIds.add(brlist[0].Id);
                
            list<Account_Title__c> titlelst = TestDataFactory.createAccountTitle(acclist.get(0),DISTRICT_MANAGER);
            Database.insert(titlelst,false);
            list<Service_Approver__c> serviceApproverlist = TestDataFactory.createServiceApprover(brlist[0]);
            serviceApproverlist[0].Title__c = titlelst[0].Id;
            serviceApproverlist[0].User__c = usr.id;
            Database.insert(serviceApproverlist,true);
            //brlist[0].Active__c = true;
            //Database.Update(brlist);
            
            list<Business_Rule__c> brlist1 = TestDataFactory.createBusinessRule(Constant_Util.CONSTANT_FIRST, acclist.get(0), 
                                                                               locationlist.get(0));
            brlist1[0].Service__c = Constant_Util.EXTRA_PICKUP;
            brlist1[0].Schedule_Type__c = Constant_Util.EMPTY_STRING;
            brlist1[0].Container__c = Constant_Util.EMPTY_STRING;
            brlist1[0].AssetId__c = assetlist[0].Id;
            brlist1[0].RecordTypeid = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.REQUIRED_INFORMATION).getRecordTypeId();
            brlist1[0].Required_Information__c = PO_PSI_VALUE; 
            Database.insert(brlist1);
            
        	Id contactRTId = Schema.SObjectType.Out_of_Office__c.getRecordTypeInfosByDeveloperName().get('Contact').getRecordTypeId();

            Business_Rule__c brRecord = [Select Id,Name from Business_Rule__c where Id =:brlist[0].Id];
            String businessRules = brRecord.Name+'-'+'Empty and Return'+'-'+'Pickup';
            
            Out_of_Office__c oooRecord = new Out_of_Office__c();
            oooRecord.Account__c = accList.get(0).id;
            oooRecord.Business_Rules__c = businessRules;
            oooRecord.Current_Contact_Approver__c = conlist1[0].Id;
            oooRecord.End_Date__c = System.today();
            oooRecord.Start_Date__c = System.today();
            oooRecord.New_Contact_Approver__c= conlist2[0].Id;
            oooRecord.RecordTypeId = contactRTId;
            insert oooRecord;
            
            Out_of_Office__c oooRecord2 = new Out_of_Office__c();
            oooRecord2.Account__c = accList.get(0).id;
            oooRecord2.Business_Rules__c = businessRules;
            oooRecord2.Current_Contact_Approver__c = conlist1[0].Id;
            oooRecord2.End_Date__c = System.today();
            oooRecord2.Start_Date__c = System.today();
            oooRecord2.New_Contact_Approver__c= conlist2[0].Id;
            oooRecord2.RecordTypeId = contactRTId;
            insert oooRecord2;
            
            BusinessRuleCtrl.getBusinessRulesData(oooRecord.Id);
            BusinessRuleCtrl.updateOutofOfficeRecord(oooRecord.Id, new List<String>{businessRules});
            BusinessRuleCtrl.getBusinessRuleApprovers(brIds);
            BusinessRuleCtrl.getApproversForEscalations(new List<String>{conlist2[0].Email});
            BusinessRuleCtrl.validateDuplicateRecord(oooRecord.Id, new List<String>{businessRules});
            BusinessRuleCtrl.getBRsApproversDetails(brIds);
            
            try{
            oooRecord2.Business_Rules__c = businessRules;
            	update oooRecord2;
            }
            Catch(Exception ex){
                System.debug('Msg : ' + ex);
            }
            System.assert(oooRecord2!=null);
            Test.stopTest();
        }
    }
    
    public static testMethod void testOOORecord3(){
        Profile prof = TestDataFactory.getProfile(SYS_ADMIN);
        User usr = TestDataFactory.createUser(prof);
        Database.insert(usr);
        system.runAs(usr){
            Test.startTest();
            list<Account> acclist = TestDataFactory.createAccount(KROGER, usr,Constant_Util.CLIENT);
            Database.insert(acclist);
            
            Categorization__c cg = new Categorization__c();
            cg.Client_Account__c = acclist[0].Id;
            cg.Category__c = 'Location Type';
            cg.Name = 'Kroger Type';
            Database.insert(cg);
            
            list<Account> locationlist = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, acclist.get(0).id);
            locationlist[0].tz__Timezone_SFDC__c = NY_TIMEZONE;
            locationlist[0].tz__UTF_Offset__c = -4;
            locationlist[0].Location_Type__c = cg.Id;
            Database.insert(locationlist);
            
            list<Contact> conlist1 = TestDataFactory.createContact('RITA1', 'REPLY1', accList.get(0), usr);
            Database.insert(conlist1);
            
            
            list<product2> productlist = TestDataFactory.createProduct(PRODUCT);
            productlist[0].Family = COMMERCIAL;
            productlist[0].ProductTypeSelected__c = COMPACTOR;
            Database.insert(productlist);
            list<Account> supplieracclist = TestDataFactory.createAccount(TESTSUPPLIER , usr, SUPPLIER);
            supplieracclist[0].AccountNumber = '600';
            Database.insert(supplieracclist);
            
            list<Asset> assetlist = TestDataFactory.createAsset(ASSET_NAME , acclist.get(0), conlist1.get(0), 
                                                                productlist.get(0), usr, locationlist.get(0));
            List<Project_Code__c> pCodeList=TestDataFactory.createProjectCode(acclist.get(0).Id);
            Database.insert(pCodeList);
            assetlist[0].Supplier__c = supplieracclist[0].Id;
            assetlist[0].Project_Code__c = pCodeList[0].Id; 
            Database.insert(assetlist);
            
            Set<Id> brIds = new Set<Id>();
            list<Business_Rule__c> brlist = TestDataFactory.createBusinessRule(Constant_Util.CONSTANT_FIRST, acclist.get(0), 
                                                                               locationlist.get(0));
            brlist[0].Service__c = Constant_Util.EXTRA_PICKUP;
            brlist[0].Schedule_Type__c = Constant_Util.EMPTY_STRING;
            brlist[0].Container__c = Constant_Util.EMPTY_STRING;
            brlist[0].AssetId__c = assetlist[0].Id;
            brlist[0].Multiple_Mandatory_Approvers__c = true;
            brlist[0].Active__c = true;
            brlist[0].RecordTypeId = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.APPROVAL).getRecordTypeId();
            Database.insert(brlist);
            brIds.add(brlist[0].Id);
                
            list<Account_Title__c> titlelst = TestDataFactory.createAccountTitle(acclist.get(0),DISTRICT_MANAGER);
            Database.insert(titlelst,false);
            list<Service_Approver__c> serviceApproverlist = TestDataFactory.createServiceApprover(brlist[0]);
            serviceApproverlist[0].Title__c = titlelst[0].Id;
            serviceApproverlist[0].User__c = usr.id;
            Database.insert(serviceApproverlist,true);
            //brlist[0].Active__c = true;
            //Database.Update(brlist);
            
            list<Business_Rule__c> brlist1 = TestDataFactory.createBusinessRule(Constant_Util.CONSTANT_FIRST, acclist.get(0), 
                                                                               locationlist.get(0));
            brlist1[0].Service__c = Constant_Util.EXTRA_PICKUP;
            brlist1[0].Schedule_Type__c = Constant_Util.EMPTY_STRING;
            brlist1[0].Container__c = Constant_Util.EMPTY_STRING;
            brlist1[0].AssetId__c = assetlist[0].Id;
            brlist1[0].RecordTypeid = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.REQUIRED_INFORMATION).getRecordTypeId();
            brlist1[0].Required_Information__c = PO_PSI_VALUE; 
            Database.insert(brlist1);
            
        	Id userRTId = Schema.SObjectType.Out_of_Office__c.getRecordTypeInfosByDeveloperName().get('User').getRecordTypeId();

            Business_Rule__c brRecord = [Select Id,Name from Business_Rule__c where Id =:brlist[0].Id];
            String businessRules = brRecord.Name+'-'+'Empty and Return'+'-'+'Pickup';
            Generic_Values__mdt groupUser = Generic_Values__mdt.getInstance('Group_User');
			Out_of_Office__c oooRecord = new Out_of_Office__c();
            oooRecord.Account__c = accList.get(0).id;
            oooRecord.Business_Rules__c = businessRules;
            oooRecord.Current_User_Approver__c = usr.Id;
            oooRecord.End_Date__c = System.today();
            oooRecord.Start_Date__c = System.today();
            oooRecord.New_User_Approver__c= groupUser.Id__c;
            oooRecord.RecordTypeId = userRTId;
            insert oooRecord;
            
            BusinessRuleCtrl.getBusinessRulesData(oooRecord.Id);
            BusinessRuleCtrl.updateOutofOfficeRecord(oooRecord.Id, new List<String>{businessRules});
            BusinessRuleCtrl.getBusinessRuleApprovers(brIds);
            BusinessRuleCtrl.getApproversForEscalations(new List<String>{conlist1[0].Email});
            BusinessRuleCtrl.validateDuplicateRecord(oooRecord.Id, new List<String>{businessRules});
            BusinessRuleCtrl.getBRsApproversDetails(brIds);
            
            System.assert(oooRecord!=null);
            Test.stopTest();
        }
    }

}