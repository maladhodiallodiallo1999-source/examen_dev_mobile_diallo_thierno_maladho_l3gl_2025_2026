import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:SunuTask/core/constants/app_colors.dart';
import 'package:SunuTask/models/task.dart';
import 'package:SunuTask/providers/task_provider.dart';
import 'package:SunuTask/screens/tasks/task_form_screen.dart';

class TaskDetailScreen extends StatelessWidget {
  final Task task;
  const TaskDetailScreen({super.key, required this.task});

  Color _statusColor(TaskStatus s) {
    switch (s) {
      case TaskStatus.todo:       return AppColors.statusTodo;
      case TaskStatus.inProgress: return AppColors.statusInProgress;
      case TaskStatus.done:       return AppColors.statusDone;
    }
  }

  String _statusText(TaskStatus s) {
    switch (s) {
      case TaskStatus.todo:       return 'À faire';
      case TaskStatus.inProgress: return 'En cours';
      case TaskStatus.done:       return 'Terminée';
    }
  }

  String _priorityText(TaskPriority p) {
    switch (p) {
      case TaskPriority.high:   return 'Haute';
      case TaskPriority.medium: return 'Moyenne';
      case TaskPriority.low:    return 'Basse';
    }
  }

  Color _priorityColor(TaskPriority p) {
    switch (p) {
      case TaskPriority.high:   return AppColors.priorityHigh;
      case TaskPriority.medium: return AppColors.priorityMedium;
      case TaskPriority.low:    return AppColors.priorityLow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail de la tâche'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TaskFormScreen(task: task))),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outlined, color: AppColors.error),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Supprimer la tâche ?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer', style: TextStyle(color: AppColors.error))),
                  ],
                ),
              );
              if (confirm == true && context.mounted) {
                await context.read<TaskProvider>().deleteTask(task.id);
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // Titre
          Text(task.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 20),

          // Changement rapide de statut
          const Text('Statut', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: TaskStatus.values.map((s) {
              final isCurrent = task.status == s;
              return GestureDetector(
                onTap: () async {
                  await context.read<TaskProvider>().updateTaskStatus(task.id, s);
                  if (context.mounted) Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isCurrent ? _statusColor(s) : _statusColor(s).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _statusColor(s)),
                  ),
                  child: Text(_statusText(s), style: TextStyle(color: isCurrent ? Colors.white : _statusColor(s), fontWeight: FontWeight.w600, fontSize: 13)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Priorité
          const Text('Priorité', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: _priorityColor(task.priority).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Text(_priorityText(task.priority), style: TextStyle(color: _priorityColor(task.priority), fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 20),

          // Description
          if (task.description.isNotEmpty) ...[
            const Text('Description', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10)),
              child: Text(task.description, style: const TextStyle(color: AppColors.textPrimary, height: 1.5)),
            ),
            const SizedBox(height: 20),
          ],

          // Date d'échéance
          if (task.dueDate != null) ...[
            const Text("Date d'échéance", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
            ]),
          ],
        ]),
      ),
    );
  }
}