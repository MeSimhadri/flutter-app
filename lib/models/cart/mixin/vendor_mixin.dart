import 'cart_mixin.dart';

mixin VendorMixin on CartMixin {
  List<dynamic> selectedShippingMethods = [];

  void setSelectedMethods(List<dynamic> selected) {
    selectedShippingMethods = selected;
  }

  bool isDisableMultiVendorCheckoutValid(productsInCart, getProductById) {
    var _isValid = true;
    var _storeId;
    if (productsInCart.keys.isNotEmpty) {
      productsInCart.keys.forEach((id) {
        final product = getProductById(id);
        if (_storeId == null) {
          _storeId = product?.store?.id;
        } else {
          if (_storeId != product?.store?.id) {
            _isValid = false;
          }
        }
      });
    }
    return _isValid;
  }
}
