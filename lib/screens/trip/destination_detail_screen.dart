import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/destination_service.dart';
import '../../widgets/buttons/buttons.dart';
import '../../widgets/overlays/weather_popup.dart';
import '../../widgets/overlays/weather_theme.dart';
import '../timeline/timeline_selector_screen.dart';

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
  String get _description =>
      _data?['description'] ?? 'Explore this beautiful destination.';
  String? get _bestSeason => _data?['best_season'];
  int? get _minDays => _data?['ideal_duration_min_days'];
  int? get _maxDays => _data?['ideal_duration_max_days'];
  num? get _rating => _data?['rating'];
  int? get _reviewCount => _data?['review_count'];
  num? get _dailyCost => _data?['estimated_daily_cost_usd'];
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
      return '\$$total';
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
      body: Stack(
        children: [
          CustomScrollView(
        controller: _scrollController,
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
                            ? '\$${_dailyCost!.round()}/day'
                            : '--/day',
                      ),
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
                      color: Colors.white,
                    ),
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
                          color: Colors.white,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
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
                                  errorWidget: (context, url, error) => CachedNetworkImage(
                                    imageUrl: 'https://images.unsplash.com/photo-1542296332-2e4473faf563?q=80&w=2070&auto=format&fit=crop', // High-fidelity aerial city fallback
                                    fit: BoxFit.cover,
                                    color: Colors.black.withOpacity(0.4),
                                    colorBlendMode: BlendMode.darken,
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
            child: _buildAttractionCard(
              toShow[i]['name'] ?? '',
              toShow[i]['location_area'] ?? '',
              toShow[i]['image_url'],
            ),
          ),
          const SizedBox(width: 12),
          if (i + 1 < toShow.length)
            Expanded(
              child: _buildAttractionCard(
                toShow[i + 1]['name'] ?? '',
                toShow[i + 1]['location_area'] ?? '',
                toShow[i + 1]['image_url'],
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
          return SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: toHeroContext.widget,
          );
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

  Widget _buildAttractionCard(String title, String location, String? imageUrl) {
    // Generate a beautiful fallback gradient based on title length/hash
    final colors = [
      [Colors.blue.shade800, Colors.purple.shade800],
      [Colors.teal.shade800, Colors.blue.shade800],
      [Colors.indigo.shade800, Colors.deepPurple.shade800],
      [Colors.orange.shade800, Colors.red.shade800],
    ];
    final colorPair = colors[title.length % colors.length];

    return Container(
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
    );
  }

  String _formatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(0)}k';
    }
    return count.toString();
  }
}
