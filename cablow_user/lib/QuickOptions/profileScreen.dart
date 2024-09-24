import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../Authentication/LoginScreen.dart';
import '../SharedPrefUtils.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final SharedPreffUtils sharedPrefs = SharedPreffUtils();
  final ImagePicker _picker = ImagePicker();
  File? _profileImage;

  final Map<String, String> _profileData = {
    'Full Name': '',
    'Phone Number': '',
    'About Me': 'A passionate developer.',
  };

  bool _isEditing = false;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() {
      _isLoading = true;
    });

    final firstName = await sharedPrefs.getStringValue(sharedPrefs.firstNameKey) ?? '';
    final phoneNumber = await sharedPrefs.getStringValue(sharedPrefs.mobileNumberKey) ?? '';
    final savedImagePath = await sharedPrefs.getStringValue('profile_image');

    setState(() {
      _profileData['Full Name'] = firstName;
      _profileData['Phone Number'] = phoneNumber;

      // Check if saved image path exists and the file exists
      if (savedImagePath != null && File(savedImagePath).existsSync()) {
        _profileImage = File(savedImagePath);
      }
      _isLoading = false;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
      // Save the image path in SharedPreferences
      await sharedPrefs.saveStringValue('profile_image', pickedFile.path);
    }
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isEditing = false;
      });
    }
  }

  void _showContactUsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Contact Us'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Phone Number: +1234567890'),
              SizedBox(height: 8),
              Text('Email: support@example.com'),
              SizedBox(height: 8),
              Text('Website: www.example.com'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String userName = _profileData['Full Name'] ?? 'User';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.lightBlue.shade100,
                      Colors.lightBlue.shade300
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: Icon(Icons.camera_alt),
                                  title: Text('Take a photo'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _pickImage(ImageSource.camera);
                                  },
                                ),
                                ListTile(
                                  leading: Icon(Icons.photo_library),
                                  title: Text('Choose from gallery'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _pickImage(ImageSource.gallery);
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: _profileImage != null
                              ? DecorationImage(
                            image: FileImage(_profileImage!),
                            fit: BoxFit.cover,
                          )
                              : DecorationImage(
                            image: AssetImage('assets/image/addprofile.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _isEditing
                              ? TextFormField(
                            initialValue: _profileData['Full Name'],
                            decoration: InputDecoration(
                              labelText: 'Full Name',
                              labelStyle: TextStyle(color: Colors.white),
                              fillColor: Colors.white,
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            onSaved: (value) {
                              _profileData['Full Name'] = value!;
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your full name';
                              }
                              return null;
                            },
                          )
                              : Text(
                            userName,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ExpansionTile(
                    title: Text(
                      'View Profile Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    children: _profileData.keys.map((key) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: ListTile(
                          title: Text(key),
                          subtitle: _isEditing
                              ? TextFormField(
                            initialValue: _profileData[key],
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            onSaved: (value) {
                              _profileData[key] = value!;
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your $key';
                              }
                              return null;
                            },
                          )
                              : Text(_profileData[key]!),
                          leading: Icon(_getIconForField(key)),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: Icon(Icons.description, color: Colors.black54),
                      title: Text('Terms & Conditions'),
                      onTap: () {
                        // Navigate to Terms & Conditions screen or show a dialog
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.info, color: Colors.black54),
                      title: Text('About Us'),
                      onTap: () {
                        // Navigate to About Us screen or show a dialog
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.contact_mail, color: Colors.black54),
                      title: Text('Contact Us'),
                      onTap: _showContactUsDialog,
                    ),
                    ListTile(
                      leading: Icon(Icons.logout, color: Colors.black54),
                      title: Text('Logout'),
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => Loginscreen()),
                              (Route<dynamic> route) => false, // This removes all previous routes
                        );
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Relax! We're here for you.",
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),// Additional UI elements
            ],
          ),
        ),
      ),
    );
  }
  IconData _getIconForField(String key) {
    switch (key) {
      case 'Full Name':
        return Icons.person;
      case 'Phone Number':
        return Icons.phone;
      case 'About Me':
        return Icons.info;
      default:
        return Icons.info;
    }
  }
}
