import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:chat_app/models/models.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';

import 'app_pages.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    Key? key,
  }) : super(key: key);

  static MaterialPage page() {
    return MaterialPage(
      name: AppPages.registerPath,
      key: ValueKey(AppPages.registerPath),
      child: const RegisterScreen(),
    );
  }

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final Color color = const Color.fromRGBO(64, 143, 77, 1);

  final TextStyle focusedStyle =
      const TextStyle(color: Colors.green, height: 1);

  final _formKey = GlobalKey<FormState>();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool showSpinner = false;

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  final _auth = FirebaseAuth.instance;

  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          leading: GestureDetector(
            child: const Icon(
              Icons.chevron_left,
              size: 35,
            ),
            onTap: () {
              Navigator.pop(context, true);
            },
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                headerField(),
                const SizedBox(height: 70),
                firstNameField(),
                const SizedBox(height: 20),
                lastNameField(),
                const SizedBox(height: 20),
                emailField(),
                const SizedBox(height: 20),
                passwordField(),
                const SizedBox(height: 20),
                confirmPasswordField(),
                const SizedBox(height: 30),
                buildSignUpButton(context),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget headerField() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //const SizedBox(height: 60),
        Text(
          'Sign Up.',
          style: TextStyle(
            fontSize: 50,
            fontWeight: FontWeight.bold,
            color: Colors.green[700],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: const [
            Expanded(
              child: Text(
                'Create your account today',
                style: TextStyle(
                  fontSize: 18,
                  //fontWeight: FontWeight.bold,
                  //color: Colors.green[700],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildSignUpButton(BuildContext context) {
    return SizedBox(
      height: 55,
      child: MaterialButton(
        color: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        child: const Text(
          'Sign up',
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () async {
          setState(() {
            showSpinner = true;
          });
          if (!_formKey.currentState!.validate()) {
            return;
          }
          signUp(emailController.text, passwordController.text);
        },
      ),
    );
  }

  Widget firstNameField() {
    return TextFormField(
      autofocus: false,
      controller: firstNameController,
      validator: (value) {
        RegExp regex = RegExp(r'^.{2,}$');
        if (value!.isEmpty) {
          return ("First Name cannot be Empty");
        }
        if (!regex.hasMatch(value)) {
          return ("Enter Valid name(Min: 2 Characters)");
        }
        return null;
      },
      onSaved: (value) {
        firstNameController.text = value!;
      },
      textInputAction: TextInputAction.next,
      cursorColor: color,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.green,
            width: 2,
          ),
        ),
        hintText: 'First name',
        hintStyle: focusedStyle,
        prefixIcon: Icon(
          Icons.account_circle,
          color: Colors.green[400],
        ),
      ),
    );
  }

  Widget lastNameField() {
    return TextFormField(
      autofocus: false,
      controller: lastNameController,
      validator: (value) {
        if (value!.isEmpty) {
          return ("Last Name cannot be Empty");
        }
        return null;
      },
      onSaved: (value) {
        lastNameController.text = value!;
      },
      textInputAction: TextInputAction.next,
      cursorColor: color,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.green,
            width: 2,
          ),
        ),
        hintText: 'Last name',
        hintStyle: focusedStyle,
        prefixIcon: Icon(
          Icons.account_circle,
          color: Colors.green[400],
        ),
      ),
    );
  }

  Widget emailField() {
    return TextFormField(
      autofocus: false,
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value!.isEmpty) {
          return ("Please Enter Your Email");
        }
        // reg expression for email validation
        if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]").hasMatch(value)) {
          return ("Please Enter a valid email");
        }
        return null;
      },
      onSaved: (value) {
        emailController.text = value!;
      },
      textInputAction: TextInputAction.next,
      cursorColor: color,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.green,
            width: 2,
          ),
        ),
        hintText: 'Email',
        hintStyle: focusedStyle,
        prefixIcon: Icon(
          Icons.mail,
          color: Colors.green[400],
        ),
      ),
    );
  }

  Widget passwordField() {
    return TextFormField(
      autofocus: false,
      controller: passwordController,
      obscureText: true,
      validator: (value) {
        RegExp regex = RegExp(r'^.{6,}$');
        if (value!.isEmpty) {
          return ("Password is required for login");
        }
        if (!regex.hasMatch(value)) {
          return ("Enter Valid Password(Min: 6 Characters)");
        }
        return null;
      },
      onSaved: (value) {
        passwordController.text = value!;
      },
      textInputAction: TextInputAction.done,
      cursorColor: color,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.green,
            width: 2,
          ),
        ),
        hintText: 'Password',
        hintStyle: focusedStyle,
        prefixIcon: Icon(
          Icons.vpn_key,
          color: Colors.green[400],
        ),
      ),
    );
  }

  Widget confirmPasswordField() {
    return TextFormField(
      autofocus: false,
      controller: confirmPasswordController,
      obscureText: true,
      validator: (value) {
        if (confirmPasswordController.text != passwordController.text) {
          return "Password don't match";
        }
        return null;
      },
      onSaved: (value) {
        confirmPasswordController.text = value!;
      },
      textInputAction: TextInputAction.done,
      cursorColor: color,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.green,
            width: 2,
          ),
        ),
        hintText: 'Confirm password',
        hintStyle: focusedStyle,
        prefixIcon: Icon(
          Icons.vpn_key,
          color: Colors.green[400],
        ),
      ),
    );
  }

  void signUp(String email, String password) async {
    if (_formKey.currentState!.validate()) {
      try {
        await _auth
            .createUserWithEmailAndPassword(email: email, password: password)
            .then((value) => {postDetailsToFirestore()});
        Provider.of<AppStateManager>(context, listen: false).register();
        setState(() {
          showSpinner = false;
        });
      } on FirebaseAuthException catch (error) {
        switch (error.code) {
          case "invalid-email":
            errorMessage = "Your email address appears to be malformed.";
            break;
          case "wrong-password":
            errorMessage = "Your password is wrong.";
            break;
          case "user-not-found":
            errorMessage = "User with this email doesn't exist.";
            break;
          case "user-disabled":
            errorMessage = "User with this email has been disabled.";
            break;
          case "too-many-requests":
            errorMessage = "Too many requests";
            break;
          case "operation-not-allowed":
            errorMessage = "Signing in with Email and Password is not enabled.";
            break;
          default:
            errorMessage = "An undefined Error happened.";
        }
        Fluttertoast.showToast(msg: errorMessage!);
        setState(() {
          showSpinner = false;
        });
        // ignore: avoid_print
        print(error.code);
      }
    }
  }

  postDetailsToFirestore() async {
    // calling our firestore
    // calling our user model
    // sedning these values

    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    User? currentUser = _auth.currentUser;

    UserModel user = UserModel(
      uid: currentUser!.uid,
      firstName: firstNameController.text,
      lastName: lastNameController.text,
      email: currentUser.email,
      avatarUrl: 'none',
    );

    await firebaseFirestore
        .collection("users")
        .doc(currentUser.uid)
        .set(user.toJson());
    Fluttertoast.showToast(msg: "Account created successfully");
  }
}
