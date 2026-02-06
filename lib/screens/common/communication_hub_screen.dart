import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/message_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/message.dart';
import '../../widgets/common/gradient_scaffold.dart';
import '../../widgets/common/glass_card.dart';

class CommunicationHubScreen extends StatefulWidget {
  const CommunicationHubScreen({super.key});

  @override
  State<CommunicationHubScreen> createState() =>
      _CommunicationHubScreenState();
}

class _CommunicationHubScreenState extends State<CommunicationHubScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showChannelList = true;
  String _selectedMessageType = 'text';

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final messageProvider =
        Provider.of<MessageProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      await messageProvider.initialize(
        userRole: authProvider.currentUser!.role,
        userId: authProvider.currentUser!.id,
      );
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final messageProvider =
        Provider.of<MessageProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user == null) return;

    _messageController.clear();

    final success = await messageProvider.sendMessage(
      content: text,
      senderId: user.id,
      senderName: user.name,
      senderRole: user.role,
      type: _selectedMessageType,
    );

    if (success) {
      _scrollToBottom();
      // Reset message type after sending
      setState(() => _selectedMessageType = 'text');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 600;

    return GradientScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Communication Hub',
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!isWideScreen)
            IconButton(
              icon: Icon(
                _showChannelList ? Icons.chat : Icons.list,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() => _showChannelList = !_showChannelList);
              },
            ),
        ],
      ),
      body: Consumer<MessageProvider>(
        builder: (context, messageProvider, _) {
          if (messageProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.softTealBlue),
            );
          }

          if (isWideScreen) {
            // Side-by-side layout for tablets
            return Row(
              children: [
                SizedBox(
                  width: 280,
                  child: _ChannelListPanel(
                    messageProvider: messageProvider,
                    onChannelSelected: (channelId) {
                      messageProvider.selectChannel(channelId);
                    },
                  ),
                ),
                Container(
                  width: 1,
                  color: Colors.white.withOpacity(0.1),
                ),
                Expanded(
                  child: _ChatPanel(
                    messageProvider: messageProvider,
                    messageController: _messageController,
                    scrollController: _scrollController,
                    selectedMessageType: _selectedMessageType,
                    onMessageTypeChanged: (type) {
                      setState(() => _selectedMessageType = type);
                    },
                    onSend: _sendMessage,
                  ),
                ),
              ],
            );
          }

          // Mobile layout: toggle between channel list and chat
          if (_showChannelList) {
            return _ChannelListPanel(
              messageProvider: messageProvider,
              onChannelSelected: (channelId) {
                messageProvider.selectChannel(channelId);
                setState(() => _showChannelList = false);
              },
            );
          }

          return _ChatPanel(
            messageProvider: messageProvider,
            messageController: _messageController,
            scrollController: _scrollController,
            selectedMessageType: _selectedMessageType,
            onMessageTypeChanged: (type) {
              setState(() => _selectedMessageType = type);
            },
            onSend: _sendMessage,
          );
        },
      ),
    );
  }
}

// ==================== CHANNEL LIST PANEL ====================
class _ChannelListPanel extends StatelessWidget {
  final MessageProvider messageProvider;
  final Function(String) onChannelSelected;

  const _ChannelListPanel({
    required this.messageProvider,
    required this.onChannelSelected,
  });

  @override
  Widget build(BuildContext context) {
    final channels = messageProvider.getChannels();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Text(
            'Channels',
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        Expanded(
          child: channels.isEmpty
              ? Center(
                  child: Text(
                    'No channels available',
                    style:
                        GoogleFonts.roboto(fontSize: 14, color: Colors.white38),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: channels.length,
                  itemBuilder: (context, index) {
                    final channel = channels[index];
                    final isSelected =
                        channel.id == messageProvider.selectedChannelId;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _ChannelTile(
                        channel: channel,
                        isSelected: isSelected,
                        onTap: () => onChannelSelected(channel.id),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _ChannelTile extends StatelessWidget {
  final Channel channel;
  final bool isSelected;
  final VoidCallback onTap;

  const _ChannelTile({
    required this.channel,
    required this.isSelected,
    required this.onTap,
  });

  IconData _getChannelIcon(String channelId) {
    switch (channelId) {
      case 'organizer-security':
        return Icons.security;
      case 'organizer-emergency':
        return Icons.medical_services;
      case 'security-emergency':
        return Icons.local_hospital;
      case 'all-staff':
        return Icons.groups;
      default:
        return Icons.chat;
    }
  }

  Color _getChannelColor(String channelId) {
    switch (channelId) {
      case 'organizer-security':
        return AppColors.blue;
      case 'organizer-emergency':
        return AppColors.red;
      case 'security-emergency':
        return AppColors.orange;
      case 'all-staff':
        return AppColors.softTealBlue;
      default:
        return AppColors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getChannelColor(channel.id);

    return GlassCard(
      padding: const EdgeInsets.all(12),
      backgroundColor: isSelected
          ? AppColors.softTealBlue.withOpacity(0.2)
          : null,
      borderColor: isSelected ? AppColors.softTealBlue.withOpacity(0.5) : null,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getChannelIcon(channel.id),
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  channel.name,
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                if (channel.lastMessagePreview != null)
                  Text(
                    channel.lastMessagePreview!,
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      color: Colors.white38,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          if (channel.unreadCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${channel.unreadCount}',
                style: GoogleFonts.roboto(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ==================== CHAT PANEL ====================
class _ChatPanel extends StatelessWidget {
  final MessageProvider messageProvider;
  final TextEditingController messageController;
  final ScrollController scrollController;
  final String selectedMessageType;
  final Function(String) onMessageTypeChanged;
  final VoidCallback onSend;

  const _ChatPanel({
    required this.messageProvider,
    required this.messageController,
    required this.scrollController,
    required this.selectedMessageType,
    required this.onMessageTypeChanged,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final messages = messageProvider.currentMessages;
    final selectedChannel = messageProvider.selectedChannelId;

    if (selectedChannel == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.chat_bubble_outline,
                size: 64, color: Colors.white24),
            const SizedBox(height: 16),
            Text(
              'Select a channel to start messaging',
              style: GoogleFonts.roboto(fontSize: 16, color: Colors.white54),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Channel header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            border: Border(
              bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
          ),
          child: Row(
            children: [
              Text(
                _getChannelName(selectedChannel),
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Text(
                '${messages.length} messages',
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  color: Colors.white38,
                ),
              ),
            ],
          ),
        ),

        // Messages
        Expanded(
          child: messages.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.forum_outlined,
                          size: 48, color: Colors.white24),
                      const SizedBox(height: 12),
                      Text(
                        'No messages yet',
                        style: GoogleFonts.roboto(
                            fontSize: 14, color: Colors.white38),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Start the conversation',
                        style: GoogleFonts.roboto(
                            fontSize: 12, color: Colors.white24),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId ==
                        Provider.of<AuthProvider>(context, listen: false)
                            .currentUser
                            ?.id;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _MessageBubble(
                        message: message,
                        isMe: isMe,
                      ),
                    );
                  },
                ),
        ),

        // Message type selector
        if (selectedMessageType != 'text')
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            color: Colors.white.withOpacity(0.05),
            child: Row(
              children: [
                Icon(
                  selectedMessageType == 'alert'
                      ? Icons.warning_amber
                      : Icons.update,
                  size: 16,
                  color: selectedMessageType == 'alert'
                      ? AppColors.orange
                      : AppColors.blue,
                ),
                const SizedBox(width: 8),
                Text(
                  selectedMessageType == 'alert'
                      ? 'Sending as Alert'
                      : 'Sending as Incident Update',
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: Colors.white54,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => onMessageTypeChanged('text'),
                  child: const Icon(Icons.close,
                      size: 16, color: Colors.white38),
                ),
              ],
            ),
          ),

        // Input bar
        SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              border: Border(
                top: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
            ),
            child: Row(
              children: [
                // Message type toggle
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.add_circle_outline,
                    color: Colors.white54,
                    size: 24,
                  ),
                  color: const Color(0xFF1A3A5C),
                  onSelected: onMessageTypeChanged,
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'text',
                      child: Row(
                        children: [
                          const Icon(Icons.chat, size: 18,
                              color: Colors.white70),
                          const SizedBox(width: 8),
                          Text('Text Message',
                              style: GoogleFonts.roboto(color: Colors.white)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'alert',
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber,
                              size: 18, color: AppColors.orange),
                          const SizedBox(width: 8),
                          Text('Alert',
                              style: GoogleFonts.roboto(color: Colors.white)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'incident_update',
                      child: Row(
                        children: [
                          Icon(Icons.update, size: 18, color: AppColors.blue),
                          const SizedBox(width: 8),
                          Text('Incident Update',
                              style: GoogleFonts.roboto(color: Colors.white)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                // Text input
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0x1AFFFFFF),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0x26FFFFFF)),
                    ),
                    child: TextField(
                      controller: messageController,
                      style: GoogleFonts.roboto(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: GoogleFonts.roboto(
                          color: Colors.white38,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => onSend(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Send button
                GestureDetector(
                  onTap: onSend,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.softTealBlue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.send, color: Colors.white,
                        size: 20),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getChannelName(String channelId) {
    final channels = messageProvider.getChannels();
    try {
      return channels.firstWhere((c) => c.id == channelId).name;
    } catch (e) {
      return 'Channel';
    }
  }
}

// ==================== MESSAGE BUBBLE ====================
class _MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  const _MessageBubble({
    required this.message,
    required this.isMe,
  });

  Color _getRoleBadgeColor(String role) {
    switch (role) {
      case 'organizer':
        return AppColors.softTealBlue;
      case 'security':
        return AppColors.blue;
      case 'emergency':
        return AppColors.red;
      default:
        return AppColors.blueGrey;
    }
  }

  Color _getMessageTypeColor() {
    switch (message.type) {
      case 'alert':
        return AppColors.orange;
      case 'incident_update':
        return AppColors.blue;
      default:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');
    final isSpecialType = message.type != 'text';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isMe
                ? AppColors.coolSteelBlue.withOpacity(0.6)
                : const Color(0x26FFFFFF),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: isMe
                  ? const Radius.circular(16)
                  : const Radius.circular(4),
              bottomRight: isMe
                  ? const Radius.circular(4)
                  : const Radius.circular(16),
            ),
            border: isSpecialType
                ? Border.all(
                    color: _getMessageTypeColor().withOpacity(0.5),
                    width: 1,
                  )
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sender info row
              if (!isMe)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message.senderName,
                        style: GoogleFonts.roboto(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.softTealBlue,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getRoleBadgeColor(message.senderRole)
                              .withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          message.roleDisplayName,
                          style: GoogleFonts.roboto(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color:
                                _getRoleBadgeColor(message.senderRole),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Message type indicator
              if (isSpecialType)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        message.type == 'alert'
                            ? Icons.warning_amber
                            : Icons.update,
                        size: 14,
                        color: _getMessageTypeColor(),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        message.typeDisplayName,
                        style: GoogleFonts.roboto(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _getMessageTypeColor(),
                        ),
                      ),
                    ],
                  ),
                ),

              // Message content
              Text(
                message.content,
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  color: Colors.white,
                  height: 1.4,
                ),
              ),

              // Incident link
              if (message.relatedIncidentId != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.blue.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.link, size: 12, color: AppColors.blue),
                        const SizedBox(width: 4),
                        Text(
                          'Incident #${message.relatedIncidentId!.substring(0, 8)}',
                          style: GoogleFonts.roboto(
                            fontSize: 11,
                            color: AppColors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Timestamp
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    timeFormat.format(message.createdAt),
                    style: GoogleFonts.roboto(
                      fontSize: 10,
                      color: Colors.white38,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
