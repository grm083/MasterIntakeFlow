({
	fetchData : function(cmp,rows) {
        cmp.set('v.spinner', true);
		return new Promise($A.getCallback(function(resolve, reject) {
            var currentDatatemp = cmp.get('c.getSearchedEmailMessages');
            var counts = cmp.get("v.data").length;
            currentDatatemp.setParams({
                "limits": cmp.get("v.initialRows"),
                "offsets": counts,
                'searchKeyWord': cmp.get("v.searchKeyword"),
                'fromDate' : cmp.get("v.FromDate"),
                'toDate' : cmp.get("v.ToDate"),
                'subject' : cmp.get("v.subject")
            });
            currentDatatemp.setCallback(this, function(a) {
                resolve(a.getReturnValue());
                var records = a.getReturnValue();
                console.log(records);
                	records.forEach(function(record){
                    		record.linkSubject = '/'+record.Id;
                        if(record.Parent){
                        	record.CaseLink = '/'+record.ParentId;
                        	record.CaseNumber = record.Parent.CaseNumber;
                            record.CaseType = record.Parent.Case_Type__c;
                            record.CaseSubType = record.Parent.Case_Sub_Type__c;
                            record.CaseLocation = record.Parent.Location_Code__c;
                            record.CaseSubStatus = record.Parent.Case_Sub_Status__c;
                            record.CaseStatus = record.Parent.Status;
                        }
                		});
                var countstemps = cmp.get("v.data").length
                countstemps = countstemps+cmp.get("v.initialRows");
                cmp.set("v.currentCount",countstemps);
                cmp.set('v.spinner', false);
                
            });
            $A.enqueueAction(currentDatatemp);
            
            
        })); 
	},
     getData : function(component) {
        component.set('v.spinner', true);
        var action = component.get("c.getSearchedEmailMessages");
        action.setParams({
            "limits": component.get("v.initialRows"),
            "offsets": 0,
            'searchKeyWord': component.get("v.searchKeyword"),
            'fromDate' : component.get("v.FromDate"),
            'toDate' : component.get("v.ToDate"),
            'subject' : component.get("v.subject")
        });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var records = response.getReturnValue();
                console.log(records);
                	records.forEach(function(record){
                    		record.linkSubject = '/'+record.Id;
                        if(record.Parent){
                        	record.CaseLink = '/'+record.ParentId;
                        	record.CaseNumber = record.Parent.CaseNumber;
                            record.CaseType = record.Parent.Case_Type__c;
                            record.CaseSubType = record.Parent.Case_Sub_Type__c;
                            record.CaseLocation = record.Parent.Location_Code__c;
                            record.CaseSubStatus = record.Parent.Case_Sub_Status__c;
                            record.CaseStatus = record.Parent.Status;
                        }
                		});
            component.set("v.data", response.getReturnValue());
            component.set("v.currentCount", component.get("v.initialRows"));
            }
           component.set('v.spinner', false); 
        });
        $A.enqueueAction(action);
    },
    getCount: function(cmp) {
        var action = cmp.get("c.getSearchedEmailMessagesCount");
        action.setParams({
			 'searchKeyWord': cmp.get("v.searchKeyword"),
            'fromDate' : cmp.get("v.FromDate"),
            'toDate' : cmp.get("v.ToDate"),
            'subject' : cmp.get("v.subject")
        });
        action.setCallback(this, function(response) {
			if (response.getState() === "SUCCESS") {
                console.log('total records'+ response.getReturnValue());
            cmp.set("v.totalNumberOfRows",response.getReturnValue());
            }
                
        });
        $A.enqueueAction(action);
    },
})