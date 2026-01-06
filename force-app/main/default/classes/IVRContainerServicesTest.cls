/**
* @author Accenture
* @date 8/21/2019
* @description : Apex class IVRContainerServicesTest 
**/

// test class for IVRContainerServices
@isTest(SeeAllData=false)
public class IVRContainerServicesTest {
    private static final string STR_CODE = '1234';
    private static final string STR_MESSAGE = 'Test message';    
    private static final string STR_TITLE = 'Test Title';
    private static final string STR_STATUS = 'Fail';
    
    @testSetup static void setup() {
        Profile p = TestDataFactory.getProfile('System Administrator');         
        User usr = TestDataFactory.createUser(p);
        Database.insert(usr); 
        System.runAs(usr){
            //create account
            list<Account> acclist = TestDataFactory.createAccount(Constant_Util.KEYWORD_TEST, usr,'Client');
            acclist[0].AccountNumber='8';
            Database.insert(acclist);
            
            //create location
            list<Account> locationlist = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, acclist.get(0).id);
            locationlist.get(0).tz__Timezone_SFDC__c = 'America/Chicago';
            Database.insert(locationlist); 
            
            //create location
            list<Account> location2 = TestDataFactory.createLocation('HMD4863', usr, acclist.get(0).id);
            location2.get(0).tz__Timezone_SFDC__c = 'America/New_York';
            Database.insert(location2);
            
              //create location
            list<Account> locationlist2 = TestDataFactory.createLocation('ABC123456789', usr, acclist.get(0).id);
            locationlist2.get(0).tz__Timezone_SFDC__c = 'America/New_York';
            Database.insert(locationlist2);
            
            //create contact
            list<Contact> conlist = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST, 
                                                                  Constant_Util.CONSTANT_LAST, acclist.get(0), usr);
            Database.insert(conlist);
            
            //create product
            list<product2> productlist = TestDataFactory.createProduct(Constant_Util.KEYWORD_TEST);
            for(Product2 objProd : productlist){
                objProd.Container_Prompt_ID__c = 'Test';
                objProd.Voice_Prompt__c = objProd.Name;
            }
            Database.insert(productlist);
            System.debug('** Prod' + productlist);
            
            list<product2> productlistRollOff = TestDataFactory.createProduct(Constant_Util.KEYWORD_TEST);
            productlistRollOff[0].Family=Constant_Util.ROLLOFF;
            productlistRollOff[0].Container_Prompt_ID__c = 'Test';
            productlistRollOff[0].Equipment_Type__c = 'Open Top';
            productlistRollOff[0].Voice_Prompt__c = productlistRollOff[0].Name;
            Database.insert(productlistRollOff);
            
            //create vendor
            list<Account> supplieracclist = TestDataFactory.createAccount('testsupplier', usr,'Vendor');
            supplieracclist[0].ParentId=acclist.get(0).id;
            Database.insert(supplieracclist);
            
            list<Asset> assetlist4 = TestDataFactory.createAsset(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                                 productlistRollOff.get(0), usr, locationlist.get(0));
            assetlist4[0].Supplier__c = supplieracclist.get(0).Id;
            assetlist4[0].Quantity__c = 1;
            assetlist4[0].Has_Extra_Pickup__c = true;
            assetlist4[0].Service_Type__c = Constant_Util.HAUL;
            assetlist4[0].Occurrence_Type__c = Constant_Util.ON_CALL;
            assetlist4[0].Material_Type__c='Trash';
            assetlist4[0].Duration__c = 'Permanent';
            assetlist4[0].Is_Self_Service__c = true;
            assetlist4[0].Start_Date__c = system.today().addDays(10);
            Database.insert(assetlist4);
            system.debug('assetlist4'+assetlist4);
            list<Asset> childAstlst4 = TestDataFactory.createChildAsset('ChildAsset');
            
            childAstlst4[0].ParentId= assetlist4.get(0).Id;
            childAstlst4[1].ParentId= assetlist4.get(0).Id;
            childAstlst4[1].Is_Self_Service__c = true;
            childAstlst4[0].Is_Self_Service__c = true;
            childAstlst4[0].Name = childAstlst4[0].Name + Constant_Util.SCHEDULED;
            childAstlst4[0].Service_Header_Id__c = assetlist4.get(0).Id;
            childAstlst4[1].Service_Header_Id__c = assetlist4.get(0).Id;
            childAstlst4[0].Is_Core_service__c=true;
            childAstlst4[0].Supplier__c = supplieracclist.get(0).Id;
            childAstlst4[0].Start_Date__c=System.today().addDays(-10);
            childAstlst4[0].End_Date__c = System.today();
            childAstlst4[0].Occurrence_Type__c = Constant_Util.SCHEDULED;
            childAstlst4[1].Occurrence_Type__c = Constant_Util.ON_CALL;
            childAstlst4[0].Monday__c = true;
            childAstlst4[0].Tuesday__c = true;
            childAstlst4[0].Wednesday__c = true;
            childAstlst4[0].Thursday__c = true;
            childAstlst4[0].Friday__c = true;
            childAstlst4[0].Duration__c = 'Permanent';
            childAstlst4[0].Frequency__c = Constant_Util.WEEKLY;
            childAstlst4[0].Service_Type__c = Constant_Util.PICKUP_CSTYPE;
            childAstlst4[1].Service_Type__c = Constant_Util.PICKUP_CSTYPE;
            childAstlst4[0].Has_Extra_Pickup__c = true;
            childAstlst4[1].Has_Extra_Pickup__c = false;
            childAstlst4[1].Start_Date__c=System.today().addDays(-10);
            childAstlst4[1].End_Date__c = System.today();
            Database.insert(childAstlst4);
            
            
            list<Asset> assetlist3 = TestDataFactory.createAsset(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                                 productlistRollOff.get(0), usr, locationlist.get(0));
            assetlist3[0].Supplier__c = supplieracclist.get(0).Id;
            assetlist3[0].Quantity__c = 1;
            assetlist3[0].Has_Extra_Pickup__c = true;
            assetlist3[0].Service_Type__c = Constant_Util.HAUL;
            assetlist3[0].Occurrence_Type__c = Constant_Util.ON_CALL;
            assetlist3[0].Material_Type__c='Trash';
            assetlist3[0].Duration__c = 'Temporary';
            assetlist3[0].Is_Self_Service__c = true;
            assetlist3[0].Start_Date__c = system.today();
            Database.insert(assetlist3);
            list<Asset> childAstlst = TestDataFactory.createChildAsset('ChildAsset');
            
            childAstlst[0].ParentId= assetlist3.get(0).Id;
            childAstlst[1].ParentId= assetlist3.get(0).Id;
            childAstlst[1].Is_Self_Service__c = true;
            childAstlst[0].Is_Self_Service__c = true;
            childAstlst[0].Name = childAstlst[0].Name + Constant_Util.SCHEDULED;
            childAstlst[0].Service_Header_Id__c = assetlist3.get(0).Id;
            childAstlst[1].Service_Header_Id__c = assetlist3.get(0).Id;
            childAstlst[0].Is_Core_service__c=true;
            childAstlst[1].Is_Core_service__c=true;
            childAstlst[0].Supplier__c = supplieracclist.get(0).Id;
            childAstlst[0].Start_Date__c=System.today().addDays(-10);
            childAstlst[0].End_Date__c = System.today().addDays(10);
            childAstlst[0].Occurrence_Type__c = Constant_Util.SCHEDULED;
            childAstlst[1].Occurrence_Type__c = Constant_Util.ON_CALL;
            childAstlst[0].Monday__c = true;
            childAstlst[0].Tuesday__c = true;
            childAstlst[0].Wednesday__c = true;
            childAstlst[0].Thursday__c = true;
            childAstlst[0].Friday__c = true;
            childAstlst[0].Duration__c = 'Permanent';
            childAstlst[0].Frequency__c = Constant_Util.WEEKLY;
            childAstlst[0].Service_Type__c = Constant_Util.PICKUP_CSTYPE;
            childAstlst[1].Service_Type__c = Constant_Util.PICKUP_CSTYPE;
            childAstlst[0].Has_Extra_Pickup__c = true;
            childAstlst[1].Has_Extra_Pickup__c = false;
            childAstlst[1].Start_Date__c=System.today().addDays(-10);
            childAstlst[0].End_Date__c = System.today().addDays(10);
            Database.insert(childAstlst);
            
            //create asset
            list<Asset> assetlist1 = TestDataFactory.createAsset(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                                 productlist.get(0), usr, locationlist2.get(0));
            assetlist1[0].Supplier__c = supplieracclist.get(0).Id;
            //assetlist1[0].ProductFamily  = Constant_Util.COMMERCIAL;
            assetlist1[0].Quantity__c = 1;
            assetlist1[0].Has_Extra_Pickup__c = true;
            //assetlist1[0].End_Date__c=System.today();
            assetlist1[0].Material_Type__c='Trash';
            assetlist1[0].Occurrence_Type__c = Constant_Util.SCHEDULED;
            assetlist1[0].Duration__c = 'Permanent';
            assetlist1[0].Start_Date__c = system.today();
            assetlist1[0].Is_Self_Service__c = true;
            // assetlist1[0].RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Service Detail').getRecordTypeId();
            // assetlist1[0].Core_Quantity__c=1;
            Database.insert(assetlist1);
            
            //create asset
            list<Asset> astlist = TestDataFactory.createAsset(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                                 productlist.get(0), usr, locationlist2.get(0));
            astlist[0].Supplier__c = supplieracclist.get(0).Id;
            astlist[0].Is_Self_Service__c = true;
            //assetlist1[0].ProductFamily  = Constant_Util.COMMERCIAL;
            astlist[0].Quantity__c = 1;
            astlist[0].Has_Extra_Pickup__c = true;
            astlist[0].Material_Type__c='Trash';
            astlist[0].Occurrence_Type__c = Constant_Util.SCHEDULED;
            astlist[0].Duration__c = 'Permanent';
            astlist[0].Start_Date__c = system.today();
            Database.insert(astlist);
            
            list<Asset> childAstlist1 = TestDataFactory.createChildAsset('ChildAsset');
            
            childAstlist1[0].ParentId= astlist.get(0).Id;
            childAstlist1[1].ParentId= astlist.get(0).Id;
            childAstlist1[1].Is_Self_Service__c = true;
            childAstlist1[0].Is_Self_Service__c = true;
            childAstlist1[0].Name = childAstlist1[0].Name + Constant_Util.SCHEDULED;
            childAstlist1[0].Service_Header_Id__c = astlist.get(0).Id;
            childAstlist1[1].Service_Header_Id__c = astlist.get(0).Id;
            childAstlist1[0].Is_Core_service__c=true;
            childAstlist1[0].Supplier__c = supplieracclist.get(0).Id;
            childAstlist1[0].Start_Date__c=System.today().addDays(-10);
            childAstlist1[0].Occurrence_Type__c = Constant_Util.SCHEDULED;
            childAstlist1[1].Occurrence_Type__c = Constant_Util.ON_CALL;
            childAstlist1[0].Monday__c = true;
            childAstlist1[0].Tuesday__c = true;
            childAstlist1[0].Wednesday__c = true;
            childAstlist1[0].Thursday__c = true;
            childAstlist1[0].Friday__c = true;
            childAstlist1[0].Duration__c = 'Permanent';
            childAstlist1[0].Frequency__c = Constant_Util.WEEKLY;
            childAstlist1[0].Service_Type__c = Constant_Util.PICKUP_CSTYPE;
            childAstlist1[1].Service_Type__c = Constant_Util.PICKUP_CSTYPE;
            childAstlist1[0].Has_Extra_Pickup__c = true;
            childAstlist1[1].Has_Extra_Pickup__c = false;
            childAstlist1[1].Start_Date__c=System.today().addDays(-10);
            Database.insert(childAstlist1);
            
            list<Asset> childAssetlist1 = TestDataFactory.createChildAsset(Constant_Util.KEYWORD_TEST);
            Asset parentAsset = [select Id,Location__c,Location__r.Name from Asset where ProductFamily=:Constant_Util.COMMERCIAL limit 1];
            Id parentId = parentAsset.Id;
            childAssetlist1[0].ParentId= parentId;
            childAssetlist1[1].ParentId= parentId;
            childAssetlist1[1].Is_Self_Service__c = true;
            childAssetlist1[0].Is_Self_Service__c = true;
            childAssetlist1[0].Name = childAssetlist1[0].Name + Constant_Util.SCHEDULED;
            childAssetlist1[0].Service_Header_Id__c = parentId;
            childAssetlist1[1].Service_Header_Id__c = parentId;
            childAssetlist1[0].Is_Core_service__c=true;
            childAssetlist1[0].Supplier__c = supplieracclist.get(0).Id;
            childAssetlist1[0].Start_Date__c=System.today().addDays(-10);
            childAssetlist1[0].Occurrence_Type__c = Constant_Util.SCHEDULED;
            childAssetlist1[1].Occurrence_Type__c = Constant_Util.ON_CALL;
            childAssetlist1[0].Monday__c = true;
            childAssetlist1[0].Tuesday__c = true;
            childAssetlist1[0].Wednesday__c = true;
            childAssetlist1[0].Thursday__c = true;
            childAssetlist1[0].Friday__c = true;
            childAssetlist1[0].Duration__c = 'Permanent';
            childAssetlist1[0].Frequency__c = Constant_Util.WEEKLY;
            childAssetlist1[0].Service_Type__c = Constant_Util.PICKUP_CSTYPE;
            childAssetlist1[1].Service_Type__c = Constant_Util.PICKUP_CSTYPE;
            childAssetlist1[0].Has_Extra_Pickup__c = true;
            childAssetlist1[1].Has_Extra_Pickup__c = false;
            childAssetlist1[1].Start_Date__c=System.today().addDays(-10);
            Database.insert(childAssetlist1);
            
                        //create asset
            list<Asset> astlist3 = TestDataFactory.createAsset(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                              productlist.get(0), usr, location2.get(0));
            astlist3[0].Supplier__c = supplieracclist.get(0).Id;
            //assetlist1[0].ProductFamily  = Constant_Util.COMMERCIAL;
            astlist3[0].Quantity__c = 1;
            astlist3[0].Has_Extra_Pickup__c = true;
            astlist3[0].Material_Type__c='Trash';
            astlist3[0].Occurrence_Type__c = Constant_Util.SCHEDULED;
            astlist3[0].Duration__c = 'Permanent';
            astlist3[0].Is_Self_Service__c = true;
            astlist3[0].Start_Date__c = system.today();
            Database.insert(astlist3);
            
            list<Asset> childlist = TestDataFactory.createChildAsset('ChildAsset');
            
            childlist[0].ParentId= astlist3.get(0).Id;
            childlist[1].ParentId= astlist3.get(0).Id;
            childlist[0].Name = childAstlist1[0].Name + Constant_Util.SCHEDULED;
            childlist[0].Service_Header_Id__c = astlist3.get(0).Id;
            childlist[1].Service_Header_Id__c = astlist3.get(0).Id;
            childlist[0].Is_Core_service__c=true;
            childlist[0].Is_Self_Service__c = true;
            childlist[0].Supplier__c = supplieracclist.get(0).Id;
            childlist[0].Start_Date__c=System.today().addDays(-10);
            childlist[0].Occurrence_Type__c = Constant_Util.SCHEDULED;
            childlist[1].Occurrence_Type__c = Constant_Util.ON_CALL;
            childlist[0].Duration__c = 'Permanent';
            childlist[0].Monday__c = true;
            childlist[0].Frequency__c = Constant_Util.WEEKLY;
            childlist[0].Service_Type__c = Constant_Util.PICKUP_CSTYPE;
            childlist[1].Service_Type__c = Constant_Util.PICKUP_CSTYPE;
            childlist[0].Has_Extra_Pickup__c = true;
            childlist[1].Has_Extra_Pickup__c = false;
            childlist[1].Start_Date__c=System.today().addDays(-10);
            Database.insert(childlist);
            
            list<Asset> assetlist2 = TestDataFactory.createAsset(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                                 productlistRollOff.get(0), usr, locationlist.get(0));
            assetlist2[0].Supplier__c = supplieracclist.get(0).Id;
            assetlist2[0].Quantity__c = 1;
            assetlist2[0].Service_Type__c = Constant_Util.HAUL;
            assetlist2[0].Occurrence_Type__c = Constant_Util.ON_CALL;
            assetlist2[0].Has_Extra_Pickup__c = false;
            //assetlist2[0].Core_Quantity__c=1;
            //assetlist2[0].End_Date__c=System.today();
            assetlist2[0].Material_Type__c= null; //'Trash';
            assetlist2[0].Duration__c = 'Temporary';
            // assetlist2[0].RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Service Detail').getRecordTypeId();
            //assetlist2[0].Equipment_Type__c = 'Open Top';
            Database.insert(assetlist2);
            
            list<Asset> childAssetlist2 = TestDataFactory.createChildAsset(Constant_Util.KEYWORD_TEST);
            childAssetlist2[0].ParentId=[select Id from Asset where ProductFamily=:Constant_Util.ROLLOFF limit 1].Id;
            childAssetlist2[0].Is_Core_service__c=true;
            childAssetlist2[0].Service_Type__c = Constant_Util.HAUL;
            childAssetlist2[0].Occurrence_Type__c = Constant_Util.ON_CALL;
            //childAssetlist2[0].Core_Quantity__c=1;
            childAssetlist2[0].Supplier__c = supplieracclist.get(0).Id;
            childAssetlist2[0].Start_Date__c=System.today();
            // childAssetlist2[0].RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Service Detail').getRecordTypeId();
            
            Database.insert(childAssetlist2[0]);
            Test.startTest(); 
            list<Case> caselist = TestDataFactory.createCase(Constant_Util.CONSTANT_FIRST,
                                                             acclist.get(0), conlist.get(0), 
                                                             usr, locationlist.get(0), assetlist2.get(0));
            // caseList[0].Service_Date__c = System.today();
            Database.insert(caseList[0]);
            
            //SDT-33637 - Bulkification 
            List<WorkOrder> workOrderBulkifi = new List<WorkOrder>();
            
            WorkOrder wo = new WorkOrder(AccountId = acclist.get(0).Id, CaseId = caselist.get(0).Id, OwnerId = caselist.get(0).OwnerId,
                                         Status = 'New');
            workOrderBulkifi.add(wo);
            //Database.insert(wo);
            
            list<WorkOrder> workOrderList1 = TestDataFactory.createWorkOrder(acclist.get(0),
                                                                             conlist.get(0), caselist.get(0), assetlist4.get(0));
            workOrderList1[0].status=Constant_UTil.WORK_COMPLETE;
            // workOrderList1[0].Service_Date__c=System.today();
            workOrderList1[0].Service_Date__c=System.today().adddays(-5);
            workOrderList1[0].Is_Bypass__c = false;  
            workOrderBulkifi.add(workOrderList1[0]);
            //Database.insert(workOrderList1);
            
            list<WorkOrder> workOrderList2 = TestDataFactory.createWorkOrder(acclist.get(0),
                                                                             conlist.get(0), caselist.get(0), assetlist1.get(0));
            workOrderList2[0].status=Constant_UTil.WORK_COMPLETE;
            workOrderList2[0].Service_Date__c=System.today().adddays(-3);
            workOrderList2[0].Is_Bypass__c = false;
            workOrderBulkifi.add(workOrderList2[0]);
            //Database.insert(workOrderList2);
            
            list<WorkOrder> workOrderList3 = TestDataFactory.createWorkOrder(acclist.get(0),
                                                                             conlist.get(0), caselist.get(0), assetlist2.get(0));
            workOrderList3[0].status=Constant_UTil.WORK_COMPLETE; 
            workOrderList3[0].Service_Date__c=System.today().adddays(-7);
            workOrderList3[0].Is_Bypass__c = false; 
            workOrderBulkifi.add(workOrderList3[0]);
            //Database.insert(workOrderList3);
           
            list<WorkOrder> workOrderList4 = TestDataFactory.createWorkOrder(acclist.get(0),
                                                                             conlist.get(0), caselist.get(0), parentAsset);
            workOrderList4[0].status=Constant_UTil.WORK_COMPLETE;
            workOrderList4[0].Service_Date__c=System.today().adddays(-6);
            workOrderList4[0].Is_Bypass__c = false;
            workOrderList4[0].AssetId =parentAsset.Id;
            workOrderBulkifi.add(workOrderList4[0]);
            //Database.insert(workOrderList4);
            
            list<WorkOrder> workOrderList5 = TestDataFactory.createWorkOrder(acclist.get(0),
                                                                             conlist.get(0), caselist.get(0), parentAsset);
            workOrderList5[0].status=Constant_UTil.STR_NEW;
            workOrderList5[0].Service_Date__c=System.today().adddays(-5);
            workOrderList5[0].Is_Bypass__c = false;
            workOrderList5[0].AssetId =parentAsset.Id;
            workOrderBulkifi.add(workOrderList5[0]);
            //Database.insert(workOrderList5);
            
            list<WorkOrder> workOrderList6 = TestDataFactory.createWorkOrder(acclist.get(0),
                                                                             conlist.get(0), caselist.get(0), astlist3.get(0));
            workOrderList6[0].status=Constant_UTil.STR_REJECTED;
            workOrderList6[0].Service_Date__c=System.today();
            workOrderList6[0].Is_Bypass__c = false;
            workOrderList6[0].AssetId = astlist3.get(0).Id;
            workOrderBulkifi.add(workOrderList6[0]);
            //Database.insert(workOrderList6);
            
            list<WorkOrder> workOrderList7 = TestDataFactory.createWorkOrder(acclist.get(0),
                                                                             conlist.get(0), caselist.get(0), astlist3.get(0));
            workOrderList7[0].status=Constant_UTil.STR_PENDING_DRAFT;
            workOrderList7[0].Service_Date__c=System.today();
            workOrderList7[0].Is_Bypass__c = false;
            workOrderList7[0].AssetId =astlist3.get(0).Id;
            workOrderBulkifi.add(workOrderList7[0]);
            //Database.insert(workOrderList7);
            insert workOrderBulkifi;
            
            //Create Entitlement With Not Gold Standard
            List<Entitlement> entitlementList = TestDataFactory.createEntitlement('test',locationlist.get(0));
            entitlementList[0].Location__c = parentAsset.Location__c;
            entitlementList[0].Gold_Standard__c = false;
            entitlementList[0].AssetId = parentAsset.Id;
            entitlementList[0].service__c = Constant_Util.EMPTY_AND_RETURN;
            entitlementList[0].Service_Guarantee_Category_Value__c = '2';
            System.debug('>>>entitlementList[0]'+entitlementList[0]);
            Database.insert(entitlementList[0]); 
            System.debug('>>>entitlementList[0]'+entitlementList[0]); 
            
            //Create Entitlement With Gold Standard
            List<Entitlement> entitlementList2 = TestDataFactory.createEntitlement('test',locationlist2.get(0));
            entitlementList2[0].Location__c = locationlist2.get(0).id;
            entitlementList2[0].Gold_Standard__c = True;
            entitlementList2[0].AssetId = assetlist1.get(0).Id;
            entitlementList2[0].service__c = Constant_Util.EXTRA_PICKUP;
            System.debug('>>>entitlementList2[0]'+entitlementList2[0]);
            Database.insert(entitlementList2[0]); 
            System.debug('>>>entitlementList2[0]'+entitlementList2[0]);
            
            //Create Entitlement With Gold Standard
            List<Entitlement> entitlementList3 = TestDataFactory.createEntitlement('test',locationlist2.get(0));
            entitlementList3[0].Location__c = locationlist2.get(0).id;
            entitlementList3[0].Gold_Standard__c = True;
            entitlementList3[0].AssetId = astlist.get(0).Id;
            entitlementList3[0].service__c = Constant_Util.EXTRA_PICKUP;
            System.debug('>>>entitlementList3[0]'+entitlementList3[0]);
            Database.insert(entitlementList3[0]);
                        //Create Entitlement With Gold Standard
            List<Entitlement> entitlementList4 = TestDataFactory.createEntitlement('test',locationlist2.get(0));
            entitlementList4[0].Location__c = location2.get(0).id;
            entitlementList4[0].Gold_Standard__c = True;
            entitlementList4[0].AssetId = astlist3.get(0).Id;
            entitlementList4[0].service__c = Constant_Util.EXTRA_PICKUP;
            Database.insert(entitlementList4[0]);
            
            //Create Entitlement With Gold Standard
            List<Entitlement> entitlementList5 = TestDataFactory.createEntitlement('test',locationlist.get(0));
            entitlementList5[0].Location__c = locationlist.get(0).id;
            entitlementList5[0].Gold_Standard__c = True;
            entitlementList5[0].AssetId = assetlist4.get(0).Id;
            entitlementList5[0].service__c = Constant_Util.EMPTY_AND_RETURN;
            entitlementList5[0].Service_Guarantee_Category_Value__c = '2';
            
            Database.insert(entitlementList5[0]);
            test.stopTest();
        }
    }
    
    @isTest static void testVoicePrompt(){
        //test class errors - SDT - 33363
        User usr = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name ='System Administrator' limit 1];
        System.runAs(usr){
            String recId=TestDataFactory.getRecordType('Location','Account');
            Account loc = [SELECT Id,Name FROM Account where RecordTypeid=:recId LIMIT 1];
            RestRequest request = new RestRequest();
            RestResponse res = new RestResponse();
            res.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
            request.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
            //Set request properties
            request.requestUri = '/services/apexrest/ContainerStatus/V1';
            request.httpMethod = 'POST';
            String jsonMsg = '{"connectionId":"1234","Location_Code":"'+loc.Name+'"}';
            request.requestBody = Blob.valueof(jsonMsg);
            RestContext.request = request;
            RestContext.response = res;
            string potentialPickupDate = '12/22/2019';//rahul
            IVRContainerServices.ContainerStatusResponse result = null;
            Test.startTest();
            IVRContainerServices.getAsset();
            result = (IVRContainerServices.ContainerStatusResponse)JSON.deserialize(res.responseBody.toString() , IVRContainerServices.ContainerStatusResponse.class);
            system.debug('Result:::'+result.container[0].PotentialPickupDate );
            Test.stopTest();
            Asset a = [SELECT Id, Name,Product2.Voice_Prompt__c from Asset where Id =: result.container[0].AssetId Limit 1];
            system.assertEquals(result.container[0].ContainerName,a.Product2.Voice_Prompt__c);
        }
    }

    @isTest static void testSchedulePickUpdate(){
        //test class errors - SDT - 33363
        User usr = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name ='System Administrator' limit 1];
        System.runAs(usr){
            String recId = TestDataFactory.getRecordType('Location','Account');
            Account loc = [SELECT Id, Name FROM Account where RecordTypeid=:recId LIMIT 1];
            
            RestRequest request = new RestRequest();
            RestResponse res = new RestResponse();
            request.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
            res.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
            // Set request properties
            request.requestUri = '/services/apexrest/ContainerStatus/V1';
            request.httpMethod = 'POST';
            String jsonMsg = '{"connectionId":"1234","Location_Code":"HMD4863"}';
            request.requestBody = Blob.valueof(jsonMsg);
            RestContext.request = request;
            RestContext.response = res;
            IVRContainerServices.ContainerStatusResponse result = null;
            Test.startTest();
            IVRContainerServices.getAsset();
            result = (IVRContainerServices.ContainerStatusResponse)JSON.deserialize(res.responseBody.toString() , IVRContainerServices.ContainerStatusResponse.class);
           
            system.assert(result.container[0].PotentialPickupDate != null);
            
            list<WorkOrder> woListRejected = [select id,status,Service_Date__c from WorkOrder where status = 'Rejected' ];
            String dt1 = String.valueOf(woListRejected[0].Service_Date__c);
            system.assertNotEquals(dt1,result.container[0].PotentialPickupDate);
            
            list<WorkOrder> woListPending = [select id,status,Service_Date__c from WorkOrder where status = 'Pending/Draft' ];
            String dt2 = String.valueOf(woListPending[0].Service_Date__c);
            system.assertNotEquals(dt2,result.container[0].PotentialPickupDate);
            
            list<WorkOrder> woListNew = [select id,status,Service_Date__c from WorkOrder where status = 'New' ];
            String dt3 = String.valueOf(woListNew[1].Service_Date__c);
            system.assertNotEquals(dt3,result.container[0].PotentialPickupDate);
            Test.stopTest();
            
        }
    }

    
    @isTest static void testGetAsset(){
        //test class errors - SDT - 33363
        User usr = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name ='System Administrator' limit 1];
        System.runAs(usr){
            String recId=TestDataFactory.getRecordType('Location','Account');
            Account loc = [SELECT Id,Name FROM Account where RecordTypeid=:recId LIMIT 1];
            RestRequest request = new RestRequest();
            RestResponse res = new RestResponse();
            res.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
            request.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
            //Set request properties
            request.requestUri = '/services/apexrest/ContainerStatus/V1';
            request.httpMethod = 'POST';
            String jsonMsg = '{"connectionId":"1234","Location_Code":"ABC123456789"}';
            request.requestBody = Blob.valueof(jsonMsg);
            RestContext.request = request;
            RestContext.response = res;
            string potentialPickupDate = '12/22/2019';//rahul
            IVRContainerServices.ContainerStatusResponse result = null;
            Test.startTest();
            IVRContainerServices.getAsset();
            result = (IVRContainerServices.ContainerStatusResponse)JSON.deserialize(res.responseBody.toString() , IVRContainerServices.ContainerStatusResponse.class);
            system.debug('Result:::'+result.container[0].PotentialPickupDate );
            Test.stopTest();
            system.assert(result.container[0].PotentialPickupDate != null);
        }
    }
    
    @isTest static void testGetAsset2(){
        //test class errors - SDT - 33363
        User usr = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name ='System Administrator' limit 1];
        System.runAs(usr){
            String recId = TestDataFactory.getRecordType('Location','Account');
            Account loc = [SELECT Id, Name FROM Account where RecordTypeid=:recId LIMIT 1];
            
            RestRequest request = new RestRequest();
            RestResponse res = new RestResponse();
            request.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
            res.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
            // Set request properties
            request.requestUri = '/services/apexrest/ContainerStatus/V1';
            request.httpMethod = 'POST';
            String jsonMsg = '{"connectionId":"1234","Location_Code":"'+loc.Name+'"}';
            request.requestBody = Blob.valueof(jsonMsg);
            RestContext.request = request;
            RestContext.response = res;
            IVRContainerServices.ContainerStatusResponse result = null;
            Test.startTest();
            IVRContainerServices.getAsset();
            result = (IVRContainerServices.ContainerStatusResponse)JSON.deserialize(res.responseBody.toString() , IVRContainerServices.ContainerStatusResponse.class);
            Test.stopTest();
            system.assert(result.container[0].PotentialPickupDate != null);
            system.assert(result.container[0].ContainerPromptId != null);
            
        }
    }
    
    @isTest static void testGetAssetForException(){  
        //test class errors - SDT - 33363
        User usr = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name ='System Administrator' limit 1];
        System.runAs(usr){
                
                RestRequest request = new RestRequest();
                RestResponse res = new RestResponse();
                res.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
                request.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
                // Set request properties
                request.requestUri = '/services/apexrest/ContainerStatus/V1';
                request.httpMethod = 'POST';
                String jsonMsg = '{}';
                //request.requestBody = Blob.valueof(jsonMsg);
                RestContext.request = request;
                RestContext.response = res;
                IVRContainerServices.ContainerStatusResponse result = null;
                Test.startTest();
                IVRContainerServices.getAsset();
                result = (IVRContainerServices.ContainerStatusResponse)JSON.deserialize(res.responseBody.toString() , IVRContainerServices.ContainerStatusResponse.class);
                Test.stopTest();
            	system.assert(Constant_Util.EXCEPTION_OCCURRED.equals(result.Problem.Title));
        } 
    }
       
    
    @isTest
    Public static void getLocalBusinessHoursServiceDateTest(){
        dateTime dt = dateTime.newInstance(2014, 9, 15, 12, 30, 0);
        string availDate = '12/22/2019';
        Case c = new Case();
        c.Location__c = '0013F00000ORWZLQA5';
        IVRContainerServices.getLocalBusinessHoursServiceDate(dt,c);
    }
    @isTest
    Public static void  getNextAvailableDateTest2(){
        date myDate1 = date.newInstance(2019, 12, 17);
        date myDate2 = date.newInstance(2019, 13, 17);
        List<Date> availDateSet= new List<Date>();
        availDateSet.add(myDate1);
        availDateSet.add(myDate2);
        date myDate3 = date.newInstance(2019, 11, 17);
        date myDate4 = date.newInstance(2019, 10, 17);
        Set <Date>  woAvailDates = new Set<Date>(); 
        woAvailDates.add(myDate3);
        woAvailDates.add(myDate4); 
        // Id businessHoursId = '0013F00000ORWZLQA5';
        BusinessHours bh = [select id from businesshours where IsDefault=true];
        string locZone = 'tst';
        IVRContainerServices.getNextAvailableDate(bh.id,woAvailDates,availDateSet,locZone);
    }
    
    @isTest
    Public static void getconverlocalTimeZone(){
        dateTime dt = dateTime.newInstance(2014, 9, 15, 12, 30, 0);
        string locZone = 'gmt';
        IVRContainerServices.converlocalTimeZone(dt,locZone);
    }
    
    @isTest
    Public static void testgetBusinessHoursServiceDate(){
        BusinessHours bh = [select id from businesshours where IsDefault=true];
        dateTime dt = dateTime.newInstance(2014, 9, 15, 12, 30, 0);
        string locZone = 'gmt';
        IVRContainerServices.getBusinessHoursServiceDate(bh.id,dt,0000000);
    }
    //test 
    @isTest static void getNextAvailableDateTest(){
        //test class errors - SDT - 33363
        User usr = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name ='System Administrator' limit 1];
        System.runAs(usr){
            BusinessHours bh = [select id from businesshours where IsDefault=true];
            string locZone='gmt';
            date myDate1 = date.newInstance(2019, 12, 17);
            date myDate2 = date.newInstance(2019, 12, 16);
            List<Date> availDateSet= new List<Date>();
            availDateSet.add(myDate1);
            availDateSet.add(myDate2);
            set<Date> woAvailDates = new set<Date>();
            woAvailDates.addAll(availDateSet);
            IVRContainerServices.getNextAvailableDate(bh.id,woAvailDates,availDateSet,locZone);
        }
    }
}