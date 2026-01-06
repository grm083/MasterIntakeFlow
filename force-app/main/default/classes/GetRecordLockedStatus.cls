/**************************************************
* ClassName:GetRecordLockedStatus
* Purpose  : Check whether record is locked or not.
* Createdby: TCS
* **************************************************/
public class GetRecordLockedStatus {
    @InvocableMethod(label='Get record lock status' description='Returns boolean whether record is locked')
    public static List<Boolean> getRecordLockStatusList(List<Id>recordIds) {   
        List<Boolean> recordLockStatusList = new List<Boolean>();
        Map<Id,Boolean> recordLockStatusMap = new Map<Id,Boolean>();
        If(recordIds !=null && !recordIds.isEmpty()){
            recordLockStatusMap = Approval.isLocked(recordIds);
            for(Id recordId:recordLockStatusMap.keySet()){
                recordLockStatusList.add(recordLockStatusMap.get(recordId));
            }
        }
        
        
        return recordLockStatusList; 
        
        
    }
    
}