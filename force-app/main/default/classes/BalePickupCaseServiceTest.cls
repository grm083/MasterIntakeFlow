/*************************************************************
@Name: BalePickupCaseServiceTest
@Author: Arvind Kumar
@CreateDate: 31/08/2021
@Description: Test Class for Apex webservice BalePickupCaseService
@UsedBy: SDT-19323 Bale Pickup Service
@URL: /services/apexrest/CreatePickupCase/V1/
**************************************************************/

@isTest
public class BalePickupCaseServiceTest {
    
    
    @testSetup static void setup() {
        Profile p = TestDataFactory.getProfile('System Administrator');        
        User usr = TestDataFactory.createUser(p);
        usr.Acorn_SUser_ID__c = 1000;
        usr.Bypass_Validation__c = true;
        Database.insert(usr);
        
        system.runAs(usr){
            //create account
            list<Account> acclist = TestDataFactory.createAccount(Constant_Util.KEYWORD_TEST, usr,'Client');
            Database.insert(acclist);
            
// Modified for SDT-33437 Start
            list<Case> caselist = new list<Case>();
            Case cs = new Case(Status ='Open', Priority = 'Medium', Origin = 'Phone',OwnerId = usr.id, 
                               Case_Type__c = 'New Service', Case_Sub_Type__c = 'Permanent', Case_Reason__c = 'Existing Location',
                               SlaStartDate = system.today(),Recordtypeid = TestDataFactory.getRecordType('New Service Case','Case'));
            caselist.add(cs);
            insert caselist;
            // Modified for SDT-33437 End
            
            /*create case
            list<Case> cases = TestDataFactory.createNewCase();
            cases[0].Origin = Constant_Util.IVR_Phone;
            insert cases[0];
            
            List<Case> caseObj = [Select Id, CaseNumber,Reference_Number__c,
                                                  Origin,Last_Customer_Interaction_ID__c,Last_Customer_Interaction_Type__c From Case where Id =: cases[0].Id ];*/
            //create location
            //list<Account> locationlist = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, acclist.get(0).id);
            //Database.insert(locationlist);
            
            //create location
            Account accLocation = TestDataFactory.returnLocation(Constant_Util.LOCATION, acclist.get(0).id, usr);
            accLocation.ShippingCountry = 'United States';
            Database.insert(accLocation);
            
            //create contact
            list<Contact> conlist = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST, 
                                                                  Constant_Util.CONSTANT_LAST, acclist.get(0), usr);
            Database.insert(conlist);
            
        }
    }
    
    // /**
    // * @description test method for createBalePickupCase
    // */
    @isTest static void testcreateBalePickupCase(){
        User usr = [Select id , Acorn_SUser_ID__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        
        system.runAs(usr){
            //create Case
            account locAcc = [select Id,Name from Account where RecordType.name = 'Location'];
            Contact contact = [select Id from Contact];
            User usr1 = [Select id , Acorn_SUser_ID__c from User limit 1];
            
            
            // Set up a test request
            RestRequest request = new RestRequest();
            RestResponse res = new RestResponse();
            request.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
            
            // Set request properties
            request.requestUri = '/services/apexrest/CreateBalePickupCase/V1';
            request.httpMethod = 'POST';
            
            // Set other properties, such as parameters
            String jsonMsg = '{"LocationId":"'+locAcc.Id+'","LocationCode":"'+ locAcc.Name+'" ,"AcornSUserId":'+ usr1.Acorn_SUser_ID__c+',"CaseType":"Pickup","ServiceDate": "2019-09-21","Origin": "IVR Phone","ContactId": "'+contact.Id+'"}';
            
            
            request.requestBody = Blob.valueof(jsonMsg);
            
            // Finally, assign the request to RestContext if used
            RestContext.request = request;
            RestContext.response = res;
            Test.startTest();
            BalePickupCaseService.createBalePickupCase();
            Test.stopTest();
            //system.assert(jsonMsg != null);
        }        
    }
    
    /**
* @description test method for createBalePickupCase
*/
    @isTest static void testcreatePickupCase2(){
        User usr = [Select id , Acorn_SUser_ID__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        
        system.runAs(usr){
            //create Case
            account locAcc = [select Id,Name from Account where RecordType.name = 'Location'];
            account clientAcc = [select Id,Name from Account where RecordType.name = 'Client'];
            Contact contact = [select Id from Contact];
            list<Contact> conlist = TestDataFactory.createContact('Unspecified', 
                                                                  locAcc.Name, clientAcc, usr);
            
            Database.insert(conlist);
            
            // Set up a test request
            RestRequest request = new RestRequest();
            RestResponse res = new RestResponse();
            request.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
            
            // Set request properties
            request.requestUri = '/services/apexrest/CreateBalePickupCase/V1';
            request.httpMethod = 'POST';
            
            // Set other properties, such as parameters
            String jsonMsg = '{"LocationId":"'+locAcc.Id+'","LocationCode":"'+ locAcc.Name+'" ,"PO":"PO-12322","PSI":100,"AcornSUserId":'+ usr.Acorn_SUser_ID__c+',"CaseType":"Pickup","Origin": "IVR Phone" }';
            
            
            request.requestBody = Blob.valueof(jsonMsg);
            
            // Finally, assign the request to RestContext if used
            RestContext.request = request;
            RestContext.response = res;
            Test.startTest();
            BalePickupCaseService.createBalePickupCase();
            Test.stopTest();
            //system.assert(jsonMsg != null);
        }        
    }
    
    /**
* @description test method for createBalePickupCase
*/
    @isTest static void testcreatePickupCase3(){
        User usr = [Select id , Acorn_SUser_ID__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        
        system.runAs(usr){
            //create Case
            account locAcc = [select Id,Name from Account where RecordType.name = 'Location'];
            account clientAcc = [select Id,Name from Account where RecordType.name = 'Client'];
            Contact contact = [select Id from Contact];
            list<Contact> conlist = TestDataFactory.createContact('Unspecified', 
                                                                  locAcc.Name, clientAcc, usr);
            Database.insert(conlist);
            
            // Set up a test request
            RestRequest request = new RestRequest();
            RestResponse res = new RestResponse();
            request.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
            
            // Set request properties
            request.requestUri = '/services/apexrest/CreateBalePickupCase/V1';
            request.httpMethod = 'POST';
            
            // Set other properties, such as parameters
            String jsonMsg = '{"LocationId":"'+locAcc.Id+'","ContactId":"'+''+'" ,"PO":"PO-12322","PSI":100,"AcornSUserId":'+ usr.Acorn_SUser_ID__c+',"CaseType":"Pickup","Origin": "IVR Phone" }';
            
            
            request.requestBody = Blob.valueof(jsonMsg);
            
            // Finally, assign the request to RestContext if used
            RestContext.request = request;
            RestContext.response = res;
            Test.startTest();
            BalePickupCaseService.createBalePickupCase();
            Test.stopTest();
            //system.assert(jsonMsg != null);
        }        
    }
    /**
* @description test method for createPickupCase Bad Data
*/
    @isTest static void testcreatePickupCaseBadData(){
        User usr = [Select id , Acorn_SUser_ID__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        
        system.runAs(usr){
            //create Case
            account locAcc = [select Id from Account where RecordType.name = 'Location'];
            Contact contact = [select Id from Contact];
            
            // Set up a test request
            RestRequest request = new RestRequest();
            RestResponse res = new RestResponse();
            request.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
            
            // Set request properties
            request.requestUri = '/services/apexrest/CreateBalePickupCase/V1';
            request.httpMethod = 'POST';
            
            // Set other properties, such as parameters
            String jsonMsg = '{"LocationId":"'+locAcc.Id+'","CaseType":"Pickup, "AcornSUserId":"'+ usr.Acorn_SUser_ID__c+'","Origin": "IVR Phone","ContactId": "'+contact.Id+'"}';
            
            
            request.requestBody = Blob.valueof(jsonMsg);
            
            // Finally, assign the request to RestContext if used
            RestContext.request = request;
            RestContext.response = res;
            Test.startTest();
            BalePickupCaseService.createBalePickupCase();
            Test.stopTest();
            //system.assert(jsonMsg != null);
        }
    }
    
    // /**
    // * @description test method for createPickupCase Bad Data
    // */
    @isTest static void testcreatePickupCaseBadData2(){
        User usr = [Select id ,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        
        system.runAs(usr){
            //create Case
            account locAcc = [select Id from Account where RecordType.name = 'Location'];
            Contact contact = [select Id from Contact];
            
            // Set up a test request
            RestRequest request = new RestRequest();
            RestResponse res = new RestResponse();
            request.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
            
            // Set request properties
            request.requestUri = '/services/apexrest/CreateBalePickupCase/V1';
            request.httpMethod = 'POST';
            
            // Set other properties, such as parameters
            String jsonMsg = '{"ContactId": "'+contact.Id+'"}';
            
            
            request.requestBody = Blob.valueof(jsonMsg);
            
            // Finally, assign the request to RestContext if used
            RestContext.request = request;
            RestContext.response = res;
            Test.startTest();
            BalePickupCaseService.createBalePickupCase();
            Test.stopTest();
            //system.assert(jsonMsg != null);
        }
    }
    
    @isTest static void testcreatePickupCase4(){
        
        User usr = [Select id , Acorn_SUser_ID__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        
        system.runAs(usr){
            //create Case
            account locAcc = [select Id,Name from Account where RecordType.name = 'Location'];
            Contact contact = [select Id from Contact];
            User usr1 = [Select id , Acorn_SUser_ID__c from User limit 1];
            
            
            // Set up a test request
            RestRequest request = new RestRequest();
            RestResponse res = new RestResponse();
            request.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
            
            // Set request properties
            request.requestUri = '/services/apexrest/CreateBalePickupCase/V1';
            request.httpMethod = 'POST';
            
            // Set other properties, such as parameters
            String jsonMsg = '{"LocationId":"'+locAcc.Id+'","LocationCode":"'+ locAcc.Name+'" ,"AcornSUserId":'+ usr1.Acorn_SUser_ID__c+',"CaseType":"Pickup","ServiceDate": "2019-09-21","Origin": "IVR Phone","ContactId": "'+contact.Id+'"}';
            
            
            request.requestBody = Blob.valueof(jsonMsg);
            
            // Finally, assign the request to RestContext if used
            RestContext.request = request;
            RestContext.response = res;
            Test.startTest();
            BalePickupCaseService.createBalePickupCase();
            Test.stopTest();
            //system.assert(jsonMsg != null);
        }        
    }
    

    // /** // Modified for SDT-33437 Start
    // * @description test method for updateCase
    // */
    @isTest static void testupdateCase(){
        User usr = [Select id ,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; 
        
        system.runAs(usr){
            Case caselist = [SELECT Id, Status FROM Case LIMIT 1];
            Test.startTest();
            BalePickupCaseService.updateCase(caselist.Id);
            Test.stopTest();
        }
    }
    
    // Modified for SDT-33437 Start
    // /** 
    // * @description test method for createCommentRecord
    // */
   	@isTest static void testcreateCommentRecord(){
        User usr = [Select id ,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1];
        
        system.runAs(usr){
            Case caseObj = [SELECT Id, Status, Last_Customer_Interaction_Id__c, Last_Customer_Interaction_Type__c, CaseNumber FROM Case LIMIT 1];
            Test.startTest();
            BalePickupCaseService.RequestData reqObj = new BalePickupCaseService.RequestData();
            reqObj.Comments = 'Test';
            BalePickupCaseService.createCommentRecord(caseObj,reqObj);
            Test.stopTest();
        }
    }
    // Modified for SDT-33437 End 
    
    // Modified for SDT-33437 Start
    // /** 
    // * @description test method for createInboundCustTask
    // */
    @isTest static void testcreateInboundCustTask(){
        User usr = [Select id ,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; 
        
        system.runAs(usr){
            Case caseObj = [SELECT Id, Status, Last_Customer_Interaction_Id__c, Last_Customer_Interaction_Type__c FROM Case LIMIT 1];
            Test.startTest();
            BalePickupCaseService.createInboundCustTask(caseObj);
            Test.stopTest();
        }
    }
    // Modified for SDT-33437 End    
    
}