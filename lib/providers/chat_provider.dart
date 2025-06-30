import 'package:flutter/cupertino.dart';
import 'package:gradpro/models/channel_list.dart';
import 'package:gradpro/models/detailed_message_list.dart';
import 'package:gradpro/models/project_details_list.dart';
import 'package:gradpro/services/user_services.dart';

import '../models/message_list.dart';
import '../models/project_list.dart';
import '../models/user_list.dart';
import '../services/models_services.dart';

class ChatProvider extends ChangeNotifier {
  final UserService _userService = UserService();
  List<DetailedMessage> _messagesList = [];

  List<DetailedMessage> get messageList => _messagesList;
  late User user;
  Channel? _channel;
  int? _project;

  TextEditingController chatTextController = TextEditingController();

  Future<List<DetailedMessage>> loadMessages() async {
    user = (await _userService.user)!;
    if (user.groups == [2]) {
      final student = await getStudent(user.id);
      final channelList = await getChannelList(student!.project);
      _channel = channelList.channel.first;
      final data = await getMessageList(_channel!.id);
      _messagesList = data.detailedMessage;
      _messagesList.sort((a, b) => b.timeSent.compareTo(a.timeSent));
      return data.detailedMessage;
    } else if (_project != null) {
      final channelList = await getChannelList(_project!);
      _channel = channelList.channel.first;
      final data = await getMessageList(_channel!.id);
      _messagesList = data.detailedMessage;
      _messagesList.sort((a, b) => b.timeSent.compareTo(a.timeSent));
      return data.detailedMessage;
    } else {
      final channelList = await getChannelList(null);
      _channel = channelList.channel.first;
      final data = await getMessageList(_channel!.id);
      _messagesList = data.detailedMessage;
      _messagesList.sort((a, b) => b.timeSent.compareTo(a.timeSent));
      return data.detailedMessage;
    }
  }

  Future<void> sendMessage() async {
    if (chatTextController.text.isNotEmpty) {
      final message = Message(
          timeSent: DateTime.now(),
          sender: user.id,
          channel: _channel!.id,
          context: chatTextController.text,
          id: 0);
      await postMessage(message);
      chatTextController.text = "";
      notifyListeners();
    }
  }

  void setProject({ProjectDetail? item, Project? project}) {
    if (item != null) {
      _project = item.id;
      notifyListeners();
    } else if (project != null) {
      _project = project.id;
      notifyListeners();
    }
  }
}
