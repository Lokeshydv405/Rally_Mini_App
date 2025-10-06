import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'event_details_page.dart';
import 'my_events_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

/// Event model class
class Event {
  final String imageUrl;
  final String title;
  final String location;
  final DateTime startDate;
  final DateTime endDate;
  final List<Color> participants;
  final int othersCount;
  final List<String> sports;
  final String organizer;
  final String description;
  final double rating;
  final double basePrice;
  final List<EventSlot> slots;
  final String time; // Added time property to Event schema

  Event({
    required this.imageUrl,
    required this.title,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.participants,
    required this.othersCount,
    required this.sports,
    required this.organizer,
    required this.description,
    this.rating = 4.5,
    this.basePrice = 199,
    required this.slots,
    required this.time, // Added time to constructor
  });
}

/// EventSlot model for date-specific slots
class EventSlot {
  final DateTime date;
  final List<TimeSlot> timeSlots;

  EventSlot({required this.date, required this.timeSlots});
}

/// TimeSlot model for a given date
class TimeSlot {
  final String time;
  final double price;
  final int availableSeats;

  TimeSlot({
    required this.time,
    required this.price,
    required this.availableSeats,
  });
}

/// Generates slots between startDate and endDate with given time slots
List<EventSlot> _generateSlots(
  DateTime startDate,
  DateTime endDate,
  double basePrice,
) {
  List<EventSlot> generatedSlots = [];
  DateTime currentDate = startDate;

  // Define dummy time slots
  List<String> dummyTimeSlots = ['6:00 PM', '7:00 PM', '8:00 PM'];

  while (!currentDate.isAfter(endDate)) {
    List<TimeSlot> dailySlots = dummyTimeSlots.map((time) {
      return TimeSlot(
        time: time,
        price: basePrice,
        availableSeats: 10,
      );
    }).toList();

    generatedSlots.add(EventSlot(date: currentDate, timeSlots: dailySlots));
    currentDate = currentDate.add(const Duration(days: 1));
  }

  return generatedSlots;
}

class _HomePageState extends State<HomePage> {
  final List<String> selectedSports = [];
  final TextEditingController _searchController = TextEditingController();
  List<Event> _allEvents = [];
  List<Event> _filteredEvents = [];
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _initializeEvents();
    _searchController.addListener(_filterEvents);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  /// Initializes all events
/// Initializes all events
  void _initializeEvents() {
  _allEvents = [
    Event(
      imageUrl: 'https://images.unsplash.com/photo-1554068865-24cecd4e34b8?w=400', // Tennis court
      title: 'Sunset Doubles Rally',
      location: 'Central Park Courts',
      description:
          'Join us for an exciting sunset tennis doubles match! Perfect for intermediate and advanced players looking for competitive gameplay in a friendly environment.',
      startDate: DateTime(2025, 5, 21),
      endDate: DateTime(2025, 5, 25),
      participants: [Colors.blue, Colors.green],
      othersCount: 12,
      sports: ['Tennis'],
      organizer: 'City Sports Club',
      basePrice: 199,
      rating: 4.6,
      slots: _generateSlots(
        DateTime(2025, 5, 21),
        DateTime(2025, 5, 25),
        199,
      ),
      time: '6:00 PM - 7:00 PM',
    ),
    Event(
      imageUrl: 'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=400', // Basketball action
      title: 'Hoops & Beats Pickup',
      location: 'Downtown Hoops Court',
      description:
          'Street basketball with music vibes! Bring your A-game and enjoy competitive 5v5 action with great tunes and even better players.',
      startDate: DateTime(2025, 5, 21),
      endDate: DateTime(2025, 5, 23),
      participants: [Colors.orange, Colors.purple],
      othersCount: 10,
      sports: ['Basketball'],
      organizer: 'Rally Crew',
      basePrice: 249,
      rating: 4.7,
      slots: _generateSlots(
        DateTime(2025, 5, 21),
        DateTime(2025, 5, 23),
        249,
      ),
      time: '7:30 PM - 8:30 PM',
    ),
    Event(
      imageUrl: 'https://images.unsplash.com/photo-1608245449230-4ac19066d2d0?w=400', // Street basketball
      title: 'Street Ball Showdown',
      location: 'The Cage Courts',
      description:
          'Intense street basketball tournament! Show your skills in this high-energy competition. All skill levels welcome, but come ready to compete!',
      startDate: DateTime(2025, 5, 22),
      endDate: DateTime(2025, 5, 27),
      participants: [Colors.red, Colors.yellow],
      othersCount: 15,
      sports: ['Basketball'],
      organizer: 'City Slam',
      basePrice: 279,
      rating: 4.9,
      slots: _generateSlots(
        DateTime(2025, 5, 22),
        DateTime(2025, 5, 27),
        279,
      ),
      time: '5:00 PM - 6:00 PM',
    ),
    Event(
      imageUrl: 'https://images.unsplash.com/photo-1579952363873-27f3bade9f55?w=400', // Soccer match
      title: 'Weekend Warriors Match',
      location: 'Downtown Arena',
      description:
          'Competitive soccer match for weekend warriors! Join us for 90 minutes of intense football action. Great way to stay fit and meet fellow soccer enthusiasts.',
      startDate: DateTime(2025, 5, 24),
      endDate: DateTime(2025, 5, 26),
      participants: [Colors.teal, Colors.amber],
      othersCount: 20,
      sports: ['Soccer'],
      organizer: 'KickIt Club',
      basePrice: 199,
      rating: 4.8,
      slots: _generateSlots(
        DateTime(2025, 5, 24),
        DateTime(2025, 5, 26),
        199,
      ),
      time: '2:00 PM - 3:00 PM',
    ),
    Event(
      imageUrl: 'https://images.unsplash.com/photo-1519861531473-9200262188bf?w=400', // Indoor basketball
      title: 'Indoor Basketball League',
      location: 'Sports Complex Arena',
      description:
          'Competitive indoor basketball league. Play in a professional setting with referees and scorekeeping.',
      startDate: DateTime(2025, 5, 25),
      endDate: DateTime(2025, 5, 29),
      participants: [Colors.pink, Colors.blueGrey],
      othersCount: 6,
      sports: ['Basketball'],
      organizer: 'Urban Hoops',
      basePrice: 229,
      rating: 4.8,
      slots: _generateSlots(
        DateTime(2025, 5, 25),
        DateTime(2025, 5, 29),
        229,
      ),
      time: '8:00 PM - 9:00 PM',
    ),
    Event(
      imageUrl: 'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?w=400', // Badminton
      title: 'Smash Fest Badminton',
      location: 'Riverside Indoor Arena',
      description:
          'High-energy badminton matches for enthusiasts. Singles and doubles categories available for all skill levels.',
      startDate: DateTime(2025, 5, 28),
      endDate: DateTime(2025, 5, 30),
      participants: [Colors.deepPurple, Colors.orangeAccent],
      othersCount: 10,
      sports: ['Badminton'],
      organizer: 'SmashPoint',
      basePrice: 179,
      rating: 4.7,
      slots: _generateSlots(
        DateTime(2025, 5, 28),
        DateTime(2025, 5, 30),
        179,
      ),
      time: '6:30 PM - 7:30 PM',
    ),
    Event(
      imageUrl: 'https://images.unsplash.com/photo-1612872087720-bb876e2e67d1?w=400', // Beach volleyball
      title: 'Beach Volleyball Bash',
      location: 'Sunny Sands Beach',
      description:
          'Feel the sand between your toes! Join our exciting 4v4 beach volleyball matches at sunset.',
      startDate: DateTime(2025, 6, 1),
      endDate: DateTime(2025, 6, 3),
      participants: [Colors.lightBlue, Colors.orange],
      othersCount: 8,
      sports: ['Volleyball'],
      organizer: 'Beach Sports Club',
      basePrice: 149,
      rating: 4.5,
      slots: _generateSlots(
        DateTime(2025, 6, 1),
        DateTime(2025, 6, 3),
        149,
      ),
      time: '5:30 PM - 6:30 PM',
    ),
    Event(
      imageUrl: 'https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?w=400', // Cricket
      title: 'Night Cricket Tournament',
      location: 'Metro Sports Ground',
      description:
          'Exciting T10 night cricket tournament under floodlights. Open to teams of all levels.',
      startDate: DateTime(2025, 6, 4),
      endDate: DateTime(2025, 6, 8),
      participants: [Colors.green, Colors.yellow],
      othersCount: 12,
      sports: ['Cricket'],
      organizer: 'Metro Cricket Club',
      basePrice: 199,
      rating: 4.6,
      slots: _generateSlots(
        DateTime(2025, 6, 4),
        DateTime(2025, 6, 8),
        199,
      ),
      time: '7:00 PM - 9:00 PM',
    ),
  ];

  _filteredEvents = List.from(_allEvents);
}

/// Filters events based on search and selected sport tags
void _filterEvents() {
  String query = _searchController.text.toLowerCase();
  setState(() {
    _filteredEvents = _allEvents.where((event) {
        bool matchesSearch = query.isEmpty ||
            event.title.toLowerCase().contains(query) ||
            event.location.toLowerCase().contains(query) ||
            event.sports.any((sport) => sport.toLowerCase().contains(query));

        bool matchesSports = selectedSports.isEmpty ||
            event.sports.any((sport) => selectedSports.contains(sport));

        return matchesSearch && matchesSports;
      }).toList();
    });
  }

  void _toggleSportFilter(String sport) {
    setState(() {
      if (selectedSports.contains(sport)) {
        selectedSports.remove(sport);
      } else {
        selectedSports.add(sport);
      }
      _filterEvents();
    });
  }

  int _getEventCountForSport(String sport) {
    return _allEvents.where((event) => event.sports.contains(sport)).length;
  }

  void _clearAllFilters() {
    setState(() {
      selectedSports.clear();
      _searchController.clear();
      _filterEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final allSports = ['Tennis', 'Basketball', 'Soccer', 'Yoga', 'Cycling', 'Volleyball', 'Running'];
    final hasActiveFilters = selectedSports.isNotEmpty || _searchController.text.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 4,
        shadowColor: Colors.black26,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF4CAF50)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.sports_tennis, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'Rally',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyEventsPage()),
              );
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.event_note, color: Colors.white, size: 22),
            ),
            tooltip: 'My Events',
          ),
          const SizedBox(width: 8),
        ],
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Color(0xFF1A1A2E),
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      decoration: InputDecoration(
                        hintText: 'Search events, sports, or locations...',
                        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                        prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear, color: Colors.grey[600]),
                                onPressed: () {
                                  _searchController.clear();
                                  _searchFocusNode.unfocus();
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                // Sport Filter Chips
                Container(
                  height: 50,
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      ...allSports.map((sport) {
                        final isSelected = selectedSports.contains(sport);
                        final count = _getEventCountForSport(sport);
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text('$sport ($count)'),
                            selected: isSelected,
                            onSelected: (_) => _toggleSportFilter(sport),
                            backgroundColor: Colors.white.withOpacity(0.15),
                            selectedColor: const Color(0xFF6C63FF),
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black, // Adjusted tag text color for better visibility
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                            checkmarkColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected ? const Color(0xFF6C63FF) : Colors.white.withOpacity(0.3),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Clear Filters Button
          if (hasActiveFilters)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.orange[50],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_filteredEvents.length} event(s) found',
                    style: TextStyle(
                      color: Colors.orange[800],
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _clearAllFilters,
                    icon: const Icon(Icons.clear_all, size: 18),
                    label: const Text('Clear Filters'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.orange[800],
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ],
              ),
            ),

          // Events Grid
          Expanded(
            child: _filteredEvents.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No events found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your filters',
                          style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: _filteredEvents.length,
                    itemBuilder: (context, index) {
                      return _EventCard(event: _filteredEvents[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final Event event;
  const _EventCard({required this.event});

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EventDetailsPage(
                title: event.title,
                location: event.location,
                date: event.startDate.toString(),
                time: event.time,
                imageUrl: event.imageUrl,
                organizer: event.organizer,
                description: event.description,
                rating: event.rating,
                price: event.basePrice,
                startDate: event.startDate, // Pass as DateTime
                endDate: event.endDate, // Pass as DateTime
                slots: event.slots,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with overlay
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    event.imageUrl,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 120,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, size: 40, color: Colors.grey),
                      );
                    },
                  ),
                ),
                // Sport Badge
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6C63FF), Color(0xFF4CAF50)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6C63FF).withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      event.sports.first,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Price Badge
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Text(
                      '₹${event.basePrice.toInt()}',
                      style: const TextStyle(
                        color: Color(0xFF007BFF),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // Event Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    
                    // Location
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    
                    // Date
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${event.startDate.day} ${_getMonthName(event.startDate.month)}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    
                    const Spacer(),
                    
                    // Rating and Participants
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Rating
                        Row(
                          children: [
                            const Icon(Icons.star, size: 14, color: Colors.amber),
                            const SizedBox(width: 2),
                            Text(
                              event.rating.toString(),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        
                        // Participants
                        Row(
                          children: [
                            ...event.participants.take(3).map((color) => Container(
                              width: 20,
                              height: 20,
                              margin: const EdgeInsets.only(left: 2),
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                            )),
                            if (event.othersCount > 0)
                              Container(
                                width: 20,
                                height: 20,
                                margin: const EdgeInsets.only(left: 2),
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: Center(
                                  child: Text(
                                    '+${event.othersCount}',
                                    style: const TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}