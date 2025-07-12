import 'package:flutter/material.dart';
import 'package:nasa_apod/data/firebase.dart';
import 'package:get/route_manager.dart';
import 'package:nasa_apod/ui/widgets/organisms/layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Layout(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width / 2,
            child: TextField(
              controller: _emailController,
              decoration: const InputDecoration(hintText: 'Email'),
            ),
          ),
          const SizedBox(
            height: 30.0,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width / 2,
            child: TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'Password',
              ),
            ),
          ),
          const SizedBox(
            height: 30.0,
          ),
          ElevatedButton(
            onPressed: () async {
              final message = await AuthService().login(
                email: _emailController.text,
                password: _passwordController.text,
              );
              if (message!.contains('Success')) {
                Get.offAllNamed("/");
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                ),
              );
            },
            child: const Text('Login'),
          ),
          const SizedBox(
            height: 30.0,
          ),
          TextButton(
            onPressed: () {
              Get.toNamed('/register');
            },
            child: const Text('Create Account'),
          ),
        ],
      ),
    );
  }
}
