sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"dashboard/test/integration/pages/VendorPerformanceList",
	"dashboard/test/integration/pages/VendorPerformanceObjectPage"
], function (JourneyRunner, VendorPerformanceList, VendorPerformanceObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('dashboard') + '/test/flp.html#app-preview',
        pages: {
			onTheVendorPerformanceList: VendorPerformanceList,
			onTheVendorPerformanceObjectPage: VendorPerformanceObjectPage
        },
        async: true
    });

    return runner;
});

