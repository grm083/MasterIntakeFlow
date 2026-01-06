/**
* @author Accenture
* @date 4/07/2019
* @description : Controller class for ETAWindowComponent lightning component
**/
public Without Sharing class ETAWindowController {

    /**
    * @author Accenture
    * @date 4/07/2019
    * @description : Wrapper class to return data to the ETAWindowComponent lightning component
    **/
    public inherited sharing class StatusWrap{
        @AuraEnabled public string ETAMessage;
        @AuraEnabled public List<StatusWrapper> dataWrapETAServicesLst = new List<StatusWrapper>();
    }    
    
    /**
    * @author Accenture
    * @date 3/25/2019
    * @description : method to display status data to the ETAWindowComponent lightning component
    **/
    @AuraEnabled
   	public static StatusWrap getStatusData(Id caseId, Id assetHeaderId){
        StatusWrap wrap = new StatusWrap();
        string response;
        Id assetId;
        string assetName;
        try {
            Case caseRec = [SELECT CaseNumber, Location__c, Location__r.tz__Timezone_SFDC__c, Location__r.tz__Timezone__c, Tracking_Number__c FROM Case WHERE Id = :CaseId]; 
            Asset assetHeader = [SELECT Id, Name, Acorn_SBID__c FROM Asset WHERE Id = :assetHeaderId];
            assetId = assetHeader != null && assetHeader.Acorn_SBID__c != null ? assetHeader.Id : null;
            assetName = assetHeader.Name;
            if(assetId == null){
                Asset assetObj = [SELECT Id, Acorn_SBID__c FROM Asset WHERE RootAssetId =: assetHeaderId AND Is_Active__c = true
                                  AND RecordType.Name =: Constant_Util.SERVICE_DETAIL AND Is_Core_Service__c = true LIMIT 1];
                assetId = assetObj != null && assetObj.Acorn_SBID__c != null ? assetObj.Id : null;
            }
            if(assetId == null){
                wrap.ETAMessage = Constant_Util.NO_ETA; 
            } else{
                response = IntegrationHandlerUtil.getMetadataDetails(Constant_Util.HAULER_STATUS, assetId);

                if(Test.isRunningTest()){
                    response = MockETAStatusResponse.ETA_STATUS_MOCK_RESPONSE;
                } 
                if(response == null || response == Constant_Util.EMPTY_STRING){
                    wrap.ETAMessage = Constant_Util.NO_ETA;
                } else {
                    Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response);
                    Map<String,Object> dataMap = (Map<String,Object>)results.get(Constant_Util.DATA);
               
                    if(dataMap != null){
                        //To get current ETA status service list
                        List<Object> currentServiceLst = (List<Object>)dataMap.get(Constant_Util.PRESENT);
                        wrap.dataWrapETAServicesLst.addAll(buildStausWrapper(currentServiceLst,caseRec,Constant_Util.PRESENT, assetName));
                        
                        //To get Past status service list
                        List<Object> pastServiceLst = (List<Object>)dataMap.get(Constant_Util.PAST);
                        wrap.dataWrapETAServicesLst.addAll(buildStausWrapper(pastServiceLst,caseRec,Constant_Util.PAST, assetName));
                        
                        //To get Future status service list
                        List<Object> futureServiceLst = (List<Object>)dataMap.get(Constant_Util.FUTURE);
                        wrap.dataWrapETAServicesLst.addAll(buildStausWrapper(futureServiceLst,caseRec,Constant_Util.FUTURE, assetName));
                    }
                    if(wrap.dataWrapETAServicesLst == null || wrap.dataWrapETAServicesLst.isEmpty()){
                        wrap.ETAMessage = Constant_Util.NO_ETA;
                    }
                }
            }
            return wrap;
        } Catch(Exception ex){
            system.debug('Exception Occurred: '+ ex.getStackTraceString());
			return null;
		}
    }
    public Static List<StatusWrapper> buildStausWrapper(List<Object> statusLst, case caseRec, string status, string assetName) {
        List<StatusWrapper> sWrapLst = new List<StatusWrapper>();
        StatusWrapper sWrap;
        for (Object obj : statusLst) {
            map<String,Object> objMap = (map<String,Object>) obj;
            sWrap = new StatusWrapper();
            string From_ETA = (String)objMap.get(Constant_Util.FROM_TEXT);
            string To_ETA = (String)objMap.get(Constant_Util.TO);
            
            string strServiceDate = (String)objMap.get(Constant_Util.SERVICE_DATE);
            if(strServiceDate != null){
                sWrap.serviceDate = strServiceDate;
            }            
            string strRescheduleDate = (String)objMap.get(Constant_Util.RESCHEDULE_DATE);
            if(strRescheduleDate != null){
                sWrap.rescheduleDate = strRescheduleDate;
            }
			//Change for SDT-14080 - Commented Line
            //sWrap.serviceStatusDate = (String)objMap.get(Constant_Util.SERVICED_DATETIME);
            sWrap.assetName = (String)objMap.get(Constant_Util.SERVICE_COMP_TYPE); 
            sWrap.truckPosition = (String)objMap.get(Constant_Util.TRUCK_COMPLETED_STOP_NUMBER);
            sWrap.customerPosition = (String)objMap.get(Constant_Util.SERVICE_STOP_NUMBER);
            sWrap.serviceStatus = (String)objMap.get(Constant_Util.STATUS);
            sWrap.exceptionReason = (String)objMap.get(Constant_Util.SUB_STATUS);
            sWrap.woNumber = (String)objMap.get(Constant_Util.WO_NUMBER);
            sWrap.materialTypeName = (String)objMap.get(Constant_Util.MATERIAL_TYPE);
            sWrap.occurrenceType = (String)objMap.get(Constant_Util.SERVICE_OCCURRENCE_TYPE);
            sWrap.imageUrl = (String)objMap.get(Constant_Util.IMAGE_URL);
            sWrap.serviceOfferingDefinitionId = (Integer)objMap.get(Constant_Util.SID);
            
            string serviceComponentTypeName = (String)objMap.get(Constant_Util.SERVICE_COMP_TYPE);
            string issuePurposeTypeName = (String)objMap.get(Constant_Util.ISSUE_PURPOSE_TYPE);
            sWrap.woDescription = serviceComponentTypeName != null ? serviceComponentTypeName : Constant_Util.EMPTY_STRING
                	+Constant_Util.BLANKSPACE+issuePurposeTypeName != null ? issuePurposeTypeName : Constant_Util.EMPTY_STRING;
            sWrap.vendorCode = (String)objMap.get(Constant_Util.VENDOR_CODE);
            sWrap.vendorName = (String)objMap.get(Constant_Util.VENDOR_NAME);
            sWrap.scheduleType = (String)objMap.get(Constant_Util.SCHEDULE_NAME);
            sWrap.masUniqueId = (String)objMap.get(Constant_Util.MAS_NO);
            sWrap.vendorAccountNumber = (String)objMap.get(Constant_Util.VENDOR_ACC_NO);
            
			//Changes for SDT-14080 - Start 
            Datetime formattedSDate ;
            
            String servicedDT = (String)objMap.get(Constant_Util.SERVICED_DATETIME);
            
            try {
				if(servicedDT!=null)
				{
					formattedSDate = DateTime.valueOfGMT(servicedDT);    
				}
            }catch(Exception ex)
            {
				//UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
				//Keeping System.Debug until Exception logs are handled 
                System.Debug ('Error for Date '+ servicedDT  + ' Exception: ' + ex.getMessage()) ;
            }
            sWrap.serviceStatusDate=formattedSDate!=null? formattedSDate.format('MM/dd/yyyy hh:mm:ss a', caseRec.Location__r.tz__Timezone_SFDC__c  ) + ' ' + caseRec.Location__r.tz__Timezone__c :servicedDT;
            //Changes for SDT-14080 - End
			
            if(From_ETA != null && To_ETA != null) {
                Datetime formattedFrom = (DateTime)JSON.deserialize('"' + From_ETA + '"', DateTime.class);
                Datetime formattedTo = (DateTime)JSON.deserialize('"' + To_ETA + '"', DateTime.class);
				if(formattedFrom != null && formattedTo != null) {
                    sWrap.etaWindow = formattedFrom.format(Constant_Util.TIME_FORMAT, caseRec.Location__r.tz__Timezone_SFDC__c)+
                        			  Constant_Util.TO_WITH_SPACE+formattedTo.format(Constant_Util.TIME_FORMAT, caseRec.Location__r.tz__Timezone_SFDC__c)
                                      +Constant_Util.OPEN_BRACE+caseRec.Location__r.tz__Timezone__c+Constant_Util.CLOSE_BRACE;
                }
            } else {
				//Changes for SDT-14080 - Start 
				/*
            	String servicedDT = (String)objMap.get(Constant_Util.SERVICED_DATETIME);
				String endTime = servicedDT != null ? servicedDT.Substring(servicedDT.length()-11,servicedDT.length()-6)+
								 Constant_Util.BLANKSPACE+servicedDT.Substring(servicedDT.length()-2,servicedDT.length()) : null;
				sWrap.etaWindow = endTime != null ? Constant_Util.PICKUP_TEXT+endTime+Constant_Util.OPEN_BRACE
                    			  + caseRec.Location__r.tz__Timezone__c + Constant_Util.CLOSE_BRACE : null;
								  */
                sWrap.etaWindow = formattedSDate!=null ? Constant_Util.PICKUP_TEXT + formattedSDate.format(Constant_Util.TIME_FORMAT, caseRec.Location__r.tz__Timezone_SFDC__c)+Constant_Util.OPEN_BRACE
                    + caseRec.Location__r.tz__Timezone__c + Constant_Util.CLOSE_BRACE : null;                				
				//Changes for SDT-14080 - End 			
			}
            if(status == Constant_Util.PRESENT){
			   sWrap.isCurrentService = true;  
            }
            sWrapLst.add(sWrap); 
        }

        if(!sWrapLst.isEmpty() && status == Constant_Util.PRESENT){
            insertETAComments(sWrapLst,caseRec, assetName);
        }
        
        return sWrapLst;
    }
    

    /**
    * @author Accenture
    * @date 6/15/2020
    * @description : method to insert comments
    **/
    @AuraEnabled
    public static void insertETAComments(List<StatusWrapper> statusList, Case caseRecord, string assetName){
        List<Comment__c> commentList = new List<Comment__c>();
        Decimal acornUserId = [select Acorn_SUser_ID__c from User where ID =: System.UserInfo.getUserId()].Acorn_SUser_ID__c;
        String userName = System.UserInfo.getName();
        Id comRecId = Schema.getGlobalDescribe().get('Comment__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Acorn_Ticket_Comment').getRecordTypeId();
        try{
        for(StatusWrapper sw : statusList){
            Comment__c myComment = new Comment__c();
            myComment.Case__c = caseRecord.id;
            myComment.Case_Number__c = caseRecord.CaseNumber;
            myComment.Comment__c = 'Asset Header Name: ' + assetName + ', ETA Window: ' + sw.etaWindow + ', Truck Position: ' + sw.truckPosition + ', Customer Position: ' + sw.customerPosition + ', W/O Number: ' + sw.woNumber + ', SID: ' + sw.serviceOfferingDefinitionId + ', Material: ' + sw.materialTypeName;
            myComment.Acorn_Tracking_Number__c = caseRecord.Tracking_Number__c != null ? caseRecord.Tracking_Number__c : Constant_Util.EMPTY_STRING;
            //System.debug('Comment body -- ' + mycomment.Comment__c);
            myComment.Workflow_Action__c = '';
            myComment.Acorn_SUser_ID__c = acornUserId;
            myComment.Type__c = Constant_Util.OBJECT_CASE;
            myComment.Communication_Log_Type_Name__c = 'Internal';
            myComment.RecordTypeId = comRecId;
            myComment.Workflow_TeamUser__c = userName;
            commentList.add(myComment);
        }
        if(!commentList.isEmpty() && commentList!=null){
            insert commentList; //try catch
        }
    }
    catch(Exception e){
        system.debug('Exception Occurred: '+ e.getStackTraceString());
    }

    }

    
    

    /**
    * @author Accenture
    * @date 6/15/2020
    * @description : method to get Asset Headers for selection drop down
    **/
    @AuraEnabled
    public static List<assetWrapper> getAssetHeaders(Id caseId,boolean IsLocation){
        List<Asset> assetHeaders = new List<Asset>();
        List<assetWrapper> returnWrap = new List<assetWrapper>();
        try{
            if(!IsLocation){
                Case caseRec = [SELECT Id, Location__c, AssetId FROM Case WHERE Id = :caseId];
       			 if(!string.isBlank(caseRec.Location__c)){
            assetHeaders = [SELECT Id, Acorn_SBID__c, Name, Material_Type__c, Supplier__r.Parent_Vendor_ID__c,  Acorn_SID__c FROM Asset WHERE Location__c = : caseRec.Location__c AND Is_Active__c = true AND Service_Header_Id__c = null];
        }
            }else{ 
                assetHeaders = [SELECT Id, Acorn_SBID__c, Name, Material_Type__c, Supplier__r.Parent_Vendor_ID__c,  Acorn_SID__c FROM Asset WHERE Location__c = : caseId AND Is_Active__c = true AND Service_Header_Id__c = null];
             
            }
        
        assetWrapper aWrapBlank = new assetWrapper();
        aWrapBlank.assetLabel = System.Label.ETA_Default;
        aWrapBlank.assetValue = 'default'; 
        returnWrap.add(aWrapBlank);

        for(Asset a : assetHeaders){
            assetWrapper aWrap = new assetWrapper();
            aWrap.assetLabel = a.Name + ' - SID: ' + a.Acorn_SID__c + ' - Material: ' + a.Material_Type__c;
            aWrap.assetValue = string.valueOf(a.Id);
            returnWrap.add(aWrap);
        }

        return returnWrap;

        }catch(Exception e){
            system.debug('Exception Occurred: '+ e.getStackTraceString());
            return null;
        }
        
    }
	@AuraEnabled
    public static Boolean getManualInvocation(String caseId){
        Boolean isReportServiceIssue=false;
       List<Task> taskList = [SELECT Id, Is_Stop_Task_Creation__c FROM Task WHERE (Process__c =: Constant_Util.RESOLVE_SERV_ISSUE 
           OR Process__c =: Constant_Util.ESCAL_UNRESP_CON_VENDOR OR Process__c =: Constant_Util.ESCAL_UNRESP_CON_CUSTOMER) AND status =: Constant_Util.OPEN AND WhatId =: caseId];
       
        if(taskList != null && !taskList.isEmpty()){  
            System.debug('@@@taskList'+taskList);
            isReportServiceIssue = true;  
            }              
        return isReportServiceIssue;
    } 
    public inherited sharing  class assetWrapper{
        @AuraEnabled public string assetLabel;
        @AuraEnabled public string assetValue;
    }
    
    @AuraEnabled
   	public static StatusWrap getStatusDataLocation(Id caseId, Id assetHeaderId){
        StatusWrap wrap = new StatusWrap();
        string response;
        Id assetId;
        string assetName;
        try {
            Account caseRec = [SELECT  tz__Timezone_SFDC__c, tz__Timezone__c FROM Account WHERE Id = :CaseId]; 
            Asset assetHeader = [SELECT Id, Name, Acorn_SBID__c FROM Asset WHERE Id = :assetHeaderId];
            assetId = assetHeader != null && assetHeader.Acorn_SBID__c != null ? assetHeader.Id : null;
            assetName = assetHeader.Name;
            if(assetId == null){
                Asset assetObj = [SELECT Id, Acorn_SBID__c FROM Asset WHERE RootAssetId =: assetHeaderId AND Is_Active__c = true
                                  AND RecordType.Name =: Constant_Util.SERVICE_DETAIL AND Is_Core_Service__c = true LIMIT 1];
                assetId = assetObj != null && assetObj.Acorn_SBID__c != null ? assetObj.Id : null;
            }
            if(assetId == null){
                wrap.ETAMessage = Constant_Util.NO_ETA; 
            } else{
                response = IntegrationHandlerUtil.getMetadataDetails(Constant_Util.HAULER_STATUS, assetId);

                if(Test.isRunningTest()){
                    response = MockETAStatusResponse.ETA_STATUS_MOCK_RESPONSE;
                } 
                if(response == null || response == Constant_Util.EMPTY_STRING){
                    wrap.ETAMessage = Constant_Util.NO_ETA;
                } else {
                    Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response);
                    Map<String,Object> dataMap = (Map<String,Object>)results.get(Constant_Util.DATA);
               
                    if(dataMap != null){
                        //To get current ETA status service list
                        List<Object> currentServiceLst = (List<Object>)dataMap.get(Constant_Util.PRESENT);
                        wrap.dataWrapETAServicesLst.addAll(buildStausWrapperLocation(currentServiceLst,caseRec,Constant_Util.PRESENT, assetName));
                        
                        //To get Past status service list
                        List<Object> pastServiceLst = (List<Object>)dataMap.get(Constant_Util.PAST);
                        wrap.dataWrapETAServicesLst.addAll(buildStausWrapperLocation(pastServiceLst,caseRec,Constant_Util.PAST, assetName));
                        
                        //To get Future status service list
                        List<Object> futureServiceLst = (List<Object>)dataMap.get(Constant_Util.FUTURE);
                        wrap.dataWrapETAServicesLst.addAll(buildStausWrapperLocation(futureServiceLst,caseRec,Constant_Util.FUTURE, assetName));
                    }
                    if(wrap.dataWrapETAServicesLst == null || wrap.dataWrapETAServicesLst.isEmpty()){
                        wrap.ETAMessage = Constant_Util.NO_ETA;
                    }
                }
            }
            return wrap;
        } Catch(Exception ex){
            system.debug('Exception Occurred: '+ ex.getStackTraceString());
			return null;
		}
    }
    
     public Static List<StatusWrapper> buildStausWrapperLocation(List<Object> statusLst, Account caseRec, string status, string assetName) {
        List<StatusWrapper> sWrapLst = new List<StatusWrapper>();
        StatusWrapper sWrap;
        for (Object obj : statusLst) {
            map<String,Object> objMap = (map<String,Object>) obj;
            sWrap = new StatusWrapper();
            string From_ETA = (String)objMap.get(Constant_Util.FROM_TEXT);
            string To_ETA = (String)objMap.get(Constant_Util.TO);
            
            string strServiceDate = (String)objMap.get(Constant_Util.SERVICE_DATE);
            if(strServiceDate != null){
                sWrap.serviceDate = strServiceDate;
            }            
            string strRescheduleDate = (String)objMap.get(Constant_Util.RESCHEDULE_DATE);
            if(strRescheduleDate != null){
                sWrap.rescheduleDate = strRescheduleDate;
            }
			//Change for SDT-14080 - Commented Line
            //sWrap.serviceStatusDate = (String)objMap.get(Constant_Util.SERVICED_DATETIME);
            sWrap.assetName = (String)objMap.get(Constant_Util.SERVICE_COMP_TYPE); 
            sWrap.truckPosition = (String)objMap.get(Constant_Util.TRUCK_COMPLETED_STOP_NUMBER);
            sWrap.customerPosition = (String)objMap.get(Constant_Util.SERVICE_STOP_NUMBER);
            sWrap.serviceStatus = (String)objMap.get(Constant_Util.STATUS);
            sWrap.exceptionReason = (String)objMap.get(Constant_Util.SUB_STATUS);
            sWrap.woNumber = (String)objMap.get(Constant_Util.WO_NUMBER);
            sWrap.materialTypeName = (String)objMap.get(Constant_Util.MATERIAL_TYPE);
            sWrap.occurrenceType = (String)objMap.get(Constant_Util.SERVICE_OCCURRENCE_TYPE);
            sWrap.imageUrl = (String)objMap.get(Constant_Util.IMAGE_URL);
            sWrap.serviceOfferingDefinitionId = (Integer)objMap.get(Constant_Util.SID);
            
            string serviceComponentTypeName = (String)objMap.get(Constant_Util.SERVICE_COMP_TYPE);
            string issuePurposeTypeName = (String)objMap.get(Constant_Util.ISSUE_PURPOSE_TYPE);
            sWrap.woDescription = serviceComponentTypeName != null ? serviceComponentTypeName : Constant_Util.EMPTY_STRING
                	+Constant_Util.BLANKSPACE+issuePurposeTypeName != null ? issuePurposeTypeName : Constant_Util.EMPTY_STRING;
            sWrap.vendorCode = (String)objMap.get(Constant_Util.VENDOR_CODE);
            sWrap.vendorName = (String)objMap.get(Constant_Util.VENDOR_NAME);
            sWrap.scheduleType = (String)objMap.get(Constant_Util.SCHEDULE_NAME);
            sWrap.masUniqueId = (String)objMap.get(Constant_Util.MAS_NO);
            sWrap.vendorAccountNumber = (String)objMap.get(Constant_Util.VENDOR_ACC_NO);
            
			//Changes for SDT-14080 - Start 
            Datetime formattedSDate ;
            
            String servicedDT = (String)objMap.get(Constant_Util.SERVICED_DATETIME);
            
            try {
				if(servicedDT!=null)
				{
					formattedSDate = DateTime.valueOfGMT(servicedDT);    
				}
            }catch(Exception ex)
            {
				//UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
				//Keeping System.Debug until Exception logs are handled 
                System.Debug ('Error for Date '+ servicedDT  + ' Exception: ' + ex.getMessage()) ;
            }
            sWrap.serviceStatusDate=formattedSDate!=null? formattedSDate.format('MM/dd/yyyy hh:mm:ss a', caseRec.tz__Timezone_SFDC__c  ) + ' ' + caseRec.tz__Timezone__c :servicedDT;
            //Changes for SDT-14080 - End
			
            if(From_ETA != null && To_ETA != null) {
                Datetime formattedFrom = (DateTime)JSON.deserialize('"' + From_ETA + '"', DateTime.class);
                Datetime formattedTo = (DateTime)JSON.deserialize('"' + To_ETA + '"', DateTime.class);
				if(formattedFrom != null && formattedTo != null) {
                    sWrap.etaWindow = formattedFrom.format(Constant_Util.TIME_FORMAT, caseRec.tz__Timezone_SFDC__c)+
                        			  Constant_Util.TO_WITH_SPACE+formattedTo.format(Constant_Util.TIME_FORMAT, caseRec.tz__Timezone_SFDC__c)
                                      +Constant_Util.OPEN_BRACE+caseRec.tz__Timezone__c+Constant_Util.CLOSE_BRACE;
                }
            } else {
				
                sWrap.etaWindow = formattedSDate!=null ? Constant_Util.PICKUP_TEXT + formattedSDate.format(Constant_Util.TIME_FORMAT, caseRec.tz__Timezone_SFDC__c)+Constant_Util.OPEN_BRACE
                    + caseRec.tz__Timezone__c + Constant_Util.CLOSE_BRACE : null;                				
							
			}
            if(status == Constant_Util.PRESENT){
			   sWrap.isCurrentService = true;  
            }
            sWrapLst.add(sWrap); 
        }

        
        return sWrapLst;
    }
    
}