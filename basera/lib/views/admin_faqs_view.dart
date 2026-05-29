import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../viewmodels/login_view_model.dart';

class AdminFaqsView extends StatefulWidget {
  const AdminFaqsView({super.key});

  @override
  State<AdminFaqsView> createState() => _AdminFaqsViewState();
}

class _AdminFaqsViewState extends State<AdminFaqsView> {
  List<dynamic> _faqs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFaqs();
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

  Future<void> _fetchFaqs() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/api/faqs'),
      ); // Public endpoint
      if (response.statusCode == 200) {
        setState(() {
          _faqs = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteFaq(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('http://10.0.2.2:3000/api/faqs/$id'),
        headers: _getHeaders(),
      );
      if (response.statusCode == 200) {
        _fetchFaqs();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('FAQ deleted.')));
      }
    } catch (e) {}
  }

  void _showFaqDialog({Map<String, dynamic>? faq}) {
    final _questionController = TextEditingController(
      text: faq?['question'] ?? '',
    );
    final _answerController = TextEditingController(text: faq?['answer'] ?? '');
    final bool isEditing = faq != null;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit FAQ' : 'Add FAQ'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _questionController,
                  decoration: const InputDecoration(labelText: 'Question'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _answerController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Answer'),
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
                final question = _questionController.text.trim();
                final answer = _answerController.text.trim();
                if (question.isNotEmpty && answer.isNotEmpty) {
                  final body = json.encode({
                    'question': question,
                    'answer': answer,
                  });
                  Navigator.pop(
                    context,
                  ); // close dialog immediately, loading state could be better, keeping it simple

                  try {
                    http.Response response;
                    if (isEditing) {
                      response = await http.put(
                        Uri.parse(
                          'http://10.0.2.2:3000/api/faqs/${faq["_id"]}',
                        ),
                        headers: _getHeaders(),
                        body: body,
                      );
                    } else {
                      response = await http.post(
                        Uri.parse('http://10.0.2.2:3000/api/faqs'),
                        headers: _getHeaders(),
                        body: body,
                      );
                    }
                    if (response.statusCode == 201 ||
                        response.statusCode == 200) {
                      _fetchFaqs();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isEditing ? 'FAQ Updated.' : 'FAQ Added.',
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
          'Manage FAQs',
          style: TextStyle(color: AppColors.pureWhite),
        ),
        backgroundColor: AppColors.primaryDark,
      ),
      backgroundColor: AppColors.backgroundBeige,
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add, color: AppColors.pureWhite),
        backgroundColor: AppColors.primaryGreen,
        onPressed: () => _showFaqDialog(),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: _faqs.length,
              itemBuilder: (context, index) {
                final faq = _faqs[index];
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
                      faq['question'] ?? 'No Question',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      faq['answer'] ?? 'No Answer',
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
                          onPressed: () => _showFaqDialog(faq: faq),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteFaq(faq['_id']),
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
