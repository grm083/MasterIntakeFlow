/*
 * Class Name: FetchAccountContactByRole
 * Author: Adil Aleem
 * Date: 01/10/2022
 * Description: This class is used to fetch account contact relation record count by roles and vendor id
 *  
 * */
public class FetchAccountContactByRole {
    @InvocableMethod
    public static List<Integer> fetchAccountContactData(List<FlowInputvalues> flowInputList){
        Integer recordCount = 0;
        if(flowInputList !=null && !flowInputList.isEmpty()){
            String vendorId = flowInputList[0].vendorId;
            String role = flowInputList[0].role; 
            if(String.isNotBlank(vendorId) && String.isNotBlank(role)) {
                recordCount =  [SELECT count()
                                FROM AccountContactRelation 
                                WHERE AccountId =: vendorId 
                                AND Roles INCLUDES (:role) 
                            ];          
            }
        }
        return new List<Integer>{recordCount};
    }

  
    // Wrapper class to get flow input variables.
  public class FlowInputvalues{
    @invocablevariable
    public String vendorId;

    @invocablevariable
    public String role;
  }

}