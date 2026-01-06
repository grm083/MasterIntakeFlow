({	
    doInit : function(component, event, helper) {
     	//component.set("v.selectedAccountFilter",true);
        var caseURL = new String(window.location); 
        var caseURLSplit = caseURL;
        var splitArray;
        /*if(caseURLSplit.includes("%2F")){
        	splitArray = caseURLSplit.split("%2F"); 
            component.set("v.recordId",splitArray[4]);
        }else{
        	splitArray = caseURLSplit.split("/");	
            component.set("v.recordId",splitArray[6]);
        }  */        
    },
    
    searchEvents: function(component, event, helper) {        
        if(event.which == 13){
            var a = component.get('c.Search');
        	$A.enqueueAction(a);			
        }        
    },

    Search: function(component, event, helper) {
        
        var searchField = component.find('searchField');
        var isValueMissing = searchField.get('v.validity').valueMissing;
        
        var searchKey= component.get("v.searchKeyword");
        var previousSearch = component.get("v.previousSearchKeyword");
        var pageNumber;
        var pageSize;
        
        if(typeof previousSearch == "undefined" || searchKey != previousSearch){
            pageNumber = 1;            
        }else{
        	pageNumber = component.get("v.PageNumber");          	   
        }
        
        pageSize = component.find("pageSize").get("v.value"); 
        
        // if value is missing show error message and focus on field
        if(isValueMissing) {
            searchField.showHelpMessageIfInvalid();
            searchField.focus();
        }else{
          // else call helper function 
            helper.SearchHelper(component, event, pageNumber, pageSize);
        }
    }, 
    
    handleNext: function(component, event, helper) {
        var pageNumber = component.get("v.PageNumber");  
        var pageSize = component.find("pageSize").get("v.value");
        pageNumber++;
        helper.SearchHelper(component, event, pageNumber, pageSize);
    },
     
    handlePrev: function(component, event, helper) {
        var pageNumber = component.get("v.PageNumber");  
        var pageSize = component.find("pageSize").get("v.value");
        pageNumber--;
        helper.SearchHelper(component, event, pageNumber, pageSize);
    },
     
    onSelectChange: function(component, event, helper) {
        var page = 1
        var pageSize = component.find("pageSize").get("v.value");
        helper.SearchHelper(component, event, page, pageSize);
    },
    
    divClick : function(component, event, helper) {
        var selectedDiv= '';
        selectedDiv= component.get("v.selectedLocationAccountId");
		var totalRecs = component.get("v.TotalRecords");
        
        if(typeof selectedDiv != "undefined"){
        	var recordhide = selectedDiv + 'hide';   
            var elementsHide = document.getElementById(recordhide);
            if(elementsHide != null){
            	elementsHide.style.backgroundColor = 'white';   
            }        	
        }
        
        var selectedSection = event.currentTarget;
        var index = selectedSection.dataset.index;
        var record = selectedSection.dataset.record;
        
        var recordshow = record + 'show';
        var recordhide = record + 'hide';
            
        var elements = document.getElementById(record);
        elements.style.display = 'block';
        
        var elementsShow = document.getElementById(recordshow);
        elementsShow.style.display = 'none';
        
        var elementsHide = document.getElementById(recordhide);
        elementsHide.style.display = 'block';
		elementsHide.style.backgroundColor = 'HoneyDew';
        component.set("v.selectedText",true);
        
        
        component.set("v.selectedLocationAccountId",record);
        
        var wrapperList= component.get("v.AccountAssetWrapperList");
        
        for(var i=0; i < wrapperList.length; i++){
            var accObj = wrapperList[i].objAcc;
            if(accObj.Id == record){
                console.log(' accObj '+ JSON.stringify(accObj));
            	component.set("v.selectedLocationAccountName",accObj.Id);
                component.set("v.selectedClientAccountName",accObj.Parent.Id);
                //modified for Dev
                component.set("v.selectedClientAccountId",accObj.Parent.Id);                
            }
        }
        component.set("v.showSaveButton",true);
    }, 
    
    divHide : function(component, event, helper) {
        
        var selectedSection = event.currentTarget;
        var index = selectedSection.dataset.index;
        var record = selectedSection.dataset.record;
        
        var recordshow = record + 'show';
        var recordhide = record + 'hide';
        
        var elements = document.getElementById(record);
        elements.style.display = 'none';   
        
        var elementsShow = document.getElementById(recordshow);
        elementsShow.style.display = 'block';
        
        var elementsHide = document.getElementById(recordhide);
        elementsHide.style.display = 'none';
        
    },
    
    onRadioChange : function(component, event, helper) {
        var id_str = event.currentTarget.dataset.value;
        var index = event.currentTarget.dataset.record;
    	//var selectedAsset = event.getSource().get("v.text");
    	//component.set('v.saveEnabled',false);
        var assetIds = component.get('v.selectedAssetId');
        if(assetIds.includes(id_str)){
            var index = assetIds.indexOf(id_str);
            if (index > -1) {
    			assetIds.splice(index, 1);
			}
        }else{
        assetIds.push(id_str);
        }
        component.set('v.selectedAssetId',assetIds);
        
        var wrapperList = component.get("v.AccountAssetWrapperList");
        var selectedAssetId= component.get("v.selectedAssetId");
        var selectedAccountId= component.get("v.selectedLocationAccountId");

        var i;
        for (i = 0; i < wrapperList.length; i++) { 
        	console.log(i);
        	var accountObj = wrapperList[i];
            var j;
            var assetListObj= accountObj.assetList;
            for(j = 0; j < assetListObj.length; j++){
                var assetObj = assetListObj[j];
                //console.log('*** assetObj '+ assetListObj.length + ' '+ JSON.stringify(assetObj));
                var k;
                for(k = 0; k < selectedAssetId.length; k++){
                if(assetObj.Id == selectedAssetId[k]){
                    component.set("v.selectedAssetName",assetObj.Name);  
                    component.set("v.selectedLocationAccountName",accountObj.objAcc.Name);
                    component.set("v.selectedClientAccountName",accountObj.objAcc.Parent.Name);
                    component.set("v.selectedClientAccountId",accountObj.objAcc.Parent.Id);                    
               	 }
                }  
            }   	            
        }
       if(assetIds == null || assetIds == ''){
            //component.set('v.saveEnabled',true);
            component.set("v.SelectionDetails",false);
        }else{
             component.set("v.SelectionDetails",true);
        }
        
    },
    
    /*selectFilterOfAccount : function(component, event, helper) {
        var selectedFilter = event.getSource().get("v.text");
        if(selectedFilter=='ActiveAccounts'){
            component.set("v.selectedAccountFilter",true);
        }else{
        	component.set("v.selectedAccountFilter",false);    
        }
    }, */
    
    SaveSelection : function(component, event, helper){  
        //alert(' client '+ component.get("v.selectedClientAccountId") + ' location ' + component.get("v.selectedLocationAccountId") + ' Asset ' + component.get("v.selectedAssetId") + ' case id ' + component.get("v.recordId"));
        helper.updateCaseforLocation(component, event,helper, component.get("v.selectedClientAccountId"), component.get("v.selectedLocationAccountId"), component.get("v.selectedAssetId"), component.get("v.recordId"));        
    },

    handleMouseHoverOnCard:function(component, event, helper){ 
      //  var cmpTarget = component.find('tablerow');
		//	console.log(cmpTarget);
     //  $A.util.addClass(cmpTarget, 'currentRow');
			
    },
   handleMouseOutOnCard:function(component, event, helper){ 
      // var cmpTarget = component.find('tablerow');

      // $A.util.removeClass(cmpTarget, 'currentRow');
   }
})