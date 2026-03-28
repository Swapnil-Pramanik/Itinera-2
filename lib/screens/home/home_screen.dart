import 'package:flutter/material.dart';
import '../../core/user_service.dart';
import '../../core/trip_service.dart';
import '../../core/destination_service.dart';
import '../../widgets/appbars/appbars.dart';
import '../../widgets/cards/cards.dart';
import '../../widgets/common/common.dart';
import 'profile_screen.dart';
import 'search_bottom_sheet.dart';
import 'my_atlas_bottom_sheet.dart';
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
  List<Map<String, dynamic>> _recentDestinations = [];
  bool _isLoadingTrips = true;
  bool _isLoadingAtlas = true;

  final PageController _pageController = PageController(viewportFraction: 0.85);

  @override
  void initState() {
    super.initState();
    _loadTrips();
    _loadAtlasArticles();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
      final destinations = await DestinationService.getRecentDestinations();
      if (mounted) {
        setState(() {
          _recentDestinations = destinations;
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
            const SectionHeader(title: 'MY ATLAS'),

            const SizedBox(height: 16),

            // Atlas content
            _buildAtlasSection(),

            const SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Transform.translate(
        offset: const Offset(0, 16),
        child: FloatingActionButton.extended(
          onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const SearchBottomSheet(),
          );
        },
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        icon: const Icon(
          Icons.search,
          color: Colors.white,
          size: 20,
        ),
        label: const Text(
          'Search',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'RobotoMono',
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
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

    if (_recentDestinations.isEmpty) {
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
            Icon(Icons.search_off, size: 36, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'NO RECENT SEARCHES',
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

    final int itemCount = _recentDestinations.length + 1;

    return SizedBox(
      height: 440,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Visual Layers stacked correctly
          AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              double page = 0.0;
              if (_pageController.hasClients && _pageController.position.haveDimensions) {
                page = _pageController.page ?? 0.0;
              }

              List<int> sortedIndices = List.generate(itemCount, (i) => i);
              sortedIndices.sort((a, b) {
                final distA = (a - page).abs();
                final distB = (b - page).abs();
                return distB.compareTo(distA);
              });

              return Stack(
                alignment: Alignment.center,
                children: sortedIndices.map((index) {
                  final double diff = (index - page);
                  final double absDiff = diff.abs();

                  if (absDiff > 2.5) return const SizedBox.shrink();

                  final double scale = (1.0 - (absDiff * 0.15)).clamp(0.0, 1.0);
                  final double translateX = diff * 210.0;
                  final double opacity = (1.0 - (absDiff * 0.4)).clamp(0.0, 1.0);

                  return Transform(
                    transform: Matrix4.identity()
                      ..translate(translateX, 0.0, 0.0)
                      ..scale(scale, scale),
                    alignment: Alignment.center,
                    child: Opacity(
                      opacity: opacity,
                      child: SizedBox(
                        width: 290,
                        height: 440,
                        child: _buildAtlasPage(index),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          
          // Invisible hit box / gesture driver layer
          PageView.builder(
            controller: _pageController,
            clipBehavior: Clip.none,
            itemCount: itemCount,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  final page = (_pageController.hasClients && _pageController.position.haveDimensions) ? _pageController.page ?? 0 : 0;
                  if ((page - index).abs() < 0.5) {
                    if (index == _recentDestinations.length) {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => const MyAtlasBottomSheet(),
                      );
                    } else {
                      final dest = _recentDestinations[index];
                      final title = dest['name'] ?? '';
                      final destCountry = dest['country'] ?? '';
                      if (title.isNotEmpty && destCountry.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DestinationDetailScreen(
                              destinationName: title,
                              destinationCountry: destCountry,
                            ),
                          ),
                        );
                      }
                    }
                  } else {
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                },
                child: Container(color: Colors.transparent),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAtlasPage(int index) {
    if (index == _recentDestinations.length) {
      return GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => const MyAtlasBottomSheet(),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.arrow_forward_rounded, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              Text(
                'See more',
                style: TextStyle(
                  fontFamily: 'RobotoMono',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final dest = _recentDestinations[index];
    final title = dest['name'] ?? '';
    final description = dest['description'] ?? '';
    final bestSeason = dest['best_season'];
    final String? duration = bestSeason != null ? 'Best in $bestSeason' : null;
    final destCountry = dest['country'] ?? '';
    final imageUrl = dest['image_url'];
    final rawRating = dest['rating'];
    final double? rating = rawRating != null ? (rawRating is int ? rawRating.toDouble() : (rawRating as num).toDouble()) : null;
    final tags = (dest['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];

    return AtlasCard(
      title: title,
      description: description,
      duration: duration,
      imageUrl: imageUrl,
      rating: rating,
      tags: tags.take(4).toList(),
      onTap: () {
        if (title.isNotEmpty && destCountry.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DestinationDetailScreen(
                destinationName: title,
                destinationCountry: destCountry,
              ),
            ),
          );
        }
      },
      onPlanTap: () {
        if (title.isNotEmpty && destCountry.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DestinationDetailScreen(
                destinationName: title,
                destinationCountry: destCountry,
              ),
            ),
          );
        }
      },
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
