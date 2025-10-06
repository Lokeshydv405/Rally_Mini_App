import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../services/booking_service.dart';

class MyEventsPage extends StatefulWidget {
  const MyEventsPage({Key? key}) : super(key: key);

  @override
  State<MyEventsPage> createState() => _MyEventsPageState();
}

class _MyEventsPageState extends State<MyEventsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final BookingService _bookingService = BookingService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD), // Updated to match home page background
      appBar: AppBar(
        title: const Text('My Events'),
        backgroundColor: Colors.white, // Updated to match home page app bar
        foregroundColor: const Color(0xFF1A1D2E), // Updated to match home page text color
        elevation: 0,
      ),
      body: AnimatedBuilder(
        animation: _bookingService,
        builder: (context, _) {
          final todaysBookings = _bookingService.todaysBookings;
          final upcomingBookings = _bookingService.upcomingBookings;

          if (todaysBookings.isEmpty && upcomingBookings.isEmpty) {
            return _buildEmptyState(
              icon: Icons.event,
              title: 'No Events Found',
              message: 'You haven\'t booked any events yet.\nExplore events and join the fun!',
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (todaysBookings.isNotEmpty) ...[
                const Text(
                  'Today\'s Events',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1D2E), // Updated to match home page text color
                  ),
                ),
                const SizedBox(height: 8),
                ...todaysBookings.map((booking) => _buildEventCard(booking, true)),
                const SizedBox(height: 16),
              ],
              if (upcomingBookings.isNotEmpty) ...[
                const Text(
                  'Upcoming Events',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1D2E), // Updated to match home page text color
                  ),
                ),
                const SizedBox(height: 8),
                ...upcomingBookings.map((booking) => _buildEventCard(booking, false)),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1D2E), // Updated to match home page text color
            ),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF007BFF), // Updated to match home page button color
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text('Explore Events'),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(Booking booking, bool isToday) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: isToday ? Border.all(color: const Color(0xFFC7F464), width: 2) : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    booking.eventTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                if (isToday)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC7F464),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'TODAY',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.location_on, booking.eventLocation),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.calendar_today,
              '${booking.chosenDateTime.day}/${booking.chosenDateTime.month}/${booking.chosenDateTime.year}',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.access_time,
              '${booking.chosenDateTime.hour.toString().padLeft(2, '0')}:${booking.chosenDateTime.minute.toString().padLeft(2, '0')}',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.payment, '₹${booking.amount.toInt()} via ${booking.paymentMethod}'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showReminderDialog(booking),
                    icon: const Icon(Icons.notification_add, size: 18),
                    label: const Text('Set Reminder'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF007BFF),
                      side: const BorderSide(color: Color(0xFF007BFF)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _viewEventDetails(booking),
                    icon: const Icon(Icons.info, size: 18),
                    label: const Text('Details',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007BFF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }

  void _showReminderDialog(Booking booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Reminder'),
        content: Text(
          'Reminder set for "${booking.eventTitle}" on '
          '${booking.chosenDateTime.day}/${booking.chosenDateTime.month}/${booking.chosenDateTime.year} '
          'at ${booking.chosenDateTime.hour.toString().padLeft(2, '0')}:${booking.chosenDateTime.minute.toString().padLeft(2, '0')}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _viewEventDetails(Booking booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildEventDetailsSheet(booking),
    );
  }

  Widget _buildEventDetailsSheet(Booking booking) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            height: 4,
            width: 40,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.eventTitle,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow('Location', booking.eventLocation, Icons.location_on),
                  _buildDetailRow('Date', '${booking.chosenDateTime.day}/${booking.chosenDateTime.month}/${booking.chosenDateTime.year}', Icons.calendar_today),
                  _buildDetailRow('Time', '${booking.chosenDateTime.hour.toString().padLeft(2, '0')}:${booking.chosenDateTime.minute.toString().padLeft(2, '0')}', Icons.access_time),
                  _buildDetailRow('Amount Paid', '₹${booking.amount.toInt()}', Icons.payment),
                  _buildDetailRow('Payment Method', booking.paymentMethod, Icons.credit_card),
                  _buildDetailRow('Booking ID', booking.id, Icons.confirmation_number),
                  _buildDetailRow('Booked On', _formatDateTime(booking.bookedAt), Icons.schedule),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007BFF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Close'),
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

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF007BFF)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}