import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_calories_calc_app/entry.dart';
import 'package:flutter_calories_calc_app/database.dart';
import 'package:flutter_calories_calc_app/edit.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late List<Map<String, dynamic>> entries = [];
  DateTime? selectedFilterDate;

  @override
  void initState() {
    super.initState();
    _loadMealRecords();
  }

  Future<void> _loadMealRecords() async {
    final database = FoodDatabase.instance;
    final List<Map<String, dynamic>> records = await database.getEntries();

    setState(() {
      entries = records;
    });
  }

  Future<void> _refresh() async {
    await _loadMealRecords();
  }

  Future<void> _filterByDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedFilterDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        selectedFilterDate = picked;
      });
    }
  }

  void _clearFilter() {
    setState(() {
      selectedFilterDate = null;
    });
  }

  List<Map<String, dynamic>> getFilteredRecords() {
    if (selectedFilterDate == null) {
      return entries;
    } else {
      return entries
          .where((record) =>
              DateTime.parse(record['date'].toString())
                  .isAtSameMomentAs(selectedFilterDate!) ||
              DateTime.parse(record['date'].toString()).isAfter(DateTime(
                      selectedFilterDate!.year,
                      selectedFilterDate!.month,
                      selectedFilterDate!.day)) &&
                  DateTime.parse(record['date'].toString()).isBefore(DateTime(
                      selectedFilterDate!.year,
                      selectedFilterDate!.month,
                      selectedFilterDate!.day + 1)))
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calorie Calculator App'),
      ),
      body: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: _filterByDate,
                child: Text('Filter by Date'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: _clearFilter,
                child: Text('Clear Filter'),
              ),
              SizedBox(width: 10),
              Text(
                selectedFilterDate == null
                    ? 'No Filter'
                    : 'Filter Date: ${DateFormat('yyyy-MM-dd').format(selectedFilterDate!)}',
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            'Saved Entries',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(label: Text('Date')),
                    DataColumn(label: Text('Food Items')),
                    DataColumn(label: Text('Total Calories')),
                    DataColumn(
                        label: Text('Actions')), // Rename column to "Actions"
                  ],
                  rows: getFilteredRecords().map<DataRow>((record) {
                    return DataRow(
                      cells: [
                        DataCell(
                          Text(DateFormat('yyyy-MM-dd').format(
                            DateTime.parse(record['date'].toString()),
                          )),
                        ),
                        DataCell(
                          FutureBuilder<List<String>>(
                            future: _getFoodItemsForMeal(record['id']),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text('Error loading food items');
                              } else {
                                final foodItems = snapshot.data ?? [];
                                return Text(foodItems.join(', '));
                              }
                            },
                          ),
                        ),
                        DataCell(
                          Text(record['total_calories'].toString()),
                        ),
                        DataCell(
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  // Navigate to the EditScreen when the "Edit" button is pressed
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditScreen(
                                          mealRecordId: record['id']),
                                    ),
                                  );
                                  // Refresh meal records after returning from EditScreen
                                  await _refresh();
                                },
                                child: Text('Edit'),
                              ),
                              SizedBox(width: 8),
                              // ElevatedButton(
                              //   onPressed: () {
                              //     // Add your delete logic here
                              //     // You can show a confirmation dialog and delete the record on confirmation
                              //   },
                              ElevatedButton(
                                onPressed: () async {
                                  // Show a confirmation dialog
                                  bool confirmDelete = await showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text('Delete Entry'),
                                      content: Text(
                                          'Are you sure you want to delete this entry?'),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(false);
                                          },
                                          child: Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(true);
                                          },
                                          child: Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  );

                                  // If the user confirms, delete the entry
                                  if (confirmDelete == true) {
                                    await FoodDatabase.instance
                                        .deleteEntry(record['id']);
                                    await _refresh();
                                  }
                                },
                                child: Text('Delete'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              // Navigate to the MealScreen when the button is pressed
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NewEntryScreen()),
              );
              // Refresh meal records after returning from MealScreen
              await _refresh();
            },
            child: Text('Add New Entry'),
          ),
        ],
      ),
    );
  }

  Future<List<String>> _getFoodItemsForMeal(int mealId) async {
    final database = FoodDatabase.instance;
    final List<int> foodItemIds = await database.getFoodItemsForEntry(mealId);
    final List<Map<String, dynamic>> foodItems =
        await database.getFoodItemsByIds(foodItemIds);

    return foodItems.map((item) => item['name'].toString()).toList();
  }
}
