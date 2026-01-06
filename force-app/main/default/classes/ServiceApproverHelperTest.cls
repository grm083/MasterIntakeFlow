/**
* @author Accenture
* @date 2/12/2019
* @description : Apex class ServiceApproverHelperTest 
**/

/* test class for ServiceApproverHelper*/
@isTest(seeAllData = false)
public class ServiceApproverHelperTest {
    private static final string SYS_ADMIN = 'System Administrator';
    private static final string DISTRICT_MANAGER = 'District Manager';
    private static final string EMAIL = 'standarduser@testorg.com';
    private static final string NAME = 'Test';
    /* set up the test data */
    @testSetup static void setup() {
        Profile p = TestDataFactory.getProfile(SYS_ADMIN);
        User usr = TestDataFactory.createUser(p);
        usr.IsActive = true;
        Database.insert(usr);
        
        system.runAs(usr){
            list<Account> acclist = TestDataFactory.createAccount(Constant_Util.KEYWORD_TEST, usr,Constant_Util.CLIENT);
            Database.insert(acclist);
            list<Account_Title__c> titlelst = TestDataFactory.createAccountTitle(acclist.get(0),DISTRICT_MANAGER);
            Database.insert(titlelst,false);
            Profile pro = TestDataFactory.getProfile(Constant_Util.CAT_RECORD_TYPE);
            User accountTeamusr = TestDataFactory.createUser(pro);
            Database.insert(accountTeamusr);
            list<Account> locationlist = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, acclist.get(0).id);
            Database.insert(locationlist);
            list<Business_Rule__c> businessrulelist = TestDataFactory.createBusinessRule(Constant_Util.CONSTANT_FIRST, acclist.get(0), 
                                                                                         locationlist.get(0));
            businessrulelist[0].Active__c = false;
            businessrulelist[0].RecordTypeId = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.APPROVAL).getRecordTypeId();
            Database.insert(businessrulelist);
            list<Contact> conlist = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST,Constant_Util.CONSTANT_LAST, acclist.get(0), usr);
            Database.insert(conlist);
            list<Contact> conlist2 = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST,Constant_Util.CONSTANT_LAST, acclist.get(0), usr);
            conlist2[0].Contact_Status__c = 'Active';
            conlist2[0].Business_Rule_Association__c = 'No';
            Database.insert(conlist2);
        	Id conRecType = TestDataFactory.getRecordType(Constant_Util.CONTACT_RECORD_TYPE,Constant_Util.SERVICE_APPROVER);
            Business_Rule__c brule = [Select Id,LocationId__c,Accountid__c,Container__c,Service__c,Request_Type__c,Schedule_Type__c,Active__c,Effective_Date__c,Channel_Req__c,RecordTypeid,No_Approval_Required__c from Business_Rule__c where RecordTypeId =: Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.APPROVAL).getRecordTypeId() Limit 1];
           	list<Service_Approver__c> serviceApproverlist = TestDataFactory.createServiceApprover(brule);
            serviceApproverlist[0].RecordTypeId = conRecType;
            serviceApproverlist[0].Approver_Contact__c = conlist2[0].Id;
            Database.insert(serviceApproverlist);
            list<product2> productlist = TestDataFactory.createProduct(Constant_Util.KEYWORD_TEST);
            Database.insert(productlist);
            list<Asset> assetlist = TestDataFactory.createAsset(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                                productlist.get(0), usr, locationlist.get(0));
            Database.insert(assetlist);
            
            AccountTeamMember member = TestDataFactory.createAccountTeamMember(acclist.get(0),accountTeamusr.Id);
            Database.insert(member);
        } 
        
    }
    /* test method for validate by Account team member and Title*/
    @isTest static void validateCATandTitle(){
        Profile sysId = TestDataFactory.getProfile(SYS_ADMIN);
        user currentuser = [select id, Bypass_Validation__c,IsActive from user where ProfileId =: sysId.Id and IsActive = true limit 1];
        currentuser.IsActive = true;
        system.runAs(currentuser){
            
            List<Account> acclst = [Select id from Account LIMIT 49999];
            Business_Rule__c brule = [Select Id,LocationId__c,Accountid__c,Container__c,Service__c,Request_Type__c,Schedule_Type__c,Active__c,Effective_Date__c,Channel_Req__c,RecordTypeid from Business_Rule__c where RecordTypeId =: Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.APPROVAL).getRecordTypeId() Limit 1];
            
            list<Service_Approver__c> serviceApproverlist = TestDataFactory.createServiceApprover(brule);
            Database.insert(serviceApproverlist,false);
            Business_Rule__c activebrule = [Select Id,Active__c,End_Date__c from Business_Rule__c where Id =:brule.Id Limit 1];
            activebrule.End_Date__c = system.today()-1;
            Test.startTest();
            Database.update(activebrule,false);
            Account_Title__c title = [Select id from Account_Title__c Limit 1];
            serviceApproverlist.clear();
            serviceApproverlist = TestDataFactory.createServiceApprover(brule);
            serviceApproverlist[0].RecordTypeId = Schema.SObjectType.Service_Approver__c.getRecordTypeInfosByName().get(Constant_Util.ATM_RECORD_TYPE).getRecordTypeId();
            serviceApproverlist[0].Title__c = title.Id;
            Database.insert(serviceApproverlist,false);
            serviceApproverlist.clear();
           // Profile pro_CAT = TestDataFactory.getProfile(Constant_Util.CAT_RECORD_TYPE);
            //user user_CAT = [Select Id from User where ProfileId =: pro_CAT.Id and Email =: EMAIL Limit 1];
            serviceApproverlist = TestDataFactory.createServiceApprover(brule);
            serviceApproverlist[0].RecordTypeId = Schema.SObjectType.Service_Approver__c.getRecordTypeInfosByName().get(Constant_Util.ATM_RECORD_TYPE).getRecordTypeId();
            //serviceApproverlist[0].Account_Team_Member__c = user_CAT.Id;
			serviceApproverlist[0].Account__c = null;
            Database.insert(serviceApproverlist,false);
            Test.stopTest();
           // system.assert(serviceApproverlist[0].Id == null);
           // system.assert(activebrule.Active__c);
        }
        
    }
    /* test method for validate by External Approver*/
    @isTest static void validateExternalApprover(){
        Profile sysId = TestDataFactory.getProfile(SYS_ADMIN);
        user currentuser = [select id, Bypass_Validation__c from user where ProfileId =: sysId.Id and IsActive = true limit 1];
        currentuser.IsActive = true;
        system.runAs(currentuser){
            Id recordtype = TestDataFactory.getRecordType(Constant_Util.DEPARTMENT_RECORDTYPE,Constant_Util.SERVICE_APPROVER);
            Id contactRecType = TestDataFactory.getRecordType(Constant_Util.CONTACT_RECORD_TYPE,Constant_Util.SERVICE_APPROVER);
            Business_Rule__c brule = [Select Id,LocationId__c,Accountid__c,Container__c,Service__c,Request_Type__c,Schedule_Type__c,Active__c,Effective_Date__c,Channel_Req__c,RecordTypeid,No_Approval_Required__c from Business_Rule__c where RecordTypeId =: Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.APPROVAL).getRecordTypeId() Limit 1];
            brule.No_Approval_Required__c = true;
			brule.Active__c = false;
            Database.update(brule);
            list<Service_Approver__c> serviceApproverlist = TestDataFactory.createServiceApprover(brule);
            serviceApproverlist[0].RecordTypeId = recordtype;
            serviceApproverlist[0].External_Approver_Name__c = NAME;
            Test.startTest();
            Database.insert(serviceApproverlist,false);
            
            brule.No_Approval_Required__c = false;
            Database.update(brule);
            list<Service_Approver__c> serviceApproverlist1 = TestDataFactory.createServiceApprover(brule);
            serviceApproverlist1[0].RecordTypeId = recordtype;
            serviceApproverlist1[0].External_Approver_Name__c = NAME;
            Database.insert(serviceApproverlist1,false);
            
            serviceApproverlist.clear();
            serviceApproverlist = TestDataFactory.createServiceApprover(brule);
            serviceApproverlist[0].RecordTypeId = contactRecType;
            Database.insert(serviceApproverlist);
            
            serviceApproverlist[0].Requester_Only__c = true;
            serviceApproverlist[0].Active__c = false;
            List<Service_Approver__c> delSa = [select id from Service_Approver__c where Id !=: serviceApproverlist[0].Id];
            Database.delete(delSa);
            Database.update(serviceApproverlist[0],true);
            Test.stopTest();
            Business_Rule__c activebrule = [Select Id,Active__c  from Business_Rule__c where Id =:brule.Id Limit 1];
            system.assert(!activebrule.Active__c);
        }
        
    }
    
    /* test method for cover exception*/
    
    @isTest static void exceptionCoverage(){
        Profile sysId = TestDataFactory.getProfile(SYS_ADMIN);
        user currentuser = [select id, Bypass_Validation__c from user where ProfileId =: sysId.Id and IsActive = true limit 1];
        currentuser.IsActive = true;
        system.runAs(currentuser){
            List<Service_Approver__c> serviceApprover;
            Test.startTest();
            ServiceApproverHandler.onbeforeInsert(serviceApprover,true);
            ServiceApproverHandler.onafterInsert(serviceApprover,Null,true);
            ServiceApproverHelper.validateSA(serviceApprover);
            ServiceApproverHelper.activateBr(serviceApprover);
            ServiceApproverHelper.activateConSt(serviceApprover);
            Business_Rule__c brule = [Select Id,LocationId__c,Accountid__c,Container__c,Service__c,Request_Type__c,Schedule_Type__c,Active__c,Effective_Date__c,Channel_Req__c,RecordTypeid from Business_Rule__c where RecordTypeId =: Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.APPROVAL).getRecordTypeId() Limit 1];          
            Test.stopTest();
            system.assert(serviceApprover == null);
        }
    }
    @isTest static void toUpdateServiceApprover(){
        Profile sysId = TestDataFactory.getProfile(SYS_ADMIN);
        user currentuser = [select id, Bypass_Validation__c from user where ProfileId =: sysId.Id and IsActive = true limit 1];
        currentuser.IsActive = true;
        Id recordtype = TestDataFactory.getRecordType(Constant_Util.USER_RECORDTYPE,Constant_Util.SERVICE_APPROVER);
        Id emailRecType = TestDataFactory.getRecordType(Constant_Util.ORIGIN_EMAIL,Constant_Util.SERVICE_APPROVER);
        system.runAs(currentuser){
            Business_Rule__c brule = [Select Id,LocationId__c,Accountid__c,Container__c,Service__c,Request_Type__c,Schedule_Type__c,Active__c,Effective_Date__c,Channel_Req__c,RecordTypeid,No_Approval_Required__c from Business_Rule__c where RecordTypeId =: Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.APPROVAL).getRecordTypeId() Limit 1];
        	list<Service_Approver__c> saplist = new list<Service_Approver__c>();
            list<Service_Approver__c> serviceApproverlist = TestDataFactory.createServiceApprover(brule);
            serviceApproverlist[0].RecordTypeId = recordtype;
            serviceApproverlist[0].External_Approver_Name__c = NAME;
            Database.insert(serviceApproverlist);
            saplist.add(serviceApproverlist[0]);
            serviceApproverlist.clear();
            serviceApproverlist = TestDataFactory.createServiceApprover(brule);
            serviceApproverlist[0].RecordTypeId = emailRecType;
          	saplist.add(serviceApproverlist[0]);
            Database.insert(serviceApproverlist);
            
            brule.Active__c = false;
            Database.update(brule);
            saplist[0].Requester_Only__c = true;
            saplist[0].Active__c = false;
            Database.update(serviceApproverlist);
            Business_Rule__c activebrule = [Select Id,Active__c  from Business_Rule__c where Id =:brule.Id Limit 1];
            system.assert(!activebrule.Active__c);
        }
    }
     @isTest static void toUpdateContactServiceApprover(){
        Profile sysId = TestDataFactory.getProfile(SYS_ADMIN);
        user currentuser = [select id, Bypass_Validation__c from user where ProfileId =: sysId.Id and IsActive = true limit 1];
        currentuser.IsActive = true;
         
        Id conRecType = TestDataFactory.getRecordType(Constant_Util.CONTACT_RECORD_TYPE,Constant_Util.SERVICE_APPROVER);
        system.runAs(currentuser){
            Business_Rule__c brule = [Select Id,LocationId__c,Accountid__c,Container__c,Service__c,Request_Type__c,Schedule_Type__c,Active__c,Effective_Date__c,Channel_Req__c,RecordTypeid,No_Approval_Required__c from Business_Rule__c where RecordTypeId =: Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.APPROVAL).getRecordTypeId() Limit 1];
            Contact con = [Select Id , Contact_Status__c from Contact limit 1];
            con.Contact_Status__c = 'Active';
            update con;
            list<Service_Approver__c> saplist = new list<Service_Approver__c>();
            list<Service_Approver__c> serviceApproverlist = TestDataFactory.createServiceApprover(brule);
            serviceApproverlist[0].RecordTypeId = conRecType;
            serviceApproverlist[0].Approver_Contact__c = con.Id;
          	saplist.add(serviceApproverlist[0]);
            Database.insert(serviceApproverlist);
            
            Contact con1 = [Select Id,Contact_Status__c from Contact where Id=: con.Id];
            system.assertEquals('Active',con1.Contact_Status__c);
        }
    }
   
    @isTest static void toUpdateBusinessRuleAssociation(){
        Profile sysId = TestDataFactory.getProfile(SYS_ADMIN);
        user currentuser = [select id, Bypass_Validation__c from user where ProfileId =: sysId.Id and IsActive = true limit 1];
        currentuser.IsActive = true;
         
        Id conRecType = TestDataFactory.getRecordType(Constant_Util.CONTACT_RECORD_TYPE,Constant_Util.SERVICE_APPROVER);
        system.runAs(currentuser){
            Business_Rule__c brule = [Select Id,LocationId__c,Accountid__c,Container__c,Service__c,Request_Type__c,Schedule_Type__c,Active__c,Effective_Date__c,Channel_Req__c,RecordTypeid,No_Approval_Required__c from Business_Rule__c where RecordTypeId =: Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.APPROVAL).getRecordTypeId() Limit 1];
            Contact con = [Select Id , Contact_Status__c from Contact limit 1];
            con.Contact_Status__c = 'Active';
            con.Business_Rule_Association__c = 'No';
            update con;
            Service_Approver__c sa = [Select Id , Approver_Contact__c from Service_Approver__c limit 1];
            sa.Approver_Contact__c=con.id;
            update sa;
            Contact con1 = [Select Id,Contact_Status__c from Contact where Id=: con.Id];
            system.assertEquals('No',con.Business_Rule_Association__c);
        }
    }
	
	@isTest static void itShouldInsertOriginApprover(){
        String recId = Schema.SObjectType.Service_Approver__c.getRecordTypeInfosByName().get(Constant_Util.ORIGIN).getRecordTypeId();
        Business_Rule__c brule = [Select Id,LocationId__c,Accountid__c,Container__c,Service__c,Request_Type__c,Schedule_Type__c,Active__c,Effective_Date__c,Channel_Req__c,RecordTypeid,No_Approval_Required__c from Business_Rule__c where RecordTypeId =: Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.APPROVAL).getRecordTypeId() Limit 1];
        list<Service_Approver__c> saplist = new list<Service_Approver__c>();
        list<Service_Approver__c> serviceApproverlist = TestDataFactory.createServiceApprover(brule);
        serviceApproverlist[0].RecordTypeId = recId;
        serviceApproverlist[0].Origin__c = 'Monitor';
        saplist.add(serviceApproverlist[0]);
        Database.insert(serviceApproverlist);
        list<Service_Approver__c> serviceApproverInserted = [Select id from Service_Approver__c where recordTypeId =:recId ];
        System.assertEquals(1, serviceApproverInserted.size());
    }
}