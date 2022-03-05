// ignore_for_file: avoid_print

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/models/models.dart';
import 'package:chat_app/screens/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserScreen extends StatelessWidget {
  UserScreen({
    Key? key,
    required this.user,
  }) : super(key: key);
  final UserModel user;

  @override
  Widget build(BuildContext context) {
    dynamic currentUserId =
        Provider.of<ProfileManager>(context, listen: false).getUser.uid;
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

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
              FollowStatus(
                firebaseFirestore: firebaseFirestore,
                currentUserId: currentUserId,
                user: user,
              ),
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
          if (doc['users']
                  .contains(firebaseFirestore.doc('users/' + currentUserId!)) &&
              doc['users']
                  .contains(firebaseFirestore.doc('users/' + user.uid!))) {
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
          'users': [
            firebaseFirestore.doc('users/' + currentUserId!),
            firebaseFirestore.doc('users/' + user.uid!),
          ]
        })
        .then((value) => print("ChatRoom created"))
        .catchError((error) => print("Failed to add chatRoom: $error"));

    roomId = docRef.id;
    print(roomId);

    return roomId;
  }
}

class FollowStatus extends StatefulWidget {
  const FollowStatus({
    Key? key,
    required this.firebaseFirestore,
    required this.currentUserId,
    required this.user,
  }) : super(key: key);
  final FirebaseFirestore firebaseFirestore;
  final String currentUserId;
  final UserModel user;

  @override
  State<FollowStatus> createState() => _FollowStatusState();
}

class _FollowStatusState extends State<FollowStatus> {
  bool _check = false;
  Future<void> check(String uid) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).get().then(
      (value) {
        if (value['following'].contains(widget.user.uid)) {
          _check = true;
          print("treuueeeeeeee\n");
          return;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    check(widget.currentUserId);
    return ElevatedButton(
      child: Text(
        _check ? 'Unfollow' : 'Follow',
        style: const TextStyle(
          fontSize: 14,
        ),
      ),
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all<Color>(
            !_check ? Colors.white : Colors.green),
        backgroundColor: MaterialStateProperty.all<Color>(
            !_check ? Colors.green : Colors.white),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color: !_check ? Colors.green : Colors.white,
            ),
          ),
        ),
      ),
      onPressed: () async {
        setState(() {
          if (!_check) {
            _check = true;
            widget.firebaseFirestore
                .collection('users')
                .doc(widget.currentUserId)
                .update({
              'following': FieldValue.arrayUnion(
                [
                  widget.firebaseFirestore.doc('users/${widget.user.uid}'),
                ],
              )
            });
            widget.firebaseFirestore
                .collection('users')
                .doc(widget.user.uid)
                .update({
              'follower': FieldValue.arrayUnion(
                [
                  widget.firebaseFirestore.doc('users/${widget.currentUserId}'),
                ],
              )
            });
          } else {
            _check = false;
            widget.firebaseFirestore
                .collection('users')
                .doc(widget.currentUserId)
                .update({
              'following': FieldValue.arrayRemove(
                [
                  widget.firebaseFirestore.doc('users/${widget.user.uid}'),
                ],
              )
            });
            widget.firebaseFirestore
                .collection('users')
                .doc(widget.user.uid)
                .update({
              'follower': FieldValue.arrayRemove(
                [
                  widget.firebaseFirestore.doc('users/${widget.currentUserId}'),
                ],
              )
            });
          }
        });
      },
    );
  }
}
