import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:SunuTask/core/constants/app_colors.dart';
import 'package:SunuTask/models/task.dart';
import 'package:SunuTask/providers/auth_provider.dart';
import 'package:SunuTask/providers/task_provider.dart';
import 'package:SunuTask/widgets/cards/task_card.dart';
import 'package:SunuTask/screens/tasks/task_detail_screen.dart';

class TasksTab extends StatefulWidget {
  const TasksTab({super.key});
  @override
  State<TasksTab> createState() => _TasksTabState();
}

class _TasksTabState extends State<TasksTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) context.read<TaskProvider>().loadAllTasks(user.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final tasks = taskProvider.tasks;

    return Column(children: [
      // Barre de filtres
      Container(
        color: AppColors.surface,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(children: [
          const Text('Filtre : ', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(width: 8),
          DropdownButton<TaskStatus?>(
            value: null,
            hint: const Text('Statut', style: TextStyle(fontSize: 13)),
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(value: null, child: Text('Tous')),
              DropdownMenuItem(value: TaskStatus.todo, child: Text('À faire')),
              DropdownMenuItem(value: TaskStatus.inProgress, child: Text('En cours')),
              DropdownMenuItem(value: TaskStatus.done, child: Text('Terminé')),
            ],
            onChanged: (v) => taskProvider.setStatusFilter(v),
          ),
          const SizedBox(width: 12),
          DropdownButton<TaskPriority?>(
            value: null,
            hint: const Text('Priorité', style: TextStyle(fontSize: 13)),
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(value: null, child: Text('Toutes')),
              DropdownMenuItem(value: TaskPriority.high, child: Text('Haute')),
              DropdownMenuItem(value: TaskPriority.medium, child: Text('Moyenne')),
              DropdownMenuItem(value: TaskPriority.low, child: Text('Basse')),
            ],
            onChanged: (v) => taskProvider.setPriorityFilter(v),
          ),
        ]),
      ),
      Expanded(
        child: tasks.isEmpty
            ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.check_circle_outline, size: 80, color: AppColors.textDisable),
                SizedBox(height: 16),
                Text('Aucune tâche', style: TextStyle(fontSize: 18, color: AppColors.textSecondary)),
              ]))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: tasks.length,
                itemBuilder: (context, i) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TaskCard(
                    task: tasks[i],
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TaskDetailScreen(task: tasks[i]))),
                  ),
                ),
              ),
      ),
    ]);
  }
}
