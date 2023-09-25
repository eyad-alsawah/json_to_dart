import 'package:json_annotation/json_annotation.dart';
part 'output.g.dart';

@JsonSerializable()
class Eyad {
  @JsonKey(name: 'store')
  Store store;
  @JsonKey(name: 'customers')
  List<CustomersItem> customers;
  @JsonKey(name: 'orders')
  List<OrdersItem> orders;

  Eyad(
    this.store,
    this.customers,
    this.orders,
  );

  factory Eyad.fromJson(Map<String, dynamic> json) => _$EyadFromJson(json);

  Map<String, dynamic> toJson() => _$EyadToJson(this);
}

@JsonSerializable()
class OrdersItem {
  @JsonKey(name: 'order_id')
  String orderId;
  @JsonKey(name: 'customer_id')
  int customerId;
  @JsonKey(name: 'order_date')
  String orderDate;
  @JsonKey(name: 'items')
  List<ItemsItem> items;
  @JsonKey(name: 'total')
  double total;

  OrdersItem(
    this.orderId,
    this.customerId,
    this.orderDate,
    this.items,
    this.total,
  );

  factory OrdersItem.fromJson(Map<String, dynamic> json) =>
      _$OrdersItemFromJson(json);

  Map<String, dynamic> toJson() => _$OrdersItemToJson(this);
}

@JsonSerializable()
class ItemsItem {
  @JsonKey(name: 'product_id')
  String productId;
  @JsonKey(name: 'quantity')
  int quantity;

  ItemsItem(
    this.productId,
    this.quantity,
  );

  factory ItemsItem.fromJson(Map<String, dynamic> json) =>
      _$ItemsItemFromJson(json);

  Map<String, dynamic> toJson() => _$ItemsItemToJson(this);
}

@JsonSerializable()
class CustomersItem {
  @JsonKey(name: 'id')
  int id;
  @JsonKey(name: 'name')
  String name;
  @JsonKey(name: 'email')
  String email;
  @JsonKey(name: 'address')
  String address;

  CustomersItem(
    this.id,
    this.name,
    this.email,
    this.address,
  );

  factory CustomersItem.fromJson(Map<String, dynamic> json) =>
      _$CustomersItemFromJson(json);

  Map<String, dynamic> toJson() => _$CustomersItemToJson(this);
}

@JsonSerializable()
class Store {
  @JsonKey(name: 'name')
  String name;
  @JsonKey(name: 'location')
  String location;
  @JsonKey(name: 'products')
  List<ProductsItem> products;

  Store(
    this.name,
    this.location,
    this.products,
  );

  factory Store.fromJson(Map<String, dynamic> json) => _$StoreFromJson(json);

  Map<String, dynamic> toJson() => _$StoreToJson(this);
}

@JsonSerializable()
class ProductsItem {
  @JsonKey(name: 'id')
  String id;
  @JsonKey(name: 'name')
  String name;
  @JsonKey(name: 'description')
  String description;
  @JsonKey(name: 'price')
  double price;
  @JsonKey(name: 'inventory')
  int inventory;

  ProductsItem(
    this.id,
    this.name,
    this.description,
    this.price,
    this.inventory,
  );

  factory ProductsItem.fromJson(Map<String, dynamic> json) =>
      _$ProductsItemFromJson(json);

  Map<String, dynamic> toJson() => _$ProductsItemToJson(this);
}
