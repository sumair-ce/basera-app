import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/room_model.dart';

class RoomService {
  static const String baseUrl = 'http://10.0.2.2:3000/api/rooms';

  Future<List<RoomModel>> fetchRooms({
    String? search,
    String? city,
    String? category,
    String? startDate,
    String? endDate,
    int? beds,
    String? sort,
  }) async {
    try {
      Map<String, String> queryParams = {};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (city != null && city != 'All') queryParams['city'] = city;
      if (category != null && category != 'All')
        queryParams['category'] = category;
      if (startDate != null && startDate.isNotEmpty)
        queryParams['startDate'] = startDate;
      if (endDate != null && endDate.isNotEmpty)
        queryParams['endDate'] = endDate;
      if (beds != null && beds > 0) queryParams['beds'] = beds.toString();
      if (sort != null && sort.isNotEmpty) queryParams['sort'] = sort;

      final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => RoomModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load rooms');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
