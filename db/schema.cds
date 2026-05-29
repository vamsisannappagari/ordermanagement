namespace procurement.db;

using { cuid, managed } from '@sap/cds/common';

type vendorStatus : String enum{
    Active;
    Inactive;
    Blocked;
    Pending;
}

type prStatus : String enum{
    Draft;
    Submitted;
    Accepted;
    Rejected;
}
type poStatus : String enum {
    Closed;
    Approved;
    Pending;
    Rejected;
}
type grStatus : String enum{
    Posted;
    Reversed;
    Pending;
}

type userStatus : String enum{
    Active;
    Inactive;
}

type paymentTerms : String enum {
    Net15      = 'Net 15';
    Net30      = 'Net 30';
    Net60      = 'Net 60';
    Net90      = 'Net 90';
    COD        = 'COD';
    Immediate  = 'Immediate';
}

entity Vendors : cuid, managed {
    vendorCode      : String @mandatory @assert.notNull;
    name            : String @mandatory @assert.notNull;
    category        : String;
    email           : String;
    paymentTerms    : paymentTerms;
    rating          : Decimal(2,1) @assert.range: [0, 5];
    status          : vendorStatus;
    purchaseOrders  : Association to many PurchaseOrders on purchaseOrders.vendor = $self;
}

entity PurchaseRequisitions : cuid, managed {
    requester         : Association to Users;
    approvedBy        : Association to Users;
    department        : String @mandatory @assert.notNull;
    itemDescription   : String @mandatory @assert.notNull;
    quantity          : Decimal(13,3) @mandatory @assert.notNull;
    estimatedUnitCost : Decimal(15,2);
    status            : prStatus;
    purchaseOrders    : Association to many PurchaseOrders on purchaseOrders.prReference = $self;
    statusCriticality : Integer;
}

entity PurchaseOrders : cuid, managed {
    vendor          : Association to Vendors;
    prReference     : Association to PurchaseRequisitions;
    approvedBy      : Association to Users;
    lineItems       : Composition of many POLineItems on lineItems.purchaseOrder = $self;
    totalValue      : Decimal(15,2);
    status          : poStatus;
    deliveryDate    : Date;
    goodsReceipts   : Association to many GoodsReceipts on goodsReceipts.purchaseOrder = $self;
}

entity POLineItems : cuid {
    purchaseOrder   : Association to PurchaseOrders;
    description     : String @mandatory @assert.notNull;
    quantity        : Decimal(13,3) @mandatory @assert.notNull;
    unitPrice       : Decimal(15,2) @mandatory @assert.notNull;
    deliveryQty     : Decimal(13,3);
    lineTotal       : Decimal(15,2) @Core.Computed;
}

entity GoodsReceipts : cuid, managed {
    purchaseOrder   : Association to PurchaseOrders;
    receivedBy      : Association to Users;
    receiptDate     : Date @mandatory @assert.notNull;
    lineReceipts    : Composition of many GoodsReceiptItems on lineReceipts.goodsReceipt = $self;
    status          : grStatus default 'Pending';
}

entity GoodsReceiptItems : cuid {
    goodsReceipt     : Association to GoodsReceipts;
    poLineItem       : Association to POLineItems;
    orderedQty       : Decimal(13,3);
    quantityReceived : Decimal(13,3) @mandatory @assert.notNull;
    remarks          : String;
}


entity Users : cuid, managed {
    username    : String @mandatory @assert.notNull;
    firstName   : String @mandatory @assert.notNull;
    lastName    : String @mandatory @assert.notNull;
    role        : String;
    status      : userStatus;
}


entity NotificationLogs:cuid  {
    recipient   : Association to Users; 
    message     : String;
    isRead      : Boolean default false;
}

entity StatusView as select  from PurchaseRequisitions {
    key status
}group by status;

entity DeptView as select  from PurchaseRequisitions {
    key department
}group by department;


entity GRView as select  from GoodsReceipts {
    key status
}group by status;

entity OrdersView as select  from PurchaseOrders {
    key status
}group by status;

entity paymentView as select  from Vendors {
    key paymentTerms
}group by paymentTerms;



view VendorPerformance as select from Vendors {
    key vendorCode,
        name,
        category,
        status,
        rating,
        count(purchaseOrders.ID) as totalOrders : Integer
} group by vendorCode, name, category, status, rating;