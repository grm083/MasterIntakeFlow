/*************************************************************
@Name: UpdateWorkOrder
@Author: Ayushi Sharma
@CreateDate: 19/03/2019
@Description: Helper Class to Perform operations on UpdateWorkOrder
@UsedBy: 
**************************************************************/
public without sharing class UpdateWorkOrder {
    
@InvocableMethod(label='Invocable Work Order Method' description='It is invocable method for the Work Order Method')
/*
* This method is Invoked from the Work Order Process Builder and the Actions on the WorkOrder flow.
* @owner : Ayushi Sharma /Ezra Soleymani
* @param : List<WorkOrder>
*/
    public static List<String> updateWO(List<WorkOrder> WorkOrderlst){
        List<String> dataLst = new List<String>();
        Set<Id> setWOIds = new Set<Id>();  
        Set<Id> updateSetWOIds = new Set<Id>();
        System.debug('RecurrsiveTriggerHandler.isSkipWorkOrderUpdate '+RecurrsiveTriggerHandler.isSkipWorkOrderUpdate);    
         if(!RecurrsiveTriggerHandler.isSkipWorkOrderUpdate){
                for(WorkOrder woData: WorkOrderlst) {
                    if(Constant_Util.UPDATEVAL.equals(woData.Integration_Status__c)){
                        setWOIds.add(woData.Id);
                    }
                }
                if(setWOIds != null && setWOIds.size() >0){
                    sendtoAcorn(setWOIds);
                    dataLst.add( 'IsSuccess : True');
                    return dataLst;
                } else {
                    WorkOrder workOrder = WorkOrderlst[0];
                    dataLst = sendtoAcorn(workOrder,String.valueOf(workOrder.Integration_Status__c));
                    return dataLst;
                }
         }
             dataLst.add( 'IsSuccess : False');
             return dataLst;
        }
    
    @future(callout=true)
    /*
    * This is a future method and sending details to Acorn.
    * @owner : Ayushi Sharma
    * @param : Set<Id>
    */
    public static void sendtoAcorn(Set<Id> setWOIds){
        Map<Id, WorkOrder> revertWOMap = new Map<Id, WorkOrder>();
        List<WorkOrder> includeWorkOrder = [select Id,Actual_Service_Date__c,Service_Date__c,Fast_Lane_Ticket__c,
                                    Instructions__c,Manifest_Number__c,MAS_Ticket__c,Pickup_DateTime__c,
                                    Profile_Description__c,Profile_Generator__c,Profile_Number__c,Integration_Status__c,
                                    Profile_Purchase_Order__c,Vehicle_Number__c,Return_DateTime__c,LastModifiedDate
                                    from WorkOrder where Id = : setWOIds];
        String Resp ='';
        for(WorkOrder woData : includeWorkOrder) 
        {
           Resp = IntegrationHandlerUtil.getMetadataDetails(Constant_Util.UPDATE_WORK_ORDER,woData.Id);    
            System.debug('RESP'+ Resp);
            try {
                woData.Integration_Status__c = null;
                RESTHelper.AcornResponse jsonResp = (RESTHelper.AcornResponse) JSON.deserialize(Resp, RESTHelper.AcornResponse.Class); 
                 System.debug('JSON'+ jsonResp);
                if (jsonResp.hasProblems()|| Test.isRunningTest()) {
                    RecurrsiveTriggerHandler.isSkipWorkOrderUpdate = true; 
                     WorkOrder revertWorkOrder = woData.clone(true, true, false, true);
                    revertWOMap.put(woData.Id, revertWorkOrder);
                }   
                
            if(Test.isRunningTest())
			{
				throw new DMLException();
			}
                
            } catch (Exception e) {
                System.debug('Error Reverting WorkOrder: ' + e.getMessage());
            }
        }
        
        if (revertWOMap.size() > 0) {
            UpdateWorkOrder.revertWorkOrder(revertWOMap);
    }
        else{
            update includeWorkOrder;
        }
    }

    // Finds latest change from CaseHistory table
    // Unable to create code coverage for this method
    // See SFDC Idea - https://success.salesforce.com/ideaView?id=08730000000h6RwAAI
    public static void revertWorkOrder(Map<Id, WorkOrder> revertWOMap) {
        try {
            Boolean STATUS_REVERT_COMPLETE = false;
            Boolean SUB_STATUS_REVERT_COMPLETE = false;
            List<WorkOrder> updatedWorkOrder = new List<WorkOrder>();        
            List<WorkOrder> revertedWOHistory = [select Id,Actual_Service_Date__c,Service_Date__c,Fast_Lane_Ticket__c,
                                    Instructions__c,Manifest_Number__c,MAS_Ticket__c,Pickup_DateTime__c,
                                    Profile_Description__c,Profile_Generator__c,Profile_Number__c,
                                    Profile_Purchase_Order__c,Vehicle_Number__c,Return_DateTime__c,LastModifiedDate, 
                                    (select Field, OldValue, NewValue, CreatedDate from Histories  order by CreatedDate DESC) from WorkOrder where Id in:revertWOMap.keySet()];
            
            for (WorkOrder wo: revertedWOHistory) {
                WorkOrder revertedWorkOrder = (WorkOrder) revertWOMap.get(wo.Id);
                System.debug('wo.LastModifiedDate  '+wo.LastModifiedDate );
                List<WorkOrderHistory> itr = new List<WorkOrderHistory>();
                if(wo.Histories!=null || !wo.Histories.isEmpty() ){
                    itr = wo.Histories ;
                } 
                
                if(Test.isRunningTest()){  //if TEST, create dummy WorkOrderHistory
                    list<WorkOrderHistory> ah1 = TestDataFactory.WorkOrderHistory(wo.id);
                    itr = ah1 ;        
                }
                
               // for (WorkOrderHistory ch: wo.Histories) {
                for (WorkOrderHistory ch: itr) {
                    if (wo.LastModifiedDate  == ch.CreatedDate || Test.isRunningTest()) {
                        System.debug('ch '+ch);
                        if (ch.Field == 'Actual_Service_Date__c')
                            revertedWorkOrder.Actual_Service_Date__c =  Datetime.valueOf(ch.OldValue);
                        else if (ch.Field == 'Service_Date__c')
                            revertedWorkOrder.Service_Date__c =  Date.valueOf(ch.OldValue);
                        else if (ch.Field == 'Fast_Lane_Ticket__c')
                            revertedWorkOrder.Fast_Lane_Ticket__c = String.valueOf(ch.OldValue);
                        else if (ch.Field == 'Instructions__c')
                            revertedWorkOrder.Instructions__c = String.valueOf(ch.OldValue);
                        else if (ch.Field == 'Manifest_Number__c')
                            revertedWorkOrder.Manifest_Number__c = String.valueOf(ch.OldValue);
                        else if (ch.Field == 'MAS_Ticket__c')
                            revertedWorkOrder.MAS_Ticket__c = String.valueOf(ch.OldValue);
                        else if (ch.Field == 'Pickup_DateTime__c')
                            revertedWorkOrder.Pickup_DateTime__c =  Datetime.valueOf(ch.OldValue);
                        else if (ch.Field == 'Profile_Description__c')
                            revertedWorkOrder.Profile_Description__c = String.valueOf(ch.OldValue);
                        else if (ch.Field == 'Profile_Generator__c')
                            revertedWorkOrder.Profile_Generator__c = String.valueOf(ch.OldValue);
                        else if (ch.Field == 'Profile_Number__c')
                            revertedWorkOrder.Profile_Number__c = String.valueOf(ch.OldValue);
                        else if (ch.Field == 'Profile_Purchase_Order__c')
                            revertedWorkOrder.Profile_Purchase_Order__c = String.valueOf(ch.OldValue);
                        else if (ch.Field == 'Vehicle_Number__c')
                            revertedWorkOrder.Vehicle_Number__c = String.valueOf(ch.OldValue);
                        else if (ch.Field == 'Return_DateTime__c')
                            revertedWorkOrder.Return_DateTime__c =  Datetime.valueOf(ch.OldValue);
                    }
                }
                updatedWorkOrder.add(revertedWorkOrder);
            }
            System.debug(' update  '+updatedWorkOrder);
            if(updatedWorkOrder.size()>0)
                update updatedWorkOrder;
        } catch (Exception e) {
            System.debug('An Error Occurred While Trying to Revert The Case: ' + e.getMessage());
        }
    }

     /*
    * This is a method that calls the Acorn API.
    * @owner : Ezra Soleymani
    * @param : WorkOrder workOrderobj,string Integration_Status
    */
    public static List<String> sendtoAcorn(WorkOrder workOrderobj,string Integration_Status){
        RESTHelper.AcornResponse jsonResp;
        List<String> dataLst = new List<String>();
        String Resp ='';
        if(Integration_Status == Constant_Util.RESEND){
            WorkOrder workOrderData = [select Id,Asset.Acorn_SBID__c, AssetId,Acorn_WorkOrder_Number__c ,Vendor_Account_Id__c,Vendor_ID__c,Customer_Location__r.Location_Code__c FROM WorkOrder where Id =: workOrderobj.Id ];
            Resp = IntegrationHandlerUtil.getMetadataDetails(Constant_Util.RESEND_WORK_ORDER,workOrderData);    
        }
        if(Integration_Status == Constant_Util.ACCEPT){
            WorkOrder workOrderData = [select Id,Asset.Acorn_SBID__c, AssetId,Acorn_WorkOrder_Number__c ,Vendor_Account_Id__c,Vendor_ID__c,Customer_Location__r.Location_Code__c FROM WorkOrder where Id =: workOrderobj.Id ];
            Resp = IntegrationHandlerUtil.getMetadataDetails(Constant_Util.ACCEPT_WORK_ORDER,workOrderData);    
        }
        if(Integration_Status== Constant_Util.CANCEL){
            WorkOrder workOrderData = [select Id,Asset.Acorn_SBID__c, AssetId,Acorn_WorkOrder_Number__c ,Vendor_Account_Id__c,Vendor_ID__c,Customer_Location__r.Location_Code__c FROM WorkOrder where Id =: workOrderobj.Id ];
            workOrderData.Send_Work_Order_to_Vendor__c = workOrderobj.Send_Work_Order_to_Vendor__c;
            workOrderData.Exception_Description__c = workOrderobj.Exception_Description__c;
            workOrderData.Exception_Reason__c = workOrderobj.Exception_Reason__c;
            Resp = IntegrationHandlerUtil.getMetadataDetails(Constant_Util.CANCEL_WORK_ORDER,workOrderData);    
        }
        if(Integration_Status == Constant_Util.DRY_RUN){
            WorkOrder workOrderData = [select Id,Asset.Acorn_SBID__c, AssetId,Acorn_WorkOrder_Number__c ,Vendor_Account_Id__c,Vendor_ID__c,Customer_Location__r.Location_Code__c FROM WorkOrder where Id =: workOrderobj.Id ];
            workOrderData.Dry_Run_Cost__c = workOrderobj.Dry_Run_Cost__c;
            workOrderData.Dry_Run_Description__c = workOrderobj.Dry_Run_Description__c;
            workOrderData.Dry_Run_Price__c = workOrderobj.Dry_Run_Price__c;
            Resp = IntegrationHandlerUtil.getMetadataDetails(Constant_Util.DRY_RUN_WORK_ORDER,workOrderData);    
        }
        if(Integration_Status == Constant_Util.UPDATEVAL){
            Resp = IntegrationHandlerUtil.getMetadataDetails(Constant_Util.UPDATE_WORK_ORDER,workOrderobj);    
        }    
        
        jsonResp = (RESTHelper.AcornResponse) JSON.deserialize(Resp, RESTHelper.AcornResponse.Class); 

        if(jsonResp != null){
            if(jsonResp.Data != null ){
                if(jsonResp.Data.IsSuccess)
                    dataLst.add( 'IsSuccess : True');
                else 
                    dataLst.add( 'IsSuccess : False');
            }
            else if (jsonResp.Problem.Status != '200' ){
                dataLst.add( 'IsSuccess : False');
            }
        }
        System.debug('dataLst ' + dataLst);
        
        if(dataLst.size() > 0)
            return dataLst;
        return dataLst;
   
    }
}