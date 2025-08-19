import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../models/chat.dart';

class ChatSidebar extends StatelessWidget {
  final List<ChatListItem> chats;
  final String? currentChatId;
  final Function(String) onChatSelected;
  final VoidCallback onNewChat;
  final Future<void> Function() onRefresh;
  final bool isSidebarOpen;
  final Function(bool) setSidebarOpen;
  final String? userEmail;
  final VoidCallback onSignOut;

  const ChatSidebar({
    super.key,
    required this.chats,
    required this.currentChatId,
    required this.onChatSelected,
    required this.onNewChat,
    required this.onRefresh,
    required this.isSidebarOpen,
    required this.setSidebarOpen,
    required this.userEmail,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      left: isSidebarOpen ? 0 : -280,
      top: 0,
      bottom: 0,
      width: 280,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.secondaryBackground,
        ),
        child: Column(
          children: [
            // Sidebar Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Chats',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.titleLarge?.color,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: onNewChat,
                    tooltip: 'New Chat',
                  ),
                ],
              ),
            ),
            // Chat History
            Expanded(
              child: RefreshIndicator(
                onRefresh: onRefresh,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    final chat = chats[index];
                    final isSelected = chat.id == currentChatId;

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            onChatSelected(chat.id);
                            setSidebarOpen(false);
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                                  : null,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline,
                                  size: 16,
                                  color: Theme.of(context).textTheme.bodyMedium?.color,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    chat.title,
                                    style: TextStyle(
                                      color: Theme.of(context).textTheme.bodyLarge?.color,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            // User Profile
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        userEmail?.isNotEmpty == true
                            ? userEmail![0].toUpperCase()
                            : 'U',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      userEmail ?? 'User',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: onSignOut,
                    icon: Icon(
                      Icons.logout,
                      color: Theme.of(context).iconTheme.color,
                      size: 20,
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