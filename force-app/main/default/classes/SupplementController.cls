public class SupplementController {

    @AuraEnabled
    public static supplementWrapper getParentQuote(string parentQuoteLineId){
        SBQQ__QuoteLine__c parentQuoteLine = new SBQQ__QuoteLine__c();
        parentQuoteLine = [SELECT id, Profile_Number__c, Landfill_Tickets__c, Other_Paperwork_Needs__c, Certificate_of_Destruction__c,
                          Certificate_of_Disposal__c, Container_in_a_Restricted_Area__c,restricted_hours_of_operation__c,Restriction_Details__c,Requires_Push_In_Push_Out_Service__c,
                          SBQQ__Quote__c, SBQQ__Quote__r.Project_Services_Request__c, SBQQ__Quote__r.Project__c, Service_Start_Time__c, Service_End_Time__c, Gate_Code__c, Special_Disposal_Description__c
                          FROM SBQQ__QuoteLine__c
                          WHERE id=:parentQuoteLineId AND SBQQ__RequiredBy__c=null
                          LIMIT 1];
        
        
        return assignSuppWrapper(parentQuoteLine);
    }
    @AuraEnabled
    public static string updateQuoteLines(string sWrapJson){
        string finalResult='SUCCESS';
        try{
            system.debug('sWrapJson==>'+sWrapJson);
            supplementWrapper supplimentWrap = (supplementWrapper)JSON.deserialize(sWrapJson, supplementWrapper.class);
            system.debug('supplimentWrap==>'+supplimentWrap);
            List<SBQQ__QuoteLine__c> qLineList = new List<SBQQ__QuoteLine__c>();
            qLineList = [SELECT id, Profile_Number__c, Landfill_Tickets__c, Other_Paperwork_Needs__c, Certificate_of_Destruction__c, 
                         Certificate_of_Disposal__c,Container_in_a_Restricted_Area__c, restricted_hours_of_operation__c,Restriction_Details__c, Requires_Push_In_Push_Out_Service__c,
                         Service_Start_Time__c, Service_End_Time__c, Gate_Code__c, Special_Disposal_Description__c
                         FROM SBQQ__QuoteLine__c
                         WHERE id=:supplimentWrap.parentQlineId OR SBQQ__RequiredBy__c=:supplimentWrap.parentQlineId];
            for(SBQQ__QuoteLine__c qLine : qLineList){
                qLine.Profile_Number__c = supplimentWrap.profileNumber;
                qLine.Landfill_Tickets__c = supplimentWrap.landfillTickets;
                qLine.Other_Paperwork_Needs__c = supplimentWrap.otherPaperWorkNeeded;
                qLine.Special_Disposal_Description__c = supplimentWrap.specialDisposalDescription;
                qLine.Certificate_of_Destruction__c=false;
                qLine.Certificate_of_Disposal__c = false;
                if(supplimentWrap.selectedDestructionType=='Destruction'){
                    qLine.Certificate_of_Destruction__c=true;
                }else if(supplimentWrap.selectedDestructionType=='Disposal'){
                    qLine.Certificate_of_Disposal__c = true;
                }
                //qLine.Restriction_Details__c = supplimentWrap.restrictionDetails;
                qLine.restricted_hours_of_operation__c = supplimentWrap.restrictionHoursOfOperation;
                qLine.Requires_Push_In_Push_Out_Service__c = supplimentWrap.requiresPushInPushOutService;
                qLine.Container_in_a_Restricted_Area__c=supplimentWrap.containerinRestrictedArea;
                qline.Restriction_Details__c = supplimentWrap.restrictionDetails;
                if(supplimentWrap.serviceStartTime != null)
                {
                    String [] strStartTime =  supplimentWrap.serviceStartTime.split(':');
                    Time tmStartTime = Time.newInstance(Integer.valueOf(strStartTime[0]), Integer.valueOf(strStartTime[1]), 0, 0); 
                    qline.Service_Start_Time__c = tmStartTime;
                }
                if(supplimentWrap.serviceEndTime != null)
                {
                    String [] strEndTime = supplimentWrap.serviceEndTime.split(':');
                    Time tmEndTime = Time.newInstance(Integer.valueOf(strEndTime[0]), Integer.valueOf(strEndTime[1]), 0, 0); 
                    qline.Service_End_Time__c = tmEndTime;
                }
                qline.Gate_Code__c = supplimentWrap.gateCode;
            }
            update qLineList;
            SBQQ__Quote__c quote = new SBQQ__Quote__c(
            	id = supplimentWrap.parentQuoteId,
                Project_Services_Request__c = supplimentWrap.projectServiceRequest,
                Project__c = supplimentWrap.projectLookUpId
            );
            update quote;
        }
        catch(exception ex){
            system.debug('exception is '+ex.getMessage());
            finalResult = ex.getMessage();
        }
        return finalResult;
    }
    
    public static supplementWrapper assignSuppWrapper(SBQQ__QuoteLine__c qLine){
        supplementWrapper suppWrap = new supplementWrapper();
        suppWrap.parentQlineId = qLine.id;
        suppWrap.parentQuoteId = qLine.SBQQ__Quote__c;
        suppWrap.profileNumber = qLine.Profile_Number__c;
        suppWrap.landfillTickets = qLine.Landfill_Tickets__c;
        suppWrap.otherPaperWorkNeeded = qLine.Other_Paperwork_Needs__c;
        suppWrap.specialDisposalDescription = qLine.Special_Disposal_Description__c;
        suppWrap.selectedDestructionType = assignDestructionType(qLine);
        suppWrap.restrictionHoursOfOperation = qLine.restricted_hours_of_operation__c;
        suppWrap.requiresPushInPushOutService = qLine.Requires_Push_In_Push_Out_Service__c;
        suppWrap.projectServiceRequest = qLine.SBQQ__Quote__r.Project_Services_Request__c;
        suppWrap.projectLookUpId = qLine.SBQQ__Quote__r.Project__c;
        SuppWrap.containerinRestrictedArea=qLine.Container_in_a_Restricted_Area__c;
        SuppWrap.restrictionDetails = qline.Restriction_Details__c;
        if(qline.Service_Start_Time__c != null){
            SuppWrap.serviceStartTime = string.valueOf(qline.Service_Start_Time__c);
        }
        if(qline.Service_End_Time__c != null){
            SuppWrap.serviceEndTime = string.valueOf(qline.Service_End_Time__c);
        }
        SuppWrap.gateCode = qline.Gate_Code__c;
        return suppWrap;
    }
    public static string assignDestructionType(SBQQ__QuoteLine__c qLine){
        string selectedDestructionType='';
        if(qLine.Certificate_of_Destruction__c==true){
            selectedDestructionType='Destruction';
        }else if(qLine.Certificate_of_Disposal__c == true){
            selectedDestructionType='Disposal';
        }
        return selectedDestructionType;
    }
    public class supplementWrapper{
        @AuraEnabled public string parentQlineId{set;get;}
        @AuraEnabled public string parentQuoteId{set;get;}
        @AuraEnabled public string profileNumber{set;get;}
        @AuraEnabled public boolean landfillTickets{set;get;}
        @AuraEnabled public string otherPaperWorkNeeded{set;get;}
        @AuraEnabled public string specialDisposalDescription{set;get;}
        @AuraEnabled public string selectedDestructionType{set;get;}
        @AuraEnabled public boolean restrictionHoursOfOperation{set;get;}
        @AuraEnabled public boolean requiresPushInPushOutService{set;get;}
        @AuraEnabled public boolean projectServiceRequest{set;get;}
        @AuraEnabled public string projectLookUpId{set;get;}
        @AuraEnabled public boolean containerinRestrictedArea{set;get;}
        @AuraEnabled public string restrictionDetails{set;get;}
        @AuraEnabled public string serviceStartTime{set;get;}
        @AuraEnabled public string serviceEndTime{set;get;}
        @AuraEnabled public string gateCode{set;get;}
    }
}