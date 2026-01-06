({
  getPriceOnlyReasonList: function (cmp){
    var action = cmp.get("c.getPriceOnlyReasonList");
    action.setCallback(this, function (response) {
      var state = response.getState();
      cmp.set("v.IsShowPicklist", true);
      if (state === "SUCCESS") {
        var wrapper = response.getReturnValue();
         if(wrapper){
          var ccs = wrapper;
          var requestReasonlst = [];
          for (var entry in ccs.PriceOnlyReason) {
            requestReasonlst.push({value:ccs.PriceOnlyReason[entry], key:entry});
          }
          cmp.set('v.requestReason', requestReasonlst);
          // window.setTimeout(
          //     $A.getCallback(function() {
          //       cmp.find('ccPicklist').set('v.value', ccs.PriceOnlyReason);
          //     }));
        }
      }
    });
    $A.enqueueAction(action);
  },

  getPricingOnlyResponseStatus: function (component) {
    component.set("v.NoData", true);
    var count = 0;
    var greenCount = 0;
    var quoteLineID = component.get("v.recordId");
    component.set("v.loadingSpinner", true);
    var action = component.get("c.getQuotePriceOnlyDetail");

    action.setParams({ quoteLineID: quoteLineID });

    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var wrapper = response.getReturnValue();
        console.log("bundle @@@@@" + JSON.stringify(wrapper));
        if (wrapper) {
          // check to make sure the list isn't null
          if (wrapper != null) {
            component.set("v.QuotePringRequestList", wrapper);
            // get the length of the list (in this case number of rows/records)
            var listLength = wrapper.length;
            // loop through the list of records and stop once you are at the list length
            for (var i = 0; i < listLength; i++) {
              component.set("v.activesection", wrapper[0].BundleID);
              // below assumes the object has a field called 'field__c'
              if (wrapper[i].Problem) {
                count = count + 1;
              }
              if (wrapper[i].ProductDetails) {
                //Comment Code for SDT-31291 : Start
                // if (wrapper[i].ProductDetails.SubstituteMessage != null) 
                // {
                //   component.set("v.SubstituteMsg",wrapper[i].ProductDetails.SubstituteMessage);
                // }

                var t = wrapper[i].ProductDetails;
                if (t.GreenPages) {
                  count = count + 1;
                }
              }
            }
            if (listLength == count) {
              component.set("v.IsPricingAvailable", true);
            }

            $A.get("e.force:refreshView").fire();
            component.set("v.loadingSpinner", false);
            component.set("v.NoData", false);
          }
        }
        var refreshEvent = $A.get("e.c:AssetPriceRefreshEvent");
        refreshEvent.setParams({ recordId: quoteLineID });
        window.setTimeout(function () {
          refreshEvent.fire();
        }, 10000);
      } else {
        var resultsToast = $A.get("e.force:showToast");
        resultsToast.setParams({
          title: "Data not received",
          message: "In Progress/Not get API response.",
          type: "info",
        });
        resultsToast.fire();
        component.set("v.NoData", true);
      }
      component.set("v.loadingSpinner", false);
    });

    $A.enqueueAction(action);
  },

  acceptPricing: function (component) {
    var quoteID = component.get("v.recordId");
    var wrapper = component.get("v.QuotePringRequestList");
    var action = component.get("c.acceptQLIPricingRequest");
    action.setParams({ qpWrapper: wrapper, isPriceOnly: true });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var resultsToast = $A.get("e.force:showToast");
        resultsToast.setParams({
          title: "Source Code Reminder",
          message: "If a source code is available for this manual cost, please ensure that you have set the source code on each appropriate line",
          type: "info",
          mode:'default', 
        });
        resultsToast.fire();
        var CloseModalEvent = component.getEvent("closeGetPrice");
        CloseModalEvent.setParams({
          closeGetPrice: "false",
        });
        CloseModalEvent.fire();
      } else {
        var resultsToast = $A.get("e.force:showToast");
        resultsToast.setParams({
          title: "Failed",
          message: "Pricing Failed",
          type: "Failed",
        });
        resultsToast.fire();
      }
      $A.get("e.force:refreshView").fire();
      var dismissActionPanel = $A.get("e.force:closeQuickAction");
      dismissActionPanel.fire();
      
    });
    $A.enqueueAction(action);
  },
});