@isTest(seeAllData = false)
public class CreatePickupCaseAPITest {

@testSetup static void setup() {
		Profile p = TestDataFactory.getProfile('System Administrator');        
        User usr = TestDataFactory.createUser(p);
        usr.Acorn_SUser_ID__c = 1000;
    	
        Database.insert(usr);
        
        system.runAs(usr){
            //create account
            list<Account> acclist = TestDataFactory.createAccount(Constant_Util.KEYWORD_TEST, usr,'Client');
            Database.insert(acclist);
            
            //create location
            list<Account> locationlist = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, acclist.get(0).id);
            Database.insert(locationlist);
            
            //create contact
            list<Contact> conlist = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST, 
                                                                Constant_Util.CONSTANT_LAST, acclist.get(0), usr);
            Database.insert(conlist);
            
            //create product
            list<product2> productlist = TestDataFactory.createProduct(Constant_Util.KEYWORD_TEST);
            Database.insert(productlist);
            
            //create vendor
            list<Account> supplieracclist = TestDataFactory.createAccount('testsupplier', usr,'Vendor');
            Database.insert(supplieracclist);
            
            //create asset
            list<Asset> assetlist = TestDataFactory.createAsset(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                                productlist.get(0), usr, locationlist.get(0));
            assetlist[0].Supplier__c = supplieracclist.get(0).Id;
            assetlist[0].Quantity__c = 5;
            Database.insert(assetlist);
            
            //create case
            list<Case> caselist = TestDataFactory.createCase(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                             usr, locationlist.get(0), assetlist.get(0));
            Database.insert(caselist);           
            
            //create Workorder
            List<WorkOrder> workOrderList = TestDataFactory.createWorkOrder(acclist.get(0), conlist.get(0), caselist.get(0), 
                                                                            assetlist.get(0));
            workOrderList[0].Vendor_Account_Id__c = supplieracclist.get(0).Id;                                                                
            Database.insert(workOrderList);
            
            list<WorkOrderLineItem> WorkOrderLineItems = TestDataFactory.createWorkOrderLineItem( workOrderList[0]);
            Database.insert(WorkOrderLineItems);

        }
    }

// /**
// * @description test method for createPickupCase
// */
    @isTest static void testcreatePickupCase(){
        User usr = [SELECT id, Bypass_Validation__c,Profile.Name,Acorn_SUser_ID__c from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        
        system.runAs(usr){
            //create Case
            Case casebj = [SELECT Id FROM Case LIMIT 1];
            account locAcc = [select Id,Name from Account where RecordType.name = 'Location'];
            Asset asset = [select Id, Acorn_SBID__c from asset ];
            Contact contact = [select Id from Contact];
            User usr1 = [Select id , Acorn_SUser_ID__c from User limit 1];
            

            // Set up a test request
            RestRequest request = new RestRequest();
            RestResponse res = new RestResponse();
            request.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
            
            // Set request properties
            request.requestUri = '/services/apexrest/v1/CreatePickupCase';
            request.httpMethod = 'POST';
            
            // Set other properties, such as parameters
            String jsonMsg = '{"LocationId":"'+locAcc.Id+'","LocationCode":"'+ locAcc.Name+'" ,"AssetId":"'+asset.Id+'","AcornSBID":'+ asset.Acorn_SBID__c+',"AcornSUserId":'+ usr1.Acorn_SUser_ID__c+',"CaseType":"Pickup","ServiceDate": "2019-09-21","Origin": "IVR Phone","ContactId": "'+contact.Id+'"}';


           request.requestBody = Blob.valueof(jsonMsg);
            
            // Finally, assign the request to RestContext if used
            RestContext.request = request;
            RestContext.response = res;
            Test.startTest();
            CreatePickupCaseAPI.createPickupCase();
            // WorkOrderWebservices.UpdateRecords(casebj.id, 12345678, '123456', woObj.id, 11111111,
            //                          '12121211', new List<String>{'test1','test2'},'43543',false,true, WorkOrderLineItems);
            Test.stopTest();
            //system.assert(jsonMsg != null);
        }        
    }

 /**
 * @description test method for createPickupCase
 *  PO , Ref # , PSI
 */
    @isTest static void testcreatePickupCase2(){
        User usr = [SELECT id, Bypass_Validation__c,Profile.Name,Acorn_SUser_ID__c from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        
        system.runAs(usr){
            //create Case
            Case casebj = [select Id FROM Case LIMIT 1];
            account locAcc = [select Id,Name from Account where RecordType.name = 'Location'];
            account clientAcc = [select Id,Name from Account where RecordType.name = 'Client'];
            Asset asset = [select Id, Acorn_SBID__c from asset ];
            Contact contact = [select Id from Contact];
                        list<Contact> conlist = TestDataFactory.createContact('Unspecified', 
                                                                locAcc.Name, clientAcc, usr);
            
            Database.insert(conlist);

            // Set up a test request
            RestRequest request = new RestRequest();
            RestResponse res = new RestResponse();
            request.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
            
            // Set request properties
            request.requestUri = '/services/apexrest/v1/CreatePickupCase';
            request.httpMethod = 'POST';
            
            // Set other properties, such as parameters
            String jsonMsg = '{"LocationId":"'+locAcc.Id+'","LocationCode":"'+ locAcc.Name+'" ,"AcornSBID":'+ asset.Acorn_SBID__c+',"PO":"PO-12322","PSI":100,"AcornSUserId":'+ usr.Acorn_SUser_ID__c+',"CaseType":"Pickup","Origin": "IVR Phone" }';


           request.requestBody = Blob.valueof(jsonMsg);
            
            // Finally, assign the request to RestContext if used
            RestContext.request = request;
            RestContext.response = res;
            Test.startTest();
            CreatePickupCaseAPI.createPickupCase();
            // WorkOrderWebservices.UpdateRecords(casebj.id, 12345678, '123456', woObj.id, 11111111,
            //                          '12121211', new List<String>{'test1','test2'},'43543',false,true, WorkOrderLineItems);
            Test.stopTest();
            //system.assert(jsonMsg != null);
        }        
    }

/**
 * @description test method for createPickupCase
 *  PO , Ref # , PSI
 */
    @isTest static void testcreatePickupCase3(){
        User usr = [SELECT id, Bypass_Validation__c,Profile.Name,Acorn_SUser_ID__c from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        
        system.runAs(usr){
            //create Case
            Case casebj = [select Id FROM Case LIMIT 1];
            account locAcc = [select Id,Name from Account where RecordType.name = 'Location'];
            account clientAcc = [select Id,Name from Account where RecordType.name = 'Client'];
            Asset asset = [select Id, Acorn_SBID__c from asset ];
            Contact contact = [select Id from Contact];
                        list<Contact> conlist = TestDataFactory.createContact('Unspecified', 
                                                                locAcc.Name, clientAcc, usr);
            Database.insert(conlist);

            // Set up a test request
            RestRequest request = new RestRequest();
            RestResponse res = new RestResponse();
            request.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
            
            // Set request properties
            request.requestUri = '/services/apexrest/v1/CreatePickupCase';
            request.httpMethod = 'POST';
            
            // Set other properties, such as parameters
            String jsonMsg = '{"LocationId":"'+locAcc.Id+'","ContactId":"'+''+'" ,"AcornSBID":'+ asset.Acorn_SBID__c+',"PO":"PO-12322","PSI":100,"AcornSUserId":'+ usr.Acorn_SUser_ID__c+',"CaseType":"Pickup","Origin": "IVR Phone" }';


           request.requestBody = Blob.valueof(jsonMsg);
            
            // Finally, assign the request to RestContext if used
            RestContext.request = request;
            RestContext.response = res;
            Test.startTest();
            CreatePickupCaseAPI.createPickupCase();
            // WorkOrderWebservices.UpdateRecords(casebj.id, 12345678, '123456', woObj.id, 11111111,
            //                          '12121211', new List<String>{'test1','test2'},'43543',false,true, WorkOrderLineItems);
            Test.stopTest();
            //system.assert(jsonMsg != null);
        }        
    }
/**
* @description test method for createPickupCase Bad Data
*/
    @isTest static void testcreatePickupCaseBadData(){
        User usr = [SELECT id, Bypass_Validation__c,Profile.Name,Acorn_SUser_ID__c from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        
        system.runAs(usr){
            //create Case
            Case casebj = [SELECT Id FROM Case LIMIT 1];
            account locAcc = [select Id from Account where RecordType.name = 'Location'];
            Asset asset = [select Id from asset ];
            Contact contact = [select Id from Contact];
            
            // Set up a test request
            RestRequest request = new RestRequest();
            RestResponse res = new RestResponse();
            request.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
            
            // Set request properties
            request.requestUri = '/services/apexrest/v1/CreatePickupCase';
            request.httpMethod = 'POST';
            
            // Set other properties, such as parameters
            String jsonMsg = '{"LocationId":"'+locAcc.Id+'","AssetId":"'+asset.Id+'","CaseType":"Pickup, "AcornSUserId":"'+ usr.Acorn_SUser_ID__c+'","Origin": "IVR Phone","ContactId": "'+contact.Id+'"}';


           request.requestBody = Blob.valueof(jsonMsg);
            
            // Finally, assign the request to RestContext if used
            RestContext.request = request;
            RestContext.response = res;
            Test.startTest();
            CreatePickupCaseAPI.createPickupCase();
            // WorkOrderWebservices.UpdateRecords(casebj.id, 12345678, '123456', woObj.id, 11111111,
            //                          '12121211', new List<String>{'test1','test2'},'43543',false,true, WorkOrderLineItems);
            Test.stopTest();
            //system.assert(jsonMsg != null);
        }
    }

// /**
// * @description test method for createPickupCase Bad Data
// */
    @isTest static void testcreatePickupCaseBadData2(){
        User usr = [SELECT id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        
        system.runAs(usr){
            //create Case
            Case casebj = [SELECT Id FROM Case LIMIT 1];
            account locAcc = [select Id from Account where RecordType.name = 'Location'];
            Asset asset = [select Id from asset ];
            Contact contact = [select Id from Contact];
            
            // Set up a test request
            RestRequest request = new RestRequest();
            RestResponse res = new RestResponse();
            request.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
            
            // Set request properties
            request.requestUri = '/services/apexrest/v1/CreatePickupCase';
            request.httpMethod = 'POST';
            
            // Set other properties, such as parameters
            String jsonMsg = '{"ContactId": "'+contact.Id+'"}';


           request.requestBody = Blob.valueof(jsonMsg);
            
            // Finally, assign the request to RestContext if used
            RestContext.request = request;
            RestContext.response = res;
            Test.startTest();
            CreatePickupCaseAPI.createPickupCase();
            // WorkOrderWebservices.UpdateRecords(casebj.id, 12345678, '123456', woObj.id, 11111111,
            //                          '12121211', new List<String>{'test1','test2'},'43543',false,true, WorkOrderLineItems);
            Test.stopTest();
            //system.assert(jsonMsg != null);
        }
    }
   
    @isTest static void testcreatePickupCase4(){
        
        User usr = [SELECT id, Bypass_Validation__c,Profile.Name ,Acorn_SUser_ID__c from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        
        system.runAs(usr){
            //create Case
            Case casebj = [SELECT Id FROM Case LIMIT 1];
            account locAcc = [select Id,Name from Account where RecordType.name = 'Location'];
            Asset asset = [select Id, Acorn_SBID__c from asset ];
            Contact contact = [select Id from Contact];
            User usr1 = [Select id , Acorn_SUser_ID__c from User limit 1];
            

            // Set up a test request
            RestRequest request = new RestRequest();
            RestResponse res = new RestResponse();
            request.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
            
            // Set request properties
            request.requestUri = '/services/apexrest/v1/CreatePickupCase';
            request.httpMethod = 'POST';
            
            // Set other properties, such as parameters
            String jsonMsg = '{"LocationId":"'+locAcc.Id+'","LocationCode":"'+ locAcc.Name+'" ,"AssetId":"'+asset.Id+'","AcornSBID":'+ asset.Acorn_SBID__c+',"AcornSUserId":'+ usr1.Acorn_SUser_ID__c+',"CaseType":"Pickup","ServiceDate": "2019-09-21","Origin": "IVR Phone","ContactId": "'+contact.Id+'"}';


           request.requestBody = Blob.valueof(jsonMsg);
            
            // Finally, assign the request to RestContext if used
            RestContext.request = request;
            RestContext.response = res;
            Test.startTest();
            CreatePickupCaseAPI.createPickupCase();
            // WorkOrderWebservices.UpdateRecords(casebj.id, 12345678, '123456', woObj.id, 11111111,
            //                          '12121211', new List<String>{'test1','test2'},'43543',false,true, WorkOrderLineItems);
            Test.stopTest();
            //system.assert(jsonMsg != null);
        }        
    }
}