({
	refreshView : function(cmp, event) {
        
        var workspaceAPI = cmp.find("workspace");
        var currTab = workspaceAPI.getFocusedTabInfo();
        
        workspaceAPI.refreshTab({
            tabId : currTab,
            includeAllSubtabs : true
        });
        /*
		var action = cmp.get(cmp);
        action.setCallback(cmp, function(response) {
            var state = response.getState();
            if (state ==='SUCCESS') {
                $A.get('e.force:refreshView').fire();
            } else {
                system.debug(response);
            }
        });
        $A.enqueueAction(action); */
	},
    showTitleToast : function(cmp, event) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": "Your new title is now available in the title drop down"
        });
        toastEvent.fire();
    },
    returnCase : function(cmp, event) {
        var returnCase = cmp.get('c.returnCase');
        var recordId = cmp.get('v.recordId');
        returnCase.setParams({
            recordId : recordId
        });
        
         //Returns the account and stores it in the component
        returnCase.setCallback(this, function(response) {
            var status = response.getState();
            if (status === 'SUCCESS') {
                var caseResult = response.getReturnValue();
                var location = caseResult.Location__c;
                var account = caseResult.Client__c;
                var vendor = caseResult.Supplier__c;
                var isLocation = cmp.get('v.isLocation');
                var isVendor = cmp.get('v.isVendor');
                var isClient = cmp.get('v.isClient');
                cmp.set('v.caseContact', caseResult.ContactId);
                cmp.set('v.caseUser', caseResult.Requested_By_User__c);
                if (contact == '') {
                    cmp.set("v.boolEdit", true);
                }
                var status = caseResult.Status;
                cmp.set('v.caseAccount', account);
                cmp.set('v.locAccount', location);
                cmp.set('v.vendorAcc', vendor);
                
                var showOldSearchResult =       cmp.get("v.showPriorSearchResult");
           
               
                if(!showOldSearchResult && location && isLocation){
                    this.searchLocCont(cmp, event,location);
                } else  if(!showOldSearchResult && account && isClient){
                    this.searchLocCont(cmp, event,account);
                }
        		
		cmp.set('v.boolSOSL', true);
                var user = cmp.get('v.caseUser');
                var contact = cmp.get('v.caseContact');
                if (!$A.util.isUndefinedOrNull(user)) {
                    cmp.set('v.boolShowUser', true);
                } else {
                    cmp.set('v.boolShowUser', false);
                	cmp.set('v.caseContact', contact);
                }
                cmp.set('v.caseStatus', status);
               
                if((!cmp.get('v.soslContacts') || (JSON.stringify(cmp.get('v.soslContacts'))).length <= 4) && 
                    (cmp.get('v.caseObj').Case_Type__c == 'Activate' || cmp.get('v.caseObj').Case_Type__c == 'Deactivate' || cmp.get('v.caseObj').Case_Type__c == 'Modify' )) {
                        cmp.set('v.boolShowNew', true);    
                }
               
            };
        });                
        $A.enqueueAction(returnCase); 
    },
    searchLocCont : function(cmp, event,location) {
        //Stores variables for use by methods
        //var locId = cmp.get('v.locAccount');
        
        //Queries all location contacts for display
        var action = cmp.get('c.searchLocCont')
        action.setParams({
            locId : location
        });
        
        //Stores the returned contact in the datatable component
        action.setCallback(this, function(response) {
            var state = response.getState();
            var results = response.getReturnValue();
            var compareStr = 'Yes';
            if (state === 'SUCCESS') {
                results.forEach(function(record){ 
                    if(record.BusinessRuleAssociation != "undefined" && record.BusinessRuleAssociation != null){
                    	record.showClass = record.BusinessRuleAssociation.toLowerCase() === compareStr.toLowerCase()? 'bgHighlight' : 'noBgHighlight';    
                    }
                });
                 cmp.set('v.soslContacts', results);
            }
        });
        $A.enqueueAction(action);
    },
    returnVendors : function(cmp, event) {
        //Stores variables for use by methods
        var locId = cmp.get('v.locAccount');
        
        //Queries all location contacts for display
        var action = cmp.get('c.returnVendors')
        action.setParams({
            acct : locId
        });
        //Stores the returned contact in the datatable component
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                cmp.set('v.vendorAccts', response.getReturnValue());
            }
        });
        $A.enqueueAction(action);		
    },
    getVendorRoles : function(cmp, event) {
        var roles = cmp.get('c.getVendorRoles');
        roles.setParams({});
        roles.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                cmp.set('v.vendorRoles', response.getReturnValue());
            }
        });
        $A.enqueueAction(roles);
    },
    getAccountTitles : function(cmp, event) {
        var titles = cmp.get('c.getAccountTitles');
        titles.setParams({
            acct : cmp.get('v.caseAccount')
        });
        titles.setCallback(this, function(response) {
            var state = response.getState();
            var returnVal = response.getReturnValue();
            if (state === 'SUCCESS') {
                cmp.set('v.accountTitles', returnVal);
            }
        });
        $A.enqueueAction(titles);
    },
    getAccountDepts : function(cmp, event) {
        var depts = cmp.get('c.getAccountDepts');
        depts.setParams({
            acct : cmp.get('v.caseAccount')
        });
        depts.setCallback(this, function(response) {
            var state = response.getState();
            var returnVal = response.getReturnValue();
            if (state === 'SUCCESS') {
                cmp.set('v.accountDepts', returnVal);
            }
        });
        $A.enqueueAction(depts);
    },
    
    checkDuplicateContacts : function(cmp, event) { 
    	var firstName = cmp.get('v.firstName');
        var lastName = cmp.get('v.lastName');
        var phone = cmp.get('v.phone');  
        var email = cmp.get('v.email');
        var title = cmp.find("accountTitleList").get("v.value");  
		var preferred = cmp.get('v.preferred');
        var department = cmp.find("accountDepts").get("v.label");  
        var caseId = cmp.get('v.recordId'); 
        var relevantAcct = cmp.get('v.caseAccount');  
        var extension = cmp.get('v.extension');    
        
        if(cmp.get('v.boolCustomer') == true){
            var search = cmp.get('c.checkDuplicateContacts');
            search.setParams({
                firstName : firstName, 
                lastName : lastName,
                email : email,
                phone : phone,
                mobile : '',
				accountId : relevantAcct,
                title : title,
                department : department,
                preferred : preferred,
                extension : extension,
                caseId : caseId
            })
            search.setCallback(this, function(response) {
                var state = response.getState();
                if(state === 'SUCCESS') {
                    var results = response.getReturnValue();
                    console.log('results.ContactId');
                    console.log(results.ContactId);
                    console.log('currency data is:' + JSON.stringify(results));
                    console.log('currency data is:' + JSON.stringify(results).length);
                    if(typeof results != "undefined" && results != null && results.length != null && results.length > 0){
                        if(results.length == 1){
                            cmp.set("v.isOpen", false); 
                            cmp.set("v.showForm",true);
                            cmp.set('v.boolReadOnly', false); 
                            cmp.set('v.boolNewContact', false);
                            this.createNewContact(cmp, event); 
                        }
                        else{
                        	cmp.set("v.isOpen", true); 
                            cmp.set("v.showForm",false);
                            cmp.set('v.dupContacts', results); 
                            cmp.set('v.boolShowNew', true);    
                        } 
                    }   
                    else{
                        //datatable.set('v.selectedRows', '[]')
                        cmp.set('v.dupContacts', results);
                        
                        this.createNewContact(cmp, event);
                		cmp.set('v.boolNewContact',false);
                        cmp.set("v.isOpen", false);
      					cmp.set("v.showForm",true); 
                    }
                }
            });
            $A.enqueueAction(search);
            }
    },    
    createNewContact : function(cmp, event) {
        var firstName = cmp.get('v.firstName');
        var lastName = cmp.get('v.lastName');
        var phone = cmp.get('v.phone');
        var email = cmp.get('v.email');
        var title = cmp.get('v.title');
        var preferred = cmp.get('v.preferred');
        var department = cmp.get('v.selDept');
        var caseId = cmp.get('v.recordId');
        var relevantAcct = cmp.get('v.caseAccount'); 
        var extension = cmp.get('v.extension');
        console.log(firstName + ' is first');
        console.log(lastName + ' is last');
        console.log(phone + ' is phone');
        console.log(email + ' is email');
        console.log(title + ' is title');
        console.log(department  + ' is department');
        console.log(preferred + ' is preferred');
        console.log(relevantAcct + ' is account')
        console.log(extension + ' is extension');
        console.log(caseId + ' is case');
        
        var createNewContact = cmp.get('c.createNewContact');
        createNewContact.setParams({
            firstName : firstName,
            lastName : lastName,
            accountId : relevantAcct,
            caseId : caseId,
            phone : phone,
            email : email,
            title : title,
            department : department,
            preferred : preferred,
            extension : extension
        });
        createNewContact.setCallback(this, function(response) {
            var state = response.getState()
            var returnVal = response.getReturnValue()
            console.log(status);
            console.log(returnVal);
            if (state === 'SUCCESS') {
                cmp.set('v.contactId', returnVal);
                cmp.set("v.searchFirstName","");
        		cmp.set("v.searchLastName","");
        		cmp.set("v.searchEmail","");
        		cmp.set("v.searchPhone","");
        		cmp.set("v.searchMobile","");
                cmp.set("v.showPriorSearchResult",false);
                       cmp.set("v.extension","");
            } else {
                console.log(response.getError());
            }
        });
        $A.enqueueAction(createNewContact);
    },
    createNewVenContact : function(cmp, event) {
        var firstName = cmp.get('v.firstName');
        var lastName = cmp.get('v.lastName');
        var phone = cmp.get('v.phone');
        var email = cmp.get('v.email');
        var preferred = cmp.get('v.preferred');
        
        var relevantAcct = cmp.get('v.vendorAccount');
        
        var extension = cmp.get('v.extension');
        
        console.log(firstName, lastName, phone, email, preferred, relevantAcct);
        
        var createNewContact = cmp.get('c.createNewVenContact');
        createNewContact.setParams({
            firstName : firstName,
            lastName : lastName,
            accountId : relevantAcct,
            phone : phone,
            email : email,
            preferred : preferred,
            extension : extension
        });
        createNewContact.setCallback(this, function(response) {
            var state = response.getState();
            var returnVal = response.getReturnValue();
            if (state === 'SUCCESS') {
                cmp.set('v.contactId', returnVal);
                cmp.set("v.searchFirstName","");
        		cmp.set("v.searchLastName","");
        		cmp.set("v.searchEmail","");
        		cmp.set("v.searchPhone","");
        		cmp.set("v.searchMobile","");
                cmp.set("v.showPriorSearchResult",false);
            } else {
                console.log(response.getError());
            }
        });
        $A.enqueueAction(createNewContact);
    },
    existingContactUpdate : function(cmp, event) {
        //Pull the case ID and Contact Id for save purposes
        var caseId = cmp.get('v.recordId');
        var contId = cmp.get('v.contactId');
        var conType = cmp.get('v.conType');
        var relevantAcct;
            
        if (cmp.get('v.boolCustomer') == true) {
            relevantAcct = cmp.get('v.caseAccount');
        } else if (cmp.get('v.boolVendor') == true) {
            relevantAcct = cmp.get('v.vendorAccount');
        }
                
        console.log(caseId, contId, conType, relevantAcct);
        
        //Call the existing Contact method
        var saveCase = cmp.get('c.existingContact');
        saveCase.setParams({
            caseId : caseId,
            accountId: relevantAcct,
            contactId : contId,
            type : conType
        });
        saveCase.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                if(response.getReturnValue())
                {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "mode": "sticky",
                        "title": "Error!",
                        "type": "Error",
                        "message": "Contact's Account Title is inactive. Please update the Account Title on the contact to move forward."
                    });
                    toastEvent.fire();
                }
                else
                {
                    cmp.set("v.showForm",false);
                    var appEvent = cmp.getEvent("SingleTabRefreshEvent");
                    appEvent.setParams({ "reload" : "true" });
                    appEvent.fire();
                    cmp.set('v.boolCustomer', false);
                    cmp.set('v.boolVendor', false);
                    cmp.set('v.boolInternal', false);
                    cmp.set('v.boolNewContact', false);
                    cmp.set('v.boolSOSL', false);
                    cmp.set('v.showSearch', false);
                    cmp.set('v.boolEdit', false);
                    cmp.set('v.boolShowNew', false);
                    cmp.set('v.boolShowUser', false);
                    cmp.set("v.searchFirstName","");
        			cmp.set("v.searchLastName","");
        			cmp.set("v.searchEmail","");
        			cmp.set("v.searchPhone","");
        			cmp.set("v.searchMobile","");
                    cmp.set("v.showPriorSearchResult",false);
                    this.returnCase(cmp, event);
                }
            } else {
                console.log(response.getError());
            }
        });
        $A.enqueueAction(saveCase);
    },
    getAccountTeam : function(cmp, event) {
        var caseAccount = cmp.get('v.caseAccount');
        var getAccountTeam = cmp.get('c.getAccountTeam');
        getAccountTeam.setParams({
            accountId : caseAccount
        });
        getAccountTeam.setCallback(this, function(response) {
            var state = response.getState();
            var returnVal = response.getReturnValue();
            if (state === 'SUCCESS') {
                cmp.set('v.soslContacts', returnVal);
            } else {
                console.log(response.getError());
            }
        })
        $A.enqueueAction(getAccountTeam);
    },
    getUsers : function(cmp, event){
        var datatable = cmp.find('atmTable');
        cmp.set('v.contactId','');
        
        var userString = cmp.get('v.userString');
        //alert('userStrin=='+userString);
        
        var getUsers = cmp.get('c.getUsers');
        getUsers.setParams({
            query : userString
        });
        
        getUsers.setCallback(this, function(response) {
            var state = response.getState();
            var returnVal = response.getReturnValue();
            
            if (state === 'SUCCESS') {
                if (returnVal.Id != '') {
                    cmp.set('v.soslContacts', returnVal);
                } else {
                    datatable.set('v.selectedRows', '[]');
                    cmp.set('v.soslContacts', results);
                }
            }
        });
        $A.enqueueAction(getUsers);
    },
    internalContact : function(cmp, event) {
        var internalContact = cmp.get('c.internalContact');
        internalContact.setParams({});
        internalContact.setCallback(this, function(response) {
            var state = response.getState();
            var returnVal = response.getReturnValue();
            if (state === 'SUCCESS') {
                cmp.set('v.contactId',returnVal);
            } else {
                console.log(response.getError());
            }
        });
        $A.enqueueAction(internalContact);
    },
    saveUserToCase : function(cmp, event) {
        var caseId = cmp.get('v.recordId');
        var userId = cmp.get('v.userId');
        var contactId = cmp.get('v.contactId');
        
        console.log('Case: ' + caseId);
        console.log('User: ' + userId); 
        console.log('Contact: ' + contactId);
        
        var saveUserToCase = cmp.get('c.saveUserToCase');
        saveUserToCase.setParams({
            caseId : caseId,
            userId : userId
        });
        saveUserToCase.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var appEvent = cmp.getEvent("SingleTabRefreshEvent");
                	appEvent.setParams({ "reload" : "true" });
					appEvent.fire(); 
                
                $A.get('e.force:refreshView').fire();
                /*var workspaceAPI = cmp.find("workspace");
                workspaceAPI.getFocusedTabInfo().then(function(response) {
                    var currTab = response.tabId;
                    workspaceAPI.refreshTab({
                        tabId : currTab,
                        includeAllSubtabs : true
                    });
                });*/
                cmp.set('v.boolCustomer', false);
                cmp.set('v.boolVendor', false);
                cmp.set('v.boolInternal', false);
                cmp.set('v.boolNewContact', false);
                cmp.set('v.boolSOSL', false);
                cmp.set('v.showSearch', false);
                cmp.set('v.boolEdit', false);
                cmp.set('v.boolShowNew', false);
                cmp.set('v.boolShowUser', true);
                cmp.set("v.showPriorSearchResult",false);
                this.returnCase(cmp, event);
            } else {
                console.log(response.getError());
            }
        });
        $A.enqueueAction(saveUserToCase);
    }   
})