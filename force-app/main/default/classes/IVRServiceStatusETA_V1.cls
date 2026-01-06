/**
* @author Kalaiselvi R
* @date 08/06/2019
* @description : Class to get ETA for DB Query 4
**/
public Without Sharing class IVRServiceStatusETA_V1 {

    /*
    * This method is ETACallout
    * @owner : Accenture
    * @param : String interfaceName, List<WorkOrder> wOList, List<Asset> assetList
    */
    public static Map<String, ETA_Status> ETACallout(String interfaceName, List<WorkOrder> woList, List<Asset> assetList) {
        Map<String, ETA_Status> etaMap = new Map<String, ETA_Status>();
        Integration_Request_URLs__mdt integrationReqUrl = new Integration_Request_URLs__mdt();
        string result = '';
		String endpoint = '';
        integrationReqUrl = [SELECT DeveloperName, Client_Key__c, Client_Token__c, Timeout__c, Content_Type__c,End_Point__c, 
                                  Method__c FROM Integration_Request_URLs__mdt WHERE DeveloperName =:interfaceName LIMIT 1];
        ETA_Status eta = null;
        if(woList != null && woList.size() > 0) {
            for(WorkOrder wo : woList) {
			   endpoint = integrationReqUrl.End_Point__c;
               if(wo.Service_Date__c == Date.today() && wo.Status == Constant_Util.ACCEPTED && wo.Vendor_Account_Id__r.Parent_Vendor_ID__c == '8' 
                               && endpoint.contains('{WorkOrderNumber}') && wo.Acorn_WorkOrder_Number__c != null){
                    endpoint = endpoint.replace('{WorkOrderNumber}', wo.Acorn_WorkOrder_Number__c);    
                    eta = getETACalloutResponse(interfaceName, integrationReqUrl, endpoint, wo, null);
                    if(!etaMap.containskey(wo.Id)){
                        etaMap.put(wo.Id, eta);
                    }
                }
            }
        }
        if(assetList != null && assetList.size() > 0) {
            for(Asset assetObj : assetList) {
                endpoint = integrationReqUrl.End_Point__c;
                if(endpoint.contains('{ServiceBaselineId}') && assetObj.Acorn_SBID__c != null) {
                    endpoint = endpoint.replace('{ServiceBaselineId}', String.valueOf(assetObj.Acorn_SBID__c));
                    String sMonth = String.valueof(Date.today().month());
                    String sDay = String.valueof(Date.today().day());
                    sMonth = sMonth.length()==1 ? '0'+sMonth : sMonth;
                    sDay = sDay.length()==1 ? '0' + sDay : sDay;
                    endpoint += '?serviceDate=' + String.valueof(Date.today().year()) + '-' + sMonth + '-' + sDay;
                    eta = getETACalloutResponse(interfaceName, integrationReqUrl, endpoint, null, assetObj);
                    if(!etaMap.containskey(assetObj.Id)){
                        etaMap.put(assetObj.Id, eta);
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
    public static ETA_Status getETACalloutResponse(String interfaceName, Integration_Request_URLs__mdt integrationReqUrl, string endpoint,
                                               WorkOrder wo, Asset assetObj){
        Http h = new Http();
        HttpRequest req = new HttpRequest();
		string response = '';
		Map<String,Object> dataMap;
        ETA_Status eta = new ETA_Status();

        req.setEndpoint(Endpoint);
        req.setMethod(integrationReqUrl.Method__c);
        req.setHeader('Content-Type',integrationReqUrl.Content_Type__c);
        req.setHeader('X-USERID', IntegrationHandlerUtil.getLoggedInUserAcornId());
        req.setHeader('X-PARTNER-KEY',integrationReqUrl.Client_Key__c);
        req.setHeader('Authorization',integrationReqUrl.Client_Token__c);
        req.setTimeout(integrationReqUrl.Timeout__c.intValue());
        try {
            if(Test.isRunningTest()){
                response = Constant_Util.ETA_MOCK_RESPONSE;
            } else {
                httpresponse res = h.send(req);
                if(res.getStatusCode() == Constant_Util.STATUS_CODE){
                    response = res.getBody();
                }
            }
            if(response != null && !response.contains(Constant_Util.BAD_REQUEST)) {
                Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(response);
            	dataMap = (Map<String,Object>)resultMap.get(Constant_Util.DATA_ETA);
				if(dataMap != null){
					String From_ETA = (String)dataMap.get(Constant_Util.FROM_ETA);
					String To_ETA = (String)dataMap.get(Constant_Util.TO_ETA);
					if(From_ETA != null && To_ETA != null) {
						Datetime formattedFrom = datetime.newInstancegmt(date.today(), time.newInstance(Integer.valueof(From_ETA.substringBefore(':')), 
															Integer.valueof(From_ETA.substringBetween(':').normalizeSpace()), 0, 0));
						Datetime formattedTo = datetime.newInstancegmt(date.today(), time.newInstance(Integer.valueof(To_ETA.substringBefore(':')), 
															Integer.valueof(To_ETA.substringBetween(':').normalizeSpace()), 0, 0));
						
                        if(formattedFrom != null && formattedTo != null) {
							if(InterfaceName == Constant_Util.WORK_ORDER_ETA) { 
								eta.fromETA = formattedFrom.format('kk:mm', wo.case.Location__r.tz__Timezone_SFDC__c);
                                				eta.ToETA = formattedTo.format('kk:mm', wo.case.Location__r.tz__Timezone_SFDC__c);
							} else {
								eta.fromETA = formattedFrom.format('kk:mm', assetObj.Location__r.tz__Timezone_SFDC__c);
                                				eta.ToETA = formattedTo.format('kk:mm',assetObj.Location__r.tz__Timezone_SFDC__c);
							} 
						} 
					} else {
                        if(dataMap.ContainsKey(Constant_Util.REASON_CODE)){
                            string reasonCode = (String)dataMap.get(Constant_Util.REASON_CODE);
							eta.ivrStatus = System.Label.ETA_Reason_Code.contains(reasonCode) ? Constant_Util.COMPLETED : '';
                        }
					}
				}
			}
        } catch (Exception e) {
            System.debug('Exception: ' + e.getStackTraceString());
        }
        return eta;
    }
    
    public Class ETA_Status {
        public string fromETA;
        public string ToETA;
        public String ivrStatus;
    }
}