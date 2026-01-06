/**
 * Date: 12/8/2022
 * Description: It covers the BatchUpdateWorkOrderLineItem Class
 * */
@isTest
public class BatchUpdateWorkOrderLITest {
    
    public testmethod static void testWorkOrderLI() {
        Profile p = TestDataFactory.getProfile('System Administrator');
        User usr = TestDataFactory.createUser(p);
        Database.insert(usr);
        
        system.runAs(usr){
            Test.startTest();
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
            BatchUpdateWorkOrderLineItem batchCls = new BatchUpdateWorkOrderLineItem();
			Database.executeBatch(batchCls, 200);
            Test.stopTest();
        }        
    }

}