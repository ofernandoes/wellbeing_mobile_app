// lib/user_details_screen.dart

import 'package:flutter/material.dart';
import 'package:wellbeing_mobile_app/theme/app_colors.dart';
import 'package:wellbeing_mobile_app/services/firestore_service.dart'; // To save the data

class UserDetailsScreen extends StatefulWidget {
  const UserDetailsScreen({super.key});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  String _firstName = '';
  String _lastName = '';
  String? _gender;
  String _phoneNumber = '';
  String _address = '';
  String _postCode = '';
  String _city = '';
  String _country = '';
  bool _isLoading = false;

  final List<String> _genderOptions = ['Male', 'Female', 'Other', 'Prefer not to say'];

  Future<void> _saveUserDetails() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      final userDetails = {
        'firstName': _firstName.trim(),
        'lastName': _lastName.trim(),
        'gender': _gender,
        'phoneNumber': _phoneNumber.trim(),
        'address': _address.trim(),
        'postCode': _postCode.trim(),
        'city': _city.trim(),
        'country': _country.trim(),
        'registrationDate': DateTime.now().toIso8601String(),
      };

      try {
        // 🔥 CRITICAL: Call a new method in FirestoreService to save user metadata
        await FirestoreService().saveUserDetails(userDetails);
        
        // Navigate to the main app screen after successful save
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save details. Please try again. Error: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                'Tell us a bit more about you!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
              ),
              const SizedBox(height: 20),

              // Name and Last Name
              Row(
                children: [
                  Expanded(child: _buildTextField('First Name', (value) => _firstName = value!)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField('Last Name', (value) => _lastName = value!)),
                ],
              ),
              const SizedBox(height: 16),

              // Gender Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.people_alt, color: AppColors.primaryColor),
                ),
                value: _gender,
                items: _genderOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _gender = newValue;
                  });
                },
                onSaved: (value) => _gender = value,
                validator: (value) => value == null ? 'Please select your gender' : null,
              ),
              const SizedBox(height: 16),

              // Phone Number
              _buildTextField('Phone Number', (value) => _phoneNumber = value!, keyboardType: TextInputType.phone),
              const SizedBox(height: 16),

              // Address
              _buildTextField('Address', (value) => _address = value!),
              const SizedBox(height: 16),

              // Post Code, City
              Row(
                children: [
                  Expanded(child: _buildTextField('Post Code', (value) => _postCode = value!, keyboardType: TextInputType.streetAddress)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField('City', (value) => _city = value!)),
                ],
              ),
              const SizedBox(height: 16),

              // Country
              _buildTextField('Country', (value) => _country = value!),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _isLoading ? null : _saveUserDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Complete Profile',
                        style: TextStyle(fontSize: 18, color: AppColors.textDark, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, FormFieldSetter<String> onSaved, {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: _getIcon(label),
      ),
      keyboardType: keyboardType,
      onSaved: onSaved,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label cannot be empty';
        }
        return null;
      },
    );
  }
  
  Icon _getIcon(String label) {
    if (label.contains('Name')) return const Icon(Icons.person, color: AppColors.primaryColor);
    if (label.contains('Phone')) return const Icon(Icons.phone, color: AppColors.primaryColor);
    if (label.contains('Address')) return const Icon(Icons.location_on, color: AppColors.primaryColor);
    if (label.contains('Post Code')) return const Icon(Icons.local_post_office, color: AppColors.primaryColor);
    if (label.contains('City')) return const Icon(Icons.location_city, color: AppColors.primaryColor);
    if (label.contains('Country')) return const Icon(Icons.flag, color: AppColors.primaryColor);
    return const Icon(Icons.text_fields, color: AppColors.primaryColor);
  }
}
