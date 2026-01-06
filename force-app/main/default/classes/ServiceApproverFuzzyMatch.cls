/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 07-13-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class ServiceApproverFuzzyMatch {
    
    @InvocableMethod(label='Service Approver Fuzzy Match' description='Check Service Approver Is fuzzy Match.')
    public static List<Boolean>  checkFuzzyMatch(List<MethodInputWrapper> inPutParams) {
        String conTitle = Null ;
        String saAccountTitle = Null ;
        Set<String> lstContactTitileSplit = new Set<String>();
        if(inPutParams[0].contactTitle != null && inPutParams[0].serviceApproverTitle != null ){
            conTitle = inPutParams[0].contactTitle;
            saAccountTitle = inPutParams[0].serviceApproverTitle;
            if(String.isNotBlank(conTitle)){     
                for(String c : conTitle.split(' ')){
                    lstContactTitileSplit.add(c.toLowerCase());
                }             
            }

            if(String.isNotBlank(saAccountTitle)){     
                for(String s : saAccountTitle.split(' ')){
                    if(!lstContactTitileSplit.contains(s.toLowerCase())) {
                        return new List<Boolean>{false};
                    }
                }             
            }    
        }

        return new List<Boolean>{true};
    }

    //input details that comes to apex from flow
    public class MethodInputWrapper{
        @InvocableVariable
        public String contactTitle;
        
        @InvocableVariable
        public String serviceApproverTitle;
    }
}