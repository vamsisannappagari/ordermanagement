using ProcurementService as service from '../../srv/procurement-service';

// PURCHASE ORDERS — Approval Dashboard

annotate service.PurchaseOrders with @(

   UI.Identification : [
    {
        $Type       : 'UI.DataFieldForAction',
        Action      : 'ProcurementService.approvePR',
        Label       : 'Accept PR',
    },
    {
        $Type       : 'UI.DataFieldForAction',
        Action      : 'ProcurementService.rejectPR',
        Label       : 'Reject PR',      
    }],

    
    UI.HeaderInfo : {
        TypeName       : 'Purchase Order',
        TypeNamePlural : 'Purchase Orders',
        Title          : { $Type : 'UI.DataField', Value : vendor.name},
        
    },

    UI.HeaderFacets : [
        { $Type : 'UI.ReferenceFacet', Target : '@UI.DataPoint#POStatus' },
        { $Type : 'UI.ReferenceFacet', Target : '@UI.DataPoint#POTotal' },
    ],

    UI.DataPoint #POStatus : {
        Value       : status,
        Criticality : (status = 'Closed' ? 5 : status = 'Approved' ? 3 : status = 'Pending' ? 2 : status = 'Rejected' ? 1 : 0),
        Title       : 'PO Status',
    },


    UI.DataPoint #POTotal : {
        Value : totalValue,
        Title : 'Total Value',
    },

    UI.SelectionFields : [
        status,
        vendor_ID,
    ],

    UI.LineItem : [
        {
            $Type : 'UI.DataField',
            Label : 'Vendor',
            Value : vendor.name
        },
        {
            $Type : 'UI.DataField',
            Label : 'PR Reference',
            Value : prReference.itemDescription
        },
        {
            $Type : 'UI.DataField',
            Label : 'Total Value',
            Value : totalValue
        },
        {
            $Type : 'UI.DataField',
            Label : 'Delivery Date',
            Value : deliveryDate
        },
        {
            $Type       : 'UI.DataField',
            Label       : 'Status',
            Value       : status,
            Criticality : (status = 'Closed' ? 5 : status = 'Approved' ? 3 : status = 'Pending' ? 2 : status = 'Rejected' ? 1 : 0),
        },
        {
            $Type  : 'UI.DataFieldForAction',
            Action : 'ProcurementService.approvePO',
            Label  : 'Approve PO'
        },
        {
            $Type  : 'UI.DataFieldForAction',
            Action : 'ProcurementService.rejectPO',
            Label  : 'Reject PO'
        }
    ],

    UI.FieldGroup #PODetails : {
        $Type : 'UI.FieldGroupType',
        Label : 'Order Details',
        Data  : [
            { $Type : 'UI.DataField', Label : 'Total Value',   Value : totalValue },
            { $Type : 'UI.DataField', Label : 'Delivery Date', Value : deliveryDate },
            
        ],
    },

    UI.FieldGroup #VendorInfo : {
        $Type : 'UI.FieldGroupType',
        Label : 'Vendor Information',
        Data  : [
             { $Type : 'UI.DataField', Label : 'Vendor Name',        Value : vendor_ID },     
            { $Type : 'UI.DataField', Label : 'Category',      Value : vendor.category },
            { $Type : 'UI.DataField', Label : 'Email',         Value : vendor.email },
            { $Type : 'UI.DataField', Label : 'Payment Terms', Value : vendor.paymentTerms }
        ],
    },

    UI.FieldGroup #PRInfo : {
        $Type : 'UI.FieldGroupType',
        Label : 'PR Reference',
        Data  : [
            { $Type : 'UI.DataField', Label : 'Quantity',         Value : prReference.quantity },
            { $Type : 'UI.DataField', Label : 'Est. Unit Cost',   Value : prReference.estimatedUnitCost },
          
        ],
    },

    UI.Facets : [
        {
            $Type  : 'UI.CollectionFacet',
            ID     : 'PODetails',
            Label  : 'PO Details',
            Facets : [
                { $Type : 'UI.ReferenceFacet', ID : 'PODetailsFacet', Label : 'Order Details',      Target : '@UI.FieldGroup#PODetails' },
                { $Type : 'UI.ReferenceFacet', ID : 'VendorFacet',    Label : 'Vendor Information', Target : '@UI.FieldGroup#VendorInfo' },
                { $Type : 'UI.ReferenceFacet', ID : 'PRFacet',        Label : 'PR Reference',       Target : '@UI.FieldGroup#PRInfo' },
            ],
        },
        
         {
            $Type  : 'UI.ReferenceFacet',
            ID     : 'LineItemsFacet',
            Label  : 'Line Items',
            Target : 'lineItems/@UI.LineItem',
        },
    ],     
);

//  Value Help 
annotate service.PurchaseOrders with {
    vendor @(
        Common.ValueListWithFixedValues : false,
        Common.Text            : vendor.name,
        Common.TextArrangement : #TextOnly,
        Common.ValueList : {
            $Type          : 'Common.ValueListType',
            CollectionPath : 'Vendors',
            Parameters     : [
                { $Type : 'Common.ValueListParameterInOut',       LocalDataProperty : vendor_ID,    ValueListProperty : 'ID' },
                { $Type : 'Common.ValueListParameterDisplayOnly', ValueListProperty : 'vendorCode' },
                { $Type : 'Common.ValueListParameterDisplayOnly', ValueListProperty : 'name' },
                { $Type : 'Common.ValueListParameterDisplayOnly', ValueListProperty : 'category' },
            ],
        },
    );

    // prReference @(
    //     Common.Text            : prReference.itemDescription,
    //     Common.TextArrangement : #TextOnly,
    //     Common.ValueList : {
    //         $Type          : 'Common.ValueListType',
    //         CollectionPath : 'PurchaseRequisitions',
    //         Parameters     : [
    //             { $Type : 'Common.ValueListParameterInOut',       LocalDataProperty : prReference_ID,  ValueListProperty : 'ID' },
    //             { $Type : 'Common.ValueListParameterDisplayOnly', ValueListProperty : 'itemDescription' },
    //             { $Type : 'Common.ValueListParameterDisplayOnly', ValueListProperty : 'department' },
    //             { $Type : 'Common.ValueListParameterDisplayOnly', ValueListProperty : 'status' },
    //         ],
    //     },
    // );
};


annotate service.PurchaseOrders with {
    status @(
        Common.ValueListWithFixedValues: true,
        Common.ValueList: {
            CollectionPath: 'OrdersView',
            Parameters: [
                {
                    $Type: 'Common.ValueListParameterInOut',
                    LocalDataProperty: status,
                    ValueListProperty: 'status'
                }
            ]
        }
    );
};


annotate service.Vendors with {
    paymentTerms @(
        Common.ValueListWithFixedValues: true,
        Common.ValueList: {
            CollectionPath: 'paymentView',
            Parameters: [
                {
                    $Type: 'Common.ValueListParameterInOut',
                    LocalDataProperty: paymentTerms,
                    ValueListProperty: 'paymentTerms'
                }
            ]
        },
        Common.Label : 'vendor/paymentTerms',
    );
};

// PO LINE ITEMS

annotate service.POLineItems with @(

    UI.HeaderInfo : {
        TypeName       : 'Line Item',
        TypeNamePlural : 'Line Items',
        Title          : { $Type : 'UI.DataField', Value : description },
        Description    : { $Type : 'UI.DataField', Value : quantity },
    },

    UI.LineItem : [
        { $Type : 'UI.DataField', Label : 'Description',   Value : description },
        { $Type : 'UI.DataField', Label : 'Quantity',      Value : quantity },
        { $Type : 'UI.DataField', Label : 'Unit Price',    Value : unitPrice },
        { $Type : 'UI.DataField', Label : 'Line Total',    Value : lineTotal },
        { $Type : 'UI.DataField', Label : 'Delivered Qty', Value : deliveryQty },
    ],

    UI.FieldGroup #LineItemDetails : {
        $Type : 'UI.FieldGroupType',
        Label : 'Line Item Details',
        Data  : [
            { $Type : 'UI.DataField', Label : 'Description',   Value : description },
            { $Type : 'UI.DataField', Label : 'Quantity',      Value : quantity },
            { $Type : 'UI.DataField', Label : 'Unit Price',    Value : unitPrice },
            { $Type : 'UI.DataField', Label : 'Delivered Qty', Value : deliveryQty },
        ],
    },

    UI.Facets : [
        { $Type : 'UI.ReferenceFacet', ID : 'LineItemDetailsFacet', Label : 'Line Item Details', Target : '@UI.FieldGroup#LineItemDetails' },
    ],
);
annotate service.POLineItems with {
    quantity @Common.Label : 'lineItems/quantity'
};

annotate service.PurchaseOrders with {
    ID @Common.Label : 'ID'
};

