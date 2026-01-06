/*************************************************************
@Name: AccountTeamMemberUIController
@Author: WM
@CreateDate: 1/17/2022
@Description: Controller class is Used to retrun List of wrapper Account Team details
@UsedBy: Aura Compoent AccountTeamsTable
@UserStory - STD-17780
**************************************************************/

public with sharing class  AccountTeamMemberUIController {
    /*************************************************************
@Name: AccountTeamWrapper
@Author: WM
@CreateDate: 1/17/2022
@Description: wrapper Class - Account Team details
@UsedBy: 
**************************************************************/
    public class AccountTeamWrapper {
        @AuraEnabled
        public string recordId {get;set;}
        @AuraEnabled
        public string teamRole {get;set;}
        @AuraEnabled
        public string userName {get;set;}
        @AuraEnabled
        public string userId {get;set;}
        @AuraEnabled
        public string userEmail {get;set;}
        
        public AccountTeamWrapper(string recordId,string teamRole, string userName,string userId,string userEmail){
            this.recordId = recordId;
            this.teamRole = teamRole;
            this.userName = userName;
            this.userId = userId;
            this.userEmail = userEmail;
        }
        
    }
    //added below as part of SDT-40683
    public class ResultWrapper {
        @AuraEnabled
        public List<string> accountTeamEmails {get;set;}
        @AuraEnabled
        public List<AccountTeamWrapper> accTeamWrapperList {get;set;}
        
        public ResultWrapper(List<AccountTeamWrapper> accTeamWrapperList, List<string> accountTeamEmails){
            this.accTeamWrapperList = accTeamWrapperList;
            this.accountTeamEmails = accountTeamEmails;
        }
        
    }
    
    
    /*
* This method is used to return Account Team Wrapper to the customTable Aura component AccountTeamsTable
* @owner : WM 
* @param : Id (Record ID from Record Page)
*/
    @AuraEnabled
    public static ResultWrapper getAccountTeamDetails (Id ObjrecordId){
        List<AccountTeamWrapper> finalWrapperList = new List<AccountTeamWrapper>();
        //added as part of SDT-40683
        ResultWrapper resultWrap;
        
        try{
            string accountId;
            String ObjName = String.valueOf(ObjrecordId.getsobjecttype());
            system.debug(ObjName);
            If(ObjName.equalsIgnoreCase(Constant_Util.ACCOUNT)){
                for(Account acc :[select Id,ParentId from Account where Id=:ObjrecordId]){
                    accountId =   acc.ParentId;
					if(String.isEmpty(accountId)){
                        accountId =   acc.Id;
                    }
                }
            }
            If(ObjName.equalsIgnoreCase(Constant_Util.KEYWORD_CASE)){
                for(case cse : [select Id,AccountId,Location__r.ParentId from case where Id=:ObjrecordId] ){
                    accountId = cse.Location__r.ParentId != Null?cse.Location__r.ParentId:Constant_Util.EMPTY_STRING;
                }
            }
            Map<string,List<AccountTeamWrapper>> teamRoleWrrapperObjMap = new Map<String,List<AccountTeamWrapper>>();
            for(AccountTeamMember accTeamMember :[select Id,Account.name,Team_Roles_Multi__c,User.Email,User.Id,
                                                  user.name,TeamMemberRole from AccountTeamMember 
                                                  where AccountId  =:accountId]){
                                                      system.debug('accTeamMember--->' + accTeamMember);
                                                      if(accTeamMember.Team_Roles_Multi__c != Null){
                                                          if(accTeamMember.Team_Roles_Multi__c.contains(Constant_Util.COMMA)){
                                                              List<String> teamRoleList = accTeamMember.Team_Roles_Multi__c.split(Constant_Util.COMMA);
                                                              for(string teamrRoleStr : teamRoleList ){
                                                                  if(teamRoleWrrapperObjMap.containsKey(teamrRoleStr)){
                                                                      List<AccountTeamWrapper> exAccTeamWrappList = teamRoleWrrapperObjMap.get(teamrRoleStr);
                                                                      AccountTeamWrapper accTeamWrapObj = new AccountTeamWrapper(accTeamMember.Id ,teamrRoleStr,accTeamMember.user.name,accTeamMember.user.Id,accTeamMember.user.Email);
                                                                      exAccTeamWrappList.add(accTeamWrapObj);
                                                                      teamRoleWrrapperObjMap.put(teamrRoleStr,exAccTeamWrappList);
                                                                  }else{
                                                                      List<AccountTeamWrapper> teamWrappList = new List<AccountTeamWrapper>();
                                                                      AccountTeamWrapper accTeamWrapObj = new AccountTeamWrapper(accTeamMember.Id ,teamrRoleStr,accTeamMember.user.name,accTeamMember.user.Id,accTeamMember.user.Email);
                                                                      teamWrappList.add(accTeamWrapObj);
                                                                      teamRoleWrrapperObjMap.put(teamrRoleStr,teamWrappList);
                                                                  }
                                                              }
                                                          }else{
                                                              if(teamRoleWrrapperObjMap.containsKey(accTeamMember.Team_Roles_Multi__c)){
                                                                  List<AccountTeamWrapper> exAccTeamWrappList = teamRoleWrrapperObjMap.get(accTeamMember.Team_Roles_Multi__c);
                                                                  AccountTeamWrapper accTeamWrapObj = new AccountTeamWrapper(accTeamMember.Id,accTeamMember.Team_Roles_Multi__c,accTeamMember.user.name,accTeamMember.user.Id,accTeamMember.user.Email);
                                                                  exAccTeamWrappList.add(accTeamWrapObj);
                                                                  teamRoleWrrapperObjMap.put(accTeamMember.Team_Roles_Multi__c,exAccTeamWrappList);
                                                              }else{
                                                                  List<AccountTeamWrapper> teamWrappList = new List<AccountTeamWrapper>();
                                                                  AccountTeamWrapper accTeamWrapObj = new AccountTeamWrapper(accTeamMember.Id , accTeamMember.Team_Roles_Multi__c,accTeamMember.user.name,accTeamMember.user.Id,accTeamMember.user.Email);
                                                                  teamWrappList.add(accTeamWrapObj);
                                                                  teamRoleWrrapperObjMap.put(accTeamMember.Team_Roles_Multi__c,teamWrappList); 
                                                              }
                                                          }
                                                      }     
                                                  }
            /*   system.debug('KEYSET' +  teamRoleWrrapperObjMap.keySet());
for(String key : teamRoleWrrapperObjMap.keySet()){
List<AccountTeamWrapper> wrappList = teamRoleWrrapperObjMap.get(key);
for(AccountTeamWrapper accwrap : wrappList){
system.debug(accwrap);
}
} 

/*  List<List<AccountTeamWrapper>> finalWrapperList = teamRoleWrrapperObjMap.values();
for(List<List<AccountTeamWrapper>> accwrapp : finalWrapperList){


} */
            
            if(!teamRoleWrrapperObjMap.isEmpty()){
                if(teamRoleWrrapperObjMap.containsKey(Constant_Util.ACCOUNT_TEAM_PM)){
                    //1 'National Accounts Program Manager (PM)'
                    List<AccountTeamWrapper> wrappList =  teamRoleWrrapperObjMap.get(Constant_Util.ACCOUNT_TEAM_PM);
                    for(AccountTeamWrapper accTeamWrapp : wrappList ){
                        finalWrapperList.add(accTeamWrapp);
                    }
                }
                if(teamRoleWrrapperObjMap.containsKey(Constant_Util.ACCOUNT_TEAM_CSS)){
                    //2 'Corporate Service Specialist (CSS)'
                    List<AccountTeamWrapper> wrappList =  teamRoleWrrapperObjMap.get(Constant_Util.ACCOUNT_TEAM_CSS);
                    for(AccountTeamWrapper accTeamWrapp : wrappList ){
                        finalWrapperList.add(accTeamWrapp);
                    }
                }
                if(teamRoleWrrapperObjMap.containsKey(Constant_Util.ACCOUNT_TEAM_PS)){
                    //3 'Program Manager Specialist (PS)'
                    List<AccountTeamWrapper> wrappList =  teamRoleWrrapperObjMap.get(Constant_Util.ACCOUNT_TEAM_PS);
                    for(AccountTeamWrapper accTeamWrapp : wrappList ){
                        finalWrapperList.add(accTeamWrapp);
                    }                
                }
                if(teamRoleWrrapperObjMap.containsKey(Constant_Util.ACCOUNT_TEAM_SPM)){ 
                    //4 'Sales Program Manager (SPM)'
                    List<AccountTeamWrapper> wrappList =  teamRoleWrrapperObjMap.get(Constant_Util.ACCOUNT_TEAM_SPM);
                    for(AccountTeamWrapper accTeamWrapp : wrappList ){
                        finalWrapperList.add(accTeamWrapp);
                    }
                }
                if(teamRoleWrrapperObjMap.containsKey(Constant_Util.ACCOUNT_TEAM_NAM)){ 
                    //5 'National Account Manager (NAM)'
                    List<AccountTeamWrapper> wrappList =  teamRoleWrrapperObjMap.get(Constant_Util.ACCOUNT_TEAM_NAM);
                    for(AccountTeamWrapper accTeamWrapp : wrappList ){
                        finalWrapperList.add(accTeamWrapp);
                    }
                }
                if(teamRoleWrrapperObjMap.containsKey(Constant_Util.ACCOUNT_TEAM_BM)){ 
                    //6 'Billing Manager (BM)'
                    List<AccountTeamWrapper> wrappList =  teamRoleWrrapperObjMap.get(Constant_Util.ACCOUNT_TEAM_BM);
                    for(AccountTeamWrapper accTeamWrapp : wrappList ){
                        finalWrapperList.add(accTeamWrapp);
                    }
                }
                if(teamRoleWrrapperObjMap.containsKey(Constant_Util.ACCOUNT_TEAM_RAM)){ 
                    //7 'Receivable Account Manager (RAM)'
                    List<AccountTeamWrapper> wrappList =  teamRoleWrrapperObjMap.get(Constant_Util.ACCOUNT_TEAM_RAM);
                    for(AccountTeamWrapper accTeamWrapp : wrappList ){
                        finalWrapperList.add(accTeamWrapp);
                    }
                }
                if(teamRoleWrrapperObjMap.containsKey(Constant_Util.ACCOUNT_TEAM_MSA)){ 
                    //8 'Manager Strategic Accounts (MSA)'
                    List<AccountTeamWrapper> wrappList =  teamRoleWrrapperObjMap.get(Constant_Util.ACCOUNT_TEAM_MSA);
                    for(AccountTeamWrapper accTeamWrapp : wrappList ){
                        finalWrapperList.add(accTeamWrapp);
                    }
                }
                if(teamRoleWrrapperObjMap.containsKey(Constant_Util.ACCOUNT_TEAM_PMD)){ 
                    //9 'Program Manager Director (PMD)'
                    
                    List<AccountTeamWrapper> wrappList =  teamRoleWrrapperObjMap.get(Constant_Util.ACCOUNT_TEAM_PMD);
                    for(AccountTeamWrapper accTeamWrapp : wrappList ){
                        finalWrapperList.add(accTeamWrapp);
                    }
                }
                if(teamRoleWrrapperObjMap.containsKey(Constant_Util.ACCOUNT_TEAM_SD)){ 
                    //10 'Sales Director (SD)'
                    List<AccountTeamWrapper> wrappList =  teamRoleWrrapperObjMap.get(Constant_Util.ACCOUNT_TEAM_SD);
                    for(AccountTeamWrapper accTeamWrapp : wrappList ){
                        finalWrapperList.add(accTeamWrapp);
                    }
                }
            }
            /*    system.debug('------------------------------------------------');
for(AccountTeamWrapper accwrapp  : finalWrapperList ){
system.debug(accwrapp);

}*/
            //added as part of SDT-40683
            List<String> accTeamEmails = null;
            if(accountId != null && accountId != ''){
                List<Account> clientAcc = [Select Id, Account_Team_Email__c from Account where Id =: accountId];
                if(clientAcc.size() > 0) {
                    if(clientAcc[0].Account_Team_Email__c != null && clientAcc[0].Account_Team_Email__c != ''){
                        accTeamEmails = clientAcc[0].Account_Team_Email__c.split(';');
                    }
                }
            }
            resultWrap = new ResultWrapper(finalWrapperList, accTeamEmails); 
                
                return resultWrap;
        }catch(Exception excp){
            //  UTIL_LoggingService.logHandledException(excp, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
            return resultWrap;
        }
    }
}