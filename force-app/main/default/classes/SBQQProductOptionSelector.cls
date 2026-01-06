//Class: SBQQProductOptionSelector
//Purpose: To return and manipulate data on the SBQQ__ProductOption__c object in accordance with the requested Parameter
//Author: Anup Dey
//Date: 8/23/2022
public class SBQQProductOptionSelector {
    
    //method to get the all product options by parent Product and Product rule productId 
    public static List<SBQQ__ProductOption__c> getProductOptionBy(Id parentProductId, Set<Id> productIds)
    {
        return [SELECT Id, Name, SBQQ__Quantity__c, Occurrence_Type__c, CostModelType__c,
        Cost_Unit_of_Measure__c, PriceUOM__c, Schedule_Frequency__c, Frequency_Interval__c,
        SBQQ__OptionalSKU__c, Equipment_Size__c, SBQQ__ProductFamily__c
        FROM SBQQ__ProductOption__c
        WHERE SBQQ__ConfiguredSKU__c =: parentProductId AND  SBQQ__OptionalSKU__c IN: productIds AND
        SBQQ__ProductFamily__c != 'Waste Category' AND SBQQ__ProductFamily__c != 'Waste Stream'];
    } 
}