({
    doInit: function (component, event, helper) {
        //alert("recordId---"+component.get("v.recordId"));
        helper.getEmail(component, event, helper);
        //console.log('PARENTID init --- ' + component.get("v.caseRecord.ParentId"));
        helper.checkChild(component);
        helper.getParentEmail(component);

    },
    replyAction: function (cmp, event, helper) {
        var actionAPI = cmp.find("quickActionAPI");
        //alert('actionApi---' + actionAPI);
        var args = { actionName: "EmailMessage._Reply" };
        //alert('args---' + JSON.stringify(args));
        actionAPI.selectAction(args).then(function (result) {
            //Action selected; show data and set field values
            //alert(JSON.stringify(result));
        }).catch(function (e) {
            if (e.errors) {
                //If the specified action isn't found on the page, show an error message in the my component 
            }
        });
    },
    viewAttachment: function (component, event, helper) {

        var relatedListEvent = $A.get("e.force:navigateToRelatedList");
        relatedListEvent.setParams({
            "relatedListId": "CombinedAttachments",
            "parentRecordId": component.get("v.recordId")
        });
        relatedListEvent.fire();

    },
    divHide: function (component, event, helper) {
        var selectedSection = event.currentTarget;
        var index = selectedSection.dataset.index;
        var record = selectedSection.dataset.record;
        var recordshow = record + 'show';
        var recordhide = record + 'hide';

        var elements = document.getElementById(record);
        elements.style.display = 'none';

        var elementsShow = document.getElementById(recordshow);
        elementsShow.style.display = 'block';

        var elementsHide = document.getElementById(recordhide);
        elementsHide.style.display = 'none';
    },

    divClick: function (component, event, helper) {
        var selectedSection = event.currentTarget;
        var index = selectedSection.dataset.index;
        var record = selectedSection.dataset.record;
        var recordshow = record + 'show';
        var recordhide = record + 'hide';

        var elements = document.getElementById(record);
        elements.style.display = 'block';

        var elementsShow = document.getElementById(recordshow);
        elementsShow.style.display = 'none';

        var elementsHide = document.getElementById(recordhide);
        elementsHide.style.display = 'block';
        /*elementsHide.style.backgroundColor = 'HoneyDew';*/
        //component.set("v.selectedText",true);


    },
    openEmail: function (component, event, helper) {
        var index = event.currentTarget.getAttribute('data-index');
        var emailId = event.currentTarget.getAttribute('data-Id');
        //alert(conId);
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/" + emailId
        });
        urlEvent.fire();
    },
    CopyEmailComp: function (component, event, helper) {
        //component.set("v.showCalendar", true);
        $A.createComponent(
            "c:CaseCopyEmail",
            {
                "recordId": component.get("v.recordId"),
                "showBox": true
            },
            function (msgBox) {
                if (component.isValid()) {
                    var targetCmp = component.find('CaseEmailCopyHolder');
                    var body = targetCmp.get("v.body");
                    body.push(msgBox);
                    targetCmp.set("v.body", body);
                }
            }
        );
    },
    selectParent: function (component, event, helper) {
        helper.getParentEmail(component);
        component.set("v.isChildTable", false);
        component.set("v.childButtonVariant", "neutral");
        component.set("v.isParentTable", true);
        component.set("v.parentButtonVariant", "brand");
    },
    selectChild: function (component, event, helper) {
        helper.getEmail(component, event, helper);
        component.set("v.isParentTable", false);
        component.set("v.parentButtonVariant", "neutral");
        component.set("v.isChildTable", true);
        component.set("v.childButtonVariant", "brand");

    },
    divClickParent: function (component, event, helper) {
        var selectedSection = event.currentTarget;
        var index = selectedSection.dataset.index;
        var record = selectedSection.dataset.record + 'parent';
        var recordshow = record + 'show';
        var recordhide = record + 'hide';

        var elements = document.getElementById(record);
        elements.style.display = 'block';

        var elementsShow = document.getElementById(recordshow);
        elementsShow.style.display = 'none';

        var elementsHide = document.getElementById(recordhide);
        elementsHide.style.display = 'block';
        /*elementsHide.style.backgroundColor = 'HoneyDew';*/
        //component.set("v.selectedText",true);


    },
    divHideParent: function (component, event, helper) {
        var selectedSection = event.currentTarget;
        var index = selectedSection.dataset.index;
        var record = selectedSection.dataset.record + 'parent';

        var recordshow = record + 'show';
        var recordhide = record + 'hide';

        var elements = document.getElementById(record);
        elements.style.display = 'none';

        var elementsShow = document.getElementById(recordshow);
        elementsShow.style.display = 'block';

        var elementsHide = document.getElementById(recordhide);
        elementsHide.style.display = 'none';

    }
})