/*
    * @Name          UserSelector
    * @Author        Seema Dhikale
    * @Vendor        TCS
    * @Date          12/12/2023
    * @description   This class will be used as Selector class for User Object, story SDT-33495
    */
public with sharing class UserServices {
    
    public static final String USER_CATEGORIZATION_CODE = 'SFCOR';
    private static boolean alreadyQueried = false;
    private static boolean isInternalCorrectionsTeamUser = false;
    
/*
    * @vendor            TCS
    * @story             SDT-33495,SDT 34351
    * @author            Seema Dhikale
    * @description       This method is used to return true if user is member of Internal corrections team. 
    					 User categorization codes are stored in custom label InternalCorrectionTeamUCC, which
						 could be further modified by admin.
    * @param             User Id
    * @return            Boolean true if user is member of Internal corrections team else false
    */    
    public static boolean isInternalCorrectionTeamUser(Id userId)
    {
        //boolean isInternalCorrectionsTeamUser = false;
        if(userId!=null){
            if(!alreadyQueried){
            User currentUser=UserSelector.getUserRecord(userId);
            List<String> ucCodeList=System.Label.InternalCorrectionTeamUCC.split(',');
            if(ucCodeList != null && ucCodeList.contains(currentUser.User_categorization_code__c)){
                isInternalCorrectionsTeamUser=true;
            }
                alreadyQueried = true;
            }
        }
        return isInternalCorrectionsTeamUser;
    }
}