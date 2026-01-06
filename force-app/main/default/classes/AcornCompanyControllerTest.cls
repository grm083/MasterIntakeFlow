@IsTest
public class AcornCompanyControllerTest {

	static testMethod void testParse() {
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
		AcornCompanyController obj = AcornCompanyController.parse(json);
		System.assert(obj != null);
	}
}