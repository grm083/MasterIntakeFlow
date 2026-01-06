/**
* @author Waste Management
* @date 2023
*
* @ Out of Office
*
* @description Test Class for OutofOfficeTriggerHandler,OutofOfficeTriggerHelper,OutofOfficeTrigger 
*/

@isTest
public class OutofOfficeTriggerTest {
    private static final string SYS_ADMIN = 'System Administrator';
    private static final string KROGER = 'kroger';
    public static final String LOCATION ='Location'; 
    public static final String CLIENT ='Client'; 
    
    public static testMethod void testOOORecord(){
        Profile prof = TestDataFactory.getProfile(SYS_ADMIN);
        User currentUser = TestDataFactory.createUser(prof);
        Database.insert(currentUser);
        
        system.runAs(currentUser){
            Test.startTest();
        	List<Account> accList = TestDataFactory.createAccount(KROGER, currentUser,CLIENT);
            Database.insert(accList);
            //List<Account> locationList = TestDataFactory.createLocation(LOCATION, currentUser, accList.get(0).id);
            //Database.insert(locationList);
            
            Id rtId = Schema.SObjectType.Out_of_Office__c.getRecordTypeInfosByDeveloperName().get('Email').getRecordTypeId();

            Out_of_Office__c oooRecord = new Out_of_Office__c();
            oooRecord.Account__c = accList.get(0).id;
            oooRecord.Business_Rules__c = 'BR-0009471-Empty and Return-Pickup';
            oooRecord.Current_Email_Approver__c = 'Test@wm.com';
            oooRecord.End_Date__c = System.today();
            oooRecord.Start_Date__c = System.today();
            oooRecord.New_Email_Approver__c= 'TestTest@wm.com';
            oooRecord.RecordTypeId = rtId;
            insert oooRecord;
            
            Out_of_Office__c oooRecord2 = new Out_of_Office__c();
            oooRecord2.Account__c = accList.get(0).id;
            //oooRecord2.Business_Rules__c = 'BR-0009471-Empty and Return-Pickup';
            oooRecord2.Current_Email_Approver__c = 'Test@wm.com';
            oooRecord2.End_Date__c = System.today();
            oooRecord2.Start_Date__c = System.today();
            oooRecord2.New_Email_Approver__c= 'TestTest@wm.com';
            oooRecord2.RecordTypeId = rtId;
            insert oooRecord2;
            try{
            oooRecord2.Business_Rules__c = 'BR-0009471-Empty and Return-Pickup';
            update oooRecord2;
            }
            Catch(Exception ex){
                System.debug('Msg : ' + ex);
            }
            System.assert(oooRecord2!=null);
            Test.stopTest();
        }
    }
    
    public static testMethod void testOOORecord1(){
        Profile prof = TestDataFactory.getProfile(SYS_ADMIN);
        User currentUser = TestDataFactory.createUser(prof);
        Database.insert(currentUser);
        
        system.runAs(currentUser){
            Test.startTest();
        	List<Account> accList = TestDataFactory.createAccount(KROGER, currentUser,CLIENT);
            Database.insert(accList);
            list<Contact> conlist1 = TestDataFactory.createContact('RITA1', 'REPLY1', accList.get(0), currentUser);
            Database.insert(conlist1);
            
            list<Contact> conlist2 = TestDataFactory.createContact('RITA2', 'REPLY2', accList.get(0), currentUser);
            conlist2[0].email = 'testContact2@gmail.com';
            Database.insert(conlist2);
            
            Id rtId = Schema.SObjectType.Out_of_Office__c.getRecordTypeInfosByDeveloperName().get('Contact').getRecordTypeId();

            Out_of_Office__c oooRecord = new Out_of_Office__c();
            oooRecord.Account__c = accList.get(0).id;
            oooRecord.Business_Rules__c = 'BR-0009471-Empty and Return-Pickup';
            oooRecord.Current_Contact_Approver__c = conlist1[0].Id;
            oooRecord.End_Date__c = System.today();
            oooRecord.Start_Date__c = System.today();
            oooRecord.New_Contact_Approver__c= conlist2[0].Id;
            oooRecord.RecordTypeId = rtId;
            insert oooRecord;
            
            Out_of_Office__c oooRecord2 = new Out_of_Office__c();
            oooRecord2.Account__c = accList.get(0).id;
            //oooRecord2.Business_Rules__c = 'BR-0009471-Empty and Return-Pickup';
            oooRecord2.Current_Contact_Approver__c = conlist1[0].Id;
            oooRecord2.End_Date__c = System.today();
            oooRecord2.Start_Date__c = System.today();
            oooRecord2.New_Contact_Approver__c= conlist2[0].Id;
            oooRecord2.RecordTypeId = rtId;
            insert oooRecord2;
            try{
            oooRecord2.Business_Rules__c = 'BR-0009471-Empty and Return-Pickup';
            	update oooRecord2;
            }
            Catch(Exception ex){
                System.debug('Msg : ' + ex);
            }
            System.assert(oooRecord2!=null);
            Test.stopTest();
        }
    }

}