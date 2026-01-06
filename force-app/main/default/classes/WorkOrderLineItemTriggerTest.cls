/**
* @author Accenture
* @date 23/06/2020
* @description : Apex class UpdateQuantityClientPriceTest 
**/
@isTest(seeAllData = false)
public class WorkOrderLineItemTriggerTest {

    /**
    * @author Accenture
    * @date 23/06/2020
    * @description : Apex method setup 
    **/
    // method for setting up data    
    @testSetup static void setup() {
        Profile p = TestDataFactory.getProfile('System Administrator');
        User usr = TestDataFactory.createUser(p);
        Database.insert(usr);
        
        system.runAs(usr){
            list<Account> acclist = TestDataFactory.createAccount(Constant_Util.KEYWORD_TEST, usr);
            Database.insert(acclist);
            
            list<Account> locationlist = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, acclist.get(0).id);
            locationlist[0].tz__Timezone_SFDC__c = 'America/Los_Angeles';
            locationlist[0].tz__Timezone__c = 'EST';
            Database.insert(locationlist);
            
            list<Contact> conlist = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST,Constant_Util.CONSTANT_LAST, acclist.get(0), usr);
            Database.insert(conlist);

            list<product2> productlist = TestDataFactory.createProduct(Constant_Util.KEYWORD_TEST);
            productlist[0].Family = Constant_Util.COMMERCIAL;
            Database.insert(productlist);
            
            list<Asset> assetlist = TestDataFactory.createAsset(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                                productlist.get(0), usr, locationlist.get(0));
            assetlist[0].Supplier__c = acclist[1].Id;
            Database.insert(assetlist);
            
            Asset srvcDetail = TestDataFactory.createChildAsset('Test Asset')[0];
            srvcDetail.Service_Header_Id__c	 = assetlist.get(0).Id;
            srvcDetail.Is_Core_Service__c = true;
            srvcDetail.Quantity__c = 5;
            srvcDetail.Service_Type__c = 'Haul';
            srvcDetail.Acorn_SBID__c = 980763;
            srvcDetail.ParentId = assetlist.get(0).Id;
            Database.insert(srvcDetail);
            
            list<Case> caselist = TestDataFactory.createCase(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                             usr, locationlist.get(0), assetlist.get(0));
            caselist[0].AccountId = acclist.get(0).Id;
            caselist[0].Service_Date__c = system.today() + 1;
            Database.insert(caselist[0]);
			
			//create Workorder
            List<WorkOrder> workOrderList = TestDataFactory.createWorkOrder(acclist.get(0), conlist.get(0), caselist.get(0), 
                                                                            assetlist.get(0));                                                             
            workOrderList[0].Acorn_WorkOrder_Number__c = 'W12332547';
            workOrderList[0].Status = 'Issued';
            Database.insert(workOrderList);
			
			list<WorkOrderLineItem> WorkOrderLineItems = TestDataFactory.createWorkOrderLineItem( workOrderList[0]);
            WorkOrderLineItems[0].AssetId = srvcDetail.Id;
            Database.insert(WorkOrderLineItems);
            
        }        
    }    
    
    /**
    * @author Accenture
    * @date 23/06/2020
    * @description : Apex method sendWOLITest 
    **/
    @isTest static void sendWOLITest(){
        //test class errors - SDT - 33363
        user currentuser = [select id, Bypass_Validation__c,isActive from user WHERE isActive =TRUE limit 1];
        system.runAs(currentuser){
            list<WorkOrderLineItem> woliLst = [select Id, Original_Client_Price__c, New_Client_Price__c, Reason_Code__c,
                         Reason_Description__c, Quantity__c FROM WorkOrderLineItem WHERE WorkOrder.Status = 'Issued'];
            Test.startTest();
                UpdateQuantityClientPrice.MOCK_RESPONSE_CODE = Constant_Util.STATUS_CODE;
                woliLst[0].Quantity__c = 3;
                update woLiLst;
            Test.stopTest();
        }
    }
    /**
    * @author Accenture
    * @date 23/06/2020
    * @description : Apex method sendWOLINegativeTest 
    **/
    @isTest static void sendWOLINegativeTest(){
        //test class errors - SDT - 33363
        user currentuser = [select id, Bypass_Validation__c,isActive from user WHERE isActive =TRUE limit 1];
        system.runAs(currentuser){
            list<WorkOrderLineItem> woliLst = [select Id, New_Client_Price__c, Reason_Code__c, Service_Type__c,
                         Reason_Description__c, Quantity__c FROM WorkOrderLineItem WHERE WorkOrder.Status = 'Issued'];
            Test.startTest();
                UpdateQuantityClientPrice.MOCK_RESPONSE_CODE = 400;
             	UpdateQuantityClientPrice.MOCK_RESPONSE = '{"Data": null, "Problem": {"Errors": [{ "Code": "403","Message": "Partner access denied"}]}}';
            	woliLst[0].Quantity__c = 5;
            	woliLst[0].Reason_Description__c = 'test';
            	update woLiLst;
            Test.stopTest();
        }
    }
    /**
    * @author Accenture
    * @date 08/06/2020
    * @description : Apex method validateQuantityTest for less than 0
    **/
    @isTest static void validateQuantityTest(){
        //test class errors - SDT - 33363
        user currentuser = [select id, Bypass_Validation__c,isActive from user WHERE isActive =TRUE limit 1];
        system.runAs(currentuser){
            list<WorkOrderLineItem> woliLst = [select Id, Service_Type__c, Quantity__c FROM WorkOrderLineItem 
                                               WHERE WorkOrder.Status = 'Issued'];
            Test.startTest();
                woliLst[0].Quantity__c = -2;
            	woliLst[0].AssetId = null;
            try{
                update woLiLst;
            } catch(Exception ex){
                Boolean expectedExceptionThrown =  ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION') ? true : false;
                System.assertEquals(expectedExceptionThrown, false);
            }
            Test.stopTest();
        }
    }
    /**
    * @author Accenture
    * @date 08/14/2020
    * @description : Apex method validateQuantityTest for value 0
    **/
    @isTest static void validateQuantityZeroTest(){
        //test class errors - SDT - 33363
        user currentuser = [select id, Bypass_Validation__c,isActive from user WHERE isActive =TRUE limit 1];
        system.runAs(currentuser){
            list<WorkOrderLineItem> woliLst = [select Id, Service_Type__c, Quantity__c FROM WorkOrderLineItem 
                                               WHERE WorkOrder.Status = 'Issued'];
            Test.startTest();
            	woliLst[0].Quantity__c = 0;
            try{
                update woLiLst;
            } catch(Exception ex){
                Boolean expectedExceptionThrown =  ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION') ? true : false;
                System.assertEquals(expectedExceptionThrown, true);
            }
            Test.stopTest();
        }
    }
    /**
    * @author Accenture
    * @date 08/14/2020
    * @description : Apex method validateQuantityTest for occurence type
    **/
    @isTest static void validateOccurenceTypeTest(){
        //test class errors - SDT - 33363
        user currentuser = [select id, Bypass_Validation__c,isActive from user WHERE isActive =TRUE limit 1];
        system.runAs(currentuser){
            Asset srvcDetail = [select Id,Occurrence_Type__c From Asset where RecordType.name = 'Service Detail'];
            srvcDetail.Occurrence_Type__c = Constant_Util.SCHEDULED;
            update srvcDetail;
            list<WorkOrderLineItem> woliLst = [select Id, Service_Type__c, Quantity__c FROM WorkOrderLineItem WHERE 
                                               WorkOrder.Status = 'Issued' AND Occurrence_Type__c =: Constant_Util.SCHEDULED];
            Test.startTest();
            	woliLst[0].Quantity__c = 50;
            try{
                update woLiLst;
            } catch(Exception ex){
                Boolean expectedExceptionThrown =  ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION') ? true : false;
                System.assertEquals(expectedExceptionThrown, true);
            }
            Test.stopTest();
        }
    }
    /**
    * @author Accenture
    * @date 08/14/2020
    * @description : Apex method validateClientPriceTest for reasoncode mandatory
    **/
    @isTest static void validateClientPriceTest(){
        //test class errors - SDT - 33363
        user currentuser = [select id, Bypass_Validation__c,isActive from user WHERE isActive =TRUE limit 1];
        system.runAs(currentuser){
            list<WorkOrderLineItem> woliLst = [select Id, Service_Type__c, Quantity__c FROM WorkOrderLineItem WHERE 
                                               WorkOrder.Status = 'Issued'];
            Test.startTest();
            	woliLst[0].New_Client_Price__c = 50;
            try{
                update woLiLst;
            } catch(Exception ex){
                Boolean expectedExceptionThrown =  ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION') ? true : false;
                System.assertEquals(expectedExceptionThrown, true);
            }
            Test.stopTest();
        }
    }
}