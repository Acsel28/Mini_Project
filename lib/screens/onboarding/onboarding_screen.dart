// lib/screens/onboarding/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/auth_service.dart';
import '../../services/profile_service.dart';
import '../../services/storage_service.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _page = 0;

  // Account fields
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _nameCtrl = TextEditingController();

  // Profile fields
  final TextEditingController _ageCtrl = TextEditingController();
  final TextEditingController _heightCtrl = TextEditingController();
  final TextEditingController _weightCtrl = TextEditingController();
  String? _gender;

  // Preferences
  String _diet = 'none';
  String? _diseaseProfileId;

  bool _loading = false;

  @override
  void dispose() {
    _pageController.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_page < 2) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _prevPage() {
    if (_page > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  // FINISH: always register (auto-register), login option exposed separately below
  Future<void> _finishOnboarding() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    final name = _nameCtrl.text.trim();

    if (email.isEmpty || password.length < 6 || name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please fill email, name and a password (min 6 chars).')));
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      debugPrint('Onboarding: starting register for $email');

      // 1) Register - AuthService registers and stores tokens locally
      await AuthService.register(email, password, name: name);
      debugPrint('Onboarding: register returned, tokens should be stored');

      // 2) Let auth provider refresh current user state (optional)
      await ref.read(authProvider.notifier).loadCurrentUser();
      debugPrint('Onboarding: loadCurrentUser done, authState: ${ref.read(authProvider)}');

      // 3) Build profile payload
      final profilePayload = <String, dynamic>{
        'name': name,
        'age': _ageCtrl.text.isNotEmpty ? int.tryParse(_ageCtrl.text) : null,
        'gender': _gender,
        'height_cm': _heightCtrl.text.isNotEmpty ? double.tryParse(_heightCtrl.text) : null,
        'weight_kg': _weightCtrl.text.isNotEmpty ? double.tryParse(_weightCtrl.text) : null,
        'language': 'en',
        'target_calories': null,
        'disease_profile_id': _diseaseProfileId,
        'accessibility_flags': null,
      };

      debugPrint('Onboarding: sending profile payload: $profilePayload');

      // 4) Update profile on server (requires access token stored by AuthService)
      final resp = await ProfileService.updateProfile(profilePayload);
      debugPrint('Onboarding: profile update status ${resp.statusCode}, body: ${resp.body}');

      // 5) Mark onboarding done
      await StorageService.setFirstTime(false);
      debugPrint('Onboarding: setFirstTime(false) done');

      // 6) Navigate to home
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/home');
    } catch (e, st) {
      debugPrint('Onboarding/register failed: $e\n$st');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Widget _pageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) => AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 6),
        width: _page == i ? 18 : 10,
        height: 10,
        decoration: BoxDecoration(
          color: _page == i ? AppColors.accent1 : Colors.white.withOpacity(0.4),
          borderRadius: BorderRadius.circular(10),
        ),
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: _page > 0
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _prevPage,
            )
          : null,
      actions: [
        TextButton(
          onPressed: () {
            final email = _emailCtrl.text.trim();
            Navigator.of(context).pushReplacementNamed(
              '/login',
              arguments: {'email': email},
            );
          },
          child: const Text(
            'Login',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    ),

      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            _pageIndicator(),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (idx) => setState(() { _page = idx; }),
                children: [
                  _accountStep(),
                  _profileStep(),
                  _preferencesStep(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _loading
                  ? const SizedBox(height: 48, child: Center(child: CircularProgressIndicator()))
                  : Column(
                      children: [
                        Row(
                          children: [
                            if (_page < 2)
                              Expanded(child: ElevatedButton(onPressed: _nextPage, child: const Text('Next')))
                            else
                              Expanded(child: ElevatedButton(onPressed: _finishOnboarding, child: const Text('Finish & Register'))),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (_page == 2)
                          TextButton(
                            onPressed: () {
                              final email = _emailCtrl.text.trim();
                              Navigator.of(context).pushReplacementNamed('/login', arguments: {'email': email});
                            },
                            child: const Text('Already have an account? Login'),
                          ),
                      ],
                    ),
            )
          ],
        ),
      ),
    );
  }

  Widget _accountStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          const Text('Create your account', style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Full name', filled: true),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email', filled: true),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _passwordCtrl,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Password (min 6 chars)', filled: true),
          ),
        ],
      ),
    );
  }

  Widget _profileStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
      child: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 12),
          const Text('About you', style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(controller: _ageCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Age', filled: true)),
          const SizedBox(height: 12),
          TextField(controller: _heightCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Height (cm)', filled: true)),
          const SizedBox(height: 12),
          TextField(controller: _weightCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Weight (kg)', filled: true)),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _gender,
            decoration: const InputDecoration(labelText: 'Gender', filled: true),
            items: const [
              DropdownMenuItem(value: 'male', child: Text('Male')),
              DropdownMenuItem(value: 'female', child: Text('Female')),
              DropdownMenuItem(value: 'other', child: Text('Other')),
            ],
            onChanged: (v) => setState(() { _gender = v; }),
          ),
        ]),
      ),
    );
  }

  Widget _preferencesStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 12),
        const Text('Preferences', style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        const Text('Diet type', style: TextStyle(color: Colors.white70)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(label: const Text('None'), selected: _diet == 'none', onSelected: (_) => setState(() { _diet = 'none'; })),
            ChoiceChip(label: const Text('Vegetarian'), selected: _diet == 'vegetarian', onSelected: (_) => setState(() { _diet = 'vegetarian'; })),
            ChoiceChip(label: const Text('Vegan'), selected: _diet == 'vegan', onSelected: (_) => setState(() { _diet = 'vegan'; })),
            ChoiceChip(label: const Text('Keto'), selected: _diet == 'keto', onSelected: (_) => setState(() { _diet = 'keto'; })),
          ],
        ),
        const SizedBox(height: 16),
        const Text('Medical conditions (optional)', style: TextStyle(color: Colors.white70)),
        const SizedBox(height: 8),
        // For MVP we keep this free text; later replace with curated disease_profile selection
        TextFormField(
          initialValue: _diseaseProfileId,
          onChanged: (v) => setState(() { _diseaseProfileId = v.isNotEmpty ? v : null; }),
          decoration: const InputDecoration(hintText: 'e.g., diabetes_type2', filled: true),
        ),
        const SizedBox(height: 24),
        const Text('When you tap Finish we will create your account and save this profile.', style: TextStyle(color: Colors.white70)),
      ]),
    );
  }
}
