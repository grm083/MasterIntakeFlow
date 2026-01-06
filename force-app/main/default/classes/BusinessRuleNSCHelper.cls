/* Quote Prioritization logic to NSC 
* Author: Arvind Kumar
* Date: 11/8/2023
* Description: Get the Business Rule based on the priorities
* */
public class BusinessRuleNSCHelper {
    
    // Select the Business Rules
    public static List<BusinessRulewrapper> selectBusinessRules(List<Case> csObj){
        List<BusinessRulewrapper> bRulesWrapper = new List<BusinessRulewrapper>();
        Map<String,Business_Rule__c> brMap = new Map<String,Business_Rule__c>();
        /*Id CaseId*/ 
        /*List<Case> csObj = [Select Id,Client__c,Location__c,Location__r.Location_Type__c,Location__r.Geography__c,
        Location__r.Division__c,Location__r.Brand__c,AssetId,
        Case_Type__c,Case_Sub_Type__c,Case_Reason__c from Case where Id =:caseId ]; */
        Map<Integer,Map<String,Business_Rule__c>> brPriorityVsBRMap = new Map<Integer,Map<String,Business_Rule__c>>();
        try{
            if(!csObj.isEmpty()){
                String required_Information = 'Required_Information';
                String locationType = 'Location Type';
                String geography = 'Geography';
                String divisionDepartment = 'Division/Department';
                String brand = 'Brand';
                Id reqInfoRTId = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByDeveloperName().get(required_Information).getRecordTypeId();
                List<Business_Rule__c> brList = [Select Id,Alias__c,Category_Type__c,Required_Information__c,AccountId__c,Case_Reason__c,
                                                 LocationId__c,Group__c,RecordTypeId,End_Date__c,
                                                 Container__c,Material__c,Service__c,Schedule_Type__c,
                                                 Project_Code__c,AssetId__c 
                                                 from Business_Rule__c where  RecordTypeId =:reqInfoRTId AND Active__c = True
                                                 AND AccountId__c=:csObj[0].Client__c AND Request_Type__c =: csObj[0].Case_Type__c AND Service__c =: csObj[0].Case_Sub_Type__c
                                                 AND Effective_Date__c <=: System.Today() AND (End_Date__c >=: System.Today() OR End_Date__c =: null) Limit 49990];
                if(brList!=null && !brList.isEmpty()){
                    for(Business_Rule__c br : brList){
                        if(br!=null && string.isblank(br.Schedule_Type__c) && string.isblank(br.Container__c) && string.isBlank(br.Material__c) 
                           && string.isblank(csObj[0].AssetId) && string.isblank(br.AssetId__c) && string.isblank(br.Project_Code__c)){
                               if(br!=null && string.isNotblank(br.LocationId__c) && csObj[0].Location__c!=null && br.LocationId__c.equals(csObj[0].Location__c) 
                                  && string.isblank(br.Category_Type__c) && string.isblank(br.Group__c) ){
                                      brMap.put(br.LocationId__c+'-'+br.Service__c,br);
                                      brPriorityVsBRMap.put(1,brMap);
                               }else if(String.isNotBlank(br.Category_Type__c) && br.Category_Type__c.equals(locationType) && csObj[0].Location__c!=null && string.isNotblank(br.Group__c) && string.isNotblank(csObj[0].Location__r.Location_Type__c) && br.Group__c.equals(csObj[0].Location__r.Location_Type__c)){
                                   brMap.put(br.Category_Type__c+'-'+br.Service__c,br);
                                   brPriorityVsBRMap.put(2,brMap);
                               }else if(String.isNotBlank(br.Category_Type__c) && br.Category_Type__c.equals(geography) && csObj[0].Location__c!=null && string.isNotblank(br.Group__c) && string.isNotblank(csObj[0].Location__r.Geography__c) && br.Group__c.equals(csObj[0].Location__r.Geography__c)){
                                   brMap.put(br.Category_Type__c+'-'+br.Service__c,br);
                                   brPriorityVsBRMap.put(3,brMap);
                               }else if(String.isNotBlank(br.Category_Type__c) && br.Category_Type__c.equals(divisionDepartment) && csObj[0].Location__c!=null && string.isNotblank(br.Group__c) && string.isNotblank(csObj[0].Location__r.Division__c) && br.Group__c.equals(csObj[0].Location__r.Division__c)){
                                   brMap.put(br.Category_Type__c+'-'+br.Service__c,br);
                                   brPriorityVsBRMap.put(4,brMap);
                               }else if(String.isNotBlank(br.Category_Type__c) && br.Category_Type__c.equals(brand) && csObj[0].Location__c!=null && string.isNotblank(br.Group__c) && string.isNotblank(csObj[0].Location__r.Brand__c) && br.Group__c.equals(csObj[0].Location__r.Brand__c)){
                                   brMap.put(br.Category_Type__c+'-'+br.Service__c,br);
                                   brPriorityVsBRMap.put(5,brMap);
                               }else if(( String.isBlank(br.Case_Reason__c) || String.isNotBlank(br.Case_Reason__c)) && csObj[0].Location__c!=null && br.LocationId__c==null && br.Group__c==null){
                                   brMap.put(br.AccountId__c+'-'+br.Service__c,br);
                                   brPriorityVsBRMap.put(6,brMap);
                               }
                           }
                    }
                    system.debug('brPriorityVsBRMap :: '+brPriorityVsBRMap.KeySet());
                    system.debug('brPriorityVsBRMap :: '+brPriorityVsBRMap);
                    
                    
                    for(Case cs : csObj){
                        if(cs.Location__c!=null){
                            BusinessRuleWrapper brWrapper = null;
                            if(brPriorityVsBRMap!=null && brPriorityVsBRMap.containsKey(1) && !brMap.isEmpty() && 
                               (brMap.containsKey(cs.Location__c+'-'+cs.Case_Sub_Type__c)) ){
                                   brMap = brPriorityVsBRMap.get(1);
                                   for(Business_Rule__c brR : brMap.values()){
                                       if(brMap.containsKey(cs.Location__c+'-'+cs.Case_Sub_Type__c)){
                                           brWrapper = new BusinessRuleWrapper(cs.Id,brMap.get(cs.Location__c+'-'+cs.Case_Sub_Type__c));
                                           break;
                                       }
                                   }
                               }else if(brPriorityVsBRMap!=null && brPriorityVsBRMap.containsKey(2) && !brMap.isEmpty() &&
                                        (brMap.containsKey(locationType+'-'+cs.Case_Sub_Type__c)) ){
                                            brMap = brPriorityVsBRMap.get(2);
                                            for(Business_Rule__c brR : brMap.values()){
                                                if(brMap.containsKey(locationType+'-'+cs.Case_Sub_Type__c)){
                                                    brWrapper = new BusinessRuleWrapper(cs.Id,brMap.get(locationType+'-'+cs.Case_Sub_Type__c));
                                                    break;
                                                }
                                            }
                                        }else if(brPriorityVsBRMap!=null && brPriorityVsBRMap.containsKey(3) && !brMap.isEmpty() &&
                                                 (brMap.containsKey(geography+'-'+cs.Case_Sub_Type__c)) ){
                                                     brMap = brPriorityVsBRMap.get(3);
                                                     for(Business_Rule__c brR : brMap.values()){
                                                         if(brMap.containsKey(geography+'-'+cs.Case_Sub_Type__c)){
                                                             brWrapper = new BusinessRuleWrapper(cs.Id,brMap.get(geography+'-'+cs.Case_Sub_Type__c));
                                                             break;
                                                         }
                                                     }
                                                 }else if(brPriorityVsBRMap!=null && brPriorityVsBRMap.containsKey(4) && !brMap.isEmpty() &&
                                                          (brMap.containsKey(divisionDepartment+'-'+cs.Case_Sub_Type__c))){
                                                              brMap = brPriorityVsBRMap.get(4);
                                                              for(Business_Rule__c brR : brMap.values()){
                                                                  if(brMap.containsKey(divisionDepartment+'-'+cs.Case_Sub_Type__c)){
                                                                      brWrapper = new BusinessRuleWrapper(cs.Id,brMap.get(divisionDepartment+'-'+cs.Case_Sub_Type__c));
                                                                      break;
                                                                  }
                                                              }
                                                          }else if(brPriorityVsBRMap!=null && brPriorityVsBRMap.containsKey(5) && !brMap.isEmpty() &&
                                                                   (brMap.containsKey(brand+'-'+cs.Case_Sub_Type__c))){
                                                                       brMap = brPriorityVsBRMap.get(5);
                                                                       for(Business_Rule__c brR : brMap.values()){
                                                                           if(brMap.containsKey(brand+'-'+cs.Case_Sub_Type__c)){
                                                                               brWrapper = new BusinessRuleWrapper(cs.Id,brMap.get(brand+'-'+cs.Case_Sub_Type__c));
                                                                               break;
                                                                           }
                                                                       }
                                                                   }else if(brPriorityVsBRMap!=null && brPriorityVsBRMap.containsKey(6) && !brMap.isEmpty()){
                                                                       brMap = brPriorityVsBRMap.get(6);
                                                                       for(Business_Rule__c brR : brMap.values()){
                                                                           if(brMap.containsKey(cs.Client__c+'-'+cs.Case_Sub_Type__c)){
                                                                               brWrapper = new BusinessRuleWrapper(cs.Id,brMap.get(cs.Client__c+'-'+cs.Case_Sub_Type__c));
                                                                               break;
                                                                           }
                                                                       }
                                                                   }
                            if(brWrapper!=null){
                                bRulesWrapper.add(brWrapper);
                            }
                        }
                    }
                }
            }
        }Catch(exception ex){
            system.debug('BR Debug Error :'+ ex.getMessage());
            bRulesWrapper.add(new BusinessRuleWrapper(null,null)); 
            return bRulesWrapper;
        }
        System.debug('bRulesWrapper : '+bRulesWrapper);
        return bRulesWrapper;
        
    }
    
    public class BusinessRuleWrapper {
        public Id caseId {get;set;}
        public Business_Rule__c bRule {get;set;}
        public BusinessRulewrapper(Id cId,Business_Rule__c br){
            this.caseId = cId;
            this.bRule = br;
        }
    }
    
}