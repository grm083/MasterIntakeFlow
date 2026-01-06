({
    doInit: function (component, event, helper) {
      helper.getPriceOnlyReasonList(component);
    },
    navigateTosObject : function(component, event, helper) {
      var recordId = event.currentTarget.dataset.id;
      var sObectEvent = $A.get("e.force:navigateToSObject");
      sObectEvent.setParams({
          "recordId": recordId,
          "slideDevName": "detail"
      });
      sObectEvent.fire();
  },
  
    acceptClick: function (component, event, helper) {
     helper.acceptPricing(component);
  },
  refreshClick: function (component, event, helper) {
    helper.getPricingOnlyResponseStatus(component);
 },

 saveCC: function (component, event, helper) {
  var selectedValue = component.get("v.selectedValue");
  var text = component.get("v.text");
  if(selectedValue != '-1')
  {
    if((typeof text === undefined || text == '')  && selectedValue =='OTH' ){
        var resultsToast = $A.get("e.force:showToast");
        resultsToast.setParams({
          "type":"error",
            "title": "Price Only Request",
            "message": "Reason description is required."
        });
        resultsToast.fire();
      }
      else {
        component.set("v.loadingSpinner", true);
        component.set("v.NoData", true);
        var quoteLineID = component.get("v.recordId");
        component.set("v.IsShowPicklist", false);
        var action = component.get("c.CreatePricingOnlyRequest");
        if(text == undefined)
        {
          text = '';
        }
        action.setParams({ quoteLineID: quoteLineID, reasonValue: selectedValue, reasonDescription: text });

        action.setCallback(this, function (response) {
          var state = response.getState();
          if (state === "SUCCESS") {
            component.set("v.RefreshButton", true);

              window.setTimeout(function () {
                helper.getPricingOnlyResponseStatus(component);
              }, 5000);
          } else {
            var CloseModalEvent = component.getEvent("closeGetPrice");
            CloseModalEvent.setParams({
              closeGetPrice: "false",
            });
            CloseModalEvent.fire();
            var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({
              title: "Price Only Request",
              message: "Failed to call Price only API due to following reason: Is a closed market or service have already price value or Cost UOM for pickup is not Month Type.",
              type: "error",
              duration: 10000,
            });
            resultsToast.fire();
            component.set("v.NoData", true);
            component.set("v.loadingSpinner", false);
          }
          
        });

        $A.enqueueAction(action);
        }
      }
      else
      {
        var resultsToast = $A.get("e.force:showToast");
        resultsToast.setParams({
          "type":"error",
            "title": "Price Only Request",
            "message": "Please select reason."
        });
        resultsToast.fire();        
      }
    },
});