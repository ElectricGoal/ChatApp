// ignore_for_file: avoid_print

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/api/firebase_api.dart';
import 'package:chat_app/models/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    Key? key,
    required this.img,
    required this.title,
    required this.existedChatRoom,
    required this.roomId,
    required this.user2Id,
  }) : super(key: key);
  final String img;
  final String title;
  final bool existedChatRoom;
  final String user2Id;
  final String roomId;

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  //bool isEmpty = true;
  bool isTyped = false;
  final TextEditingController _messageController = TextEditingController();

  Map<String, dynamic> lastMessageMap = {};

  addMessage() {
    if (_messageController.text.isNotEmpty) {
      Map<String, dynamic> messageMap = {
        'message': _messageController.text,
        'sendBy': context.read<ProfileManager>().getUser.uid,
        'time': DateTime.now(),
      };
      lastMessageMap = messageMap;
      FirestoreDatabase().addMessage(messageMap, widget.roomId);

      _messageController.clear();
      isTyped = true;
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String? currentUserId = context.read<ProfileManager>().getUser.uid;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 177, 211, 228),
      appBar: AppBar(
        leading: BackButton(
          onPressed: () async {
            if (!widget.existedChatRoom) {
              if (!isTyped) {
                FirestoreDatabase().deleteChatRooms(widget.roomId);
              } else {
                FirestoreDatabase().updateChatRoomToUser(
                  roomId: widget.roomId,
                  currentUserId: widget.user2Id,
                  user2Id: currentUserId!,
                  title: context.read<ProfileManager>().getUser.firstName! +
                      ' ' +
                      context.read<ProfileManager>().getUser.lastName!,
                  img: context.read<ProfileManager>().getUser.avatarUrl!,
                );
                FirestoreDatabase().updateChatRoomToUser(
                  roomId: widget.roomId,
                  currentUserId: currentUserId,
                  user2Id: widget.user2Id,
                  title: widget.title,
                  img: widget.img,
                );
              }
            }
            if (isTyped) {
              FirestoreDatabase().updateLastMessageToChatRoom(
                currentUserId: currentUserId!,
                roomId: widget.roomId,
                lastMessageMap: lastMessageMap,
              );

              FirestoreDatabase().updateLastMessageToChatRoom(
                currentUserId: widget.user2Id,
                roomId: widget.roomId,
                lastMessageMap: lastMessageMap,
              );
            }
            Navigator.pop(context, false);
          },
        ),
        leadingWidth: 40,
        title: Row(
          children: [
            widget.img == 'none'
                ? Icon(
                    Icons.account_circle,
                    size: 40,
                    color: Colors.green[600],
                  )
                : Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: Image(
                          image: CachedNetworkImageProvider(
                            widget.img,
                          ),
                        ).image,
                      ),
                    ),
                  ),
            const SizedBox(
              width: 15,
            ),
            Text(
              widget.title,
              style: const TextStyle(fontSize: 17),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirestoreDatabase().getMessages(widget.roomId),
              builder: (
                BuildContext context,
                AsyncSnapshot<QuerySnapshot> snapshot,
              ) {
                if (snapshot.hasData) {
                  if (snapshot.data == null) {
                    return Container();
                  }
                  return ListView.builder(
                    reverse: true,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> message = snapshot.data!.docs[index]
                          .data() as Map<String, dynamic>;
                      //print(data['message']);
                      bool isMe = message['sendBy'] == currentUserId;
                      DateTime dt = (message['time'] as Timestamp).toDate();
                      //final DateFormat timeFormatter = DateFormat('jm');
                      //final DateFormat dayFormatter = DateFormat('yyyy-MM-dd');
                      final String time = DateFormat('jm').format(dt);
                      final String dayMessage =
                          DateFormat('yyyy-MM-dd').format(dt);
                      // print(dayMessage);
                      // if (day != dayMessage) {
                      //   //print(day);
                      //   var messageWidget = Column(
                      //     children: [
                      //       Text(day),
                      //       MessageTile(
                      //         message: message['message'],
                      //         isMe: isMe,
                      //         avatar: widget.img,
                      //         time: time,
                      //       ),
                      //     ],
                      //   );
                      //   day = dayMessage;
                      //   return messageWidget;
                      // }
                      return MessageTile(
                        message: message['message'],
                        isMe: isMe,
                        avatar: widget.img,
                        time: time,
                      );
                    },
                  );
                } else {
                  const CircularProgressIndicator();
                  return Container();
                }
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(2),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  constraints: BoxConstraints(
                    minWidth: MediaQuery.of(context).size.width - 80,
                    maxWidth: MediaQuery.of(context).size.width - 80,
                    minHeight: 25.0,
                    maxHeight: 100.0,
                  ),
                  child: Scrollbar(
                    child: TextField(
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (value) {},
                      maxLines: null,
                      // focusNode: focusNode,
                      controller: _messageController,
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 13,
                        ),
                        hintText: "Message",
                        hintStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    addMessage();
                  },
                  child: Container(
                    //color: Colors.amber,
                    margin: const EdgeInsets.only(
                      //right: 20,
                      left: 19,
                      bottom: 12,
                    ),
                    child: const Icon(
                      Icons.arrow_upward,
                      size: 21,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MessageTile extends StatelessWidget {
  const MessageTile({
    Key? key,
    required this.message,
    required this.isMe,
    required this.avatar,
    required this.time,
  }) : super(key: key);

  final String message;
  final bool isMe;
  final String avatar;
  final String time;

  @override
  Widget build(BuildContext context) {
    if (isMe) {
      return Container(
        padding: const EdgeInsets.only(
          top: 8,
          bottom: 8,
          left: 0,
          right: 15,
        ),
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(left: 70),
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                textAlign: TextAlign.start,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontFamily: 'OverpassRegular',
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                time,
                textAlign: TextAlign.start,
                style: const TextStyle(
                  color: Colors.white30,
                  fontSize: 9,
                  fontFamily: 'OverpassRegular',
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.only(
              top: 8,
              bottom: 8,
              left: 15,
              right: 0,
            ),
            child: avatar == 'none'
                ? Icon(
                    Icons.account_circle,
                    size: 40,
                    color: Colors.green[600],
                  )
                : Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: Image(
                          image: CachedNetworkImageProvider(
                            avatar,
                          ),
                        ).image,
                      ),
                    ),
                  ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(
                top: 8,
                bottom: 8,
                left: 10,
                right: 0,
              ),
              alignment: Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.only(right: 70),
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message,
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontFamily: 'OverpassRegular',
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      time,
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        color: Colors.black26,
                        fontSize: 9,
                        fontFamily: 'OverpassRegular',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }
  }
}
