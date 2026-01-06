public with sharing class ToolingAPIUtility {
public String className{ get; set; }
public Transient String testClassNames{ get; set; }
    public static final String endpoint = '/services/data/v51.0/tooling/query/?q=';
    
    public static HttpResponse queryToolingAPI(String query) {
        
        String urlString = endpoint + EncodingUtil.urlEncode(query, 'UTF-8');
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();

        HttpRequest request = new HttpRequest();
        
        request.setEndpoint(baseUrl + urlString);
        request.setMethod('GET');
        request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        request.setHeader('Content-Type', 'application/json');
        
        Http http = new Http();
        HttpResponse response = http.send(request);
        System.debug('>>>>>'+response.getBody());
        return response;
    }
   public Void save() {
        
        HttpResponse response = ToolingAPIUtility.queryToolingAPI('SELECT Id, Name FROM ApexClass where Name=\''+ClassName+'\'');
        Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        List<Object> records = (List<Object>) jsonResponse.get('records');
        
        Map<String, Object> jsonResponseUpdated = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(records[0]));
        List<Object> recordsUpdated = (List<Object>) jsonResponse.get('records');

        String apexClassId  = String.Valueof(jsonResponseUpdated.get('Id'));

       //HttpResponse responseTestClass = ToolingAPIUtility.queryToolingAPI('SELECT ApexTestClass.name,sum(NumLinesCovered) FROM ApexCodeCoverage WHERE ApexClassOrTriggerId=\''+apexClassId+'\' Group by ApexTestClass.name');
//       HttpResponse responseTestClass = ToolingAPIUtility.queryToolingAPI('SELECT ApexTestClass.name,sum(NumLinesCovered) FROM ApexCodeCoverage WHERE ApexClassOrTriggerId=\''+apexClassId+'\' Group by ApexTestClass.name order by sum(NumLinesCovered) DESC');
       HttpResponse responseTestClass = ToolingAPIUtility.queryToolingAPI('SELECT ApexTestClass.name,sum(NumLinesCovered) FROM ApexCodeCoverage WHERE ApexClassOrTriggerId=\''+apexClassId+'\' Group by ApexTestClass.name order by sum(NumLinesCovered) DESC');
       //SELECT ApexTestClass.name,sum(NumLinesCovered) FROM ApexCodeCoverage WHERE ApexClassOrTriggerId='01p3u00000IUN7aAAH' Group by ApexTestClass.name order by sum(NumLinesCovered) DESC
        Map<String, Object> jsonResponseTestClass = (Map<String, Object>) JSON.deserializeUntyped(responseTestClass.getBody());
         List<Object> recordsTestClasses = (List<Object>) jsonResponseTestClass.get('records');
    
        System.debug('recordsTestClasses[0]>>>>'+responseTestClass.getBody());
      //  testClassNames  = ''+responseTestClass.getBody();
        
        testClassNames = '';
        for(Object item: recordsTestClasses )
        {
            Map<String, Object> jsonResponseUpdatedClas = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(item));
            testClassNames = testClassNames  + '\n' + ',' +(jsonResponseUpdatedClas.get('Name') == 'null' ? '' :jsonResponseUpdatedClas.get('Name') +'--'+ jsonResponseUpdatedClas.get('expr0'))  ;

        }
        
                
    }     
}