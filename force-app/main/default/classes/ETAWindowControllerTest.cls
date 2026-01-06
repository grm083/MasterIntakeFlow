/**
* @author Accenture
* @date 3/28/2019
* @description : Apex class ETAWindowControllerTest 
**/
@isTest(seeAllData = false)
public class ETAWindowControllerTest {

    /**
    * @author Accenture
    * @date 2/27/2019
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
            locationlist[0].tz__Timezone__c = 'EST';
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
            
        }        
    }    
    
    /**
    * @author Accenture
    * @date 2/27/2019
    * @description : Apex method getETAStatusPositiveTest 
    **/
    @isTest static void getETAStatusPositiveTest(){
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name ='System Administrator' limit 1];
        system.runAs(currentuser){
            Case cse = [select Id, AssetId, Asset.Acorn_SBID__c FROM Case limit 1];
            Account acc = [select Id FROM Account limit 1];
            Test.startTest();
                ETAWindowController.StatusWrap data = ETAWindowController.getStatusData(cse.Id, cse.AssetId);
                ETAWindowController.StatusWrap data2 = ETAWindowController.getStatusDataLocation(acc.Id, cse.AssetId);
                system.assert(3 == data.dataWrapETAServicesLst.size());
            Test.stopTest();
        }
    }
    
    /**
    * @author Accenture
    * @date 2/27/2019
    * @description : Apex method blankAcornSBIDTest
    **/
    @isTest static void blankAcornSBIDTest(){
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name ='System Administrator' limit 1];
        system.runAs(currentuser){
            Case cse = [select Id, AssetId, Asset.Acorn_SBID__c FROM Case limit 1];
             Account acc = [select Id FROM Account limit 1];
            Asset assetHeader = [select Id, Acorn_SBID__c FROM Asset WHERE Id =: cse.AssetId limit 1];
            assetHeader.Acorn_SBID__c = null;
            update assetHeader;
            
			Asset assetDetail = [select Id, Acorn_SBID__c FROM Asset WHERE RootAssetId =: cse.AssetId AND 
                         RecordType.Name =: Constant_Util.SERVICE_DETAIL limit 1];
			assetDetail.Acorn_SBID__c = null;
            update assetDetail;
            Test.startTest();
                ETAWindowController.StatusWrap data = ETAWindowController.getStatusData(cse.Id, cse.AssetId);
                ETAWindowController.StatusWrap data2 = ETAWindowController.getStatusDataLocation(acc.Id, cse.AssetId);
                system.assert(data.ETAMessage == Constant_Util.NO_ETA);
            Test.stopTest();
        }
    }
    /**
    * @author Accenture
    * @date 2/27/2019
    * @description : Apex method getETAStatusRespNegativeTest (Blank http response)
    **/
    @isTest static void getETAStatusRespNegativeTest(){
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name ='System Administrator' limit 1];
        system.runAs(currentuser){
            Case cse = [select Id, AssetId, Asset.Acorn_SBID__c FROM Case limit 1];
            Account acc = [select Id FROM Account limit 1];
			MockETAStatusResponse.ETA_STATUS_MOCK_RESPONSE = '';
            Test.startTest();
                ETAWindowController.StatusWrap data = ETAWindowController.getStatusData(cse.Id, cse.AssetId);
                ETAWindowController.StatusWrap data2 = ETAWindowController.getStatusDataLocation(acc.Id, cse.AssetId);
                system.assert(data.ETAMessage == Constant_Util.NO_ETA);
            Test.stopTest();
        }
    }
    /**
    * @author Accenture
    * @date 2/27/2019
    * @description : Apex method blankHttpDataTest (http response with blank data)
    **/
    @isTest static void blankHttpDataTest(){
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name ='System Administrator' limit 1];
        system.runAs(currentuser){
            Case cse = [select Id, AssetId, Asset.Acorn_SBID__c FROM Case limit 1];
            Account acc = [select Id FROM Account limit 1];
			MockETAStatusResponse.ETA_STATUS_MOCK_RESPONSE = '{"data": {"future": [],"present": [],"past": []}, "problem": {}}';
            Test.startTest();
                ETAWindowController.StatusWrap data = ETAWindowController.getStatusData(cse.Id, cse.AssetId);
                ETAWindowController.StatusWrap data2 = ETAWindowController.getStatusDataLocation(acc.Id, cse.AssetId);
                system.assert(data.ETAMessage == Constant_Util.NO_ETA);
            Test.stopTest();
        }
    }

    /**
    * @author Accenture
    * @date 2/27/2019
    * @description : testing getAssetHeaders
    **/
    @isTest static void testGetAssetHeaders(){
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name ='System Administrator' limit 1];
        system.runAs(currentuser){
            Case cse = [select Id, AssetId, Asset.Acorn_SBID__c FROM Case limit 1];
            Test.startTest();
                List<ETAWindowController.assetWrapper> data = ETAWindowController.getAssetHeaders(cse.Id,false);
                List<ETAWindowController.assetWrapper> data2 = ETAWindowController.getAssetHeaders(cse.Id,true);
                system.assert(data.size()>0);
            Test.stopTest();
        }
    }
    /**
    * @description :  Defect-14080 . Check for update on Service Date  
    **/
    @isTest static void checkServiceDateOutputTest(){
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name ='System Administrator' limit 1];
        system.runAs(currentuser){
              Case cse = [select Id, AssetId, Location__r.tz__Timezone__c, Location__r.tz__Timezone_SFDC__c, Asset.Acorn_SBID__c FROM Case limit 1];
                //MockETAStatusResponse.ETA_STATUS_MOCK_RESPONSE = getMockServiceDate;
                 
            Test.startTest();
                ETAWindowController.StatusWrap data = ETAWindowController.getStatusData(cse.Id, cse.AssetId);
                //System.debug('**** data.dataWrapETAServicesLst' + data.dataWrapETAServicesLst );
		
		Datetime GMTDate =   Datetime.newInstanceGmt(2020,8,8,0,0,0);
				String strConvertedDate = GMTDate.format('MM/dd/yyyy hh:mm a', cse.Location__r.tz__Timezone_SFDC__c );
				String expectedtime = strConvertedDate.right(8);
		
		system.assert(data.ETAMessage != Constant_Util.NO_ETA);
		
            	for (StatusWrapper sw: data.dataWrapETAServicesLst)
                {
                    if(sw.etaWindow.contains(Constant_Util.PICKUP_TEXT))
                    {
                       String expectedDate=Constant_Util.PICKUP_TEXT + expectedtime +Constant_Util.OPEN_BRACE
                                  + cse.Location__r.tz__Timezone__c + Constant_Util.CLOSE_BRACE ;
                       //String expectedDate = 'Picked up at 05:00 PM (PST)';
                       system.assert(expectedDate.equalsIgnorecase(sw.etaWindow	), 'etaWindow Data variance ' +sw.etaWindow +' vs ' + expectedDate) ; 
                    }
                    
                    if(sw.serviceStatusDate!=null)
                    {
                        system.assert(sw.serviceStatusDate.contains(cse.Location__r.tz__Timezone__c), 'serviceStatusDate Data variance ' +sw.serviceStatusDate ) ; 
                    }
                }
				
            Test.stopTest();
        }
    }	   
}