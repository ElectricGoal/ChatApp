import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/models/models.dart';
import 'package:chat_app/screens/user_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final navigatorKey = GlobalKey<NavigatorState>();
  final TextEditingController _textController = TextEditingController();
  late StreamController _streamController;
  late Stream _stream;
  Timer? _debouncer;

  @override
  void initState() {
    _streamController = StreamController();
    _stream = _streamController.stream;
    _textController.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    _streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            buildTextField(),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: StreamBuilder(
                stream: _stream,
                builder: (_, AsyncSnapshot snapshot) {
                  if (snapshot.hasError) {
                    return _errorCase();
                  }
                  if (snapshot.data == 'no data') {
                    return _notFoundCase();
                  }

                  switch (snapshot.data) {
                    case null:
                      return _nullCase();
                    case 'waiting':
                      return _waitingCase();
                    default:
                      return buildUsersList(snapshot, context);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<UserModel>> onSearchUserName() async {
    List<UserModel> users = [];
    FirebaseFirestore _firestore = FirebaseFirestore.instance;

    await _firestore
        .collection("users")
        //.where("email", arrayContains: "t")
        .get()
        .then(
      (QuerySnapshot querySnapshot) {
        for (var doc in querySnapshot.docs) {
          String name = doc["firstName"] + ' ' + doc["lastName"];
          if (name.toLowerCase().contains(_textController.text)) {
            //print(name);
            UserModel user = UserModel.fromMap(doc);
            users.add(user);
          }
        }
      },
    );

    return users;
  }

  void _search() async {
    if (_textController.text == null || _textController.text.isEmpty) {
      _streamController.add(null);
      return;
    }

    _streamController.add('waiting');

    final List<UserModel> users = await onSearchUserName();

    //print(users);

    if (users.isEmpty) {
      _streamController.add('no data');
      return;
    }

    _streamController.add(users);
  }

  TextField buildTextField() {
    return TextField(
      onChanged: (_) {
        if (_debouncer?.isActive ?? false) {
          // Note: _debouncer?.isActive same as _debouncer != null ? _debouncer.isActive : null
          _debouncer!.cancel();
        }
        _debouncer = Timer(
          const Duration(milliseconds: 400),
          () {
            _search();
          },
        );
      },
      controller: _textController,
      cursorColor: Colors.green,
      decoration: InputDecoration(
        suffixIcon: _textController.text.isEmpty
            ? Container(width: 0)
            : IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Colors.grey,
                ),
                onPressed: _textController.clear,
              ),
        contentPadding: const EdgeInsets.only(left: 30),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.green,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        hintText: 'Search',
        hintStyle: const TextStyle(color: Colors.grey),
      ),
    );
  }

  Widget buildUsersList(AsyncSnapshot snapshot, BuildContext context) {
    final List<UserModel> users = snapshot.data;
    //print(users);
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (_, index) {
        return ListTile(
          leading: users[index].avatarUrl == 'none'
              ? const Icon(
                  Icons.account_circle,
                  size: 40,
                  color: Colors.white,
                )
              : Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: Image(
                        image:
                            CachedNetworkImageProvider(users[index].avatarUrl!),
                      ).image,
                    ),
                  ),
                ),
          title: Text(users[index].firstName! + ' ' + users[index].lastName!),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => UserScreen(user: users[index],),
              ),
            );
          },
        );
      },
    );
  }
}

Widget _waitingCase() {
  return const Center(
    child: CircularProgressIndicator(
      color: Colors.green,
    ),
  );
}

Widget _nullCase() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: const [
        Icon(
          Icons.person_search,
          color: Colors.green,
          size: 50,
        ),
        SizedBox(
          height: 20,
        ),
        Text(
          'Search user',
          style: TextStyle(
            color: Colors.green,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

Widget _notFoundCase() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: const [
        Icon(
          Icons.sentiment_dissatisfied,
          color: Colors.green,
          size: 50,
        ),
        SizedBox(
          height: 20,
        ),
        Text(
          'Not found',
          style: TextStyle(
            color: Colors.green,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

Widget _errorCase() {
  return const Center(
    child: Icon(
      Icons.error_outline,
      color: Colors.red,
      size: 60,
    ),
  );
}
