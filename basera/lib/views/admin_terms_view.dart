import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../viewmodels/login_view_model.dart';

class AdminTermsView extends StatefulWidget {
  const AdminTermsView({super.key});

  @override
  State<AdminTermsView> createState() => _AdminTermsViewState();
}

class _AdminTermsViewState extends State<AdminTermsView> {
  List<dynamic> _terms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTerms();
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

  Future<void> _fetchTerms() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/api/terms'),
      );
      if (response.statusCode == 200) {
        setState(() {
          _terms = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteTerm(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('http://10.0.2.2:3000/api/terms/$id'),
        headers: _getHeaders(),
      );
      if (response.statusCode == 200) {
        _fetchTerms();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Term deleted.')));
      }
    } catch (e) {}
  }

  void _showTermDialog({Map<String, dynamic>? term}) {
    final _titleController = TextEditingController(
      text: term?['sectionTitle'] ?? '',
    );
    final _contentController = TextEditingController(
      text: term?['content'] ?? '',
    );
    final _orderController = TextEditingController(
      text: term != null ? term['order'].toString() : '0',
    );
    final bool isEditing = term != null;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit T&C Section' : 'Add T&C Section'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Section Title'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _orderController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Order (Number)',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _contentController,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Content'),
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
                final title = _titleController.text.trim();
                final content = _contentController.text.trim();
                final order = int.tryParse(_orderController.text.trim()) ?? 0;

                if (title.isNotEmpty && content.isNotEmpty) {
                  final body = json.encode({
                    'sectionTitle': title,
                    'content': content,
                    'order': order,
                  });
                  Navigator.pop(context);

                  try {
                    http.Response response;
                    if (isEditing) {
                      response = await http.put(
                        Uri.parse(
                          'http://10.0.2.2:3000/api/terms/${term["_id"]}',
                        ),
                        headers: _getHeaders(),
                        body: body,
                      );
                    } else {
                      response = await http.post(
                        Uri.parse('http://10.0.2.2:3000/api/terms'),
                        headers: _getHeaders(),
                        body: body,
                      );
                    }
                    if (response.statusCode == 201 ||
                        response.statusCode == 200) {
                      _fetchTerms();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isEditing ? 'T&C Updated.' : 'T&C Added.',
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
          'Manage T&Cs',
          style: TextStyle(color: AppColors.pureWhite),
        ),
        backgroundColor: AppColors.primaryDark,
      ),
      backgroundColor: AppColors.backgroundBeige,
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add, color: AppColors.pureWhite),
        backgroundColor: AppColors.primaryGreen,
        onPressed: () => _showTermDialog(),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: _terms.length,
              itemBuilder: (context, index) {
                final term = _terms[index];
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
                      term['sectionTitle'] ?? 'No Title',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      term['content'] ?? 'No Content',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.blueAccent,
                          ),
                          onPressed: () => _showTermDialog(term: term),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteTerm(term['_id']),
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
