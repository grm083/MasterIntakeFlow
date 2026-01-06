/**
* @author TCS
* @date 28/05/2024
* @description : Apex class RecursionCheckTest 
test class for RecursionCheck
**/
@isTest(seeAllData = false)
public class RecursionCheckTest {
    @isTest static void checkRecusrionTest(){
        Test.startTest(); 
        List<Case> caseObjList = new List<Case>();
        Case caseObj = new Case(); 
        caseObj.Status = 'New';
        caseObj.Origin = 'Phone';
        caseObj.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Constant_Util.INTERRUPTION).getRecordTypeId();
        caseObjList.add(caseObj);              
        Database.insert(caseObjList);
        List<Case> caseList = [select id FROM Case where id = : caseObjList[0].id];
        
        RecursionCheck.checkRecusrion(caseList);
        Test.stopTest();
    }
}