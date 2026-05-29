using ProcurementService as service from '../../srv/procurement-service';

// PURCHASE REQUISITIONS

annotate service.PurchaseRequisitions with @(

    UI.HeaderInfo : {
        TypeName       : 'Purchase Requisition',
        TypeNamePlural : 'Purchase Requisitions',
        Title          : { $Type : 'UI.DataField', Value : itemDescription },
        Description    : { $Type : 'UI.DataField', Value : department },
    },
    

    UI.HeaderFacets : [
        { $Type : 'UI.ReferenceFacet', Target : '@UI.DataPoint#Status' },
        { $Type : 'UI.ReferenceFacet', Target : '@UI.DataPoint#Quantity' },
        { $Type : 'UI.ReferenceFacet', Target : '@UI.DataPoint#EstimatedCost' },
    ],

    UI.DataPoint #Status : {
        Value       : status,
        Criticality : (status = 'Accepted' ? 3 : status = 'Submitted' ? 2 : status = 'Rejected' ? 1 : 0),
        Title       : 'Status',
    },
     UI.DataPoint #EstimatedCost : {
        Value : estimatedUnitCost,
        Title : 'Estimated Unit Cost',
    },

    UI.DataPoint #Quantity : {
        Value : quantity,
        Title : 'Quantity',
    },

    UI.LineItem : [
        { $Type : 'UI.DataField', Label : 'Department',       Value : department },
        { $Type : 'UI.DataField', Label : 'Item Description', Value : itemDescription },
        { $Type : 'UI.DataField', Label : 'Quantity',         Value : quantity },
        { $Type : 'UI.DataField', Label : 'Status',           Value : status, Criticality : (status = 'Accepted' ? 3 : status = 'Submitted' ? 2 : status = 'Rejected' ? 1 : 0),},
       { 
        $Type  : 'UI.DataFieldForAction', 
        Action : 'ProcurementService.submitPR',  
        Label  : 'Submit',
        Inline : true,
    }],

    UI.SelectionFields : [ department, status, itemDescription ],

    UI.FieldGroup #GeneralInfo : {
        $Type : 'UI.FieldGroupType',
        Label : 'General Information',
        Data  : [
            { $Type : 'UI.DataField', Label : 'Department',          Value : department },
            { $Type : 'UI.DataField', Label : 'Item Description',    Value : itemDescription },
            { $Type : 'UI.DataField', Label : 'Quantity',            Value : quantity },
            { $Type : 'UI.DataField', Label : 'Estimated Unit Cost', Value : estimatedUnitCost },
            {$Type : 'UI.DataField',Label : 'Requester',Value : requester.firstName}
           
        ],
    },

    UI.Facets : [
        {
            $Type  : 'UI.CollectionFacet',
            ID     : 'PRDetails',
            Label  : 'PR Details',
            Facets : [
                {
                     $Type : 'UI.ReferenceFacet', 
                     ID : 'GeneralInfoFacet',  
                     Label : 'General Information',  
                     Target : '@UI.FieldGroup#GeneralInfo' 
                },
              
            ],
        },       
    ],
);


annotate service.PurchaseRequisitions with {
    status @(
        Common.ValueListWithFixedValues: true,
        Common.ValueList: {
            CollectionPath: 'StatusView',
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

annotate service.PurchaseRequisitions with {
    department @(
        Common.ValueListWithFixedValues: true,
        Common.ValueList: {
            CollectionPath: 'DeptView',
            Parameters: [
                {
                    $Type: 'Common.ValueListParameterInOut',
                    LocalDataProperty: department,
                    ValueListProperty: 'department'
                }
            ]
        }
    );
};
annotate service.Users with {
    firstName @Common.FieldControl : #ReadOnly
};

