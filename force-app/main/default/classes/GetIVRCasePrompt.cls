/*************************************************************
@Name: GetIVRCasePrompt
@Author: WM
@CreateDate: 07/18/2019
@Description: Handler Class to Get IVR Prompt 
@UsedBy: IVRServiceStatusWebService
**************************************************************/
public without sharing class GetIVRCasePrompt {
      /*
* This method will get IVR Prompt value from custom metadata basis of case type, sub type and case reason
* @owner : WM
* @param : Case Values
*/
        public static Map<String,String> getIVRPrompt(List<String> inputCaseValues){
            try{
                   Map<String,String> promptResponse = new Map<String,String>();                
         
             for(IVRCaseTypePrompt__mdt ivrCaseType :[select id,DeveloperName,
                                                      Case_Type_IVR_Key__c,Case_Type__c,Case_Sub_Type__c,Service_Prompt_Id__c,
                                                      Case_Reason__c,Read_In_IVR__c from IVRCaseTypePrompt__mdt
                                                      where Case_Type_IVR_Key__c IN :inputCaseValues LIMIT 49999]){
               	 promptResponse.put((ivrCaseType.Case_Type_IVR_Key__c).toLowerCase(),
                                    (ivrCaseType.Read_In_IVR__c + Constant_Util.UNDERSCORE +ivrCaseType.Service_Prompt_Id__c));            	
            }
            
            return promptResponse;
            }
            catch(Exception e){ 
                 return NULL; 
      }
      
      } 
      
      /* 
	  * @Author 	: Yogesh Sharma
      * @Param 		: Material Type
      * @Return Type: String(Material Prompt Id)   
      * @Description: Get Material Prompt ID using Material type through Custom Metadata type
      */
	  public static Map<String,String> getMaterialPromptID(List<String> materialTypeList){
      	try{
      		Map<String,String> getMaterialPrmoptIDByMaterialType = new Map<String,String>();
         	Set<String> materialTypes = new Set<String>();
         	
         	materialTypes.addAll(materialTypeList);
            for(IVRMaterialTypePrompt__mdt ivrMaterialData : [SELECT MasterLabel,
                                                              Voice_Prompt__c, Material_Prompt_ID__c
                                                              FROM IVRMaterialTypePrompt__mdt 
                                                              WHERE MasterLabel IN : materialTypes LIMIT 49999]){
                getMaterialPrmoptIDByMaterialType.put((ivrMaterialData.MasterLabel).toLowerCase(),
                                           (ivrMaterialData.Material_Prompt_ID__c+ Constant_Util.UNDERSCORE +ivrMaterialData.Voice_Prompt__c));
         		
            }    			
            	return getMaterialPrmoptIDByMaterialType; 
        }catch(Exception e){ 
            System.debug('Exception-->'+e.getMessage() + 'At Line Number -->'+e.getLineNumber());
            return NULL; 
            }
     	
      } 
 }