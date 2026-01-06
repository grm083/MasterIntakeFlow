/**
* @author Accenture
* @date 2/27/2019
* @description : Apex class CustomCaseCreationCntrlrTest 
**/
@isTest(seeAllData = false)
public class CustomCaseCreationCntrlrTest {

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
            Database.insert(locationlist);
            list<Contact> conlist = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST,Constant_Util.CONSTANT_LAST, acclist.get(0), usr);
            Database.insert(conlist);
            list<product2> productlist = TestDataFactory.createProduct(Constant_Util.KEYWORD_TEST);
            Database.insert(productlist);
            list<Asset> assetlist = TestDataFactory.createAsset(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                                productlist.get(0), usr, locationlist.get(0));
            assetlist[0]. Supplier__c = acclist[1].Id;
            Database.insert(assetlist);
            Test.startTest();
            list<Case> caselist = TestDataFactory.createCase(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                             usr, locationlist.get(0), assetlist.get(0));
            caselist[0].Service_Date__c = system.today() +1;
            caselist[0].PurchaseOrder_Number__c =  Constant_Util.PO_VALUE_TEST;
            Database.SaveResult[] srList = Database.insert(caselist);
            list<Case> caseWithParentList = TestDataFactory.createCase(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                         usr, locationlist.get(0), assetlist.get(0));
            caseWithParentList[0].ParentId = srList[0].Id;
            Database.insert(caseWithParentList);
            list<task> taskList = TestDataFactory.createTask(caseWithParentList[0].Id, usr);
            taskList[0].subject = Constant_Util.TASK_SUBJECT;
            Database.insert(taskList);
            Test.stopTest();
            EmailMessage email = new EmailMessage();
            email.TextBody = 'Test';
            email.ParentId = caselist[0].Id;
            email.RelatedToId = caselist[0].Id;
            Database.insert(email);
            Comment__c notes = new Comment__c();
            notes.Case__c = caselist[0].Id;
            notes.RecordTypeId = Schema.getGlobalDescribe().get('Comment__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Acorn_Ticket_Comment').getRecordTypeId();
            Database.insert(notes);
            
            
        	/*
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = caselist[0].id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.shareType = 'V';
            insert cdl;
*/
        } 
    }
/**
* @author Accenture
* @date 2/27/2019
* @description : Apex method testCustomCaseCreationFromAsset 
**/    
    @isTest static void testCustomCaseCreationFromAsset(){
        user currentuser = [SELECT id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        system.runAs(currentuser){
        list<case> caselist = [select id, origin, contactid, Case_Type__c, Client__c, Location__c, 
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                   Service_Date__c,SLA_Service_Date_Time__c,RecordTypeId from case limit 1];
        CustomCaseCreationCntrlr.ResultWrapper result = new CustomCaseCreationCntrlr.ResultWrapper();
            result = CustomCaseCreationCntrlr.customCaseCreation('Pickup',caselist[0].assetid, null);
            system.assert(result.success == true);

            result = CustomCaseCreationCntrlr.customCaseCreation('ETA',caselist[0].assetid, null);
            system.assert(result.success == true);    

            result = CustomCaseCreationCntrlr.customCaseCreation('SNP',caselist[0].assetid, null);
            system.assert(result.success == true);    

            result = CustomCaseCreationCntrlr.customCaseCreation('New Service',caselist[0].assetid, null);
            system.assert(result.success == true);    
        }
    }
/**
* @author Accenture
* @date 2/27/2019
* @description : Apex method testCustomCaseCreationFromCaseHome 
**/    
    @isTest static void testCustomCaseCreationFromCaseHome(){
        user currentuser = [SELECT id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        String caseTypeData = '{"Case_Type__c" : "" , "Case_SubType__c" : "" , "Case_Reason__c" : ""}';
            
        system.runAs(currentuser){
        list<case> caselist = [select id, origin, contactid, Case_Type__c, Client__c, Location__c, 
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                   Service_Date__c,SLA_Service_Date_Time__c,RecordTypeId from case limit 1];
        CustomCaseCreationCntrlr.ResultWrapper result = CustomCaseCreationCntrlr.customCaseCreation(Constant_Util.PICKUP,null,null);
		CustomCaseCreationCntrlr.ResultWrapper resultForNSC = CustomCaseCreationCntrlr.customCaseCreation(Constant_Util.New_Service_Case, null,caseTypeData);

        list<case> caselistResult = [select id, Client__c, Location__c from case where id =: result.message limit 1];
        system.assert(caselistResult[0].Client__c == null);
        }
    }
/**
* @author Accenture
* @date 2/27/2019
* @description : Apex method testGetCaseRecordTypes 
**/ 
    
    @isTest static void testGetCaseRecordTypes(){
        List<recordType> recordType = CustomCaseCreationCntrlr.getCaseRecordTypes();
        system.assert(recordType !=null);
    }
    
/**
* @author Accenture
* @date 2/27/2019
* @description : Apex method testCustomCaseCreationFromCaseFeed 
**/    
    @isTest static void testCustomCaseCreationFromCaseFeed(){
        user currentuser = [SELECT id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        String caseTypeData = '{"Case_Type__c" : "" , "Case_SubType__c" : "" , "Case_Reason__c" : ""}';
        system.runAs(currentuser){
        list<case> caselist = [select id, origin, contactid, Case_Type__c, Client__c, Location__c, 
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                   Service_Date__c,SLA_Service_Date_Time__c,RecordTypeId from case limit 1];
        CustomCaseCreationCntrlr.ResultWrapper result = CustomCaseCreationCntrlr.customCaseCreation('Pickup',caselist[0].Id, caseTypeData);
        list<case> caselistResult = [select id, Client__c, Location__c, Case_Type__c from case where id =: result.message limit 1];
        system.assertEquals(caselist[0].Client__c, caselistResult[0].Client__c);
        }
    }
/**
* @author Accenture
* @date 2/27/2019
* @description : Apex method testCustomCaseCreationFromCaseFeedWithParent 
**/
    @isTest static void testCustomCaseCreationFromCaseFeedWithParent(){
        user currentuser = [SELECT id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        system.runAs(currentuser){
            list<case> caselist = [select id, origin, contactid, Case_Type__c, Client__c, Location__c, 
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                   Service_Date__c,SLA_Service_Date_Time__c,RecordTypeId,ParentId from case where ParentId != null limit 1];
            CustomCaseCreationCntrlr.ResultWrapper result = CustomCaseCreationCntrlr.customCaseCreation(Constant_Util.PICKUP,caselist[0].Id ,null);
            list<case> caselistResult = [select id, Client__c, Location__c from case where id =: result.message limit 1];
            system.assertEquals(caselist[0].Client__c, caselistResult[0].Client__c);
        }
    }
    
/**
* @author Accenture
* @date 2/27/2019
* @description : Apex method testCustomCaseCreationNegative 
**/
    @isTest static void testCustomCaseCreationNegative(){
        user currentuser = [SELECT id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        system.runAs(currentuser){
            list<case> caselist = [select id, origin, contactid, Case_Type__c, Client__c, Location__c, 
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                   Service_Date__c,SLA_Service_Date_Time__c,RecordTypeId from case limit 1];
            Asset assets = [select id,Location__c from asset where id=: caselist[0].assetid limit 1];
            assets.Location__c = null;
            database.update(assets);
            CustomCaseCreationCntrlr.ResultWrapper result = CustomCaseCreationCntrlr.customCaseCreation(Constant_Util.PICKUP,assets.id ,null);
            system.assert(result.success == false);
        }
    }
    
    @isTest static void testCustomCaseCreationCopyData(){
        user currentuser = [SELECT id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        system.runAs(currentuser){
            //list<ContentVersion> contentversions = [Select Id,FirstPublishLocationId FROM ContentVersion LIMIT 1];
            list<case> caselist = [select id, origin, contactid, Case_Type__c, Client__c, Location__c, 
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                   Service_Date__c,SLA_Service_Date_Time__c,RecordTypeId from case limit 1];
            
            ContentVersion cv = new ContentVersion();
  				cv.Title = 'TestAttach';
  				cv.PathOnClient = 'TestAttach.jpg';
                cv.VersionData = Blob.valueOf('Test Content');
  				cv.IsMajorVersion = false;
				cv.FirstPublishLocationId = caselist[0].Id;                
            insert cv;
            
            List<String> emailIds = new List<String>();
            List<String> copyOptions = new List<String>{'Email', 'Comments', 'Asset', 'Attachments'};
            
            for(EmailMessage em : [SELECT Id FROM EmailMessage WHERE ParentId = :caselist[0].id]){
                emailIds.add(em.id);
            }
            String caseTypeData = '{"Case_Type__c" : "" , "Case_SubType__c" : "" , "Case_Reason__c" : ""}';
            CustomCaseCreationCntrlr.ResultWrapper result = CustomCaseCreationCntrlr.CaseCreationwithCopyData(Constant_Util.Pickup, caselist[0].id, copyOptions, emailIds, caseTypeData);
            Case newCase = [SELECT Id, AssetId FROM Case WHERE Id = :result.message];
            List<ContentDocumentLink> newcontentLinks = [SELECT Id from ContentDocumentLink WHERE LinkedEntityId = :result.message];
            List<Comment__c> comments = [SELECT Id, Case__c FROM Comment__c WHERE Case__c = :result.message];
            //List<Comment__c> emailComments = [SELECT Id, Case__c FROM Comment__c WHERE Case__c = :result.message AND Comment__c = 'Test'];
            List<EmailMessage> emails = [SELECT Id, ParentId FROM EmailMessage WHERE ParentId = :result.message];
            
            System.assertequals(newCase.AssetId, caselist[0].AssetId);
            System.assert(comments.size()>0);
            System.assert(newcontentLinks.size()>0);
            //System.assert(emailComments.size()>0);
            System.assert(emails.isEmpty());            
        }
    }

    @isTest static void testGetEmails(){
        user currentuser = [SELECT id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        system.runAs(currentuser){
            List<EmailMessage> emails = [SELECT Id, ParentId FROM EmailMessage WHERE ParentId != null];

            List <EmailMessage> returnedEmails = CustomCaseCreationCntrlr.GetEmails(emails[0].ParentId);

            System.assertEquals(emails[0].ParentId, returnedEmails[0].ParentId);
        }
    }
	
	  @isTest static void testCaseSubtypeChange(){
        user currentuser =[SELECT id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        system.runAs(currentuser){
            list<case> caselist = [select id, origin, contactid, Case_Type__c, Client__c, Location__c, 
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                   Service_Date__c,SLA_Service_Date_Time__c,RecordTypeId from case limit 1];
            Asset assets = [select id,Location__c,product2.family,Occurrence_Type__c from asset where id=: caselist[0].assetid limit 1];
            assets.product2.family = Constant_Util.ROLLOFF;
            assets.Occurrence_Type__c = Constant_Util.SCHEDULED;
            database.update(assets);
            Boolean  rolloffPickUP = CustomCaseCreationCntrlr.checkRollofStatusLogic(assets.id);
           
        }
    }
	
}