/**
* @author Accenture
* @date 2/26/2019
* @description : Apex class WorkOrderWebservicesTest 
**/

// test class for WorkOrderWebservices
@isTest(SeeAllData=false)
public class WorkOrderWebservicesTest {
    /**
* @description set the test data
*/ 
    @testSetup static void setup() {
        Profile p = TestDataFactory.getProfile('System Administrator');        
        User usr = TestDataFactory.createUser(p);
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
    
    /**
* @description test method for work order with data
*/
    @isTest static void testGetWorkOrderDetails(){
        //Test class error - 1204
        User usr = [Select id,isActive from User WHERE isActive = TRUE limit 1];
        
        system.runAs(usr){
            //create workorder
			WorkOrder woObj = [SELECT Id FROM WorkOrder LIMIT 1];
			List<WorkOrderLineItem> WorkOrderLineItems = [select Id, Acorn_WOC__c  from WorkOrderLineItem where WorkOrderId  =: woObj.Id ];
            //create Case
            Case casebj = [SELECT Id FROM Case LIMIT 1];
            
            // Set up a test request
            RestRequest request = new RestRequest();
            RestResponse res = new RestResponse();
            request.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
            
            // Set request properties
            request.requestUri = '/services/apexrest/WorkOrder/V1';
            request.httpMethod = 'POST';
            
            // Set other properties, such as parameters
            String jsonMsg = '{"WorkOrderId":"'+woObj.Id+'"}';
            request.requestBody = Blob.valueof(jsonMsg);
            
            // Finally, assign the request to RestContext if used
            RestContext.request = request;
            RestContext.response = res;
            Test.startTest();
            WorkOrderWebservices.getWorkOrderDetails();
            system.assert(jsonMsg != null);
            system.assert(res.responseBody != null);
            System.debug(res.responseBody);
            WorkOrderWebservices.WorkOrderResponse response = (WorkOrderWebservices.WorkOrderResponse)JSON.deserialize(res.responseBody.toString(), WorkOrderWebservices.WorkOrderResponse.Class);
            System.assertEquals(1,response.RecordCount); 
            System.assertEquals(woObj.Id,response.WorkOrder[0].WorkOrderHeader.Id);
			
        }        
    }
    
    @isTest static void testCaseandWorkorderfailure(){
        //Test class error - 1204
        User usr = [Select id,isActive from User WHERE isActive = TRUE limit 1];
        
        system.runAs(usr){
            //create workorder
            WorkOrder woObj = [SELECT Id FROM WorkOrder LIMIT 1];
            List<WorkOrderLineItem> WorkOrderLineItems = [select Id, Acorn_WOC__c  from WorkOrderLineItem where WorkOrderId  =: woObj.Id ];
            System.debug(' WorkOrderLineItems '+WorkOrderLineItems);
            //create Case
            Case casebj = [SELECT Id FROM Case LIMIT 1];
            
            // Set up a test request
            RestRequest request = new RestRequest();
            RestResponse res = new RestResponse();
            request.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
            
            // Set request properties
            request.requestUri = '/services/apexrest/WorkOrder/V1';
            request.httpMethod = 'POST';
            
            // Set other properties, such as parameters
            String jsonMsg = '{"WorkOrderId":"'+woObj.Id+'"}';
            request.requestBody = Blob.valueof(jsonMsg);
            
            // Finally, assign the request to RestContext if used
            RestContext.request = request;
            RestContext.response = res;
            Test.startTest();
            WorkOrderWebservices.UpdateRecords('', 12345678, '123456', '', 11111111,
                                               '12121211',new List<String>{''},'43543',false,true,true,false,WorkOrderLineItems);
            Test.stopTest();
            system.assert(jsonMsg != null);
        }        
    }
    
    /**
* @description test method when work order does not exist
*/
    @isTest static void testForException(){
        //Test class error - 1204
        User usr = [Select id,isActive from User WHERE isActive = TRUE limit 1];
        
        system.runAs(usr){
            // Set up a test request
            RestRequest request = new RestRequest();
            RestResponse res = new RestResponse();
            request.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
            //create workorder
            WorkOrder woObj = [SELECT Id FROM WorkOrder LIMIT 1];
            List<WorkOrderLineItem> WorkOrderLineItems = [select Id, Acorn_WOC__c  from WorkOrderLineItem where WorkOrderId  =: woObj.Id ];
            // Set request properties
            request.requestUri = '/services/apexrest/WorkOrder/V1';
            request.httpMethod = 'POST';
            
            // Finally, assign the request to RestContext if used
            RestContext.request = request;
            RestContext.response = res;
            Test.startTest();
            WorkOrderWebservices.getWorkOrderDetails();
            WorkOrderWebservices.UpdateRecords('', 20456914, '123456', woObj.id, 11111111,
                                               '12121211',new List<String>{'test1','test2'},'43543',false,true,true,null,WorkOrderLineItems);
            Test.stopTest();
            system.assert(request.requestBody == null);
        }
    }
    
    @isTest static void testUpdateRecords1(){
        //Test class error - 1204
        User usr = [Select id,isActive from User WHERE isActive = TRUE limit 1];
        
        System.runAs(usr){
            Test.startTest();
            List<WorkOrderWebservices.ResponseWrapper> resultWrapper;
            WorkOrder woObj = [SELECT Id FROM WorkOrder LIMIT 1];
            Case casebj = [SELECT Id FROM Case LIMIT 1];
            
            // workorder updates
            
            resultWrapper  = WorkOrderWebservices.UpdateRecords('',null,'', woObj.id, 11111111,
                                                                '12121211', new List<String>{},'43543',false,true,true,null, null);
            
            if(resultWrapper[0].IsSuccess){
                WorkOrder wo = [SELECT Acorn_WorkOrder_Id__c, Acorn_WorkOrder_Number__c, 
                                    Acorn_Purchase_Order_Number__c, Status 
                                FROM WorkOrder 
                                WHERE id=:woObj.id];

                System.assertEquals(11111111, wo.Acorn_WorkOrder_Id__c);
                System.assertEquals('12121211', wo.Acorn_WorkOrder_Number__c);
                System.assertEquals('43543', wo.Acorn_Purchase_Order_Number__c);
                System.assertEquals(Constant_Util.STATUS_NEW, wo.Status);
            }
        }
    }  

    @isTest static void testUpdateRecords2(){
        //Test class error - 1204
        User usr = [Select id,isActive from User WHERE isActive = TRUE limit 1];
        
        System.runAs(usr){
            Test.startTest();
            List<WorkOrderWebservices.ResponseWrapper> resultWrapper;
            WorkOrder woObj = [SELECT Id FROM WorkOrder LIMIT 1];
            Case casebj = [SELECT Id FROM Case LIMIT 1];

            resultWrapper  = WorkOrderWebservices.UpdateRecords(casebj.Id,11111,'123456', null, 11111111,
                                                                '12121211',new List<String>{'test1','test2'},null,false,true,true,null, null);
            
			if(resultWrapper[0].IsSuccess){
                Case c = [SELECT Acorn_Issue_Id__c, Tracking_Number__c, Email_Tracking_Number__c 
                            FROM Case 
                            WHERE id=:casebj.Id];
                
                System.assertEquals(11111, c.Acorn_Issue_Id__c);
                System.assertEquals('123456', c.Tracking_Number__c);
                System.assertEquals('123456', c.Email_Tracking_Number__c);
            }
            Test.stopTest();
        }
    }  
    
    @isTest static void testWorkOrderLineItemUpdate(){
        //Test class error - 1204
        User usr = [Select id,isActive from User WHERE isActive = TRUE limit 1];
        
        system.runAs(usr){
            List<WorkOrderWebservices.ResponseWrapper> resultWrapper;
            WorkOrder woObj = [SELECT Id FROM WorkOrder LIMIT 1];
        	List<WorkOrderLineItem> newWorkOrderLineItems = [select Id, Acorn_WOC__c  from WorkOrderLineItem where WorkOrderId  !=: woObj.Id limit 2];
            List<WorkOrderLineItem> WorkOrderLineItems = [select Id, Acorn_WOC__c  from WorkOrderLineItem where WorkOrderId  =: woObj.Id];
        	Test.startTest();
            //WorkOrderLineItem update
        	resultWrapper  = WorkOrderWebservices.UpdateRecords(null,null,null, woObj.Id, 11111111,
                                                                '12121211', new List<String>{'test1','test2'},'4354',null,null,true,null,newWorkOrderLineItems);
            if(resultWrapper[0].IsSuccess){
                List<WorkOrderLineItem> getWorkOrderLineItems = [select Id, Acorn_WOC__c  from WorkOrderLineItem where WorkOrderId  !=: woObj.Id limit 2];
                System.assertEquals(getWorkOrderLineItems[0].Acorn_WOC__c, WorkOrderLineItems[0].Acorn_WOC__c);
			}
            Test.stopTest();
        }
    }
}