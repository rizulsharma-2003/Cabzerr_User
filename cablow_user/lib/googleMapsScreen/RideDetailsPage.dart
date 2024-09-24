import 'package:flutter/material.dart';

class RideDetailsPage extends StatelessWidget {
  final Map<String, dynamic> rideData;

  const RideDetailsPage({Key? key, required this.rideData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Ride Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('From: ${rideData['source_address']}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('To: ${rideData['destination_address']}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 16),
            Text('Date: ${rideData['date']}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Fare: ${rideData['fare']}', style: TextStyle(fontSize: 18)),
            // Add more fields as necessary
          ],
        ),
      ),
    );
  }
}
