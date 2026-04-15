import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/destination_service.dart';
import '../../widgets/buttons/buttons.dart';
import '../../widgets/overlays/weather_popup.dart';
import '../../widgets/overlays/weather_theme.dart';
import '../timeline/timeline_selector_screen.dart';
import '../../widgets/overlays/destination_chat_sheet.dart';
import '../../widgets/inputs/rating_stars.dart';

/// Destination Detail Screen - Dynamic city overview with attractions
class DestinationDetailScreen extends StatefulWidget {
  final String destinationName;
  final String destinationCountry;
  final double? latitude;
  final double? longitude;
  final Map<String, dynamic>? preloadedData;

  const DestinationDetailScreen({
    super.key,
    required this.destinationName,
    required this.destinationCountry,
    this.latitude,
    this.longitude,
    this.preloadedData,
  });

  @override
  State<DestinationDetailScreen> createState() =>
      _DestinationDetailScreenState();
}

class _DestinationDetailScreenState extends State<DestinationDetailScreen> {
  Map<String, dynamic>? _data;
  Map<String, dynamic>? _weather;
  bool _isLoading = true;
  String? _error;
  int? _userRating;

  final ScrollController _scrollController = ScrollController();
  bool _isCollapsed = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.hasClients) {
        bool isCollapsed = _scrollController.offset > 200;
        if (isCollapsed != _isCollapsed) {
          setState(() {
            _isCollapsed = isCollapsed;
          });
        }
      }
    });

    if (widget.preloadedData != null) {
      _data = widget.preloadedData;
      _isLoading = false;
      
      if (_data?['id'] != null) {
        _fetchUserRating(_data!['id']);
      }

      // If data is preloaded but incomplete (missing attractions or daily cost),
      // we still fetch the full details in the background to ensure it populates
      // as soon as the first-visit enrichment finishes on the backend.
      final hasAttractions = (_data!['attractions'] as List? ?? []).isNotEmpty;
      final hasBudget = _data!['estimated_daily_cost_usd'] != null;
      
      if (!hasAttractions || !hasBudget) {
        debugPrint('[Detail] Preloaded data incomplete, triggering deep fetch in background...');
        _fetchDetails(); 
      }
    } else {
      _fetchDetails();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchDetails() async {
    try {
      final data = await DestinationService.getDestinationByName(
        widget.destinationName,
        widget.destinationCountry,
        lat: widget.latitude,
        lon: widget.longitude,
      );
      if (mounted) {
        setState(() {
          _data = data;
          _isLoading = false;
          _error = (data == null && _data == null) ? 'Could not load destination details' : null;
        });
        
        if (data?['id'] != null) {
          _fetchUserRating(data!['id']);
        }
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

  Future<void> _fetchUserRating(String destinationId) async {
    final rating = await DestinationService.getUserRating(destinationId);
    if (mounted) {
      setState(() => _userRating = rating);
    }
  }

  Future<void> _handleRate(int rating) async {
    if (_data?['id'] == null) return;
    
    // Optimistic UI update
    final oldRating = _userRating;
    setState(() => _userRating = rating);

    final success = await DestinationService.rateDestination(_data!['id'], rating);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'RATING SAVED: $rating STARS',
            style: const TextStyle(fontFamily: 'RobotoMono', color: Colors.white, fontSize: 12),
          ),
          backgroundColor: Colors.black87,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    } else if (mounted) {
      // Revert if failed
      setState(() => _userRating = oldRating);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save rating.')),
      );
    }
  }

  // Helpers to extract data with fallbacks
  String get _name => _data?['name'] ?? widget.destinationName;
  String get _country => _data?['country'] ?? widget.destinationCountry;
  String get _description =>
      _data?['description'] ?? 'Explore this beautiful destination.';
  String? get _bestSeason => _data?['best_season'];
  int? get _minDays => _data?['ideal_duration_min_days'];
  int? get _maxDays => _data?['ideal_duration_max_days'];
  num? get _rating => _data?['rating'];
  int? get _reviewCount => _data?['review_count'];
  num? get _dailyCost => _data?['estimated_daily_cost_usd'];
  num? get _luxuryDailyCost => _data?['metadata']?['luxury_cost_inr'] ?? _data?['metadata']?['luxury_cost_usd'];
  String? get _imageUrl => _data?['image_url'];
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
      return '₹$total';
    }
    return '--';
  }

  String _parseWeatherCode(dynamic code) {
    if (code == null) return 'Unknown';
    final intCode = code is int ? code : int.tryParse(code.toString()) ?? -1;
    if (intCode == 0) return 'Clear';
    if (intCode >= 1 && intCode <= 3) return 'Cloudy';
    if (intCode == 45 || intCode == 48) return 'Fog';
    if (intCode >= 51 && intCode <= 57) return 'Drizzle';
    if (intCode >= 61 && intCode <= 67) return 'Rain';
    if (intCode >= 71 && intCode <= 77) return 'Snow';
    if (intCode >= 80 && intCode <= 82) return 'Showers';
    if (intCode >= 95) return 'Storm';
    return 'Clear';
  }

  Map<String, dynamic>? get _weatherData => _data?['metadata']?['weather'] ?? _weather;

  String get _weatherLabel {
    final weather = _weatherData;
    if (weather != null) {
      final current = weather['current'];
      if (current != null) {
        final temp = current['temperature_2m'];
        final code = current['weather_code'];
        return '${temp?.round() ?? '--'}°C, ${_parseWeatherCode(code)}';
      }
    }
    if (_bestSeason != null) {
      return _bestSeason!.contains('in') ? _bestSeason! : 'Best in $_bestSeason';
    }
    return '-- Season';
  }

  Future<void> _launchGoogleMaps() async {
    // Use name search for better "Human" results in Google Maps
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(_name)}');
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _showBudgetBreakdown() {
    final avgTotal = (_dailyCost ?? 0) * (_minDays ?? 7);
    final luxuryTotal = (_luxuryDailyCost ?? 0) * (_minDays ?? 7);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.85),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: Colors.white10),
          ),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'EXPERIENCE COST',
                style: TextStyle(
                  fontFamily: 'RobotoMono',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white60,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Estimates for ${_minDays ?? 7} days',
                style: const TextStyle(
                  fontFamily: 'RobotoMono',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              _buildCostRow(
                'Standard Discovery',
                '₹${avgTotal.round()}',
                'Covers local transport, mid-range dining, and top attractions.',
                Icons.travel_explore,
                Colors.blue,
              ),
              const SizedBox(height: 24),
              _buildCostRow(
                'Luxury Explorer',
                _luxuryDailyCost != null ? '₹${luxuryTotal.round()}' : 'Coming Soon',
                'Covers private transfers, fine dining, and exclusive experiences.',
                Icons.diamond_outlined,
                Colors.amber,
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                text: 'CLOSE',
                onPressed: () => Navigator.pop(context),
                showArrow: false,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showAttractionDetail(Map<String, dynamic> attraction) {
    if (attraction['name'] == '--') return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.85),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: Colors.white10),
          ),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (attraction['image_url'] != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: attraction['image_url'],
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 180,
                      color: Colors.white.withOpacity(0.05),
                      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      (attraction['category'] ?? 'SIGHTSEEING').toUpperCase(),
                      style: const TextStyle(
                        fontFamily: 'RobotoMono',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.blueAccent,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  if (attraction['typical_duration_hours'] != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      '• ${attraction['typical_duration_hours']} HOURS',
                      style: TextStyle(
                        fontFamily: 'RobotoMono',
                        fontSize: 10,
                        color: Colors.white.withOpacity(0.5),
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              Text(
                attraction['name'] ?? 'Unknown Attraction',
                style: const TextStyle(
                  fontFamily: 'RobotoMono',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              if (attraction['location_area'] != null)
                Text(
                  attraction['location_area'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              const SizedBox(height: 24),
              Text(
                attraction['description'] ?? 'No description available for this location.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white.withOpacity(0.8),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                text: 'CLOSE',
                onPressed: () => Navigator.pop(context),
                showArrow: false,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showAllAttractions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.9),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              border: Border.all(color: Colors.white10),
            ),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'EXPLORE ALL HIGHLIGHTS',
                  style: TextStyle(
                    fontFamily: 'RobotoMono',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white60,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: _attractions.length,
                    itemBuilder: (context, index) {
                      final attr = _attractions[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            _showAttractionDetail(attr);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: Row(
                              children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: attr['image_url'] != null
                                        ? CachedNetworkImage(
                                            imageUrl: attr['image_url'],
                                            fit: BoxFit.cover,
                                          )
                                        : const Icon(Icons.location_on, color: Colors.blueAccent),
                                  ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        attr['name'] ?? '',
                                        style: const TextStyle(
                                          fontFamily: 'RobotoMono',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        attr['category'] ?? 'Sightseeing',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white.withOpacity(0.4),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.2)),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCostRow(String title, String amount, String description, IconData icon, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'RobotoMono',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    amount,
                    style: TextStyle(
                      fontFamily: 'RobotoMono',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.5),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    if (_error != null && _data == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
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
      backgroundColor: Colors.black,
      body: RefreshIndicator(
        onRefresh: () => _fetchDetails(),
        color: Colors.white,
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
          // Hero image app bar
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: Colors.black,
            title: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _isCollapsed ? 1.0 : 0.0,
              child: Text(
                _name,
                style: const TextStyle(
                  fontFamily: 'RobotoMono',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            centerTitle: true,
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
                  if (_imageUrl != null && _imageUrl!.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: _imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey.shade800,
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey.shade900,
                        child: const Icon(Icons.broken_image,
                            size: 60, color: Colors.grey),
                      ),
                    )
                  else
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
                          Colors.black.withOpacity(0.1),
                          Colors.black.withOpacity(0.7),
                          Colors.black,
                        ],
                        stops: const [0.0, 0.5, 0.85, 1.0],
                      ),
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

                        const SizedBox(height: 4),
                        Row(
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
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.9),
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.star,
                                size: 16, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              _rating != null ? _rating.toString() : '--',
                              style: const TextStyle(
                                fontFamily: 'RobotoMono',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _reviewCount != null
                                  ? '(${_formatCount(_reviewCount!)} reviews)'
                                  : '(-- reviews)',
                              style: const TextStyle(
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
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick info chips
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _buildInfoChip(
                        Icons.wb_sunny_outlined,
                        _weatherLabel,
                        bgColor: WeatherThemeMapper.getTheme(_weatherData?['current']?['weather_code']).buttonBg,
                        accentColor: WeatherThemeMapper.getTheme(_weatherData?['current']?['weather_code']).accentColor,
                        heroTag: 'weather-hero-${_data?['id']}',
                        onTap: () {
                          final weather = _weatherData;
                          if (weather != null) {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                opaque: false,
                                barrierDismissible: true,
                                transitionDuration: const Duration(milliseconds: 700),
                                reverseTransitionDuration: const Duration(milliseconds: 250),
                                pageBuilder: (context, animation, secondaryAnimation) => WeatherPopup(
                                  locationName: _name,
                                  weatherData: weather,
                                  heroTag: 'weather-hero-${_data?['id']}',
                                ),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  final curve = animation.status == AnimationStatus.forward
                                      ? Curves.easeOutBack
                                      : Curves.easeInBack;
                                  
                                  return ScaleTransition(
                                    scale: CurvedAnimation(
                                      parent: animation,
                                      curve: curve,
                                    ),
                                    child: FadeTransition(
                                      opacity: CurvedAnimation(
                                        parent: animation,
                                        curve: const Interval(0.0, 0.7, curve: Curves.linear),
                                      ),
                                      child: child,
                                    ),
                                  );
                                },
                              ),
                            );
                          }
                        },
                      ),
                      _buildInfoChip(
                        Icons.schedule,
                        _durationLabel.isNotEmpty ? _durationLabel : '-- Days',
                      ),
                      _buildInfoChip(
                        Icons.attach_money,
                        _dailyCost != null
                            ? 'EST. ₹${(_dailyCost!.round() * (_minDays ?? 7))}'
                            : '--/day',
                        onTap: _showBudgetBreakdown,
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // What to expect
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'What to expect',
                        style: TextStyle(
                          fontFamily: 'RobotoMono',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => DestinationChatSheet(
                              cityName: _name,
                              countryName: _country,
                              description: _description,
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.amber.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.auto_awesome, color: Colors.amber, size: 14),
                              const SizedBox(width: 6),
                              Text(
                                'Ask Itinera',
                                style: TextStyle(
                                  fontFamily: 'RobotoMono',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.amber.shade200,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Text(
                    _description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Interactive Rating Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.06)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _userRating != null ? 'YOUR RATING' : 'RATE THIS PLACE',
                              style: TextStyle(
                                fontFamily: 'RobotoMono',
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white.withOpacity(0.4),
                                letterSpacing: 2,
                              ),
                            ),
                            if (_userRating != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.greenAccent.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'SAVED',
                                  style: TextStyle(fontSize: 9, color: Colors.greenAccent, fontWeight: FontWeight.bold),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        RatingStars(
                          initialRating: _userRating ?? 0,
                          onRatingChanged: _handleRate,
                          starSize: 32,
                          alignment: MainAxisAlignment.start,
                        ),
                        if (_userRating == null) ...[
                          const SizedBox(height: 12),
                          Text(
                            'Tap a star to share your experience.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

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
                          color: Colors.white,
                        ),
                      ),
                      TextButton(
                        onPressed: _showAllAttractions,
                        child: const Text(
                          'See all',
                          style: TextStyle(
                            fontFamily: 'RobotoMono',
                            fontSize: 13,
                            color: Colors.white60,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Attractions grid — show up to 4 in 2x2
                  _buildAttractionsGrid(),

                  const SizedBox(height: 32),

                  // Location
                  const Text(
                    'Location',
                    style: TextStyle(
                      fontFamily: 'RobotoMono',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Aerial Visual Card (Map)
                  GestureDetector(
                    onTap: _launchGoogleMaps,
                    child: Container(
                      height: 350,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade900,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CachedNetworkImage(
                              imageUrl: 'https://api.maptiler.com/maps/basic-v2/static/${widget.longitude ?? _data?['longitude'] ?? 73.8567},${widget.latitude ?? _data?['latitude'] ?? 18.5204},12/600x400@2x.png?key=GfuxUc0Qb7MFssVNEWXu&markers=${widget.longitude ?? _data?['longitude'] ?? 73.8567},${widget.latitude ?? _data?['latitude'] ?? 18.5204}',
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(color: Colors.grey.shade900, child: const Center(child: CircularProgressIndicator())),
                              errorWidget: (context, url, error) => CachedNetworkImage(
                                imageUrl: 'https://maps.googleapis.com/maps/api/staticmap?center=${widget.latitude ?? _data?['latitude'] ?? 18.5204},${widget.longitude ?? _data?['longitude'] ?? 73.8567}&zoom=13&size=600x400',
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) => CachedNetworkImage(
                                  imageUrl: 'https://static-maps.yandex.ru/1.x/?lang=en_US&ll=${widget.longitude ?? _data?['longitude'] ?? 73.8567},${widget.latitude ?? _data?['latitude'] ?? 18.5204}&size=600,400&z=12&l=map&pt=${widget.longitude ?? _data?['longitude'] ?? 73.8567},${widget.latitude ?? _data?['latitude'] ?? 18.5204},pmwtm1',
                                  fit: BoxFit.cover,
                                  errorWidget: (context, url, error) => Container(
                                    color: const Color(0xFF0F0F0F),
                                    child: Stack(
                                      children: [
                                        CustomPaint(
                                          painter: GridPainter(
                                            gridColor: Colors.white.withOpacity(0.03),
                                            spacing: 30,
                                          ),
                                          size: Size.infinite,
                                        ),
                                        Center(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.map_outlined, color: Colors.white.withOpacity(0.1), size: 48),
                                              const SizedBox(height: 12),
                                              Text(
                                                'MAP VISUAL UNAVAILABLE',
                                                style: TextStyle(
                                                  fontFamily: 'RobotoMono',
                                                  fontSize: 10,
                                                  color: Colors.white.withOpacity(0.2),
                                                  letterSpacing: 2,
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
                            ),
                            // Dark Navigation Badge
                            Positioned(
                              right: 20,
                              bottom: 20,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.4),
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      'assets/map_16509523.png',
                                      width: 20,
                                      height: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'GOOGLE MAPS',
                                      style: TextStyle(
                                        fontFamily: 'RobotoMono',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Discovery Overlay
                            Positioned(
                              left: 20,
                              top: 20,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _name.toUpperCase(),
                                    style: TextStyle(
                                      fontFamily: 'RobotoMono',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.black.withOpacity(0.8),
                                      letterSpacing: 2,
                                    ),
                                  ),
                                  Text(
                                    'TAP TO EXPLORE CITY',
                                    style: TextStyle(
                                      fontFamily: 'RobotoMono',
                                      fontSize: 10,
                                      color: Colors.black.withOpacity(0.5),
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 2,
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
                ],
              ),
            ),
          ),
        ],
      ),
          // Progressive fade at the bottom matching the top gradient
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 60,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.1),
                      Colors.black.withOpacity(0.7),
                      Colors.black,
                    ],
                    stops: const [0.0, 0.5, 0.85, 1.0],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),

      // Bottom bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.black,
          border: Border(top: BorderSide(color: Colors.white10)),
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
                      color: Colors.white60,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    _costLabel,
                    style: const TextStyle(
                      fontFamily: 'RobotoMono',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(
                child: PrimaryButton(
                  text: 'Plan this trip',
                  onPressed: () {
                    final destId = _data?['id'];
                    if (destId != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TimelineSelectorScreen(
                            destinationId: destId,
                            destinationName: _name,
                            dailyCost: _dailyCost?.toDouble(),
                            luxuryDailyCost: _luxuryDailyCost?.toDouble(),
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Destination data not fully loaded')),
                      );
                    }
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
    final toShow = _attractions.isNotEmpty
        ? _attractions.take(4).toList()
        : [
            {'name': '--', 'location_area': '--'},
            {'name': '--', 'location_area': '--'},
            {'name': '--', 'location_area': '--'},
            {'name': '--', 'location_area': '--'},
          ];
    final rows = <Widget>[];

    for (var i = 0; i < toShow.length; i += 2) {
      final row = Row(
        children: [
          Expanded(
            child: _buildAttractionCard(toShow[i]),
          ),
          const SizedBox(width: 12),
          if (i + 1 < toShow.length)
            Expanded(
              child: _buildAttractionCard(toShow[i + 1]),
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

  Widget _buildInfoChip(IconData icon, String label, {VoidCallback? onTap, String? heroTag, Color? bgColor, Color? accentColor}) {
    final effectiveBg = bgColor ?? (onTap != null ? Colors.blue.withOpacity(0.2) : Colors.white.withOpacity(0.1));
    final effectiveAccent = accentColor ?? (onTap != null ? Colors.blue.shade200 : Colors.white70);
    final effectiveText = accentColor != null ? accentColor.withOpacity(0.8) : (onTap != null ? Colors.blue.shade100 : Colors.white70);

    Widget chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: effectiveBg.withOpacity(0.3),
        ),
        boxShadow: onTap != null ? [
          BoxShadow(
            color: effectiveBg.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 1,
          )
        ] : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: effectiveAccent),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'RobotoMono',
              fontSize: 12,
              color: effectiveText,
              fontWeight: onTap != null ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );

    if (heroTag != null) {
      chip = Hero(
        tag: heroTag,
        placeholderBuilder: (context, size, widget) => widget,
        flightShuttleBuilder: (flightContext, animation, flightDirection, fromHeroContext, toHeroContext) {
          return toHeroContext.widget;
        },
        child: Material(color: Colors.transparent, child: chip),
      );
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: chip,
      );
    }
    return chip;
  }

  Widget _buildAttractionCard(Map<String, dynamic> attraction) {
    final title = attraction['name'] ?? '';
    final location = attraction['location_area'] ?? '';
    final imageUrl = attraction['image_url'];

    // Generate a beautiful fallback gradient based on title length/hash
    final colors = [
      [Colors.blue.shade800, Colors.purple.shade800],
      [Colors.teal.shade800, Colors.blue.shade800],
      [Colors.indigo.shade800, Colors.deepPurple.shade800],
      [Colors.orange.shade800, Colors.red.shade800],
    ];
    final colorPair = colors[title.length % colors.length];

    return GestureDetector(
      onTap: () => _showAttractionDetail(attraction),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imageUrl != null && imageUrl.isNotEmpty)
              CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: colorPair[0]),
                errorWidget: (context, url, error) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: colorPair,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: colorPair,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child:
                    const Icon(Icons.landscape, color: Colors.white24, size: 40),
              ),
            // Gradient overlay for text readability
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
            ),
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

class GridPainter extends CustomPainter {
  final Color gridColor;
  final double spacing;

  GridPainter({required this.gridColor, required this.spacing});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.0;

    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
