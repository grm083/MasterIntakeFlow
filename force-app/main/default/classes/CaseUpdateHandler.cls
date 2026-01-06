/*************************************************************
@Name: CaseUpdateHandler
@Author: TCS (Jatan sharma)
@CreateDate: 15/08/24
@Description: Update Case status to New for  IVR New service Process.
@UsedBy: SDT-40344 ,SDT-31997
**************************************************************/
public class CaseUpdateHandler implements IHandler{
    
    public static Map<String,sobject> execute(Map<String,sobject> caseDataMap) {
    // Code for getting data from PE
        Map<String,sobject>  returnMap = new Map<String,sobject>();
        Map<String,case>  caseMap = new Map<String,case>();
        List<case> caseList = new List<case>();
        try{
        for(Id key : caseDataMap.Keyset()){
            sobject obj = caseDataMap.get(key);
            
            if (obj.getSObjectType() == Case.sObjectType) { 
                caseMap.put(key,(Case) obj);
                caseList.add((Case) obj);
            } 
        }
        List<Case> caseToUpdateList = new List<Case>();
        for(case c : caseMap.values() ){
            c.status = 'New';
            caseToUpdateList.add(c);
        }
        if(caseToUpdateList.size()>0){
            update caseToUpdateList;
        }
        for(case returnCase : caseToUpdateList)
        {
            returnMap.put(String.valueof(returnCase.Id),returnCase);
        }
    }
    catch(exception ex){
        IVRUtility.taskandGenesysRouting(caseList,'Unable to update case',ex.getMessage());
        IVRUtility.createIVRExceptionLogObj('Execute',ex.getMessage(),'CaseUpdateHandler');
        return null;
    }
        return returnMap;  
    }
    
}