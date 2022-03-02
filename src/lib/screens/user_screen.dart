// ignore_for_file: avoid_print

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/api/firebase_api.dart';
import 'package:chat_app/models/models.dart';
import 'package:chat_app/screens/chat_screen.dart';
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
    String? currentUserId =
        Provider.of<ProfileManager>(context, listen: false).getUser.uid;
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
                  //String? roomId = await postChatRoomToFirestore(context);
                  List? chatRoom = await FirestoreDatabase()
                      .postChatRoomToFirestore(currentUserId, user.uid);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        img: user.avatarUrl!,
                        title: user.firstName! + ' ' + user.lastName!,
                        existedChatRoom: chatRoom[1],
                        roomId: chatRoom[0],
                        user: user,
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
}
