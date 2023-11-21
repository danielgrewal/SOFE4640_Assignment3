import 'package:flutter/material.dart';
import 'package:flutter_calories_calc_app/database.dart';

class EditScreen extends StatefulWidget {
  final int mealRecordId; // Change the type to int

  EditScreen({required this.mealRecordId});

  @override
  _EditScreenState createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  late TextEditingController _foodItemsController;
  late TextEditingController _totalCaloriesController;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with empty values
    _foodItemsController = TextEditingController();
    _totalCaloriesController = TextEditingController();

    // Load meal record data
    _loadMealRecord();
  }

  Future<void> _loadMealRecord() async {
    final database = FoodDatabase.instance;
    final Map<String, dynamic> record =
    await database.getMealRecordById(widget.mealRecordId);

    // Use the retrieved record to set initial values for controllers
    setState(() {
      _totalCaloriesController.text = record['total_calories'].toString();
    });

    // Get the food items for the meal record
    final List<int> foodItemIds = await database.getFoodItemsForMeal(widget.mealRecordId);
    final List<Map<String, dynamic>> foodItems =
    await database.getFoodItemsByIds(foodItemIds);

    // Join the food items into a comma-separated string and update the controller
    setState(() {
      _foodItemsController.text = foodItems.map((item) => item['name']).join(', ');
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Meal Entry'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Edit Meal Entry',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _foodItemsController,
              decoration: InputDecoration(labelText: 'Food Items'),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _totalCaloriesController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Total Calories'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Handle the save button press and update the meal record
                _saveChanges();
              },
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveChanges() {
    // Retrieve the edited values from controllers
    final List<String> foodItems =
    _foodItemsController.text.split(',').map((e) => e.trim()).toList();
    final int totalCalories = int.tryParse(_totalCaloriesController.text) ?? 0;

    // Update the meal record with edited values
    final Map<String, dynamic> updatedRecord = {
      'id': widget.mealRecordId, // Use the received 'id'
      'foodItems': foodItems,
      'total_calories': totalCalories,
    };

    // TODO: Implement the logic to update the database with the updatedRecord

    // Navigate back to the main screen
    Navigator.pop(context);
  }
}
