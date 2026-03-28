import 'package:flutter/material.dart';
import '../../core/user_service.dart';
import '../../core/trip_service.dart';
import '../../core/destination_service.dart';
import '../../widgets/appbars/appbars.dart';
import '../../widgets/cards/cards.dart';
import '../../widgets/common/common.dart';
import 'profile_screen.dart';
import 'search_bottom_sheet.dart';
import '../trip/destination_detail_screen.dart';
import '../trip/trip_scheduled_screen.dart';

/// Home Screen - Main dashboard with trips and atlas
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _trips = [];
  List<Map<String, dynamic>> _atlasArticles = [];
  bool _isLoadingTrips = true;
  bool _isLoadingAtlas = true;

  @override
  void initState() {
    super.initState();
    _loadTrips();
    _loadAtlasArticles();
  }

  Future<void> _loadTrips() async {
    try {
      final trips = await TripService.getMyTrips();
      if (mounted) {
        setState(() {
          _trips = trips;
          _isLoadingTrips = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingTrips = false;
        });
      }
    }
  }

  Future<void> _loadAtlasArticles() async {
    try {
      final articles = await DestinationService.getAtlasArticles();
      if (mounted) {
        setState(() {
          _atlasArticles = articles;
          _isLoadingAtlas = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingAtlas = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: HomeAppBar(
        temperature: '--',
        onMenuTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          );
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Greeting
            Text(
              UserService.getGreeting(),
              style: TextStyle(
                fontFamily: 'RobotoMono',
                fontSize: 28,
                fontWeight: FontWeight.w300,
                color: Colors.grey.shade800,
              ),
            ),
            Text(
              UserService.getDisplayName(),
              style: const TextStyle(
                fontFamily: 'RobotoMono',
                fontSize: 32,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 24),

            // My Planned Trips section
            SectionHeader(
              title: 'MY PLANNED TRIPS',
              actionText: _trips.isNotEmpty ? 'View all' : null,
              onActionTap: _trips.isNotEmpty ? () {} : null,
            ),

            const SizedBox(height: 16),

            // Dynamic trip cards or empty state
            _buildTripsSection(),

            const SizedBox(height: 32),

            // The Atlas section
            const SectionHeader(title: 'THE ATLAS'),

            const SizedBox(height: 16),

            // Atlas content
            _buildAtlasSection(),

            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const SearchBottomSheet(),
          );
        },
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  /// Builds the Atlas section — loading, empty, or dynamic article cards.
  Widget _buildAtlasSection() {
    if (_isLoadingAtlas) {
      return SizedBox(
        height: 100,
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.grey.shade400,
            ),
          ),
        ),
      );
    }

    if (_atlasArticles.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(Icons.auto_stories_outlined, size: 36, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'NO ARTICLES YET',
              style: TextStyle(
                fontFamily: 'RobotoMono',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: _atlasArticles.map((article) {
        final title = article['title'] ?? '';
        final description = article['description'] ?? '';
        final duration = article['read_duration'] ?? '';
        final destination = article['destinations'] as Map<String, dynamic>?;
        final destName = destination?['name'] ?? '';
        final destCountry = destination?['country'] ?? '';

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: AtlasCard(
            title: title,
            description: description,
            duration: duration,
            onTap: () {
              if (destName.isNotEmpty && destCountry.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DestinationDetailScreen(
                      destinationName: destName,
                      destinationCountry: destCountry,
                    ),
                  ),
                );
              }
            },
            onPlanTap: () {
              if (destName.isNotEmpty && destCountry.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DestinationDetailScreen(
                      destinationName: destName,
                      destinationCountry: destCountry,
                    ),
                  ),
                );
              }
            },
          ),
        );
      }).toList(),
    );
  }

  /// Builds the trips section — loading, empty state, or dynamic trip cards.
  Widget _buildTripsSection() {
    if (_isLoadingTrips) {
      return SizedBox(
        height: 150,
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.grey.shade400,
            ),
          ),
        ),
      );
    }

    if (_trips.isEmpty) {
      return _buildEmptyTripsState();
    }

    // Dynamic trip cards from fetched data
    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _trips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final trip = _trips[index];
          final destination = trip['destinations'] as Map<String, dynamic>?;
          final name = destination?['name'] ?? trip['title'] ?? 'Trip';
          final country = destination?['country'] ?? '';
          final tags = (destination?['tags'] as List<dynamic>?)
                  ?.map((t) => t.toString())
                  .toList() ??
              (trip['tags'] as List<dynamic>?)
                  ?.map((t) => t.toString())
                  .toList() ??
              [];

          return TripCard(
            destination: name,
            country: country,
            tags: tags,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TripScheduledScreen(),
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// Empty state shown when the user has no planned trips.
  Widget _buildEmptyTripsState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.explore_outlined,
            size: 40,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            'NO TRIPS PLANNED YET',
            style: TextStyle(
              fontFamily: 'RobotoMono',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to explore destinations\nand plan your first adventure.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
