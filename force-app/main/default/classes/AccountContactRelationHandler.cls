/*************************************************************
@Name: AccountContactRelationHandler
@Author: Yogesh Sharma
@CreateDate: 01/05/2020
@Description: Handler Class to Perform operations on AccountContactRelation
@UsedBy: AccountContactRelationTrigger
**************************************************************/
public without sharing class AccountContactRelationHandler {
    /*
    * It is invoked on after inserting the AccountContactRelation 
    * @owner : Yogesh Sharma
    * @param : AccountContactRelationList
    */
  /*  public static void onAfterInsert(List<AccountContactRelation > newACRList, Map<Id,AccountContactRelation> newACRMap){
       AccountContactRelationHelper.getNumberOfLocationOnContact(newACRList,newACRMap,Null,Null,true,false);
    }
    */
    
    /*
    * It is invoked on after deleting the AccountContactRelation 
    * @owner : Yogesh Sharma
    * @param : AccountContactRelationList
    */
  /*  public static void onAfterDelete(List<AccountContactRelation > oldACRList, Map<Id,AccountContactRelation> oldACRMap){
       AccountContactRelationHelper.getNumberOfLocationOnContact(Null,Null,oldACRList,oldACRMap,false,true);
   }
     */
    
    
    /*
    * It is invoked on before inserting the AccountContactRelation 
    * @owner : Devendra Patel
    * @param : AccountContactRelationList
    */
  /*  public static void onBeforeInsert(List<AccountContactRelation> NewACRList){
      AccountContactRelationHelper.validateBeforeInsert(NewACRList);
   }
     */
    
    /*
    * It is invoked on before updating the AccountContactRelation 
    * @owner : Devendra Patel
    * @param : AccountContactRelationList
    */
 /*   public static void onBeforeUpdate(List<AccountContactRelation > oldACRList, Map<Id,AccountContactRelation> oldACRMap){
       AccountContactRelationHelper.validateBeforeUpdate(oldACRList,oldACRMap);
   } */
}