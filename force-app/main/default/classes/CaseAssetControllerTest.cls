@isTest
public class CaseAssetControllerTest {
    @testSetup
    public static void dataSetup() {
        Profile p = TestDataFactory.getProfile('System Administrator');
        User usr = TestDataFactory.createUser(p);
        Database.insert(usr);
        
        system.runAs(usr){
            Account clientAcc = TestDataFactory.createAccount(Constant_Util.KEYWORD_TEST, usr,'Client')[0];
            Database.insert(clientAcc);
            Account locAcc = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, clientAcc.id)[0];
            Database.insert(locAcc);
            Contact contct = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST,Constant_Util.CONSTANT_LAST, clientAcc, usr)[0];
            Database.insert(contct);
            Product2 prdct = TestDataFactory.createProduct('Sample Product Test')[0];
            Database.insert(prdct);
            Asset asst = TestDataFactory.createAsset('Test Asset', clientAcc,contct, prdct, usr,locAcc)[0];
            Database.insert(asst);
            List<Asset> childAssts = TestDataFactory.createChildAsset('Test Asset');
            childAssts[0].Service_Header_Id__c   = asst.Id;
            childAssts[0].ParentId = asst.Id;
            childAssts[0].Location__c = locAcc.Id;
            childAssts[1].Service_Header_Id__c   = asst.Id;
            childAssts[1].ParentId = asst.Id;
            childAssts[1].Location__c = locAcc.Id;
            Database.insert(childAssts);
            list<Case> caselist = TestDataFactory.createCase(Constant_Util.CONSTANT_FIRST, clientAcc, contct, 
                                                             usr, locAcc, asst);
            caselist[0].AccountId = clientAcc.Id;
            Database.insert(caselist[0]);
            SBS_Case_Asset__c cseAsset = new SBS_Case_Asset__c(CaseId__c = caselist[0].Id,Asset_Header__c = asst.Id,AssetId__c = childAssts[0].Id);
            Database.insert(cseAsset);
        }
    }
    
    public static testmethod void serviceAssetDetailTest(){
        Case cse = [select id from Case limit 1];
        test.startTest();
        CaseAssetController.serviceAssetDetail(cse.Id);
        test.stopTest();
    }
    
    public static testmethod void createAssetTest(){
        Case cse = [select id from Case limit 1];
        List<Asset> detailAssets = [select id,Service_Header_Id__c from Asset where recordtype.name='Service Detail'];
        system.debug('child assets'+detailAssets);
        String assetString = json.serialize(detailAssets);
        system.debug('json string'+assetString);
        test.startTest();
        CaseAssetController.createAsset(assetString, cse.Id);
        test.stopTest();
    }
}