/**
* @Name          BATCH_DuplicateCaseAssetProcessorTest
* @Author        Accenture
* @Date          28/01/2020
* @Description   Test class for BATCH_DuplicateCaseAssetProcessor
*/
@isTest
public class BATCH_DuplicateCaseAssetProcessorTest {
    
    private static final String SYSTEM_ADMIN = 'System Administrator';
    private static final String TEST_NAME = 'Test';
    private static final String PICKUP = 'Pickup';
    private static final String EXTRA_PICKUP = 'Extra Pickup';
    private static final string COMMERCIAL = 'Commercial';
    private static final string SCHEDULED ='Scheduled';
    private static final string REPAIRS = 'Repairs';
    private static final string COMPACTOR = 'COMPACTOR';
    
    @testSetup static void setup() {
        Profile p = TestDataFactory.getProfile(SYSTEM_ADMIN);
        User usr = TestDataFactory.createUser(p);
        Database.insert(usr);  
        system.runAs(usr){
            list<Account> acclist = TestDataFactory.createAccount(Constant_Util.KEYWORD_TEST, usr);
            Database.insert(acclist);
            list<Account> locationlist = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, acclist.get(0).id);
            locationlist[0].tz__Timezone_SFDC__c = 'America/Chicago';
            Database.insert(locationlist);
            list<Contact> conlist = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST,Constant_Util.CONSTANT_LAST, acclist.get(0), usr);
            Database.insert(conlist);
            list<product2> productlist = TestDataFactory.createProduct(Constant_Util.KEYWORD_TEST);
            productlist[0].ProductTypeSelected__c = COMPACTOR;
            productlist[0].Family = COMMERCIAL;
            
            Database.insert(productlist);
            list<Asset> assetlist = TestDataFactory.createAsset(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                                productlist.get(0), usr, locationlist.get(0));
            assetlist[0].Supplier__c = acclist[1].Id;
            Database.insert(assetlist);
            
            list<Asset>childassetlist = TestDataFactory.createChildAsset(Constant_Util.CONSTANT_FIRST);
            childassetlist[0].Supplier__c = acclist[1].Id;
            childassetlist[0].parentId = assetlist[0].Id;
            childassetlist[0].Service_Header_Id__c = assetlist[0].Id;
            childassetlist[0].Service_Type__c='Pickup';
            childassetlist[0].Occurrence_Type__c='Scheduled';
            Database.insert(childassetlist);
            
            Test.startTest();
            list<Case> caselist = TestDataFactory.createCase(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                             usr, locationlist.get(0), assetlist.get(0));
            caselist[0].Service_Date__c = system.today() + 1;
            caselist[0].SLA_Service_Date_Time__c = system.today() + 2;
            Database.insert(caselist);
        }
	}
    
     private static testmethod void duplicateDataCheck(){
        user currentuser = [select id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        Case c = [select Id from case limit 1];
		List<SBS_Case_Asset__c> CAList=[select id,Asset_Header__c,AssetId__c,CaseId__c,Asset_Service_Type__c from SBS_Case_Asset__c where CaseId__c=:c.Id];
        System.assertEquals(1, CAList.size());
		SBS_Case_Asset__c newCA = CAList[0].clone(false, false, false, false);
        Database.insert(newCA);
        System.assertEquals(2, [select id,Asset_Header__c,AssetId__c,CaseId__c,Asset_Service_Type__c from SBS_Case_Asset__c where CaseId__c=:c.Id].size());
        List<SBS_Case_Asset__c> batchCAList=[SELECT Id,Name,Asset_Header__c, AssetId__c, CaseId__c, Asset_Service_Type__c,CreatedDate,CaseId__r.CaseNumber FROM SBS_Case_Asset__c WHERE CaseId__c=:c.Id];
        Database.BatchableContext currentScope;
        BATCH_DuplicateCaseAssetProcessor batchVar = new BATCH_DuplicateCaseAssetProcessor();
        System.assertEquals(0, batchVar.duplicateCSVRowValues.size());
        System.assertEquals(0, batchVar.AllCSVRowValues.size());
        Test.startTest();
        System.runAs(currentuser){
            batchVar.execute(currentScope, batchCAList);
            batchVar.finish(currentScope);
        }
        Test.stopTest();
        System.assertEquals(1, batchVar.duplicateCSVRowValues.size());
        System.assertEquals(2, batchVar.AllCSVRowValues.size());
    }
}