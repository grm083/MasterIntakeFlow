/*
* @Name          CodeSwitchTestData
* @Author        Amardeep Chauhan
* @Vendor        TCS  
* @Date          05/14/2025
* @description   This class will be used to create Code Switch Utility Test Data
*/

@isTest
public class CodeSwitchTestData  {    
    /*
    * @Name          CodeSwitchData
    * @Author        Amardeep Chauhan
    * @Vendor        TCS  
    * @Date          05/14/2025
    * @description   Generric Method to create Test data 
    */ 
    
	private static List<String> ListofCodeSwitch = new List<String>{'Amendment Quote Approvals', 'Correction Quote Approvals',
    'Exception Quote Approvals','ExhibitPricingCodeSwitch','Haul_Away','HaulAwayUIEnable','IVR_New_Service',
    'Spec_Mapping','Process_Builder_to_Flow','OfficeTraxServiceStatus','New_Quote_Validation','SLA Logic Switch','QuotelineTriggerSwitchModifyExisting',
	'Pricing MulltiVendor AM Switch','Pricing MulltiVendor PT Switch'};
	
	
    public static void CodeSwitchData(){        
            List<Code_Switch__c> codeSwitchList = new  List<Code_Switch__c>();
            Code_Switch__c codeSwitchObject;
            
            for (String  codeSwitchName : ListofCodeSwitch) {
                codeSwitchObject =  new Code_Switch__c();
                codeSwitchObject.Name = codeSwitchName;
                codeSwitchObject.Switch_Off__c = false;
                
                codeSwitchList.add(codeSwitchObject);               
        }
        Insert codeSwitchList;
        
    }
}
