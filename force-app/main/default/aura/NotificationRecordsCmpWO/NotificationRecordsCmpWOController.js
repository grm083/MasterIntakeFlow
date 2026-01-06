({
	initAction: function (component, event, helper) {
		helper.getAssets(component, event, helper);
		component.set('v.NTColumns', [{
				label: 'Contact Name',
				fieldName: 'contactName',
				type: 'text'
			},
			{
				label: 'Email Address/Phone Number',
				fieldName: 'emailAddPhoneNum',
				type: 'text'
			},
			{
				label: 'Type',
				fieldName: 'emailSMSType',
				type: 'text'
			},
			{
				label: 'Email Subject/Text Content',
				fieldName: 'emailSubBody',
				type: 'text'
			},
			{
				label: 'Image/Video URL',
				fieldName: 'imageURL',
				type: 'url'
			},
			{
				label: 'Message Type',
				fieldName: 'messageType',
				type: 'text'
			},
			{
				label: 'Date Time Sent',
				fieldName: 'dateTimeSent',
				type: 'text'
			},
			{
				label: 'Status',
				fieldName: 'status',
				type: 'text'
			},

		]);

		if (component.get('v.isSubTab')) {
			helper.getNTDataFromAPI(component, event, helper);
		}
	},

	getNTData: function (component, event, helper) {
		component.set('v.pageSize', component.get('v.pageSize10'));
		helper.getNTDataFromAPI(component, event, helper);
	},

	next: function (component, event, helper) {
		var pgNum = component.get('v.pageNumber');
		pgNum = pgNum + 1;
		component.set('v.pageNumber', pgNum);
		helper.getNTDataFromAPI(component, event, helper);
	},
	previous: function (component, event, helper) {
		var pgNum = component.get('v.pageNumber');
		pgNum = pgNum - 1;
		component.set('v.pageNumber', pgNum);
		helper.getNTDataFromAPI(component, event, helper);
	},

	viewAll: function (component, event, helper) {
		var evt = $A.get("e.force:navigateToComponent");
		evt.setParams({
			componentDef: "c:NotificationRecordsCmp",
			componentAttributes: {
				selectedAsset: component.get("v.selectedAsset"),
				pageNumber: component.get("v.pageNum1"),
				pageSize: component.get("v.pageSize50"),
				hideFooter: true,
				isSubTab: true
			}
		});
		evt.fire();
	},

	onChange: function (component, event, helper) {
		var assetId = component.find("selectAsset").get("v.value");
		component.set("v.selectedAsset", assetId);
		if (assetId == 'default') {
			component.set("v.disable", true);
		} else {
			component.set("v.disable", false);
		}
	},

	handlePic: function (component, event, helper) {
		var url = event.currentTarget.getAttribute("data-Id");
		let params ='width=600,height=300';
		window.open(url, "imgWindow",params);
	},
    handleClick : function(component, event, helper) {
      	 var recordId =event.currentTarget.getAttribute("data-Id");
            var sObectEvent = $A.get("e.force:navigateToSObject");
                sObectEvent.setParams({
                    "recordId": recordId,
                    "slideDevName": "detail"
                });
                sObectEvent.fire();
    },
})