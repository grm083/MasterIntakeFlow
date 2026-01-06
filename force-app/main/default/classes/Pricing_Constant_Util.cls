/**
 * @description       : It declares constants specific to Price Only API for STP, designed for SDT-28509
 * @author            : Digdershika Ojha
 * @vendor			  :	TCS
 * @reference		  : PriceOnlyRequestSTPProcess.apxc
 * @last modified on  : 10-07-2023
 * @last modified by  : Digdershika Ojha
**/
public class Pricing_Constant_Util {
	public static final string SERVICE_TYPE_SEAS = 'SEAS';
    public static final string SERVICE_TYPE_TEMP = 'TEMP';    
    public static final string SERVICE_TYPE_PERM = 'PERM';
    public static final string PRICE_ONLY_STP_URL = 'Price_Only_Integration_Request';
    public static final string SOURCE_SYSTEM = 'SFDC';

    public static final string PRICING_REQUEST_C = 'Pricing_Request__c';
    public static final string CONTAINER_TYPE_C = 'Container_Type__c';
    public static final string CONTAINER_SIZE_C = 'Container_Size__c';
    public static final string MATERIAL_CODE_C = 'Material_Code__c';
    public static final string PRICING_TYPE_AMPO = 'AMPO';
    public static final string TEMP = 'Temp';
    public static final string PRODUCT_CODE_OT = 'OT';
    public static final string PRODUCT_CODE_TOT = 'TOT';
    public static final string PRODUCT_CODE_CMP = 'CMP';
    public static final string PRODUCT_CODE_VTC = 'VTC';
    public static final string COMPACTOR = 'Compactor';
    public static final string VERTICAL_COMPACTOR = 'Vertical Compactor';
    public static final string OCCURENCE_TYPE_OC = 'OC';
    public static final string OCCURENCE_TYPE_SOC = 'SOC';
    public static final string ON_CALL = 'On-Call';
    public static final string SCHEDULED = 'Scheduled';
    public static final string OWNERSHIP_CLT = 'CLT';
    public static final string COST_UOM_MTH = 'MTH';
    //http Call out headers
    public static final string METHOD_POST = 'POST';
    public static final string HEADER_CONTENT_TYPE = 'Content-Type';
    public static final string HEADER_USERID = 'X-USERID';
    public static final string HEADER_PARTNER_KEY = 'X-PARTNER-KEY';
    public static final string HEADER_AUTHORIZATION = 'Authorization';
    // moved from constant_util
    public static final string HAUL = 'Haul';
    public static final String DISPOSAL = 'Disposal';
    public static final string PR_PICKUP = 'Pickup';
    public static final string PR_EXTRA_PICKUP = 'Extra Pickup';
    public static final String SCH_CALL = 'SCH';
    public static final String RECYCLING = 'Recycling';
    public static final string PERCENT = 'Percent';
    public static final string AMOUNT = 'Amount';
    public static final string ENERGY_SURCHARGE = 'Energy Surcharge';
    public static final string ENVIRONMENTAL_CHARGE = 'Environmental Charge';
    public static final string ROLLOFF = 'Rolloff';
    public static final string ROLL_OFF = 'Roll off';
    public static final String COMMERCIAL = 'Commercial';
    public static final String AMPERSAND = '&';
    public static final string PERCENTAGE = '%';
    public static final string OPEN = 'Open';
    public static final Integer ONE_NUMBER = 1;
    public static final string CLOSE = 'Close';
    public static final string OPEN_MARKET = 'Open Market';
    public static final string OPTION_ANY = 'Any';
    public static final string DSP = 'DSP';
    public static final string HAUL_PRODUCT = 'H';
    public static final string PICKUP_PRODUCT = 'PCK';
    public static final string REC_PRODUCT = 'REC';
    public static final string SURCHARGE_FEE = 'Surcharges and Fees';
    public static final string WASTE_STREAM = 'Waste Stream';
    public static final string DASH = '-';
    public static final string QUOTE_ID = ' QuoteId ';
    public static final string WASTE_CATEGORY = 'Waste Category';
    public static final string SBQQ_QUOTELINE_C = 'SBQQ__QuoteLine__c';
    public static final string PRICEUOM_C = 'PriceUOM__c';
    public static final string COST_UNIT_OF_MEASURE = 'Cost_Unit_of_Measure__c';
    public static final string COMMA = ',';
    public static final string WM_VENDOR = 'WM';
    public static final string IS_API_RESULT_C = 'isAPIResult__c';
    public static final string STP = 'STP';
    public static final string LIST_METHOD = 'List';
    public static final string REBATE = 'Rebate';
    public static final string CARDBOARD = 'C';
    public static final string SSR = 'SSR';
    public static final string TN_UOM = 'TN';
    public static final string REB_COST_MODEL = 'REB';
    public static final string EV_UOM = 'EV';
    public static final string CSC = 'CSC';
    public static final string DLV = 'DLV';
    public static final string ADJUST = 'Adjust';
    public static final string ALLOW = 'Allow';
    public static final string MANUAL_REVIEW = 'Manual Review';
    public static final string EXCLUDE = 'Exclude';	//TCS-pkulkarn-SDT-40031-9-Apr-2025-Added
    public static final string MONTHLY = 'Monthly';
    public static final string OTH_REASON = 'OTH';
    public static final string STEP_BY_STEP = 'Step by Step Process';
    public static final string PRICING_ID = 'PricingId';
    public static final string EMPTY_STRING = '';
    public static final string EMPTY_SPACE = ' ';
    public static final string SUCCESS_STRING = 'SUCCESS';
    public static final String OTHER_PRICING_ERROR = 'OtherPricingError';

    //Quote Line Scode
    public static final string SCODE_CAM = 'CAM';
    public static final string SCODE_CTY = 'CTY';
    public static final string SCODE_FRCH = 'FRCH';
    public static final string SCODE_UTL = 'UTL';
    public static final string SCODE_LL = 'LL';
    public static final string SCODE_OGIT = 'OGIT';
    public static final string SCODE_Split = 'SPL';
    
    public static final string PARTIAL_STP = 'Partial STP';
    public static final string FULL_STP = 'Full STP';
    public static final string STP_HAUL_COST = 'STP_Haul_Cost';
    public static final string New_Service_Case = 'New Service Case';
    public static final string QUOTE_PRICE_CONFIGURED = 'Price Configured';
    public static final string EMPTY_AND_RETURN = 'Empty and Return';
    public static final string OPEN_TOP = 'Open Top';
    Public Static final string CUSTOMER_SERVICE = 'Customer Service';
    Public static final String PICKUP_CASE = 'Pickup Case';
    
    //SDT - 31627
    public static final String MAS_COMPANY_CODE = 'MAS Company Code';
    public static final String VENDOR_WM = '8';
    public static final String VENDOR_CANADA = '5889';
    public static final String WM_FRANCHISE = 'WM Franchise';
    public static final String COMPETITOR = 'Competitor';
    public static final String CLOSED = 'Closed';
    //STP Exception
    public static final String STP_EXCEPTION = ' STP Failed Exception';
    public static final String STP_EXCEPTION_DESCRIPTION = 'Straight through processing failed';
    public static final string APPLICATION_NAME = 'STP Rule Execution Apex';
    public static final String FAILED_EXCEPTION = ' Failed Exception';
    public static final String STP_RULE_CLASS_NAME = 'STPRuleExecution';
    public static final String STEP_STP_CLASS_NAME = 'PriceOnlyRequestSTPProcess ';
    public static final string STEP_STP_EXCEPTION_TYPE = 'STPStepByStepException ';
    public static final string STEP_STP_APPLICATION_NAME = 'STP Step By Step Execution Apex ';
    public static final String PRICING_REQUEST_STP_APEX ='Pricing Request STP Process Apex';
    //SDT-30855
    public static final String THRID_PARTY = 'Third Party';
    //SDT-43354 SDT-46922
    public static final String EXHIBIT_HAUL_COST = 'Exhibit_Haul_Cost';
    public static final String EXHIBIT_PRICING = 'Exhibit Pricing';
    public static final String EXHIBIT_COST_PRICING = 'Exhibit Cost Pricing';

    //Pricing Specific Block
    public static final string PR_CUSTOMER_CODE = '{CustomerCode}';
    public static final string PR_LOCATION_CODE = '{LocationCode}';
    public static final string PR_SERVICE_BASELINE_ID = '{ServiceBaselineId}';
    public static final string PR_LOCATIONCODE = 'LocationCode=';
    public static final string PR_ADDRESS1 = 'Address1=';
    public static final string PR_CITY = 'City=';
    public static final string PR_STATE = 'State=';
    public static final string PR_ZIPCODE = 'ZipCode=';
    public static final string PR_COUNTRY = 'Country=';
    public static final string PR_EQUIPMENT_CODE = 'equipmentCode=';
    public static final string PR_EQUIPMENT_SIZE_CODE = 'equipmentSizeCode=';
    public static final string PR_MATERIAL_CODE = 'materialCode=';
    public static final string PR_MARKET_TYPE_CODE = 'MarketTypeCode=';
    public static final string PR_SUPPLIER_CODE = 'SupplierCode=';
    public static final string PR_DISPOSAL_COST = 'DisposalCost=';
    public static final string PR_HAUL_COST = 'HaulCost=';
    public static final string PR_PICKUP_COST = 'PickupCost=';
    public static final string PR_EXTRAPICKUP_COST = 'ExtraPickupCost=';
    public static final string PR_QUANTITY = 'Quantity=';
    public static final string PR_HAULS_PER_MONTH = 'HaulsPerMonth=';
    public static final string PR_NAIC_CODE = 'NAICCode=';
    public static final string PR_IS_CLIENT_OWNED = 'IsClientOwned=';
    public static final string PR_EQUIPMENT_AVAILABILITY = 'equipmentAvailabilityCode=';
    public static final string PR_OCCURENCE_CODE = 'OccurenceCode=';
    public static final string PR_OCCURENCE_COUNT = 'OccurenceCount=';
    public static final string PR_ISPRICING_ELEGIBLE = 'IsPricingEligible=';
    public static final string PR_PREMARYSEGMENT = 'PrimarySegment=';
    public static final string PR_ContainerServiceCharge = 'Container Service Charge';
    public static final string PR_ContainerServiceCharge_Rental_rolloff_1 = 'Container Service Charge (\"Rental\" for Roll Off Accounts)';
    public static final string PR_ContainerServiceCharge_Rental_rolloff_2 = 'Container Service Charge (Rental for Roll Off Accounts)';
    public static final string PR_ContainerServiceCharge_Rental_rolloff_3 = 'Container Service Charge ("Rental" for Roll Off Accounts)';
    public static final string PR_HaulAway_Pickup = 'Haul Away';
    public static final String IS_PROJECT = 'isProject=';
    public static final String PROJECT_CATEFORY = 'projectCategory=';
    public static final string QUOTE_TYPE_AMEND = 'Amendment';
    public static final string QUOTE_TYPE_CORRECTION = 'Correction';
    public static final string QUOTE_TYPE_EXCEPTION = 'Exception';	//pkulkarn-TCS-3-Aug-23-Added for SDT-31211
    public static final string WM_AVAILABILITY_CONFIRMED = 'WM Availability Confirmed';
    public static final string NO_COST_PRICE_AVAILABLE = 'No cost/price information available';
    public static final string NO_WM_ZONE_AVAILABLE = 'No WM Zone information available';
    public static final string MISSING_DISPOSAL_FACILITY = 'Missing Disposal Facility. Reach out to the Market Area for Pricing';
    public static final string UNABLE_GEOCODE_ADDRESS = 'Unable to geocode address';
}