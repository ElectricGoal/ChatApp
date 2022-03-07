// ignore_for_file: unused_local_variable

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/api/firebase_api.dart';
import 'package:chat_app/screens/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/profile_manager.dart';

class ChatRoomsScreen extends StatelessWidget {
  const ChatRoomsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String? currentUserId = context.read<ProfileManager>().getUser.uid;
    return StreamBuilder(
      stream: FirestoreDatabase().getUserData(),
      builder: (
        BuildContext context,
        AsyncSnapshot<DocumentSnapshot> snapshot,
      ) {
        if (!snapshot.hasData) {
          return Container();
        }
        if (snapshot.data == null) {
          return Container();
        }
        List chatRooms = snapshot.data!.get('chatRooms') as List;

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(
                  right: 5,
                  left: 5,
                  top: 16,
                ),
                itemCount: chatRooms.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> chatRoom = chatRooms[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: chatRoom['img'] == 'none'
                          ? const Icon(
                              Icons.account_circle,
                              size: 60,
                              color: Colors.white,
                            )
                          : Container(
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: Image(
                                    image: CachedNetworkImageProvider(
                                      chatRoom['img'],
                                    ),
                                  ).image,
                                ),
                              ),
                            ),
                      title: Text(chatRoom['title']),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(
                              img: chatRoom['img'],
                              title: chatRoom['title'],
                              existedChatRoom: true,
                              roomId: chatRoom['id'],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
