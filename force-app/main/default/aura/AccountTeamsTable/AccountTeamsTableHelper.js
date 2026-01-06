({
    getAccountTeamsData : function(cmp,event,helper) {
        var accountTeamData ;
        var action = cmp.get('c.getAccountTeamDetails');
        action.setParams({
            ObjrecordId : cmp.get("v.recordId")
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state =="SUCCESS"){
             //   $A.get('e.force:refreshView').fire();
                accountTeamData = response.getReturnValue();
                console.log(JSON.stringify(accountTeamData));
                //modified as part of SDT-40683
                if(accountTeamData){
                    //if account team email data exists
                    if(accountTeamData.accountTeamEmails && accountTeamData.accountTeamEmails.length != 0){
                        cmp.set("v.accTeamEmails",accountTeamData.accountTeamEmails);
                        cmp.set("v.showAccTeamEmail",true);
                        var recCount = accountTeamData.accountTeamEmails.length;
                        cmp.set("v.accEmailTitle" , 'Account Team Email For Parent Account' + " " +'('+recCount+')');

                    }
                    else {
                        cmp.set("v.showAccTeamEmail",false);
                    }
                    //if account team member data exists
                    if(accountTeamData.accTeamWrapperList && accountTeamData.accTeamWrapperList.length > 0){
                        cmp.set("v.accountTeamList",accountTeamData.accTeamWrapperList);
                    cmp.set("v.showTable",true);
                        var recordCount = accountTeamData.accTeamWrapperList.length;
                        cmp.set("v.tableTitile" , 'Account Team For Parent Account' + " " +'('+recordCount+')');
                    var title = 'Account Team For Parent Account('+recordCount+')';
                }
                    else {
                        cmp.set("v.showTable",false);
                    }
                }
                else {
                    cmp.set("v.showAccTeamEmail",false);
                    cmp.set("v.showTable",false);
                }
                
            }else{
                console.log('ERROR');
            }
        })
        $A.enqueueAction(action);
    }
})