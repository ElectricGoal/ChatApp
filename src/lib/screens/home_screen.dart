import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/api/firebase_api.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/models/models.dart';
import 'package:chat_app/screens/screens.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({Key? key, required this.currentTab}) : super(key: key);

  static MaterialPage page(int currentTab) {
    return MaterialPage(
      name: AppPages.home,
      key: ValueKey(AppPages.home),
      child: Home(
        currentTab: currentTab,
      ),
    );
  }

  final int currentTab;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  static List<Widget> pages = const [
    ChatRoomsScreen(),
    SearchScreen(),
    Tab2Screen(),
  ];

  //User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel(
    uid: 'none',
    firstName: 'none',
    lastName: 'none',
    email: 'none',
    avatarUrl: 'none',
  );

  @override
  Widget build(BuildContext context) {
    return Material(
      child: StreamBuilder<DocumentSnapshot>(
        // stream: FirebaseFirestore.instance
        //     .collection("users")
        //     .doc(user!.uid)
        //     .snapshots(),
        stream: FirestoreDatabase().getUserData(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.greenAccent,
              ),
            );
          }
          //print(snapshot.data);
          Map<String, dynamic>? data =
              snapshot.data?.data() as Map<String, dynamic>?;
          loggedInUser = UserModel.fromJson(data!);
          //print(loggedInUser.firstName);
          Provider.of<ProfileManager>(context, listen: true)
              .updateUserData(loggedInUser);
          return Consumer<AppStateManager>(
            builder: (
              context,
              appStateManager,
              child,
            ) {
              return Scaffold(
                appBar: AppBar(
                  backgroundColor: Colors.green,
                  title: const Text("Chat!"),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: InkWell(
                        child: loggedInUser.avatarUrl == 'none'
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
                                      image: CachedNetworkImageProvider(
                                          loggedInUser.avatarUrl!),
                                    ).image,
                                  ),
                                ),
                              ),
                        onTap: () {
                          Provider.of<ProfileManager>(context, listen: false)
                              .onProfilePressed(true);
                        },
                      ),
                    ),
                  ],
                ),
                body: IndexedStack(
                  index: widget.currentTab,
                  children: pages,
                ),
                bottomNavigationBar: BottomNavigationBar(
                  selectedItemColor: Colors.green,
                  currentIndex: widget.currentTab,
                  onTap: (index) {
                    Provider.of<AppStateManager>(context, listen: false)
                        .goToTab(index);
                  },
                  items: const <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                      label: 'Chat',
                      icon: Icon(Icons.explore),
                    ),
                    BottomNavigationBarItem(
                      label: 'Search',
                      icon: Icon(Icons.search),
                    ),
                    BottomNavigationBarItem(
                      label: 'Tab2',
                      icon: Icon(Icons.format_list_bulleted),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
    // return Consumer<AppStateManager>(
    //   builder: (
    //     context,
    //     appStateManager,
    //     child,
    //   ) {
    //     return Scaffold(
    //       appBar: AppBar(
    //         backgroundColor: Colors.green,
    //         title: const Text("Chat!"),
    //         actions: [
    //           profileButton(),
    //         ],
    //       ),
    //       body: StreamBuilder<DocumentSnapshot>(
    //         stream: FirebaseFirestore.instance
    //             .collection("users")
    //             .doc(user!.uid)
    //             .snapshots(),
    //         builder: (context, snapshot) {
    //           if (!snapshot.hasData) {
    //             return const Center(
    //               child: CircularProgressIndicator(
    //                 backgroundColor: Colors.greenAccent,
    //               ),
    //             );
    //           }
    //           final data = snapshot.data;
    //           loggedInUser = UserModel.fromMap(data);
    //           //print(loggedInUser.firstName);
    //           Provider.of<ProfileManager>(context, listen: true)
    //               .getDataUser(loggedInUser);
    //           return IndexedStack(
    //             index: widget.currentTab,
    //             children: pages,
    //           );
    //         },
    //       ),
    //       bottomNavigationBar: BottomNavigationBar(
    //         selectedItemColor: Colors.green,
    //         currentIndex: widget.currentTab,
    //         onTap: (index) {
    //           Provider.of<AppStateManager>(context, listen: false)
    //               .goToTab(index);
    //         },
    //         items: <BottomNavigationBarItem>[
    //           const BottomNavigationBarItem(
    //             label: 'Tab 0',
    //             icon: Icon(Icons.explore),
    //           ),
    //           const BottomNavigationBarItem(
    //             label: 'Tab 1',
    //             icon: Icon(Icons.search),
    //           ),
    //           BottomNavigationBarItem(
    //             label: 'Tab 2',
    //             icon: avatar(),
    //           ),
    //         ],
    //       ),
    //     );
    //   },
    // );
  }
}
