/**
* @author WM
* @date 1/28/2022
* @description : Apex class AccountTeamMemberUIController_Test (Test Class For AccountTeamMemberUIController)
*@UserStory - STD-17780
**/
@isTest
public class AccountTeamMemberUIController_Test {
    /**
* @author WM
* @date 1/28/2022
* @description : Apex method setup 
**/
    // method for setting up data    
    @testSetup static void setup() {
        List<User> userList = new List<User>();
        Profile p = TestDataFactory.getProfile('System Administrator');
        User usr = TestDataFactory.createUser(p);
        User userCss = TestDataFactory.createUser(p);
        userCss.UserName = 'CorporateServiceSpecialist@test.com';
        User userMulti = TestDataFactory.createUser(p);
        userMulti.UserName = 'ProgramManagerSpecialist@test.com';
        User userSD = TestDataFactory.createUser(p);
        userSD.UserName = 'SalesDirectorUser@test.com';
        User userSD2 = TestDataFactory.createUser(p);
        userSD2.UserName = 'SalesDirectorUserTwo@test.com';
        userList.add(usr);
        userList.add(userCss);
        userList.add(userMulti);
        userList.add(userSD);
        userList.add(userSD2);
        Database.insert(userList);
        system.runAs(usr){
            list<Account> acclist = TestDataFactory.createAccount(Constant_Util.KEYWORD_TEST, usr);
            //added as part of SDT-40683
            accList[0].Account_Team_Email__c = 'av4@wm.com;adey@wm.com';
            Database.insert(acclist);
            list<Account> locationlist = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, acclist.get(0).id);
            Database.insert(locationlist);
            List<Contact> conlist = TestDataFactory.createContact('Rita','Reply', acclist.get(0), usr);
            conlist[0].Preferred_Method__c='Email';
            Database.insert(conlist);  
            List<product2> productlist = TestDataFactory.createProduct('8 yrd');
            Database.insert(productlist);
            List<Asset> assetlist = TestDataFactory.createAsset('8 yrd Dumpster', acclist.get(0), conlist.get(0), productlist.get(0), usr, locationlist.get(0));
            Database.insert(assetlist);
            List<AccountTeamMember> accTeamMemberList = new List<AccountTeamMember>();
            AccountTeamMember accTeammberPM = new AccountTeamMember(AccountId =acclist.get(0).id,UserId=usr.Id,Team_Roles_Multi__c='National Accounts Program Manager (PM),National Account Manager (NAM),Sales Program Manager (SPM),Receivable Account Manager (RAM),Program Manager Director (PMD)');//modified for SDT-40683
            AccountTeamMember accTeammberCSS = new AccountTeamMember(AccountId =acclist.get(0).id,UserId=userCss.Id,Team_Roles_Multi__c='Corporate Service Specialist (CSS),Program Manager Specialist (PS),Billing Manager (BM),Manager Strategic Accounts (MSA),Sales Director (SD)');//modified for SDT-40683
            String TeamRole = 'Program Manager Specialist (PS),Corporate Service Specialist (CSS),Sales Program Manager (SPM),National Account Manager (NAM),Billing Manager (BM),Receivable Account Manager (RAM),Manager Strategic Accounts (MSA),Program Manager Director (PMD)';
            AccountTeamMember accTeammberMulti = new AccountTeamMember(AccountId =acclist.get(0).id,UserId=userMulti.Id,Team_Roles_Multi__c=TeamRole );
            AccountTeamMember accTeammberSD = new AccountTeamMember(AccountId =acclist.get(0).id,UserId=userSD.Id,Team_Roles_Multi__c='Sales Director (SD)' );
            AccountTeamMember accTeammberSD2 = new AccountTeamMember(AccountId =acclist.get(0).id,UserId=userSD2.Id,Team_Roles_Multi__c='Sales Director (SD)' );
            accTeamMemberList.add(accTeammberPM);
            accTeamMemberList.add(accTeammberCSS);
            //accTeamMemberList.add(accTeammberMulti);
           // accTeamMemberList.add(accTeammberSD);
           // accTeamMemberList.add(accTeammberSD2);
            Database.insert(accTeamMemberList);
            List<Case> caselist = TestDataFactory.createCase('FRIST', acclist.get(0), conlist.get(0), usr, locationlist.get(0), assetlist.get(0));
            Database.insert(caselist); 
        }
    }
    /**
* @author WM
* @date 1/28/2022
* @description : testMethod passing account ID (for Account Object)
**/
    @isTest static void testForAccountRecord(){
        user currentuser = [select id, Bypass_Validation__c,IsActive from user Where IsActive = true limit 1]; //SDT-33363
        Account acc = [select Id,Name, Account_Team_Email__c from Account where Name =:Constant_Util.LOCATION LIMIT 1];//modified for SDT-40683
        Case caseRec = [select Id from case LIMIT 1];
        system.runAs(currentuser){
            Test.startTest();
            AccountTeamMemberUIController.ResultWrapper accTeamWrapper = AccountTeamMemberUIController.getAccountTeamDetails(acc.Id);
            AccountTeamMemberUIController.ResultWrapper accTeamWrapperCase = AccountTeamMemberUIController.getAccountTeamDetails(caseRec.Id);
            
            Test.stopTest();
            system.assertEquals(accTeamWrapper.accTeamWrapperList[0].teamRole,'National Accounts Program Manager (PM)');
            //integer index = accTeamWrapper.size();
           // system.assertEquals(accTeamWrapper[index-1].teamRole,'Program Manager Director (PMD)');
            system.assertEquals(accTeamWrapperCase.accTeamWrapperList[0].teamRole,'National Accounts Program Manager (PM)');
            //added for SDT-40683
             system.assert(accTeamWrapperCase.accountTeamEmails.size() == 2);
           //integer indexCseList = accTeamWrapperCase.size();
           // system.assertEquals(accTeamWrapper[indexCseList-1].teamRole,'Sales Director (SD)');
        }
    }
    /**
* @author WM
* @date 1/28/2022
* @description : testMethod passing Case ID (for case Object)
**/
    /*  @isTest static void testForCaseRecord(){
user currentuser = [select id, Bypass_Validation__c from user limit 1];
Case caseRec = [select Id from case LIMIT 1];
system.runAs(currentuser){
Test.startTest();
List<AccountTeamMemberUIController.AccountTeamWrapper> accTeamWrapper = AccountTeamMemberUIController.getAccountTeamDetails(caseRec.Id);
Test.stopTest();
system.assertEquals(accTeamWrapper[0].teamRole,'National Accounts Program Manager (PM)');
integer index = accTeamWrapper.size();
system.assertEquals(accTeamWrapper[index-1].teamRole,'Sales Director (SD)');
}
} */
}