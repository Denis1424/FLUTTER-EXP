import 'package:flutter/material.dart';

void main() {
  runApp(const FruitApp());
}

class FruitApp extends StatelessWidget {
  const FruitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fruit Market - Widgets & Layouts',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const FruitListScreen(),
    );
  }
}

/// Model representing a Fruit item
class Fruit {
  final String name;
  final String scientificName;
  final String origin;
  final double pricePerKg;
  final int calories;
  final String season;
  final IconData icon;
  final Color themeColor;

  const Fruit({
    required this.name,
    required this.scientificName,
    required this.origin,
    required this.pricePerKg,
    required this.calories,
    required this.season,
    required this.icon,
    required this.themeColor,
  });
}

class FruitListScreen extends StatelessWidget {
  const FruitListScreen({super.key});

  static const List<Fruit> fruitList = [
    Fruit(
      name: 'Fresh Apple',
      scientificName: 'Malus domestica',
      origin: 'Kashmir, India',
      pricePerKg: 180.0,
      calories: 52,
      season: 'Autumn / Winter',
      icon: Icons.apple,
      themeColor: Colors.red,
    ),
    Fruit(
      name: 'Cavendish Banana',
      scientificName: 'Musa acuminata',
      origin: 'Kerala, India',
      pricePerKg: 50.0,
      calories: 89,
      season: 'All Year',
      icon: Icons.eco,
      themeColor: Colors.amber,
    ),
    Fruit(
      name: 'Alphonso Mango',
      scientificName: 'Mangifera indica',
      origin: 'Ratnagiri, India',
      pricePerKg: 350.0,
      calories: 60,
      season: 'Summer',
      icon: Icons.wb_sunny,
      themeColor: Colors.orange,
    ),
    Fruit(
      name: 'Valencia Orange',
      scientificName: 'Citrus sinensis',
      origin: 'Nagpur, India',
      pricePerKg: 120.0,
      calories: 47,
      season: 'Winter',
      icon: Icons.circle,
      themeColor: Colors.deepOrange,
    ),
    Fruit(
      name: 'Green Kiwi',
      scientificName: 'Actinidia deliciosa',
      origin: 'New Zealand',
      pricePerKg: 280.0,
      calories: 61,
      season: 'Spring',
      icon: Icons.spa,
      themeColor: Colors.green,
    ),
    Fruit(
      name: 'Red Strawberry',
      scientificName: 'Fragaria × ananassa',
      origin: 'Mahabaleshwar, India',
      pricePerKg: 240.0,
      calories: 33,
      season: 'Winter',
      icon: Icons.favorite,
      themeColor: Colors.pink,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.shopping_basket_rounded, color: Colors.white),
            SizedBox(width: 10),
            Text(
              'Fruit Market Catalog',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
        backgroundColor: Colors.deepOrange,
        elevation: 2,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange.shade50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header Banner using Container & Row
            Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 18.0),
              decoration: BoxDecoration(
                color: Colors.deepOrange.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.deepOrange.shade300),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.deepOrange),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Experiment 1: Demonstrating Row, Column, Container, Card, & ListView widgets with reusable custom widgets.',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.deepOrange,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Text(
                'Available Fruits',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
            ),

            // Scrollable List of Fruits using ListView.builder
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 16.0),
                itemCount: fruitList.length,
                itemBuilder: (context, index) {
                  return FruitCard(fruit: fruitList[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable Custom Widget: FruitCard
/// Combines Card, Container, Row, and Column widgets
class FruitCard extends StatelessWidget {
  final Fruit fruit;

  const FruitCard({super.key, required this.fruit});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left Icon Badge Container
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: fruit.themeColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                fruit.icon,
                size: 32,
                color: fruit.themeColor,
              ),
            ),
            const SizedBox(width: 16),

            // Middle Information Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fruit.name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    fruit.scientificName,
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Badges Row
                  Row(
                    children: [
                      NutrientBadge(
                        label: '${fruit.calories} kcal',
                        icon: Icons.local_fire_department,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      NutrientBadge(
                        label: fruit.season,
                        icon: Icons.calendar_today,
                        color: Colors.teal,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Right Price & Action Column
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${fruit.pricePerKg.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: fruit.themeColor,
                  ),
                ),
                const Text(
                  '/ kg',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.green.shade300),
                  ),
                  child: const Text(
                    'In Stock',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable Custom Widget: NutrientBadge
class NutrientBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const NutrientBadge({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
