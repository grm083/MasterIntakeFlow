/*************************************************************
@Name: UpdateWorkOrderTest
@Author: Kalaiselvi
@CreateDate: 25/03/2019
@Description: Test class of UpdateWorkOrder
@UsedBy: 
**************************************************************/
@isTest
public class UpdateWorkOrderTest {

    // method for setting up data    
    @testSetup static void setup() {
        Profile p = TestDataFactory.getProfile('System Administrator');
        User usr = TestDataFactory.createUser(p);
        Database.insert(usr);
        
        system.runAs(usr){
			list<Account> acclist = TestDataFactory.createAccount(Constant_Util.KEYWORD_TEST, usr);
            Database.insert(acclist);
            list<Account> locationlist = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, acclist.get(0).id);
            Database.insert(locationlist);
            list<Contact> conlist = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST,Constant_Util.CONSTANT_LAST, acclist.get(0), usr);
            Database.insert(conlist);
            list<product2> productlist = TestDataFactory.createProduct(Constant_Util.KEYWORD_TEST);
            Database.insert(productlist);
            list<Asset> assetlist = TestDataFactory.createAsset(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                                productlist.get(0), usr, locationlist.get(0));
            assetlist[0]. Supplier__c = acclist[1].Id;
            Database.insert(assetlist);
            list<Case> caselist = TestDataFactory.createCase(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                             usr, locationlist.get(0), assetlist.get(0));
            caselist[0].PurchaseOrder_Number__c = '1234';
            Database.insert(caselist);
            list<WorkOrder> workOrderList = TestDataFactory.createWorkOrder(acclist.get(0), conlist.get(0), caselist.get(0), assetlist.get(0));
            Database.insert(workOrderList);
		}
	}
	
	//Test Resend work order   
    @isTest static void testResendWO() {
        //test class errors - SDT - 33363
        User currentuser = [Select id,isActive from User WHERE isActive = TRUE and Profile.Name='System Administrator' limit 1];
        List<Integration_Request_URLs__mdt> urlMDList = new List<Integration_Request_URLs__mdt>();
        urlMDList = [Select DeveloperName,MasterLabel,Client_Key__c,Client_Token__c,Timeout__c, Content_Type__c,End_Point__c,Method__c from Integration_Request_URLs__mdt where DeveloperName=: Constant_Util.DRY_RUN_WORK_ORDER];
               
        
        system.runAs(currentuser){
            list<Account> locationlist = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'Location' LIMIT 1]; 
        	list<WorkOrder> workOrderList = [SELECT Id FROM WorkOrder LIMIT 1];    
            workOrderList[0].Integration_Status__c = Constant_Util.RESEND;
            workOrderList[0].Acorn_WorkOrder_Number__c = 'W14001328';   
            workOrderList[0].Customer_Location__c = locationlist[0].id;
            Database.update(workOrderList);
            system.assertEquals(Constant_Util.RESEND,workOrderList[0].Integration_Status__c);
            Test.startTest();
                RecurrsiveTriggerHandler.isSkipWorkOrderUpdate = false;
            	UpdateWorkOrder.updateWO(workOrderList);
            	IntegrationHandlerUtil.getIntegrationRequsetMapping(Constant_Util.RESEND_WORK_ORDER,workOrderList[0].id); 
            	IntegrationHandlerUtil.getCalloutResponseContents(Constant_Util.RESEND_WORK_ORDER,urlMDList, workOrderList[0].id);
            Test.stopTest();
        }
    }
	//Test Cancel work order   
    @isTest static void testCancelWO() {
        //test class errors - SDT - 33363
        User currentuser = [Select id,isActive from User WHERE isActive = TRUE and Profile.Name='System Administrator' limit 1];
        List<Integration_Request_URLs__mdt> urlMDList = new List<Integration_Request_URLs__mdt>();
        urlMDList = [Select DeveloperName,MasterLabel,Client_Key__c,Client_Token__c,Timeout__c, Content_Type__c,End_Point__c,Method__c from Integration_Request_URLs__mdt where DeveloperName=: Constant_Util.CANCEL_WORK_ORDER];
               
        system.runAs(currentuser){
        	list<WorkOrder> workOrderList = [SELECT Id FROM WorkOrder LIMIT 1];    
            workOrderList[0].Integration_Status__c = Constant_Util.CANCEL;
            workOrderList[0].Acorn_WorkOrder_Number__c = 'W14001329';
            workOrderList[0].Send_Work_Order_to_Vendor__c = false;
            workOrderList[0].Exception_Description__c = 'aaaaaaaaaaaaaaaaaaaaaaaaaa';
            workOrderList[0].Exception_Reason__c = 'Blocked Can';
            Database.update(workOrderList);
            system.assertEquals(Constant_Util.CANCEL,workOrderList[0].Integration_Status__c);
            Test.startTest();
                RecurrsiveTriggerHandler.isSkipWorkOrderUpdate = false;
            	UpdateWorkOrder.updateWO(workOrderList);
            	IntegrationHandlerUtil.getIntegrationRequsetMapping(Constant_Util.CANCEL_WORK_ORDER,workOrderList[0].id);  
            	IntegrationHandlerUtil.getCalloutResponseContents(Constant_Util.CANCEL_WORK_ORDER,urlMDList, workOrderList[0].id);
            Test.stopTest();
        }
    }
	//Test Dry Run work order   
    @isTest static void testDryRunWO() {
        //test class errors - SDT - 33363
        User currentuser = [Select id,isActive from User WHERE isActive = TRUE and Profile.Name='System Administrator' limit 1];
        List<Integration_Request_URLs__mdt> urlMDList = new List<Integration_Request_URLs__mdt>();
        urlMDList = [Select DeveloperName,MasterLabel,Client_Key__c,Client_Token__c,Timeout__c, Content_Type__c,End_Point__c,Method__c from Integration_Request_URLs__mdt where DeveloperName=: Constant_Util.DRY_RUN_WORK_ORDER];
                                      
        
        system.runAs(currentuser){
        	list<WorkOrder> workOrderList = [SELECT Id FROM WorkOrder LIMIT 1];    
            workOrderList[0].Integration_Status__c = Constant_Util.DRY_RUN;
            workOrderList[0].Acorn_WorkOrder_Number__c = 'W14001330';
            workOrderList[0].Dry_Run_Price__c = 98;
            workOrderList[0].Dry_Run_Cost__c = 100;
            workOrderList[0].Dry_Run_Description__c ='test trest test trst';
            Database.update(workOrderList);
            system.assertEquals(Constant_Util.DRY_RUN,workOrderList[0].Integration_Status__c);
            Test.startTest();
                RecurrsiveTriggerHandler.isSkipWorkOrderUpdate = false;           
            	UpdateWorkOrder.updateWO(workOrderList);
            	IntegrationHandlerUtil.getIntegrationRequsetMapping(Constant_Util.DRY_RUN_WORK_ORDER,workOrderList[0].id);
            	IntegrationHandlerUtil.getCalloutResponseContents(Constant_Util.DRY_RUN_WORK_ORDER,urlMDList, workOrderList[0].id);
            Test.stopTest();
        }
    }
	//Test Accept work order   
    @isTest static void testAcceptWO() {
        //test class errors - SDT - 33363
        User currentuser = [Select id,isActive from User WHERE isActive = TRUE and Profile.Name='System Administrator' limit 1];
                       
        system.runAs(currentuser){ 
        	list<WorkOrder> workOrderList = [SELECT Id FROM WorkOrder LIMIT 1];    
            workOrderList[0].Integration_Status__c = Constant_Util.ACCEPT;
            workOrderList[0].Acorn_WorkOrder_Number__c = 'W14001330';
            Database.update(workOrderList);
            system.assertEquals(Constant_Util.ACCEPT,workOrderList[0].Integration_Status__c);
            Test.startTest();
                RecurrsiveTriggerHandler.isSkipWorkOrderUpdate = false;
            	UpdateWorkOrder.updateWO(workOrderList);
            	IntegrationHandlerUtil.getIntegrationRequsetMapping(Constant_Util.ACCEPT_WORK_ORDER,workOrderList[0].id);      
            	
            Test.stopTest();
        }
    }
	//Test Update work order   
    @isTest static void testUpdateWO() {
        //test class errors - SDT - 33363
        User currentuser = [Select id,isActive from User WHERE isActive = TRUE and Profile.Name='System Administrator' limit 1];
        List<Integration_Request_URLs__mdt> urlMDList = new List<Integration_Request_URLs__mdt>();
        urlMDList = [Select DeveloperName,MasterLabel,Client_Key__c,Client_Token__c,Timeout__c, Content_Type__c,End_Point__c,Method__c from Integration_Request_URLs__mdt where DeveloperName=: Constant_Util.UPDATE_WORK_ORDER];
               
        system.runAs(currentuser){
            String interfaceName = 'Update_Work_Order';
            List<Integration_Request_Mapping__mdt> metadataList = new List<Integration_Request_Mapping__mdt>();
        	metadataList = Database.query('SELECT DeveloperName,Field_Name__c,Id,Is_Active__c,Is_Node__c,Is_Parent__c, ' + 
                                      'Is_State__c,JSON_field_name__c, Object_Name__c,Parent_Node__c,Sequence__c,Used_for__c, ' +
                                      'Data_Type__c FROM Integration_Request_Mapping__mdt WHERE Is_Active__c = true AND ' +
                                       'Used_for__c =: interfaceName ORDER BY sequence__c');
            
            
        	list<WorkOrder> workOrderList = [SELECT Id, Case.PurchaseOrder_Number__c, Customer_Location__r.Location_Code__c, 
                                                Instructions__c, Profile_Purchase_Order__c, Manifest_Number__c, Pickup_DateTime__c,	
                                                Return_DateTime__c, Actual_Service_Date__c, Service_Date__c, 
                                                Vendor_ID__c, MAS_Case__c, MAS_Ticket__c, Profile_Number__c, 
                                                Vehicle_Number__c, Profile_Generator__c, Profile_Description__c, 
                                                Fast_Lane_Ticket__c 
                                            FROM WorkOrder LIMIT 1];

            workOrderList[0].Integration_Status__c = Constant_Util.UPDATEVAL;
            workOrderList[0].Acorn_WorkOrder_Number__c = 'W14001330';
            workOrderList[0].Pickup_DateTime__c = system.now();
            workOrderList[0].Manifest_Number__c = '23445';
            Database.update(workOrderList);
            system.assertEquals(Constant_Util.UPDATEVAL,workOrderList[0].Integration_Status__c);
            Test.startTest();
            RecurrsiveTriggerHandler.isSkipWorkOrderUpdate = false;
            UpdateWorkOrder.updateWO(workOrderList);
			// //for Get service ETA - POD3
            IntegrationHandlerUtil.getIntegrationRequsetMapping(Constant_Util.Get_Service_ETA,workOrderList[0].id); 
            IntegrationHandlerUtil.getCalloutResponseContents(Constant_Util.UPDATE_WORK_ORDER,urlMDList, workOrderList[0].id);
            String result = IntegrationHandlerUtil.generateJson(metaDataList, workorderlist[0]);
            System.debug('result --- ' + result);
            
            System.assert(result.contains('\"clientAuthorizationNumber\" : \"1234\"'));
            
            Test.stopTest();
        }
    }
    
}