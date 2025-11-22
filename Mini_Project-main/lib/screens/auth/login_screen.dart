import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design_system.dart';
import '../../core/theme.dart';
import '../../providers/user_provider.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../widgets/ambient_background.dart';
import '../home/main_navigation_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _showPassword = false;
  bool _rememberMe = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AmbientBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;
              final content = ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Flex(
                  direction: isWide ? Axis.horizontal : Axis.vertical,
                  crossAxisAlignment:
                      isWide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: isWide ? 6 : 0,
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: isWide ? 32 : 0,
                          bottom: isWide ? 0 : AppSpacing.xl,
                        ),
                        child: _buildHeroPanel(context),
                      ),
                    ),
                    Expanded(
                      flex: isWide ? 5 : 0,
                      child: Center(
                        child: _buildLoginCard(context),
                      ),
                    ),
                  ],
                ),
              );

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Center(child: content),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeroPanel(BuildContext context) {
    final stats = [
      {'value': '4.9/5', 'label': 'Avg. wellness score'},
      {'value': '+42%', 'label': 'Habit adherence'},
      {'value': '120K', 'label': 'Meals curated'},
    ];

    final pillars = [
      {'label': 'Personalized plans', 'icon': Icons.auto_graph},
      {'label': 'AI coach support', 'icon': Icons.psychology_alt_outlined},
      {'label': 'Clinically backed', 'icon': Icons.health_and_safety_outlined},
    ];

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: AppGradients.hero,
        borderRadius: BorderRadius.circular(34),
        boxShadow: const [
          BoxShadow(
            color: Color(0x403C6B90),
            blurRadius: 40,
            offset: Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: AppRadius.pill,
                ),
                child: const Text(
                  'AI Nutrition Concierge',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.help_outline, color: Colors.white70),
                tooltip: 'Need help?',
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Fuel your best self with calming precision',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(color: Colors.white, height: 1.2),
          ),
          const SizedBox(height: 12),
          const Text(
            'Intelligent meal planning, mindful rituals, and biomarker-aware guidance designed with dietitians.',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 22),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: stats
                .map(
                  (stat) => Container(
                    width: 150,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: AppRadius.lg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stat['value']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(stat['label']!, style: const TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 22),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: pillars
                .map(
                  (pillar) => Chip(
                    backgroundColor: Colors.white.withValues(alpha: 0.18),
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(pillar['icon'] as IconData, size: 18, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(pillar['label']! as String, style: const TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginCard(BuildContext context) {
    return AnimatedContainer(
      duration: AppDurations.regular,
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(28),
      decoration: AppStyles.cardDecoration.copyWith(
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A102A43),
            blurRadius: 30,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Welcome back 👋',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Sign in to sync your rituals, adaptive plans, and AI nudges.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: _isLoading ? null : () {},
              icon: const Icon(Icons.account_circle_outlined),
              label: const Text('Continue with Google'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.surfaceMuted,
                foregroundColor: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: _isLoading ? null : () {},
              icon: const Icon(Icons.apple),
              label: const Text('Continue with Apple'),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: const [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('or email login'),
                ),
                Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
              decoration: _inputDecoration(
                label: 'Email address',
                icon: Icons.mail_outline,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _passwordController,
              obscureText: !_showPassword,
              style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
              decoration: _inputDecoration(
                label: 'Password',
                icon: Icons.lock_outline,
                suffix: IconButton(
                  icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.primaryDark),
                  onPressed: () => setState(() => _showPassword = !_showPassword),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter your password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            Row(
              children: [
                Switch.adaptive(
                  value: _rememberMe,
                  onChanged: (value) => setState(() => _rememberMe = value),
                  thumbColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return Colors.white;
                    }
                    return AppColors.textSecondary;
                  }),
                  trackColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return AppColors.primary.withValues(alpha: 0.45);
                    }
                    return AppColors.surfaceAlt;
                  }),
                  trackOutlineColor: WidgetStateProperty.all(
                    AppColors.primary.withValues(alpha: 0.25),
                  ),
                ),
                const Text('Stay signed in'),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Password recovery coming soon.')),
                    );
                  },
                  child: const Text('Forgot password?'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            AnimatedSwitcher(
              duration: AppDurations.fast,
              child: _errorMessage == null
                  ? const SizedBox.shrink()
                  : Container(
                      key: ValueKey(_errorMessage),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.08),
                        borderRadius: AppRadius.md,
                      ),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w600),
                      ),
                    ),
            ),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton(
              onPressed: _isLoading ? null : _login,
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.6, color: Colors.white),
                    )
                  : const Text('Login'),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Voice login coming soon')),
                );
              },
              icon: const Icon(Icons.mic_none_rounded),
              label: const Text('Try voice assistant'),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildSignUpPrompt(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSignUpPrompt(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('New to the app? '),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SignupScreen()),
              );
            },
            child: const Text(
              'Create an account',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await AuthService.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (!result.success) {
      setState(() {
        _isLoading = false;
        _errorMessage = result.message;
      });
      return;
    }

    final userProfile = await UserService.fetchCurrentUser();

    if (userProfile == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load profile';
      });
      return;
    }

    ref.read(userProvider.notifier).setUser(userProfile);

    setState(() => _isLoading = false);

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      (_) => false,
    );
  }
  InputDecoration _inputDecoration({required String label, required IconData icon, Widget? suffix}) {
    final baseBorder = OutlineInputBorder(
      borderRadius: AppRadius.lg,
      borderSide: BorderSide(color: AppColors.textSecondary.withValues(alpha: 0.18)),
    );

    return InputDecoration(
      labelText: label,
      hintText: label,
      filled: true,
      fillColor: Colors.white,
      prefixIcon: Icon(icon, color: AppColors.primaryDark),
      suffixIcon: suffix,
      enabledBorder: baseBorder,
      focusedBorder: baseBorder.copyWith(
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: baseBorder.copyWith(borderSide: const BorderSide(color: AppColors.error)),
      focusedErrorBorder: baseBorder.copyWith(
        borderSide: BorderSide(color: AppColors.error.withValues(alpha: 0.9), width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    );
  }
}
