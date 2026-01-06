/***************************************
*Class Name : objectQueryUtility 
*Author : Rajan Sajani
*JIRA : SDT-40063
*Description : to optimization for Soql 101 issues
****************************************/
public class objectQueryUtility {
   private static Map<String, String> cachedGroupIdMap = new Map<String, String>();
   private static Map<String, String> cachedLoggedInUserProfileMap = new Map<String, String>();
   private static Map<String, EmailTemplate> cachedEmailTemplate = new Map<String, EmailTemplate>();
   private static Map<String, Id> cachedBusinessHourMap = new Map<String, Id>();

   public static String getGroupId(String DeveloperName) {
    
       if (cachedGroupIdMap.isEmpty()) {

           try {
               String corporateServiceQueueId = [SELECT Id FROM Group WHERE DeveloperName =:DeveloperName LIMIT 1].Id;
               cachedGroupIdMap.put(DeveloperName, corporateServiceQueueId);
           } catch (QueryException e) {
              
               cachedGroupIdMap.put(DeveloperName, null);
           }
       }
       return cachedGroupIdMap.get(DeveloperName);
       
   }
   
   public static String getBusinessHoursId(String Name) {
    
       if (cachedBusinessHourMap.isEmpty()) {
           try {
               Id businessHoursId = [SELECT Id FROM BusinessHours WHERE Name =:Name AND IsActive = true LIMIT 1].Id;
               cachedBusinessHourMap.put(Name, businessHoursId);
           } catch (QueryException e) {
               cachedBusinessHourMap.put(Name, null);
           }
       }
       return cachedBusinessHourMap.get(Name);
   }
   
   public static String getLoggedInUserProfile(Id UserProfileId ) {

   String Name = Constant_Util.BUSINESSNAME;
       if (!cachedLoggedInUserProfileMap.containsKey(UserProfileId)) {
           try {
               String  loggedInUserProfileName  = [SELECT Id, Name FROM Profile WHERE Id=:UserProfileId ].Name;
               cachedLoggedInUserProfileMap.put(UserProfileId , loggedInUserProfileName  );
           } catch (QueryException e) {
               cachedLoggedInUserProfileMap.put(UserProfileId , null);
           }
       }
       return cachedLoggedInUserProfileMap.get(UserProfileId );
   }
   public static EmailTemplate getEmailTemplateByName(String TemplateName) {
        String TEMPLATE_NAME_CASE = 'Customer or Internal: Pickup Approval';
        String TEMPLATE_NAME_MULTICASE = 'Pickup Obtain Service Approval - Multi Case';
        String TEMPLATE_NAME_ESC = 'Customer or Internal: Pickup Approval Escalation';
        List<String> templateList = new List<String>{TEMPLATE_NAME_CASE,TEMPLATE_NAME_MULTICASE,TEMPLATE_NAME_ESC};
   
           if (!cachedEmailTemplate.containsKey(TemplateName)) {
               try {
                   For(EmailTemplate template : [SELECT Id, Name  FROM EmailTemplate WHERE Name IN :templateList]){
                                                    
                                cachedEmailTemplate.put(template.Name,template);                    
                                                    
                    }
                                                
                  
               } catch (QueryException e) {
                   cachedEmailTemplate.put(TemplateName, null);
               }
           }
       return cachedEmailTemplate.get(TemplateName);
   }



   
}