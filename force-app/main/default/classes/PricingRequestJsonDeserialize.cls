public class PricingRequestJsonDeserialize {
    public List<Request> data;
    public PricingReportingFieldsMetadata.Problem problem;
    
    public class Request {
        public String requestNumber;
        public PricingReportingFieldsMetadata.data price;
        public PricingReportingFieldsMetadata.data data;
        public messages[]  messages;
        public PricingReportingFieldsMetadata.Problem problem;

    }

    public class messages {
		public String code;
		public String description;
	}
    
    
    public static PricingRequestJsonDeserialize parse(string jsonString) {
    // JSON deserialization
        PricingRequestJsonDeserialize root =  (PricingRequestJsonDeserialize)System.JSON.deserialize(jsonString, PricingRequestJsonDeserialize.class);
        return root;
    }
    
    public static Request parseOnlyRequest(string jsonString) {
    // JSON deserialization
        PricingRequestJsonDeserialize.Request root =  (PricingRequestJsonDeserialize.Request)System.JSON.deserialize(jsonString, PricingRequestJsonDeserialize.Request.class);
        return root;
    }

}