({
    
    doinit : function(cmp, event,helper) {
        
            // var action = cmp.get("c.showErrorWrapper");
            // var recordId = cmp.get("v.recordId");
        	// var product = event.getSource().get('v.value');
            // console.log('The product Id line is: ' + product.parentId);
            // action.setParams({
            //     quoteId: recordId,
            //     parentQLineId: null
            // });
            // action.setCallback(this,function(response){
            //     var state = response.getState();
                
            //     if(state === 'SUCCESS'){
            //         var response = response.getReturnValue();
            //         var showError = response.showMessage;
            //         if(showError){
            //             cmp.set('v.ShowiconForNTW',true);
            //             }   
            //         else{
            //             cmp.set('v.ShowiconForNTW',false);
            //         }
            //     }
            // });
        	// $A.enqueueAction(action);
            //cmp.set('v.ShowiconForNTW',true);
        console.log('do inti triggered');
        cmp.set('v.serviceWrapper', '[]');
        cmp.set('v.showSpinner', true);
        var recordId = cmp.get('v.recordId');
        cmp.set('v.quoteRecordId',recordId);
        var userRoleCombination ='';
        var userRole='';
        var action = cmp.get("c.fetchUser");
        action.setParams({
                        quoteId: cmp.get('v.recordId'),//SDT-42335
                        
                    });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //SDT-31110
                var result = response.getReturnValue();
                var storeResponse = result['User'];
                console.log('storeResponse==>'+JSON.stringify(storeResponse));
                cmp.set("v.loggedUser",storeResponse);
                userRoleCombination = storeResponse.RoleCombination__c;
                if(storeResponse.UserRole!=undefined ||storeResponse.UserRole!=null )
                userRole = storeResponse.UserRole.Name;
                
                // set constant SDT-31110
                cmp.set('v.NewServiceRecordType' , result["NewServiceRecordType"]);
                cmp.set('v.isHaulAway' , result["isHaulAway"]); //SDT-42335
            }
        });
        $A.enqueueAction(action);
        
        
        
        var getWrapper = cmp.get('c.buildWrapper');
        getWrapper.setParams({
            quoteId : recordId
        });
        getWrapper.setCallback(this, function(response) {
            var state = response.getState();
            console.log('Response is: ' + response.getState());
            if (state === 'SUCCESS') {
                var products = response.getReturnValue();
                //cmp.set('v.serviceWrapper', products);
                helper.assignccObj(cmp, event,helper);
                cmp.set('v.showSpinner', false);
                console.log('in prod');
                var showToast = false;
             if(products.length) {
                    for (let i = 0; i < products.configuredProducts.length; i++) {
                        console.log(JSON.stringify(products.configuredProducts[i]));
						//SDT 33101
                        var amendmentQuote = products.configuredProducts[i].quoteType;
                        if(amendmentQuote=='Amendment'){
                            cmp.set('v.IsAmendmentQuote', true);
                        }
                        //SDT 33101 end
                        if (products.configuredProducts[i].lineError) {

                            showToast = true;

                        }

                    }
                    if (showToast) {

                        var toastEvent = $A.get('e.force:showToast');

                        toastEvent.setParams({

                            'title': 'Validation Error',

                            'message': 'One or more lines have failed a validation check.  Please review the quote lines that indicate there is an error in the Configured Products component below.',

                            'type': 'error',

                            'mode': 'dismissible'

                        });

                        toastEvent.fire();

                    }

                }
				 if(products != undefined  && products != null && products.configuredProducts != undefined && products.configuredProducts != null) {
					 var qlIds= [];
                    for (let i = 0; i < products.configuredProducts.length; i++) {
                        console.log(JSON.stringify(products.configuredProducts[i]));
                        qlIds.push(products.configuredProducts[i].parentId);
                        

                    }
				 var action = cmp.get("c.showErrorWrapper");
                    var recordId = cmp.get("v.recordId");
                    action.setParams({
                        quoteId: recordId,
                        parentQLineIds: qlIds
                    });
                    action.setCallback(this,function(response){
                        var state = response.getState();
                        
                        if(state === 'SUCCESS'){
                            var response = response.getReturnValue();
                            if(response!=null && response != undefined)
                            {
                                for (let i = 0; i < products.configuredProducts.length; i++) {
                                    var nteMessage = '';
                                    for (let j = 0; j < response.length; j++) {
                                        
                                        if(products.configuredProducts[i].parentId == response[j].qlineId)
                                        {
                                            nteMessage += response[j].qlineDetails + ',';
                                            
                                            products.configuredProducts[i].nteWarnning = true;
                                            
                                        	//products.configuredProducts[i].procurementErrorMessage = products.configuredProducts[i].procurementErrorMessage + response[j].qlineDetails;
                                        }
                                    }
                                    var ntrSplitMessage = nteMessage.slice(0, -1);
                                    if(products.configuredProducts[i].nteWarnning == true){
                                      products.configuredProducts[i].nteWarnningMessage = 'NTE - Approval Needed for ' +ntrSplitMessage;
                                    }
                                }
                            }
                            cmp.set('v.serviceWrapper', products);
                            //SDT 33101
                            if(products.length) {
                                for (let i = 0; i < products.configuredProducts.length; i++) {
                                    console.log(JSON.stringify(products.configuredProducts[i]));
                                    
                                    var amendmentQuote = products.configuredProducts[i].quoteType;
                                    if(amendmentQuote=='Amendment'){
                                        cmp.set('v.IsAmendmentQuote', true);
                                    }}}//SDT 33101 end
                            // var showError = response.showMessage;
                            // if(showError){
                            //     cmp.set('v.ShowiconForNTW',true);
                            //     }   
                            // else{
                            //     cmp.set('v.ShowiconForNTW',false);
                            // }
                        }
                    });
                    $A.enqueueAction(action);
				 }
                console.log('userRole' + userRole);
                console.log('cmp.set(v.showConfigureProduct' + cmp.get('v.showConfigureProduct'));
                console.log('userRoleCombination' + userRoleCombination);
                    if(products.configuredProducts!= null &&products.configuredProducts!= undefined && products.configuredProducts.length ) {
                        //TCS-pkulkarn-SDT-44675-27-Jan-2025-Added below 2 lines
                        cmp.set('v.numRecords', products.configuredProducts.length);
                        cmp.set('v.quoteStatusForUI', products.configuredProducts[0].quoteStatus);
                    for (let i = 0; i < products.configuredProducts.length; i++) {
                        console.log('products.configuredProducts[i].quoteStatus' +products.configuredProducts[i].quoteStatus);
                        //SDT 42687
                        var IsAmendmentQuoteWithQuoteOnly = products.configuredProducts[i].quoteOnly;
                        cmp.set('v.IsAmendmentQuoteWithQuoteOnly', IsAmendmentQuoteWithQuoteOnly);
                        if((products.configuredProducts[i].quoteStatus == 'Product Configured' || products.configuredProducts[i].quoteStatus =='Cost Configured' || products.configuredProducts[i].quoteStatus =='Price Configured' || products.configuredProducts[i].quoteStatus == 'Draft') && userRoleCombination == true) {
                        cmp.set('v.showConfigureProduct', true)    
                               
                            //$A.get('e.force:refreshView').fire();    
                        }
                       // console.log('Products'+products);
                        else if(products.configuredProducts[i].quoteStatus == 'Product Configured' || products.configuredProducts[i].quoteStatus =='Cost Configured' && userRole =='Customer Experience Representative')
                        {
                         cmp.set('v.showConfigureProduct', true);  
                        
                          //$A.get('e.force:refreshView').fire();
                        }     
                        else if(products.configuredProducts[i].quoteStatus == 'Approved' || products.configuredProducts[i].quoteStatus =='Declined')  {
                            cmp.set('v.showConfigureProduct', false);   
                        }  
                        //SDT-31110 - disable button for Non New Service cases
                        //Used 0 index as will use- Case Type in help which is common for all products 
                        if(!helper.isNewService(cmp,products.configuredProducts[0]))
                        {
                            cmp.set('v.isUpdateAssetCase', true);
                        }
                        else{
                            cmp.set('v.isUpdateAssetCase', false);
                        }
                    }
                }
                   
  
            } else {
                cmp.set('v.showSpinner', false);
            };
        });
        //SDT 33101
        helper.getIfAmendmentQuote(cmp, event,helper);//commenting for SDT33101 reverse
        helper.getDisplayApprovalButton(cmp, event,helper);//commenting for SDT33101 reverse
        //SDT 33101 end
        
     //   helper.viewProductButton(cmp,event,helper)
        $A.enqueueAction(getWrapper);
        
    },
    showNTEErrorMsg : function(cmp, event) {
        
        // var action = cmp.get("c.showErrorWrapper");
        // var recordId = cmp.get("v.recordId");
		// var product = event.getSource().get('v.value');
        // console.log('The product Id line is: ' + product.parentId);
		// action.setParams({
		// 	quoteId: recordId,
        //     parentQLineId: product.parentId
		// });
		// action.setCallback(this,function(response){
		// 	var state = response.getState();
			
		// 	if(state === 'SUCCESS'){
        //     	var response = response.getReturnValue();
        //     	var showError = response.showMessage;
        //     	var showdetail = response.qlineDetails;
        //          var quoteStatus = response.quoteStatus;
        //         var message = 'NTE - Approval needed for ' +showdetail;
        //         /*if(quoteStatus == 'Price Configured'){
        //             var message = 'Approval is needed in order to proceed quote from “Submit for Approval" to "Approved for" '+showdetail;
        //         }
        //         else{
                    
        //         }*/
        //         if(showError){
        //             var toastEvent = $A.get('e.force:showToast');
		// 			toastEvent.setParams({
		// 						'title': 'Procured Status',
		// 						'message': message,
		// 						'type': 'error',
		// 						'mode': 'dismissible'
		// 					});
		// 			toastEvent.fire();
        //         }
				
		// 	}
		// });
		// 	$A.enqueueAction(action); 
		},
    
    getErrorMessage : function(cmp, event) {
        window.setTimeout($A.getCallback(function(){
        var showMessage = event.getSource().get('v.title');
		var toastEvent = $A.get('e.force:showToast');
		toastEvent.setParams({ 
                            'title': 'Procured Status',
                            'message': showMessage,
                            'type': 'error',
                            'mode': 'dismissible'
                        });
                               toastEvent.fire();
        }), 500);
        
        window.setTimeout($A.getCallback(function(){
        var showMessage2 = event.getSource().get('v.alternativeText');
        if(showMessage2 != '' && showMessage2 != null){
		var toastEvent = $A.get('e.force:showToast');
		toastEvent.setParams({ 
                            'title': 'Procured Status',
                            'message': showMessage2,
                            'type': 'error',
                            'mode': 'dismissible'
                        });
                               toastEvent.fire();
    }
            }), 500);
      

        
        // var action = cmp.get("c.showErrorWrapper");
        // var recordId = cmp.get("v.recordId");
		// var product = event.getSource().get('v.value');
        // console.log('The product Id line is: ' + product.parentId);
		// action.setParams({
		// 	quoteId: recordId
		// });
		// action.setCallback(this,function(response){
		// 	var state = response.getState();
			
		// 	if(state === 'SUCCESS'){
        //         var response = response.getReturnValue();
        //     	var showError = response.showMessage;
        //     	var showdetail = response.qlineDetails;
        //         var quoteStatus = response.quoteStatus;
        //         var message = 'NTE - Approval needed for ' +showdetail;

        //         /*if(quoteStatus == 'Price Configured'){
        //             var message = 'Approval is needed in order to proceed quote from “Submit for Approval" to "Approved for" '+showdetail;
        //         }
        //         else{
        //         }*/
        //         if(showError){
        //             var toastEvent = $A.get('e.force:showToast');
		// 			toastEvent.setParams({
		// 						'title': 'Procured Status',
		// 						'message': message,
		// 						'type': 'error',
		// 						'mode': 'dismissible'
		// 					});
		// 		toastEvent.fire();
        //         }
				
		// 	}
		// });
		// 	$A.enqueueAction(action); 
		},
    
    ViewDetails: function(cmp, event) {
        var product = event.getSource().get('v.value');
        var name = event.getSource().get('v.name');
        console.log('name==>'+name);
        cmp.set('v.componentType', name);
        cmp.set('v.selectedProduct', product);
        console.log(JSON.stringify(product));
        cmp.set('v.showModal', 'true');        
    },
    closeModal: function(cmp) {
        cmp.set('v.showModal', 'false');
        $A.get('e.force:refreshView').fire();
    },
    ViewLocationDetails: function(cmp, event) {
        var product = event.getSource().get('v.value');
        var name = event.getSource().get('v.name');
        cmp.set('v.componentType', name);
        console.log('The component type name we\'re pulling in is:' + name)
        cmp.set('v.selectedProduct', product);
        console.log('The product Id line is: ' + product.parentId);
        cmp.set('v.showLocationModal', 'true');        
    },
    SupplementalInstructions: function(component, event){
        var product = event.getSource().get('v.value');
        console.log('product==>'+JSON.stringify(product));
        component.set("v.parentQLineId",product.parentId);
        component.set("v.componentType",'SupplementModal');
        component.set('v.showSupplementModal', true); 
    },
    closeSupplementModal: function(component) {
        component.set("v.componentType",'');
        component.set('v.showSupplementModal', false);
        $A.get('e.force:refreshView').fire();
    },
    supplementChange : function(component, event){
        let changeValue = event.getParam("value");
        if(changeValue==false){
         	$A.get('e.force:refreshView').fire();  
            component.set("v.componentType",'');
        }
    },
    closeLocationModal: function(cmp) {
        cmp.set('v.showLocationModal', 'false');
        $A.get('e.force:refreshView').fire();
    },

    GetPrice: function(cmp, event) {
        var product = event.getSource().get('v.value');
        console.log(JSON.stringify(product))
        //cmp.set('v.QuoteID', (JSON.parse(JSON.stringify(product.quoteID))));
         cmp.set('v.QuoteID', (JSON.parse(JSON.stringify(product.parentId))));
         
        
        cmp.set('v.showGetPrice', 'true');        
    },
    closeGetPrice: function(cmp) {
        cmp.set('v.showGetPrice', 'false');
        $A.get('e.force:refreshView').fire();
    },
    addMore: function(cmp){
        cmp.set("v.showFavCompModal", true);
        var getAction = cmp.get('c.getAddProductId');
        var quoteId = cmp.get('v.quoteRecordId');
        console.log('quoteId>>'+quoteId);
        var goToCase = cmp.get('c.goToCase');
        goToCase.setParams({
            quoteID: quoteId
        });
        getAction.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
                    var addId = response.getReturnValue();
                    cmp.set('v.getAddProductId', addId);
                    goToCase.setCallback(this, function(response) {
                    if (response.getState() === 'SUCCESS') {
                            var caseId = response.getReturnValue();
                            cmp.set('v.caseId',caseId);
                    }});
                    $A.enqueueAction(goToCase);																															
                }});
        $A.enqueueAction(getAction);   
    },
    createViewOrder: function(cmp, event) {
        var getPickList = cmp.get('c.getPicklistSchema');
        getPickList.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
                var pickListValues = response.getReturnValue();  
                //console.log('pickListValues>>>'+JSON.stringify(pickListValues));
                cmp.set('v.servicePicklistValues',pickListValues); 
                
            }
        });
        $A.enqueueAction(getPickList);
        var product = event.getSource().get('v.value');
        console.log('138product==>'+JSON.stringify(product));
        //console.log(JSON.stringify(product.parentId));
        var productId= JSON.stringify(product.parentId).slice(1,-1);
        cmp.set('v.selectedProduct', productId);
        cmp.set('v.showOrderModal', true);
        //console.log('quoteStatus>>>'+JSON.stringify(product.quoteStatus).slice(1,-1));
        var qStatus= JSON.stringify(product.quoteStatus).slice(1,-1);
        cmp.set('v.quoteStatus',qStatus);
        
        if(qStatus == 'Draft' || qStatus == 'Product Configured' || qStatus == 'Cost Configured' || qStatus == 'Price Configured'){
            cmp.find('workOrderLwc1').openModal();
            setTimeout(()=>{
                cmp.find('workOrderLwc1').getChildProducts();
            },1000);
        } else {
            cmp.find('workOrderLwc2').openModal();
            setTimeout(()=>{
                cmp.find('workOrderLwc2').getChildProducts();
            },1000);
        }
    },
                
        
    onTabFocus: function(cmp, event) {
        $A.get('e.force:refreshView').fire();
    },
    //SDT-21060 start
    closeFinancialModel: function(cmp) {
        cmp.set('v.showFinancialDetailsModal', 'false');
        $A.get('e.force:refreshView').fire();
    },

    financialDetails: function(cmp, event){
        var product = event.getSource().get('v.value');
        cmp.set('v.selectedProduct', product);
        cmp.set('v.showFinancialDetailsModal', 'true');
    },
    //SDT-21060 end
	togglecChanges : function(cmp, event, helper){
        cmp.set("v.showSpinner",true);
        var iconName = event.getSource().get("v.iconName");
        var indx =  event.getSource().get("v.title");
        var serviceWrapper = cmp.get('v.serviceWrapper');
        if(iconName == 'utility:chevrondown'){
            event.getSource().set("v.iconName","utility:chevronup");
            serviceWrapper.configuredProducts[indx].showClassificationChanges= true;
        }else{
            event.getSource().set("v.iconName","utility:chevrondown");
            serviceWrapper.configuredProducts[indx].showClassificationChanges= false;
        }
        cmp.set('v.serviceWrapper',serviceWrapper);
        cmp.set("v.showSpinner",false);
    }//SDT33101
    ,ApproveQuoteOnlyOption: function (cmp, event, helper){
        var action = cmp.get("c.approveQuoteLine");
        var quoteId = cmp.get("v.recordId");
        var product = event.getSource().get('v.value');
        var qlIdToApprove = product.parentId;
        action.setParams({
            quoteId: quoteId,
            qlIdToApprove : qlIdToApprove
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                helper.refreshConfiguredProductComp(cmp);
            }
        });
        $A.enqueueAction(action);
    }
})