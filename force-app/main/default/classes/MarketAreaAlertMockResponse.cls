/*
*********************************************************
Apex Class Name    : MarketAreaAlertMockResponse
Created Date       : July 30, 2025
@description       : This is class is used for generating fake Market Area Alert Response
@author            : Soham Datta
Modification Log:
Ver   Date         Author                               Modification
1.0   30-07-2025   Soham Datta						   Initial Version
*********************************************************
*/
@isTest
public class MarketAreaAlertMockResponse implements HttpCalloutMock {
    
    public HTTPResponse respond(HTTPRequest request) {
        String responseBody = '{"count":8,"data":[{"agentInstructions":"Your service has been null.  We appreciate your business.","endDate":"08/05/2025 00:00:00","lob":"Roll Off","marketareaName":"Mid-South","name":"Alert-558116","outageStartDate":"08/05/2025 00:00:00","outageType":"capacityoutage","reason":"capacityoutage","Sites":[{"alertFacilitiesName":"Alert Facility-581587","id":"S10143","name":"Blountville Hauling"}],"startDate":"08/05/2025 00:00:00","status":"Published","title":"S10143 Blountville Hauling","type":"Operational"},{"agentInstructions":"Your service has been null.  We appreciate your business.","endDate":"08/05/2025 00:00:00","lob":"Roll Off","marketareaName":"Mid-South","name":"Alert-558182","outageStartDate":"08/05/2025 00:00:00","outageType":"capacityoutage","reason":"capacityoutage","Sites":[{"alertFacilitiesName":"Alert Facility-581652","id":"S03422","name":"West Louisville Hauling"}],"startDate":"08/05/2025 00:00:00","status":"Published","title":"S03422 West Louisville Hauling","type":"Operational"},{"agentInstructions":"Your service has been null.  We appreciate your business.","endDate":"08/05/2025 00:00:00","lob":"Roll Off","marketareaName":"Mid-South","name":"Alert-558216","outageStartDate":"08/05/2025 00:00:00","outageType":"capacityoutage","reason":"capacityoutage","Sites":[{"alertFacilitiesName":"Alert Facility-581682","id":"S04009","name":"WM of TN - Memphis"}],"startDate":"08/05/2025 00:00:00","status":"Published","title":"S04009 WM of TN - Memphis","type":"Operational"}],"pageIndex":0,"pageSize":10,"problem":null}';
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody(responseBody);
        response.setStatusCode(200);
        return response; 
    }

}