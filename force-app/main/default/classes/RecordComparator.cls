/*************************************************************
@Name: RecordComparator
@Author: Soham Datta
@CreateDate: 24/01/20125
@Description: Compare two Business Rule Records. Currently using in CustomCloningBusinessRule Flow
**************************************************************/

public class RecordComparator {
    
    @InvocableMethod(label='Compare Two Records' description='Compares fields of two records dynamically')
    public static List<ComparisonResult> compareRecords(List<RecordComparisonInput> inputs) {
        List<ComparisonResult> results = new List<ComparisonResult>();
        
        for (RecordComparisonInput input : inputs) {
            
            ComparisonResult result = new ComparisonResult();
            
            // Check if either record is null
            if (input.oldRecord == null || input.newRecord == null) {
                result.differences = null;
                results.add(result);
                continue; // Skip further processing for this input
            }
            
            // Get field maps of both records
            Map<String, Object> oldRecordFields = input.oldRecord.getPopulatedFieldsAsMap();
            Map<String, Object> newRecordFields = input.newRecord.getPopulatedFieldsAsMap();
            
            // Track differences
            List<String> differingFields = new List<String>();
            
            for (String fieldName : oldRecordFields.keySet()) {
                if (newRecordFields.containsKey(fieldName)) {
                    
                    // Fetch field values
                    Object value1 = oldRecordFields.get(fieldName);
                    Object value2 = newRecordFields.get(fieldName);
                    
                    // Compare values safely
                    if ((value1 != null && value2 != null && !value1.equals(value2)) || (value1 == null && value2 != null) || (value1 != null && value2 == null)) {
                        differingFields.add(fieldName + ': ' + 'Record 1 Value = ' + value1 + ', Record 2 Value = ' + value2);
                    }
                }
            }
            
            result.differences = differingFields;
            results.add(result);
        }
        
        return results;
    }
    
    public class RecordComparisonInput {
        @InvocableVariable(label='Old Record' description='The first record to compare')
        public Business_Rule__c oldRecord;
        
        @InvocableVariable(label='New Record' description='The second record to compare')
        public Business_Rule__c newRecord;
    }
    
    public class ComparisonResult {
        @InvocableVariable(label='Differences' description='List of differing fields between the two records')
        public List<String> differences;
    }
}