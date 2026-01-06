/**
 * @description       : Class is used to Check Task Recursion in migrated Flows.
 * @author            : TCS
 * @User Story        : SDT-33639 and SDT-33638
 **/
public class PutTaskRecursionCheck {
    //This Map may containe caseId as TaskId which are running with delay logic.
    public static Map<ID, Boolean> Flow_Ran_By_Delay_Logic = new Map<ID, Boolean>();
    @InvocableMethod(label='Task Recursion Check Put' description='Put Check Recursion')
    public static void setTaskDelayPauseFlow(list<Id> newTaskList) {
    
            for(Id item: newTaskList){
                Flow_Ran_By_Delay_Logic.put(item, true);
            }
        
    }
}