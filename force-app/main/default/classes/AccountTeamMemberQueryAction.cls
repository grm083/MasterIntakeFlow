public class AccountTeamMemberQueryAction {

  @InvocableMethod(label='Get Account Team Members Emails' description='Returns the list of account Team Members Emails To be Deleted.' category='AccountTeamMember')
  public static List<Id> getAccountTeamMembersEmails(List<ID> ids) {
    List<String> emails = new List<String>();
    //List<String> accountTeamValuesList = new List<String>();
    Set<String> accountTeamValuesList = new Set<String>();
    String AccountTeamValuse =null;
    
    Map<id,String> accountTeamEmail = new Map<id,String>();
    List<Account> accountUpdateList = new List<Account>();
    
    System.debug('ids>>'+ids);
    
    List<AccountTeamMember> teamMembers = [SELECT id,AccountId,Account.Account_Team_Member__c,UserId,User.Email FROM AccountTeamMember WHERE Id in :ids];
    
        List<String> listofEmail = new List<String>();
        
    for (AccountTeamMember acctMemberObj : teamMembers) {
        if(accountTeamEmail.containsKey(acctMemberObj.AccountId))
        {
            String email = accountTeamEmail.get(acctMemberObj.AccountId);
            
            try {
                listofEmail = email.split(',');
            	listofEmail.remove(listofEmail.indexof(acctMemberObj.User.Email));
                accountTeamEmail.put(acctMemberObj.AccountId,String.join(listofEmail,',')); 
            }
            catch(NullPointerException nullPointerException){
                System.debug('There is no Team member available based on your request of deletion :: ' + acctMemberObj.User.Email);
            }
            catch(ListException listException){
                System.debug('There is no Team member available based on your request of deletion :: ' + acctMemberObj.User.Email);
            }
            catch(Exception ex){
                System.debug('There is no Team member available based on your request of deletion' + ex.getMessage());
            }
            
            
    
                        
        }
        else
        {
            String email = acctMemberObj.Account.Account_Team_Member__c;
            
            try {
                listofEmail = email.split(',');
            	listofEmail.remove(listofEmail.indexof(acctMemberObj.User.Email));
                accountTeamEmail.put(acctMemberObj.AccountId,String.join(listofEmail,','));
            }
            catch(NullPointerException nullPointerException){
                System.debug('There is no Team member available based on your request of deletion');
            }
            catch(ListException listException){
                System.debug('There is no Team member available based on your request of deletion');
            }
            catch(Exception ex){
                System.debug('There is no Team member available based on your request of deletion' + ex.getMessage());
            }
             
        }
    }

    for (ID accountId : accountTeamEmail.KeySet()) {
            Account acocuntObj = new Account();
            acocuntObj.id  = accountId;
            acocuntObj.Account_Team_Member__c = accountTeamEmail.get(accountId);
            accountUpdateList.add(acocuntObj);
            
    }
    
       //accountOBj.id  = AccountId;
        
        update accountUpdateList;
    
    return ids;
}
}