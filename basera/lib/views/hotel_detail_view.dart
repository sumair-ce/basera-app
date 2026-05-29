import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../core/constants/app_colors.dart';
import '../models/room_model.dart';
import '../services/booking_service.dart';
import 'booking_form_view.dart';

class HotelDetailView extends StatefulWidget {
  final RoomModel room;

  const HotelDetailView({Key? key, required this.room}) : super(key: key);

  @override
  _HotelDetailViewState createState() => _HotelDetailViewState();
}

class _HotelDetailViewState extends State<HotelDetailView> with SingleTickerProviderStateMixin {
  final BookingService _bookingService = BookingService();

  DateTime _focusedDay = DateTime.now();
  DateTime? _startDate;
  DateTime? _endDate;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOn;

  Set<DateTime> _bookedDates = {};
  bool _loadingDates = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchBookedDates();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchBookedDates() async {
    try {
      final ranges = await _bookingService.getBookedDatesForRoom(widget.room.id);
      final Set<DateTime> allDates = {};
      for (final range in ranges) {
        final start = DateTime.parse(range['startDate']).toLocal();
        final end = DateTime.parse(range['endDate']).toLocal();
        DateTime cur = DateTime(start.year, start.month, start.day);
        final endNorm = DateTime(end.year, end.month, end.day);
        while (!cur.isAfter(endNorm)) {
          allDates.add(cur);
          cur = cur.add(const Duration(days: 1));
        }
      }
      if (mounted) {
        setState(() {
          _bookedDates = allDates;
          _loadingDates = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingDates = false);
    }
  }

  bool _isDayBooked(DateTime day) {
    final norm = DateTime(day.year, day.month, day.day);
    return _bookedDates.contains(norm);
  }

  List<Map<String, dynamic>> _getAmenities() {
    final cat = widget.room.category.toLowerCase();
    List<Map<String, dynamic>> base = [
      {'icon': Icons.wifi_rounded, 'label': 'Free WiFi'},
      {'icon': Icons.local_parking_rounded, 'label': 'Parking'},
      {'icon': Icons.ac_unit_rounded, 'label': 'A/C'},
      {'icon': Icons.restaurant_menu_rounded, 'label': 'Dining'},
    ];
    if (cat == 'deluxe' || cat == 'vip' || cat == 'premium' || cat == 'suite') {
      base.addAll([
        {'icon': Icons.pool_rounded, 'label': 'Heated Room'},
        {'icon': Icons.landscape_rounded, 'label': 'Mountain View'},
      ]);
    }
    if (cat == 'vip' || cat == 'premium' || cat == 'suite') {
      base.addAll([
        {'icon': Icons.spa_rounded, 'label': 'Room Service'},
        {'icon': Icons.local_bar_rounded, 'label': 'Mini Bar'},
      ]);
    }
    return base;
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focused) {
    setState(() {
      _focusedDay = focused;
      _startDate = start;
      _endDate = end;
      _rangeSelectionMode = RangeSelectionMode.toggledOn;
    });
  }

  bool _rangeHasConflict() {
    if (_startDate == null) return false;
    final end = _endDate ?? _startDate!;
    DateTime cur = DateTime(_startDate!.year, _startDate!.month, _startDate!.day);
    final endN = DateTime(end.year, end.month, end.day);
    while (!cur.isAfter(endN)) {
      if (_bookedDates.contains(cur)) return true;
      cur = cur.add(const Duration(days: 1));
    }
    return false;
  }

  void _proceedToBook() {
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select check-in and check-out dates'),
          backgroundColor: AppColors.errorRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (_rangeHasConflict()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selected dates overlap with existing bookings. Please choose different dates.'),
          backgroundColor: AppColors.errorRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingFormView(
          room: widget.room,
          startDate: _startDate!,
          endDate: _endDate ?? _startDate!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final room = widget.room;
    final double displayRating = room.rating > 0 ? room.rating : (4.0 + (room.title.hashCode.abs() % 10) / 10);
    final int displayReviews = room.reviews > 0 ? room.reviews : (20 + (room.title.hashCode.abs() % 150));
    final int days = (_endDate != null && _startDate != null)
        ? _endDate!.difference(_startDate!).inDays.clamp(1, 9999)
        : 1;

    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      body: Stack(
        children: [
          // Scrollable content
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Hero Image App Bar
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                stretch: true,
                backgroundColor: AppColors.primaryDark,
                iconTheme: const IconThemeData(color: AppColors.pureWhite),
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [StretchMode.zoomBackground],
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        room.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.primaryDark,
                          child: const Icon(Icons.hotel, color: AppColors.pureWhite, size: 60),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.3),
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                            stops: const [0.0, 0.4, 1.0],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        left: 20,
                        right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.accentSand,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                room.category.toUpperCase(),
                                style: const TextStyle(
                                  color: AppColors.pureWhite,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              room.title,
                              style: const TextStyle(
                                color: AppColors.pureWhite,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                shadows: [Shadow(color: Colors.black45, blurRadius: 10)],
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.location_on, color: AppColors.accentSand, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  room.city,
                                  style: TextStyle(color: AppColors.pureWhite.withOpacity(0.9), fontSize: 13),
                                ),
                                const SizedBox(width: 16),
                                const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  '${ displayRating.toStringAsFixed(1)} (${displayReviews})',
                                  style: TextStyle(color: AppColors.pureWhite.withOpacity(0.9), fontSize: 13),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Price + Quick Info
                    Container(
                      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.pureWhite,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5)),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Price per night', style: TextStyle(color: AppColors.textHint, fontSize: 13)),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Rs.${room.pricePerNight.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [AppColors.primaryDark, AppColors.primaryGreen],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.bed_rounded, color: AppColors.pureWhite, size: 18),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${room.beds} Bed${room.beds > 1 ? 's' : ''}',
                                      style: const TextStyle(color: AppColors.pureWhite, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildInfoBadge(Icons.space_dashboard_outlined, room.config),
                              _buildInfoBadge(Icons.location_city_rounded, room.city),
                              _buildInfoBadge(Icons.hotel_class_outlined, room.category),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Tab Bar
                    const SizedBox(height: 16),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.pureWhite,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10),
                        ],
                      ),
                      child: TabBar(
                        controller: _tabController,
                        labelColor: AppColors.primaryDark,
                        unselectedLabelColor: AppColors.textHint,
                        indicator: BoxDecoration(
                          color: AppColors.lightGreen,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                        tabs: const [
                          Tab(text: 'Overview'),
                          Tab(text: 'Amenities'),
                          Tab(text: 'Availability'),
                        ],
                      ),
                    ),

                    // Tab Content
                    SizedBox(
                      height: 520,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildOverviewTab(room),
                          _buildAmenitiesTab(),
                          _buildAvailabilityTab(days),
                        ],
                      ),
                    ),

                    // Bottom padding for sticky button
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),

          // Sticky Book Now Button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              decoration: BoxDecoration(
                color: AppColors.pureWhite,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, -5)),
                ],
              ),
              child: Row(
                children: [
                  if (_startDate != null) ...[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${DateFormat('MMM d').format(_startDate!)} → ${_endDate != null ? DateFormat('MMM d').format(_endDate!) : '?'}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark, fontSize: 14),
                          ),
                          Text(
                            'Rs.${(room.pricePerNight * days).toStringAsFixed(0)} total · $days night${days > 1 ? 's' : ''}',
                            style: const TextStyle(color: AppColors.textHint, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    flex: _startDate != null ? 1 : 2,
                    child: GestureDetector(
                      onTap: _proceedToBook,
                      child: Container(
                        height: 54,
                        decoration: BoxDecoration(
                          gradient: _rangeHasConflict()
                              ? LinearGradient(colors: [Colors.grey.shade400, Colors.grey.shade500])
                              : const LinearGradient(
                                  colors: [AppColors.primaryDark, AppColors.primaryGreen],
                                ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryDark.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            _rangeHasConflict()
                                ? 'Dates Unavailable'
                                : (_startDate == null ? 'Select Dates Below' : 'Book Now →'),
                            style: const TextStyle(
                              color: AppColors.pureWhite,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.lightGreen,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primaryGreen),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryDark)),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(RoomModel room) {
    final desc = room.config.isNotEmpty
        ? 'This ${room.category} room in ${room.city} offers a comfortable stay with ${room.beds} bed(s) in a ${room.config} configuration. Perfect for travelers seeking quality accommodation in the breathtaking northern areas of Pakistan.'
        : 'Experience the beauty of ${room.city} from this stunning ${room.category.toLowerCase()} room. Wake up to majestic mountain views and enjoy premium hospitality.';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text('About this property', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
          const SizedBox(height: 10),
          Text(desc, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.7)),
          const SizedBox(height: 20),
          const Text('Room Highlights', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
          const SizedBox(height: 12),
          _buildHighlightRow(Icons.check_circle_outline_rounded, 'Free cancellation 3+ days before check-in'),
          _buildHighlightRow(Icons.check_circle_outline_rounded, 'Instant booking confirmation'),
          _buildHighlightRow(Icons.check_circle_outline_rounded, 'No hidden charges'),
          _buildHighlightRow(Icons.check_circle_outline_rounded, 'Clean & sanitized rooms'),
        ],
      ),
    );
  }

  Widget _buildHighlightRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryGreen, size: 18),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildAmenitiesTab() {
    final amenities = _getAmenities();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.1,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: amenities.length,
        itemBuilder: (context, i) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.lightGreen,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(amenities[i]['icon'] as IconData, color: AppColors.primaryGreen, size: 22),
                ),
                const SizedBox(height: 8),
                Text(
                  amenities[i]['label'] as String,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primaryDark),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvailabilityTab(int days) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(AppColors.errorRed, 'Booked'),
              const SizedBox(width: 20),
              _buildLegendItem(AppColors.primaryGreen, 'Selected'),
              const SizedBox(width: 20),
              _buildLegendItem(AppColors.lightGreen, 'Available'),
            ],
          ),
          const SizedBox(height: 8),
          if (_loadingDates)
            const Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            )
          else
            TableCalendar(
              firstDay: DateTime.now(),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _focusedDay,
              rangeStartDay: _startDate,
              rangeEndDay: _endDate,
              rangeSelectionMode: _rangeSelectionMode,
              onRangeSelected: _onRangeSelected,
              onPageChanged: (d) => setState(() => _focusedDay = d),
              calendarStyle: CalendarStyle(
                rangeHighlightColor: AppColors.lightGreen,
                rangeStartDecoration: const BoxDecoration(
                  color: AppColors.primaryDark,
                  shape: BoxShape.circle,
                ),
                rangeEndDecoration: const BoxDecoration(
                  color: AppColors.primaryGreen,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: AppColors.accentSand.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                outsideDaysVisible: false,
                weekendTextStyle: const TextStyle(color: AppColors.primaryDark),
              ),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  if (_isDayBooked(day)) {
                    return Container(
                      margin: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.errorRed,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${day.day}',
                          style: const TextStyle(color: AppColors.pureWhite, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  }
                  return null;
                },
                disabledBuilder: (context, day, focusedDay) {
                  if (_isDayBooked(day)) {
                    return Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.errorRed.withOpacity(0.7),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${day.day}',
                          style: const TextStyle(color: AppColors.pureWhite, fontSize: 13),
                        ),
                      ),
                    );
                  }
                  return null;
                },
              ),
              enabledDayPredicate: (day) => !_isDayBooked(day),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primaryDark),
              ),
            ),
          if (_startDate != null && _endDate != null)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.lightGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${DateFormat('MMM d').format(_startDate!)} → ${DateFormat('MMM d, yyyy').format(_endDate!)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                  ),
                  Text(
                    '$days night${days > 1 ? 's' : ''}',
                    style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
