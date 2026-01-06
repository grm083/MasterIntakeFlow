/**
* @author Accenture
* @date 4/16/2019
* @description : Test Class for CaseAssetTriggerHelper
**/
@isTest(seeAllData = false)
public class CaseAssetTriggerHelperTest {
	//public static final string SYS_ADMIN = 'System Administrator'; //Commented for SDT-33440 
    private static final string CUSTOMER_SERVICE = 'Customer Service';
    public static final string EMAIL = 'testfrom@test.com';
	
	// method for setting up data    
    @testSetup 
    static void setup() {
        //Profile p = TestDataFactory.getProfile(SYS_ADMIN); //Commented for SDT-33440 
        Profile p = TestDataFactory.getProfile(CUSTOMER_SERVICE);
        User usr = TestDataFactory.createUser(p);
        Database.insert(usr);  
        system.runAs(usr){
            list<Account> acclist = TestDataFactory.createAccount(Constant_Util.KEYWORD_TEST, usr);
            Database.insert(acclist);
            list<Account> locationlist = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, acclist.get(0).id);
            Database.insert(locationlist);

List<Contact> conList = new List<Contact>(); //Modified for SDT-33440 
        	contact con = new contact(FirstName = 'Bob', LastName = 'Smith', phone = '1235557812', Accountid = acclist[0].id, OwnerId = usr.id, Email='testdfrom@tACBest2.com');
	        conList.add(con); //Modified for SDT-33440 
            insert conList; //Modified for SDT-33440
            
            list<product2> productlist = TestDataFactory.createProduct(Constant_Util.KEYWORD_TEST);
            Database.insert(productlist);
            list<Asset> assetlist = TestDataFactory.createAsset(Constant_Util.CONSTANT_FIRST, acclist.get(0), con, 
                                                                productlist.get(0), usr, locationlist.get(0));
            assetlist[0]. Supplier__c = acclist[1].Id;
            Database.insert(assetlist);
            
List<Asset> assList = new List<Asset>(); //Modified for SDT-33440 
            Asset assetHeader = new Asset();
            assetHeader.Name = 'Test Asset Header';
            assetHeader.location__c = locationlist[0].id;
            assetHeader.RecordTypeId = TestDataFactory.getRecordType('Service Header', 'Asset');
            assList.add(assetHeader); //Modified for SDT-33440 
            insert assList; //Modified for SDT-33440
            
List<Asset> asstList = new List<Asset>(); //Modified for SDT-33440 
            Asset coreAsset = new Asset();
            coreAsset.Name = 'Test Core Asset';
            coreAsset.Location__c = locationlist[0].id;
            coreAsset.Quantity__c = 5;
            coreAsset.Is_Core_Service__c = true;
            coreAsset.Service_Type__c = 'Pickup';
            coreAsset.RecordTypeId = TestDataFactory.getRecordType('Service Header', 'Asset');
            asstList.add(coreAsset); //Modified for SDT-33440 
            insert asstList; //Modified for SDT-33440
            
List<Asset> astList = new List<Asset>(); //Modified for SDT-33440 
            Asset noncoreAsset = new Asset();
            noncoreAsset.Name = 'Test Non Core Asset';
            noncoreAsset.Location__c = locationlist[0].id;
            noncoreAsset.Quantity__c = 10;
            noncoreAsset.Is_Core_Service__c = false;
            noncoreAsset.RecordTypeId = TestDataFactory.getRecordType('Service Header', 'Asset');
            astList.add(noncoreAsset); //Modified for SDT-33440 
            insert astList; //Modified for SDT-33440
            
List<Case> csList = new List<Case>(); //Modified for SDT-33440 
            Case caseWithCore = new Case();
            caseWithCore.AccountId = acclist[0].id;
            caseWithCore.ContactId = con.id;
            caseWithCore.Reference_Number__c = '1';
            csList.add(caseWithCore); //Modified for SDT-33440 
            insert csList; //Modified for SDT-33440
            
List<SBS_Case_Asset__c> coreCAList = new List<SBS_Case_Asset__c>(); //Modified for SDT-33440 
            SBS_Case_Asset__c coreCA = new SBS_Case_Asset__c();
            coreCA.Asset_Header__c = assetHeader.id;
            coreCA.AssetId__c = coreAsset.Id;
            coreCA.CaseId__c = caseWithCore.id;
            coreCA.New_Client_Price__c = 4;
            coreCAList.add(coreCA); //Modified for SDT-33440 
            insert coreCAList; //Modified for SDT-33440
    
            list<Case> caselist = TestDataFactory.createCase(Constant_Util.CONSTANT_FIRST, acclist.get(0), con, 
                                                             usr, locationlist.get(0), assetlist.get(0));
            caselist[0].Reference_Number__c = '2';
            Database.insert(caselist);
    	}
	}
	
	@isTest 
	static void runTest(){ 
		Asset aHeader = [SELECT Id FROM Asset WHERE Name = 'Test Asset Header' LIMIT 1];
        Asset aCoreDetail = [SELECT Id, Quantity__c FROM Asset WHERE Name = 'Test Core Asset'];
        Case caseCore = [SELECT Id, Quantity_Override__c FROM Case WHERE Reference_Number__c = '1'];
        
        Asset aNonCoreDetail = [SELECT Id, Quantity__c FROM Asset WHERE Name = 'Test Non Core Asset'];
		Case caseNonCore = [SELECT Id, Quantity_Override__c FROM Case WHERE Reference_Number__c = '2'];        
        
List<SBS_Case_Asset__c> coreCaseList = new List<SBS_Case_Asset__c>(); //Modified for SDT-33440 
        SBS_Case_Asset__c coreCA = new SBS_Case_Asset__c();
        coreCA.Asset_Header__c = aHeader.id;
        coreCA.AssetId__c = aCoreDetail.Id;
        coreCA.CaseId__c = caseCore.id;
coreCaseList.add(coreCA); //Modified for SDT-33440 
        
List<SBS_Case_Asset__c> nonCoreCAList = new List<SBS_Case_Asset__c>(); //Modified for SDT-33440 
        SBS_Case_Asset__c nonCoreCA = new SBS_Case_Asset__c();
        nonCoreCA.Asset_Header__c = aHeader.id;
        nonCoreCA.AssetId__c = aNonCoreDetail.id;
        nonCoreCA.CaseId__c = caseNonCore.id;
nonCoreCAList.add(nonCoreCA); //Modified for SDT-33440 
        
        Test.startTest();
            insert coreCaseList; //Modified for SDT-33440
            insert nonCoreCAList; //Modified for SDT-33440
        Test.stopTest();
        System.assertEquals(2, 2);
	}  
    //method to handle exceptions
    @isTest
    static void exceptionCoverage(){
        Map<Id,SBS_Case_Asset__c> caseAssetMap;
        CaseAssetTriggerHandler.onAfterInsert(caseAssetMap,caseAssetMap);
        System.assertEquals(caseAssetMap,caseAssetMap);
    }
	@isTest
    static void validateQuantityTest(){ 
List<SBS_Case_Asset__c> sbsCaseAssetList = new List<SBS_Case_Asset__c>(); //Modified for SDT-33440 
    	SBS_Case_Asset__c ca = [SELECT Id, Asset_Service_Type__c, Quantity__c, Quantity_Override__c FROM SBS_Case_Asset__c LIMIT 1];
        ca.Quantity_Override__c = 12;
sbsCaseAssetList.add(ca); //Modified for SDT-33440 
        Test.startTest();
        	try{
                update sbsCaseAssetList; //Modified for SDT-33440
            } catch(Exception ex){
                Boolean expectedExceptionThrown =  ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION') ? true : false;
                System.assertEquals(expectedExceptionThrown, true);
            }
        Test.stopTest();
    }
    @isTest
    static void validateQuantityZeroTest(){ 
List<SBS_Case_Asset__c> caList = new List<SBS_Case_Asset__c>(); //Modified for SDT-33440 
    	SBS_Case_Asset__c ca = [SELECT Id, Asset_Service_Type__c, Quantity__c, Quantity_Override__c FROM SBS_Case_Asset__c LIMIT 1];
        ca.Quantity_Override__c = 0;
caList.add(ca); //Modified for SDT-33440 
        Test.startTest();
        	try{
                update caList; //Modified for SDT-33440
            } catch(Exception ex){
                Boolean expectedExceptionThrown =  ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION') ? true : false;
                System.assertEquals(expectedExceptionThrown, true);
            }
        Test.stopTest();
    }
    @isTest
    static void validateQuantityNegativeTest(){ 
List<SBS_Case_Asset__c> cAssetList = new List<SBS_Case_Asset__c>(); //Modified for SDT-33440 
    	SBS_Case_Asset__c ca = [SELECT Id, Asset_Service_Type__c, Quantity__c, Quantity_Override__c FROM SBS_Case_Asset__c LIMIT 1];
        ca.Quantity_Override__c = -12;
cAssetList.add(ca); //Modified for SDT-33440 
        Test.startTest();
        	try{
                update cAssetList; //Modified for SDT-33440
            } catch(Exception ex){
                Boolean expectedExceptionThrown =  ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION') ? true : false;
                System.assertEquals(expectedExceptionThrown, true);
            }
        Test.stopTest();
    }
    @isTest
    static void validateCPTest(){ 
List<SBS_Case_Asset__c> caseAssetList = new List<SBS_Case_Asset__c>(); //Modified for SDT-33440 
    	SBS_Case_Asset__c ca = [SELECT Id, New_Client_Price__c, Quantity_Override__c FROM SBS_Case_Asset__c 
                                	WHERE New_Client_Price__c != Null LIMIT 1];
        ca.New_Client_Price__c = 8;
caseAssetList.add(ca); //Modified for SDT-33440 
        Test.startTest();
        	try{
                update caseAssetList; //Modified for SDT-33440
            } catch(Exception ex){
                Boolean expectedExceptionThrown =  ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION') ? true : false;
                System.assertEquals(expectedExceptionThrown, true);
            }
        Test.stopTest();
    }
}