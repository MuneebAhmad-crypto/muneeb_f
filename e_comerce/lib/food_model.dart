class Food {
  String name;
  double price;
  int quantity;

  Food({
    required this.name,
    required this.price,
    this.quantity = 0,
  });
}