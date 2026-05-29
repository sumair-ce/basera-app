class RoomModel {
  final String id;
  final String title;
  final String city;
  final String category;
  final String config;
  final int beds;
  final double pricePerNight;
  final String imageUrl;
  final bool isAvailable;
  final bool isAvailableForDates;
  final List<dynamic>? conflicts;
  final double rating;
  final int reviews;

  RoomModel({
    required this.id,
    required this.title,
    required this.city,
    required this.category,
    required this.config,
    required this.beds,
    required this.pricePerNight,
    required this.imageUrl,
    required this.isAvailable,
    this.isAvailableForDates = true,
    this.conflicts,
    this.rating = 0.0,
    this.reviews = 0,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['_id'],
      title: json['title'] ?? '',
      city: json['city'] ?? '',
      category: json['category'] ?? 'Standard',
      config: json['config'] ?? '1-bed',
      beds: json['beds'] ?? 1,
      pricePerNight: (json['pricePerNight'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      isAvailable: json['isAvailable'] ?? true,
      isAvailableForDates: json['isAvailableForDates'] ?? true,
      conflicts: json['conflicts'],
      // Fallbacks in case your current API doesn't return these yet
      rating: (json['rating'] ?? 4.5).toDouble(),
      reviews: json['reviews'] ?? 128,
    );
  }
}
