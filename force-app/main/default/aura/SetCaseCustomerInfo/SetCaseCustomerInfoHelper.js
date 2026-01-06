({
	callApex : function(component, event, helper) {
		var action = component.get('c.getCaseRecordDetails');
        action.setParams({
            "caseId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            if(response.getState() == "SUCCESS"){
                var result = response.getReturnValue();
                component.set("v.recordTypeId",result[0]);
               // component.set("v.selectedLabel",result[1]);
               
               //SDT-41473
               result.forEach(function(value,index){
                if(value=== 'true'){
                    component.set("v.isHaulAwayChecked",value);
                }
                
                   //SDT-42651
                   if(value == 'VendorServiceIdReq') {
                       component.set("v.vendorIdRequired",true);
                   }  
                   
                   //SDT-42886
                   if(value == 'HaulAwayBookedService') {
                    component.set("v.haulAwayBookedRequired",true);
                }
                //SDT 45074
                if(value == 'HaulAwayUIEnabled') {
                    component.set("v.isHaulAwayUIEnable",true);//This veriable will store value of custom setting record HaulAwayUIEnable
                       }
                //SDT 39047
                   if(value == 'BillingInvoiceChargeDispute') {
                       component.set("v.isBillingInvoiceChargeDispute",true);
                   }
               })

                component.set("v.value",result[2]); 
                this.callGetCC(component, event, helper);
            }
        });
        $A.enqueueAction(action);
	},
    
    callGetCC : function(component, event, helper) {
    	//changes done for SDT-26287
        var action = component.get("c.getCompanyCategory");
        action.setParams({
        	"caseId" :component.get("v.recordId")
        });
        
        action.setCallback(this, function(response) {
            let state = response.getState();
            console.log('getCompanyCategory '+ state);
            if(state === "SUCCESS") {
               // console.log('res : '+  JSON.stringify(response.getReturnValue()));
                component.set("v.options", response.getReturnValue());
              //  component.set("v.label", response.getReturnValue()[0].label);
               // component.set("v.value", response.getReturnValue()[0].value);
                //component.set("v.selected", response.getReturnValue()[0].label);
            }
        });
        $A.enqueueAction(action); 
      //SDT-26287 changes end
	}
 
})