({
    getAllBrRecords : function(component, event, helper) {
        var action = component.get('c.getBrRecords'); 
        action.setParams({
            "locationId" : component.get("v.recordId")
        });
        action.setCallback(this, function(a){
            var state = a.getState(); 
            if(state == 'SUCCESS') {
                 component.set("v.showSpinner",false );
                var brList = a.getReturnValue() ;
                var records = a.getReturnValue();
                component.set("v.recordCount",records.length );
                records.forEach(function(record){
                    console.log('DAS'  + JSON.stringify(brList));
                    record.brNameLink = '/'+record.Id;
                    console.log('DAS'  + JSON.stringify(record.AccountId__r.Name));
                    record.AccountName = record.AccountId__r.Name ;
                });
                component.set("v.brRecList", records);
                console.log( 'DAS ' +  a.getReturnValue());
                console.log( 'DAS' +    JSON.stringify(brList));  
                component.set("v.data",brList);
                if(brList && brList.length > 0){
                       component.set("v.showDataTable",true );
                }
                  component.set("v.showSpinner",false );
                
            }else{
                   component.set("v.showSpinner",false );
            }
            
        });
        $A.enqueueAction(action);
    }
})