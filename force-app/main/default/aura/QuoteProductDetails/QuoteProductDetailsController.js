({
	doinit : function(cmp, event, helper) {
        var inlineEditing = false;
		var editCost = cmp.get('v.canCost');
        var editPrice = cmp.get('v.canPrice');
        var editVendor = cmp.get('v.canVendor');
        var detailLines = cmp.get('v.productHeader.details');
        //shajiya 48563
        var errorMessage='';
        var hasErrors = false;
        var quoteLineErrors = cmp.get("v.lineErrorList") || [];
        detailLines.forEach(rec => {
            errorMessage += rec.errorMessage
            //  errorList to hold all validations
             var qlineErrorList = [];
            if (rec.errorMessage && rec.errorMessage !== 'All validations passed') {
                rec.errorList = rec.errorMessage.split(/;|\n/).map(e => e.trim());
                var qlineErrorList = rec.qLErrorMessages
                    .split(/;|\n/)         // Split the string into an array of substrings
                    .map(e => e.trim())    // Trim whitespace from each substring
                    .filter(e => e.length > 0) // Optional: Remove empty strings resulting from the split
                    .map(trimmedError => { // Add the custom prefix to the non-empty, trimmed message
                        return rec.componentType+' '+ trimmedError+' for the quote.';
                    });
                qlineErrorList = [...new Set(qlineErrorList)];
                console.log('Error List:', rec.errorList);
                rec.errorMessage = rec.errorList.length > 0 ? rec.errorList[0] : ''; 
            } else {
                qlineErrorList = [];
                rec.errorList = [];
                rec.errorMessage = 'All Validations Passed'; // No error for icon
                            rec.qLErrorMessages = '';
                            rec.iconName = 'utility:check'; // reset hover + icon
            }
            rec.errorIndex = 0;
            var newItem = {
                "QLName": rec.quoteLineName,
                "QLErrorsList": qlineErrorList
            };

            if (qlineErrorList && qlineErrorList.length > 0) {
                hasErrors = true;
                quoteLineErrors.push(newItem);
            }

        });
                // <--- Minimal change: if no errors at all, push single "All validations passed" row
        if (!hasErrors) {
            quoteLineErrors.push({
                "QLErrorsList": ['All validations passed for all quote lines']
            });
        }
        cmp.set("v.lineErrorList", quoteLineErrors);
        cmp.set('v.productHeader.details', detailLines);
        console.log('errorMessage' + errorMessage);
        //shajiya48563
        
        cmp.set('v.detailColumns', [
            {label: 'Validation', fieldName: '',  type: 'button-icon', typeAttributes: {iconName: {fieldName: 'iconName'}, 
                                                                  alternativeText: {fieldName: 'errorMessage'},  alignment: 'center'}},
            {label: 'Quote Line', fieldName: 'quoteLineName', type: 'text', wrapText: true},
            {label: 'Component', fieldName: 'componentType', type: 'text', wrapText: true},
            {label: '', fieldName: 'costCurrencyCode', type: 'text', wrapText: false, cellAttributes: {alignment: 'center'}},
            {label: 'Cost', fieldName: 'vendorCost', type: 'text', editable: inlineEditing, typeAttributes: {maximumFractionDigits:'6'}, cellAttributes: {alignment: 'right'}},
            {label: 'Cost UOM', fieldName: 'costUOM', type: 'text', editable: inlineEditing},
            {label: '', fieldName: 'priceCurrencyCode', type: 'text', wrapText: false, cellAttributes: {alignment: 'center'}},
            {label: 'Price', fieldName: 'customerPrice', type: 'text', editable: inlineEditing, typeAttributes: {maximumFractionDigits:'6'}, cellAttributes: {alignment: 'right'}},
            {label: 'Price UOM', fieldName: 'priceUOM', type: 'text', editable: inlineEditing},
            {label: 'Start Date', fieldName: 'componentStartDate', type: 'date', typeAttributes: {
                day: 'numeric',
                month: 'numeric',
                year: 'numeric'
            }, editable: inlineEditing, wrapText: true},
            {label: 'End Date', fieldName: 'componentEndDate', type: 'date', typeAttributes: {
                day: 'numeric',
                month: 'numeric',
                year: 'numeric'
            }, editable: inlineEditing, wrapText: true}
        ]);   
        var product1 = cmp.get("v.productHeader");
        console.log("v.productHeader"+JSON.stringify(product1));
        console.log("product1"+product1.quoteID);
        
	},
    // 48563 expand / collapse bundle error section

    toggleBundleErrors: function (cmp, event, helper) {
        cmp.set("v.showBundleErrors", !cmp.get("v.showBundleErrors"));
    },
    //48563

    SIDDetails : function(cmp, event) {
        var product = cmp.get('v.productHeader');
        var name = event.getSource().get('v.name');
        cmp.set('v.componentType', name);
        cmp.set('v.showSIDModal', 'true');
    },
    serviceScheduler: function(cmp, event, helper){
        console.log('here');
        cmp.set('v.componentType', 'serviceSchedulerComponent');
        cmp.set('v.showSIDModal', 'true');
    },
    saveChanges : function(cmp, event) {
        
    },

     handleRowAction: function (cmp, event, helper) {
        var row = event.getParam('row');
        console.log('row==>' + JSON.stringify(row));
        // Check if the row has an errorList
            if (row.errorList && row.errorList.length > 0) {
        helper.showToast( event, 'error','Error', row.errorList[0] );
    }
    //  CASE 2: NO errors + success icon → show success toast
    else if (row.iconName === 'utility:check') {
        helper.showToast( event, 'success', 'Success', 'All validations passed' );
    }
    },
    closeModal: function(cmp) {
        cmp.set('v.showSIDModal', false);
    },
    closeDetail: function(cmp) {
        var closeModalEvent = cmp.getEvent('CloseModalEvent');
        closeModalEvent.setParams({
            "showModal" : "false"
        });
        closeModalEvent.fire();
    }
    
})