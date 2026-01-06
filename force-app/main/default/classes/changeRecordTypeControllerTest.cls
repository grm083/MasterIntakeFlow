@isTest
private class changeRecordTypeControllerTest {
    
    @isTest static void getRecordTypeNames() {
        
        //Create and insert new record types
        RecordType firstRT = [SELECT Id, Name FROM RecordType WHERE SobjectType='Case' LIMIT 1];
        String RTI = firstRT.Id;
        Case c1 = new Case(Subject='Test', RecordTypeId=RTI);
        insert c1;
        Account a1 = new Account(Name='Test');
        insert a1;
        
        //Store the Ids to verify sObject Names and pass into methods
        Id caseId = c1.Id;
        system.debug(c1.RecordTypeId);
        Id accountId = a1.Id;
        
        //Confirm the correct types of sObjects based on new records created
        String CobjType = c1.getSobjectType().getDescribe().getName();
        System.assertEquals(CobjType, 'Case');
        String AobjType = a1.getSobjectType().getDescribe().getName();
        System.assertEquals(AobjType, 'Account');
        
        //Pass the records into the method on the Controller class
        List<RecordType> CRT = changeRecordTypeController.getRecordTypeNames(caseId);
        List<RecordType> ART = changeRecordTypeController.getRecordTypeNames(accountId);
        List<RecordType> caseRecordTypes = changeRecordTypeController.getRecordTypeNamesFromObject('Case');
        changeRecordTypeController.updateCaseRecord(caseId,null,'Pickup',null,null,null);
        changeRecordTypeController.updateCaseRecord(caseId,null,'New Service',null,null,null);
        changeRecordTypeController.updateCaseRecord(caseId,null,'SNP',null,null,null);
        changeRecordTypeController.updateCaseRecord(caseId,null,'ETA',null,null,null);
        Id RecordTypeId = Schema.SobjectType.Case.getRecordTypeInfosByName().get('Pickup Case').getRecordTypeId();
        
        changeRecordTypeController.updateCaseRecord(caseId,RecordTypeId,null,'Pickup','Empty and Return',null);
        
            
        
        //Verify that neither list are null
        System.assert(CRT != Null);
        System.assert(ART != Null);
        System.assert(caseRecordTypes != Null);
    }
    @isTest static void getRecordTypeIdandDesc() {
        
        List<RecordType> firstRT = [SELECT Id, Name FROM RecordType WHERE SobjectType='Case' AND Description != Null];
        String RTI = firstRT[0].Id;
        Id RecordTypeId = Schema.SobjectType.Case.getRecordTypeInfosByName().get(Constant_Util.New_Service_Case).getRecordTypeId();
        
        Case c1 = new Case(Subject='Test', RecordTypeId=RTI);
        insert c1;
        Id caseId = c1.Id;
        String caseRecordId = c1.RecordTypeId;
        
        RecordType recType = [SELECT Id, Name, Description FROM RecordType WHERE Id=:caseRecordId LIMIT 1];
        String recTypeName = recType.Name;
        
        changeRecordTypeController.recordTypeWrapper rtw = changeRecordTypeController.getInfo(recTypeName, caseId);
        
        System.assert(rtw.recordTypeId != Null);
        System.assert(rtw.recordTypeDesc != Null);
        
        String newRTI = firstRT[1].Id;
        
        changeRecordTypeController.changeRecordType(caseId, RecordTypeId);
        
        System.assert(c1.RecordTypeId != Null);
    }
}