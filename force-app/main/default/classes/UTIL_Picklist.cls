/*
  * @Name          UTIL_Picklist
  * @Author        WM - Ali
  * @Date          21/05/2021
  * @Description   UTIL class for the purpose of get list of value from dependent picklist.
 */
public class UTIL_Picklist {

    public with sharing class picklistWrapper {
        @AuraEnabled public Boolean isvalid {get;set;}          
        @AuraEnabled public String apivalue {get;set;}
    }   

    /*@methodName- validatePicklist
    *@description- Method to validate pick value with case value 
    *@param- String :ObjectApiName - Hold object name
    *@param- String :FieldApiName - Hold object field name
    *@param- String :fieldValue - Hold picklist value FROM case
    *@return- wrapper class
    */  
    @AuraEnabled(cacheable=true)
    public static picklistWrapper validatePicklist(String ObjectApiName, String FieldApiName, String fieldValue){
        picklistWrapper pckWrapper = new picklistWrapper();
        Boolean isValid = false;
        String apivalue = '';
        try{
            List<String> pckValue = getPickListValuesIntoList(ObjectApiName, FieldApiName);
            for(Integer i=0; i< pckValue.size(); i++){
                if(pckValue[i].split(',').get(0) == fieldValue){
                    apivalue = pckValue[i].split(',').get(1);
                    isValid = true;
                    break;
                }
            }
            if(String.isEmpty(apivalue)) {
                isValid = false;
            }
        
            pckWrapper.apivalue = apivalue;
            pckWrapper.isvalid = isValid;
        }catch(Exception ex){
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.Pricing_Request_APEX,LoggingLevel.ERROR);
        }
        return pckWrapper;
    }
    
    /*@methodName- getPickListValuesIntoList
    *@description- Method to query the object picklist value 
    *@param- String :ObjectApiName - Hold object name
    *@param- String :FieldApiName - Hold object field name
    *@return- String: picklist value
    */  
    public static List<String> getPickListValuesIntoList(String ObjectApiName, String FieldApiName){
        List<String> pickListValuesList = new List<String>();
        try{
            Schema.SObjectType s = Schema.getGlobalDescribe().get(ObjectApiName);
            Schema.DescribeSObjectResult r = s.getDescribe();
            Map<String,Schema.SObjectField> fields = r.fields.getMap();
            Schema.DescribeFieldResult fieldResult = fields.get(FieldApiName).getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry pickListVal : ple){
                pickListValuesList.add(pickListVal.getLabel()+','+ pickListVal.getValue());
            }
        }catch(Exception ex){
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.Pricing_Request_APEX,LoggingLevel.ERROR);
        }
        return pickListValuesList;
    }

    @AuraEnabled(cacheable=true)
    public static picklistWrapper validateDependentPicklist(String ObjectApiName, String FieldApiName, String ControllingfieldValue, String DependentfieldValue){
        picklistWrapper pckWrapper = new picklistWrapper();
        Boolean isValid = false;
        String apivalue = '';
        try {
            List<String> controllinglist = getDependentPicklistValues(ObjectApiName,FieldApiName,ControllingfieldValue);
        
            for(Integer i=0; i< controllinglist.size(); i++){
                if(controllinglist[i].split(',').get(0) == DependentfieldValue){
                    apivalue = controllinglist[i].split(',').get(1);
                    isValid = true;
                    break;
                }
            }
            if(String.isEmpty(apivalue)) {
                isValid = false;
            }
        
            pckWrapper.apivalue = apivalue;
            pckWrapper.isvalid = isValid;
        } catch (Exception ex) {
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.Pricing_Request_APEX,LoggingLevel.ERROR);
        }
        

        return pckWrapper;
    }

    public static List<String> getDependentPicklistValues(String ObjectApiName, String FieldApiName, String ControllingfieldValue) {
        system.debug('getDependentPicklistValues---> '+ ObjectApiName + ',' + FieldApiName + ',' +  ControllingfieldValue);
        Schema.SobjectField dependToken = Schema.getGlobalDescribe().get(ObjectApiName).getDescribe().fields.getMap().get(FieldApiName);
        Schema.DescribeFieldResult depend = dependToken.getDescribe();

        Schema.sObjectField controlToken = depend.getController();
        if (controlToken == null) {
            return new List<String>();
        }
    
        Schema.DescribeFieldResult control = controlToken.getDescribe();
        List<Schema.PicklistEntry> controlEntries;
        if(control.getType() != Schema.DisplayType.Boolean) {
            controlEntries = control.getPicklistValues();
        }
    
        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        Map<String,List<String>> dependentPicklistValues = new Map<String,List<String>>();
        List<String> controllinglist = new List<String>();
        for (Schema.PicklistEntry entry : depend.getPicklistValues()) {
            if (entry.isActive() && String.isNotEmpty(String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')))) {
                List<String> base64chars =
                        String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')).split('');
                for (Integer index = 0; index < (controlEntries != null ? controlEntries.size() : 2); index++) {
                    Object controlValue =
                            (controlEntries == null
                                    ?   (Object) (index == 1)
                                    :   (Object) (controlEntries[index].isActive() ? controlEntries[index].getLabel() : null)
                            );
                    Integer bitIndex = index / 6;
                    if (bitIndex > base64chars.size() - 1) {
                        break;
                    }
                    Integer bitShift = 5 - Math.mod(index, 6);
                    if  (controlValue == null || (base64map.indexOf(base64chars[bitIndex]) & (1 << bitShift)) == 0)
                        continue;
                    if (!dependentPicklistValues.containsKey((String) controlValue)) {
                        dependentPicklistValues.put((String) controlValue, new List<String>());
                    }
                    dependentPicklistValues.get((String) controlValue).add(entry.getLabel() + ',' + entry.getValue());
                }
            }
        }
        if(dependentPicklistValues.containsKey(ControllingfieldValue)){
            controllinglist = dependentPicklistValues.get(ControllingfieldValue);
            system.debug('In dependentPicklistValues---> '+ controllinglist);
        }
        return controllinglist;
    }

    public static Map<String,List<String>> getPicklistDependentValues(String ObjectApiName, String FieldApiName) {
        Schema.SobjectField dependToken = Schema.getGlobalDescribe().get(ObjectApiName).getDescribe().fields.getMap().get(FieldApiName);
        Schema.DescribeFieldResult depend = dependToken.getDescribe();

        Schema.sObjectField controlToken = depend.getController();
        if (controlToken == null) {
            return new Map<String,List<String>>();
        }
    
        Schema.DescribeFieldResult control = controlToken.getDescribe();
        List<Schema.PicklistEntry> controlEntries;
        if(control.getType() != Schema.DisplayType.Boolean) {
            controlEntries = control.getPicklistValues();
        }
    
        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        Map<String,List<String>> dependentPicklistValues = new Map<String,List<String>>();
        for (Schema.PicklistEntry entry : depend.getPicklistValues()) {
            if (entry.isActive() && String.isNotEmpty(String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')))) {
                List<String> base64chars =
                        String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')).split('');
                for (Integer index = 0; index < (controlEntries != null ? controlEntries.size() : 2); index++) {
                    Object controlValue =
                            (controlEntries == null
                                    ?   (Object) (index == 1)
                                    :   (Object) (controlEntries[index].isActive() ? controlEntries[index].getLabel() : null)
                            );
                    Integer bitIndex = index / 6;
                    if (bitIndex > base64chars.size() - 1) {
                        break;
                    }
                    Integer bitShift = 5 - Math.mod(index, 6);
                    if  (controlValue == null || (base64map.indexOf(base64chars[bitIndex]) & (1 << bitShift)) == 0)
                        continue;
                    if (!dependentPicklistValues.containsKey((String) controlValue)) {
                        dependentPicklistValues.put((String) controlValue, new List<String>());
                    }
                    dependentPicklistValues.get((String) controlValue).add(entry.getLabel() + ',' + entry.getValue());
                }
            }
        }
        return dependentPicklistValues;
    }
    
    /* TCS-SDT-31265
    * @methodName- getPickListLabelByAPIValue
    *@description- Method to query the object picklist label by API value 
    *@param- String :ObjectApiName - Hold object name
    *@param- String :FieldApiName - Hold object field name
	*@param- String :FieldApiName - Hold object field API value
    *@return- String: picklist lavel value 
    */  
    public static String getPickListLabelByAPIValue(String ObjectApiName, String FieldApiName, String fieldAPIValue){
        String pickListLabel = '';
        try{
            Schema.SObjectType s = Schema.getGlobalDescribe().get(ObjectApiName);
            Schema.DescribeSObjectResult r = s.getDescribe();
            Map<String,Schema.SObjectField> fields = r.fields.getMap();
            Schema.DescribeFieldResult fieldResult = fields.get(FieldApiName).getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for(Schema.PicklistEntry pickListVal : ple)
            {
                if(pickListVal.getValue() == fieldAPIValue)
                	pickListLabel = pickListVal.getLabel();
            }
        }catch(Exception ex){
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.Pricing_Request_APEX,LoggingLevel.ERROR);
        }
        return pickListLabel;
    }
	
	//TCS-pkulkarn-SDT-36171-Created this method to collate picklist related methods in one class
    //Test class: AssetQuoteProcurementControllerTest.testScheduleAOverrideFieldDefaults
    public static String getPicklistEntryByLabel(List<Schema.PicklistEntry> picklistEntries, String searchString)
    {
        String result;
        if(searchString!='')
        {
            for(Schema.PicklistEntry pe :picklistEntries){
                if(pe.getLabel() == searchString){
                    result= pe.getValue();
                    break;
                }
            }
        }
        return result;
    }
/*
    * @vendor            TCS
    * @story             SDT-31262,SDT 30079
    * @author            Seema Dhikale
    * @description       This method is used to return map of controlling fields and its dependent fields
    * @param             Schema.sObjectField dependentField
    * @return            Map<Object,List<String>>
    */    
    public static Map<Object,List<String>> getDependentPicklistValues(Schema.sObjectField dependentField){
        Map<Object,List<String>> dependentPicklistValues = new Map<Object,List<String>>();
        //Get dependent field result
        Schema.DescribeFieldResult dependentFieldResult = dependentField.getDescribe();
        //Get dependent field controlling field 
        Schema.sObjectField controllerField = dependentFieldResult.getController();
        //Check controlling field is not null
        if(controllerField == null){
            return null;
        } 
        //Get controlling field result
        Schema.DescribeFieldResult controllerFieldResult = controllerField.getDescribe();
        //Get controlling field picklist values if controlling field is not a checkbox
        List<Schema.PicklistEntry> controllerValues = (controllerFieldResult.getType() == Schema.DisplayType.Boolean ? null : controllerFieldResult.getPicklistValues());
         
        //It is used to decode the characters of the validFor fields. 
        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
         
        for (Schema.PicklistEntry entry : dependentFieldResult.getPicklistValues()){
            if (entry.isActive()){
            //The PicklistEntry is serialized and deserialized using the Apex JSON class and it will check to have a 'validFor' field
                List<String> base64chars = String.valueOf(((Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')).split('');
                for (Integer i = 0; i < controllerValues.size(); i++){
                    Object controllerValue = (controllerValues == null ? (Object) (i == 1) : (Object) (controllerValues[i].isActive() ? controllerValues[i].getLabel() : null));
                    Integer bitIndex = i / 6;
                    Integer bitShift = 5 - Math.mod(i, 6 );
                    if(controllerValue == null || (base64map.indexOf(base64chars[bitIndex]) & (1 << bitShift)) == 0){
                        continue;
                    } 
                    if (!dependentPicklistValues.containsKey(controllerValue)){
                        dependentPicklistValues.put(controllerValue, new List<String>());
                    }
                    dependentPicklistValues.get(controllerValue).add(entry.getLabel());
                }
            }
        }
        return dependentPicklistValues;
    }
}