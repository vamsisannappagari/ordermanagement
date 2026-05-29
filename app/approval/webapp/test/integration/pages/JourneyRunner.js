sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"approval/test/integration/pages/PurchaseOrdersList",
	"approval/test/integration/pages/PurchaseOrdersObjectPage"
], function (JourneyRunner, PurchaseOrdersList, PurchaseOrdersObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('approval') + '/test/flp.html#app-preview',
        pages: {
			onThePurchaseOrdersList: PurchaseOrdersList,
			onThePurchaseOrdersObjectPage: PurchaseOrdersObjectPage
        },
        async: true
    });

    return runner;
});

