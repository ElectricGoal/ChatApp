import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/models/models.dart';
import 'package:chat_app/screens/screens.dart';
import 'package:image_picker/image_picker.dart';
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
  var _image;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.close,
          ),
          onPressed: () {
            Provider.of<ProfileManager>(context, listen: false)
                .tapOnProfile(false);
          },
        ),
        actions: [
          buildLogoutButton(),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              buildProfile(),
              const SizedBox(
                height: 14,
              ),
              buildDarkModeSwitch(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildProfile() {
    return Column(
      children: [
        _image == null
            ? const Icon(
                Icons.account_circle,
                //size: 120,
                size: 120,
                color: Colors.amber,
              )
            : Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: FileImage(_image),
                  ),
                ),
              ),
        const SizedBox(
          height: 5,
        ),
        buildChangeAvatarButton(),
        const SizedBox(
          height: 25,
        ),
        ListTile(
          leading: const Text(
            'Full name:',
            style: TextStyle(fontSize: 18),
          ),
          trailing: Text(
            '${widget.user.firstName} ${widget.user.lastName}',
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
            '${widget.user.email} ',
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ],
    );
  }

  Widget buildLogoutButton() {
    return Container(
      padding: const EdgeInsets.only(right: 16),
      child: TextButton(
        onPressed: () {
          logout();

          Provider.of<ProfileManager>(context, listen: false)
              .tapOnProfile(false);

          Provider.of<AppStateManager>(context, listen: false).logout();

          Provider.of<ProfileManager>(context, listen: false).logout();
        },
        child: const Text(
          'Logout',
          style: TextStyle(
            fontSize: 16,
            color: Colors.green,
          ),
        ),
      ),
    );
  }

  Widget buildChangeAvatarButton() {
    return ElevatedButton(
      child: const Text(
        'Change avatar',
        style: TextStyle(
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
      onPressed: () {
        pickImage();
      },
    );
  }

  Future<void> pickImage() async {
    XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
    }
  }

  Widget buildDarkModeSwitch(BuildContext context) {
    return ListTile(
      leading: const Text(
        'Dark mode',
        style: TextStyle(
          fontSize: 18,
        ),
      ),
      trailing: Switch(
        activeColor: Colors.greenAccent,
        value: Provider.of<ProfileManager>(context, listen: false).darkMode,
        onChanged: (value) {
          Provider.of<ProfileManager>(context, listen: false).darkMode = value;
        },
      ),
    );
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }
}
