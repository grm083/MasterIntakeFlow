/*************************************************************
@Name: IntegrationHandlerUtil
@Author: Ayushi Sharma
@CreateDate: 15/03/2019
@Description: Handles Rest Callouts
@UsedBy: 
**************************************************************/
public without sharing class IntegrationHandlerUtil {
    public static final string EMPTYSTR = '';
    /*
    * This method is Invoked from the Invocation of the API's
    * @owner : Ayushi Sharma
    * @param : InterfaceName :- InterfaceName for the Rest Callout, RequestObjectId:- Id of the object
    */
    public static String getMetadataDetails(String InterfaceName,Id RequestObjectId){
        String strMetadataName = Constant_Util.URL_DEVELOPER_NAME;
        String result = EMPTYSTR;
        
        List<Integration_Request_URLs__mdt> urlMDList = new List<Integration_Request_URLs__mdt>();
        urlMDList = Database.query('select DeveloperName,MasterLabel,Client_Key__c,Client_Token__c,Timeout__c, ' + 
                                      'Content_Type__c,End_Point__c,Method__c from Integration_Request_URLs__mdt ' +
                                      'where DeveloperName =:InterfaceName limit 1');
        
        if(urlMDList.size()>0){
          result = IntegrationHandlerUtil.getCalloutResponseContents(InterfaceName,urlMDList,RequestObjectId);  
        }else{}
        return result;
    }

    /*
    * This method is Invoked from the Invocation of the API's
    * @owner : Kyle Homovec
    * @param : InterfaceName :- InterfaceName for the Rest Callout, caseObj:- Case Object
    */
    public static String getMetadataDetails(String InterfaceName, Case caseObj, String oldAssignment){
         String strMetadataName = Constant_Util.URL_DEVELOPER_NAME;
        String result = EMPTYSTR;
        
        List<Integration_Request_URLs__mdt> urlMDList = new List<Integration_Request_URLs__mdt>();
        urlMDList = Database.query('select DeveloperName,MasterLabel,Client_Key__c,Client_Token__c,Timeout__c, ' + 
                                      'Content_Type__c,End_Point__c,Method__c from Integration_Request_URLs__mdt ' +
                                      'where DeveloperName =:InterfaceName limit 1');
        
        if(urlMDList.size()>0){
          result = IntegrationHandlerUtil.getCalloutResponseContents(InterfaceName,urlMDList,caseObj, oldAssignment);  
        }else{}
        return result;
    }
    
     /*
    * This method is Invoked from the Invocation of the API's
    * @owner : Kyle Homovec
    * @param : InterfaceName :- InterfaceName for the Rest Callout, assetObj:- Asset Object
    */
    public static String getMetadataDetails(String InterfaceName, Asset assetObj){
         String strMetadataName = Constant_Util.URL_DEVELOPER_NAME;
        String result = EMPTYSTR;
        
        List<Integration_Request_URLs__mdt> urlMDList = new List<Integration_Request_URLs__mdt>();
        urlMDList = Database.query('select DeveloperName,MasterLabel,Client_Key__c,Client_Token__c,Timeout__c, ' + 
                                      'Content_Type__c,End_Point__c,Method__c from Integration_Request_URLs__mdt ' +
                                      'where DeveloperName =:InterfaceName limit 1');
        
        if(urlMDList.size()>0){
          result = IntegrationHandlerUtil.getCalloutResponseContents(InterfaceName,urlMDList,assetObj);  
        }else{}
        return result;
    }
    
    /*
    * This method is Invoked from the Invocation of the API's
    * @owner : Ezra Soleymani
    * @param : InterfaceName :- InterfaceName for the Rest Callout, workOrderobj:- Work Order Object
    */
    public static String getMetadataDetails(String InterfaceName, WorkOrder workOrderobj){
        String strMetadataName = Constant_Util.URL_DEVELOPER_NAME;
        String result = null;
        
        List<Integration_Request_URLs__mdt> urlMDList = new List<Integration_Request_URLs__mdt>();
        urlMDList = Database.query('select DeveloperName,MasterLabel,Client_Key__c,Client_Token__c,Timeout__c, ' + 
                                      'Content_Type__c,End_Point__c,Method__c from Integration_Request_URLs__mdt ' +
                                      'where DeveloperName =:InterfaceName limit 1');
        if(urlMDList.size()>0){
           HttpRequest req =  buildHttpRequest(urlMDList,workOrderobj,InterfaceName);
           String RequestBody = requestBody(workOrderobj, InterfaceName);
            if(RequestBody != null){
                req.setBody(RequestBody);
            }
            else {
                req.setHeader('Content-Length', '0');
            }

            result = makeAPICall(req,urlMDList,workOrderobj.Id);
        }else{}
        return result; 
    }

    /*
    * This method is Invoked from the Invocation of the API's
    * @owner : Ezra Soleymani
    * @param : InterfaceName :- InterfaceName for the Rest Callout, Case Obj , String File ID
    */
    public static String getCaseDoc(String InterfaceName, Case caseObj,String fileId){
        String strMetadataName = Constant_Util.URL_DEVELOPER_NAME;
        String result = null;
        
        List<Integration_Request_URLs__mdt> urlMDList = new List<Integration_Request_URLs__mdt>();
        urlMDList = Database.query('select DeveloperName,MasterLabel,Client_Key__c,Client_Token__c,Timeout__c, ' + 
                                      'Content_Type__c,End_Point__c,Method__c from Integration_Request_URLs__mdt ' +
                                      'where DeveloperName =:InterfaceName limit 1');
        if(urlMDList.size()>0){
            HttpRequest req =  buildHttpRequestDoc(urlMDList,caseObj,InterfaceName,fileId);
            req.setHeader('Content-Length', '0');
            result = makeAPICallDoc(req,urlMDList,caseObj.Id,InterfaceName);
            System.debug('Results '+ result);
        }else{}
        return result; 
    }

        /*
    * This method is Invoked from the Invocation of the API's
    * @owner : Ezra Soleymani
    * @param : InterfaceName :- InterfaceName for the Rest Callout, Case Obj , String File ID
    */
    public static String getCaseDocList(String InterfaceName, Case caseObj){
        String strMetadataName = Constant_Util.URL_DEVELOPER_NAME;
        String result = null;
        
        List<Integration_Request_URLs__mdt> urlMDList = new List<Integration_Request_URLs__mdt>();
        urlMDList = Database.query('select DeveloperName,MasterLabel,Client_Key__c,Client_Token__c,Timeout__c, ' + 
                                      'Content_Type__c,End_Point__c,Method__c from Integration_Request_URLs__mdt ' +
                                      'where DeveloperName =:InterfaceName limit 1');
        if(urlMDList.size()>0){
            HttpRequest req =  buildHttpRequest(urlMDList,caseObj,InterfaceName);
            req.setHeader('Content-Length', '0');
            result = makeAPICallDoc(req,urlMDList,caseObj.Id,InterfaceName);
        }else{}
        return result; 
    }

   /*
    * This method is Invoked from the Invocation of the API's
    * @owner : Ezra Soleymani
    * @param : InterfaceName :- InterfaceName for the Rest Callout, Case Obj , String File ID
    */
    public static String uploadCaseDoc(String InterfaceName, Case caseObj,String RequestBody){
        String strMetadataName = Constant_Util.URL_DEVELOPER_NAME;
        String result = null;
        
        List<Integration_Request_URLs__mdt> urlMDList = new List<Integration_Request_URLs__mdt>();
        urlMDList = Database.query('select DeveloperName,MasterLabel,Client_Key__c,Client_Token__c,Timeout__c, ' + 
                                      'Content_Type__c,End_Point__c,Method__c from Integration_Request_URLs__mdt ' +
                                      'where DeveloperName =:InterfaceName limit 1');
        if(urlMDList.size()>0){
            HttpRequest req =  buildHttpRequest(urlMDList,caseObj,InterfaceName);
            req.setBody(RequestBody);
            result = makeAPICall(req,urlMDList,caseObj.Id);
        }
        return result; 
    }

    /*
    * This method is Invoked from the Invocation of the API's
    * @owner : Ezra Soleymani
    * @param : InterfaceName :- InterfaceName for the Rest Callout, Case Obj , String RequestBody
    */
    public static String updateCasePO(String InterfaceName,Case caseObj,String RequestBody){
        String strMetadataName = Constant_Util.URL_DEVELOPER_NAME;
        String result = null;
        
        List<Integration_Request_URLs__mdt> urlMDList = new List<Integration_Request_URLs__mdt>();
        urlMDList = Database.query('select DeveloperName,MasterLabel,Client_Key__c,Client_Token__c,Timeout__c, ' + 
                                      'Content_Type__c,End_Point__c,Method__c from Integration_Request_URLs__mdt ' +
                                      'where DeveloperName =:InterfaceName limit 1');
        if(urlMDList.size()>0){
            HttpRequest req =  buildHttpRequest(urlMDList,caseObj,InterfaceName);
            req.setBody(RequestBody);
            result = makeAPICall(req,urlMDList,caseObj.Id);
        }
        return result; 
    }
    
    //Kyle asset position update    
    public static String getCalloutResponseContents(String InterfaceName,List<Integration_Request_URLs__mdt> metadataList, Asset assetObj){
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        String Endpoint = metadataList[0].End_Point__c;
        
       	Endpoint = Endpoint.replace('{ServiceDefinitionId}',string.valueOf(assetObj.Acorn_SID__c));
        
        System.debug('Partner Key: ' + metadataList[0].Client_Key__c);
        req.setEndpoint(Endpoint);
        req.setMethod(metadataList[0].Method__c);
        req.setHeader('Content-Type',metadataList[0].Content_Type__c);
        req.setHeader('X-USERID', IntegrationHandlerUtil.getLoggedInUserAcornId());
        req.setHeader('X-PARTNER-KEY',metadataList[0].Client_Key__c);
        req.setHeader('Authorization',metadataList[0].Client_Token__c);
        req.setTimeout(metadataList[0].Timeout__c.intValue());
        String RequestBody;
        
        //Reassign request body
        if(InterfaceName == Constant_Util.Update_Asset_Position){
            RequestBody = '{"LocationPositionName":"'+assetObj.Container_Position__c + '","LocationPositionDescription":"'+assetObj.Container_Position__c +'"}';
        }
            else{}
            System.debug('RequestBody : ' + requestBody);
        if(RequestBody != null){
            req.setBody(RequestBody);
        } else {
            req.setHeader('Content-Length', '0');
        }
        System.debug('*** Request' + req);
        string result = '';
        if(!Test.isRunningTest()) {
            try {
                httpresponse res = h.send(req);
                system.debug('res :'+res);
                result = res.getBody();
                IntegrationHandlerUtil.handleAcornResponse(res, req, endpoint, metadataList[0].Method__c, assetObj.id);
            } catch (Exception e) {
                // Logger
                System.debug('Exception: ' + e.getMessage());
                new Logger().addLog(Logger.ERROR, e.getMessage(), '', 'getCalloutResponseContents', 'IntegrationHandlerUtil', '', '', 500, RESTHelper.ErrorMessage.UNHANDLED_ACORN_CALLOUT_EXCEPTION.name(),
                       endpoint, metadataList[0].Method__c, 'Outbound', req.getHeader('X-USERID')).saveLogs();
            }
        }
        else {
            if(InterfaceName == Constant_Util.DOWNLOAD_WORK_ORDER){
                result = '{'+
                            '    \"Data\": {'+
                            '        \"File\": \"zzzzxzxzxzxzxzxzxzxzxxxxxx\",'+
                            '        \"FileName\": \"WorkOrder-W15168352.pdf\"'+
                            '    },'+
                            '    \"Problem\": null'+
                            '}';
            }
            else {
                result = '{"Data":{"IsSuccess":true},"Problem":null}';
    
            }            
        }
         System.debug('*** Result' + result); 
        return result;
    }
    
//Reassign Acorn Ticket and Update Asset on Case    
    public static String getCalloutResponseContents(String InterfaceName,List<Integration_Request_URLs__mdt> metadataList, Case caseObj, String OldAssignment){
        String childTrackingNumber = '';
        String TeamQueue = '';
        Integer AcornUser;
        String UserName;
        String NewUserAssigned;
        Id OldUserAssignedId;
        String oldSBID;
        String newSBID;
        List<Asset> coreAsset;
        
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        String Endpoint = metadataList[0].End_Point__c;
                 
        
        if(InterfaceName == Constant_Util.REASSIGN_TICKET) {
            Case acornTicket = [select Id, Tracking_Number__c, User_Name__c, Team_Queue__c, User_Name__r.Acorn_SUser_ID__c, User_Name__r.Name from Case where Id =: caseObj.id];
            if(acornTicket != null && acornTicket.Tracking_Number__c != null){
                Endpoint = Endpoint.replace('{TrackingNumber}', String.valueOf(acornTicket.Tracking_Number__c));
                childTrackingNumber = acornTicket.Tracking_Number__c;
                TeamQueue = acornTicket.Team_Queue__c;
                if(acornTicket.User_Name__r.Acorn_SUser_ID__c != null && acornTicket.User_Name__c !=null){
                    AcornUser = acornTicket.User_Name__r.Acorn_SUser_Id__c.intValue();
                    NewUserAssigned = acornTicket.User_Name__r.Name;
                }
            }else{}
        }

        //SDT-9485
        
        if(InterfaceName == Constant_Util.UPDATE_ASSET_ON_CASE){
            Case acornTicket = [SELECT Id, Tracking_Number__c, AssetId FROM Case WHERE Id =: caseobj.id];
            if(acornTicket != null && acornTicket.Tracking_Number__c != null){
                Endpoint = Endpoint.replace('{TrackingNumber}', String.valueOf(acornTicket.Tracking_Number__c));
            }

        }
        
        
        
        
        else{}
        
        System.debug('Partner Key: ' + metadataList[0].Client_Key__c);
        req.setEndpoint(Endpoint);
        req.setMethod(metadataList[0].Method__c);
        req.setHeader('Content-Type',metadataList[0].Content_Type__c);
        req.setHeader('X-USERID', IntegrationHandlerUtil.getLoggedInUserAcornId());
        req.setHeader('X-PARTNER-KEY',metadataList[0].Client_Key__c);
        req.setHeader('Authorization',metadataList[0].Client_Token__c);
        req.setTimeout(metadataList[0].Timeout__c.intValue());
        String RequestBody;
        
        //Reassign request body
        if(InterfaceName == Constant_Util.REASSIGN_TICKET){
            List<User> userlst = [SELECT Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            if(userlst.size()>0){
                UserName = userlst[0].Name;
            }
            if(oldAssignment!=null && oldAssignment.substring(0,3) == '005'){
                oldUserAssignedId = Id.valueOf(OldAssignment);
                User olduser = [SELECT Name FROM User WHERE Id = :oldUserAssignedId];
                oldAssignment = olduser.Name;
            }
            if(AcornUser!=null){
                RequestBody = '{"AssignToUserId":' + AcornUser + ',"Comments":"' + Constant_Util.TICKET_REASSIGNED_IN_SALESFORCE_BY + UserName + ' from ' + OldAssignment + ' to '+ NewUserAssigned +'"}';
            }else if (TeamQueue!=null){
                RequestBody = '{"TeamName":"' + TeamQueue + '","Comments":"'+ Constant_Util.TICKET_REASSIGNED_IN_SALESFORCE_BY + UserName + ' from '+ OldAssignment + ' to '+ TeamQueue + '"}';
            }
            else{}
            System.debug('RequestBody : ' + requestBody);
        }
      
        
        //Update Asset Request Body

        if(InterfaceName == Constant_Util.UPDATE_ASSET_ON_CASE){
            coreAsset = new List<Asset>();
            if(caseObj.AssetDetail__c != null){
                for(Asset a : [SELECT Id, Acorn_SBID__c FROM Asset WHERE Id = : caseobj.AssetDetail__c]){
                    coreAsset.add(a);
                }
            }else if(caseObj.Case_Sub_Type__c != Constant_Util.Bulk_Junk_Junk_King_Sub || caseObj.Case_Sub_Type__c != Constant_Util.BULKString||caseObj.Case_Sub_Type__c != Constant_Util.Haul_Away_No_Equipment ){
                for(Asset a : [SELECT Id, Is_Active__c, Acorn_SBID__c, Is_Core_Service__C FROM Asset WHERE Service_Header_ID__c = : caseObj.AssetId AND Is_Active__c = TRUE AND Is_Core_Service__C = TRUE ]){
                    coreAsset.add(a);
                }
            }else{
                for(Asset a : [SELECT Id, Is_Active__c, Acorn_SBID__c, Is_Core_Service__C FROM Asset WHERE Service_Header_ID__c = : caseObj.AssetId AND Is_Active__c = TRUE]){
                    coreAsset.add(a);
                }
            }
            //System.debug('CoreAssetlist --- ' + coreAsset);
            //System.debug('CoreAsset SBID -- ' + coreAsset[0].Acorn_SBID__c);
            if(coreAsset.size()>0 && !coreAsset.isEmpty()){
			    RequestBody = '{"oldServiceBaselineId": ' + oldAssignment + ', "newServiceBaselineId": ' + coreAsset[0].Acorn_SBID__c + '}';
			}
            System.debug('RequestBody--- update Asset : ' + requestBody);
        }
        
      
        else{}

        if(RequestBody != null){
            req.setBody(RequestBody);
        } else {
            req.setHeader('Content-Length', '0');
        }
        System.debug('*** Request' + req);
        string result = '';
        if(!Test.isRunningTest()) {
            try {
                httpresponse res = h.send(req);
                system.debug('res :'+res);
                result = res.getBody();
                IntegrationHandlerUtil.handleAcornResponse(res, req, endpoint, metadataList[0].Method__c, caseObj.id);
            } catch (Exception e) {
                // Logger
                System.debug('Exception: ' + e.getMessage());
                new Logger().addLog(Logger.ERROR, e.getMessage(), '', 'getCalloutResponseContents', 'IntegrationHandlerUtil', '', '', 500, RESTHelper.ErrorMessage.UNHANDLED_ACORN_CALLOUT_EXCEPTION.name(),
                       endpoint, metadataList[0].Method__c, 'Outbound', req.getHeader('X-USERID')).saveLogs();
            }
        }
        else {
            if(InterfaceName == Constant_Util.DOWNLOAD_WORK_ORDER){
                result = '{'+
                            '    \"Data\": {'+
                            '        \"File\": \"zzzzxzxzxzxzxzxzxzxzxxxxxx\",'+
                            '        \"FileName\": \"WorkOrder-W15168352.pdf\"'+
                            '    },'+
                            '    \"Problem\": null'+
                            '}';
            }
            else {
                result = '{"Data":{"IsSuccess":true},"Problem":null}';
    
            }            
        }
         System.debug('*** Result' + result); 
        return result;
    }
    
    
    
    /*
    * This method is getCallOutResponseContent
    *   Updated: PMP - 4/28/19 - Added X-USERID Request Header to include Logged-In Acorn User ID
    *   Updated: PMP - 4/30/19 - Added handleResponse for logging error responses
    * @owner : Ayushi Sharma
    * @param : List<EmailMessage>
    */
    public static String getCalloutResponseContents(String InterfaceName,List<Integration_Request_URLs__mdt> metadataList, Id RequestObjectId){
        WorkOrder objWO = new WorkOrder();
        List<WorkOrder> objWOList = new List<WorkOrder>();
        Asset objAsset = new Asset();
        String childTrackingNumber = '';
        String TeamQueue = '';
        Integer AcornUser;
        String UserName;
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        String Endpoint = metadataList[0].End_Point__c;
        
        //objWOList = [select Id,Customer_Location__r.Location_Code__c, Asset.Acorn_SBID__c, AssetId,Vendor_ID__c,
                //Acorn_WorkOrder_Number__c from WorkOrder where Id = : RequestObjectId];
        
        if(InterfaceName == Constant_Util.WORK_ORDER_ETA || metadataList[0].End_Point__c.contains('{WorkOrderNumber}')){
            objWOList = [select Id,Customer_Location__r.Location_Code__c, Asset.Acorn_SBID__c, AssetId,Vendor_ID__c,
                 Acorn_WorkOrder_Number__c from WorkOrder where Id = : RequestObjectId];
        }
        
        else if(InterfaceName == Constant_Util.Get_Service_ETA || InterfaceName == Constant_Util.HAULER_STATUS){
            objAsset = [select Id,Acorn_SBID__c from Asset where Id = : RequestObjectId];
        } 
        else if(InterfaceName == Constant_Util.CLOSE_ACORN_TICKET) {
            Case acornTicket = [select Id, Tracking_Number__c, User_Name__c, Team_Queue__c, User_Name__r.Acorn_SUser_ID__c from Case where Id =: RequestObjectId];
            if(acornTicket != null && acornTicket.Tracking_Number__c != null){
                Endpoint = Endpoint.replace('{TrackingNumber}', String.valueOf(acornTicket.Tracking_Number__c));
                childTrackingNumber = acornTicket.Tracking_Number__c;
                TeamQueue = acornTicket.Team_Queue__c;
                if(acornTicket.User_Name__r.Acorn_SUser_ID__c != null && acornTicket.User_Name__c !=null){
                	AcornUser = acornTicket.User_Name__r.Acorn_SUser_Id__c.intValue();
                }
            }else{}
        }else{}
        if(metadataList[0].End_Point__c.contains('{WorkOrderNumber}')){
            if(objWOList != null && objWOList[0].Acorn_WorkOrder_Number__c != null){
                Endpoint = Endpoint.replace('{WorkOrderNumber}', objWOList[0].Acorn_WorkOrder_Number__c);
            }else{}
        } else{}  
        if(metadataList[0].End_Point__c.contains(Constant_Util.SBID)){
            if(RequestObjectId != null){
                if(objAsset != null && objAsset.Acorn_SBID__c != null){
                	Endpoint = Endpoint.replace(Constant_Util.SBID, String.valueOf(objAsset.Acorn_SBID__c));
                }else{}
                if(InterfaceName == Constant_Util.Get_Service_ETA){
                    Date dateToday = Date.today();
                    String sMonth = String.valueof(dateToday.month());
                    String sDay = String.valueof(dateToday.day());
                        
                    if(sMonth.length()==1){
                        sMonth = '0' + sMonth;
                    }else{}
                    if(sDay.length()==1){
                        sDay = '0' + sDay;
                    }else{}
                    String sToday = String.valueof(dateToday.year()) + '-' + sMonth + '-' + sDay;
                    Endpoint = Endpoint + '?serviceDate=' + sToday;
                }
            }else{}
        }else{}
        System.debug('Partner Key: ' + metadataList[0].Client_Key__c);
        req.setEndpoint(Endpoint);
        req.setMethod(metadataList[0].Method__c);
        req.setHeader('Content-Type',metadataList[0].Content_Type__c);
        req.setHeader('X-USERID', IntegrationHandlerUtil.getLoggedInUserAcornId());
        req.setHeader('X-PARTNER-KEY',metadataList[0].Client_Key__c);
        req.setHeader('Authorization',metadataList[0].Client_Token__c);
        req.setTimeout(metadataList[0].Timeout__c.intValue());
        String RequestBody;
        
        if(InterfaceName == Constant_Util.RESEND_WORK_ORDER){
            RequestBody = getIntegrationRequsetMapping(Constant_Util.RESEND_WORK_ORDER,RequestObjectId);
        }else{}
        if(InterfaceName == Constant_Util.UPDATE_WORK_ORDER){
            RequestBody = getIntegrationRequsetMapping(Constant_Util.UPDATE_WORK_ORDER,RequestObjectId);
        }else{}
        if(InterfaceName == Constant_Util.DRY_RUN_WORK_ORDER){
            RequestBody = getIntegrationRequsetMapping(Constant_Util.DRY_RUN_WORK_ORDER,RequestObjectId);
        }else{}   
        if(InterfaceName == Constant_Util.ACCEPT_WORK_ORDER){
            RequestBody = getIntegrationRequsetMapping(Constant_Util.ACCEPT_WORK_ORDER,RequestObjectId);
        }else{}
        if(InterfaceName == Constant_Util.CANCEL_WORK_ORDER){
            RequestBody = getIntegrationRequsetMapping(Constant_Util.CANCEL_WORK_ORDER,RequestObjectId);
        }else{}
        if(InterfaceNAme == Constant_Util.CLOSE_ACORN_TICKET){
            RequestBody = '{\"childTrackingNumber\":\"' + childTrackingNumber + '\"}';
        }else{}
        if(RequestBody != null){
            req.setBody(RequestBody);
        } else {
            req.setHeader('Content-Length', '0');
        }
        System.debug('*** Request' + req);
        string result = '';
        if(!Test.isRunningTest()) {
            try {
                httpresponse res = h.send(req);
                system.debug('res :'+res);
                result = res.getBody();
                IntegrationHandlerUtil.handleAcornResponse(res, req, endpoint, metadataList[0].Method__c, RequestObjectId);
            } catch (Exception e) {
                // Logger
                System.debug('Exception: ' + e.getMessage());
                new Logger().addLog(Logger.ERROR, e.getMessage(), '', 'getCalloutResponseContents', 'IntegrationHandlerUtil', '', '', 500, RESTHelper.ErrorMessage.UNHANDLED_ACORN_CALLOUT_EXCEPTION.name(),
                       endpoint, metadataList[0].Method__c, 'Outbound', req.getHeader('X-USERID')).saveLogs();
            }
        }
        else {
            if(InterfaceName == Constant_Util.DOWNLOAD_WORK_ORDER){
                result = '{'+
                            '    \"Data\": {'+
                            '        \"File\": \"zzzzxzxzxzxzxzxzxzxzxxxxxx\",'+
                            '        \"FileName\": \"WorkOrder-W15168352.pdf\"'+
                            '    },'+
                            '    \"Problem\": null'+
                            '}';
            }
            else {
                result = '{"Data":{"IsSuccess":true},"Problem":null}';
    
            }            
        }
         System.debug('*** Result' + result); 
        return result;
    }

    /*
    * This method is buildHttpRequest
    * 	Updated: PMP - 4/28/19 - Added X-USERID Request Header to include Logged-In Acorn User ID
    * 	Updated: PMP - 4/30/19 - Added handleResponse for logging error responses
    * @owner : Ezra Soleymani
    * @param : Sobject
    */
    public static HttpRequest buildHttpRequest(List<Integration_Request_URLs__mdt> metadataList, sObject s , String InterfaceName ){
        
        WorkOrder objWO = new WorkOrder();
        Case objC = new Case();
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        String Endpoint = null;
        Asset objAsset = new Asset();
        String childTrackingNumber = '';
        
        if(String.valueOf(s.getSObjectType())  == Constant_Util.WorkOrder)
        {   objWO = (WorkOrder)s;
            Id RequestObjectId = s.Id;
            Endpoint = metadataList[0].End_Point__c;

            // if(InterfaceName == Constant_Util.WORK_ORDER_ETA || metadataList[0].End_Point__c.contains('{WorkOrderNumber}')){
            //     objWOList = [select Id,Customer_Location__r.Location_Code__c, Asset.Acorn_SBID__c, AssetId,Vendor_ID__c,
            //     Acorn_WorkOrder_Number__c from WorkOrder where Id = : RequestObjectId];
            // }
            if(InterfaceName == Constant_Util.Get_Service_ETA){
                objAsset = [select Id,Acorn_SBID__c from Asset where Id = : RequestObjectId];
            } 
            else if(InterfaceName == Constant_Util.CLOSE_ACORN_TICKET) {
                Case acornTicket = [select Id, Tracking_Number__c from Case where Id =: RequestObjectId];
                if(acornTicket != null && acornTicket.Tracking_Number__c != null){
                    Endpoint = Endpoint.replace('{TrackingNumber}', String.valueOf(acornTicket.Tracking_Number__c));
                    childTrackingNumber = acornTicket.Tracking_Number__c;
                }
            }
            if(metadataList[0].End_Point__c.contains('{WorkOrderNumber}')){
                if(objWO != null && objWO.Acorn_WorkOrder_Number__c != null)
                    Endpoint = Endpoint.replace('{WorkOrderNumber}', objWO.Acorn_WorkOrder_Number__c);
            }        
            if(metadataList[0].End_Point__c.contains('{ServiceBaselineId}')){
                if(RequestObjectId != null){
                    if(objAsset != null && objAsset.Acorn_SBID__c != null){
                        Endpoint = Endpoint.replace('{ServiceBaselineId}', String.valueOf(objAsset.Acorn_SBID__c));
                    }

                    Date dateToday = Date.today();
                    String sMonth = String.valueof(dateToday.month());
                    String sDay = String.valueof(dateToday.day());
                
                    if(sMonth.length()==1){
                        sMonth = '0' + sMonth;
                    } 
                    if(sDay.length()==1){
                        sDay = '0' + sDay;
                    }
                    String sToday = String.valueof(dateToday.year()) + '-' + sMonth + '-' + sDay;
                    Endpoint = Endpoint + '?serviceDate=' + sToday;
                }
            }
        }

         if(String.valueOf(s.getSObjectType())  == Constant_Util.OBJECT_CASE)
        {   
            objC = (Case)s;
            Endpoint = metadataList[0].End_Point__c;
            
            if(InterfaceName == Constant_Util.Get_Ticket_Documents || InterfaceName == Constant_Util.Upload_Ticket_Document ) {
                if(objC != null && objC.Tracking_Number__c != null){
                    Endpoint = Endpoint.replace('{TrackingNumber}', String.valueOf(objC.Tracking_Number__c.SubStringBefore('-')));
                }
            }

            if(InterfaceName == Constant_Util.Update_Purchase_Order){
                 Endpoint = Endpoint.replace('{PurchaseOrderNumber}', objC.Work_Order__r.Acorn_Purchase_Order_Number__c);
            }
        }
        
        req.setEndpoint(Endpoint);
        req.setMethod(metadataList[0].Method__c);
        req.setHeader('Content-Type',metadataList[0].Content_Type__c);
        req.setHeader('X-USERID', IntegrationHandlerUtil.getLoggedInUserAcornId());
        req.setHeader('X-PARTNER-KEY',metadataList[0].Client_Key__c);
        req.setHeader('Authorization',metadataList[0].Client_Token__c);
        req.setTimeout(metadataList[0].Timeout__c.intValue());

        return req;
    }
    public static String requestBody(sObject s,String InterfaceName){
        String RequestBody;
        if(String.valueOf(s.getSObjectType()) == Constant_Util.WorkOrder){
            WorkOrder objWO = new WorkOrder();
            objWO = (WorkOrder)s;
            String RequestObjectId = objWO.Id;
            if(InterfaceName == Constant_Util.RESEND_WORK_ORDER){
                RequestBody = getIntegrationRequsetMapping(Constant_Util.RESEND_WORK_ORDER,objWO);
            }else{}
            if(InterfaceName == Constant_Util.UPDATE_WORK_ORDER){
                RequestBody = getIntegrationRequsetMapping(Constant_Util.UPDATE_WORK_ORDER,RequestObjectId);
            }else{}
            if(InterfaceName == Constant_Util.DRY_RUN_WORK_ORDER){
                RequestBody = getIntegrationRequsetMapping(Constant_Util.DRY_RUN_WORK_ORDER,objWO);
            }else{}	
            if(InterfaceName == Constant_Util.ACCEPT_WORK_ORDER){
                RequestBody = getIntegrationRequsetMapping(Constant_Util.ACCEPT_WORK_ORDER,objWO);
            }else{}
            if(InterfaceName == Constant_Util.CANCEL_WORK_ORDER){
                RequestBody = getIntegrationRequsetMapping(Constant_Util.CANCEL_WORK_ORDER,objWO);
            }else{}
        }else{}
        return RequestBody;
    }
    //
    public static HttpRequest buildHttpRequestDoc(List<Integration_Request_URLs__mdt> metadataList, sObject s , String InterfaceName,String FileId ){
        
        Case objC = new Case();
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        String Endpoint = null;
        String childTrackingNumber = '';
        
        if(String.valueOf(s.getSObjectType())  == Constant_Util.OBJECT_CASE)
        {   objC = (Case)s;
            Id RequestObjectId = s.Id;
            Endpoint = metadataList[0].End_Point__c;
            if(InterfaceName == Constant_Util.Download_Ticket_Document) {
                if(objC != null && objC.Tracking_Number__c != null){
                    Endpoint = Endpoint.replace('{TrackingNumber}', String.valueOf(objC.Tracking_Number__c).SubStringBefore('-'));
                    Endpoint = Endpoint.replace('{FileId}', FileId);
                }else{}
            }else{}
        }else{}
        
        
        req.setEndpoint(Endpoint);
        req.setMethod(metadataList[0].Method__c);
        req.setHeader('Content-Type',metadataList[0].Content_Type__c);
        req.setHeader('X-USERID', IntegrationHandlerUtil.getLoggedInUserAcornId());
        req.setHeader('X-PARTNER-KEY',metadataList[0].Client_Key__c);
        req.setHeader('Authorization',metadataList[0].Client_Token__c);
        req.setTimeout(metadataList[0].Timeout__c.intValue());

        return req;
    }
    
    public static string makeAPICall (HttpRequest req,List<Integration_Request_URLs__mdt> metadataList ,String RequestObjectId ){
        Http h = new Http();
        System.debug('*** Request' + req);
        string result = '';
        string endpoint = req.getEndpoint();
        if(!Test.isRunningTest()) {
            try {
                httpresponse res = h.send(req);
                result = res.getBody();
                System.debug('*** Result' + result); 
                IntegrationHandlerUtil.handleAcornResponse(res, req, endpoint, metadataList[0].Method__c, RequestObjectId);
            } catch (Exception e) {
                // Logger
                System.debug('Exception: ' + e.getMessage());
                new Logger().addLog(Logger.ERROR, e.getMessage(), '', 'getCalloutResponseContents', 'IntegrationHandlerUtil', '', '', 500, RESTHelper.ErrorMessage.UNHANDLED_ACORN_CALLOUT_EXCEPTION.name(),
                       endpoint, metadataList[0].Method__c, 'Outbound', req.getHeader('X-USERID')).saveLogs();
            }
        }
        else {
            result = '{"Data":{"IsSuccess":true},"Problem":null}';
        }
        return result;
    }
    public static string makeAPICallDoc (HttpRequest req,List<Integration_Request_URLs__mdt> metadataList ,String RequestObjectId,String InterfaceName ){
        Http h = new Http();
        System.debug('*** Request' + req);
        string result = '';
        string endpoint = req.getEndpoint();
        if(!Test.isRunningTest()) {
            try {
                httpresponse res = h.send(req);
                result = res.getBody();
                System.debug('*** Result' + result); 
                //IntegrationHandlerUtil.handleAcornResponse(res, req, endpoint, metadataList[0].Method__c, RequestObjectId);
            } catch (Exception e) {
                // Logger
                System.debug('Exception: ' + e.getMessage());
                new Logger().addLog(Logger.ERROR, e.getMessage(), '', 'getCalloutResponseContents', 'IntegrationHandlerUtil', '', '', 500, RESTHelper.ErrorMessage.UNHANDLED_ACORN_CALLOUT_EXCEPTION.name(),
                       endpoint, metadataList[0].Method__c, 'Outbound', req.getHeader('X-USERID')).saveLogs();
            }
        }
        else {
            if(InterfaceName == Constant_Util.Get_Ticket_Documents){
                result =  '{'+
                            '    \"PageIndex\": 0,'+
                            '    \"PageSize\": 20,'+
                            '    \"Count\": 7,'+
                            '    \"Data\": ['+
                            '        {'+
                            '            \"IssueId\": 21379032,'+
                            '            \"IssueFileId\": 215646,'+
                            '            \"FileTitle\": \"new\",'+
                            '            \"FileDescription\": \"Ticket Attachment\",'+
                            '            \"FileExtention\": \"xlsx\",'+
                            '            \"IssueFileTypeName\": \"Customer eBusiness Portal\",'+
                            '            \"IssueFileStatusName\": \"Active\",'+
                            '            \"UserLogonName\": \"mdurkee\"'+
                            '        }'+
                            '    ],'+
                            '    \"Problem\": null'+
                            '}';
            }
            else 
                result = '{'+
                            '    \"Data\": {'+
                            '        \"File\": \"UEsDB\",'+
                            '        \"FileName\": \"ACORN\"'+
                            '    },'+
                            '    \"Problem\": null'+
                            '}';
        }
        return result;
    }
    
    
    
    /*
    * This method is handleResponse (Error Framework)
    * @owner : Paul Payne
    */
    public static void handleAcornResponse(HttpResponse resp, HttpRequest req, String endpoint, String method, Id RequestObjectId) {
        RESTHelper.AcornResponse jsonResp;
        Boolean CREATE_ERROR_LOG = false;
        String result = resp.getBody();
        String acctId = '';
        String caseId = ''; if (String.valueOf(RequestObjectId).startsWith('500') && RESTHelper.isValidId(RequestObjectId)) caseId = RequestObjectId;
        String respMsg = '';
        String errorMsg = '';
        Integer statusCode = 0;
        try {
            jsonResp = (RESTHelper.AcornResponse) JSON.deserialize(result, RESTHelper.AcornResponse.Class); 
            if (jsonResp.hasProblems() || Test.isRunningTest()) {
                CREATE_ERROR_LOG = true;
                respMsg = jsonResp.Problem.Title + ': ' + jsonResp.Problem.Errors[0].Message;
                errorMsg = RESTHelper.ErrorMessage.ACORN_PROBLEM_HAS_OCCURRED.name();
                statusCode = Integer.valueOf(jsonResp.Problem.Errors[0].Code);
            }else{}
        } catch(Exception e) {
            //changes related to SDT - 36006
            if(resp !=null && resp.getStatusCode() > 0 && resp.getStatusCode()!=503){
            	CREATE_ERROR_LOG = true;
            }
            //CREATE_ERROR_LOG = true;
            respMsg = 'Exception: '+ e.getMessage();
            errorMsg = RESTHelper.ErrorMessage.UNHANDLED_ACORN_CALLOUT_EXCEPTION.name();
            statusCode = 500;
        }
        if (CREATE_ERROR_LOG) {
            new Logger().addLog(Logger.ERROR, respMsg, acctId, 'getCalloutResponseContents', 'IntegrationHandlerUtil', RequestObjectId, result, statusCode, errorMsg,
                       endpoint, method, 'Outbound', req.getHeader('X-USERID')).saveLogs();
        }else{}
    }
    
    /*
    * This method is getLoggedInUserAcornId
    * @owner : Paul Payne
    */
    public static String getLoggedInUserAcornId() {
        Decimal acornUserId = [select Acorn_SUser_ID__c from User where Id =: System.UserInfo.getUserId()].Acorn_SUser_ID__c; 
        if (acornUserId == null){ return '0';}else{}
        return String.valueOf(acornUserId.intValue());
    }

    /*
    @Method Description: Fetch Integration_Request_Mapping__mdt records based on the Interface Name and WorkOrder Id. 
    @Return Type: JSON String
    @Parameters: Interface Name and WorkOrder Id
    */
    public static String getIntegrationRequsetMapping(String InterfaceName, String RequestObjectId){                
        List<Integration_Request_Mapping__mdt> metadataList = null;
        metadataList = Database.query('SELECT DeveloperName,Field_Name__c,Id,Is_Active__c,Is_Node__c,Is_Parent__c, ' + 
                                      'Is_State__c,JSON_field_name__c, Object_Name__c,Parent_Node__c,Sequence__c,Used_for__c, ' +
                                      'Data_Type__c FROM Integration_Request_Mapping__mdt WHERE Is_Active__c = true AND ' +
                                       'Used_for__c =: InterfaceName ORDER BY sequence__c');
        WorkOrder objWorkOrder = buildDynamicQuery(metadataList, RequestObjectId);
        String result = generateJson(metadataList, objWorkOrder);
        System.debug('** Json '+result);
        return result;
    }

    /*
        @Method Description: Fetch Integration_Request_Mapping__mdt records based on the Interface Name and WorkOrder Id. 
        @Return Type: JSON String
        @Parameters: Interface Name and WorkOrder obj
    */
    public static String getIntegrationRequsetMapping(String InterfaceName,  WorkOrder objWorkOrder){                
        List<Integration_Request_Mapping__mdt> metadataList = null;
        metadataList = Database.query('SELECT DeveloperName,Field_Name__c,Id,Is_Active__c,Is_Node__c,Is_Parent__c, ' + 
                                      'Is_State__c,JSON_field_name__c, Object_Name__c,Parent_Node__c,Sequence__c,Used_for__c, ' +
                                      'Data_Type__c FROM Integration_Request_Mapping__mdt WHERE Is_Active__c = true AND ' +
                                       'Used_for__c =: InterfaceName ORDER BY sequence__c');
        String result = generateJson(metadataList, objWorkOrder);
        System.debug('** Json '+result);
        return result;
    }
    
    /*
    @Method Description: Build dynamic query to get work order details based metadata results. 
    @Return Type: WorkOrder
    @Parameters: list<Integration_Request_Mapping__mdt> and WorkOrder Id
    */
    public static WorkOrder buildDynamicQuery(List<Integration_Request_Mapping__mdt> metadataResult, String RequestObjectId){
        String selectQuery = 'SELECT ';
        String fieldQuery = '';
        String SObjectName = ' FROM WorkOrder ';
        String whereQuery = ' WHERE Id =: RequestObjectId ';   
        for(Integration_Request_Mapping__mdt IRM : metadataResult) {
            fieldQuery += IRM.Field_Name__c+',';
        }
        fieldQuery = fieldQuery.removeEnd(',');
        WorkOrder objWorkOrder = Database.query(selectQuery+fieldQuery+SObjectName+whereQuery);
        return objWorkOrder;
    }
    
    /*
    @Method Description: Generating JSON. 
    @Return Type: JSON String
    @Parameters: List<Integration_Request_Mapping__mdt> and WorkOrder
    */
    public static String generateJson(List<Integration_Request_Mapping__mdt> metaDataResult, WorkOrder objWorkOrder){
        MAP<String, Integration_Request_Mapping__mdt> JSONandWOFieldNameMap = new MAP<String, Integration_Request_Mapping__mdt>();
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        for(Integration_Request_Mapping__mdt IRM : metaDataResult) {
            JSONandWOFieldNameMap.put(IRM.JSON_field_name__c, IRM);
        }
        for(String firstNodeJson: JSONandWOFieldNameMap.keySet()) {
            String WOFieldVal = '';
            Integration_Request_Mapping__mdt objIRM = JSONandWOFieldNameMap.get(firstNodeJson);
            if(objIRM.Data_Type__c == Constant_Util.IS_STRING) {
                WOFieldVal = objIRM.Field_Name__c;
                if(WOFieldVal.contains('__r')) {
                    String[] splitedVal = WOFieldVal.split('\\.');
                    if(objWorkOrder.getSObject(splitedVal[0]) != NULL) {
                        if(objWorkOrder.getSObject(splitedVal[0]).get(splitedVal[1]) != NULL)
                            gen.WriteStringField(firstNodeJson, String.valueOf(objWorkOrder.getSObject(splitedVal[0]).get(splitedVal[1])));   
                    }
                } else if(WoFieldVal.equals('Case.PurchaseOrder_Number__c')){ 
                    String POnum = (String) objWorkOrder.getSobject('Case').get('PurchaseOrder_Number__c');
                    if(!string.isBlank(POnum) && POnum != null){
                        gen.writeStringField(firstNodeJson, String.valueOf(Ponum));
                    	}
                	}                
                else {
                    if(objWorkOrder.get(WOFieldVal) != NULL && WOFieldVal.contains('Service_Date__c')){
                        gen.WriteStringField(firstNodeJson, String.valueOf(Date.valueOf(objWorkOrder.get(WOFieldVal))));
                    }
                    else if (objWorkOrder.get(WOFieldVal) != NULL) {
                         gen.WriteStringField(firstNodeJson, String.valueOf(objWorkOrder.get(WOFieldVal)));
                    }
                }
            } else if(objIRM.Data_Type__c == Constant_Util.IS_NUMBER) {
                WOFieldVal = objIRM.Field_Name__c;
                if(objWorkOrder.get(WOFieldVal) != null)
                    gen.WriteNumberField(firstNodeJson, Integer.valueOf(objWorkOrder.get(WOFieldVal)));
            } else if(objIRM.Data_Type__c == Constant_Util.IS_DATETIME) {
                WOFieldVal = objIRM.Field_Name__c;
                if(objWorkOrder.get(WOFieldVal) != null)
                    if(WOFieldVal == Constant_Util.PICKUP_DATETIME || WOFieldVal == Constant_Util.RETURN_DATETIME){
                        DateTime dt = DateTime.valueOf(objWorkOrder.get(WOFieldVal));
                        Timezone tz = Timezone.getTimeZone('America/New_York');
                        Double offset = ( tz.getOffset(dt)/3600000);
                        Double subTime = ( -1* (24/ offset));
                        gen.WriteDateTimeField(firstNodeJson,(dt- (1/subTime)));    
                    }
                    else{
                        gen.WriteDateTimeField(firstNodeJson, DateTime.valueOf(objWorkOrder.get(WOFieldVal)));
                    }
            } else if(objIRM.Data_Type__c == Constant_Util.IS_BOOLEAN) {
                WOFieldVal = objIRM.Field_Name__c;
                if(objWorkOrder.get(WOFieldVal) != null)
                    gen.writeBooleanField(firstNodeJson, Boolean.valueOf(objWorkOrder.get(WOFieldVal)));
            } else {}
        }
        gen.writeEndObject();
        String genString = gen.getAsString();
        return genString;
    }
    
    /*
* This method is Invoked from the Invocation of the API's- Notification Story-SDT-13934
* @owner : Devendra Patel
* @param : InterfaceName :- InterfaceName for the Rest Callout, RequestObjectId:- Id of the object, Page Number , Page Size
* 
*/
    public static String getMetadataDetails(String InterfaceName,Id RequestObjectId,string PageNum,string PageSize ){
        String result ;        
        List<Integration_Request_URLs__mdt> urlMDList = new List<Integration_Request_URLs__mdt>();
        urlMDList = Database.query('select DeveloperName,MasterLabel,Client_Key__c,Client_Token__c,Timeout__c, ' + 
                                   'Content_Type__c,End_Point__c,Method__c from Integration_Request_URLs__mdt ' +
                                   'where DeveloperName =:InterfaceName limit 1');
        
        if(urlMDList.size()>0){
            result = IntegrationHandlerUtil.getCalloutResponseContents(InterfaceName,urlMDList,RequestObjectId,PageNum,PageSize );  
        }else{
            result = EMPTYSTR;
        }
        return result;
    }
    
    /*
* This method is getCallOutResponseContent with pagination  -Notification Story-SDT-13934 
* @owner : Devendra Patel
* @param : InterfaceName :- InterfaceName for the Rest Callout, metadataList - MetaData item , RequestObjectId:- Id of the object, Page Number , Page Size
*/
    public static String getCalloutResponseContents(String InterfaceName,List<Integration_Request_URLs__mdt> metadataList, Id RequestObjectId,string PageNum,string PageSize){
        Asset objAsset = new Asset();
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        String Endpoint = metadataList[0].End_Point__c;
        if(InterfaceName == Constant_Util.NOTIFICATION_API){  
            objAsset = [select Id,Acorn_SBID__c from Asset where Id = : RequestObjectId];
        } 
        if(metadataList[0].End_Point__c.contains(Constant_Util.SBID)){
            if(RequestObjectId != null){
                if(objAsset != null && objAsset.Acorn_SBID__c != null){
                    Endpoint = Endpoint.replace(Constant_Util.SBID,String.valueOf(objAsset.Acorn_SBID__c));                   
                    Endpoint=Endpoint + '?pageSize='+PageSize + '&'+ 'pageIndex=' + pageNum;
                }
                
            }else{}
        }else{}
        System.debug('Partner Key: ' + metadataList[0].Client_Key__c);
        req.setEndpoint(Endpoint);
        req.setMethod(metadataList[0].Method__c);
        req.setHeader('Content-Type',metadataList[0].Content_Type__c);
        req.setHeader('X-USERID', IntegrationHandlerUtil.getLoggedInUserAcornId());
        req.setHeader('X-PARTNER-KEY',metadataList[0].Client_Key__c);
        req.setHeader('Authorization',metadataList[0].Client_Token__c);
        req.setTimeout(metadataList[0].Timeout__c.intValue());
        String RequestBody;
        if(RequestBody != null){
            req.setBody(RequestBody);
        } else {
            req.setHeader('Content-Length', '0');
        }
        System.debug('*** Request' + req);
        string result = '';
        if(!Test.isRunningTest()) {
            try {
                httpresponse res = h.send(req);
                system.debug('res :'+res);
                result = res.getBody();
                system.debug('result :'+result);
            } catch (Exception e) {
                System.debug('Exception: ' + e.getMessage());
                UTIL_LoggingService.logHandledException(e, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
            }
        }
        else {
            if(InterfaceName == Constant_Util.NOTIFICATION_API){                 
                result = MockNotificationResponse.NOTIFICATION_MOCK_RESPONSE;
            }       
        }
        System.debug('*** Result' + result); 
        return result;
    }
    /*
    * This method is Invoked from the Invocation of the API's
    * @owner : WM
    * @param : InterfaceName :- InterfaceName for the Rest Callout
    */
    public static String getQueueMetadataDetails(String InterfaceName,String trackingNumber){
        String strMetadataName = Constant_Util.URL_DEVELOPER_NAME;
        String result = EMPTYSTR;
        
        List<Integration_Request_URLs__mdt> urlMDList = new List<Integration_Request_URLs__mdt>();
        urlMDList = Database.query('select DeveloperName,MasterLabel,Client_Key__c,Client_Token__c,Timeout__c, ' + 
                                      'Content_Type__c,End_Point__c,Method__c from Integration_Request_URLs__mdt ' +
                                      'where DeveloperName =:InterfaceName limit 1');
        
        if(urlMDList.size()>0){
          result = IntegrationHandlerUtil.getQueueCalloutResponseContents(InterfaceName,urlMDList,trackingNumber);  
        }
        return result;
    }
	/* This method is for getting current assignment
	* @owner : WM
	* @param : InterfaceName :- InterfaceName for the Rest Callout, metadataList - MetaData item
	*/
    public static String getQueueCalloutResponseContents(String InterfaceName,List<Integration_Request_URLs__mdt> metadataList,String trackingNumber){
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        String Endpoint = metadataList[0].End_Point__c;
        Endpoint = Endpoint.replace('{TrackingNumber}',trackingNumber);
        req.setEndpoint(Endpoint);
        req.setMethod(metadataList[0].Method__c);
        req.setHeader('Content-Type',metadataList[0].Content_Type__c);
        req.setHeader('X-USERID', IntegrationHandlerUtil.getLoggedInUserAcornId());
        req.setHeader('X-PARTNER-KEY',metadataList[0].Client_Key__c);
        req.setHeader('Authorization',metadataList[0].Client_Token__c);
        req.setTimeout(metadataList[0].Timeout__c.intValue());
        string result = '';
        if(!Test.isRunningTest()) {
            try {
                httpresponse res = h.send(req);
                result = res.getBody();
            } catch (Exception e) {
                UTIL_LoggingService.logHandledException(e, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
            }
        }
        else
        {
            result = '{"data": {"trackingNumber": null,"teamName": null,"userName": null,"sUserId": null},"problem": {"title": "Validation Error","status": 400,"errors": [{"code": "400","message": "No Response for the assignment is not valid."}]}}}';
        }
        return result;
    }
	
	/*
    * This method is Invoked from the Invocation of the API's
    * @owner : WM
    * @param : InterfaceName :- InterfaceName for the Rest Callout, RequestObjectId:- Id of the object
    */
    public static String getMetadataDetails(String InterfaceName,String tracknumber,Boolean isReopen){
        String strMetadataName = Constant_Util.URL_DEVELOPER_NAME;
        String result = EMPTYSTR;
        
        List<Integration_Request_URLs__mdt> urlMDList = new List<Integration_Request_URLs__mdt>();
        urlMDList = Database.query('select DeveloperName,MasterLabel,Client_Key__c,Client_Token__c,Timeout__c, ' + 
                                      'Content_Type__c,End_Point__c,Method__c from Integration_Request_URLs__mdt ' +
                                      'where DeveloperName =:InterfaceName limit 1');
        
        if(urlMDList.size()>0){
          result = IntegrationHandlerUtil.getReopenCalloutResponseContents(urlMDList,tracknumber);  
        }else{}
        return result;
    }
	
    public static String getReopenCalloutResponseContents(List<Integration_Request_URLs__mdt> metadataList,String trackingNumber)
    {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        String Endpoint = metadataList[0].End_Point__c;
        Endpoint = Endpoint.replace('{TrackingNumber}',trackingNumber);
        req.setEndpoint(Endpoint);
        req.setMethod(metadataList[0].Method__c);
        req.setHeader('Content-Type',metadataList[0].Content_Type__c);
        req.setHeader('X-USERID', '1');
        req.setHeader('X-PARTNER-KEY',metadataList[0].Client_Key__c);
        req.setHeader('Authorization',metadataList[0].Client_Token__c);
        req.setHeader('Content-Length', '0');
        req.setTimeout(metadataList[0].Timeout__c.intValue());
        string result = '';
        if(!Test.isRunningTest()) {
            try {
                httpresponse res = h.send(req);
                result = res.getBody();
            } catch (Exception e) {
                UTIL_LoggingService.logHandledException(e, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
            }
        }
        else
        {
            result = '{"data": {"trackingNumber": null,"teamName": null,"userName": null,"sUserId": null},"problem": {"title": "Validation Error","status": 400,"errors": [{"code": "400","message": "No Response for the assignment is not valid."}]}}}';
        }
        return result;
    }	
}