import 'package:flutter/material.dart';
import 'chat_box.dart';

void main() {
  // Replace this with your own API key from OpenAI
  const String apiKey = 'YOUR-API-KEY';

  runApp(const ChatBox(apiKey: apiKey));
}
