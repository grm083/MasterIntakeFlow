/**
* @author Accenture
* @date 19/06/2020
* @description : Apex class DisplayCaseAssetController 
**/
@isTest(seeAllData = false)
public class DisplayCaseAssetControllerTest {

    /**
    * @author Accenture
    * @date 19/06/2020
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
            Database.insert(locationlist);
            
            list<Contact> conlist = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST,Constant_Util.CONSTANT_LAST, acclist.get(0), usr);
            Database.insert(conlist);

            list<product2> productlist = TestDataFactory.createProduct(Constant_Util.KEYWORD_TEST);
            productlist[0].Family = Constant_Util.COMMERCIAL;
            Database.insert(productlist);
            
            list<Asset> assetlist = TestDataFactory.createAsset(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                                productlist.get(0), usr, locationlist.get(0));
            assetlist[0]. Supplier__c = acclist[1].Id;
            Database.insert(assetlist);
            
            Asset srvcDetail = TestDataFactory.createChildAsset('Test Asset')[0];
            srvcDetail.Service_Header_Id__c	 = assetlist.get(0).Id;
            srvcDetail.Is_Core_Service__c = true;
            srvcDetail.Acorn_SBID__c = 980763;
            srvcDetail.ParentId = assetlist.get(0).Id;
            Database.insert(srvcDetail);
            
            list<Case> caselist = TestDataFactory.createCase(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                             usr, locationlist.get(0), assetlist.get(0));
            caselist[0].AccountId = acclist.get(0).Id;
            caselist[0].Service_Date__c = system.today() + 1;
            Database.insert(caselist[0]);
            
            List<SBS_Case_Asset__c> caseAssetList = new List<SBS_Case_Asset__c>();
            SBS_Case_Asset__c caseAsset1 = new SBS_Case_Asset__c(CaseId__c = caselist[0].Id, Asset_Header__c = caselist[0].AssetId,AssetId__c = srvcDetail.id);
            SBS_Case_Asset__c caseAsset2 = new SBS_Case_Asset__c(CaseId__c = caselist[0].Id, Asset_Header__c = caselist[1].AssetId,AssetId__c = srvcDetail.id);
        	caseAssetList.add(caseAsset1);
            caseAssetList.add(caseAsset2);
            Database.insert(caseAssetList);
        }        
    }    
    
    /**
    * @author Accenture
    * @date 19/06/2020
    * @description : Apex method getCaseAssetTest 
    **/
    @isTest static void getCaseAssetTest(){
        user currentuser = [SELECT id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        system.runAs(currentuser){
            Case cse = [select Id FROM Case limit 1];
            Test.startTest();
                List<SBS_Case_Asset__c> caseAssetLst = DisplayCaseAssetController.getCaseAsset(cse.Id);
            Test.stopTest();
        }
    }
    /**
    * @author Accenture
    * @date 19/06/2020
    * @description : Apex method updateCaseAssetTest 
    **/
    @isTest static void updateCaseAssetTest(){
        user currentuser = [SELECT id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        system.runAs(currentuser){
            List<SBS_Case_Asset__c> caseAssetLst = [select Id,Reason_Code__c,Quantity_Override__c,AssetId__r.Price__c FROM SBS_Case_Asset__c];
            Test.startTest();
		caseAssetLst[0].Quantity_Override__c = 0;
		caseAssetLst[0].Reason_Code__c = 'None';
            	try{
		   DisplayCaseAssetController.updateCaseAsset(caseAssetLst);
                } catch(Exception ex){
                    Boolean expectedExceptionThrown =  ex.getMessage().contains('Script-thrown exception') ? true : false;
                    System.assertEquals(expectedExceptionThrown, true);
                }
            	system.assert(2 == caseAssetLst.size());
            Test.stopTest();
        }
    }
}