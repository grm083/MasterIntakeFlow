global class AcornCompanyDetails {
    
	@InvocableMethod
	global static List<List<String>> getCompanyCategories(List<String> AccountNum) {
        
        List<List<String>> retCC = new List<List<String>>();
        
        If (AccountNum.get(0) != Null) {
            String companyCode = AccountNum.get(0);
            
            retCC = getAcornCC(companyCode);
        }
        
        return retCC;
    }
    
    global static List<List<String>> getAcornCC(String companyCode) {
        
        //Query Metadata for Request URL
        Integration_Request_URLs__mdt urlMD = [Select DeveloperName, MasterLabel, Client_Key__c, Client_Token__c, 
                                               Timeout__c, Content_Type__c, End_Point__c, Method__c FROM Integration_Request_URLs__mdt WHERE
                                               DeveloperName = 'Get_Company_Categories'];												
		String endpoint = urlMD.End_Point__c;
        
        //Replace the {CustomerCode} in endpoint with the companyCode
		endpoint = endpoint.replace('{CustomerCode}', companyCode);
		
        //Create New HTTP request based on paramters of metadata record
		Http h = new Http();
		HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
		
        //Set request headers
		req.setEndpoint(endpoint);
		req.setMethod('GET');
		req.setHeader('Content-Type', urlMD.Content_Type__c);
		req.setHeader('X-PARTNER-KEY', urlMD.Client_Key__c);
        req.setHeader('X-USERID', '1');
		req.setHeader('Authorization', urlMD.Client_Token__c);
		req.setTimeout(urlMD.Timeout__c.intValue());
        
        List<List<String>> retCC = new List<List<String>>();
        List<String> groupCC = new List<String>();
        
        try {
            res = h.send(req);
            String result = res.getBody();
            AcornCompanyController results = AcornCompanyController.parse(result);
            for (AcornCompanyController.Data retData : results.Data) {
                system.debug(retData.Name);
                groupCC.add(retData.Name);
            }
            retCC.add(groupCC);
        } catch (Exception e) {}
		
        return retCC;
    }
    
    @AuraEnabled
    global static map<String, String> getAcornCCMap(String companyCode) {
        
        //Query Metadata for Request URL
        Integration_Request_URLs__mdt urlMD = [Select DeveloperName, MasterLabel, Client_Key__c, Client_Token__c, 
                                               Timeout__c, Content_Type__c, End_Point__c, Method__c FROM Integration_Request_URLs__mdt WHERE
                                               DeveloperName = 'Get_Company_Categories'];												
		String endpoint = urlMD.End_Point__c;
        
        //Replace the {CustomerCode} in endpoint with the companyCode
		endpoint = endpoint.replace('{CustomerCode}', companyCode);
		
        //Create New HTTP request based on paramters of metadata record
		Http h = new Http();
		HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
		
        //Set request headers
		req.setEndpoint(endpoint);
		req.setMethod('GET');
		req.setHeader('Content-Type', urlMD.Content_Type__c);
		req.setHeader('X-PARTNER-KEY', urlMD.Client_Key__c);
        req.setHeader('X-USERID', '1');
		req.setHeader('Authorization', urlMD.Client_Token__c);
		req.setTimeout(urlMD.Timeout__c.intValue());
        
        map<String, String> retCC = new map<String, String>();
        
        try {
            res = h.send(req);
            String result = res.getBody();
            AcornCompanyController results = AcornCompanyController.parse(result);
            for (AcornCompanyController.Data retData : results.Data) {
                retCC.put(retData.code, retData.name);
            }
        } catch (Exception e) {}
		
        return retCC;
    }
    
}