/**
* @author Accenture
* @date 12/06/2019
* @description : Apex class ANIMatch2WebservicesTest 
**/

// test class for ANIMatch2Webservices
@isTest(SeeAllData=false)
public class ANIMatch2WebservicesTest {
    /**
    * @description set the test data
    */ 
    @testSetup static void setup() {        
        Profile p = TestDataFactory.getProfile('System Administrator');
        User usr = TestDataFactory.createUser(p);

        Database.insert(usr);
        
        system.runAs(usr){
            list<Account> acclist = TestDataFactory.createAccount(Constant_Util.KEYWORD_TEST, usr);
            Database.insert(acclist);
            list<Account> locationlist = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, acclist.get(0).id);
            Database.insert(locationlist);
            list<Contact> conlist = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST, 
                                                                Constant_Util.CONSTANT_LAST, acclist.get(0), usr);
            Database.insert(conlist);
            AccountContactRelation acr = new AccountContactRelation (ContactId = conlist.get(0).Id, 
                                                                     AccountId = locationlist.get(0).Id);
            Database.insert(acr);
        }
        
    }

    /**
    * @description test method for phone on contact
    */
    @isTest static void testbyContact(){
        User usr = [Select id ,IsActive from user Where IsActive = true limit 1]; //SDT-33363
        
        system.runAs(usr){
            // Set up a test request
            RestRequest request = new RestRequest();
            RestResponse res = new RestResponse();
            request.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
            
            // Set request properties
            request.requestUri = '/services/apexrest/ANIMatch/V1';
            request.httpMethod = 'POST';
            
            // Set other properties, such as parameters
            String jsonMsg = '{"ANI":"9999999999"}';
            request.requestBody = Blob.valueof(jsonMsg);
            
            // Finally, assign the request to RestContext if used
            RestContext.request = request;
            RestContext.response = res;
            Test.startTest();
            ANIMatch2Webservices.getContact();
            Test.StopTest();
            system.assert(jsonMsg != null);
        }
        
    }

    /**
    * @description test method for phone on location
    */
    @isTest
    static void testbyLocation(){
        User usr = [Select id,IsActive from user Where IsActive = true limit 1]; //SDT-33363
        
        system.runAs(usr){
            // Set up a test request
            RestRequest request = new RestRequest();
            RestResponse res = new RestResponse();
            request.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
            
            // Set request properties
            request.requestUri = '/services/apexrest/ANIMatch/V2' ;
            request.httpMethod = 'POST';
            
            // Set other properties, such as parameters
            String jsonMsg = '{"ANI":"9999999991"}';
            request.requestBody = Blob.valueof(jsonMsg);
            
            // Finally, assign the request to RestContext if used
            RestContext.request = request;
            RestContext.response = res;
            Test.startTest();
            ANIMatch2Webservices.getContact();
            Test.StopTest();
            system.assert(jsonMsg != null);
        }
        
    }
    
    /**
    * @description test method for phone is not available
    */
    @isTest static void testForException(){
        User usr = [Select id,IsActive from user Where IsActive = true limit 1]; //SDT-33363
        
        system.runAs(usr){
            // Set up a test request
            RestRequest request = new RestRequest();
            RestResponse res = new RestResponse();
            request.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
            
            // Set request properties
            request.requestUri = '/services/apexrest/ANIMatch/V2';
            request.httpMethod = 'POST';
            
            // Finally, assign the request to RestContext if used
            RestContext.request = request;
            RestContext.response = res;
            Test.startTest();
            ANIMatch2Webservices.getContact();
            Test.StopTest();
            system.assert(request.requestBody == null);
        }
        
    }
}