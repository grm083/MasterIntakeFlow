({
    init : function(component, event, helper) {
        console.log('************ init');
        if (typeof(document.getElementsByClassName("contactLookup")[0]) != 'undefined') {
            //helper.clearForm(component);
            //document.getElementsByClassName("contactLookup")[0].style.display = 'block';
        }
        var action = component.get("c.getCaseContactId");
        component.set('v.toggleErrors', false);
        component.set('v.error', '');
        action.setParams({ 
            recordId : component.get("v.recordId"),
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var resp = response.getReturnValue();
                 if (typeof(resp) != 'undefined' && resp != null) {
                    component.set('v.contactId', resp);
                    component.set('v.contactID2', resp);
                    /*
                    setTimeout(function () {
                        document.getElementsByClassName("contactLookup")[0].style.display = 'block';
                        document.getElementsByClassName("createContactSection")[0].style.display = 'none';
                        document.getElementsByClassName("selectContactSection")[0].style.display = 'block';
                    }, 2000);
                    */
                 	component.set('v.mode', 'view');
                 } else {
                    component.set('v.mode', 'create');
                 }
                // obtain our title picklist selections
                helper.getTitles(component, event);
            }
        });
        $A.enqueueAction(action);
    },
    isRefreshed: function(component, event, helper) {
        location.reload();
    },
    handleError : function(component, event, helper) {
        let button = component.find('submit');
      button.set('v.disabled',false);
    },
    handleCancel : function(component, event, helper) {
        helper.closeModal(component,event);
    },
    handleSubmit : function(component, event, helper) {   
        console.log('handleSubmit');
        var contactRec = event.getParams().fields;   
        var fields = JSON.stringify(contactRec);
        var errorfields = '';
        var sep = '';
        for (var f in contactRec) {
            //console.log('field:' + f + '=' + contactRec[f]);
            if (!contactRec[f]) {
                if (f == 'FirstName' || f == 'LastName') {
                    if (f == 'FirstName') f = 'First Name'; if (f == 'LastName') f = 'Last Name';
                    errorfields = errorfields + sep + f;
                    sep = ', ';
                    event.preventDefault();
                }             
            }
        }  
        if (errorfields !=='') component.set('v.error',errorfields+ ' must be completed');
      component.set('v.toggleErrors', true);
        var mode = component.get('v.mode');
        if(mode == 'create'){
        	helper.existingCheck(component, event, helper,fields);    
        }
        
    },
    handleSuccess : function(component, event, helper) {  
        console.log('handleSuccess');
        console.log(component.get("v.isConRels"));
        var payload = event.getParams().response;
        //console.log(JSON.stringify(payload));
        var mode = component.get('v.mode');
        //console.log('Mode: ' + mode);
        var msg = 'A new Contact has been created successfully and added as the Case Contact';
        if (mode == 'edit') msg = 'You have successfully updated the Case Contact';
        if(component.get("v.isConRels") && mode == 'create'){
            msg = 'Contact already exists. Account Contact relationship created';
        }
        //helper.closeModal(component,event);
        var toastEvent = $A.get("e.force:showToast");
        if (typeof(toastEvent) != 'undefined') {
            toastEvent.setParams({
                "title": "Success!",
                "message": msg,
                "type": "success"
            });
            toastEvent.fire();
        } else {
            alert(msg);
        }
        console.log('New ID: ' + payload.id);
        
        // for create, lets create the contact/location association
        if(component.get("v.isConRels") == false && mode == 'create'){
            var locationId = component.get('v.caseAccountInfo.Location__c');
        	helper.createContactAssociation(component, payload.id, locationId);
        }
        
        // set our new contact to the new saved record and display details (initialize)
        if (mode == 'create') {
          component.set('v.contactId', payload.id);
          component.set('v.contactID2', payload.id);
            component.set("v.isConRels", false);
        }else {
            component.set("v.isConRels", true);
        }
        
        let button = component.find('submit');
        button.set('v.disabled',false);
        component.set('v.toggleErrors', false);
        component.set('v.error', '');
        
        //helper.refreshView(component, event);
        
        // was init
        if (mode == 'create') {
            var a = component.get('c.handleContactSuccess');
            $A.enqueueAction(a);
        }else {
            /*
            var elements = document.getElementsByClassName("createContactSection");
        	var elementsB = document.getElementsByClassName("selectContactSection");
            elements[0].style.display = 'none';
            elementsB[0].style.display = 'block';
            */
            component.set('v.mode', 'view');
            helper.refreshView(component, event);
        }
        
    },
    createTitle : function(component, event, helper) {
        let button = component.find('createtitlebutton');
      button.set('v.disabled',true);
        
        var newTitle = component.get("v.NewTitle");
        if (typeof(newTitle) == 'undefined') alert('Error: Missing required field Title.');
        else {
            var action = component.get("c.createContactTitle");
            action.setParams({ 
                acctId : component.get("v.caseAccountInfo.Client__c"),
                newTitle : newTitle
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
                    var resp = response.getReturnValue();
                    if (typeof(resp) != 'undefined') {
                        var titleOptions = component.get('v.titleOptions');
                        titleOptions.push({key: resp, value: newTitle, selected: true});
                        component.set('v.titleOptions', titleOptions);
                        component.set('v.titleId', resp);
                        component.set('v.NewTitle', '');
                        button.set('v.disabled',false);
                    }                    
                }
            });
      $A.enqueueAction(action);
        }
     },
    handleContactSuccess : function(component, event, helper) {
        console.log('handleContactSuccess');
        console.log(component.get("v.isConRels")); 
        var contactId = component.get('v.contactId');
        //alert(contactId);
        //alert('Contact Id: ' + typeof(contactId) + ' : ' + contactId);
        //var elements = document.getElementsByClassName("createContactSection");
        //var elementsB = document.getElementsByClassName("selectContactSection");
        if (typeof(contactId) != 'undefined' && contactId != '') {          
            //elements[0].style.display = 'none';
            //elementsB[0].style.display = 'block';   
            var action = component.get("c.setCaseContactId");
            action.setParams({ 
                'recordId' : component.get("v.recordId"),
                'contactId' : contactId,
                'locationId' : component.get('v.caseAccountInfo.Location__c'),
                'isselectedRow' : component.get("v.isConRels")
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
                    //setTimeout(function () {
                      helper.refreshView(component, event);
                    //}, 2000);
                    var a = component.get('c.init');
              $A.enqueueAction(a);
                } else {
                    var errors = response.getError();                      
                    alert(state + ' : ' + errors[0].message);
                }
            });
          $A.enqueueAction(action);
           
        } else {
            //elements[0].style.display = 'block';
            //elementsB[0].style.display = 'none';
        }
        component.set('v.toggleErrors', false);
        //**
        component.set('v.mode', 'view');
    },
    createNew : function(component, event, helper) {
        component.set('v.mode', 'create');
        component.set('v.editContactId', '');
        component.set('v.contactId', '');
        component.set('v.toggleErrors', false);
        helper.clearForm(component);
        /*
        document.getElementsByClassName("createContactSection")[0].style.display = 'block';
        document.getElementsByClassName("selectContactSection")[0].style.display = 'none';
        document.getElementsByClassName("contactLookup")[0].style.display = 'none';
        */
    },
    editCaseContact : function(component, event, helper) {
        //**var title = component.find("hiddentitlefield").get("v.value");
        component.set('v.mode', 'edit');
        component.set('v.toggleErrors', false);
        component.set('v.contactId', component.get('v.contactID2'));
        // populate form w/ contact information, mode, and contactId
        /*
        document.getElementsByClassName("createContactSection")[0].style.display = 'block';
        document.getElementsByClassName("selectContactSection")[0].style.display = 'none';
        document.getElementsByClassName("contactLookup")[0].style.display = 'none';
        */
        component.set('v.editContactId', component.get('v.contactID2'));
        
        // set the Title
        helper.setContactTitle(component, event);
    },
    onLeaveLookupPane : function(component, event, helper) {
        //Search - Input control focus removed on mouse leave
        var inputContainerCmp = component.find('master-container');
        helper.removeClass(inputContainerCmp,'slds-has-input-focus');
    },
    remove : function (component, event, helper) {
        //Hide the active SLDS - pill
        var selectedItemPill = component.find('selected-item-pill');
        helper.hideElement(selectedItemPill);
        
        //Show search-input control
        var inputElement = component.find('input-area');
        helper.showElement(inputElement);
    },
    onInputChange : function (component, event, helper) {
        var searchContent = component.get("v.searchText");
        var lookupContainerCmp = component.find("lookUpPane");
        if ( searchContent && searchContent.trim().length > 0 ) {
            searchContent = searchContent.trim();
            helper.addClass(lookupContainerCmp,'slds-is-open');
            helper.removeClass(lookupContainerCmp,'slds-is-close');
            helper.searchContent(component,searchContent);
        } else {
            helper.removeClass(lookupContainerCmp,'slds-is-open');
            helper.addClass(lookupContainerCmp,'slds-is-close');
        }
        
    },
    onSearchInputClick : function (component, event, helper) {
        //input control foucs enabled by adding focus style class
        var inputContainerCmp = component.find('master-container');
        helper.addClass(inputContainerCmp,'slds-has-input-focus');
    },
    selectedRecordRowClick : function (component, event, helper) {
        //event triggered on lookup row selection
        //fetching the details of selected row and it's index
        var targetSource = event.currentTarget;
        var selectedIndex = targetSource.dataset.index;
        
        console.log(targetSource,selectedIndex);
        var listedRecords = component.get("v.fetchedRecords");
        if (listedRecords && listedRecords.length > 0 && +selectedIndex >=0) {
            var selectedRecord = listedRecords[selectedIndex];
            console.log(selectedRecord.name + ':' + selectedRecord.id);
            component.set('v.contactId', selectedRecord.id);
            component.set('v.contactID2', selectedRecord.id);          
            console.log(JSON.stringify(selectedRecord));
            //Search input control value resets
            component.find("searchContent").set("v.value", ""); 
            component.set("v.selectedRecord", selectedRecord);
            
            //Hide the lookup
            var lookupContainerCmp = component.find("lookUpPane");
            helper.removeClass(lookupContainerCmp,'slds-is-open');
            helper.addClass(lookupContainerCmp,'slds-is-close');
            
            //Show Selected row content as a SLDS - pill
            var selectedItemPill = component.find('selected-item-pill');
            helper.showElement(selectedItemPill);
            
            //Hide the search-input control
            var inputElement = component.find('input-area');
            helper.hideElement(inputElement);
            component.set("v.isConRels", true);
            console.log('handling contact success...');
            helper.handleContactSuccessB(component, event, selectedRecord.id);
        }
    },
    waiting: function(component, event, helper) {
 	 	component.set("v.HideSpinner", true);
 	},
 	doneWaiting: function(component, event, helper) {
  		component.set("v.HideSpinner", false);
        var mode = component.get('v.mode');
 	}
})