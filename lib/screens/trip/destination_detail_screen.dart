import 'package:flutter/material.dart';
import '../../core/destination_service.dart';
import '../../widgets/buttons/buttons.dart';
import '../timeline/timeline_selector_screen.dart';

/// Destination Detail Screen - Dynamic city overview with attractions
class DestinationDetailScreen extends StatefulWidget {
  final String destinationName;
  final String destinationCountry;
  final Map<String, dynamic>? preloadedData;

  const DestinationDetailScreen({
    super.key,
    required this.destinationName,
    required this.destinationCountry,
    this.preloadedData,
  });

  @override
  State<DestinationDetailScreen> createState() => _DestinationDetailScreenState();
}

class _DestinationDetailScreenState extends State<DestinationDetailScreen> {
  Map<String, dynamic>? _data;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.preloadedData != null) {
      _data = widget.preloadedData;
      _isLoading = false;
    } else {
      _fetchDetails();
    }
  }

  Future<void> _fetchDetails() async {
    try {
      final data = await DestinationService.getDestinationByName(
        widget.destinationName,
        widget.destinationCountry,
      );
      if (mounted) {
        setState(() {
          _data = data;
          _isLoading = false;
          if (data == null) _error = 'Could not load destination details';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Failed to load: $e';
        });
      }
    }
  }

  // Helpers to extract data with fallbacks
  String get _name => _data?['name'] ?? widget.destinationName;
  String get _country => _data?['country'] ?? widget.destinationCountry;
  String get _description => _data?['description'] ?? 'Explore this beautiful destination.';
  String? get _bestSeason => _data?['best_season'];
  int? get _minDays => _data?['ideal_duration_min_days'];
  int? get _maxDays => _data?['ideal_duration_max_days'];
  num? get _rating => _data?['rating'];
  int? get _reviewCount => _data?['review_count'];
  num? get _dailyCost => _data?['estimated_daily_cost_usd'];
  List<Map<String, dynamic>> get _attractions {
    final raw = _data?['attractions'];
    if (raw is List) {
      return raw.cast<Map<String, dynamic>>();
    }
    return [];
  }

  String get _durationLabel {
    if (_minDays != null && _maxDays != null) return '$_minDays-$_maxDays Days';
    if (_minDays != null) return '$_minDays+ Days';
    return '';
  }

  String get _costLabel {
    if (_dailyCost != null) {
      final days = _minDays ?? 7;
      final total = (_dailyCost! * days).round();
      return '\$$total';
    }
    return '--';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.black),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Colors.black),
        ),
      );
    }

    if (_error != null && _data == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.black),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _error = null;
                  });
                  _fetchDetails();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

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
                          _country.toUpperCase(),
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
                  Positioned(
                    bottom: 60,
                    left: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _name,
                          style: const TextStyle(
                            fontFamily: 'RobotoMono',
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        if (_rating != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.star, size: 16, color: Colors.amber),
                              const SizedBox(width: 4),
                              Text(
                                _rating.toString(),
                                style: const TextStyle(
                                  fontFamily: 'RobotoMono',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              if (_reviewCount != null) ...[
                                const SizedBox(width: 8),
                                Text(
                                  '(${_formatCount(_reviewCount!)} reviews)',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
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
                      if (_bestSeason != null)
                        _buildInfoChip(Icons.wb_sunny_outlined, _bestSeason!.contains('in') ? _bestSeason! : 'Best in $_bestSeason'),
                      if (_durationLabel.isNotEmpty)
                        _buildInfoChip(Icons.schedule, _durationLabel),
                      if (_dailyCost != null)
                        _buildInfoChip(Icons.attach_money, '\$${_dailyCost!.round()}/day'),
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
                    _description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Top attractions
                  if (_attractions.isNotEmpty) ...[
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
                        if (_attractions.length > 4)
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

                    // Attractions grid — show up to 4 in 2x2
                    _buildAttractionsGrid(),

                    const SizedBox(height: 32),
                  ],

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
                  Text(
                    _costLabel,
                    style: const TextStyle(
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

  Widget _buildAttractionsGrid() {
    final toShow = _attractions.take(4).toList();
    final rows = <Widget>[];

    for (var i = 0; i < toShow.length; i += 2) {
      final row = Row(
        children: [
          Expanded(
            child: _buildAttractionCard(
              toShow[i]['name'] ?? '',
              toShow[i]['location_area'] ?? '',
            ),
          ),
          const SizedBox(width: 12),
          if (i + 1 < toShow.length)
            Expanded(
              child: _buildAttractionCard(
                toShow[i + 1]['name'] ?? '',
                toShow[i + 1]['location_area'] ?? '',
              ),
            )
          else
            const Expanded(child: SizedBox()),
        ],
      );
      rows.add(row);
      if (i + 2 < toShow.length) rows.add(const SizedBox(height: 12));
    }

    return Column(children: rows);
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
            right: 12,
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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

  String _formatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(0)}k';
    }
    return count.toString();
  }
}
