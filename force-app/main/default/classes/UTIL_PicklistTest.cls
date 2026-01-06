@isTest(seeAllData=false)
global class UTIL_PicklistTest {

    private static final string SYS_ADMIN = 'System Administrator';
    private static final string ObjectApiName = 'Pricing_Request__c';
    private static final string FieldApiName = 'Material_Code__c';
    private static final string fieldValue = 'Cardboard';
    private static final string dp_FieldApiName = 'Container_Size__c';
    private static final string ControllingfieldValue = 'Open Top';
    private static final string DependentfieldValue = '30 Yards';
    
    /* @description : Apex method setup */
    /* method for setting up data*/ 
    @testSetup static void setup() {
     	Profile adminProfile = TestDataFactory.getProfile(SYS_ADMIN);
        User usr = TestDataFactory.createUser(adminProfile);
        Database.insert(usr);   
    }

    /*@testmethodName- validatePicklist
    *@description- Test validatePicklist method to get Picklist value
    */
    @isTest static void testPicklist(){
        //test class errors - SDT - 33363
         List<user> currentuser = [select id, Bypass_Validation__c,isActive from user WHERE isActive = TRUE  LIMIT 1];
        system.runAs(currentuser.get(0)){
       
            Test.startTest();
            UTIL_Picklist.picklistWrapper picklistWpr =  UTIL_Picklist.validatePicklist(ObjectApiName, FieldApiName, fieldValue);

            Test.stopTest();
            system.assert(picklistWpr != null);
            system.assertEquals(picklistWpr.isvalid, true);
        }   
    }
    /*@testmethodName- validatePicklist
    *@description- Test validatePicklist method to handle exception
    */
    @isTest static void testPicklist_InValid(){
        //test class errors - SDT - 33363
         List<user> currentuser = [select id, Bypass_Validation__c,isActive from user WHERE isActive = TRUE  LIMIT 1];
        system.runAs(currentuser.get(0)){
       
            Test.startTest();
            UTIL_Picklist.picklistWrapper picklistWpr =  UTIL_Picklist.validatePicklist(ObjectApiName, null, fieldValue);

            Test.stopTest();
            system.assert(picklistWpr != null);
            system.assertEquals(picklistWpr.isvalid, false);
        }   
    }
    /*@testmethodName- validateDependentPicklist
    *@description- Test validateDependentPicklist method to get Dependent Picklist value
    */
    @isTest static void testDependentPicklist(){
        //test class errors - SDT - 33363
         List<user> currentuser = [select id, Bypass_Validation__c,isActive from user WHERE isActive = TRUE  LIMIT 1];
        system.runAs(currentuser.get(0)){
       
            Test.startTest();
            UTIL_Picklist.picklistWrapper picklistWpr =  UTIL_Picklist.validateDependentPicklist(ObjectApiName, dp_FieldApiName, ControllingfieldValue, DependentfieldValue);

            Test.stopTest();
            system.assert(picklistWpr != null);
            system.assertEquals(picklistWpr.isvalid, true);
        }   
    }
    /*@testmethodName- validateDependentPicklist
    *@description- Test validateDependentPicklist method to handle exception
    */
    @isTest static void testDependentPicklist_InValid(){
        //test class errors - SDT - 33363
         List<user> currentuser = [select id, Bypass_Validation__c,isActive from user WHERE isActive = TRUE  LIMIT 1];
        system.runAs(currentuser.get(0)){
       
            Test.startTest();
            UTIL_Picklist.picklistWrapper picklistWpr =  UTIL_Picklist.validateDependentPicklist(ObjectApiName, dp_FieldApiName, 'Test', DependentfieldValue);

            Test.stopTest();
            system.assert(picklistWpr != null);
            system.assertEquals(picklistWpr.isvalid, false);
        }   
    }
}