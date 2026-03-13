import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:SunuTask/core/constants/app_colors.dart';
import 'package:SunuTask/models/task.dart';
import 'package:SunuTask/providers/auth_provider.dart';
import 'package:SunuTask/providers/project_provider.dart';
import 'package:SunuTask/providers/task_provider.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  String _getGreeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Bonjour';
    if (h < 18) return 'Bon après-midi';
    return 'Bonsoir';
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final projectProvider = context.watch<ProjectProvider>();
    final taskProvider = context.watch<TaskProvider>();

    return RefreshIndicator(
      onRefresh: () async {
        if (user != null) {
          await projectProvider.loadProjects(user.id);
          await taskProvider.loadAllTasks(user.id);
        }
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            // Message de bienvenue
            Text(
              '${_getGreeting()}, ${user?.name ?? ''} 👋',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            const Text('Voici votre tableau de bord', style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 24),

            // Statistiques
            const Text('Statistiques', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _StatCard(title: 'Projets', value: '${projectProvider.projectCount}', icon: Icons.folder_outlined, color: AppColors.primary)),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(title: 'À faire', value: '${taskProvider.taskCountByStatus[TaskStatus.todo] ?? 0}', icon: Icons.radio_button_unchecked, color: AppColors.statusTodo)),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _StatCard(title: 'En cours', value: '${taskProvider.taskCountByStatus[TaskStatus.inProgress] ?? 0}', icon: Icons.pending_outlined, color: AppColors.statusInProgress)),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(title: 'Terminées', value: '${taskProvider.taskCountByStatus[TaskStatus.done] ?? 0}', icon: Icons.check_circle_outline, color: AppColors.statusDone)),
            ]),
            const SizedBox(height: 28),

            // Projets récents
            const Text('Projets récents', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            if (projectProvider.projects.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(children: [
                    Icon(Icons.folder_outlined, size: 50, color: Colors.grey.shade400),
                    const SizedBox(height: 8),
                    const Text('Aucun projet', style: TextStyle(color: AppColors.textSecondary)),
                  ]),
                ),
              )
            else
              ...projectProvider.projects.take(3).map((p) {
                final color = Color(int.parse(p.color));
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border(left: BorderSide(color: color, width: 4)),
                  ),
                  child: Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      if (p.description.isNotEmpty)
                        Text(p.description, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ])),
                  ]),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(children: [
        Icon(icon, color: color, size: 26),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ]),
      ]),
    );
  }
}
