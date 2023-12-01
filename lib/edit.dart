import 'package:flutter/material.dart';
import 'package:flutter_calories_calc_app/database.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:intl/intl.dart';

class UpdateScreen extends StatefulWidget {
  final int entryId;

  UpdateScreen({required this.entryId});

  @override
  _UpdateScreenState createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  List<Map<String, dynamic>> foodItems = [];
  List<FoodEntry> foodEntries = [];
  int? selectedFoodItemId;
  int? selectedDropdownItemId;
  TextEditingController searchController = TextEditingController();
  int targetDailyCalories = 0;
  DateTime? selectedDate;

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

  Future<void> _loadFoodItems() async {
    final database = FoodDatabase.instance;
    final db = await database.database;

    final List<Map<String, dynamic>> items = await db.query('food_items');

    setState(() {
      foodItems = items;
    });

    await _loadExistingEntry();
  }

  Future<void> _loadExistingEntry() async {
    final database = FoodDatabase.instance;
    final entry = await database.getEntryById(widget.entryId);

    if (entry.isNotEmpty) {
      setState(() {
        targetDailyCalories = entry['total_calories'] as int;
        selectedDate = DateTime.parse(entry['date'] as String);
        final foodItemIds = (entry['food_item_ids'] as String)
            .split(',')
            .map(int.parse)
            .toList();
        foodEntries = foodItemIds.map((id) {
          final foodItem = foodItems.firstWhere((item) => item['id'] == id);
          return FoodEntry(
            foodItemId: id,
            calories: foodItem['calories'] as int,
          );
        }).toList();
      });
    }
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
      return 'Selected Date: ${DateFormat('yyyy-MM-dd').format(date)}';
    }
  }

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

  void _deleteRow(FoodEntry entry) {
    setState(() {
      foodEntries.remove(entry);
    });
  }

  void _saveUpdatedEntry() async {
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

    print('Formatted Date: $formattedDate');

    final foodItemIds = foodEntries.map((entry) => entry.foodItemId).toList();

    await database.updateEntry(
      widget.entryId,
      totalCalories,
      formattedDate,
      foodItemIds,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Entry updated!'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Entry'),
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
                _saveUpdatedEntry();
              },
              child: Text('Update Entry'),
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
