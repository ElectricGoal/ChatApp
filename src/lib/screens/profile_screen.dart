import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/models/models.dart';
import 'package:chat_app/screens/screens.dart';
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
        const Icon(
          Icons.account_circle,
          size: 120,
          color: Colors.amber,
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
