/*
* @Name          STPCriteriaSelectorTest
* @Author        Digdershika Ojha
* @Vendor		 TCS
* @Date          24/02/2023
* @LastModifiedDate 07/11/2023
* @LastModifiedBy   Digdershika Ojha
* @description	  This class will be used as Test class for STPCriteriaSelector, initially created for story SDT-26174
*/
@isTest (SeeAllData = FALSE)
public class STPCriteriaSelectorTest {
    public static final string CUSTOMER_SERVICE = 'Customer Service';
    public static final string SYS_ADMIN = 'System Administrator';
    public static final string parent_AccName = 'Test Parent Account';
    public static final Map<Id,string> quoteLineProductMap = new Map<Id,string>();
    public static final Map<Id,string> durationMap = new Map<Id,string>();
    /*
	 * @MethodName    setup
	 * @Author        Digdershika Ojha
	 * @Vendor		  TCS
	 * @description	  This method will be used to setup inital required data to test getStpRule method.
	 * creating a STPCriteria record having a customer_all field true
	 * @return		  void
	 */
	@testSetup static void setup(){
        List<User> userList = new List<User>();
            Profile adminProfile = TestDataFactory.getProfile(SYS_ADMIN);
        	Profile csUserProfile = TestDataFactory.getProfile(CUSTOMER_SERVICE);
            User adminUser = TestDataFactory.createUser(adminProfile);
            User csrUser = TestDataFactory.createUser(csUserProfile);
            Database.insert(adminUser);
        	Database.insert(csrUser);
            List<STP_Criteria__c> stpCriteriaList = new List<STP_Criteria__c>();
            List<STP_Criteria__c> stpCriteriaExemptionList = new List<STP_Criteria__c>();
            string byPassProducts = 'Delivery;Container Service Charge';
            
            String customer_code = 'WAL';
            
            system.runAs(adminUser){
                Product2 openTop = TestDataFactory.createProduct('Open Top','Rolloff', 'OT');
                //creating STP criteria with customer all is true
                STP_Criteria__c ruleWithCustomerAll = QuoteTestDataFactory.createSTPCriteriaWithAllParam(null, true, true,
                                                                                          'TEMP', 'Open Top', 'OC',
                                                                                          'Trash', 'New Service Case',true, '8','K00129',null, true, true, 'Full STP', true, false, false, true, '', 'Any');
                STP_Criteria__c ruleWithCustomerAllPERM = QuoteTestDataFactory.createSTPCriteriaWithAllParam(null, true, true,
                                                                                          'PERM', 'Open Top', 'SOC',
                                                                                          'Trash', 'New Service Case',true, '8','K00129',null, true, true, 'Full STP', true, false, false, true, '', 'Any');
                STP_Criteria__c multipleFrequency = QuoteTestDataFactory.createSTPCriteriaWithAllParam(null, true, true,
                                                                                          'PERM', 'Open Top', 'OC;SOC',
                                                                                          'Trash', 'New Service Case',true, '8','K00129',null, true, true, 'Full STP', true, false, false, true, '', 'Any');
                
                stpCriteriaList.add(ruleWithCustomerAll);
                stpCriteriaList.add(ruleWithCustomerAllPERM);
                stpCriteriaList.add(multipleFrequency);
                QuoteTestDataFactory.insertSTPRules(stpCriteriaList);
                
                //Exemption Stp Criteria
                Account parentAccount = QuoteTestDataFactory.createParentAccountRecord(parent_AccName,customer_code, 
                                                                                   ConstantClass.RecordType_Client, adminUser);

                parentAccount.Status__c = 'Active'; 
                parentAccount.Accounting_System__c = 'WMNAT';                                                                     
                QuoteTestDataFactory.insertAccount(parentAccount);
                
                
                STP_Criteria__c exemptionStpCriteria = QuoteTestDataFactory.createSTPExemptionWithAllParam(parentAccount, byPassProducts,true,Constant_Util.KEYWORD_TEST);
                exemptionStpCriteria.Duration__c = 'TEMP';
                exemptionStpCriteria.Equipment__c = 'Open Top';
                stpCriteriaExemptionList.add(exemptionStpCriteria);
                QuoteTestDataFactory.insertSTPRules(stpCriteriaExemptionList);
            }
        }
        /*
         * @MethodName    : testGetRecordByMatchingQuote
         * @description	  : Test if getRecordByMatchingQuote method is able to fetch the records for matching quote values.
         * @return        : void
         */
        @isTest
        static void testGetRecordByMatchingQuote(){
            User adminUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND IsActive = true  LIMIT 1];
            //String duration = 'Temporary';
            String recordType = 'New Service Case';
            String material = 'Trash';
            String product = 'Open Top';
            String frequency = 'OC';
            String stpEligibilityRecType = 'STP Eligibility';
            ID idObj = 'a9H8A000000A4t4UAC';
            Map<Id,string> quoteLineProductMap = new Map<Id,string>();
            quoteLineProductMap.put(idObj,product);
            Map<Id,string> quotLineMaterialMap = new Map<Id,string>();
            quotLineMaterialMap.put(idObj,material);
            Map<Id,string> quotLineOccuranceTypeMap = new Map<Id,string>();
            quotLineOccuranceTypeMap.put(idObj,frequency);
            Map<Id,string> durationMap = new Map<Id,string>();
            durationMap.put(idObj,'Temporary');
            Test.startTest();
            System.runAs(adminUser){
            List<STP_Criteria__c> stpRules = STPCriteriaSelector.getRecordByMatchingQuote( recordType, quoteLineProductMap, quotLineMaterialMap, durationMap, 
            quotLineOccuranceTypeMap, stpEligibilityRecType, 'Full STP');
            //system.assertEquals(1,stpRules.size(),'Expected record size is 1');
//            system.assertEquals(recordType,stpRules.get(0).Service_Type__c,'Expected record type is New Service case');
        	}
            Test.stopTest();
        }

        /*
         * @MethodName    : testExemptionRecord
         * @description	  : Test if getSTPExemptionRecord method is able to fetch the active stp exemtion records.
         * @return        : void
         */
        @isTest
        static void testExemptionRecord(){
           User adminUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND IsActive = true  LIMIT 1];
            Test.startTest();
            
            System.runAs(adminUser){
                Account acc = [SELECT Id,Name,Customer_Code__c FROM Account where Name = :parent_AccName LIMIT 1];
                quoteLineProductMap.put(acc.Id,'Open Top');
            	durationMap.put(acc.Id,'Temporary');
            //List<STP_Criteria__c> stpRules = STPCriteriaSelector.getSTPExemptionRecord('Client Pricing Exemption', 'WAL');
            List<STP_Criteria__c> stpRules = STPCriteriaSelector.getSTPExemptionRecord('Client Pricing Exemption', 'WAL',durationMap,quoteLineProductMap);
            //System.debug(' stpRules.size() '+ stpRules.size());
            //    system.assertEquals(1,stpRules.size(),'Expected record size is 1');
            }
            Test.stopTest();
        }
            /*
         * @MethodName    : testMultipleGetRecordByMatchingQuote
         * @description	  : Test if getRecordByMatchingQuote method is able to fetch multiple records for matching quote values.
         * @return        : void
         */
        @isTest
        static void testMultipleGetRecordByMatchingQuote(){
            User adminUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND IsActive = true  LIMIT 1];
            String recordType = 'New Service Case';
            String materialTrash = 'Trash';
            String productOT = 'Open Top';
            String frequencyOC = 'OC';
            String frequencySOC = 'SOC';
            String stpEligibilityRecType = 'STP Eligibility';
            ID idObj1 = 'a9H8A000000A4t4UAC';
            ID idObj2 = 'a9H8A000000A4t4UAD';
            Map<Id,string> quoteLineProductMap = new Map<Id,string>();
            quoteLineProductMap.put(idObj1,productOT);
            Map<Id,string> quotLineMaterialMap = new Map<Id,string>();
            quotLineMaterialMap.put(idObj1,materialTrash);
            Map<Id,string> quotLineOccuranceTypeMap = new Map<Id,string>();
            quotLineOccuranceTypeMap.put(idObj1,frequencyOC);
            quotLineOccuranceTypeMap.put(idObj2,frequencySOC);
            Map<Id,string> durationMap = new Map<Id,string>();
            durationMap.put(idObj1,'Temporary');
            durationMap.put(idObj2,'Permanent');
            Test.startTest();
            System.runAs(adminUser){
                List<STP_Criteria__c> stpRules = STPCriteriaSelector.getRecordByMatchingQuote( recordType, quoteLineProductMap, quotLineMaterialMap, durationMap, 
                quotLineOccuranceTypeMap, stpEligibilityRecType, 'Full STP');
                //system.assertEquals(3,stpRules.size(),'Expected record size is 3');
                //system.assertEquals(recordType,stpRules.get(0).Service_Type__c,'Expected record type is New Service case');
                //system.assertEquals(recordType,stpRules.get(1).Service_Type__c,'Expected record type is New Service case');
            }
            Test.stopTest();
        }
    	/*
         * @MethodName    : testSTPEligibilityByCSRPersona
         * @description	  : Test if customer representative is able or not to Fetch stp criteria record of type STP Exemption.
         * @return        : void
         */
        @isTest
        static void testSTPExemptionByCSRPersona(){
           User csrUser = [SELECT Id FROM User WHERE Profile.Name = :CUSTOMER_SERVICE AND IsActive = true  LIMIT 1];
            Test.startTest();
            System.runAs(csrUser){
                Account acc = [SELECT Id,Name,Customer_Code__c FROM Account where Name = :parent_AccName LIMIT 1];
                quoteLineProductMap.put(acc.Id,'Open Top');
            	durationMap.put(acc.Id,'Temporary');
            List<STP_Criteria__c> stpRules = STPCriteriaSelector.getSTPExemptionRecord('Client Pricing Exemption', 'WAL',durationMap,quoteLineProductMap);
            //System.debug('stpRules.size() '+ stpRules.size());
			//system.assertEquals(1,stpRules.size(),'Expected record size is 1');
            }
            Test.stopTest();
        }

}