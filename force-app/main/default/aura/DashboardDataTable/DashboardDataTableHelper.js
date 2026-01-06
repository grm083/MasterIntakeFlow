({
    fetchPicklistValues: function(component,data ,helper) {
        // call the server side function  
        var wrappers=new Array();
        
        var StoreResponse = component.get("v.dependentFieldMap");
        
        // once set #StoreResponse to depnedentFieldMap attribute 
        component.set("v.dependentFieldMap",StoreResponse);
        
        // create a empty array for store map keys(@@--->which is controller picklist values) 
        var listOfkeys = []; // for store all map keys (controller picklist values)
        var ControllerField = []; // for store controller picklist value to set on lightning:select. 
        
        // play a for loop on Return map 
        // and fill the all map key on listOfkeys variable.
        for (var singlekey in StoreResponse) {
            listOfkeys.push(singlekey);
        }
        
        //set the controller field value for lightning:select
        if (listOfkeys != undefined && listOfkeys.length > 0) {
            ControllerField.push('--- None ---');
        }
        
        for (var i = 0; i < listOfkeys.length; i++) {
            ControllerField.push(listOfkeys[i]);
        }  
        // set the ControllerField variable values to country(controller picklist field)
        component.set("v.listControllingValues", ControllerField);
        
        for (var idx=0; idx<data.length; idx++) {
            var process = '';
            if(data[idx].Process != undefined){
                process = data[idx].Process ;
                this.onControllerField(component, event,process);
                var wrapper = { 'acc' : data[idx],
                               'listDependingValues' : component.get("v.listDependingValues"),
                               'Comment' : data[idx].Comments,
                               'Outcome' : data[idx].Outcome ,
                               'ServiceDate' : data[idx].ServiceDate 
                              };
                wrappers.push(wrapper);
            }
            else{
                process = data[idx].Process ;
                this.onControllerField(component, event,process);
                wrappers.push(data[idx]);
            }
        }
        //component.set('v.wrappers', wrappers);
        component.set('v.finalDataList', wrappers);
    },
    
    fetchDepValues: function(component, ListOfDependentFields) {
        // create a empty array var for store dependent picklist values for controller field  
        var dependentFields = [];
        dependentFields.push('--- None ---');
        for (var i = 0; i < ListOfDependentFields.length; i++) {
            dependentFields.push(ListOfDependentFields[i]);
        }
        // set the dependentFields variable values to store(dependent picklist field) on lightning:select
        component.set("v.listDependingValues", dependentFields);
        
    },
    onControllerField: function(component, event, ctrlvalue) {     
        var controllerValueKey = ctrlvalue ; // get selected controller field value
        var depnedentFieldMap = component.get("v.dependentFieldMap");
        
        if (controllerValueKey != '--- None ---') {
            
            var ListOfDependentFields = depnedentFieldMap[controllerValueKey];
            
            if(ListOfDependentFields != undefined && ListOfDependentFields.length > 0){
                component.set("v.bDisabledDependentFld" , false);  
                this.fetchDepValues(component, ListOfDependentFields);    
            }else{
                component.set("v.bDisabledDependentFld" , true); 
                component.set("v.listDependingValues", ['--- None ---']);
            }  
            
        } else {
            component.set("v.listDependingValues", ['--- None ---']);
            component.set("v.bDisabledDependentFld" , true);
        }
    }
    
})