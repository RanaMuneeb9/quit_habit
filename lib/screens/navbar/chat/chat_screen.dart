import 'package:flutter/material.dart';
import 'package:quit_habit/utils/app_colors.dart';

/// A simple class to hold chat message data.
class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, this.isUser = false});
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  bool _hasChatStarted = false; // <-- ADDED: Tracks if the chat has begun

  // Initial messages from the screenshot
  final List<ChatMessage> _messages = [
    ChatMessage(
        text:
            "I'm here to guide you, motivate you, and answer anything you need on your quit journey. Ask me anything or choose a question to begin"),
    ChatMessage(
        text:
            "Every message you send helps me give you more personalized guidance. Just start typing whenever you're ready"),
    ChatMessage(
        text:
            "Whether you're dealing with cravings, stress, habit triggers, or just need encouragement, you can talk to me anytime"),
  ];

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _isTyping = _controller.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Handles sending a message
  void _sendMessage() {
    if (_isTyping) {
      final text = _controller.text;

      // --- MODIFICATION: Check if chat is starting ---
      if (!_hasChatStarted) {
        setState(() {
          _hasChatStarted = true;
          _messages.clear(); // Clear the guidelines
        });
      }
      // --- END MODIFICATION ---

      setState(() {
        _messages.add(ChatMessage(text: text, isUser: true));
        _controller.clear();
      });

      // Scroll to the bottom after sending
      _scrollToBottom();

      // TODO: Add logic to get a response from the AI
      // For demo, just add a simple response
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          _messages.add(ChatMessage(text: "Thanks for sharing! I'm here to help."));
        });
        _scrollToBottom();
      });
    }
  }

  /// Scrolls the ListView to the very bottom
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      resizeToAvoidBottomInset: true,
      appBar: _buildAppBar(theme),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Chat messages
            Expanded(
              // --- MODIFICATION: Conditionally show guidelines or chat ---
              child: _hasChatStarted
                  ? _buildChatList(theme)
                  : _buildGuidelinesList(theme),
              // --- END MODIFICATION ---
            ),
            // Input field
            _buildInputField(theme),


          ],
        ),
      ),
    );
  }

  // --- ADDED: Widget for centered guidelines ---
  Widget _buildGuidelinesList(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      // --- MODIFICATION: Added LayoutBuilder and SingleChildScrollView ---
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                // Ensure the column is at least as tall as the available space
                minHeight: constraints.maxHeight,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _messages.map((message) {
                  // Build a bubble but force it to be centered
                  return _buildChatBubble(theme, message, forceCenter: true);
                }).toList(),
              ),
            ),
          );
        },
      ),
      // --- END MODIFICATION ---
    );
  }

  // --- ADDED: Widget for the actual chat message list ---
  Widget _buildChatList(ThemeData theme) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16.0),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        return _buildChatBubble(theme, _messages[index]);
      },
    );
  }

  /// Builds the custom AppBar for the chat screen
  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      backgroundColor: AppColors.lightBackground,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back,
          color: AppColors.lightTextPrimary,
          size: 24,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      titleSpacing: 0,
      centerTitle: true,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Gradient Logo
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.lightSecondary, // Purple
                  AppColors.lightPrimary, // Blue
                ],
              ),
            ),
            child: const Icon(
              Icons.history_toggle_off_rounded,
              color: AppColors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          // Title
          Text(
            'QUIT AI',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: AppColors.lightTextPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
        ],
      ),
      actions: [
        // Coin Badge
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: _buildCoinBadge(theme),
        ),
      ],
    );
  }

  /// Builds the coin badge for the AppBar
  Widget _buildCoinBadge(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.badgeOrange,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Image.asset(
            "images/icons/header_coin.png",
            width: 16,
            height: 16,
          ),
          const SizedBox(width: 4),
          Text(
            '4\$', // From screenshot
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppColors.lightWarning,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a single chat bubble
  // --- MODIFICATION: Added 'forceCenter' parameter ---
  Widget _buildChatBubble(ThemeData theme, ChatMessage message,
      {bool forceCenter = false}) {
    final bool isAI = !message.isUser;

    // --- MODIFICATION: Alignment is forced if 'forceCenter' is true ---
    final alignment = forceCenter
        ? Alignment.center
        : (isAI ? Alignment.centerLeft : Alignment.centerRight);

    final color = isAI
        ? AppColors.lightPrimary.withOpacity(0.1)
        : AppColors.lightPrimary;
    final textColor =
        isAI ? AppColors.lightTextPrimary : AppColors.white;

    // --- MODIFICATION: Guidelines use AI bubble style ---
    final borderRadius = (isAI || forceCenter)
        ? const BorderRadius.only(
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          );

    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          // --- MODIFICATION: Guideline color uses AI style ---
          color: forceCenter ? AppColors.lightPrimary.withOpacity(0.1) : color,
          borderRadius: borderRadius,
        ),
        child: Text(
          message.text,
          // --- MODIFICATION: Centered text for AI/Guidelines, left-align for user ---
          textAlign: (isAI || forceCenter) ? TextAlign.center : TextAlign.start,
          style: theme.textTheme.bodyMedium?.copyWith(
            // --- MODIFICATION: Guideline text color uses AI style ---
            color: forceCenter ? AppColors.lightTextPrimary : textColor,
            fontSize: 15,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  /// Builds the text input field at the bottom
  Widget _buildInputField(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 12.0,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.lightBorder, width: 1.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Text Field
          Expanded(
            child: TextField(
              controller: _controller,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.lightTextPrimary,
                fontSize: 15,
              ),
              keyboardType: TextInputType.multiline,
              minLines: 1,
              maxLines: 5, // Allows the field to grow up to 5 lines
              decoration: InputDecoration(
                hintText: 'Send a message.',
                hintStyle: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.lightTextTertiary,
                  fontSize: 15,
                ),
                filled: true,
                fillColor: AppColors.white, // From screenshot
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                // Border style from screenshot
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.lightBorder,
                    width: 1.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.lightBorder,
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.lightPrimary,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Send Button
          IconButton(
            onPressed: _sendMessage,
            icon: Icon(
              Icons.send_rounded,
              size: 24,
              color: _isTyping
                  ? AppColors.lightPrimary
                  : AppColors.lightTextTertiary,
            ),
            padding: const EdgeInsets.all(12),
          ),
        ],
      ),
    );
  }
}