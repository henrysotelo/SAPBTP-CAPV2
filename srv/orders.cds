using com.training as training from '../db/training';

service ManageOrders {
    entity GetOrders as projection on training.Orders;
    entity CreateOrder as projection on training.Orders;
    entity UpdateOrder as projection on training.Orders;
    entity DeleteOrder as projection on training.Orders;
}
