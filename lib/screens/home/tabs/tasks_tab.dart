import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sunu_task/models/task.dart';
import 'package:sunu_task/providers/task_provider.dart';
import 'package:sunu_task/screens/tasks/task_detail_screen.dart';
import 'package:sunu_task/widgets/cards/task_card.dart';

/// Onglet Tâches - Liste de toutes les tâches avec filtres
class TasksTab extends StatelessWidget {
  const TasksTab({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final tasks = taskProvider.tasks;

    return Column(
      children: [
        // Barre de filtres
        _buildFilters(context, taskProvider),

        // Liste des tâches
        Expanded(
          child: taskProvider.isLoading
              ? Center(child: CircularProgressIndicator())
              : tasks.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return TaskCard(
                task: task,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          TaskDetailScreen(task: task),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  /// Barre de filtres par statut
  Widget _buildFilters(BuildContext context, TaskProvider taskProvider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Filtre Tous
          _buildFilterChip(
            context,
            label: 'Tous',
            isSelected: taskProvider.tasks.length ==
                taskProvider.tasks.length,
            onTap: () => taskProvider.clearFilters(),
          ),
          SizedBox(width: 8),
          // Filtre À faire
          _buildFilterChip(
            context,
            label: 'À faire',
            isSelected: false,
            color: Colors.orange,
            onTap: () =>
                taskProvider.setStatusFilter(TaskStatus.todo),
          ),
          SizedBox(width: 8),
          // Filtre En cours
          _buildFilterChip(
            context,
            label: 'En cours',
            isSelected: false,
            color: Colors.blue,
            onTap: () =>
                taskProvider.setStatusFilter(TaskStatus.inProgress),
          ),
          SizedBox(width: 8),
          // Filtre Terminées
          _buildFilterChip(
            context,
            label: 'Terminées',
            isSelected: false,
            color: Colors.green,
            onTap: () =>
                taskProvider.setStatusFilter(TaskStatus.done),
          ),
        ],
      ),
    );
  }

  /// Chip de filtre réutilisable
  Widget _buildFilterChip(
      BuildContext context, {
        required String label,
        required bool isSelected,
        Color? color,
        required VoidCallback onTap,
      }) {
    final Color chipColor = color ?? Theme.of(context).primaryColor;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? chipColor : chipColor.withAlpha(20),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: chipColor.withAlpha(100)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : chipColor,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  /// État vide
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.task, size: 80, color: Colors.grey.shade300),
          SizedBox(height: 16),
          Text(
            'Aucune tâche pour l\'instant',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Créez un projet et ajoutez des tâches',
            style: TextStyle(color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}