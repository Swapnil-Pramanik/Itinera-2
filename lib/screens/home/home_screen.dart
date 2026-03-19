import 'package:flutter/material.dart';
import '../../core/user_service.dart';
import '../../widgets/appbars/appbars.dart';
import '../../widgets/cards/cards.dart';
import '../../widgets/common/common.dart';
import '../../widgets/buttons/buttons.dart';
import 'profile_screen.dart';
import 'search_bottom_sheet.dart';
import '../trip/destination_detail_screen.dart';
import '../trip/trip_scheduled_screen.dart';

/// Home Screen - Main dashboard with trips and atlas
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: HomeAppBar(
        temperature: '22°C',
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
              actionText: 'View all',
              onActionTap: () {},
            ),

            const SizedBox(height: 16),

            // Horizontal scrolling trip cards
            SizedBox(
              height: 150,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  TripCard(
                    destination: 'Tokyo',
                    country: 'Japan',
                    tags: const ['URBAN', 'FOOD'],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TripScheduledScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 16),
                  TripCard(
                    destination: 'Paris',
                    country: 'France',
                    tags: const ['CULTURE', 'ART'],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TripScheduledScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 16),
                  TripCard(
                    destination: 'Bali',
                    country: 'Indonesia',
                    tags: const ['NATURE', 'RELAX'],
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // The Atlas section
            const SectionHeader(title: 'THE ATLAS'),

            const SizedBox(height: 16),

            // Category chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChipButton(
                    label: 'TRENDING',
                    icon: Icons.trending_up,
                    isSelected: true,
                    onTap: () {},
                  ),
                  const SizedBox(width: 10),
                  ChipButton(
                    label: 'SPRING',
                    isSelected: false,
                    onTap: () {},
                  ),
                  const SizedBox(width: 10),
                  ChipButton(
                    label: 'WINTER',
                    isSelected: false,
                    onTap: () {},
                  ),
                  const SizedBox(width: 10),
                  ChipButton(
                    label: 'HIDDEN',
                    isSelected: false,
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Atlas cards
            AtlasCard(
              title: 'Kyoto in Autumn',
              description:
                  'Witness the ancient world transform into a canvas of crimson and gold. A curated guide...',
              duration: '8 MIN READ',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DestinationDetailScreen(),
                  ),
                );
              },
              onPlanTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DestinationDetailScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            AtlasCard(
              title: 'Nordic Escape',
              description:
                  'A complete 7-day automated itinerary for Iceland. Chase the Northern Lights and rela...',
              duration: '5 MIN',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DestinationDetailScreen(),
                  ),
                );
              },
              onPlanTap: () {},
            ),

            const SizedBox(height: 16),

            AtlasCard(
              title: 'Taste of Tuscany',
              description:
                  'Discover the culinary heart of Italy with this food-focused journey through vineyards an...',
              duration: '10 WEEKS',
              onTap: () {},
              onPlanTap: () {},
            ),

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
}
