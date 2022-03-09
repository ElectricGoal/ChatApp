import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/api/firebase_api.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  UserModel loggedInUser = UserModel(
    uid: 'none',
    firstName: 'none',
    lastName: 'none',
    email: 'none',
    avatarUrl: 'none',
  );

  @override
  Widget build(BuildContext context) {
    String label = '';
    switch (context.read<AppStateManager>().getSelectedTab) {
      case 0:
        label = 'Chat';
        break;
      case 1:
        label = 'Search';
        break;
      case 2:
        label = 'Follow';
        break;
      default:
        label = 'Error';
        break;
    }
    return Material(
      child: StreamBuilder<DocumentSnapshot>(
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
          context.watch<ProfileManager>().updateUserData(loggedInUser);
          return Scaffold(
            appBar: AppBar(
              toolbarHeight: 80,
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(
                label,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: InkWell(
                    child: loggedInUser.avatarUrl == 'none'
                        ? Icon(
                            Icons.account_circle,
                            size: 40,
                            color: Colors.green[600],
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
                                    loggedInUser.avatarUrl!,
                                  ),
                                ).image,
                              ),
                            ),
                          ),
                    onTap: () {
                      context.read<ProfileManager>().onProfilePressed(true);
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
                context.read<AppStateManager>().goToTab(index);
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
      ),
    );
  }
}
