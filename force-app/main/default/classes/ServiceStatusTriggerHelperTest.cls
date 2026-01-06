@isTest(seeAllData = false)
public class ServiceStatusTriggerHelperTest {
    
    private static final string SYS_ADMIN = 'System Administrator';
    private static final string PRODUCT = '8 yrd';
    private static final string KROGER = 'kroger';
    private static final string RITA = 'Rita';
    private static final string REPLY = 'Reply';
    private static final string MESSAGE_STATUS_PENDING='Pending';
    private static final string ACC_KROGER='Kroger';
    
    private static final string MESSAGE_STATUS_COMPLETE='Complete';
    
    private static final string MESSAGE_TYPE_ONOURWAY='On Our Way';
    private static final string MESSAGE_TYPE_NEGATIVE_HOC='Negative HOC';
    private static final string MESSAGE_TYPE_DEL_CNF='Delivery Confirmation';
    private static final string NOTIF_TYPE_ONOURWAY='On Our Way';
    private static final string NOTIF_TYPE_NEGATIVE_HOC='Negative HOC';
    private static final string NOTIF_TYPE_DEL_CNF='Delivery Confirmation';
    private static final string NOTIF_PREF_EMAIL='Email';
    private static final string NOTIF_PREF_SMS='SMS';
    private static final string NOTIF_PREF_DNN='Do Not Notify';
    private static final string NOTIF_PREF_LANG_ENG='English';
    private static final string NOTIF_PREF_LANG_FRENCH='French (Francais)';
    private static final string NOTIF_STATUS_ON='On';
    private static final string NOTIF_STATUS_OFF='Off';
    
    
    @testSetup static void setup(){
        Profile prof = TestDataFactory.getProfile(SYS_ADMIN);
        User currentUser = TestDataFactory.createUser(prof);
        Database.insert(currentUser);
        system.runAs(currentUser){
            List<Account> accList = TestDataFactory.createAccount(KROGER, currentUser,Constant_Util.CLIENT);
            Database.insert(accList);
            List<Account> locationList = TestDataFactory.createLocation(Constant_Util.LOCATION, currentUser, accList.get(0).id);
            Database.insert(locationList);
            ///List<Contact> conList = TestDataFactory.createContact(RITA,REPLY, accList.get(0), currentUser);
            List<Contact> conList = new List<Contact>();
            Contact cont= new Contact(FirstName='Noti', LastName='Test',accountId=accList.get(0).id);
            Contact cont2= new Contact(FirstName='Fname', LastName='Lname',accountId=accList.get(0).id);
            conList.add(cont);
            conList.add(cont2);
            Database.insert(conList);
            
            List<AccountContactRelation> acrList= new  List<AccountContactRelation>();
            AccountContactRelation testACR1 = new AccountContactRelation(AccountId=locationList[0].Id , ContactId=conList[0].id, Roles=Constant_Util.DISPATCH,Notification_Point_Of_Contact__c=true );
            AccountContactRelation testACR2 = new AccountContactRelation(AccountId=locationList[0].Id , ContactId=conList[1].id, Roles=Constant_Util.DISPATCH,Notification_Point_Of_Contact__c=true );
            
            acrList.add(testACR1);
            acrList.add(testACR2);
            
            Database.insert(acrList);
            
            //Creating two records for KRG account with notification On for Negative HOC and On our way notification type
            Account_Notification_Preference__c   anpObj= new Account_Notification_Preference__c(Account_Name__c=accList.get(0).id,Notification_Status__c=NOTIF_STATUS_ON,Notification_Type__c=NOTIF_TYPE_ONOURWAY);
            Account_Notification_Preference__c   anpObj2= new Account_Notification_Preference__c(Account_Name__c=accList.get(0).id,Notification_Status__c=NOTIF_STATUS_ON,Notification_Type__c=NOTIF_TYPE_NEGATIVE_HOC);
            List<Account_Notification_Preference__c> anpList= new  List<Account_Notification_Preference__c>();
            anpList.add(anpObj);
            anpList.add(anpObj2);
            insert anpList;
            
            //Creating two records for contact notificaiton pref with notification pref as email and sms, and notif type as  On our way and  Negative HOC respectively
            
            Contact_Notification_Preference__c cnpObj = new  Contact_Notification_Preference__c(Preferred_Language__c=NOTIF_PREF_LANG_ENG,Notification_Preference__c=NOTIF_PREF_EMAIL,Notification_Type__c=NOTIF_TYPE_ONOURWAY,
                                                                                                Contact_Name__c=conList[0].id
                                                                                               );
            Contact_Notification_Preference__c cnpObj2 = new  Contact_Notification_Preference__c(Preferred_Language__c=NOTIF_PREF_LANG_FRENCH,Notification_Preference__c=NOTIF_PREF_SMS,Notification_Type__c=NOTIF_TYPE_NEGATIVE_HOC,
                                                                                                 Contact_Name__c=conList[1].id
                                                                                                );
            List<Contact_Notification_Preference__c> cnpList = new List<Contact_Notification_Preference__c> ();
            cnpList.add(cnpObj);
            cnpList.add(cnpObj2);
            insert cnpList;            
            
            //Creating 3 Service status records, 1 for on our way, 2nd negative hoc, 3rd delivery confirmation
            List<Service_Status__c> ssList= new  List<Service_Status__c>();
            service_status__c ssObj= new service_status__c(Message_Status__c='',Message_Type__c=MESSAGE_TYPE_ONOURWAY ,location__c=locationList[0].Id);
            service_status__c ssObj2= new service_status__c(Message_Status__c='',Message_Type__c=NOTIF_TYPE_NEGATIVE_HOC ,location__c=locationList[0].Id);
            service_status__c ssObj3= new service_status__c(Message_Status__c='',Message_Type__c=MESSAGE_TYPE_DEL_CNF ,location__c=locationList[0].Id);
            
            ssList.add(ssObj);
            ssList.add(ssObj2);
            ssList.add(ssObj3);            
            insert ssList;
            
            //creating 1 notification asset record associated with service status with msg type as delivery confirmation
            Notification_Asset__c naObj= new Notification_Asset__c(Service_StatusId__c=ssList.get(2).id,Is_Eligible_For_Notification__c=true,Acorn_SBID__c=12121,Status__c='Test Status',Status_Date__c =System.now() );            
            insert naObj;  
        }
    }
    
    /*
* Method where system found valid contact to be notify for on our way notification(No asset added against this service status)
*Expected result: Notification contact record inserted against service status, Is_Ready_For_Notification__c is set to true and Message status set to Complete
*/    
    public static testmethod void processPendingRec_Positive_withoutAsset(){        
        Test.startTest();
        Service_Status__c ssRec= [SELECT id ,Message_Status__c FROM service_status__c where Message_Type__c =:MESSAGE_TYPE_ONOURWAY LIMIT 1]; // SS rec with message type on our way
        ssRec.Message_Status__c=MESSAGE_STATUS_PENDING;
        update ssRec;
        Test.stopTest();
        Service_Status__c ssRec2 = [SELECT id , Message_Status__c, Is_Ready_For_Notification__c FROM Service_Status__c WHERE id = : ssRec.id LIMIT 1];
        system.assertEquals(ssRec2.Message_Status__c,MESSAGE_STATUS_COMPLETE); 
        
        List<Notification_Contact__c> ncRecList=[SELECT id,Service_StatusId__c FROM Notification_Contact__c WHERE Service_StatusId__c = : ssRec.id];
        system.assert(ncRecList.size() > 0);
        system.assert(ssRec2.Is_Ready_For_Notification__c);
        
    }
    
    
    /*
* Method where two valid contact found to be notify for service status negative hoc(No asset added against this service status)
*Expected result: 2 Notification contact record inserted against service status, Is_Ready_For_Notification__c is set to true and Message status set to Complete
*/
    
    public static testmethod void processPendingRec_Two_Notification(){
        Contact_Notification_Preference__c cnpRec= [SELECT id,Notification_Type__c FROM Contact_Notification_Preference__c WHERE Notification_Type__c=: NOTIF_TYPE_NEGATIVE_HOC LIMIT 1 ];
        cnpRec.Notification_Type__c=MESSAGE_TYPE_ONOURWAY;
        update cnpRec;
        Test.startTest();
        Service_Status__c ssRec= [SELECT id ,Message_Status__c FROM service_status__c WHERE Message_Type__c =:MESSAGE_TYPE_ONOURWAY LIMIT 1]; // SS rec with message type on our way
        ssRec.Message_Status__c=MESSAGE_STATUS_PENDING;
        update ssRec;
        Test.stopTest();
        Service_Status__c ssRec2 = [SELECT id , Message_Status__c, Is_Ready_For_Notification__c FROM service_status__c WHERE id =: ssRec.id LIMIT 1];
        system.assertEquals(ssRec2.Message_Status__c,MESSAGE_STATUS_COMPLETE);
        
        List<Notification_Contact__c> ncRecList=[SELECT id,Service_StatusId__c FROM Notification_Contact__c WHERE Service_StatusId__c = : ssRec.id];
        system.assert(ncRecList.size()== 2);
        system.assert(ssRec2.Is_Ready_For_Notification__c);        
    }
    
    /*
* Method to where no valid contact found as notification is turned off at account level for on our way(No asset added against this service status)
*Expected result: NO Notification contact record inserted against service status, Is_Ready_For_Notification__c is remains false and Message status set to Complete
*/
    public static testmethod void processPendingRec_NO_Notif_OFFAtACCLVL(){
        Account acc=[  select id from account where Name=:ACC_KROGER];
        Account_Notification_Preference__c anpRec= [SELECT id,Account_Name__c,Notification_Type__c, Notification_Status__c FROM  Account_Notification_Preference__c WHERE Account_Name__c =:acc.id AND Notification_Type__c=:NOTIF_TYPE_ONOURWAY ];
        anpRec.Notification_Status__c=NOTIF_STATUS_OFF;
        update anpRec;
        
        Contact_Notification_Preference__c cnpRec= [SELECT id,Notification_Type__c FROM Contact_Notification_Preference__c WHERE Notification_Type__c=: MESSAGE_TYPE_ONOURWAY Limit 1 ];
        
        Test.startTest();
        Service_Status__c ssRec= [SELECT id ,Message_Status__c FROM Service_Status__c WHERE Message_Type__c =:MESSAGE_TYPE_ONOURWAY LIMIT 1]; // SS rec with message type on our way
        ssRec.Message_Status__c=MESSAGE_STATUS_PENDING;
        update ssRec;
        Test.stopTest();
        
        Service_Status__c ssRec2 = [SELECT id , Message_Status__c, Is_Ready_For_Notification__c FROM service_status__c WHERE id =: ssRec.id LIMIT 1];
        
        system.assertEquals(ssRec2.Message_Status__c,MESSAGE_STATUS_COMPLETE);
        
        List<Notification_Contact__c> ncRecList=[SELECT id,Service_StatusId__c FROM Notification_Contact__c WHERE Service_StatusId__c = : ssRec.id];
        
        system.assert(ncRecList.size()== 0);
        system.assert(!ssRec2.Is_Ready_For_Notification__c);
        
        
    }
    
    /*
* Method to where no valid contact found as no point of contact found at account contact relationship level for on our way notify type
*Expected result: NO Notification contact record inserted against service status, Is_Ready_For_Notification__c is remains false and Message status set to Complete
*/    
    public static testmethod void processPendingRec_NO_Notif_OFFAtACRLevel(){    
        
        Contact_Notification_Preference__c cnpRec= [SELECT id,Notification_Type__c,Contact_Name__c  FROM Contact_Notification_Preference__c WHERE Notification_Type__c=: MESSAGE_TYPE_ONOURWAY LIMIT 1 ];
        Service_Status__c ssRec= [SELECT id ,Message_Status__c,Location__c FROM service_status__c WHERE Message_Type__c =:MESSAGE_TYPE_ONOURWAY LIMIT 1]; // SS rec with message type on our way
        
        Test.startTest();
        accountContactRelation acrRec=[SELECT id,Notification_Point_of_Contact__c FROM accountContactRelation WHERE ContactId=:cnpRec.Contact_Name__c and AccountId =:ssRec.Location__c];
        acrRec.Notification_Point_of_Contact__c = false;
        update acrRec;
        ssRec.Message_Status__c=MESSAGE_STATUS_PENDING;
        update ssRec;
        Test.stopTest();
        
        Service_Status__c ssRec2 = [SELECT id , Message_Status__c, Is_Ready_For_Notification__c FROM service_status__c WHERE id =: ssRec.id LIMIT 1];
        system.assertEquals(ssRec2.Message_Status__c,MESSAGE_STATUS_COMPLETE);
        
        List<Notification_Contact__c> ncRecList=[SELECT id,Service_StatusId__c FROM Notification_Contact__c WHERE Service_StatusId__c = : ssRec.id];
        system.assert(ncRecList.size()== 0);
        system.assert(!ssRec2.Is_Ready_For_Notification__c);
    }
    
    /*
* Method to where no valid contact found at contact notification pref level for on our way notify type
*Expected result: NO Notification contact record inserted against service status, Is_Ready_For_Notification__c is remains false and Message status set to Complete
*/    
    public static testmethod void processPendingRec_NO_Notif_OFFAtCNPLevel(){  
        Contact_Notification_Preference__c cnpRec= [SELECT id,Notification_Type__c,Contact_Name__c,Notification_Preference__c FROM Contact_Notification_Preference__c where Notification_Type__c=: MESSAGE_TYPE_ONOURWAY Limit 1 ];
        Service_Status__c ssRec= [SELECT id ,Message_Status__c,Location__c FROM service_status__c WHERE Message_Type__c =:MESSAGE_TYPE_ONOURWAY LIMIT 1]; // SS rec with message type on our way
        cnpRec.Notification_Preference__c =NOTIF_PREF_DNN;
        update cnpRec;
        ssRec.Message_Status__c=MESSAGE_STATUS_PENDING;
        Test.startTest();
        update ssRec;
        Test.stopTest();
        
        Service_Status__c ssRec2 = [SELECT id , Message_Status__c, Is_Ready_For_Notification__c FROM service_status__c WHERE id =: ssRec.id LIMIT 1];
        system.assertEquals(ssRec2.Message_Status__c,MESSAGE_STATUS_COMPLETE);
        
        List<Notification_Contact__c> ncRecList=[SELECT id,Service_StatusId__c FROM Notification_Contact__c WHERE Service_StatusId__c = : ssRec.id];
        system.assert(ncRecList.size()== 0);
        system.assert(!ssRec2.Is_Ready_For_Notification__c);        
    }
    
    /*
* Method to where no valid contact found at contact notification pref level for delivery confirmation notify type
*Expected result: NO Notification contact record inserted against service status, Is_Ready_For_Notification__c is remains false and Message status set to Complete
*/  
    public static testmethod void processPendingRec_Positive_withAsset(){    
        Test.startTest();
        Service_Status__c ssRec= [SELECT id ,Message_Status__c FROM service_status__c WHERE Message_Type__c =:MESSAGE_TYPE_DEL_CNF LIMIT 1]; // SS rec with message type on our way
        ssRec.Message_Status__c=MESSAGE_STATUS_PENDING;
        update ssRec;
        Test.stopTest();
        Notification_Asset__c naRec=  [SELECT id, Service_StatusId__c, Is_Eligible_For_Notification__c, Acorn_SBID__c, Name,Status_Date__c FROM Notification_Asset__c WHERE Service_StatusId__c =: ssRec.id ];
        System.assert(naRec.Is_Eligible_For_Notification__c);
        Service_Status__c ssRec2 = [SELECT id , Message_Status__c, Is_Ready_For_Notification__c FROM service_status__c WHERE id =: ssRec.id LIMIT 1];
        system.assertEquals(ssRec2.Message_Status__c,MESSAGE_STATUS_COMPLETE);
        
        List<Notification_Contact__c> ncRecList=[SELECT id,Service_StatusId__c FROM Notification_Contact__c WHERE Service_StatusId__c = : ssRec.id];
        system.assert(ncRecList.size()== 0);
        system.assert(!ssRec2.Is_Ready_For_Notification__c);
        
    }
    
    /*
* Test method where there are two notification asset with is eligibile flag as true
* but there is no contact with prefrere for Delivery confirmation
*Expected result: NO Notification contact record inserted against service status, Is_Ready_For_Notification__c is remains false and Message status set to Complete
*/
    public static testmethod void processPendingRec_Positive_withTwoAsset(){     
        Service_Status__c ssRec= [SELECT id ,Message_Status__c FROM service_status__c WHERE Message_Type__c =:MESSAGE_TYPE_DEL_CNF LIMIT 1]; // SS rec with message type on our way
        ssRec.Message_Status__c=MESSAGE_STATUS_PENDING;
        Notification_Asset__c naObj= new Notification_Asset__c(Service_StatusId__c=ssRec.id,Is_Eligible_For_Notification__c=true,Acorn_SBID__c=12121,Status__c='Test Status',Status_Date__c =System.now() );            
        insert naObj;
        Test.startTest();
        update ssRec;
        Test.stopTest();
        
        Notification_Asset__c naRec=  [SELECT id, Service_StatusId__c, Is_Eligible_For_Notification__c, Acorn_SBID__c, Name,Status_Date__c FROM Notification_Asset__c WHERE Service_StatusId__c =: ssRec.id LIMIT 1 ];
        system.assert(naRec.Is_Eligible_For_Notification__c);
        Service_Status__c ssRec2 = [SELECT id , Message_Status__c, Is_Ready_For_Notification__c FROM service_status__c WHERE id =: ssRec.id LIMIT 1];
        system.assertEquals(ssRec2.Message_Status__c,MESSAGE_STATUS_COMPLETE);
        
        List<Notification_Contact__c> ncRecList=[SELECT id,Service_StatusId__c FROM Notification_Contact__c WHERE Service_StatusId__c = : ssRec.id];
        system.assert(ncRecList.size()== 0);
        system.assert(!ssRec2.Is_Ready_For_Notification__c);
    }
    
    
    /**
* Test method where there is a notification asset with is eligibile flag as true
* and also we got a valid contanct pref for on our way
*Expected result: There is atleaset 1 valid Notification contact record inserted against service status, Is_Ready_For_Notification__c is set to true and Message status set to Complete
*/
    public static testmethod void processPendingRec_Positive_withAsset2a(){     
        Service_Status__c ssRec= [SELECT id ,Message_Status__c FROM service_status__c WHERE Message_Type__c =:MESSAGE_TYPE_ONOURWAY LIMIT 1]; // SS rec with message type on our way
        ssRec.Message_Status__c=MESSAGE_STATUS_PENDING;
        Notification_Asset__c naObj= new Notification_Asset__c(Service_StatusId__c=ssRec.id,Is_Eligible_For_Notification__c=true,Acorn_SBID__c=12121,Status__c='Test Status',Status_Date__c =System.now() );            
        insert naObj;
        Test.startTest();
        update ssRec;
        Test.stopTest();
        
        Notification_Asset__c naRec=  [SELECT id, Service_StatusId__c, Is_Eligible_For_Notification__c, Acorn_SBID__c, Name,Status_Date__c FROM Notification_Asset__c WHERE Service_StatusId__c =: ssRec.id LIMIT 1 ];
        system.assert(naRec.Is_Eligible_For_Notification__c);
        Service_Status__c ssRec2 = [SELECT id , Message_Status__c, Is_Ready_For_Notification__c FROM service_status__c WHERE id =: ssRec.id LIMIT 1];
        system.assertEquals(ssRec2.Message_Status__c,MESSAGE_STATUS_COMPLETE);
        
        List<Notification_Contact__c> ncRecList=[SELECT id,Service_StatusId__c FROM Notification_Contact__c WHERE Service_StatusId__c = : ssRec.id];
        system.assert(ncRecList.size()> 0);
        system.assert(ssRec2.Is_Ready_For_Notification__c);
    }
}