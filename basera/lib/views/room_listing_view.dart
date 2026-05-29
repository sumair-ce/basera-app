import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_colors.dart';
import '../viewmodels/room_view_model.dart';
import '../models/room_model.dart';
import 'hotel_detail_view.dart';

class RoomListingView extends StatefulWidget {
  final String city;

  const RoomListingView({Key? key, required this.city}) : super(key: key);

  @override
  _RoomListingViewState createState() => _RoomListingViewState();
}

class _RoomListingViewState extends State<RoomListingView> {
  DateTime? _startDate;
  DateTime? _endDate;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query, DashboardViewModel vm) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      vm.updateSearch(query);
    });
  }

  void _selectDates(BuildContext context, DashboardViewModel vm) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: AppColors.primaryDark,
            colorScheme: ColorScheme.light(primary: AppColors.primaryDark),
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      vm.updateDates(
        _startDate!.toIso8601String(),
        _endDate!.toIso8601String(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<DashboardViewModel>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Clean, high-end off-white
      appBar: AppBar(
        title: Text(
          '${widget.city} Stays',
          style: const TextStyle(
            color: AppColors.pureWhite,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.pureWhite),
      ),
      body: Column(
        children: [
          _buildHeaderFilters(context, vm),
          Expanded(
            child: vm.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryDark,
                    ),
                  )
                : vm.errorMessage != null
                ? Center(
                    child: Text(
                      vm.errorMessage!,
                      style: const TextStyle(color: AppColors.errorRed),
                    ),
                  )
                : vm.rooms.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    physics: const BouncingScrollPhysics(),
                    itemCount: vm.rooms.length,
                    itemBuilder: (context, index) {
                      return _buildRoomCard(context, vm.rooms[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // --- Header, Search, and Filters ---
  Widget _buildHeaderFilters(BuildContext context, DashboardViewModel vm) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Column(
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: AppColors.pureWhite.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => _onSearchChanged(val, vm),
              style: const TextStyle(color: AppColors.pureWhite),
              decoration: InputDecoration(
                hintText: 'Search hotels by name...',
                hintStyle: TextStyle(
                  color: AppColors.pureWhite.withOpacity(0.6),
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.pureWhite,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Date Selector Button
          GestureDetector(
            onTap: () => _selectDates(context, vm),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.pureWhite,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_month_rounded,
                    color: AppColors.primaryDark,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _startDate != null && _endDate != null
                        ? '${DateFormat('MMM d').format(_startDate!)}  -  ${DateFormat('MMM d').format(_endDate!)}'
                        : 'Select Dates',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Scrollable Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildDropdownFilter(
                  label: vm.selectedCategory == 'All'
                      ? 'Category'
                      : vm.selectedCategory,
                  icon: Icons.hotel_class_outlined,
                  items: ['All', 'Basic', 'Deluxe', 'Premium', 'Suite'],
                  onSelected: (val) => vm.updateCategoryFilter(val),
                ),
                const SizedBox(width: 10),
                _buildDropdownFilter(
                  label: vm.selectedBeds == 0
                      ? 'Beds'
                      : '${vm.selectedBeds} Bed(s)',
                  icon: Icons.bed_outlined,
                  items: ['All', '1', '2', '3', '4'],
                  onSelected: (val) =>
                      vm.updateBedFilter(val == 'All' ? 0 : int.parse(val)),
                ),
                const SizedBox(width: 10),
                _buildDropdownFilter(
                  label: vm.sortOrder == 'Default' ? 'Sort' : vm.sortOrder,
                  icon: Icons.sort,
                  items: ['Default', 'Low to High', 'High to Low'],
                  onSelected: (val) => vm.updateSortOrder(val),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownFilter({
    required String label,
    required IconData icon,
    required List<String> items,
    required Function(String) onSelected,
  }) {
    return PopupMenuButton<String>(
      onSelected: onSelected,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (context) => items
          .map((item) => PopupMenuItem(value: item, child: Text(item)))
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.pureWhite.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.pureWhite.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.pureWhite, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.pureWhite,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.arrow_drop_down,
              color: AppColors.pureWhite,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  // --- Empty State ---
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 80,
            color: Colors.grey.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          const Text(
            'No rooms match your filters.',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // --- Premium Room Card ---
  Widget _buildRoomCard(BuildContext context, RoomModel room) {
    final double displayRating = room.rating > 0
        ? room.rating
        : (4.0 + (room.title.hashCode.abs() % 10) / 10);

    final int displayReviews = room.reviews > 0
        ? room.reviews
        : (20 + (room.title.hashCode.abs() % 150));

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HotelDetailView(room: room),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(top: 16),
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Area
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: Stack(
                children: [
                  Image.network(
                    room.imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 200,
                      color: Colors.grey[200],
                      child: const Icon(Icons.hotel, size: 50, color: Colors.grey),
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.black.withOpacity(0.3), Colors.transparent, Colors.black.withOpacity(0.5)],
                          stops: const [0.0, 0.4, 1.0],
                        ),
                      ),
                    ),
                  ),
                  // Category badge
                  Positioned(
                    top: 14,
                    right: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.accentSand,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        room.category.toUpperCase(),
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.pureWhite, letterSpacing: 0.5),
                      ),
                    ),
                  ),
                  // Availability badge
                  if (_startDate != null)
                    Positioned(
                      top: 14,
                      left: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: room.isAvailableForDates ? AppColors.primaryGreen : AppColors.errorRed,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              room.isAvailableForDates ? Icons.check_circle_outline : Icons.cancel_outlined,
                              color: AppColors.pureWhite,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              room.isAvailableForDates ? 'Available' : 'Booked',
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.pureWhite),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Rating overlay
                  Positioned(
                    bottom: 12,
                    left: 14,
                    child: Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          '${displayRating.toStringAsFixed(1)} ($displayReviews)',
                          style: const TextStyle(color: AppColors.pureWhite, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Details Area
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          room.title,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryDark, height: 1.2),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Rs.${room.pricePerNight.toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primaryDark),
                          ),
                          const Text('/ night', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _buildInfoChip(Icons.bed_outlined, '${room.beds} Bed(s)'),
                      _buildInfoChip(Icons.space_dashboard_outlined, room.config),
                      _buildInfoChip(Icons.location_on_outlined, room.city),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppColors.primaryDark, AppColors.primaryGreen]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('View Details & Book', style: TextStyle(color: AppColors.pureWhite, fontWeight: FontWeight.bold, fontSize: 14)),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_forward_rounded, color: AppColors.pureWhite, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.black87),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
