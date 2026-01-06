/**
* @author Accenture
* @description : Apex class DuplicateCheckOnCaseController 
test class for DuplicateCheckOnCaseController
**/

@isTest
public class DuplicateCheckOnCaseControllerTest {
    @testSetup
    public static void dataSetup() {
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
            List<Case> cseList = new List<Case>();
            List<Case> multicseList = new List<Case>();
            String rcdTypeId = TestDataFactory.getRecordType('Pickup Case', 'Case');
            for(Integer i=0;i<4;i++){
                Case cse = new case();
                cse.ContactId = contct.id;
                cse.AccountId = clientAcc.id;
                cse.OwnerId = usr.id;
                cse.Client__c = locAcc.ParentId;
                cse.Location__c = locAcc.id;
                cse.assetid = asst.id;
                cse.Status = 'New';
                cse.Case_Type__c = 'Pickup';
                cse.Case_Sub_Type__c = 'Extra Pickup';
                cse.SlaStartDate = system.today();
                cse.Service_Date__c = system.today();
                cse.RecordTypeId = rcdTypeId;
                cse.Is_Multiple_Asset__c = false;
                cse.Reference_Number__c = '';
                cse.Is_Clone__c = false;
                cse.Ignore_Duplicate__c = false;
                cse.Bypass_WO_Duplicate__c = false;
                cse.Ignore_Duplicate__c = false;
                cseList.add(cse);
            }
            
            Database.insert(cseList);
            cseList[0].Case_Sub_Status__c = 'Pending Service Integration';
            Database.update(cseList[0]);
            
            List<WorkOrder> wrkOrderlst = TestDataFactory.createWorkOrder(clientAcc,contct,cseList[0],asst);
            wrkOrderlst[0].Status = 'New';
            wrkOrderlst[0].Service_Date__c = system.today();
            wrkOrderlst[0].Customer_Location__c = cseList[0].Location__c;
            Database.insert(wrkOrderlst);
            
            WorkOrder wrk = [Select id from WorkOrder where CaseId =: cseList[0].Id limit 1];
            wrk.CaseId = cseList[0].Id;
            wrk.Acorn_WorkOrder_Number__c = '7654567';
            Database.update(wrk);
            
        }
    }
    
    
    public static testmethod void fetchSingleAssetWrapperTest(){
        List<Case> cases = [Select Id,AssetId from case limit 4];
        
        test.startTest();
       
            List<DuplicateCheckOnCaseController.MultiAssetWrapper> wrprrObj = new List<DuplicateCheckOnCaseController.MultiAssetWrapper> (); 
            DuplicateCheckOnCaseController.ParentMultiAssetWrapper objDT = new DuplicateCheckOnCaseController.ParentMultiAssetWrapper();
            objDT = DuplicateCheckOnCaseController.fetchMultiAssetWrapper(cases[2].Id);
            wrprrObj = objDT.multiAssetWrapperList;
            
            system.assert(wrprrObj.size() == 1);
            system.assert(wrprrObj[0].caseID != null);
            system.assertEquals(wrprrObj[0].caseID, cases[2].Id);
            system.assert(wrprrObj[0].assetID != null);
            system.assertEquals(wrprrObj[0].assetID, cases[2].AssetId);
         
        test.stopTest();
    }
    
    public static testmethod void fetchMultiAssetWrapperTest(){
        List<Case> cases = [Select id,AssetId,Is_Multiple_Asset__c,Status from case limit 4];
        
        cases[0].Status = 'New';
        cases[0].Is_Multiple_Asset__c=true;
        cases[0].Reference_Number__c='04206107';
        
        cases[1].Status = 'New';
        cases[1].Is_Multiple_Asset__c=true;
        cases[1].Reference_Number__c='04206107';
        Database.update(cases);
        
        test.startTest();
        
            List<DuplicateCheckOnCaseController.MultiAssetWrapper> wrprrObj = new List<DuplicateCheckOnCaseController.MultiAssetWrapper> (); 
            DuplicateCheckOnCaseController.ParentMultiAssetWrapper objDT = new DuplicateCheckOnCaseController.ParentMultiAssetWrapper();
            objDT = DuplicateCheckOnCaseController.fetchMultiAssetWrapper(cases[0].Id);
            wrprrObj = objDT.multiAssetWrapperList;
            
            system.assert(wrprrObj.size() != 0);
            system.assert(wrprrObj[0].caseID != null);
            system.assert(wrprrObj[0].assetID != null);
           
        test.stopTest();
    }
    
    public static testmethod void updateSingleAssetCasesTest(){
        List<Case> cases = [Select id from case limit 4];
        
        test.startTest();
  
            List<DuplicateCheckOnCaseController.MultiAssetWrapper> wrprrObj = new List<DuplicateCheckOnCaseController.MultiAssetWrapper> (); 
            DuplicateCheckOnCaseController.ParentMultiAssetWrapper objDT = new DuplicateCheckOnCaseController.ParentMultiAssetWrapper();
            objDT = DuplicateCheckOnCaseController.fetchMultiAssetWrapper(cases[2].Id);
            wrprrObj = objDT.multiAssetWrapperList; 
            
            List<DuplicateCheckOnCaseController.MultiAssetWrapper> wrprrObj2 = new List<DuplicateCheckOnCaseController.MultiAssetWrapper> (); 
            DuplicateCheckOnCaseController.ParentMultiAssetWrapper objDT2 = new DuplicateCheckOnCaseController.ParentMultiAssetWrapper();
            objDT2 = DuplicateCheckOnCaseController.fetchMultiAssetWrapper(cases[3].Id);
            wrprrObj2 = objDT2.multiAssetWrapperList; 
            
            DuplicateCheckOnCaseController.updateSingleAssetCases(true,'Test',wrprrObj);
            DuplicateCheckOnCaseController.updateSingleAssetCases(false,'Test',wrprrObj2);
            List<CaseComment> cmmnts = [Select id from CaseComment where parentid=:cases[2].Id ];
            List<CaseComment> cmmnts2 = [Select id from CaseComment where parentid=:cases[3].Id ];
            Case case1 = [Select Id,Ignore_Duplicate__c,Bypass_WO_Duplicate__c from Case where Id =: cases[2].Id LIMIT 1 ];
            Case case2 = [Select Id,Status from Case where Id =: cases[3].Id LIMIT 1 ];
            
            system.assert(cmmnts.size() == 1);
            system.assert(cmmnts2.size() == 1);
            system.assertequals(true,case1.Ignore_Duplicate__c);
            system.assertequals(true,case1.Bypass_WO_Duplicate__c);
            system.assertequals('Closed',case2.Status);
        
        test.stopTest();
    }
    
    public static testmethod void updateMultiAssetCasesTest(){
        List<Case> cases = [Select id,Is_Multiple_Asset__c,Status,Ignore_Duplicate__c,Bypass_WO_Duplicate__c from case limit 4];
        
        cases[0].Status = 'New';
        cases[0].Is_Multiple_Asset__c=true;
        cases[0].Reference_Number__c='04206107';
        
        cases[1].Status = 'New';
        cases[1].Is_Multiple_Asset__c=true;
        cases[1].Reference_Number__c='04206107';
        Database.update(cases);
        
        List<ID> selectedcases = new List<ID>();
        selectedcases.add(cases[0].id);
        selectedcases.add(cases[1].id);
        
        List<ID> unselectedcases = new List<ID>();
        unselectedcases.add(cases[2].id);
        unselectedcases.add(cases[3].id);
        
        test.startTest();
        
        DuplicateCheckOnCaseController.updateMultiAssetCases(selectedcases,unselectedcases);
        List<CaseComment> cmnts = [Select id from CaseComment where parentid=:cases[0].id ];
        List<CaseComment> cmmnts = [Select id from CaseComment where parentid=:cases[1].id ];
        Case case1 = [Select Id,Status from Case where Id =: cases[0].Id LIMIT 1 ];
        Case case2 = [Select Id,Status from Case where Id =: cases[1].Id LIMIT 1 ];
        List<CaseComment> cmnts2 = [Select id from CaseComment where parentid=:cases[2].id ];
        List<CaseComment> cmmnts2 = [Select id from CaseComment where parentid=:cases[3].id ];
        Case case3 = [Select Id,Ignore_Duplicate__c,Bypass_WO_Duplicate__c from Case where Id =: cases[2].Id LIMIT 1 ];
        Case case4 = [Select Id,Ignore_Duplicate__c,Bypass_WO_Duplicate__c from Case where Id =: cases[3].Id LIMIT 1 ];
        
        system.assert(cmnts.size() == 1);
        system.assert(cmmnts.size() == 1);
        system.assertequals('Closed',case1.Status);
        system.assertequals('Closed',case2.Status);
        
        system.assert(cmnts2.size() == 1);
        system.assert(cmmnts2.size() == 1);
        system.assertequals(true,case3.Ignore_Duplicate__c);
        system.assertequals(true,case3.Bypass_WO_Duplicate__c);
        system.assertequals(true,case4.Ignore_Duplicate__c);
        system.assertequals(true,case4.Bypass_WO_Duplicate__c);
        
        test.stopTest();          
 }
    
    public static testmethod void checkForDuplicateTest(){
        List<Case> cases = [Select id from case limit 4];
        test.startTest();
     
            List<WorkOrder> wrkList = DuplicateCheckOnCaseController.checkForDuplicate(cases[2].Id);
            system.assert(wrkList.size() == 1);
        
        test.stopTest();
    }
    
    public static testmethod void updateCaseWithCommentsTest(){
        Case cse = [Select id from case limit 1];
        List<Case> cseList = [Select id,CaseNumber,Ignore_Duplicate__c from case where id !=: cse.id];
        List<WorkOrder> wrkList = [Select id,CaseId,WorkOrderNumber from WorkOrder limit 4];
        
        test.startTest();
        
            DuplicateCheckOnCaseController.updateCaseWithComments(cse.Id,true,'Test',wrkList);
            DuplicateCheckOnCaseController.updateCaseWithComments(cse.Id,false,'Test',wrkList);
            List<CaseComment> cmmnts = [Select id from CaseComment where parentid=:cse.id ];
            system.assert(cmmnts.size() == 2);
        
        test.stopTest();
    }
    
}