const cds = require('@sap/cds');

module.exports = cds.service.impl(async function () {

    const { Vendors, PurchaseRequisitions, PurchaseOrders, POLineItems, Users, NotificationLogs } = this.entities;

    // BEFORE: createPO
    this.before('createPO', async (req) => {
        const { prID, vendorID } = req.data;
        const pr = await SELECT.one.from(PurchaseRequisitions).where({ ID: prID });
        if (!pr) return req.error(404, `PR ${prID} not found`);
        if (pr.status !== 'Approved') return req.error(400, `PR must be Approved before creating a PO`);

        const vendor = await SELECT.one.from(Vendors).where({ ID: vendorID });
        if (!vendor) return req.error(404, `Vendor ${vendorID} not found`);
        if (vendor.status === 'Blocked' || vendor.status === 'Inactive') return req.error(400, `Vendor is not active`);
    });

    // BEFORE: approvePO
    this.before('approvePO', async (req) => {
        // const poID = req.params?.[0]?.ID ?? req.params?.[0] ?? req.data?.ID;
        const poID = req.data.ID || req.params[0]?.ID;
        const po = await SELECT.one.from(PurchaseOrders).where({ ID: poID });
        if (!po) return req.error(404, `PO ${poID} not found`);

        const approver = await SELECT.one.from(Users).where({ username: req.user?.id });
        if (approver) {
            const authLimit = parseFloat(approver.authorizationLimit || 0);
            const poTotal   = parseFloat(po.totalValue || 0);
            if (authLimit > 0 && poTotal > authLimit)
                return req.error(403, `PO total ${poTotal} exceeds your authorization limit of ${authLimit}`);
        }
    });

    // ON: submitPR
    this.on('submitPR', async (req) => {
        const prID = req.data.ID || req.params[0]?.ID;
        const pr = await SELECT.one.from(PurchaseRequisitions).where({ ID: prID });
        if (!pr) return req.error(404, `PR ${prID} not found`);
        if (pr.status === 'Submitted') return req.error(400, `PR ${prID} is already submitted`);
        await UPDATE(PurchaseRequisitions).set({ status: 'Submitted' }).where({ ID: prID });
        req.info(`PR ${prID} submitted`);
        return 'PR submitted successfully';
    });


    // ON: createPO
    this.on('createPO', async (req) => {
        const { prID, vendorID } = req.data;
        const pr = await SELECT.one.from(PurchaseRequisitions).where({ ID: prID });
        const unitPrice = parseFloat(pr.estimatedUnitCost || 0);
        const quantity  = parseFloat(pr.quantity || 0);
        const lineTotal = quantity * unitPrice;
        const poID      = cds.utils.uuid();

        await INSERT.into(PurchaseOrders).entries({
            ID             : poID,
            vendor_ID      : vendorID,
            prReference_ID : prID,
            totalValue     : lineTotal,
            status         : 'Pending'
        });

        await INSERT.into(POLineItems).entries({
            ID               : cds.utils.uuid(),
            purchaseOrder_ID : poID,
            description      : pr.itemDescription,
            quantity         : pr.quantity,
            unitPrice        : unitPrice,
            lineTotal        : lineTotal
        });

        return 'PO is created from PR';
    });

    // ON: approvePO 
    this.on('approvePO', async (req) => {
        const poID = req.data.ID || req.params[0]?.ID;
        const po = await SELECT.one.from(PurchaseOrders).where({ ID: poID }); 
        if (!po) return req.error(404, `PO ${poID} not found`);
        if (po.status === 'Approved') return req.error(400, `PO ${poID} is already approved`);
        if (po.status === 'Rejected') return req.error(400, `PO ${poID} is rejected`);
        const approver = await SELECT.one.from(Users).where({ username: req.user?.id });
        await UPDATE(PurchaseOrders)
        .set({ status: 'Approved', approvedBy_ID: approver?.ID })
        .where({ ID: poID });
        req.info(`PO ${poID} approved`);
        return 'PO is approved';
    });

    // ON: rejectPO 
    this.on('rejectPO', async (req) => {
        const poID = req.data.ID || req.params[0]?.ID;
        const reason = req.data.reason;
        const po = await SELECT.one.from(PurchaseOrders).where({ ID: poID });  
        if (!po) return req.error(404, `PO ${poID} not found`);
        if (po.status === 'Rejected') return req.error(400, `PO ${poID} is already rejected`);
        
        await UPDATE(PurchaseOrders).set({ status: 'Rejected' }).where({ ID: poID });
        req.info(`PO ${poID} rejected by user ${req.user?.id}. Reason: ${req.data.reason}`);
        return `PO ${poID} rejected. Reason: ${reason}`;
    });



    
    
    // AFTER: approvePR — notify requester + auto-create PO
    this.after('approvePR', async (result, req) => {
    const prID = req.data.ID || req.params[0]?.ID;
    const pr = await SELECT.one.from(PurchaseRequisitions).where({ ID: prID });
    // Notify requester
    if (pr?.requester_ID) {
        await INSERT.into(NotificationLogs).entries({
            ID           : cds.utils.uuid(),
            recipient_ID : pr.requester_ID,
            message      : `Your PR (ID: ${prID}) has been approved.`,
            isRead       : false
        });
    }
    });



    this.before('CREATE', PurchaseRequisitions, async (req) => {
        req.data.status = 'Draft';

        const user = await SELECT.one.from(Users)
            .columns('ID', 'username', 'firstName') 
            .where({ username: req.user?.id });

        console.log('>>> req.user?.id =>', req.user?.id);
        console.log('>>> user found =>', JSON.stringify(user));

        if (user) {
            req.data.requester_ID = user.ID;
        }
    });


    this.after('submitPR', async (result, req) => {
        // const prID = req.data.ID || req.params[0]?.ID;
        const prID = req.params?.[0]?.ID || req.params?.[0] || req.data?.ID;
        const pr = await SELECT.one.from(PurchaseRequisitions).where({ ID: prID });
        if (!pr) return;

        const unitPrice = parseFloat(pr.estimatedUnitCost || 0);
        const quantity  = parseFloat(pr.quantity || 0);
        const lineTotal = unitPrice * quantity;
        const poID      = cds.utils.uuid();

        await INSERT.into(PurchaseOrders).entries({
            ID             : poID,
            prReference_ID : prID,
            totalValue     : lineTotal,
            status         : 'Pending'
        });

        await INSERT.into(POLineItems).entries({
            ID               : cds.utils.uuid(),
            purchaseOrder_ID : poID,
            description      : pr.itemDescription,
            quantity         : pr.quantity,
            unitPrice        : unitPrice,
            lineTotal        : lineTotal
        });

    });


    this.on('approvePR', 'PurchaseOrders', async (req) => {
        const poID = req.params?.[0]?.ID || req.params?.[0];

        const po = await SELECT.one.from(PurchaseOrders).where({ ID: poID });
        if (!po)                return req.error(404, `PO not found`);
        if (!po.prReference_ID) return req.error(400, `No PR linked to this PO`);

        const pr = await SELECT.one.from(PurchaseRequisitions).where({ ID: po.prReference_ID });
        if (!pr) return req.error(404, `PR not found`);
        if (pr.status === 'Accepted') return req.error(400, `PR is already accepted`);
        if (pr.status === 'Rejected') return req.error(400, `PR is already rejected`);
        if (pr.status !== 'Submitted') return req.error(400, `PR must be Submitted before approving`);

        const approver = await SELECT.one.from(Users).where({ username: req.user?.id });
        await UPDATE(PurchaseRequisitions)
            .set({ status: 'Accepted', approvedBy_ID: approver?.ID })
            .where({ ID: po.prReference_ID });

        req.info('PR is accepted ');
        return 'PR Accepted Successfully';
    });

        // ON: rejectPR 
        this.on('rejectPR', 'PurchaseOrders', async (req) => {
            const poID  = req.params?.[0]?.ID || req.params?.[0];
            const reason = req.data.reason;
            const po = await SELECT.one.from(PurchaseOrders).where({ ID: poID });
            if (!po) return req.error(404, `PO not found`);
            if (!po.prReference_ID) return req.error(400, `No PR linked to this PO`);
            const pr = await SELECT.one.from(PurchaseRequisitions).where({ ID: po.prReference_ID });
            if (!pr) return req.error(404, `PR not found`);
            if (pr.status === 'Approved') return req.error(400, `PR is already approved`);
            if (pr.status === 'Rejected') return req.error(400, `PR is already rejected`);
            await UPDATE(PurchaseRequisitions)
                .set({ status: 'Rejected' })
                .where({ ID: po.prReference_ID });

            req.info(`PR ${po.prReference_ID} rejected by ${req.user?.id}. Reason: ${reason}`);
            return `PR Rejected. Reason: ${reason}`;
        });

        
        

    });