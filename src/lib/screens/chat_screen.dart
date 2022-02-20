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

  getChat() async {
    return firebaseFirestore
        .collection('chatRooms')
        .doc(widget.roomId)
        .collection('chats')
        .snapshots();
  }

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
  void initState() {
    _messageController.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: Stack(
        children: [
          StreamBuilder(
            stream: getChat(),
            builder: (
              BuildContext context,
              AsyncSnapshot<QuerySnapshot> snapshot,
            ) {
              if (snapshot.hasData) {
                if (snapshot.data == null) {
                  return Container();
                }
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> data = snapshot.data!.docs[index]
                        .data() as Map<String, dynamic>;
                    print(data['message']);
                    return Container();
                  },
                );
              } else {
                return Container();
              }
            },
          ),
          _buildTextField(),
        ],
      ),
    );
  }

  Widget _buildTextField() {
    return Container(
      alignment: Alignment.bottomCenter,
      width: MediaQuery.of(context).size.width,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 24,
        ),
        color: Colors.black54,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: "Message ...",
                  hintStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: const Icon(
                Icons.arrow_upward,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
