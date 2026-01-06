({
        doInit: function(component, event, helper) {  
             var recId = component.get("v.recordId");
//added as part of SDT 33127
        var validate = component.get("c.showSyncButton");
        validate.setParams({caseId : recId});
        validate.setCallback(this, function(response) {
            var status = response.getState();
            if(status === "SUCCESS") {
                component.set("v.showSyncButton", response.getReturnValue());
            }
        });
        $A.enqueueAction(validate);
        
             // Create the action
             var action = component.get("c.getPDF");
                 action.setParams({recordId : recId});
                 // Add callback behavior for when response is received
                 action.setCallback(this, function(response) {
                 var state = response.getState();
                 if (state === "SUCCESS") {
                     if(response.getReturnValue != null){
                         component.set("v.lstContentDoc", response.getReturnValue());
                         component.set("v.stopLoad", true);
                         document.getElementsByClassName("api_spinner")[0].style.display = 'none';
                         document.getElementsByClassName("success")[0].style.display = 'block';   
                     }
                     else{
                         document.getElementsByClassName("success")[0].style.display = 'block';
                         document.getElementsByClassName("api_spinner")[0].style.display = 'none';
                     }
                 }
                 else {
                     console.log("Failed with state: " + state);
                     document.getElementsByClassName("api_spinner")[0].style.display = 'none';
                     document.getElementsByClassName("failed")[0].style.display = 'block';
                 }
             });
             // Send action off to be executed
             $A.enqueueAction(action);
        },
        getSelected : function(component,event,helper){
             // display modle and set seletedDocumentId attribute with selected record Id   
             component.set("v.hasModalOpen" , true);
             component.set("v.selectedDocumentId" , event.currentTarget.getAttribute("data-Id"));  
         },
         closeModel: function(component, event, helper) {
             // for Close Model, set the "hasModalOpen" attribute to "FALSE"  
             component.set("v.hasModalOpen", false);
             component.set("v.selectedDocumentId" , null); 
         },
         handleUploadFinished: function (component, event) {
            // This will contain the List of File uploaded data and status
            var recId = component.get("v.recordId");
            var uploadedFiles = event.getParam("files");
            component.set("v.isModalOpen", false);
            //alert("Files uploaded : " + uploadedFiles.length);
            document.getElementsByClassName("api_spinner")[0].style.display = 'block';
            document.getElementsByClassName("success")[0].style.display = 'none';
            var docID = uploadedFiles[0].documentId;
            // Create the action
            let docList;
            if(component.get("v.lstContentDoc") != null){
                 docList =  component.get("v.lstContentDoc");
            }
            else{
                 docList = [];
            }
            var action = component.get("c.uploadDoc");
                action.setParams({"ConDocId" : docID, "TicketFileTypeName" : component.get("v.fileTypeTxt"),"fileName" : component.get("v.fileNameTxt"),'recordId':recId});
                // Add callback behavior for when response is received
                action.setCallback(this, function(response) {
                var state = response.getState();
                    if (state === "SUCCESS") {
                        if(response.getReturnValue() != null){
                    //33127
                            component.set("v.lstContentDoc", response.getReturnValue());                
                            //   helper.updateItem(component, event.getParam("item"));
                    // helper.Doreload(component,event,helper);
                    
                        }
                            document.getElementsByClassName("api_spinner")[0].style.display = 'none';
                            document.getElementsByClassName("success")[0].style.display = 'block';   
                    }       
            });
            // Send action off to be executed
            $A.enqueueAction(action);
        },
        openUploadModel: function(component, event, helper) {
            // Set isModalOpen attribute to true
            component.set("v.isModalOpen", true); 
            component.set("v.uploadDisabled", true);
            component.set("v.fileTypeTxt","");
            component.set("v.fileNameTxt","");

            // Initialize input select options
            var opts = [
                { "class": "optionClass", label: "-- Select One --", value: "", selected: "true" }
            ];
                
                var action = component.get("c.getFileTypePickList");
                // Add callback behavior for when response is received
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var allValues = response.getReturnValue();
                        for (var i = 0; i < allValues.length; i++) {
                            opts.push({
                                class: "optionClass",
                                label: allValues[i],
                                value: allValues[i]
                            });
                        }
                        component.find("InputSelectDynamic").set("v.options", opts);
                    }  
                });
                $A.enqueueAction(action);
         },
        
         closeUploadModel: function(component, event, helper) {
            // Set isModalOpen attribute to false  
            component.set("v.isModalOpen", false);
         },
        //Used with OK button
         submitDetails: function(component, event, helper) {
            // Set isModalOpen attribute to false
            //Add your code to call apex method or do some processing
            component.set("v.isModalOpen", false);
         },
         onChange: function(component) {
            var dynamiccomponent = component.find("InputSelectDynamic");
            //var resultcomponent = component.find("dynamicResult");
            var filetype = dynamiccomponent.get("v.value");
            //resultcomponent.set("v.value", dynamiccomponent.get("v.value"));
            component.set("v.fileTypeTxt",filetype);
            if(filetype.length > 0 && component.get("v.fileNameTxt").length > 0){
                component.set("v.uploadDisabled", false);
            }
            else{
                component.set("v.uploadDisabled", true);
 
            }
            
        },
    
    //added as part of SDT 33127
    onSync : function(component) {
        document.getElementsByClassName("api_spinner")[0].style.display = 'block';
        var recId = component.get("v.recordId");
        var action = component.get("c.integrateDocsToAcorn");
        action.setParams({'caseId':recId});
        // Add callback behavior for when response is received
        action.setCallback(this, function(response) {
            document.getElementsByClassName("api_spinner")[0].style.display = 'none';
            var state = response.getState();
            if (state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Sync to acorn successful",
                    "type": "success"
                });
                toastEvent.fire();
            }
            else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "Error occurred",
                    "type": "error"
                });
                toastEvent.fire();
            }
            
        });
        // Send action off to be executed
        $A.enqueueAction(action);
    }
    
    
})