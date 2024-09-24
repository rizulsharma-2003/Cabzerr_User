import 'dart:convert';
import 'dart:io';

import 'package:cablow_user/Authentication/LoginScreen.dart';
import 'package:cablow_user/SharedPrefUtils.dart';
import 'package:cablow_user/bookrideBloc/book_ride_bloc.dart';
import 'package:cablow_user/googleMapsScreen/priceList.dart';
import 'package:cablow_user/googleMapsScreen/rideHistory.dart';
import 'package:cablow_user/my_helpers/helps/navigator_help.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../QuickOptions/help.dart';
import '../QuickOptions/myRewards.dart';
import '../QuickOptions/profileScreen.dart';
import '../QuickOptions/referalScreen.dart';
import '../google_places_flutter.dart';
import '../model/prediction.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({Key? key}) : super(key: key);

  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen>
    with SingleTickerProviderStateMixin {
  final SharedPreffUtils sharedPrefs = SharedPreffUtils();
  File? _profileImage;
  String firstName = ''; // Default value
  String mobileNo = ''; // Default value



  late GoogleMapController mapController;
  LatLng? pickupLocation;
  bool _isPermissionGranted = false;
  LatLng? _destinationLocation;
  LatLng? _curruntLocation;

  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};
  TextEditingController _fromController = TextEditingController();
  TextEditingController _toController =   TextEditingController();
  final FocusNode _focusNode = FocusNode();

  static const String _apiKey = 'AIzaSyDO8ZayxOthLcRSQeTqqz8molJwLdS2cQ0';
  double _initialChildSize = 0.3;

  String? selectedPrice;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    print('current location $pickupLocation');
    _loadUserData();
    _loadProfileImage();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        // Hide the keyboard when the TextField loses focus
        FocusScope.of(context).unfocus();
      }
    });
  }

  // Function to load the profile image
  Future<void> _loadProfileImage() async {
    final savedImagePath = await sharedPrefs.getStringValue('profile_image');
    if (savedImagePath != null && savedImagePath.isNotEmpty) {
      setState(() {
        _profileImage = File(savedImagePath);  // Load the image if it was saved
      });
    }
  }

  // Fetch data from SharedPreferences
  Future<void> _loadUserData() async {
    SharedPreffUtils prefs = SharedPreffUtils();
    String? fetchedFirstName = await prefs.getStringValue(prefs.firstNameKey);
    String? fetchedMobileNo = await prefs.getStringValue(prefs.mobileNumberKey);

    setState(() {
      firstName = fetchedFirstName ?? 'Guest'; // Default to 'Guest' if null
      mobileNo = fetchedMobileNo ?? 'No mobile number';
    });
  }

  Future<void> _requestLocationPermission() async {
    var status = await Permission.locationWhenInUse.request();
    if (status.isGranted) {
      print('checking permition');

      setState(() {
        _isPermissionGranted = true;
      });
      await _getCurrentLocation();
      // _setupPolylines();
      print(status);
    } else {
      _showPermissionDeniedDialog();
    }

  }

  Future<void> _getCurrentLocation() async {
    try {
      Location location = Location();
      var currentLocationData = await location.getLocation();
      setState(() {
        pickupLocation = LatLng(
            currentLocationData.latitude!, currentLocationData.longitude!);
       if(pickupLocation!=null){}

        setState(() {
          _fromController.text= '📍Your location';
        });
      });
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  _setupPolylines() async {
    // if(_fromController.text.isEmpty) {
    //   await _getCurrentLocation();
    //
    //   // _getLatLngFromAddress(address)
    //   setState(() {
    //     _fromController.text = 'Your location';
    //   });
    // }
    if (pickupLocation == null || _destinationLocation == null) return;

    final originString =
        'origin=${pickupLocation!.latitude},${pickupLocation!.longitude}';
    final destString =
        'destination=${_destinationLocation?.latitude},${_destinationLocation?.longitude}';

    final polylineResult = await _fetchPolyline(
        '$originString&$destString&mode=driving&key=$_apiKey');

    if (polylineResult != null) {
      setState(() {
        _polylines.add(
          Polyline(
            polylineId: PolylineId('driving_polyline'),
            visible: true,
            points: polylineResult['polyline'],
            color: Colors.black,
            width: 5,
          ),
        );

        // Convert distance to integer
        final int distanceInMeters = polylineResult['distance'];
        print('Total distance: $distanceInMeters meters');

        // Calculate fare based on distance
        final double distanceInKilometers = distanceInMeters / 1000;

        setState(() {
          bikeFare = distanceInKilometers * 10;
          autoFare = distanceInKilometers * 12;
          miniFare = distanceInKilometers * 13;
          sedanFare = distanceInKilometers * 15;
          suvFare = distanceInKilometers * 19;
        });

        print('Bike Fare: ₹$bikeFare');
        print('Auto Fare: ₹$autoFare');
        print('Mini Fare: ₹$miniFare');
        print('Sedan Fare: ₹$sedanFare');
        print('SUV Fare: ₹$suvFare');

        // You can now pass these values to your Pricelist class or use them as needed
      });
      return 1;
    }
  }

  Future<Map<String, dynamic>?> _fetchPolyline(String url) async {
    try {
      final response = await http.get(Uri.parse(
          'https://maps.googleapis.com/maps/api/directions/json?$url'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final encodedPolyline = route['overview_polyline']['points'];

          // Extract distance from the legs
          final distance =
              route['legs'][0]['distance']['value']; // distance in meters

          return {
            'polyline': _decodePolyline(encodedPolyline),
            'distance': distance
          };
        }
      } else {
        print(
            'Failed to fetch polyline     wtyudskauh. Status code: ${response.body}');
      }
    } catch (e) {
      print('Error fetching polyline: $e');
    }
    return null;
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polyline = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;
      do {
        b = encoded.codeUnitAt(index) - 63;
        index++;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index) - 63;
        index++;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      polyline.add(LatLng((lat / 1E5), (lng / 1E5)));
    }

    return polyline;
  }

  Future<LatLng?> _getLatLngFromAddress(String address) async {
    print('address ===$address');
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(address)}&key=$_apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['results'].isNotEmpty) {
        final location = data['results'][0]['geometry']['location'];
        return LatLng(location['lat'], location['lng']);
      }
    } else {
      const snackBar = SnackBar(
        content: Text('please select pickup location'),
        // action: SnackBarAction(
        //   label: 'Undo',
        //   onPressed: () {
        //     // Code to execute when the action is pressed
        //   },
        // ),
      );

      // Show the Snackbar using ScaffoldMessenger
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      print('Failed to fetch location. Status code: ${response.body}');
      return null;
    }
  }

  void _addMarkers() {
    if (pickupLocation != null && _destinationLocation != null) {
      setState(() {
        _markers.clear();
        _markers.add(
          Marker(
            markerId: MarkerId('destination'),
            position: _destinationLocation!,
            infoWindow: InfoWindow(
              title: 'Destination',
            ),
          ),
        );
        _markers.add(
          Marker(
            markerId: MarkerId('origin'),
            position: pickupLocation!,
            infoWindow: InfoWindow(
              title: 'You',
            ),
          ),
        );
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (pickupLocation != null) {
      mapController
          .moveCamera(CameraUpdate.newLatLngZoom(pickupLocation!, 10.0));
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Permission Denied'),
        content: Text('Location permission is required to use this feature.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();

    super.dispose();
  }

  Widget placesAutoCompleteTextField(TextEditingController controller) {
    return SizedBox(
      width: 200, // Adjust this width to your desired value
      child: Container(
        width: 200, // Ensure this matches the width of the SizedBox
        padding: const EdgeInsets.symmetric(horizontal: 10), // Adjust padding if necessary
        child: GooglePlaceAutoCompleteTextField(
          textEditingController: controller,
          focusNode: _focusNode,
          googleAPIKey: _apiKey,
          inputDecoration: InputDecoration(
            hintText: "📍 Search Ride Location",
            hintStyle: TextStyle(
              fontSize: 16,  // Adjust font size
              fontWeight: FontWeight.w900,  // Set font weight
              // fontStyle: FontStyle.italic,  // Set font style to italic (optional)
              color: Colors.black54,  // Set hint text color
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
          ),
          debounceTime: 400,
          countries: ["in", "fr"],
          isLatLngRequired: true,
          getPlaceDetailWithLatLng: (Prediction prediction) {
            print("placeDetails" + prediction.lat.toString());
          },
          itemClick: (Prediction prediction) {
            controller.text = prediction.description ?? "";
            controller.selection = TextSelection.fromPosition(
                TextPosition(offset: prediction.description?.length ?? 0));
          },
          seperatedBuilder: Divider(),
          containerHorizontalPadding: 10,
          itemBuilder: (context, index, Prediction prediction) {
            return Container(
              padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  Icon(Icons.location_on),
                  SizedBox(
                    width: 7,
                  ),
                  Expanded(child: Text("${prediction.description ?? ""}"))
                ],
              ),
            );
          },
          isCrossBtnShown: true,
        ),
      ),
    );
  }

  bool _isSheetVisible = true;

  double _distanceInKilometers = 0.0;
  double bikeFare = 0.0;
  double autoFare = 0.0;
  double miniFare = 0.0;
  double sedanFare = 0.0;
  double suvFare = 0.0;

  void _updateToAddress(String toAddress) {
    setState(() {
      _toController.text = toAddress;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return BlocProvider(
        create: (context) => BookRideBloc(),
    child: GestureDetector(
    onTap: () {
    // Dismiss the keyboard when tapping outside
    FocusScope.of(context).unfocus();
    },
        child: Scaffold(
            body: SafeArea(
              child: Stack(
                children: [
                  GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: pickupLocation ?? LatLng(28.7041, 77.1025),
                      zoom: 10.0,
                    ),
                    mapType: MapType.normal,
                    polylines: _polylines,
                    myLocationButtonEnabled: true,
                    myLocationEnabled: true,
                    markers: _markers,
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 10.0, left: 10, right: 10),
                    child: SizedBox(
                      height: 45,
                      width: width / 1.2,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Builder(
                              builder: (BuildContext context) {
                                return IconButton(
                                  onPressed: () {
                                    Scaffold.of(context).openDrawer();
                                  },
                                  icon: Icon(Icons.view_headline_sharp),
                                );
                              },
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _initialChildSize = 1.0;
                              });
                              _fromController.text = "";
                              if (kDebugMode) {
                                print("Tapped on From Field");
                              }
                            },
                            child: Container(
                              width: 240,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Container(
                                width: 150,
                                child: GooglePlaceAutoCompleteTextField(
                                  textEditingController: _fromController,
                                  focusNode: _focusNode,

                                  googleAPIKey: _apiKey,
                                  inputDecoration:  InputDecoration(
                                    hintText: "Pickup location",

                                    suffixIcon: IconButton(onPressed: (){
                                      setState(() {
                                        _fromController.clear();
                                        pickupLocation =null;
                                      });
                                    }, icon: Icon(Icons.close_outlined)),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                  ),
                                  debounceTime: 400,
                                  countries: const ["in", "fr"],
                                  isLatLngRequired: true,
                                  getPlaceDetailWithLatLng:
                                      (Prediction prediction) {
                                    if (kDebugMode) {
                                      print("placeDetails${prediction.lat}");
                                    }
                                  },
                                  itemClick: (Prediction prediction) {
                                    setState(() {
                                      _initialChildSize = 1.0;
                                    });

                                    _fromController.text =
                                        prediction.description ?? "";
                                    _fromController.selection =
                                        TextSelection.fromPosition(
                                      TextPosition(
                                        offset:
                                            prediction.description?.length ?? 0,
                                      ),
                                    );
                                  },
                                  seperatedBuilder: Divider(),
                                  containerHorizontalPadding: 10,
                                  itemBuilder:
                                      (context, index, Prediction prediction) {
                                    return Container(
                                      padding: EdgeInsets.all(10),
                                      child: Row(
                                        children: [
                                          Icon(Icons.location_on),
                                          SizedBox(
                                            width: 7,
                                          ),
                                          Expanded(
                                            child: Text(
                                              "${prediction.description ?? ""}",
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  isCrossBtnShown: false,

                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_isSheetVisible)
                    DraggableScrollableSheet(
                      initialChildSize: _initialChildSize,
                      minChildSize: _initialChildSize,
                      maxChildSize: 1.0,
                      builder: (BuildContext context, ScrollController scrollController) {
                        return Container(
                          padding: EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: Offset(0, 3), // changes position of shadow
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Container(
                                  width: 50,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              Expanded(
                                child: ListView(
                                  controller: scrollController,
                                  children: [
                                    // The placesAutoCompleteTextField widget
                                    Container(
                                      margin: EdgeInsets.only(bottom: 10),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12.0),
                                        child: placesAutoCompleteTextField(_toController),
                                      ),
                                    ),
                                    Center(
                                      child: BlocConsumer<BookRideBloc,
                                          BookRideState>(
                                        listener: (context, state) async {
                                          if (state is BookRideSuccess) {
                                            // Assuming _distanceInKilometers has been set
                                          }

                                          if (state is BookRideFailed) {
                                            SharedPreferences sp =
                                            await SharedPreferences
                                                .getInstance();
                                            context.read<BookRideBloc>().add(
                                              SendBookRideDetailsEvent(
                                                rideId: sp.getString(SharedPreffUtils().userIdKey) ?? '',
                                                destinationlatitude: _destinationLocation?.latitude ?? 0.0,
                                                sourcelatitude: pickupLocation?.latitude ?? 0.0,
                                                destinationLongitudex: _destinationLocation?.longitude ?? 0.0,
                                                sourceaddress: _fromController.text,
                                                sourceLongitudex: pickupLocation?.longitude ?? 0.0,
                                                destinationaddress: _toController.text,
                                                vehicleType: '',  // assuming you're setting it to mini
                                                price:300,  // setting price to 200
                                              ),
                                            );

                                          }
                                        },
                                        builder: (context, state) {
                                          if (state is BookRideLoading) {
                                            return const Center(
                                              child:
                                              CircularProgressIndicator(),
                                            );
                                          }
                                          return ElevatedButton(
                                            onPressed: () async {
                                              // // Add a delay to ensure the keyboard dismisses properly
                                              // Future.delayed(Duration(milliseconds: 100), () {
                                              //   FocusScope.of(context).unfocus();
                                              // });
                                              LatLng? fromLatLng;
                                              if(_fromController!=null){
                                                print('from controllr ${_fromController.text}');
                                                // await _getCurrentLocation();
                                                print(pickupLocation);
                                                // LatLng? fromLatLng =
                                                // await _getLatLngFromAddress(
                                                //     _fromController.text);
                                                upDateValueOffromlatlong() async {
                                                  fromLatLng=await _getLatLngFromAddress(_fromController.text);
                                                }

                                                if(_fromController.text=='📍Your location'){
                                                  print('your location');
                                                  setState(() {
                                                    fromLatLng=pickupLocation;
                                                  });
                                                }else{
                                                  setState(()  {
                                                    print('alkdjfklasj');
                                                    upDateValueOffromlatlong();
                                                  });
                                                }
                                                LatLng? toLatLng =
                                                await _getLatLngFromAddress(
                                                    _toController.text);
                                                setState(() {
                                                  _initialChildSize = 0;
                                                });
                                                print(fromLatLng);
                                                print(toLatLng);
                                                if (fromLatLng != null &&
                                                    toLatLng != null) {
                                                  setState(() {
                                                    pickupLocation = fromLatLng;
                                                    _destinationLocation =
                                                        toLatLng;
                                                  });
                                                  final status =
                                                  await _setupPolylines();
                                                  _addMarkers();
                                                  mapController.moveCamera(
                                                    CameraUpdate.newLatLngZoom(
                                                        pickupLocation!, 14.0),
                                                  );

                                                  // if(status==1){
                                                  print('skldjflkasdklfadsklflkan $_distanceInKilometers');
                                                  if (_distanceInKilometers !=
                                                      null) {
                                                    print('skldjflkasdklfadsklflkan distance');
                                                    showModalBottomSheet(
                                                      context: context,
                                                      builder:
                                                          (BuildContext context) {
                                                        return Pricelist(
                                                          location: _destinationLocation!,
                                                          bikeFare: bikeFare,
                                                          autoFare: autoFare,
                                                          miniFare: miniFare,
                                                          sedanFare: sedanFare,
                                                          suvFare: suvFare,
                                                          currentLocation:
                                                          pickupLocation!,
                                                          from: _fromController
                                                              .text,
                                                          to: _toController.text,
                                                        );
                                                      },
                                                      isScrollControlled: false,
                                                    );
                                                  } else {
                                                    if (kDebugMode) {
                                                      print(
                                                          'Distance not calculated');
                                                    }
                                                  }
                                                }
                                              }else{
                                                print('_currunt location is not null');
                                              }
                                            },
                                            child: Text('Search Ride'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.amber,
                                              foregroundColor: Colors.black,
                                              // Text color
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(10),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    // Ridehistory widget moved above images
                                    Container(
                                      height: 300,
                                      child: Ridehistory(
                                        onToAddressSelected: _updateToAddress,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 10.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Image(
                                            image: AssetImage('assets/image/auto.png'),
                                            width: 50,
                                          ),
                                          Image(
                                            image: AssetImage('assets/image/bike.png'),
                                            width: 50,
                                          ),
                                          Image(
                                            image: AssetImage('assets/image/car.png'),
                                            width: 50,
                                          ),
                                          Image(
                                            image: AssetImage('assets/image/bike.png'),
                                            width: 50,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    // Book Now button
                                    // Center(
                                    //   child: BlocConsumer<BookRideBloc, BookRideState>(
                                    //     listener: (context, state) async {
                                    //       if (state is BookRideSuccess) {
                                    //         // Handle success state
                                    //       }
                                    //
                                    //       if (state is BookRideFailed) {
                                    //         SharedPreferences sp = await SharedPreferences.getInstance();
                                    //         context.read<BookRideBloc>().add(
                                    //           SendBookRideDetailsEvent(
                                    //             rideId: sp.getString(SharedPreffUtils().userIdKey) ?? '',
                                    //             destinationlatitude: _destinationLocation?.latitude ?? 0.0,
                                    //             sourcelatitude: pickupLocation?.latitude ?? 0.0,
                                    //             destinationLongitudex: _destinationLocation?.longitude ?? 0.0,
                                    //             sourceaddress: _fromController.text,
                                    //             sourceLongitudex: pickupLocation?.longitude ?? 0.0,
                                    //             destinationaddress: _toController.text,
                                    //             vehicleType: '',
                                    //             price: 300,
                                    //           ),
                                    //         );
                                    //       }
                                    //     },
                                    //     // builder: (context, state) {
                                    //     //   if (state is BookRideLoading) {
                                    //     //     return const Center(child: CircularProgressIndicator());
                                    //     //   }
                                    //     //
                                    //     //   return ElevatedButton(
                                    //     //     onPressed: () async {
                                    //     //       LatLng? fromLatLng;
                                    //     //       if (_fromController != null) {
                                    //     //         print('from controller ${_fromController.text}');
                                    //     //         upDateValueOffromlatlong() async {
                                    //     //           fromLatLng=await _getLatLngFromAddress(_fromController.text);
                                    //     //
                                    //     //           setState(()  {
                                    //     //           });
                                    //     //         }
                                    //     //         if (_fromController.text == '📍Your location') {
                                    //     //           setState(() {
                                    //     //             fromLatLng = pickupLocation;
                                    //     //           });
                                    //     //         } else {
                                    //     //           setState(() {
                                    //     //             upDateValueOffromlatlong();
                                    //     //           });
                                    //     //         }
                                    //     //         LatLng? toLatLng = await _getLatLngFromAddress(_toController.text);
                                    //     //         setState(() {
                                    //     //           _initialChildSize = 0;
                                    //     //         });
                                    //     //         if (fromLatLng != null && toLatLng != null) {
                                    //     //           setState(() {
                                    //     //             pickupLocation = fromLatLng;
                                    //     //             _destinationLocation = toLatLng;
                                    //     //           });
                                    //     //           final status = await _setupPolylines();
                                    //     //           _addMarkers();
                                    //     //           mapController.moveCamera(
                                    //     //             CameraUpdate.newLatLngZoom(pickupLocation!, 14.0),
                                    //     //           );
                                    //     //
                                    //     //           if (_distanceInKilometers != null) {
                                    //     //             showModalBottomSheet(
                                    //     //               context: context,
                                    //     //               builder: (BuildContext context) {
                                    //     //                 return Pricelist(
                                    //     //                   location: _destinationLocation!,
                                    //     //                   bikeFare: bikeFare,
                                    //     //                   autoFare: autoFare,
                                    //     //                   miniFare: miniFare,
                                    //     //                   sedanFare: sedanFare,
                                    //     //                   suvFare: suvFare,
                                    //     //                   currentLocation: pickupLocation!,
                                    //     //                   from: _fromController.text,
                                    //     //                   to: _toController.text,
                                    //     //                 );
                                    //     //               },
                                    //     //               isScrollControlled: false,
                                    //     //             );
                                    //     //           } else {
                                    //     //             if (kDebugMode) {
                                    //     //               print('Distance not calculated');
                                    //     //             }
                                    //     //           }
                                    //     //         }
                                    //     //       } else {
                                    //     //         print('_current location is not null');
                                    //     //       }
                                    //     //     },
                                    //     //     child: Text('Search Ride'),
                                    //     //     style: ElevatedButton.styleFrom(
                                    //     //       backgroundColor: Colors.black,
                                    //     //       foregroundColor: Colors.white,
                                    //     //       shape: RoundedRectangleBorder(
                                    //     //         borderRadius: BorderRadius.circular(10),
                                    //     //       ),
                                    //     //     ),
                                    //     //   );
                                    //     // },
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.amber,
              onPressed: () {
                setState(() {
                  _isSheetVisible = !_isSheetVisible;
                  _initialChildSize = _isSheetVisible ? 0.4 : 0.0;
                });
              },
              child: Icon(_isSheetVisible ? Icons.close : Icons.arrow_upward),
            ),
            drawer: SafeArea(  // Wrap the Drawer inside SafeArea
              child: Drawer(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    // Custom Drawer Header
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 4,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              colors: [
                                Colors.lightBlue.shade100,
                                Colors.lightBlue.shade300
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 25,
                                        backgroundColor: Colors.grey[300],
                                        backgroundImage: _profileImage != null
                                            ? FileImage(_profileImage!) // Use FileImage if image is loaded
                                            : null, // If no image, fall back to the child below
                                        child: _profileImage == null
                                            ? Icon(Icons.person, color: Colors.grey[600], size: 40)
                                            : null, // Hide icon if image is loaded
                                      ),
                                      SizedBox(width: 16),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            firstName, // Use the dynamic firstName
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          Text(
                                            mobileNo, // Use the dynamic mobileNo
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],

                                ),
                                Divider(height: 20),
                                Row(
                                  children: [
                                    Icon(Icons.star, color: Colors.amber),
                                    SizedBox(width: 8),
                                    Text(
                                      '0.00 My Rating',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    // List of options without arrows
                    _buildDrawerOption(
                        context,
                        icon: Icons.help_outline,
                        text: 'Help',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HelpScreen()),
                        );
                        // Navigate to Coins screenWalletScreen
                      },
                    ),
                    _buildDrawerOption(
                        context,
                        icon: Icons.payment,
                        text: 'Payment',
                        onTap: () {
                          // Navigate to Payment screen
                        }
                    ),
                    _buildDrawerOption(
                        context,
                        icon: Icons.history,
                        text: 'My Rides',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Ridehistory(onToAddressSelected: (String toAddress) {  },)),
                        );
                        // Navigate to Coins screenWalletScreen
                      },
                    ),
                    _buildDrawerOption(
                        context,
                        icon: Icons.security,
                        text: 'Safety',
                        onTap: () {
                          // Navigate to Safety screen
                        }
                    ),
                    _buildDrawerOption(
                      context,
                      icon: Icons.card_giftcard,
                      text: 'Refer and Earn',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ReferralScreen()),
                        );
                        // Navigate to Coins screenWalletScreen
                      },
                      trailingText: 'Get ₹50',
                    ),
                    _buildDrawerOption(
                        context,
                        icon: Icons.redeem,
                        text: 'My Rewards',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => WalletScreen()),
                        );
                        // Navigate to Coins screen
                      },
                    ),
                    _buildDrawerOption(
                        context,
                        icon: Icons.flash_on,
                        text: 'Power Pass',
                        onTap: () {
                          // Navigate to Power Pass screen
                        }
                    ),
                    _buildDrawerOption(
                        context,
                        icon: Icons.monetization_on,
                        text: 'City Ride Coins',
                        onTap: () {
                          // Navigate to Coins screen
                        }
                    ),
                    _buildDrawerOption(
                        context,
                        icon: Icons.person,
                        text: 'My Profile',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ProfileScreen()),
                          );
                          // Navigate to Coins screen
                        }
                    ),
                    _buildDrawerOption(
                        context,
                        icon: Icons.exit_to_app,
                        text: 'Log Out',
                        onTap: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => Loginscreen()),
                                (Route<dynamic> route) => false, // This removes all previous routes
                          );
                        }
                    ),
                  ],
                ),
              ),
            )
        ),
    )
    );
  }
  Widget _buildDrawerOption(BuildContext context, {required IconData icon, required String text, required VoidCallback onTap, String? trailingText}) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(text),
      trailing: trailingText != null
          ? Text(
        trailingText,
        style: TextStyle(color: Colors.green),
      )
          : null,
      onTap: onTap,
    );
  }
}
