({
    paginateRecords: function(component) {
        let records = component.get("v.allNotes");
        let currentPage = component.get("v.currentPageNumber");
        let recordsPerPage = component.get("v.pageSize");

        // Calculate start and end index for the current page
        let startIndex = (currentPage - 1) * recordsPerPage;
        let endIndex = currentPage * recordsPerPage;

        // Slice the records to get the paginated data
        let paginatedRecords = records.slice(startIndex, endIndex);
        component.set("v.paginatedNotes", paginatedRecords);
    },
    fireToastEvent: function(component, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Error!",
            "message": message,
            "type": "error"
        });
        toastEvent.fire();
    }


})