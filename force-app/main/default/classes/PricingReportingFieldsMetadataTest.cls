/*
* @Name          PricingReportingFieldsMetadata
* @Author        Digdershika Ojha
* @Vendor		 TCS
* @Date          03/22/2024
* @LastModifiedDate 03/22/2024
* @LastModifiedBy   Digdershika Ojha
* @description	 This class will be used as Test class for PricingReportingFieldsMetadata
*/
@isTest (SeeAllData = FALSE)
public class PricingReportingFieldsMetadataTest {	
    public static final string JSON_VALID = '{\r\n  \"data\": {\r\n    \"priceQuoteIdentifier\": \"Q215\",\r\n    \"supplierCode\": \"8\",\r\n    \"supplierName\": \"WMI\",\r\n    \"customerCode\": \"HMD\",\r\n    \"customerName\": \"The Home Depot\",\r\n    \"locationCode\": \"HMD002706\",\r\n    \"costSource\": \"WM (SBS|RO|OT|30O|B02860|20200901|050638|5411)\",\r\n    \"pricingMethodDisposalCode\": \"1.0\",\r\n    \"pricingMethodDisposalDescription\": \"Market Based Pricing\",\r\n    \"pricingMethodHaulingCode\": \"1.0\",\r\n    \"pricingMethodHaulingDescription\": \"Market Based Pricing\",\r\n    \"haulCost\": 345.82,\r\n    \"disposalCost\": 30.71,\r\n    \"haulPrice\": null,\r\n    \"disposalPrice\": null,\r\n    \"equipmentUOM\": \"Tons\",\r\n    \"estimatedVolumePerHaul\": 4.00,\r\n    \"applyInvoiceFeesToDisposalCharges\": \"Y\",\r\n    \"applyInvoiceFeesToRentalCharges\": null,\r\n    \"dispositionType\": \"S04264_LF\",\r\n    \"dispositionName\": \"B02860|S04264_LF|129A_WDL|MSW_RO\",\r\n    \"transferSiteCode\": \"NA\",\r\n    \"businessUnit\": \"B02860\",\r\n    \"wasteStreamCode\": \"MSW_RO\",\r\n    \"wasteStreamName\": \"Municipal Solid Waste\",\r\n    \"equipmentCode\": \"30O\",\r\n    \"equipmentName\": \"30 Yard Open Top\",\r\n    \"materialName\": \"MSW - Unspecified\",\r\n    \"materialClassName\": \"MSW_MSWI_Municipal Solid Waste - Industrial\",\r\n    \"zoneCode\": \"GIS543763\",\r\n    \"zoneName\": \"Detroit Central - RO MSW - To Woodland\",\r\n    \"masLibrary\": \"129A_WDL\",\r\n    \"equipmentAvailabilityTypeCode\": \"TEMP\",\r\n    \"zoneContractType\": \"Open Market\",\r\n    \"francisePricingLink\": \"\",\r\n    \"greenPagesLink\": \"\",\r\n    \"serviceCharges\": [\r\n      {\r\n        \"code\": \"FU_RO_TEMP_OPEN\",\r\n        \"name\": \"Fuel Fee\",\r\n        \"componentTypeCode\": null,\r\n        \"componentTypeName\": null,\r\n        \"actionCode\": null,\r\n        \"actionName\": null,\r\n        \"cost\": 10.2100,\r\n        \"costValueType\": \"Percent\",\r\n        \"price\": null,\r\n        \"priceValueType\": null\r\n      },\r\n      {\r\n        \"code\": \"ENV_RO_TEMP_OPEN\",\r\n        \"name\": \"Environmental Fee\",\r\n        \"componentTypeCode\": null,\r\n        \"componentTypeName\": null,\r\n        \"actionCode\": null,\r\n        \"actionName\": null,\r\n        \"cost\": 17.5000,\r\n        \"costValueType\": \"Percent\",\r\n        \"price\": null,\r\n        \"priceValueType\": null\r\n      },\r\n      {\r\n        \"code\": \"RCR_RO_TEMP_OPEN\",\r\n        \"name\": \"Regulatory Cost Recovery\",\r\n        \"componentTypeCode\": null,\r\n        \"componentTypeName\": null,\r\n        \"actionCode\": null,\r\n        \"actionName\": null,\r\n        \"cost\": 3.6000,\r\n        \"costValueType\": \"Percent\",\r\n        \"price\": null,\r\n        \"priceValueType\": null\r\n      },\r\n      {\r\n        \"code\": \"CSC_RO_TEMP_OPEN\",\r\n        \"name\": \"Container Service Charge\",\r\n        \"componentTypeCode\": null,\r\n        \"componentTypeName\": null,\r\n        \"actionCode\": null,\r\n        \"actionName\": null,\r\n        \"cost\": 108.50,\r\n        \"costValueType\": \"Amount\",\r\n        \"price\": null,\r\n        \"priceValueType\": null\r\n      }\r\n    ]\r\n  },\r\n  \"problem\": null\r\n}';
    public static final string CUSTOMER_SERVICE = 'Customer Service';
    public static final string TEST_STRING = 'Test';
    
    /*
	 * @MethodName    setup
	 * @description	  This method will be used to setup inital required data to test PricingReportingFieldsMetadata queries
	 * @return		  void
	 */
	@testSetup
    public static void setup(){
        
        //fetching Customer Service profile 
        Profile CustomerServieUser = TestDataFactory.getProfile(CUSTOMER_SERVICE);
        //creating a CSR user
        User CSRUser = TestDataFactory.createUser(CustomerServieUser);
        Database.insert(CSRUser);
    }
    /*
     * @MethodName    : testParse
     * @description	  : Test if parse method is able to deseralise the passed json string.
     * @return        : void
     */
    @isTest
    public static void testParse(){
        User csrUser = [SELECT Id FROM User WHERE Profile.Name = :CUSTOMER_SERVICE AND IsActive = true  LIMIT 1];
        Test.startTest();
         System.runAs(csrUser){
            PricingReportingFieldsMetadata parsedValue = PricingReportingFieldsMetadata.parse(JSON_VALID);
            assert.isNotNull(parsedValue,'parsedValue should not be null');
         }
        Test.stopTest();
    }
    /*
     * @MethodName    : testIsErrorTrue
     * @description	  : Test if IsError method able to return true or false
     * @return        : void
     */
    @isTest
    public static void testIsErrorTrue(){
        User csrUser = [SELECT Id FROM User WHERE Profile.Name = :CUSTOMER_SERVICE AND IsActive = true  LIMIT 1];
        Test.startTest();
         System.runAs(csrUser){
            PricingReportingFieldsMetadata prFMObj = new PricingReportingFieldsMetadata();
            PricingReportingFieldsMetadata.problem prb = new PricingReportingFieldsMetadata.problem();
            List<PricingReportingFieldsMetadata.Errors> errList = new List<PricingReportingFieldsMetadata.Errors>();
             PricingReportingFieldsMetadata.Errors err = new PricingReportingFieldsMetadata.Errors();
             err.message = TEST_STRING;
             err.code = TEST_STRING;
             errList.add(err);
             
             prb.errors = errList;
             prFMObj.problem = prb;
            Boolean isError = prFMObj.isError();
            System.assertEquals(isError, true);           
          }
        Test.stopTest();
    }
    /*
     * @MethodName    : testIsErrorFalse
     * @description	  : Test if IsError method able to return true or false
     * @return        : void
     */
    @isTest
    public static void testIsErrorFalse(){
        User csrUser = [SELECT Id FROM User WHERE Profile.Name = :CUSTOMER_SERVICE AND IsActive = true  LIMIT 1];
        Test.startTest();
         System.runAs(csrUser){
            PricingReportingFieldsMetadata prFMObj = new PricingReportingFieldsMetadata();
            Boolean isError = prFMObj.isError();
            System.assertEquals(isError, false);           
          }
        Test.stopTest();
    }
}