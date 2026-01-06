/* Quote Prioritization logic to NTE 
* Author: Rajan Sajani
* Date: 6/11/2023
* Description: Get the Business Rule based on the priorities
* */
public class NTEApprovalRuleHelper {
    
    // Select the Business Rules
    public static List<BusinessRulewrapper> selectBusinessRules(List<Case> csObj, SBQQ__Quote__c quoteObj){
        //SBQQ__Quote__c quoteObj = [Select Id,Project__c from SBQQ__Quote__c where Id ='a9L8A0000009H1hUAE'];
        List<BusinessRulewrapper> bRulesWrapper = new List<BusinessRulewrapper>();
        Map<String,Business_Rule__c> brMap = new Map<String,Business_Rule__c>();
        Map<String,Map<String,Business_Rule__c>> brPriorityVsBRMap = new Map<String,Map<String,Business_Rule__c>>();
        try{
            if(!csObj.isEmpty()){
                String Approval = 'Approval';
                String locationType = 'Location Type';
                String geography = 'Geography';
                String divisionDepartment = 'Division/Department';
                String brand = 'Brand';
                BusinessRuleWrapper brWrapper = null;
                Id apr_RTId = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByDeveloperName().get(Approval).getRecordTypeId();
                List<Business_Rule__c> brList = [Select Id,Name,Alias__c,NTE_Rules__c,Category_Type__c,AccountId__c,Case_Reason__c,
                                                 LocationId__c,Group__c,RecordTypeId,End_Date__c,
                                                 Container__c,Material__c,Service__c,Schedule_Type__c,
                                                 Project_Code__c,AssetId__c,(SELECT id,NTE_Amount__c,Service_Type__c,RecordType.Name,Active__c from Approver_Entities__r  WHERE RecordType.Name = 'NTE Approval'
                                    AND Active__c = true ) from Business_Rule__c where  RecordTypeId =:apr_RTId AND Active__c = True
                                                 AND AccountId__c=:csObj[0].Client__c AND Request_Type__c =: csObj[0].Case_Type__c AND Service__c =: csObj[0].Case_Sub_Type__c
                                                 AND Effective_Date__c <=: System.Today() AND (End_Date__c >=: System.Today() OR End_Date__c =: null) Limit 49990];
                                                 System.debug('brList in main^^^' +brList);
                if(brList!=null && !brList.isEmpty()){
                    for(Business_Rule__c br : brList){
                        system.debug('br :' + br.Name);
                        if(br!=null){
                               if(string.isNotblank(br.LocationId__c) && csObj[0].Location__c!=null && br.LocationId__c.equals(csObj[0].Location__c) && string.isNotblank(br.Project_Code__c) && br.Project_Code__c.equals(quoteObj.Project__c) && string.isblank(br.Category_Type__c) && string.isblank(br.Group__c) ){
                                   String brKey = br.LocationId__c+'-'+br.Project_Code__c+'-'+br.Service__c;
                                   if(brKey.equals(csObj[0].Location__c+'-'+quoteObj.Project__c+'-'+csObj[0].Case_Sub_Type__c)){	
                                   		brWrapper = new BusinessRuleWrapper(csObj[0].Id,br);
                                        break;
                                   }
                               }
							   else if(string.isNotblank(br.LocationId__c) && csObj[0].Location__c!=null && br.LocationId__c.equals(csObj[0].Location__c) && string.isblank(br.Project_Code__c) && string.isblank(br.Category_Type__c) && string.isblank(br.Group__c) ){
                                   String brKey = br.LocationId__c+'-'+br.Service__c;
                                   if(brKey.equals(csObj[0].Location__c+'-'+csObj[0].Case_Sub_Type__c)){
                                       	brWrapper = new BusinessRuleWrapper(csObj[0].Id,br);
                                        break;
                                   }
                               }else if(String.isNotBlank(br.Category_Type__c) && br.Category_Type__c.equals(locationType) && csObj[0].Location__c!=null && string.isNotblank(br.Project_Code__c) && br.Project_Code__c.equals(quoteObj.Project__c) && string.isNotblank(br.Group__c) && string.isNotblank(csObj[0].Location__r.Location_Type__c) && br.Group__c.equals(csObj[0].Location__r.Location_Type__c)){
                                   String brKey = br.Category_Type__c+'-'+br.Service__c;
                                   if(brKey.equals(locationType+'-'+csObj[0].Case_Sub_Type__c)){	
                                   		brWrapper = new BusinessRuleWrapper(csObj[0].Id,br);
                                        break;
                                   }
                               }
							   else if(String.isNotBlank(br.Category_Type__c) && br.Category_Type__c.equals(locationType) && csObj[0].Location__c!=null && string.isblank(br.Project_Code__c) && string.isNotblank(br.Group__c) && string.isNotblank(csObj[0].Location__r.Location_Type__c) && br.Group__c.equals(csObj[0].Location__r.Location_Type__c)){
                                   String brKey = br.Category_Type__c+'-'+br.Service__c;
                                   if(brKey.equals(locationType+'-'+csObj[0].Case_Sub_Type__c)){	
                                   		brWrapper = new BusinessRuleWrapper(csObj[0].Id,br);
                                        break;
                                   }
                               }else if(String.isNotBlank(br.Category_Type__c) && br.Category_Type__c.equals(geography) && csObj[0].Location__c!=null && string.isNotblank(br.Project_Code__c) && br.Project_Code__c.equals(quoteObj.Project__c) && string.isNotblank(br.Group__c) && string.isNotblank(csObj[0].Location__r.Geography__c) && br.Group__c.equals(csObj[0].Location__r.Geography__c)){
                                   String brKey = br.Category_Type__c+'-'+br.Service__c;
                                   if(brKey.equals(geography+'-'+csObj[0].Case_Sub_Type__c)){	
                                   		brWrapper = new BusinessRuleWrapper(csObj[0].Id,br);
                                        break;
                                   }
                               }else if(String.isNotBlank(br.Category_Type__c) && br.Category_Type__c.equals(geography) && csObj[0].Location__c!=null && string.isblank(br.Project_Code__c) && string.isNotblank(br.Group__c) && string.isNotblank(csObj[0].Location__r.Geography__c) && br.Group__c.equals(csObj[0].Location__r.Geography__c)){
                                   String brKey = br.Category_Type__c+'-'+br.Service__c;
                                   if(brKey.equals(geography+'-'+csObj[0].Case_Sub_Type__c)){	
                                   		brWrapper = new BusinessRuleWrapper(csObj[0].Id,br);
                                        break;
                                   }
                               }else if(String.isNotBlank(br.Category_Type__c) && br.Category_Type__c.equals(divisionDepartment) && csObj[0].Location__c!=null && string.isNotblank(br.Project_Code__c) && br.Project_Code__c.equals(quoteObj.Project__c) && string.isNotblank(br.Group__c) && string.isNotblank(csObj[0].Location__r.Division__c) && br.Group__c.equals(csObj[0].Location__r.Division__c)){
                                   String brKey = br.Category_Type__c+'-'+br.Service__c;
                                   if(brKey.equals(divisionDepartment+'-'+csObj[0].Case_Sub_Type__c)){	
                                   		brWrapper = new BusinessRuleWrapper(csObj[0].Id,br);
                                        break;
                                   }
                               }else if(String.isNotBlank(br.Category_Type__c) && br.Category_Type__c.equals(divisionDepartment) && csObj[0].Location__c!=null && string.isblank(br.Project_Code__c) && string.isNotblank(br.Group__c) && string.isNotblank(csObj[0].Location__r.Division__c) && br.Group__c.equals(csObj[0].Location__r.Division__c)){
                                   String brKey = br.Category_Type__c+'-'+br.Service__c;
                                   if(brKey.equals(divisionDepartment+'-'+csObj[0].Case_Sub_Type__c)){	
                                   		brWrapper = new BusinessRuleWrapper(csObj[0].Id,br);
                                        break;
                                   }
                               }else if(String.isNotBlank(br.Category_Type__c) && br.Category_Type__c.equals(brand) && csObj[0].Location__c!=null && string.isNotblank(br.Project_Code__c) && br.Project_Code__c.equals(quoteObj.Project__c) && string.isNotblank(br.Group__c) && string.isNotblank(csObj[0].Location__r.Brand__c) && br.Group__c.equals(csObj[0].Location__r.Brand__c)){
                                   String brKey = br.Category_Type__c+'-'+br.Service__c;
                                   if(brKey.equals(brand+'-'+csObj[0].Case_Sub_Type__c)){	
                                   		brWrapper = new BusinessRuleWrapper(csObj[0].Id,br);
                                        break;
                                   }
                               }else if(String.isNotBlank(br.Category_Type__c) && br.Category_Type__c.equals(brand) && csObj[0].Location__c!=null && string.isblank(br.Project_Code__c) && string.isNotblank(br.Group__c) && string.isNotblank(csObj[0].Location__r.Brand__c) && br.Group__c.equals(csObj[0].Location__r.Brand__c)){
                                   String brKey = br.Category_Type__c+'-'+br.Service__c;
                                   if(brKey.equals(brand+'-'+csObj[0].Case_Sub_Type__c)){	
                                   		brWrapper = new BusinessRuleWrapper(csObj[0].Id,br);
                                        break;
                                   }
                               }else if(( String.isBlank(br.Case_Reason__c) || String.isNotBlank(br.Case_Reason__c)) && csObj[0].Location__c!=null && string.isNotblank(br.Project_Code__c) && br.Project_Code__c.equals(quoteObj.Project__c) && br.LocationId__c==null && br.Group__c==null){
                                   String brKey = br.AccountId__c+'-'+br.Service__c;
                                   if(brKey.equals(csObj[0].Client__c+'-'+csObj[0].Case_Sub_Type__c)){	
                                   		brWrapper = new BusinessRuleWrapper(csObj[0].Id,br);
                                        break;
                                   }
                               }else if(( String.isBlank(br.Case_Reason__c) || String.isNotBlank(br.Case_Reason__c)) && csObj[0].Location__c!=null && string.isblank(br.Project_Code__c) && br.LocationId__c==null && br.Group__c==null){
                                   system.debug('12 br Name : ' + br.Name);
                                   String brKey = br.AccountId__c+'-'+br.Service__c;
                                   if(brKey.equals(csObj[0].Client__c+'-'+csObj[0].Case_Sub_Type__c)){	
                                   		brWrapper = new BusinessRuleWrapper(csObj[0].Id,br);
                                        break;
                                   }
                               }
                           }
                    }
                    if(brWrapper!=null){
                    	bRulesWrapper.add(brWrapper);
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