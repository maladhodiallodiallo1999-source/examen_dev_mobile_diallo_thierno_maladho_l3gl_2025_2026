import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:SunuTask/core/constants/app_colors.dart';
import 'package:SunuTask/core/constants/app_strings.dart';
import 'package:SunuTask/providers/auth_provider.dart';
import 'package:SunuTask/widgets/common/custom_button.dart';
import 'package:SunuTask/widgets/common/custom_text_field.dart';
import 'package:SunuTask/screens/home/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? "Erreur lors de l'inscription"),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.register)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 16),

                CustomTextField(
                  label: AppStrings.name,
                  controller: _nameController,
                  prefixIcon: Icons.person_outlined,
                  validator: (v) {
                    if (v == null || v.isEmpty) return AppStrings.nameRequired;
                    if (v.trim().length < 2) return 'Minimum 2 caractères';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: AppStrings.email,
                  controller: _emailController,
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return AppStrings.emailRequired;
                    if (!v.contains('@') || !v.contains('.')) return AppStrings.invalidEmail;
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: AppStrings.password,
                  controller: _passwordController,
                  prefixIcon: Icons.lock_outlined,
                  obscureText: true,
                  validator: (v) {
                    if (v == null || v.isEmpty) return AppStrings.passwordRequired;
                    if (v.length < 6) return AppStrings.passwordTooShort;
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: AppStrings.confirmPassword,
                  controller: _confirmController,
                  prefixIcon: Icons.lock_outlined,
                  obscureText: true,
                  validator: (v) {
                    if (v != _passwordController.text) return AppStrings.passwordsNotMatch;
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                CustomButton(
                  text: AppStrings.register,
                  onPressed: isLoading ? null : _handleRegister,
                  isLoading: isLoading,
                ),
                const SizedBox(height: 16),

                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    '${AppStrings.haveAccount} ${AppStrings.login}',
                    style: const TextStyle(color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
