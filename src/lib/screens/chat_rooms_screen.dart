// ignore_for_file: unused_local_variable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/profile_manager.dart';

class ChatRoomsScreen extends StatelessWidget {
  const ChatRoomsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    String? currentUserId =
        Provider.of<ProfileManager>(context, listen: false).getUser.uid;
    return Scaffold(
      // body: SingleChildScrollView(
      //   child: StreamBuilder(
      //     stream: firebaseFirestore.collection('chatRooms').snapshots(),
      //     builder: (
      //       BuildContext context,
      //       AsyncSnapshot<QuerySnapshot> snapshot,
      //     ) {
      //       if (!snapshot.hasData) {
      //         return Container();
      //       }
      //       if (snapshot.data == null) {
      //         return Container();
      //       }
      //       return ListView.builder(
      //         itemCount: snapshot.data!.docs.length,
      //         itemBuilder: (context, index) {
      //           Map<String, dynamic> data = snapshot.data!.docs[index]
      //                     .data() as Map<String, dynamic>;
      //           if (data['users'].contains(currentUserId)){

      //           }
      //           return ListTile(
      //             title: ,
      //           );
      //         },
      //       );
      //     },
      //   ),
      // ),
      body: Container(),
    );
  }
}
