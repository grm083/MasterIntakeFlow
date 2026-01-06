@isTest (SeeAllData = FALSE)
	/*
	 * @Name          STPCriteriaServiceTest
	 * @Author        Digdershika Ojha
	 * @Vendor		  TCS
	 * @Date          10/02/2023
	 * @description	  This class will be used as Test class for STPCriteriaService, initially created for story SDT-26174
	 */
public class STPCriteriaServiceTest {

    /*
	 * @MethodName    setup
	 * @Author        Digdershika Ojha
	 * @Vendor		  TCS
	 * @description	  This method will be used to setup inital required data to test getStpRule method.
	 * creating a STPCriteria record having a customer_all field true
	 */
	 /*
	@testSetup static void setup(){
	List<User> userList = new List<User>();
        Profile p = TestDataFactory.getProfile('System Administrator');
        User user = TestDataFactory.createUser(p);
        List<STP_Criteria__c> stpCriteriaList = new List<STP_Criteria__c>();
		Database.insert(user);
		system.runAs(user){
			//creating STP criteria with customer all is true
            STP_Criteria__c ruleWithCustomerAll = QuoteTestDataFactory.createSTPCriteriaWithAllParam(null, true, true,
                                                                                      'TEMP', 'Open Top', 'OC',
                                                                                      'Trash', 'New Service Case',true, '8',null);
            stpCriteriaList.add(ruleWithCustomerAll);
			QuoteTestDataFactory.insertSTPRules(stpCriteriaList);
		}
	}*/
    /*
	 * @MethodName    testGetSTPRules
	 * @Author        Digdershika Ojha
	 * @description	  Test if getSTPRules method is able to fetch the records which is created in setup method
	 */
	 /*
	@isTest
    static void testGetSTPRules(){
		String duration = 'Temporary';
		String recordType = 'New Service Case';
		String material = 'Trash';
		String product = 'Open Top';
        String frequency = 'OC';
        ID idObj = 'a9H8A000000A4t4UAC';
		Map<Id,string> quoteLineProductMap = new Map<Id,string>();
        quoteLineProductMap.put(idObj,product);
		Map<Id,string> quotLineMaterialMap = new Map<Id,string>();
        quotLineMaterialMap.put(idObj,material);
        Map<Id,string> quotLineOccuranceTypeMap = new Map<Id,string>();
        quotLineOccuranceTypeMap.put(idObj,frequency);
		Test.startTest();
		List<STP_Criteria__c> stpRules = STPCriteriaService.getSTPRules( recordType, quoteLineProductMap, quotLineMaterialMap, duration, quotLineOccuranceTypeMap);
		system.assertEquals(1,stpRules.size());
		system.assertEquals(recordType,stpRules.get(0).Service_Type__c);
		Test.stopTest();
	}*/

}