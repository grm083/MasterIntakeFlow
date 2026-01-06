/**
* @author Waste Management
* @date 2023
*
* @group Out of Office
*
* @description Helper class for having all the business logic for OutofOfficeTriggerHandler events. 
*              This class generally getting executed from all the OutofOfficeTriggerHandler.
*/
public class OutofOfficeTriggerHelper {
    /*
    public static void updateBusinessRules(List<Out_of_Office__c> newOutOfficeList){
        List<Id> accountIds = new List<Id>();
        List<String> currentUsers = new List<String>();
        List<String> currentContacts = new List<String>();
        List<String> currentEmails = new List<String>();
        for(Out_of_Office__c ooo : newOutOfficeList){
            if(ooo.Account__c !=null){
                accountIds.add(ooo.Account__c);
            }
            if(String.isNotBlank(ooo.Current_User_Approver__c)){
                currentUsers.add(ooo.Current_User_Approver__c);
            }
            if(String.isNotBlank(ooo.Current_Contact_Approver__c)){
                currentContacts.add(ooo.Current_Contact_Approver__c);
            }
            if(String.isNotBlank(ooo.Current_Email_Approver__c)){
                currentEmails.add(ooo.Current_Email_Approver__c);
            }
        }
        if(!accountIds.isEmpty()){
            Set<Id> brIds = new Set<Id>();
            for(Business_Rule__c br : [Select Id, Name,AccountId__c from Business_Rule__c where AccountId__c =: accountIds]){
                brIds.add(br.Id);
            }
            if(!brIds.isEmpty()){
                List<Service_Approver__c> serviceApproverList = new List<Service_Approver__c>();
                List<String> brNameList = new List<String>();
                if(!currentUsers.isEmpty()){
                    serviceApproverList = [Select Id,Business_Rule__c,Business_Rule__r.Name,Business_Rule__r.Service__c,Business_Rule__r.Request_Type__c,Approver_Contact__c from Service_Approver__c where User__c =:currentUsers AND Business_Rule__c IN : brIds];
                }else if(!currentContacts.isEmpty()){
                    serviceApproverList = [Select Id,Business_Rule__c,Business_Rule__r.Name,Business_Rule__r.Service__c,Business_Rule__r.Request_Type__c,Approver_Contact__c from Service_Approver__c where Approver_Contact__c =:currentContacts AND Business_Rule__c IN : brIds];
                }else if(!currentEmails.isEmpty()){
                    serviceApproverList = [Select Id,Business_Rule__c,Business_Rule__r.Name,Business_Rule__r.Service__c,Business_Rule__r.Request_Type__c,Approver_Contact__c from Service_Approver__c where Approver_Email__c =:currentEmails AND Business_Rule__c IN : brIds];
                }
                Set<String> brNameSet = new Set<String>();
                for(Service_Approver__c srAppr : serviceApproverList){
                    brNameSet.add(srAppr.Business_Rule__r.Name+'-'+srAppr.Business_Rule__r.Service__c+'-'+srAppr.Business_Rule__r.Request_Type__c);
                }
                brNameList.addAll(brNameSet);
                //system.debug('brNameSet : ' + brNameSet);
                system.debug('brNameList : ' + brNameList);
                for(Out_of_Office__c oooNew :  newOutOfficeList){
                    if(!brNameList.isEmpty()){
                        oooNew.Business_Rules__c = String.join(brNameList, ',');
                    }
                }
            }
        }
    }*/
    
    // Find Duplicate Out of Office Records
    public static void validateDuplicateRecord(List<Out_of_Office__c> newOutOfficeList){
        Set<Id> accountIds = new Set<Id>();
        Set<Id> recordIds = new Set<Id>();
        List<Date> startDate = new List<Date>();
        List<Date> endDate = new List<Date>();
        Set<String> currentUserIds = new Set<String>();
        Set<String> currentContactIds = new Set<String>();
        Set<String> currentEmailIds = new Set<String>();
        Set<String> newUserIds = new Set<String>();
        Set<String> newContactIds = new Set<String>();
        Set<String> newEmailIds = new Set<String>();
        Set<String> businessRules = new Set<String>();
        Set<String> recordTypeIds = new Set<String>();
        // Prepare new OOO List
        for(Out_of_Office__c office : newOutOfficeList){
            system.debug('office.Business_Rules__c :: ' + office.Business_Rules__c);
            recordIds.add(office.Id);
            accountIds.add(office.Account__c);
            startDate.add(office.Start_Date__c);
            endDate.add(office.End_Date__c);
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
        }
        
        // Find Old Records
        Map<Id,Out_of_Office__c> comparedOfficeMap = new Map<Id,Out_of_Office__c>();
        for(Out_of_Office__c existingRecord : [Select Id,Account__c,Start_Date__c,End_Date__c,recordTypeId,recordType.developerName,
                                              Current_User_Approver__c,Current_Contact_Approver__c,Current_Email_Approver__c,
                                              New_User_Approver__c, New_Contact_Approver__c,New_Email_Approver__c,
                                              Business_Rules__c  
                                              from Out_of_Office__c where 
                                               Id Not IN : recordIds AND 
                                              Account__c IN : accountIds AND
                                              Start_Date__c <=: startDate.get(0) AND 
                                              End_Date__c >=: endDate[0] AND 
                                              recordTypeId IN : recordTypeIds ]){
                                                  system.debug('existingRecord ' + existingRecord);
                                                  if(String.isNotBlank(existingRecord.Business_Rules__c) && businessRules.contains(existingRecord.Business_Rules__c)){
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
        // Compare the OOO Records, to get the duplicate Records
        for(Out_of_Office__c newOffice : newOutOfficeList){
            if(!comparedOfficeMap.isEmpty()){
                newOffice.addError(Label.OOODuplicateErrorMessage);
            }
        }
        
    }

}