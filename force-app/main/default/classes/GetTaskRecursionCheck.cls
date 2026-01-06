/**
 * @description       : Class is used to Check Task Recursion in migrated Flows.
 * @author            : TCS
 * @User Story        : SDT-33639 and SDT-33638
 **/
public class GetTaskRecursionCheck {
    @InvocableMethod(label='Task Recursion Check Get' description='Get Check Recursion')
    public static List<Boolean> getTaskDelayPauseFlow(list<Id> newTaskList) { 
        

        List<Boolean> result = new  List<Boolean>();
        for(Id item: newTaskList){
            if(PutTaskRecursionCheck.Flow_Ran_By_Delay_Logic != null && PutTaskRecursionCheck.Flow_Ran_By_Delay_Logic.containsKey(item)) {
                result.add(PutTaskRecursionCheck.Flow_Ran_By_Delay_Logic.get(item));
                //integer i = 1/0;
            } else {
                result.add(false);
            }
            
        }
        //System.debug('PutTaskRecursionCheck.Flow_Ran_By_Delay_Logic>>>>'+PutTaskRecursionCheck.Flow_Ran_By_Delay_Logic);        
        //System.debug('result>>>>'+result);
        return result; 
    }
}