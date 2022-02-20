// ignore_for_file: avoid_print

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/models/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key, required this.user, required this.roomId})
      : super(key: key);
  final UserModel user;
  final String roomId;

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  addMessage() {
    if (_messageController.text.isNotEmpty) {
      Map<String, dynamic> messageMap = {
        'message': _messageController.text,
        'sendBy':
            Provider.of<ProfileManager>(context, listen: false).getUser.uid,
        'time': DateTime.now().microsecondsSinceEpoch,
      };

      firebaseFirestore
          .collection('chatRooms')
          .doc(widget.roomId)
          .collection('chats')
          .add(messageMap)
          .catchError(
        (e) {
          print(e.toString());
        },
      );

      _messageController.clear();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String? currentUserId =
        Provider.of<ProfileManager>(context, listen: false).getUser.uid;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 177, 211, 228),
      appBar: AppBar(
        leadingWidth: 40,
        title: Row(
          children: [
            widget.user.avatarUrl == 'none'
                ? const Icon(
                    Icons.account_circle,
                    size: 40,
                    color: Colors.white,
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
                            widget.user.avatarUrl!,
                          ),
                        ).image,
                      ),
                    ),
                  ),
            const SizedBox(
              width: 10,
            ),
            Text(widget.user.firstName! + ' ' + widget.user.lastName!),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: firebaseFirestore
                  .collection('chatRooms')
                  .doc(widget.roomId)
                  .collection('chats')
                  .orderBy('time', descending: true)
                  .snapshots(),
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
                      Map<String, dynamic> data = snapshot.data!.docs[index]
                          .data() as Map<String, dynamic>;
                      //print(data['message']);
                      bool isMe = data['sendBy'] == currentUserId;
                      String message = data['message'];
                      return MessageTile(
                        message: message,
                        isMe: isMe,
                        user: widget.user,
                      );
                    },
                  );
                } else {
                  return Container();
                }
              },
            ),
          ),
          Container(
            height: 60,
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 10,
            ),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: "Message...",
                      hintStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    addMessage();
                  },
                  child: const Icon(
                    Icons.arrow_upward,
                    size: 20,
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
    required this.user,
  }) : super(key: key);

  final String message;
  final bool isMe;
  final UserModel user;

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
              borderRadius: BorderRadius.circular(23),
            ),
            child: Text(
              message,
              textAlign: TextAlign.start,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'OverpassRegular',
                fontWeight: FontWeight.w300,
              ),
            )),
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
            child: user.avatarUrl == 'none'
                ? const Icon(
                    Icons.account_circle,
                    size: 40,
                    color: Colors.white,
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
                            user.avatarUrl!,
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
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(23),
                ),
                child: Text(
                  message,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'OverpassRegular',
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }
  }
}
