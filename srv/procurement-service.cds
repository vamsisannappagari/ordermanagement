using { procurement.db as db } from '../db/schema';

@requires: 'authenticated-user'
service ProcurementService {

    @restrict: [
        { grant: ['READ'], to: ['Requester','Approver','Buyer','Administrator'] },
        { grant: ['CREATE','UPDATE','DELETE'], to: ['Buyer','Administrator'] }
    ]
    @cds.redirection.target
    entity Vendors as projection on db.Vendors;

    @cds.redirection.target
    @odata.draft.enabled
    @restrict: [
        { grant: ['READ'],to: ['Requester','Approver','Buyer','Administrator'] },
        { grant: ['CREATE','UPDATE'], to: ['Requester'] },
        { grant: ['DELETE'], to: ['Administrator'] }
    ]
    entity PurchaseRequisitions as projection on db.PurchaseRequisitions
    actions{
    @restrict: [{ to: 'Requester' }]
    @Core.OperationAvailable: {
    $edmJson: {
        $And: [
            { $Ne: [ { $Path: 'status' }, 'Submitted' ] },
            { $Ne: [ { $Path: 'status' }, 'Accepted' ] },
            { $Ne: [ { $Path: 'status' }, 'Rejected' ] }]},
    }
    action submitPR() returns String;
    };

    @restrict: [
        { grant: ['READ'], to: ['Requester','Approver','Buyer','Administrator'] },
        { grant: ['CREATE','UPDATE'], to: ['Buyer'] },
        { grant: ['DELETE'], to: ['Administrator'] }
    ]
    @cds.redirection.target
    @odata.draft.enabled
    entity PurchaseOrders as projection on db.PurchaseOrders
    actions{
        @restrict: [{ to: ['Approver', 'Administrator'] }]
        @Core.OperationAvailable: {
        $edmJson: {
            $And: [
                { $Ne: [ { $Path: 'status' }, 'Rejected' ] },
                { $Ne: [ { $Path: 'status' }, 'Approved' ] }]}
        }
        action approvePR() returns String;  
        @restrict: [{ to: ['Approver', 'Administrator'] }] 
        @Core.OperationAvailable: {
        $edmJson: {
            $And: [
                { $Ne: [ { $Path: 'status' }, 'Approved' ] },
                { $Ne: [ { $Path: 'status' }, 'Rejected' ] }]},
        }      
        action rejectPR(reason : String) returns String;  
        @restrict: [{ to: ['Buyer','Administrator'] }]
        @Core.OperationAvailable: {
        $edmJson: {
            $And: [
                { $Ne: [ { $Path: 'status' }, 'Rejected' ] },
                { $Ne: [ { $Path: 'status' }, 'Approved' ] }]}
        }
        action approvePO() returns String;
        @restrict: [{ to: ['Approver','Buyer','Administrator'] }]
        @Core.OperationAvailable: {
        $edmJson: {
            $And: [
                { $Ne: [ { $Path: 'status' }, 'Rejected' ] },
                { $Ne: [ { $Path: 'status' }, 'Approved' ] }]}
        }
        action rejectPO(reason : String) returns String;
    };

    @restrict: [
        { grant: ['READ'], to: ['Requester','Approver','Buyer','Administrator'] },
        { grant: ['CREATE','UPDATE','DELETE'], to: ['Buyer','Administrator'] }
    ]
    entity POLineItems as projection on db.POLineItems;
    @restrict: [{ grant: '*', to: 'Administrator' }]
    entity Users as projection on db.Users;

    @restrict: [{ grant: 'READ', to: ['Approver','Administrator'] }]
    entity NotificationLogs as projection on db.NotificationLogs;

    entity GoodsReceipts as projection on db.GoodsReceipts;

    @restrict: [{ to: 'Buyer' }]
    action createPO  (prID : UUID, vendorID : UUID) returns String;
    
    entity DeptView as projection on db.DeptView;
    entity StatusView as projection on db.StatusView;
    entity OrdersView as projection on db.OrdersView;
    entity paymentView as projection on db.paymentView;
    
    @readonly
    @Analytics.query: true
    @Aggregation.ApplySupported: {
        Transformations      : [
            'aggregate', 'groupby', 'filter',
            'orderby', 'top', 'skip', 'search'
        ],
        Rollup               : #None,
        PropertyRestrictions : true,
        GroupableProperties  : [vendorCode, name, category, status],
        AggregatableProperties: [
            { Property: rating      },
            { Property: totalOrders }
        ]
    }
    @Analytics.AggregatedProperty #avgRating: {
        Name                : 'avgRating',
        AggregationMethod   : 'average',
        AggregatableProperty: 'rating',
        ![@Common.Label]    : 'Average Rating'
    }
    @Analytics.AggregatedProperty #sumOrders: {
        Name                : 'sumOrders',
        AggregationMethod   : 'sum',
        AggregatableProperty: 'totalOrders',
        ![@Common.Label]    : 'Total Orders'
    }

    entity VendorPerformance as projection on db.VendorPerformance ;

}