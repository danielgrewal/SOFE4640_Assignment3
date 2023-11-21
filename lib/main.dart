import 'package:flutter/material.dart';
import 'package:flutter_calories_calc_app/meal.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigate to the MealScreen when the button is pressed
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MealScreen()),
            );
          },
          child: Text('Open Meal Screen'),
        ),
      ),
    );
  }
}
