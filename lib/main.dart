import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_calories_calc_app/meal.dart';
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
  late List<Map<String, dynamic>> mealRecords = [];
  DateTime? selectedFilterDate;

  @override
  void initState() {
    super.initState();
    _loadMealRecords();
  }

  Future<void> _loadMealRecords() async {
    final database = FoodDatabase.instance;
    final List<Map<String, dynamic>> records = await database.getMealRecords();

    setState(() {
      mealRecords = records;
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
      return mealRecords;
    } else {
      return mealRecords
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
            'Saved Meal Records',
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
                    DataColumn(label: Text('Edit')),  // New column for the "Edit" button
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
                          ElevatedButton(
                            onPressed: () async {
                              // Navigate to the EditScreen when the "Edit" button is pressed
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditScreen(mealRecord: record),
                                ),
                              );
                              // Refresh meal records after returning from EditScreen
                              await _refresh();
                            },
                            child: Text('Edit'),
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
                MaterialPageRoute(builder: (context) => MealScreen()),
              );
              // Refresh meal records after returning from MealScreen
              await _refresh();
            },
            child: Text('Add A New Meal'),
          ),
        ],
      ),
    );
  }

  Future<List<String>> _getFoodItemsForMeal(int mealId) async {
    final database = FoodDatabase.instance;
    final List<int> foodItemIds = await database.getFoodItemsForMeal(mealId);
    final List<Map<String, dynamic>> foodItems =
        await database.getFoodItemsByIds(foodItemIds);

    return foodItems.map((item) => item['name'].toString()).toList();
  }
}
