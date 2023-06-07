import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'widgets/message.dart';
import 'widgets/message_ui.dart';

class ChatBox extends StatefulWidget {
  final String apiKey;
  const ChatBox({super.key, required this.apiKey});

  @override
  State<ChatBox> createState() => _ChatBoxState();
}

class _ChatBoxState extends State<ChatBox> {
  final TextEditingController _inputController = TextEditingController();
  List<Message> messages = [];
  bool isLoading = false;

  @override
  initState() {
    super.initState();
    getInitialMessage();
  }

  void getInitialMessage() {
    if (messages.isEmpty) {
      setState(() {
        messages = [
          widget.apiKey.length < 20
              ? Message(
                  text:
                      'Please add your API Key to the variable apiKey in main.dart',
                  isUser: false)
              : Message(text: 'Ask me anything.', isUser: false),
        ];
      });
    }
  }

  Future<http.Response> sendGptRequest(String prompt) async {
    setState(() {
      isLoading = true;
    });

    // GPT API endpoint
    const String apiUrl = 'https://api.openai.com/v1/chat/completions';

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${widget.apiKey}',
    };

    Map<String, dynamic> body = {
      "model": "gpt-3.5-turbo",
      "messages": [
        {
          "role": "user",
          "content": prompt,
        }
      ]
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: headers,
      body: jsonEncode(body),
    );

    setState(() {
      isLoading = false;
    });

    return response;
  }

  Future<void> callApi() async {
    String prompt = _inputController.text;

    setState(() {
      messages.add(
        Message(
          isUser: true,
          text: prompt,
        ),
      );
      _inputController.text = '';
    });

    if (widget.apiKey.length < 20) {
      setState(() {
        messages.add(
          Message(
            isUser: false,
            text:
                'Your API Key is not configured yet. \nVisit https://platform.openai.com/account/api-keys to get one. \nThen add it to the variable apiKey in main.dart',
          ),
        );
      });
      return;
    }

    // Send a request to the GPT API
    final response = await sendGptRequest(prompt);

    // Process the response
    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);

      Logger().i(result);

      setState(() {
        messages.add(
          Message(
            isUser: false,
            text: result['choices'][0]['message']['content'],
          ),
        );
      });
    } else {
      setState(() {
        messages.add(
          Message(
            isUser: false,
            text: 'Error: ${response.statusCode}',
          ),
        );
      });
    }
  }

  String formatDate(DateTime date) {
    return '${date.year}-${date.month}-${date.day} ${date.hour}:${date.minute}';
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 80,
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                      border:
                          Border.all(color: const Color(0xFFE4E4E4), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(width: 20),
                        Expanded(
                          child: TextField(
                            controller: _inputController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Enter your text here',
                            ),
                            onSubmitted: (value) {
                              if (!isLoading && value.isNotEmpty) {
                                callApi();
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 80,
                          height: 60,
                          child: TextButton(
                              style: ButtonStyle(
                                overlayColor:
                                    MaterialStateProperty.resolveWith<Color?>(
                                  (Set<MaterialState> states) {
                                    return const Color(0xFFD7D3CA);
                                  },
                                ),
                              ),
                              onPressed: callApi,
                              child: const Text(
                                'Send',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 16,
                                ),
                              )),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: 80,
                child: SingleChildScrollView(
                  reverse: true,
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      for (var message in messages) MessageUI(message: message),
                      Text(
                        formatDate(messages.last.timestamp),
                        style: const TextStyle(
                          color: Colors.black26,
                          fontSize: 12.0,
                        ),
                      ),
                      isLoading
                          ? const Padding(
                              padding: EdgeInsets.all(20.0),
                              child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.black12,
                                    strokeWidth: 2,
                                  )),
                            )
                          : Container(),
                    ],
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
