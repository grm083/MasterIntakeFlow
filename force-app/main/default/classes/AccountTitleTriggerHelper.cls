/*************************************************************
@Name: AccountTitleTriggerHelper
@Author: Anupreethy
@CreateDate: 10/04/2019
@Description: Handler Class to Perform operations on AccountTitle
@UsedBy: AccountTitleTriggerHandler
**************************************************************/
public class AccountTitleTriggerHelper {
    /*
* This method will check if the given Account title is a Service Approver
* @owner : Anupreethy
* @param : Account_Title__c List
*/
    public static void checkTitleInServiceApprover(Map<Id,Account_Title__c> newAccTitleMap , Map<Id,Account_Title__c> oldAccTitleMap, Boolean isDelete){
        Set<Id> ServiceApproversID = new set<ID>();
        Map<Id,Id> accTitleSAmap = new Map<Id,Id>();
        Account_Title__c oldAccTile;
        
        try{
            system.debug('newAccTitleMap' +newAccTitleMap);
            system.debug('oldAccTitleMap' +newAccTitleMap);
            system.debug('isDelete' +isDelete);

            for (Service_Approver__c sa : [SELECT Id,Title__c from Service_Approver__c
                                           WHERE Title__c IN: oldAccTitleMap.Keyset() ])
            {
                accTitleSAmap.put(sa.Title__c,sa.Id);
                //system.debug('accTitleSAmap ' +accTitleSAmap);
            }
            
            if(isDelete) {
                for(Account_Title__c thisTitle : oldAccTitleMap.values()){
                    if(!oldAccTitleMap.isEmpty() && oldAccTitleMap.containsKey(thisTitle.Id)){
                        //system.debug('oldAccTitleMap' +oldAccTitleMap);
                        thisTitle.addError(Label.AccTitleIsServiceApprover);
                    }
                }
                
            }
            else {
                for(Account_Title__c thisTitle : newAccTitleMap.values()){
                    oldAccTile = oldAccTitleMap.get(thisTitle.Id);
                    //System.debug('Inside Else');
                    if((!oldAccTitleMap.isEmpty() && oldAccTitleMap.containsKey(thisTitle.Id) 
                        && (!Constant_Util.ACTIVE.equals(thisTitle.Status__c)) ) ){
                            //system.debug('Inside 2nd IF');
                            if(!accTitleSAmap.isEmpty() && accTitleSAmap.containsKey(thisTitle.id)){
                                //system.debug('Inside IF accTitleSAmap'+accTitleSAmap);
                                thisTitle.addError(Label.AccTitleIsServiceApprover);
                            }     
                        }
                }   
            }
        }
        catch(Exception e){
            //To handle Error in future Sprints
            System.debug('Exception::::'+e.getStackTraceString());
        }
    }
    
}