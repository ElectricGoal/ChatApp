import 'package:flutter/material.dart';
import 'package:chat_app/models/models.dart';
import 'package:chat_app/screens/screens.dart';
import 'package:provider/provider.dart';

class InitializeScreen extends StatefulWidget {
  const InitializeScreen({Key? key}) : super(key: key);

  static MaterialPage page() {
    return MaterialPage(
      name: AppPages.initalizePath,
      key: ValueKey(AppPages.initalizePath),
      child: const InitializeScreen(),
    );
  }

  @override
  _InitializeScreenState createState() => _InitializeScreenState();
}

class _InitializeScreenState extends State<InitializeScreen> {
  @override
  void didChangeDependencies() {
    Provider.of<AppStateManager>(context, listen: false).initializeApp();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 200,
              child: Image.asset(
                'assets/logo.png',
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
