import 'package:cablow_user/googleMapsScreen/rideHistoryBloc/ride_history_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Ridehistory extends StatefulWidget {
  final Function(String toAddress) onToAddressSelected;

  const Ridehistory({super.key, required this.onToAddressSelected});

  @override
  State<Ridehistory> createState() => _RidehistoryState();
}

class _RidehistoryState extends State<Ridehistory> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RideHistoryBloc()..add(FetchRideHistoryEvent()),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text('🕰️ Recent Rides'),
          titleTextStyle: TextStyle(fontSize: 25,  // Adjust font size
          fontWeight: FontWeight.w900,  // Set font weight
          color: Colors.black,
          ),
          centerTitle: true,
        ),
        backgroundColor: Colors.white,
        body: BlocBuilder<RideHistoryBloc, RideHistoryState>(
          builder: (context, state) {
            if (state is RideHistorySuccess) {
              final data = state.historyData;
              return ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Icon(Icons.location_on),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('From - ${data[index]['source_address']}'),
                        Text('To - ${data[index]['destination_address']}'),
                      ],
                    ),
                    trailing: Icon(Icons.favorite_border),
                    onTap: () {
                      // Pass the selected "To" address back to the parent
                      widget.onToAddressSelected(data[index]['destination_address']);
                    },
                  );
                },
              );
            }
            return SizedBox();
          },
        ),
      ),
    );
  }
}
