@isTest(seeAllData=false)
global class AcornCompanyDetailsTest {
   
	@testSetup static void setup() {
		Profile adminProfile = TestDataFactory.getProfile('System Administrator');
		User usr = TestDataFactory.createUser(adminProfile);
		insert usr;

		list<Account> accounts = TestDataFactory.createAccount('Test Account',usr);
		Integer acctNum =1;
		for (Account a: accounts) {
			a.AccountNumber = 'Account-' + acctNum;
			acctNum++;
		}
		insert accounts;
	}
	@isTest static void testCompanyCategories() {
        //Query some account and pass it to the company categories method
        List<Account> acctNumber = [Select Customer_Code__c from Account limit 1];
        List<String> acctIds = new List<String>();       
        For (Account a: acctNumber) {
            acctIds.add(a.Customer_Code__c);
        }
        //acctIds.add(COMPANY_CODE);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AcornCompanyDetailsMock());
        List<List<String>> MethodResults = AcornCompanyDetails.getCompanyCategories(acctIds);
        Map<String, String> methodMaps = AcornCompanyDetails.getAcornCCMap(acctIds[0]);
        Test.stopTest();
        System.assert(MethodResults != null);
    }
    
    global class AcornCompanyDetailsMock implements HTTPCalloutMock {
    	global HTTPResponse respond(HTTPRequest request) {
         
         String json = '{'+
		'    \"Data\": ['+
		'        {'+
		'            \"Code\": \"WAL-NS\",'+
		'            \"Name\": \"New Store\",'+
		'            \"Description\": \"New Store\",'+
		'            \"IsConstructionDemolition\": 1'+
		'        },'+
		'        {'+
		'            \"Code\": \"WAL-R\",'+
		'            \"Name\": \"Remodel\",'+
		'            \"Description\": \"Remodel\",'+
		'            \"IsConstructionDemolition\": 1'+
		'        },'+
		'        {'+
		'            \"Code\": \"WAL_24976359\",'+
		'            \"Name\": \"Take Over\",'+
		'            \"Description\": \"Take Over\",'+
		'            \"IsConstructionDemolition\": 1'+
		'        },'+
		'        {'+
		'            \"Code\": \"WAL_26515170\",'+
		'            \"Name\": \"H&W SSR\",'+
		'            \"Description\": \"H&W SSR\",'+
		'            \"IsConstructionDemolition\": 0'+
		'        },'+
		'        {'+
		'            \"Code\": \"WAL_28823501\",'+
		'            \"Name\": \"MC Project\",'+
		'            \"Description\": \"MC Project\",'+
		'            \"IsConstructionDemolition\": 1'+
		'        },'+
		'        {'+
		'            \"Code\": \"WAL_34684539\",'+
		'            \"Name\": \"Relocation\",'+
		'            \"Description\": \"Relocation (New Stores)\",'+
		'            \"IsConstructionDemolition\": 1'+
		'        },'+
		'        {'+
		'            \"Code\": \"WAL_37219753\",'+
		'            \"Name\": \"Milk Plant\",'+
		'            \"Description\": \"Milk Plant\",'+
		'            \"IsConstructionDemolition\": 1'+
		'        },'+
		'        {'+
		'            \"Code\": \"WAL_39208837\",'+
		'            \"Name\": \"Offsite Warehouse\",'+
		'            \"Description\": \"Offsite Warehouse\",'+
		'            \"IsConstructionDemolition\": 1'+
		'        },'+
		'        {'+
		'            \"Code\": \"WAL_42837931\",'+
		'            \"Name\": \"Consolidation Center\",'+
		'            \"Description\": \"Consolidation Center\",'+
		'            \"IsConstructionDemolition\": 1'+
		'        },'+
		'        {'+
		'            \"Code\": \"WAL_45350948\",'+
		'            \"Name\": \"Non-Retail Metal Division 7\",'+
		'            \"Description\": \"Non-Retail Metal Division 7\",'+
		'            \"IsConstructionDemolition\": 0'+
		'        },'+
		'        {'+
		'            \"Code\": \"WAL_52176350\",'+
		'            \"Name\": \"White Box\",'+
		'            \"Description\": \"White Box\",'+
		'            \"IsConstructionDemolition\": 1'+
		'        },'+
		'        {'+
		'            \"Code\": \"WAL_56342216\",'+
		'            \"Name\": \"FET\",'+
		'            \"Description\": \"FET\",'+
		'            \"IsConstructionDemolition\": 1'+
		'        },'+
		'        {'+
		'            \"Code\": \"WAL_92573356\",'+
		'            \"Name\": \"Dark Stores\",'+
		'            \"Description\": \"Dark Stores\",'+
		'            \"IsConstructionDemolition\": 1'+
		'        },'+
		'        {'+
		'            \"Code\": \"WAL_A\",'+
		'            \"Name\": \"Auction\",'+
		'            \"Description\": \"Auction\",'+
		'            \"IsConstructionDemolition\": 1'+
		'        },'+
		'        {'+
		'            \"Code\": \"WAL_EX\",'+
		'            \"Name\": \"Expansion\",'+
		'            \"Description\": \"Expansion\",'+
		'            \"IsConstructionDemolition\": 1'+
		'        },'+
		'        {'+
		'            \"Code\": \"WAL_G\",'+
		'            \"Name\": \"Grocery\",'+
		'            \"Description\": \"Grocery\",'+
		'            \"IsConstructionDemolition\": 0'+
		'        },'+
		'        {'+
		'            \"Code\": \"WAL_OF\",'+
		'            \"Name\": \"Old Fixtures\",'+
		'            \"Description\": \"Old Fixtures\",'+
		'            \"IsConstructionDemolition\": 1'+
		'        },'+
		'        {'+
		'            \"Code\": \"WAL_SP\",'+
		'            \"Name\": \"Special Project\",'+
		'            \"Description\": \"Special Project\",'+
		'            \"IsConstructionDemolition\": 1'+
		'        }'+
		'    ],'+
		'    \"Problem\": null'+
		'}';
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody(json);
        response.setStatusCode(200);
        return response;
    	}
	}
    @isTest static void testArray() {
        List<string> testArray = New List<String>();
        testArray.add('A');
        testArray.add('D');
        testArray.add('B');
        testArray.add('C');
        
        testArray.sort();
        
        System.assertEquals(testArray[1], 'B');
        System.assertEquals(testarray[3], 'D');
    }    
}