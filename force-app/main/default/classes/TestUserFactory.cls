/**
* @author TCS
* @date 2/21/2024
* @description : Apex class TestUserFactory
**/
@isTest
public class TestUserFactory {
    public static User createUserDetails(Profile P){
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User usr = new User(Alias = 'standt', Email= uniqueName + '@test' + orgId + '.org', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p.Id, Acorn_SUser_ID__c = 999,
                            TimeZoneSidKey='America/Los_Angeles', UserName= uniqueName + '@test' + orgId + '.org', IsActive = true);
        return usr;
    }
    
    /*
    * @vendor            TCS
    * @story             
    * @author            Manisha Patil
    * @description       This method will be used to setup inital required data to test the methods.
    * @param             none
    * @return            List of User for Customer Service
    */
    public static User getCSRUserDetails(Boolean BypassValidation, Boolean GenesysEnabled){
        Set<String> permissionsetNames = new Set<String>{'Customer_Service_Reporting_User','Governance_Team','Merge_Access_for_Non_Admin_Users',
                                                     'Price_Accessibility_Permission_Set','Pricing_Access', 'CPQ_Extended_License'};    
        List<PermissionSetLicense> pslList= [SELECT Id FROM PermissionSetLicense WHERE DeveloperName = 'SalesforceCPQ_CPQStandardPerm' AND Status='Active'];
   
        //fetching Customer Service profile 
        Profile CustomerServieUser = TestDataFactory.getProfile(Constant_Util.CUSTOMER_SERVICE);
        //creating a CSR user
        User CSRUser = TestDataFactory.createUser(CustomerServieUser);
        CSRUser.Bypass_Validation__c = BypassValidation;
        CSRUser.Genesys_Enabled__c = GenesysEnabled;
        CSRUser.LastName = 'TestingForApproval';
        Database.Insert(CSRUser);
        //Assigning permissionset license
        insert new PermissionSetLicenseAssign(AssigneeId = CSRUser.Id, PermissionSetLicenseId= pslList[0].Id);
        //assigning permission sets
        QuoteTestDataFactory.assignPermissionSet(permissionsetNames, CSRUser);
        return CSRUser;
    }

    /*
    * @vendor            TCS
    * @story             
    * @author            Ruchika
    * @description       This method will insert and return a csr user with a ucc code.
    * @param             BypassValidation,GenesysEnabled and UCC
    * @return            User for Customer Service with UCC
    */
    
    public static User getCSRUserDetailswithUCC(Boolean BypassValidation, Boolean GenesysEnabled, String UCC){
        User currentuser = TestUserFactory.getCSRUserDetails(BypassValidation, GenesysEnabled);
        currentuser.User_categorization_code__c = UCC;
        update currentuser;
        return currentuser;
    }
    
}