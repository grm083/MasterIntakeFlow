/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 03-02-2023
* @Updated By        : Soham Datta - 21/02/2025 - Added getCaseId()
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class BusinessRuleCtrl {

    //Get CaseId
    @AuraEnabled
    public static String getCaseId(Id recordId) {
        String caseId;
        String sObjectType = recordId.getsobjectType().getDescribe().getName();
        switch on sObjectType {
            when 'Case' {
                caseId = recordId;
            }
            when 'SBQQ__Quote__c' {
            caseId = recordId;
            }
            when else {
                caseId = recordId;
            }
        }        
        return caseId;
    }

    // Used for Out of Office Features
    @AuraEnabled
    public static List<String> getBusinessRulesData(String recordId){
        List<String> brNameList = new List<String>();
        If(String.isNotBlank(recordId)){
            Set<Id> brIds = new Set<Id>();
            List<Out_of_Office__c> oOfficeList = [Select Id,Account__c,Current_User_Approver__c,Current_Email_Approver__c,Current_Contact_Approver__c from Out_of_Office__c where Id =: recordId];
            if(!oOfficeList.isEmpty()){
                for(Business_Rule__c br : [Select Id, Name,AccountId__c from Business_Rule__c where AccountId__c =: oOfficeList[0].Account__c AND Active__c =: true]){
                    brIds.add(br.Id);
                }
                if(!brIds.isEmpty()){
                    List<Service_Approver__c> serviceApproverList = new List<Service_Approver__c>();
                    if(String.isNotBlank(oOfficeList[0].Current_User_Approver__c)){
                        serviceApproverList = [Select Id,Business_Rule__c,Business_Rule__r.Name,Business_Rule__r.Service__c,Business_Rule__r.Request_Type__c,Approver_Contact__c from Service_Approver__c where User__c =:oOfficeList[0].Current_User_Approver__c AND Business_Rule__c IN : brIds AND  Active__c =: true];
                    }else if(String.isNotBlank(oOfficeList[0].Current_Contact_Approver__c)){
                        serviceApproverList = [Select Id,Business_Rule__c,Business_Rule__r.Name,Business_Rule__r.Service__c,Business_Rule__r.Request_Type__c,Approver_Contact__c from Service_Approver__c where Approver_Contact__c =:oOfficeList[0].Current_Contact_Approver__c AND Business_Rule__c IN : brIds AND  Active__c =: true];
                    }else if(String.isNotBlank(oOfficeList[0].Current_Email_Approver__c)){
                        serviceApproverList = [Select Id,Business_Rule__c,Business_Rule__r.Name,Business_Rule__r.Service__c,Business_Rule__r.Request_Type__c,Approver_Contact__c from Service_Approver__c where Approver_Email__c =:oOfficeList[0].Current_Email_Approver__c AND Business_Rule__c IN : brIds AND  Active__c =: true];
                    }
                    Set<String> brNameSet = new Set<String>();
                    for(Service_Approver__c srAppr : serviceApproverList){
                        brNameSet.add(srAppr.Business_Rule__r.Name+'-'+srAppr.Business_Rule__r.Service__c+'-'+srAppr.Business_Rule__r.Request_Type__c);
                    }
                    brNameList.addAll(brNameSet);
                    system.debug('brNameSet : ' + brNameSet);
                    system.debug('brNameList : ' + brNameList);
                }
            }
        }
        
        return brNameList;
    }
    
    @AuraEnabled
    public static String updateOutofOfficeRecord(String recordId, List<String> selectedBusinessRules){
        System.debug('recordId :' + recordId);
        System.debug('selectedBusinessRules :' + selectedBusinessRules);
        String returnMessage;
        //try{
        List<Out_of_Office__c> officeList = new List<Out_of_Office__c>();
        Out_of_Office__c office = new Out_of_Office__c();
        office.Id = recordId;
        if(!selectedBusinessRules.isEmpty()){
            office.Business_Rules__c = String.join(selectedBusinessRules, ',');
        }
        officeList.add(office);
        //try{
        if(!officeList.isEmpty()){
            returnMessage = validateDuplicateRecord(recordId,selectedBusinessRules);
            system.debug('returnMessage :' + returnMessage);
            if(String.isBlank(returnMessage)){
                update officeList;
            }
        }
        /*}catch (DmlException ex) {
//System.DmlException: Update failed. First exception on row 0 with id a1G8A0000020e0HUAQ; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, Duplicate records are found.: []
if ( String.isNotBlank( ex.getMessage() ) && ex.getMessage().contains('Update failed') && ex.getMessage().contains('The rule with the same criteria already exists.')) {
returnMessage = 'Duplicate records are founds.';
} else {
returnMessage = ex.getMessage();
}
}*/
        return returnMessage;
    }
    // Out of Office Features
    
    // OOO Features
    public static Map<String , Set<String>> getBusinessRuleApprovers(Set<Id> businessRuleIds){
        Map<String , Set<String>> busRulesMap = new Map<String , Set<String>>();
        system.debug('businessRuleIds : ' + businessRuleIds);
        if(!businessRuleIds.isEmpty()){
            List<String> brRulesName = new List<String>();
            //List<String> brRulesIds = new List<String>();
            for(Business_Rule__c br : [Select Id,Name from Business_Rule__c where Id IN : businessRuleIds AND  Active__c =: true] ){
                brRulesName.add(br.Name);
                //brRulesIds.add(br.Id);
            }
            //Set<Id> officeIds = new Set<Id>();
            for(Out_of_Office__c oOffice : [Select Id, Business_Rules__c,Current_User_Approver__c,New_User_Approver__c,Current_User_Approver__r.Email,
                                            New_User_Approver__r.Email,Current_Contact_Approver__c, Current_Contact_Approver__r.Email, 
                                            New_Contact_Approver__c,New_Contact_Approver__r.Email,Current_Email_Approver__c,New_Email_Approver__c,
                                            Start_Date__c,End_Date__c from Out_of_Office__c where Account__c!=null AND Start_Date__c <=: System.today() AND End_Date__c >=: System.today()]){
                                                if(String.isNotBlank(oOffice.Business_Rules__c)){
                                                    system.debug('oOffice : ' + oOffice);
                                                    String[] brList = oOffice.Business_Rules__c.split(',');
                                                    //List<String> brRuleNameList = new List<String>();
                                                    for(String str : brList){
                                                        if(String.isNotBlank(str)){
                                                            String brName = str.left(10);
                                                            system.debug('brName : ' + brName);
                                                            system.debug('brRulesName : ' + brRulesName);
                                                            if(brRulesName.contains(brName)){
                                                                system.debug('contain sbrRulesName : ');
                                                                //officeIds.add(oOffice.Id);
                                                                if(oOffice.Current_User_Approver__c!=null && String.isNotBlank(oOffice.Current_User_Approver__r.Email)){
                                                                    Set<String> bList = new Set<String>();
                                                                    if(!busRulesMap.containsKey(oOffice.Current_User_Approver__r.Email)){                                    
                                                                        bList = new Set<String>();
                                                                    } else {
                                                                        bList = busRulesMap.get(oOffice.Current_User_Approver__r.Email);
                                                                    }   
                                                                    if(oOffice.New_User_Approver__c!=null && String.isNotBlank(oOffice.New_User_Approver__r.Email) ){
                                                                        bList.add(oOffice.New_User_Approver__r.Email); 
                                                                    }else if(oOffice.New_Contact_Approver__c!=null && String.isNotBlank(oOffice.New_Contact_Approver__r.Email)){
                                                                        bList.add(oOffice.New_Contact_Approver__r.Email);
                                                                    }else if(oOffice.New_Email_Approver__c!=null && String.isNotBlank(oOffice.New_Email_Approver__c)){
                                                                        bList.add(oOffice.New_Email_Approver__c);
                                                                    }
                                                                    busRulesMap.put(oOffice.Current_User_Approver__r.Email, bList);
                                                                }
                                                                if(oOffice.Current_Contact_Approver__c!=null && String.isNotBlank(oOffice.Current_Contact_Approver__r.Email)){
                                                                    Set<String> bList = new Set<String>();
                                                                    if(!busRulesMap.containsKey(oOffice.Current_Contact_Approver__r.Email)){                                    
                                                                        bList = new Set<String>();
                                                                    } else {
                                                                        bList = busRulesMap.get(oOffice.Current_Contact_Approver__r.Email);
                                                                    }   
                                                                    if(oOffice.New_User_Approver__c!=null && String.isNotBlank(oOffice.New_User_Approver__r.Email) ){
                                                                        bList.add(oOffice.New_User_Approver__r.Email); 
                                                                    }else if(oOffice.New_Contact_Approver__c!=null && String.isNotBlank(oOffice.New_Contact_Approver__r.Email)){
                                                                        bList.add(oOffice.New_Contact_Approver__r.Email);
                                                                    }else if(oOffice.New_Email_Approver__c!=null && String.isNotBlank(oOffice.New_Email_Approver__c)){
                                                                        bList.add(oOffice.New_Email_Approver__c);
                                                                    }
                                                                    busRulesMap.put(oOffice.Current_Contact_Approver__r.Email, bList);
                                                                }
                                                                if(String.isNotBlank(oOffice.Current_Email_Approver__c)){
                                                                    Set<String> bList = new Set<String>();
                                                                    if(!busRulesMap.containsKey(oOffice.Current_Email_Approver__c)){                                    
                                                                        bList = new Set<String>();
                                                                    } else {
                                                                        bList = busRulesMap.get(oOffice.Current_Email_Approver__c);
                                                                    }   
                                                                    if(oOffice.New_User_Approver__c!=null && String.isNotBlank(oOffice.New_User_Approver__r.Email) ){
                                                                        bList.add(oOffice.New_User_Approver__r.Email); 
                                                                    }else if(oOffice.New_Contact_Approver__c!=null && String.isNotBlank(oOffice.New_Contact_Approver__r.Email)){
                                                                        bList.add(oOffice.New_Contact_Approver__r.Email);
                                                                    }else if(oOffice.New_Email_Approver__c!=null && String.isNotBlank(oOffice.New_Email_Approver__c)){
                                                                        bList.add(oOffice.New_Email_Approver__c);
                                                                    }
                                                                    busRulesMap.put(oOffice.Current_Email_Approver__c, bList);
                                                                }
                                                            }
                                                        }
                                                    }
                                                }system.debug('oOffice Id : ' + oOffice.id);
                                            }
        }
        return busRulesMap;
    }
    
    public static List<String> getApproversForEscalations(List<String> approverEmails){
        List<String> approverEmailsList;
        Map<String,Set<String>> busRulesMap = new Map<String,Set<String>>();
        if(!approverEmails.isEmpty()){
            for(Out_of_Office__c oOffice : [Select Id, Business_Rules__c,Current_User_Approver__c,New_User_Approver__c,Current_User_Approver__r.Email,
                                            New_User_Approver__r.Email,Current_Contact_Approver__c, Current_Contact_Approver__r.Email, 
                                            New_Contact_Approver__c,New_Contact_Approver__r.Email,Current_Email_Approver__c,New_Email_Approver__c,
                                            Start_Date__c,End_Date__c from Out_of_Office__c where (Current_Contact_Approver__r.Email IN : approverEmails OR  Current_User_Approver__r.Email IN : approverEmails OR Current_Email_Approver__c IN : approverEmails) AND Account__c!=null AND Start_Date__c <=: System.today() AND End_Date__c >=: System.today()]){
                                                system.debug('oOffice : ' + oOffice);
                                                if(oOffice.Current_User_Approver__c!=null && String.isNotBlank(oOffice.Current_User_Approver__r.Email)){
                                                    Set<String> bList = new Set<String>();
                                                    if(!busRulesMap.containsKey(oOffice.Current_User_Approver__r.Email)){                                    
                                                        bList = new Set<String>();
                                                    } else {
                                                        bList = busRulesMap.get(oOffice.Current_User_Approver__r.Email);
                                                    }   
                                                    if(oOffice.New_User_Approver__c!=null && String.isNotBlank(oOffice.New_User_Approver__r.Email) ){
                                                        bList.add(oOffice.New_User_Approver__r.Email); 
                                                    }else if(oOffice.New_Contact_Approver__c!=null && String.isNotBlank(oOffice.New_Contact_Approver__r.Email)){
                                                        bList.add(oOffice.New_Contact_Approver__r.Email);
                                                    }else if(oOffice.New_Email_Approver__c!=null && String.isNotBlank(oOffice.New_Email_Approver__c)){
                                                        bList.add(oOffice.New_Email_Approver__c);
                                                    }
                                                    busRulesMap.put(oOffice.Current_User_Approver__r.Email, bList);
                                                }
                                                if(oOffice.Current_Contact_Approver__c!=null && String.isNotBlank(oOffice.Current_Contact_Approver__r.Email)){
                                                    Set<String> bList = new Set<String>();
                                                    if(!busRulesMap.containsKey(oOffice.Current_Contact_Approver__r.Email)){                                    
                                                        bList = new Set<String>();
                                                    } else {
                                                        bList = busRulesMap.get(oOffice.Current_Contact_Approver__r.Email);
                                                    }   
                                                    if(oOffice.New_User_Approver__c!=null && String.isNotBlank(oOffice.New_User_Approver__r.Email) ){
                                                        bList.add(oOffice.New_User_Approver__r.Email); 
                                                    }else if(oOffice.New_Contact_Approver__c!=null && String.isNotBlank(oOffice.New_Contact_Approver__r.Email)){
                                                        bList.add(oOffice.New_Contact_Approver__r.Email);
                                                    }else if(oOffice.New_Email_Approver__c!=null && String.isNotBlank(oOffice.New_Email_Approver__c)){
                                                        bList.add(oOffice.New_Email_Approver__c);
                                                    }
                                                    busRulesMap.put(oOffice.Current_Contact_Approver__r.Email, bList);
                                                }
                                                if(String.isNotBlank(oOffice.Current_Email_Approver__c)){
                                                    Set<String> bList = new Set<String>();
                                                    if(!busRulesMap.containsKey(oOffice.Current_Email_Approver__c)){                                    
                                                        bList = new Set<String>();
                                                    } else {
                                                        bList = busRulesMap.get(oOffice.Current_Email_Approver__c);
                                                    }   
                                                    if(oOffice.New_User_Approver__c!=null && String.isNotBlank(oOffice.New_User_Approver__r.Email) ){
                                                        bList.add(oOffice.New_User_Approver__r.Email); 
                                                    }else if(oOffice.New_Contact_Approver__c!=null && String.isNotBlank(oOffice.New_Contact_Approver__r.Email)){
                                                        bList.add(oOffice.New_Contact_Approver__r.Email);
                                                    }else if(oOffice.New_Email_Approver__c!=null && String.isNotBlank(oOffice.New_Email_Approver__c)){
                                                        bList.add(oOffice.New_Email_Approver__c);
                                                    }
                                                    busRulesMap.put(oOffice.Current_Email_Approver__c, bList);
                                                }
                                                
                                            }
            system.debug('busRulesMap : ' + busRulesMap);
            system.debug('approverEmails : ' + approverEmails);
            
           
        System.debug('approversMap : ' + busRulesMap);
        if(busRulesMap!=null && !busRulesMap.isEmpty()){
            Set<String> approverEmailSet = new Set<String>(approverEmails);
            for(String strEmail : approverEmailSet){
                if(busRulesMap.containsKey(strEmail)){
                    approverEmailSet.remove(strEmail);
                    approverEmailSet.addAll(busRulesMap.get(strEmail));
                } 
            }
            approverEmailsList = new List<String>(approverEmailSet);
            system.debug('approverEmailsList : ' + approverEmailsList);
        }
            
            /*for(String str : approverEmails){
                if(busRulesMap.containsKey(str)){
                    approverEmailsList.addAll(busRulesMap.get(str));
                }else{
                    approverEmailsList.add(str);
                }
            }system.debug('approverEmailsList : ' + approverEmailsList);
            */
        }
        return approverEmailsList;
    }
    
    public static Map<String,Out_of_Office__c> getBRsApproversDetails(Set<Id> businessRuleIds){
        Map<String,Out_of_Office__c> mapBRApprovers = new Map<String,Out_of_Office__c>();
        system.debug('businessRuleIds : ' + businessRuleIds);
        if(!businessRuleIds.isEmpty()){
            List<String> brRulesName = new List<String>();
            //List<String> brRulesIds = new List<String>();
            for(Business_Rule__c br : [Select Id,Name from Business_Rule__c where Id IN : businessRuleIds AND  Active__c =: true] ){
                brRulesName.add(br.Name);
                //brRulesIds.add(br.Id);
            }
            //Set<Id> officeIds = new Set<Id>();
            for(Out_of_Office__c oOffice : [Select Id, Business_Rules__c,Current_User_Approver__c,New_User_Approver__c,
                                            Current_User_Approver__r.Name,Current_User_Approver__r.Email,
                                            New_User_Approver__r.Email,New_User_Approver__r.Name,Current_Contact_Approver__c, Current_Contact_Approver__r.Name,Current_Contact_Approver__r.Email, 
                                            New_Contact_Approver__c,New_Contact_Approver__r.Name,New_Contact_Approver__r.Email,New_Contact_Approver__r.Phone,Current_Email_Approver__c,New_Email_Approver__c,
                                            Start_Date__c,End_Date__c from Out_of_Office__c where Account__c!=null AND Start_Date__c <=: System.today() AND End_Date__c >=: System.today()]){
                                                if(String.isNotBlank(oOffice.Business_Rules__c)){
                                                    String[] brList = oOffice.Business_Rules__c.split(',');
                                                    //List<String> brRuleNameList = new List<String>();
                                                    for(String str : brList){
                                                        if(String.isNotBlank(str)){
                                                            String brName = str.left(10);
                                                            if(brRulesName.contains(brName)){
                                                                system.debug('contain sbrRulesName : ' + brName);
                                                                //officeIds.add(oOffice.Id);
                                                                String backUpEmail;
                                                                /* if(oOffice.New_User_Approver__c!=null && String.isNotBlank(oOffice.New_User_Approver__r.Email) ){
backUpEmail = oOffice.New_User_Approver__r.Email + '~~~' + 'User'; 
} else if(oOffice.New_Contact_Approver__c!=null && String.isNotBlank(oOffice.New_Contact_Approver__r.Email)){
backUpEmail = oOffice.New_Contact_Approver__r.Email + '~~~' + 'Contact';
} else if(oOffice.New_Email_Approver__c!=null && String.isNotBlank(oOffice.New_Email_Approver__c)){
backUpEmail = oOffice.New_Email_Approver__c + '~~~' + 'Email';
}
*/
                                                                if(oOffice.Current_User_Approver__c!=null &&  String.isNotBlank(oOffice.Current_User_Approver__r.Email)
                                                                  /* && oOffice.New_User_Approver__c!=null && String.isNotBlank(oOffice.New_User_Approver__r.Email)*/){
                                                                       mapBRApprovers.put(oOffice.Current_User_Approver__c , oOffice ); 
                                                                   }
                                                                if(oOffice.Current_Contact_Approver__c!=null && String.isNotBlank(oOffice.Current_Contact_Approver__r.Email)
                                                                  /* && oOffice.New_Contact_Approver__c!=null && String.isNotBlank(oOffice.New_Contact_Approver__r.Email)*/){
                                                                       mapBRApprovers.put(oOffice.Current_Contact_Approver__c , oOffice ); 
                                                                   }
                                                                if(String.isNotBlank(oOffice.Current_Email_Approver__c) 
                                                                  /* && oOffice.New_Email_Approver__c!=null && String.isNotBlank(oOffice.New_Email_Approver__c) */){
                                                                       mapBRApprovers.put(oOffice.Current_Email_Approver__c , oOffice );                                
                                                                   }
                                                            }
                                                        }
                                                    }
                                                }system.debug('oOffice Id : ' + oOffice.id);
                                            }
        }System.debug('busRulesList : ' + mapBRApprovers);
        return mapBRApprovers;
    }
    
    public static String validateDuplicateRecord(Id recordId, List<String> businessRulesList){
        String returnMessage;
        Set<Id> accountIds = new Set<Id>();
        Set<Id> recordIds = new Set<Id>();
        //Set<Date> startDate = new Set<Date>();
        //Set<Date> endDate = new Set<Date>();
        Date startDate;
        Date endDate;
        Set<String> currentUserIds = new Set<String>();
        Set<String> currentContactIds = new Set<String>();
        Set<String> currentEmailIds = new Set<String>();
        Set<String> newUserIds = new Set<String>();
        Set<String> newContactIds = new Set<String>();
        Set<String> newEmailIds = new Set<String>();
        Set<String> businessRules = new Set<String>();
        Set<String> recordTypeIds = new Set<String>();
        for(Out_of_Office__c office : [Select Id,Account__c,Start_Date__c,End_Date__c,recordTypeId,recordType.developerName,
                                       Current_User_Approver__c,Current_Contact_Approver__c,Current_Email_Approver__c,
                                       New_User_Approver__c, New_Contact_Approver__c,New_Email_Approver__c,
                                       Business_Rules__c  
                                       from Out_of_Office__c where 
                                       Id =: recordId]){
                                           system.debug('office office : ' + office);
                                           system.debug('office.Business_Rules__c :: ' + office.Business_Rules__c);
                                           // if(String.isNotBlank(office.Business_Rules__c) && businessRules.contains(office.Business_Rules__c)){                                       
                                           recordIds.add(office.Id);
                                           accountIds.add(office.Account__c);
                                           startDate=office.Start_Date__c;
                                           endDate=office.End_Date__c;
                                           recordTypeIds.add(office.RecordTypeId);
                                           if(String.isNotBlank(office.Current_User_Approver__c))
                                               currentUserIds.add(office.Current_User_Approver__c);
                                           if(String.isNotBlank(office.Current_Email_Approver__c))
                                               currentEmailIds.add(office.Current_Email_Approver__c);
                                           if(String.isNotBlank(office.Current_Contact_Approver__c))
                                               currentContactIds.add(office.Current_Contact_Approver__c);
                                           if(String.isNotBlank(office.New_User_Approver__c))
                                               newUserIds.add(office.New_User_Approver__c);
                                           if(String.isNotBlank(office.New_Contact_Approver__c))
                                               newContactIds.add(office.New_Contact_Approver__c);
                                           if(String.isNotBlank(office.New_Email_Approver__c))
                                               newEmailIds.add(office.New_Email_Approver__c);
                                           if(String.isNotBlank(office.Business_Rules__c))
                                               businessRules.add(office.Business_Rules__c);
                                           //}
                                       }
        
        Map<Id,Out_of_Office__c> comparedOfficeMap = new Map<Id,Out_of_Office__c>();
        for(Out_of_Office__c existingRecord : [Select Id,Account__c,Start_Date__c,End_Date__c,recordTypeId,recordType.developerName,
                                               Current_User_Approver__c,Current_Contact_Approver__c,Current_Email_Approver__c,
                                               New_User_Approver__c, New_Contact_Approver__c,New_Email_Approver__c,
                                               Business_Rules__c  
                                               from Out_of_Office__c where 
                                               Id Not IN : recordIds AND 
                                               Account__c IN : accountIds AND
                                               Start_Date__c <=: startDate AND 
                                               End_Date__c >=: endDate AND 
                                               recordTypeId IN : recordTypeIds ]){
                                                   system.debug('existingRecord ' + existingRecord);
                                                   system.debug('businessRulesList ' + businessRulesList);
                                                   if(String.isNotBlank(existingRecord.Business_Rules__c) && businessRulesList.contains(existingRecord.Business_Rules__c)){
                                                       system.debug('Business_Rules__c ' + existingRecord.Business_Rules__c);
                                                       if(existingRecord.RecordType.DeveloperName == 'User' && String.isNotBlank(existingRecord.Current_User_Approver__c) && currentUserIds.contains(existingRecord.Current_User_Approver__c)){
                                                           if((String.isNotBlank(existingRecord.New_User_Approver__c) && newUserIds.contains(existingRecord.New_User_Approver__c)) 
                                                              || (String.isNotBlank(existingRecord.New_Contact_Approver__c) && newContactIds.contains(existingRecord.New_Contact_Approver__c))
                                                              || (String.isNotBlank(existingRecord.New_Email_Approver__c) && newEmailIds.contains(existingRecord.New_Email_Approver__c))){
                                                                  comparedOfficeMap.put(existingRecord.Id,existingRecord);
                                                              }
                                                       }
                                                       if(existingRecord.recordType.developerName == 'Contact' && String.isNotBlank(existingRecord.Current_Contact_Approver__c) && currentContactIds.contains(existingRecord.Current_Contact_Approver__c)){
                                                           if((String.isNotBlank(existingRecord.New_User_Approver__c) && newUserIds.contains(existingRecord.New_User_Approver__c)) 
                                                              || (String.isNotBlank(existingRecord.New_Contact_Approver__c) && newContactIds.contains(existingRecord.New_Contact_Approver__c))
                                                              || (String.isNotBlank(existingRecord.New_Email_Approver__c) && newEmailIds.contains(existingRecord.New_Email_Approver__c))){
                                                                  comparedOfficeMap.put(existingRecord.Id,existingRecord);
                                                              }
                                                       }
                                                       if(existingRecord.recordType.developerName == 'Email' && String.isNotBlank(existingRecord.Current_Email_Approver__c) && currentEmailIds.contains(existingRecord.Current_Email_Approver__c)){
                                                           system.debug('currentEmailIds ' + currentEmailIds);
                                                           if((String.isNotBlank(existingRecord.New_User_Approver__c) && newUserIds.contains(existingRecord.New_User_Approver__c)) 
                                                              || (String.isNotBlank(existingRecord.New_Contact_Approver__c) && newContactIds.contains(existingRecord.New_Contact_Approver__c))
                                                              || (String.isNotBlank(existingRecord.New_Email_Approver__c) && newEmailIds.contains(existingRecord.New_Email_Approver__c))){
                                                                  comparedOfficeMap.put(existingRecord.Id,existingRecord);
                                                              }
                                                       }
                                                   }
                                                   
                                               }
        system.debug('comparedOfficeMap : ' + comparedOfficeMap);
        for(Out_of_Office__c newOffice : [Select Id,Account__c,Start_Date__c,End_Date__c,recordTypeId,recordType.developerName,
                                          Current_User_Approver__c,Current_Contact_Approver__c,Current_Email_Approver__c,
                                          New_User_Approver__c, New_Contact_Approver__c,New_Email_Approver__c,
                                          Business_Rules__c  
                                          from Out_of_Office__c where 
                                          Id =: recordId ]){
                                              if(!comparedOfficeMap.isEmpty()){
                                                  returnMessage = Label.OOODuplicateErrorMessage;//'The rule with the same criteria already exists.';
                                              }
                                          }
        return returnMessage;
        
    }
    // OOO Features
    
}