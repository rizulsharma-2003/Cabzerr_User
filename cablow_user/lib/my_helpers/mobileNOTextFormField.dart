import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MobileNumberField extends StatelessWidget {
  final TextEditingController controller;

  const MobileNumberField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly, // Allow only digits
        LengthLimitingTextInputFormatter(10),   // Limit to 10 digits
      ],
      decoration: const InputDecoration(
        // labelText: 'Mobile Number',
        hintText: 'Enter your mobile number',
        border: OutlineInputBorder(
            borderRadius: BorderRadius.zero
        ),
        // prefixIcon: Icon(Icons.phone), // Optional: add a phone icon
      ),
      validator: (value) {
        // Simple validation: check if the input is empty or not a 10-digit number
        if (value == null || value.isEmpty) {
          return 'Please enter your mobile number';
        } else if (value.length != 10) {
          return 'Please enter a valid 10-digit mobile number';
        }
        return null;
      },
    );
  }
}
