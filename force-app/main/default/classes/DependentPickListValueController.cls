/*************************************************************
@Name: DependentPickListValueController
@CreatedBy: Dinesh Kumar S
@CreatedDate: 28/08/2017
@Release: PBO
@Requirement ID : SDT-8434  
@ChangeDescription: As part of PBO Requirement SDT-8434, This class is used to create dependent fields according to picklist value selection
******************************************************************/

public class DependentPickListValueController{
    Public Static final String ENDPOINT = '/services/data/v46.0/ui-api/object-info/{0}/picklist-values/{1}/{2}';
    public static map<String,List<String>> getPicklistValueBasedonRecordType(String objectAPIName, String fieldAPIName, Id recordTypeId){
        List<String> picklistvalueset = new List<string>();
        map<String,List<String>> picklistvaluemap = new map<String,List<String>>();
        
        if(recordTypeId != null){    
            String method = Constant_Util.GET_METHOD;
            String relativeURL = String.format(ENDPOINT, new String[]{ objectAPIName, recordTypeId, fieldAPIName });
            String host = System.Url.getSalesforceBaseURL().toExternalForm();
            string endPoint = host + relativeURL;
            //String sessionId = UserInfo.getSessionId();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endPoint);
            request.setMethod(method);
            // set authorization header
            request.setHeader(Constant_Util.AUTH, Constant_Util.OAUTH+ getSessionIdFromVFPage(Page.SessionID));
            request.setHeader(Constant_Util.ACCEPT, Constant_Util.JSON_CONTENTTYPE); 
            request.setHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
            HTTPResponse response = (new Http()).send(request);
            
            if(response.getStatusCode() == 200){
                Map<String,Object> root = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
                Integer controlling;
                map<Integer,string> controllingValuemap = new map<Integer,string>();
                if(root != null && root.containsKey(Constant_Util.CONTROLLERVALUE)){
                    map<string,Object> controllingmap = (map<string,Object>) root.get(Constant_Util.CONTROLLERVALUE);
                    for(String cm : controllingmap.keySet()){
                        controllingValuemap.put((Integer) controllingmap.get(cm),cm);
                    }
                }
                if(root != null && root.containsKey(Constant_Util.VALUES)){ 
                    List<Object> picklistVals = (List<Object>)root.get(Constant_Util.VALUES);
                    map<String,Object> picklistValMap;
                    List<object> validforset;
                    for(Object picklistVal : picklistVals){
                        picklistValMap = (Map<String,Object>) picklistVal;
                        validforset = (List<object>) picklistValMap.get(Constant_Util.VALIDFOR);
                        controlling = (Integer) validforset.get(0);
                        if((picklistvaluemap.IsEmpty() && picklistvaluemap.size() == 0 && controllingValuemap.containsKey(controlling))  || (controllingValuemap.containsKey(controlling) && !picklistvaluemap.containskey(controllingValuemap.get(controlling)))){
                            picklistvaluemap.put(controllingValuemap.get(controlling),new List<String>{(String) picklistValMap.get(Constant_Util.VALUE)});        
                        }else if((controllingValuemap.containsKey(controlling) && picklistvaluemap.containskey(controllingValuemap.get(controlling)))){
                            picklistvaluemap.get(controllingValuemap.get(controlling)).add((String) picklistValMap.get(Constant_Util.VALUE));
                        }    
                    }
                    
                } 
            }
            
        }
        return picklistvaluemap;
    }
    
    public static String getSessionIdFromVFPage( PageReference visualforcePage ) {
        string res = null;
        if( !Test.isRunningTest() ) {    
            String sessionId = visualforcePage.getContent().toString();
            res = sessionId;
        }else {
        	res = UserInfo.getSessionId();
        }
        return res;
        
    }
    // Changes for SDT-38437 -  commenting for Coverage
	/*public static List<String> getOriginBasedonRecordType(String objectAPIName, String fieldAPIName, Id recordTypeId){
        List<String> picklistvalueset = new List<string>();
        map<String,List<String>> picklistvaluemap = new map<String,List<String>>();
        List<String> returnList =new List<String>();
        if(recordTypeId != null){    
            String method = Constant_Util.GET_METHOD;
            List<Object> picklistVals;
            
            String relativeURL = String.format(ENDPOINT, new String[]{ objectAPIName, recordTypeId, fieldAPIName });
            String host = System.Url.getSalesforceBaseURL().toExternalForm();
            string endPoint = host + relativeURL;
            //String sessionId = UserInfo.getSessionId();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endPoint);
            request.setMethod(method);
            // set authorization header
            request.setHeader(Constant_Util.AUTH, Constant_Util.OAUTH+ getSessionIdFromVFPage(Page.SessionID));
            request.setHeader(Constant_Util.ACCEPT, Constant_Util.JSON_CONTENTTYPE); 
            request.setHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
            HTTPResponse response = (new Http()).send(request);
            
            if(response.getStatusCode() == 200){
                Map<String,Object> root = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
                Integer controlling;
                map<Integer,string> controllingValuemap = new map<Integer,string>();
                if(root != null && root.containsKey(Constant_Util.CONTROLLERVALUE)){
                    map<string,Object> controllingmap = (map<string,Object>) root.get(Constant_Util.CONTROLLERVALUE);
                    for(String cm : controllingmap.keySet()){
                        controllingValuemap.put((Integer) controllingmap.get(cm),cm);
                    }
                }
                if(root != null && root.containsKey(Constant_Util.VALUES)){ 
                    picklistVals = (List<Object>)root.get(Constant_Util.VALUES);
                }
                System.debug(picklistVals);
				map<String,Object> picklistValMap; 
                for(Object o : picklistVals){
                    picklistValMap = (Map<String,Object>) o;
                    returnList.add((String) picklistValMap.get(Constant_Util.VALUE));
                }
            }
            
        }
        return returnList;
    }
    */
    //Changes related to Origin Issue
    // Changes for SDT-38437	
    public static List<String> getPicklistValues(String recordtypeId){
        String recordTypeName = [Select DeveloperName  from RecordType  where Id =: recordtypeId].DeveloperName;
        Map<String,List<String>> picklistMap = new Map<String, List<String>>{
            'Pickup_Case'=> new List<String>{'Email','Phone','Monitor','E-Business','MAS Service Setup','Mobile Application','The Wire','External System','Migration','Chat Now','Acorn Default','Upload','AutoRecon','SFDC Default'},
            'Integration_Case'=> new List<String>{'Email','Phone','Monitor','E-Business','MAS Service Setup','Mobile Application','The Wire','External System','Migration','Chat Now','Acorn Default','Upload','AutoRecon','SFDC Default'},
            'Interruption_Case' => new List<String>{'Email','Phone','Monitor','E-Business','MAS Service Setup','Mobile Application','The Wire','External System','Client Portal','Migration','Acorn Default','Upload','AutoRecon','SFDC Default'},
            'Modify_Existing_Service_Case' => new List<String>{'Email','Phone','Monitor','E-Business','MAS Service Setup','Mobile Application','The Wire','External System','Client Portal','Migration','Chat Now','Acorn Default','Upload','AutoRecon','SFDC Default'},
            'New_Service_Case' => new List<String>{'Email','Phone','Monitor','E-Business','MAS Service Setup','Mobile Application','The Wire','External System','Client Portal','Migration','Chat Now','Acorn Default','Upload','AutoRecon','SFDC Default'},
            'Repair_Case' => new List<String>{'Email','Phone','Monitor','E-Business','MAS Service Setup','Mobile Application','The Wire','External System','Client Portal','Migration','Chat Now','Acorn Default','Upload','AutoRecon','SFDC Default'},
            'Service_Request_Case' => new List<String>{'Email','Phone','Monitor','E-Business','MAS Service Setup','Mobile Application','The Wire','External System','Client Portal','Migration','Chat Now','Acorn Default','Upload','AutoRecon','SFDC Default'},
            'Standard' => new List<String>{'Email','Phone','Monitor','E-Business','MAS Service Setup','Mobile Application','The Wire','External System','Client Portal','Migration','Chat Now','Acorn Default','Upload','AutoRecon','SFDC Default'},
            'Status_Case' => new List<String>{'Email','Phone','Monitor','E-Business','MAS Service Setup','Mobile Application','The Wire','External System','Client Portal','Migration','Chat Now','Acorn Default','Upload','AutoRecon','SFDC Default'},
            'Update_Asset_Case' => new List<String>{'Email','Phone','Monitor','E-Business','MAS Service Setup','Mobile Application','The Wire','External System','IVR Phone','Client Portal','Migration','Auto Closed','Officetrax','Service Channel','IVR Email','Acorn Default','Upload','AutoRecon','SFDC Default'},
            'Vendor_Case' => new List<String>{'Email','Phone','Monitor','E-Business','MAS Service Setup','Mobile Application','The Wire','External System','Client Portal','Migration','Acorn Default','Upload','AutoRecon','SFDC Default'}};
            
                return picklistMap.get(recordTypeName);
    }
    
    
}