@isTest
public class UpdateAssetOnCaseTest {
private static final string CUSTOMER_SERVICE = 'Customer Service';//Modified for SDT-33456
    @testSetup static void setup(){
		Id serviceHeaderRecId = Schema.SobjectType.Asset.getRecordTypeInfosByName().get('Service Header').getRecordTypeId();
        Id serviceDetailRecId = Schema.SobjectType.Asset.getRecordTypeInfosByName().get('Service Detail').getRecordTypeId();
        Id standardRecType = Schema.SobjectType.Case.getRecordTypeInfosByName().get('Standard Case').getRecordTypeId();
        List<Asset> assetHeaders = new List<Asset>();
        List<Asset> assetDetails = new List<Asset>();
        
        Asset a1 = new Asset(Name = '4 Yard Dumpster', Recordtypeid = serviceHeaderRecId, Duration__c = 'Temporary');
        Asset a2 = new Asset(Name = '8 Yard Dumpster', Recordtypeid = serviceHeaderRecId, Duration__c = 'Temporary');
        assetHeaders.add(a1);
        assetHeaders.add(a2);
        insert assetHeaders;
        
        Asset ad1 = new Asset(Name = '4 Yard Dumpster', Recordtypeid = serviceDetailRecId, Duration__c = 'Temporary', Service_Header_Id__c = a1.id, is_core_service__c = true);
        Asset ad2 = new Asset(Name = '4 Yard Dumpster', Recordtypeid = serviceDetailRecId, Duration__c = 'Temporary', Service_Header_Id__c = a2.id, is_core_service__c = true);
        assetDetails.add(ad1);
        assetDetails.add(ad2);
        insert assetDetails;
        
        
        list<Case> case1 = TestDataFactory.createNewCase();
       	case1[0].RecordTypeId = standardRecType;
        case1[0].Status = 'New';
        case1[0].Tracking_Number__c =  'T22510938';
        case1[0].Origin = 'Officetrax';
        case1[0].AssetId = a1.id;
        case1[0].AssetDetail__c = ad1.id;
        //System.debug('Case[0]------ ' + case1[0]);
        insert case1;
        
        list<Case>case2 = TestDataFactory.createNewCase();
        case2[0].RecordTypeId = standardRecType;
        case2[0].Status = 'New';
        case2[0].Tracking_Number__c =  'T1111111';
        case2[0].Origin = 'Officetrax';
        case2[0].AssetId = a1.id;
 		insert case2;
        
        //Profile p = TestDataFactory.getProfile('System Administrator'); //Commented for SDT-33456
        Profile p = TestDataFactory.getProfile(CUSTOMER_SERVICE); //Modified for SDT-33456
        User u = TestDataFactory.createUser(p);
        Database.insert(u); //Modified for SDT-33456        
    }
    
    @isTest static void testAssetUpdateWithDetail(){
        Test.startTest();
        Id serviceHeaderRecId = Schema.SobjectType.Asset.getRecordTypeInfosByName().get('Service Header').getRecordTypeId();
        //Case c = [SELECT Id, AssetId FROM Case WHERE Tracking_Number__c = 'T22510938' LIMIT 1]; //Commented for SDT-33456
        List<Case> c = [SELECT Id, AssetId FROM Case WHERE Tracking_Number__c = 'T22510938' LIMIT 1]; //Modified for SDT-33456
        Asset a = [SELECT Id FROM Asset WHERE Name = '8 Yard Dumpster' AND RecordTypeId = :serviceHeaderRecId LIMIT 1];
        
        c[0].AssetId = a.id; //Modified for SDT-33456
        Database.update(c); //Modified for SDT-33456
        Test.stopTest();
    }
    
    @isTest static void testAssetUpdateWithoutDetail(){
        Test.startTest();
        Id serviceHeaderRecId = Schema.SobjectType.Asset.getRecordTypeInfosByName().get('Service Header').getRecordTypeId();
        //Case c = [SELECT Id FROM Case WHERE Tracking_Number__c = 'T1111111' LIMIT 1]; //Commented for SDT-33456
        List<Case> c = [SELECT Id FROM Case WHERE Tracking_Number__c = 'T1111111' LIMIT 1]; //Modified for SDT-33456
        Asset a = [SELECT Id FROM Asset WHERE Name = '8 Yard Dumpster' AND RecordTypeId = :serviceHeaderRecId LIMIT 1];
        
        c[0].AssetId = a.id; //Modified for SDT-33456
        Database.update(c); //Modified for SDT-33456
        Test.stopTest();
    }
}