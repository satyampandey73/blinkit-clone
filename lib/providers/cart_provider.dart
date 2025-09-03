import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/product_model.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => [..._items];

  int get itemCount => _items.fold(0, (sum, item) => sum + item.count);

  double get totalAmount => _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get originalTotalAmount => _items.fold(0.0, (sum, item) => sum + item.originalTotalPrice);

  double get totalSavings => originalTotalAmount - totalAmount;

  bool get isEmpty => _items.isEmpty;

  void addItem(ProductModel product) {
    final existingIndex = _items.indexWhere((item) => item.productId == product.id);
    
    if (existingIndex >= 0) {
      _items[existingIndex] = _items[existingIndex].copyWith(
        count: _items[existingIndex].count + 1,
      );
    } else {
      _items.add(
        CartItem(
          id: DateTime.now().toString(),
          productId: product.id ?? '',
          name: product.name,
          image: product.images.isNotEmpty ? product.images[0] : '',
          price: product.price,
          discountPercent: product.discountPercent,
          quantity: product.quantity,
        ),
      );
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.removeWhere((item) => item.productId == productId);
    notifyListeners();
  }

  void updateQuantity(String productId, int newCount) {
    final existingIndex = _items.indexWhere((item) => item.productId == productId);
    
    if (existingIndex >= 0) {
      if (newCount <= 0) {
        _items.removeAt(existingIndex);
      } else {
        _items[existingIndex] = _items[existingIndex].copyWith(count: newCount);
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
