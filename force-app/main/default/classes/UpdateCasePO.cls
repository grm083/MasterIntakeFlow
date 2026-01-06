public with sharing class UpdateCasePO {

    public static void updateCasePO(List<Case> caselst){
        Set<Id> setCaseIds = new Set<Id>();
        for(Case c : caselst){
            setCaseIds.add(c.id);
        }
        sendtoAcorn(setCaseIds);
    }

    @future(callout=true)
    /*
    * This is a future method and sending details to Acorn.
    * @owner : Ezra Soleymani
    * @param : Set<Id>
    */
    public static void sendtoAcorn(Set<Id> caselst){
        System.debug(' caselist '+caselst);
        Map<Id, Case> revertedCases = new Map<Id, Case>();
        List<Case> includeCases = [select Id,Location__r.Name ,Work_Order__r.Vendor_ID__c, Work_Order__r.Acorn_Purchase_Order_Number__c, Acorn_Work_order__c,PurchaseOrder_Number__c, Location__r.Parent.AccountNumber  from Case where Id = : caselst and Work_Order__r.Acorn_Purchase_Order_Number__c != null];
        for (Case c: includeCases) {
            
            // Write data to the JSON string.
            JSONGenerator gen = JSON.createGenerator(true);
                gen.writeStartObject();
                //gen.writeObjectField('LocationCode', c.Location__r.Name);
                //gen.writeObjectField('SupplierCode', c.Work_Order__r.Vendor_ID__c);
                //gen.writeFieldName('UpdatePurchaseOrder');
                //gen.writeStartObject();
                //    gen.writeObjectField('ClientAuthorizationNumber', c.PurchaseOrder_Number__c);
                //gen.writeEndObject();

                gen.writeObjectField('CustomerCode', c.Location__r.Parent.AccountNumber);
                gen.writeObjectField('ClientAuthorizationNumber', c.PurchaseOrder_Number__c);

                gen.writeEndObject();
            String genString = gen.getAsString();
            System.debug(genString);
            System.debug('Update Acorn PO: ' + c.Id);
           
            String result = IntegrationHandlerUtil.updateCasePO(Constant_Util.Update_Purchase_Order, c ,genString);           	
            System.debug('Results '+ result);
            RESTHelper.AcornResponse jsonResp = (RESTHelper.AcornResponse) JSON.deserialize(result, RESTHelper.AcornResponse.Class); 
            
            // if (jsonResp.hasProblems() || Test.isRunningTest()){ 
            //     revertedCases.put(c.Id, c.clone(true, true, false, true));
                
            // }
        }
        
       /* if (revertedCases.size() > 0)
        { 
            CloseAcornTicket.revertCases(revertedCases);

        }*/
    }
    
    // Finds latest change from CaseHistory table for 
   /* public static void revertCases(Map<Id, Case> revertedCases) {
        try {
            Boolean STATUS_REVERT_COMPLETE = false;
            Boolean SUB_STATUS_REVERT_COMPLETE = false;
            Map<Id, Case> updatedCases = new Map<Id, Case>();        
            
            List<Case> revertedCaseHistory = [select Id, PurchaseOrder_Number__c, LastModifiedDate, (select Field, OldValue, NewValue, CreatedDate from Histories where Field in ('PurchaseOrder_Number__c') order by CreatedDate DESC limit 2) from Case where Id in:revertedCases.keySet()];
            
            for (Case c: revertedCaseHistory) {
                Case revertedCase = (Case) revertedCases.get(c.Id);
                List<CaseHistory> itr = new List<CaseHistory>();
                if(c.Histories!=null || !c.Histories.isEmpty() ){
                    itr = c.Histories ;
                } 
                
                if(Test.isRunningTest()){  //if TEST, create dummy CaseHistory
                    list<CaseHistory> chList = TestDataFactory.CaseHistory(c.id);
                    itr = chList ;        
                }

                for (CaseHistory ch: itr) {
                    if ( Test.isRunningTest() ||c.LastModifiedDate.date() == ch.CreatedDate.date()) {
                        System.debug('ch '+ch);
                        if (ch.Field == 'PurchaseOrder_Number__c') { 
                            revertedCase.Status = String.valueOf(ch.OldValue);
                        } 
                    }
                     updatedCases.put(revertedCase.Id, revertedCase); 
                }
            }
            if (updatedCases.size()>0){ 
                update updatedCases.values(); 
            }    
        } catch(Exception e) {
            System.debug('An Error Occurred While Trying to Revert The Case: ' + e.getMessage());
        }
    }*/
}