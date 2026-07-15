import 'package:flutter/material.dart';
import 'food_model.dart';

class FoodCard extends StatelessWidget {

  final Food food;
  final VoidCallback onAdd;

  const FoodCard({
    super.key,
    required this.food,
    required this.onAdd,
  });


  @override
  Widget build(BuildContext context) {

    return Card(
      child: ListTile(

        title: Text(food.name),

        subtitle: Text(
          "\$${food.price}",
        ),

        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          onPressed: onAdd,
          child: Text("Add" , style: TextStyle(color: Colors.white),),
        ),

      ),
    );
  }
}