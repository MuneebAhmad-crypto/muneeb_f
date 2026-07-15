import 'package:flutter/material.dart';
import 'food_model.dart';
import 'food_card.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Food> foods = [
    Food(name: "Pizza", price: 10),
    Food(name: "Burger", price: 5),
    Food(name: "Fries", price: 3),
    Food(name: "Drink", price: 2),
  ];

  TextEditingController nameController = TextEditingController();

  double get totalBill {
    double total = 0;

    for (var food in foods) {
      total += food.price * food.quantity;
    }

    return total;
  }

  void addFood(Food food) {
    setState(() {
      food.quantity++;
    });
  }

  void confirmOrder() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Order Confirmed"),
          content: Text(
            "Name: ${nameController.text}\n"
            "Bill: \$${totalBill.toStringAsFixed(2)}",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);

                setState(() {
                  // Reset all quantities
                  for (var food in foods) {
                    food.quantity = 0;
                  }

                  // Clear name
                  nameController.clear();
                });
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade200,
      appBar: AppBar(
        backgroundColor: Colors.black38,
        title: Text("Food Shopping 🛒", style: TextStyle(color: Colors.white)),
      ),

      body: Padding(
        padding: EdgeInsets.all(16),

        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: foods.length,

                itemBuilder: (context, index) {
                  return FoodCard(
                    food: foods[index],

                    onAdd: () {
                      addFood(foods[index]);
                    },
                  );
                },
              ),
            ),

            Text(
              "Total: \$$totalBill",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),

            TextField(
              controller: nameController,

              decoration: InputDecoration(
                labelText: "Enter Name",

                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 10),

            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: confirmOrder,

              child: Text("Proceed To Pay", style:  TextStyle(color: Colors.white)),
            ),
        ],
      ),
      ),
    );
  }
}
