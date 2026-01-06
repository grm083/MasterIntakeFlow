@isTest (SeeAllData = FALSE)
public class AccountTeamMemberQueryAction_Test {

    @testSetup static void setup(){
        List<User> userList = new List<User>();
        Profile p = TestDataFactory.getProfile('System Administrator');
        User user1 = TestDataFactory.createUser(p);
        User user2 = TestDataFactory.createUser(p);
        user2.UserName = 'SalesDirectorUser@test.com';
        userList.add(user1);
        userList.add(user2);
        Database.insert(userList);
        
        system.runAs(user1){
            List<Account> acclist = TestDataFactory.createAccount(Constant_Util.KEYWORD_TEST, user1);
            Database.insert(acclist);
            List<AccountTeamMember> accountTeamMemberList = new List<AccountTeamMember>();
            AccountTeamMember accountTeamMember1 = new AccountTeamMember(AccountId =acclist.get(0).id,UserId=user1.Id,Team_Roles_Multi__c='National Accounts Program Manager (PM)' );
            AccountTeamMember accountTeamMember2 = new AccountTeamMember(AccountId =acclist.get(0).id,UserId=user2.Id,Team_Roles_Multi__c='Sales Director (SD)' );
            accountTeamMemberList.add(accountTeamMember1);
            accountTeamMemberList.add(accountTeamMember2);
            Database.insert(accountTeamMemberList);
        }
       }
    //Delete 1 Account Team Member
    @isTest
    static void testOneAcctTeamMbrDelete(){
        user currentuser = [select id, Bypass_Validation__c,IsActive from user Where IsActive = true limit 1]; //SDT-33363
        Account acc = [select Id, Name, Account_Team_Member__c from Account where Name =:Constant_Util.KEYWORD_TEST LIMIT 1];
        system.debug('Test Account Id :: '+ acc.Id);
        List<Id> accTeamMbrList = new List<Id>();
        AccountTeamMember teamMember = [SELECT Id, User.Email FROM AccountTeamMember WHERE AccountId =:acc.Id limit 1];
        
        if(!String.isEmpty(teamMember.Id)){
           accTeamMbrList.add(teamMember.Id);
           String emailBeforeDelete = teamMember.User.Email;
           system.runAs(currentuser){
               
            Test.startTest();
            system.debug('Account_Team_Member__c Before delete :: '+ acc.Account_Team_Member__c);
               
            AccountTeamMemberQueryAction.getAccountTeamMembersEmails(accTeamMbrList);
               
            Account accAfterDelete = [select Id, Name, Account_Team_Member__c from Account where Name =:Constant_Util.KEYWORD_TEST LIMIT 1];
            String emailAfterDelete = accAfterDelete.Account_Team_Member__c;
            system.debug('Account_Team_Member__c After delete :: '+ emailAfterDelete);
            system.Assert(!emailAfterDelete.contains(emailBeforeDelete));
            Test.stopTest();
        	} 
        }
        
    }
    
    //Delete multiple AccountTeamMembers
    @isTest
    static void testMultipleAcctTeamMbrDelete(){
        user currentuser = [select id, Bypass_Validation__c,IsActive from user Where IsActive = true limit 1]; //SDT-33363
        Account acc = [select Id, Name, Account_Team_Member__c from Account where Name =:Constant_Util.KEYWORD_TEST LIMIT 1];
        List<Id> accTeamMbrList = new List<Id>();
        List<AccountTeamMember> teamMembers = [SELECT Id FROM AccountTeamMember WHERE AccountId =:acc.Id];
        if(teamMembers.size()>0){
            system.debug('List Size of teamMembers :: '+ teamMembers);
            for(AccountTeamMember mbrObj : teamMembers){
                accTeamMbrList.add(mbrObj.Id); // List Of Ids
            } 
        }
        if(accTeamMbrList.size()>0){
            system.runAs(currentuser){
            Test.startTest();
            system.debug('Multi Delete Account_Team_Member__c Before delete :: '+ acc.Account_Team_Member__c);
            AccountTeamMemberQueryAction.getAccountTeamMembersEmails(accTeamMbrList);
            
            Account accAfterDelete = [select Id, Name, Account_Team_Member__c from Account where Name =:Constant_Util.KEYWORD_TEST LIMIT 1];
        	String emailAfterDelete = accAfterDelete.Account_Team_Member__c;
            system.debug('Multi Delete Account_Team_Member__c After delete :: '+ emailAfterDelete);
            system.Assert(String.isBlank(emailAfterDelete));
            Test.stopTest();
            } 
        }
    }
    
    //Negative scenario when 1 email which needs to removed does not exist in 'Account_Team_Member__c'
    @isTest
    static void testNonExistingAcctTeamMbrDelete(){
        List<Id> accTeamMbrList = new List<Id>();
        user currentuser = [select id, Bypass_Validation__c,IsActive from user Where IsActive = true limit 1]; //SDT-33363
        Account acc = [select Id, Name, Account_Team_Member__c from Account where Name =:Constant_Util.KEYWORD_TEST LIMIT 1];
        
        system.debug('Negative 1 delete - Test Account Id :: '+ acc.Id);
        AccountTeamMember teamMember = [SELECT Id, User.Email FROM AccountTeamMember WHERE AccountId =:acc.Id limit 1];
        
        if(!String.isEmpty(teamMember.Id)){
           accTeamMbrList.add(teamMember.Id);
           String emailBeforeDelete = teamMember.User.Email;
           system.runAs(currentuser){
               
            Test.startTest();
            //Set Account_team_member__c as blank
            acc.Account_Team_Member__c = '';
            update acc;   
            system.debug('Negative 1 delete - Email to be deleted :: '+ emailBeforeDelete);
               try{ 
            AccountTeamMemberQueryAction.getAccountTeamMembersEmails(accTeamMbrList);
               }catch(NullPointerException ne){
                    system.debug('NullPointerException :: '+ne.getMessage());
                   system.assertEquals(true, ne.getMessage().contains('There is no Team member available based on your request of deletion'));
               }catch(ListException le){
                   system.debug('ListException :: '+le.getMessage());
                   system.assertEquals(true, le.getMessage().contains('There is no Team member available based on your request of deletion'));

               }catch(Exception ex){
                System.debug('There is no Team member available based on your request of deletion' + ex.getMessage());
            	}  
            Account accAfterDelete = [select Id, Name, Account_Team_Member__c from Account where Name =:Constant_Util.KEYWORD_TEST LIMIT 1];
            String emailAfterDelete = accAfterDelete.Account_Team_Member__c;
            system.debug('Negative 1 delete - Account_Team_Member__c After delete :: '+ emailAfterDelete);
            Test.stopTest();
        	} 
        }
    }
    
    //Negative scenario when All email which needs to removed does not exist in 'Account_Team_Member__c'
    @isTest
    static void testMultiNonExistingAcctTeamMbrDelete(){
        user currentuser = [select id, Bypass_Validation__c,IsActive from user Where IsActive = true limit 1];  //SDT-33363
        Account acc = [select Id, Name, Account_Team_Member__c from Account where Name =:Constant_Util.KEYWORD_TEST LIMIT 1];
        List<Id> accTeamMbrList = new List<Id>();
        List<AccountTeamMember> teamMembers = [SELECT Id FROM AccountTeamMember WHERE AccountId =:acc.Id];
        if(teamMembers.size()>0){
            system.debug('List Size of teamMembers :: '+ teamMembers);
            for(AccountTeamMember mbrObj : teamMembers){
                accTeamMbrList.add(mbrObj.Id); // List Of Ids
            } 
        }
        if(accTeamMbrList.size()>0){
            system.runAs(currentuser){
            Test.startTest();
            acc.Account_Team_Member__c = '';
            update acc;
                try{
                	AccountTeamMemberQueryAction.getAccountTeamMembersEmails(accTeamMbrList);
                }catch(NullPointerException ne){
                    system.debug('NullPointerException :: '+ne.getMessage());
                   system.assertEquals(true, ne.getMessage().contains('There is no Team member available based on your request of deletion'));
               }catch(ListException le){
                   system.debug('ListException :: '+le.getMessage());
                   system.assertEquals(true, le.getMessage().contains('There is no Team member available based on your request of deletion'));

               }
                catch(Exception ex){
                System.debug('There is no Team member available based on your request of deletion' + ex.getMessage());
            }
            Account accAfterDelete = [select Id, Name, Account_Team_Member__c from Account where Name =:Constant_Util.KEYWORD_TEST LIMIT 1];
        	String emailAfterDelete = accAfterDelete.Account_Team_Member__c;
            system.debug('Multi Delete Account_Team_Member__c After delete :: '+ emailAfterDelete);
            system.Assert(String.isBlank(emailAfterDelete));
            Test.stopTest();
            } 
        }
    }

}