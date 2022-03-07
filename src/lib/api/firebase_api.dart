// ignore_for_file: avoid_print

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

class FirestoreDatabase {
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  late Stream<DocumentSnapshot<Map<String, dynamic>>> snapshot;

  void deleteChatRooms(roomId) {
    firebaseFirestore.collection('chatRooms').doc(roomId).delete();
  }

  void updateChatRoomToUser({
    required String roomId,
    required UserModel user,
    required String currentUserId,
  }) async {
    Map<String, dynamic> chatRoomInfor = {
      'id': roomId,
      'img': user.avatarUrl,
      'title': user.firstName! + ' ' + user.lastName!,
    };
    firebaseFirestore.collection('users').doc(currentUserId).update(
      {
        'chatRooms': FieldValue.arrayUnion(
          [
            //firebaseFirestore.doc('chatRooms/$roomId'),
            chatRoomInfor,
          ],
        )
      },
    );
  }

  void addMessage(messageMap, roomId) {
    firebaseFirestore
        .collection('chatRooms')
        .doc(roomId)
        .collection('chats')
        .add(messageMap)
        .catchError(
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

  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserData() {
    User? user = FirebaseAuth.instance.currentUser;
    //firebaseFirestore.collection("users").doc(user!.uid).get()
    return firebaseFirestore.collection("users").doc(user!.uid).snapshots();
  }

  Future<List> postChatRoomToFirestore(
    String? user1Id,
    String? user2Id,
  ) async {
    String? roomId;

    bool existedChatRoom = false;

    final collRef = firebaseFirestore.collection('chatRooms');

    // collRef.where('users',
    //     arrayContains: firebaseFirestore.doc('users/' + user1Id!));

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
          'users': [
            firebaseFirestore.doc('users/' + user1Id!),
            firebaseFirestore.doc('users/' + user2Id!),
          ]
        })
        .then((value) => print("ChatRoom created"))
        .catchError((error) => print("Failed to add chatRoom: $error"));

    roomId = docRef.id;
    print(roomId);

    return [roomId, existedChatRoom];
  }
}
