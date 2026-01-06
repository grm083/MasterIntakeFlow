/*
    * @Name          UserSelector
    * @Author        Seema Dhikale
    * @Vendor        TCS
    * @Date          12/12/2023
    * @description   This class will be used as Selector class for User Object, story SDT-33495,SDT 34351
    */
public with sharing class UserSelector {
	/*
    * @vendor            TCS
    * @story             SDT-33495
    * @author            Seema Dhikale
    * @description       This method is to return user record for userId. 
    * @param             User Id
    * @return            user object
    */    
    public static User getUserRecord(Id userId)
    {
        return [select id,User_categorization_code__c from user where id=:userId];
    }

    //TCS-pkulkarn-SDT-41186-14-Oct-2024-Added
    //Caller: QuoteApprovalHandler.assignQuoteToSSMTeam
    public static List<User> getSSMUser()
    {
        List<User> ssmTeamUser = [SELECT Id FROM User WHERE Name = 'SSM Team' LIMIT 1];
        return ssmTeamUser;
    }
    
    //SDT-45079
    //Caller: QuoteApprovalHandler.assignQuoteToCSResolutionTeamUser
    public static List<User> getCSResolutionTeamUser()
    {
        List<User> ssmTeamUser = [SELECT Id,UserName FROM User WHERE Name = 'CS Service Resolution Team' LIMIT 1];
        return ssmTeamUser;
    }

    @InvocableMethod(label='Get Team User' description='Get the Team User by Email Id')
    /*
    * This method is Invokable from flow Create Genesys Routing
    * @owner : TCS - Aliasgher
    * @param : List<String>
    */
public static List<CSR_User_Data_Setup__mdt> getUserByEmailId(List<String> toEmail) {
        List<CSR_User_Data_Setup__mdt> usrCSRRecord = new List<CSR_User_Data_Setup__mdt>();
    List<CSR_User_Data_Setup__mdt> sfdcCSRUserLst = [SELECT id, User_categorization__c, User_categorization_code__c, 
                                                     Is_Genesys_User__c, Email_Id__c, SFDC_Task_User__c, 
                                                     SFDC_user_Id__c, SFDC_Team__c, GR_Service_Flag__c 
                                                     FROM CSR_User_Data_Setup__mdt LIMIT 1000];
    
    // Process each email in the input list
    for(String email : toEmail) {
        Boolean foundMatch = false;
        
        // Find matching records for this email
        for(CSR_User_Data_Setup__mdt sfdcCSR : sfdcCSRUserLst) {
            if(sfdcCSR.Email_Id__c != null && email != null && sfdcCSR.Email_Id__c.containsIgnoreCase(email)) {
                    usrCSRRecord.add(sfdcCSR);
                foundMatch = true;
            }
        }
        
        // If no match found for this email, add a null or placeholder
        if(!foundMatch) {
            // Adding null ensures we maintain the 1:1 ratio between inputs and outputs
            usrCSRRecord.add(null);
        }
    }
    
    system.debug('CSR Records: ' + usrCSRRecord);
        return usrCSRRecord;
    }
}