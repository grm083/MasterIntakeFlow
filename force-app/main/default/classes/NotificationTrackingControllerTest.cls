/**
* @author Devendra Patel
* @date 09/08/2020
* @description : Apex class NotificationTrackingControllerTest 
**/

@isTest(seeAllData = false)
public class NotificationTrackingControllerTest {
    
    
    /**
    * @author Devendra Patel
    * @date 09/08/2020
    * @description : Apex method setup 
    **/
    // method for setting up data    
    @testSetup static void setup() {
        Profile p = TestDataFactory.getProfile(Constant_Util.SYSTEM_ADMINISTRATOR);
        User usr = TestDataFactory.createUser(p);
        Database.insert(usr);
        
        system.runAs(usr){
            list<Account> acclist = TestDataFactory.createAccount(Constant_Util.KEYWORD_TEST, usr);
            Database.insert(acclist);
            
            list<Account> locationlist = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, acclist.get(0).id);
            locationlist[0].tz__Timezone_SFDC__c = 'America/Los_Angeles';
            locationlist[0].tz__Timezone__c = 'EST';
            Database.insert(locationlist);
            
            //list<Contact> conlist = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST,Constant_Util.CONSTANT_LAST, acclist.get(0), usr);
            //Database.insert(conlist);
            
             List<Contact> conlist = new List<Contact>();
          Contact con1 = new Contact(FirstName = 'FirstContact', LastName = 'lastname', phone = '9999999999', 
                                  Accountid = acclist.get(0).id, OwnerId = usr.id, Email='testfrom@test.com');
        	conlist.add(con1);
              Contact con2 = new Contact(FirstName = 'SecondContact', LastName = 'lastname', phone = '9999999999', 
                                  Accountid = acclist.get(0).id, OwnerId = usr.id, Email='testfrom@test.com');
        	conlist.add(con2);
              Contact con3 = new Contact(FirstName = 'ThirdContact', LastName = 'lastname', phone = '9999999999', 
                                  Accountid = acclist.get(0).id, OwnerId = usr.id, Email='testfrom@test.com');
        	conlist.add(con3);
              Contact con4 = new Contact(FirstName = 'ForthContact', LastName = 'lastname', phone = '9999999999', 
                                  Accountid = acclist.get(0).id, OwnerId = usr.id, Email='testfrom@test.com');
        	conlist.add(con4);
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
            caselist[0].ContactId  = conlist[0].id;
            Database.insert(caselist[0]);
            
            // list<Asset> assetlist2 = TestDataFactory.createAsset(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
              //                                                  productlist.get(0), usr, locationlist.get(0));
            //assetlist2[0]. Supplier__c = acclist[1].Id;
           
            
             List<Asset> assetlist2 = new List<Asset>();
        		asset ast = new asset(Name = Constant_Util.CONSTANT_FIRST, AccountId = locationlist.get(0).Id, ContactId = conlist.get(0).id, product2id = productlist.get(0).id, OwnerId = usr.id,
                              Location__c = locationlist.get(0).id, Recordtypeid = TestDataFactory.getRecordType('Service Header','Asset'), Duration__c = 'Temporary',Acorn_SID__c='999');
       		 assetlist2.add(ast);
             Database.insert(assetlist2);
            
            list<Case> caselist2 = TestDataFactory.createCase(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                             usr, locationlist.get(0), assetlist2.get(0));
            caselist2[0].AccountId = acclist.get(0).Id;
            caselist2[0].Service_Date__c = system.today() + 2;
            caselist2[0].ContactId  = conlist[1].id;
            Database.insert(caselist2[0]);
            
             List<Asset> assetlist3 = new List<Asset>();
        		asset ast3 = new asset(Name = Constant_Util.CONSTANT_FIRST, AccountId = locationlist.get(0).Id, ContactId = conlist.get(0).id, product2id = productlist.get(0).id, OwnerId = usr.id,
                              Location__c = locationlist.get(0).id, Recordtypeid = TestDataFactory.getRecordType('Service Header','Asset'), Duration__c = 'Temporary',Acorn_SID__c='999');
       		 assetlist3.add(ast3);
             Database.insert(assetlist3);
            
            Asset srvcDetail3 = TestDataFactory.createChildAsset('Test Asset')[0];
            srvcDetail3.Service_Header_Id__c	 = assetlist3.get(0).Id;
            srvcDetail3.Is_Core_Service__c = true;
            srvcDetail3.Acorn_SBID__c = 880763;
            srvcDetail3.ParentId = assetlist3.get(0).Id;
            Database.insert(srvcDetail3);
            
            
            list<Case> caselist3 = TestDataFactory.createCase(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                             usr, locationlist.get(0), assetlist3.get(0));
            caselist3[0].AccountId = acclist.get(0).Id;
            caselist3[0].Service_Date__c = system.today() + 3;
            caselist3[0].ContactId  = conlist[2].id;
            Database.insert(caselist3[0]);
            
        }        
    }    
    
    
    /**
    * @author Devendra
    * @date 09/08/2020
    * @description : testing getAssetHeaders
    **/
    @isTest static void testGetAssetHeaders(){
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name ='System Administrator' limit 1];
        system.runAs(currentuser){
            Case cse = [SELECT Id, AssetId, Asset.Acorn_SBID__c FROM Case LIMIT 1];
            Test.startTest();
                List<NotificationTrackingController.assetWrapper> data = NotificationTrackingController.getAssetHeaders(cse.Id,false);
                List<NotificationTrackingController.assetWrapper> data2 = NotificationTrackingController.getAssetHeaders(cse.Id,true);
                system.assert(data.size()>0);
            Test.stopTest();
        }
    }
    
    /**
    * @author Devendra
    * @date 09/08/2020
    * @description : testing getNotificationTrackingData
    **/
    @isTest static void getNotificationTrackingData(){
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name ='System Administrator' limit 1];
        string pageNumber='1';
        String pageSize='10';
       system.runAs(currentuser){
            Case cse = [SELECT Id, AssetId, Asset.Acorn_SBID__c FROM Case WHERE Contact.FirstName = : 'FirstContact'  LIMIT 1];
            Test.startTest();
                NotificationTrackingController.NotificationTrackingDataWrap data = NotificationTrackingController.getTrackingData(cse.AssetId,pageNumber,pageSize);
            system.debug('dat--!>' + data);    
            system.assert(1 == data.dataWrapNotifTrackLst.size());
            Test.stopTest();
        }
    }
    
    /**
    * @author Devendra
    * @date 09/08/2020
    * @description : testing getNotificationTrackingData
    **/
    @isTest static void getNotificationTrackingDataWithoutAssetDetail(){
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name ='System Administrator' limit 1];
        string pageNumber='1';
        String pageSize='10';
        system.runAs(currentuser){ 
            Case cse = [SELECT Id, AssetId, Asset.Acorn_SBID__c FROM Case  WHERE Contact.FirstName =: 'SecondContact' LIMIT 1];
            Test.startTest();
                NotificationTrackingController.NotificationTrackingDataWrap data = NotificationTrackingController.getTrackingData(cse.AssetId,pageNumber,pageSize);
            system.debug('dat.notifMessage--!>' + data.notifMessage);    
            system.assert(data.notifMessage == Constant_Util.ASSET_WITHOUT_SBID);
            Test.stopTest();
        }
    }
    
    
     /**
    * @author Devendra
    * @date 09/08/2020
    * @description : testing getNotificationTrackingData
    **/
    @isTest static void getNotificationTrackingDataWithSBIDonAssetDetail(){
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name ='System Administrator' limit 1];
        string pageNumber='1';
        String pageSize='10';
        system.runAs(currentuser){
            Case cse = [SELECT Id, AssetId, Asset.Acorn_SBID__c FROM Case  WHERE Contact.FirstName =: 'ThirdContact' LIMIT 1];
            Test.startTest();
                NotificationTrackingController.NotificationTrackingDataWrap data = NotificationTrackingController.getTrackingData(cse.AssetId,pageNumber,pageSize);
            system.assert(1 == data.dataWrapNotifTrackLst.size());
            Test.stopTest();
        }
    }
    
    
}