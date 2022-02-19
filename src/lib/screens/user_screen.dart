// ignore_for_file: avoid_print

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/models/models.dart';
import 'package:chat_app/screens/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserScreen extends StatelessWidget {
  const UserScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (user.avatarUrl == 'none')
                const Icon(
                  Icons.account_circle,
                  //size: 120,
                  size: 120,
                  color: Colors.amber,
                )
              else
                Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      //image: FileImage(_image!),
                      image: Image(
                        image: CachedNetworkImageProvider(user.avatarUrl!),
                      ).image,
                    ),
                  ),
                ),
              const SizedBox(
                height: 20,
              ),
              Text(
                user.firstName! + ' ' + user.lastName!,
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                child: const Text(
                  'Message',
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
                style: ButtonStyle(
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.green),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: const BorderSide(
                        color: Colors.green,
                      ),
                    ),
                  ),
                ),
                onPressed: () async {
                  String? roomId = await postChatRoomToFirestore(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        user: user,
                        roomId: roomId!,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                child: const Text(
                  'Add friends',
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
                style: ButtonStyle(
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.green),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: const BorderSide(
                        color: Colors.green,
                      ),
                    ),
                  ),
                ),
                onPressed: () async {},
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> postChatRoomToFirestore(BuildContext context) async {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    String? currentUserId =
        Provider.of<ProfileManager>(context, listen: false).getUser.uid;

    String? roomId;

    bool existedChatRoom = false;

    final collRef = firebaseFirestore.collection('chatRooms');

    await collRef.get().then(
      (QuerySnapshot querySnapshot) {
        for (var doc in querySnapshot.docs) {
          if (doc['users'].contains(currentUserId) &&
              doc['users'].contains(user.uid)) {
            roomId = doc.id;
            existedChatRoom = true;
            return;
          }
        }
      },
    );

    if (existedChatRoom) {
      print(roomId);
      return roomId;
    }

    DocumentReference docRef = collRef.doc();
    await docRef
        .set({
          'users': [user.uid, currentUserId]
        })
        .then((value) => print("ChatRoom created"))
        .catchError((error) => print("Failed to add chatRoom: $error"));

    roomId = docRef.id;
    print(roomId);

    return roomId;
  }
}
