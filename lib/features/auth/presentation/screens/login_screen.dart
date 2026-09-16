import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';

/// Bare-bones on purpose — this is Phase 1's real design work.
/// Wired up just enough to prove the auth flow works end-to-end.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _submitting = false;
  bool _autovalidate = false;
  String? _error;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validatePhone(String? value) {
    final phone = value?.trim() ?? '';
    if (phone.isEmpty) return 'Phone number is required';
    if (!RegExp(r'^\+?[0-9]{7,15}$').hasMatch(phone)) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Password is required';
    if (password.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  Future<void> _submit() async {
    setState(() => _autovalidate = true);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref.read(authProvider.notifier).login(
            phoneNumber: _phoneController.text.trim(),
            password: _passwordController.text,
          );
    } catch (_) {
      // The notifier already worked out *why* it failed (bad
      // credentials, network, unreadable response) — show that
      // instead of always blaming the phone/password.
      final message = ref.read(authProvider).errorMessage;
      setState(
        () => _error = message ?? 'Login failed — check your phone and password',
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            autovalidateMode: _autovalidate
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/rider_icon.png',
                  height: 160,
                  // Reserve the space if the asset ever fails to load,
                  // so the form doesn't jump up the screen.
                  errorBuilder: (context, error, stack) =>
                      const SizedBox(height: 160),
                ),
                const SizedBox(height: 8),
                Text('Zaytoon Driver',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                      hintText: '+9627xxxxxxxx',
                      labelText: 'Phone number',
                      border: OutlineInputBorder()),
                  validator: _validatePhone,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  validator: _validatePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error)),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Log in'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
