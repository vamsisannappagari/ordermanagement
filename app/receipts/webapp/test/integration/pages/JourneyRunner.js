sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"receipts/test/integration/pages/GoodsReceiptsList",
	"receipts/test/integration/pages/GoodsReceiptsObjectPage"
], function (JourneyRunner, GoodsReceiptsList, GoodsReceiptsObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('receipts') + '/test/flp.html#app-preview',
        pages: {
			onTheGoodsReceiptsList: GoodsReceiptsList,
			onTheGoodsReceiptsObjectPage: GoodsReceiptsObjectPage
        },
        async: true
    });

    return runner;
});

