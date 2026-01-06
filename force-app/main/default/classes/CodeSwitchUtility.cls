/*
* @Name          CodeSwitchUtility
* @Author        Amardeep Chauhan
* @Vendor        TCS  
* @Date          08/04/2025
* @description   This class will be used as Utility Class for Apex code switch for different functionalities Liken IVR , Haul Away etc. 
*/
public class CodeSwitchUtility  {
    
   /*
* @Name          GenericCodeSwitch
* @Author        Amardeep Chauhan
* @Vendor        TCS  
* @Date          08/04/2025
* @description   Generric Method to get Code Switch Value 
*/ 

public static boolean getCodeSwitchOn(String typeOfSwitch){
        Code_Switch__c codeSwitchSetting = Code_Switch__c.getValues(typeOfSwitch); 
        If(codeSwitchSetting !=null) 
        return codeSwitchSetting.Switch_Off__c;
        else
        return false;       
        
    }
    
    
}