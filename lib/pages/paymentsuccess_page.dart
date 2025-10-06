import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import '../services/booking_service.dart';
import '../models/booking.dart';
import 'my_events_page.dart';

// Add to pubspec.yaml:
// dependencies:
//   confetti: ^0.7.0

class PaymentSuccessPage extends StatefulWidget {
  final String eventTitle;
  final String eventDate;
  final String eventTime;
  final double amount;
  final String eventLocation;
  final String paymentMethod;
  final DateTime? chosenDateTime;
  final String? eventId;

  const PaymentSuccessPage({
    Key? key,
    this.eventTitle = 'Event Registration',
    this.eventDate = 'TBD',
    this.eventTime = 'TBD',
    this.amount = 0,
    this.eventLocation = 'TBD',
    this.paymentMethod = 'Card',
    this.chosenDateTime,
    this.eventId,
  }) : super(key: key);

  @override
  State<PaymentSuccessPage> createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  final List<Balloon> _balloons = [];

  @override
  void initState() {
    super.initState();

    // Add booking to service
    _addBooking();

    // Confetti controller
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 5),
    );

    // Scale animation for success icon
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Fade animation for content
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    // Generate random balloons
    _generateBalloons();

    // Start animations
    _confettiController.play();
    _scaleController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _fadeController.forward();
    });
  }

  void _generateBalloons() {
    final random = Random();
    for (int i = 0; i < 6; i++) {
      _balloons.add(
        Balloon(
          left: random.nextDouble() * 0.8 + 0.1,
          delay: random.nextDouble() * 2,
          color: i % 2 == 0 ? const Color(0xFF007BFF) : const Color(0xFFC7F464),
        ),
      );
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _scaleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _addBooking() {
    final DateTime chosen = widget.chosenDateTime ?? DateTime.now();
    final eventId = widget.eventId ?? widget.eventTitle.replaceAll(RegExp(r'[^A-Za-z0-9]'), '_');

    final booking = Booking(
      id: 'BK${DateTime.now().millisecondsSinceEpoch}',
      eventId: eventId,
      eventTitle: widget.eventTitle,
      eventLocation: widget.eventLocation,
  chosenDateTime: chosen,
      amount: widget.amount,
      paymentMethod: widget.paymentMethod,
      bookedAt: DateTime.now(),
      status: 'upcoming',
    );

    BookingService().addBooking(booking).then((added) {
      if (!added) {
        if (kDebugMode) print('PaymentSuccessPage: booking was duplicate, not added');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You already have a booking for this event at the selected time.')));
      }
    });
  }

  Path _drawStar(Size size) {
    double degToRad(double deg) => deg * (pi / 180.0);

    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width / 2, 0);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(
        halfWidth + externalRadius * cos(step),
        halfWidth + externalRadius * sin(step),
      );
      path.lineTo(
        halfWidth + internalRadius * cos(step + halfDegreesPerStep),
        halfWidth + internalRadius * sin(step + halfDegreesPerStep),
      );
    }
    path.close();
    return path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey[50]!,
              Colors.white,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Confetti
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  Color(0xFF007BFF),
                  Color(0xFFC7F464),
                  Color(0xFFFFC107),
                  Color(0xFF4CAF50),
                ],
                createParticlePath: _drawStar,
                numberOfParticles: 30,
                gravity: 0.3,
                emissionFrequency: 0.05,
              ),
            ),

            // Floating balloons
            ..._balloons.map((balloon) => _FloatingBalloon(balloon: balloon)),

            // Main content
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),

                        // Success Icon with decorative balloons
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Decorative balloon - left
                            Positioned(
                              left: -40,
                              top: 0,
                              child: _DecorativeBalloon(
                                color: const Color(0xFF007BFF),
                                delay: 0.5,
                              ),
                            ),
                            // Decorative balloon - right
                            Positioned(
                              right: -40,
                              top: 20,
                              child: _DecorativeBalloon(
                                color: const Color(0xFFC7F464),
                                delay: 1.0,
                              ),
                            ),
                            // Success icon
                            ScaleTransition(
                              scale: _scaleAnimation,
                              child: Container(
                                width: 160,
                                height: 160,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFC7F464)
                                          .withOpacity(0.3),
                                      blurRadius: 30,
                                      spreadRadius: 10,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.check,
                                  size: 100,
                                  color: Color(0xFF7CB342),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),

                        // Success Message
                        const Text(
                          'Payment',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF007BFF),
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const Text(
                          'Successful!',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF007BFF),
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),

                        // Event Details Card
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.eventTitle,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '${widget.eventDate} • ${widget.eventTime}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Divider(color: Colors.grey[300]),
                              const SizedBox(height: 16),
                              Text(
                                'Amount Paid: ₹${widget.amount.toInt()}',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Buttons
                        Row(
                          children: [
                            // View My Events Button
                            Expanded(
                              child: Container(
                                height: 60,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF007BFF),
                                      Color(0xFF0056CC),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF007BFF).withOpacity(0.5),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const MyEventsPage(),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: const Text(
                                    'My Events',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Back to Home Button
                            Expanded(
                              child: Container(
                                height: 60,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFC7F464),
                                      Color(0xFFB8E356),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFC7F464).withOpacity(0.5),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    // Pop all routes back to home
                                    Navigator.of(context).popUntil(
                                      (route) => route.isFirst,
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: const Text(
                                    'Back to Home',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
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
      ),
    );
  }
}

// Balloon data model
class Balloon {
  final double left;
  final double delay;
  final Color color;

  Balloon({
    required this.left,
    required this.delay,
    required this.color,
  });
}

// Floating balloon widget
class _FloatingBalloon extends StatefulWidget {
  final Balloon balloon;

  const _FloatingBalloon({required this.balloon});

  @override
  State<_FloatingBalloon> createState() => _FloatingBalloonState();
}

class _FloatingBalloonState extends State<_FloatingBalloon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 4 + Random().nextInt(3)),
    );

    _animation = Tween<double>(
      begin: 1.2,
      end: -0.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));

    Future.delayed(
      Duration(milliseconds: (widget.balloon.delay * 1000).toInt()),
      () {
        if (mounted) {
          _controller.repeat();
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Positioned(
          left: MediaQuery.of(context).size.width * widget.balloon.left,
          top: MediaQuery.of(context).size.height * _animation.value,
          child: Opacity(
            opacity: 0.6,
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 50,
                  decoration: BoxDecoration(
                    color: widget.balloon.color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                Container(
                  width: 2,
                  height: 30,
                  color: widget.balloon.color.withOpacity(0.5),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Decorative balloon near success icon
class _DecorativeBalloon extends StatefulWidget {
  final Color color;
  final double delay;

  const _DecorativeBalloon({
    required this.color,
    required this.delay,
  });

  @override
  State<_DecorativeBalloon> createState() => _DecorativeBalloonState();
}

class _DecorativeBalloonState extends State<_DecorativeBalloon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _animation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    Future.delayed(
      Duration(milliseconds: (widget.delay * 1000).toInt()),
      () {
        if (mounted) {
          _controller.repeat(reverse: true);
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: Opacity(
            opacity: 0.7,
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 40,
                  decoration: BoxDecoration(
                    color: widget.color,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                Container(
                  width: 1.5,
                  height: 24,
                  color: widget.color.withOpacity(0.5),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}