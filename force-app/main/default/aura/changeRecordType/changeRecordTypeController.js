({
    doInit : function(cmp, event, helper) {
        var recId = cmp.get('v.recordId');
       
        var action = cmp.get('c.getRecordTypeNames');
        action.setParams ({
            recordId: recId
        });
		//commented as part of SDT 32772
        //Changes added for bug SDT-24986
        //var updateAssetactiveflag = cmp.get('c.getActiveAssetUserDetail');
        //updateAssetactiveflag.setParams({caseId: recId});
        //End
         action.setCallback(this, function(response){
              var order=response.getReturnValue();
              var newOrder=cmp.get('v.recordTypes');
            
              var caseRecordTypeOrder=$A.get("$Label.c.CaseRecordType");       
              var properOrder = caseRecordTypeOrder.split('|');
            
            for (var x in properOrder) {
                for (var i in order) {
                    if (order[i].Name == properOrder[x]) {
                        newOrder.push(order[i]);
                        break;
                    } else if (i == order.length) {
                        newOrder.push(order[i]);
                    }
                }
            }
            cmp.set('v.recordTypes',newOrder);
			//commented as part of SDT 32772
            //Changes added for bug SDT-24986
            /*updateAssetactiveflag.setCallback(this,function(response){
                var success = response.getState();
                if(success){
                    cmp.set('v.showUpdateAssetButton',response.getReturnValue());
                }
            });
            $A.enqueueAction(updateAssetactiveflag);*/
            //ENd

        });
        $A.enqueueAction(action);
	 },
    
    handleButtonClick : function(cmp, event, helper) {
        var action = cmp.get('c.changeRecordType');
        action.setParams ({
            recordId: cmp.get('v.recordId'),
            newRecordType: cmp.get('v.newRecordTypeId')
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS') {
                //window.location.reload();
                var appEvent = cmp.getEvent("SingleTabRefreshEvent");
                	appEvent.setParams({ "reload" : "true" });
					appEvent.fire();
                  
            }
        });
        $A.enqueueAction(action);
    },
    handleSelect : function(cmp, event, helper) {
        cmp.set('v.showForm', true);
        var recordTypes = cmp.get('v.recordTypes');
        var item = cmp.get('v.selectedItem');
        var action = cmp.get('c.getInfo');
        action.setParams({
            recordId: cmp.get('v.recordId'),
            recordType: item
        })
        action.setCallback(this, function(response) {
            var returnVal = response.getReturnValue();
            cmp.set('v.newRecordTypeId', returnVal.recordTypeId);
            cmp.set('v.itemDescription', returnVal.recordTypeDesc);
          	cmp.set("v.reloadForm", false);
        	cmp.set("v.reloadForm", true);
            
           			 
        })
        $A.enqueueAction(action);
    },
    
    handleClick : function(cmp, event, helper) {
        
       console.log('===='+cmp.get('v.recordId'));
        
       var buttonName = event.getSource().get("v.label") ;

       var action = cmp.get('c.updateCaseRecord');
        action.setParams ({
            recordId: cmp.get('v.recordId'),
            newRecordType: cmp.get('v.newRecordTypeId'),
            caseBtnType: buttonName,
            casetype :  '',
            caseSubType: '',
            caseReason : ''
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS') {
                //window.location.reload();
                var appEvent = cmp.getEvent("SingleTabRefreshEvent");
                	appEvent.setParams({ "reload" : "true" });
					appEvent.fire();
            }
        });
        $A.enqueueAction(action);
        
    },
     handleSubmit :  function(cmp, event, helper) {
        event.preventDefault(); // stop form submission
        
        var eventFields = event.getParam("fields");
        var caseType = eventFields["Case_Type__c"];
        var caseSubType = eventFields["Case_Sub_Type__c"];
        var caseReason = eventFields["Case_Reason__c"];

        //added as part of sdt 29220
        if ((caseType == 'Vendor Confirmation' && caseSubType == 'Hauler of Record') || (caseType == 'Vendor Confirmation' && caseSubType == 'Schedule A') || (caseType == 'Discrepencies' && caseSubType == 'Asset') || (caseType == 'Discrepencies' && caseSubType == 'Hauler') || (caseType == 'Discrepencies' && caseSubType == 'Price') || (caseType == 'Discrepencies' && caseSubType == 'Service Date') || (caseType == 'Discrepencies' && caseSubType == 'Vendor') || (caseType == 'Discrepencies' && caseSubType == 'Vendor or Client Identification')) {
            console.log('in error condition3');
            cmp.set("v.errorCombination", true);
            const caseSubTypeError = $A.get("$Label.c.CaseSubTypeError");
            cmp.set("v.errorMsg", caseSubTypeError);
        }
        else {
       // alert('caseType==='+caseType+caseSubType+caseReason);
        var action = cmp.get('c.updateCaseRecord');
        action.setParams ({
            recordId: cmp.get('v.recordId'),
            newRecordType: cmp.get('v.newRecordTypeId'),
            caseBtnType: '',
            casetype :  caseType,
            caseSubType: caseSubType,
            caseReason : caseReason
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS') {
                //window.location.reload();
                var appEvent = cmp.getEvent("SingleTabRefreshEvent");
                	appEvent.setParams({ "reload" : "true" });
					appEvent.fire();
            }
        });
        $A.enqueueAction(action);
    }    
    },
     handleSuccess : function(component, event, helper) {
      	component.set('v.showForm', false); 
        $A.get('e.force:refreshView').fire();
	},
     handleError: function (event) {
        component.set('v.showForm', true);
        component.find('CaseMessage').setError('Undefined error occured');
    },
    
    
    
})