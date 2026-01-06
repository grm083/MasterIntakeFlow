// SDT-31110
// Class to read the field Set
public class FieldSetReader {
    
    // enforces refresh else returns already present values
    public static boolean enforce_Refresh = true;
    
    
    // Method to read Field Set
    // Parameter - fieldSetName , ObjectName
    public static Set<String> readFieldSet(String fieldSetName, String ObjectName)
    {        
        // Field API Name
        Set<String> fieldAPIName = new Set<String>();
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
        List<Schema.FieldSetMember> fieldSetMemberList = fieldSetObj.getFields(); 
        for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList)
        {
            fieldAPIName.add(fieldSetMemberObj.getFieldPath());
        }
        
        return fieldAPIName;
    }
}