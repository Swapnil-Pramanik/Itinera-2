import 'package:flutter/material.dart';
import '../../widgets/buttons/buttons.dart';
import 'timeline_update_preview_screen.dart';

/// Timeline Editor Screen - Modify activities
class TimelineEditorScreen extends StatefulWidget {
  final String tripId;
  const TimelineEditorScreen({super.key, required this.tripId});

  @override
  State<TimelineEditorScreen> createState() => _TimelineEditorScreenState();
}

class _TimelineEditorScreenState extends State<TimelineEditorScreen> {
  double _duration = 2.0;
  String _transportMode = 'WALK';

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
            // Alert
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.orange.shade200)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.schedule, size: 20, color: Colors.orange.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('SCHEDULING ALERT', style: TextStyle(fontFamily: 'RobotoMono', fontSize: 12, fontWeight: FontWeight.w600, color: Colors.orange.shade800)),
                        const SizedBox(height: 4),
                        Text('This time may conflict with lunch. Consider adjusting start time or duration.', style: TextStyle(fontFamily: 'RobotoMono', fontSize: 12, color: Colors.orange.shade700, height: 1.4)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
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
                        child: Icon(Icons.temple_buddhist, size: 20, color: Colors.orange.shade700),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Senso-ji Temple', style: TextStyle(fontFamily: 'RobotoMono', fontSize: 16, fontWeight: FontWeight.w600)), Text('09:00 - 11:00', style: TextStyle(fontFamily: 'RobotoMono', fontSize: 12, color: Colors.grey))])),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)), child: const Text('SIGHTSEEING', style: TextStyle(fontFamily: 'RobotoMono', fontSize: 10))),
                    ],
                  ),
                ],
              ),
            ),
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
            // Transport mode
            Text('GETTING THERE', style: TextStyle(fontFamily: 'RobotoMono', fontSize: 11, color: Colors.grey.shade600, letterSpacing: 1.2)),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildTransportOption('WALK', Icons.directions_walk, '15 min'),
                const SizedBox(width: 12),
                _buildTransportOption('TRAIN', Icons.train, '8 min'),
                const SizedBox(width: 12),
                _buildTransportOption('TAXI', Icons.local_taxi, '5 min'),
              ],
            ),
            const SizedBox(height: 24),
            // Swap suggestion
            Text('SWAP WITH', style: TextStyle(fontFamily: 'RobotoMono', fontSize: 11, color: Colors.grey.shade600, letterSpacing: 1.2)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.blue.shade100, borderRadius: BorderRadius.circular(10)), child: Icon(Icons.museum, size: 20, color: Colors.blue.shade700)),
                  const SizedBox(width: 12),
                  const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('National Museum', style: TextStyle(fontFamily: 'RobotoMono', fontSize: 14, fontWeight: FontWeight.w500)), Text('Alternative for this slot', style: TextStyle(fontFamily: 'RobotoMono', fontSize: 12, color: Colors.grey))])),
                  const Icon(Icons.swap_horiz, color: Colors.grey),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        child: SafeArea(
          child: PrimaryButton(
            text: 'SAVE CHANGES',
            showArrow: false,
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => TimelineUpdatePreviewScreen(
                    tripId: widget.tripId,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTransportOption(String label, IconData icon, String time) {
    final isSelected = _transportMode == label;
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
            ],
          ),
        ),
      ),
    );
  }
}
