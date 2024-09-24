import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter_platform_interface/src/types/location.dart';

import '../SharedPrefUtils.dart';
import '../bookrideBloc/book_ride_bloc.dart';
import '../bookrideBloc/get_driver_info_bloc.dart';
import '../bookrideBloc/get_driver_info_event.dart';
import '../bookrideBloc/get_driver_info_state.dart';

class Pricelist extends StatefulWidget {
  final double bikeFare;
  final double autoFare;
  final double miniFare;
  final double sedanFare;
  final double suvFare;
  final LatLng location;
  final LatLng currentLocation;
  final String? from;
  final String? to;

  const Pricelist({
    Key? key,
    required this.bikeFare,
    required this.autoFare,
    required this.miniFare,
    required this.sedanFare,
    required this.suvFare,
    required this.location,
    required this.currentLocation,
    this.from,
    this.to,
  }) : super(key: key);

  @override
  State<Pricelist> createState() => _PricelistState();
}

class _PricelistState extends State<Pricelist> {
  String? selectedPrice;
  String buttonText = 'Book Ride';
  late StreamController<void> _controller;
  Timer? _timer;

  void _updateSelectedPrice(String price, String rideType) {
    setState(() {
      selectedPrice = price;
      buttonText = 'Book $rideType';
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = StreamController<void>();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.close();
    super.dispose();
  }

  void _showDetailsDialog(BuildContext context, String title, String imageAsset, String description) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                imageAsset, // Display the same image in the dialog
                width: 100,  // Set the desired width
                height: 100, // Set the desired height
                fit: BoxFit.cover, // Make the image cover the box
              ),
              SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
            ],
          ),
          actions: [
            Center(
              child: Container(
                width: 190, // Set the desired width for the button
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.amber, // Set the background color of the button
                    foregroundColor: Colors.white, // Set the text color of the button
                  ),
                  child: Text(
                    'Okay',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showBottomSheet(BuildContext context, {required List driverInfo}) {
    // Use a post-frame callback to show the bottom sheet
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              // Check if driverInfo is null or empty, show Lottie animation
              if (driverInfo == null || driverInfo.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Lottie.asset(
                      'assets/lottie/loading_animation.json', // Path to your Lottie animation file
                      width: 150,
                      height: 150,
                    ),
                  ),
                );
              }

              // When driverInfo is available, display the information
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: driverInfo.map<Widget>((driver) {
                    return Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 25,
                              backgroundImage: AssetImage('assets/image/aadhar.jpg'),
                            ),
                            SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Driver ID: ${driver['driver_id']}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text('Status: ${driver['status']}'),
                                Text('OTP: ${driver['otp']}'),
                              ],
                            ),
                            Spacer(),
                            Icon(Icons.phone),
                          ],
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  driver['source_address'],
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text('${driver['destination_address']}'),
                              ],
                            ),
                            Spacer(),
                            Text(
                              '\$${driver['price']}',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                      ],
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      );
    });
  }
  bool _isPolling = false;

  // ... (other methods remain the same)

  void _startDriverInfoPolling(BuildContext context) {
    if (!_isPolling) {
      _isPolling = true;
      _timer = Timer.periodic(Duration(seconds: 5), (timer) async {
        SharedPreferences sp = await SharedPreferences.getInstance();
        context.read<DriverInfoBloc>().add(
          GetDriverInfoEvent(
            userId: sp.getString(SharedPreffUtils().userIdKey)!,
            datetime: DateTime.now().toString(),
            rideId: '',
          ),
        );
        _controller.add(null); // Trigger StreamBuilder rebuild
      });
    }
  }
  void _stopDriverInfoPolling() {
    _timer?.cancel();
    _isPolling = false;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<BookRideBloc>(
          create: (context) => BookRideBloc(),
        ),
        BlocProvider<DriverInfoBloc>(
          create: (context) => DriverInfoBloc(),
        ),
      ],
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPriceTile(
                context,
                imageAsset: 'assets/image/motorcycle.png', // Path to the image
                title: 'Bike',
                subtitle: 'Affordable and Fast',
                price: '₹${widget.bikeFare.toStringAsFixed(2)}',
                rideType: 'Bike',
                description: 'Bike rides are designed for quick and efficient travel, especially in urban areas. Ideal for short distances and solo travelers.',
              ),
              _buildPriceTile(
                context,
                imageAsset: 'assets/image/mini.png',
                title: 'Mini',
                subtitle: 'Economical Car',
                price: '₹${widget.miniFare.toStringAsFixed(2)}',
                rideType: 'Mini',
                description: 'Mini cars are budget-friendly and suitable for city commutes or short distances, offering comfort for up to four passengers.',
              ),
              _buildPriceTile(
                context,
                imageAsset: 'assets/image/SEDAN.png',
                title: 'Sedan',
                subtitle: 'Premium Car',
                price: '₹${widget.sedanFare.toStringAsFixed(2)}',
                oldPrice: '₹369',
                rideType: 'Sedan',

                description: 'Sedans offer a blend of comfort and luxury with spacious interiors, making them ideal for longer trips and business travelers.',
              ),
              _buildPriceTile(
                context,
                imageAsset: 'assets/image/suv.png',
                title: 'SUV',
                subtitle: '7 Seater Spacious',
                price: '₹${widget.suvFare.toStringAsFixed(2)}',
                oldPrice: '₹424',
                rideType: 'SUV',

                description: 'SUVs are perfect for larger groups or long journeys, offering ample space and comfort with powerful engines.',
              ),
              _buildPriceTile(
                context,
                imageAsset: 'assets/image/auto.png',
                title: 'Auto',
                subtitle: 'Drop 5:06 pm',
                price: 'Coming Soon',
                oldPrice: 'Coming Soon',
                rideType: '',

                description: 'Auto rides are coming soon!',
              ),
              SizedBox(height: 16),
              Center(child: Text("*Prices are Exclusive of Toll Taxes")),
              SizedBox(height: 16),
              Center(
                child: BlocConsumer<DriverInfoBloc, DriverInfoState>(
                  listener: (context, state) {
                    if (state is DriverInfoSuccess) {
                      setState(() {
                        _isPolling = true;
                      });
                      print(state.driverInfo);
                      print('state is success');
                      final driverInfoList = state.driverInfo;
                      _showBottomSheet(context, driverInfo: driverInfoList);
                      _stopDriverInfoPolling(); // Stop polling on success
                    } else if (state is DriverInfoFailed) {
                      print('state is failed');
                      // You may want to handle the failed state differently
                    }
                  },
                  builder: (context, state) {
                    if (state is DriverInfoLoading) {
                      print('state is Loading');
                      return CircularProgressIndicator();
                    }

                    return ElevatedButton(
                      onPressed: selectedPrice != null
                          ? () async {
                        // Show loading or placeholder before the driver info is available
                        _showBottomSheet(context, driverInfo: []);

                        String cleanedPrice = selectedPrice!.replaceAll(RegExp('₹'), '');
                        SharedPreferences sp = await SharedPreferences.getInstance();

                        context.read<BookRideBloc>().add(
                          SendBookRideDetailsEvent(
                            rideId: sp.getString(SharedPreffUtils().userIdKey) ?? '',
                            sourceaddress: widget.from ?? '',
                            sourcelatitude: widget.currentLocation.latitude,
                            sourceLongitudex: widget.currentLocation.longitude,
                            destinationaddress: widget.to ?? '',
                            destinationlatitude: widget.location.latitude,
                            destinationLongitudex: widget.location.longitude,
                            vehicleType: 'mini',  // Example: Pass the selected vehicle type
                            price: double.parse(cleanedPrice), // Convert the selected price to a double
                          ),
                        );

                        _startDriverInfoPolling(context);
                      }
                          : null,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(buttonText, style: TextStyle(fontSize: 16)),
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceTile(
      BuildContext context, {
        required String imageAsset, // Path to the image asset
        required String title,
        required String subtitle,
        required String price,
        String? oldPrice,
        required String rideType,
        required String description,
      }) {
    bool isSelected = selectedPrice == price; // Check if the tile is selected

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            _updateSelectedPrice(price, rideType);
            _showDetailsDialog(context, title, imageAsset, description); // Pass imageAsset to the dialog
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8), // Rounded corners for the box
              gradient: isSelected
                  ? LinearGradient(
                colors: [
                  Colors.amberAccent.withOpacity(0.2),
                  Colors.amber.withOpacity(0.9)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
                  : null, // Apply the gradient when the tile is selected
              color: isSelected ? null : Colors.white, // Default to white if not selected
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.4),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: Offset(0, 4), // Shadow positioning
                  ),
              ],
            ),
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: Image.asset(
                imageAsset,
                width: 40, // Set the desired width
                height: 40, // Set the desired height
                fit: BoxFit.cover, // Make the image cover the box
              ),
              title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(subtitle),
              trailing: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (oldPrice != null)
                    Text(
                      oldPrice,
                      style: TextStyle(
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey,
                      ),
                    ),
                  Text(
                    price,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Divider(
          color: Colors.grey[300], // Light grey divider
          thickness: 2.0,
          height: 16.0,
        ), // Add divider between tiles
      ],
    );
  }
}
