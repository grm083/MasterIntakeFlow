public class DataStoreProcessor {
    
    Private Static DECIMAL MAX_FIELDS = 10;//we are creating 10 custom fields on the object
    Private Static INTEGER CHUNK_SIZE = 131071;//character limit for long text area in salesforce
    Private Static List<String> EXCEPTION_FIELDS_LIST = new List<String> {'attributes', 'Id'};
        
        /***********CONVERTING TO JSON AND INSERTING AS DATA STORE RECORD STRTS HERE***********/
        
        //serialize the list of records received
        public string serialize(List<sObject> objList) {
            return JSON.serialize(objList, false);
        }
    
    //Splits the serialized JSON into chunks
    public List<String> splitJsonIntoChunks(String jsonString) {
        List<String> chunks = new List<String>();
        for (Integer i = 0; i < jsonString.length(); i += CHUNK_SIZE) {
            Integer endLocation = Math.min(i + CHUNK_SIZE, jsonString.length());
            chunks.add(jsonString.substring(i, endLocation));
        }
        return chunks;
    }
    
    //Stores the chunks into a Data_Store__c record with 10 long text fields
    public List<Data_Store__c> storeChunksInFields(List<String> chunks, String relatedRecordId) {
        
       // if (chunks.size() > MAX_FIELDS) {
         //   throw new LimitException('Data too large to store in 10 fields.');
        //}
        
        
        Decimal chunkSize 			= chunks.size();
        Decimal records   			= chunkSize/MAX_FIELDS; 
        Long numberOfRecords      	= records.round(System.roundingmode.CEILING);
        
        Integer offset 				= 0;
        List<Data_Store__c> lstDataStore = new List<Data_Store__c>();
        for(integer counter=0;counter<numberOfRecords; counter++){
            
            Data_Store__c dataRecord = new Data_Store__c();
            
            for (Integer i = offset; i < chunks.size(); i++) {
                String fieldName = 'Field' + (i + 1) + '__c';
                dataRecord.put(fieldName, chunks[i]);
                if(i > MAX_FIELDS){
                    dataRecord.Related_Record_Id__c = relatedRecordId;
                    lstDataStore.add(dataRecord);
                    offset = i+1;
                    break;
                }else{
                    if((chunks.size()-(i+1))==0){
                          dataRecord.Related_Record_Id__c = relatedRecordId;
                         lstDataStore.add(dataRecord);
                    }
                }
            }
        }
        
        return lstDataStore;
    }
    
    //inserting the Data_Store__c record into the data base
    public String convertAndInsertToDataStore(List<sObject> objList, String relatedRecordId) {
        String result;
        
        try {
            //converting to json string
            String jsonString = serialize(objList);
            System.debug('jsonString ' + jsonString);
            System.debug('objList ' + objList);
            
            //splitting into chunks
            List<String> jsonChunks = splitJsonIntoChunks(jsonString);
                        System.debug('jsonChunks ' + jsonChunks);
                        
            //storing to fields and inserting the data store record
            List<Data_Store__c> lstDataStore = storeChunksInFields(jsonChunks, relatedRecordId);
            
            insert lstDataStore;
            
            result = 'SUCCESS';
        }
        
        catch(Exception ex) {
            result = 'FAILURE';
        }
        
        return result;
    }
    
    /***********ENDS HERE***********/
    
    
    /***********RECONSTUCTING TO FULL JSON AND INSERTING AS List<sObject> STARTS HERE***********/
    
    //method to reconstruct json string from the fields
    public String reconstructJson(Data_Store__c record) {
        String finalJsonString = '';
        for (Integer i = 1; i <= 10; i++) {
            String fieldName = 'Field' + i + '__c';
            String part = (String)record.get(fieldName);
            if (part != null) finalJsonString += part;
        }
        return finalJsonString;
        
    }
    
    // Convert JSON string to sObject list and insert to database
    // Returns the data based on the type provided.
    public Object reconstruct(Type sObjectType, Id relatedRecordId) {
        Object  result;
            String finalJsonString = '';
            // Step 1: Query stored record
            for(Data_Store__c dataStoreRecord : [
                SELECT Field1__c, Field2__c, Field3__c, Field4__c, Field5__c,
                Field6__c, Field7__c, Field8__c, Field9__c, Field10__c, Related_Record_Id__c                  
                FROM Data_Store__c
                WHERE Related_Record_Id__c = :relatedRecordId
                ORDER BY Sequence_Number__c ASC
                LIMIT 200
            ])
            {
                
                // Step 2: Reconstruct full JSON string from multiple records
                finalJsonString += reconstructJson(dataStoreRecord);
            }
            
            System.debug('finalJsonString >> ' + finalJsonString);
            // Step 3: Deserialize into list of Map<String, Object>
            result =  JSON.deserialize(finalJsonString, sObjectType); 
            //result = JSON.deserializeUntyped(finalJsonString);
            System.debug('recordList >> ' + result);
           
            return result;
    }
    
   public static String getFieldsAsCommaSeparatedString(String sObjectName) {
    if (String.isBlank(sObjectName)) return '';
    SObjectType objType = Schema.getGlobalDescribe().get(sObjectName);
    if (objType == null) return '';
    Map<String, Schema.SObjectField> fieldMap = objType.getDescribe().fields.getMap();
    List<String> fieldNames = new List<String>(fieldMap.keySet());
    fieldNames.sort();
    return String.join(fieldNames, ',');
}

    
    
    
    /***********ENDS HERE***********/
    
}