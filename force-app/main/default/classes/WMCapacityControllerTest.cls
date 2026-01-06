@isTest 
public class WMCapacityControllerTest {

    //Author - George Martin

    //WMCapacityController has dependencies upon records of the following objects, and their
    //actions can also be found as reference here. These are the items that must be accounted for
    //in the test class.

    //Case
    	//Case has a service date updated (updateCase)
    	//Case has the Availability Confirmed checkbox updated (updateCase)
    	//Case has the Availability Checked checkbox updated (updateCase and confirmCheck)
    	//Case record is inspected for viability for use within the component and may return true or false (validate)
    	//SLA Date Time, when available, is returned with exception handling (getSLADate)
    //Asset
    	//ServiceHeader record is associated to the case and is used to return all ServiceDetails
    	//ServiceDetails are inspected for Core Service and the baseline returned (getAcornBaseline)
    //Account - Supplier
    	//Supplier account arranged in a hierarchy is inspected for validation of parent account (getAcornBaseline)
    //capacityResponse - custom wrapper and constructor
    	//Constructor needs to be confirmed 
    	
    //Order of operations for test setup:
    	//Account Supplier - Parent where VID = 8
    	//Account Supplier - Child whose parent = parent above and BU = 2881
    	//Asset ServiceHeader record of product type roll off
    	//Asset ServiceDetail records whose parent = ServiceHeader and at least one with a core service designation and baseline 8422438
    	//Case record tied to asset service header
    
    @testSetup
    static void setup() {
        RecordType supplierRT = [SELECT Id FROM RecordType WHERE DeveloperName='Vendor'];
        RecordType headerRT = [SELECT Id FROM RecordType WHERE DeveloperName='Service_Header'];
        RecordType detailRT = [SELECT Id FROM RecordType WHERE DeveloperName='Service_Detail'];
        RecordType pickupRT = [SELECT Id FROM RecordType WHERE DeveloperName='Pickup_Case'];
        
        Product2 rolloffProduct = new Product2();
        Account parentSupplier = new Account();
        Account childSupplier = new Account();
        Asset headerAsset = new Asset();
        Asset detailAsset = new Asset();
        Asset headerAsset1 = new Asset();
        Asset detailAsset1 = new Asset();
        Case c1 = new Case();
        Case c2 = new Case();
        
        rolloffProduct.Name = '30 Yard Open Top';
        rolloffProduct.Family ='Rolloff';
        insert rolloffProduct;
        
        parentSupplier.Name = 'Parent WM Account';
        parentSupplier.AccountNumber = '8';
        parentSupplier.RecordTypeId = supplierRT.Id;
        insert parentSupplier;
        
        childSupplier.Name = 'Child WM Account';
        childSupplier.ParentId = parentSupplier.Id;
        childSupplier.Vendor_Business_Unit__c = '2881';
        childSupplier.RecordTypeId = supplierRT.Id;
        insert childSupplier;
        
        headerAsset.Name = '30 yard trash open top';
        headerAsset.Supplier__c = childSupplier.Id;
        headerAsset.RecordTypeId = headerRT.Id;
        insert headerAsset;
        
        detailAsset.Name = 'Haul';
        detailAsset.ParentId = headerAsset.Id;
        detailAsset.Is_Core_Service__c = TRUE;
        detailAsset.RecordTypeId = detailRT.Id;
        detailAsset.Supplier__c = childSupplier.Id;
        detailAsset.Acorn_SBID__c = 8422438;
        detailAsset.Start_Date__c = date.today();
        insert detailAsset;
        
        headerAsset1.Name = '30 yard trash open top';
        headerAsset1.Supplier__c = childSupplier.Id;
        headerAsset1.RecordTypeId = headerRT.Id;
        insert headerAsset1;
        
        detailAsset1.Name = 'Haul';
        detailAsset1.ParentId = headerAsset1.Id;
        detailAsset1.Is_Core_Service__c = TRUE;
        detailAsset1.RecordTypeId = detailRT.Id;
        detailAsset1.Supplier__c = childSupplier.Id;
        detailAsset1.Start_Date__c = date.today();
        insert detailAsset1;
        
        DateTime Now = datetime.now();
        DateTime slaDate = Now.addDays(1);
        
        c1.Subject = 'Test Case';
        c1.RecordTypeId = pickupRT.Id;
        c1.AssetId = headerAsset.Id;
        c1.SLA_Service_Date_Time__c = slaDate;
        c1.Status = 'New';
        insert c1;
        
        c2.Subject = 'Test Case';
        c2.RecordTypeId = pickupRT.Id;
        c2.AssetId = headerAsset1.Id;
        c2.SLA_Service_Date_Time__c = Null;
        c2.Status = 'New';
        insert c2;
    }
    @isTest public static void testGetSLADate() {
        
        //Test of C1 Case record accounts for the parsing of Date/Time values
        //SLA_Service_Date_Time__c is returned in YYYY-MM-DD HH:MM:SS format
        /*Case c1 = [SELECT Id, SLA_Service_DateTime__c 
                   FROM Case 
                   WHERE SLA_Service_DateTime__c != Null LIMIT 1];
        String slaStringExact = String.valueOf(c1.SLA_Service_DateTime__c).substringBefore(' ');
        String year = slaStringExact.substringBefore('-').substringBefore(' ');
        String day = slaStringExact.substringAfterLast('-');
        String month = slaStringExact.substringBeforeLast('-').substringAfter('-');
        String slaString = month + '/' + day + '/' + year;
        String result1 = WMCapacityController.getSLADate(c1.Id);*/
        
        //Test method should return nothing if it's not available, and the action
        //to set a value is decided by the Lightning Component's Server-side helper
        Case c2 = [SELECT Id, SLA_Service_DateTime__c
                  FROM Case
                  WHERE SLA_Service_DateTime__c = Null LIMIT 1];
        String result2 = WMCapacityController.getSLADate(c2.Id);
        
        //system.debug('Result1 Is ' + result1);
        //system.debug('slaString Is ' + slaStringExact);
        
        //system.assertEquals(result1, slaStringExact);
        system.assertEquals(result2, Null);
    }
    @isTest public static void testUpdateCase() {
        
        //Test to return the case and pass in a new service date formatted
        //as a string, and validate that the passed in value and the new
        //case service date are equal
        List<Case> c = [SELECT Id, Service_Date__c
                 FROM Case
                 LIMIT 2];
        
        String newDate = '01/01/2025';
        String sysDate = '2025-01-01';
        
        WMCapacityController.updateCase(c[0].Id, newDate);
        WMCapacityController.confirmCheck(c[1].Id);
        
        Case c2 = [SELECT Id, Service_Date__c, Availability_Confirmed__c, Availability_Checked__c
                  FROM Case
                  WHERE Id =: c[0].Id
                  LIMIT 1];
        
        Case c3 = [SELECT Id, Availability_Checked__c
                  FROM Case
                  WHERE Id =: c[1].Id
                  LIMIT 1];
        
        system.assertEquals(String.valueOf(c2.Service_Date__c), sysDate);
        system.assertEquals(c2.Availability_Confirmed__c, TRUE);
        system.assertEquals(c2.Availability_Checked__c, TRUE);        
        system.assertEquals(c3.Availability_Checked__c, TRUE);
    }
    @isTest public static void testGetAcornBaseline() {
        
        //Test to return the baseline
        Case c = [SELECT Id
                 FROM Case
                 WHERE SLA_Service_Date_Time__c != Null LIMIT 1];
        
        Case c1 = [SELECT Id
                  FROM Case
                  WHERE SLA_Service_Date_Time__c = Null LIMIT 1];
        
        String baselinePositive = WMCapacityController.getAcornBaseline(c.Id);
        String baselineNegative = WMCapacityController.getAcornBaseline(c1.Id);
        
        system.assertEquals(baselinePositive, '8422438');
        system.assertEquals(baselineNegative, '0');
    }
    @isTest public static void testDualList() {
        
        WMCapacityController.dualList testDL = new WMCapacityController.dualList('test', 'test');
        system.assertEquals(testDL.label, 'test');
        system.assertEquals(testDL.value, 'test');
    }
    @isTest public static void testCapacityResponse() {
        String json = '{'+
		'  \"Data\": {'+
		'    \"Site\": {'+
		'      \"Name\": \"string\",'+
		'      \"Capacity\": ['+
		'        {'+
		'          \"LineOfBusiness\": \"string\",'+
		'          \"Status\": \"string\",'+
		'          \"AvailableDates\": ['+
		'            \"string\"'+
		'          ]'+
		'        }'+
		'      ]'+
		'    }'+
		'  },'+
		'  \"Problem\": {'+
		'    \"Title\": \"string\",'+
		'    \"Status\": 0,'+
		'    \"Errors\": ['+
		'      {'+
		'        \"Code\": \"string\",'+
		'        \"Message\": \"string\"'+
		'      }'+
		'    ]'+
		'  }'+
		'}';
		WMCapacityController.capacityResponse obj = WMCapacityController.capacityResponse.parseCapacity(json);
		System.assert(obj != null);
    }
    @isTest public static void testGetAvailableDates() {
        
        Case c = [SELECT Id
                 FROM Case
                 WHERE SLA_Service_Date_Time__c != Null
                 LIMIT 1];
        
        String baseline = WMCapacityController.getAcornBaseline(c.Id);
        String slaDate = WMCapacityController.getSLADate(c.Id);
        
        system.debug('baseline ++ '+baseline);
        system.debug('slaDate ++ '+slaDate);
        
        List<String> testDates = WMCapacityController.getAvailableDates(baseline);
        
        //System.assert(testDates.size() > 0 && testDates != Null);
        
        String json1 = '{\"Data\":{\"Site\":{\"Name\":null,\"Capacity\":[{\"LineOfBusiness\":\"Rolloff\",\"Status\":\"Available\",\"AvailableDates\":[\"2019/08/02\",\"2019/08/05\",\"2019/08/06\",\"2019/08/07\",\"2019/08/08\",\"2019/08/09\",\"2019/08/12\",\"2019/08/13\",\"2019/08/14\",\"2019/08/15\"]}]}},\"Problem\":null}';
        String json2 = '{\"Data\":{\"Site\":{\"Name\":null,\"Capacity\":[{\"LineOfBusiness\":\"Rolloff\",\"Status\":\"Unavailable\",\"AvailableDates\":[\"2019/08/05\",\"2019/08/06\",\"2019/08/07\",\"2019/08/08\",\"2019/08/09\",\"2019/08/12\",\"2019/08/13\",\"2019/08/14\",\"2019/08/15\"]}]}},\"Problem\":null}';

        WMCapacityController.capacityResponse capRepPos = WMCapacityController.capacityResponse.parseCapacity(json1);
        WMCapacityController.capacityResponse capRepNeg = WMCapacityController.capacityResponse.parseCapacity(json2);
        
        List<String> testPosDates = WMCapacityController.parseCapJSON(capRepPos, '08/01/2019');
        List<String> testPosDates1 = WMCapacityController.parseCapJSON(capRepPos, '2019-08-01');
        List<String> testNegDates = WMCapacityController.parseCapJSON(capRepNeg, '08/01/2019');
        
        system.assertEquals(testPosDates[0], '08/02/2019');
        system.assertEquals(testPosDates1[0], '08/02/2019');
        system.assertEquals(testNegDates[0], '08/05/2019');
    }
}