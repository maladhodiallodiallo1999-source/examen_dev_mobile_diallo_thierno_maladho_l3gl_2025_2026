import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sunu_task/providers/auth_provider.dart';
import 'package:sunu_task/providers/project_provider.dart';
import 'package:sunu_task/providers/task_provider.dart';
import 'package:sunu_task/screens/projects/project_detail_screen.dart';
import 'package:sunu_task/screens/projects/project_form_screen.dart';
import 'package:sunu_task/widgets/cards/project_card.dart';

/// Onglet Projets - Liste de tous les projets
class ProjectsTab extends StatelessWidget {
  const ProjectsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final projectProvider = context.watch<ProjectProvider>();
    final taskProvider = context.watch<TaskProvider>();
    final projects = projectProvider.projects;

    // Affichage pendant le chargement
    if (projectProvider.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    // État vide - aucun projet
    if (projects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 80, color: Colors.grey.shade300),
            SizedBox(height: 16),
            Text(
              'Aucun projet pour l\'instant',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Appuyez sur + pour créer un projet',
              style: TextStyle(color: Colors.grey.shade400),
            ),
          ],
        ),
      );
    }

    // Liste des projets
    return RefreshIndicator(
      onRefresh: () async {
        final user = context.read<AuthProvider>().currentUser;
        if (user == null) return;
        await context.read<ProjectProvider>().loadProjects(user.id);
      },
      child: ListView.builder(
        itemCount: projects.length,
        itemBuilder: (context, index) {
          final project = projects[index];

          // Compte les tâches de ce projet
          final int taskCount = taskProvider.tasks
              .where((t) => t.projectId == project.id)
              .length;

          return ProjectCard(
            project: project,
            taskCount: taskCount,
            // Navigation vers le détail du projet
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProjectDetailScreen(project: project),
                ),
              );
            },
            // Navigation vers le formulaire de modification
            onEdit: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProjectFormScreen(project: project),
                ),
              );
            },
            // Suppression avec confirmation
            onDelete: () async {
              final bool? confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Supprimer le projet'),
                  content: Text(
                    'Voulez-vous vraiment supprimer "${project.name}" ? '
                        'Toutes ses tâches seront supprimées.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text('Annuler'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text('Supprimer',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await context
                    .read<ProjectProvider>()
                    .deleteProject(project.id);
              }
            },
          );
        },
      ),
    );
  }
}