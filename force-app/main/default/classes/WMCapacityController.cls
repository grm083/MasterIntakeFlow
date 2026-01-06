public with sharing class WMCapacityController {
	
    @AuraEnabled
    public static void updateCase(Id caseId, String serviceDate) {
        Case c = [SELECT Id, Service_Date__c, Availability_Confirmed__c, Availability_Checked__c 
                  FROM Case WHERE Id=:caseId];
        
        String parseDate = date.parse(serviceDate).format();  
        
        c.Service_Date__c = date.parse(parseDate);
        c.Availability_Confirmed__c = TRUE;
        c.Availability_Checked__c = TRUE; 
        
        update c;
		GetCaseInformation.insertPlannerComment(caseId, parseDate, true, false);
    }
    @AuraEnabled
    public static void confirmCheck(Id caseId) {
        Case c = [SELECT Id, Availability_Checked__c FROM Case WHERE Id=:caseId];
        
        c.Availability_Checked__c = TRUE;
        
        update c;
    }
    @AuraEnabled
    public static String getSLADate(Id caseId) {
        
        String slaDate;
		
		//Updated on 5/15/2020 by George Martin - Returning the same field to the capacity controller that is being returned
		//to the Case UI
	        
        Case c = [SELECT SLA_Service_DateTime__c
                 FROM Case
                 WHERE Id =: caseId];
        
        If (c.SLA_Service_DateTime__c != Null) {
            slaDate = string.valueOf(c.SLA_Service_DateTime__c);
            if (slaDate.contains('-')) {
                slaDate = slaDate.substringBefore(' ');
                String year = slaDate.substringBefore('-').substringBefore(' ');
                String day = slaDate.substringAfterLast('-');
                String month = slaDate.substringBeforeLast('-').substringAfter('-');
                slaDate = month + '/' + day + '/' + year;
            } else {
                slaDate = slaDate.substringBefore(' ');
            }
        }
            
        return slaDate;
    }
    @AuraEnabled
    public static String getAcornBaseline(Id caseId) {
        
        String baseline;
        Case c = [SELECT Id, AssetId FROM Case WHERE Id=:caseId];
        Id serviceHeader = c.AssetId;
        
        Asset[] details = [SELECT Id, Is_Core_Service__c, SBID_Text_c__c, Supplier__r.Parent_Vendor_ID__c 
                           FROM Asset 
                           WHERE ParentId=:serviceHeader AND Is_Core_service__c = TRUE AND
                           Start_Date__c <= Today AND (End_Date__c >= Today OR End_Date__c = Null)
                           LIMIT 1
                          ];
        
        If (details == Null || details[0].SBID_text_c__c == Null) {
            return baseline;
        }
        
        If (details[0].Supplier__r.Parent_Vendor_ID__c == '8') {
        	baseline = details[0].SBID_Text_c__c;
        }
        
        
        return baseline;
    }
    @AuraEnabled
    public static List<String> getAvailableDates(String baseline) {
    	
        //This current method asks for a "request date" however we should always pass today
        
        String slaDate = string.valueOf(system.now());
        
        String justDate = slaDate.substringBefore(' ');
        String year = justDate.substringBefore('-').substringBefore(' ');
        String day = justDate.substringAfterLast('-');
        String month = justDate.substringBeforeLast('-').substringAfter('-');
        slaDate = year + '-' + month + '-' + day;
        
        List<String> availDates = new List<String>();
        
        Integration_Request_URLs__mdt urlMD = [SELECT DeveloperName, MasterLabel, Client_Key__c, Client_Token__c,
                                             Timeout__c, Content_Type__c, End_Point__c, Method__c
                                             FROM Integration_Request_URLs__mdt
                                             WHERE DeveloperName='Site_Capacity'];
        
        String endpoint = urlMD.End_Point__c;
        endpoint = endpoint.replace('{ServiceBaselineId}', baseline);
        endpoint = endpoint + '?serviceDate=' + slaDate;
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        
        req.setEndpoint(endpoint);
        req.setMethod(urlMD.Method__c);
        req.setHeader('Content-Type', urlMD.Content_Type__c);
        req.setHeader('X-USERID', '1');
        req.setHeader('X-PARTNER-KEY', urlMD.Client_Key__c);
        req.setHeader('Authorization', urlMD.Client_Token__c);
        req.setTimeout(urlMD.Timeout__c.intValue());
        
        String result = '';
        capacityResponse jsonResp;
        
        try {
            httpresponse res = h.send(req);
            result = res.getBody();
            jsonResp = parseCapacity(result);
            availDates = parseCapJSON(jsonResp, slaDate);
        } catch (Exception e) {}
        
        return availDates;
    }
    
    @AuraEnabled
	public static List<String> parseCapJSON(capacityResponse jsonResp, String requestedDate) {
		
		List<String> dates = new List<String>();
		List<String> availDates = new List<String>();
        	List<Capacity> capacities = new List<Capacity>(); 
		if(jsonResp.Data!=null){      
            		capacities = jsonResp.Data.Site.Capacity;
        	}		
		for (Capacity cap : capacities) {
                for (String d : cap.AvailableDates) {
                    String year = d.substringBefore('/');
                    String day = d.substringAfterLast('/');
                    String month = d.substringBeforeLast('/').substringAfter('/');
                    d = month + '/' + day + '/' + year;
                    availDates.add(d);
                }
            }
            
			return availDates;
	}
    
    public inherited sharing class capacityResponse {
        public Data Data;
        public WorkOrderWebservices.ErrorMessageWrapper Problem;
    }
    public inherited sharing class Data {
        public Site Site;
    }
    public inherited sharing class Site {
        public String Name;
        public List<Capacity> Capacity;
    }
    public inherited sharing class Capacity {
        public String LineOfBusiness;
        public String Status;
        public List<String> AvailableDates;
    }
    public static capacityResponse parseCapacity(String json) {
        return (capacityResponse) System.JSON.deserialize(json, capacityResponse.class);
    }
    public inherited sharing class dualList {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;
        
        public dualList(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
}