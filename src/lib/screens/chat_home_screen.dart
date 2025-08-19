import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/chat.dart';
import '../widgets/chat_interface.dart';
import '../widgets/chat_sidebar.dart';
import '../services/auth_service.dart';
import '../services/chat_service.dart';
import '../services/messaging_service.dart';
import '../utils/logger.dart';

class ChatHomeScreen extends StatefulWidget {
  const ChatHomeScreen({super.key});

  @override
  State<ChatHomeScreen> createState() => _ChatHomeScreenState();
}

class _ChatHomeScreenState extends State<ChatHomeScreen> {
  List<ChatListItem> _chats = [];
  Chat? _currentChat;
  bool _isLoading = true;
  bool _isSidebarOpen = false;
  final _uuid = Uuid();

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  Future<void> _loadChats() async {
    setState(() {
      _isLoading = true;
    });
    try {
      AppLogger.info('📁 Loading chats from ChatService');
      final chats = await ChatService.getChats();
      AppLogger.info('✅ Successfully loaded ${chats.length} chats');
      
      setState(() {
        _chats = chats;
      });

      // New Logic: Check if the most recent chat was used in the last hour.
      if (chats.isNotEmpty) {
        final mostRecentChat = chats.first;
        final timeSinceLastUpdate = DateTime.now().difference(mostRecentChat.updatedAt ?? DateTime(1970));
        
        if (timeSinceLastUpdate.inHours < 1) {
          AppLogger.info('🔄 Recent chat found. Loading "${mostRecentChat.title}".');
          await _selectChat(mostRecentChat.id);
        } else {
          AppLogger.info('🕰️ No recent chats found. Defaulting to new chat view.');
          setState(() {
            _currentChat = null;
            _isLoading = false;
          });
        }
      } else {
        // No chats exist, default to new chat view.
        AppLogger.info('🆕 No chats found. Defaulting to new chat view.');
        setState(() {
          _currentChat = null;
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      AppLogger.logError('ChatHomeScreen._loadChats()', e, stackTrace);
      _showErrorDialog('Error loading chats', e.toString());
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectChat(String chatId) async {
    setState(() {
      _isLoading = true;
    });
    try {
      AppLogger.info('💬 Selecting chat: $chatId');
      final chat = await ChatService.getChat(chatId);
      AppLogger.info('✅ Successfully loaded chat with ${chat.messages.length} messages');
      AppLogger.debug('🔍 Chat details - ID: "${chat.id}", Title: "${chat.title}", Models: ${chat.models}');
      AppLogger.warning('🚨 CRITICAL: Chat ID loaded as: "${chat.id}" - isEmpty: ${chat.id.isEmpty} - isNull: ${chat.id == null}');
      setState(() {
        _currentChat = chat;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      AppLogger.logError('ChatHomeScreen._selectChat($chatId)', e, stackTrace);
      _showErrorDialog('Error loading chat history', e.toString());
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendMessage(String text) async {
    AppLogger.debug('🚀 _sendMessage called with text: "$text"');
    
    // If there is no current chat, we are creating a new one.
    if (_currentChat == null) {
      try {
        AppLogger.info('🆕 Creating new chat with first message...');
        final newChat = await MessagingService.createChatAndSendFirstMessage(
          prompt: text,
          model: 'models/gemini-2.5-flash', // Use the correct model name provided by the user.
        );
        setState(() {
          _currentChat = newChat;
          // Add the new chat to the top of the sidebar list.
          _chats.insert(0, ChatListItem(id: newChat.id, title: newChat.title));
        });
        AppLogger.info('✅ New chat created and message sent successfully.');
      } catch (e, stackTrace) {
        AppLogger.logError('ChatHomeScreen._sendMessage(new chat)', e, stackTrace);
        _showErrorDialog('Failed to create new chat', e.toString());
      }
      return;
    }

    // If a chat already exists, send a message to it.
    final existingChatId = _currentChat!.id;
    try {
      AppLogger.info('💬 Sending message to existing chat: $existingChatId');
      
      // 1. Send the message. This method returns the AI's response as a String.
      await MessagingService.sendMessage(
        chatId: existingChatId,
        currentMessages: _currentChat!.messages,
        model: _currentChat!.models.isNotEmpty ? _currentChat!.models.first : 'llama3.1:latest',
        prompt: text,
      );
      AppLogger.info('✅ Message sent successfully, now reloading chat state.');

      // 2. Reload the chat from the server to get the updated state.
      final updatedChat = await ChatService.getChat(existingChatId);
      setState(() {
        _currentChat = updatedChat;
      });
      AppLogger.info('✅ Chat state reloaded successfully.');

    } catch (e, stackTrace) {
      AppLogger.logError('ChatHomeScreen._sendMessage(existing chat)', e, stackTrace);
      _showErrorDialog('Failed to send message', e.toString());
    }
  }

  Future<void> _createNewChat() async {
    AppLogger.info('🆕 User clicked "New Chat". Clearing chat view.');
    setState(() {
      _currentChat = null;
      // Close the sidebar after clicking "New Chat"
      if (_isSidebarOpen) {
        _isSidebarOpen = false;
      }
    });
  }

  void _showErrorDialog(String title, String content) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(child: Text(content)),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.user;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            setState(() {
              _isSidebarOpen = !_isSidebarOpen;
            });
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'ID: ${_currentChat?.id ?? 'No Chat Selected'}',
              style: TextStyle(fontSize: 14),
            ),
            if (_currentChat?.title != null)
              Text(
                'Title: ${_currentChat!.title}',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
        actions: [
          PopupMenuButton(
            offset: const Offset(0, 40),
            icon: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  user?.email.isNotEmpty == true ? user!.email[0].toUpperCase() : 'U',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text('Sign Out'),
                onTap: () async {
                  await authService.signOut();
                },
              ),
            ],
          ),
          const SizedBox(width: 16),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ChatInterface(
                  messages: _currentChat?.messages ?? [],
                  onSendMessage: _sendMessage,
                ),
          ChatSidebar(
            chats: _chats,
            currentChatId: _currentChat?.id,
            onChatSelected: _selectChat,
            onNewChat: _createNewChat,
            onRefresh: _loadChats,
            isSidebarOpen: _isSidebarOpen,
            setSidebarOpen: (isOpen) => setState(() => _isSidebarOpen = isOpen),
            userEmail: user?.email,
            onSignOut: () async => await authService.signOut(),
          ),
        ],
      ),
    );
  }
}