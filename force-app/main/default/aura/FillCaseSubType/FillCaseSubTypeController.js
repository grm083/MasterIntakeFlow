({
    doInit : function(component, event, helper) {
        helper.callApex(component, event, helper);
    },
	closeModel : function(component, event, helper) {
		component.set("v.showForm",false);
	},
    handleSuccess : function(component, event, helper) {
      	component.set('v.showForm', false); 
        $A.get('e.force:refreshView').fire();
	},
     handleError: function (event) {
        component.set('v.showForm', true);
        component.find('CaseMessage').setError('Undefined error occured');
    },
    handleSubmit :  function(component, event, helper) {
        event.preventDefault(); // stop form submission
        
        var eventFields = event.getParam("fields");
        
        //SNP changes starts
        var caseType = eventFields["Case_Type__c"];
        var caseSubType = eventFields["Case_Sub_Type__c"];
        var caseReason = eventFields["Case_Reason__c"];
        if (caseType == 'Status' && caseSubType == 'Service Not Performed' && caseReason == '') {
            component.set("v.showErrorSNP", true);
            component.set("v.errorMsg", 'Case Reason is Required, when case sub type is selected as Service Not Performed.');
            event.preventDefault();
        }
		else if ((caseType == 'Vendor Confirmation' && caseSubType == 'Hauler of Record') || (caseType == 'Vendor Confirmation' && caseSubType == 'Schedule A') || (caseType == 'Discrepencies' && caseSubType == 'Asset') || (caseType == 'Discrepencies' && caseSubType == 'Hauler') || (caseType == 'Discrepencies' && caseSubType == 'Price') || (caseType == 'Discrepencies' && caseSubType == 'Service Date') || (caseType == 'Discrepencies' && caseSubType == 'Vendor') || (caseType == 'Discrepencies' && caseSubType == 'Vendor or Client Identification')) {
            component.set("v.showErrorSNP", true);
            const caseSubTypeError = $A.get("$Label.c.CaseSubTypeError");
            component.set("v.errorMsg", caseSubTypeError);
            event.preventDefault();
        }
        else {
            component.set("v.showErrorSNP", false);
            component.set("v.errorMsg", '');
        }
        //SNP change ends 9566
        
         if(eventFields["Case_Type__c"] === "Pickup")
         {
        	helper.handleFormSubmit(component, event, helper);
         }
        else
        {
            if(!component.get("v.showErrorSNP"))  // snp code added post sprint 7 
            { 
                component.find("recordViewForm").submit();
                component.set("v.showForm",false);
            }
        }
        
           setTimeout(function(){
            $A.get('e.force:refreshView').fire();      
                }, 2000);
          
        
    }
    
  
})