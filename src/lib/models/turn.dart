import 'message.dart';

class Turn {
  final String id;
  final Message userMessage;
  Message? modelMessage;
  final List<Map<String, String>> thoughts;
  bool isThinking;
  bool showThoughts;

  Turn({
    required this.id,
    required this.userMessage,
    this.modelMessage,
    required this.thoughts,
    required this.isThinking,
    this.showThoughts = false,
  });
}
