import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/app_colors.dart';

class TermsConditionsView extends StatefulWidget {
  const TermsConditionsView({super.key});

  @override
  State<TermsConditionsView> createState() => _TermsConditionsViewState();
}

class _TermsConditionsViewState extends State<TermsConditionsView> {
  List<dynamic> _terms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTerms();
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
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Terms & Conditions',
          style: TextStyle(color: AppColors.pureWhite),
        ),
        backgroundColor: AppColors.primaryDark,
        iconTheme: const IconThemeData(color: AppColors.pureWhite),
      ),
      backgroundColor: AppColors.backgroundBeige,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            )
          : _terms.isEmpty
          ? const Center(child: Text('Failed to load terms.'))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _terms.length,
              itemBuilder: (context, index) {
                final term = _terms[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.pureWhite,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        term['sectionTitle'] ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        term['content'] ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
