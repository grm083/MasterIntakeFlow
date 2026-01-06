public class ExhibitPriceServices {
    Pricing_Threshold_Settings__mdt exhibitPricingThreshold = Pricing_Threshold_Settings__mdt.getInstance(Pricing_Constant_Util.EXHIBIT_HAUL_COST);
    //Metadataselector class reuse
    public final string ExhibitPricingCodeSwitch ='ExhibitPricingCodeSwitch';
    public decimal exhibitHaulCostMaxValue{get;set;}
    public decimal exhibitHaulCostMinValue{get;set;}
    public boolean isCanadaClient{get;set;}
    public boolean isExhibitPricing{get;set;}
    public Id quoteID{get; set;}
    public  final string CSC = 'CSC';
    public  final string DAYS = 'DAYS';
    public  final string MONTHS = 'MONTHS';
    public  final string WEEKS = 'WEEKS';
    public  final string SCH = 'SCH';
    public  final string H = 'H';
    public  final string GTF = 'GTF';
    public  final string DSP = 'DSP';
    public  final string STF = 'STFEE';
    public string ancillaryQuoteLineProductCode{get; set;}
    public  final string newServiceCase = 'New_Service_Case';
    public  final string OAKWL = 'OAKWL';
    public  final string STPUser = 'STP Systemuser';
    public  final string EV='EV';
    public  final string MT='MT';
    public  final string D='D';
    /*
* @Method Name    : returnMetadata
* @author         : TCS
* @description    : This method is a supporing method to fetch Custom metadata and return Labels
* @return         : Returns a list of metadata MasterLabel. 
*/
    /*Private List<String> returnExhibitMetadata() {
        List<String> masterLabelList = new List<String>();
        Map<String, Pricing_Threshold_Settings__mdt> mtdataList = MetadataSelector.getPricingThresholdSettingsMetadata();
        for(String priceThreshould: mtdataList.keySet()){
            /*if(mtdataList.get(priceThreshould).Enable_Switch__c == true)
{
masterLabelList.add(mtdataList.get(priceThreshould).Label);
}
        }
        return masterLabelList;
    } */
    /*
* @Method Name    : getExhibitMinThreshould
* @author         : Seema SDT-46922
* @description    : This method will return Minimum_Value__c from custom metadata(Pricing_Threshold_Settings__mdt) record of EXHIBIT_HAUL_COST
*covered by       : STPExhibitRuleExecutionTest.haulCostTest_US()
* */
public decimal getExhibitMinThreshould()
{
    return exhibitPricingThreshold.Minimum_Value__c;
}
 /*
* @Method Name    : getExhibitMaxThreshould
* @author         : Seema SDT-46922
* @description    : This method will return Minimum_Value__c from custom metadata(Pricing_Threshold_Settings__mdt) record of EXHIBIT_HAUL_COST
*covered by       : STPExhibitRuleExecutionTest.haulCostTest_US()
* */
public decimal getExhibitMaxThreshould()
{
    return exhibitPricingThreshold.Maximum_Value__c;
}
 /*
* @Method Name    : getIsExhibitPricing
* @author         : Seema SDT-46922
* @description    : This method will return true if pricing response is of Exhibit Pricing or Exhibit Cost Pricing
*covered by       : STPExhibitRuleExecutionTest.haulCostTest_US()
* */
public boolean getIsExhibitPricing(SBQQ__QuoteLine__c ql)
{
    boolean IsExhibitCodeSwitchOff = CodeSwitchUtility.getCodeSwitchOn(ExhibitPricingCodeSwitch);
    boolean isExhibitPricing = false;
    if(!IsExhibitCodeSwitchOff && ql.Pricing_Request__r.Customer_Price_Type__c != null 
       && (ql.Pricing_Request__r.Customer_Price_Type__c.contains(Pricing_Constant_Util.EXHIBIT_PRICING)
           || ql.Pricing_Request__r.Customer_Price_Type__c.contains(Pricing_Constant_Util.EXHIBIT_COST_PRICING)))
    {
        isExhibitPricing = true;
    }
    return isExhibitPricing;
}
    
    // Created bt Sarfaraz- TCS as part of SDT-44637
    /*
* @Method Name    : getQuoteDetails
* @author         : Sarfaraz SDT-44637
* @description    : This method is a supporing method to fetch quote details
* */
    
    public static SBQQ__Quote__c getQuoteDetails(ID quoteID)
    {
        
        SBQQ__Quote__c quoteDetails=[SELECT id,SBQQ__Account__r.Parent.Accounting_System__c, Case_Number__c,SBQQ__Opportunity2__r.Case__r.RecordType.DeveloperName  from SBQQ__Quote__c where id =: quoteID];
        return quoteDetails;
    }
    
     /*
* @Method Name    : checkIfCanadianAccount
* @author         : Sarfaraz SDT-44637
* @description    : This method is a supporing method to check canadian account
* */
   public  boolean checkIfCanadianAccount(ID quoteID)
    {
        SBQQ__Quote__c quoteDetails= getQuoteDetails(quoteID);
        boolean IsExhibitCodeSwitchOn = CodeSwitchUtility.getCodeSwitchOn('ExhibitPricingCodeSwitch');
        if (!IsExhibitCodeSwitchOn && quoteDetails.SBQQ__Account__r.Parent.Accounting_System__c!= null && quoteDetails.SBQQ__Account__r.Parent.Accounting_System__c.contains(OAKWL))
        {
            return true;
        }
        return false;
    }
     /*
* @Method Name    : checkIfNewServiceCase
* @author         : Sarfaraz SDT-44637
* @description    : This method is a supporing method to check case rec type
* */
    
    public  boolean checkIfNewServiceCase(ID quoteID)
    {
        SBQQ__Quote__c quoteDetails= getQuoteDetails(quoteID);
        if (quoteDetails.SBQQ__Opportunity2__r.Case__r.RecordType.DeveloperName=='New_Service_Case')
        {
            return true;
        }
        return false;
    }
     /*
* @Method Name    : assignAncillaryQuoteLineValues
* @author         : Sarfaraz SDT-44637
* @description    : This method is a supporing method to assign quote line values
* */
    private  void assignAncillaryQuoteLineValues( SBQQ__QuoteLine__c ancillaryQuoteLine)
    {
        ancillaryQuoteLine.Frequency_Interval__c=null;
        ancillaryQuoteLine.Service_Days__c=null;  
    }
    
     /*
* @Method Name    : setAncillaryServices
* @author         : Sarfaraz SDT-44637
* @description    : This method is a supporing method to set ancillary quote lines
* */
    
    private  void setAncillaryServices( SBQQ__QuoteLine__c ancillaryQuoteLine, SBQQ__QuoteLine__c singleQuoteLine,Map<String,String> costUOMMapName,Map<String,String> priceUOMMapName, string costUOM, string priceUOM)
    {
        ancillaryQuoteLine.Occurrence_Type__c=singleQuoteLine.Occurrence_Type__c;
        ancillaryQuoteLine.Schedule_Frequency__c=singleQuoteLine.Schedule_Frequency__c;
        ancillaryQuoteLine.Frequency_Interval__c=singleQuoteLine.Frequency_Interval__c;
        ancillaryQuoteLine.Service_Days__c=singleQuoteLine.Service_Days__c;
        
        ancillaryQuoteLine.Cost_Unit_of_Measure__c = setMonthlytoMonthUOM(costUOMMapName, costUOM);
        ancillaryQuoteLine.PriceUOM__c = setMonthlytoMonthUOM(priceUOMMapName, priceUOM);
    }
    
    /*
Vendor: TCS 
Developer: Aliasgher
Description: Change SDT-30895, Change the Acorn - Monthly to SF - Month picklist value.
*/
    public static string setMonthlytoMonthUOM(Map<String,String> UOMMapName, string UOM)
    {
        return UOM == Pricing_Constant_Util.MONTHLY ? Pricing_Constant_Util.COST_UOM_MTH : UOMMapName.get(UOM);
    }
    
    /*
* @Method Name    : processAncillaryQuoteLine
* @author         : Sarfaraz SDT-44637
* @description    : This method is a supporing method to set ancillary quote lines
* */
    public void processAncillaryQuoteLine(SBQQ__QuoteLine__c ancillaryQuoteLine, SBQQ__QuoteLine__c singleQuoteLine,Map<String,String> costUOMMapName,Map<String,String> priceUOMMapName, string costUOM, string priceUOM)
    {
        if(((singleQuoteLine.SBQQ__ProductCode__c.equalsIgnoreCase(H) && ancillaryQuoteLineProductCode.equalsIgnoreCase(GTF)) || 
            (singleQuoteLine.SBQQ__ProductCode__c.equalsIgnoreCase(DSP) && ancillaryQuoteLineProductCode.equalsIgnoreCase(STF))) && 
           checkIfNewServiceCase(quoteID) && checkIfCanadianAccount(quoteID) )
        {
            setAncillaryServices(ancillaryQuoteLine,singleQuoteLine,costUOMMapName,priceUOMMapName,costUOM,priceUOM);
             system.debug('Inside sarf processAncillaryQuoteLine');
        } 
        
        else if( ancillaryQuoteLineProductCode.equalsIgnoreCase(CSC)  && checkIfNewServiceCase(quoteID) && checkIfCanadianAccount(quoteID) )
        {
            assignAncillaryQuoteLineValues(ancillaryQuoteLine);
            
        }
        
    }
     /* 
*Developer : Sheikh Sarfaraz
*Description : This method is used to update manually added quote line services.
*Date : 25/April/2025
*/
public static void updateManuallyAddedQuoteLines(List<SBQQ__QuoteLine__c> newQouteLineList, set<Id> quoteIds)
    {
        ExhibitPriceServices exhibitService= new ExhibitPriceServices();
        
        list<SBQQ__QuoteLine__c> qLDetailsList= getQuoteLineDetails(new list<Id>(quoteIds));
        processQuoteLines(newQouteLineList,qLDetailsList);
        
    }
    
    /* 
*Developer : Sheikh Sarfaraz
*Description : This method is used to get manually added quote line services.
*Date : 25/April/2025
*/
    Public static list<SBQQ__QuoteLine__c> getQuoteLineDetails(list<Id> quoteIds)
    {
        ExhibitPriceServices exhibitService= new ExhibitPriceServices();
        list<SBQQ__QuoteLine__c> qLDetailsList= [select id, SBQQ__ProductCode__c,SBQQ__Product__r.ProductCode,Occurrence_Type__c,Schedule_Frequency__c,Frequency_Interval__c,Service_Days__c,SBQQ__Quote__c,
                                                 SBQQ__Quote__r.SBQQ__Account__r.Parent.Accounting_System__c, 
                                                 SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__r.RecordType.DeveloperName 
                                                 from SBQQ__QuoteLine__c where  SBQQ__Quote__c IN: quoteIds and
                                                 ((SBQQ__ProductCode__c=:exhibitService.DSP or SBQQ__ProductCode__c=:exhibitService.H) )];
        Return qLDetailsList;
    }
    
    /* 
*Developer : Sheikh Sarfaraz
*Description : This method is used to process manually added quote line services.
*Date : 25/April/2025
*/
    
    public static void processQuoteLines(List<SBQQ__QuoteLine__c> newQouteLineList, List<SBQQ__QuoteLine__c> qLDetailsList)
    {
        ExhibitPriceServices exhibitService= new ExhibitPriceServices();
        String currentUser =UserInfo.getName();
        
        for(SBQQ__QuoteLine__c qLSingle:newQouteLineList)
        {
            for (SBQQ__QuoteLine__c sbquoteline : qLDetailsList)
            {
                if(currentUser!= null && qLDetailsList!= null)
                {
                    
                    if( sbquoteline.SBQQ__Quote__r.SBQQ__Account__r.Parent.Accounting_System__c!=null && sbquoteline.SBQQ__Quote__r.SBQQ__Account__r.Parent.Accounting_System__c.contains(exhibitService.OAKWL) 
                       && sbquoteline.SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__r.RecordType.DeveloperName== exhibitService.newServiceCase && currentUser!=exhibitService.STPUser  )
                    {
            
            
                if(qLDetailsList!= null && sbquoteline.SBQQ__ProductCode__c.equalsIgnoreCase(exhibitService.H)
                   && qLSingle.SBQQ__ProductCode__c.equalsIgnoreCase(exhibitService.GTF ))
                {
                    qLSingle.Occurrence_Type__c=sbquoteline.Occurrence_Type__c;
                    qLSingle.Schedule_Frequency__c=sbquoteline.Schedule_Frequency__c;
                    qLSingle.Frequency_Interval__c=sbquoteline.Frequency_Interval__c;
                    qLSingle.Service_Days__c =sbquoteline.Service_Days__c ;
                    qLSingle.Cost_Unit_of_Measure__c=exhibitService.EV;
                    qLSingle.PriceUOM__c=exhibitService.EV;
                    
                }
                   
                if(sbquoteline.SBQQ__ProductCode__c!= null && qLSingle.SBQQ__ProductCode__c!=null && sbquoteline.SBQQ__ProductCode__c.equalsIgnoreCase(exhibitService.DSP )
                   && qLSingle.SBQQ__ProductCode__c.equalsIgnoreCase(exhibitService.STF ))
                {
                    qLSingle.Occurrence_Type__c=sbquoteline.Occurrence_Type__c;
                    qLSingle.Schedule_Frequency__c=sbquoteline.Schedule_Frequency__c;
                    qLSingle.Frequency_Interval__c=sbquoteline.Frequency_Interval__c;
                    qLSingle.Service_Days__c =sbquoteline.Service_Days__c ;
                    qLSingle.Cost_Unit_of_Measure__c=exhibitService.MT;
                    qLSingle.PriceUOM__c=exhibitService.MT;
                    
                }
                if(qLSingle.SBQQ__ProductCode__c!=null && qLSingle.SBQQ__ProductCode__c.equalsIgnoreCase(exhibitService.CSC ))
                {
                    qLSingle.Occurrence_Type__c=exhibitService.SCH;
                    qLSingle.Schedule_Frequency__c=exhibitService.D;
                    qLSingle.Frequency_Interval__c='1';
                    qLSingle.Service_Days__c =null ;
                    qLSingle.Cost_Unit_of_Measure__c='DYS';
                    qLSingle.PriceUOM__c='DYS';
                    }
                    }}
            }
            
        }
    }
}
