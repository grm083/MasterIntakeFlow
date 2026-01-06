({
	doInit : function(component, event, helper){     
     var recordId = component.get("v.recordId");
        // check for invocation of the case from asset page or case home page
        
        if(recordId == 'undefined' || recordId == null){
            component.set("v.isOpenModal", true);
            component.set("v.isOpen", false);
        }else if(recordId.substring(0,3) == '500'){
            component.set("v.isRecTypeModal",true);
            component.set("v.isOpen", false);
            component.set("v.isOpenModal", false);
        }else{
            component.set("v.isOpen", true);
            component.set("v.isOpenModal", false);
        }
     helper.getRecordTypeList(component);
    },
    
    closeModel: function(component, event, helper) {
      // for Hide/Close Model,set the "isOpen" attribute to "False"  
      component.set("v.isOpenModal", false);
   },
    
    // On selection of rcord type
    onselectRecordType:function(component, event, helper){
        var recordType = event.getSource().get("v.value");
        component.set('v.selectedRecordType',recordType);
        component.set('v.nextEnabled',false);
    },
    
    cancelPopup:function(component, event, helper){
        var dismissQA = $A.get("e.force:closeQuickAction");
        var refreshView = $A.get('e.force:refreshView');
        //console.log('cancel action');
        dismissQA.fire();
        refreshView.fire();
    },

    //go back to record type selection
    goBack:function(component, event, helper){
        component.set("v.isCopyOptionModal", false);
        component.set("v.isRecTypeModal",true);
        component.set('v.nextEnabled',true);
    },
    
    //Creation of case in background & navigation to case landing page
    createCase:function(component, event, helper){
        helper.createCase(component);
    },
    
    //Select recordtype and move to copy selection modal
    handleNext:function(component, event, helper){
        var recordId = component.get("v.recordId");
        component.set('v.nextEnabled',false);
        component.set("v.IsSpinner" , true);
        component.set("v.caseData",event.getParam('caseData'));
        component.set("v.selectedRecordType",event.getParam('recordTypeName'));
        console.log('this is the recordtype name >' + event.getParam('recordTypeName'));
        if(component.get("v.isOpenModal") || component.get("v.isOpen")){
             //adding as part of SDT 29220
             var cseData = component.get("v.caseData");
            
             if (((event.getParam('recordTypeName') === 'Standard Case') && ((cseData.Case_Type__c == 'Vendor Confirmation' && cseData.Case_Sub_Type__c == 'Hauler of Record') || 
                     (cseData.Case_Type__c == 'Vendor Confirmation' && cseData.Case_Sub_Type__c == 'Schedule A') || 
                     (cseData.Case_Type__c == 'Discrepencies' && cseData.Case_Sub_Type__c == 'Asset') || 
                     (cseData.Case_Type__c == 'Discrepencies' && cseData.Case_Sub_Type__c == 'Hauler') || 
                     (cseData.Case_Type__c == 'Discrepencies' && cseData.Case_Sub_Type__c == 'Price') || 
                     (cseData.Case_Type__c == 'Discrepencies' && cseData.Case_Sub_Type__c == 'Service Date') || 
                     (cseData.Case_Type__c == 'Discrepencies' && cseData.Case_Sub_Type__c == 'Vendor') || 
                     (cseData.Case_Type__c == 'Discrepencies' && cseData.Case_Sub_Type__c == 'Vendor or Client Identification')))) {
                console.log('inside error condition1');
                //setting the errorCombination boolean value true
                component.set("v.errorCombination",true);
        	}
            else {
                component.set("v.errorCombination",false);
            	$A.enqueueAction(component.get("c.createCase"));
            }
        } 
        else { 
            //adding as part of SDT 29220
            var cseData = component.get("v.caseData");
            
            if (((event.getParam('recordTypeName') === 'Standard Case') && ((cseData.Case_Type__c == 'Vendor Confirmation' && cseData.Case_Sub_Type__c == 'Hauler of Record') || 
                     (cseData.Case_Type__c == 'Vendor Confirmation' && cseData.Case_Sub_Type__c == 'Schedule A') || 
                     (cseData.Case_Type__c == 'Discrepencies' && cseData.Case_Sub_Type__c == 'Asset') || 
                     (cseData.Case_Type__c == 'Discrepencies' && cseData.Case_Sub_Type__c == 'Hauler') || 
                     (cseData.Case_Type__c == 'Discrepencies' && cseData.Case_Sub_Type__c == 'Price') || 
                     (cseData.Case_Type__c == 'Discrepencies' && cseData.Case_Sub_Type__c == 'Service Date') || 
                     (cseData.Case_Type__c == 'Discrepencies' && cseData.Case_Sub_Type__c == 'Vendor') || 
                     (cseData.Case_Type__c == 'Discrepencies' && cseData.Case_Sub_Type__c == 'Vendor or Client Identification')))) {
                console.log('inside error condition in else');
                component.set("v.IsSpinner", false);
                component.set("v.errorCombination",true);

        	}
            else {
                console.log('inside execution in else');
                component.set("v.errorCombination",false);
                $A.enqueueAction(component.get("c.openCopyModal"));
            }
        }
	},

    //Select recordtype and move to copy selection modal
    openCopyModal:function(component, event, helper){
    	component.set("v.isRecTypeModal", false);
    	component.set("v.isCopyOptionModal", true);
        component.set("v.IsSpinner" , false);
    	//console.log('recordTypeId -- ' + component.get('v.selectedRecordType'));
	},
    
    onselectCopyOption:function(component, event, helper){
        var copyOptions = event.getSource().get("v.value");
        component.set('v.selectedCopyOptions', copyOptions);
        //console.log('copyOptions -- ' + copyOptions);
        
    },
    
    createCaseWithCopyData:function(component, event, helper){
        var emailList = component.get("v.selectedEmails");
        if(component.get("v.selectedCopyOptions").includes('Email') && emailList.length===0){
            //console.log('In email handle');
            component.set("v.isCopyOptionModal",false);
            component.set("v.emailSelectionModal",true);
            helper.getEmails(component);
        }else{
            component.set("v.IsSpinner", true);
            helper.createCaseWithCopyData(component);
        }
    },

    onselectEmailOptions:function(component, event, helper){
        var selectIds = [];
        var selectedRows = event.getParam('selectedRows');
        for(var i = 0; i<selectedRows.length; i++){
            selectIds.push(selectedRows[i].Id);
        }
        if(selectIds.length>0){
            component.set("v.emailNextEnabled", false);
            component.set("v.selectedEmails", selectIds);
        }else{
            component.set("v.emailNextEnabled",true);
        }
        //console.log('selected rows Ids -- ' + selectIds);
    },

    createCaseAfterEmailSelect: function(component, event, helper){
        component.set("v.IsSpinner", true);
        //console.log('In create case for email --- ');
        helper.createCaseWithCopyData(component);
    },
    
    goBackToCopyOption: function(component, event, helper){
        component.set("v.emailSelectionModal",false);
        component.set("v.isCopyOptionModal",true);
        
    }


})