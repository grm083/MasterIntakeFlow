/**************************************************************************
Class Name: ConcatenateTaskDetailForAcorn
Author: Niranjan
Created Date:8/5/2019
***************************************************************************/

public Without Sharing class ConcatenateTaskDetailForAcorn {
    @InvocableMethod
    /*
	* This method is invoked from process builder/flow to concatenate task details which needs to be sent to Acorn
	* @owner : Niranjan
	* @param : List<string>
	*/
    public static List<List<String>> concatenateTaskDetail(List<Task> lstTask) {
        List<String> inputlst =  new  List<String>();
		List<List<string>> lstString = new List<List<string>>();
		set<Id> taskIds = new set<Id>();
		set<String> recordTypeNames = new set<String>();
		for(task objTask : lstTask){
			taskIds.add(objTask.Id);
		}
        for(task objTask : [SELECT Id, Status, RecordType.DeveloperName FROM Task WHERE Id IN : taskIds Limit 49999]){
			recordTypeNames.add(objTask.RecordType.DeveloperName);
		}
		List<String> retValToFlowLst = getTaskDetailtoAcornMapping(taskIds, recordTypeNames);
		for(String retValToFlow : retValToFlowLst) {	
			retValToFlow = retValToFlow.replaceAll('"', '');
			retValToFlow = retValToFlow.remove('{');
            retValToFlow = retValToFlow.remove('}');
			inputlst.add(retValToFlow);
            lstString.add(inputlst);
		}
		return lstString;
    }    
    /*
    @Method Description: Fetch Task_To_Acorn_Mapping__mdt records based on the RecordTypeName and Task Id. 
    @Return Type: JSON String
    @Parameters: RecordTypeName and TaskId
    */
    public static List<String> getTaskDetailtoAcornMapping(set<Id> taskIds, set<String> recordTypeNames){                
        List<Task_To_Acorn_Mapping__mdt> metadataList = null;
        metadataList = [SELECT Id,Field_Name__c,JSON_field_name__c,Is_Active__c,Sequence__c,Task_Record_Type__c,Data_Type__c FROM
					 Task_To_Acorn_Mapping__mdt WHERE Is_Active__c = true AND Task_Record_Type__c IN: recordTypeNames ORDER BY sequence__c];
        List<Task> taskLst = buildDynamicQuery(metadataList, taskIds);
        List<String> response = generateJson(metadataList, taskLst);
        return response;
    }
    /*
    @Method Description: Build dynamic query to get Task details based metadata results. 
    @Return Type: Task
    @Parameters: list<Integration_Request_Mapping__mdt> and Task Id
    */
    public static List<Task> buildDynamicQuery(List<Task_To_Acorn_Mapping__mdt> metadataResult, set<Id> taskIds){
        List<Task> taskLst = new List<Task>();
        set<string> fieldNames = new set<string>();
		String selectQuery = 'SELECT ';
        String fieldQuery = 'RecordType.DeveloperName,';
        String SObjectName = ' FROM Task ';
        String whereQuery = ' WHERE Id IN: taskIds ';   
        for(Task_To_Acorn_Mapping__mdt TaskToAcornMap : metadataResult) {
			fieldNames.add(TaskToAcornMap.Field_Name__c);
        }
		//To avoid duplicates
		for(string fieldName : fieldNames){
			fieldQuery += fieldName+',';
		}
        fieldQuery = fieldQuery.removeEnd(',');
        String limitQuery = 'LIMIT 49999'; 
        string query = selectQuery+fieldQuery+SObjectName+whereQuery+limitQuery; 
        taskLst = Database.query(query); 
        return taskLst;
    }
    /*@Method Description: Generating JSON
    @Return Type: JSON String
    @Parameters: List<Task_To_Acorn_Mapping__mdt> and Task
    */
    public static List<String> generateJson(List<Task_To_Acorn_Mapping__mdt> metaDataResult, List<Task> taskLst){
        MAP<String, Task_To_Acorn_Mapping__mdt> JSONandTaskFieldNameMap = new MAP<String, Task_To_Acorn_Mapping__mdt>();
		List<String> genStringLst = new List<String>();
        for(Task_To_Acorn_Mapping__mdt IRM : metaDataResult) {
            JSONandTaskFieldNameMap.put(IRM.JSON_field_name__c, IRM);
        }
		for(Task objTask : taskLst) {
			JSONGenerator gen = JSON.createGenerator(true);
			gen.writeStartObject();
			for(String firstNodeJson: JSONandTaskFieldNameMap.keySet()) {
				String TaskFieldVal = '';
				Task_To_Acorn_Mapping__mdt objIRM = JSONandTaskFieldNameMap.get(firstNodeJson);
				if(objTask.RecordType.DeveloperName == objIRM.Task_Record_Type__c) {
					if(objIRM.Data_Type__c == Constant_Util.IS_STRING) {
						TaskFieldVal = objIRM.Field_Name__c;
						if(TaskFieldVal.contains('.Name')) {
							String[] splitedVal = TaskFieldVal.split('\\.');
							if(objTask.getSObject(splitedVal[0]) != NULL) {
								if(objTask.getSObject(splitedVal[0]).get(splitedVal[1]) != NULL){
								  gen.WriteStringField(firstNodeJson, String.valueOf(objTask.getSObject(splitedVal[0]).get(splitedVal[1]))); 
								}
							}
						} else {
							if(objTask.get(TaskFieldVal) != NULL){
								gen.WriteStringField(firstNodeJson, String.valueOf(objTask.get(TaskFieldVal)));
							}
						}
					} 
					else if(objIRM.Data_Type__c == Constant_Util.IS_NUMBER) {
						TaskFieldVal = objIRM.Field_Name__c;
						if(objTask.get(TaskFieldVal) != null){
							gen.WriteNumberField(firstNodeJson, Integer.valueOf(objTask.get(TaskFieldVal)));
						}
					} 
					else if(objIRM.Data_Type__c == Constant_Util.IS_DATE) {
						TaskFieldVal = objIRM.Field_Name__c;
						if(objTask.get(TaskFieldVal) != null){
							gen.WriteDateTimeField(firstNodeJson, Date.valueOf(objTask.get(TaskFieldVal)));
						}
					} else {}
				}   
			}
            gen.writeEndObject();
			genStringLst.add(gen.getAsString());
        }
        return genStringLst;
    }
}