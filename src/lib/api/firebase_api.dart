// ignore_for_file: avoid_print

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../models/models.dart';

class FirebaseApi {
  static UploadTask? uploadFile(String destination, File file) {
    try {
      final ref = FirebaseStorage.instance.ref(destination);

      return ref.putFile(file);
    } on FirebaseException catch (e) {
      print(e);
      return null;
    }
  }
}

bool isNotToday(DateTime date) {
  if (date.year != DateTime.now().year) {
    return true;
  }
  if (date.month != DateTime.now().month) {
    return true;
  }
  if (date.day != DateTime.now().day) {
    return true;
  }
  return false;
}

class FirestoreDatabase {
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  late Stream<DocumentSnapshot<Map<String, dynamic>>> snapshot;

  void deleteChatRooms(roomId) {
    firebaseFirestore.collection('chatRooms').doc(roomId).delete();
  }

  void updateChatRoomToUser({
    required String roomId,
    required String user2Id,
    required String currentUserId,
    required String title,
    required String img,
  }) async {
    Map<String, dynamic> chatRoomInfor = {
      'id': roomId,
      'img': img,
      'title': title,
      'user2Id': user2Id,
      'lastMessage': 'none',
      'time': DateTime.now(),
      'sendBy': 'none',
    };

    firebaseFirestore
        .collection('users')
        .doc(currentUserId)
        .collection('chatRooms')
        .add(chatRoomInfor)
        .catchError(
      (e) {
        print(e.toString());
      },
    );
  }

  void updateLastMessageToChatRoom({
    required String currentUserId,
    required String roomId,
    required Map<String, dynamic> lastMessageMap,
  }) async {
    String id = '';
    CollectionReference colRef = firebaseFirestore
        .collection('users')
        .doc(currentUserId)
        .collection('chatRooms');

    await colRef.get().then(
      (QuerySnapshot querySnapshot) {
        for (var doc in querySnapshot.docs) {
          if (doc['id'].contains(roomId)) {
            id = doc.id;
            return;
          }
        }
      },
    );

    Map<String, dynamic> formattedLastMessageMap = {
      'lastMessage': lastMessageMap['message'],
      'sendBy': lastMessageMap['sendBy'] == currentUserId ? 'you' : 'other',
      'time': lastMessageMap['time'],
    };

    colRef.doc(id).update(formattedLastMessageMap).catchError((error) {
      print(error);
    });
  }

  void addMessage(messageMap, roomId) async {
    DocumentReference docRef =
        firebaseFirestore.collection('chatRooms').doc(roomId);

    DateTime lastTimeMessage = DateTime.now();
    //print(messageMap['time']);
    await docRef.get().then(
      (value) {
        // try {
        //   lastTimeMessage = (value['lastTimeMessage'] as Timestamp).toDate();
        //   if (isNotToday(lastTimeMessage)) {
        //     print("it not today");
        //     docRef.update(
        //       {'lastTimeMessage': messageMap['time']},
        //     ).catchError((error) => print(error));

        //     messageMap['header'] = DateFormat('EEE, M/d/y')
        //         .format((messageMap['time'] as Timestamp).toDate());
        //   }
        // } catch (e) {
        //   docRef.update(
        //     {'lastTimeMessage': messageMap['time']},
        //   ).catchError((error) => print(error));
        //   print(2);
        //   messageMap['header'] = DateFormat('EEE, M/d/y').format(lastTimeMessage);
        // }
        lastTimeMessage = (value['lastTimeMessage'] as Timestamp).toDate();
        if (isNotToday(lastTimeMessage)) {
          //print("it not today");
          try {
            messageMap['header'] = DateFormat('EEE, M/d/y')
                .format((messageMap['time']))
                .toString();
          } catch (e) {
            print(e);
          }
        }
        docRef.update(
          {'lastTimeMessage': messageMap['time']},
        ).catchError((error) => print(error));
      },
    );

    //print(messageMap['header']);

    docRef.collection('chats').add(messageMap).catchError(
      (e) {
        print(e.toString());
      },
    );
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getMessages(roomId) {
    return firebaseFirestore
        .collection('chatRooms')
        .doc(roomId)
        .collection('chats')
        .orderBy('time', descending: true)
        .snapshots();
  }

  Future<List<UserModel>> searchByUserName(String text) async {
    List<UserModel> users = [];

    await firebaseFirestore.collection("users").get().then(
      (QuerySnapshot querySnapshot) {
        for (var doc in querySnapshot.docs) {
          String name = doc["firstName"] + ' ' + doc["lastName"];
          if (name.toLowerCase().contains(text)) {
            UserModel user =
                UserModel.fromJson(doc.data() as Map<String, dynamic>);
            users.add(user);
          }
        }
      },
    );

    return users;
  }

  Future<void> updateData(String picUrl, String currentUserId) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUserId)
        .update({'avatarUrl': picUrl});
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserData() {
    User? user = FirebaseAuth.instance.currentUser;
    return firebaseFirestore.collection("users").doc(user!.uid).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getChatRooms() {
    User? user = FirebaseAuth.instance.currentUser;
    return firebaseFirestore
        .collection("users")
        .doc(user!.uid)
        .collection('chatRooms')
        .snapshots();
  }

  Future<List> postChatRoomToFirestore(
    String? user1Id,
    String? user2Id,
  ) async {
    String? roomId;

    bool existedChatRoom = false;

    final collRef = firebaseFirestore.collection('chatRooms');

    await collRef.get().then(
      (QuerySnapshot querySnapshot) {
        for (var doc in querySnapshot.docs) {
          if (doc['users']
                  .contains(firebaseFirestore.doc('users/' + user1Id!)) &&
              doc['users']
                  .contains(firebaseFirestore.doc('users/' + user2Id!))) {
            roomId = doc.id;
            existedChatRoom = true;
            return;
          }
        }
      },
    );

    if (existedChatRoom) {
      print(roomId);
      return [roomId, existedChatRoom];
    }

    DocumentReference docRef = collRef.doc();
    await docRef
        .set({
          'lastTimeMessage': DateTime(2000, 1, 1),
          'users': [
            firebaseFirestore.doc('users/' + user1Id!),
            firebaseFirestore.doc('users/' + user2Id!),
          ],
        })
        .then((value) => print("ChatRoom created"))
        .catchError((error) => print("Failed to add chatRoom: $error"));

    roomId = docRef.id;
    print(roomId);

    return [roomId, existedChatRoom];
  }
}
