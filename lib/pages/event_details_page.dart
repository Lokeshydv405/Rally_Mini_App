import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Import for kDebugMode
import 'package:rally/pages/home_page.dart';
import 'checkout_page.dart';
import '../services/booking_service.dart';
import 'my_events_page.dart';

class EventDetailsPage extends StatefulWidget {
  final String? title;
  final String? location;
  final String? date;
  final String? time;
  final String? imageUrl;
  final String? organizer;
  final String? description;
  final double? rating;
  final double? price;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<EventSlot>? slots;

  const EventDetailsPage({
    Key? key,
    this.title,
    this.location,
    this.date,
    this.time,
    this.imageUrl,
    this.organizer,
    this.description,
    this.rating,
    this.price,
    this.startDate,
    this.endDate,
    this.slots,
  }) : super(key: key);

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isDescriptionExpanded = false;
  final BookingService _bookingService = BookingService();

  late DateTime _startDate = DateTime.now();
  late DateTime _endDate = DateTime.now().add(const Duration(days: 7));
  late Map<DateTime, List<DateTime>> _timeSlotsByDate;

  DateTime? _selectedDate;
  DateTime? _selectedTime;

  final List<String> participantImages = [
    'https://i.pravatar.cc/150?img=1',
    'https://i.pravatar.cc/150?img=5',
    'https://i.pravatar.cc/150?img=9',
    'https://i.pravatar.cc/150?img=10',
    'https://i.pravatar.cc/150?img=12',
    'https://i.pravatar.cc/150?img=13',
    'https://i.pravatar.cc/150?img=14',
    'https://i.pravatar.cc/150?img=15',
    'https://i.pravatar.cc/150?img=16',
    'https://i.pravatar.cc/150?img=17',
  ];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    _startDate = widget.startDate ?? _startDate;
    _endDate = widget.endDate ?? _endDate;

    // Replace dynamic time slots with dummy time slots
    _timeSlotsByDate = {
      for (var date = _startDate;
          !date.isAfter(_endDate);
          date = date.add(const Duration(days: 1)))
        DateTime(date.year, date.month, date.day): [
          DateTime(date.year, date.month, date.day, 18, 0), // 6:00 PM
          DateTime(date.year, date.month, date.day, 19, 0), // 7:00 PM
          DateTime(date.year, date.month, date.day, 20, 0), // 8:00 PM
        ]
    };

    _bookingService.addListener(_onBookingChanged);
  }

  void _onBookingChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _bookingService.removeListener(_onBookingChanged);
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildActionButton() {
    final eventId =
        (widget.title ?? 'Weekend Tennis Rally').replaceAll(RegExp(r'[^A-Za-z0-9]'), '_');
    final chosenDateTime = _selectedTime ?? DateTime.now();
    final isBooked = _bookingService.isEventAlreadyBooked(eventId, chosenDateTime);
    if (kDebugMode) {
      print('DEBUG: Checking if event is booked - eventId: $eventId, chosenDateTime: $chosenDateTime, isBooked: $isBooked');
    }

    if (isBooked) {
      return Column(
        children: [
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.green, width: 2),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Already Booked',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF007BFF), Color(0xFF0056CC)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const MyEventsPage()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              child: const Text(
                'View My Events',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ),
        ],
      );
    }

    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFC7F464), Color(0xFFB8E356)]),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFC7F464).withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _selectedTime == null
            ? null
            : () {
                final eventId = (widget.title ?? 'Event').replaceAll(RegExp(r'[^A-Za-z0-9]'), '_');
                final chosenDateTime = _selectedTime!;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CheckoutPage(
                      eventTitle: widget.title ?? 'Event',
                      eventLocation: widget.location ?? 'Unknown Location',
                      eventImage: widget.imageUrl ?? '',
                      eventPrice: widget.price ?? 0.0,
                      chosenDateTime: chosenDateTime,
                      eventId: eventId,
                    ),
                  ),
                );
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        ),
        child: const Text(
          'Join Event',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      )
      );
    }

  Widget _buildDateAndTimeSelectors() {
    return Row(
      children: [
        Expanded(
          child: DropdownButton<DateTime>(
            value: _selectedDate,
            hint: const Text('Select a date'),
            items: _timeSlotsByDate.keys
                .map((date) => DateTime(date.year, date.month, date.day)) // normalize
                .toSet() // remove duplicates
                .toList()
                .map((date) {
              return DropdownMenuItem<DateTime>(
                value: date,
                child: Text('${date.day}/${date.month}/${date.year}'),
              );
            }).toList(),

            onChanged: (date) {
              setState(() {
                _selectedDate = date;
                _selectedTime = null; // Reset time when date changes
              });
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButton<DateTime>(
            value: _selectedTime,
            hint: const Text('Select a time slot'),
            items: _selectedDate != null
                ? _timeSlotsByDate[_selectedDate!]!
                    .map((time) => DateTime(
                        time.year, time.month, time.day, time.hour, time.minute)) // normalize
                    .toSet() // remove duplicates
                    .toList()
                    .map((time) => DropdownMenuItem<DateTime>(
                          value: time,
                          child: Text('${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}'),
                        ))
                    .toList()
                : [],
            onChanged: (time) {
              setState(() {
                _selectedTime = time;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildExistingBookingInfo() {
    final eventId = (widget.title ?? 'Event').replaceAll(RegExp(r'[^A-Za-z0-9]'), '_');
    final existingBooking = _bookingService.getBookingForEvent(eventId, _selectedTime ?? DateTime.now());

    if (existingBooking != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You have already booked this event.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Date: ${existingBooking.chosenDateTime.day}/${existingBooking.chosenDateTime.month}/${existingBooking.chosenDateTime.year}',
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            Text(
              'Time: ${existingBooking.chosenDateTime.hour.toString().padLeft(2, '0')}:${existingBooking.chosenDateTime.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    if (_timeSlotsByDate.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: const Color(0xFF007BFF),
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.3),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.black.withOpacity(0.3),
                  child: IconButton(
                    icon: const Icon(Icons.share, color: Colors.white),
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.black.withOpacity(0.3),
                  child: IconButton(
                    icon: const Icon(Icons.favorite_border, color: Colors.white),
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    widget.imageUrl ??
                        'https://images.unsplash.com/photo-1622279457486-62dcc4a431d6?w=800',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.sports_tennis, size: 80, color: Colors.grey),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                        stops: const [0.6, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.title ?? 'Weekend Tennis Rally',
                          style: const TextStyle(
                              fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87, height: 1.2)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 20,
                            backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=33'),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Organizer: ${widget.organizer ?? 'Coach Alex'}',
                                  style: const TextStyle(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: List.generate(
                              (widget.rating ?? 4.5).floor(),
                              (index) => const Icon(Icons.star, color: Color(0xFFFFC107), size: 18),
                            )
                              ..add(((widget.rating ?? 4.5) % 1) > 0
                                  ? const Icon(Icons.star_half, color: Color(0xFFFFC107), size: 18)
                                  : const SizedBox()),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _InfoRow(
                        icon: Icons.calendar_today,
                        label: '${_startDate.day}/${_startDate.month}/${_startDate.year} - ${_endDate.day}/${_endDate.month}/${_endDate.year}',
                        
                      ),
                      const SizedBox(height: 16),
                      _InfoRow(icon: Icons.location_on, label: widget.location ?? 'City Park Tennis Courts', value: null),
                      const SizedBox(height: 28),
                      _buildExistingBookingInfo(),
                      const SizedBox(height: 16),
                      Padding(padding: const EdgeInsets.only(bottom: 12), child: _buildDateAndTimeSelectors()),
                      // _buildEventDateRange(),
                      _buildActionButton(),
                      const SizedBox(height: 28),
                      _ExpandableSection(
                        isExpanded: _isDescriptionExpanded,
                        onToggle: () => setState(() => _isDescriptionExpanded = !_isDescriptionExpanded),
                        title: 'About Event',
                        content: widget.description ??
                            'This event is for tennis enthusiasts looking to improve their game while meeting new people. We\'ll have doubles matches, coaching tips, and plenty of opportunities to practice your skills. All skill levels welcome!',
                      ),
                      const SizedBox(height: 24),
                      const Text('Participants: 18 joined (2 spots left!)',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                      const SizedBox(height: 16),
                      // Fix ListView.builder
                      SizedBox(
                        height: 60,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: participantImages.length,
                          itemBuilder: (context, index) => Container(
                            margin: const EdgeInsets.only(right: 8),
                            child: CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.grey[200],
                              backgroundImage: NetworkImage(participantImages[index]),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text('Event Tags',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: const [
                          _TagChip(label: 'Tennis', color: Color(0xFFFF8C42)),
                          _TagChip(label: 'Open for All', color: Colors.grey, textColor: Colors.black87),
                          _TagChip(label: 'Weekend', color: Colors.grey, textColor: Colors.black87),
                          _TagChip(label: 'Intermediate Level', color: Color(0xFF7B68EE)),
                        ],
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;

  const _InfoRow({required this.icon, required this.label, this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, size: 24, color: Colors.black87),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500)),
              if (value != null)
                Text(value!,
                    style: const TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}

class _ExpandableSection extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onToggle;
  final String title;
  final String content;

  const _ExpandableSection(
      {required this.isExpanded, required this.onToggle, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onToggle,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
              Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.black87),
            ],
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(content, style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.6)),
          ),
          crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;

  const _TagChip({required this.label, required this.color, this.textColor = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textColor)),
    );
  }
}
