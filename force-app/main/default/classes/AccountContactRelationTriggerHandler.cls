/**
* @author Adil Aleem
* @date 07/02/2021
*
* @description Trigger Framework Optmizaition, Created beforeInsert,beforeUpdate, afterInsert, afterDelete methods
*/
public without sharing class AccountContactRelationTriggerHandler extends TriggerHandler{
 
       private Map<Id, AccountContactRelation> newAccConMap;
       private Map<Id, AccountContactRelation> oldAccConMap;
       private List<AccountContactRelation> newAccConList;
       private List<AccountContactRelation> oldAccConList;
 
       public AccountContactRelationTriggerHandler() {
          this.newAccConMap = (Map<Id, AccountContactRelation>) Trigger.newMap;
          this.oldAccConMap = (Map<Id, AccountContactRelation>) Trigger.oldMap;
          this.newAccConList = (List<AccountContactRelation>) Trigger.new;
          this.oldAccConList = (List<AccountContactRelation>) Trigger.old;
          this.setMaxLoopCount(14);
       }
       
     /*
      * @description  It is invoked on before insert of AccountContactRelation
      * @param null
      * @return null
      */
      public override void beforeInsert(){
       if(!RecurrsiveTriggerHandler.bypassValidation) { 
         AccountContactRelationTriggerHelper.validateBeforeInsert(newAccConList);
       }
     }
     
     
      /*
      * @description  It is invoked on before update of AccountContactRelation
      * @param null
      * @return null
      */
      public override void beforeUpdate(){
        if(!RecurrsiveTriggerHandler.bypassValidation) {
         AccountContactRelationTriggerHelper.validateBeforeUpdate(newAccConList, oldAccConMap);
        }   
     }

   /*
    * @description  It is invoked on after insert of AccountContactRelation
    * @param null
    * @return null
    */
    public override void afterInsert() {
      if(!RecurrsiveTriggerHandler.bypassValidation) { 
         AccountContactRelationTriggerHelper.getNumberOfLocationOnContact(newAccConList, newAccConMap ,Null,Null,true,false);
         AccountContactRelationTriggerHelper.updateDispatchEmail(newAccConList , oldAccConList , 'isInsert');
      }   
   }
  
   /*
    * @description  It is invoked on after delete of AccountContactRelation
    * @param null
    * @return null
    */
    public override void afterDelete() {
      if(!RecurrsiveTriggerHandler.bypassValidation) {
         AccountContactRelationTriggerHelper.getNumberOfLocationOnContact(Null,Null, oldAccConList, oldAccConMap,false,true);
         AccountContactRelationTriggerHelper.updateDispatchEmail(newAccConList , oldAccConList , 'isDelete');
      }   
   }

   /*
    * @description  It is invoked on after update of AccountContactRelation
    * @param null
    * @return null
    */
    public override void afterUpdate() {
      if(!RecurrsiveTriggerHandler.bypassValidation) {
         AccountContactRelationTriggerHelper.updateDispatchEmail(newAccConList , oldAccConList , 'isUpdate');
      }   
   }
   
       
 }