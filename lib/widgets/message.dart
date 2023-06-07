class Message {
  final String text;
  final DateTime timestamp = DateTime.now();
  final bool isUser;

  Message({
    required this.text,
    required this.isUser,
  });
}
