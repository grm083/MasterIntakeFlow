({	
    doInit : function(component, event, helper) {
        var caseURL = new String(window.location); 
        var caseURLSplit = caseURL;
        var splitArray;
              
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
        var accId = event.currentTarget.dataset.record;       
        component.set("v.selectedVendorAccountId", accId);
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
    
    SaveSelection : function(component, event, helper){  
        helper.updateCaseforVendor(component, event,helper, component.get("v.selectedVendorAccountId"), component.get("v.recordId"));        
    },
})