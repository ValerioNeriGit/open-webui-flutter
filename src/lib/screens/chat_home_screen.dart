import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/chat.dart';
import '../models/model.dart';
import '../services/model_service.dart';
import '../widgets/chat_interface.dart';
import '../widgets/chat_sidebar.dart';
import '../services/auth_service.dart';
import '../services/chat_service.dart';
import '../services/messaging_service.dart';
import '../utils/logger.dart';
import '../widgets/model_selection_drawer.dart';

class ChatHomeScreen extends StatelessWidget {
  const ChatHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ChatHomeScreenContent();
  }
}

class _ChatHomeScreenContent extends StatefulWidget {
  const _ChatHomeScreenContent();

  @override
  State<_ChatHomeScreenContent> createState() => _ChatHomeScreenContentState();
}

class _ChatHomeScreenContentState extends State<_ChatHomeScreenContent> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<ChatListItem> _chats = [];
  Chat? _currentChat;
  Model? _selectedModel;
  bool _isLoading = true;
  bool _isSidebarOpen = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // Ensure models are loaded before trying to load chats
    await Provider.of<ModelService>(context, listen: false).fetchModels();
    await _loadChats();
  }

  Future<void> _loadChats() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      AppLogger.info('📁 Loading chats from ChatService');
      final chats = await ChatService.getChats();
      if (!mounted) return;

      AppLogger.info('✅ Successfully loaded ${chats.length} chats');
      
      setState(() {
        _chats = chats;
      });

      if (chats.isNotEmpty) {
        final mostRecentChat = chats.first;
        final timeSinceLastUpdate = DateTime.now().difference(mostRecentChat.updatedAt ?? DateTime(1970));
        
        if (timeSinceLastUpdate.inHours < 1) {
          AppLogger.info('🔄 Recent chat found. Loading "${mostRecentChat.title}".');
          await _selectChat(mostRecentChat.id);
        } else {
          _createNewChat();
        }
      } else {
        _createNewChat();
      }
    } catch (e, stackTrace) {
      AppLogger.logError('ChatHomeScreen._loadChats()', e, stackTrace);
      if (!mounted) return;
      _showErrorDialog('Error loading chats', e.toString());
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectChat(String chatId) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      AppLogger.info('💬 Selecting chat: $chatId');
      final modelService = Provider.of<ModelService>(context, listen: false);
      final chat = await ChatService.getChat(chatId);
      if (!mounted) return;
      
      Model? model;
      if (chat.models.isNotEmpty) {
        model = modelService.getModelById(chat.models.first);
      }
      
      setState(() {
        _currentChat = chat;
        _selectedModel = model ?? modelService.defaultModel;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      AppLogger.logError('ChatHomeScreen._selectChat($chatId)', e, stackTrace);
      if (!mounted) return;
      _showErrorDialog('Error loading chat history', e.toString());
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendMessage(String text) async {
    if (_selectedModel == null) {
      _showErrorDialog('No Model Selected', 'Please select a model before sending a message.');
      return;
    }

    final userMessage = ChatMessage(
      id: Random().nextInt(1000000).toString(), // temp ID
      role: 'user',
      content: text,
      timestamp: DateTime.now(),
    );
    final thinkingMessage = ChatMessage(
      id: Random().nextInt(1000000).toString(), // temp ID
      role: 'assistant',
      content: 'Thinking...',
      timestamp: DateTime.now().add(const Duration(milliseconds: 100)),
    );

    if (_currentChat == null) {
      // Optimistically create a new chat
      setState(() {
        _currentChat = Chat(
          id: 'temp-chat',
          title: text,
          models: [_selectedModel!.id],
          messages: [userMessage, thinkingMessage],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      });

      try {
        AppLogger.info('🆕 Creating new chat with first message...');
        final newChat = await MessagingService.createChatAndSendFirstMessage(
          prompt: text,
          model: _selectedModel!.id,
        );
        if (!mounted) return;
        setState(() {
          _currentChat = newChat;
          _chats.insert(0, ChatListItem(id: newChat.id, title: newChat.title));
        });
        AppLogger.info('✅ New chat created and message sent successfully.');
      } catch (e, stackTrace) {
        AppLogger.logError('ChatHomeScreen._sendMessage(new chat)', e, stackTrace);
        if (!mounted) return;
        // Revert optimistic update on failure
        setState(() {
          _currentChat = null;
        });
        _showErrorDialog('Failed to create new chat', e.toString());
      }
      return;
    }

    // Capture the state before the optimistic update
    final messagesToSend = List<ChatMessage>.from(_currentChat!.messages);
    final existingChatId = _currentChat!.id;

    // Optimistic update for existing chat
    setState(() {
      _currentChat!.messages.add(userMessage);
      _currentChat!.messages.add(thinkingMessage);
    });

    try {
      AppLogger.info('💬 Sending message to existing chat: $existingChatId');
      
      await MessagingService.sendMessage(
        chatId: existingChatId,
        currentMessages: messagesToSend,
        model: _selectedModel!.id,
        prompt: text,
      );
      AppLogger.info('✅ Message sent successfully, now reloading chat state.');

      final updatedChat = await ChatService.getChat(existingChatId);
      if (!mounted) return;
      setState(() {
        _currentChat = updatedChat;
      });
      AppLogger.info('✅ Chat state reloaded successfully.');

    } catch (e, stackTrace) {
      AppLogger.logError('ChatHomeScreen._sendMessage(existing chat)', e, stackTrace);
      if (!mounted) return;
      // Revert optimistic update on failure
      setState(() {
        _currentChat!.messages.removeWhere((m) => m.id == userMessage.id || m.id == thinkingMessage.id);
      });
      _showErrorDialog('Failed to send message', e.toString());
    }
  }

  void _createNewChat() {
    AppLogger.info('🆕 User clicked "New Chat". Clearing chat view.');
    final modelService = Provider.of<ModelService>(context, listen: false);
    setState(() {
      _currentChat = null;
      _selectedModel = modelService.defaultModel;
      _isLoading = false;
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

  void _showModelSelection() {
    _scaffoldKey.currentState?.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.user;

    return Scaffold(
      key: _scaffoldKey,
      drawer: ModelSelectionDrawer(
        selectedModel: _selectedModel,
        onModelSelected: (model) {
          Provider.of<ModelService>(context, listen: false).saveSelectedModel(model);
          setState(() {
            _selectedModel = model;
          });
          Navigator.pop(context);
        },
      ),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            setState(() {
              _isSidebarOpen = !_isSidebarOpen;
            });
          },
        ),
        title: InkWell(
          onTap: _showModelSelection,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Text(
                    _selectedModel?.name ?? 'Select a Model',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const Icon(Icons.arrow_drop_down, size: 20),
                ],
              ),
              Text(
                'Chat ID: ${_currentChat?.id.substring(0, 8) ?? 'New Chat'}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
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
