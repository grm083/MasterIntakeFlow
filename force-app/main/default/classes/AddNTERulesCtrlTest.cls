@isTest(seeAllData=false)
public class AddNTERulesCtrlTest {
    private static final string SYS_ADMIN = 'System Administrator';
    private static final string KROGER = 'kroger';
    private static final string NY_TIMEZONE = 'America/New_York';
    
    @isTest static void saveNTERulesTest(){
        Profile p = TestDataFactory.getProfile(SYS_ADMIN);
        User usr = TestDataFactory.createUser(p);
        usr.bypass_validation__c = true;
        Database.insert(usr);
        
        system.runAs(usr){
            Test.startTest();
            list<Account> acclist = TestDataFactory.createAccount(KROGER, usr,Constant_Util.CLIENT);
            Database.insert(acclist);
            
            list<Account> locationlist = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, acclist.get(0).id);
            locationlist[0].tz__Timezone_SFDC__c = NY_TIMEZONE;
            locationlist[0].tz__UTF_Offset__c = -4;
            Database.insert(locationlist);
			system.debug(' acclist[0].Id : ' + acclist[0].Id + ' : locationlist[0].Id : '+ locationlist[0].Id);
            list<Business_Rule__c> brlist = new list<Business_Rule__c>();
            Business_Rule__c brObj = new Business_Rule__c();
            brObj.Accountid__c = acclist[0].Id;
            brObj.LocationId__c = locationlist[0].Id;
            brObj.Request_Type__c = 'Pickup';
            brObj.Service__c = 'Bulk';
            brObj.RecordTypeid = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get('Approval').getRecordTypeId();
            brObj.Effective_Date__c = System.today()-1;
            brObj.NTE_Rules__c = True;
            brObj.Active__c=True;
            brlist.add(brObj);
            insert brlist;
            
            Service_Approver__c newSA = new Service_Approver__c();
            Id rtId = Schema.SObjectType.Service_Approver__c.getRecordTypeInfosByDeveloperName().get('NTE_Approval').getRecordTypeId();
            newSA.Service_Type__c = 'Pickup';
            newSA.RecordTypeId = rtId;
            newSA.Business_Rule__c = brlist[0].Id;
            newSA.NTE_Rule_ExtId__c = 'Pickup' + '-'+brlist[0].Id;
            newSA.NTE_Amount__c = 100;
            newSA.Account__c = acclist[0].Id;
            newSA.Location__c = locationlist[0].Id;
            newSA.Active__c = True;
            insert newSA; 
            system.debug(' newSA : '+newSA);
            
            brlist[0].Active__c = true;
            update brlist;
            
            String srvType = 'Pickup';
        	String ruleData = '{ "businessRuleId": "'+brlist[0].Id+'", "serviceType": "'+srvType+'", "nteAmount": 10, "accountId": "'+acclist[0].Id+'", "locationId" : "'+locationlist[0].Id+'" }';
        	AddNTERulesCtrl.saveNTERulesData(ruleData);
        	NTEBRRulesModalCtrl.getBRData('Pickup Case',acclist[0].Id,locationlist[0].Id,'Pickup','Bulk','reason');
            Test.stopTest();
            System.assert(!brlist.isEmpty());
        }
        
    }

}