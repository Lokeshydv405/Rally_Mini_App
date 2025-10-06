import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../services/booking_service.dart';
import '../models/booking.dart';

class CheckoutPage extends StatefulWidget {
  final String eventTitle;
  final String eventDate;
  final String eventTime;
  final String eventLocation;
  final String eventImage;
  final double eventPrice;
  final DateTime? chosenDateTime;
  final String? eventId;

  const CheckoutPage({
    Key? key,
    this.eventTitle = 'Weekend Hoops Pickup',
    this.eventDate = 'SAT, MAY 25',
    this.eventTime = '4:00 PM',
    this.eventLocation = 'City Park Courts',
    this.eventImage = 'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=400',
    this.eventPrice = 199,
    this.chosenDateTime,
    this.eventId,
  }) : super(key: key);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage>
    with SingleTickerProviderStateMixin {
  String _selectedPaymentMethod = 'UPI / Wallet';
  bool _isProcessing = false;

  // Ensure _shimmerController is initialized before use
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();

    // Initialize shimmer controller
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    // Dispose shimmer controller
    _shimmerController.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);

    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isProcessing = false);

    if (widget.eventId != null && widget.chosenDateTime != null) {
      final booking = Booking(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        eventId: widget.eventId!,
        eventTitle: widget.eventTitle,
        eventLocation: widget.eventLocation,
        chosenDateTime: widget.chosenDateTime!,
        amount: widget.eventPrice,
        paymentMethod: _selectedPaymentMethod,
        bookedAt: DateTime.now(),
        status: 'upcoming',
      );

      if (!kDebugMode) {
        print('DEBUG: Attempting to add booking for eventId: ${widget.eventId}, chosenDateTime: ${widget.chosenDateTime}');
      }

      final success = await BookingService().addBooking(booking);
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Duplicate booking detected'),
            backgroundColor: Colors.red[400],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
        return;
      }
    }

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => PaymentSuccessPage(
            eventTitle: widget.eventTitle,
            eventDate: widget.eventDate,
            eventTime: widget.eventTime,
            amount: widget.eventPrice,
            eventLocation: widget.eventLocation,
            paymentMethod: _selectedPaymentMethod,
            chosenDateTime: widget.chosenDateTime,
            eventId: widget.eventId,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventDate = widget.chosenDateTime != null
        ? '${widget.chosenDateTime!.day}/${widget.chosenDateTime!.month}/${widget.chosenDateTime!.year}'
        : widget.eventDate;

    final eventTime = widget.chosenDateTime != null
        ? '${widget.chosenDateTime!.hour.toString().padLeft(2, '0')}:${widget.chosenDateTime!.minute.toString().padLeft(2, '0')}'
        : widget.eventTime;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text(
          'Secure Checkout',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1D2E),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Decorative Header
            Container(
              width: double.infinity,
              height: 6,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF007BFF),
                    const Color(0xFF00C6FF),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Card
                  Hero(
                    tag: 'event_${widget.eventId}',
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF007BFF).withOpacity(0.08),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  // Event Image with gradient overlay
                                  Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: Image.network(
                                          widget.eventImage,
                                          width: 110,
                                          height: 110,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              width: 110,
                                              height: 110,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    const Color(0xFF007BFF).withOpacity(0.1),
                                                    const Color(0xFF00C6FF).withOpacity(0.1),
                                                  ],
                                                ),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: const Icon(
                                                Icons.sports_basketball,
                                                size: 48,
                                                color: Color(0xFF007BFF),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(0.6),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Text(
                                            'LIVE',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 16),
                                  // Event Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.eventTitle,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1A1D2E),
                                            letterSpacing: 0.2,
                                            height: 1.3,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 12),
                                        _InfoChip(
                                          icon: Icons.calendar_today,
                                          text: eventDate,
                                        ),
                                        const SizedBox(height: 6),
                                        _InfoChip(
                                          icon: Icons.access_time,
                                          text: eventTime,
                                        ),
                                        const SizedBox(height: 6),
                                        _InfoChip(
                                          icon: Icons.location_on,
                                          text: widget.eventLocation,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 1,
                              margin: const EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.grey[200]!,
                                    Colors.grey[100]!,
                                    Colors.grey[200]!,
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Total Amount',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '₹${widget.eventPrice.toInt()}',
                                            style: const TextStyle(
                                              fontSize: 32,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF007BFF),
                                              letterSpacing: -0.5,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 6),
                                            child: Text(
                                              '\$${(widget.eventPrice * 0.012).toStringAsFixed(2)}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[500],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFC7F464).withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFFC7F464).withOpacity(0.3),
                                      ),
                                    ),
                                    child: Row(
                                      children: const [
                                        Icon(
                                          Icons.verified_user,
                                          size: 18,
                                          color: Color(0xFF7CB342),
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          'Secure',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF7CB342),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Payment Method Section
                  const Text(
                    'Select Payment Method',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1D2E),
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Choose your preferred payment option',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // UPI / Wallet Option
                  _PaymentMethodCard(
                    icon: Icons.account_balance_wallet,
                    title: 'UPI / Wallet',
                    subtitle: 'PhonePe, Paytm, GPay',
                    isSelected: _selectedPaymentMethod == 'UPI / Wallet',
                    onTap: () {
                      setState(() {
                        _selectedPaymentMethod = 'UPI / Wallet';
                      });
                    },
                  ),
                  const SizedBox(height: 14),

                  // Credit/Debit Card Option
                  _PaymentMethodCard(
                    icon: Icons.credit_card,
                    title: 'Credit/Debit Card',
                    subtitle: 'Visa, Mastercard, Rupay',
                    isSelected: _selectedPaymentMethod == 'Credit/Debit Card',
                    onTap: () {
                      setState(() {
                        _selectedPaymentMethod = 'Credit/Debit Card';
                      });
                    },
                  ),
                  const SizedBox(height: 14),

                  // Net Banking Option
                  _PaymentMethodCard(
                    icon: Icons.account_balance,
                    title: 'Net Banking',
                    subtitle: 'All major banks',
                    isSelected: _selectedPaymentMethod == 'Net Banking',
                    onTap: () {
                      setState(() {
                        _selectedPaymentMethod = 'Net Banking';
                      });
                    },
                  ),
                  const SizedBox(height: 32),

                  // Security Features
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF007BFF).withOpacity(0.1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.security,
                            color: Color(0xFF007BFF),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '100% Secure Payment',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1A1D2E),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Your payment info is safe with us',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Pay Button with shimmer effect
                  AnimatedBuilder(
                    animation: _shimmerController,
                    builder: (context, child) {
                      return Container(
                        width: double.infinity,
                        height: 62,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: const [
                              Color(0xFFC7F464),
                              Color(0xFFB8E356),
                              Color(0xFFC7F464),
                            ],
                            stops: [
                              0.0,
                              _shimmerController.value,
                              1.0,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(31),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFC7F464).withOpacity(0.4),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _isProcessing ? null : _processPayment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(31),
                            ),
                            elevation: 0,
                          ),
                          child: _isProcessing
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.black87,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'Processing...',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.lock_outline,
                                      color: Colors.black87,
                                      size: 22,
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'Pay Securely',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Trust Badges
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.verified, size: 16, color: Colors.grey[500]),
                      const SizedBox(width: 6),
                      Text(
                        'Encrypted Payment',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.receipt_long, size: 16, color: Colors.grey[500]),
                      const SizedBox(width: 6),
                      Text(
                        'Receipt Sent',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF007BFF)
                : Colors.grey[200]!,
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: const Color(0xFF007BFF).withOpacity(0.15),
                blurRadius: 16,
                offset: const Offset(0, 4),
              )
            else
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isSelected
                      ? [
                          const Color(0xFF007BFF),
                          const Color(0xFF00C6FF),
                        ]
                      : [
                          Colors.grey[100]!,
                          Colors.grey[200]!,
                        ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? const Color(0xFF1A1D2E)
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF007BFF)
                      : Colors.grey[400]!,
                  width: 2,
                ),
                color: isSelected
                    ? const Color(0xFF007BFF)
                    : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentSuccessPage extends StatefulWidget {
  final String eventTitle;
  final String eventDate;
  final String eventTime;
  final String eventLocation;
  final double amount;
  final String paymentMethod;
  final DateTime? chosenDateTime;
  final String? eventId;

  const PaymentSuccessPage({
    Key? key,
    required this.eventTitle,
    required this.eventDate,
    required this.eventTime,
    required this.eventLocation,
    required this.amount,
    required this.paymentMethod,
    this.chosenDateTime,
    this.eventId,
  }) : super(key: key);

  @override
  State<PaymentSuccessPage> createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late AnimationController _confettiController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _scaleController.forward();
    _confettiController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Confetti Animation
          ...List.generate(30, (index) {
            final colors = [
              const Color(0xFF007BFF),
              const Color(0xFFC7F464),
              const Color(0xFF00C6FF),
              const Color(0xFFFFD700),
            ];
            return AnimatedBuilder(
              animation: _confettiController,
              builder: (context, child) {
                final progress = _confettiController.value;
                final randomX = (index * 37) % 100 / 100;
                final randomDelay = (index * 13) % 100 / 100;
                final adjustedProgress = (progress - randomDelay).clamp(0.0, 1.0);
                
                return Positioned(
                  left: MediaQuery.of(context).size.width * randomX,
                  top: -50 + (MediaQuery.of(context).size.height * adjustedProgress * 1.2),
                  child: Opacity(
                    opacity: (1 - adjustedProgress).clamp(0.0, 1.0),
                    child: Transform.rotate(
                      angle: adjustedProgress * 12.56 * (index % 2 == 0 ? 1 : -1),
                      child: Container(
                        width: index % 3 == 0 ? 8 : 12,
                        height: index % 3 == 0 ? 8 : 12,
                        decoration: BoxDecoration(
                          color: colors[index % colors.length],
                          shape: index % 2 == 0 ? BoxShape.circle : BoxShape.rectangle,
                          borderRadius: index % 2 == 1 ? BorderRadius.circular(2) : null,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const Spacer(),

                  // Success Icon with Ring Animation
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [
                                const Color(0xFF7CB342).withOpacity(0.1),
                                const Color(0xFF7CB342).withOpacity(0.0),
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFFC7F464).withOpacity(0.2),
                                const Color(0xFF7CB342).withOpacity(0.15),
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_circle_rounded,
                            size: 110,
                            color: Color(0xFF7CB342),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Success Message
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        const Text(
                          '🎉 Payment Successful!',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1D2E),
                            letterSpacing: 0.3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'You\'re all set for',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.eventTitle,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF007BFF),
                            letterSpacing: 0.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Payment Details Card
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.grey[50]!,
                            Colors.white,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.grey[200]!,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _DetailRow(
                            icon: Icons.calendar_today_rounded,
                            label: 'Date & Time',
                            value: '${widget.eventDate} at ${widget.eventTime}',
                          ),
                          const SizedBox(height: 20),
                          Divider(color: Colors.grey[200], height: 1),
                          const SizedBox(height: 20),
                          _DetailRow(
                            icon: Icons.location_on_rounded,
                            label: 'Location',
                            value: widget.eventLocation,
                          ),
                          const SizedBox(height: 20),
                          Divider(color: Colors.grey[200], height: 1),
                          const SizedBox(height: 20),
                          _DetailRow(
                            icon: Icons.payment_rounded,
                            label: 'Payment Method',
                            value: widget.paymentMethod,
                          ),
                          const SizedBox(height: 20),
                          Divider(color: Colors.grey[200], height: 1),
                          const SizedBox(height: 20),
                          _DetailRow(
                            icon: Icons.account_balance_wallet_rounded,
                            label: 'Amount Paid',
                            value: '₹${widget.amount.toInt()}',
                            valueColor: const Color(0xFF7CB342),
                            isBold: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),

                  // Action Buttons
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).popUntil((route) => route.isFirst);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF007BFF),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(29),
                              ),
                              elevation: 4,
                              shadowColor: const Color(0xFF007BFF).withOpacity(0.4),
                            ),
                            child: const Text(
                              'Back to Home',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        // SizedBox(
                        //   width: double.infinity,
                        //   height: 58,
                        //   child: OutlinedButton.icon(
                        //     onPressed: () {
                        //       // View ticket logic
                        //       ScaffoldMessenger.of(context).showSnackBar(
                        //         SnackBar(
                        //           content: const Text('Ticket sent to your email!'),
                        //           backgroundColor: const Color(0xFF7CB342),
                        //           behavior: SnackBarBehavior.floating,
                        //           shape: RoundedRectangleBorder(
                        //             borderRadius: BorderRadius.circular(12),
                        //           ),
                        //           margin: const EdgeInsets.all(16),
                        //         ),
                        //       );
                        //     },
                        //     icon: const Icon(Icons.confirmation_number_rounded, size: 22),
                        //     label: const Text(
                        //       'View Ticket',
                        //       style: TextStyle(
                        //         fontSize: 17,
                        //         fontWeight: FontWeight.bold,
                        //         letterSpacing: 0.3,
                        //       ),
                        //     ),
                        //     style: OutlinedButton.styleFrom(
                        //       foregroundColor: const Color(0xFF007BFF),
                        //       side: const BorderSide(
                        //         color: Color(0xFF007BFF),
                        //         width: 2,
                        //       ),
                        //       shape: RoundedRectangleBorder(
                        //         borderRadius: BorderRadius.circular(29),
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                  // const SizedBox(height: 16),

                  // Footer message
                  // FadeTransition(
                  //   opacity: _fadeAnimation,
                  //   child: Text(
                  //     'A confirmation email has been sent',
                  //     style: TextStyle(
                  //       fontSize: 13,
                  //       color: Colors.grey[600],
                  //       fontWeight: FontWeight.w500,
                  //     ),
                  //     textAlign: TextAlign.center,
                  //   ),
                  // ),
                  // const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF007BFF).withOpacity(0.1),
                const Color(0xFF00C6FF).withOpacity(0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF007BFF),
            size: 22,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: TextStyle(
                  fontSize: isBold ? 17 : 15,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                  color: valueColor ?? const Color(0xFF1A1D2E),
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}