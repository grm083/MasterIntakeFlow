@isTest(seeAllData = false)
    public class CaseDetailCardControllerTest {
        
        @testSetup static void setup() {
            Profile p = TestDataFactory.getProfile('System Administrator');
            User usr = TestDataFactory.createUser(p);
            //User usr = TestDataFactory.createUser();
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
                Asset srvcDetail = TestDataFactory.createChildAsset('Test Asset')[0];
                srvcDetail.Service_Header_Id__c	 = assetlist[0].Id;
                srvcDetail.Is_Core_Service__c = true;
                srvcDetail.ParentId = assetlist[0].Id;
                Database.Insert(srvcDetail);
                Test.startTest();
                list<Case> caselist = TestDataFactory.createCase(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                                 usr, locationlist.get(0), assetlist.get(0));
                caselist[0].Service_Date__c = system.today() + 1;
                caselist[0].PurchaseOrder_Number__c =  Constant_Util.PO_VALUE_TEST;
                Database.insert(caselist);
                list<Case> testCaselist = TestDataFactory.createCase(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                                 usr, locationlist.get(0), assetlist.get(0));
                testCaselist[0].Reference_Number__c = caselist[0].CaseNumber;
                testCaselist[0].Is_Multiple_Asset__c = true;
                testCaselist[0].AssetId = assetlist[0].Id;
                testCaselist[0].Origin = Constant_Util.Officetrax ;
                Database.insert(testCaselist);
                Test.stopTest();
            } 
            
        }
       @isTest static void getCaseDetailsTest(){
            user currentuser = [select id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
            system.runAs(currentuser){
            list<case> caselist = [select id, origin, contactid, Case_Type__c, Client__c, Location__c, 
                                       PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                       Service_Date__c,SLA_Service_Date_Time__c from case limit 1];
            Test.startTest();   
            Case cse = CaseDetailCardController.getCaseDetails(caselist[0].id);
            system.assert(cse != null);
            Test.stopTest();
            }
        }    
       @isTest static void callinvoketest1() {
            string[] assetlist = new String[]{};
            user currentuser = [select id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
            system.runAs(currentuser){
            list<case> caselist = [select id, origin, contactid, Case_Type__c, Client__c, Location__c, 
                                       PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                       Service_Date__c,SLA_Service_Date_Time__c from case limit 1];
            caselist[0].Origin = Constant_Util.ORIGIN_EMAIL;
            Database.update(caselist[0]);
            Test.startTest();   
            String status = CaseDetailCardController.callinvoke(caselist[0].id,caselist[0].Origin);
            system.assert(status == Constant_Util.SUCCESS);
            Test.stopTest();
            }
        } 
		@isTest static void callinvoketest2() {
            string[] assetlist = new String[]{};
            user currentuser = [select id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
            system.runAs(currentuser){
            list<case> caselist = [select id, origin, contactid, Case_Type__c, Client__c, Location__c, 
                                       PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                       Service_Date__c,SLA_Service_Date_Time__c from case limit 1];
            caselist[0].Origin = Constant_Util.EMPTY_STRING;
            Database.update(caselist[0]);
            Test.startTest();   
            String status = CaseDetailCardController.callinvoke(caselist[0].id,caselist[0].Origin);
            system.assert(status == Constant_Util.SUCCESS);
            Test.stopTest();
            }
        }
// Modified for SDT-33446 Start
        @isTest static void callinvoketest3() {
            string[] assetlist = new String[]{};
            user currentuser = [select id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
            system.runAs(currentuser){
            list<case> caselist = [select id, origin, contactid, Case_Type__c, Client__c, Location__c, 
                                       PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                       Service_Date__c,SLA_Service_Date_Time__c from case limit 1];
            Test.startTest();   
            String status = CaseDetailCardController.callinvoke(caselist[0].Origin,caselist[0].Origin);
            system.assert(status == Constant_Util.SUCCESS);
            Test.stopTest();
            }
        }
        // Modified for SDT-33446 End
  @isTest static void getselectOptionstest(){
            user currentuser = [select id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
            system.runAs(currentuser){
            list<case> caselist = [select id, origin, contactid, Case_Type__c, Client__c, Location__c,RecordTypeId, 
                                       PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                       Service_Date__c,SLA_Service_Date_Time__c from case limit 1];
            caselist[0].RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Constant_Util.Pickup_Case_Rec_Type).getRecordTypeId();
            string cse = Constant_Util.OBJECT_CASE;
            Database.update(caselist[0]);
            map<String, String> responseHeaders = new Map<String, String>{'Client_Id' => 'abdhb123'};
            //Changes related to SDT-38437  --removed these values from fake response -{"value":"IVR Email","label":"IVR Email","attributes":null},{"value":"IVR Phone","label":"IVR Phone","attributes":null},{"value":"Auto Closed","label":"Auto Closed","attributes":null},{"value":"OfficeTrax","label":"OfficeTrax","attributes":null}
            SingleRequestMock fakeResponse = new SingleRequestMock(200,
                                                 'Complete',
                                                 '{"controllerValues":{},"defaultValue":null,"eTag":"32113baa7c26132b94de4f20618f257f","url":"/services/data/v46.0/ui-api/object-info/Case/picklist-values/0121I000000JoJxQAK/Origin","values":[{"value":"Email","label":"Email","attributes":null},{"value":"Phone","label":"Phone","attributes":null},{"value":"Monitor","label":"Monitor","attributes":null},{"value":"E-Business","label":"E-Business","attributes":null},{"value":"MAS Service Setup","label":"MAS Service Setup","attributes":null},{"value":"Mobile Application","label":"Mobile Application","attributes":null},{"value":"The Wire","label":"The Wire","attributes":null},{"value":"External System","label":"External System","attributes":null},{"value":"Client Portal","label":"Client Portal","attributes":null},{"value":"Migration","label":"Migration","attributes":null},{"value":"Chat Now","label":"Chat Now","attributes":null}]}',
                                                 responseHeaders);
            PageReference pageRef = Page.SessionID;    
           Test.startTest();
                Test.setCurrentPage(pageRef);
                Test.setMock(HttpCalloutMock.class, fakeResponse);
               List<String> res = CaseDetailCardController.getselectOptions( caselist[0].Id);
                //Changes related to SDT-38437
                system.assertEquals(14, res.size());
            Test.stopTest();
            }
        }
       
    }