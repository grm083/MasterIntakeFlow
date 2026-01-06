({
   doInit : function(component, event, helper) {
       component.set("v.isLoading",true);
       component.set('v.columns', [
           {label: 'Action', fieldName: 'Action__c', type: 'text'},
           {label: 'Quote Line', fieldName: 'Quote_Line_Number__c', type: 'text'},
           {label: 'Product Name', fieldName: 'Product_Name__c', type: 'text'},
           //{label: 'Date/Time', fieldName: 'Timestamp__c', type: 'date'},
           {label: 'Quote', fieldName: 'Quote_Number__c', type: 'text'},
           {label: 'Modified By', fieldName: 'User_Name__c', type: 'Text'},
           {label: 'Date', fieldName: 'CreatedDate', type: 'date',
                                                                    typeAttributes: {
                                                                           day: '2-digit',
                                                                           month: '2-digit',
                                                                           year: 'numeric',
                                                                           hour: '2-digit',
                                                                           minute: '2-digit',
                                                                           second: '2-digit',
                                                                           hour12: true
                                                                       }
           }
           /*{label: 'Details', fieldName: 'Details__c', type: 'text'}*/
          
       ]);
       
       helper.fetchQuoteLineChanges(component);
       
   }
})