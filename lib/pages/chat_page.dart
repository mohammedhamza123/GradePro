import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gradpro/models/detailed_message_list.dart';
import 'package:gradpro/pages/widgets/widget_admin_base_page.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Start the timer when the widget is initialized
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      Provider.of<ChatProvider>(context, listen: false).loadMessages();
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminBasePage(child: Expanded(
      child: Consumer<ChatProvider>(builder: (context, provider, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: FutureBuilder<List<DetailedMessage>>(
                    future: provider.loadMessages(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return ListView(
                          reverse: true,
                          children: List.generate(provider.messageList.length,
                              (index) {
                            final message = provider.messageList[index];
                            return ChatMessage(
                              text: message.context,
                              isMe: message.sender.id == provider.user.id,
                              user: message.sender,
                            );
                          }),
                        );
                      } else if (snapshot.hasError) {
                        return Text(snapshot.error.toString());
                      } else {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return const Text('لا توجد رسائل');
                        }
                      }
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  TextField(
                    controller: provider.chatTextController,
                    onSubmitted: (value) {
                      provider.sendMessage();
                    },
                    decoration: const InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 0.0),
                        borderRadius: BorderRadius.all(Radius.circular(32)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 0.0),
                        borderRadius: BorderRadius.all(Radius.circular(32)),
                      ),
                    ),
                  ),
                  IconButton(
                      onPressed: () {
                        provider.sendMessage();
                      },
                      icon: const Icon(Icons.send))
                ],
              ),
            ),
          ],
        );
      }),
    ));
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isMe;
  final user;

  const ChatMessage({super.key, required this.text, required this.isMe, this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: <Widget>[
          !isMe
              ? const CircleAvatar(
                  radius: 22,
                  backgroundImage: AssetImage("assets/default_profile.jpg"),
                )
              : Container(),
          SizedBox(
            width: !isMe ? 4 : 0,
          ),
          Column(
            crossAxisAlignment: !isMe ? CrossAxisAlignment.start: CrossAxisAlignment.end,
            children: [
              Text(
                '${user.firstName} ${user.lastName}',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 13,
                  fontFamily: 'Tajawal',
                  fontWeight: FontWeight.w300,
                  height: 0,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: isMe ? Colors.blue : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text(
                  text,
                  style: TextStyle(
                    color: isMe ? Colors.white : Colors.black,
                    fontSize: 16.0,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            width: isMe ? 4 : 0,
          ),
          isMe
              ? const CircleAvatar(
                  radius: 22,
                  backgroundImage: AssetImage("assets/default_profile.jpg"),
                )
              : Container(),
        ],
      ),
    );
  }
}
