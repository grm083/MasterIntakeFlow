/*
* @Name          OrgWideEmailSelector
* @Author        Rishan Mohammed
* @Vendor		 TCS
* @Date          22/05/2025
* @description	 This class will be used as Selector class for OrgWideEmailAddress object, story SDT-37849
*/
public without sharing class OrgWideEmailSelector {
    
    /*
* @vendor			 TCS
* @story		   	 SDT-37849
* @author			 Rishan Ali
* @description       This method is used to return OrgWideEmailAddress. Get Quote Lines by DisplayName
* @param             list of DisplayName
* @return            List of type OrgWideEmailAddress 
* @coverage          QuoteEmailHandlerTest.checkForGenesysMediatypeIfORgAddressInTo
*/    
    public static List<OrgWideEmailAddress> getOrgWideAddressList(List<String> displayNames)
    {
        return [SELECT Id, Address FROM OrgWideEmailAddress WHERE DisplayName IN:displayNames];
    }
    
}
