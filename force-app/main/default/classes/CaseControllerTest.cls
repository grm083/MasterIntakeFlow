@isTest
public class CaseControllerTest {
	
    @testSetup
    public static void dataSetup() {
        Id recordTypeId = Schema.getGlobalDescribe().get('Comment__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Acorn_Ticket_Comment').getRecordTypeId();
        Profile p = TestDataFactory.getProfile('System Administrator');
        User usr = TestDataFactory.createUser(p);
        Database.insert(usr);
        system.runAs(usr){
            Account clientAcc = TestDataFactory.createAccount(Constant_Util.KEYWORD_TEST, usr,'Client')[0];
            Database.insert(clientAcc);
            Account locAcc = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, clientAcc.id)[0];
            Database.insert(locAcc);
            Contact contct = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST,Constant_Util.CONSTANT_LAST, clientAcc, usr)[0];
            Database.insert(contct);
            Product2 prdct = TestDataFactory.createProduct('Sample Product Test')[0];
            Database.insert(prdct);
            Asset asst = TestDataFactory.createAsset('Test Asset', clientAcc,contct, prdct, usr,locAcc)[0];
            Database.insert(asst);
			AccountContactRelation testACR1 = 
            TestDataFactory.returnAccConRel(locAcc.Id, contct, 'Commercial Service/Dispatch');
            Database.insert(testACR1);
            Case cse = TestDataFactory.createNewCase()[0];
            cse.Client__c = clientAcc.Id;
            cse.Location__c = locAcc.Id;
            cse.ContactId = contct.Id;
            cse.Case_Type__c = 'Pickup';
            cse.Case_Sub_Type__c = 'Empty and Return';
            cse.Origin = 'Phone';
            cse.Emergency__c = false;
            Database.insert(cse);
            EmailMessage email = new EmailMessage();
            email.ParentId = cse.Id;
            email.RelatedToId = cse.Id;
            Database.insert(email);
            Comment__c notes = new Comment__c();
            notes.Case__c = cse.Id;
            notes.RecordTypeId = recordTypeId;
            Database.insert(notes);
        }
    }
    
    public static testmethod void createMultipleCasesInvokeTest(){
        Case cse = [Select id from case limit 1];
        Test.startTest();
        CaseController.CaseSuccess result = CaseController.createMultipleCasesInvoke(new List<String>{String.valueof((Date.today()+5).format()).replace('-','/'),
            													  String.valueof((Date.today()+6).format()).replace('-','/'),
            													  String.valueof((Date.today()+7).format()).replace('-','/')}, cse.Id,true,true);
		//system.debug('error'+result.message);
        system.assert(result.success == true);
        Test.stopTest();
    }
    
    
    public static testmethod void createMultipleCasesInvokeNegative(){
        Case cse = [Select id from case limit 1];
        Test.startTest();
        CaseController.CaseSuccess result = CaseController.createMultipleCasesInvoke(new List<String>{String.valueof(Date.today()-3)}, cse.Id,false,false);
        system.assert(result.success != true);
        Test.stopTest();
    }
    
    public static testmethod void fetchAccountAssetWrapperTest(){
        Case cse = [Select id from case limit 1];
        Account loc = [select id,recordtype.developername,status__c from account where name='location' limit 1];
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = loc.id;
        Test.setFixedSearchResults(fixedSearchResults);
        List<List<Account>> accountSerachResults= [FIND 'Location' IN ALL FIELDS RETURNING Account (id, RecordType.DeveloperName Where RecordType.DeveloperName='Location' AND status__c='Active') ];
        test.startTest();
        CaseController.fetchAccountAssetWrapper('Location', true, 1, 10,true , cse.id);
        CaseController.fetchAccountAssetWrapper('Location', false, 1, 10,false , cse.id);
        test.stopTest();
    }
    
    public static testmethod void fetchAssetRecsTest(){
        Account loc =[Select id from account where recordtype.name ='Location'];
        List<Asset> assList= new List<Asset>();
        List<CaseController.LocationAssetWrapper> wrap = new List<CaseController.LocationAssetWrapper>();
        wrap.add(new CaseController.LocationAssetWrapper(loc,assList,'Test'));
        test.startTest();
        CaseController.fetchAssetRecs(loc.Id, wrap);
        test.stopTest();
    }
    
    public static testmethod void updateCaseTest(){
        string[] assetlist = new String[]{};
        Account client = [select id from Account where recordtype.name='Client' Limit 1];
        Account loc = [Select id from account where recordtype.name ='Location' Limit 1];
        Asset asst = [select id from asset where AccountId =: loc.id Limit 1];
        // Modified for SDT-33443 Start
        Case cse = [Select id from case limit 1];
        /*Case cse = new Case(); //Commented for SDT-33443
        insert cse; //Commented for SDT-33443  */
        // Modified for SDT-33443 End
        assetlist.add(asst.Id);
        test.startTest();
        casecontroller.updateCase(client.Id, loc.Id, assetlist, cse.Id);
        casecontroller.LocationAssetWrapper wrap = new casecontroller.LocationAssetWrapper();
        test.stopTest();
        
    }
    
    public static testmethod void multipleAssetCaseTest(){
        string[] assetlist = new String[]{};
        Account client = [select id from Account where recordtype.name='Client' Limit 1];
        Account loc = [Select id from account where recordtype.name ='Location' Limit 1];
        Asset asst = [select id from asset where AccountId =: loc.id Limit 1];
       	list<case> caselist = [select id, ParentId,Reference_Number__c,origin, contactid, Case_Type__c, Client__c, Location__c, 
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                   Service_Date__c,SLA_Service_Date_Time__c from case limit 1];
        assetlist.add(asst.Id);
        //assetlist.add(asst.Id); // Commented for SDT-33443
        test.startTest();
        casecontroller.updateCase(client.Id, loc.Id, assetlist, caselist[0].Id);
        System.assertEquals(1, [SELECT Id from case where Reference_Number__c= :caselist[0].Reference_Number__c].size());
        System.assertEquals(caselist[0].ParentId, [SELECT Id,ParentId from case where Reference_Number__c= :caselist[0].Reference_Number__c][0].ParentId);
        casecontroller.LocationAssetWrapper wrap = new casecontroller.LocationAssetWrapper();
        test.stopTest();
        
    }
    
    public static testmethod void multipleAssetCaseNullTest(){
        string[] assetlist = null;
        Account client = [select id from Account where recordtype.name='Client' Limit 1];
        Account loc = [Select id from account where recordtype.name ='Location' Limit 1];
        // Modified for SDT-33443 Start
        Case cse = [Select id from case limit 1];
        /*Case cse = new Case(); //Commented for SDT-33443
        insert cse; //Commented for SDT-33443  */
        // Modified for SDT-33443 End
        test.startTest();
        casecontroller.updateCase(client.Id, loc.Id, assetlist, cse.Id);
        casecontroller.LocationAssetWrapper wrap = new casecontroller.LocationAssetWrapper();
        test.stopTest();
        
    }
    
     public static testmethod void ignoreCloseTest(){
        Case cse = [Select id,assetId,OwnerId,Location__c,ContactId,Case_Type__c,RecordTypeId,Case_Sub_Type__c,Client__c from case limit 1];
        Case case1 = cse.clone(false, false, false, false);
        case1.Service_Date__c = Date.today()+3;
        Case case2 = cse.clone(false, false, false, false);
        case2.Service_Date__c =  Date.today()+4;
        List<Case> cseList = new List<Case>();
        cseList.add(case1);
        cseList.add(case2);
        Database.insert(cseList);
        
        case1.Status = 'Open';
case2.Service_Date__c = Date.Today();// Modified for SDT-33443
        case1.Case_Sub_Status__c = 'Pending Service Integration';
        case2.Status = 'Open';
case2.Service_Date__c = Date.Today();// Modified for SDT-33443
        case2.Case_Sub_Status__c = 'Pending Service Integration';
        Database.update(cseList);
        
               
        WorkOrder wrkOrdr1 = TestDataFactory.createWorkOrder(new Account(Id=Case1.Location__c), new Contact(Id=Case1.ContactId),Case1, new Asset(Id = Case1.AssetId))[0];
        wrkOrdr1.Acorn_WorkOrder_Number__c = '7654567342';
wrkOrdr1.Service_Date__c = Date.Today();// Modified for SDT-33443
        Database.insert(wrkOrdr1);
        
        WorkOrder wrkOrdr2 = TestDataFactory.createWorkOrder(new Account(Id=Case2.Location__c), new Contact(Id=Case2.ContactId),Case2, new Asset(Id = Case2.AssetId))[0];
        wrkOrdr2.Acorn_WorkOrder_Number__c = '7654567897';
        Database.insert(wrkOrdr2);  
            
        List<WorkOrder> woList1 = new List<WorkOrder>();
        woList1.add(wrkOrdr1);
		test.startTest();
        Database.update(woList1);
            
        List<WorkOrder> woList2 = new List<WorkOrder>();
        woList2.add(wrkOrdr2);
        Database.update(woList2);
            
	    

        CaseController.CaseSuccess result = CaseController.createMultipleCasesInvoke(new List<String>{String.valueof((Date.today()+2).format()).replace('-','/'),
            													  String.valueof((Date.today()+3).format()).replace('-','/'),
            													  String.valueof((Date.today()+4).format()).replace('-','/')}, cse.Id,true,true);
        
        CaseController.updateClosehandler(cseList,woList1,woList2);// Modified for SDT-33443
        //CaseController.updateClosehandler(result.childCases,woList1,woList2);// Modified for SDT-33443
        test.stopTest();
    } 
	
	  /* 
     * Added below test method for story SDT-10799
	*/
   public static testmethod void is_AM_PM_Applied_On_Parent_Only_And_Not_On_Child_Positive()
    {   
       
         Case ParentCase = [SELECT id,Create_AM_and_PM_pickups__c, AccountId,CaseNumber,Case_Information__c,Override_PO_Create_Task__c,User_Input_Work_Order_Instructions__c,recordTypeId, Location__c, Reference_Number__c, AssetId, Client__c, ContactId,Case_Type__c,Case_Sub_Type__c,Case_Reason__c,Origin,Emergency__c,Site_Contact__c,Site_Contact_Phone__c,SalesMeet_Container_Position__c,Supplier__c,PurchaseOrder_Number__c,PSI__c,Profile_Number__c,PSI_Required__c,Override_Profile_Number_Task__c,PurchaseOrder_Required__c,SLA_Override_Reason__c,/*Work_Order_Instructions__c,*/isMultiCalendarChecked__c 
                                 FROM Case  limit 1];    
   
   		 Test.startTest();
         CaseController.CaseSuccess result = CaseController.createMultipleCasesInvoke(new List<String>{String.valueof((Date.today()+2).format()).replace('-','/'),
            													  String.valueof((Date.today()+3).format()).replace('-','/'),
            													  String.valueof((Date.today()+4).format()).replace('-','/')}, ParentCase.Id,false,true);
        
         List<Case> childCases= [select id,create_AM_and_PM_Pickups__c,casenumber from case where parentid =:ParentCase.id];        
         Test.stopTest();
         system.assert(childCases.size() == 3); 
         for(case cse : childCases )
         { 
            system.assert(cse.Create_AM_and_PM_pickups__c == false);
         }
         Case parntCase=[select Create_AM_and_PM_pickups__c from case where id  =: ParentCAse.id ];         
         system.assert(parntCase.Create_AM_and_PM_pickups__c);    
    }
    
    /* 
     * Added below test method for story SDT-10799
	*/
    public static testmethod void is_AM_PM_Not_applied_On_Any_Case_Positive()
    {   
       
         Case ParentCase = [SELECT id,Create_AM_and_PM_pickups__c, AccountId,CaseNumber,Case_Information__c,Override_PO_Create_Task__c,User_Input_Work_Order_Instructions__c,recordTypeId, Location__c, Reference_Number__c, AssetId, Client__c, ContactId,Case_Type__c,Case_Sub_Type__c,Case_Reason__c,Origin,Emergency__c,Site_Contact__c,Site_Contact_Phone__c,SalesMeet_Container_Position__c,Supplier__c,PurchaseOrder_Number__c,PSI__c,Profile_Number__c,PSI_Required__c,Override_Profile_Number_Task__c,PurchaseOrder_Required__c,SLA_Override_Reason__c,/*Work_Order_Instructions__c,*/isMultiCalendarChecked__c 
                                 FROM Case  limit 1];    
   
   		 Test.startTest();
         CaseController.CaseSuccess result = CaseController.createMultipleCasesInvoke(new List<String>{String.valueof((Date.today()+2).format()).replace('-','/'),
            													  String.valueof((Date.today()+3).format()).replace('-','/'),
            													  String.valueof((Date.today()+4).format()).replace('-','/')}, ParentCase.Id,false,false);
        
         List<Case> childCases= [select id,create_AM_and_PM_Pickups__c,casenumber from case where parentid =:ParentCase.id];        
         Test.stopTest();
         system.assert(childCases.size() == 3); 
         for(case cse : childCases )
         { 
            system.assert(cse.Create_AM_and_PM_pickups__c == false);
         }
         Case parntCase=[select Create_AM_and_PM_pickups__c from case where id  =: ParentCAse.id ];         
         system.assert(parntCase.Create_AM_and_PM_pickups__c == false);    
    }
	
	public static testmethod void updateContactLocation(){
        string[] assetlist = new String[]{};
        Account client = [select id from Account where recordtype.name='Client' Limit 1];
        Account loc = [Select id from account where recordtype.name ='Location' Limit 1];
        Asset asst = [select id from asset where AccountId =: loc.id Limit 1];
        Contact cnt = [select id from Contact Limit 1];
        AccountContactRelation acr =  [SELECT id, AccountId,ContactId FROM AccountContactRelation
                            		    WHERE AccountId =: loc.Id];
        Case cse = [select Id,AssetId,ParentId,RecordTypeId,Case_Sub_Status__c,Client__c,Location__c,Reference_Number__c,ContactId from case limit 1];
        assetlist.add(asst.Id);
        test.startTest();
        casecontroller.updateCase(client.Id, loc.Id, assetlist, cse.Id);
        test.stopTest();
        system.assertEquals('Success',casecontroller.updateCase(client.Id, loc.Id, assetlist, cse.Id));
        
    }
    
    
public static testmethod void cloSeMultiCaseTest(){
        test.startTest();
        CaseController.cloSeMultiCase();
        test.stopTest();
    }
    
    public static testmethod void updateCaseOnVendorClientSelectionTest(){
        Case css = [Select id,assetId,OwnerId,Location__c,ContactId,Case_Type__c,RecordTypeId,Case_Sub_Type__c,Client__c from case limit 1];
        Account acc = [Select id from account Limit 1];
        test.startTest();
        CaseController.updateCaseOnVendorClientSelection(acc.Id, css.Id, css.Id);
        test.stopTest();
    }
    
    public static testmethod void fetchVendorOrClientWrapperTest(){
        Case css = [Select id,CaseNumber,assetId,OwnerId,Location__c,ContactId,Case_Type__c,RecordTypeId,Case_Sub_Type__c,Client__c from case limit 1];
        Account client = [select id, recordtype.name from Account where recordtype.name='Client' Limit 1];
        test.startTest();
        CaseController.fetchVendorOrClientWrapper('test', True, 1, 10, css.Id, client.recordtype.name);
        
        CaseController.copyEmailtoAnotherCase(css.Id, css.CaseNumber);
        test.stopTest();
    }
    
    
}