import 'package:flutter/material.dart';
import 'dart:ui';
import '../../core/destination_service.dart';

/// Premium brand-themed chat bottom sheet for destination Q&A.
class DestinationChatSheet extends StatefulWidget {
  final String cityName;
  final String countryName;
  final String description;

  const DestinationChatSheet({
    super.key,
    required this.cityName,
    required this.countryName,
    this.description = '',
  });

  @override
  State<DestinationChatSheet> createState() => _DestinationChatSheetState();
}

class _DestinationChatSheetState extends State<DestinationChatSheet>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final List<_ChatMessage> _messages = [];
  bool _isTyping = false;

  late AnimationController _dotAnimController;

  @override
  void initState() {
    super.initState();
    _dotAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _messages.add(_ChatMessage(
      role: 'assistant',
      content:
          "Hey! I'm Itinera, your personal guide for ${widget.cityName}. Ask me about food, safety, transport, or budget tips!",
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _dotAnimController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isTyping) return;

    _controller.clear();
    setState(() {
      _messages.add(_ChatMessage(role: 'user', content: text));
      _isTyping = true;
    });
    _scrollToBottom();

    final history = _messages
        .where((m) => m != _messages.first || m.role == 'user')
        .map((m) => {'role': m.role, 'content': m.content})
        .toList();

    if (history.isNotEmpty) history.removeLast();

    final responseMsg = _ChatMessage(role: 'assistant', content: '');
    bool firstTokenReceived = false;

    try {
      await for (final chunk in DestinationService.streamChatWithDestination(
        city: widget.cityName,
        country: widget.countryName,
        message: text,
        description: widget.description,
        history: history,
      )) {
        if (!mounted) break;
        
        setState(() {
          if (!firstTokenReceived) {
             _isTyping = false;
             _messages.add(responseMsg);
             firstTokenReceived = true;
          }
          responseMsg.content += chunk;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTyping = false;
          if (!firstTokenReceived) {
             _messages.add(responseMsg);
          }
          responseMsg.content = "Connection lost. Please try again later.";
        });
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -4),
            blurRadius: 20,
          )
        ],
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 48,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 16, 12),
            child: Row(
              children: [
                // Minimal logo handling
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/logo_black.png',
                    width: 20,
                    height: 20,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        child: Text(
                          widget.cityName.toUpperCase(),
                          style: const TextStyle(
                            fontFamily: 'RobotoMono',
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white, // Required for shader
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.bolt, size: 12, color: Color(0xFF6B6B6B)),
                          const SizedBox(width: 2),
                          Text(
                            'Powered by Itinera AI',
                            style: TextStyle(
                              fontFamily: 'RobotoMono',
                              fontSize: 11,
                              color: const Color(0xFF6B6B6B),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: Colors.black54, size: 24),
                ),
              ],
            ),
          ),

          Divider(color: Colors.grey.shade200, height: 1),

          // Messages list
          Expanded(
            child: Container(
              color: const Color(0xFFFDFDFD),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (_isTyping && index == _messages.length) {
                    return _buildTypingIndicator();
                  }
                  return _buildMessageBubble(_messages[index]);
                },
              ),
            ),
          ),

          // Suggestion chips
          if (_messages.length == 1)
            Container(
              color: const Color(0xFFFDFDFD),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    _buildSuggestionChip('🍜 Best local food?'),
                    _buildSuggestionChip('🔒 Is it safe?'),
                    _buildSuggestionChip('🚕 Getting around?'),
                    _buildSuggestionChip('💰 Budget tips?'),
                  ],
                ),
              ),
            ),

          // Input bar
          Container(
            padding: EdgeInsets.fromLTRB(20, 16, 12, 16 + bottomInset),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  offset: const Offset(0, -4),
                  blurRadius: 16,
                )
              ]
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F7),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      style: const TextStyle(
                        fontFamily: 'System', // system font for standard clarity
                        color: Colors.black87,
                        fontSize: 15,
                        height: 1.3,
                      ),
                      maxLines: 4,
                      minLines: 1,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Ask anything...',
                        hintStyle: TextStyle(
                          fontFamily: 'RobotoMono',
                          color: Colors.grey.shade500,
                          fontSize: 14,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _isTyping ? null : _sendMessage,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: _isTyping ? null : const LinearGradient(
                        colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      color: _isTyping ? Colors.grey.shade200 : null,
                      shape: BoxShape.circle,
                      boxShadow: _isTyping ? [] : [
                        BoxShadow(
                          color: const Color(0xFF1E3C72).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Icon(
                      Icons.arrow_upward_rounded,
                      color: _isTyping ? Colors.grey.shade400 : Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(_ChatMessage message) {
    final isUser = message.role == 'user';

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2))
                ]
              ),
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Image.asset('assets/images/logo_black.png', fit: BoxFit.contain),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: isUser ? const Color(0xFF1A1A2E) : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(24),
                  topRight: const Radius.circular(24),
                  bottomLeft: Radius.circular(isUser ? 24 : 8),
                  bottomRight: Radius.circular(isUser ? 8 : 24),
                ),
                border: isUser ? null : Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isUser ? 0.08 : 0.02),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  fontFamily: isUser ? 'System' : 'RobotoMono',
                  fontSize: isUser ? 15 : 14,
                  fontWeight: isUser ? FontWeight.w400 : FontWeight.w500,
                  color: isUser ? Colors.white : const Color(0xFF2D2D2D),
                  height: 1.6,
                  letterSpacing: isUser ? 0 : 0.2,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Image.asset('assets/images/logo_black.png', fit: BoxFit.contain),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(24),
              ),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: AnimatedBuilder(
              animation: _dotAnimController,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (i) {
                    final delay = i * 0.2;
                    final t = ((_dotAnimController.value - delay) % 1.0).clamp(0.0, 1.0);
                    final opacity = 0.2 + 0.8 * (t < 0.5 ? t * 2 : (1 - t) * 2).clamp(0.0, 1.0);
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.5),
                      child: Opacity(
                        opacity: opacity,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF1A1A2E),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () {
          _controller.text = label.replaceAll(RegExp(r'^[^\w]+\s*'), '');
          _sendMessage();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ]
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF4A4A4A),
              fontFamily: 'RobotoMono',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _ChatMessage {
  final String role; // 'user' or 'assistant'
  String content;

  _ChatMessage({required this.role, required this.content});
}
