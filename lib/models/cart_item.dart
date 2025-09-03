class CartItem {
  final String id;
  final String productId;
  final String name;
  final String image;
  final double price;
  final double discountPercent;
  final String quantity;
  int count;

  CartItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.image,
    required this.price,
    required this.discountPercent,
    required this.quantity,
    this.count = 1,
  });

  double get discountedPrice => price * (1 - discountPercent / 100);
  double get totalPrice => discountedPrice * count;
  double get originalTotalPrice => price * count;
  double get savings => originalTotalPrice - totalPrice;

  CartItem copyWith({
    String? id,
    String? productId,
    String? name,
    String? image,
    double? price,
    double? discountPercent,
    String? quantity,
    int? count,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      image: image ?? this.image,
      price: price ?? this.price,
      discountPercent: discountPercent ?? this.discountPercent,
      quantity: quantity ?? this.quantity,
      count: count ?? this.count,
    );
  }
}
