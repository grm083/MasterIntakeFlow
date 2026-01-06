({
    rerender: function (cmp, helper) {
        var assetIds = cmp.get('v.selectedOptions');
        var existingAssetOnCase = cmp.get("v.assetIdOnCase")
        if (!assetIds.includes(existingAssetOnCase)) {
        }
        else {
            if (assetIds[0] !== existingAssetOnCase) {
                assetIds.splice(assetIds.indexOf(existingAssetOnCase), 1);
                assetIds.unshift(existingAssetOnCase);
            }
        }
        cmp.set("v.firstElementOnList", assetIds[0]);
        this.superRerender();
    }
})