// import 'package:flutter/material.dart';
// import 'package:google_place/google_place.dart';
// import 'package:flutter_typeahead/flutter_typeahead.dart';
//
// class PlacesAutocomplete extends StatefulWidget {
//   @override
//   _PlacesAutocompleteState createState() => _PlacesAutocompleteState();
// }
//
// class _PlacesAutocompleteState extends State<PlacesAutocomplete> {
//   late GooglePlace googlePlace;
//   final TextEditingController _controller = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     googlePlace = GooglePlace('YOUR_API_KEY'); // Replace with your API key
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Google Places Autocomplete')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: TypeAheadField<AutocompletePrediction>(
//           textFieldConfiguration: TextFieldConfiguration(
//             controller: _controller,
//             decoration: InputDecoration(
//               labelText: 'Search Places',
//               border: OutlineInputBorder(),
//             ),
//           ),
//           suggestionsCallback: _getSuggestions,
//           itemBuilder: (context, AutocompletePrediction suggestion) {
//             return ListTile(
//               leading: Icon(Icons.location_on),
//               title: Text(suggestion.description ?? ''),
//             );
//           },
//           onSuggestionSelected: (AutocompletePrediction suggestion) {
//             _controller.text = suggestion.description ?? '';
//           }, onSelected: (InvalidType value) {  },
//         ),
//       ),
//     );
//   }
//
//   Future<List<AutocompletePrediction>> _getSuggestions(String input) async {
//     if (input.isEmpty) {
//       return [];
//     }
//
//     var result = await googlePlace.autocomplete.get(input);
//
//     if (result != null && result.predictions != null) {
//       return result.predictions!;
//     }
//
//     return [];
//   }
// }
