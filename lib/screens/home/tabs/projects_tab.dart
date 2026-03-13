import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:SunuTask/core/constants/app_colors.dart';
import 'package:SunuTask/providers/project_provider.dart';
import 'package:SunuTask/providers/task_provider.dart';
import 'package:SunuTask/widgets/cards/project_card.dart';
import 'package:SunuTask/screens/projects/project_form_screen.dart';
import 'package:SunuTask/screens/projects/project_detail_screen.dart';

class ProjectsTab extends StatelessWidget {
  const ProjectsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final projectProvider = context.watch<ProjectProvider>();

    if (projectProvider.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (projectProvider.projects.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.folder_outlined, size: 80, color: AppColors.textDisable),
          const SizedBox(height: 16),
          const Text('Aucun projet', style: TextStyle(fontSize: 18, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          const Text('Appuyez sur + pour créer votre premier projet', style: TextStyle(color: AppColors.textDisable)),
        ]),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: projectProvider.projects.length,
      itemBuilder: (context, index) {
        final project = projectProvider.projects[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ProjectCard(
            project: project,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProjectDetailScreen(project: project))),
            onEdit: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProjectFormScreen(project: project))),
            onDelete: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Supprimer le projet ?'),
                  content: Text('Le projet "${project.name}" et toutes ses tâches seront supprimés.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer', style: TextStyle(color: AppColors.error))),
                  ],
                ),
              );
              if (confirm == true && context.mounted) {
                await context.read<ProjectProvider>().deleteProject(project.id);
                context.read<TaskProvider>().clearTasks();
              }
            },
          ),
        );
      },
    );
  }
}
