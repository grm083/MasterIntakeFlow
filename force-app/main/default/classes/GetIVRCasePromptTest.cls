@isTest(seeAllData = false)
public class GetIVRCasePromptTest {
    static User currentUser;
    static{
    	currentUser = [SELECT id from User WHERE id =: Userinfo.getUserId() limit 1];
    } 
    
    @isTest static void getIVRPromptTest(){
        System.runAs(currentUser){
            List<String> inputCaseValList = new List<String>();
            inputCaseValList.add('Add_Accessories_Additional Keys');
            inputCaseValList.add('Add_Accessories_Bale Wire');
            inputCaseValList.add('Add_Accessories_Lids');
            inputCaseValList.add('Add_Accessories_Locks');
            Test.startTest();
            	GetIVRCasePrompt.getIVRPrompt(inputCaseValList);
                List<IVRCaseTypePrompt__mdt> ivrCaseTypeList = [select id,DeveloperName,Case_Type_IVR_Key__c,Read_In_IVR__c from IVRCaseTypePrompt__mdt where Case_Type_IVR_Key__c IN : inputCaseValList];
            Test.stopTest();
                
                System.assert(ivrCaseTypeList.get(0).Read_In_IVR__c != NULL);
                System.assert(ivrCaseTypeList.get(1).Read_In_IVR__c != NULL);
                System.assert(ivrCaseTypeList.get(2).Read_In_IVR__c != NULL);
                System.assert(ivrCaseTypeList.get(3).Read_In_IVR__c != NULL);
           }       
    }
    
    @isTest static void getIVRPromptExceptionTest(){
        System.runAs(currentUser){
            Test.startTest();
            	Map<String,String> promptIdByCaseTypeSubTypeReasonMap = GetIVRCasePrompt.getIVRPrompt(Null);
            Test.stopTest(); 
           }       
    }
     
    private static testmethod void getMaterialPromptIDTest(){    
        Test.startTest();
            System.runAs(currentUser){
            	Map<String,String> promptIdByVoicePromptMap = GetIVRCasePrompt.getMaterialPromptID(new List<String>{'Trash'});
        		IVRMaterialTypePrompt__mdt ivrMaterialData = [SELECT Id, MasterLabel, Material_Prompt_ID__c, Voice_Prompt__c FROM IVRMaterialTypePrompt__mdt WHERE Voice_Prompt__c = 'Trash' LIMIT 1];
        		System.assert(ivrMaterialData.Material_Prompt_ID__c != NULL);
        	}
        Test.stopTest(); 
    }
    
    private static testmethod void getMaterialPromptIDExceptionTest(){     
        Test.startTest();
            System.runAs(currentUser){ 
                Map<String,String> promptIdByVoicePromptMap = GetIVRCasePrompt.getMaterialPromptID(Null);
        	}
        Test.stopTest(); 
    }
    
}