/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class PotentialDeliveryDateTest {

    @testSetup static void setup() {
        Profile p = TestDataFactory.getProfile('System Administrator');         
        User usr = TestDataFactory.createUser(p);
        usr.Bypass_Validation__c = true;
        usr.Genesys_Enabled__c = false;
        usr.FirstName = 'testuser#9999';
        Database.insert(usr); 
        System.runAs(usr){
        list<Account> acclist = TestDataFactory.createAccount(Constant_Util.KEYWORD_TEST, usr,'Client');
            acclist[0].AccountNumber='8';
            Database.insert(acclist);

        //create location
        list<Account> HMDLocation = TestDataFactory.createLocation('HMD000601', usr, acclist.get(0).id);
        HMDLocation.get(0).tz__Timezone_SFDC__c = 'America/New_York';
        Database.insert(HMDLocation);
            //create location
        list<Account> HMDLocation1 = TestDataFactory.createLocation('HMD0006011', usr, acclist.get(0).id);
        HMDLocation1.get(0).tz__Timezone_SFDC__c = 'America/New_York';
        Database.insert(HMDLocation1);

        //create product
        list<product2> productlist = TestDataFactory.createProduct(Constant_Util.KEYWORD_TEST);
            productlist[0].ProductTypeSelected__c = 'COMPACTOR';
            productlist[0].Family = 'Commercial';
            
            Product2 container = new Product2(Name = 'Open Top', Family = 'Equipment', ProductCode = 'OT');
            productlist.add(container);
            insert productlist;

        List<Entitlement> entList = new List<Entitlement>();

        //Schedule and Container Details
        Entitlement ent = new Entitlement();
        ent.name = 'IVR Testing';
        ent.Status__c = 'Approved';
        ent.Container__c = 'Open Top';
        ent.Request_Type__c = 'New Service';
        ent.AccountId = acclist[0].id;
        ent.Location__c = HMDLocation[0].id;
        ent.StartDate = System.today();
        ent.Service__c = 'Temporary';
        ent.Schedule_Type__c= 'Temporary';
        ent.Before_After__c= 'After';
        ent.Call_Time__c= '15:00';
        entList.add(ent);
        Database.insert( entList);

        }
    }
    @isTest static void entitlementFetchWithPriority3(){
        User usr = [Select id, FirstName from User WHERE FirstName =: 'testuser#9999' AND isActive = TRUE limit 1];
        System.runAs(usr){
            RestRequest request = new RestRequest();
            RestResponse res = new RestResponse();
            request.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
            res.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
            // Set request properties
            request.requestUri = '/services/apexrest/PotentialDeliveryDate/V1/*';
            request.httpMethod = 'POST';
            String jsonMsg = '{"locationCode":"HMD000601","duration":"Temporary","containerCode":"OT","caseType":"New Service"}';
            request.requestBody = Blob.valueof(jsonMsg);
            RestContext.request = request;
            RestContext.response = res;
            Test.startTest();
            Code_Switch__c codeSwitchSLA = QuoteTestDataFactory.createCodeSwitch('SLA Logic Switch',false);
            Insert codeSwitchSLA;
            PotentialDeliveryDate.getData();
            Test.stopTest();
        }
    }
    @isTest static void entitlementFetchWithPriority4(){
        User usr = [Select id, FirstName from User WHERE FirstName =: 'testuser#9999' AND isActive = TRUE limit 1];
        Entitlement ent = [select id,Container__c from Entitlement limit 1];
        ent.Container__c ='';
        update ent;
        system.debug(ent);
        System.runAs(usr){
            RestRequest request = new RestRequest();
            RestResponse res = new RestResponse();
            request.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
            res.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
            // Set request properties
            request.requestUri = '/services/apexrest/PotentialDeliveryDate/V1/*';
            request.httpMethod = 'POST';
            String jsonMsg = '{"locationCode":"HMD000601","duration":"Temporary","containerCode":"OT","caseType":"New Service"}';
            request.requestBody = Blob.valueof(jsonMsg);
            RestContext.request = request;
            RestContext.response = res;
            Test.startTest();
            Code_Switch__c codeSwitchSLA = QuoteTestDataFactory.createCodeSwitch('SLA Logic Switch',true);
            Insert codeSwitchSLA;
            PotentialDeliveryDate.getData();
            Test.stopTest();
        }
    }
    @isTest static void fetchWithIndustrySLA(){
        User usr = [Select id, FirstName from User WHERE FirstName =: 'testuser#9999' AND isActive = TRUE limit 1];
        System.runAs(usr){
            RestRequest request = new RestRequest();
            RestResponse res = new RestResponse();
            request.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
            res.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
            // Set request properties
            request.requestUri = '/services/apexrest/PotentialDeliveryDate/V1/*';
            request.httpMethod = 'POST';
            String jsonMsg = '{"locationCode":"HMD0006011","duration":"Temporary","containerCode":"OT","caseType":"New Service"}';
            request.requestBody = Blob.valueof(jsonMsg);
            RestContext.request = request;
            RestContext.response = res;
            Test.startTest();
            Code_Switch__c codeSwitchSLA = QuoteTestDataFactory.createCodeSwitch('SLA Logic Switch',false);
            Insert codeSwitchSLA;
            PotentialDeliveryDate.getData();
            Test.stopTest();
        }
    }
}
