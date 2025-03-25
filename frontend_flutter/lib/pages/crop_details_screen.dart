import 'package:flutter/material.dart';

class CropDetailsScreen extends StatelessWidget {
  final String cropName;

  CropDetailsScreen({required this.cropName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(cropName)),
      body: Center(
        child: Column(
          children: [
            // Crop Image (replace with actual image)
            Image.asset('assets/placeholder_crop.jpg'),
            // Crop Details (fetch from API)
            Text('Crop Name: $cropName'),
            Text('Yield: 35 tons/acre'),
            Text('Price: \$0.60/kg'),
            ElevatedButton(onPressed: () {}, child: Text('View Details')),
          ],
        ),
      ),
    );
  }
}
