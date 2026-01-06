({
    doInit: function (component, event, helper) {
      helper.getPricingResponseStatus(component);
      //added for 31114
      helper.getPricingResponseAssetError(component);
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
  });