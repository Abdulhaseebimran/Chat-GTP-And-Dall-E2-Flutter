import 'dart:async';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:chat_gtp_demo/screens/chat_message.dart';
import 'package:chat_gtp_demo/screens/three_dots.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  ChatGPT? chatGPT;
   bool _isImageSearch = false;
  StreamSubscription? _subscription;
  bool _isTyping = false;
  
   @override
  void initState() {
    super.initState();
    chatGPT = ChatGPT.instance.builder(
      "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",
    );
  }

  @override
  void dispose() {
    chatGPT!.genImgClose();
    _subscription?.cancel();
    super.dispose();
  }

  // Link for api - https://beta.openai.com/account/api-keys

  void _sendMessage() {
    if (_controller.text.isEmpty) return;
    ChatMessage message = ChatMessage(
      text: _controller.text,
      sender: "user",
      isImage: false,
    );

    setState(() {
      _messages.insert(0, message);
      _isTyping = true;
    });

    _controller.clear();

    if (_isImageSearch) {
      final request = GenerateImage(message.text, 1, size: "256x256");

      _subscription = chatGPT!
          .generateImageStream(request)
          .asBroadcastStream()
          .listen((response) {
        Vx.log(response.data!.last!.url!);
        insertNewData(response.data!.last!.url!, isImage: true);
      });
    } else {
      final request = CompleteReq(
          prompt: message.text, model: kTranslateModelV3, max_tokens: 200);

      _subscription = chatGPT!
          .onCompleteStream(request: request)
          .asBroadcastStream()
          .listen((response) {
        Vx.log(response!.choices[0].text);
        insertNewData(response.choices[0].text, isImage: false);
      });
    }
  }

  void insertNewData(String response, {bool isImage = false}) {
    ChatMessage botMessage = ChatMessage(
      text: response,
      sender: "bot",
      isImage: isImage,
    );

    setState(() {
      _isTyping = false;
      _messages.insert(0, botMessage);
    });
  }

  Widget _buildTextComposer() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            onSubmitted: (value) => _sendMessage(),
            decoration: const InputDecoration.collapsed(
                hintText: "Question/description"),
          ),
        ),
        ButtonBar(
          children: [
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () {
                _isImageSearch = false;
                _sendMessage();
              },
            ),
            TextButton(
                onPressed: () {
                  _isImageSearch = true;
                  _sendMessage();
                },
                child: const Text("Generate Image"))
          ],
        ),
      ],
    ).px16();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("ChatGPT & Dall-E2 Demo"),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Flexible(
                  child: ListView.builder(
                reverse: true,
                padding: Vx.m8,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _messages[index];
                },
              )),
              if (_isTyping) const ThreeDots(),
              const Divider(
                height: 1.0,
              ),
              Container(
                decoration: BoxDecoration(
                  color: context.cardColor,
                ),
                child: _buildTextComposer(),
              )
            ],
          ),
        ));
  }
}
