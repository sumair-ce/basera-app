class PaymentModel {
  final String id;
  final String bookingId;
  final String roomId;
  final String roomTitle;
  final double amount;
  final String status;
  final String createdAt;

  PaymentModel({
    required this.id,
    required this.bookingId,
    required this.roomId,
    required this.roomTitle,
    required this.amount,
    required this.status,
    required this.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    // Handling populated bookingId -> roomId
    String rId = '';
    String rTitle = 'Unknown Room';
    
    if (json['bookingId'] is Map && json['bookingId']['roomId'] is Map) {
      rId = json['bookingId']['roomId']['_id'] ?? '';
      rTitle = json['bookingId']['roomId']['title'] ?? 'Unknown Room';
    }

    return PaymentModel(
      id: json['_id'] ?? '',
      bookingId: (json['bookingId'] is Map) ? json['bookingId']['_id'] : json['bookingId'] ?? '',
      roomId: rId,
      roomTitle: rTitle,
      amount: (json['amount'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt'] ?? '',
    );
  }
}
