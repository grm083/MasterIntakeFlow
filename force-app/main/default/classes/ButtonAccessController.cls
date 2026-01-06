public class ButtonAccessController {
    @auraEnabled
    public static Boolean returnButtonAccess() {
        String profileName;
        Boolean showButton = TRUE;
        profileName = [SELECT Name FROM Profile WHERE Id =:UserInfo.getProfileId() LIMIT 1].Name;
        if(profileName != NULL && profileName == Constant_Util.CAT_RECORD_TYPE){
            showButton = FALSE;
        }
        return showButton;
    }
    
}