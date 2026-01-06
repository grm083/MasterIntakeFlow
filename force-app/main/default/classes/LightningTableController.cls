/*************************************************************
@Name: LightningTableController
@Author: Accenture

**************************************************************/
public without sharing class LightningTableController {
@AuraEnabled
    /*
	  @owner : Accenture
	* @param : String sObjectName, String fieldSetName
	*/
    public static String getFieldSet(String sObjectName, String fieldSetName) {
        String result = '';
        try{
            SObjectType objToken = Schema.getGlobalDescribe().get(sObjectName);
            Schema.DescribeSObjectResult d = objToken.getDescribe();
            Map<String, Schema.FieldSet> FsMap = d.fieldSets.getMap();
            system.debug('>>>>>>> FsMap >>> ' + FsMap);
            if(FsMap.containsKey(fieldSetName))
            {
              for(Schema.FieldSetMember f : FsMap.get(fieldSetName).getFields()) {
                    if(result != Constant_Util.EMPTY_STRING ){
                        result += Constant_Util.COMMA ;
                    }
                    String jsonPart = Constant_Util.OPEN_CURLY_BRACE ;
                    jsonPart += Constant_Util.STR_LABEL + f.getLabel() + Constant_Util.DOUBLE_QUOTES_AND_COMMA  ;
                    jsonPart += Constant_Util.REQUIRED  + (f.getDBRequired() || f.getRequired()) + Constant_Util.DOUBLE_QUOTES_AND_COMMA;
                    jsonPart += Constant_Util.TYPE  + (f.getType()) + Constant_Util.DOUBLE_QUOTES_AND_COMMA;
                    if(Constant_Util.REFERENCE.equals(string.valueof(f.getType()) ) ){
                        jsonPart += Constant_Util.REFERENCE_OBJECT  + objToken.getDescribe().fields.getMap().get(f.getFieldPath()).getDescribe().getReferenceTo()[0].getDescribe().getName() 
                            + Constant_Util.DOUBLE_QUOTES_AND_COMMA;
                    }
                    jsonPart += Constant_Util.STR_NAME  + f.getFieldPath() + Constant_Util.DOUBLE_QUOTES;
                    jsonPart += Constant_Util.CLOSE_CURLY_BRACE ;
                    result += jsonPart;
                }
            }
        }
        catch(Exception e){
            result += e.getLineNumber() + Constant_Util.COLON + e.getMessage();
        }
        system.debug('result'+result);
        return Constant_Util.OPEN_SQUARE_BRACE +result+ Constant_Util.CLOSE_SQUARE_BRACE;
    }
    
    @AuraEnabled
    public static String getRecords(String sObjectName, String parentFieldName, String parentRecordId, String fieldNameJson){
        
        List<sObject> lstResult = new List<sObject>();
        String result = '[]';
        try{
            system.debug('fieldNameJson'+fieldNameJson);
            List<String> fieldNames = (List<String>) JSON.deserialize(fieldNameJson, List<String>.class);
            system.debug('fieldNames'+fieldNames);
            Set<String> setFieldNames = new Set<String>();
            String query = Constant_Util.STR_SELECT  + String.join(fieldNames, Constant_Util.COMMA) + Constant_Util.STR_FROM  + sObjectName;
            if(parentFieldName != NULL && parentFieldName != '' && parentRecordId != NULL){
                query += Constant_Util.STR_WHERE  + parentFieldName + Constant_Util.EQUALS_BACKSLASH  +  parentRecordId + Constant_Util.BACKSLASH_QUOTE ;
            }
            system.debug('query'+query);
            for(sObject s : Database.query(query)){
                lstResult.add(s);
            }
            if(lstResult.size() > 0) {
                result = JSON.serialize(lstResult);
            }
        }
        catch(Exception e){
            result += e.getLineNumber() + Constant_Util.COLON + e.getMessage();
        }
        return result;
    }
}