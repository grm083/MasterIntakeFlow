public class CaseEntitlement {
    // public static  Map<String,Id> businessIdMap = new Map<String,Id>();
    public static set<Id> parentAccountIdset = new set<Id>();
    //public  static set<Id> contactIdset = new set<Id>();
    public static set<String> serviceset = new set<String>();
    public static Map<Id,Account> casewithLocation = new Map<Id,Account>();
    public static Map<Id,Asset> casewithContainer = new Map<Id,Asset>();
    
    public static Boolean getCaseEntitlement(Id caseId){
        map<string,case> caseMap = new map<string,case>();
        Set < Id > assetIdSet = new Set < Id >();
        Set < Id > accountIdSet = new Set < Id >();
        boolean criteriamet = false;
        string container = null;
        boolean isBackDatedCase = false;
        string scheduleType = null;
        string casekey = null;
        String query = getObjectFields('case');
        system.debug('query'+query);
        List<Case> newCaseList = database.query('SELECT ' +query + ' From Case where Id =: caseId');
        for(Case thisCase :newCaseList){
           /* if(thisCase.Location__c != null && thisCase.AssetId != null && thisCase.ContactId !=null){
              criteriamet = true;  
            }*/
                  
           if(thisCase.assetId != null)
            {
                assetIdSet.add(thisCase.assetId);
            }
            if(thisCase.Location__c != null)
            {
                accountIdSet.add(thisCase.Location__c);
            }
            
            parentAccountIdset.add(thisCase.Client__c);
            serviceset.add(thisCase.Case_Sub_Type__c);
            system.debug('***thisCase: '+thisCase);
            system.debug('***thisCase Case_Type__c: '+thisCase.Case_Type__c);
            if(String.ISNotBlank(thisCase.Case_Type__c) && thisCase.Case_Type__c.equalsIgnoreCase(CONSTANT_UTIL.NEW_SERVICE)){
                container = thisCase.Equipment_Type_Code__c != Null? thisCase.Equipment_Type_Code__c : Null;
                casekey = thisCase.Client__c + Constant_Util.STAR + thisCase.Location__c + Constant_Util.STAR + container + Constant_Util.STAR + thisCase.Case_Sub_Type__c + Constant_Util.STAR + scheduleType;
            }
            else{
                container = casewithContainer != null && casewithContainer.containsKey(thisCase.AssetId) ? casewithContainer.get(thisCase.AssetId).Product2.ProductTypeSelected__c : null;
                scheduleType = casewithContainer != null && casewithContainer.containsKey(thisCase.AssetId) ? casewithContainer.get(thisCase.AssetId).Duration__c : null;
                casekey = thisCase.Client__c + Constant_Util.STAR + thisCase.Location__c + Constant_Util.STAR + container + Constant_Util.STAR + thisCase.Case_Sub_Type__c + Constant_Util.STAR + scheduleType;
            }
            
            caseMap.put(casekey,thisCase);
        }//for
        String assetQuery = getObjectFields('Asset');
        system.debug('query'+assetQuery);
        List<Asset> newAssetList = [SELECT id,Duration__c,Project_Code__c FROM Asset WHERE Id IN:assetIdSet];
           // database.query('SELECT ' +query + ' From Asset where Id IN: assetIdSet');
        for(Asset eachAsset : newAssetList)
        {
            casewithContainer.put(eachAsset.Id, eachAsset);
        }
        
           // String accountQuery = getObjectFields('Account');
        //system.debug('query'+accountQuery);
        List<Account> newAccountList =[SELECT id,tz__Timezone_SFDC__c FROM Account WHERE Id IN:accountIdSet];
        
            //database.query('SELECT ' +query + ' From Account where Id IN: accountIdSet');
        for(Account eachAcc : newAccountList)
        {
            casewithLocation.put(eachAcc.Id, eachAcc);
        }
        system.debug('************caseMap: '+caseMap);
        system.debug('************casewithContainer: '+casewithContainer);        
        system.debug('************casewithLocation: '+casewithLocation);
        map<string,Entitlement> caseEntitlementMapFial =fetchSLA(caseMap);
        system.debug('************caseEntitlementMapFinal: '+caseEntitlementMapFial);
        for(string eachKey : caseEntitlementMapFial.keyset())
        {
            if(caseEntitlementMapFial.get(eachKey) != null)
            {
                return (caseEntitlementMapFial.get(eachKey).Gold_Standard__c);
            }
        }
        return false;
    }
  public static map<string,Entitlement> fetchSLA(map<string,case> caseMap){
        string entitlementKey = null;
        map<string,Entitlement> caseEntitlementMap = new map<string,Entitlement>();
        map<String,List<Entitlement>> entitlementmap = new map<String,List<Entitlement>>();
        List<Entitlement> entlst = null;
      List < Entitlement > entitlementList = New List < Entitlement >();
      entitlementList = [Select id,Gold_Standard__c,AccountId,Call_On__c,AssetId,Project_Code__c,Before_After__c,
                         Call_Time__c,Container__c,Service_Guarantee_Category__c,Service_Guarantee_Category_Value__c,
                         Location__c,Service__c,Schedule_Type__c,Status__c,StartDate,EndDate,SLA_Ins__c 
                         from Entitlement 
                         where AccountId IN :parentAccountIdset 
                         		and Status__c =: Constant_Util.APPROVED 
                         		and service__c IN :serviceset LIMIT 49999];
      system.debug('***entitlementList: '+entitlementList);
      system.debug('***entitlementList size: '+entitlementList.size());
        for(Entitlement e :entitlementList){ 
            entitlementKey = e.AccountId + Constant_Util.STAR + e.Service__c;
            if(entitlementmap.isEmpty() || !entitlementmap.containskey(entitlementKey)){
                entlst = new List<Entitlement>();
                entitlementmap.put(entitlementKey,entlst);
            }
            If(!entitlementmap.isEmpty() && entitlementmap.containskey(entitlementKey)){
                entitlementmap.get(entitlementKey).add(e);
            }
        }
        
        entitlementKey = null;
        List<String> entitlelst = new List<String>();
        Entitlement actualent = null;
        Map<String,String> keylst;
        Map<String,Entitlement> enlst;
        for(String caseKey : caseMap.keySet()){
            entitlelst = caseKey.split(Constant_Util.STAR);
            keylst = new Map<String,String>();
            enlst = new Map<String,Entitlement>();
            actualent = new Entitlement();
            if(!entitlementmap.IsEmpty() && entitlementmap.containskey(entitlelst[0] + Constant_Util.STAR + entitlelst[3])){
                for(Entitlement en : entitlementmap.get(entitlelst[0] + Constant_Util.STAR + entitlelst[3])){
                    if(string.isNotBlank(en.AssetId)){
                        system.debug('1stkeylst.containskey(Constant_Util.ASSET) '+keylst.containskey(Constant_Util.ASSET));
                        system.debug('1st if: en.AssetId'+en.AssetId);
                        system.debug('1st if: caseMap.get(caseKey).AssetId: '+caseMap.get(caseKey).AssetId);
                        system.debug('1st if: entitlelst[1]'+entitlelst[1]);
                        system.debug('1st if: en.Location__c'+en.Location__c);
                        
                        
                        if(!keylst.containskey(Constant_Util.ASSET)&& caseMap.get(caseKey).AssetId != null && (en.AssetId).equals(caseMap.get(caseKey).AssetId)
                           && ((String.isNotBlank(entitlelst[1]) && (entitlelst[1]).equals(en.Location__c)))){
                               actualent = getactualSLA(en,caseMap.get(casekey));
                               if(actualent != null) {
                                   keylst.put(Constant_Util.ASSET,casekey);
                                   enlst.put(caseKey + Constant_Util.ASSET,en);
                               }
                           }
                    }
                    else{
                        system.debug('1st else: entitlement doesnt have assetId');
                        if(!keylst.containskey(Constant_Util.PROJECT_LOCATION)&& caseMap.get(caseKey).AssetId != null && (!string.isBlank(en.Project_Code__c) && !string.isBlank(casewithContainer.get(caseMap.get(caseKey).AssetId).Project_Code__c))
                           && (en.Project_Code__c).equals(casewithContainer.get(caseMap.get(caseKey).AssetId).Project_Code__c) && (!string.IsBlank(entitlelst[1]) && (entitlelst[1]).equals(en.Location__c))){
                                system.debug('1st else 1st if: entitlement has PROJECT_LOCATION');
                               actualent = getactualSLA(en,caseMap.get(casekey));
                               if(actualent != null) {
                                   keylst.put(Constant_Util.PROJECT_LOCATION,casekey);
                                   enlst.put(caseKey+Constant_Util.PROJECT_LOCATION,en);
                               }
                           }else if(!keylst.containskey(Constant_Util.FLOW_PROJECT)&& caseMap.get(caseKey).AssetId != null && (!string.isBlank(en.Project_Code__c) && !string.isBlank(casewithContainer.get(caseMap.get(caseKey).AssetId).Project_Code__c))
                                    && (en.Project_Code__c).equals(casewithContainer.get(caseMap.get(caseKey).AssetId).Project_Code__c) && string.IsBlank(en.Location__c)){
                                       system.debug('1st else 1st if else: entitlement has FLOW_PROJECT');
                                        actualent = getactualSLA(en,caseMap.get(casekey));
                                        if(actualent != null) {
                                            keylst.put(Constant_Util.FLOW_PROJECT,casekey);
                                            enlst.put(caseKey+Constant_Util.FLOW_PROJECT,en);
                                        }
                                    }else if(!keylst.containskey(Constant_Util.SCHEDULETYPE_CONTAINER_LOCATION)&& (!string.isBlank(entitlelst[4]) && (entitlelst[4]).equals(en.Schedule_Type__c)) 
                                             && (!String.IsBlank(entitlelst[1]) && (entitlelst[1]).equals(en.Location__c))
                                             && (!String.IsBlank(entitlelst[2]) && (entitlelst[2]).equals(en.Container__c)) ){
                                                system.debug('1st else 1st if else: entitlement has SCHEDULETYPE_CONTAINER_LOCATION');
                                                 actualent = getactualSLA(en,caseMap.get(casekey));
                                                 if(actualent != null) {
                                                     keylst.put(Constant_Util.SCHEDULETYPE_CONTAINER_LOCATION,casekey);
                                                     enlst.put(caseKey+Constant_Util.SCHEDULETYPE_CONTAINER_LOCATION,en);
                                                 }
                                             }else if(!keylst.containskey(Constant_Util.SCHEDULETYPE_LOCATION)&& (!string.isBlank(entitlelst[4]) && (entitlelst[4]).equals(en.Schedule_Type__c)) 
                                                      && (!String.IsBlank(entitlelst[1]) && (entitlelst[1]).equals(en.Location__c)) 
                                                      && String.IsBlank(en.Container__c)){
                                                          system.debug('1st else 1st if else: entitlement has SCHEDULETYPE_LOCATION');
                                                          actualent = getactualSLA(en,caseMap.get(casekey));
                                                          if(actualent != null) {
                                                              keylst.put(Constant_Util.SCHEDULETYPE_LOCATION,casekey);
                                                              enlst.put(caseKey+Constant_Util.SCHEDULETYPE_LOCATION,en);
                                                          }
                                                      }else if(!keylst.containskey(Constant_Util.CONTAINER_LOCATION)&& (!string.IsBlank(entitlelst[2]) && (entitlelst[2]).equals(en.Container__c)) 
                                                               && (!string.IsBlank(entitlelst[1]) && (entitlelst[1]).equals(en.Location__c)) && String.IsBlank(en.Schedule_Type__c)){
                                                                   system.debug('1st else 1st if else: entitlement has CONTAINER_LOCATION');
                                                                   actualent = getactualSLA(en,caseMap.get(casekey));
                                                                   if(actualent != null) {
                                                                       keylst.put(Constant_Util.CONTAINER_LOCATION,casekey);
                                                                       enlst.put(caseKey+ Constant_Util.CONTAINER_LOCATION,en);
                                                                   }
                                                               }else if(!keylst.containskey(Constant_Util.LOCATION)&&(!string.IsBlank(entitlelst[1]) && (entitlelst[1]).equals(en.Location__c)) 
                                                                        && string.IsBlank(en.Container__c) && String.IsBlank(en.Schedule_Type__c)){
                                                                            system.debug('1st else 1st if else: entitlement has LOCATION');
                                                                            actualent = getactualSLA(en,caseMap.get(casekey));
                                                                            if(actualent != null) {
                                                                                keylst.put(Constant_Util.LOCATION,casekey);
                                                                                enlst.put(caseKey+Constant_Util.LOCATION,en);
                                                                            }
                                                                        }else if(!keylst.containskey(Constant_Util.SCHEDULETYPE_CONTAINER)&& (!string.isBlank(entitlelst[4]) && (entitlelst[4]).equals(en.Schedule_Type__c)) 
                                                                                 && String.IsBlank(en.Location__c) && (!String.IsBlank(entitlelst[2]) && (entitlelst[2]).equals(en.Container__c)) ){
                                                                                     system.debug('172: 1st else 1st if else: entitlement has SCHEDULETYPE_CONTAINER');
                                                                                     actualent = getactualSLA(en,caseMap.get(casekey));
                                                                                     if(actualent != null) {
                                                                                         keylst.put(Constant_Util.SCHEDULETYPE_CONTAINER,casekey);
                                                                                         enlst.put(caseKey+Constant_Util.SCHEDULETYPE_CONTAINER,en);
                                                                                     }
                                                                                 }else if(!keylst.containskey(Constant_Util.SCHEDULETYPE)&& (!string.isBlank(entitlelst[4]) && (entitlelst[4]).equals(en.Schedule_Type__c)) 
                                                                                          && string.IsBlank(en.Location__c)&& String.IsBlank(en.Container__c)){
                                                                                              system.debug('180: 1st else 1st if else: entitlement has SCHEDULETYPE');
                                                                                              actualent = getactualSLA(en,caseMap.get(casekey));
                                                                                              if(actualent != null) {
                                                                                                  keylst.put(Constant_Util.SCHEDULETYPE,casekey);
                                                                                                  enlst.put(caseKey+Constant_Util.SCHEDULETYPE,en);
                                                                                              }
                                                                                          }else if(!keylst.containskey(Constant_Util.CONTAINER)&& (!string.IsBlank(entitlelst[2]) && (entitlelst[2]).equals(en.Container__c)) 
                                                                                                   && string.Isblank(en.Location__c) && String.IsBlank(en.Schedule_Type__c)){
                                                                                                       system.debug('188: 1st else 1st if else: entitlement has CONTAINER');
                                                                                                       actualent = getactualSLA(en,caseMap.get(casekey));
                                                                                                       if(actualent != null) {
                                                                                                           keylst.put(Constant_Util.CONTAINER,casekey);
                                                                                                           enlst.put(caseKey+ Constant_Util.CONTAINER,en);
                                                                                                       }
                                                                                                   }else if(!keylst.containskey(Constant_Util.ACCOUNT) && (String.IsBlank(en.Schedule_Type__c) || (!String.IsBlank(en.Schedule_Type__c) && (en.Schedule_Type__c).equals(entitlelst[4]))) 
                                                                                                            && (String.IsBlank(en.Container__c) || (!String.IsBlank(en.Container__c) && (en.Container__c).equals(entitlelst[2])))
                                                                                                            && (en.Location__c == null || (!string.IsBlank(entitlelst[1]) && (entitlelst[1]).equals(en.Location__c))) ){
                                                                                                               system.debug('196: 1st else 1st if else: entitlement has ACCOUNT');
                                                                                                                system.debug('entered account and service++++');
                                                                                                                actualent = getactualSLA(en,caseMap.get(casekey));
                                                                                                                system.debug('actualent++++'+actualent);
                                                                                                                if(actualent != null) {
                                                                                                                    keylst.put(Constant_Util.ACCOUNT,casekey); 
                                                                                                                    enlst.put(caseKey+Constant_Util.ACCOUNT,en);
                                                                                                                }
                                                                                                            }
                        else{
                            //novacop fix
                           system.debug('*************NOthing matched************');
                        }
                    }
                }
            }
            system.debug('211: keylst***'+keylst);
            if(keylst!=null && enlst!=null){
                String c = null;
                String Key =null;
                if(keylst.containskey(Constant_Util.ASSET)){
                    c = keylst.get(Constant_Util.ASSET);
                    key = c+Constant_Util.ASSET;
                    caseEntitlementMap.put(c,enlst.get(key));
                    continue;
                }
                if(keylst.containskey(Constant_Util.PROJECT_LOCATION)){
                    c = keylst.get(Constant_Util.PROJECT_LOCATION);
                    key = c+Constant_Util.PROJECT_LOCATION;
                    caseEntitlementMap.put(c,enlst.get(key));
                    continue;
                }
                if(keylst.containskey(Constant_Util.FLOW_PROJECT)){
                    c = keylst.get(Constant_Util.FLOW_PROJECT);
                    key = c+Constant_Util.FLOW_PROJECT;
                    caseEntitlementMap.put(c,enlst.get(key));
                    continue;
                }
                if(keylst.containskey(Constant_Util.SCHEDULETYPE_CONTAINER_LOCATION)){
                    c = keylst.get(Constant_Util.SCHEDULETYPE_CONTAINER_LOCATION);
                    key = c+Constant_Util.SCHEDULETYPE_CONTAINER_LOCATION;
                    caseEntitlementMap.put(c,enlst.get(key));
                    continue;
                }
                if(keylst.containskey(Constant_Util.SCHEDULETYPE_LOCATION)){
                    c = keylst.get(Constant_Util.SCHEDULETYPE_LOCATION);
                    key = c+Constant_Util.SCHEDULETYPE_LOCATION;
                    caseEntitlementMap.put(c,enlst.get(key));
                    continue;
                }
                if(keylst.containskey(Constant_Util.CONTAINER_LOCATION)){
                    c = keylst.get(Constant_Util.CONTAINER_LOCATION);
                    key = c+Constant_Util.CONTAINER_LOCATION;
                    caseEntitlementMap.put(c,enlst.get(key));
                    continue;
                }
                if(keylst.containskey(Constant_Util.LOCATION)){
                    c = keylst.get(Constant_Util.LOCATION);
                    key = c+Constant_Util.LOCATION;
                    caseEntitlementMap.put(c,enlst.get(key));
                    continue;
                }
                if(keylst.containskey(Constant_Util.SCHEDULETYPE_CONTAINER)){
                    c = keylst.get(Constant_Util.SCHEDULETYPE_CONTAINER);
                    key = c+Constant_Util.SCHEDULETYPE_CONTAINER;
                    caseEntitlementMap.put(c,enlst.get(key));
                    continue;
                }
                if(keylst.containskey(Constant_Util.SCHEDULETYPE)){
                    c = keylst.get(Constant_Util.SCHEDULETYPE);
                    key = c+Constant_Util.SCHEDULETYPE;
                    caseEntitlementMap.put(c,enlst.get(key));
                    continue;
                }
                if(keylst.containskey(Constant_Util.CONTAINER)){
                    c = keylst.get(Constant_Util.CONTAINER);
                    key = c+Constant_Util.CONTAINER;
                    caseEntitlementMap.put(c,enlst.get(key));
                    continue;
                }
                if(keylst.containskey(Constant_Util.ACCOUNT)){
                    c = keylst.get(Constant_Util.ACCOUNT);
                    key = c+Constant_Util.ACCOUNT;
                    actualent = getactualSLA(enlst.get(key),caseMap.get(c));
                    caseEntitlementMap.put(c,enlst.get(key));
                    continue;
                }
            }
        }
        return caseEntitlementMap;
    }   
    public static string getObjectFields(String objectName){
        List<string> fields = new List<String>(); 
        Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map <String, Schema.SObjectField> fieldMap = schemaMap.get(objectName).getDescribe().fields.getMap();
        for(Schema.SObjectField sfield : fieldMap.Values()){
            schema.describefieldresult dfield = sfield.getDescribe();
            fields.add(dfield.getname());
        }
        return string.join(fields, ',');
    }
     private static Entitlement getactualSLA(Entitlement et, Case ca){
        Entitlement e = null;
        Integer ct = 0;
        Integer callmin = 0;
        Integer difference = 0;
        Time callTime = Time.newInstance(0, 0, 0, 0);
        if(ca !=null && String.IsNotBlank(et.Call_On__c)  && et.Call_On__c.contains(ca.SlaStartDate.format(Constant_Util.DAY_FORMAT)) && et.StartDate <= ca.SlaStartDate 
           && (et.EndDate == null || et.EndDate >= ca.SlaStartDate)){
               If(et.Call_Time__c!= null){
                   callmin = Integer.valueOf((et.Call_Time__c).split(Constant_Util.COLON)[1]);
                   ct = Integer.valueOf((et.Call_Time__c).split(Constant_Util.COLON)[0]);
                   if(callmin > 0){
                       ct += 1;
                   }
                   
                   callTime = Time.newInstance(ct, 0, 0, 0);
                   Integer callhour = callTime.hour();
                   if(callhour == 0){
                       callhour += 24;
                   }
                   difference  = (ca.SlaStartDate).hourGmt() - callhour;
                   integer mins = (ca.SlaStartDate).minuteGmt();
                   if( (difference > 0 || (difference == 0 && mins > 0)) && (Constant_Util.AFTER).equals(et.Before_After__c)){
                       e = et;
                   }else if(difference < 0 && (Constant_Util.BEFORE).equals(et.Before_After__c)){
                       e = et;
                   }
               } else {
                   e = et;
               }
           }
        return e;
    }
}