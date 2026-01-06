@isTest

public class TestScreenpopEmulatorController {
    
    Public Static String CLIENT_ID = '1001';
    Public Static String Location_ID;
    private static final string TESTSUPPLIER = 'testsupplier';
    private static final string SUPPLIER = 'Vendor';
    private static final string COMMERCIAL = 'Commercial';
    private static final string COMPACTOR = 'COMPACTOR';
    private static final string ASSET_NAME = '8 yrd Dumpster';
    private static final string PRODUCT = '8 yrd';
    
	@isTest
    public static void testPageTitle() {        
        PageReference pageRef = Page.ScreenpopEmulator;
        Test.setCurrentPage(pageRef);
    	ScreenpopEmulatorController controller = new ScreenpopEmulatorController();
        System.assert(controller.PageTitle != null && controller.PageTitle.length() > 0);        
    }
    
    @isTest
    public static void testUpdateScreenpopUrl1() {  
        
        PageReference pageRef = Page.ScreenpopEmulator;
        Test.setCurrentPage(pageRef);
        
    	ScreenpopEmulatorController controller = new ScreenpopEmulatorController();
        controller.MediaType = ScreenpopController.MEDIA_TYPE_VOICE;
        controller.GenesysId = 'TEST1234567890';
        controller.ReferenceNumber = 'TEST12345';
        controller.IntentSelected = 'ETA';
        controller.AccountSelected = '10001';
        controller.LocationSelected = '10002';
        controller.ContactSelected = '10003';
        controller.workOrder = '12343';
        controller.AssetSelected = '3434edf534';
        controller.ivrr4c = 'ETA';
        controller.ivrqueue = 'RETAIL_IV_GENERAL';
        controller.ivrlanguage = 'English';
        controller.ivrlob = 'Retail';
        controller.ivrexitpoint = 'Pickup';
        controller.ivrsseligible = 'Y';
        controller.isVendor = 'Y';
        controller.ivrdnis = '354345465';
        controller.ivrani = '354345465';
        controller.tpFlag = 'Empty and Return';
        controller.pickDate = 'Y';
	//Added as part of SDT-17701
        controller.ivrSpokenName = 'Test User';
        controller.ivrIntentName = 'Test Pickup';
        controller.ivrSpokenLoc = 'HMD000101';
        controller.ivrSpokenRefNum = '00032121';
        controller.ivrSpokenIntent = 'I want pickup';  //18313
		controller.updateScreenpopUrl();
        
        String expectedUrl = ScreenpopEmulatorController.BASE_URL + ScreenpopController.MEDIA_TYPE_VOICE + '&'
            + ScreenpopController.PARAM_CONNECTION_ID + '=TEST1234567890&'
            + ScreenpopController.PARAM_REF_NO + '=TEST12345&'
            + 'cti_WorkOrderNumber=12343&'+
            + ScreenpopController.PARAM_INTENT + '=ETA&'
            + ScreenpopController.PARAM_ACCT_ID + '=10001&'
            + ScreenpopController.PARAM_LOCATION_ID + '=10002&'
            + ScreenpopController.PARAM_ASSET_ID + '=3434edf534&'
            + ScreenpopController.PARAM_CONTACT_ID + '=10003'
            + '&ivrskill=ETA&cti_TargetVQ=RETAIL_IV_GENERAL&cti_ivrlanguage=English&'
            + 'ivrlob=Retail&cti_ivrexitpoint=Pickup&ivrsseligible=Y&ivrisvendor=Y'
            + '&cti_DNIS=354345465&cti_CallersANI=354345465&ivrpickupdate=Y'
            + '&cti_NameTitle=Test User&cti_IntentName=Test Pickup&cti_SpokenLocName=HMD000101&cti_SpokenRefNumber=00032121&cti_SpokenIntent=I want pickup';
		System.assertEquals(expectedUrl, controller.ScreenpopUrl);
    }
    
    @isTest
    public static void testUpdateScreenpopUrl2() {  
        
        PageReference pageRef = Page.ScreenpopEmulator;
        Test.setCurrentPage(pageRef);
        
    	ScreenpopEmulatorController controller = new ScreenpopEmulatorController();
        controller.MediaType = ScreenpopController.MEDIA_TYPE_WORKITEM;
        controller.ReferenceNumber = 'TEST12345';
		controller.updateScreenpopUrl();
        
        String head = ScreenpopEmulatorController.BASE_URL + ScreenpopController.MEDIA_TYPE_WORKITEM + '&'
            + ScreenpopController.PARAM_INTERACTION_ID;
		System.assert(controller.ScreenpopUrl != null && controller.ScreenpopUrl.startsWith(head));
        
        String tail = ScreenpopController.PARAM_REF_NO + '=TEST12345';
		System.assert(controller.ScreenpopUrl != null && controller.ScreenpopUrl.endsWith(tail));
    }
    
    @isTest
    public static void testLoadAccountLists() {  
        
        PageReference pageRef = Page.ScreenpopEmulator;
        Test.setCurrentPage(pageRef); 
        createAccountListsTestData();
    	ScreenpopEmulatorController controller = new ScreenpopEmulatorController();
        List<SelectOption> accounts = controller.getAccountList();
        System.debug('>>>>> TestScreenpopEmulatorController.testLoadAccountLists: accounts count = ' + accounts.size());
        System.assert(accounts != null && accounts.size() > 1, 'No accounts found!');
        
       	Integer lCount = 0;
        Integer cCount = 0;
        
        for(SelectOption a : accounts) {            
            if(a.getLabel().startsWith('Select ')){ continue;
            controller.AccountSelected = a.getValue();            
            System.debug('>>>>> TestScreenpopEmulatorController.testLoadAccountLists: AccountSelected = ' + controller.AccountSelected);
            controller.loadAccountLists();            
            lCount += controller.LocationList == null ? 0 : controller.LocationList.size() - 1;
            cCount += controller.ContactList == null ? 0 : controller.ContactList.size() - 1;
            }else{}                                      
            if(lCount > 0 && cCount > 0){ break;}else{}
        }
        
        System.debug('>>>>> TestScreenpopEmulatorController.testLoadAccountLists: location count = ' + lCount + ', contact count = ' + cCount);
        //System.assert(lCount > 0 && cCount > 0, 'No locations or contacts found for ' + accounts.size() + ' accounts!');
    }
    
    @isTest
    public static void testToggleOnMediaType1() {  
        
        PageReference pageRef = Page.ScreenpopEmulator;
        Test.setCurrentPage(pageRef); 
        createAccountListsTestData();
    	ScreenpopEmulatorController controller = new ScreenpopEmulatorController();
         
        controller.MediaType = ScreenpopController.MEDIA_TYPE_VOICE;
        controller.toggleOnMediaType();
        System.assert(controller.ScreenpopUrl.contains(ScreenpopController.PARAM_CONNECTION_ID), 'Connection ID not found!');
        
    }
    
    @isTest
    public static void testToggleOnMediaType2() {  
        
        PageReference pageRef = Page.ScreenpopEmulator;
        Test.setCurrentPage(pageRef); 
        createAccountListsTestData();
    	ScreenpopEmulatorController controller = new ScreenpopEmulatorController();
        controller.MediaType = ScreenpopController.MEDIA_TYPE_WORKITEM;
       controller.AccountSelected = CLIENT_ID;
        controller.toggleOnMediaType();
        System.assert(controller.ScreenpopUrl.contains(ScreenpopController.PARAM_INTERACTION_ID), 'Interaction ID not found!');
        
    }
    @isTest
    public static void loadLocationListTest() {  
        
        PageReference pageRef = Page.ScreenpopEmulator;
        Test.setCurrentPage(pageRef); 
        createAccountListsTestData();
    	ScreenpopEmulatorController controller = new ScreenpopEmulatorController();
        controller.MediaType = ScreenpopController.MEDIA_TYPE_WORKITEM;
        controller.AccountSelected = CLIENT_ID;
        controller.LocationSelected = Location_ID;
        controller.loadLocationList();
        System.assert(controller.ScreenpopUrl.contains(ScreenpopController.PARAM_INTERACTION_ID), 'Interaction ID not found!');
        
    }
    
    @isTest
    public static void loadContactListTest() {  
        
        PageReference pageRef = Page.ScreenpopEmulator;
        Test.setCurrentPage(pageRef); 
        createAccountListsTestData();
    	ScreenpopEmulatorController controller = new ScreenpopEmulatorController();
        controller.MediaType = ScreenpopController.MEDIA_TYPE_WORKITEM;
        controller.AccountSelected = CLIENT_ID;
        controller.LocationSelected = Location_ID;
        controller.loadContactList();
        System.assert(controller.ScreenpopUrl.contains(ScreenpopController.PARAM_INTERACTION_ID), 'Interaction ID not found!');
        
    }
    
    public static void createAccountListsTestData() {
        
        Profile p = TestDataFactory.getProfile('Standard User');
        
        User u = TestDataFactory.createUser(p);
        insert u;
        System.debug('>>>>> TestScreenpopEmulatorController.createAccountListsTestData: User created');
        
        List<Account> clients = TestDataFactory.createAccount('ACME', u, 'Client');
        if(clients == null || clients.size() < 1){ return;}else{}
        
        Account client = clients.get(0);
        client.Status__c = Constant_Util.ACTIVE;
        insert client;
        CLIENT_ID = client.id;
        System.debug('>>>>> TestScreenpopEmulatorController.createAccountListsTestData: Client account created [' + client + ']');
       
        
        List<Account> locations = TestDataFactory.createLocation('ACME000001', u, client.Id);
        if(locations == null || locations.size() < 1){ return;}else{}
        
        Account location = locations.get(0);
        location.Status__c = Constant_Util.ACTIVE;
        insert location;
        Location_ID = location.Id;
        System.debug('>>>>> TestScreenpopEmulatorController.createAccountListsTestData: Location created [' + location + ']');
        
        list<product2> productlist = TestDataFactory.createProduct(PRODUCT);
        productlist[0].Family = COMMERCIAL;
        productlist[0].ProductTypeSelected__c = COMPACTOR;
        Database.insert(productlist);
        
        list<Account> supplieracclist = TestDataFactory.createAccount(TESTSUPPLIER , u, SUPPLIER);
        supplieracclist[0].AccountNumber = '600';
        Database.insert(supplieracclist);
        
        List<Contact> contacts = TestDataFactory.createContact('John', 'Doe', client, u);
        //if(contacts == null || contacts.size() < 1){ return;}else{}
        
        Contact contact = contacts.get(0);
        contact.Contact_Status__c = Constant_Util.ACTIVE;
        contact.Accountid = client.id ;
        insert contact;
        System.debug('>>>>> TestScreenpopEmulatorController.createAccountListsTestData: Contact created [' + contact + ']');        
    	list<Asset> assetlist = TestDataFactory.createAsset(ASSET_NAME , client, contact,productlist.get(0), u, location);
        assetlist[0].Supplier__c = supplieracclist[0].Id;
        Database.insert(assetlist);
    }

}