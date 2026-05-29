using { procurement.db as db } from '../db/schema';

@requires: 'authenticated-user'
service ReceiptService {
    
    @restrict: [
        { grant: ['READ'], to: ['Requester','Approver','Buyer','Administrator'] },
        { grant: ['CREATE'], to: ['Requester','Administrator'] }
    ]
    @odata.draft.enabled
    @cds.redirection.target
    entity GoodsReceipts as projection on db.GoodsReceipts
    actions{
        @restrict: [{ to: ['Requester','Administrator'] }]
        @Core.OperationAvailable: {
        $edmJson: {
            $And: [
                { $Ne: [ { $Path: 'status' }, 'Posted' ] },
                { $Ne: [ { $Path: 'status' }, 'Reversed' ] }]}
        }
        action confirmReceipt( quantityReceived : Decimal(13,3)) returns GoodsReceipts;

    };

    @restrict: [
        { grant: ['READ'], to: ['Requester','Approver','Buyer','Administrator'] },
        { grant: ['CREATE'], to: ['Requester','Administrator'] }
    ]
    
    entity GoodsReceiptItems as projection on db.GoodsReceiptItems;
    entity PurchaseOrders as projection on db.PurchaseOrders;
    entity POLineItems as projection on db.POLineItems;
    @readonly
    entity GRView as projection on db.GRView;
    @restrict: [{ to: ['Approver','Buyer','Administrator'] }]
    function getPendingDeliveries() returns array of GoodsReceipts;
}