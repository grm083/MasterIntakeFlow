@isTest
public class ContactByRoleHelperTest{
    public static testmethod void test(){
        List<Account> accList = new List<Account>();
        Profile p = TestDataFactory.getProfile('System Administrator');
        User usr = TestDataFactory.createUser(p);
        Database.insert(usr);
        system.runAs(usr){
            accList = TestDataFactory.createAccount(Constant_Util.KEYWORD_TEST, usr);
            Database.insert(accList);
            Account locAcc = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, accList[0].id)[0];
            Database.insert(locAcc);
            List<contact> conList = new List<contact>();
            Contact contct = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST,Constant_Util.CONSTANT_LAST, accList[0], usr)[0];
            Database.insert(contct);
            
            Contact contct1 = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST,Constant_Util.CONSTANT_LAST, accList[1], usr)[0];
            conList.add(contct1);
            Contact contct2 = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST,Constant_Util.CONSTANT_LAST, accList[1], usr)[0];
            conList.add(contct2);
            Contact contct3 = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST,Constant_Util.CONSTANT_LAST, accList[1], usr)[0];
            conList.add(contct3);
            
            insert conList;
            List<AccountContactRelation> acrList = new List<AccountContactRelation>();
            List<AccountContactRelation> conListForAccount = new List<AccountContactRelation>();
            conListForAccount = [SELECT Id, ContactId,Contact.Phone,Contact.MobilePhone,Contact.Email,Contact.Preferred_Method__c,Contact.Name, Roles, Account_Record_Type__c, Tech_Contact_Created_Date__c, Tech_Contact_Status__c, Relationship_Strength__c 
                                FROM AccountContactRelation 
                                where AccountId =: accList[1].id 
                                LIMIT 50000];
            if(conListForAccount != null && !conListForAccount.isEmpty()){
                for(AccountContactRelation acr:  conListForAccount){
                    if(acr.contactId == contct2.Id){
                        acr.Roles = 'Emergency/After Hours;Dispatch - Commercial;Tonnage Inquiries;1st Cost Escalation;Site Surveys';
                    }
                    else{
                        acr.Roles = 'Site Surveys';
                    }
                    acrList.add(acr);
                }
            }   
            update(acrList);             
          
            
            Product2 prdct = TestDataFactory.createProduct('Sample Product Test')[0];
            Database.insert(prdct);
            Asset asst = TestDataFactory.createAsset('Test Asset', accList[0],contct, prdct, usr,locAcc)[0];
            Database.insert(asst);
            Case cse = TestDataFactory.createNewCase()[0];
            cse.Client__c = accList[0].Id;
            cse.Location__c = locAcc.Id;
            cse.ContactId = contct.Id;
            cse.Supplier__c = accList[1].id;
            cse.Case_Type__c = 'Pickup';
            cse.Case_Sub_Type__c = 'Empty and Return';
            cse.Origin = 'Phone';
            cse.Emergency__c = false;
            Database.insert(cse);
            
            Communication_Channel__c testChannel = new Communication_Channel__c(
                AccountId__c = accList[1].Id,
                Channel_Function__c = 'REMITTO',
                Channel_Type__c = 'MADR',
                Channel_Value__c = 'Value Test',
                Notes__c = 'Notes Test',
                isActive__c = true
            );
            insert testChannel;
            
            ContactByRoleHelper.retrieveContact(accList[1].Id);
            ContactByRoleHelper.retrieveContact(cse.Id);
            ContactByRoleHelper.isCommChannelEnabled(cse.Id);
            ContactByRoleHelper.isCommChannelEnabled(accList[1].Id);
            CommunicationChannelViewController.communicationData(cse.Id);
            CommunicationChannelViewController.ComTableResponse comT =  CommunicationChannelViewController.communicationData(accList[1].Id);
            System.assertEquals(1, comT.lstComType.size());
        }
    }
    
    public static testmethod void testWorkOrderVendorContact(){
        Profile p = TestDataFactory.getProfile('System Administrator');
        User usr = TestDataFactory.createUser(p);
        Database.insert(usr);
        system.runAs(usr){
            List<Account> accList = TestDataFactory.createAccount('VENDOR Acc', usr ,'Vendor');
            insert accList;
            List<contact> conList = new List<contact>();
            Contact contct = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST,Constant_Util.CONSTANT_LAST, accList[0], usr)[0];
            Database.insert(contct);
            
            Contact contct1 = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST,Constant_Util.CONSTANT_LAST, accList[0], usr)[0];
            conList.add(contct1);
            Contact contct2 = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST,Constant_Util.CONSTANT_LAST, accList[0], usr)[0];
            conList.add(contct2);
            Contact contct3 = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST,Constant_Util.CONSTANT_LAST, accList[0], usr)[0];
            conList.add(contct3);
            
            insert conList;
            List<AccountContactRelation> acrList = new List<AccountContactRelation>();
            List<AccountContactRelation> conListForAccount = new List<AccountContactRelation>();
            conListForAccount = [SELECT Id, ContactId,Contact.Phone,Contact.MobilePhone,Contact.Email,Contact.Preferred_Method__c,Contact.Name, Roles, Account_Record_Type__c, Tech_Contact_Created_Date__c, Tech_Contact_Status__c, Relationship_Strength__c 
                                FROM AccountContactRelation 
                                where AccountId =: accList[0].id 
                                LIMIT 50000];
            if(conListForAccount != null && !conListForAccount.isEmpty()){
                for(AccountContactRelation acr:  conListForAccount){
                    if(acr.contactId == contct2.Id){
                        acr.Roles = 'Emergency/After Hours;Dispatch - Commercial;Tonnage Inquiries;1st Cost Escalation;Site Surveys';
                    }
                    else{
                        acr.Roles = 'Site Surveys';
                    }
                    acrList.add(acr);
                }
            }   
            update(acrList);             
          
            
            WorkOrder wo = new WorkOrder(Vendor_Account_Id__c = accList[0].id);
            Database.insert(wo);
            Communication_Channel__c testChannel = new Communication_Channel__c(
                AccountId__c = accList[0].id,
                Channel_Function__c = 'REMITTO',
                Channel_Type__c = 'MADR',
                Channel_Value__c = 'Value Test',
                Notes__c = 'Notes Test',
                isActive__c = true
            );
            insert testChannel;
            ContactByRoleHelper.retrieveContact(wo.Id);
            CommunicationChannelViewController.communicationData(wo.Id);
            Boolean isChecked = ContactByRoleHelper.isCommChannelEnabled(wo.Id);
            System.assert(isChecked);
        }
    }
}