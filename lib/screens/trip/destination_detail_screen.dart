import 'package:flutter/material.dart';
import '../../widgets/buttons/buttons.dart';
import '../timeline/timeline_selector_screen.dart';

/// Destination Detail Screen - City overview with attractions and map
class DestinationDetailScreen extends StatelessWidget {
  const DestinationDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // Hero image app bar
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: Colors.black,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.bookmark_border, color: Colors.white),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.share_outlined, color: Colors.white),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: Colors.grey.shade800,
                    child: const Icon(
                      Icons.image,
                      size: 60,
                      color: Colors.grey,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 80,
                    left: 20,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.place,
                          size: 14,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'JAPAN',
                          style: TextStyle(
                            fontFamily: 'RobotoMono',
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Positioned(
                    bottom: 60,
                    left: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tokyo',
                          style: TextStyle(
                            fontFamily: 'RobotoMono',
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.star, size: 16, color: Colors.amber),
                            SizedBox(width: 4),
                            Text(
                              '4.9',
                              style: TextStyle(
                                fontFamily: 'RobotoMono',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              '(20k reviews)',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick info chips
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _buildInfoChip(Icons.wb_sunny_outlined, 'Best in Spring'),
                      _buildInfoChip(Icons.schedule, '7-10 Days'),
                      _buildInfoChip(Icons.thermostat_outlined, 'Hig...'),
                    ],
                  ),
                  
                  const SizedBox(height: 28),
                  
                  // What to expect
                  const Text(
                    'What to expect',
                    style: TextStyle(
                      fontFamily: 'RobotoMono',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Text(
                    'A neon-lit blend of old and new, where ancient temples stand in the shadow of skyscrapers. Tokyo offers an sensory overload of culinary masterpieces, efficient transit, and distinct neighborhood subcultures.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.6,
                    ),
                  ),
                  
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text(
                      'Read more',
                      style: TextStyle(
                        fontFamily: 'RobotoMono',
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Top attractions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Top attractions',
                        style: TextStyle(
                          fontFamily: 'RobotoMono',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'See all',
                          style: TextStyle(
                            fontFamily: 'RobotoMono',
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Attractions grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildAttractionCard('Senso-ji\nTemple', 'Asakusa'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildAttractionCard('Shibuya\nCrossing', 'Shibuya'),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Location
                  const Text(
                    'Location',
                    style: TextStyle(
                      fontFamily: 'RobotoMono',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Map placeholder
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Icon(
                            Icons.map_outlined,
                            size: 40,
                            color: Colors.grey.shade400,
                          ),
                        ),
                        Positioned(
                          right: 12,
                          bottom: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.open_in_new,
                                  size: 14,
                                  color: Colors.grey.shade700,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Open Map',
                                  style: TextStyle(
                                    fontFamily: 'RobotoMono',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      
      // Bottom bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'EST. COST',
                    style: TextStyle(
                      fontFamily: 'RobotoMono',
                      fontSize: 10,
                      color: Colors.grey.shade600,
                      letterSpacing: 1,
                    ),
                  ),
                  const Text(
                    '\$1,200',
                    style: TextStyle(
                      fontFamily: 'RobotoMono',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(
                child: PrimaryButton(
                  text: 'Plan this trip',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TimelineSelectorScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade700),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'RobotoMono',
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttractionCard(String title, String location) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 12,
            bottom: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'RobotoMono',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  location,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
