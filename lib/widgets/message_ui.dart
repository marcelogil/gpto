import 'package:flutter/material.dart';
import 'message.dart';

class MessageUI extends StatelessWidget {
  const MessageUI({
    super.key,
    required this.message,
  });

  final Message message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(
          bottom: 12.0,
          right: 20,
          left: 20,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width *
                0.8, // Set your desired maximum width
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: message.isUser
                    ? const Radius.circular(20)
                    : const Radius.circular(4),
                bottomRight: message.isUser
                    ? const Radius.circular(4)
                    : const Radius.circular(20),
              ),
              color: message.isUser
                  ? const Color.fromARGB(255, 196, 210, 197)
                  : const Color.fromARGB(255, 175, 197, 226),
              gradient: LinearGradient(
                colors: message.isUser
                    ? const [
                        Color.fromARGB(255, 46, 180, 194),
                        Color.fromARGB(255, 57, 205, 222),
                      ]
                    : const [
                        Color.fromARGB(255, 220, 232, 233),
                        Color.fromARGB(255, 235, 242, 242),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Text(message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.white : Colors.black87,
                  fontSize: 16,
                )),
          ),
        ),
      ),
    );
  }
}
