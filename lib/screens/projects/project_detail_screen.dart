import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:SunuTask/core/constants/app_colors.dart';
import 'package:SunuTask/models/project.dart';
import 'package:SunuTask/models/task.dart';
import 'package:SunuTask/providers/project_provider.dart';
import 'package:SunuTask/providers/task_provider.dart';
import 'package:SunuTask/widgets/cards/task_card.dart';
import 'package:SunuTask/screens/projects/project_form_screen.dart';
import 'package:SunuTask/screens/tasks/task_form_screen.dart';
import 'package:SunuTask/screens/tasks/task_detail_screen.dart';

class ProjectDetailScreen extends StatefulWidget {
  final Project project;
  const ProjectDetailScreen({super.key, required this.project});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTasks(widget.project.id);
    });
  }

  Future<void> _deleteProject() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer le projet ?'),
        content: const Text('Le projet et toutes ses tâches seront supprimés définitivement.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer', style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await context.read<ProjectProvider>().deleteProject(widget.project.id);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectColor = Color(int.parse(widget.project.color));
    final taskProvider = context.watch<TaskProvider>();
    final tasks = taskProvider.tasks;
    final counts = taskProvider.taskCountByStatus;

    return Scaffold(
      body: CustomScrollView(slivers: [
        // En-tête coloré
        SliverAppBar(
          expandedHeight: 180,
          pinned: true,
          backgroundColor: projectColor,
          foregroundColor: Colors.white,
          actions: [
            IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProjectFormScreen(project: widget.project)))),
            IconButton(icon: const Icon(Icons.delete_outlined), onPressed: _deleteProject),
          ],
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            title: Text(widget.project.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            background: Container(
              color: projectColor,
              padding: const EdgeInsets.fromLTRB(16, 80, 16, 50),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(widget.project.description, style: const TextStyle(color: Colors.white70, fontSize: 13)),
              ),
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Chips de statistiques
              Wrap(spacing: 8, children: [
                Chip(label: Text('${counts[TaskStatus.todo] ?? 0} à faire'), backgroundColor: AppColors.statusTodo.withOpacity(0.1), labelStyle: const TextStyle(color: AppColors.statusTodo, fontSize: 12)),
                Chip(label: Text('${counts[TaskStatus.inProgress] ?? 0} en cours'), backgroundColor: AppColors.statusInProgress.withOpacity(0.1), labelStyle: const TextStyle(color: AppColors.statusInProgress, fontSize: 12)),
                Chip(label: Text('${counts[TaskStatus.done] ?? 0} terminée(s)'), backgroundColor: AppColors.statusDone.withOpacity(0.1), labelStyle: const TextStyle(color: AppColors.statusDone, fontSize: 12)),
              ]),
              const SizedBox(height: 8),
              Text(
                'Créé le ${widget.project.createdAt.day}/${widget.project.createdAt.month}/${widget.project.createdAt.year}',
                style: const TextStyle(color: AppColors.textDisable, fontSize: 12),
              ),
              const SizedBox(height: 20),
              const Text('Tâches', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ]),
          ),
        ),

        if (taskProvider.isLoading)
          const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator(color: AppColors.primary)))
        else if (tasks.isEmpty)
          const SliverToBoxAdapter(
            child: Center(child: Padding(
              padding: EdgeInsets.all(40),
              child: Column(children: [
                Icon(Icons.check_circle_outline, size: 60, color: AppColors.textDisable),
                SizedBox(height: 12),
                Text('Aucune tâche pour ce projet', style: TextStyle(color: AppColors.textSecondary)),
                Text('Appuyez sur + pour en ajouter', style: TextStyle(color: AppColors.textDisable, fontSize: 13)),
              ]),
            )),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: TaskCard(
                  task: tasks[i],
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TaskDetailScreen(task: tasks[i]))),
                ),
              ),
              childCount: tasks.length,
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ]),

      floatingActionButton: FloatingActionButton(
        backgroundColor: projectColor,
        foregroundColor: Colors.white,
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TaskFormScreen(projectId: widget.project.id))),
        child: const Icon(Icons.add),
      ),
    );
  }
}
