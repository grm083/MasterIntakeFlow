@isTest
public with sharing class AAV_APIIntegrationMockTest  implements HttpCalloutMock{
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        system.debug('Request End Point @@@ '+req.getEndpoint());
        if(req.getEndpoint().contains('/Availabilities/')){
            String resBody = '{"data": {"requestedDate": "2023-05-19","lineOfBusiness": "Roll Off","customerCode": "HMD","customerName": "The Home Depot","locationCode": "HMD001048","materialCode": "T","materialName": "Trash",'
            +'"countryCode": "USA","suppliers": [  {"availabilitySource": "WM","supplierCode": null,"supplierName": null,"contractType": "Competitor","wasteStreamCode": "MSW","wasteStreamName": "Municipal Solid Waste",'
            +'"zoneCode": "GIS544488","zoneName": "LA, City of - Non WM Franchise - Athens","wmMetaData": {  "marketAreaCode": "K00175",  "marketAreaName": "WM of Southern California",  "facilityId": "CA0110",  "facilityName": "West Valley Yard", '
            +' "siteId": "S09936",  "siteName": "Industrial Street-West Valley Yard"},"tpMetaData": null,"deliveryDays": null,"serviceDays": null,"deliveries": null,"outages": null,'
            +'"messages": [  {"code": "ER400","description": "WM Schedule information not available due to Competitor / Franchise Contract Type"  }]  }],"messages": []  },  "problem": null}';
    
            res.setHeader('Content-Type', 'application/json');
            res.setBody(resBody);
            res.setStatusCode(200);
        }
        return res;
    }
}