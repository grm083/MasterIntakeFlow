@isTest(seeAllData = false)
public class BusinessRuleNSCHelperTest {
    
    private static final string SYS_ADMIN = 'System Administrator';
    private static final string KROGER = 'kroger';
    private static final string RITA = 'Rita';
    private static final string REPLY = 'Reply';
    private static final string NY_TIMEZONE = 'America/New_York';
    private static final string PO_PSI_VALUE = 'PO Number'; //SDT-33363- changing PO Number;Company category to PO number

    
    /* set the test data*/
    @testSetup static void setup() {
        Profile p = TestDataFactory.getProfile(SYS_ADMIN);
        User usr = TestDataFactory.createUser(p);
        usr.bypass_validation__c = true;
        Database.insert(usr);
        
        system.runAs(usr){
            list<Account> acclist = TestDataFactory.createAccount(KROGER, usr,Constant_Util.CLIENT);
            Database.insert(acclist);
            
            List<Categorization__c> cgList = new List<Categorization__c>();
            Categorization__c cg1 = new Categorization__c();
            cg1.Client_Account__c = acclist[0].Id;
            cg1.Category__c = 'Location Type';
            cg1.Name = 'Kroger Type';
            cgList.add(cg1);
            
            Categorization__c cg2 = new Categorization__c();
            cg2.Client_Account__c = acclist[0].Id;
            cg2.Category__c = 'Geography';
            cg2.Name = 'Geography Type';
            cgList.add(cg2);
            
            Categorization__c cg3 = new Categorization__c();
            cg3.Client_Account__c = acclist[0].Id;
            cg3.Category__c = 'Division/Department';
            cg3.Name = 'DivisionDepartment Type';
            cgList.add(cg3);
            
            Categorization__c cg4 = new Categorization__c();
            cg4.Client_Account__c = acclist[0].Id;
            cg4.Category__c = 'Brand';
            cg4.Name = 'Brand Type';
            cgList.add(cg4);
            Database.insert(cgList);
            
            list<Account> locationlist = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, acclist.get(0).id);
            locationlist[0].tz__Timezone_SFDC__c = NY_TIMEZONE;
            locationlist[0].tz__UTF_Offset__c = -4;
            locationlist[0].Location_Type__c = cg1.Id;
            locationlist[0].Geography__c = cg2.Id;
            locationlist[0].Division__c = cg3.Id;
            locationlist[0].Brand__c = cg4.Id;
            Database.insert(locationlist);
            
            list<Contact> conlist = TestDataFactory.createContact(RITA,REPLY, acclist.get(0), usr);
            Database.insert(conlist);
            
            list<Case> caselist = new list<Case>(); 
            Case cs = new Case(Status ='New', Priority = 'Medium', Origin = 'Phone', ContactId = conlist[0].id, 
                               AccountId = locationlist[0].ParentId, OwnerId = usr.id, Client__c = locationlist[0].ParentId, Location__c = locationlist[0].id, 
                               Case_Type__c = 'New Service', Case_Sub_Type__c = 'Permanent', Case_Reason__c = 'Existing Location',
                               SlaStartDate = system.today(),Recordtypeid = TestDataFactory.getRecordType('New Service Case','Case'));
            caselist.add(cs);
            try{
                Database.insert(caselist);
            }catch(Exception ex){
                system.debug('Exception while inserting case:::'+ex.getStackTraceString());
            }
        }
    }
    
    @isTest static void testSelectFirstBR(){
        user currentuser = [select id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        
        system.runAs(currentuser){
            Test.startTest();
            list<case> caselist = [select id, origin, contactid, Case_Type__c,Contact_Title__c, Client__c, Location__c,Site_Contact__c,Site_Contact_Phone__c,
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,OwnerId,
                                   Service_Date__c,SLA_Service_Date_Time__c,Location__r.Location_Type__c,Location__r.Geography__c,
                                   Location__r.Division__c,Location__r.Brand__c,
                                   Case_Reason__c from case where status = 'New' limit 1];
            list<Business_Rule__c> brlist = new list<Business_Rule__c>();
            Business_Rule__c brObj = new Business_Rule__c();
            brObj.Accountid__c = caselist[0].Client__c;
            brObj.LocationId__c = caselist[0].Location__c;
            brObj.Request_Type__c = 'New Service';
            brObj.Service__c = 'Permanent';
            brObj.RecordTypeid = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.REQUIRED_INFORMATION).getRecordTypeId();
            brObj.Required_Information__c = PO_PSI_VALUE; 
            brObj.Effective_Date__c = System.today()-1;
            brObj.Active__c=True;
            brlist.add(brObj);
            Database.insert(brlist);
            
            BusinessRuleNSCHelper.selectBusinessRules(caselist);
            Test.stopTest();
            
        }
    }
    
    @isTest static void testSelectSecondBR(){
        user currentuser = [select id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        
        system.runAs(currentuser){
            Test.startTest();
            list<case> caselist = [select id, origin, contactid, Case_Type__c,Contact_Title__c, Client__c, Location__c,Site_Contact__c,Site_Contact_Phone__c,
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,OwnerId,
                                   Service_Date__c,SLA_Service_Date_Time__c,Location__r.Location_Type__c,Location__r.Geography__c,
                                   Location__r.Division__c,Location__r.Brand__c,
                                   Case_Reason__c from case where status = 'New' limit 1];
            
            Business_Rule__c brObj1 = new Business_Rule__c();
            brObj1.Accountid__c = caselist[0].Client__c;
            brObj1.Request_Type__c = 'New Service';
            brObj1.Service__c = 'Permanent';
            brObj1.RecordTypeid = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.REQUIRED_INFORMATION).getRecordTypeId();
            brObj1.Required_Information__c = PO_PSI_VALUE;
            brObj1.Effective_Date__c = System.today()-1;
            brObj1.Active__c=True;
            Database.insert(brObj1);
            
            BusinessRuleNSCHelper.selectBusinessRules(caselist);
            Test.stopTest();
            
        }
    }
    
    @isTest static void testSelectThirdBR(){
        user currentuser = [select id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        
        system.runAs(currentuser){
            Test.startTest();
            list<case> caselist = [select id, origin, contactid, Case_Type__c,Contact_Title__c, Client__c, Location__c,Site_Contact__c,Site_Contact_Phone__c,
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,OwnerId,
                                   Service_Date__c,SLA_Service_Date_Time__c,Location__r.Location_Type__c,Location__r.Geography__c,
                                   Location__r.Division__c,Location__r.Brand__c,
                                   Case_Reason__c from case where status = 'New' limit 1];
            
            Categorization__c category = [Select Id from Categorization__c where Category__c = 'Location Type' LIMIT 1 ];
            
            Business_Rule__c brObj1 = new Business_Rule__c();
            brObj1.Accountid__c = caselist[0].Client__c;
            brObj1.Request_Type__c = 'New Service';
            brObj1.Service__c = 'Permanent';
            brObj1.RecordTypeid = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.REQUIRED_INFORMATION).getRecordTypeId();
            brObj1.Required_Information__c = PO_PSI_VALUE;
            brObj1.Effective_Date__c = System.today()-1;
            brObj1.Category_Type__c  = 'Location Type';
            brObj1.Group__c = category.Id;
            brObj1.Active__c=True;
            Database.insert(brObj1);
            
            BusinessRuleNSCHelper.selectBusinessRules(caselist);
            Test.stopTest();
            
        }
    }
    
    @isTest static void testSelectFourthBR(){
        user currentuser = [select id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        
        system.runAs(currentuser){
            Test.startTest();
            list<case> caselist = [select id, origin, contactid, Case_Type__c,Contact_Title__c, Client__c, Location__c,Site_Contact__c,Site_Contact_Phone__c,
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,OwnerId,
                                   Service_Date__c,SLA_Service_Date_Time__c,Location__r.Location_Type__c,Location__r.Geography__c,
                                   Location__r.Division__c,Location__r.Brand__c,
                                   Case_Reason__c from case where status = 'New' limit 1];
            
            Categorization__c category = [Select Id from Categorization__c where Category__c = 'Geography' LIMIT 1 ];
            
            Business_Rule__c brObj1 = new Business_Rule__c();
            brObj1.Accountid__c = caselist[0].Client__c;
            brObj1.Request_Type__c = 'New Service';
            brObj1.Service__c = 'Permanent';
            brObj1.RecordTypeid = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.REQUIRED_INFORMATION).getRecordTypeId();
            brObj1.Required_Information__c = PO_PSI_VALUE;
            brObj1.Effective_Date__c = System.today()-1;
            brObj1.Category_Type__c  = 'Geography';
            brObj1.Group__c = category.Id;
            brObj1.Active__c=True;
            Database.insert(brObj1);
            
            BusinessRuleNSCHelper.selectBusinessRules(caselist);
            Test.stopTest();
            
        }
    }
    
    @isTest static void testSelectFifthBR(){
        user currentuser = [select id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        
        system.runAs(currentuser){
            Test.startTest();
            list<case> caselist = [select id, origin, contactid, Case_Type__c,Contact_Title__c, Client__c, Location__c,Site_Contact__c,Site_Contact_Phone__c,
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,OwnerId,
                                   Service_Date__c,SLA_Service_Date_Time__c,Location__r.Location_Type__c,Location__r.Geography__c,
                                   Location__r.Division__c,Location__r.Brand__c,
                                   Case_Reason__c from case where status = 'New' limit 1];
            
            Categorization__c category = [Select Id from Categorization__c where Category__c = 'Division/Department' LIMIT 1 ];
            
            Business_Rule__c brObj1 = new Business_Rule__c();
            brObj1.Accountid__c = caselist[0].Client__c;
            brObj1.Request_Type__c = 'New Service';
            brObj1.Service__c = 'Permanent';
            brObj1.RecordTypeid = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.REQUIRED_INFORMATION).getRecordTypeId();
            brObj1.Required_Information__c = PO_PSI_VALUE;
            brObj1.Effective_Date__c = System.today()-1;
            brObj1.Category_Type__c  = 'Division/Department';
            brObj1.Group__c = category.Id;
            brObj1.Active__c=True;
            Database.insert(brObj1);
            
            BusinessRuleNSCHelper.selectBusinessRules(caselist);
            Test.stopTest();
            
        }
    }
    
    @isTest static void testSelectSixthBR(){
        user currentuser = [select id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        
        system.runAs(currentuser){
            Test.startTest();
            list<case> caselist = [select id, origin, contactid, Case_Type__c,Contact_Title__c, Client__c, Location__c,Site_Contact__c,Site_Contact_Phone__c,
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,OwnerId,
                                   Service_Date__c,SLA_Service_Date_Time__c,Location__r.Location_Type__c,Location__r.Geography__c,
                                   Location__r.Division__c,Location__r.Brand__c,
                                   Case_Reason__c from case where status = 'New' limit 1];
            
            Categorization__c category = [Select Id from Categorization__c where Category__c = 'Brand' LIMIT 1 ];
            
            Business_Rule__c brObj1 = new Business_Rule__c();
            brObj1.Accountid__c = caselist[0].Client__c;
            brObj1.Request_Type__c = 'New Service';
            brObj1.Service__c = 'Permanent';
            brObj1.RecordTypeid = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.REQUIRED_INFORMATION).getRecordTypeId();
            brObj1.Required_Information__c = PO_PSI_VALUE;
            brObj1.Effective_Date__c = System.today()-1;
            brObj1.Category_Type__c  = 'Brand';
            brObj1.Group__c = category.Id;
            brObj1.Active__c=True;
            Database.insert(brObj1);
            
            BusinessRuleNSCHelper.selectBusinessRules(caselist);
            Test.stopTest();
            
        }
    }
    
}