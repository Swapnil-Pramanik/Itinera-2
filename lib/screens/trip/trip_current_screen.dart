import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/trip_service.dart';
import '../../core/destination_service.dart';
import '../../widgets/common/common.dart';
import '../../widgets/buttons/buttons.dart';
import '../../widgets/overlays/destination_chat_sheet.dart';
import '../../widgets/overlays/weather_popup.dart';
import '../../widgets/overlays/weather_theme.dart';

/// Trip Current Screen - Active trip dashboard with "Now" focus (Dark Theme)
class TripCurrentScreen extends StatefulWidget {
  final String tripId;
  const TripCurrentScreen({super.key, required this.tripId});

  @override
  State<TripCurrentScreen> createState() => _TripCurrentScreenState();
}

class _TripCurrentScreenState extends State<TripCurrentScreen> {
  Map<String, dynamic>? _trip;
  List<Map<String, dynamic>> _itinerary = [];
  Map<String, dynamic>? _weatherData;
  final Set<String> _completedActivities = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchTripData();
  }

  Future<void> _fetchTripData() async {
    try {
      final tripData = await TripService.getTripById(widget.tripId);
      final itineraryData = await TripService.getTripDays(widget.tripId);

      if (mounted) {
        setState(() {
          _trip = tripData;
          _itinerary = itineraryData;
          _isLoading = false;
          if (_trip == null) _error = 'Trip not found';
        });
      }

      // Fetch weather if location is available
      if (tripData != null && tripData['destinations'] != null) {
        final dest = tripData['destinations'];
        final lat = dest['latitude'];
        final lon = dest['longitude'];
        if (lat != null && lon != null) {
          final weather = await DestinationService.getLocalWeather(
            (lat as num).toDouble(),
            (lon as num).toDouble(),
          );
          if (mounted && weather != null) {
            setState(() {
              _weatherData = weather;
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Failed to load trip: $e';
        });
      }
    }
  }

  // Helpers
  String get _title => _trip?['destinations']?['name'] ?? _trip?['title'] ?? 'CURRENT TRIP';
  String get _country => _trip?['destinations']?['country'] ?? '';
  String? get _imageUrl => _trip?['destinations']?['image_url'];

  int get _currentDayNumber {
    if (_trip?['start_date'] == null) return 1;
    final start = DateTime.tryParse(_trip!['start_date']);
    if (start == null) return 1;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diff = today.difference(start).inDays;
    return (diff + 1).clamp(1, _itinerary.length.clamp(1, 100));
  }

  Map<String, dynamic>? get _currentDayData {
    if (_itinerary.isEmpty) return null;
    final dayNum = _currentDayNumber;
    return _itinerary.firstWhere(
      (d) => d['day_number'] == dayNum,
      orElse: () => _itinerary.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF121212),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF121212),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 16),
              PrimaryButton(text: 'RETRY', onPressed: _fetchTripData),
            ],
          ),
        ),
      );
    }

    final dayData = _currentDayData;
    final activities = (dayData?['activities'] as List? ?? []);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: CustomScrollView(
        slivers: [
          // Cinematic Header
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: const Color(0xFF121212),
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (_imageUrl != null)
                    CachedNetworkImage(
                      imageUrl: _imageUrl!,
                      fit: BoxFit.cover,
                    )
                  else
                    Container(color: Colors.grey.shade900),
                  
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.4),
                          const Color(0xFF121212),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: 30,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 14, color: Colors.redAccent),
                            const SizedBox(width: 4),
                            Text(
                              '$_title, $_country'.toUpperCase(),
                              style: const TextStyle(
                                fontFamily: 'RobotoMono',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'DAY $_currentDayNumber: ${dayData?['day_title'] ?? 'EXPLORATION'}',
                          style: const TextStyle(
                            fontFamily: 'RobotoMono',
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Action Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Indicators
                  Row(
                    children: [
                      _buildStatusPulse(),
                      const SizedBox(width: 8),
                      const Text(
                        'LIVE UPDATES',
                        style: TextStyle(
                          fontFamily: 'RobotoMono',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      if (_weatherData != null) _buildWeatherBadge(),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Aerial Visual Card (Map)
                  GestureDetector(
                    onTap: () async {
                      final dests = _trip?['destinations'];
                      if (dests != null) {
                        final lat = dests['latitude'];
                        final lon = dests['longitude'];
                        if (lat != null && lon != null) {
                          final mapUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lon');
                          if (await canLaunchUrl(mapUrl)) {
                            await launchUrl(mapUrl);
                          }
                        }
                      }
                    },
                    child: Container(
                      height: 250,
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
                              imageUrl: 'https://api.maptiler.com/maps/basic-v2/static/${_trip?['destinations']?['longitude'] ?? 73.8567},${_trip?['destinations']?['latitude'] ?? 18.5204},12/600x400@2x.png?key=GfuxUc0Qb7MFssVNEWXu&markers=${_trip?['destinations']?['longitude'] ?? 73.8567},${_trip?['destinations']?['latitude'] ?? 18.5204}',
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(color: Colors.grey.shade900, child: const Center(child: CircularProgressIndicator())),
                              errorWidget: (context, url, error) => CachedNetworkImage(
                                imageUrl: 'https://maps.googleapis.com/maps/api/staticmap?center=${_trip?['destinations']?['latitude'] ?? 18.5204},${_trip?['destinations']?['longitude'] ?? 73.8567}&zoom=13&size=600x400',
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) => CachedNetworkImage(
                                  imageUrl: 'https://static-maps.yandex.ru/1.x/?lang=en_US&ll=${_trip?['destinations']?['longitude'] ?? 73.8567},${_trip?['destinations']?['latitude'] ?? 18.5204}&size=600,400&z=12&l=map&pt=${_trip?['destinations']?['longitude'] ?? 73.8567},${_trip?['destinations']?['latitude'] ?? 18.5204},pmwtm1',
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
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset(
                                      'assets/map_16509523.png',
                                      width: 16,
                                      height: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'GOOGLE MAPS',
                                      style: TextStyle(
                                        fontFamily: 'RobotoMono',
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Timeline Section
                  Text(
                    'COMING UP NEXT',
                    style: TextStyle(
                      fontFamily: 'RobotoMono',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withOpacity(0.4),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (activities.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text('Relax and enjoy the day!', style: TextStyle(color: Colors.white.withOpacity(0.3))),
                    )
                  else
                    ...activities.map((act) => _buildLiveActivityCard(act)),

                  const SizedBox(height: 24),

                  // AI Input - The common AiInputBar already has some white background, but I'll make it fit
                  AiInputBar(
                    hintText: 'Ask Itinera to find food nearby...',
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => DestinationChatSheet(
                          cityName: _title,
                          countryName: _country,
                          description: _trip?['notes'] ?? '',
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPulse() {
    return Container(
      width: 10,
      height: 10,
      decoration: const BoxDecoration(
        color: Colors.redAccent,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.redAccent, blurRadius: 4, spreadRadius: 1),
        ],
      ),
    );
  }

  Widget _buildWeatherBadge() {
    final current = _weatherData!['current'];
    final code = current?['weather_code'];
    final temp = current?['temperature_2m']?.round()?.toString() ?? '--';
    
    final theme = WeatherThemeMapper.getTheme(code);
    final heroTag = 'trip-weather-hero';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            opaque: false,
            barrierDismissible: true,
            transitionDuration: const Duration(milliseconds: 700),
            reverseTransitionDuration: const Duration(milliseconds: 250),
            pageBuilder: (context, animation, secondaryAnimation) => WeatherPopup(
              locationName: _title,
              weatherData: _weatherData!,
              heroTag: heroTag,
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return ScaleTransition(
                scale: CurvedAnimation(
                  parent: animation,
                  curve: animation.status == AnimationStatus.forward
                      ? Curves.easeOutBack
                      : Curves.easeInBack,
                ),
                child: child,
              );
            },
          ),
        );
      },
      child: Hero(
        tag: heroTag,
        placeholderBuilder: (context, size, widget) => widget,
        flightShuttleBuilder: (flightContext, animation, flightDirection, fromHeroContext, toHeroContext) {
          return toHeroContext.widget;
        },
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: theme.cardGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: theme.cardGradient.last.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(theme.icon, size: 16, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  '$temp°C',
                  style: const TextStyle(
                    fontFamily: 'RobotoMono',
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLiveActivityCard(Map<String, dynamic> activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                activity['time'] ?? 'NOW',
                style: const TextStyle(
                  fontFamily: 'RobotoMono',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Icon(Icons.arrow_downward, size: 12, color: Colors.white.withOpacity(0.3)),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (activity['type'] ?? 'VISIT').toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'RobotoMono',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent.shade100,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  activity['title'] ?? 'Activity',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity['description'] ?? 'Enjoy your time here.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: () {
              setState(() {
                final activityId = activity['title'] ?? activity.hashCode.toString();
                if (_completedActivities.contains(activityId)) {
                  _completedActivities.remove(activityId);
                } else {
                  _completedActivities.add(activityId);
                }
              });
            },
            icon: Icon(
              Icons.check_circle_outline,
              color: _completedActivities.contains(activity['title'] ?? activity.hashCode.toString())
                  ? Colors.greenAccent
                  : Colors.white.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }
}
