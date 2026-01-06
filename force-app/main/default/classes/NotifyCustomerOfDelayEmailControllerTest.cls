/***********************************

@description : Test class for NotifyCustomerOfDelayEmailController
@Author : Rajan Sajani
/********************************/
@isTest(seeAllData = false)
public class NotifyCustomerOfDelayEmailControllerTest {
    
    private static final string SYS_ADMIN = 'System Administrator';
    private static final string SPECIAL_INS ='Test Special Instructions';
    private static final string CHANNEL_INFO ='Test Channel Instructions';
    private static final string OTHER ='Other';
    private static final string TEST_NAME ='Test';
    private static final string NUMBER_145 ='145';
    private static final string SLA = 'Test SLA Instructions';
    private static final String LOCATION = 'Location';
    private static final String CONTACT = 'Contact';
    private static final string COMMERCIAL = 'Commercial';
    private static final string SCHEDULED ='Scheduled';
    private static final string REPAIRS = 'Repairs';
    private static final string COMPACTOR = 'COMPACTOR';
        
    
    private static final string INTERRUPTION = 'Interruption';
    private static final string STOP_SERVICE = 'Stop Service';
    private static final string CAM = 'CAM';
    private static final string SERVICE_REQUEST_CASE = 'Service Request Case';
    private static final string ADD = 'Add';
    private static final string EQUIPMENT = 'Equipment';
    private static final string COMPACTOR1 = 'Compactor';
    private static final string REPAIR_CASE = 'Repair Case';
    private static final string OPERABLE = 'Operable';
    private static final string COMPACTOR_ACCESSORIES = 'Compactor Accessories';
    
    
    @testSetup static void setup() {
        Profile adminProfile = TestDataFactory.getProfile(SYS_ADMIN);
        User usr = TestDataFactory.createUser(adminProfile);
        Database.insert(usr);  
        system.runAs(usr){
            list<Account> acclist = TestDataFactory.createAccount('test', usr,'Client');
            Database.insert(acclist);
            list<Account> locationlist = TestDataFactory.createLocation('Location', usr, acclist.get(0).id);
            Database.insert(locationlist);
            list<Contact> conlist = TestDataFactory.createContact('first', 'last', acclist.get(0), usr);
            conlist[0].Email = 'abc@test.com';
            Database.insert(conlist);
            list<product2> productlist = TestDataFactory.createProduct('test');
            productlist[0].Family = Constant_Util.COMMERCIAL;
            Database.insert(productlist);
            list<Account> supplieracclist = TestDataFactory.createAccount('testsupplier', usr,'Vendor');
            Database.insert(supplieracclist);
            String roles = Constant_Util.ROLL_OFF_ESCALATION_DISPATCH_ROLE + ';' + Constant_Util.COMMERCIAL_ESCALATION_DISPATCH_ROLE;
            AccountContactRelation accContactList = TestDataFactory.returnAccConRel(supplieracclist.get(0).id, conlist.get(0), roles);
            Database.insert(accContactList);
            list<Asset> assetlist = TestDataFactory.createAsset('first', acclist.get(0), conlist.get(0), 
                                                                productlist.get(0), usr, locationlist.get(0));
            assetlist[0].Supplier__c = supplieracclist[0].Id;
            assetlist[0].Frequency__c = 'Weekly';
            assetlist[0].Monday_Frequency__c = '1';
            assetlist[0].Tuesday_Frequency__c = '1';
            assetlist[0].Thursday_Frequency__c = '1';
            assetlist[0].Friday_Frequency__c = '1';
            assetlist[0].Saturday_Frequency__c = '1';
            assetlist[0].Sunday_Frequency__c = '1';
            assetlist[0].Wednesday_Frequency__c = '1';
            assetlist[0].Monday_Frequency__c = '1';
            assetlist[0].Occurrence_Type__c = 'On-Call';
            Database.insert(assetlist);
            list<Case> caselist = TestDataFactory.createCase('first', acclist.get(0), conlist.get(0), 
                                                             usr, locationlist.get(0), assetlist.get(0));
            caselist[0].AccountId = locationlist[0].Id;
            caselist[0].Case_Type__c = 'Pickup';
            caselist[0].Status = Constant_Util.OPEN;
            caselist[0].RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constant_Util.PICK_CASE).getRecordTypeId();
            caselist[0].Case_Sub_Type__c = 'Empty and Return';
            caselist[0].Proposed_Service_Date__c = Date.today();
            caselist[0].Service_Date__c = date.today();
            Database.insert(caselist);
            
            list<Task> tasklist = TestDataFactory.createTask(caselist.get(0).id, usr);
            taskList[0].RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Follow_Up').getRecordTypeId();
            taskList[0].Process__c = 'Notify Customer of Delay';
            Database.insert(tasklist);                  
      } 
    }
    
        @isTest static void getNotifyEmailTest(){
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
         Case caseRec = [SELECT id,Contact_Name__c,Case_Type__c,Case.AssetId,Case.Asset.Occurrence_Type_Formula__c,Customer_Code__c,Case_Sub_Type__c,Proposed_Service_Date__c,Case.Asset.wednesday_Frequency__c,Case.Asset.Thursday_Frequency__c,Case.Asset.Friday_Frequency__c,Case.Asset.Saturday_Frequency__c,Case.Asset.Sunday_Frequency__c,Case.Asset.Tuesday_Frequency__c,Case.Asset.Monday_Frequency__c,Case.Asset.Occurrence__c,Service_Date__c,Reference_Number__c,Case.Asset.Name,Case.Asset.Equipment_Size__c,Case.Account.ShippingCity,Case.Asset.Container_Position__c,Case.Asset.Occurrence_Type__c,Case.Asset.Schedule_Type__c,Case.Asset.Frequency__c,Case.Asset.Schedule__c,Case.Asset.Material_Type__c,Case.Account.Location_Code__c,Case.Account.ShippingStreet,Case.Account.ShippingState,Case.Account.ShippingPostalCode,Case.Account.ShippingCountry from case limit 1];
        asset assetRec = [Select id from Asset limit 1];
        assetRec.Frequency__c = 'Daily';
        system.runAs(currentuser){
       // quoteData = [SELECT Id, SBQQ__Account__r.AccountNumber,SBQQ__Account__r.ParentId,  SBQQ__Account__r.Id, SBQQ__ShippingStreet__c, SBQQ__ShippingCity__c, SBQQ__ShippingCountry__c, SBQQ__ShippingState__c, SBQQ__ShippingPostalCode__c ,SBQQ__Status__c
           //                 FROM SBQQ__Quote__c limit 1];
           // quoteData.SBQQ__ShippingCity__c = 'Constant';
           
            Test.startTest();
           // Database.update(quoteData); 
            NotifyCustomerOfDelayEmailController gd =new NotifyCustomerOfDelayEmailController();
           gd.objCase = caseRec;
            gd.getCaseFields();
            NotifyCustomerOfDelayEmailController gd2 =new NotifyCustomerOfDelayEmailController();
           gd2.objCase = caseRec;
            assetRec.Frequency__c = 'Daily';
            update assetRec;
            gd2.getCaseFields();
            
            Test.stopTest();
            }   
        }    
}