import 'package:flutter/material.dart';
import '../../core/destination_service.dart';
import '../../widgets/cards/cards.dart';
import '../trip/destination_detail_screen.dart';

/// Dark-themed bottom sheet displaying full history of destinations found in My Atlas.
class MyAtlasBottomSheet extends StatefulWidget {
  const MyAtlasBottomSheet({super.key});

  @override
  State<MyAtlasBottomSheet> createState() => _MyAtlasBottomSheetState();
}

class _MyAtlasBottomSheetState extends State<MyAtlasBottomSheet> {
  List<Map<String, dynamic>> _destinations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDestinations();
  }

  Future<void> _loadDestinations() async {
    final list = await DestinationService.getAllDestinations();
    if (mounted) {
      setState(() {
        _destinations = list;
        _isLoading = false;
      });
    }
  }

  void _navigateToDestination(String name, String country) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DestinationDetailScreen(
          destinationName: name,
          destinationCountry: country,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.67,
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade700,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Icon(Icons.explore, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'MY ATLAS HISTORY',
                  style: TextStyle(
                    fontFamily: 'RobotoMono',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white70),
                ),
              ],
            ),
          ),
          
          const Divider(color: Colors.white12, thickness: 1, height: 24),
          
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white54),
                  )
                : _destinations.isEmpty
                    ? Center(
                        child: Text(
                          'No history available.',
                          style: TextStyle(
                            fontFamily: 'RobotoMono',
                            color: Colors.grey.shade500,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        itemCount: _destinations.length,
                        itemBuilder: (context, index) {
                          final dest = _destinations[index];
                          final title = dest['name'] ?? '';
                          final country = dest['country'] ?? '';
                          final description = dest['description'] ?? '';
                          final bestSeason = dest['best_season'];
                          final duration = bestSeason != null ? 'Best in $bestSeason' : null;
                          final imageUrl = dest['image_url'];
                          final rawRating = dest['rating'];
                          final double? rating = rawRating != null ? (rawRating is int ? rawRating.toDouble() : (rawRating as num).toDouble()) : null;
                          final tags = (dest['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: SizedBox(
                              height: 380, // Explicit height required since AtlasCard relies on parent bounds
                              child: AtlasCard(
                                title: title,
                                description: description,
                                duration: duration,
                                imageUrl: imageUrl,
                                rating: rating,
                                tags: tags.take(4).toList(),
                                onTap: () => _navigateToDestination(title, country),
                                onPlanTap: () => _navigateToDestination(title, country),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
