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

    // Insert 40 common food items with their approximate calories
    await _insertInitialFoodItems(db);

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
      CREATE TABLE meals(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        total_calories INTEGER,
        date_time TEXT,
        food_item_ids TEXT,
        FOREIGN KEY (food_item_ids) REFERENCES food_items(id)
      )
    ''');
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

    await db.insert(
      'food_items',
      {
        'name': name,
        'calories': calories,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

// Add more methods for interacting with the database as needed
}
