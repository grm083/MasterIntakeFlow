({
    openModel: function (component, event, helper) {
        component.set("v.isOpen", true);
    },
    closeModel: function (component, event, helper) {
        component.set("v.isOpen", false);
    },
    toggleSection: function (component, event, helper) {
        var sectionAuraId = event.target.getAttribute("data-auraId");
        var sectionDiv = component.find(sectionAuraId).getElement();
        var activeSectionDiv = component.find("activeAssetHeaderSection").getElement();
        var inactiveSectionDiv = component.find("inactiveAssetHeaderSection").getElement();
        var sectionState = sectionDiv.getAttribute('class').search('slds-is-open');
        if (sectionAuraId == 'activeAssetHeaderSection') {
            if (sectionState == -1) {
                sectionDiv.setAttribute('class', 'slds-section slds-is-open');
                inactiveSectionDiv.setAttribute('class', 'slds-section slds-is-close');
            } else {
                sectionDiv.setAttribute('class', 'slds-section slds-is-close');
            }
        }
        if (sectionAuraId == 'inactiveAssetHeaderSection') {
            if (sectionState == -1) {
                sectionDiv.setAttribute('class', 'slds-section slds-is-open');
                activeSectionDiv.setAttribute('class', 'slds-section slds-is-close');
            } else {
                sectionDiv.setAttribute('class', 'slds-section slds-is-close');
            }
        }
        component.updateAssetHeaders();
    },

    doInit: function (component, event, helper) {
        component.set("v.loadingSpinner", true);
        component.set("v.isMultiAssetCase", false);
        helper.getAssetHeaders(component, event, helper);
        helper.saveDisableCheck(component, event, helper);
    },

    onSelectAsset: function (component, event, helper) {
        var assetIds = component.get('v.selectedOptions');
        var alreadySelectedAssets = component.get("v.selectedAssetHeaders");
           
        component.set('v.saveEnabled', false);
											   
        if (component.get('v.officetrax') == true) {
            var id_str = event.currentTarget.dataset.value;
            assetIds = id_str;
        } else {
            var id_str = event.currentTarget.dataset.value;
            var index = event.currentTarget.dataset.record;
            if (assetIds.includes(id_str)) {
                var index = assetIds.indexOf(id_str);
                if (index > -1) {
                    assetIds.splice(index, 1);
                }
            } else {
                assetIds.push(id_str);
            }
        }
        if (assetIds == null || assetIds == '') {
            component.set('v.saveEnabled', true);
        }
        if (assetIds.length == alreadySelectedAssets.length && helper.checkContainer(assetIds, alreadySelectedAssets)) {
            component.set('v.saveEnabled', true);
            component.set('v.selectedOptions', alreadySelectedAssets);
        }
        else {
            component.set("v.selectedOptions", assetIds);
        }
    },

    saveAssetInCase: function (component, event, helper) {
        var assetSelections = component.get('v.selectedOptions');
        var existingAssetOnCase = component.get("v.assetIdOnCase")
        var assetToReplace = null;
        var multiAssetIds = [];
        var assetHeaders = component.get('v.assetHeaders');
        var equipmentTypes = [];
        var caseRecord = component.get('v.caseRecord');

        for(let i = 0; i<assetSelections.length; i++){
            var obj = assetHeaders.find(o => o.assetId == assetSelections[i]);
            //Added null check. Jatan
            if(obj !=null)
            {
                equipmentTypes.push(obj.EquipmentType);
            }
        }
        
        if (assetSelections && assetSelections.length == 1 && !assetSelections.includes(existingAssetOnCase)) {
            assetToReplace = assetSelections[0];
        }
        else if (assetSelections && assetSelections.length > 1) {
            if (!assetSelections.includes(existingAssetOnCase)) {
                assetToReplace = assetSelections[0];
            }
            for (var idx = 0; idx < assetSelections.length; idx++) {
                if (existingAssetOnCase !== assetSelections[idx]) {
                    multiAssetIds.push(assetSelections[idx]);
                }
            }
        }
        if (assetToReplace && multiAssetIds) {
            multiAssetIds.shift();
        }
        
        if(caseRecord.Status == 'Open' && caseRecord.Case_Type__c == 'Pickup' && caseRecord.Case_Sub_Type__c == 'Bale(s)' && !equipmentTypes.includes('Baler')){
            helper.showToast(component, 'Error', 'You may only select Baler Equipment Type.');
        }else{
            helper.replaceAssetOrStoreSelectionOnCase(component, event, assetToReplace, multiAssetIds);
            component.set("v.saveEnabled", true);
            component.set("v.loadingSpinner", true);
        }
        
    },
})