({
  getPricingResponseStatus: function (component) {
    component.set("v.NoData",false );
    var count =0;
    var greenCount =0;
    var quoteID = component.get("v.recordId");
    component.set("v.loadingSpinner", true);
    var action = component.get("c.getQuotePricingDetail");
    action.setParams({ quoteID: quoteID });
    
     action.setCallback(this, function (response) {
      var state = response.getState();

      if (state === "SUCCESS") {
        var wrapper = response.getReturnValue();
        console.log("bundle @@@@@"+JSON.stringify(wrapper));
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
                count = count +1;
               // component.set("v.ErrorMsg", wrapper[i].Problem);
              }
             
              if(wrapper[i].ProductDetails){
                  //Comment Code for SDT-31291 : Start
                  // if (wrapper[i].ProductDetails.SubstituteMessage != null) 
                  // {
                  //   component.set("v.SubstituteMsg",wrapper[i].ProductDetails.SubstituteMessage);
                  // }
                  
              
                var t =wrapper[i].ProductDetails;
               // var isPricing =wrapper[i].IsPricingAvailable;
                if(t.GreenPages){
                  count = count +1;
                //component.set("v.ErrorMsg", wrapper[i].ProductDetails);
                }
                // if(isPricing == true){
                //   component.set("v.IsPricingAvailable", wrapper[i].IsPricingAvailable);
                // }
               
              }
            }
            if(listLength == count){
              component.set("v.IsPricingAvailable", true);
              var PassPricingResult = component.getEvent('PassPricingResult');
              PassPricingResult.setParams({
                  "IsPricingAvailable": true
              });
              PassPricingResult.fire();
            }
           
            $A.get("e.force:refreshView").fire();
            component.set("v.loadingSpinner", false);
          }
        }      
        var refreshEvent = $A.get("e.c:AssetPriceRefreshEvent");
              refreshEvent.setParams({ "recordId" : quoteID });
              window.setTimeout(function() {
                refreshEvent.fire(); 
              }, 10000);
      }  
      else{
        var resultsToast = $A.get("e.force:showToast");
        resultsToast.setParams({
          title: "Data not received",
          message: "In Progress/Not get API response.",
          type: "info"
        });
        resultsToast.fire();
        component.set("v.NoData",true );
      } 
      component.set("v.loadingSpinner", false);
    });
 
    
    $A.enqueueAction(action);
   
  },
  
// acceptPricing: function (component) {
//   var quoteID = component.get("v.recordId");
//   var wrapper = component.get("v.QuotePringRequestList");
//   var action = component.get("c.acceptQLIPricingRequest");
//   action.setParams({ qpWrapper: wrapper, isPriceOnly : false });
//   action.setCallback(this, function (response) {
//     var state = response.getState();
//     if (state === "SUCCESS") {
//       var resultsToast = $A.get("e.force:showToast");
//       resultsToast.setParams({
//         title: "Saved",
//         message: "Pricing Accepted succesfuly",
//         type: "success"
//       });
//       resultsToast.fire();
//       // var action2 = component.get("c.UpdateQuoteStatus");
//       // action2.setParams({ quoteID: quoteID , quoteStatus:'Price Configured'});
//       // action2.setCallback(this, function (response) {
//       //   var state = response.getState();
  
//       //   if (state === "SUCCESS") {

//       //   }
//       // });
//       // $A.enqueueAction(action2);
//     }
//     else{
//       var resultsToast = $A.get("e.force:showToast");
//       resultsToast.setParams({
//         title: "Failed",
//         message: "Pricing Failed",
//         type: "Failed"
//       });
//       resultsToast.fire();
//     } 
//     $A.get("e.force:refreshView").fire();
//     var dismissActionPanel = $A.get("e.force:closeQuickAction");
//     dismissActionPanel.fire();
//   });
//   $A.enqueueAction(action);

  
//  },

});