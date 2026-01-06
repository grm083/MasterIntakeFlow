public with sharing class AcornCompanyController {
	
    public List<Data> Data;
    public Object Project;
    
    public class Data {
        public String Code;
        public String Name;
        public String Description;
        public Integer IsConstructionDemolition;
    }
    
    public static AcornCompanyController parse(String json) {
        return (AcornCompanyController) System.JSON.deserialize(json, 
                                                                AcornCompanyController.class);
    }
}