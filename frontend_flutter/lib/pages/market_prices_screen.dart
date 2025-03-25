import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class MarketPricesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Market Prices')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: const Text('Total Yield: 1500 kg'),
              trailing: const Text('\$3,500'),
            ),
            ListTile(
              title: const Text('Active Alerts: 3'),
              trailing: const Text('Recommendations: 12'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Crop Yield Over Time',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(height: 200, child: _buildLineChart()),
            const SizedBox(height: 16),
            const Text(
              'Recent Activities',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ListTile(
              title: const Text('Pest Detected'),
              subtitle: const Text('June 14, 2024'),
              trailing: const Text(
                'Alert',
                style: TextStyle(color: Colors.red),
              ),
            ),
            ListTile(
              title: const Text('Irrigation Complete'),
              subtitle: const Text('June 13, 2024'),
              trailing: const Text(
                'Completed',
                style: TextStyle(color: Colors.green),
              ),
            ),
            ListTile(
              title: const Text('Soil Test Results'),
              subtitle: const Text('June 12, 2024'),
              trailing: const Text('View'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey, width: 1),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [FlSpot(0, 5), FlSpot(1, 25), FlSpot(2, 100), FlSpot(3, 75)],
            isCurved: true,
            color: Colors.blue,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }
}
