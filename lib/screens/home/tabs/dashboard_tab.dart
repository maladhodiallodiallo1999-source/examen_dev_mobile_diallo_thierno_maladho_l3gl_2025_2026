import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sunu_task/models/task.dart';
import 'package:sunu_task/providers/auth_provider.dart';
import 'package:sunu_task/providers/project_provider.dart';
import 'package:sunu_task/providers/task_provider.dart';
import 'package:sunu_task/widgets/cards/project_card.dart';

/// Onglet Dashboard - Vue d'ensemble de l'application
class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  /// Message de bienvenue selon l'heure
  String _getGreeting() {
    final int hour = DateTime.now().hour;
    if (hour < 12) return 'Bonjour';
    if (hour < 18) return 'Bon après-midi';
    return 'Bonsoir';
  }

  @override
  Widget build(BuildContext context) {
    // Écoute les providers pour se mettre à jour automatiquement
    final auth = context.watch<AuthProvider>();
    final projectProvider = context.watch<ProjectProvider>();
    final taskProvider = context.watch<TaskProvider>();

    final user = auth.currentUser;
    final projects = projectProvider.projects;
    final taskCounts = taskProvider.taskCountByStatus;

    return RefreshIndicator(
      // Rafraîchir les données en tirant vers le bas
      onRefresh: () async {
        if (user == null) return;
        await context.read<ProjectProvider>().loadProjects(user.id);
        await context.read<TaskProvider>().loadTasksByUser(user.id);
      },
      child: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Message de bienvenue
          Text(
            '${_getGreeting()}, ${user?.name ?? ''} 👋',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 4),

          Text(
            'Voici un résumé de vos activités',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),

          SizedBox(height: 24),

          // Titre section statistiques
          Text(
            'Statistiques',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 12),

          // Cartes de statistiques
          Row(
            children: [
              // Nombre de projets
              Expanded(
                child: _buildStatCard(
                  context,
                  title: 'Projets',
                  value: projects.length.toString(),
                  icon: Icons.folder,
                  color: Colors.blue,
                ),
              ),
              SizedBox(width: 12),
              // Tâches à faire
              Expanded(
                child: _buildStatCard(
                  context,
                  title: 'À faire',
                  value: (taskCounts[TaskStatus.todo] ?? 0).toString(),
                  icon: Icons.radio_button_unchecked,
                  color: Colors.orange,
                ),
              ),
            ],
          ),

          SizedBox(height: 12),

          Row(
            children: [
              // Tâches en cours
              Expanded(
                child: _buildStatCard(
                  context,
                  title: 'En cours',
                  value: (taskCounts[TaskStatus.inProgress] ?? 0).toString(),
                  icon: Icons.timelapse,
                  color: Colors.blue,
                ),
              ),
              SizedBox(width: 12),
              // Tâches terminées
              Expanded(
                child: _buildStatCard(
                  context,
                  title: 'Terminées',
                  value: (taskCounts[TaskStatus.done] ?? 0).toString(),
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
              ),
            ],
          ),

          SizedBox(height: 24),

          // Projets récents
          Text(
            'Projets récents',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 12),

          // Liste des projets récents (max 3)
          if (projects.isEmpty)
            Center(
              child: Column(
                children: [
                  SizedBox(height: 24),
                  Icon(Icons.folder_open,
                      size: 60, color: Colors.grey.shade300),
                  SizedBox(height: 12),
                  Text(
                    'Aucun projet pour l\'instant',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            )
          else
          // Affiche les 3 derniers projets
            ...projects.take(3).map((project) {
              final int taskCount = taskProvider.tasks
                  .where((t) => t.projectId == project.id)
                  .length;
              return ProjectCard(
                project: project,
                taskCount: taskCount,
              );
            }),
        ],
      ),
    );
  }

  /// Carte de statistique réutilisable
  Widget _buildStatCard(
      BuildContext context, {
        required String title,
        required String value,
        required IconData icon,
        required Color color,
      }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}