/*
* @Name          HaulAwayService
* @Author        Seema Dhikale34234
* @Vendor        TCS  
* @Date          1/10/2024
* @description   This class will be used as controller class for haul away services, story SDT-41544
*/
public class HaulAwayService  {
    public static final string HaulAway_Vendor_Not_Available = 'Not Available';
	public static final string Vendor_Got_Junk  = 'Got Junk';
	public static final string Vendor_Junk_King  = 'Junk King';
	public static final string Vendor_Check_Sammy = 'Check Sammy';
    public static final string Vendor_Got_Junk_API = '223110_5378';  
    public static final string Vendor_Junk_King_API = '7803'; 
    public static final string Vendor_Check_Sammy_API = '8601_9239';
    public static final string Haul_Away_AssetHaulerAvailable = 'Haul Away + Asset Available + End date Available+ Hauler Available'; //new Haulaway
    public static final string Haul_Away_NoAssetHaulerAvailable = 'Haul Away + No Asset Available + Hauler Available'; //new Haulaway
    public static final string Haul_Away_AssetAvailableOpenTop = 'Haul Away + Asset Available + End date Available + No Hauler Available'; //open top
    public static final string Haul_Away_NoAssetHaulerAvailableOpenTop = 'Haul Away + No Asset Available + No Hauler Available'; //open top
    public static final string Haul_Away_WithoutEnddate = 'Haul Away + Asset Available + No End date Available'; // for error message
    public static final string Haul_Away_Service_Product = 'Haul Away Product';
    public static final string Haul_Away_SFDCTaskDescCode = 'HaulAwayApp';
    public static final string Haul_Away_SFDCTaskDescription = 'Haul Away Approved';
    public static final string Haul_Away_Rej_SFDCTaskDescCode = 'HaulAwayRej';
    public static final string Haul_Away_Rej_SFDCTaskDescription = 'Haul Away Rejected';
    public static final string Haul_Away_Initiate_Task = 'Initiate_Task';
    public static final string Haul_Away_NewTask_Subject = 'Haul Away ';
    public static final string Haul_Away_NewTask_Approve_Subject = ' has been Approved';
    public static final string Haul_Away_NewTask_Approve_Description = ' has been Approved.\nPlease take below actions:\nInform the Vendor to start the service.';
    public static final string Haul_Away_NewTask_Reject_Subject = ' has been Declined';
    public static final string Haul_Away_NewTask_Reject_Description = ' has been Declined.\nPlease take below actions:\nInform the Vendor to stop the service and inform the customer';
    
    
    //SDT 41544
    public static final string Haul_Away_Service = Constant_Util.Haul_Away_Service;
    public static final string Haul_Away_Vendor_Not_Available = HaulAway_Vendor_Not_Available; // 42650
    public static final string Haul_Away_Vendor_Got_Junk = Vendor_Got_Junk;  // 42650
    public static final string Haul_Away_Vendor_Junk_King = Vendor_Junk_King;  // 42650
    public static final string Haul_Away_Vendor_Check_Sammy = Vendor_Check_Sammy;  // 42650
    //Haul Away SDT 44574
    public static final string Haul_Away_Vendor_Got_Junk_API = Vendor_Got_Junk_API; 
    public static final string Haul_Away_Vendor_Junk_King_API = Vendor_Junk_King_API;
    public static final string Haul_Away_Vendor_Check_Sammy_API = Vendor_Check_Sammy_API;  
    public static final list<string> Haul_Away_Vendor_LIST = new List<String>{Haul_Away_Vendor_Got_Junk_API,Haul_Away_Vendor_Junk_King_API,Haul_Away_Vendor_Check_Sammy_API};
        
    public static final string Haul_Away_Service_AssetHaulerAvailable = Haul_Away_AssetHaulerAvailable; //new Haulaway
    public static final string Haul_Away_Service_NoAssetHaulerAvailable = Haul_Away_NoAssetHaulerAvailable; //new Haulaway
    public static final string Haul_Away_Service_AssetAvailableOpenTop = Haul_Away_AssetAvailableOpenTop; //open top
    public static final string Haul_Away_Service_NoAssetHaulerAvailableOpenTop = Haul_Away_NoAssetHaulerAvailableOpenTop; //open top
    public static final string Haul_Away_Service_WithoutEnddate = Haul_Away_WithoutEnddate; // for error message
    
    public static final string Haul_Away_Product = Haul_Away_Service_Product;
    public static boolean skipTaskTrigger = true;

    /*
* @vendor           TCS
* @story            ////Haul Away SDT 44574
* @author           Seema Dhikale
* @description       This method is used to set default values for haul away quoteLine. 
* @param             Quoteline being updated and Parent Quote Name
* @return            Void
*/ 
    public static String getHaulAwayVendorByLocation(String haulAwayVendor,String location){
        String haulAwayVendorId;
        if(haulAwayVendor!=null && haulAwayVendor!='' && location!=null && location!='' && haulAwayVendor!=Haul_Away_Vendor_Not_Available){
            List<String> hVendorList = haulAwayVendor.split(Constant_Util.UNDERSCORE);
            if(location.equals(Constant_Util.UNITED_STATES) && hVendorList.size()==2){
                haulAwayVendorId = hVendorList[0];
            }else if(location.equals(Constant_Util.Canada_Shipping_Country) && hVendorList.size()==2){
                haulAwayVendorId = hVendorList[1];
            }else{
                haulAwayVendorId = haulAwayVendor;
            }
        } 
        return haulAwayVendorId;
    }
    public static Id getHaulAwayVendor(String haulAwayVendor){
        id haulAwayVendorId;
        if(haulAwayVendor!=null && haulAwayVendor!='' && haulAwayVendor!=Haul_Away_Vendor_Not_Available){
            
            haulAwayVendorId = [select id from account where Vendor_ID__c =: haulAwayVendor].id;
        }
        return haulAwayVendorId;
    }
    
    //SDT 41544
    public static boolean getIsHaulAwayService(Id caseIdToValidateAgainstHaulAway){
        boolean IsHaulAwayServiceCodeSwitchOn = getIsHaulAwayServiceCodeSwitchOn();
        if(caseIdToValidateAgainstHaulAway!=null){
            case caseToValidateAgainstHaulAway = [select id,Is_Haul_Away_Service__c,Haul_Away_information__c, Haul_Away_Vendor__c from case where id =: caseIdToValidateAgainstHaulAway];
            return getIsHaulAwayService(caseToValidateAgainstHaulAway);
        }
        return false;
    }
    //SDT 41544 SDT 44574
    //This method takes case object as parameter and it is assumed that required fields are already queried on case before passing it
    public static boolean getIsHaulAwayService(Case caseToValidateAgainstHaulAway){
        boolean IsHaulAwayService = false;
        boolean IsHaulAwayServiceCodeSwitchOn = getIsHaulAwayServiceCodeSwitchOn();
        Boolean IsHaulAwayServicecase =  caseToValidateAgainstHaulAway.Is_Haul_Away_Service__c;
        //String HaulAwayInformation =  caseToValidateAgainstHaulAway.Haul_Away_information__c;
        // 42650
        String HaulAwayVendor =  caseToValidateAgainstHaulAway.Haul_Away_Vendor__c;
        if(!IsHaulAwayServiceCodeSwitchOn && IsHaulAwayServicecase && Haul_Away_Vendor_LIST.contains(HaulAwayVendor))
            IsHaulAwayService = true;
        //(HaulAwayInformation==Haul_Away_Service_AssetHaulerAvailable || HaulAwayInformation==Haul_Away_Service_NoAssetHaulerAvailable || HaulAwayInformation==Haul_Away_Service_AssetAvailableOpenTop || HaulAwayInformation==Haul_Away_Service_NoAssetHaulerAvailableOpenTop))
        return IsHaulAwayService;
    }
    public static boolean getIsHaulAwayServiceCodeSwitchOn(){
        Code_Switch__c codeSwitchSetting = Code_Switch__c.getValues('Haul_Away'); 
        return codeSwitchSetting.Switch_Off__c;
    }
    /*
* @vendor           TCS
* @story            //SDT 41543, SDT 41968
* @author           Seema Dhikale
* @description       This method is used to set default values for haul away quoteLine. 
* @param             Quoteline being updated and Parent Quote Name
* @return            Void
*/ 
    public static void assignDefaultsToHaulAwayQL(SBQQ__QuoteLine__c quoteLineRecord){
        if(quoteLineRecord.SBQQ__ProductName__c==Haul_Away_Service){
            quoteLineRecord.SBQQ__UnitCost__c = 0;
	    quoteLineRecord.SBQQ__ListPrice__c = 0;
        }
    }
    
    
    /*
* @vendor           TCS
* @story            //SDT 41540, SDT 42045
* @author           Harun
* @description      This method is check the loggedin user is CE agent or not. 
* @return           Boolean
*/     
    /*
public static boolean checkIfCEAgent(){
boolean  IsCEAgent = false;
ID userId = Userinfo.getuserId();
user usr = [Select id,name,UserRole.Name,Profile.Name  from user where ID = :userId];
if((usr.Profile.Name == 'Customer Service') && (usr.UserRole.Name == 'Customer Experience Representative')){
IsCEAgent = true;
}
return IsCEAgent;

} */
    
    /*
* @vendor           TCS
* @story            //SDT 41540, SDT 42045
* @author           Harun
* @description      This method is check the haulAway service or not by passing quote Id 
* @return           Boolean
*/  
    //SDT 41544
    @AuraEnabled
    public static boolean getIsHaulAwayServiceforQuote(Id quoteIdToValidateAgainstHaulAway){
        boolean IsHaulAwayService = false;
        boolean IsHaulAwayServiceCodeSwitchOn = getIsHaulAwayServiceCodeSwitchOn();
        Case objCase = new Case();
        if(quoteIdToValidateAgainstHaulAway!=null){
            SBQQ__Quote__c quoteIdCase = [select Id,SBQQ__Opportunity2__r.Case__r.Haul_Away_information__c,SBQQ__Opportunity2__r.Case__r.Is_Haul_Away_Service__c,SBQQ__Opportunity2__r.Case__r.Haul_Away_Vendor__c from SBQQ__Quote__c where Id =: quoteIdToValidateAgainstHaulAway];
            
            objCase.Is_Haul_Away_Service__c = quoteIdCase.SBQQ__Opportunity2__r.Case__r.Is_Haul_Away_Service__c;
            objCase.Haul_Away_information__c = quoteIdCase.SBQQ__Opportunity2__r.Case__r.Haul_Away_information__c;
            objCase.Haul_Away_Vendor__c = quoteIdCase.SBQQ__Opportunity2__r.Case__r.Haul_Away_Vendor__c;    
            
            
        }
        return getIsHaulAwayService(objCase);
    }
    
    /*
* @vendor           TCS
* @story            //SDT 41540, SDT 42045
* @author           Harun
* @description      This method is check the haulAway service or not by passing set of quote Id 
* @return           Boolean
*/  
    
public static Map<Id,Boolean> getIsHaulAwayServiceforQuote(set<Id> quoteIdToValidateAgainstHaulAway){
boolean IsHaulAwayService = false;
//boolean IsHaulAwayServiceCodeSwitchOn = getIsHaulAwayServiceCodeSwitchOn();
Map<Id,Boolean> haulAwayServiceMap = new Map<Id,Boolean>();
if(quoteIdToValidateAgainstHaulAway!=null && !quoteIdToValidateAgainstHaulAway.isEmpty()){
List<SBQQ__Quote__c> quoteWithCases = [select Id,SBQQ__Opportunity2__r.Case__r.Haul_Away_information__c,SBQQ__Opportunity2__r.Case__r.Is_Haul_Away_Service__c,SBQQ__Opportunity2__r.Case__r.Haul_Away_Vendor__c from SBQQ__Quote__c where Id =: quoteIdToValidateAgainstHaulAway];
for(SBQQ__Quote__c qList :quoteWithCases){
Case objCase = new Case();
objCase.Is_Haul_Away_Service__c = qList.SBQQ__Opportunity2__r.Case__r.Is_Haul_Away_Service__c;
objCase.Haul_Away_information__c = qList.SBQQ__Opportunity2__r.Case__r.Haul_Away_information__c;
objCase.Haul_Away_Vendor__c = qList.SBQQ__Opportunity2__r.Case__r.Haul_Away_Vendor__c;    
//return getIsHaulAwayService(objCase);
haulAwayServiceMap.put(qList.Id,getIsHaulAwayService(objCase));
}

}
return haulAwayServiceMap;
}
    
    public static Map<Id,Boolean> getIsHaulAwayServiceforQuote(List<SBQQ__Quote__c> quoteIdToValidateAgainstHaulAway){
        boolean IsHaulAwayService = false;
        //boolean IsHaulAwayServiceCodeSwitchOn = getIsHaulAwayServiceCodeSwitchOn();
        Map<Id,Boolean> haulAwayServiceMap = new Map<Id,Boolean>();
        if(quoteIdToValidateAgainstHaulAway!=null && !quoteIdToValidateAgainstHaulAway.isEmpty()){
            // List<SBQQ__Quote__c> quoteWithCases = [select Id,SBQQ__Opportunity2__r.Case__r.Haul_Away_information__c,SBQQ__Opportunity2__r.Case__r.Is_Haul_Away_Service__c,SBQQ__Opportunity2__r.Case__r.Haul_Away_Vendor__c from SBQQ__Quote__c where Id =: quoteIdToValidateAgainstHaulAway];
            for(SBQQ__Quote__c qList :quoteIdToValidateAgainstHaulAway){
                Case objCase = new Case();
                objCase.Is_Haul_Away_Service__c = qList.SBQQ__Opportunity2__r.Case__r.Is_Haul_Away_Service__c;
                objCase.Haul_Away_information__c = qList.SBQQ__Opportunity2__r.Case__r.Haul_Away_information__c;
                objCase.Haul_Away_Vendor__c = qList.SBQQ__Opportunity2__r.Case__r.Haul_Away_Vendor__c;    
                //return getIsHaulAwayService(objCase);
                haulAwayServiceMap.put(qList.Id,getIsHaulAwayService(objCase));
            }
            
        }
        return haulAwayServiceMap;
    }
    
    public static Set<Id> haulAwayCheckForBypassValidation(SBQQ__Quote__c quoteRec,Set<Id> quoteIdSet){
        Set<Id> haulAwayQuoteSet = new Set<Id>();
        if(HaulAwayService.getIsHaulAwayService(new Case(Is_Haul_Away_Service__c = quoteRec.SBQQ__Opportunity2__r.Case__r.Is_Haul_Away_Service__c,
                                                         Haul_Away_Vendor__c = quoteRec.SBQQ__Opportunity2__r.Case__r.Haul_Away_Vendor__c)))
        {
            haulAwayQuoteSet.add(quoteRec.Id);
        }
        return haulAwayQuoteSet;
    }
    //SDT45079 seema
    //getIfGenesysEnabledUser
    //Creating a wrapper class that will store info about how mant quote only services added till now
    public class genUserDetalsWrapper
    {
        @AuraEnabled public Boolean isGenesysEnabledUser {get; set;}
        @AuraEnabled public String genFlag {get; set;}
    }
    public static genUserDetalsWrapper getIfGenesysEnabledUser(String quoteAssigntoId){
        genUserDetalsWrapper genUserDetalsWrapperRec = new genUserDetalsWrapper();
        genUserDetalsWrapperRec.isGenesysEnabledUser = false;
        genUserDetalsWrapperRec.genFlag='';
        User usr =[Select User_categorization_code__c From User where Id=:quoteAssigntoId];
        if(usr.User_categorization_code__c != null){
            CSR_User_Data_Setup__mdt userDataSetup = CSR_User_Data_Setup__mdt.getInstance(usr.User_categorization_code__c);
            if(userDataSetup != null && userDataSetup.Is_Genesys_User__c){
                genUserDetalsWrapperRec.isGenesysEnabledUser = true;
                genUserDetalsWrapperRec.genFlag = userDataSetup.GR_Service_Flag__c;
            }
        }
        return genUserDetalsWrapperRec;
    }
    //SDT45079 seema
    public static Boolean getIfLastAgentAvailable(String userLastAgent){
        Boolean isGenesysEnabledUser = false;
        if(userLastAgent!='')
        {
            isGenesysEnabledUser = true;
        }
        return isGenesysEnabledUser;
    }
    //SDT45079 seema
    public static Boolean createGenesysRecord(SBQQ__Quote__c quote,String str,String ownerId,String genServiceFlag,Task genTask){
    	Boolean isGenesysEnabledUser = false;Id emailToCaseRec = Schema.getGlobalDescribe().get(Constant_Util.Genesys_Routing).getDescribe().getRecordTypeInfosByDeveloperName().get(Constant_Util.EMAILTOCASERECORD).getRecordTypeId();
        Map<String,TaskDesc__mdt> quoteTaskDescMap = new Map<String,TaskDesc__mdt>();
        Generic_Values__mdt genValue = Generic_Values__mdt.getInstance(Constant_Util.GENESYS_USER);  
        Genesys_Routing__c gen = new Genesys_Routing__c();
        gen.LastAgentId__c = str!=null ? str : null;
        gen.MediaType__c = Constant_Util.SFDCWORKFLOWTASK;
        gen.RecordTypeId = emailToCaseRec;                
        gen.Action__c = Constant_Util.STATUS_NEW;
        gen.SFDCObjRecordID__c = genTask.Id;
        gen.SFDCObjType__c = Constant_Util.OBJECT_TASK;
        gen.SFDCAcctID__c = quote.SBQQ__Account__r.Parent.Customer_Code__c;
        gen.SFDCAcctSegment__c = quote.SBQQ__Account__r.Parent.Primary_Segment__c;
        gen.SFDCAcctLocation__c = quote.SBQQ__Account__r.Location_Code__c;
        gen.SFDCAcctLocationTimeZone__c = quote.SBQQ__Account__r.tz__Timezone__c;
        gen.SFDCCaseNumber__c = quote.SBQQ__Opportunity2__r.Case__r.CaseNumber;
        gen.SFDCCaseRefNo__c = quote.SBQQ__Opportunity2__r.Case__r.Reference_Number__c;
        gen.SFDCCaseType__c = quote.SBQQ__Opportunity2__r.Case__r.Case_Type__c;
        gen.SFDCCaseSubCaseType__c = quote.SBQQ__Opportunity2__r.Case__r.Case_Sub_Type__c;
        gen.SFDCCaseReason__c = quote.SBQQ__Opportunity2__r.Case__r.Case_Reason__c;    
        gen.SFDCServiceFlag__c = genServiceFlag!=null ? genServiceFlag : null;
        
        if(quote.Sbqq__Status__c == Constant_Util.APPROVED) {
            gen.SFDCTaskDescCode__c = Haul_Away_SFDCTaskDescCode;              
            gen.SFDCTaskDescription__c = Haul_Away_SFDCTaskDescription;
        }
        else {
            gen.SFDCTaskDescCode__c = Haul_Away_Rej_SFDCTaskDescCode;
            gen.SFDCTaskDescription__c = Haul_Away_Rej_SFDCTaskDescription;
        }
        
        gen.SFDCTaskDueDateTime__c = quote.Next_Action_Due_Date__c;
        gen.SFDCRouteStartTime__c = String.valueof(System.today()) + Constant_Util.START_TIME_TEXT;
        gen.SFDCRouteEndTime__c = String.valueof(System.today()) + Constant_Util.END_TIME_TEXT;
        gen.SFDCRoutePriority__c = quote.Priority__c;
        gen.SFDCTaskDueDateTime__c = quote.SBQQ__Opportunity2__r.Case__r.SLA_Service_Date_Time__c;
        gen.Integrate_with_Genesys_Routing__c = true;
        gen.OwnerId = ownerId!=null ? ownerId : null;//genValue.Id__c;
        
        Database.SaveResult insertOutcome = Database.insert(gen);
        return isGenesysEnabledUser;
    }
    
    //SDT45079 seema
    public static Task createGenesysTask(SBQQ__Quote__c quote,String assignto){
        List<Task> tasksToCreate = new List<Task>();
        Task newTask = new Task();
        Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(Haul_Away_Initiate_Task).getRecordTypeId();
        newTask.OwnerId = assignTo;
        if(quote.SBQQ__Status__c == Constant_Util.QUOTE_APPROVED){
            newTask.Subject = Haul_Away_NewTask_Subject+quote.Name+Haul_Away_NewTask_Approve_Subject;
            newTask.Description =Haul_Away_NewTask_Subject +quote.Name+ Haul_Away_NewTask_Approve_Description;
        }else{
            newTask.Subject = Haul_Away_NewTask_Subject+quote.Name+Haul_Away_NewTask_Reject_Subject;
            newTask.Description =Haul_Away_NewTask_Subject +quote.Name+ Haul_Away_NewTask_Reject_Description;
        }                
        newTask.RecordTypeId = recordTypeId ;
        newTask.WhatId = quote.SBQQ__Opportunity2__r.Case__c;
        newTask.ActivityDate = date.valueOf(quote.SBQQ__Opportunity2__r.Case__r.SLA_Service_Date_Time__c);//due date
        newTask.Due_Date_Time__c = quote.SBQQ__Opportunity2__r.Case__r.SLA_Service_Date_Time__c;//due datetime
        tasksToCreate.add(newTask);
        
        if(!tasksToCreate.isEmpty()){
            //SDT 45079
            skipTaskTrigger = false;
            insert  tasksToCreate ;
            //SDT 45079
            skipTaskTrigger = true;
        }
        return newTask;
    }
}
