/***************************************
*Class Name : SystemObjectSelector
*Author : Rajan Sajani
*JIRA : SDT-40063
*Description : to optimization for Soql 101 issues
****************************************/
public class SystemObjectSelector{
   private static Map<String, String> cachedGroupIdMap = new Map<String, String>();
   private static Map<String, String> cachedLoggedInUserProfileMap = new Map<String, String>();
   private static Map<String, EmailTemplate> cachedEmailTemplate = new Map<String, EmailTemplate>();
   private static Map<String, Id> cachedBusinessHourMap = new Map<String, Id>();
    private static Map<Id, Decimal> cachedacornUserMap = new Map<Id, Decimal>();
  private static Map<Set<Id>, List<Case>> caseCache = new Map<Set<Id>, List<Case>>(); 
    private static Map<Id, User> userCacheMap = new Map<Id, User>();

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
    
     public static List<Case> getCasesByIds(Set<Id> caselst) {
       // Check if the cache already has the results for the given set of IDs
       if (caseCache.containsKey(caselst)) {
          // System.debug('caseCache.get(caselst)^^^ ' +caseCache.get(caselst));
           return caseCache.get(caselst);
            
       }
       // If not cached, run the query
       List<Case> casechargeup2 = [SELECT Id,Chargeable__c,ParentId,Reference_Number__c FROM Case WHERE Id IN :caselst];
       // Store the results in the cache
       caseCache.put(caselst, casechargeup2);
          //System.debug('casechargeup2^^^ ' +casechargeup2);
       return casechargeup2;
        
   }
    
    public static List<User> getUsersByIds(Set<Id> userIds) {
       List<User> userList = new List<User>();
        //system.debug('userIds^^^ ' +userIds);
       // Split userIds into two sets: cached and non-cached
       Set<Id> nonCachedUserIds = new Set<Id>();
       for (Id userId : userIds) {
           if (userCacheMap.containsKey(userId)) {
               userList.add(userCacheMap.get(userId));
               //System.debug('userList contains^^^' +userList);
           } else {
               nonCachedUserIds.add(userId);
               //system.debug('nonCachedUserIds^^^ ' +nonCachedUserIds);
           }
       }
       // Query non-cached users
       if (!nonCachedUserIds.isEmpty()) {
           List<User> queriedUsers = [SELECT Id, Profile.Name, Username FROM User WHERE Id IN:nonCachedUserIds];
           for (User user : queriedUsers) {
               userCacheMap.put(user.Id, user);
               userList.add(user);
                 //System.debug('userList 79^^^' +userList);
           }
       }
        //System.debug('userList^^^ ' +userList);
       return userList;
   }
    
    public static Decimal acornUserId(Id UserId) {
    
       if (cachedacornUserMap.isEmpty()) {
           try {
               Decimal acornUserId = [select Acorn_SUser_ID__c from User where ID =:UserId].Acorn_SUser_ID__c;
               cachedacornUserMap.put(UserId, acornUserId);
           } catch (QueryException e) {
               cachedacornUserMap.put(UserId, null);
           }
       }
       return cachedacornUserMap.get(UserId);
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
         //SDT-39594 
        String TEMPLATE_NAME_ESC = 'Customer or Internal: Pickup Approval - Multi Case Escalation';
        String TEMPLATE_NAME_SINGLE_ESC = 'Customer or Internal: Pickup Approval Escalation';


        List<String> templateList = new List<String>{TEMPLATE_NAME_CASE,TEMPLATE_NAME_MULTICASE,TEMPLATE_NAME_ESC,TEMPLATE_NAME_SINGLE_ESC};
   
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