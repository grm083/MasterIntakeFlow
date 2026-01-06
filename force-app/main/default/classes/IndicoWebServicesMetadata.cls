public class IndicoWebServicesMetadata {
    public Data data;
	public Problem problem;

	public class cases {
        public String location;   
        public Id assetheader;  
        public Id contact;
        public String caseType; 
        public String recordType; 
        public String casesubType; 
		public String casereason;  
		public Boolean HasSFRule;		
        public String po;
        public String profile;  
        public Decimal psi;
		public Date serviceDate;
		public List<ErrorMessage> errorMessage;
	}


	public class Errors {
		public Integer code;
		public String message;
	}

	public class ErrorMessage {
		public String fieldName;
		public String errormessage;
	}

	public class Problem {
		public String title;
		public Integer status;
		public List<Errors> errors;
	}

	public class Data {
        public Id CaseId;
        public Id EmailMessageId ;		
        public List<cases> cases;
	}

	
	public static IndicoWebServicesMetadata parse(String json) {
		return (IndicoWebServicesMetadata) System.JSON.deserialize(json, IndicoWebServicesMetadata.class);
	}
}