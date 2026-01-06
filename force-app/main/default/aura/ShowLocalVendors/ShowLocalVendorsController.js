({
	init : function(cmp) {
		var recordId = cmp.get('v.recordId');
        var action = cmp.get('c.getDetails');
        var allWasteCategories= $A.get('$Label.c.WasteCategory_ShowLocalVendorComp');
        cmp.set('v.showSpinner', true);
        action.setParams({
            quoteId: recordId
        });
        action.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS') {
                cmp.set('v.mapValues', response.getReturnValue());
                if(response.getReturnValue()){
                    let picklist=[];
                    let mapValues= cmp.get('v.mapValues');
                    for(var k in mapValues){
                        if(k!==allWasteCategories){
                            picklist.push(k);
                        }
                    }
                    cmp.set('v.picklist',picklist);
                    cmp.find('wasteStreamDropdown').setPicklistValues();
                    cmp.set('v.showSpinner', false);
                }
            }
        });
        $A.enqueueAction(action);
	},

    selectWSHandler : function(cmp,event){
        let selectedWs= event.getParam('value');
        let mapValues= cmp.get('v.mapValues');
        let wasteStreamAssetMap = new Map();
        for(let k in mapValues){
            wasteStreamAssetMap.set(k,mapValues[k]);
        }
        if(wasteStreamAssetMap.has(selectedWs)){
            let assetList= wasteStreamAssetMap.get(selectedWs);
            let masList=[];
            if(assetList){
                let masSet= new Set();
                let vendorMap= new Map();
                assetList.forEach(key=>{
                    
                    if(vendorMap.has(key.Supplier__r.Id)){
                        let v= vendorMap.get(key.Supplier__r.Id);
                        if(!v.Materials.includes(key.Material_Type__c)){
                            v.Materials = v.Materials+', '+key.Material_Type__c;
                        }
                        vendorMap.set(key.Supplier__r.Id,v);
                    }else {
                        let v= {Name:key.Supplier__r.Name,AccountNumber:key.Supplier__r.AccountNumber,Vendor_Business_Unit__c:key.Supplier__r.Vendor_Business_Unit__c,Legacy_Ranking__c:key.Supplier__r.Legacy_Ranking__c,Id:key.Supplier__r.Id,Materials:key.Material_Type__c};
                        vendorMap.set(key.Supplier__r.Id,v);
                    }
                    if(!masSet.has(key.MAS_Company_Code__c)){
                        masList.push({MAS_Library__c:key.MAS_Library__c,MAS_Company_Code__c:key.MAS_Company_Code__c});
                        masSet.add(key.MAS_Company_Code__c);
                    }
                });
                //console.log('vendorList>>'+vendorMap.values());
                //console.log('masList>>'+JSON.stringify(masList));
                
                let vlist=[];
                if(vendorMap.values()){
                    vendorMap.forEach((value,key)=>{
                        vlist.push(value);
                    });
                    cmp.set('v.vendorList',vlist);
                }
                if(masList){
                    cmp.set('v.masList',masList);
                }
            }
        }
    },

    onTabFocus: function(cmp, event) {
        $A.get('e.force:refreshView').fire();
    }
})