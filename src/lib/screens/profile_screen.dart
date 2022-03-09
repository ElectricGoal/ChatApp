import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/api/firebase_api.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/models/models.dart';
import 'package:chat_app/screens/screens.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key, required this.user}) : super(key: key);

  static MaterialPage page(UserModel user) {
    return MaterialPage(
      name: AppPages.profilePath,
      key: ValueKey(AppPages.profilePath),
      child: ProfileScreen(
        user: user,
      ),
    );
  }

  final UserModel user;

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _image;
  UploadTask? task;
  String? picUrl;
  bool showSpinner = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileManager>(
      builder: (
        context,
        profileManager,
        child,
      ) {
        return ModalProgressHUD(
          inAsyncCall: showSpinner,
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(
                  Icons.close,
                ),
                onPressed: () {
                  profileManager.onProfilePressed(false);
                },
              ),
              actions: [
                Container(
                  padding: const EdgeInsets.only(right: 16),
                  child: TextButton(
                    onPressed: () {
                      logout();

                      Provider.of<AppStateManager>(context, listen: false)
                          .logout();

                      profileManager.onProfilePressed(false);

                      profileManager.logout();
                    },
                    child: const Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (profileManager.user.avatarUrl == 'none')
                      Icon(
                        Icons.account_circle,
                        //size: 120,
                        size: 120,
                        color: Colors.green[600],
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
                              image: CachedNetworkImageProvider(
                                //widget.user.avatarUrl!,
                                profileManager.user.avatarUrl!,
                              ),
                            ).image,
                          ),
                        ),
                      ),
                    const SizedBox(
                      height: 5,
                    ),
                    ElevatedButton(
                      child: const Text(
                        'Change avatar',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      style: ButtonStyle(
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.white),
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.green),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                            side: const BorderSide(
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ),
                      onPressed: () async {
                        XFile? image = await pickImage();
                        if (image != null) {
                          setState(() {
                            _image = File(image.path);
                          });
                        } else {
                          return;
                        }
                        setState(() {
                          showSpinner = true;
                        });
                        await uploadImg();
                        await FirestoreDatabase().updateData(picUrl!, widget.user.uid!);
                        //await updateData(picUrl!);
                        setState(() {
                          showSpinner = false;
                        });
                      },
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    ListTile(
                      leading: const Text(
                        'Full name:',
                        style: TextStyle(fontSize: 18),
                      ),
                      trailing: Text(
                        '${profileManager.user.firstName} ${profileManager.user.lastName}',
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 14,
                    ),
                    ListTile(
                      leading: const Text(
                        'Email:',
                        style: TextStyle(fontSize: 18),
                      ),
                      trailing: Text(
                        '${profileManager.user.email} ',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                    const SizedBox(
                      height: 14,
                    ),
                    ListTile(
                      leading: const Text(
                        'Dark mode',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      trailing: Switch(
                        activeColor: Colors.greenAccent,
                        value: profileManager.darkMode,
                        onChanged: (value) {
                          profileManager.darkMode = value;
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<XFile?> pickImage() async {
    XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 480,
      maxWidth: 640,
      imageQuality: 50,
    );
    return image;
  }

  Future<void> uploadImg() async {
    if (_image == null) {
      return;
    }

    final fileName = "${widget.user.uid}.jpg";

    final destination = "profilePics/$fileName";

    task = FirebaseApi.uploadFile(destination, _image!);
    setState(() {});

    if (task == null) {
      return;
    }

    final snapshot = await task!.whenComplete(() {});
    picUrl = await snapshot.ref.getDownloadURL();

    if (picUrl == null) {
      return;
    }

    Provider.of<ProfileManager>(context, listen: false).updateAvatar(picUrl!);
  }

  // Future<void> updateData(String picUrl) async {
  //   await FirebaseFirestore.instance
  //       .collection("users")
  //       .doc(widget.user.uid)
  //       .update({'avatarUrl': picUrl});
  // }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }
}
