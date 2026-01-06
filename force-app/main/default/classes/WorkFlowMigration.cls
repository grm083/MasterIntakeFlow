/**
 * @description       : Class is used to migrate Workflow rules to code base
 * @author            : TCS
 **/
        
public class WorkFlowMigration {
    
    /* Workflow migration for Recreated WorkOrder Successful*/
    public static void  RecreatedWorkOrderSuccessful(Case caseObj){
        
        if(caseObj.Is_Recreated__c == true && caseObj.Acorn_Work_order__c != null){
            caseObj.Is_Recreated__c = false;
        }
    }
    
    /* Workflow migration for Set Reference Number */
    public static void  SetReferenceNumber(Case caseObj){
        
        if(caseObj.ParentId == null && caseObj.Reference_Number__c == null){
            caseObj.Reference_Number__c = caseObj.CaseNumber;
        }
    }
    /* Workflow migration for Work Order Created */
    public static void  WorkOrderCreated(Case caseObj){
        //added on 06/06/2024 as part of defect SDT-40099
        String recTypeName = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(caseObj.RecordTypeId).getName();        
    if(((recTypeName == 'Pickup Case') && ((caseObj.Status == 'Pending') || (caseObj.Status == 'Open'))) || ((recTypeName != 'Pickup Case' && caseObj.Status == 'Open' && caseObj.Acorn_Work_order__c == null)))
            {
                caseObj.isWorkOrderCreated__c = true;
            }
    }
 
}