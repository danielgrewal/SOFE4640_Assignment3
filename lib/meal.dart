// import 'package:flutter/material.dart';
// import 'package:flutter_calories_calc_app/database.dart';
// import 'package:autocomplete_textfield/autocomplete_textfield.dart';
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Add Meal',
//       home: MyHomePage(),
//     );
//   }
// }
//
// class MyHomePage extends StatefulWidget {
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   List<Map<String, dynamic>> foodItems = [];
//   List<FoodEntry> foodEntries = [];
//   int? selectedFoodItemId;
//   TextEditingController searchController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     _loadFoodItems();
//   }
//
//   Future<void> _loadFoodItems() async {
//     final database = FoodDatabase.instance;
//     final db = await database.database;
//
//     final List<Map<String, dynamic>> items = await db.query('food_items');
//
//     setState(() {
//       foodItems = items;
//     });
//   }
//
//   void _addRow() async {
//     if (selectedFoodItemId == null) {
//       return; // Don't add a row if no food item is selected
//     }
//
//     // Fetch calorie count for the selected food item
//     final selectedFoodItem =
//     foodItems.firstWhere((item) => item['id'] == selectedFoodItemId);
//     final int calories = selectedFoodItem['calories'] as int;
//
//     setState(() {
//       // Add a new entry to the table with the selected food item and its calorie count
//       foodEntries
//           .add(FoodEntry(foodItemId: selectedFoodItemId!, calories: calories));
//       // Clear the search field and selected item after adding a row
//       searchController.clear();
//       selectedFoodItemId = null;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Save Meal To Database'),
//       ),
//       body: Column(
//         children: <Widget>[
//           // Search Text Field
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: AutoCompleteTextField<Map<String, dynamic>>(
//               key:
//               GlobalKey<AutoCompleteTextFieldState<Map<String, dynamic>>>(),
//               controller: searchController,
//               clearOnSubmit: false,
//               suggestions: foodItems,
//               itemFilter: (item, query) {
//                 // return item['name'].toLowerCase().contains(query.toLowerCase());
//                 return item['name']
//                     .toLowerCase()
//                     .contains(query.toLowerCase()) ||
//                     query.toLowerCase().contains(item['name'].toLowerCase());
//               },
//               itemSorter: (a, b) {
//                 return a['name'].compareTo(b['name']);
//               },
//               itemSubmitted: (item) {
//                 setState(() {
//                   selectedFoodItemId = item['id'] as int;
//                 });
//               },
//               itemBuilder: (context, item) {
//                 return ListTile(
//                   title: Text(item['name'] as String),
//                 );
//               },
//               decoration: InputDecoration(
//                 labelText: 'Search for a Food Item',
//               ),
//             ),
//           ),
//           SizedBox(height: 20),
//           ElevatedButton(
//             onPressed: () {
//               // Add a new row when the button is pressed
//               _addRow();
//             },
//             child: Text('Add Food Item To Meal'),
//           ),
//           SizedBox(height: 20),
//           foodEntries.isEmpty
//               ? Text(
//               'No Food Items Added To This Meal') // Display "Empty" when there are no rows
//               : DataTable(
//             columns: [
//               DataColumn(label: Text('Food Item')),
//               DataColumn(label: Text('Calories')),
//             ],
//             rows: foodEntries.map<DataRow>((FoodEntry entry) {
//               return DataRow(
//                 cells: [
//                   DataCell(
//                     Text(
//                       foodItems.firstWhere(
//                             (item) => item['id'] == entry.foodItemId,
//                         orElse: () => {'name': 'Unknown'},
//                       )['name'] as String,
//                     ),
//                   ),
//                   DataCell(
//                     Text(
//                       entry.calories.toString(),
//                     ),
//                   ),
//                 ],
//               );
//             }).toList(),
//           ),
//           SizedBox(height: 20),
//           Text(
//             'Total Meal Calories: ${foodEntries.fold(0, (sum, entry) => sum + entry.calories)}',
//             style: TextStyle(fontSize: 16),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class FoodEntry {
//   final int foodItemId;
//   final int calories;
//
//   FoodEntry({required this.foodItemId, required this.calories});
// }
//
// import 'package:flutter/material.dart';
// import 'package:flutter_calories_calc_app/database.dart';
// import 'package:autocomplete_textfield/autocomplete_textfield.dart';
//
// class MealScreen extends StatefulWidget {
//   @override
//   _MealScreenState createState() => _MealScreenState();
// }
//
// class _MealScreenState extends State<MealScreen> {
//   List<Map<String, dynamic>> foodItems = [];
//   List<FoodEntry> foodEntries = [];
//   int? selectedFoodItemId;
//   TextEditingController searchController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     _loadFoodItems();
//   }
//
//   Future<void> _loadFoodItems() async {
//     final database = FoodDatabase.instance;
//     final db = await database.database;
//
//     final List<Map<String, dynamic>> items = await db.query('food_items');
//
//     setState(() {
//       foodItems = items;
//     });
//   }
//
//   void _addRow() async {
//     if (selectedFoodItemId == null) {
//       return; // Don't add a row if no food item is selected
//     }
//
//     // Fetch calorie count for the selected food item
//     final selectedFoodItem =
//     foodItems.firstWhere((item) => item['id'] == selectedFoodItemId);
//     final int calories = selectedFoodItem['calories'] as int;
//
//     setState(() {
//       // Add a new entry to the table with the selected food item and its calorie count
//       foodEntries
//           .add(FoodEntry(foodItemId: selectedFoodItemId!, calories: calories));
//       // Clear the search field and selected item after adding a row
//       searchController.clear();
//       selectedFoodItemId = null;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Save Meal To Database'),
//       ),
//       body: Column(
//         children: <Widget>[
//           // Search Text Field
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: AutoCompleteTextField<Map<String, dynamic>>(
//               key:
//               GlobalKey<AutoCompleteTextFieldState<Map<String, dynamic>>>(),
//               controller: searchController,
//               clearOnSubmit: false,
//               suggestions: foodItems,
//               itemFilter: (item, query) {
//                 return item['name']
//                     .toLowerCase()
//                     .contains(query.toLowerCase()) ||
//                     query.toLowerCase().contains(item['name'].toLowerCase());
//               },
//               itemSorter: (a, b) {
//                 return a['name'].compareTo(b['name']);
//               },
//               itemSubmitted: (item) {
//                 setState(() {
//                   selectedFoodItemId = item['id'] as int;
//                 });
//               },
//               itemBuilder: (context, item) {
//                 return ListTile(
//                   title: Text(item['name'] as String),
//                 );
//               },
//               decoration: InputDecoration(
//                 labelText: 'Search for a Food Item',
//               ),
//             ),
//           ),
//           SizedBox(height: 20),
//           ElevatedButton(
//             onPressed: () {
//               // Add a new row when the button is pressed
//               _addRow();
//             },
//             child: Text('Add Food Item To Meal'),
//           ),
//           SizedBox(height: 20),
//           foodEntries.isEmpty
//               ? Text(
//               'No Food Items Added To This Meal') // Display "Empty" when there are no rows
//               : DataTable(
//             columns: [
//               DataColumn(label: Text('Food Item')),
//               DataColumn(label: Text('Calories')),
//             ],
//             rows: foodEntries.map<DataRow>((FoodEntry entry) {
//               return DataRow(
//                 cells: [
//                   DataCell(
//                     Text(
//                       foodItems.firstWhere(
//                             (item) => item['id'] == entry.foodItemId,
//                         orElse: () => {'name': 'Unknown'},
//                       )['name'] as String,
//                     ),
//                   ),
//                   DataCell(
//                     Text(
//                       entry.calories.toString(),
//                     ),
//                   ),
//                 ],
//               );
//             }).toList(),
//           ),
//           SizedBox(height: 20),
//           Text(
//             'Total Meal Calories: ${foodEntries.fold(0, (sum, entry) => sum + entry.calories)}',
//             style: TextStyle(fontSize: 16),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class FoodEntry {
//   final int foodItemId;
//   final int calories;
//
//   FoodEntry({required this.foodItemId, required this.calories});
// }

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

  // void _saveMealToDatabase() async {
  //   final database = FoodDatabase.instance;
  //   final db = await database.database;
  //
  //   // Calculate total calories for the meal
  //   final totalCalories =
  //   foodEntries.fold(0, (sum, entry) => sum + entry.calories);
  //
  //   // Get the current date and time
  //   final dateTime = DateTime.now().toIso8601String();
  //
  //   // Get the list of food item IDs for the meal
  //   final foodItemIds = foodEntries.map((entry) => entry.foodItemId).toList();
  //
  //   // Insert the meal into the database
  //   await database.insertMeal(totalCalories, dateTime, foodItemIds);
  //
  //   // Clear the food entries list
  //   setState(() {
  //     foodEntries.clear();
  //   });
  //
  //   // Display a success message or navigate to another screen if needed
  //   // You can customize this part based on your app's requirements
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text('Meal saved to database!'),
  //     ),
  //   );
  // }

  void _saveMealToDatabase() async {
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

    final database = FoodDatabase.instance;
    final db = await database.database;

    // Calculate total calories for the meal
    final totalCalories =
        foodEntries.fold(0, (sum, entry) => sum + entry.calories);

    // Get the current date and time
    final dateTime = DateTime.now().toIso8601String();

    // Get the list of food item IDs for the meal
    final foodItemIds = foodEntries.map((entry) => entry.foodItemId).toList();

    // Insert the meal into the database
    await database.insertMeal(totalCalories, dateTime, foodItemIds);

    // Clear the food entries list
    setState(() {
      foodEntries.clear();
    });

    // Display a success message or navigate to another screen if needed
    // You can customize this part based on your app's requirements
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Meal saved to database!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Save Meal To Database'),
      ),
      body: Column(
        children: <Widget>[
          // Search Text Field
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: AutoCompleteTextField<Map<String, dynamic>>(
              key:
                  GlobalKey<AutoCompleteTextFieldState<Map<String, dynamic>>>(),
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
            'Total Meal Calories: ${foodEntries.fold(0, (sum, entry) => sum + entry.calories)}',
            style: TextStyle(fontSize: 16),
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
    );
  }
}

class FoodEntry {
  final int foodItemId;
  final int calories;

  FoodEntry({required this.foodItemId, required this.calories});
}
