public with sharing class ReqInfoServiceApprovers {
    private static boolean isAutoApproved;		
    private static boolean ruleMatched;
    public static Map<Id,Asset> casewithContainer = new Map<Id,Asset>();
    public static Map<Id,Account> casewithLocation = new Map<Id,Account>();
    private static Flow.Interview.Business_Rule_with_Accounts brFlow {get; set;}
    private static Flow.Interview.Business_Rule_Selection bruleFlow {get; set;}
    public static Map<String,Case> caseMap = new Map <String,Case>();
   
    @InvocableMethod(label='Get Red Notes' description='Returns the list of RecordTypeId')
    public static List<string> getInfo(List<Case> caselist) {  
        List<String> recordTypeIdlst = new List<String>();
        string redNotes = Constant_Util.EMPTY_STRING;
        string approvers = getServiceApprovers(caselist);
        if(!String.isBlank(approvers)){
                redNotes = Constant_Util.APPROVERS + Constant_Util.NEW_LINE + approvers + Constant_Util.NEW_LINE;
        }
        string reqInfo = getReqInfo(caselist);
        if(!String.Isblank(reqInfo)){
            if(!String.isBlank(redNotes)){
                redNotes += Constant_Util.NEW_LINE;
            }
            redNotes += Constant_Util.REQUIREDINFORMATION + Constant_Util.NEW_LINE;
            if(reqInfo.contains(Constant_Util.PO_MSG)){
                redNotes += Constant_Util.PO_NUMBER+ Constant_Util.NEW_LINE;
            }
            //commenting as part of 33312
            /*if(reqInfo.contains(Constant_Util.PROFILE_MSG)){
                redNotes += Constant_Util.PROFILE_NUMBER+ Constant_Util.NEW_LINE;
            }*/
            if(reqInfo.contains(Constant_Util.PSI_REQUIRED)){
                redNotes += Constant_Util.PSI + Constant_Util.NEW_LINE;
            }
        }
        string channelReq = channelRequirement(caselist);
		string splIns = specialInstruction(caselist);
		if(!String.Isblank(channelReq) || !String.Isblank(splIns)) {
            if(!String.isBlank(redNotes)){
                redNotes += Constant_Util.NEW_LINE;
            }
			redNotes += Constant_Util.BUSINESSNOTIFICATION + Constant_Util.NEW_LINE;
			if(!String.Isblank(channelReq)){
				redNotes += channelReq + Constant_Util.NEW_LINE;
			}
			if(!String.Isblank(splIns)){
				redNotes += Constant_Util.SPECIAL_INSTRUCTIONS + splIns + Constant_Util.NEW_LINE;
			}
		}
        /*string bNotification = null;
        if(!String.Isblank(channelReq)) {
            if(!String.isBlank(redNotes)){
                redNotes += Constant_Util.NEW_LINE;
            }
            bNotification = Constant_Util.BUSINESSNOTIFICATION + Constant_Util.NEW_LINE + Constant_Util.CHANNEL_REQUIREMENTS + channelReq + Constant_Util.NEW_LINE;
        }
        string splIns = specialInstruction(caselist);
        if(String.Isblank(channelReq) && !String.Isblank(splIns)){
            if(!String.isBlank(redNotes)){
                redNotes += Constant_Util.NEW_LINE;
            }
            bNotification = Constant_Util.BUSINESSNOTIFICATION + Constant_Util.NEW_LINE +  Constant_Util.SPECIAL_INSTRUCTIONS + splIns + Constant_Util.NEW_LINE;
        }else if(!String.Isblank(splIns)){
        	bNotification = bNotification + Constant_Util.SPECIAL_INSTRUCTIONS + splIns + Constant_Util.NEW_LINE;
        }
        if(!String.IsBlank(bNotification)){
            redNotes = redNotes + bNotification;
        }*/
        String slaIns = slaInstruction(caselist);
        If(!String.IsBlank(slaIns) && !String.isEmpty(slaIns)){
            if(!String.isBlank(redNotes)){
                redNotes += Constant_Util.NEW_LINE;
            }
             redNotes = redNotes + Constant_Util.SLA_INSTRUCTION  + Constant_Util.NEW_LINE +slaIns;
        }
        recordTypeIdlst.add(rednotes);
        return recordTypeIdlst;    
    }
    
    Public static String channelRequirement(List<Case> myCases){
        String chanReq = '';
        Business_Rule__c channelReq = getbrule(myCases[0], Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.BUSINESS_NOTIFICATION).getRecordTypeId(),true,false);
        If(channelReq != null && string.isNotBlank(channelReq.Channel_Req__c) && string.isNotBlank(channelReq.Channel__c)){
            chanReq = Constant_Util.CHANNEL + channelReq.Channel__c + Constant_Util.NEW_LINE;
			chanReq += Constant_Util.CHANNEL_REQUIREMENTS + channelReq.Channel_Req__c;
        } 
        Return chanReq;
    }
    
    Public static String specialInstruction(List<Case> myCases){
        String specIns = '';
        Business_Rule__c specialIns = getbrule(myCases[0], Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.BUSINESS_NOTIFICATION).getRecordTypeId(),false,true);
        If(specialIns != null && string.isNotBlank(specialIns.Special_Ins__c)){
            specIns = specialIns.Special_Ins__c;
        }
        Return specIns;
    }
    
    Public static String slaInstruction(List<Case> myCases){
        String slaIns = '';
        Map<String,Case> caseMap = new Map<String,Case>();
        String Key = String.valueof(myCases[0].Client__c) + Constant_Util.STAR + String.valueof(myCases[0].Location__c) + Constant_Util.STAR + (casewithContainer!= null && casewithContainer.containsKey(myCases[0].AssetId)? string.valueof(casewithContainer.get(myCases[0].AssetId).Product2.ProductTypeSelected__c): ' ') + Constant_Util.STAR + string.valueof(myCases[0].Case_Sub_type__c) + Constant_Util.STAR + (casewithContainer!= null && casewithContainer.containsKey(myCases[0].AssetId) ? string.valueof(casewithContainer.get(myCases[0].AssetId).Duration__c): ' '); 
        myCases[0].SlaStartDate = myCases[0].SlaStartDate != null ? myCases[0].SlaStartDate : system.now();
        caseMap.put(Key,myCases[0]);
        Map<string,Entitlement> caseEntitlementMap = fetchSLA(caseMap,String.valueof(myCases[0].Client__c),String.valueof(myCases[0].Case_Sub_type__c));
        If(caseEntitlementMap != null && !caseEntitlementMap.isEmpty()&& caseEntitlementMap.containskey(key) && caseEntitlementMap.get(key).SLA_Ins__c!=null && String.isNotBlank(caseEntitlementMap.get(key).SLA_Ins__c)){
            slaIns = caseEntitlementMap.get(key).SLA_Ins__c; 
        }
        return slaIns;
    } 
    
    /* Modified to pass the values of Asset and Project of Asset in Case to Business Rule Selection Flow */
    Public static Business_Rule__c getbrule(Case c,Id recordTypeId, boolean ChannelRequirements, boolean SpecialInstructions){
        Business_Rule__c brule = new Business_Rule__c();
        map<String, Object> flowInputMap = new map<String, Object>();
        flowInputMap.put(Constant_Util.FLOW_ACCOUNTID , c.Client__c);
        flowInputMap.put(Constant_Util.FLOW_CONTAINER , casewithContainer!=null && casewithContainer.containsKey(c.AssetId) ? casewithContainer.get(c.AssetId).Product2.ProductTypeSelected__c : null);
        flowInputMap.put(Constant_Util.FLOW_LOCATIONID , c.Location__c);
        flowInputMap.put(Constant_Util.FLOW_SERVICE , c.Case_Sub_Type__c);
        flowInputMap.put(Constant_Util.FLOW_SCHEDULETYPE , casewithContainer!=null && casewithContainer.containsKey(c.AssetId) ? casewithContainer.get(c.AssetId).Duration__c : null);
        flowInputMap.put(Constant_Util.FLOW_RECORDTYPEID , recordTypeId);
        flowInputMap.put(Constant_Util.FLOW_ASSETID , c.AssetId);
        flowInputMap.put(Constant_Util.FLOW_CASETYPE , c.Case_Type__c);
        flowInputMap.put(Constant_Util.FLOW_PROJECT , casewithContainer!=null && casewithContainer.containsKey(c.AssetId) &&  casewithContainer.get(c.AssetId).Project_Code__c != null && casewithContainer.get(c.AssetId).Active__c ? casewithContainer.get(c.AssetId).Project_Code__c : null);
        flowInputMap.put(Constant_Util.FLOW_CHANNELREQ , ChannelRequirements);
        flowInputMap.put(Constant_Util.FLOW_SPECIALINS , SpecialInstructions);
        flowInputMap.put(Constant_Util.FLOW_BRAND , casewithLocation!=null && casewithLocation.containsKey(c.Location__c) ? casewithLocation.get(c.Location__c).Brand__c : null);
        flowInputMap.put(Constant_Util.FLOW_DIVISION , casewithLocation!=null && casewithLocation.containsKey(c.Location__c) ? casewithLocation.get(c.Location__c).Division__c : null);
        flowInputMap.put(Constant_Util.FLOW_GEOGRAPHY , casewithLocation!=null && casewithLocation.containsKey(c.Location__c) ? casewithLocation.get(c.Location__c).Geography__c : null);
        flowInputMap.put(Constant_Util.FLOW_LOCATIONTYPE , casewithLocation!=null && casewithLocation.containsKey(c.Location__c) ? casewithLocation.get(c.Location__c).Location_Type__c : null);
        brFlow = new Flow.Interview.Business_Rule_with_Accounts(flowInputMap);
        brFlow.Start();
        brule = (Business_Rule__c)(brFlow.getVariableValue(Constant_Util.FLOW_BUSINESSRULEREC));
        return brule;
    }
    /* Modified to pass the values of Asset and Project of Asset in Case to Business Rule Selection Flow */
    Public static Business_Rule__c getbusinessRule(Case c,Id recordTypeId, boolean ChannelRequirements, boolean SpecialInstructions){
        Business_Rule__c brule = new Business_Rule__c();
        map<String, Object> flowInputMap = new map<String, Object>();
        flowInputMap.put(Constant_Util.FLOW_ACCOUNTID , c.Client__c);
        flowInputMap.put(Constant_Util.FLOW_CONTAINER , casewithContainer!=null && casewithContainer.containsKey(c.AssetId) ? casewithContainer.get(c.AssetId).Product2.ProductTypeSelected__c : null);
        flowInputMap.put(Constant_Util.FLOW_LOCATIONID , c.Location__c);
        flowInputMap.put(Constant_Util.FLOW_SERVICE , c.Case_Sub_Type__c);        
        flowInputMap.put(Constant_Util.FLOW_CASETYPE , c.Case_Type__c);
        flowInputMap.put(Constant_Util.FLOW_SCHEDULETYPE , casewithContainer!=null && casewithContainer.containsKey(c.AssetId) ? casewithContainer.get(c.AssetId).Duration__c : null);
        flowInputMap.put(Constant_Util.FLOW_RECORDTYPEID , recordTypeId);
        flowInputMap.put(Constant_Util.FLOW_ASSETID , c.AssetId);
        flowInputMap.put(Constant_Util.FLOW_PROJECT , casewithContainer!=null && casewithContainer.containsKey(c.AssetId) &&  casewithContainer.get(c.AssetId).Project_Code__c != null && casewithContainer.get(c.AssetId).Active__c ? casewithContainer.get(c.AssetId).Project_Code__c : null);
        flowInputMap.put(Constant_Util.FLOW_CHANNELREQ , ChannelRequirements);
        flowInputMap.put(Constant_Util.FLOW_SPECIALINS , SpecialInstructions);
        flowInputMap.put(Constant_Util.FLOW_BRAND , casewithLocation!=null && casewithLocation.containsKey(c.Location__c) ? casewithLocation.get(c.Location__c).Brand__c : null);
        flowInputMap.put(Constant_Util.FLOW_DIVISION , casewithLocation!=null && casewithLocation.containsKey(c.Location__c) ? casewithLocation.get(c.Location__c).Division__c : null);
        flowInputMap.put(Constant_Util.FLOW_GEOGRAPHY , casewithLocation!=null && casewithLocation.containsKey(c.Location__c) ? casewithLocation.get(c.Location__c).Geography__c : null);
        flowInputMap.put(Constant_Util.FLOW_LOCATIONTYPE , casewithLocation!=null && casewithLocation.containsKey(c.Location__c) ? casewithLocation.get(c.Location__c).Location_Type__c : null);
        bruleFlow = new Flow.Interview.Business_Rule_Selection(flowInputMap);
        bruleFlow.Start();
        brule = (Business_Rule__c)(bruleFlow.getVariableValue(Constant_Util.FLOW_BUSINESSRULEREC));
        return brule;
    }
    
    /* Fetch reqInfo. for respective case*/
    public static string getReqInfo(List<Case> myCases){
        string reqInfo = null;
        if(myCases!= null && myCases.size()>0){
            Id reqInfoRecTypeId = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.REQUIRED_INFORMATION).getRecordTypeId();
            Business_Rule__c caseRule = getbusinessRule(myCases[0],reqInfoRecTypeId,false,false);
            reqInfo = Constant_Util.EMPTY_STRING;
            if(caseRule !=null && caseRule.Required_Information__c.contains(Constant_Util.PO_NUMBER)){// && String.isBlank(myCases[0].PurchaseOrder_Number__c) && !(myCases[0].Override_PO_Create_Task__c)){
                reqInfo += Constant_Util.PO_MSG + Constant_Util.NEW_LINE;            
            }
            //commenting as part of 33312
            /*if(caseRule !=null && caseRule.Required_Information__c.contains(Constant_Util.PROFILE_NUMBER)){//&& String.isBlank(myCases[0].Profile_Number__c) && !(myCases[0].Override_Profile_Number_Task__c)){
                reqInfo += Constant_Util.PROFILE_MSG + Constant_Util.NEW_LINE;            
            }*/
            if(caseRule !=null && caseRule.Required_Information__c.contains(Constant_Util.PSI)){// && myCases[0].PSI__c == null){
                reqInfo += Constant_Util.PSI_REQUIRED + Constant_Util.NEW_LINE;
            }
        }
        return reqInfo;
    }
    
    /*Fetch Servie Approvers*/
    public static string getServiceApprovers(List<Case> myCases){
        string approverInfo = null;
        if(myCases!= null && myCases.size()>0){
            Id approvalRecTypeId = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.APPROVAL).getRecordTypeId();
            for(Asset a : [SELECT Id,Product2.ProductTypeSelected__c,Duration__c,Project_Code__c,Active__c,End_Date_Based_on_Project_code__c
                           FROM Asset WHERE Id =: myCases[0].AssetId LIMIT 49999]){
                               casewithContainer.put(a.Id,a);
            }
            for(Account loc: [SELECT Id,Brand__c,Geography__c,Division__c,Location_Type__c 
                              FROM Account WHERE Id =: myCases[0].Location__c LIMIT 49999]){
                                  casewithLocation.put(loc.Id,Loc);
             }
            Business_Rule__c thisBusinessRule = getbusinessRule(myCases[0],approvalRecTypeId,false,false);
            approverInfo = Constant_Util.EMPTY_STRING;
            if(thisBusinessRule != null){
                List<Service_Approver__c> serviceapproverlst = [Select id,Account_Team_Member__c,Approver_Type__c,Approver_Contact__c,Title__c,Account_Department__c,Title__r.Name,Approver_Contact__r.FirstName,Approver_Contact__r.LastName,
                                                                Account_Team_Member__r.FirstName,Account_Team_Member__r.LastName,Email__c,User__c,User__r.FirstName,User__r.LastName from Service_Approver__c where Business_Rule__c =: thisBusinessRule.Id and Active__c = true LIMIT 49999];
                Boolean flag = false;
                string approver =Constant_Util.EMPTY_STRING;
                if(thisBusinessRule.Multiple_Mandatory_Approvers__c && serviceapproverlst!= null){
                    
                    for(Service_Approver__c sap :serviceapproverlst){
                        approver = Constant_Util.EMPTY_STRING;
                        approver = ((sap.Account_Team_Member__c == null )?((sap.Approver_Contact__c == null)? ((sap.Title__c == null) ?((sap.Account_Department__c == null) ? ((sap.Email__c == null)?((sap.User__c == null)? null: sap.User__r.FirstName + Constant_Util.EMPTY_SPACE + sap.User__r.LastName ): sap.Email__c ) : sap.Account_Department__c ) : sap.Title__r.Name ) :sap.Approver_Contact__r.FirstName + Constant_Util.EMPTY_SPACE + sap.Approver_Contact__r.LastName) : sap.Account_Team_Member__r.FirstName + Constant_Util.EMPTY_SPACE + sap.Account_Team_Member__r.LastName);
                        if(!flag){
                            approverInfo += approver +  Constant_Util.EMPTY_SPACE + Constant_Util.HYPHEN + Constant_Util.EMPTY_SPACE + sap.Approver_Type__c ; 
                            flag = true;
                        }
                        else{
                            approverInfo += Constant_Util.EMPTY_SPACE + Constant_Util.CONSTANT_AND + Constant_Util.NEW_LINE + approver + Constant_Util.EMPTY_SPACE + Constant_Util.HYPHEN + Constant_Util.EMPTY_SPACE + sap.Approver_Type__c;
                        }
                    }
                }else if(!thisBusinessRule.Multiple_Mandatory_Approvers__c && serviceapproverlst!= null ){
                    for(Service_Approver__c sap :serviceapproverlst){
                        approver = Constant_Util.EMPTY_STRING;
                        approver = ((sap.Account_Team_Member__c == null )?((sap.Approver_Contact__c == null)? ((sap.Title__c == null) ?((sap.Account_Department__c == null) ? ((sap.Email__c == null)?((sap.User__c == null)? null: sap.User__r.FirstName + Constant_Util.EMPTY_SPACE + sap.User__r.LastName ): sap.Email__c ) : sap.Account_Department__c ) : sap.Title__r.Name ) :sap.Approver_Contact__r.FirstName + Constant_Util.EMPTY_SPACE + sap.Approver_Contact__r.LastName) : sap.Account_Team_Member__r.FirstName + Constant_Util.EMPTY_SPACE + sap.Account_Team_Member__r.LastName);
                        if(!flag){
                            approverInfo += approver + Constant_Util.EMPTY_SPACE + Constant_Util.HYPHEN + Constant_Util.EMPTY_SPACE + sap.Approver_Type__c; 
                            flag = true;
                        }
                        else{
                            approverInfo += Constant_Util.EMPTY_SPACE + Constant_Util.CONSTANT_OR + Constant_Util.NEW_LINE + approver + Constant_Util.EMPTY_SPACE + Constant_Util.HYPHEN + Constant_Util.EMPTY_SPACE + sap.Approver_Type__c;
                        }
                    }
                }
                else{
                    //Nova cop fix
                }
            }
        }
        return approverInfo;
    }
    public static map<string,Entitlement> fetchSLA(map<string,case> caseMap,String accountId,String service){
        string entitlementKey = null;
        map<string,Entitlement> caseEntitlementMap = new map<string,Entitlement>();
        map<String,List<Entitlement>> entitlementmap = new map<String,List<Entitlement>>();
        List<Entitlement> entlst = null;
        for(Entitlement e : [Select id,AccountId,Call_On__c,AssetId,Project_Code__c,Before_After__c,Call_Time__c,Container__c,Service_Guarantee_Category__c,Service_Guarantee_Category_Value__c,Location__c,Service__c,Schedule_Type__c,Status__c,StartDate,EndDate,SLA_Ins__c from Entitlement where AccountId =:accountId and Status__c =: Constant_Util.APPROVED and service__c =: service LIMIT 49999]){ 
        	entitlementKey = String.valueof(e.AccountId) + Constant_Util.STAR + String.valueof(e.Service__c);
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
                        if(!keylst.containskey(Constant_Util.PROJECT_LOCATION)&& caseMap.get(caseKey).AssetId != null && (!string.isBlank(en.Project_Code__c) && !string.isBlank(casewithContainer.get(caseMap.get(caseKey).AssetId).Project_Code__c))
                           && (en.Project_Code__c).equals(casewithContainer.get(caseMap.get(caseKey).AssetId).Project_Code__c) && (!string.IsBlank(entitlelst[1]) && (entitlelst[1]).equals(en.Location__c))){
                               actualent = getactualSLA(en,caseMap.get(casekey));
                               if(actualent != null) {
                                   keylst.put(Constant_Util.PROJECT_LOCATION,casekey);
                                   enlst.put(caseKey+Constant_Util.PROJECT_LOCATION,en);
                               }
                           }else if(!keylst.containskey(Constant_Util.FLOW_PROJECT)&& caseMap.get(caseKey).AssetId != null && (!string.isBlank(en.Project_Code__c) && !string.isBlank(casewithContainer.get(caseMap.get(caseKey).AssetId).Project_Code__c))
                                    && (en.Project_Code__c).equals(casewithContainer.get(caseMap.get(caseKey).AssetId).Project_Code__c) && string.IsBlank(en.Location__c)){
                                        actualent = getactualSLA(en,caseMap.get(casekey));
                                        if(actualent != null) {
                                            keylst.put(Constant_Util.FLOW_PROJECT,casekey);
                                            enlst.put(caseKey+Constant_Util.FLOW_PROJECT,en);
                                        }
                                    }else if(!keylst.containskey(Constant_Util.SCHEDULETYPE_CONTAINER_LOCATION)&& (!string.isBlank(entitlelst[4]) && (entitlelst[4]).equals(en.Schedule_Type__c)) 
                                             && (!String.IsBlank(entitlelst[1]) && (entitlelst[1]).equals(en.Location__c))
                                             && (!String.IsBlank(entitlelst[2]) && (entitlelst[2]).equals(en.Container__c)) ){
                                                 actualent = getactualSLA(en,caseMap.get(casekey));
                                                 if(actualent != null) {
                                                     keylst.put(Constant_Util.SCHEDULETYPE_CONTAINER_LOCATION,casekey);
                                                     enlst.put(caseKey+Constant_Util.SCHEDULETYPE_CONTAINER_LOCATION,en);
                                                 }
                                             }else if(!keylst.containskey(Constant_Util.SCHEDULETYPE_LOCATION)&& (!string.isBlank(entitlelst[4]) && (entitlelst[4]).equals(en.Schedule_Type__c)) 
                                                      && (!String.IsBlank(entitlelst[1]) && (entitlelst[1]).equals(en.Location__c)) 
                                                      && String.IsBlank(en.Container__c)){
                                                          actualent = getactualSLA(en,caseMap.get(casekey));
                                                          if(actualent != null) {
                                                              keylst.put(Constant_Util.SCHEDULETYPE_LOCATION,casekey);
                                                              enlst.put(caseKey+Constant_Util.SCHEDULETYPE_LOCATION,en);
                                                          }
                                                      }else if(!keylst.containskey(Constant_Util.CONTAINER_LOCATION)&& (!string.IsBlank(entitlelst[2]) && (entitlelst[2]).equals(en.Container__c)) 
                                                               && (!string.IsBlank(entitlelst[1]) && (entitlelst[1]).equals(en.Location__c)) && String.IsBlank(en.Schedule_Type__c)){
                                                                   actualent = getactualSLA(en,caseMap.get(casekey));
                                                                   if(actualent != null) {
                                                                       keylst.put(Constant_Util.CONTAINER_LOCATION,casekey);
                                                                       enlst.put(caseKey+ Constant_Util.CONTAINER_LOCATION,en);
                                                                   }
                                                               }else if(!keylst.containskey(Constant_Util.LOCATION)&&(!string.IsBlank(entitlelst[1]) && (entitlelst[1]).equals(en.Location__c)) 
                                                                        && string.IsBlank(en.Container__c) && String.IsBlank(en.Schedule_Type__c)){
                                                                            actualent = getactualSLA(en,caseMap.get(casekey));
                                                                            if(actualent != null) {
                                                                                keylst.put(Constant_Util.LOCATION,casekey);
                                                                                enlst.put(caseKey+Constant_Util.LOCATION,en);
                                                                            }
                                                                        }else if(!keylst.containskey(Constant_Util.SCHEDULETYPE_CONTAINER)&& (!string.isBlank(entitlelst[4]) && (entitlelst[4]).equals(en.Schedule_Type__c)) 
                                                                                 && String.IsBlank(en.Location__c) && (!String.IsBlank(entitlelst[2]) && (entitlelst[2]).equals(en.Container__c)) ){
                                                                                     actualent = getactualSLA(en,caseMap.get(casekey));
                                                                                     if(actualent != null) {
                                                                                         keylst.put(Constant_Util.SCHEDULETYPE_CONTAINER,casekey);
                                                                                         enlst.put(caseKey+Constant_Util.SCHEDULETYPE_CONTAINER,en);
                                                                                     }
                                                                                 }else if(!keylst.containskey(Constant_Util.SCHEDULETYPE)&& (!string.isBlank(entitlelst[4]) && (entitlelst[4]).equals(en.Schedule_Type__c)) 
                                                                                          && string.IsBlank(en.Location__c)&& String.IsBlank(en.Container__c)){
                                                                                              actualent = getactualSLA(en,caseMap.get(casekey));
                                                                                              if(actualent != null) {
                                                                                                  keylst.put(Constant_Util.SCHEDULETYPE,casekey);
                                                                                                  enlst.put(caseKey+Constant_Util.SCHEDULETYPE,en);
                                                                                              }
                                                                                          }else if(!keylst.containskey(Constant_Util.CONTAINER)&& (!string.IsBlank(entitlelst[2]) && (entitlelst[2]).equals(en.Container__c)) 
                                                                                                   && string.Isblank(en.Location__c) && String.IsBlank(en.Schedule_Type__c)){
                                                                                                       actualent = getactualSLA(en,caseMap.get(casekey));
                                                                                                       if(actualent != null) {
                                                                                                           keylst.put(Constant_Util.CONTAINER,casekey);
                                                                                                           enlst.put(caseKey+ Constant_Util.CONTAINER,en);
                                                                                                       }
                                                                                                   }else if(!keylst.containskey(Constant_Util.ACCOUNT) && (String.IsBlank(en.Schedule_Type__c) || (!String.IsBlank(en.Schedule_Type__c) && (en.Schedule_Type__c).equals(entitlelst[4]))) 
                                                                                                            && (String.IsBlank(en.Container__c) || (!String.IsBlank(en.Container__c) && (en.Container__c).equals(entitlelst[2])))
                                                                                                            && (en.Location__c == null || (!string.IsBlank(entitlelst[1]) && (entitlelst[1]).equals(en.Location__c))) ){
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
                        }
                    }
                }
            }
            
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
    
    /*
* This method is used to identify the particular Entitlement based on the field Call_Time__c for the respective case. 
* @owner : Priyadharshini R
* @param : Entitlement,Case
*/
    private static Entitlement getactualSLA(Entitlement et, Case ca){
        Entitlement e = null;
        Integer ct = 0;
        Integer callmin = 0;
        Integer difference = 0;
        Time callTime = Time.newInstance(0, 0, 0, 0);
        if(ca !=null && et!=null && String.IsNotBlank(et.Call_On__c)  && et.Call_On__c.contains(ca.SlaStartDate.format(Constant_Util.DAY_FORMAT)) && et.StartDate <= ca.SlaStartDate 
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