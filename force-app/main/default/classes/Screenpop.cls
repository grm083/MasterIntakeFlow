public class Screenpop {
    
    public static String SESSION_CACHE_KEY = 'cache.screenpop';
    
    public String MediaType { get; set; }
    public String GenesysId { get; set; }
    public String Intent { get; set; }
    public String CaseRefNo { get; set; }
    public String AcctId { get; set; }
    public String AcctLocationId { get; set; }
    public String ContactId { get; set; }
    public String SFDCRecordId { get; set; } 
    public String ivrQueue { get;set; }
    public String ivrLang { get;set; }
    public String ivrLOB { get;set; }
    public String ivrexitpoint { get;set; }
    public String ivrsseligible { get;set; }
    public String ivrsseligiblepickup { get;set; }
    public String ivrsseligiblestatus { get;set; }
    public String ivrdnis { get;set; }
    public String ivrani { get;set; }
    public String ivrWorkOrder { get;set; }
    public String ivrVendor { get;set; }
    public String ivrR4C { get;set; }
    public String ivrContainerId { get;set; }
    public String ivrPickDate { get;set; }
    
    //Below parameters added as part of SDT-17701
    public String ivrSpokenName { get;set; }
    public String ivrIntentName { get;set; }
    public String ivrSpokenLoc { get;set; }
    public String ivrSpokenRefNum { get;set; }
     //Above parameters added as part of SDT-17701
     //Below parameter added as part of SDT-18313
    public String ivrSpokenIntent { get;set; }
     //Above parameter added as part of SDT-18313

    public String ivrSubTypeReturn {get; set;} // SDT-23351

    //SDT-41550 New fields for IVR New service.
    public string NSEqCode {get;set;}
    public string NSMatType {get;set;}
    public string NSEqSizeCode {get;set;}
    public string NSDeliveryDate {get;set;}
    public string NSRemovalDate {get;set;}
    public string NSEARDates {get;set;}
    public string NSPlacementInts {get;set;}
    public string NSSiteContName {get;set;}
    public string NSSiteContPhNum {get;set;}
    public string NSReason {get;set;}
    public string NSQuoteOnly {get;set;}
    public string NSQuoteContName {get;set;}
    public string NSQuoteContPhNum {get;set;}
    public string NSCaseSubType {get;set;}
    public string NSCaseReason {get;set;}
    public string NSCompanyCategory {get;set;}
    
    public Screenpop() {
        // do nothing
    }
    
    public Screenpop(String theMediaType) {
        MediaType = theMediaType;
    }
    
    public override String toString() {
        String s = 'MediaType=' + MediaType;
        s += ', GenesysId=' + GenesysId;
        s += ', Intent=' + Intent;
        s += ', CaseRefNo=' + CaseRefNo;
        s += ', AcctId=' + AcctId;
        s += ', AcctLocationId=' + AcctLocationId;
        s += ', ContactId=' + ContactId;
        return s;
    }

}