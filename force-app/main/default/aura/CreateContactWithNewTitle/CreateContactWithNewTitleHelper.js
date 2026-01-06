({
    closeModal : function(cmp,event) {
        var contactRec = event.getParams().response;
        //console.log(JSON.stringify(contactRec));
        
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": cmp.get('v.recordId'),
            "slideDevName": "related"
        });
        
        navEvt.fire();
    },
    refreshView : function(cmp, event) {
        console.log('refreshView');
        $A.get('e.force:refreshView').fire();
    },
    getTitles : function(cmp, event) {
        var action = cmp.get("c.getAccountTitlesForCase");
        action.setParams({ 
            caseId : cmp.get("v.recordId"),
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var titleOptions = [];
                for(var key in result){
                    titleOptions.push({key: key, value: result[key]});
                }
                titleOptions.sort();
                cmp.set("v.titleOptions", titleOptions);
            }
        });
        $A.enqueueAction(action);
    },
    setContactTitle : function(cmp, event) {
        var action = cmp.get("c.getContactTitleId");
        action.setParams({ 
            'contactId' : cmp.get('v.contactID2')
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var resp = response.getReturnValue();
                cmp.set('v.titleId', resp)
            }
        });
        $A.enqueueAction(action);
    },
    clearForm : function(cmp) {
        cmp.find("firstname").set("v.value", '');
        cmp.find("lastname").set("v.value", '');
        cmp.find("phone").set("v.value", '');
        cmp.find("mobile").set("v.value", '');
        cmp.find("email").set("v.value", '');
        cmp.find('preferredmethod').set("v.value", '');
        cmp.find('contactstatus').set("v.value", '');
    },
    addClass : function (element, className) {
        //Global Aura util method for adding a style class from an aura element
        $A.util.addClass(element,className);
    }, 
    
    removeClass : function (element , className) {
        //Global Aura util method for removing a style class from an aura element
        $A.util.removeClass(element,className);
    },
    
    showElement : function (element) {
        //To show an aura html element
        var self = this;
        self.removeClass(element,'slds-hide');
        self.addClass(element,'slds-show');
    },
    
    hideElement : function (element) {
        //To hide an aura html element
        var self = this;
        self.removeClass(element,'slds-show');
        self.addClass(element,'slds-hide');
    },
    searchContent : function (component,searchContent) {
        //The helper method calls sets the matched search content to component view
        //Now, it is returing some dummy records
        //Note - In your application - you should call the server method here with search query string 
        //(searchContent)as parameter.
        //Matched records should  sets to v.fetchedRecords attribute.
        try {
            if (searchContent.length > 2) {
                var action = component.get("c.getAccountContactsFromCase");
                action.setParams({ 
                    caseID : component.get("v.recordId"),
                    searchContent : searchContent
                });
                action.setCallback(this, function(response){
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var resp = response.getReturnValue();
                        var contacts = [];
                        for(var key in resp){
                            var title = '';
                            if (typeof(resp[key].Account_Title__r) != 'undefined') title = resp[key].Account_Title__r.Name;
                            contacts.push({'name': resp[key].FirstName + ' ' + resp[key].LastName, 'description' : resp[key].Account.Name, 'title' : title ,'id' : resp[key].Id});
                        }
                        component.set("v.fetchedRecords",contacts);
                        
                    } else {
                        alert('Error: ' + response.getError());
                    }
                });
                $A.enqueueAction(action);
            }
        } catch(e) {}
    },
    handleContactSuccessB : function(component, event, contactId) {
        console.log('handleContactSuccessB');
        //var contactId = component.get('v.contactId');  // [0]
        //alert('Contact Id: ' + typeof(contactId) + ' : ' + contactId);
        console.log('*' + contactId);
        console.log('*' + component.get("v.recordId"));
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
                    setTimeout(function () {
                        $A.get('e.force:refreshView').fire();
                    }, 2000);
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
    },
    
    existingCheck : function(component, event, contactId, fields) {
        var action = component.get("c.checkExisting");
        action.setParams({ 
            'caseId' : component.get("v.recordId"),
            'jsonParams' : fields
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                if(response.getReturnValue()){
                }
            }
        });
        $A.enqueueAction(action);
    },
    createContactAssociation : function(component, contactId, locationId) {
        var action = component.get("c.createContactLocationAssociation");
        action.setParams({ 
            'contactId' : contactId,
            'locationId' : locationId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                if(response.getReturnValue()){
                }
            }
        });
        $A.enqueueAction(action);
    }
})