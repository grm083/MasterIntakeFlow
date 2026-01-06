/**
* @author Shilpa
* @date 2/26/2019
* @description : Apex class IndicoWebServicesTest 

**/
@isTest(SeeAllData=false)
public class IndicoWebServicesTest {
    /**
* @description set the test data
*/ 
    // @testSetup static void setup() {
    //     Profile p = TestDataFactory.getProfile('System Administrator');        
    //     User usr = TestDataFactory.createUser(p);
    //     String Subject = 'TEST SUBJECT';
    //     String Body = 'Testing Email Subj';
    //     Database.insert(usr);
        
    //     system.runAs(usr){
    //         //create account
    //         list<Account> acclist = TestDataFactory.createAccount(Constant_Util.KEYWORD_TEST, usr,'Client');
    //         Database.insert(acclist);
            
    //         //create location
    //         list<Account> locationlist = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, acclist.get(0).id);
    //         Database.insert(locationlist);
            
    //         //create Second Location
    //         List<Account> seclocationLst = TestDataFactory.createLocation('Test Location', usr, acclist.get(0).id);
    //         Database.insert(seclocationLst);
            
    //         //create contact
    //         list<Contact> conlist = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST, 
    //                                                               Constant_Util.CONSTANT_LAST, acclist.get(0), usr);
    //         Database.insert(conlist);
            
    //         //create product
    //         list<product2> productlist = TestDataFactory.createProduct(Constant_Util.KEYWORD_TEST);
    //         Database.insert(productlist);
            
    //         //create vendor
    //         list<Account> supplieracclist = TestDataFactory.createAccount('testsupplier', usr,'Vendor');
    //         Database.insert(supplieracclist);
            
    //         //create asset
    //         list<Asset> assetlist = TestDataFactory.createAsset(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
    //                                                             productlist.get(0), usr, locationlist.get(0));
    //         assetlist[0].Supplier__c = supplieracclist.get(0).Id;
    //         assetlist[0].Quantity__c = 5;
    		
    //         Database.insert(assetlist);
            
    //         //create second asset
    //         list<Asset> secAssetList = TestDataFactory.createAsset('Test', acclist.get(0), conlist.get(0), 
    //                                                             productlist.get(0), usr, seclocationLst.get(0));
    //         Database.insert(secAssetList);
            
            
            
    //         //create case
    //         list<Case> caselist = TestDataFactory.createCase(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
    //                                                          usr, locationlist.get(0), assetlist.get(0));
    //         Database.insert(caselist);           
          
    //         IndicoEmailMessageFilter__c indicoEmailType = new IndicoEmailMessageFilter__c();
    //         indicoEmailType.Name = 'IndicoEmail';
    //         indicoEmailType.FilterConditionColumnName__c = 'All';
    //         indicoEmailType.FilterConditionValue__c = 'cct_sbs_test_17@wm.com';
    //         indicoEmailType.Type__c = 'WMPORTALS';
    //     	Database.insert(indicoEmailType);
            
    //         List<EmailMessage> lstEM = new List<EmailMessage>();
          
    //         EmailMessage objEM = new EmailMessage(Subject = Subject, TextBody = Body, ToAddress = 'cct_sbs_test_17@wm.com',
    //                                            FromAddress = 'testfrom@test.com', ParentId = caselist[0].Id,isIndicoEligible__c = true);
                    
    //         lstEM.add(objEM);
    //         Database.insert(lstEM);
            
    //     }
    // }
    
    // @isTest static void testEmailMessageDetails(){
    //      User usr = [Select id from User limit 1];
        
    //     system.runAs(usr){
    //          Case casebj = [SELECT Id,Location__c,Case_Type__c,Case_Sub_Type__c,ContactId,AssetId FROM Case LIMIT 1];
    //          casebj.Location__c = null;
	// 	     casebj.AssetId = null;
    //          casebj.ContactId = null;
    //          casebj.Case_Type__c = null;
    //          casebj.Case_Sub_Type__c = null;
    //          Database.update(casebj);
            
    //          List<EmailMessage> emsg = [Select id,ParentId,FromAddress,ToAddress,isIndicoEligible__c,CcAddress,Subject,TextBody from EmailMessage where ParentId =: casebj.Id];
    //          emsg[0].isIndicoEligible__c = true; 
    //          Database.update(emsg);           
    //          List<Account> locList = [Select id,Location_Code__c from Account where Name = 'Location' Limit 1];
    //          list<Asset> assetlist = [Select id from Asset limit 1];
    //          list<Contact> conlist = [Select id from Contact Limit 1];
    //          List<SFDCEmailMessage__c> sfdcEmsg = [Select id from SFDCEmailMessage__c where SFDCEmailMessageParentId__c =: casebj.Id];
                                     
    //     // Set up a test request
    //         RestRequest request = new RestRequest();
    //         RestResponse res = new RestResponse();
    //         request.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
            
    //         // Set request properties
    //         request.requestUri = '/services/apexrest/IndicoEmail/V1';
    //         request.httpMethod = 'POST';    
            
    //         // Set other properties, such as parameters
    //         String jsonMsg = '{"data": {"caseId":"'+casebj.Id+'","emailMessageId":"'+emsg[0].Id+'","cases": [{"location": "'+locList[0].Location_Code__c+'","assetheader": "'+assetlist[0].Id+'","contact":"'+conlist[0].Id+'","caseType":"Pickup","recordType":"Pickup Case","casesubType":"Empty and Return","casereason":"Contaminated","HasSFRule":false,"po":"123","profile":"123","psi":"123","serviceDate":"2020-12-08","errorMessage": null}]}}';
    //         request.requestBody = Blob.valueof(jsonMsg);         
            
    //          // Finally, assign the request to RestContext if used
    //         RestContext.request = request;
    //         RestContext.response = res;
            
    //         Test.startTest();            	     	
    //             IndicoWebServices.getIndicoCaseDetails();
    //         Test.stopTest();
            

    //         system.assert(jsonMsg != null);
    //         system.assert(res.responseBody != null);
    //        }
        
    //  }
     

    // //Method to Cover Catch Expression
    //  @isTest static void testThirdEmailMessageDetails(){
    //      User usr = [Select id from User limit 1];
        
    //     system.runAs(usr){
    //          Case casebj = [SELECT Id,Location__c,Case_Type__c,Case_Sub_Type__c,ContactId,AssetId FROM Case LIMIT 1];
    //          casebj.Location__c = null;
	// 	     casebj.AssetId = null;
    //          casebj.ContactId = null;
    //          casebj.Case_Type__c = null;
    //          casebj.Case_Sub_Type__c = null;
    //          Database.update(casebj);
            
    //          List<EmailMessage> emsg = [Select id,ParentId,FromAddress,ToAddress,isIndicoEligible__c,CcAddress,Subject,TextBody from EmailMessage where ParentId =: casebj.Id];
    //          emsg[0].isIndicoEligible__c = true; 
    //          Database.update(emsg);           
    //          List<Account> locList = [Select id,Location_Code__c from Account where Name = 'Location' Limit 1];
    //          list<Asset> assetlist = [Select id from Asset limit 1];
    //          list<Contact> conlist = [Select id from Contact Limit 1];
    //          List<SFDCEmailMessage__c> sfdcEmsg = [Select id from SFDCEmailMessage__c where SFDCEmailMessageParentId__c =: casebj.Id];
                                     
    //     // Set up a test request
    //         RestRequest request = new RestRequest();
    //         RestResponse res = new RestResponse();
    //         request.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
            
    //         // Set request properties
    //         request.requestUri = '/services/apexrest/IndicoEmail/V1';
    //         request.httpMethod = 'POST';    
            
    //         // Set other properties, such as parameters
    //         String jsonMsg = '{"data": {"caseId":"'+casebj.Id+'","emailMessageId":"'+emsg[0].Id+'","cases": [{"location": "'+locList[0].Id+'","assetheader": "'+assetlist[0].Id+'","contact":"'+conlist[0].Id+'","caseType":"Pickup","recordType":"Pickup Case","casesubType":"Empty and Return","casereason":"Contaminated","HasSFRule":false,"po":"123","profile":"123","psi":"123","serviceDate":"2020-12-08","errorMessage": null}]}}';
    //         request.requestBody = Blob.valueof(jsonMsg);         
            
    //          // Finally, assign the request to RestContext if used
    //         RestContext.request = request;
    //         RestContext.response = res;
            
    //         Test.startTest();            	           	
    //             IndicoWebServices.getIndicoCaseDetails();
    //         Test.stopTest();
            
    //         system.assert(jsonMsg != null);
    //         system.assert(res.responseBody != null);
    // 	 }       
    //  }

     
    //  @isTest static void testErrorsWrapper(){
         
    //     IndicoWebServices.ErrorsWrapper erWrpper = new IndicoWebServices.ErrorsWrapper('test','test');
    //     List<IndicoWebServices.ErrorsWrapper> lstErWrpper = new List<IndicoWebServices.ErrorsWrapper> ();
    //     lstErWrpper.add(erWrpper);
        
    //     IndicoWebServices.ErrorMessageWrapper erWrp = new IndicoWebServices.ErrorMessageWrapper('','',lstErWrpper);
    //     IndicoWebServices.IndicoResponse erIndico = new IndicoWebServices.IndicoResponse();

    //     IndicoWebServices.IndicoResponse varIndicoResponse = new IndicoWebServices.IndicoResponse();
    //     varIndicoResponse.isSuccess = true;
    //     varIndicoResponse.Problem = erWrp;
    // }
     
    // //when contact of Case is not null
    // @isTest static void testContactOnCase(){
    //     User usr = [Select id from User limit 1];
       
    //    system.runAs(usr){
    //         Case casebj = [SELECT Id,Location__c,Case_Type__c,Case_Sub_Type__c,ContactId,AssetId FROM Case LIMIT 1];
    //         casebj.Location__c = null;
    //         casebj.AssetId = null;
    //         //casebj.ContactId = null;
    //         casebj.Case_Type__c = null;
    //         casebj.Case_Sub_Type__c = null;
    //         Database.update(casebj);
           
    //         List<EmailMessage> emsg = [Select id,ParentId,FromAddress,ToAddress,isIndicoEligible__c,CcAddress,Subject,TextBody from EmailMessage where ParentId =: casebj.Id];
    //         emsg[0].isIndicoEligible__c = true; 
    //         Database.update(emsg);           
    //         List<Account> locList = [Select id,Location_Code__c from Account where Name = 'Location' Limit 1];
    //         list<Asset> assetlist = [Select id from Asset limit 1];
    //         list<Contact> conlist = [Select id from Contact Limit 1];
    //         List<SFDCEmailMessage__c> sfdcEmsg = [Select id from SFDCEmailMessage__c where SFDCEmailMessageParentId__c =: casebj.Id];
                                    
    //    // Set up a test request
    //        RestRequest request = new RestRequest();
    //        RestResponse res = new RestResponse();
    //        request.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
           
    //        // Set request properties
    //        request.requestUri = '/services/apexrest/IndicoEmail/V1';
    //        request.httpMethod = 'POST';    
           
    //        // Set other properties, such as parameters
    //        String jsonMsg = '{"data": {"caseId":"'+casebj.Id+'","emailMessageId":"'+emsg[0].Id+'","cases": [{"location": "'+locList[0].Location_Code__c+'","assetheader": "'+assetlist[0].Id+'","contact":"'+conlist[0].Id+'","caseType":"Pickup","recordType":"Pickup Case","casesubType":"Empty and Return","casereason":"Contaminated","HasSFRule":false,"po":"123","profile":"123","psi":"123","serviceDate":"2020-12-08","errorMessage":null}]}}';
    //        request.requestBody = Blob.valueof(jsonMsg);         
           
    //         // Finally, assign the request to RestContext if used
    //        RestContext.request = request;
    //        RestContext.response = res;
           
    //        Test.startTest();            	
               
    //            IndicoWebServices.getIndicoCaseDetails();
    //        Test.stopTest();        

    //        system.assert(jsonMsg != null);
    //        system.assert(res.responseBody != null);
    //    }
       
    // }
    // //when location is not correct
    //  @isTest static void testLocation(){
    //     User usr = [Select id from User limit 1];
       
    //    system.runAs(usr){
    //         Case casebj = [SELECT Id,Location__c,Case_Type__c,Case_Sub_Type__c,ContactId,AssetId FROM Case LIMIT 1];
    //         casebj.Location__c = null;
    //         casebj.AssetId = null;
    //         //casebj.ContactId = null;
    //         casebj.Case_Type__c = null;
    //         casebj.Case_Sub_Type__c = null;
    //         Database.update(casebj);
           
    //         List<EmailMessage> emsg = [Select id,ParentId,FromAddress,ToAddress,isIndicoEligible__c,CcAddress,Subject,TextBody from EmailMessage where ParentId =: casebj.Id];
    //         emsg[0].isIndicoEligible__c = true; 
    //         Database.update(emsg);           
    //         List<Account> locList = [Select id,Location_Code__c from Account where Name = 'Location' Limit 1];
    //         list<Asset> assetlist = [Select id from Asset limit 1];
    //         list<Contact> conlist = [Select id from Contact Limit 1];
    //         List<SFDCEmailMessage__c> sfdcEmsg = [Select id from SFDCEmailMessage__c where SFDCEmailMessageParentId__c =: casebj.Id];
                                    
    //    // Set up a test request
    //        RestRequest request = new RestRequest();
    //        RestResponse res = new RestResponse();
    //        request.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
           
    //        // Set request properties
    //        request.requestUri = '/services/apexrest/IndicoEmail/V1';
    //        request.httpMethod = 'POST';    
           
    //        // Set other properties, such as parameters
    //        String jsonMsg = '{"data": {"caseId":"'+casebj.Id+'","emailMessageId":"'+emsg[0].Id+'","cases": [{"location": "123","assetheader": "'+assetlist[0].Id+'","contact":"'+conlist[0].Id+'","caseType":"Pickup","recordType":"Pickup Case","casesubType":"Empty and Return","casereason":"Contaminated","HasSFRule":false,"po":"123","profile":"123","psi":"123","serviceDate":"2020-12-08","errorMessage":null}]}}';
    //        request.requestBody = Blob.valueof(jsonMsg);         
           
    //         // Finally, assign the request to RestContext if used
    //        RestContext.request = request;
    //        RestContext.response = res;
           
    //        Test.startTest();            	             
    //            IndicoWebServices.getIndicoCaseDetails();           	  
    //        Test.stopTest();
           
    //        system.assert(jsonMsg != null);
    //        system.assert(res.responseBody != null);
                                                    
    //    }       
    // }
    
    //   //when location is not correct
    //  @isTest static void testWrongCase(){
    //     User usr = [Select id from User limit 1];
       
    //    system.runAs(usr){
    //         Case casebj = [SELECT Id,Location__c,Case_Type__c,Case_Sub_Type__c,ContactId,AssetId FROM Case LIMIT 1];
    //         casebj.Location__c = null;
    //         casebj.AssetId = null;
    //         casebj.ContactId = null;
    //         casebj.Case_Type__c = null;
    //         casebj.Case_Sub_Type__c = null;
    //         Database.update(casebj);
           
    //         List<EmailMessage> emsg = [Select id,ParentId,FromAddress,ToAddress,isIndicoEligible__c,CcAddress,Subject,TextBody from EmailMessage where ParentId =: casebj.Id];
    //         emsg[0].isIndicoEligible__c = true; 
    //         Database.update(emsg);           
    //         List<Account> locList = [Select id,Location_Code__c from Account where Name = 'Location' Limit 1];
    //         list<Asset> assetlist = [Select id from Asset limit 1];
    //         list<Contact> conlist = [Select id from Contact Limit 1];
    //         List<SFDCEmailMessage__c> sfdcEmsg = [Select id from SFDCEmailMessage__c where SFDCEmailMessageParentId__c =: casebj.Id];
                                    
    //    // Set up a test request
    //        RestRequest request = new RestRequest();
    //        RestResponse res = new RestResponse();
    //        request.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
           
    //        // Set request properties
    //        request.requestUri = '/services/apexrest/IndicoEmail/V1';
    //        request.httpMethod = 'POST';    
           
    //        // Set other properties, such as parameters
    //        String jsonMsg = '{"data": {"caseId":"'+casebj.Id+'","emailMessageId":"'+emsg[0].Id+'","cases":null}}';
    //        request.requestBody = Blob.valueof(jsonMsg);         
           
    //         // Finally, assign the request to RestContext if used
    //        RestContext.request = request;
    //        RestContext.response = res;
           
    //        Test.startTest();            	             
    //            IndicoWebServices.getIndicoCaseDetails();          	  
    //        Test.stopTest();
           
    //        system.assert(jsonMsg != null);
    //        system.assert(res.responseBody != null);
                                                    
    //    }       
    // }
    
    // //when Data is null
    //  @isTest static void testData(){
    //     User usr = [Select id from User limit 1];
       
    //    system.runAs(usr){
    //         Case casebj = [SELECT Id,Location__c,Case_Type__c,Case_Sub_Type__c,ContactId,AssetId FROM Case LIMIT 1];
    //         casebj.Location__c = null;
    //         casebj.AssetId = null;
    //         casebj.ContactId = null;
    //         casebj.Case_Type__c = null;
    //         casebj.Case_Sub_Type__c = null;
    //         Database.update(casebj);
           
    //         List<EmailMessage> emsg = [Select id,ParentId,FromAddress,ToAddress,isIndicoEligible__c,CcAddress,Subject,TextBody from EmailMessage where ParentId =: casebj.Id];
    //         emsg[0].isIndicoEligible__c = true; 
    //         Database.update(emsg);           
    //         List<Account> locList = [Select id,Location_Code__c from Account where Name = 'Location' Limit 1];
    //         list<Asset> assetlist = [Select id from Asset limit 1];
    //         list<Contact> conlist = [Select id from Contact Limit 1];
    //         List<SFDCEmailMessage__c> sfdcEmsg = [Select id from SFDCEmailMessage__c where SFDCEmailMessageParentId__c =: casebj.Id];
                                    
    //    // Set up a test request
    //        RestRequest request = new RestRequest();
    //        RestResponse res = new RestResponse();
    //        request.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
           
    //        // Set request properties
    //        request.requestUri = '/services/apexrest/IndicoEmail/V1';
    //        request.httpMethod = 'POST';    
           
    //        // Set other properties, such as parameters
    //        String jsonMsg ='{"data": null, "problem": { "title": "Bad Request", "status": 400, "errors": [ { "code": "1000", "message": "No Cost information available" }]}}';

    //        request.requestBody = Blob.valueof(jsonMsg);         
           
    //         // Finally, assign the request to RestContext if used
    //        RestContext.request = request;
    //        RestContext.response = res;
           
    //        Test.startTest();            	             
    //            IndicoWebServices.getIndicoCaseDetails();
    //        Test.stopTest();
           
    //        system.assert(jsonMsg != null);
    //        system.assert(res.responseBody != null);
                                                    
    //    }       
    // }
    //    @isTest static void testContact(){
    //     User usr = [Select id from User limit 1];
       
    //    system.runAs(usr){
    //         Case casebj = [SELECT Id,Location__c,Case_Type__c,Case_Sub_Type__c,ContactId,AssetId FROM Case LIMIT 1];
    //        // casebj.Location__c = null;
    //         casebj.AssetId = null;
    //         //casebj.ContactId = null;
    //         casebj.Case_Type__c = null;
    //         casebj.Case_Sub_Type__c = null;
    //         Database.update(casebj);
           
    //         List<EmailMessage> emsg = [Select id,ParentId,FromAddress,ToAddress,isIndicoEligible__c,CcAddress,Subject,TextBody from EmailMessage where ParentId =: casebj.Id];
    //         emsg[0].isIndicoEligible__c = true; 
    //         Database.update(emsg);           
    //         List<Account> locList = [Select id,Location_Code__c from Account where Name = 'Location' Limit 1];
    //         list<Asset> assetlist = [Select id from Asset limit 1];
    //         list<Contact> conlist = [Select id from Contact Limit 1];
    //         List<SFDCEmailMessage__c> sfdcEmsg = [Select id from SFDCEmailMessage__c where SFDCEmailMessageParentId__c =: casebj.Id];
                                    
    //    // Set up a test request
    //        RestRequest request = new RestRequest();
    //        RestResponse res = new RestResponse();
    //        request.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
           
    //        // Set request properties
    //        request.requestUri = '/services/apexrest/IndicoEmail/V1';
    //        request.httpMethod = 'POST';    
           
    //        // Set other properties, such as parameters
    //        String jsonMsg = '{"data": {"caseId":"'+casebj.Id+'","emailMessageId":"'+emsg[0].Id+'","cases": [{"location": "'+locList[0].Location_Code__c+'","assetheader": "'+assetlist[0].Id+'","contact":"","caseType":"Pickup","recordType":"Pickup Case","casesubType":"Empty and Return","casereason":"Contaminated","HasSFRule":false,"po":"123","profile":"123","psi":"123","serviceDate":"2020-12-08","errorMessage":null}]}}';
    //        request.requestBody = Blob.valueof(jsonMsg);         
           
    //         // Finally, assign the request to RestContext if used
    //        RestContext.request = request;
    //        RestContext.response = res;
           
    //        Test.startTest();            	             
    //            IndicoWebServices.getIndicoCaseDetails();           	  
    //        Test.stopTest();
           
    //        system.assert(jsonMsg != null);
    //        system.assert(res.responseBody != null);
                                                    
    //    }       
    // }

    //      @isTest static void testValidateContact(){
         
    //              list<Contact> conlist = [Select id from Contact Limit 1];
    //              List<Account> locList = [Select id from Account where Name = 'Location' Limit 1];
         
    //          Boolean var = IndicoWebServices.validateContact(conlist[0].Id,locList[0].Id);
         
    //      }
    
    // @isTest static void testUpdateCaseTypeFields(){
        
    //     List<Case> caseLst = [SELECT Id FROM Case LIMIT 1];
    //     Boolean var = IndicoWebServices.updateCaseTypeFields(caseLst,'Pickup','Empty and Return','Contaminated');
        
    // }
        
    // @isTest static void testUpdateServiceDate(){
        
    //     List<Case> caseLst = [SELECT Id FROM Case LIMIT 1];
    //     Date ServiceDate = 	System.now().Date();
    //     list<Contact> conlist = [Select id from Contact Limit 1];
    //     Boolean var = IndicoWebServices.updateServiceDate(caseLst,ServiceDate);
	// 	Boolean varContact = IndicoWebServices.updateContact(caseLst,conlist[0].Id,True);
        
    // 	}
    }