@isTest
private class TriggerActionBaseTest{

    /*************************************************************************************************************************************************************
    Test Method to test funtionality of Controller class TriggerActionBase 
    *************************************************************************************************************************************************************/
    public testmethod static void TriggerActionBaseTestMethod(){
    //TriggerActionBase tab = new TriggerActionBase();
    
     TriggerParameters tp = new TriggerParameters (null, null,null,null,true, true, false,true, true,false,true,'typeName');
                
     TriggerActionBase tab = new TriggerActionBase();
     tab.beforeInsert(tp);
     tab.beforeUpdate(tp);
     tab.beforeDelete(tp);
     tab.afterInsert(tp);
     tab.afterUpdate(tp);
     tab.afterDelete(tp);
     tab.afterUnDelete(tp);
                
    }
    
    
 }