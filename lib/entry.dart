import 'package:flutter/material.dart';
import 'package:flutter_calories_calc_app/database.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:intl/intl.dart';

// Stateful widget for new entry page
class NewEntryScreen extends StatefulWidget {
  @override
  _NewEntryScreenState createState() => _NewEntryScreenState();
}

class _NewEntryScreenState extends State<NewEntryScreen> {
  // Lists for food items and database entries
  List<Map<String, dynamic>> foodItems = [];
  List<FoodEntry> foodEntries = [];

  // Variables for user input
  int? selectedFoodItemId;
  int? selectedDropdownItemId;
  TextEditingController searchController = TextEditingController();
  int targetDailyCalories = 0;
  DateTime? selectedDate;

  // Calculates the total calories for selected food items
  int calculateTotalCalories() {
    return foodEntries.fold(0, (sum, entry) => sum + entry.calories);
  }

  late TextEditingController targetCaloriesController;

  @override
  void initState() {
    super.initState();
    targetCaloriesController = TextEditingController();
    _loadFoodItems();
  }

  // Load the food items into the page from the database for selection
  Future<void> _loadFoodItems() async {
    final database = FoodDatabase.instance;
    final db = await database.database;

    final List<Map<String, dynamic>> items = await db.query('food_items');

    setState(() {
      foodItems = items;
    });
  }

  // DatePicker widget for selecting the date of the entry
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

  // Format user input for data from the picker before going into the database
  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'No Date Selected';
    } else {
      return 'Selected Date: ${DateFormat('yyyy-MM-dd').format(date)}';
    }
  }

  // Add selected food item into the DataTable view on new entry page
  void _addRow() {
    if (selectedFoodItemId == null && selectedDropdownItemId == null) {
      return;
    }

    int selectedItemId = selectedFoodItemId ?? selectedDropdownItemId!;

    final selectedFoodItem =
        foodItems.firstWhere((item) => item['id'] == selectedItemId);
    final int calories = selectedFoodItem['calories'] as int;

    setState(() {
      foodEntries
          .add(FoodEntry(foodItemId: selectedItemId, calories: calories));
      searchController.clear();
      selectedFoodItemId = null;
      selectedDropdownItemId = null;
    });
  }

  // Delete food item from the DataTable
  void _deleteRow(FoodEntry entry) {
    setState(() {
      foodEntries.remove(entry);
    });
  }

  // Save entry to the database, with error checking conditions
  void _saveEntryToDatabase() async {
    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a date.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (targetDailyCalories <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid target daily calories value.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (foodEntries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cannot save entry with no food items.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (calculateTotalCalories() > targetDailyCalories) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Total calories cannot exceed the daily target.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final database = FoodDatabase.instance;
    final db = await database.database;

    final totalCalories = calculateTotalCalories();
    final formattedDate =
        "${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}";

    final foodItemIds = foodEntries.map((entry) => entry.foodItemId).toList();

    await database.insertEntry(totalCalories, formattedDate, foodItemIds);

    setState(() {
      foodEntries.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Entry saved!'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Entry'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                keyboardType: TextInputType.number,
                controller: targetCaloriesController,
                decoration: InputDecoration(
                  labelText: 'Target Daily Calories',
                ),
                onChanged: (value) {
                  setState(() {
                    targetDailyCalories = int.tryParse(value) ?? 0;
                  });
                },
                validator: (value) {
                  if (targetDailyCalories <= 0) {
                    return 'Please enter a valid target daily calories value.';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      _selectDate(context);
                    },
                    child: Text('Select Date'),
                  ),
                  SizedBox(width: 10),
                  Text(
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
                    _addRow();
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButtonFormField<int>(
                value: selectedDropdownItemId,
                onChanged: (value) {
                  setState(() {
                    selectedDropdownItemId = value;
                  });
                },
                items: foodItems.map<DropdownMenuItem<int>>((item) {
                  return DropdownMenuItem<int>(
                    value: item['id'] as int,
                    child: Text(item['name'] as String),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Select Food Item from Dropdown',
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _addRow();
              },
              child: Text('Add Food Item'),
            ),
            SizedBox(height: 20),
            foodEntries.isEmpty
                ? Text('No Food Items Added')
                : DataTable(
                    columns: [
                      DataColumn(label: Text('Food Item')),
                      DataColumn(label: Text('Calories')),
                      DataColumn(label: Text('Actions')),
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
                          DataCell(
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                _deleteRow(entry);
                              },
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
            SizedBox(height: 20),
            Text(
              'Total Daily Calories: ${calculateTotalCalories()}',
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
                _saveEntryToDatabase();
              },
              child: Text('Save Entry'),
            ),
          ],
        ),
      ),
    );
  }
}

// Food Entry object class
class FoodEntry {
  final int foodItemId;
  final int calories;

  FoodEntry({required this.foodItemId, required this.calories});
}
