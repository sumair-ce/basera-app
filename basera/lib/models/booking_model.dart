class BookingModel {
  final String id;
  final String userId;
  final String roomId;
  final String roomTitle;
  final String startDate;
  final String endDate;
  final String status;
  final double totalPrice;
  final String paymentStatus;

  BookingModel({
    required this.id,
    required this.userId,
    required this.roomId,
    this.roomTitle = '',
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.totalPrice,
    required this.paymentStatus,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    final roomData = json['roomId'];
    String rId = '';
    String rTitle = '';
    if (roomData is Map) {
      rId = roomData['_id'] ?? '';
      rTitle = roomData['title'] ?? '';
    } else if (roomData is String) {
      rId = roomData;
    }

    return BookingModel(
      id: json['_id'] ?? '',
      userId: (json['userId'] is Map) ? json['userId']['_id'] : json['userId'] ?? '',
      roomId: rId,
      roomTitle: rTitle,
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      status: json['status'] ?? 'pending',
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      paymentStatus: json['paymentStatus'] ?? 'pending',
    );
  }
}
