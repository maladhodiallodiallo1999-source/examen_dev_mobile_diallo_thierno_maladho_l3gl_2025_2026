import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:SunuTask/core/constants/app_colors.dart';
import 'package:SunuTask/providers/auth_provider.dart';
import 'package:SunuTask/providers/project_provider.dart';
import 'package:SunuTask/providers/task_provider.dart';
import 'package:SunuTask/screens/auth/login_screen.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final projectCount = context.watch<ProjectProvider>().projectCount;
    final taskCount = context.watch<TaskProvider>().tasks.length;

    if (user == null) return const SizedBox();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(children: [
        const SizedBox(height: 20),
        CircleAvatar(
          radius: 50,
          backgroundColor: AppColors.primary,
          child: Text(user.name[0].toUpperCase(),
              style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 16),
        Text(user.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 4),
        Text(user.email, style: const TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Text(
          'Membre depuis ${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}',
          style: const TextStyle(color: AppColors.textDisable, fontSize: 13),
        ),
        const SizedBox(height: 32),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _StatItem(value: '$projectCount', label: 'Projets'),
          _StatItem(value: '$taskCount', label: 'Tâches'),
        ]),
        const SizedBox(height: 40),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          icon: const Icon(Icons.logout),
          label: const Text('Se déconnecter', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          onPressed: () async {
            await context.read<AuthProvider>().logout();
            if (!context.mounted) return;
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false);
          },
        ),
      ]),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value, label;
  const _StatItem({required this.value, required this.label});
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
    Text(label, style: const TextStyle(color: AppColors.textSecondary)),
  ]);
}
