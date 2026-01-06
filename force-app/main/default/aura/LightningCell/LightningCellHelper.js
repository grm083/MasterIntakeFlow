({
	displayField : function(component, event, helper) {
		var record = component.get("v.record");
        var field = component.get("v.field");

        component.set("v.cellValue", record[field.name]);
        if(field.type == 'STRING' || field.type == 'PICKLIST')
            component.set("v.isTextField", true);
        else if(field.type == 'DATE'){
        	component.set("v.isDateField", true);
        }
        else if(field.type == 'DATETIME'){
        	component.set("v.isDateTimeField", true);
        }
        else if(field.type == 'CURRENCY'){
        	component.set("v.isCurrencyField", true);
        }
        else if(field.type == 'REFERENCE'){
        	component.set("v.isReferenceField", true);
            var relationShipName = '';
            if(field.name.indexOf('__c') == -1) {
                relationShipName = field.name.substring(0, field.name.indexOf('Id'));
            }
            else {
                relationShipName = field.name.substring(0, field.name.indexOf('__c')) + '__r';
            }
            console.log('field.relatedObject'+field.referenceObject);
            if(field.referenceObject == 'Case'){
                console.log('relationShipName'+relationShipName);
                console.log('record'+record[relationShipName]);
                component.set("v.cellLabel", record[relationShipName].CaseNumber);
            }else {
            	component.set("v.cellLabel", record[relationShipName].Name);
            }
        }
	}
})