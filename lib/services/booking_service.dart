import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/booking.dart';

class BookingService extends ChangeNotifier {
  static final BookingService _instance = BookingService._internal();
  factory BookingService() => _instance;
  BookingService._internal() {
    _loadBookingsFromFile();
  }

  final List<Booking> _bookings = [];

  List<Booking> get bookings => List.unmodifiable(_bookings);

  List<Booking> get upcomingBookings =>
      _bookings.where((booking) => booking.isUpcoming).toList();

  List<Booking> get todaysBookings =>
      _bookings.where((booking) => booking.isToday && booking.status == 'upcoming').toList();

  // In-memory storage only (no SharedPreferences) to avoid native plugin resolution issues

  /// Adds a booking if not already present for same eventId and chosenDateTime.
  /// Returns true if added, false if duplicate.
  Future<bool> addBooking(Booking booking) async {
    final exists = _bookings.any((b) => b.eventId == booking.eventId && b.chosenDateTime == booking.chosenDateTime && b.status != 'cancelled');
    if (exists) {
      if (kDebugMode) print('BookingService: duplicate booking prevented for eventId: ${booking.eventId}, chosenDateTime: ${booking.chosenDateTime}');
      return false;
    }
    _bookings.add(booking);
    if (kDebugMode) {
      print('DEBUG: Booking added - ${booking.eventTitle}');
      print('DEBUG: Total bookings count: ${_bookings.length}');
    }
    notifyListeners();
    _scheduleReminder(booking);
    await _saveBookingsToFile();
    return true;
  }

  void updateBookingStatus(String bookingId, String status) {
    final index = _bookings.indexWhere((booking) => booking.id == bookingId);
    if (index != -1) {
      final oldBooking = _bookings[index];
      _bookings[index] = Booking(
        id: oldBooking.id,
        eventId: oldBooking.eventId,
        eventTitle: oldBooking.eventTitle,
        eventLocation: oldBooking.eventLocation,
        chosenDateTime: oldBooking.chosenDateTime,
        amount: oldBooking.amount,
        paymentMethod: oldBooking.paymentMethod,
        bookedAt: oldBooking.bookedAt,
        status: status,
      );
      notifyListeners();
    }
  }

  void removeBooking(String bookingId) {
    _bookings.removeWhere((booking) => booking.id == bookingId);
    notifyListeners();
  }

  Booking? getBookingById(String id) {
    try {
      return _bookings.firstWhere((booking) => booking.id == id);
    } catch (e) {
      return null;
    }
  }

  bool isEventAlreadyBooked(String eventId, DateTime chosenDateTime) {
    return _bookings.any((booking) => booking.eventId == eventId && booking.chosenDateTime == chosenDateTime && booking.status != 'cancelled');
  }

  Booking? getBookingForEvent(String eventId, DateTime chosenDateTime) {
    try {
      return _bookings.firstWhere((booking) => booking.eventId == eventId && booking.chosenDateTime == chosenDateTime && booking.status != 'cancelled');
    } catch (e) {
      return null;
    }
  }

  void _scheduleReminder(Booking booking) {
    // Placeholder: scheduling integration (flutter_local_notifications) can be added here.
    if (kDebugMode) {
      print('Reminder scheduled for ${booking.eventTitle} on ${booking.chosenDateTime.toIso8601String()}');
      print('Location: ${booking.eventLocation}');
    }
  }

  // Simulate getting reminders for today
  List<Map<String, String>> getTodaysReminders() {
    return todaysBookings.map((booking) => {
      'title': 'Event Today: ${booking.eventTitle}',
      'message': 'Your event at ${booking.eventLocation} starts at ${booking.chosenDateTime.hour}:${booking.chosenDateTime.minute.toString().padLeft(2, '0')}',
      'bookingId': booking.id,
    }).toList();
  }

  // Clear all bookings (for demo purposes)
  void clearAllBookings() {
    _bookings.clear();
    notifyListeners();
  }

  Future<void> _loadBookingsFromFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/bookings.json');
      if (kDebugMode) print('DEBUG: Loading bookings from file: ${file.path}');
      if (await file.exists()) {
        final contents = await file.readAsString();
        if (kDebugMode) print('DEBUG: File contents: $contents');
        final List<dynamic> jsonData = json.decode(contents);
        _bookings.clear();
        _bookings.addAll(jsonData.map((data) => Booking.fromJson(data)));
        if (kDebugMode) print('DEBUG: Loaded ${_bookings.length} bookings from file.');
      }
    } catch (e) {
      if (kDebugMode) print('ERROR: Failed to load bookings from file - $e');
    }
  }

  Future<void> _saveBookingsToFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/bookings.json');
      final contents = json.encode(_bookings.map((booking) => booking.toJson()).toList());
      if (kDebugMode) print('DEBUG: Saving bookings to file: ${file.path}');
      if (kDebugMode) print('DEBUG: File contents to save: $contents');
      await file.writeAsString(contents);
      if (kDebugMode) print('DEBUG: Saved ${_bookings.length} bookings to file.');
    } catch (e) {
      if (kDebugMode) print('ERROR: Failed to save bookings to file - $e');
    }
  }
}