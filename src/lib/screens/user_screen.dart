import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/models/models.dart';
import 'package:flutter/material.dart';

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
            ],
          ),
        ),
      ),
    );
  }
}
