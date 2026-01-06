/**************************************************
 * ClassName:NotifyCustomerOfDelayEmailController
 * Author:Rajan Sajani 
 * @description: Controller class
 * CreatedDate:10/1/2024
 * **************************************************/
public  class NotifyCustomerOfDelayEmailController {
    
    public Case caseRec;
    public Case objCase{get;set;}
    Public String assetFrequencyWeeklyVar {get; set;} 
    Public String assetFrequencyVar {get; set;} 
    Public String caseReasonVal {get; set;} 
    Public String wmLogoURL{get;set;}
    Public String wmQRCodeURL{get;set;}
    Public String occurenceDaysVar {get; set;} 
    Public String newServiceString{get; set;}
    Public String oldServiceString{get; set;}

    public Case getCaseFields(){ 
        
        
        //System.debug('caseObj'+objCase);
        caseRec = [SELECT id,Contact_Name__c,Case_Type__c,Case_Reason__c,Location_Code__c,Case.AssetId,Case.Asset.Occurrence_Type_Formula__c,Customer_Code__c,Case_Sub_Type__c,Proposed_Service_Date__c,Case.Asset.wednesday_Frequency__c,Case.Asset.Thursday_Frequency__c,Case.Asset.Friday_Frequency__c,Case.Asset.Saturday_Frequency__c,Case.Asset.Sunday_Frequency__c,Case.Asset.Tuesday_Frequency__c,Case.Asset.Monday_Frequency__c,Case.Asset.Occurrence__c,Service_Date__c,Reference_Number__c,Case.Asset.Name,Case.Asset.Equipment_Size__c,Case.Account.ShippingCity,Case.Asset.Container_Position__c,Case.Asset.Occurrence_Type__c,Case.Asset.Schedule_Type__c,Case.Asset.Frequency__c,Case.Asset.Schedule__c,Case.Asset.Material_Type__c,Case.Account.Location_Code__c,Case.Account.ShippingStreet,Case.Account.ShippingState,Case.Account.ShippingPostalCode,Case.Account.ShippingCountry,Case.Location__r.ShippingStreet,Case.Location__r.ShippingCity,Case.Location__r.ShippingState,Case.Location__r.ShippingPostalCode,Case.Location__r.ShippingCountry FROM Case WHERE id =:objCase.Id  ];  //         
       //caseRec = [SELECT id FROM Case WHERE id =:objCase.Id];            
       
        integer count = 0;
        occurenceDaysVar = '';
        assetFrequencyWeeklyVar = '';
        caseReasonVal = '';
        newServiceString = '';
        wmLogoURL =System.Label.WM_ImageLogoNew;
        wmQRCodeURL=System.Label.wmQRCodeLogo;
        
        if(caseRec != null && caseRec.AssetId != null){
            
        
           if(String.isNotEmpty(caseRec.Asset.Frequency__c) && caseRec.Asset.Frequency__c == 'Monthly'){
            assetFrequencyWeeklyVar  = 'Once per month';
            }
            else if(String.isNotEmpty(caseRec.Asset.Frequency__c) && caseRec.Asset.Frequency__c == 'Daily'){
                if(String.isNotEmpty(caseRec.Asset.Occurrence_Type_Formula__c)){
                    assetFrequencyWeeklyVar  = caseRec.Asset.Occurrence_Type_Formula__c.replace('Scheduled,','');
                    assetFrequencyWeeklyVar = assetFrequencyWeeklyVar.replace('()','');
                    assetFrequencyWeeklyVar =  assetFrequencyWeeklyVar.replaceAll('(\\d)([^\\d]*$)','$1 $2');
                }
            
            }
            else if(String.isNotEmpty(caseRec.Asset.Frequency__c) && caseRec.Asset.Frequency__c == 'Weekly'){
                //System.debug('caseRec.Asset.Frequency__c^^^ ' +caseRec.Asset.Frequency__c);
                if(String.isNotEmpty(caseRec.Asset.Monday_Frequency__c) && caseRec.Asset.Monday_Frequency__c == '1'){
                    count++;
                    occurenceDaysVar += ','+'Mon';
                }
                if(String.isNotEmpty(caseRec.Asset.Tuesday_Frequency__c) && caseRec.Asset.Tuesday_Frequency__c == '1'){
                    count++;
                    occurenceDaysVar += ','+'Tues';
                }
                if(String.isNotEmpty(caseRec.Asset.wednesday_Frequency__c) && caseRec.Asset.wednesday_Frequency__c == '1'){
                    count++;
                    occurenceDaysVar += ','+'Wed';
                }
                if(String.isNotEmpty(caseRec.Asset.Thursday_Frequency__c) &&  caseRec.Asset.Thursday_Frequency__c == '1'){
                    count++;
                    occurenceDaysVar += ','+'Thurs';
                }
                if(String.isNotEmpty(caseRec.Asset.Friday_Frequency__c) && caseRec.Asset.Friday_Frequency__c == '1'){
                    count++;
                    occurenceDaysVar += ','+'Fri';
                }
                if(String.isNotEmpty(caseRec.Asset.Saturday_Frequency__c) && caseRec.Asset.Saturday_Frequency__c == '1'){
                //System.debug('caseRec.Asset.Saturday_Frequency__c^^^ ' +caseRec.Asset.Saturday_Frequency__c);
                    count++;
                    occurenceDaysVar += ','+'Sat';
                }
                if(String.isNotEmpty(caseRec.Asset.Sunday_Frequency__c) && caseRec.Asset.Sunday_Frequency__c == '1'){
                    count++;
                    occurenceDaysVar += ','+'Sun';
                }
               //assetFrequencyWeeklyVar =  count + 'x/ week';
               if(String.isNotEmpty(caseRec.Asset.Occurrence_Type_Formula__c)){
                   assetFrequencyWeeklyVar  = caseRec.Asset.Occurrence_Type_Formula__c.replace('Scheduled,','');
                   assetFrequencyWeeklyVar = assetFrequencyWeeklyVar.replace('()','');
                   assetFrequencyWeeklyVar = assetFrequencyWeeklyVar.replaceAll('(\\d)([^\\d]*$)','$1 $2');
               }
               //System.debug('occurenceDaysVar^^^ ' +occurenceDaysVar);
               //if(occurenceDaysVar!= ''){
                 //occurenceDaysVar = occurenceDaysVar.replaceFirst(',','');
               //}
           
            }
            else{
                assetFrequencyWeeklyVar = caseRec.Asset.Occurrence_Type_Formula__c;
            }
            
            if(caseRec.Proposed_Service_Date__c != null){
                Datetime newDate = caseRec.Proposed_Service_Date__c;
                newServiceString = newDate.format('MMM dd, yyyy','GMT');
               // System.debug('newServiceString^^^ ' +newServiceString);
            }
            if(caseRec.Service_Date__c != null){
                Datetime serviceDate = caseRec.Service_Date__c;
                oldServiceString = serviceDate.format('MMM dd, yyyy','GMT');
                
                
            }
            if(String.isNotEmpty(caseRec.Case_Reason__c)){
				caseReasonVal = ', ' +caseRec.Case_Reason__c;
			}
         
            return caseRec;
        }
        else{
            return null;
        }
        
    }   

  
    
    }
