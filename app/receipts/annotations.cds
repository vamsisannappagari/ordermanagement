using ReceiptService as service from '../../srv/receipt-service';

// GOODS RECEIPTS

annotate service.GoodsReceipts with @(

    UI.HeaderInfo : {
        TypeName       : 'Goods Receipt',
        TypeNamePlural : 'Goods Receipts',
        Title          : { $Type : 'UI.DataField', Value : purchaseOrder_ID},
    },

    UI.HeaderFacets : [
        { $Type : 'UI.ReferenceFacet', Target : '@UI.DataPoint#GRStatus' },
    ],

    UI.DataPoint #GRStatus : {
        Value       : status,
        Criticality : (status = 'Posted' ? 3 : status = 'Reversed' ? 1 :status='Pending' ? 2 : 0),
        Title       : 'Status',
    },

    
    // List page columns
    UI.LineItem : [
       
        { $Type : 'UI.DataField', Label : 'PO Reference', Value : purchaseOrder_ID },
        { $Type : 'UI.DataField', Label : 'Created On', Value : createdAt },
        {
            $Type       : 'UI.DataField',
            Label       : 'Status',
            Value       : status,
            Criticality : (status = 'Posted' ? 3 : status = 'Reversed' ? 1 :status='Pending' ? 2 : 0),
        },
        {
            $Type  : 'UI.DataFieldForAction',
            Action : 'ReceiptService.confirmReceipt',
            Label  : 'Confirm Receipt',
        },
    ],

    UI.SelectionFields : [ status, purchaseOrder_ID ],

    // Object page sections
    UI.FieldGroup #GRInfo : {
        $Type : 'UI.FieldGroupType',
        Label : 'Receipt Information',
        Data  : [
            { $Type : 'UI.DataField', Label : 'Receipt Date', Value : receiptDate },

            { $Type : 'UI.DataField', Label : 'PO Reference', Value : purchaseOrder_ID },
        ],
    },

    UI.Facets : [
        {
            $Type  : 'UI.ReferenceFacet',
            ID     : 'GRInfoFacet',
            Label  : 'Receipt Details',
            Target : '@UI.FieldGroup#GRInfo',
        },
        {
            $Type  : 'UI.ReferenceFacet',
            ID     : 'GRLineItemsFacet',
            Label  : 'Receipt Lines',
            Target : 'lineReceipts/@UI.LineItem',
        },
    ],
);


annotate service.GoodsReceipts with {

    purchaseOrder @(
        Common.Text            : purchaseOrder_ID,
        Common.TextArrangement : #TextOnly,
        Common.ValueList : {
            $Type          : 'Common.ValueListType',
            CollectionPath : 'PurchaseOrders',
            Parameters     : [
                {
                    $Type             : 'Common.ValueListParameterInOut',
                    LocalDataProperty : purchaseOrder_ID,
                    ValueListProperty : 'ID'
                },
            ],
        },
    );
};

// GOODS RECEIPT ITEMS

annotate service.GoodsReceiptItems with @(

    UI.HeaderInfo : {
        TypeName       : 'Receipt Item',
        TypeNamePlural : 'Receipt Items',
        Title          : { $Type : 'UI.DataField', Value : quantityReceived },
        Description    : { $Type : 'UI.DataField', Value : remarks },
    },

    // Columns shown in the lineReceipts sub-table inside GR object page
    UI.LineItem : [
        { $Type : 'UI.DataField', Label : 'PO Line Item',      Value : poLineItem_ID },
        { $Type : 'UI.DataField', Label : 'Ordered Qty', Value : orderedQty },
        { $Type : 'UI.DataField', Label : 'Quantity Received', Value : quantityReceived },
        { $Type : 'UI.DataField', Label : 'Remarks',           Value : remarks },
    ],

    UI.FieldGroup #GRItemDetails : {
        $Type : 'UI.FieldGroupType',
        Label : 'Item Details',
        Data  : [
            { $Type : 'UI.DataField', Label : 'PO Line Item',      Value : poLineItem_ID },
            { $Type : 'UI.DataField', Label : 'Ordered Qty', Value : orderedQty },
            { $Type : 'UI.DataField', Label : 'Unit Price',        Value : poLineItem.unitPrice },
            { $Type : 'UI.DataField', Label : 'Quantity Received', Value : quantityReceived },
            { $Type : 'UI.DataField', Label : 'Remarks',           Value : remarks },
        ],
    },

    UI.Facets : [
        { $Type : 'UI.ReferenceFacet', ID : 'GRItemDetailsFacet', Label : 'Item Details', Target : '@UI.FieldGroup#GRItemDetails' },
    ],
);

// Value help for poLineItem — lets user pick which PO line they are receiving against
annotate service.GoodsReceiptItems with {
    poLineItem @(
        Common.Text            : poLineItem.description,
        Common.TextArrangement : #TextOnly,
        Common.ValueList : {
            $Type          : 'Common.ValueListType',
            CollectionPath : 'POLineItems',
            Parameters     : [
                { $Type : 'Common.ValueListParameterInOut',       LocalDataProperty : poLineItem_ID,  ValueListProperty : 'ID' },
                { $Type : 'Common.ValueListParameterDisplayOnly', ValueListProperty : 'description' },
                { $Type : 'Common.ValueListParameterOut', LocalDataProperty : quantityReceived, ValueListProperty : 'quantity' },
                { $Type : 'Common.ValueListParameterDisplayOnly', ValueListProperty : 'unitPrice' },
            ],
        },
    );
};

annotate service.GoodsReceipts with {
    status @(
        Common.ValueListWithFixedValues : true,
        Common.ValueList : {
            CollectionPath : 'GRView',
            Parameters     : [
                {
                    $Type             : 'Common.ValueListParameterInOut',
                    LocalDataProperty : status,
                    ValueListProperty : 'status'
                }
            ]
        }
    );
};