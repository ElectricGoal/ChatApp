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

  Future<bool> check(String uid) async {
    bool check = false;
    await FirebaseFirestore.instance.collection('users').doc(uid).get().then(
      (value) {
        if (value['friends'].contains(user.uid)) {
          //print('true');
          check = true;
          return;
        }
      },
    );

    return check;
  }

  Future<bool> isFriend(String uid) {
    var snapshot = FirebaseFirestore.instance
        .collection('users')
        .doc('$uid/friends')
        .snapshots();
    return snapshot.contains(user.uid);
  }

  Future<bool> isSending(String uid) {
    var snapshot = FirebaseFirestore.instance
        .collection('users')
        .doc('$uid/reqSend')
        .snapshots();
    return snapshot.contains(user.uid);
  }

  Future<bool> isReceived(String uid) {
    var snapshot = FirebaseFirestore.instance
        .collection('users')
        .doc('$uid/reqReceived')
        .snapshots();
    return snapshot.contains(user.uid);
  }

  Future<int> whichType(String uid) async {
    if (await isFriend(uid)) {
      print('is friend');
      return 1;
    }
    if (await isSending(uid)) {
      print('is friend request send');
      return 2;
    }
    if (await isReceived(uid)) {
      print('is friend requested by');
      return 3;
    }
    return 4;
  }

  @override
  Widget build(BuildContext context) {
    dynamic currentUserId =
        Provider.of<ProfileManager>(context, listen: false).getUser.uid;
    //Future<int> typeF = whichType(currentUserId);
    //print(isFriend(currentUserId));
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
              // FriendStatus(
              //     firebaseFirestore: firebaseFirestore,
              //     currentUserId: currentUserId,
              //     user: user,
              //     typeFriend: typeF,),
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

class FriendStatus extends StatelessWidget {
  FriendStatus({
    Key? key,
    required this.firebaseFirestore,
    required this.currentUserId,
    required this.user,
    required this.typeFriend,
  }) : super(key: key);
  int _type = 0;
  final FirebaseFirestore firebaseFirestore;
  final String currentUserId;
  final UserModel user;
  final Future<int> typeFriend;
  Future<void> convertF(Future<int> type) async {
    _type = await type;
  }

  @override
  Widget build(BuildContext context) {
    convertF(typeFriend);
    String status = "";
    print(_type);
    if (_type == 1 || _type == 2 || _type == 4) {
      print('hmmm\n');
      if (_type == 1) {
        status = "Friend";
      } else if (_type == 2) {
        status = "Friend Request Send";
      } else if (_type == 4) {
        status = "Friend Requested By";
      }
      return ElevatedButton(
        child: Text(
          status,
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
          backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
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
          firebaseFirestore.collection('users').doc(currentUserId).update({
            'reqSend': FieldValue.arrayUnion(
              [
                firebaseFirestore.doc('users/${user.uid}'),
              ],
            )
          });
          firebaseFirestore.collection('users').doc(user.uid).update({
            'reqReceived': FieldValue.arrayUnion(
              [
                firebaseFirestore.doc('users/$currentUserId'),
              ],
            )
          });
        },
      );
    }
    return Container(
      color: Colors.cyan,
      child: const Text(
        'oh noooooo',
        style: TextStyle(
          fontSize: 14,
        ),
      ),
    );
  }
}
