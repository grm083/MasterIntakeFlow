public with sharing class changeRecordTypeController {
    
    @AuraEnabled
    public static list<recordType> getRecordTypeNames(Id recordId) {
        
        String objName = recordId.getSobjectType().getDescribe().getName();
        
        List<recordType> recordTypes = [SELECT Id, Name, Description FROM RecordType WHERE SobjectType =:objName and Name Not IN ('Pickup Case','Status Case','New Service Case') and isActive=true];
        
        //system.debug(recordTypes);
        return recordTypes;
        
    }

    @AuraEnabled
    public static boolean isAssetUserAccess(){
        List<User> uList = new List<User>();
        uList = [SELECT id, Update_Asset_Active_User__c FROM User WHERE id = :UserInfo.getUserId()];
        if(uList.size()>0){
            return uList[0].Update_Asset_Active_User__c;
        }
        return false;
    }

    @AuraEnabled
    public static list<recordType> getRecordTypeNamesFromObject(String objName) {
        
       List<recordType> recordTypes = [SELECT Id, Name, Description FROM RecordType WHERE SobjectType =:objName and Name Not IN ('Pickup Case','Status Case','New Service Case') and isActive=true];
       //List<recordType> recordTypes = [SELECT Id, Name, Description FROM RecordType WHERE SobjectType =:objName and Name Not IN ('Pickup Case','Status Case','New Service Case','Modify Existing Service Case') and isActive=true];

      return recordTypes;
       
    }

    @AuraEnabled
    public static void updateCaseRecord(Id recordId, Id newRecordType, String caseBtnType,String casetype,String caseSubType,String caseReason) {
        
               
        System.debug('newRecordType===='+newRecordType+'==='+casetype+'%%%%'+caseSubType+'$$$$'+caseReason);
       
        Case c = [Select Id,AssetId,Asset.Name,Asset.product2.family,Asset.Duration__c,
                  Asset.Occurrence_Type__c,Asset.product2.Equipment_Type__c,Case_Type__c,
                  Case_Sub_Type__c,Case_Reason__c,CPQ_New_Service__c,Case_Record_Type__c,Service_Date__c,
                  LOB__c, RecordTypeId From Case WHERE Id=:recordId LIMIT 1];
        
        //Field is updated for bug SDT-24987. Resetting the field to flase for other case type other than new service case.          
        c.CPQ_New_Service__c = false;
        //End
        if(caseBtnType == 'Pickup'){
            c.Case_Type__c = 'Pickup';
            c.RecordTypeId = Schema.SobjectType.Case.getRecordTypeInfosByName().get('Pickup Case').getRecordTypeId();
            c.Case_Reason__c='';
             if(c.asset.product2.family == Constant_Util.COMMERCIAL && c.asset.Occurrence_Type__c == Constant_Util.ON_CALL){
                 c.Case_Sub_Type__c = Constant_Util.ON_CALL_PICK;
             }else if(c.asset.product2.family == Constant_Util.COMMERCIAL && Constant_Util.HAND_PICKUP.equals(c.asset.product2.Equipment_Type__c) && c.asset.Duration__c.equals(Constant_Util.PERMANENT)){
                 c.Case_Sub_Type__c = '';
             }else if(c.asset.product2.family == Constant_Util.COMMERCIAL && (c.asset.Occurrence_Type__c == Constant_Util.SCHEDULED || c.asset.Occurrence_Type__c == Constant_Util.SCHEDULED_ON_CALL)){
                 c.Case_Sub_Type__c = Constant_Util.EXTRA_PICKUP;                        
             }else if(c.asset.product2.family == Constant_Util.ROLLOFF && c.asset.Duration__c == Constant_Util.PERMANENT && c.asset.product2.Equipment_Type__c != Constant_Util.Baler){
                 c.Case_Sub_Type__c = Constant_Util.EMPTY_AND_RETURN;
             }else if(Constant_Util.Baler.equals(c.asset.product2.Equipment_Type__c)){
                 c.Case_Sub_Type__c = Constant_Util.Bales;
             }else if(( c.asset.product2.family == Constant_Util.SERVICES && c.asset.Name.equals(Constant_Util.Bulk_Service_Type))){
                 c.Case_Sub_Type__c = Constant_Util.Bulk_Service_Type;
             }else if((c.asset.product2.family == Constant_Util.SERVICES  && c.asset.Name.equals(Constant_Util.Got_Junk_Pickup))){
                 c.Case_Sub_Type__c = Constant_Util.Haul_Away_No_Equipment;
             }else{
                 c.Case_Sub_Type__c = '';
             }
        }
        else if(caseBtnType == 'New Service'){
            Id newServiceRecordType = Schema.SobjectType.Case.getRecordTypeInfosByName().get(Constant_Util.New_Service_Case).getRecordTypeId();
            c.Case_Type__c = 'New Service';
            c.Case_Sub_Type__c = '';
            c.Case_Reason__c = '';
            //Field is updated for bug SDT-24987
            c.CPQ_New_Service__c = true;
            //End
            c.RecordTypeId = newServiceRecordType;
            // Field is updated for bug 29490
            if(String.isBlank(c.LOB__c)){
                c.LOB__c = (String.isNotEmpty(c.Asset.Name) && String.isNotBlank(c.Asset.product2.family))?c.Asset.product2.family:Constant_Util.COMMERCIAL; 
            }        
        }
        else if(caseBtnType == 'SNP'){
            c.Case_Type__c = 'Status';
            c.Case_Sub_Type__c = 'Service not performed';
			c.Case_Reason__c ='Customer Reported' ;
            c.RecordTypeId = Schema.SobjectType.Case.getRecordTypeInfosByName().get('Status Case').getRecordTypeId();
                                  
        }
        else if(caseBtnType == 'ETA'){
            c.Case_Type__c = 'Status';
            c.Case_Sub_Type__c = 'ETA'; 
             c.Case_Reason__c = '';
            c.RecordTypeId = Schema.SobjectType.Case.getRecordTypeInfosByName().get('Status Case').getRecordTypeId();
        
        }
        //Condition added for bug SDT-24986
        else if(caseBtnType == 'Update Asset'){
            Id updateAssetCase = Schema.SobjectType.Case.getRecordTypeInfosByName().get('Update Asset Case').getRecordTypeId();
            c.Case_Type__c = '';
            c.Case_Sub_Type__c = '';
            c.Case_Reason__c = '';
            c.RecordTypeId = updateAssetCase;        
        }
        //END
        else{
        
            if(newRecordType !=null){
                c.recordtypeID = newRecordType ;
            }
          // if(casetype !=null && casetype !=''){
                c.Case_Type__c =casetype ;
                
         //  }
           // if(caseSubType !=null && caseSubType !=''){
                c.Case_Sub_Type__c =caseSubType ;
               
           // }
          //  if(caseReason !=null && caseReason !=''){
                c.Case_Reason__c =caseReason ;
                    //  }
        }
        try{
            System.debug('c======'+c);
            update c;
            } catch (DMLException e) {
            system.debug('======'+e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void changeRecordType(Id recordId, Id newRecordType) {
        
        String objName = recordId.getSobjectType().getDescribe().getName();
        
        Case c = [Select Id,CPQ_New_Service__c,Case_Record_Type__c,LOB__c, RecordTypeId From Case WHERE Id=:recordId LIMIT 1];
        
        c.RecordTypeId = newRecordType;
        c.Case_Type__c = NULL;
        c.Case_Sub_Type__c = NULL;
        c.Case_Reason__c = NULL;
        Id newServiceRecordType = Schema.SobjectType.Case.getRecordTypeInfosByName().get(Constant_Util.New_Service_Case).getRecordTypeId();

        if(newServiceRecordType == newRecordType){
                List<PermissionSetLicenseAssign> PSLList = new List<PermissionSetLicenseAssign>();
                PSLList = [SELECT id, AssigneeId,PermissionSetLicenseId, PermissionSetLicense.MasterLabel  From PermissionSetLicenseAssign WHERE PermissionSetLicense.MasterLabel = 'Salesforce CPQ License' AND AssigneeId =: UserInfo.getUserId()];
                if (PSLList.size() > 0)
                 {
                    if(PSLList[0].PermissionSetLicense.MasterLabel == 'Salesforce CPQ License'){
                        c.CPQ_New_Service__c = true;
                    }
                 }
                 c.LOB__c = Constant_Util.COMMERCIAL;

            }
        try{
            update c;
        } catch (DMLException e) {
            system.debug(e.getMessage());
        }
    }
    @AuraEnabled
    public static recordTypeWrapper getInfo(String recordType, Id recordId) {
        String objName = recordId.getSobjectType().getDescribe().getName();
        RecordType recType = [SELECT Id, Description FROM RecordType WHERE SobjectType=:objName AND Name=:recordType];
        recordTypeWrapper rtw = new recordTypeWrapper(recType.Id, recType.Description);
        return rtw;
    }
    public inherited sharing class recordTypeWrapper {
        @AuraEnabled
        public String recordTypeId {get;set;}
        @AuraEnabled
        public String recordTypeDesc {get;set;}
        
        
        public recordTypeWrapper(String recordTypeId, String recordTypeDesc) {
            this.recordTypeId = recordTypeId;
            this.recordTypeDesc = recordTypeDesc;
            
        }
    }
    //Changes added for bug SDT-24986
    //Description: This method is used to get the Update_Asset_Active_User__c flag which is used to Hide/Show the Update Asset button on UI.
    // If flag is true Update Asset button will be visible on UI.
    //Developer : Jatan Sharma
    //Story/Bug : SDT-24986
    //Method Update : Changes done for SDT-24993 by jatan sharma
    // In addition we will check if asset has CPQProduct in it if null the value will be false.
    // calling AssetQuoteProcurementController.getQuoteAssetHeaders to get all asset present in case. As asset is stored in session we will required this method.
  /*  @AuraEnabled
    public static Boolean getActiveAssetUserDetail(ID caseId) { 
       Boolean result = false;

       result = isUpdateAssetActiveUser();
       
       List<AssetQuoteProcurementController.assetHeaderModel> caseAssetList =  AssetQuoteProcurementController.getQuoteAssetHeaders(caseId);
       for(AssetQuoteProcurementController.assetHeaderModel lst : caseAssetList){
        if (lst.CPQ_Product == null){
            return result = false;
        } 
       }
       return result;
   } */

    //Changes added for bug SDT-24993
    //Description: This will check if asset has CPQ_Product. If null result will be false.
    // With this flag we will show/hide the Update Asset button.
    //Developer : Jatan Sharma
   @AuraEnabled
   public static Boolean checkassetCPQProduct(ID assetId){
    Boolean result = true;

    result = isUpdateAssetActiveUser();
    if(assetId != null ){
        Asset asset = [Select Id, CPQ_Product__c from asset where id =: assetId];
        if( asset.CPQ_Product__c == null ){
            return result = false;
        } 
    }

    return result;
   }
    //Changes added for SDT-24993 and SDT-24986
    //Description: This method is used to get the Update_Asset_Active_User__c flag which is used to Hide/Show the Update Asset button on UI.
    // If flag is true Update Asset button will be visible on UI.
    //Developer : Jatan Sharma
   public static Boolean isUpdateAssetActiveUser() {
    Boolean result = false;       
    User u = [SELECT Id, Update_Asset_Active_User__c FROM User WHERE Id =: UserInfo.getUserId()];

    if( u.Update_Asset_Active_User__c == true)
    {
       return  result = true;
    }

    return result;
   }
    
    
    
    
}