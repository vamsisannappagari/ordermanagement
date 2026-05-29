using ProcurementService as service from '../../srv/procurement-service';

//  Property-level Annotations
annotate service.VendorPerformance with {
    vendorCode  @Analytics.Dimension : true
                @Core.Immutable      : true
                @Common.Label        : 'Vendor Code';

    name        @Analytics.Dimension : true
                @Common.Label        : 'Vendor Name';

    category    @Analytics.Dimension : true
                @Common.Label        : 'Category';

    status      @Analytics.Dimension : true
                @Common.Label        : 'Status';

    rating      @Analytics.Measure   : true
                @Common.Label        : 'Rating';

    totalOrders @Analytics.Measure   : true
                @Common.Label        : 'Total Orders';

};

// UI Annotations 

annotate service.VendorPerformance with @(

    UI.UpdateHidden : false,
    UI.DeleteHidden : false,
    UI.CreateHidden : false,

    //  Filter Bar
    UI.SelectionFields: [
        category,
        status
    ],


    // Aggregated Property (used by the chart)
    Analytics.AggregatedProperty #avgRating: {
        $Type               : 'Analytics.AggregatedPropertyType',
        Name                : 'avgRating',
        AggregationMethod   : 'average',
        AggregatableProperty: rating
    },


    //  Chart 
    UI.Chart: {
        $Type              : 'UI.ChartDefinitionType',
        Title              : 'Vendor Performance',
        ChartType          : #Bar,
        Dimensions         : [name],
        DimensionAttributes: [{
            $Type    : 'UI.ChartDimensionAttributeType',
            Dimension: name,
            Role     : #Category
        }],
        DynamicMeasures    : ['@Analytics.AggregatedProperty#avgRating'],
        MeasureAttributes  : [{
            $Type         : 'UI.ChartMeasureAttributeType',
            DynamicMeasure: '@Analytics.AggregatedProperty#avgRating',
            Role          : #Axis1
        }]
    },


    //  DataPoint — star rating with criticality color 
    UI.DataPoint #vendorRating: {
        $Type        : 'UI.DataPointType',
        Title        : 'Vendor Rating',
        Value        : rating,
        Criticality  : criticality,
        Visualization: #Rating,
        MaxValue     : 5,
        TargetValue  : 5
    },


    // Object Page — Header 
    UI.HeaderInfo: {
        $Type         : 'UI.HeaderInfoType',
        TypeName      : 'Vendor',
        TypeNamePlural: 'Vendors',
        Title        : {
            $Type: 'UI.DataField',
            Value: name
        },
        Description  : {
            $Type: 'UI.DataField',
            Value: vendorCode
        },
        TypeImageUrl  : 'sap-icon://supplier'
    },


    //  Object Page — Header Facet
    UI.HeaderFacets: [{
        $Type : 'UI.ReferenceFacet',
        Label : 'Rating',
        ID    : 'HeaderRating',
        Target: '@UI.DataPoint#vendorRating'
    }],


    //  Object Page — Field Groups (body sections) 
    UI.FieldGroup #overview: {
        $Type : 'UI.FieldGroupType',
        Label : 'Overview',
        Data  : [
            {
                $Type: 'UI.DataField',
                Value: vendorCode,
                Label: 'Vendor Code'
            },
            {
                $Type: 'UI.DataField',
                Value: name,
                Label: 'Vendor Name'
            },
            {
                $Type: 'UI.DataField',
                Value: category,
                Label: 'Category'
            },
            {
                $Type: 'UI.DataField',
                Value: status,
                Label: 'Status',
                Criticality : ( status = 'Active' ? 3 : status = 'Inactive' ? 2 : status = 'Blocked' ? 1 :status ='Pending' ? 5 : 0)
            }
        ]
    },

    UI.FieldGroup #performance: {
        $Type : 'UI.FieldGroupType',
        Label : 'Performance',
        Data  : [
            {
                $Type : 'UI.DataFieldForAnnotation',
                Target: '@UI.DataPoint#vendorRating',
                Label : 'Rating'
            },
            {
                $Type: 'UI.DataField',
                Value: totalOrders,
                Label: 'Total Orders'
            }
        ]
    },


    //  Object Page — Facets (wires field groups onto the page) 
    UI.Facets: [{
        $Type : 'UI.CollectionFacet',
        Label : 'General Information',
        ID    : 'GeneralInfo',
        Facets: [
            {
                $Type : 'UI.ReferenceFacet',
                Label : 'Overview',
                ID    : 'Overview',
                Target: '@UI.FieldGroup#overview'
            },
            {
                $Type : 'UI.ReferenceFacet',
                Label : 'Performance',
                ID    : 'Performance',
                Target: '@UI.FieldGroup#performance'
            }
        ]
    }],


    //  List Report — Table 
    UI.LineItem: [
        {
            $Type      : 'UI.DataField',
            Value      : name,
            Label      : 'Vendor',
           
             
        },
        {
            $Type: 'UI.DataField',
            Value: category,
            Label: 'Category'
        },
        {
            $Type: 'UI.DataField',
            Value: status,
            Label: 'Status',
            Criticality : ( status = 'Active' ? 3 : status = 'Inactive' ? 2 : status = 'Blocked' ? 1 :status ='Pending' ? 5 : 0)
        }
    ],


    //  Presentation Variant 
    UI.PresentationVariant: {
        $Type         : 'UI.PresentationVariantType',
        Visualizations: [
            '@UI.Chart',
            '@UI.LineItem'
        ],
        SortOrder     : [{
            Property  : rating,
            Descending: true
        }]
    }
);