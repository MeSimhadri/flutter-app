import 'package:localstorage/localstorage.dart';
import '../../../models/entities/index.dart';
import '../../../models/entities/paging_response.dart';
import '../../../services/paging/paging_with_user_repository.dart';

class ListOrderRepository extends PagingWithUserRepository<Order> {
  ListOrderRepository({required User user}) : super(user);

  @override
  Future<PagingResponse<Order>>? Function({dynamic cursor, User? user})
      get requestApi {
    return service.api.getMyOrders;
    // if (user.id == null) {
    //   return getLocalOrders;
    // } else {
    //   return service.api.getMyOrders;
    // }
  }

  Future<PagingResponse<Order>> getLocalOrders(
      {User? user, dynamic cursor}) async {
    final storage = LocalStorage('data_order');
    var items = storage.getItem('orders');
    var list = <Order>[];
    if (items != null && cursor == 1) {
      for (var item in items) {
        list.add(Order.fromLocalJson(item));
      }
    }
    return PagingResponse(data: list);
  }
}
