({
	helperMethod: function () {

	},
	showFields: function (component) {
		var fields = component.get("v.pop");
		console.log('NSEqCode' + fields.NSEqCode)
		if (fields.NSEqCode == null || fields.NSEqCode == '') {
			$A.util.addClass(component.find("NSEqCode"), "slds-hide");
		}
		if (fields.NSMatType == null || fields.NSMatType == '') {
			$A.util.addClass(component.find("NSMatType"), "slds-hide");
		}
		if (fields.NSDeliveryDate == null || fields.NSDeliveryDate == '') {
			$A.util.addClass(component.find("NSDeliveryDate"), "slds-hide");
		}
		if (fields.NSEqSizeCode == null || fields.NSEqSizeCode == '') {
			$A.util.addClass(component.find("NSEqSizeCode"), "slds-hide");
		}
		if (fields.NSEqCode == null || fields.NSEqCode == '') {
			$A.util.addClass(component.find("NSEqCode"), "slds-hide");
		}
		if (fields.NSQuoteContName == null || fields.NSQuoteContName == '') {
			$A.util.addClass(component.find("NSQuoteContName"), "slds-hide");
		}
		if (fields.NSQuoteContPhNum == null || fields.NSQuoteContPhNum == '') {
			$A.util.addClass(component.find("NSQuoteContPhNum"), "slds-hide");
		}
		if (fields.NSReason == null || fields.NSReason == '') {
			$A.util.addClass(component.find("NSReason"), "slds-hide");
		}
		if (fields.NSSiteContPhNum == null || fields.NSSiteContPhNum == '') {
			$A.util.addClass(component.find("NSSiteContPhNum"), "slds-hide");
		}
		if (fields.NSSiteContName == null || fields.NSSiteContName == '') {
			$A.util.addClass(component.find("NSSiteContName"), "slds-hide");
		}
		if (fields.NSPlacementInts == null || fields.NSPlacementInts == '') {
			$A.util.addClass(component.find("NSPlacementInts"), "slds-hide");
		}
		if (fields.NSEARDates == null || fields.NSEARDates == '') {
			$A.util.addClass(component.find("NSEARDates"), "slds-hide");
		}
		if (fields.NSRemovalDate == null || fields.NSRemovalDate == '') {
			$A.util.addClass(component.find("NSRemovalDate"), "slds-hide");
		}
		if (fields.NSQuoteOnly == null || fields.NSQuoteOnly == '') {
			$A.util.addClass(component.find("NSQuoteOnly"), "slds-hide");
		}
		
	}
})