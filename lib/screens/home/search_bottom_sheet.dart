import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/destination_service.dart';
import '../../widgets/overlays/loading_buffer_screen.dart';

/// Search Bottom Sheet - Modal for searching destinations with live Nominatim search
class SearchBottomSheet extends StatefulWidget {
  const SearchBottomSheet({super.key});

  @override
  State<SearchBottomSheet> createState() => _SearchBottomSheetState();
}

class _SearchBottomSheetState extends State<SearchBottomSheet> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  List<Map<String, dynamic>> _results = [];
  List<String> _recentSearches = [];
  bool _isSearching = false;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRecentSearches() async {
    final recents = await DestinationService.getRecentSearches();
    if (mounted) {
      setState(() => _recentSearches = recents);
    }
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.trim().length < 2) {
      setState(() {
        _results = [];
        _hasSearched = false;
        _isSearching = false;
      });
      return;
    }
    setState(() => _isSearching = true);
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    final results = await DestinationService.searchDestinations(query);
    if (mounted) {
      setState(() {
        _results = results;
        _isSearching = false;
        _hasSearched = true;
      });
    }
  }

  void _navigateToDestination(String name, String country, {double? lat, double? lon}) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoadingBufferScreen(
          destinationName: name,
          destinationCountry: country,
          latitude: lat,
          longitude: lon,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 20),

          // Search field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search destinations...',
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey.shade500,
                ),
                suffixIcon: _isSearching
                    ? const Padding(
                        padding: EdgeInsets.all(14),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : _searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                            icon: Icon(
                              Icons.close,
                              color: Colors.grey.shade500,
                              size: 20,
                            ),
                          )
                        : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Content
          Expanded(
            child: _hasSearched ? _buildSearchResults() : _buildDefaultContent(),
          ),
        ],
      ),
    );
  }

  /// Search results list
  Widget _buildSearchResults() {
    if (_results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 40, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'No destinations found',
              style: TextStyle(
                fontFamily: 'RobotoMono',
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final item = _results[index];
        final name = item['name'] ?? '';
        final country = item['country'] ?? '';
        final isCached = item['source'] == 'cached';
        final rating = item['rating'];

        return _buildResultItem(
          name: name,
          country: country,
          isCached: isCached,
          rating: rating?.toString(),
          onTap: () => _navigateToDestination(
            name,
            country,
            lat: item['lat'] != null ? (item['lat'] is int ? (item['lat'] as int).toDouble() : item['lat']) : item['latitude'],
            lon: item['lon'] != null ? (item['lon'] is int ? (item['lon'] as int).toDouble() : item['lon']) : item['longitude'],
          ),
        );
      },
    );
  }

  /// Default content: recent searches + suggestions
  Widget _buildDefaultContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent searches
          if (_recentSearches.isNotEmpty) ...[
            Text(
              'RECENT',
              style: TextStyle(
                fontFamily: 'RobotoMono',
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            ..._recentSearches.map((query) => _buildRecentItem(query)),
            const SizedBox(height: 24),
          ],

          // Suggested
          Text(
            'SUGGESTED',
            style: TextStyle(
              fontFamily: 'RobotoMono',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          _buildSuggestionItem(
            icon: Icons.place,
            title: 'Tokyo',
            subtitle: 'Culture, food & technology',
            onTap: () => _navigateToDestination('Tokyo', 'Japan'),
          ),
          _buildSuggestionItem(
            icon: Icons.place,
            title: 'Kyoto',
            subtitle: 'Ancient temples & autumn foliage',
            onTap: () => _navigateToDestination('Kyoto', 'Japan'),
          ),
          _buildSuggestionItem(
            icon: Icons.place,
            title: 'Paris',
            subtitle: 'Culture, art & romantic streets',
            onTap: () => _navigateToDestination('Paris', 'France'),
          ),
          _buildSuggestionItem(
            icon: Icons.place,
            title: 'Bali',
            subtitle: 'Beaches, nature & relaxation',
            onTap: () => _navigateToDestination('Bali', 'Indonesia'),
          ),
        ],
      ),
    );
  }

  Widget _buildResultItem({
    required String name,
    required String country,
    required bool isCached,
    String? rating,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isCached ? Colors.black : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isCached ? Icons.star_rounded : Icons.place,
                size: 20,
                color: isCached ? Colors.white : Colors.grey.shade700,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontFamily: 'RobotoMono',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    country,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (rating != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, size: 14, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    rating,
                    style: TextStyle(
                      fontFamily: 'RobotoMono',
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentItem(String query) {
    return InkWell(
      onTap: () {
        _searchController.text = query;
        _onSearchChanged(query);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(Icons.history, size: 18, color: Colors.grey.shade500),
            const SizedBox(width: 12),
            Text(
              query,
              style: TextStyle(
                fontFamily: 'RobotoMono',
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 20,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'RobotoMono',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
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
}
