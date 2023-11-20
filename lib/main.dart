import 'package:flutter/material.dart';
import 'package:flutter_calories_calc_app/database.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Item Selector',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> foodItems = [];
  List<FoodEntry> foodEntries = [];
  int? selectedFoodItemId;

  @override
  void initState() {
    super.initState();
    _loadFoodItems();
  }

  Future<void> _loadFoodItems() async {
    final database = FoodDatabase.instance;
    final db = await database.database;

    final List<Map<String, dynamic>> items = await db.query('food_items');

    setState(() {
      foodItems = items;
    });
  }

  void _addRow() async {
    if (selectedFoodItemId == null) {
      return; // Don't add a row if no food item is selected
    }

    // Fetch calorie count for the selected food item
    final selectedFoodItem = foodItems.firstWhere((item) => item['id'] == selectedFoodItemId);
    final int calories = selectedFoodItem['calories'] as int;

    setState(() {
      // Add a new entry to the table with the selected food item and its calorie count
      foodEntries.add(FoodEntry(foodItemId: selectedFoodItemId!, calories: calories));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Food Item Selector'),
      ),
      body: Column(
        children: <Widget>[
          DropdownButton<int>(
            value: selectedFoodItemId,
            hint: Text('Select a Food Item'),
            onChanged: (int? newValue) {
              setState(() {
                selectedFoodItemId = newValue;
              });
            },
            items: foodItems
                .map<DropdownMenuItem<int>>((Map<String, dynamic> item) {
              return DropdownMenuItem<int>(
                value: item['id'] as int,
                child: Text(item['name'] as String),
              );
            }).toList(),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Add a new row when the button is pressed
              _addRow();
            },
            child: Text('Add Row'),
          ),
          SizedBox(height: 20),
          foodEntries.isEmpty
              ? Text('Empty') // Display "Empty" when there are no rows
              : DataTable(
            columns: [
              DataColumn(label: Text('Food Item')),
              DataColumn(label: Text('Calories')),
            ],
            rows: foodEntries.map<DataRow>((FoodEntry entry) {
              return DataRow(
                cells: [
                  DataCell(
                    Text(
                      foodItems
                          .firstWhere(
                            (item) => item['id'] == entry.foodItemId,
                        orElse: () => {'name': 'Unknown'},
                      )['name'] as String,
                    ),
                  ),
                  DataCell(
                    Text(
                      entry.calories.toString(),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
          SizedBox(height: 20),
          Text(
            'Total Calories: ${foodEntries.fold(0, (sum, entry) => sum + entry.calories)}',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class FoodEntry {
  final int foodItemId;
  final int calories;

  FoodEntry({required this.foodItemId, required this.calories});
}
