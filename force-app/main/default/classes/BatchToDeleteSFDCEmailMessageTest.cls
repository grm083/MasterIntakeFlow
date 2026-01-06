/**
* @author WM
* @date 11/22/2020
* @description : Apex class BatchToDeleteSFDCEmailMessageTest
**/
@isTest
public class BatchToDeleteSFDCEmailMessageTest {
	
    // method for setting up data    
    @testSetup static void setup() {
        Profile p = TestDataFactory.getProfile('System Administrator');
        User usr = TestDataFactory.createUser(p);
        Database.insert(usr);
        
        IndicoEmailMessageFilter__c indicoEmailType = new IndicoEmailMessageFilter__c();
        indicoEmailType.Name = 'IndicoEmail';
        indicoEmailType.FilterConditionColumnName__c = 'All';
        indicoEmailType.FilterConditionValue__c = 'cct_sbs_test_17@wm.com';
        indicoEmailType.Type__c = 'WMPORTALS';
        Database.insert(indicoEmailType);
                      
        list<Case> caselist = TestDataFactory.createNewCase();        
        Database.insert(caselist);
        
        List<EmailMessage> lstEM = new List<EmailMessage>();
        lstEM = TestDataFactory.createEmailMessage('Test','Test', caselist.get(0));
        Database.insert(lstEM);
        
        SFDCEmailMessage__c sfdcEmsg = new SFDCEmailMessage__c();
		sfdcEmsg.EmailMessageId__c = lstEM[0].Id;
        sfdcEmsg.Name = 'Test';
        sfdcEmsg.SFDCEmailMessageParentId__c = caselist[0].Id;
        sfdcEmsg.SFDCEmailMessageToAddress__c = 'cct_sbs_test_17@wm.com';
        Database.insert(sfdcEmsg);
                          
    }   
    
    @isTest static void testBatchToDeleteSFDCEmailMessage() {
        
        List<user> currentuser = [select id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        List<Case>cslst= [Select id from Case ];
        List<EmailMessage> emsg = [Select id,ParentId,FromAddress,ToAddress,isIndicoEligible__c,CcAddress,Subject,TextBody from EmailMessage where ParentId =: cslst[0].Id];
        emsg[0].isIndicoEligible__c = true;
        Database.update(emsg);
        
        List<SFDCEmailMessage__c> sfdcMsg= [Select id from SFDCEmailMessage__c where SFDCEmailMessageParentId__c =:cslst[0].Id];
        
           system.runAs(currentuser.get(0)){
            String cronexp = '0 0 0 24 5 ? *';
            
            Test.startTest();
                String jobId = System.schedule('Test BatchToDeleteSFDCEmailMessage',  cronexp, new BatchToDeleteSFDCEmailMessage());
                CronTrigger cronTrgr = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger
                                        WHERE id = :jobId Limit 1];             
            Test.stopTest();
            System.assertEquals(0, cronTrgr.TimesTriggered);
        }
   	  }
	}