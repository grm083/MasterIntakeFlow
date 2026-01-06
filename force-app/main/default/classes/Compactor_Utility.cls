public class Compactor_Utility 
{
	/* Author : TCS
	 * Date: 6-Oct-2023
	 * Use of Class : This class will be ue as an Utility class for Compactor product related functional utility
    */
    public static String COMPACTOR_VERTICAL_PRODUCT_NAME = 'Compactor - Vertical';
    
    public static String retrieveCompactorVerticalEquivalentProduct(SBQQ__QuoteLine__c bundleQuoteLine)
    {
        //To retrieve the correct mapping name for Pricing Request for Compactor - Vertical product
        return bundleQuoteLine.SBQQ__Product__r.Name == COMPACTOR_VERTICAL_PRODUCT_NAME ? Pricing_Constant_Util.VERTICAL_COMPACTOR : bundleQuoteLine.SBQQ__Product__r.Name;
    }
}