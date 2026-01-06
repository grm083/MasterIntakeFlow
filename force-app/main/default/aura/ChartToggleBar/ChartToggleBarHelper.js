({
	dynamicColors : function() {
		 var r = Math.floor(Math.random() * 255);
        var g = Math.floor(Math.random() * 255);
        var b = Math.floor(Math.random() * 255);
        return "rgb(" + r + "," + g + "," + b + ")";
	},
   
    // sort a dataset
    generateChart: function (component,dataset,datalabel,xAxisLimit) {
      if(xAxisLimit == 1){
            xAxisLimit = 2 ;
        }
        if(xAxisLimit == 0){
            xAxisLimit = 2 ;
        }
        new Highcharts.Chart({
            chart: {
        type: 'bar',
        marginLeft: 150,
		renderTo: component.find("chart").getElement(),
    },
    title: {
        text: 'Task Count'
    },
    subtitle: {
        text: ''
    },
    colors: [
                "rgb(122, 184, 0)"
            ],
    xAxis: {
        type: 'category',
        title: {
            text: null
        },
        min: 0,
        max: 4,
        categories: datalabel,
        scrollbar: {
            enabled: true
        },
        tickLength: 0
    },
    yAxis: {
        min: 0,
        max: xAxisLimit,
        
        title: {
            text: 'Count of Tasks',
            align: 'high'
        }
    },
    plotOptions: {
        bar: {
            dataLabels: {
                enabled: true
            }
        },
        series: {
                cursor: 'pointer',
                point: {
                    events: {
                        click: function() {
                            var cmpEvent = component.getEvent("cmpEvent");
        cmpEvent.setParams({
            "AccountName" : this.category,
            "UserDropdownValue" : ""
        });
        cmpEvent.fire();
                        }
                    }
                }
            }
    },
    legend: {
        enabled: false
    },
    credits: {
        enabled: false
    },
    series: [{
        name: 'Count of Tasks',
        data: dataset 
    }]
});
    
        return component.Chart ;
    },
     showSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
     
    hideSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    },
    sortData : function(component,fieldName,sortDirection){
        var data = component.get("v.accountColumns");
        //function to return the value stored in the field
        var key = function(a) { return a[fieldName]; }
        var reverse = sortDirection == 'asc' ? 1: -1;
        
            data.sort(function(a,b){ 
                var a = key(a) ? key(a).toLowerCase() : '';//To handle null values , uppercase records during sorting
                var b = key(b) ? key(b).toLowerCase() : '';
                return reverse * ((a>b) - (b>a));
            });    
        
        //set sorted data to accountData attribute
        component.set("v.accountColumns",data);
    }
})