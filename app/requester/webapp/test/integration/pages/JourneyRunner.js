sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"requester/test/integration/pages/PurchaseRequisitionsList",
	"requester/test/integration/pages/PurchaseRequisitionsObjectPage"
], function (JourneyRunner, PurchaseRequisitionsList, PurchaseRequisitionsObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('requester') + '/test/flp.html#app-preview',
        pages: {
			onThePurchaseRequisitionsList: PurchaseRequisitionsList,
			onThePurchaseRequisitionsObjectPage: PurchaseRequisitionsObjectPage
        },
        async: true
    });

    return runner;
});

