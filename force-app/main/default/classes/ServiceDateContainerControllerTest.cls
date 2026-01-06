@isTest
public class ServiceDateContainerControllerTest {
      	private static final string KROGER = 'kroger';
       	private static final string NY_TIMEZONE = 'America/New_York';
        private static final string RITA = 'Rita';
        private static final string REPLY = 'Reply';
        private static final string COMPACTOR = 'COMPACTOR';
        private static final string TESTSUPPLIER = 'testsupplier';
        private static final string PRODUCT = '8 yrd';
        private static final string SUPPLIER = 'Supplier';
     	private static final string ASSET_NAME = '8 yrd Dumpster';
        private static final string CASE_NAME = 'First';
        private static final string ROLLOFF = 'Rolloff';
        private static final string PO_NUMBER = '1243';
		private static final string NAME = 'test';
    
     @testSetup
    public static void dataSetup() {
        
        Profile adminProfile = TestDataFactory.getProfile('System Administrator');
        User usr = TestDataFactory.createUser(adminProfile);
        Database.insert(usr); 
        system.runAs(usr){
             List<Account> acclist = TestDataFactory.createAccount(KROGER, usr,Constant_Util.CLIENT);
            acclist[0].AccountNumber = '8'; 
            
            Database.insert(acclist);
            
            List<Account> locationlist = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, acclist.get(0).id);
            
            locationlist[0].tz__Timezone_SFDC__c = NY_TIMEZONE;
            locationlist[0].tz__UTF_Offset__c = -4;
            Database.insert(locationlist);
            
            List<Contact> conlist = TestDataFactory.createContact(RITA, REPLY, acclist.get(0), usr);
            Database.insert(conlist);
            
            List<product2> productlist = TestDataFactory.createProduct(PRODUCT);
            productlist[0].Family = ROLLOFF;
            productlist[0].ProductTypeSelected__c = COMPACTOR;
            Database.insert(productlist);
            
            List<product2> productlist2 = TestDataFactory.createProduct(PRODUCT);
            productlist[0].Family = 'Commercial';
            productlist[0].ProductTypeSelected__c = COMPACTOR;
            Database.insert(productlist2);
                        
            list<Account> parentacclist = TestDataFactory.createAccountwithParent(Constant_Util.KEYWORD_TEST, usr ,acclist.get(0).id);
            Database.insert(parentacclist);
            
            list<Account> supplieracclist = TestDataFactory.createAccountwithoutParent(Constant_Util.KEYWORD_TEST, usr);
            Database.insert(supplieracclist);
            
            List<Project_Code__c> pCodeList = TestDataFactory.createProjectCode(acclist.get(0).Id);
            Database.insert(pCodeList);

            List<Asset> assetlist = TestDataFactory.createAsset(ASSET_NAME, acclist.get(0), conlist.get(0), productlist.get(0), usr, locationlist.get(0));
            assetlist[0].Supplier__c = parentacclist[0].Id;
            assetlist[0].Project_Code__c = pCodeList[0].Id; 
            Database.insert(assetlist);
            
            List<Asset> assetlist2 = TestDataFactory.createAsset(ASSET_NAME, acclist.get(0), conlist.get(0), productlist2.get(0), usr, locationlist.get(0));
            assetlist[0].Supplier__c = parentacclist[0].Id;
            assetlist[0].Project_Code__c = pCodeList[0].Id; 
            Database.insert(assetlist2);

            // This will return a caseList with 4 cases of Case Type = Pickup
            // and Case Sub Type = Extra Pickup
            List<Case> caselist = TestDataFactory.createCase(CASE_NAME, acclist.get(0), conlist.get(0), usr, locationlist.get(0), assetlist.get(0));
			
            caselist[0].Status = Constant_Util.Case_New_Status;
            caselist[0].Case_Type__c = Constant_Util.PICKUP_CSTYPE;
            caselist[0].Case_Sub_Type__c = Constant_Util.EXTRA_PICKUP;
            caselist[0].Create_AM_and_PM_Pickups__c = true;          
            caselist[0].SLA_Service_Date_Time__c=System.now().addHours(3);
                
           List<Case> caselist2 = TestDataFactory.createCase(CASE_NAME, acclist.get(0), conlist.get(0), usr, locationlist.get(0), assetlist2.get(0));
			caselist2[0].Status = Constant_Util.Case_New_Status;
            caselist2[0].Case_Type__c = Constant_Util.PICKUP_CSTYPE;
            caselist2[0].Case_Sub_Type__c = Constant_Util.EXTRA_PICKUP;
            try{
                Database.insert(caselist);
            } catch(Exception ex){
                system.debug('Exception while inserting case:::'+ex.getStackTraceString());
            }
			
			 List<Entitlement> entitlementlist = TestDataFactory.createEntitlement(NAME , locationlist.get(0));
            entitlementlist[0].AccountId = caselist[0].Client__c;
            entitlementlist[0].service__c = Constant_Util.EXTRA_PICKUP;
            Database.insert(entitlementlist);
        }
    }
    
     public static testmethod void IsWMCapacityPlannerVisible_Positive()
    {
        List<Case> cselist = [SELECT id,Case_Type__c,Status,Availability_Checked__c,Location_Code__c,SLA_Service_DateTime__c,Client__r.Name,Asset.Supplier__r.Parent_Vendor_ID__c
                              FROM CASE 
                     		  LIMIT 1];   
      
   		 Test.startTest();
         Boolean  result = ServiceDateContainerController.IsWMCapacityPlannerVisible(cselist.get(0).id);      
         Test.stopTest();
    }
        
    public static testmethod void IsWMCapacityPlannerVisible_Negative()
    {   
        List<Case> cselist = [SELECT id,Case_Type__c,Status,Availability_Checked__c,Location_Code__c,SLA_Service_DateTime__c,
                              Asset.Product2.Family,
                              Client__r.Name,Asset.Supplier__r.Parent_Vendor_ID__c
                              FROM CASE 
                              LIMIT 1];   
       
         Test.startTest();
   		 for( Case c : cselist){
             Case cs= [select id, assetid,Create_AM_and_PM_Pickups__c,casenumber,SlaStartDate,Asset.Supplier__r.Parent_Vendor_ID__c,Asset.Product2.Family,SLA_Service_Date_Time__c,SLA_Service_DateTime__c from case where id =: c.id];
             Asset ast= [select id,product2id from asset where id =: c.assetid];
             Product2 p2 =[select id,family from product2 where id =: ast.product2id];
             p2.Family=COMPACTOR;
             update p2;
         }
        
        Boolean  result = ServiceDateContainerController.IsWMCapacityPlannerVisible(cselist.get(0).id);
        system.assert(result==false);
        Test.stopTest();
    }
    
     public static testmethod void IsMultiVisibleTest()
     {   
         List<Case> cselist = [SELECT id   FROM CASE LIMIT 1];
         GetCaseInformation.Wrapper wc=ServiceDateContainerController.IsMultiVisible(cselist[0].id);
         system.assert(wc.caseInfo!='');
     }
    

}