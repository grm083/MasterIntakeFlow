/*
Use of Class : This class will be ue as Service class for CPQ Quote Object
 
Generally Service class should call to Query Selector class 
*/
public with sharing class SBQQQuoteService {
    // Constants
    public static final String UNITED_STATES = 'United States'; 
    public static final String PRIORITY_P3 = 'P3';   
    public static final String PRIORITY_P4 = 'P4';   
    
    // Changes for SDT-25549
    // get the from Email address from Organization-Wide From Email Address
    public static String getOrganizationWideFromEmailAddress(Id quoteId)
    {
        // Local Variables
        String orgWidefromAddress= Constant_Util.EMPTY_STRING;
        Boolean isCustomerTypePS = false;

        //Get all the Organization-Wide where display name is 'Email To Quote' OR 'PS Email to Quote' OR 'VRM Email to Quote'
        //Cosidering Email addresses are Ordered by Name : SSM > PS > VRM
        List<OrgWideEmailAddress> oweaList = [SELECT Id,Address,DisplayName FROM OrgWideEmailAddress WHERE DisplayName =: 'WM Service Update' OR DisplayName =: Constant_Util.EMAIL_TO_QUOTE OR DisplayName =: Constant_Util.PS_EMAIL_TO_QUOTE OR DisplayName =: Constant_Util.CANADA_VRM_EMAIL_TO_QUOTE Order by DisplayName];
        
        // Get quote record by quote Id
        SBQQ__Quote__c quoteRecord= [SELECT Id, SBQQ__Opportunity2__r.Case__c,CreatedBy.UserRole.Name, SBQQ__Account__r.Parent.Primary_Segment__c, Project__c, Project_Services_Request__c, QuoteProcuredStatus__c, Priority__c, SBQQ__Status__c, SBQQ__ShippingCountry__c from SBQQ__Quote__c  WHERE Id =: quoteId]; 
        Boolean isHaulAwayQuote = HaulAwayService.getIsHaulAwayService(quoteRecord.SBQQ__Opportunity2__r.Case__c);
        // Check OWE list and quote record should not empty
        if(oweaList.size()>0 && quoteRecord != null)
        {
            //'CANADA' Check
            if(quoteRecord.SBQQ__ShippingCountry__c != UNITED_STATES){
                // 'Canada' Conditions   
                // Changes for SDT-26208
                orgWidefromAddress = getFromEmailAddress(true,false,oweaList,isHaulAwayQuote);
            }
            else{

                // 'United States' condition
                 // Condition to check Customer Type = PS
                if(CheckCustomerTypePS(quoteRecord))
                {
                    // PS Type
                    isCustomerTypePS = true;
                }
                // get the From Email address
                orgWidefromAddress = getFromEmailAddress(false,isCustomerTypePS,oweaList,isHaulAwayQuote);
            }
        }
        system.debug('orgWidefromAddress >'+ orgWidefromAddress);
        return orgWidefromAddress;
    }

    // Method to check weather customer type is 'PS' 
    // Condition = Quote CreatedBy UserRole Name ='Project Service' OR Quotes Primary Account Primary Segment ='Construction and Demolition' OR Quote's Project Should not Empty OR  Project_Services_Request__c Should be true
    public static boolean CheckCustomerTypePS(SBQQ__Quote__c quoteRecord)
    {
        if((!String.isEmpty(quoteRecord.CreatedBy.UserRole.Name) && quoteRecord.CreatedBy.UserRole.Name.contains(Constant_Util.PROJECT_SERVICE)) || quoteRecord.SBQQ__Account__r.Parent.Primary_Segment__c == Constant_Util.CONSTRUCTION_AND_DEMOLITION || !String.isEmpty(quoteRecord.Project__c) || quoteRecord.Project_Services_Request__c)
            return true;
        else
           return false;
    }

    // method to get the From Email address
    public static string getFromEmailAddress(boolean isCanadianQuote,boolean isCustomerTypePS, List<OrgWideEmailAddress> oweaList,boolean isHaulAwayQuote)
    {
        integer orgWideWMServiceUpdateAddress = 0;
        integer orgWideWMSBSNewServiceAddress = 1;
        integer orgWideWMSBSProjectServicesAddress = 2;
        integer orgWideWMSSCCustomerServiceAddress = 3;
        String orgWidefromAddress =Constant_Util.EMPTY_STRING;
        if(isCanadianQuote)
        {
            // Condition for 'Canada'
            if(oweaList[orgWideWMSSCCustomerServiceAddress] != null)
                orgWidefromAddress = oweaList[orgWideWMSSCCustomerServiceAddress].Id;
        }
        else
        {
            if(isCustomerTypePS && !isHaulAwayQuote)
            {
                system.debug('oweaList[].DisplayName >'+ oweaList[orgWideWMSBSProjectServicesAddress].DisplayName);
                // Condition for 'PS'
                if(oweaList[orgWideWMSBSProjectServicesAddress] != null)
                    orgWidefromAddress = oweaList[orgWideWMSBSProjectServicesAddress].Id;
            }
            else
            {
                //SDT 44734 oweaList[orgWideWMServiceUpdateAddress] will have Organization-Wide Email Address for WM Service Update
				system.debug('oweaList[orgWideWMServiceUpdateAddress].DisplayName >'+ oweaList[orgWideWMServiceUpdateAddress].DisplayName);
				if(oweaList[orgWideWMServiceUpdateAddress] != null && isHaulAwayQuote)
                    orgWidefromAddress = oweaList[orgWideWMServiceUpdateAddress].Id;
                // Condition for 'SSM'
                else if(oweaList[orgWideWMSBSNewServiceAddress] != null)
                    orgWidefromAddress = oweaList[orgWideWMSBSNewServiceAddress].Id;
            }
        }
        return orgWidefromAddress;
    }
}