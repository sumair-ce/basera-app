import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/app_colors.dart';

class FaqView extends StatefulWidget {
  const FaqView({super.key});

  @override
  State<FaqView> createState() => _FaqViewState();
}

class _FaqViewState extends State<FaqView> {
  List<dynamic> _faqs = [];
  List<dynamic> _filteredFaqs = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  int? _expandedIndex;

  @override
  void initState() {
    super.initState();
    _fetchFaqs();
    _searchController.addListener(_filterFaqs);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterFaqs() {
    final q = _searchController.text.toLowerCase();
    setState(() {
      _filteredFaqs = _faqs
          .where(
            (f) =>
                (f['question'] ?? '').toLowerCase().contains(q) ||
                (f['answer'] ?? '').toLowerCase().contains(q),
          )
          .toList();
    });
  }

  Future<void> _fetchFaqs() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/api/faqs'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        setState(() {
          _faqs = data;
          _filteredFaqs = data;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: AppColors.primaryDark,
            iconTheme: const IconThemeData(color: AppColors.pureWhite),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryDark, AppColors.primaryGreen],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 40),
                    Icon(
                      Icons.help_outline_rounded,
                      color: Colors.white70,
                      size: 40,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Frequently Asked Questions',
                      style: TextStyle(
                        color: AppColors.pureWhite,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Find answers to common questions',
                      style: TextStyle(color: Colors.white60, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.pureWhite,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search FAQs...',
                    hintStyle: const TextStyle(color: AppColors.textHint),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.primaryGreen,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.clear_rounded,
                              color: AppColors.textHint,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              _filterFaqs();
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
          ),

          if (_isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primaryGreen),
              ),
            )
          else if (_filteredFaqs.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      size: 60,
                      color: AppColors.textHint,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'No FAQs found',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final faq = _filteredFaqs[index];
                  final isExpanded = _expandedIndex == index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppColors.pureWhite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isExpanded
                            ? AppColors.primaryGreen.withOpacity(0.4)
                            : Colors.transparent,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(
                            isExpanded ? 0.08 : 0.04,
                          ),
                          blurRadius: isExpanded ? 16 : 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => setState(
                            () => _expandedIndex = isExpanded ? null : index,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: isExpanded
                                            ? AppColors.primaryGreen
                                            : AppColors.lightGreen,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${index + 1}',
                                          style: TextStyle(
                                            color: isExpanded
                                                ? AppColors.pureWhite
                                                : AppColors.primaryGreen,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        faq['question'] ?? '',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: isExpanded
                                              ? AppColors.primaryDark
                                              : AppColors.textPrimary,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    AnimatedRotation(
                                      duration: const Duration(
                                        milliseconds: 250,
                                      ),
                                      turns: isExpanded ? 0.5 : 0,
                                      child: Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: isExpanded
                                            ? AppColors.primaryGreen
                                            : AppColors.textHint,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isExpanded)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.fromLTRB(
                                    60,
                                    0,
                                    16,
                                    16,
                                  ),
                                  child: Text(
                                    faq['answer'] ?? '',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      height: 1.6,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }, childCount: _filteredFaqs.length),
              ),
            ),
        ],
      ),
    );
  }
}
