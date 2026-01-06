({ 
    doInit: function (cmp, event, helper) {
        cmp.set("v.showDataTable",false );
        cmp.set("v.showSpinnerOnPageChange",true );
        cmp.set('v.gridColumns', [
            {label: 'ASSET NAME', fieldName: 'assName', type: 'url',initialWidth: 200, typeAttributes: { label: { fieldName: 'Name' }, target: '_self', tooltip: { fieldName: 'Name' } } },
            {label: 'SID',fieldName: 'Acorn_SID__c',  type: 'text',initialWidth: 100  },
            {label: 'COST', fieldName: 'Cost__c', type: 'currency', typeAttributes: { currencyCode: 'USD',currencyDisplayAs: "code" },initialWidth: 100},
            {label: 'PRICE', fieldName: 'Price__c', type: 'currency', typeAttributes: { currencyCode: 'USD',currencyDisplayAs: "code" },initialWidth: 100},
            {label: 'MATERIAL TYPE',fieldName: 'Material_Type__c',  type: 'text',initialWidth: 100  },
            {label: 'SERVICE TYPE',fieldName: 'Service_Type__c',  type: 'text',initialWidth: 100  },
            {label: 'DURATION',fieldName: 'Duration__c',  type: 'text',initialWidth: 100  },
            {label: 'OCCURRENCE TYPE',fieldName: 'Occurrence_Type__c',  type: 'text',initialWidth: 100  },
            {label: 'SCHEDULE',fieldName: 'Schedule__c',  type: 'text',initialWidth: 100  },
            {label: 'HAS XPU',fieldName: 'Has_Extra_Pickup__c',  type: 'boolean',initialWidth: 100  },
            {label: 'QUANTITY',fieldName: 'Quantity__c',  type: 'number',initialWidth: 100  },
            {label: 'VENDOR NAME', fieldName: 'vendorRecordId', type: 'url',initialWidth: 100, typeAttributes: { label: { fieldName: 'vendorName' }, target: '_self', tooltip: { fieldName: 'vendorName' } } },
            {label: 'CONTAINER POSITION',fieldName: 'Container_Position__c',  type: 'text',initialWidth: 100  },
            {label: 'VENDOR ID',fieldName: 'Vendor_ID__c',  type: 'text',initialWidth: 100  },
            {label: 'S-CODE',fieldName: 'Sensitivity_Code__c',  type: 'text',initialWidth: 100  },
             {label: 'START DATE',fieldName: 'Start_Date__c',  type: 'date',initialWidth: 100  },
            {label: 'END DATE',fieldName: 'End_Date__c',  type: 'date',initialWidth: 100  },
            {label: 'VENDOR ACCOUNT NAME',fieldName: 'Vendor_Account_Number__c',  type: 'text',initialWidth: 100  },
            {label: 'MAS COMPANY # - ACCOUNT #',fieldName: 'MAS_Company_Account_Number__c',  type: 'text',initialWidth: 100  },
            {label: 'MAS UNIQUE #',fieldName: 'MAS_Unique_Text__c',  type: 'text',initialWidth: 100  },
            {label: 'MAS LIBRARY',fieldName: 'MAS_Library__c',  type: 'text',initialWidth: 100  },
            {label: 'CATEGORY',fieldName: 'Category__c',  type: 'date',initialWidth: 100  },
            {label: 'EQUIPMENT OWNER',fieldName: 'Equipment_Owner__c',  type: 'text',initialWidth: 100  },
            {label: 'PROJECT',fieldName: 'Active__c',  type: 'boolean',initialWidth: 100  },
        ]);
             cmp.set("v.startPage",0);
            cmp.set("v.recordCount",0 );
            helper.getAssetRecords(cmp);
            },
            next: function (cmp, event, helper) {
            helper.next(cmp, event);
            },
            previous: function (cmp, event, helper) {
            helper.previous(cmp, event);
            }
            })