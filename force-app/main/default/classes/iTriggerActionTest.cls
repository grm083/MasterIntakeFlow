@isTest
public class iTriggerActionTest {

     public testmethod static void iTriggerActionTestMethod(){
     
     TriggerParameters tps = new TriggerParameters (null, null,null,null,true, true, false,true, true,false,true,'typeName');
                
     iTriggerAction tab = new TriggerActionBase();
     tab.beforeInsert(tps);
     tab.beforeUpdate(tps);
     tab.beforeDelete(tps);
     tab.afterInsert(tps);
     tab.afterUpdate(tps);
     tab.afterDelete(tps);
     tab.afterUnDelete(tps);
}
}