/*
* @vendor           TCS
* @story            //SDT 39047
* @author           Seema Dhikale
* @description       This class is used to perform Billing case related calculations. 
*/ public class BillingService{
    public List<String> elligibleProfileNames = new List<String>{'Customer Account Team','Customer Service','Compliance','Quality-Billing','System Administrator'};//list of allow profile names
    public String profileName='';
    public string  CASE_TYPE_BILLING = 'Billing';
    public string  CASE_SUB_TYPE_Invoice_Charge_Dispute = 'Invoice Charge Dispute';
    
    //This method will return profile name if loggedin user profile is elligible for providing data in Invoice_Number__c and Disputed_Amount__c
    /*Private String loggedInUserProfileName(){
        Id profileId=userinfo.getProfileId();
        if(profileName=='')
        {
        Profile p=[Select Id,Name from Profile where Id=:profileId];
            if(p!=null && elligibleProfileNames.contains(p.Name)){
                profileName = p.Name;
            }
        }
        return profileName;
    }*/
    Private String loggedInUserProfileName(String LoggedInUserProfile){
        if(LoggedInUserProfile!='')
        {
            if(elligibleProfileNames.contains(LoggedInUserProfile)){
                profileName = LoggedInUserProfile;
            }
        }
        return profileName;
    }
    /*
* @vendor           TCS
* @story            //SDT 39047
* @author           Seema Dhikale
* @description       This method is used to get whether grogress case should be enabled or disabled 
* @param             Case Type, Case Subtype, Invoice number, Disupted Amount
* @return            Void
*/ 
    public boolean isBillingDataBlank(Case myCase,String LoggedInUserProfile){
        boolean allowProgressCase = true;
        profileName = loggedInUserProfileName(LoggedInUserProfile);
        if(string.isNotBlank(myCase.Case_Type__c) && string.isNotBlank(myCase.Case_Sub_type__c) && profileName!=''){
            if(myCase.Case_Type__c == CASE_TYPE_BILLING && myCase.Case_Sub_Type__c == CASE_SUB_TYPE_Invoice_Charge_Dispute && (String.isBlank(myCase.Invoice_Number__c)  || myCase.Disputed_Amount__c==null)){
                allowProgressCase = false;
            }
        }
        return allowProgressCase;
    }
}