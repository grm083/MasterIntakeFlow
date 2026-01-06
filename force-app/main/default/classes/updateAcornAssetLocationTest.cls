@isTest
public class updateAcornAssetLocationTest {

    
    @testSetup static void Setup(){
        Profile p = TestDataFactory.getProfile('System Administrator');
        User u = TestDataFactory.createUser(p);
        insert u;
        Account a = new Account();
        a.Name = 'Test Account';
        a.OwnerId = u.id;
        insert a;
        List<Account> lccs = TestDataFactory.createLocation('Test Location',u,a.id);
        List<Product2> prod = TestDataFactory.createProduct('Test Product');
        List<Contact> con = TestDataFactory.createContact('Bruce', 'Lee',a,u);
        List<Asset> asst = TestDataFactory.createAsset('Test Asset', a, con[0], prod[0], u, lccs[0]);
        List<Asset> asstDet = TestDataFactory.createAsset('Test Asset Detail', a, con[0], prod[0], u, lccs[0]);
		asstDet[0].Service_Header_Id__c = asst[0].id;
        
        insert lccs;
        insert prod;
        insert con;
        insert asst;
        insert asstDet;
        
    }
    
    @isTest static void testUpdateLocation(){
        Asset asst = [SELECT Id, Container_Position__c FROM Asset LIMIT 1];
        
        
        Test.startTest();
        asst.Container_Position__c = 'back door';
        update asst;
        
        List<AssetHistory> ahist = [SELECT Id FROM AssetHistory WHERE AssetId = :asst.id];
        Map<Id,Asset> revertAssets = new Map<Id, Asset>();
        revertAssets.put(asst.id,asst);
        updateAcornAssetLocation.revertAssets(revertAssets);
        Test.stopTest();
        
    }
    
}