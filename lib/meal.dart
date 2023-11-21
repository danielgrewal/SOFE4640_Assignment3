import 'package:flutter/material.dart';
import 'package:flutter_calories_calc_app/database.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';

class MealScreen extends StatefulWidget {
  @override
  _MealScreenState createState() => _MealScreenState();
}

class _MealScreenState extends State<MealScreen> {
  List<Map<String, dynamic>> foodItems = [];
  List<FoodEntry> foodEntries = [];
  int? selectedFoodItemId;
  TextEditingController searchController = TextEditingController();
  int targetDailyCalories = 2000; // Set your default value
  DateTime? selectedDate; // Make selectedDate nullable

  int calculateTotalCalories() {
    return foodEntries.fold(0, (sum, entry) => sum + entry.calories);
  }

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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'No Date Selected';
    } else {
      return 'Selected Date: ${date.year}-${date.month}-${date.day}';
    }
  }

  void _addRow() async {
    if (selectedFoodItemId == null) {
      return; // Don't add a row if no food item is selected
    }

    // Fetch calorie count for the selected food item
    final selectedFoodItem =
        foodItems.firstWhere((item) => item['id'] == selectedFoodItemId);
    final int calories = selectedFoodItem['calories'] as int;

    setState(() {
      // Add a new entry to the table with the selected food item and its calorie count
      foodEntries
          .add(FoodEntry(foodItemId: selectedFoodItemId!, calories: calories));
      // Clear the search field and selected item after adding a row
      searchController.clear();
      selectedFoodItemId = null;
    });
  }

  void _saveMealToDatabase() async {
    if (selectedDate == null) {
      // Show an error message if no date is selected
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a date.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (foodEntries.isEmpty) {
      // Show an error message if no food items are added to the meal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cannot save a meal with no food items.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (calculateTotalCalories() > targetDailyCalories) {
      // Show an error message if the total calories exceed the target
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Total meal calories cannot exceed the daily target.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final database = FoodDatabase.instance;
    final db = await database.database;

    // Calculate total calories for the meal
    final totalCalories = calculateTotalCalories();

    // Format the selected date only if it's not null
    final formattedDate =
        "${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}";

    // Get the list of food item IDs for the meal
    final foodItemIds = foodEntries.map((entry) => entry.foodItemId).toList();

    // Insert the meal into the database
    await database.insertMeal(totalCalories, formattedDate, foodItemIds);

    // Clear the food entries list
    setState(() {
      foodEntries.clear();
    });

    // Display a success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Meal saved to the database!'),
        backgroundColor: Colors.green,
      ),
    );

    // Navigate back to the main screen
    Navigator.pop(context);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Save Meal To Database'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Target Daily Calories',
                ),
                onChanged: (value) {
                  setState(() {
                    targetDailyCalories = int.tryParse(value) ?? 0;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      // Open the date picker when the button is pressed
                      _selectDate(context);
                    },
                    child: Text('Select Date'),
                  ),
                  SizedBox(width: 10),
                  Text(
                    // Display the selected date or a placeholder
                    _formatDate(selectedDate),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: AutoCompleteTextField<Map<String, dynamic>>(
                key: GlobalKey<
                    AutoCompleteTextFieldState<Map<String, dynamic>>>(),
                controller: searchController,
                clearOnSubmit: false,
                suggestions: foodItems,
                itemFilter: (item, query) {
                  return item['name']
                          .toLowerCase()
                          .contains(query.toLowerCase()) ||
                      query.toLowerCase().contains(item['name'].toLowerCase());
                },
                itemSorter: (a, b) {
                  return a['name'].compareTo(b['name']);
                },
                itemSubmitted: (item) {
                  setState(() {
                    selectedFoodItemId = item['id'] as int;
                  });
                },
                itemBuilder: (context, item) {
                  return ListTile(
                    title: Text(item['name'] as String),
                  );
                },
                decoration: InputDecoration(
                  labelText: 'Search for a Food Item',
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Add a new row when the button is pressed
                _addRow();
              },
              child: Text('Add Food Item To Meal'),
            ),
            SizedBox(height: 20),
            foodEntries.isEmpty
                ? Text(
                    'No Food Items Added To This Meal') // Display "Empty" when there are no rows
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
                              foodItems.firstWhere(
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
              'Total Meal Calories: ${calculateTotalCalories()}',
              style: TextStyle(
                fontSize: 16,
                color: calculateTotalCalories() > targetDailyCalories
                    ? Colors.red
                    : Colors.green,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Save the meal to the database when the button is pressed
                _saveMealToDatabase();
              },
              child: Text('Save Meal To Database'),
            ),
          ],
        ),
      ),
    );
  }
}

class FoodEntry {
  final int foodItemId;
  final int calories;

  FoodEntry({required this.foodItemId, required this.calories});
}
