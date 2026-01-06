({
    doInit : function(component, event, helper) {
        helper.getTableFieldSet(component, event, helper);
    },
    
    getTableFieldSet : function(component, event, helper) {
        var action = component.get("c.getFieldSet");
        action.setParams({
            sObjectName: component.get("v.sObjectName"),
            fieldSetName: component.get("v.fieldSetName")
        });
        
        action.setCallback(this, function(response) {
            var fieldSetObj = JSON.parse(response.getReturnValue());
            component.set("v.fieldSetValues", fieldSetObj);
            //Call helper method to fetch the records
            helper.getTableRows(component, event, helper);
        })
        $A.enqueueAction(action);
    },
    
    getTableRows : function(component, event, helper){
        var action = component.get("c.getRecords");
        var fieldSetValues = component.get("v.fieldSetValues");
        var setfieldNames = new Set();
        for(var c=0, clang=fieldSetValues.length; c<clang; c++){             
            if(!setfieldNames.has(fieldSetValues[c].name)) {                 
                
                setfieldNames.add(fieldSetValues[c].name);                   
                if(fieldSetValues[c].type == 'REFERENCE') {                     
                    if(fieldSetValues[c].name.indexOf('__c') == -1) {                     	
                        setfieldNames.add(fieldSetValues[c].name.substring(0, fieldSetValues[c].name.indexOf('Id')) + '.Name'); 
                    }else if(fieldSetValues[c].referenceObject == 'Case'){                     
                        setfieldNames.add(fieldSetValues[c].name.substring(0, fieldSetValues[c].name.indexOf('__c')) + '__r.CaseNumber'); 
                    }else {
                        setfieldNames.add(fieldSetValues[c].name.substring(0, fieldSetValues[c].name.indexOf('__c')) + '__r.Name'); 
                    }                 
                }             
            }         
        }         
        var arrfieldNames = [];         
        setfieldNames.forEach(v => arrfieldNames.push(v));
        console.log('arrfieldNames'+arrfieldNames);
        console.log('parentRecordId'+component.get("v.parentRecordId"));
        action.setParams({
            sObjectName: component.get("v.sObjectName"),
            parentFieldName: component.get("v.parentFieldName"),
            parentRecordId: component.get("v.parentRecordId"),
            fieldNameJson: JSON.stringify(arrfieldNames)
        });
        action.setCallback(this, function(response) {
            var list = JSON.parse(response.getReturnValue());
            console.log(list);
            component.set("v.tableRecords", list);
        })
        $A.enqueueAction(action);
    },
    
    createTableRows : function(component, event, helper){
        
    }
})