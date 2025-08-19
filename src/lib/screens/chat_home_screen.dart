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
      if (chats.isNotEmpty) {
        AppLogger.debug('🔍 First chat - ID: "${chats.first.id}", Title: "${chats.first.title}"');
      }
      setState(() {
        _chats = chats;
      });
      if (chats.isNotEmpty) {
        await _selectChat(chats.first.id);
      } else {
        setState(() {
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
    AppLogger.debug('🔍 Current chat - ID: "${_currentChat?.id}", Title: "${_currentChat?.title}"');
    
    if (_currentChat == null) {
      _showErrorDialog('Error', 'No chat selected');
      return;
    }

    try {
      AppLogger.info('💬 Sending message to chat: ${_currentChat!.id}');
      await MessagingService.sendMessage(
        chatId: _currentChat!.id,
        currentMessages: _currentChat!.messages,
        model: _currentChat!.models.isNotEmpty ? _currentChat!.models.first : 'llama3.1:latest',
        prompt: text,
      );
      AppLogger.info('✅ Message sent successfully');
      
      // Reload the chat to get the updated state from server
      await _selectChat(_currentChat!.id);

    } catch (e, stackTrace) {
      AppLogger.logError('ChatHomeScreen._sendMessage()', e, stackTrace);
      _showErrorDialog('Failed to send message', e.toString());
    }
  }

  Future<void> _createNewChat() async {
    try {
      AppLogger.info('🆕 Creating new chat');
      setState(() {
        _isLoading = true;
      });

      // Use a default model for new chats - you might want to make this configurable
      final defaultModels = ['llama3.1:latest']; // Adjust based on your API's available models
      final newChat = await ChatService.createChat(
        title: 'New Chat',
        models: defaultModels,
      );

      setState(() {
        _currentChat = newChat;
        _chats = [ChatListItem(id: newChat.id, title: newChat.title), ..._chats];
        _isLoading = false;
      });

      AppLogger.info('✅ New chat created successfully: ${newChat.id}');
    } catch (e, stackTrace) {
      AppLogger.logError('ChatHomeScreen._createNewChat()', e, stackTrace);
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Error creating new chat', e.toString());
    }
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