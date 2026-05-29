import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../viewmodels/login_view_model.dart';

class AdminHostelsView extends StatefulWidget {
  const AdminHostelsView({super.key});

  @override
  State<AdminHostelsView> createState() => _AdminHostelsViewState();
}

class _AdminHostelsViewState extends State<AdminHostelsView> {
  List<dynamic> _hostels = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHostels();
  }

  Map<String, String> _getHeaders() {
    final token =
        Provider.of<LoginViewModel>(
          context,
          listen: false,
        ).currentUser?.token ??
        '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<void> _fetchHostels() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/api/admin/hostels'),
        headers: _getHeaders(),
      );
      if (response.statusCode == 200) {
        setState(() {
          _hostels = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteHostel(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('http://10.0.2.2:3000/api/admin/hostels/$id'),
        headers: _getHeaders(),
      );
      if (response.statusCode == 200) {
        _fetchHostels();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Hostel deleted.')));
      }
    } catch (e) {}
  }

  void _showHostelDialog({Map<String, dynamic>? hostel}) {
    final _nameController = TextEditingController(text: hostel?['name'] ?? '');
    final _cityController = TextEditingController(text: hostel?['city'] ?? '');
    final _addressController = TextEditingController(
      text: hostel?['address'] ?? '',
    );
    final _contactEmailController = TextEditingController(
      text: hostel?['contactEmail'] ?? '',
    );
    final _descController = TextEditingController(
      text: hostel?['description'] ?? '',
    );
    final bool isEditing = hostel != null;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Hostel' : 'Add Hostel'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: _cityController,
                  decoration: const InputDecoration(labelText: 'City'),
                ),
                TextField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                ),
                TextField(
                  controller: _contactEmailController,
                  decoration: const InputDecoration(labelText: 'Contact Email'),
                ),
                TextField(
                  controller: _descController,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
              ),
              onPressed: () async {
                final name = _nameController.text.trim();
                final city = _cityController.text.trim();
                final address = _addressController.text.trim();
                if (name.isNotEmpty && city.isNotEmpty && address.isNotEmpty) {
                  final body = json.encode({
                    'name': name,
                    'city': city,
                    'address': address,
                    'contactEmail': _contactEmailController.text.trim(),
                    'description': _descController.text.trim(),
                  });
                  Navigator.pop(context);

                  try {
                    http.Response response;
                    if (isEditing) {
                      response = await http.put(
                        Uri.parse(
                          'http://10.0.2.2:3000/api/admin/hostels/${hostel['_id']}',
                        ),
                        headers: _getHeaders(),
                        body: body,
                      );
                    } else {
                      response = await http.post(
                        Uri.parse('http://10.0.2.2:3000/api/admin/hostels'),
                        headers: _getHeaders(),
                        body: body,
                      );
                    }
                    if (response.statusCode == 201 ||
                        response.statusCode == 200) {
                      _fetchHostels();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isEditing ? 'Hostel Updated.' : 'Hostel Added.',
                          ),
                        ),
                      );
                    }
                  } catch (e) {}
                }
              },
              child: const Text(
                'Save',
                style: TextStyle(color: AppColors.pureWhite),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Hostels',
          style: TextStyle(color: AppColors.pureWhite),
        ),
        backgroundColor: AppColors.primaryDark,
      ),
      backgroundColor: AppColors.backgroundBeige,
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add, color: AppColors.pureWhite),
        backgroundColor: AppColors.primaryGreen,
        onPressed: () => _showHostelDialog(),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: _hostels.length,
              itemBuilder: (context, index) {
                final hostel = _hostels[index];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 8,
                  ),
                  child: ListTile(
                    title: Text(
                      hostel['name'] ?? 'No Name',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('${hostel['city']} - ${hostel['address']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.blueAccent,
                          ),
                          onPressed: () => _showHostelDialog(hostel: hostel),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteHostel(hostel['_id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
