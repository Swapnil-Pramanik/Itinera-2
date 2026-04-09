import 'package:flutter/material.dart';
import '../../core/trip_service.dart';
import '../../widgets/buttons/buttons.dart';
import '../../widgets/common/common.dart';

/// Trip Checklist Screen - Functional Pre-trip preparation checklist (Dark Theme)
class TripChecklistScreen extends StatefulWidget {
  final String tripId;
  const TripChecklistScreen({super.key, required this.tripId});

  @override
  State<TripChecklistScreen> createState() => _TripChecklistScreenState();
}

class _TripChecklistScreenState extends State<TripChecklistScreen> {
  List<Map<String, dynamic>> _checklistItems = [];
  bool _isLoading = true;
  bool _isGenerating = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchChecklist();
  }

  Future<void> _fetchChecklist() async {
    try {
      final items = await TripService.getChecklist(widget.tripId);
      if (mounted) {
        setState(() {
          _checklistItems = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load checklist: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _generateSmartChecklist() async {
    setState(() => _isGenerating = true);
    try {
      await TripService.generateChecklist(widget.tripId);
      await _fetchChecklist();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Generation failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  Future<void> _toggleItem(String itemId, bool isCompleted) async {
    setState(() {
      final idx = _checklistItems.indexWhere((item) => item['id'] == itemId);
      if (idx != -1) {
        _checklistItems[idx]['is_completed'] = isCompleted;
      }
    });

    final success = await TripService.toggleChecklistItem(itemId, isCompleted);
    if (!success) {
      _fetchChecklist();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update item')),
        );
      }
    }
  }

  Future<void> _addItem() async {
    String label = '';
    String selectedCategory = 'ESSENTIALS';
    final categories = ['TRAVEL', 'STAY', 'ESSENTIALS', 'DOCUMENTS', 'HEALTH'];

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ADD CHECKLIST ITEM',
                  style: TextStyle(
                    fontFamily: 'RobotoMono',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Text Field
                TextField(
                  autofocus: true,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  cursorColor: Colors.amber,
                  decoration: InputDecoration(
                    hintText: 'e.g., Buy extra batteries',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.amber.withOpacity(0.5)),
                    ),
                  ),
                  onChanged: (val) => label = val,
                ),
                
                const SizedBox(height: 24),
                
                const Text(
                  'CATEGORY',
                  style: TextStyle(
                    fontFamily: 'RobotoMono',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white38,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Chip Selection
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: categories.map((cat) {
                    final isSelected = selectedCategory == cat;
                    return GestureDetector(
                      onTap: () => setDialogState(() => selectedCategory = cat),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.amber : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? Colors.amber : Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            fontFamily: 'RobotoMono',
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.black : Colors.white60,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 32),
                
                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(
                        'CANCEL',
                        style: TextStyle(
                          fontFamily: 'RobotoMono',
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text(
                        'ADD',
                        style: TextStyle(fontFamily: 'RobotoMono', fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (result == true && label.isNotEmpty) {
      setState(() => _isLoading = true);
      await TripService.addChecklistItem(widget.tripId, label, selectedCategory);
      await _fetchChecklist();
    }
  }

  Future<void> _removeItem(String itemId) async {
    setState(() {
      _checklistItems.removeWhere((item) => item['id'] == itemId);
    });
    final success = await TripService.removeChecklistItem(itemId);
    if (!success) {
      _fetchChecklist();
    }
  }

  int get _completedCount => _checklistItems.where((item) => item['is_completed'] == true).length;
  double get _progress => _checklistItems.isEmpty ? 0 : _completedCount / _checklistItems.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text(
          'PRE-TRIP CHECKLIST',
          style: TextStyle(
            fontFamily: 'RobotoMono',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _isGenerating ? null : _generateSmartChecklist,
            icon: _isGenerating 
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.amber))
              : const Icon(Icons.auto_awesome, color: Colors.amber, size: 20),
            tooltip: 'Regenerate Smart Checklist',
          ),
          IconButton(
            onPressed: _addItem,
            icon: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.white))
        : _error != null
          ? Center(child: Text(_error!, style: const TextStyle(color: Colors.white70)))
          : Column(
              children: [
                // Progress indicator
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$_completedCount/${_checklistItems.length} COMPLETED',
                            style: const TextStyle(
                              fontFamily: 'RobotoMono',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            '${(_progress * 100).round()}%',
                            style: TextStyle(
                              fontFamily: 'RobotoMono',
                              fontSize: 12,
                              color: Colors.greenAccent.shade400,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _progress,
                          backgroundColor: Colors.white.withOpacity(0.05),
                          color: Colors.greenAccent,
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
                // Checklist items
                Expanded(
                  child: _checklistItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('No items yet', style: TextStyle(color: Colors.white24)),
                            const SizedBox(height: 16),
                            PrimaryButton(
                              text: 'GENERATE SMART LIST',
                              width: 200,
                              height: 48,
                              onPressed: _generateSmartChecklist,
                            ),
                          ],
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        children: _buildGroupedItems(),
                      ),
                ),
                // Done button
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: SecondaryButton(
                    text: 'BACK TO HOME',
                    onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                  ),
                ),
              ],
            ),
    );
  }

  List<Widget> _buildGroupedItems() {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var item in _checklistItems) {
      final cat = item['category'] ?? 'OTHER';
      grouped.putIfAbsent(cat, () => []).add(item);
    }

    final List<Widget> widgets = [];
    grouped.forEach((category, items) {
      widgets.add(Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 8),
        child: Text(
          category.toUpperCase(),
          style: TextStyle(
            fontFamily: 'RobotoMono',
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.white.withOpacity(0.35),
            letterSpacing: 1.5,
          ),
        ),
      ));
      
      for (var item in items) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Expanded(
                child: ChecklistItem(
                  label: item['label'] ?? '',
                  isChecked: item['is_completed'] ?? false,
                  onChanged: (val) => _toggleItem(item['id'], val),
                ),
              ),
              IconButton(
                onPressed: () => _removeItem(item['id']),
                icon: Icon(Icons.close, size: 16, color: Colors.white.withOpacity(0.1)),
              ),
            ],
          ),
        ));
      }
      widgets.add(const SizedBox(height: 16));
    });

    return widgets;
  }
}
