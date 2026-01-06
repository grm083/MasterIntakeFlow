/**
* @author Kalaiselvi R
* @date 08/06/2019
* @description : Class to get ETA for DB Query 4
**/
public Without Sharing class IVRServiceStatusETA {
    /*
    * This method is ETACallout
    * @owner : Accenture
    * @param : String interfaceName, List<WorkOrder> wOList, List<Asset> assetList
    */
    public static Map<String, string> ETACallout(String interfaceName, List<WorkOrder> woList, List<Asset> assetList) {
        Map<String, string> etaMap = new Map<String, string>();
        Integration_Request_URLs__mdt integrationReqUrl = new Integration_Request_URLs__mdt();
        string result = '';
        integrationReqUrl = [SELECT DeveloperName, Client_Key__c, Client_Token__c, Timeout__c, Content_Type__c,End_Point__c, 
                                  Method__c FROM Integration_Request_URLs__mdt WHERE DeveloperName =:interfaceName LIMIT 1];
        String endpoint = integrationReqUrl.End_Point__c;
        if(woList != null && woList.size() > 0) {
            for(WorkOrder wo : woList) {
               if(wo.Service_Date__c == Date.today() && wo.Status == Constant_Util.ACCEPTED && wo.Vendor_Account_Id__r.Parent_Vendor_ID__c == '8' 
                               && integrationReqUrl.End_Point__c.contains('{WorkOrderNumber}') && wo.Acorn_WorkOrder_Number__c != null){
                    endpoint = endpoint.replace('{WorkOrderNumber}', wo.Acorn_WorkOrder_Number__c);    
                    result = getETACalloutResponse(interfaceName, integrationReqUrl, endpoint, wo, null);
                    if(!etaMap.containskey(wo.Id)){
                        etaMap.put(wo.Id, result);
                    }
                }
            }
        }
        if(assetList != null && assetList.size() > 0) {
            for(Asset assetObj : assetList) {
                if(integrationReqUrl.End_Point__c.contains('{ServiceBaselineId}') && assetObj.Acorn_SBID__c != null) {
                    endpoint = endpoint.replace('{ServiceBaselineId}', String.valueOf(assetObj.Acorn_SBID__c));
                    String sMonth = String.valueof(Date.today().month());
                    String sDay = String.valueof(Date.today().day());
                    sMonth = sMonth.length()==1 ? '0'+sMonth : sMonth;
                    sDay = sDay.length()==1 ? '0' + sDay : sDay;
                    endpoint = endpoint + '?serviceDate=' + String.valueof(Date.today().year()) + '-' + sMonth + '-' + sDay;
                    result = getETACalloutResponse(interfaceName, integrationReqUrl, endpoint, null, assetObj);
                    if(!etaMap.containskey(assetObj.Id)){
                        etaMap.put(assetObj.Id, result);
                    }
                }
            }
        }
        return etaMap;
    }
    /*
    * This method is getETACalloutResponse
    * @owner : Accenture
    * @param : String interfaceName, List<WorkOrder> wOList, List<Asset> assetList
    */
    public static String getETACalloutResponse(String interfaceName, Integration_Request_URLs__mdt integrationReqUrl, string endpoint,
                                               WorkOrder wo, Asset assetObj){
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        string result = '';
        
        req.setEndpoint(Endpoint);
        req.setMethod(integrationReqUrl.Method__c);
        req.setHeader('Content-Type',integrationReqUrl.Content_Type__c);
        req.setHeader('X-USERID', IntegrationHandlerUtil.getLoggedInUserAcornId());
        req.setHeader('X-PARTNER-KEY',integrationReqUrl.Client_Key__c);
        req.setHeader('Authorization',integrationReqUrl.Client_Token__c);
        req.setTimeout(integrationReqUrl.Timeout__c.intValue());
        try {
            if(Test.isRunningTest() || IVRServiceStatusWebService.isSandbox){
                result = Constant_Util.MOCK_RESPONSE;
            } else {
                httpresponse res = h.send(req);
                if(res.getStatusCode() == Constant_Util.STATUS_CODE){
                    result = res.getBody();
                }
            }
            Map<String,Object> dataMap;
            if(result != null){
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(result);
            	dataMap = (Map<String,Object>)results.get(Constant_Util.DATA_ETA);
            }
            if(dataMap != null){
                String From_ETA = (String)dataMap.get(Constant_Util.FROM_ETA);
                String To_ETA = (String)dataMap.get(Constant_Util.TO_ETA);
                Datetime formattedFrom = datetime.newInstancegmt(date.today(), time.newInstance(Integer.valueof(From_ETA.substringBefore(':')), 
                                                        Integer.valueof(From_ETA.substringBetween(':').normalizeSpace()), 0, 0));
                Datetime formattedTo = datetime.newInstancegmt(date.today(), time.newInstance(Integer.valueof(To_ETA.substringBefore(':')), 
                                                        Integer.valueof(To_ETA.substringBetween(':').normalizeSpace()), 0, 0));
                if(InterfaceName == Constant_Util.WORK_ORDER_ETA) { 
                    result = formattedFrom.format('kk:mm', wo.case.Location__r.tz__Timezone_SFDC__c)+'-' + formattedTo.format('kk:mm', wo.case.Location__r.tz__Timezone_SFDC__c);
                } else {
                    result = formattedFrom.format('kk:mm', assetObj.Location__r.tz__Timezone_SFDC__c)+'-' + formattedTo.format('kk:mm',assetObj.Location__r.tz__Timezone_SFDC__c);
                }
            }
        } catch (Exception e) {
            System.debug('Exception: ' + e.getStackTraceString());
        }
        return result;
    }
}