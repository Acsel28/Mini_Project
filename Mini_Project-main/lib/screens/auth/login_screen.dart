import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../providers/user_provider.dart';
import '../home/main_navigation_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  String? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Welcome Back",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),

            const SizedBox(height: 20),

            if (error != null)
              Text(
                error!,
                style: const TextStyle(color: Colors.red),
              ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : _login,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Login"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _login() async {
    setState(() {
      loading = true;
      error = null;
    });

    // 1️⃣ TRY LOGIN
    final result = await AuthService.login(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    if (!result.success) {
      setState(() {
        loading = false;
        error = result.message;
      });
      return;
    }

    // 2️⃣ GET PROFILE FROM BACKEND
    final userProfile = await UserService.fetchCurrentUser();

    if (userProfile == null) {
      setState(() {
        loading = false;
        error = "Failed to load profile";
      });
      return;
    }

    // 3️⃣ SAVE INTO PROVIDER
    ref.read(userProvider.notifier).setUser(userProfile);

    // 4️⃣ NAVIGATE TO HOME
    setState(() => loading = false);

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        (_) => false,
      );
    }
  }
}
