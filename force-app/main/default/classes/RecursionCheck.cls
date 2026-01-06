/**
* @author TCS
* @date 5/28/2024
* @description : Apex class RecursionCheck
* @story : SDT-33638 & SDT-33639
**/
public class RecursionCheck {
    public static List<sObject> checkRecusrion(List<sObject> sObjList){
        List<sObject> triggerNewsObjectList = new List<sObject>(); //Added for SDT-33638
        if(sObjList != null && !sObjList.isEmpty() && sObjList.size()>0) { //Added for SDT-40075
        triggerNewsObjectList.addAll(sObjList); //Added for SDT-33638
        //Added for SDT-33638 Start
        if(Test.isRunningTest()){
            TestDataFactory.createProcessBuilderTOFlow();                       
        }
        Code_Switch__c codeSwitchSetting = Code_Switch__c.getValues('Process_Builder_to_Flow');
        If(!codeSwitchSetting.Switch_Off__c){
            for(sObject item: sObjList) {
                if(PutTaskRecursionCheck.Flow_Ran_By_Delay_Logic != null && PutTaskRecursionCheck.Flow_Ran_By_Delay_Logic.containsKey(item.Id)) {
                    triggerNewsObjectList.remove(triggerNewsObjectList.indexOf(item));
                    } 
                } 
            }
        }
        return triggerNewsObjectList;
    }
}