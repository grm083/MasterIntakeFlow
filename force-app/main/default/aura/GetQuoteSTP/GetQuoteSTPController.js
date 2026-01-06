({
    doInit: function (component, event, helper) {
        // Commented as part of SDT-31130. This is causing an extra call and making extra genesys record.
        //helper.getQuoteStatusByCase(component);
    },
});