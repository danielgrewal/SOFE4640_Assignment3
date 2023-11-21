import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditScreen extends StatefulWidget {
  final Map<String, dynamic> mealRecord;

  EditScreen({required this.mealRecord});

  @override
  _EditScreenState createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  late TextEditingController _foodItemsController;
  late TextEditingController _totalCaloriesController;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with current values
    final foodItems = widget.mealRecord['foodItems'];
    _foodItemsController = TextEditingController(
      text: foodItems != null ? foodItems.join(', ') : '',
    );

    _totalCaloriesController = TextEditingController(
      text: widget.mealRecord['total_calories'].toString(),
    );
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
              'Edit Meal Entry for Date: ${DateFormat('yyyy-MM-dd').format(
                DateTime.parse(widget.mealRecord['date'].toString()),
              )}',
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
      'id': widget.mealRecord['id'],
      'date': widget.mealRecord['date'],
      'foodItems': foodItems,
      'total_calories': totalCalories,
    };

    // TODO: Implement the logic to update the database with the updatedRecord

    // Navigate back to the main screen
    Navigator.pop(context);
  }
}
