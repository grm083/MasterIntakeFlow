/**
* @author TCS
* @date 28/05/2024
* @description : Apex class WorkFlowMigrationTest 
test class for WorkFlowMigration
**/
@isTest(seeAllData = false)
public class WorkFlowMigrationTest {
    @isTest static void RecreatedWorkOrderSuccessfulTest(){
        List<Case> caseObjList = new List<Case>();
        Case caseObj = new Case(); 
        caseObj.Status = 'New';
        caseObj.Origin = 'Phone';
        caseObj.Is_Recreated__c = true;
        caseObjList.add(caseObj); 
        
        Test.startTest(); 
        Database.insert(caseObjList);        
        WorkFlowMigration.RecreatedWorkOrderSuccessful(caseObjList[0]);
        Test.stopTest();
    }
    @isTest static void SetReferenceNumberTest(){
        List<Case> caseObjList = new List<Case>();
        Case caseObj = new Case(); 
        caseObj.Status = 'New';
        caseObj.Origin = 'Phone';
        caseObj.Reference_Number__c = null;
        caseObj.ParentId = null;
        caseObjList.add(caseObj);
        
        Test.startTest();
        Database.insert(caseObjList);
        WorkFlowMigration.SetReferenceNumber(caseObjList[0]);
        Test.stopTest();
    }
    @isTest static void WorkOrderCreatedTest(){
        List<Case> caseObjList = new List<Case>();
        Case caseObj = new Case(); 
        caseObj.Status = 'Pending';
        caseObj.Reference_Number__c = null;
        caseObj.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Constant_Util.PICKUP).getRecordTypeId();
        caseObjList.add(caseObj);              
        Database.insert(caseObjList);        
        
        Test.startTest(); 
        caseObjList = [Select Id, Reference_Number__c, RecordTypeId, Status, RecordType.Name From Case Limit 1];
        WorkFlowMigration.WorkOrderCreated(caseObjList[0]);
        Test.stopTest();
    }
}