import 'package:flutter/material.dart';
import '../../widgets/buttons/buttons.dart';
import '../../core/trip_service.dart';

/// Timeline Editor Screen - Modify activities
class TimelineEditorScreen extends StatefulWidget {
  final String tripId;
  final Map<String, dynamic> activity;
  final String? previousActivityTitle;
  final String city;
  final String country;

  const TimelineEditorScreen({
    super.key, 
    required this.tripId,
    required this.activity,
    this.previousActivityTitle,
    required this.city,
    required this.country,
  });

  @override
  State<TimelineEditorScreen> createState() => _TimelineEditorScreenState();
}

class _TimelineEditorScreenState extends State<TimelineEditorScreen> {
  late double _duration;
  late double _originalDuration;
  late String _transportMode;
  late String _activityTitle;
  late String _time;
  late String _category;

  // Transport estimate state
  bool _isLoadingTransport = true;
  Map<String, dynamic>? _transportEstimate;
  String _currency = '₹';

  @override
  void initState() {
    super.initState();
    _activityTitle = widget.activity['title'] ?? 'Activity';
    _time = widget.activity['time'] ?? '09:00';
    _category = widget.activity['type'] ?? 'SIGHTSEEING';
    _duration = widget.activity['duration_hours']?.toDouble() ?? 2.0; 
    _originalDuration = _duration;
    _transportMode = widget.activity['transport_mode'] ?? 'TRANSIT';
    _fetchTransportEstimate();
  }

  Future<void> _fetchTransportEstimate() async {
    if (widget.previousActivityTitle == null) {
      setState(() => _isLoadingTransport = false);
      return;
    }

    final estimate = await TripService.getTransportEstimate(
      tripId: widget.tripId,
      originTitle: widget.previousActivityTitle!,
      destinationTitle: _activityTitle,
      city: widget.city,
      country: widget.country,
    );

    if (mounted) {
      setState(() {
        _transportEstimate = estimate;
        _isLoadingTransport = false;
        if (estimate != null) {
          final curr = estimate['currency'] ?? 'INR';
          _currency = _getCurrencySymbol(curr);
          // Set recommended mode
          final rec = estimate['recommended'] ?? 'transit';
          if (_transportMode == 'TRANSIT' || _transportMode == 'TRAIN') {
            _transportMode = rec.toString().toUpperCase();
          }
        }
      });
    }
  }

  String _getCurrencySymbol(String code) {
    switch (code.toUpperCase()) {
      case 'INR': return '₹';
      case 'EUR': return '€';
      case 'GBP': return '£';
      case 'JPY': return '¥';
      case 'USD': return '\$';
      default: return code;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.black)),
        title: const Text('EDIT ACTIVITY', style: TextStyle(fontFamily: 'RobotoMono', fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 1, color: Colors.black)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Activity card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(10)),
                        child: Icon(_getIconForCategory(_category), size: 20, color: Colors.orange.shade700),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(_activityTitle, style: const TextStyle(fontFamily: 'RobotoMono', fontSize: 16, fontWeight: FontWeight.w600)), Text(_time, style: const TextStyle(fontFamily: 'RobotoMono', fontSize: 12, color: Colors.grey))])),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)), child: Text(_category, style: const TextStyle(fontFamily: 'RobotoMono', fontSize: 10))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Editable fields
            _buildEditableField('TITLE', _activityTitle, (v) => setState(() => _activityTitle = v)),
            const SizedBox(height: 16),
            _buildEditableField('TIME', _time, (v) => setState(() => _time = v)),
            const SizedBox(height: 24),
            // Duration slider
            Text('DURATION', style: TextStyle(fontFamily: 'RobotoMono', fontSize: 11, color: Colors.grey.shade600, letterSpacing: 1.2)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('${_duration.toStringAsFixed(1)} hours', style: const TextStyle(fontFamily: 'RobotoMono', fontSize: 16, fontWeight: FontWeight.w600)), Text('Recommended: 2 hrs', style: TextStyle(fontFamily: 'RobotoMono', fontSize: 12, color: Colors.grey.shade600))]),
                  const SizedBox(height: 12),
                  Slider(value: _duration, min: 0.5, max: 4.0, divisions: 7, activeColor: Colors.black, onChanged: (v) => setState(() => _duration = v)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Transport mode (powered by Gemini)
            if (widget.previousActivityTitle != null) ...[
              Text('GETTING THERE', style: TextStyle(fontFamily: 'RobotoMono', fontSize: 11, color: Colors.grey.shade600, letterSpacing: 1.2)),
              const SizedBox(height: 12),
              if (_isLoadingTransport)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: const Center(
                    child: Column(
                      children: [
                        SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                        SizedBox(height: 8),
                        Text('Estimating routes...', style: TextStyle(fontFamily: 'RobotoMono', fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ),
                )
              else
                Row(
                  children: [
                    _buildTransportOption(
                      'WALK', Icons.directions_walk, 
                      '${_transportEstimate?['walk']?['duration_min'] ?? 25} min',
                      (_transportEstimate?['walk']?['price'] ?? 0).toDouble(),
                      (_transportEstimate?['walk']?['price_inr'] ?? 0).toDouble(),
                    ),
                    const SizedBox(width: 12),
                    _buildTransportOption(
                      'TRANSIT', Icons.train, 
                      '${_transportEstimate?['transit']?['duration_min'] ?? 15} min',
                      (_transportEstimate?['transit']?['price'] ?? 30).toDouble(),
                      (_transportEstimate?['transit']?['price_inr'] ?? 30).toDouble(),
                    ),
                    const SizedBox(width: 12),
                    _buildTransportOption(
                      'TAXI', Icons.local_taxi, 
                      '${_transportEstimate?['taxi']?['duration_min'] ?? 8} min',
                      (_transportEstimate?['taxi']?['price'] ?? 200).toDouble(),
                      (_transportEstimate?['taxi']?['price_inr'] ?? 200).toDouble(),
                    ),
                  ],
                ),
              if (_transportEstimate?['recommended'] != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Recommended: ${_transportEstimate!['recommended'].toString().toUpperCase()}',
                  style: TextStyle(fontFamily: 'RobotoMono', fontSize: 10, color: Colors.blue.shade600, fontWeight: FontWeight.w600),
                ),
              ],
            ],
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PrimaryButton(
                text: 'SAVE CHANGES',
                showArrow: false,
                onPressed: () {
                  final double savedTime = _originalDuration - _duration;
                  final Map<String, dynamic> updatedActivity = Map.from(widget.activity);
                  updatedActivity['title'] = _activityTitle;
                  updatedActivity['time'] = _time;
                  updatedActivity['type'] = _category;
                  updatedActivity['duration_hours'] = _duration;

                  // Get selected transport stats
                  double newTransportHours = 0.33;
                  double priceDelta = 0;
                  
                  if (_transportEstimate != null) {
                    final modeKey = _transportMode.toLowerCase();
                    final modeData = _transportEstimate![modeKey];
                    if (modeData != null) {
                      newTransportHours = (modeData['duration_min'] ?? 20) / 60.0;
                      priceDelta = (modeData['price'] ?? 0).toDouble();
                    }
                  }
                  
                  Navigator.pop(context, <String, dynamic>{
                    'savedTime': savedTime,
                    'activity': updatedActivity,
                    'transport_mode': _transportMode,
                    'transport_duration_hours': newTransportHours,
                    'transport_price_delta': priceDelta,
                    'currency_symbol': _currency,
                  });
                },
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context, <String, dynamic>{
                      'deleted': true,
                      'savedTime': _originalDuration,
                      'activity': widget.activity,
                    });
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.red.withOpacity(0.3)),
                    ),
                  ),
                  child: const Text(
                    'DELETE THIS ACTIVITY', 
                    style: TextStyle(
                      fontFamily: 'RobotoMono', 
                      fontSize: 12, 
                      fontWeight: FontWeight.w700, 
                      color: Colors.red
                    )
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableField(String label, String value, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontFamily: 'RobotoMono', fontSize: 11, color: Colors.grey.shade600, letterSpacing: 1.2)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: TextField(
            controller: TextEditingController(text: value),
            onChanged: onChanged,
            style: const TextStyle(fontFamily: 'RobotoMono', fontSize: 14),
            decoration: const InputDecoration(border: InputBorder.none),
          ),
        ),
      ],
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'SIGHTSEEING': return Icons.camera_alt_outlined;
      case 'DINING': return Icons.restaurant_outlined;
      case 'TRANSPORT': return Icons.directions_bus_outlined;
      case 'RELAXATION': return Icons.hotel_outlined;
      default: return Icons.explore_outlined;
    }
  }

  Widget _buildTransportOption(String label, IconData icon, String time, double price, double priceInr) {
    final isSelected = _transportMode == label;
    
    // Determine how to format the price display
    String priceDisplay = '';
    if (price > 0) {
      priceDisplay = '$_currency${price.toInt()}';
      if (_currency != '₹' && priceInr > 0) {
        priceDisplay += ' (₹${priceInr.toInt()})';
      }
    }

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _transportMode = label),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: isSelected ? Colors.black : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: isSelected ? Colors.black : Colors.grey.shade300)),
          child: Column(
            children: [
              Icon(icon, size: 24, color: isSelected ? Colors.white : Colors.grey.shade700),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(fontFamily: 'RobotoMono', fontSize: 10, fontWeight: FontWeight.w500, color: isSelected ? Colors.white : Colors.grey.shade700)),
              Text(time, style: TextStyle(fontFamily: 'RobotoMono', fontSize: 10, color: isSelected ? Colors.white70 : Colors.grey.shade500)),
              if (priceDisplay.isNotEmpty)
                Text(priceDisplay, style: TextStyle(fontFamily: 'RobotoMono', fontSize: 9, fontWeight: FontWeight.bold, color: isSelected ? Colors.green.shade200 : Colors.green.shade700)),
            ],
          ),
        ),
      ),
    );
  }
}
