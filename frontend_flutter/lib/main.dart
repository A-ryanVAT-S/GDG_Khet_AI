import 'package:flutter/material.dart';
import 'pages/crop_details_screen.dart'; // Import CropDetailsScreen
import 'pages/market_prices_screen.dart'; // Import MarketPricesScreen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KhetAl App',
      theme: ThemeData(
        primarySwatch: Colors.green, // You can customize the theme
      ),
      home: const HomeScreen(), // Set HomeScreen as the home
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('KhetAl')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.yellow[100],
              child: Column(
                children: [
                  const Text(
                    'Pest there !! Don\'t Worry',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to ScannerScreen
                    },
                    child: const Text('Scan it here'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Chip(label: const Text('Fruits')),
                Chip(label: const Text('Grains')),
                Chip(label: const Text('Herbs')),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Popular Crops',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildCropCard(context, 'Berries', '₹500', '4.5 (672)'),
            _buildCropCard(context, 'Tulsi', '₹100', '4.9 (324)'),
            _buildCropCard(context, 'Milk', '₹70', '4.9 (560)'),
            _buildCropCard(context, 'Tomatoes', '₹50', '4.7 (874)'),
            _buildCropCard(context, 'Beans', '24 tons/acre', '\$1.20/kg'),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Scanner',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        onTap: (int index) {
          if (index == 2) {
            // Assuming Analytics is at index 2
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MarketPricesScreen()),
            );
          }
          // Add other navigation logic for other tabs
        },
      ),
    );
  }

  Widget _buildCropCard(
    BuildContext context,
    String title,
    String price,
    String rating,
  ) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(price),
        trailing: Text(rating),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CropDetailsScreen(cropName: title),
            ),
          );
        },
      ),
    );
  }
}
