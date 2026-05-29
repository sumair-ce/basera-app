import 'package:flutter/material.dart';
import '../services/room_service.dart';
import '../models/room_model.dart';

class DashboardViewModel extends ChangeNotifier {
  final RoomService _roomService = RoomService();

  List<RoomModel> _rooms = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Filters State
  String _searchQuery = '';
  String _selectedCity = 'All';
  String _selectedCategory = 'All';
  int _selectedBeds = 0; // 0 means 'All'
  String _sortOrder = 'Default'; // Default, Low to High, High to Low

  String? _startDate;
  String? _endDate;

  // Getters
  List<RoomModel> get rooms => _rooms;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedCity => _selectedCity;
  String get selectedCategory => _selectedCategory;
  int get selectedBeds => _selectedBeds;
  String get sortOrder => _sortOrder;
  String? get startDate => _startDate;
  String? get endDate => _endDate;

  DashboardViewModel() {
    loadRooms();
  }

  Future<void> loadRooms() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      List<RoomModel> fetchedRooms = await _roomService.fetchRooms(
        search: _searchQuery,
        city: _selectedCity,
        category: _selectedCategory,
        startDate: _startDate,
        endDate: _endDate,
        beds: _selectedBeds > 0 ? _selectedBeds : null,
        sort: _sortOrder,
      );

      // Local filtering and sorting as a fallback/enhancement
      if (_selectedBeds > 0) {
        fetchedRooms = fetchedRooms
            .where((r) => r.beds == _selectedBeds)
            .toList();
      }

      if (_sortOrder == 'Low to High') {
        fetchedRooms.sort((a, b) => a.pricePerNight.compareTo(b.pricePerNight));
      } else if (_sortOrder == 'High to Low') {
        fetchedRooms.sort((a, b) => b.pricePerNight.compareTo(a.pricePerNight));
      }

      _rooms = fetchedRooms;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateDates(String start, String end) {
    _startDate = start;
    _endDate = end;
    loadRooms();
  }

  void updateSearch(String query) {
    _searchQuery = query;
    loadRooms();
  }

  void updateCityFilter(String city) {
    _selectedCity = city;
    loadRooms();
  }

  void updateCategoryFilter(String category) {
    _selectedCategory = category;
    loadRooms();
  }

  void updateBedFilter(int beds) {
    _selectedBeds = beds;
    loadRooms();
  }

  void updateSortOrder(String sort) {
    _sortOrder = sort;
    loadRooms();
  }
}
