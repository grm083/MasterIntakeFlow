({
    init : function(cmp, event, helper) {
        cmp.set('v.soslFields', [
			{label: 'Name',  fieldName: 'Name', type: 'text', cellAttributes: {class: {fieldName: 'showClass'}}},
			{label: 'Title', fieldName: 'Title', type: 'text', cellAttributes: {class: {fieldName: 'showClass'}}},
			{label: 'Phone', fieldName: 'Phone', type: 'text', cellAttributes: {class: {fieldName: 'showClass'}}},
			{label: 'Email', fieldName: 'Email', type: 'text', cellAttributes: {class: {fieldName: 'showClass'}}}
		]);
        //Uses the helper to load the case details to component variables
        var isLocation = !cmp.get('v.isVendor') && !cmp.get('v.isClient');
         cmp.set('v.isLocation', isLocation);
        helper.returnCase(cmp, event);
    },
	closeModel : function(component, event, helper) {
		component.set("v.showForm",false);
          component.set("v.isModalOpenContact",false);
        component.set("v.searchFirstName","");
        component.set("v.searchLastName","");
        component.set("v.searchEmail","");
        component.set("v.searchPhone","");
        component.set("v.searchMobile","");
        component.set("v.boolShowNew",false);
        component.set("v.extension",""); //STD-12999
        component.set("v.showPriorSearchResult",false);
	},
    handleCusClick : function(cmp, event, helper) {
        //Sets the contact type to customer and id to nothing
        if(cmp.get('v.conType') == 'Vendor'){
           cmp.set('v.searchFirstName', ''); 
         cmp.set('v.searchLastName', '');
         cmp.set('v.searchEmail', '');
         cmp.set('v.searchPhone', '');
         cmp.set("v.extension","");
         cmp.set("v.searchMobile","");
            
        }
        cmp.set('v.conType', 'Customer');
        cmp.set('v.soslContacts', '[]');
        cmp.set('v.contactId','');
        cmp.set('v.userId', '');
        cmp.set('v.boolNewContact', false);
        cmp.set('v.boolShowNew', false);
        cmp.set('v.searchLabel', "Search for your contact below, and press enter when you're ready to search");
        cmp.set('v.searchPlaceholder', 'Search all account contacts...');
        cmp.set('v.searchString', '');
        
        //Clears any new contact entries
        cmp.set('v.firstName', '');
        cmp.set('v.lastName', '');
        cmp.set('v.phone', '');
        cmp.set('v.email', '');
        cmp.set('v.title', '');
        cmp.set('v.preferred', '');
        
        //Sets the customer interface to true which will show it
		var boolCustomer = cmp.get('v.boolCustomer')
        cmp.set('v.boolCustomer',!boolCustomer);
        
        //Toggles the other buttons off 
        if (boolCustomer != true) {
            cmp.set('v.boolCorporate',boolCustomer);
            cmp.set('v.boolVendor',boolCustomer);
            cmp.set('v.boolInternal',boolCustomer);
        };
        
        //helper.searchLocCont(cmp, event);
	var  location  =  cmp.get('v.locAccount');
        var  account  =  cmp.get('v.caseAccount');
        var isLocation = cmp.get('v.isLocation');
        var isClient = cmp.get('v.isClient');
            
        if(location && isLocation){
            helper.searchLocCont(cmp, event,location);
        } else  if(account && isClient){
            helper.searchLocCont(cmp, event,account);
        }  
	    
        //Sets the variable to true that would otherwise hide the component
        cmp.set('v.boolSOSL', true);
	},
 	handleVenClick : function(cmp, event, helper) {
         
        cmp.set('v.contactId','');
        cmp.set('v.conType', 'Vendor');
        cmp.set('v.soslContacts', '[]');
        cmp.set('v.userId', '');
        cmp.set('v.boolNewContact', false);
        cmp.set('v.boolShowNew', false);
        cmp.set('v.searchLabel', "Search across all vendors below, and press enter when you're ready to search");
        cmp.set('v.searchPlaceholder', 'Search all vendors...');
        cmp.set('v.searchString', '');
        cmp.set('v.showSearch', false);
        
        //Clears any new contact entries
        cmp.set('v.firstName', '');
        cmp.set('v.lastName', '');
        cmp.set('v.phone', '');
        cmp.set('v.email', '');
        cmp.set('v.title', '');
        cmp.set('v.preferred', '');
        
        cmp.set("v.searchFirstName","");
         cmp.set('v.searchLastName', '');
         cmp.set('v.searchEmail', '');
         cmp.set('v.searchPhone', '');
         cmp.set("v.extension","");
          cmp.set("v.searchMobile","");
            
		var boolVendor = cmp.get('v.boolVendor')
        cmp.set('v.boolVendor',!boolVendor);
        if (boolVendor != true) {
            cmp.set('v.boolCorporate',boolVendor);
            cmp.set('v.boolCustomer',boolVendor);
            cmp.set('v.boolInternal',boolVendor);
        }
        
        helper.returnVendors(cmp, event);
        
        cmp.set('v.boolSOSL', false);
	},
	handleIntClick : function(cmp, event, helper) {
        cmp.set('v.contactId','');
        cmp.set('v.soslContacts', '[]');
        cmp.set('v.userString', '');
        cmp.set('v.userId', '');
        cmp.set('v.boolNewContact', false);
        cmp.set('v.lastName','');
        cmp.set('v.boolShowNew', false);
        
		var boolInternal = cmp.get('v.boolInternal')
        cmp.set('v.boolInternal',!boolInternal);
        if (boolInternal != true) {
            cmp.set('v.boolCorporate',boolInternal);
            cmp.set('v.boolVendor',boolInternal);
            cmp.set('v.boolCustomer',boolInternal);
        }
        
        //helper.getAccountTeam(cmp, event);
	},
    newContact : function(cmp, event, helper) {
        
        //SDT-10964: Set the Contact Detail on new contact component if not come in serach detail.
        var firstName = cmp.get('v.searchFirstName');
        cmp.set('v.firstName', firstName);
        var lastName = cmp.get('v.searchLastName');
        cmp.set('v.lastName', lastName);
        var phone = cmp.get('v.searchPhone');
        cmp.set('v.phone', phone);
        var email = cmp.get('v.searchEmail');
        cmp.set('v.email', email);
        
        //var preferred = cmp.get('v.preferred');
        
        //Set the contact Id to nothing to hide the "show details" panel
        cmp.set('v.contactId', '');
        
        //Fire Conditional methods from the helper
        if (cmp.get('v.boolCustomer') == true) {
            cmp.set('v.conType', 'Customer')
        	helper.getAccountTitles(cmp, event);
        	helper.getAccountDepts(cmp, event);
        } else {
            cmp.set('v.conType', 'Vendor')
            cmp.set('v.lastName', cmp.get('v.vendorName'));
            helper.getVendorRoles(cmp, event);
        }
        
        //Set the new contact boolean value to true to show the new contact panel
        var boolNewContact = cmp.get('v.boolNewContact');
        cmp.set('v.boolNewContact', !boolNewContact);
    },
    saveExistingContact : function(cmp, event, helper) {
        //cmp.set("v.showForm",false);
        helper.existingContactUpdate(cmp, event);
        
        
    },
    
      /*SearchButton : function(component, event) {
        component.set('v.BoolSearchButton', true);
        
        var eventKeyCode = event.keyCode;
        component.set('v.eventKey',eventKeyCode);
        var a = component.get('c.searchAllContact');
        $A.enqueueAction(a);
    },*/
    
    searchAll : function(cmp, event) {
        //When the user presses enter this function is fired
        var isEnterKey = true;
         var boolButtonForSearch = true;
        /*
        if (cmp.get('v.BoolSearchButton') == true){
            
            
        }
        else{
             isEnterKey = event.keyCode === 13;
        }
            
        var boolButtonForSearch = cmp.get('v.BoolSearchButton');
        
        if (cmp.get('v.boolCustomer') == true && cmp.get('v.boolSOSL') == true) {
            cmp.set('v.soslRows', '[]');
        }
        cmp.set('v.contactId', '');
        */
        if (isEnterKey || boolButtonForSearch) {
            
            cmp.set('v.boolNewContact', false);
            cmp.set('v.BoolSearchButton', false);
           
            //Resets the contact Id to nothing and the selected rows to unselected
           	var datatable = cmp.find('soslTable');
            cmp.set('v.contactId','');
            cmp.set('v.boolShowNew', false);
            
            //finds the search bar where the user entered their value
            //and stores the entry as a variable
            var contName = cmp.get('v.searchString');
         	
            
            //Invokes the searchContact method using the name and current
            //account Id from the case
            
            var relevantAcct;
            if (cmp.get('v.boolCustomer') == true) {
                relevantAcct = cmp.get('v.caseAccount');
                var search = cmp.get('c.searchContact');
                search.setParams({
                    searchQuery : contName,
                    acct : relevantAcct
                })
                search.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === 'SUCCESS') {
                        //SOSL may return nothing, and we need conditions for handling
                        //nothing and the caching of prior selections in the data table
                        var results = response.getReturnValue();
                        if (results.ContactId != '') {
                            cmp.set('v.soslContacts', results);
                            cmp.set('v.boolShowNew', true);
                            //Note that this still returns nothing, however it should reset the
                            //value of the SelectedRows attribute of the datatable
                        } else {
                            datatable.set('v.selectedRows', '[]')
                            cmp.set('v.soslContacts', results);
                        }
                    }
                });
                
                $A.enqueueAction(search);
                
            } else if (cmp.get('v.boolVendor') == true && contName.length >=3) {
                
                var search = cmp.get('c.searchVendors');
                search.setParams({
                    searchQuery : contName
                })
                
                //Fires the method conditionally upon the response state
                search.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === 'SUCCESS') {
                        
                        //SOSL may return nothing, and we need conditions for handling
                        //nothing and the caching of prior selections in the data table
                        var results = response.getReturnValue();
                        if (results.Id != '') {
                            cmp.set('v.vendorAccts', results);
                            
                            //Note that this still returns nothing, however it should reset the
                            //value of the SelectedRows attribute of the datatable
                        } else {
                            datatable.set('v.selectedRows', '[]')
                            cmp.set('v.vendorAccts', results);
                        }
                    }
                });
                $A.enqueueAction(search);
            }
        }
    },
    
    searchAllContact : function(cmp, event) {
        
        var contFName  = cmp.get('v.searchFirstName');
            var contLName  = cmp.get('v.searchLastName');
            var contEmail  = cmp.get('v.searchEmail');
            var contPhone  = cmp.get('v.searchPhone');
            var contMobile = cmp.get('v.searchMobile');
        
        if(contFName.length > 2 || contLName.length > 2 || event.type === 'focusout'){
            var relevantAcct;
            //var contFName  = cmp.get('v.searchFirstName');
            //var contLName  = cmp.get('v.searchLastName');
            //var contEmail  = cmp.get('v.searchEmail');
            //var contPhone  = cmp.get('v.searchPhone');
            //var contMobile = cmp.get('v.searchMobile');
            var caseId = cmp.get('v.recordId');
        
            if(cmp.get('v.boolCustomer') == true){
                relevantAcct = cmp.get('v.caseAccount');
                var search = cmp.get('c.searchContacts');
                search.setParams({
                    firstName : contFName, 
                    lastName : contLName,
                    email : contEmail,
                    phone : contPhone,
                    mobile : contMobile,
                    acct : relevantAcct,
                    caseId : caseId
                })
                search.setCallback(this, function(response) {
                    var state = response.getState();
                    if(state === 'SUCCESS') {
                        var results = response.getReturnValue();
                        var compareStr = 'Yes';
                        if(results.ContactId != '') {
                            results.forEach(function(record){ 
                                if(record.BusinessRuleAssociation != "undefined" && record.BusinessRuleAssociation != null){
                                	record.showClass = record.BusinessRuleAssociation.toLowerCase() === compareStr.toLowerCase()? 'bgHighlight' : 'noBgHighlight';
                                }
                            });
                            cmp.set('v.soslContacts', results);
                            cmp.set('v.boolShowNew', true);
                          } 
                          else{
                            datatable.set('v.selectedRows', '[]')
                            cmp.set('v.soslContacts', results);
                        }
                    }
                });
                $A.enqueueAction(search);
            }
         	else if(cmp.get('v.boolVendor') == true){
                var search = cmp.get('c.searchVendors');
                search.setParams({
                    firstName: contFName,
                    lastName : contLName,
                    email 	 : contEmail,
                    phone    : contPhone,
                    mobile   : contMobile
                })
                search.setCallback(this, function(response){
                    var state = response.getState();
                    if(state === 'SUCCESS'){
                        var results = response.getReturnValue();
                        if(results.Id != ''){
                            cmp.set('v.vendorAccts', results);
                        } 
                        else{
                            datatable.set('v.selectedRows', '[]')
                            cmp.set('v.vendorAccts', results);
                        }
                    }
                });
                $A.enqueueAction(search);
            }
        }  
    }, 
    
    selectContact : function(cmp, event, helper) {
        //Drives user selection of a row in the datatable
		cmp.set('v.contactId', '');
        cmp.set('v.boolNewContact', false);
        var selectedRows = event.getParam('selectedRows');
        
        //Prior to moving forward, logic on what to do if there are no rows
        if (selectedRows.length != 0) {
            console.log('The selected title is ' + selectedRows[0].Title);
            if (cmp.get('v.boolVendor') == true && selectedRows[0].Title != undefined) {
                console.log('setting fields to read only');
                cmp.set('v.boolReadOnly', true);
            } else {
                console.log('setting fields to view');
                cmp.set('v.boolReadOnly', false);
            }

            var rowId = selectedRows[0].ContactId; 
            console.log('rowId'+rowId); 
            if(typeof rowId != "undefined"){
                cmp.set('v.contactId', rowId);
            }	
            else{ 
                helper.createNewContact(cmp, event);
            }              
        } 
         
    },
    selectVenAccount : function(cmp, event) {
        cmp.set('v.showSearch', true);
        var selectedRows = event.getParam('selectedRows');
        cmp.set('v.boolShowNew', true);
        
        if (selectedRows.length != 0) {
            var datatable = cmp.find('soslTable');
            var rowId = selectedRows[0].AccountId;
            cmp.set('v.vendorAccount', rowId);
            cmp.set('v.vendorName', selectedRows[0].Name);
            var action = cmp.get("c.getVendorContacts");
            action.setParams({
                vendor : cmp.get('v.vendorAccount')
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === 'SUCCESS') {
                    
                    //SOSL may return nothing, and we need conditions for handling
                    //nothing and the caching of prior selections in the data table
                    var results = response.getReturnValue();
                    if (results.ContactId != '') {
                    	cmp.set('v.soslContacts', results);
                        
                    //Note that this still returns nothing, however it should reset the
                    //value of the SelectedRows attribute of the datatable
                    } else {
                        datatable.set('v.selectedRows', '[]');
                        cmp.set('v.soslContacts', results);
                    }
                }
            });
            $A.enqueueAction(action);
        }
    },
    changeContact : function(cmp, event) {
        var boolEdit = cmp.get('v.boolEdit');
        cmp.set('v.boolEdit', !boolEdit);
    },
    addNewTitle : function(cmp, event, helper) {
        $A.createComponent('c:createNewAccountTitle', {
            'accountId' : cmp.get('v.caseAccount')
        }, 
        function(modalComponent, status, errorMessage) {
            if (status === 'SUCCESS'){
                var body = cmp.find('titleModal').get('v.body');
                body.push(modalComponent);
                cmp.find('titleModal').set("v.body", body);
            } else if (status === 'INCOMPLETE'){
                console.log('Server Issue maybe');
            } else if (status === 'ERROR') {
                console.log('error');
            }
        });
    },
    newTitleCreated : function(cmp, event, helper) {
        helper.getAccountTitles(cmp, event);
        var newTitle = event.getParam('titleName')
        cmp.set('v.title', newTitle);
        helper.showTitleToast(cmp, event);
    },
    saveNewContact : function(cmp, event, helper) {
        var phone = cmp.get('v.phone');
        var email = cmp.get('v.email');
        var firstName = cmp.get('v.firstName');
        var lastName = cmp.get('v.lastName');
        var preferred = cmp.get('v.preferred');
        var title = cmp.get('v.title');
        
        var extension = cmp.get('v.extension');
        
        if (phone == '' && email == '') {
            alert('You must enter either an email or phone number prior to saving this contact.')
        } else if (firstName == '' || lastName == '' || preferred == "") {
            alert('Please complete all required fields prior to attempting to save this contact.')
    	} else if (cmp.get('v.boolCustomer') === true) {
            if (title == '') {
                alert('Title is a required field for all customer contacts.')
            } else {
                helper.checkDuplicateContacts(cmp, event);  
            }
        } else if (cmp.get('v.boolVendor') === true) {  
        	helper.createNewVenContact(cmp, event);
            cmp.set('v.boolNewContact',false);
        }
    },
    closeModelForDuplicate : function(component, event, helper) {
      // for Hide/Close Model,set the "isOpen" attribute to "False"  
      component.set("v.isOpen", false);
      component.set("v.showForm",true);  
   }, 
    searchUsers : function(cmp, event, helper) {
        //var isEnterKey = event.keyCode === 13;
        var isEnterKey=true;
        var userkey = cmp.get('v.userString');
        cmp.set('v.userId', '');
        var soslTable = cmp.find('atmTable');
        soslTable.set('v.selectedRows', '[]');
        if (isEnterKey && userkey.length >=3) {
            helper.getUsers(cmp, event);
        };
    },
    getUserDetails : function(cmp, event, helper) {
		cmp.set('v.userId', '');
        var selectedRows = event.getParam('selectedRows');
        if (selectedRows.length != 0) {
            var userId = selectedRows[0].ContactId;
            cmp.set('v.userId', userId);
        } 
    },
    saveUser : function(cmp, event, helper) {
        helper.saveUserToCase(cmp, event);
    },
    minimizeModal : function(component, event, helper) {
        component.set("v.isModalOpenContact",false);
        component.set("v.showForm",false); 
        //12999
        var conserachResult  = component.get("v.soslContacts");
        if(conserachResult && conserachResult !="[]"){
            component.set("v.showPriorSearchResult" ,true)
        }
          if(component.get('v.conType') == 'Vendor'){
         component.set('v.searchFirstName', '');
         component.set('v.searchLastName', '');
         component.set('v.searchEmail', '');
         component.set('v.searchPhone', '');
           component.set("v.extension","");
            component.set("v.searchMobile","");
          component.set("v.showPriorSearchResult",false);
        component.set("v.soslContacts","[]");
            
        }
        
    },
    //bugFix -// 12999
     setUserInputValues : function(cmp, event) {
         cmp.set('v.searchFirstName',cmp.get('v.firstName'));
         cmp.set('v.searchLastName', cmp.get('v.lastName'));
         cmp.set('v.searchEmail', cmp.get('v.email'));
         cmp.set('v.searchPhone', cmp.get('v.phone')); 
    }
})