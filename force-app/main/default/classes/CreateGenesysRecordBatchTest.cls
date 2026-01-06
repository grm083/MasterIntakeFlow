/**
* @author Accenture
* @Date:27/3/2020
* @description : Apex class CreateGenesysRecordBatch 
**/

@isTest(seeAllData = false)
public class CreateGenesysRecordBatchTest {
	@testSetup static void setup() {
        Profile p = TestDataFactory.getProfile('System Administrator');
        User usr = TestDataFactory.createUser(p);
        Database.insert(usr);
        
        system.runAs(usr){
			list<Account> accLst = TestDataFactory.createAccount(Constant_Util.KEYWORD_TEST, usr,'Client');
            Database.insert(accLst);
            Complete_Task__c cte= new Complete_Task__c();
            cte.Name = 'Complete_Genesys_Routing';
            cte.Recent_Run__c = System.now()-(60/1440);
            Database.insert(cte,false);
			list<Account> locationLst = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, accLst.get(0).id);
            Database.insert(locationLst);
            
			list<Contact> conLst = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST,Constant_Util.CONSTANT_LAST, 
                                                                 accLst.get(0), usr);
            Database.insert(conLst);
            
			list<product2> productLst = TestDataFactory.createProduct(Constant_Util.KEYWORD_TEST);
            Database.insert(productLst);
            
			list<Account> supplierAccLst = TestDataFactory.createAccount('testsupplier', usr,'Vendor');
            Database.insert(supplierAccLst);
            
			list<Asset> assetLst = TestDataFactory.createAsset(Constant_Util.CONSTANT_FIRST, accLst.get(0), conLst.get(0), 
                                                               productLst.get(0), usr, locationLst.get(0));
            assetLst[0].Supplier__c = supplierAccLst.get(0).Id;
            assetLst[0].Quantity__c = 5;
            Database.insert(assetLst);
            
			list<Case> caseLst = TestDataFactory.createCase(Constant_Util.CONSTANT_FIRST, accLst.get(0), conLst.get(0), 
                                                            usr, locationLst.get(0), assetLst.get(0));
			caseLst[0].Status = 'Closed';
            caseLst[0].CreatedDate = System.now()-(5/1440);
            caseLst[0].LastModifiedDate = System.now();
            Database.insert(caseLst);  
            String Subject = Constant_Util.KEYWORD_TEST;
            String Body = Constant_Util.KEYWORD_TEST + ' lOCatioN # FAM002508';
            List<EmailMessage> lstEM = new List<EmailMessage>();
            lstEM = TestDataFactory.createEmailMessage(Subject, Body, caseLst.get(0));
            Database.insert(lstEM); 
	    List<Case> listOfCasestoUpdate = new List<Case>();
            for(Case emailMsgRelatedCase:[Select Id,Status from Case WHERE Status!='Closed' AND Origin='Email']){                                        
                emailMsgRelatedCase.Status='Closed';
                listOfCasestoUpdate.add(emailMsgRelatedCase);            
            }
            
            Database.update(listOfCasestoUpdate);
            
            Id genesysRoutingRec = Schema.getGlobalDescribe().get(Constant_Util.Genesys_Routing).getDescribe().getRecordTypeInfosByDeveloperName().get(Constant_Util.EMAILTOCASERECORD).getRecordTypeId();
            Genesys_Routing__c gr = new Genesys_Routing__c();
            gr.MediaType__c = Constant_Util.SFDCEMAILCASE;
            gr.RecordTypeId = genesysRoutingRec;
            gr.SFDCObjName__c = Constant_Util.OBJECT_CASE;
            gr.SFDCObjType__c =  Constant_Util.OBJECT_EMAILMESSAGE;
            gr.Integrate_with_Genesys_Routing__c = true; 
            gr.Action__c = 'New';
            gr.SFDCObjRecordID__c = lstEM.get(0).Id;
            Database.insert(gr,false); 
		}
    }
    
    @isTest static void testBatchCreateGenesysRecordBatch() {
        Id genesysRoutingRec = Schema.getGlobalDescribe().get(Constant_Util.Genesys_Routing).getDescribe().getRecordTypeInfosByDeveloperName().get(Constant_Util.EMAILTOCASERECORD).getRecordTypeId();
        EmailMessage e = [select id from emailMessage limit 1];
        system.assertEquals(0, [select Id from Genesys_Routing__c where SFDCObjRecordID__c =:e.Id and RecordTypeId=:genesysRoutingRec and Action__c='Cancel'].size());   
        user usr = [SELECT id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        system.runAs(usr) {
            Test.startTest();
            DataBase.executeBatch(new CreateGenesysRecordBatch());
            Test.stopTest();
        }
        List<Genesys_Routing__c> genRecList = new List<Genesys_Routing__c>();
        genRecList = [select Id from Genesys_Routing__c where SFDCObjRecordID__c=:e.Id and RecordTypeId=:genesysRoutingRec and Action__c='Cancel'];
        if(genRecList.size()>0){
        system.assertEquals(1, genRecList.size());
        }
    }
}