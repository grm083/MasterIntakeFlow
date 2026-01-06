({
    getData : function(cmp, event, helper){
        cmp.set("v.showSpinner",true);
        console.log('getData parentQuoteLineId'+cmp.get("v.parentQuoteLineId"));
       	var action = cmp.get("c.getclassificationChanges");
        action.setParams({ pQLineId :  cmp.get("v.parentQuoteLineId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var resp = response.getReturnValue();
                console.log('final doInit resp==>'+JSON.stringify(resp));
                cmp.set("v.cChangesObj",resp);
                // if(cmp.get("v.caseRecordtype") == 'Update Asset Case'){
                //TCS-SDT-31265-Modified record type check to New Service Case from Modify Existing Service Case
                if(cmp.get("v.caseRecordtype") != 'New Service Case'){
                
                	helper.formatJsonClr(cmp);   
               }
                cmp.set("v.showSpinner",false);
            }else{
                cmp.set("v.showSpinner",false);
            }
        });
        $A.enqueueAction(action);
    },
    
    // - SDT-42334 -> start
    getIsHaulAway : function(cmp, event, helper){
        var action = cmp.get("c.getIsHaulAwayValue");
        var parentQLId = cmp.get("v.parentQuoteLineId");
        action.setParams({
            pQLineId: parentQLId
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            
            if(state === 'SUCCESS'){
                var respons = response.getReturnValue();
                if (respons != null && respons != undefined) {
                    cmp.set('v.isHaulAway', respons);
                    console.log('isHaulAway value:', respons);
                } else {
                    console.warn('Received null or undefined response from Apex.');
                }
                
                console.log('abc abhishek'+cmp.get('v.isHaulAway'));
            }
        });
        $A.enqueueAction(action);
    },
    // // - SDT-42334 -> End
    formatJsonClr : function(cmp){
        var colorRed = 'red';	//pkulkar-TCS-08-May-23-Added as per SDT-29623 - To change the hard coded values
        var colorBlack = 'black';	//pkulkar-TCS-08-May-23-Added as per SDT-29623 - To change the hard coded values
        var cChangesObj = cmp.get("v.cChangesObj");
        var newQLineDetails = cChangesObj.newQLineDetails;
        var oldQLineDetails = cChangesObj.oldQLineDetails;
        var oldQLinesPrdIdSlineMap = {};
        Object.keys(oldQLineDetails).forEach(function(key) {
            if(key == 'serviceLines'){
                var oldsLines = oldQLineDetails[key];
                for(let j=0; j< oldsLines.length; j++){
                    if(!$A.util.isEmpty(oldsLines[j].productId)){
                        //SDT 33136 --Seema--23/11/23--comparing basis on Quoteline Id instead of product Id
                        //For product Keys it was not working as expected because same productId is shared by multiple services
                        //oldQLinesPrdIdSlineMap[oldsLines[j].productId] =oldsLines[j];
                        oldQLinesPrdIdSlineMap[oldsLines[j].qlId] =oldsLines[j];
                    }
                }
            }
        });
        console.log('oldQLinesPrdIdSlineMap==>'+JSON.stringify(oldQLinesPrdIdSlineMap));
        Object.keys(newQLineDetails).forEach(function(key) {
            console.log('key is ==>'+key);
            if(key != 'serviceLines'){
                let keyclr = key+'clr';
                newQLineDetails[keyclr] = colorBlack;
                if(newQLineDetails[key] != oldQLineDetails[key]){
                    newQLineDetails[keyclr] = colorRed;
                }
            }else{
                var sLines = newQLineDetails[key];
                for(let i=0; i< sLines.length; i++){
                    //SDT 33136 --Seema--23/11/23--comparing basis on Quoteline Id instead of product Id
                        //For product Keys it was not working as expected because same productId is shared by multiple services
                    //if(oldQLinesPrdIdSlineMap.hasOwnProperty(sLines[i].productId)){
                        //var oldSline = oldQLinesPrdIdSlineMap[sLines[i].productId];
                        if(oldQLinesPrdIdSlineMap.hasOwnProperty(sLines[i].qlId)){
                        var oldSline = oldQLinesPrdIdSlineMap[sLines[i].qlId];
                        if(oldSline.cost!= sLines[i].cost){
                            sLines[i].costclr = colorRed;
                        }
                        if(oldSline.price!= sLines[i].price){
                            sLines[i].priceclr = colorRed;
                        }
                        if(oldSline.schedule!= sLines[i].schedule){
                            sLines[i].scheduleclr = colorRed;
                        }
                        if(oldSline.startDate!= sLines[i].startDate){
                            sLines[i].startDateclr = colorRed;
                        }
                        if(oldSline.EndDate!= sLines[i].EndDate){
                            sLines[i].EndDateclr = colorRed;
                        }
                        if(oldSline.Vendor!= sLines[i].Vendor){
                            sLines[i].Vendorclr = colorRed;
                        }
                        //pkulkar-TCS-08-May-23-Added as per SDT-29623
                        if(oldSline.quantity!= sLines[i].quantity){
                            sLines[i].quantityclr = colorRed;
                        }
                        //pkulkar-TCS-08-May-23-End
                        //TCS-SDT-32165-Added following lines
                        if(oldSline.cMinimumQuantity != sLines[i].cMinimumQuantity){
                            sLines[i].cMinimumQuantityclr = colorRed;
                        }
                        if(oldSline.cUnitOfMeasurement != sLines[i].cUnitOfMeasurement){
                            sLines[i].cUnitOfMeasurementclr = colorRed;
                        }
                        if(oldSline.pUnitOfMeasurement != sLines[i].pUnitOfMeasurement){
                            sLines[i].pUnitOfMeasurementclr = colorRed;
                        }
                        if(oldSline.pMinimumQuantity != sLines[i].pMinimumQuantity){
                            sLines[i].pMinimumQuantityclr = colorRed;
                        }
                        //TCS-SDT-32165-End
                    }else{
                        sLines[i].costclr = colorRed;
                        sLines[i].priceclr = colorRed;
                        sLines[i].scheduleclr = colorRed;
                        sLines[i].serviceclr = colorRed;
                        sLines[i].startDateclr = colorRed;
                        sLines[i].EndDateclr = colorRed;
                        sLines[i].Vendorclr = colorRed;
                        //pkulkar-TCS-08-May-23-Added following line as per SDT-29623
                        sLines[i].quantityclr = colorRed;
                        //TCS-SDT-32165-Added following lines
                        sLines[i].cMinimumQuantityclr = colorRed;
                        sLines[i].cUnitOfMeasurementclr = colorRed;
                        sLines[i].pUnitOfMeasurementclr = colorRed;
                        sLines[i].pMinimumQuantityclr = colorRed;
                        //TCS-SDT-32165-End
                    }
                    /*Object.keys(sLines[i]).forEach(function(subKey) {
                      if(subKey != 'productId'){
                          let subKeyclr = subKey+'clr';
                          if(!$A.util.isEmpty(oldQLineDetails.serviceLines.find(c => c.productId == sLines[i].productId)) && oldQLineDetails.serviceLines.find(c => c.productId == sLines[i].productId)[subKey] != sLines[i][subKey]){
                              sLines[i][subKeyclr] = 'red';
                            }
                        }
                    });*/
                }
                newQLineDetails[key] = sLines;
            }
        });
        
        cChangesObj.newQLineDetails = newQLineDetails;
        console.log('cChangesObj==>'+JSON.stringify(cChangesObj));
        cmp.set("v.cChangesObj",cChangesObj);
    }
})