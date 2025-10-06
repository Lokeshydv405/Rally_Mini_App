class Booking {
  final String id;
  final String eventId;
  final String eventTitle;
  final String eventLocation;
  final DateTime chosenDateTime; // precise chosen date/time for the event
  final double amount;
  final String paymentMethod;
  final DateTime bookedAt;
  final String status; // 'upcoming', 'completed', 'cancelled'

  Booking({
    required this.id,
    required this.eventId,
    required this.eventTitle,
    required this.eventLocation,
    required this.chosenDateTime,
    required this.amount,
    required this.paymentMethod,
    DateTime? bookedAt,
    this.status = 'upcoming',
  }) : bookedAt = bookedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'eventId': eventId,
    'eventTitle': eventTitle,
    'eventLocation': eventLocation,
    'chosenDateTime': chosenDateTime.toIso8601String(),
    'amount': amount,
    'paymentMethod': paymentMethod,
    'bookedAt': bookedAt.toIso8601String(),
    'status': status,
  };

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
    id: json['id'] as String,
    eventId: json['eventId'] as String,
    eventTitle: json['eventTitle'] as String,
    eventLocation: json['eventLocation'] as String,
    chosenDateTime: DateTime.parse(json['chosenDateTime'] as String),
    amount: (json['amount'] as num).toDouble(),
    paymentMethod: json['paymentMethod'] as String,
    bookedAt: DateTime.parse(json['bookedAt'] as String),
    status: json['status'] ?? 'upcoming',
  );

  // Helper method to check if event is today
  bool get isToday {
    final now = DateTime.now();
    return chosenDateTime.year == now.year &&
           chosenDateTime.month == now.month &&
           chosenDateTime.day == now.day;
  }

  // Helper method to check if event is upcoming
  bool get isUpcoming {
    return status == 'upcoming' && chosenDateTime.isAfter(DateTime.now());
  }
}