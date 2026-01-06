/**
* @author Waste Management - Vishnu
* @date 9-13-2022
* @ User Story -SDT-24410
* @ Description - Class Used BR_RelatedList Aura component Controller
*/


public class BR_RelatedListController {
    



    /**
* @author Waste Management - Vishnu
*  @date 9-13-2022
* @ User Story -SDT-24410
* @ Description - Method fetch BR records 
* @ Params - Location (Id) - Account Id
*/
    @AuraEnabled    
    public static List<Business_Rule__c> getBrRecords (String locationId){
        Id parentAccId ;
        set<Id> categoryIdset = new set<Id> ();
        List<Business_Rule__c> brList =  new List<Business_Rule__c>();
        for(Account loc: [Select Id,ParentId,Brand__c,Division__c,Geography__c,Location_Type__c from account where Id =:locationId]){
            parentAccId = loc.ParentId ;
            if(loc.Brand__c != null){
                categoryIdset.add(loc.Brand__c);
            }
             if(loc.Division__c != null){
                categoryIdset.add(loc.Division__c);
            }
             if(loc.Geography__c != null){
                categoryIdset.add(loc.Geography__c);
            }
             if(loc.Location_Type__c != null){
                categoryIdset.add(loc.Location_Type__c);
            }
        }
        for(Business_Rule__c br : [select Id,Name,AccountId__c,LocationId__c,Active__c,Group__c,AccountId__r.Name,Request_Type__c,Service__c,Category_Type__c,Is_Auto_Email__c 
                                   from Business_Rule__c where AccountId__c =:parentAccId]){
                                       if((br.LocationId__c != Null && br.LocationId__c == locationId)
                                          || (br.LocationId__c == Null && br.Group__c == NULL) 
                                          || (br.LocationId__c == Null && categoryIdset.size() > 0 && categoryIdset.contains( br.Group__c) ) ){
                                           brList.add(br)  ;
                                       }
                                     
                                   }
       return brList ;

}
}