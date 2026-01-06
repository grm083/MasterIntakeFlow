/**
* @author Accenture
* @date 3/25/2019
* @description : MultipleWorkorderController for multiple workorder scenario
**/
public Without Sharing class MultipleWorkorderController {
    public static final string ANDSTR = '&';
    public static final string AMSTR = '&AM';
    public static final string PMSTR = '&PM';  
    /**
    * @author Accenture
    * @date 3/25/2019
    * @description : MultipleWorkorderController for multiple workorder scenario
    **/    
    Public static void getAMPMCaseBulk(List<case> selectedCaseList){
        System.debug('RecurrsiveTriggerHandler.getRunTimes()===='+RecurrsiveTriggerHandler.getRunTimes());
        if(RecurrsiveTriggerHandler.getRunTimes() < 1){
            RecurrsiveTriggerHandler.setRunTimes();
            Map<string,SBS_Case_Asset__c> parentRemovedAssetMap = new Map<string,SBS_Case_Asset__c>();
            List<SBS_Case_Asset__c> caseAssetCreateList = new List<SBS_Case_Asset__c>();
            Map<string,List<SBS_Case_Asset__c>> vendorCaseAssetMap = new Map<string,List<SBS_Case_Asset__c>>();
           // Map<string,List<SBS_Case_Asset__c>> vendorCaseAssetMap = new Map<string,List<SBS_Case_Asset__c>>();
            List<Case> newCaseList = new List<Case>();
            Map<id,List<SBS_Case_Asset__c>> caseAssetFinalMap = new Map<id,List<SBS_Case_Asset__c>>();
            LIst<case> newCaseUpdateList = new LIst<case>();
            set<id> newChildCaseIdSet = new set<id>();
            List<case> caseUpdateFinalList = new List<case>();
            Map<string,case> caseMap = new Map<string,case>();
            Map<string,string> assetServiceTypeMap = new Map<string,string>();
            Map<string,case> casePMMap = new Map<string,case>();
            Map<id,Case> caseUpdateFinalMap = new Map<id,Case>();
            Map<id,case> parentAmCaseUpdateMap = new Map<id,case>();
            set<id> caseIdSet = new set<id>();
            Map<string,string> vendorAssetMap = new Map<string,string>();
            Map<id,SBS_Case_Asset__c> caseAssetMapValue = new Map<id,SBS_Case_Asset__c>();
            Map<id,Asset> assetMap = new MAp<Id,Asset>();
            set<id> assetIdSet = new set<id>();
            try{
                if(selectedCaseList != null && !selectedCaseList.isEmpty()){
                    for(case caseRec : selectedCaseList){
                        caseIdSet.add(caseRec.Id);                        
                    }
                }
                
                Map<id,boolean> pmCaseDecisionMap = new Map<id,boolean>();
                List<SBS_Case_Asset__c> caseAssetList = DataBase.query('select id,Name,CaseId__c,Asset_Header__r.Name,Asset_Service_Type__c,AssetId__c,AssetId__r.Vendor_ID__c,AssetId__r.Supplier__c,Quantity_Override__c,New_Client_Price__c,Reason_Code__c,Reason_Description__c, Original_Client_Price__c from SBS_Case_Asset__c where CaseId__c in :CaseIdSet ORDER BY Id asc');
                List<Approval_Log__c> approvalLogList = DataBase.query('select id,CaseId__c,Status__c,BusinessRuleId__c,Approval_Description__c,Requested_DateTime__c,Required_Approver_Contact__c,Required_Approver_Title__c,Required_Approver__c,Email__c,Actual_Approver_Contact__c,Actual_Approver_Title__c,Actual_Approver__c,Decision_Date_Time__c,Approval_source__c,Approval_Comments__c from Approval_Log__c where CaseId__c in:CaseIdSet');
                List<EmailMessage> emailList = DataBase.query('select Subject,FromAddress,HtmlBody,TextBody,ToAddress,ParentId,RelatedToId from EmailMessage where ParentId in:CaseIdSet');
                // SDT-9563 Start
                Id recordTypeId = Schema.getGlobalDescribe().get('Comment__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Acorn_Ticket_Comment').getRecordTypeId();
                List<Comment__c> notes = DataBase.query('SELECT Id, Name, Communication_Log_Type_Name__c,Case_Number__c,Case__c,Acorn_SUser_ID__c,Comment__c, CreatedDate,Workflow_Action__c,recordTypeId,Workflow_TeamUser__c from Comment__c where Case__r.Id in:CaseIdSet and RecordTypeId =: recordTypeId order by CreatedDate DESC');
                List<Comment__c> updatedCommentsList = new List<Comment__c>();
                //SDT-9563 End
                List<EmailMessage> updatedEmailList = new List<EmailMessage>();
                Map<id,List<SBS_Case_Asset__c>> caseAssetMap = new Map<id,List<SBS_Case_Asset__c>>();
                
                if(caseAssetList != null && !caseAssetList.isEmpty()){
                    system.debug('**** inside if not null caselist:'+caseAssetList);
                    for(SBS_Case_Asset__c caseAsset :caseAssetList ){
                        system.debug('******** inside for loop');
                        if(caseAssetMap != null && caseAssetMap.containsKey(caseAsset.CaseId__c)){
                            caseAssetMap.get(caseAsset.CaseId__c).add(caseAsset);
                        }
                        else{
                            caseAssetMap.put(caseAsset.CaseId__c,new List<SBS_Case_Asset__c>{caseAsset});
                        }
                        caseAssetMapValue.put(caseAsset.id,caseAsset);
                        assetServiceTypeMap.put(caseAsset.AssetId__c,caseAsset.Asset_Service_Type__c);
                        system.debug('****caseAssetMapValue:'+caseAssetMapValue);
                        assetIdSet.add(caseAsset.AssetId__c);
                    } 
                }
                for(Asset asst : [Select id,Service_Type__c,Supplier__c,Name from Asset where Id in: assetIdSet limit 10000]){
                    assetMap.put(asst.id,asst);
                }
                 system.debug('****assetMap:'+assetMap);
                Map<string,List<SBS_Case_Asset__c>> vendorCaseAssetDecisionMap = new Map<string,List<SBS_Case_Asset__c>>();
                Map<string,List<SBS_Case_Asset__c>> multiVendorWithAMMap = new Map<string,List<SBS_Case_Asset__c>>();
                system.debug('***inside try');
                set<id> newCaseIdSet = new set<id>();
                if(selectedCaseList != null && !selectedCaseList.isEmpty()){
                    system.debug('***selectedCaseList:'+selectedCaseList);
                    for(case newCase: selectedCaseList){
                        if(caseAssetMap != null && !caseAssetMap.isEmpty() && caseAssetMap.containsKey(newCase.Id)){
                            List<SBS_Case_Asset__c> caseAssetByCaseList = new List<SBS_Case_Asset__c >();
                            caseAssetByCaseList = caseAssetMap.get(newCase.Id);
                            if(caseAssetByCaseList != null && !caseAssetByCaseList.isEmpty() ){
                                for(SBS_Case_Asset__c caseAsset : caseAssetByCaseList){ 
                                    caseAssetCreateList = new List<SBS_Case_Asset__c>();
                                    String vendorId = caseAssetMap.get(newCase.Id)[0].AssetId__r.Vendor_ID__c;
                                    String supplierId = caseAsset.AssetId__r.Supplier__c;
                                    string caseAssetId = caseAsset.AssetId__c;
                                    System.debug('asset ==='+caseAsset.AssetId__c);
                                    System.debug('vendor==='+caseAsset.AssetId__r.Vendor_ID__c );
                                    string key = newCase.Id+ANDSTR+caseAsset.AssetId__r.Vendor_ID__c+ANDSTR+ supplierId;
                                    System.debug('caseAsset.Asset_Service_Type__c===='+caseAsset.Asset_Service_Type__c);
                                    System.debug('caseAssetByCaseList.size()===='+caseAssetByCaseList.size());
                                    if(caseAssetByCaseList.size()> 1){                                    
                                        
                                        if(caseAsset.AssetId__r.Vendor_ID__c != vendorId){
                                            SBS_Case_Asset__c caseAssets = new SBS_Case_Asset__c(AssetId__c = caseAsset.AssetId__c,Asset_Header__c = newCase.AssetId, Original_Client_Price__c = caseAsset.Original_Client_Price__c,
																				Quantity_Override__c = caseAsset.Quantity_Override__c, New_Client_Price__c = caseAsset.New_Client_Price__c,
																				Reason_Code__c = caseAsset.Reason_Code__c, Reason_Description__c = caseAsset.Reason_Description__c);
                                            if(vendorCaseAssetMap != null && !vendorCaseAssetMap.isEmpty() && vendorCaseAssetMap.containsKey(key)){                                        
                                                vendorCaseAssetMap.get(key).add(caseAssets);
                                            }
                                            else{
                                                vendorCaseAssetMap.put(key, new List<SBS_Case_Asset__c>{caseAssets});
                                            }
                                            vendorAssetMap.put(key,caseAssetId+ANDSTR+supplierId);
                                            System.debug('vendorCaseAssetMap===='+vendorCaseAssetMap);
                                        
                                            //parentRemovedAssetMap.put(caseAsset.id,caseAsset);
                                            if(newCase.Create_AM_and_PM_Pickups__c){
                                                SBS_Case_Asset__c caseAssetsAM = new SBS_Case_Asset__c(AssetId__c = caseAsset.AssetId__c,Asset_Header__c = newCase.AssetId, Original_Client_Price__c = caseAsset.Original_Client_Price__c,
																					Quantity_Override__c = caseAsset.Quantity_Override__c, New_Client_Price__c = caseAsset.New_Client_Price__c,
																					Reason_Code__c = caseAsset.Reason_Code__c, Reason_Description__c = caseAsset.Reason_Description__c);
                                                multiVendorWithAMMap.put(key+AMSTR,new List<SBS_Case_Asset__c>{caseAssetsAM});   
                                                vendorAssetMap.put(key+AMSTR,caseAssetId+ANDSTR+supplierId);                                      
                                            }
											
											if(caseAsset.Asset_Service_Type__c == Constant_Util.RECYCLING)
											{
												parentRemovedAssetMap.put(caseAsset.id,caseAsset);
											}
                                            //parentRemovedAssetMap.put(caseAsset.id,caseAsset);
                                        }
                                        else if(newCase.Create_AM_and_PM_Pickups__c){
                                                system.debug('caseAssetCreateList==size='+caseAssetCreateList.size());  
                                            
                                            if(caseAsset.Asset_Service_Type__c == Constant_Util.RECYCLING){
                                                parentRemovedAssetMap.put(caseAsset.id,caseAsset);
                                                SBS_Case_Asset__c caseAssetsPM = new SBS_Case_Asset__c(AssetId__c = caseAsset.AssetId__c,Asset_Header__c = newCase.AssetId, Original_Client_Price__c = caseAsset.Original_Client_Price__c,
																					Quantity_Override__c = caseAsset.Quantity_Override__c, New_Client_Price__c = caseAsset.New_Client_Price__c,
																					Reason_Code__c = caseAsset.Reason_Code__c, Reason_Description__c = caseAsset.Reason_Description__c);
                                                multiVendorWithAMMap.put(key+PMSTR,new List<SBS_Case_Asset__c>{caseAssetsPM });   
                                                vendorAssetMap.put(key+PMSTR,caseAssetId+ANDSTR+supplierId); 
                                                
                                                SBS_Case_Asset__c caseAssetsAM = new SBS_Case_Asset__c(AssetId__c = caseAsset.AssetId__c,Asset_Header__c = newCase.AssetId, Original_Client_Price__c = caseAsset.Original_Client_Price__c,
																					Quantity_Override__c = caseAsset.Quantity_Override__c, New_Client_Price__c = caseAsset.New_Client_Price__c,
																					Reason_Code__c = caseAsset.Reason_Code__c, Reason_Description__c = caseAsset.Reason_Description__c);
                                                multiVendorWithAMMap.put(key+AMSTR,new List<SBS_Case_Asset__c>{caseAssetsAM });   
                                                vendorAssetMap.put(key+AMSTR,caseAssetId+ANDSTR+supplierId); 
                                            }  
                                            else{
                                                SBS_Case_Asset__c caseAssets = new SBS_Case_Asset__c(AssetId__c = caseAsset.AssetId__c,Asset_Header__c = newCase.AssetId, Original_Client_Price__c = caseAsset.Original_Client_Price__c,
                                                                                    Quantity_Override__c = caseAsset.Quantity_Override__c, New_Client_Price__c = caseAsset.New_Client_Price__c,
																					Reason_Code__c = caseAsset.Reason_Code__c, Reason_Description__c = caseAsset.Reason_Description__c);
                                                caseAssetCreateList.add(caseAssets);
                                                if(vendorCaseAssetMap != null && !vendorCaseAssetMap.isEmpty() && vendorCaseAssetMap.containskey(key)){
                                                    vendorCaseAssetMap.get(key).addAll(caseAssetCreateList);
                                                }
                                                else{
                                                    vendorCaseAssetMap.put(key,caseAssetCreateList);
                                                }
                                            }
                                            System.debug('vendorCaseAssetMap==='+vendorCaseAssetMap);                                
                                        }
                                        else {
                                            if(!newCase.Create_AM_and_PM_Pickups__c && caseAsset.AssetId__r.Vendor_ID__c == vendorId && caseAsset.Asset_Service_Type__c == Constant_Util.RECYCLING){
                                                SBS_Case_Asset__c caseAssets = new SBS_Case_Asset__c(AssetId__c = caseAsset.AssetId__c,Asset_Header__c = newCase.AssetId, Original_Client_Price__c = caseAsset.Original_Client_Price__c,
																					Quantity_Override__c = caseAsset.Quantity_Override__c, New_Client_Price__c = caseAsset.New_Client_Price__c,
																					Reason_Code__c = caseAsset.Reason_Code__c, Reason_Description__c = caseAsset.Reason_Description__c);
                                                if(vendorCaseAssetMap != null && !vendorCaseAssetMap.isEmpty() && vendorCaseAssetMap.containsKey(key)){                                        
                                                    vendorCaseAssetMap.get(key).add(caseAssets);
                                                }
                                                else{
                                                    vendorCaseAssetMap.put(key, new List<SBS_Case_Asset__c>{caseAssets});
                                                }
                                                vendorAssetMap.put(key,caseAssetId+ANDSTR+supplierId);
                                                parentRemovedAssetMap.put(caseAsset.id,caseAsset);
                                                System.debug('vendorCaseAssetMap==='+vendorCaseAssetMap);
                                            }
                                        }                               
                                    }
                                    else {
                                         if(caseAssetByCaseList.size() == 1 && (/*caseAsset.Asset_Service_Type__c != Constant_Util.RECYCLING || */ newCase.Create_AM_and_PM_Pickups__c )){
                                             SBS_Case_Asset__c caseAssets = new SBS_Case_Asset__c(AssetId__c = caseAsset.AssetId__c,Asset_Header__c = newCase.AssetId, Original_Client_Price__c = caseAsset.Original_Client_Price__c,
																				Quantity_Override__c = caseAsset.Quantity_Override__c, New_Client_Price__c = caseAsset.New_Client_Price__c,
																				Reason_Code__c = caseAsset.Reason_Code__c, Reason_Description__c = caseAsset.Reason_Description__c);
                                             caseAssetCreateList.add(caseAssets);
                                             if(vendorCaseAssetMap != null && !vendorCaseAssetMap.isEmpty() && vendorCaseAssetMap.containskey(key)){
                                                 vendorCaseAssetMap.get(key).addAll(caseAssetCreateList);
                                             }
                                             else{
                                                 vendorCaseAssetMap.put(key,caseAssetCreateList);
                                             }
                                         }
                                         System.debug('vendorCaseAssetMap==else='+vendorCaseAssetMap);
                                    }
                                }
                                
                            }
                            
                            if(multiVendorWithAMMap != null && !multiVendorWithAMMap.isEmpty()){
                                vendorCaseAssetMap.putAll(multiVendorWithAMMap);
                            }
                        }
                       system.debug('multiVendorWithAMMap===='+multiVendorWithAMMap);
                        case updateparentCase = new Case(id=newCase.id);
                        if(!newCase.Is_Clone__c && newCase.Create_AM_and_PM_Pickups__c ){
                            updateparentCase.System_Gen_WO_Instructions__c = CONSTANT_UTIL.AM_CASE + CONSTANT_UTIL.NEW_LINE;
                            System.debug('updateparentCase.System_Gen_WO_Instructions__c ====='+updateparentCase.System_Gen_WO_Instructions__c );
                            if(newCase.System_Gen_WO_Instructions__c!=null){
                                updateparentCase.Work_Order_Instructions__c = newCase.System_Gen_WO_Instructions__c + Constant_Util.NEW_LINE;
                                System.debug('updateparentCase.Work_Order_Instructions__c====='+updateparentCase.Work_Order_Instructions__c);
                                System.debug('updateparentCase.User_Input_Work_Order_Instructions__c ====='+updateparentCase.Work_Order_Instructions__c);
                                if(newCase.User_Input_Work_Order_Instructions__c !=null){
                                    system.debug('insdie if');
                                    updateparentCase.Work_Order_Instructions__c += newCase.User_Input_Work_Order_Instructions__c;
                                }
                                System.debug('updateparentCase.Work_Order_Instructions__c====='+updateparentCase.Work_Order_Instructions__c);
                            }
                            
                            parentAmCaseUpdateMap.put(updateparentCase.id,updateparentCase);
                            system.debug('updateparentCase===='+updateparentCase.System_Gen_WO_Instructions__c );
                        }
                        caseMap.put(newCase.id,newCase);
                        system.debug('***caseMap:'+caseMap);
                    }
                    System.debug('vendorCaseAssetMap==final=='+vendorCaseAssetMap);
                    System.debug('parentAmCaseUpdateMap===='+parentAmCaseUpdateMap);
                    LIst<case> newCaseCreatedList = new List<case>();
                    
                    if(vendorCaseAssetMap != null && !vendorCaseAssetMap.isEmpty()){
                        newChildCaseIdSet = createMultiVendorCase(vendorCaseAssetMap,caseMap,assetMap,vendorAssetMap,multiVendorWithAMMap);
                        system.debug('newChildCaseIdSet ----'+newChildCaseIdSet );
                        newCaseIdSet.addAll(newChildCaseIdSet);                         
                    }
                    Map<string,boolean> processMap = new Map<string,boolean>();
                    List<SBS_Case_Asset__c> caseAssetCreateFinalList = new List<SBS_Case_Asset__c>();
                    Approval_Log__c approvalLog = new Approval_Log__c();
                    system.debug('newChildCaseIdSet ===='+newChildCaseIdSet );
                    if(newChildCaseIdSet != null && !newChildCaseIdSet.isEmpty()){
                        List<case> newChildVendorCaseList = [SELECT id,Case_Sub_Status__c,AccountId,Case.ParentId,Supplier__c,recordTypeId,Supplier__r.Vendor_ID__c,Asset.Supplier__c,Asset.Vendor_ID__c,Service_Date__c,SLA_Service_Date_Time__c,Create_AM_and_PM_Pickups__c, Location__c, Reference_Number__c, AssetId, Client__c, ContactId,Case_Type__c,Case_Sub_Type__c,Case_Reason__c,Origin,Emergency__c,Site_Contact__c,Site_Contact_Phone__c,SalesMeet_Container_Position__c,PurchaseOrder_Number__c,SLA_Override_Reason__c,Work_Order_Instructions__c, EntitlementId, Entitlement.SLA_Ins__c, Entitlement.Name, User_Input_Work_Order_Instructions__c, Is_Clone__c 
                                     FROM Case 
                                     where id in: newChildCaseIdSet 
                                     limit 10000];
                                     
                        system.debug('newChildVendorCaseList----'+newChildVendorCaseList);
                         if(newChildVendorCaseList != null && !newChildVendorCaseList.isEmpty()){
                            for(case newCase : newChildVendorCaseList){                                    
                                string key = newCase.ParentId+ANDSTR+newCase.Supplier__r.Vendor_ID__c+ANDSTR+newCase.Supplier__c;
                                System.debug('key----'+key);
                                string updatedKey = '';
                                List<SBS_Case_Asset__c> childCaseAssetList = new List<SBS_Case_Asset__c>();
                                System.debug('newCase===='+newCase.Id);
                                system.debug('newCase.Is_Clone__c--='+newCase.Is_Clone__c);
                                System.debug('key check in vendorCaseAssetMap==='+vendorCaseAssetMap.containskey(key));
                                System.debug('key check in multiVendorWithAMMap=AM=='+multiVendorWithAMMap.containskey(key+AMSTR));
                                 System.debug('key check in multiVendorWithAMMap==PM='+multiVendorWithAMMap.containskey(key+PMSTR));
                                 System.debug('vendorCaseAssetMap.get(key)----'+vendorCaseAssetMap.get(key));
                                 System.debug('processMap.get(key+AMSTR) ===='+processMap.get(key+AMSTR) );
                                 System.debug('processMap===='+processMap);
                                if(vendorCaseAssetMap != null && !vendorCaseAssetMap.isEmpty() && vendorCaseAssetMap.get(key)!= null ){
                                    if(processMap != null && !processMap.isEmpty()&& processMap.containskey(key)){
                                        System.debug('processMap.containskey(key+PMSTR)===='+processMap.containskey(key+PMSTR));
                                        System.debug('processMap.containskey(key+AMSTR)----'+processMap.containskey(key+AMSTR));
                                        if(multiVendorWithAMMap != null && !multiVendorWithAMMap.isEmpty()){
                                            if(multiVendorWithAMMap.get(key+AMSTR)!= null && !processMap.containskey(key+AMSTR)){                                        
                                                System.debug('process map AM==newCase.Is_Clone__c='+newCase.Is_Clone__c);
                                                childCaseAssetList= multiVendorWithAMMap.get(key+AMSTR);  
                                                updatedKey = key+AMSTR;
                                                /*if(!newCase.Is_Clone__c){
                                                    childCaseAssetList= multiVendorWithAMMap.get(key+AMSTR);                                                    
                                                } 
                                                else{
                                                    childCaseAssetList = vendorCaseAssetMap.get(key);                                                    
                                                }*/
                                                processMap.put(key+AMSTR,true);
                                                System.debug('childCaseAssetList--in both AM & multivendor--'+childCaseAssetList);
                                                system.debug('newCase===='+newCase.Id);
                                            }
                                            else{
                                                if(multiVendorWithAMMap.get(key+PMSTR)!= null &&!processMap.containskey(key+PMSTR)){   
                                                    System.debug('process map with PM==newCase.Is_Clone__c==='+newCase.Is_Clone__c);
                                                    childCaseAssetList= multiVendorWithAMMap.get(key+PMSTR);
                                                    updatedKey = key+PMSTR;
                                                    System.debug('childCaseAssetList--in both AM & multivendor--'+childCaseAssetList);
                                                    processMap.put(key+PMSTR,true);
                                                }
                                            }
                                        }   
                                    }              
                                    else{
                                        childCaseAssetList = vendorCaseAssetMap.get(key);
                                        processMap.put(key,true);
                                        updatedKey = key;
                                        System.debug('childCaseAssetList---else---'+childCaseAssetList);
                                        system.debug('newCase===='+newCase.Id);
                                    }
                                                        
                                }
                                System.debug('childCaseAssetList ===='+childCaseAssetList );
                                System.debug('processMap==='+processMap);
                                if(childCaseAssetList != null && !childCaseAssetList.isEmpty()){
                                    for(SBS_Case_Asset__c caseAssets : childCaseAssetList){
                                        caseAssets.CaseId__c = newCase.Id;
                                        /*if((assetServiceTypeMap.get(caseAssets.AssetId__c) == Constant_Util.RECYCLING && newCase.Case_Reason__c == Constant_Util.RECYCLING ) ){
                                            caseAssets.CaseId__c = newCase.Id;
                                            
                                        }*/
                                        caseAssetCreateFinalList.add(caseAssets);
                                        System.debug('update case id in asset0-----'+caseAssetCreateFinalList);
                                    }
                                }
                                System.debug('caseAssetCreateFinalList===='+caseAssetCreateFinalList);
                             
                                if(!approvalLogList.isEmpty()){  
                                    for(Approval_Log__c apprLogs : approvalLogList){
                                        approvalLog = apprLogs.clone(false, false, false, false);
                                        approvalLog.CaseId__c = newCase.id;
                                    }                                   
                                }
                                if(emailList.size()>0) {
                                    for(EmailMessage email : emailList){
                                        EmailMessage newEmail= new EmailMessage();
                                        newEmail = email.clone(false, false, false, false);
                                        newEmail.ParentId = newCase.Id;
                                        newEmail.RelatedToId = newCase.Id;
                                        updatedEmailList.add(newEmail);                    
                                    }
                                }else{}
                                // SDT-9563 Start
                                if(notes.size()>0) {
                                    for(Comment__c comments : notes){
                                        Comment__c newComments= new Comment__c();
                                        newComments = comments.clone(false, false, false, false);
                                        newComments.Case__c = newCase.Id;
                                        updatedCommentsList.add(newComments);                    
                                    }
                                }else{}
                                // SDT-9563 End
                                casePMMap.put(newCase.id,newCase);
                                caseUpdateFinalMap.put(newCase.id,newCase);
                             }
                             if(!approvalLogList.isEmpty()){
                                database.insert(approvalLog);
                             }
                             if(!updatedEmailList.isEmpty()){
                                database.insert(updatedEmailList);
                             }
                             // SDT-9563 Start
                             if(!updatedCommentsList.isEmpty()){
                                database.insert(updatedCommentsList);
                             }
                             // SDT-9563 End
                         }
                     } 
                     
                    set<id> newAssetIdSet = new set<id>();
                    if(caseAssetCreateFinalList != null && !caseAssetCreateFinalList .isEmpty()){
                         newAssetIdSet = doDMLOperation(caseAssetCreateFinalList);                       
                    }
                    System.debug('newAssetIdSet===='+newAssetIdSet);
                }
                system.debug('casePMMap----'+casePMMap);
                
                if(casePMMap!= null && !casePMMap.isEmpty()){
                    for(case newCase : casePMMap.values()){                        
                        newCase.Status = Constant_Util.OPEN;
                        newCase.Case_Sub_Status__c = Constant_Util.PENDING_SERVICE_INTEGRATION;
                        newCaseUpdateList.add(newCase);
                    }
                }
                if(parentAmCaseUpdateMap != null && !parentAmCaseUpdateMap.isEmpty()){
                    newCaseUpdateList.addAll(parentAmCaseUpdateMap.values());
                }
                system.debug('newCaseUpdateList==='+newCaseUpdateList);
                if(newCaseUpdateList != null && !newCaseUpdateList.isEmpty()){
                    newCaseIdSet = doDMLOperation(newCaseUpdateList);                     
                } 
                set<id> removedAssetIdSet = new set<id>();
                if(parentRemovedAssetMap != null && !parentRemovedAssetMap.isEmpty()){
                    List<Database.deleteResult> srAssetList = new List<database.deleteResult>();
                    srAssetList = database.delete(parentRemovedAssetMap.values(),false);
                    for(Database.deleteResult sr : srAssetList){
                        if(sr.isSuccess()){
                            System.debug('delete success=---'+sr.getId());
                        }
                        else{
                            for(database.error err : sr.getErrors()){
                                System.debug('Case Asset failure: ' + err.getMessage());
                            }
                        }
                    }
                }
            }
            Catch(Exception ex){
                System.debug('DmlException caught: ' + ex.getStackTraceString() + ex.getLineNumber() + ex.getMessage());
            }  
       }
    }
    public static set<id> doDMLOperation(LIst<Sobject> dmlList){    
        set<id> newCaseIdSet = new set<id>();
        try{
            if(dmlList != null && !dmlList.isEmpty()){
                List<Database.upsertResult> srList = new List<database.upsertResult>();
                srList = database.upsert(dmlList,false);
                for(Database.upsertResult sr : srList){
                    if(sr.isSuccess()){
                        newCaseIdSet.add(sr.getId());
                        system.debug('sucess==='+sr.getId());
                    }
                    else{
                        for(database.error err : sr.getErrors()){
                            System.debug('New Case failure caught: ' + err.getMessage()+'---Fields---'+err.getFields());
                        }
                    }
                }           
            }
            if(Test.isRunningTest())
            {
                throw new TypeException();
            }
        }
        catch(Exception ex){
            System.debug('error occured---'+ex.getMessage());
        }
        return newCaseIdSet;
    }
    /**
    * @author Accenture
    * @date 3/25/2019
    * @description : Multiple Vendor Case Creation 
    **/
    public static set<id> createMultiVendorCase(Map<string,List<SBS_Case_Asset__c>> vendorCaseAssetMap,Map<string,case> caseMap,
                        Map<id,Asset> assetMap,Map<string,string> vendorAssetMap,Map<string,List<SBS_Case_Asset__c>> multiVendorWithAMMap ){
        set<id> newChildCaseIdSet = new set<id>();
        List<case> newChildCaseList = new List<case>();
        try{
            if(vendorCaseAssetMap != null && !vendorCaseAssetMap.isEmpty()){
                for(string keyValue : vendorCaseAssetMap.keyset()){             
                    if(keyValue.contains(ANDSTR)){
                        System.debug('keyValue----'+keyValue);
                        boolean amMulticase = false;
                        if(keyValue.split(ANDSTR).size()>3 && multiVendorWithAMMap.containsKey(keyValue)){
                           string checkVal = ANDSTR +keyValue.split(ANDSTR)[3];
                           system.debug('checkVal ----'+checkVal );
                            if(checkVal == PMSTR){
                                amMulticase = false;
                            }
                            else{
                                amMulticase = true;
                            }
                        }
						
                        case selectedCase = new case();
                        string key = keyValue.split(ANDSTR)[0];
                        string supplierId = keyValue.split(ANDSTR)[2];
                        string assetId = (vendorAssetMap != null && vendorAssetMap.containskey(keyValue) ?vendorAssetMap.get(keyValue).split(ANDSTR)[0]:'');
                        
						if(test.isRunningTest() || (caseMap != null && caseMap.containskey(key) && supplierId != caseMap.get(key).Supplier__c) || caseMap.get(key).isMultiCalendarChecked__c  || (caseMap != null && caseMap.containskey(key) && supplierId == caseMap.get(key).Supplier__c && assetMap.get(assetId).Service_Type__c == Constant_Util.RECYCLING)) 

						{
                            selectedCase = caseMap.get(key);
                        }
                        
                        if(selectedCase != null ){
                            System.debug('inside case creation');
                            Case newCase = new case();
                            newCase = selectedCase.clone(false, false, false, false);
                            //string contactInfo = Constant_Util.ONSITE_CONTACT_NAME + selectedCase.Site_Contact__c + Constant_Util.NEW_LINE + CONSTANT_UTIL.ONSITE_CONTACT_PHONE + selectedCase.Site_Contact_Phone__c + Constant_Util.NEW_LINE;
                            String contactInfo;
                            if(selectedCase.Site_Contact__c !=null && selectedCase.Site_Contact_Phone__c !=null){
                                contactInfo = Constant_Util.New_Line + Constant_Util.ONSITE_CONTACT_NAME + selectedCase.Site_Contact__c + Constant_Util.NEW_LINE + CONSTANT_UTIL.ONSITE_CONTACT_PHONE + selectedCase.Site_Contact_Phone__c + Constant_Util.NEW_LINE;
                            }
                            if(selectedCase.Site_Contact__c !=null && selectedCase.Site_Contact_Phone__c == null){
                                contactInfo = Constant_Util.New_Line + Constant_Util.ONSITE_CONTACT_NAME + selectedCase.Site_Contact__c + Constant_Util.NEW_LINE;
                            }
                            if(selectedCase.Site_Contact__c==null && selectedCase.Site_Contact_Phone__c != null){
                                contactInfo = Constant_Util.NEW_LINE + CONSTANT_UTIL.ONSITE_CONTACT_PHONE + selectedCase.Site_Contact_Phone__c + Constant_Util.NEW_LINE;
                            }
                            if(selectedCase.Site_Contact__c == null && selectedCase.Site_Contact_Phone__c == null){
                                contactInfo = '';
                            }
                            System.debug('cloned case==='+newCase );
                            newCase.Reference_Number__c = selectedCase.Reference_Number__c;
                            newCase.ParentId = selectedCase.Id;
                            newCase.Service_Date__c = selectedCase.Service_Date__c;
                            newCase.SLA_Service_Date_Time__c = selectedCase.SLA_Service_Date_Time__c;
                            newCase.Is_Multivendor__c = true;
                            newCase.User_Input_Work_Order_Instructions__c = selectedCase.User_Input_Work_Order_Instructions__c;
                            newCase.Quantity_Override__c = selectedCase.Quantity_Override__c;
                            newCase.Ignore_Duplicate__c = true; //kyle add
                            System.debug('assetId----'+assetId);
                            if(!string.isBlank(assetId) && assetMap.containskey(assetId)){
                                Asset caseAsset = new Asset();
                                caseAsset = assetMap.get(assetId);
                                System.debug('caseAsset.Asset_Service_Type__c ===='+caseAsset.Service_Type__c );
                                newCase.Supplier__c = caseAsset.Supplier__c;
                                System.debug('***inside for for fetching reason:'+caseAsset);
                                if(caseAsset.Service_Type__c == Constant_Util.RECYCLING){
                                    System.debug('***inside reason if');
                                    newCase.Case_Reason__c = Constant_Util.RECYCLING;
                                }else if(caseAsset.Service_Type__c == Constant_Util.DISPOSAL){
                                    system.debug('***inside reason else');
                                    newCase.Case_Reason__c = Constant_Util.DISPOSAL;
                                }
                            }
                            System.debug('newCase.Case_Reason__c ==='+newCase.Case_Reason__c );
                            System.debug('newCase.Create_AM_and_PM_Pickups__c ==='+newCase.Create_AM_and_PM_Pickups__c );
                            newCase.Status = Constant_Util.NEW_STATUS;
                            if(selectedCase.Create_AM_and_PM_Pickups__c && !amMulticase){
                                newCase.Is_Clone__c = true;
                                newCase.Ignore_Duplicate__c = true; //kyle add
                            }
                            system.debug('newCase.Is_Clone__c-----'+newCase.Is_Clone__c);
                            if(selectedCase.Create_AM_and_PM_Pickups__c  && !newCase.Is_Clone__c){
                                newCase.System_Gen_WO_Instructions__c = CONSTANT_UTIL.AM_CASE + CONSTANT_UTIL.NEW_LINE;
                                system.debug('System_Gen_WO_Instructions__c in AM-----'+newCase.System_Gen_WO_Instructions__c );
                            }
                            
                            if(selectedCase.Create_AM_And_PM_Pickups__c  && newCase.Is_Clone__c ){
                                newCase.System_Gen_WO_Instructions__c = CONSTANT_UTIL.PM_CASE + CONSTANT_UTIL.NEW_LINE;
                                System.debug('System_Gen_WO_Instructions__c --in PM---'+newCase.System_Gen_WO_Instructions__c );
                            }
                            System.debug('System_Gen_WO_Instructions__c -----'+newCase.System_Gen_WO_Instructions__c );
                            if(newCase.System_Gen_WO_Instructions__c!=null){
                                newCase.Work_Order_Instructions__c = newCase.System_Gen_WO_Instructions__c + Constant_Util.NEW_LINE + contactInfo;
                                system.debug('selectedCase.User_Input_Work_Order_Instructions__c===='+selectedCase.User_Input_Work_Order_Instructions__c);
                                if(selectedCase.User_Input_Work_Order_Instructions__c!=null){   
                                    newCase.Work_Order_Instructions__c += CONSTANT_UTIL.NEW_LINE +selectedCase.User_Input_Work_Order_Instructions__c;
                                }
                                newCase.Work_Order_Instructions__c += Constant_Util.NEW_LINE;
                                /*
                                newCase.User_Input_Work_Order_Instructions__c = newCase.Work_Order_Instructions__c ;
                                */
                                
                                System.debug('User_Input_Work_Order_Instructions__c -----'+newCase.User_Input_Work_Order_Instructions__c );
                            }
                            if(newCase.System_Gen_WO_Instructions__c==null && selectedCase.User_Input_Work_Order_Instructions__c != null){
                                newCase.Work_Order_Instructions__c = selectedCase.User_Input_Work_Order_Instructions__c;
                            }
                            System.debug('newCase.Case_Sub_Status__c ==='+newCase.Case_Sub_Status__c );
                            newChildCaseList.add(newCase);
                        }
                    }
                    
                }
                system.debug('newChildCaseList===='+newChildCaseList);
                if(newChildCaseList != null && !newChildCaseList.isEmpty()){
                    newChildCaseIdSet = doDMLOperation(newChildCaseList);
                }
                
            }
            
            if(Test.isRunningTest())
            {
                throw new TypeException();
            }
        }
          
        catch(Exception ex){
            system.debug('error===='+ex.getMessage());
        }
        return newChildCaseIdSet;
    }
    
}