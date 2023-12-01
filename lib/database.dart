import 'package:sqflite/sqflite.dart';

class FoodDatabase {
  static final FoodDatabase instance = FoodDatabase._init();

  static Database? _database;

  FoodDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('food_calculator.db');
    return _database!;
  }

  Future<Database> _initDB(String dbName) async {
    final dbPath = await getDatabasesPath();
    final path = '$dbPath/$dbName';

    final db = await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );

    return db;
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE food_items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        calories INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE entries(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        total_calories INTEGER,
        date TEXT,
        food_item_ids TEXT,
        FOREIGN KEY (food_item_ids) REFERENCES food_items(id)
      )
    ''');

    // Insert initial food items after creating the tables
    await _insertInitialFoodItems(db);
  }

  Future<void> _insertInitialFoodItems(Database db) async {
    // Insert 40 common food items with their approximate calories
    final foodItems = [
      {'name': 'Chicken Breast', 'calories': 165},
      {'name': 'Broccoli', 'calories': 55},
      {'name': 'Salmon', 'calories': 206},
      {'name': 'Eggs', 'calories': 68},
      {'name': 'Spinach', 'calories': 7},
      {'name': 'Banana', 'calories': 105},
      {'name': 'Quinoa', 'calories': 222},
      {'name': 'Greek Yogurt', 'calories': 100},
      {'name': 'Sweet Potato', 'calories': 112},
      {'name': 'Almonds', 'calories': 7},
      {'name': 'Brown Rice', 'calories': 215},
      {'name': 'Strawberries', 'calories': 4},
      {'name': 'Avocado', 'calories': 160},
      {'name': 'Beef Steak', 'calories': 250},
      {'name': 'Milk', 'calories': 103},
      {'name': 'Oatmeal', 'calories': 154},
      {'name': 'Tomato', 'calories': 22},
      {'name': 'Cheese (Cheddar)', 'calories': 110},
      {'name': 'Lentils', 'calories': 230},
      {'name': 'Whole Wheat Bread', 'calories': 69},
      {'name': 'Shrimp', 'calories': 85},
      {'name': 'Asparagus', 'calories': 20},
      {'name': 'Pineapple', 'calories': 83},
      {'name': 'Cottage Cheese', 'calories': 206},
      {'name': 'Cauliflower', 'calories': 25},
      {'name': 'Peanut Butter', 'calories': 94},
      {'name': 'Turkey Breast', 'calories': 135},
      {'name': 'Blueberries', 'calories': 84},
      {'name': 'White Potato', 'calories': 130},
      {'name': 'Walnuts', 'calories': 185},
      {'name': 'Wild Rice', 'calories': 166},
      {'name': 'Cucumber', 'calories': 16},
      {'name': 'Feta Cheese', 'calories': 100},
      {'name': 'Tuna', 'calories': 120},
      {'name': 'Peach', 'calories': 59},
      {'name': 'Ground Beef (Lean)', 'calories': 250},
      {'name': 'Mushrooms', 'calories': 15},
      {'name': 'Cashews', 'calories': 155},
      {'name': 'Whole Wheat Pasta', 'calories': 180},
      {'name': 'Carrots', 'calories': 41},
    ];

    for (final foodItem in foodItems) {
      await db.insert(
        'food_items',
        foodItem,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> insertFoodItem(String name, int calories) async {
    final db = await database;

    // Check if a food item with the same name already exists
    final existingItems = await db.query(
      'food_items',
      where: 'name = ?',
      whereArgs: [name],
    );

    if (existingItems.isNotEmpty) {
      // Handle the case where the food item already exists (e.g., show an error message)
      print('Food item with the name "$name" already exists.');
    } else {
      // Insert the new food item if it doesn't already exist
      await db.insert(
        'food_items',
        {
          'name': name,
          'calories': calories,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<int> _insertEntry(Map<String, dynamic> entry) async {
    final db = await database;
    return await db.insert('entries', entry);
  }

  Future<void> insertEntry(
      int totalCalories, String date, List<int> foodItemIds) async {
    final db = await database;

    final Map<String, dynamic> entry = {
      'total_calories': totalCalories,
      'date': date,
      'food_item_ids': foodItemIds.join(','),
    };

    await _insertEntry(entry);
  }

  Future<void> deleteEntry(int entryId) async {
    final db = await database;
    await db.delete('entries', where: 'id = ?', whereArgs: [entryId]);
  }

  Future<List<Map<String, dynamic>>> getEntries() async {
    final db = await database;
    return await db.query('entries');
  }

  Future<List<int>> getFoodItemsForEntry(int entryId) async {
    final db = await database;
    final result =
        await db.query('entries', where: 'id = ?', whereArgs: [entryId]);
    final foodItemIds =
        (result.isNotEmpty) ? result.first['food_item_ids'] : '';
    return (foodItemIds as String)
        .split(',')
        .map((id) => int.parse(id))
        .toList();
  }

  Future<List<Map<String, dynamic>>> getFoodItemsByIds(
      List<int> foodItemIds) async {
    final db = await database;
    final inClause = foodItemIds.map((id) => '?').join(',');
    return await db.rawQuery(
        'SELECT * FROM food_items WHERE id IN ($inClause)', foodItemIds);
  }

  Future<Map<String, dynamic>> getEntryById(int entryId) async {
    final db = await database;
    final result =
        await db.query('entries', where: 'id = ?', whereArgs: [entryId]);

    return result.isNotEmpty ? result.first : {};
  }
}
