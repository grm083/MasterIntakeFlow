({
  doInit: function (component, event, helper) {
    helper.getPricingResponseStatus(component);
  //.catch(error => helper.displayError(error));
   // helper.getPricingResponseStatus(component);
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

//   acceptClick: function (component, event, helper) {
//    helper.acceptPricing(component);
// },
// acceptandProcureClick: function (component, event, helper) {
//   helper.acceptPricing1(component);
// },
  // procureClick: function (component, event, helper) {
  //   // Close the action panel
  //   var resultsToast = $A.get("e.force:showToast");
  //   resultsToast.setParams({
  //     title: "Procure Manually",
  //     message: "Submited for Procure Manually.",
  //     type: "success"
  //   });
  //   resultsToast.fire();
  //   var dismissActionPanel = $A.get("e.force:closeQuickAction");
  //   dismissActionPanel.fire();
  // },

  // returnToDraftClick: function (component) {
  //   var quoteID = component.get("v.recordId");
  //   var action = component.get("c.UpdateQuoteStatus");
  //   action.setParams({ quoteID: quoteID , quoteStatus:'Draft'});
  //   action.setCallback(this, function (response) {
  //     var state = response.getState();

  //     if (state === "SUCCESS") {
  //       var resultsToast = $A.get("e.force:showToast");
  //       resultsToast.setParams({
  //         title: "Saved",
  //         message: "Status changed to Draft Succesfully",
  //         type: "success"
  //       });
  //       resultsToast.fire();

  //     } else {
  //       var resultsToast = $A.get("e.force:showToast");
  //       resultsToast.setParams({
  //         title: "Failed",
  //         message: "Status changed failed",
  //         type: "error"
  //       });
  //       resultsToast.fire();
        
  //     }
  //     $A.get("e.force:refreshView").fire();
  //     var dismissActionPanel = $A.get("e.force:closeQuickAction");
  //     dismissActionPanel.fire();
  //   });
  //   $A.enqueueAction(action);

    
  // },
//   gotoURL : function (component, event, helper) {
//     var urlEvent = $A.get("e.force:navigateToURL");
    
//     alert(component.get('!v.GPURL'));

//     urlEvent.setParams({
//       "url": "/006/o"
//     });
//     urlEvent.fire();
// }
 
    /*gotoURL:function(component,event,helper){
        var evt = $A.get("e.force:navigateToComponent");
        var quoteID = component.get("v.recordId");
        console.log('evt'+evt);
        evt.setParams({
            componentDef: "skbteqforce:GetPrice",
            componentAttributes :{"quoteID": quoteID }
        });
       
    evt.fire();
    }*/

});