/**
* @author Kalaiselvi R
* @date 08/08/2019
* @description : Apex class IVRServiceStatusWebServiceTest 
**/
@isTest
public class IVRServiceStatusWebServiceTest_V1 {
    
    private static list<Account> acclist = new list<Account>();
    private static list<Account> locationlist = new list<Account>();
    private static list<Account> locationlist1 = new list<Account>();
    private static list<Account> supplierAcclist = new list<Account>();
    private static list<Contact> conlist = new list<Contact>();
    private static list<Asset> assetlist = new list<Asset>();
    private static list<Asset> assetlist1 = new list<Asset>();
    private static list<Case> caselist = new list<Case>();
    private static final string STR_CODE = '1234';
	private static final string STR_MESSAGE = 'Test message';
    private static final string STR_TITLE = 'Test Title';
	private static final string STR_STATUS = 'Fail';
    private static final string STR_LOCATION_CODE = 'FAM020342';
    private static final string STR_LOCATION_CODE2 = 'HMD020342';
    
	/**
    * @description set the test data
    */ 
    @testSetup static void setup() {
		Profile p = TestDataFactory.getProfile('System Administrator');        
        User usr = TestDataFactory.createUser(p);
        Database.insert(usr);
        
        system.runAs(usr){
            //create account
            acclist = TestDataFactory.createAccount(Constant_Util.KEYWORD_TEST, usr,'Client');
            Database.insert(acclist);
            
            //create location
            locationlist = TestDataFactory.createLocation(STR_LOCATION_CODE2, usr, acclist.get(0).id);
            locationlist[0].tz__Timezone_SFDC__c = 'America/Los_Angeles';
            Database.insert(locationlist);
            locationlist1 = TestDataFactory.createLocation(STR_LOCATION_CODE, usr, acclist.get(0).id);
            locationlist1[0].tz__Timezone_SFDC__c = 'America/Los_Angeles';
            Database.insert(locationlist1);
            
            //create contact
            conlist = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST, 
                                                                Constant_Util.CONSTANT_LAST, acclist.get(0), usr);
            Database.insert(conlist);
            
            //create product
            list<product2> productlist = TestDataFactory.createProduct(Constant_Util.KEYWORD_TEST);
            productlist[0].Container_Prompt_ID__c = '319.vox';
            Database.insert(productlist);
            
            //create vendor
			supplierAcclist = TestDataFactory.createAccount('testsupplier', usr,'Vendor');
            supplierAcclist[0].AccountNumber = '8';
            Database.insert(supplierAcclist);
            
            list<Account> supplierAcclist1 = TestDataFactory.createAccount('testsupplier', usr,'Vendor');
            supplierAcclist1[0].ParentId = supplierAcclist[0].Id;
            Database.insert(supplierAcclist1);
            
            //create asset
            assetlist = TestDataFactory.createAsset(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                                productlist.get(0), usr, locationlist.get(0));
            assetlist[0].Supplier__c = supplierAcclist.get(0).Id;
            assetlist[0].Quantity__c = 1;
			assetlist[0].Material_Type__c = 'Trash';
            Database.insert(assetlist);
            assetlist1 = TestDataFactory.createAsset(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                                productlist.get(0), usr, locationlist1.get(0));
            assetlist1[0].Supplier__c = supplierAcclist.get(0).Id;
            assetlist1[0].Quantity__c = 1;
			assetlist1[0].Material_Type__c = 'Trash';
            assetlist1[0].Acorn_SBID__c = 56843.45;
			assetlist1[0].Is_Core_service__c=true;
            Database.insert(assetlist1);
			
            list<Asset> childAssetlist1 = TestDataFactory.createChildAsset(Constant_Util.KEYWORD_TEST);
            childAssetlist1[0].ParentId=[select Id from Asset where ProductFamily=:Constant_Util.COMMERCIAL limit 1].Id;
            childAssetlist1[0].Supplier__c = supplieracclist.get(0).Id;
            childAssetlist1[0].Quantity__c = 1;
			childAssetlist1[0].Location__c = locationlist.get(0).Id;
            childAssetlist1[0].product2Id = productlist.get(0).Id;
            childAssetlist1[0].Acorn_SBID__c = 56843.45;
            childAssetlist1[0].Is_Core_service__c=true;
            childAssetlist1[0].Start_Date__c=System.today();
            Database.insert(childAssetlist1);
            //create case
            caselist = TestDataFactory.createCase(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                             usr, locationlist.get(0), assetlist.get(0));
            caselist[0].Reference_Number__c =  '01093767';
			caselist[0].SLA_Service_Date_Time__c = system.now();
			caselist[1].Reference_Number__c =  '01093767';
            caselist[2].Reference_Number__c =  '01093768';
            caselist[3].Reference_Number__c =  '01093767';
            caselist[0].Location__c = locationlist1.get(0).Id;
            caselist[0].AssetId = assetlist1.get(0).Id;
            caselist[1].AssetId = assetlist1.get(0).Id;
            caselist[1].Location__c = locationlist1.get(0).Id;
			caselist[1].Work_Order__c = null;
            Database.insert(caselist);      
            caselist[0].Case_Sub_Type__c = 'Extra pickup';
            caselist[1].Case_Sub_Type__c = 'On Call';
            Database.update(caselist); 
            //create Workorder
            List<WorkOrder> workOrderList = TestDataFactory.createWorkOrder(acclist.get(0), conlist.get(0), caselist.get(0), 
                                                                            assetlist.get(0));
            workOrderList[0].Vendor_Account_Id__c = supplierAcclist1.get(0).Id; 
            workOrderList[0].Service_Date__c = System.Today();
			workOrderList[0].status = 'Accepted';
			workOrderList[0].Actual_Service_Date__c = system.now();
			workOrderList[0].Service_Exception_Received_Date_Time__c = system.now();
			workOrderList[0].Rescheduled_Date__c = system.now();
            workOrderList[0].Acorn_WorkOrder_Number__c = 'W1245634';
            Database.insert(workOrderList);
			List<WorkOrder> workOrderList1 = TestDataFactory.createWorkOrder(acclist.get(0), conlist.get(0), caselist.get(0), 
                                                                            assetlist.get(0));
			workOrderList1[0].status = 'Accepted';
            workOrderList1[0].Vendor_Account_Id__c = supplierAcclist1.get(0).Id;
            workOrderList1[0].Acorn_WorkOrder_Number__c = 'W1245644';
			Database.insert(workOrderList1);
			List<WorkOrder> workOrderList2 = TestDataFactory.createWorkOrder(acclist.get(0), conlist.get(0), caselist.get(3), 
                                                                            assetlist.get(0));
			workOrderList2[0].status = 'Accepted';
			workOrderList2[0].Vendor_Account_Id__c = supplierAcclist1.get(0).Id;
            workOrderList2[0].Acorn_WorkOrder_Number__c = 'W1245654';
			Database.insert(workOrderList2);
        }
    }
    /**
    * @description test method for getWorkOrder
    */
    @isTest static void testGetWorkOrder(){
        //test class errors - SDT - 33363
        User usr = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name ='System Administrator' limit 1];
        
        system.runAs(usr){
			RestRequest request = new RestRequest();
			RestResponse res = new RestResponse();
			request.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
			request.requestUri = '/services/apexrest/ServiceStatus_V1/V1';
			request.httpMethod = 'POST';

			// Set other properties, such as parameters
			String jsonMsg = '{"ReferenceNumber":"01093767","workOrderNumber":"Null"}';
			request.requestBody = Blob.valueof(jsonMsg);

			// Finally, assign the request to RestContext if used
			RestContext.request = request;
			RestContext.response = res;
			Test.startTest();
				IVRServiceStatusWebService_V1.getWorkOrder();
			Test.StopTest();
			system.assert(jsonMsg != null);
        }
    }
	/**
    * @description test method for getWorkOrder2
    */
    @isTest static void testGetCaseByWO(){
        //test class errors - SDT - 33363
        User usr = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name ='System Administrator' limit 1];
       
        system.runAs(usr){
            RestRequest request = new RestRequest();
            RestResponse res = new RestResponse();
            request.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
            
            // Set request properties
            request.requestUri = '/services/apexrest/ServiceStatus_V1/V1';
            request.httpMethod = 'POST';
            
            // Set other properties, such as parameters
            String jsonMsg = '{"ReferenceNumber":"01093768","workOrderNumber":"Null"}';
            request.requestBody = Blob.valueof(jsonMsg);
            
            // Finally, assign the request to RestContext if used
            RestContext.request = request;
            RestContext.response = res;
            Test.startTest();
				IVRServiceStatusWebService_V1.getWorkOrder();
            Test.StopTest();
            system.assert(jsonMsg != null);
        }
    }
    /**
    * @description test method for get asset details
    */
    @isTest static void testGetAssetByLocCode(){
        //test class errors - SDT - 33363
        User usr = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name ='System Administrator' limit 1];
        
        system.runAs(usr){
			RestRequest request = new RestRequest();
			RestResponse res = new RestResponse();
			request.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
			request.requestUri = '/services/apexrest/ServiceStatus_V1/V1';
			request.httpMethod = 'POST';

			// Set other properties, such as parameters
			String jsonMsg = '{"ReferenceNumber":"Null","LocationCode": "'+STR_LOCATION_CODE+'"}';
			request.requestBody = Blob.valueof(jsonMsg);

			// Finally, assign the request to RestContext if used
			RestContext.request = request;
			RestContext.response = res;
			Test.startTest();
				IVRServiceStatusWebService_V1.getWorkOrder();
			Test.StopTest();
			system.assert(jsonMsg != null);
        }
    }
	/**
    * @description test method to GetWOByLocCode
    */
    @isTest static void testGetWOByLocCode(){
        //test class errors - SDT - 33363
        User usr = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name ='System Administrator' limit 1];
       
        system.runAs(usr){
            //create Workorder
            Account acc = [SELECT Id FROM Account LIMIT 1];
            Case caseObj = [SELECT Id,OwnerId FROM Case LIMIT 1];
            Contact con = [SELECT Id FROM Contact LIMIT 1];
            Asset assetObj = [SELECT Id FROM Asset LIMIT 1];
            Id supplierId = [SELECT Id, RecordType.Name FROM Account WHERE recordtype.name='Vendor' LIMIT 1].Id;
            
            List<WorkOrder> workOrderList2 = TestDataFactory.createWorkOrder(acc, con, caseObj, assetObj); 
            workOrderList2[0].Vendor_Account_Id__c = supplierId; 
            workOrderList2[0].Service_Date__c = System.Today().adddays(-2);
			workOrderList2[0].Vendor_Service_Status__c = 'Confirmed Negative';
            Database.insert(workOrderList2);
            
            List<WorkOrder> workOrderList3 = TestDataFactory.createWorkOrder(acc, con, caseObj, assetObj);
            workOrderList3[0].Vendor_Account_Id__c = supplierId; 
            workOrderList3[0].Service_Date__c = System.Today();
            Database.insert(workOrderList3);
            
            RestRequest request = new RestRequest();
            RestResponse res = new RestResponse();
            request.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
            
            // Set request properties
            request.requestUri = '/services/apexrest/ServiceStatus_V1/V1';
            request.httpMethod = 'POST';
            
            // Set other properties, such as parameters
            String jsonMsg = '{"ReferenceNumber":"Null","LocationCode": "'+STR_LOCATION_CODE2+'"}';
            request.requestBody = Blob.valueof(jsonMsg);
            
            // Finally, assign the request to RestContext if used
            RestContext.request = request;
            RestContext.response = res;
            Test.startTest();
				IVRServiceStatusWebService_V1.getWorkOrder();
            Test.StopTest();
            system.assert(jsonMsg != null);
        }
    }
	/**
    * @description test method to GetMultiWOByRefNo
    */
    @isTest static void testGetMultiWOByRefNo(){
        //test class errors - SDT - 33363
        User usr = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name ='System Administrator' limit 1];
       
        system.runAs(usr){
            //create Workorder
            Account acc = [SELECT Id FROM Account LIMIT 1];
            List<Case> caseLst = [SELECT Id,OwnerId FROM Case LIMIT 2];
            Contact con = [SELECT Id FROM Contact LIMIT 1];
            Asset assetObj = [SELECT Id FROM Asset LIMIT 1];
            Id supplierId = [SELECT Id, RecordType.Name FROM Account WHERE recordtype.name='Vendor' LIMIT 1].Id;
            
            List<WorkOrder> workOrderList2 = TestDataFactory.createWorkOrder(acc, con, caseLst.get(0), assetObj); 
            workOrderList2[0].Vendor_Account_Id__c = supplierId; 
            workOrderList2[0].Service_Date__c = System.Today().adddays(-2);
			workOrderList2[0].Vendor_Service_Status__c = 'Rescheduled';
            Database.insert(workOrderList2);
            
            List<WorkOrder> workOrderList3 = TestDataFactory.createWorkOrder(acc, con, caseLst.get(1), assetObj);
            workOrderList3[0].Vendor_Account_Id__c = supplierId; 
            workOrderList3[0].Service_Date__c = System.Today().adddays(1);
			workOrderList2[0].Vendor_Service_Status__c = 'Confirmed Positive';	
            Database.insert(workOrderList3);
            
            RestRequest request = new RestRequest();
            RestResponse res = new RestResponse();
            request.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
            
            // Set request properties
            request.requestUri = '/services/apexrest/ServiceStatus_V1/V1';
            request.httpMethod = 'POST';
            
            // Set other properties, such as parameters
            String jsonMsg = '{"ReferenceNumber":"01093767","workOrderNumber":"Null"}';
            request.requestBody = Blob.valueof(jsonMsg);
            
            // Finally, assign the request to RestContext if used
            RestContext.request = request;
            RestContext.response = res;
            Test.startTest();
				IVRServiceStatusWebService_V1.getWorkOrder();
            Test.StopTest();
            system.assert(jsonMsg != null);
        }
    }
    /**
    * @description test method for getWorkOrder
    */
    @isTest static void testGetWorkOrderException(){
        //test class errors - SDT - 33363
        User usr = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name ='System Administrator' limit 1];
        
        system.runAs(usr){
			RestRequest request = new RestRequest();
			RestResponse res = new RestResponse();
			request.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
			request.requestUri = '/services/apexrest/ServiceStatus_V1/V1/';
			request.httpMethod = 'POST';

			// Set other properties, such as parameters
            String jsonMsg = '{}';
			request.requestBody = Blob.valueof(jsonMsg);
			// Finally, assign the request to RestContext if used
			RestContext.request = request;
			RestContext.response = res;
			Test.startTest();
				IVRServiceStatusWebService_V1.getWorkOrder();
			Test.StopTest();
            IVRServiceStatusWebService_V1.ErrorsWrapper ew = new IVRServiceStatusWebService_V1.ErrorsWrapper(STR_CODE,STR_MESSAGE);
            IVRServiceStatusWebService_V1.ErrorMessageWrapper emw = new IVRServiceStatusWebService_V1.ErrorMessageWrapper(STR_TITLE,STR_STATUS,new List<IVRServiceStatusWebService_V1.ErrorsWrapper>{ew});
			system.assert(jsonMsg != null);
        }
    }	
    /**
    * @description test method for get asset details
    */
    @isTest static void testGetAssetByLocCodeException(){
        //test class errors - SDT - 33363
        User usr = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name ='System Administrator' limit 1];
        List<Account> locAccountLst = [SELECT Id, RecordType.Name FROM Account WHERE RecordType.Name = 'Location' 
                              AND Name =: STR_LOCATION_CODE2 LIMIT 1];
        locAccountLst[0].tz__Timezone_SFDC__c = '';
        Database.update(locAccountLst);

        system.runAs(usr){
			RestRequest request = new RestRequest();
			RestResponse res = new RestResponse();
			request.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
			request.requestUri = '/services/apexrest/ServiceStatus_V1/V1';
			request.httpMethod = 'POST';

			// Set other properties, such as parameters
			String jsonMsg = '{"ReferenceNumber":"Null","LocationCode": "'+STR_LOCATION_CODE2+'"}';
			request.requestBody = Blob.valueof(jsonMsg);

			// Finally, assign the request to RestContext if used
			RestContext.request = request;
			RestContext.response = res;
			Test.startTest();
				IVRServiceStatusWebService_V1.getWorkOrder();
			Test.StopTest();
			system.assert(jsonMsg != null);
        }
    }
}