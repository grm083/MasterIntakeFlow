/**************************************************
* ClassName:GetSobjectRecordTypeId
* Author:Dinesh
* CreatedDate:14/4/2019
* **************************************************/
public without sharing class GetSobjectRecordTypeId {
    @InvocableMethod(label='Get Sobject RecordType Id' description='Returns the list of RecordTypeId')
    /*
@Owner : Accenture
@Param : List<String>
Method : getRecordTypeId
*/ 
    public static List<string> getRecordTypeId(List<String> inputParameter) {  
        List<String> recordTypeIdlst = new List<String>();
        try{
            List<string> inputlst = new List<string>();
            for(String input : inputParameter){
                inputlst = input.split(Constant_Util.SEMI_COLON);
                String sobjectType = inputlst[0];
                String recordTypeName = inputlst[1];
                Id recordTypeId = Schema.getGlobalDescribe().get(sobjectType).getDescribe().getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
                recordTypeIdlst.add(String.valueof(recordTypeId));
            }
        }		
        Catch(Exception e){
            //To handle Error in future Sprints
            system.debug('$$$$'+e.getStackTraceString());
            system.debug('DmlException caught: ' + e.getMessage());
        }
        return recordTypeIdlst;
        
    }
}