@isTest
public with sharing class AAV_AvailbilityAppHelperTest {
    private static final string SYS_ADMIN = 'System Administrator';
    @testSetup static void setup() {
        Profile adminProfile = TestDataFactory.getProfile(SYS_ADMIN);
        
        User usr = TestDataFactory.createUser(adminProfile);
        Database.insert(usr);  
        
        User bypassuser = TestDataFactory.createUser(adminProfile);
        bypassuser.Bypass_Validation__c = true;
        insert bypassuser;
        system.runAs(usr)
        { 
            List<Opportunity> oppList = new List<Opportunity>();
            List<SBQQ__Quote__c> quoteList= new List<SBQQ__Quote__c>();
            List<Product2> prdList = new List<Product2>();    
            list<Account> acclist = new List<Account>();

            Account accParent = new Account(Name = 'Parent Account', phone = '9999999999', OwnerId = usr.id, AccountNumber='5678',
             RecordTypeid = TestDataFactory.getRecordType('Client','Account'), IsPricingEligible__c = true); 
            insert accParent;

            Account acc = new Account(Name = Constant_Util.KEYWORD_TEST, phone = '9999999999', OwnerId = usr.id, AccountNumber='1234',
                RecordTypeid = TestDataFactory.getRecordType('Client','Account'), IsPricingEligible__c = true, ParentId = accParent.Id, Type ='Location');
            acclist.add(acc);

            Account vendorAcc = new Account(Name = 'Vendor Account', phone = '9999999999', OwnerId = usr.id, AccountNumber='4321',
             RecordTypeid = TestDataFactory.getRecordType('Vendor','Account'));
            acclist.add(vendorAcc);

            Database.insert(acclist);

            list<Account> locationlist = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, acclist.get(0).id);
            locationlist[0].tz__Timezone_SFDC__c = 'America/Chicago';
            locationlist[0].IsPricingEligible__c = true;
            Database.insert(locationlist);

            list<Entitlement> entitlements= TestDataFactory.createEntitlement('',locationlist[0]);
            entitlements[0].Request_Type__c = 'New Service';
            entitlements[0].Service__c ='Permanent';
            entitlements[0].Schedule_Type__c ='Permanent';
            Database.insert(entitlements);
            
            list<Contact> conlist = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST,Constant_Util.CONSTANT_LAST, acclist.get(0), usr);
            Database.insert(conlist);

            //Inserting Account Position (Location_Position)
            Account_Position__c accLocPosition = new Account_Position__c(AccountId__c = acclist[0].Id,
            Container_Position__c = 'Test 2',
            AlternatePostalCode__c = '1234',
            AlternateCity__c = 'Test City',
            AlternateCountry__c = 'USA',
            AlternateState__c = 'NY',
            AlternateStreet__c = 'Day Hill Road');
            insert accLocPosition;
            //
            AAV_Asset_Availability__c aav = new AAV_Asset_Availability__c(
                AAV_Delivery_Date__c = system.now().date(),
                AAV_Location__c =locationlist[0].Id,
                AAV_Line_of_Business__c = 'Rolloff',
                AAV_Container_Type__c = 'OT',
                AAV_MaterialCode__c ='T',
                AAV_Service_Type__c ='PERM',
                AAV_APIRequestOutput__c ='',
                AAV_isAPIResult__c =false
            );
            insert aav;
        }
    }

    @isTest static void getAvailabilityRecordByIdTest() {
        user currentuser = [select id, Bypass_Validation__c,IsActive from user Where IsActive = true limit 1]; //SDT-33363
        system.runAs(currentuser){
            list<AAV_Asset_Availability__c> availabilityList = [SELECT Id FROM AAV_Asset_Availability__c limit 1];
            if(availabilityList != null && availabilityList.size() > 0){           
                Test.startTest();
                AAV_AvailbilityAppHelper.AvailabilityOutputWrapper wrapper = AAV_AvailbilityAppHelper.getAvailabilityRecordById(availabilityList[0].Id);
                Test.stopTest(); 
                System.assert(wrapper.lineOfBusiness!=null);
            }            
        }
    }
    
    @isTest static void determineSLAForAllContainersTest() {
        user currentuser = [select id, Bypass_Validation__c ,IsActive from user Where IsActive = true limit 1]; //SDT-33363
        Account location =[Select Id ,ParentId from Account where name =:Constant_Util.LOCATION limit 1];
        AAV_AvailbilityAppHelper.SlaCalculationInputWrapper wrapper = new AAV_AvailbilityAppHelper.SlaCalculationInputWrapper();
        wrapper.location = location.Id;
        wrapper.account = location.ParentId;
        wrapper.duration = 'PERM';
        wrapper.productFamily = 'Rolloff';
        wrapper.project = null;
        wrapper.productName = 'Open Top';
        system.runAs(currentuser){
            Test.startTest();
            Date dateCheck = AAV_AvailbilityAppHelper.determineSLAForAllContainers(wrapper);
            Test.stopTest(); 
            System.assert(dateCheck!=null);
        }
    }
    @isTest static void getAccountAddressTest() {
        user currentuser = [select id, Bypass_Validation__c,IsActive from user Where IsActive = true limit 1]; //SDT-33363
        Account location = [Select Id ,ParentId from Account where name =:Constant_Util.LOCATION limit 1];
        system.runAs(currentuser){
            Test.startTest();
            Account acc = AAV_AvailbilityAppHelper.getAccountAddress(location.Id);
            Test.stopTest(); 
            System.assert(acc!=null);
        }
    }
    @isTest static void getAppOutputFieldsTest() {
        user currentuser = [select id, Bypass_Validation__c,IsActive from user Where IsActive = true limit 1]; //SDT-33363
        system.runAs(currentuser){
            Test.startTest();
            list<AAV_Asset_Availability_Output_Field__mdt> aavList = AAV_AvailbilityAppHelper.getAppOutputFields('Outage Data');
            Test.stopTest(); 
            System.assert(aavList!=null);
        }
    }
}