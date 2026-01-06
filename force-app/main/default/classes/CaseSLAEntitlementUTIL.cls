public class CaseSLAEntitlementUTIL {
    public static map<id,date> getQuoteIdServiceDateMap(set<id> quoteIdSet){
        map<id,date> quoteIdSlaDateMap = new map<id,date>();
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        quoteList = [SELECT id, Project__c, SBQQ__Opportunity2__r.Case__c, SBQQ__Account__c, SBQQ__Account__r.ParentId
                     FROM SBQQ__Quote__c 
                     WHERE id IN : quoteIdSet];
        
        map<id, SBQQ__QuoteLine__c> quoteIdQuoteLineMap = new map<id, SBQQ__QuoteLine__c>();
        map<id,datetime> quoteIdparentQuoteLineCreatedDateMap = new map<id, datetime>();
        List<Schema.PicklistEntry> values = SBQQ__QuoteLine__c.Duration__c.getDescribe().getPicklistValues();
		Map<String,String> statusApiToLabelMap = new Map<String,String>();
		For(Schema.PicklistEntry sp : values){
    	//Map to hold Picklist API as Key and Picklist Label as Value
    	statusApiToLabelMap.put(sp.getValue(), sp.getLabel());
         }
        
        for(SBQQ__QuoteLine__c qLine : [SELECT id, Name, SBQQ__Quote__c, Duration__c, SBQQ__ProductName__c, CreatedDate  FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c IN : quoteIdSet AND SBQQ__RequiredBy__c=null ORDER BY CREATEDDATE]){
            if(quoteIdparentQuoteLineCreatedDateMap.containsKey(qLine.SBQQ__Quote__c)){
                if(qLine.CreatedDate > quoteIdparentQuoteLineCreatedDateMap.get(qLine.SBQQ__Quote__c)){
                    quoteIdparentQuoteLineCreatedDateMap.put(qLine.SBQQ__Quote__c,qLine.CreatedDate);
                    quoteIdQuoteLineMap.put(qLine.SBQQ__Quote__c, qLine);
                    
                }
            }else{
            	quoteIdparentQuoteLineCreatedDateMap.put(qLine.SBQQ__Quote__c,qLine.CreatedDate);
                quoteIdQuoteLineMap.put(qLine.SBQQ__Quote__c, qLine); 
                
            }
        }
       
        map<id,set<id>> accIdQuotedIdSet = new map<id,set<id>>();
        map<id,SBQQ__Quote__c> caseIdQuoteMap = new map<id,SBQQ__Quote__c>();
        for(SBQQ__Quote__c quote: quoteList){
            caseIdQuoteMap.put(quote.SBQQ__Opportunity2__r.Case__c, quote);
            if(accIdQuotedIdSet.containsKey(quote.SBQQ__Account__c)){
                set<id> tempidSet = new set<id>();
                tempidSet = accIdQuotedIdSet.get(quote.SBQQ__Account__c);
                tempidSet.add(quote.Id);
                accIdQuotedIdSet.put(quote.SBQQ__Account__c,tempidSet);
            }else{
                set<id> dummyidSet = new set<id>();
                dummyidSet.add(quote.Id);
                accIdQuotedIdSet.put(quote.SBQQ__Account__c,dummyidSet);
            }
        }
        map<id, case> caseIdCaseMap = new map<id, case>([SELECT id, SLA_Service_Date_Time__c
                                                         FROM Case 
                                                         WHERE id IN: caseIdQuoteMap.keySet()]);
        
        map<id, Account> accountidAccountRecordMap = new map<id, Account>([SELECT id, name, 
                                                                           (SELECT id, AccountId, Project_Code__c,Project__c, Location__c, Schedule_Type__c,Container__c FROM Entitlements) 
                                                                           FROM Account 
                                                                           WHERE id IN:accIdQuotedIdSet.keySet()]);
        for(SBQQ__Quote__c quote: quoteList){
            datetime slaDateTime;
            if(accountidAccountRecordMap.containsKey(quote.SBQQ__Account__c)){
                Account acc = accountidAccountRecordMap.get(quote.SBQQ__Account__c);
                if(acc.Entitlements.size()>0){
                    for(Entitlement ent: acc.Entitlements){
                        //Projects for Locations
                        if(quote.Project__c == ent.Project_Code__c && 
                           quote.SBQQ__Account__c == ent.Location__c)
                        {
                            slaDateTime = caseIdCaseMap.get(quote.SBQQ__Opportunity2__r.Case__c).SLA_Service_Date_Time__c;
                            break;
                        }
                        //Projects for Accounts
                        else if(quote.Project__c == ent.Project_Code__c && 
                                quote.SBQQ__Account__r.ParentId == ent.AccountId)
                        {
                            slaDateTime = caseIdCaseMap.get(quote.SBQQ__Opportunity2__r.Case__c).SLA_Service_Date_Time__c;
                            break;
                        }
                        //Duration and Container Match for Location
                        else if(quoteIdQuoteLineMap.containskey(quote.Id) && 
                                statusApiToLabelMap.get(quoteIdQuoteLineMap.get(quote.Id).Duration__c) == ent.Schedule_Type__c && 
                                quoteIdQuoteLineMap.get(quote.Id).SBQQ__ProductName__c == ent.Container__c && 
                                quote.SBQQ__Account__c  == ent.Location__c)
                        {
                            slaDateTime = caseIdCaseMap.get(quote.SBQQ__Opportunity2__r.Case__c).SLA_Service_Date_Time__c;
                            break;
                        }
                        //Duration Match for Location
                        else if(quoteIdQuoteLineMap.containskey(quote.Id) && 
                                statusApiToLabelMap.get(quoteIdQuoteLineMap.get(quote.Id).Duration__c) == ent.Schedule_Type__c && 
                                quote.SBQQ__Account__c == ent.Location__c)
                        {
                            slaDateTime = caseIdCaseMap.get(quote.SBQQ__Opportunity2__r.Case__c).SLA_Service_Date_Time__c;
                            break;                        
                        }
                        //Container Match for Location
                        /*else if(quoteIdQuoteLineMap.containsKey(quote.Id) &&
                                quoteIdQuoteLineMap.get(quote.Id).SBQQ__ProductName__c == ent.Container__c && 
                                quote.SBQQ__Account__c == ent.Location__c)
                        {
                            slaDateTime = caseIdCaseMap.get(quote.SBQQ__Opportunity2__r.Case__c).SLA_Service_Date_Time__c;
                            break;    
                        }*/
                        //Entitlement for Location
                        /*else if(quote.SBQQ__Account__c == ent.Location__c){
                            slaDateTime = caseIdCaseMap.get(quote.SBQQ__Opportunity2__r.Case__c).SLA_Service_Date_Time__c;
                            break;
                        }*/
                        //Duration and Container Match for Account
                        else if(quoteIdQuoteLineMap.containsKey(quote.Id) && 
                                statusApiToLabelMap.get(quoteIdQuoteLineMap.get(quote.Id).Duration__c) == ent.Schedule_Type__c && 
                                quoteIdQuoteLineMap.get(quote.Id).SBQQ__ProductName__c == ent.Container__c && 
                                quote.SBQQ__Account__r.ParentId == ent.AccountId)
                        {
                            slaDateTime = caseIdCaseMap.get(quote.SBQQ__Opportunity2__r.Case__c).SLA_Service_Date_Time__c;
                            break;
                        }
                        //Duration Match for Location
                        else if(quoteIdQuoteLineMap.containsKey(quote.Id) && 
                                statusApiToLabelMap.get(quoteIdQuoteLineMap.get(quote.Id).Duration__c) == ent.Schedule_Type__c && 
                                quote.SBQQ__Account__r.ParentId == ent.AccountId)
                        {
                            slaDateTime = caseIdCaseMap.get(quote.SBQQ__Opportunity2__r.Case__c).SLA_Service_Date_Time__c;
                            break;
                        }
                        //Entitlement for Location
                        /*else if(quote.SBQQ__Account__r.ParentId == ent.AccountId)
                        {
                            slaDateTime = caseIdCaseMap.get(quote.SBQQ__Opportunity2__r.Case__c).SLA_Service_Date_Time__c;
                            break;
                        }*/
                    }  
                }
                
            }
            if(slaDateTime !=null){
                quoteIdSlaDateMap.put(quote.Id,convertDateTimeToDate(slaDateTime));
            }
        }
        return quoteIdSlaDateMap;
    }
	public static map<id,date> getQuoteIdServiceDateMap1(set<id> quoteIdSet){
        map<id,date> quoteIdSlaDateMap = new map<id,date>();
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        quoteList = [SELECT id, Project__c, SBQQ__Opportunity2__r.Case__c, SBQQ__Account__c, SBQQ__Account__r.ParentId
                     FROM SBQQ__Quote__c 
                     WHERE id IN : quoteIdSet];
        map<id, SBQQ__QuoteLine__c> quoteIdQuoteLineMap = new map<id, SBQQ__QuoteLine__c>();
        map<id,datetime> quoteIdparentQuoteLineCreatedDateMap = new map<id, datetime>();
        
        for(SBQQ__QuoteLine__c qLine : [SELECT id, Name, SBQQ__Quote__c, Duration__c, SBQQ__ProductName__c, CreatedDate  FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c IN : quoteIdSet AND SBQQ__RequiredBy__c=null ORDER BY CREATEDDATE]){
            if(quoteIdparentQuoteLineCreatedDateMap.containsKey(qLine.SBQQ__Quote__c)){
                if(qLine.CreatedDate > quoteIdparentQuoteLineCreatedDateMap.get(qLine.SBQQ__Quote__c)){
                    quoteIdparentQuoteLineCreatedDateMap.put(qLine.SBQQ__Quote__c,qLine.CreatedDate);
                    quoteIdQuoteLineMap.put(qLine.SBQQ__Quote__c, qLine);
                }
            }else{
            	quoteIdparentQuoteLineCreatedDateMap.put(qLine.SBQQ__Quote__c,qLine.CreatedDate);
                quoteIdQuoteLineMap.put(qLine.SBQQ__Quote__c, qLine); 
            }
        }
        
        map<id,SBQQ__Quote__c> caseIdQuoteMap = new map<id,SBQQ__Quote__c>();
        for(SBQQ__Quote__c quote: quoteList){
            caseIdQuoteMap.put(quote.SBQQ__Opportunity2__r.Case__c, quote);
        }
        map<id,set<id>> parentAccountIdCaseIdSetMap = new map<id,set<id>>();
        for(case caseRec : [SELECT id, Client__c FROM case WHERE id IN : caseIdQuoteMap.keySet()]){
            set<id> caseIdSet = new set<id>();
            if(parentAccountIdCaseIdSetMap.containsKey(caseRec.Client__c)){
                caseIdSet.addAll(parentAccountIdCaseIdSetMap.get(caseRec.Client__c));
            }else{
                caseIdSet.add(caseRec.Id);
            }
            parentAccountIdCaseIdSetMap.put(caseRec.Client__c, caseIdSet);
        }
        map<id, case> caseIdCaseEntitlementMap = new map<id, case>([SELECT id, SLA_Service_Date_Time__c, Entitlement.Project__c, 
                                                                    Entitlement.Project_Code__c,
                                                                    Entitlement.Location__c, Entitlement.AccountId,
                                                                    Entitlement.Schedule_Type__c, Entitlement.Container__c
                                                                    FROM Case WHERE id IN: caseIdQuoteMap.keySet()]);
        
        
        for(SBQQ__Quote__c quote: quoteList){
            datetime slaDateTime;
            //Projects for Locations
            if(caseIdCaseEntitlementMap.containsKey(quote.SBQQ__Opportunity2__r.Case__c) && 
               quote.Project__c == caseIdCaseEntitlementMap.get(quote.SBQQ__Opportunity2__r.Case__c).Entitlement.Project_Code__c && 
               quote.SBQQ__Account__c == caseIdCaseEntitlementMap.get(quote.SBQQ__Opportunity2__r.Case__c).Entitlement.Location__c)
            {
                slaDateTime = caseIdCaseEntitlementMap.get(quote.SBQQ__Opportunity2__r.Case__c).SLA_Service_Date_Time__c;
            }
            //Projects for Locations Parent Account
            else if(caseIdCaseEntitlementMap.containsKey(quote.SBQQ__Opportunity2__r.Case__c) && 
                    quote.Project__c == caseIdCaseEntitlementMap.get(quote.SBQQ__Opportunity2__r.Case__c).Entitlement.Project__c && 
                    quote.SBQQ__Account__r.ParentId == caseIdCaseEntitlementMap.get(quote.SBQQ__Opportunity2__r.Case__c).Entitlement.AccountId)
            {
                slaDateTime = caseIdCaseEntitlementMap.get(quote.SBQQ__Opportunity2__r.Case__c).SLA_Service_Date_Time__c;           
            }
            //Duration and Container Match for Location
            else if(quoteIdQuoteLineMap.containsKey(quote.Id) && 
                    caseIdCaseEntitlementMap.containsKey(quote.SBQQ__Opportunity2__r.Case__c) &&
                    quoteIdQuoteLineMap.get(quote.Id).Duration__c == caseIdCaseEntitlementMap.get(quote.SBQQ__Opportunity2__r.Case__c).Entitlement.Schedule_Type__c && 
                    quoteIdQuoteLineMap.get(quote.Id).SBQQ__ProductName__c == caseIdCaseEntitlementMap.get(quote.SBQQ__Opportunity2__r.Case__c).Entitlement.Container__c && 
                    quote.SBQQ__Account__c == caseIdCaseEntitlementMap.get(quote.SBQQ__Opportunity2__r.Case__c).Entitlement.Location__c)
            {
                slaDateTime = caseIdCaseEntitlementMap.get(quote.SBQQ__Opportunity2__r.Case__c).SLA_Service_Date_Time__c;           
            }
            //Duration Match for Location
            else if(quoteIdQuoteLineMap.containsKey(quote.Id) && 
                    caseIdCaseEntitlementMap.containsKey(quote.SBQQ__Opportunity2__r.Case__c) &&
                    quoteIdQuoteLineMap.get(quote.Id).Duration__c == caseIdCaseEntitlementMap.get(quote.SBQQ__Opportunity2__r.Case__c).Entitlement.Schedule_Type__c && 
                    quote.SBQQ__Account__c == caseIdCaseEntitlementMap.get(quote.SBQQ__Opportunity2__r.Case__c).Entitlement.Location__c)
            {
                slaDateTime = caseIdCaseEntitlementMap.get(quote.SBQQ__Opportunity2__r.Case__c).SLA_Service_Date_Time__c;           
            }
            //Container Match for Location
            /*else if(quoteIdQuoteLineMap.containsKey(quote.Id) && 
                    caseIdCaseEntitlementMap.containsKey(quote.SBQQ__Opportunity2__r.Case__c) &&
                    quoteIdQuoteLineMap.get(quote.Id).SBQQ__ProductName__c == caseIdCaseEntitlementMap.get(quote.SBQQ__Opportunity2__r.Case__c).Entitlement.Container__c && 
                    quote.SBQQ__Account__c == caseIdCaseEntitlementMap.get(quote.SBQQ__Opportunity2__r.Case__c).Entitlement.Location__c)
            {
                slaDateTime = caseIdCaseEntitlementMap.get(quote.SBQQ__Opportunity2__r.Case__c).SLA_Service_Date_Time__c;           
            }*/
            //Entitlement for Location
            /*else if(caseIdCaseEntitlementMap.containsKey(quote.SBQQ__Opportunity2__r.Case__c) &&
                    quote.SBQQ__Account__c == caseIdCaseEntitlementMap.get(quote.SBQQ__Opportunity2__r.Case__c).Entitlement.Location__c)
            {
                slaDateTime = caseIdCaseEntitlementMap.get(quote.SBQQ__Opportunity2__r.Case__c).SLA_Service_Date_Time__c;           
            }*/
            //Duration and Container Match for Locations Account
            else if(quoteIdQuoteLineMap.containsKey(quote.Id) && 
                    caseIdCaseEntitlementMap.containsKey(quote.SBQQ__Opportunity2__r.Case__c) &&
                    quoteIdQuoteLineMap.get(quote.Id).Duration__c == caseIdCaseEntitlementMap.get(quote.SBQQ__Opportunity2__r.Case__c).Entitlement.Schedule_Type__c && 
                    quoteIdQuoteLineMap.get(quote.Id).SBQQ__ProductName__c == caseIdCaseEntitlementMap.get(quote.SBQQ__Opportunity2__r.Case__c).Entitlement.Container__c && 
                    quote.SBQQ__Account__r.ParentId == caseIdCaseEntitlementMap.get(quote.SBQQ__Opportunity2__r.Case__c).Entitlement.AccountId)
            {
                slaDateTime = caseIdCaseEntitlementMap.get(quote.SBQQ__Opportunity2__r.Case__c).SLA_Service_Date_Time__c;           
            }
            //Duration Match for Locations Parent Account
            else if(quoteIdQuoteLineMap.containsKey(quote.Id) && 
                    caseIdCaseEntitlementMap.containsKey(quote.SBQQ__Opportunity2__r.Case__c) &&
                    quoteIdQuoteLineMap.get(quote.Id).Duration__c == caseIdCaseEntitlementMap.get(quote.SBQQ__Opportunity2__r.Case__c).Entitlement.Schedule_Type__c && 
                    quote.SBQQ__Account__r.ParentId == caseIdCaseEntitlementMap.get(quote.SBQQ__Opportunity2__r.Case__c).Entitlement.AccountId)
            {
                slaDateTime = caseIdCaseEntitlementMap.get(quote.SBQQ__Opportunity2__r.Case__c).SLA_Service_Date_Time__c;           
            }
            //Entitlement for Locations Parent Account
            /*else if(caseIdCaseEntitlementMap.containsKey(quote.SBQQ__Opportunity2__r.Case__c) &&
                    quote.SBQQ__Account__r.ParentId == caseIdCaseEntitlementMap.get(quote.SBQQ__Opportunity2__r.Case__c).Entitlement.AccountId)
            {
                slaDateTime = caseIdCaseEntitlementMap.get(quote.SBQQ__Opportunity2__r.Case__c).SLA_Service_Date_Time__c;           
            }*/
            if(slaDateTime !=null){
                quoteIdSlaDateMap.put(quote.Id,convertDateTimeToDate(slaDateTime));
            }
        }
        
        return quoteIdSlaDateMap;
    }
    public static date convertDateTimeToDate(DateTime dt){
        return date.newinstance(dT.year(), dT.month(), dT.day());
    }
}