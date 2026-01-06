global with sharing class RESTHelper {
    
     /* Example:
     * HTTP/1.1 500 Server Error (Uncaught Exception)
     * 
          [ {
          "errorCode" : "APEX_ERROR",
          "message" : "System.NullPointerException: Argument cannot be null.\n\nClass.AcornCaseDetailsResource.getCaseInfo: line 48, column 1\nClass.AcornCaseDetailsResource.getCase: line 26, column 1"
           } ]
	
	  HTTP/1.1 200 OK
		See above
	*/
    public static final String SUCCESS = 'SUCCESS';
    public static final String ERROR = 'ERROR';
    public static final String WARNING = 'WARNING';
    public static final String INFO = 'INFO';
    public static final String PROBLEM = 'PROBLEM';
    public static final String CREATED = 'CREATED';
    
    public static final Integer HTTP_NOT_FOUND = 404;
    public static final Integer HTTP_SUCCESS = 200;
    public static final Integer HTTP_INVALID_MISSING_PARAM = 400;
    public static final Integer HTTP_EXCEPTION = 500;
    public static final Integer HTTP_Created = 201;

    
    public enum ErrorMessage {
        APEX_ERROR,							// standard SFDC Response Error Message
        ACORN_PROBLEM_HAS_OCCURRED,			// Acorn Response, A Problem/Error Exists
        UNHANDLED_ACORN_CALLOUT_EXCEPTION,  // Unhadled Exception During Callout  
    	ERROR_NOT_FOUND,
        ERROR_INVALID_MISSING_PARAM,
        EXCEPTION_OCCURRED
    }
    
    global with sharing class AcornResponse {
        public String status 				{get;set;}		// success, error, true, false, OK, ERROR (currently IsSuccess)
        public Object payload				{get;set;}		// V2 API data
        public RESTHelper.DataWrapper Data	{get;set;}		// Acorn Standard Response
        public String errorCode {							// standard SFDC (i.e. APEX_ERROR)
            get;
            set {
                errorCode = value;
                if (String.isNotEmpty(errorCode)) {
                    this.isError = true; 
                }else{}
            }
        }		
        public String message   {get;set;}		// standard SFDC, success or error message (currently ErrorMessage)
        public Boolean isError  {get;set;}
        // duplicate
        public Integer statusCode 	{get;set;}			// Optional (https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_methods_system_restresponse.htm)
        public RESTHelper.ErrorMessageWrapper Problem {get;set;}	// Original Error Message List
        
        public AcornResponse() {
            this.statusCode = 200;
            this.isError = false;
            this.message = '';
            this.errorCode = '';
        }
        
        public boolean hasProblems() {
            if (this.Problem != null && this.Problem.Errors != null && this.Problem.Errors.size() > 0) {
                return true;
            }else{
            return false;
            }
        }
    }
    
    global with sharing class createResponse {
        public string status 				{get;set;}		// success, error, true, false, OK, ERROR (currently IsSuccess)
        public Object Data				    {get;set;}	
        //public String message   {get;set;}		// standard SFDC, success or error message (currently ErrorMessage)
        public Boolean isError  {get;set;}
        // duplicate
        public Integer statusCode 	{get;set;}			// Optional (https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_methods_system_restresponse.htm)
        public RESTHelper.ErrorMessageWrapper Problem {get;set;}	// Original Error Message List
        /*public String errorCode {							// standard SFDC (i.e. APEX_ERROR)
            get;
            set {
                errorCode = value;
                if (String.isNotEmpty(errorCode)) {
                    this.isError = true; 
                }else{}
            }
        }*/
        public createResponse() {
            this.statusCode = 200;
            this.isError = false;
            //this.message = '';
            //this.errorCode = '';
        }
    }

    global with sharing class DataWrapper{
        public Boolean IsSuccess = true;
        public DataWrapper() {}
    }
    
    global with sharing class ErrorMessageWrapper{
        public String Title {get;set;}
        public String Status {get;set;}
        public List<ErrorsWrapper> Errors {get;set;}
                
        public ErrorMessageWrapper(String title, String status, List<ErrorsWrapper> errors){
            this.Title = title;
            this.Status = status;
            this.Errors = errors;
        }
    }
    
    global with sharing class ErrorsWrapper{
        public String Code {get;set;}
        public String Message {get;set;}
          
        public ErrorsWrapper(String code, String message){
            this.Code = code;
            this.Message = message;
        }
    }
    
    public static Boolean isValidId(String Idparam) {
        String id = String.escapeSingleQuotes(Idparam);
        if((id.length() == 15 || id.length() == 18) && Pattern.matches('^[a-zA-Z0-9]*$', id)) {
            return true;
        }
        return false;
    }
    
    /*
    public static void debugRequest(RestRequest req, RestResponse res) {
        Map<String, String> headers = req.headers;
        for (String h: headers.keySet()) {
            System.debug(h + ':' + headers.get(h));
        }
        
        System.debug('Request');
        System.debug(req.headers);
        System.debug(req.httpMethod);
        System.debug(req.params);
        System.debug(req.remoteAddress);
        System.debug(req.requestBody);
        System.debug(req.requestURI);
        System.debug(req.resourcePath);
        System.debug('Response');
        //System.debug(JSON.serialize(cases[0]));
        System.debug(res.statusCode);
        System.debug(res.headers);
        System.debug('OK');
    }
	*/
    
    public static RESTHelper.AcornResponse createAcornErrorResponse(RESTHelper.AcornResponse response, Integer httpRespCode, String errMsg) {
        response.statusCode = httpRespCode;
        if (httpRespCode == RESTHelper.HTTP_NOT_FOUND) {
            response.errorCode = ErrorMessage.ERROR_NOT_FOUND.name();	    
        } else if (httpRespCode == RESTHelper.HTTP_INVALID_MISSING_PARAM ) {
            response.errorCode = ErrorMessage.ERROR_INVALID_MISSING_PARAM.name();	 
        } else if (httpRespCode == RESTHelper.HTTP_EXCEPTION ) {
            response.errorCode = ErrorMessage.EXCEPTION_OCCURRED.name();	 
        }
        response.status = RESTHelper.ERROR;
        response.message = errMsg;
        response.statusCode = httpRespCode;
        return response;
    }
    
    public static RESTHelper.createResponse createAcornErrorResponse(RESTHelper.createResponse response, Integer httpRespCode, String errMsg) {
        response.statusCode = httpRespCode;
        String errorCode;
        if (httpRespCode == RESTHelper.HTTP_NOT_FOUND) {
            errorCode = ErrorMessage.ERROR_NOT_FOUND.name();	    
        } else if (httpRespCode == RESTHelper.HTTP_INVALID_MISSING_PARAM ) {
            errorCode = ErrorMessage.ERROR_INVALID_MISSING_PARAM.name();	 
        } else if (httpRespCode == RESTHelper.HTTP_EXCEPTION ) {
            errorCode = ErrorMessage.EXCEPTION_OCCURRED.name();	 
        }
        response.status = RESTHelper.ERROR;
        //response.message = errMsg;
        response.statusCode = httpRespCode;
        //response.errorCode = errorCode;

        List<ErrorsWrapper> errors =  new List<ErrorsWrapper>();
        ErrorsWrapper error = new ErrorsWrapper(String.ValueOf(httpRespCode),errMsg);
        errors.add(error);
        ErrorMessageWrapper errorWrapper = new ErrorMessageWrapper(errorCode,String.ValueOf(httpRespCode),errors);
        //errorWapper.ErrorMessageWrapper();
        response.Problem = errorWrapper;
        
        
        return response;
    }
    
    public static RESTHelper.AcornResponse createAcornSuccessResponse(RESTHelper.AcornResponse response) {
        response.status = RESTHelper.SUCCESS;
        response.statusCode = 200;
        
        return response;
    }

    public static RESTHelper.createResponse createAcornSuccessResponse(RESTHelper.createResponse response) {
        response.status = RESTHelper.SUCCESS;
        response.statusCode = RESTHelper.HTTP_SUCCESS;
        
        return response;
    }

        public static RESTHelper.createResponse createAcornCreatedResponse(RESTHelper.createResponse response) {
        response.status = RESTHelper.CREATED;
        response.statusCode = RESTHelper.HTTP_Created;
        
        return response;
    }
    
}