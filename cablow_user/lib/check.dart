import  'package:flutter/material.dart';

class Check extends StatefulWidget {
  const Check({super.key});

  @override
  State<Check> createState() => _CheckState();
}

class _CheckState extends State<Check> {
  var amount = '350';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              ridePrice(
                vehicleImage: 'assets/image/car.png',
                amount: amount,
                carTitle: 'Mini',
                onTap: () {

                },
              ),
              ridePrice(
                vehicleImage: 'assets/image/suv.png',
                amount: amount,
                carTitle: 'SUV',
                onTap: () {
                },
              ),
              ridePrice(
                vehicleImage: 'assets/image/sedancar.png',
                amount: amount,
                carTitle: 'Sedan',
                onTap: () {
                },
              ),
              ridePrice(
                vehicleImage: 'assets/image/bike.png',
                amount: amount,
                carTitle: 'Bike',
                onTap: () {
                },
              ),
              ridePrice(
                vehicleImage: 'assets/image/auto.png',
                amount: amount,
                carTitle: 'Auto',
                onTap: () {
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  ridePrice({
    required String carTitle,
    required String vehicleImage,
    required String amount,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 20,
      child: ListTile(
        onTap: onTap, // Pass the function here
        leading: SizedBox(
          width: 70,
          height: 70,
          child: Image.asset(
            vehicleImage,
            fit: BoxFit.contain,
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.only(left: 18.0),
          child: Text(
            carTitle,
            style: const TextStyle(fontSize: 18),
          ),
        ),
        subtitle: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 18.0),
              child: Text(
                '₹ $amount',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.grey),
              ),
            ),
            const SizedBox(width: 10),
            Image.asset(
              'assets/image/dollar.png',
              width: 22,
            ),
          ],
        ),
        trailing: const Icon(
          Icons.arrow_circle_right_outlined,
          size: 28,
        ),
      ),
    );
  }


}