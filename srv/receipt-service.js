const cds = require('@sap/cds');

module.exports = cds.service.impl(async function () {

   const { PurchaseOrders, GoodsReceipts, GoodsReceiptItems,POLineItems } = cds.entities('procurement.db');
   // ON: confirmReceipt
   this.on('confirmReceipt', 'GoodsReceipts', async (req) => {
    const { ID } = req.params[0];
    const { quantityReceived } = req.data;

    // Fetch GR
    const gr = await SELECT.one.from(GoodsReceipts).where({ ID });
    if (!gr) return req.error(404, `Goods Receipt ${ID} not found`);
    if (gr.status === 'Posted') return req.error(400, 'Already posted');

    const poID = gr.purchaseOrder_ID;

    // Fetch PO
    const po = await SELECT.one.from(PurchaseOrders).where({ ID: poID });
    if (!po) return req.error(404, `PO ${poID} not found`);
    // if (po.status === 'Closed')    return req.error(400, 'PO is already closed');
    if (po.status === 'Rejected')  return req.error(400, 'PO is rejected');

    // Fetch PO line item
    const lineItem = await SELECT.one.from(POLineItems).where({ purchaseOrder_ID: poID });
    if (!lineItem) return req.error(404, `No line items found for PO ${poID}`);

    // Insert GR item
    await INSERT.into(GoodsReceiptItems).entries({
        ID               : cds.utils.uuid(),
        goodsReceipt_ID  : ID,
        poLineItem_ID    : lineItem.ID,
        quantityReceived : quantityReceived
    });

    // Update deliveryQty
    const newDeliveryQty = parseFloat(lineItem.deliveryQty || 0) + parseFloat(quantityReceived);
    await UPDATE(POLineItems)
        .set({ deliveryQty: newDeliveryQty })
        .where({ ID: lineItem.ID });

    // Auto-close PO if fully received
    const allLines = await SELECT.from(POLineItems).where({ purchaseOrder_ID: poID });
    const fullyReceived = allLines.every(
        li => parseFloat(li.deliveryQty || 0) >= parseFloat(li.quantity)
    );
    if (fullyReceived) {
        await UPDATE(PurchaseOrders).set({ status: 'Closed' }).where({ ID: poID });
    }

    // Post the GR
    await UPDATE(GoodsReceipts).set({ status: 'Posted' }).where({ ID });
    req.info(`Confirmed receipt for GR ${ID}, updated deliveryQty to ${newDeliveryQty}, PO ${poID} status: ${fullyReceived ? 'Closed' : po.status}`);
    return SELECT.one.from(GoodsReceipts).where({ ID });
    });

    // AFTER: confirmReceipt — update deliveryQty + three-way match + auto-close
    this.after('confirmReceipt', async (result, req) => {
        const { poID, quantityReceived } = req.data;

        // Fetch PO line item
        const lineItem = await SELECT.one.from(POLineItems).where({ purchaseOrder_ID: poID });
        if (!lineItem) return;

        // Update cumulative deliveryQty
        const newDeliveryQty = parseFloat(lineItem.deliveryQty || 0) + parseFloat(quantityReceived);
        await UPDATE(POLineItems)
            .set({ deliveryQty: newDeliveryQty })
            .where({ ID: lineItem.ID });

        // Three-way match — auto-close PO if fully received
        const allLines = await SELECT.from(POLineItems).where({ purchaseOrder_ID: poID });
        const fullyReceived = allLines.every(
            li => parseFloat(li.deliveryQty || 0) >= parseFloat(li.quantity)
        );
        if (fullyReceived) {
            await UPDATE(PurchaseOrders).set({ status: 'Closed' }).where({ ID: poID });
        }
    });

    this.on('getPendingDeliveries', async (req) => {
       const result= await SELECT.from(PurchaseOrders).columns('ID as poID', 'deliveryDate', 'vendor.name as vendor').where({ status: 'Pending' });
        return result;
    });

   

});