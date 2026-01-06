/*************************************************************
@Name: AccountContactRelationTrigger
@Author: Yogesh Sharma
@CreateDate:
@ Change History: 06.30.2021 / Adil / SDT-19138 - Trigger Framework Optmizaition 
@Description: Trigger to Perform operations on AccountContactRelation
**************************************************************/

trigger AccountContactRelationTrigger on AccountContactRelation (after insert, after delete, before update, before insert, after update) {
    new AccountContactRelationTriggerHandler().run();
}