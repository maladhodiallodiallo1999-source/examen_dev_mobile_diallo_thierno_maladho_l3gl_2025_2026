import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sunu_task/models/project.dart';
import 'package:sunu_task/providers/project_provider.dart';
import 'package:sunu_task/providers/task_provider.dart';
import 'package:sunu_task/screens/projects/project_form_screen.dart';
import 'package:sunu_task/screens/tasks/task_form_screen.dart';
import 'package:sunu_task/widgets/cards/task_card.dart';
import 'package:sunu_task/screens/tasks/task_detail_screen.dart';
import 'package:sunu_task/models/task.dart';
/// Écran de détail d'un projet avec ses tâches
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
    // Charger les tâches du projet au démarrage
    context.read<TaskProvider>().loadTasks(widget.project.id);
  }

  /// Supprime le projet avec confirmation
  Future<void> _deleteProject() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Supprimer le projet'),
        content: Text(
          'Voulez-vous vraiment supprimer "${widget.project.name}" ? '
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

    if (confirm == true && mounted) {
      await context.read<ProjectProvider>().deleteProject(widget.project.id);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectColor = Color(widget.project.color);
    final taskProvider = context.watch<TaskProvider>();
    final tasks = taskProvider.tasks;
    final taskCounts = taskProvider.taskCountByStatus;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.project.name),
        actions: [
          // Bouton modifier
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ProjectFormScreen(project: widget.project),
                ),
              );
            },
          ),
          // Bouton supprimer
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: _deleteProject,
          ),
        ],
      ),

      body: ListView(
        children: [
          // En-tête coloré
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(24),
            color: projectColor.withAlpha(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icône et nom
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: projectColor.withAlpha(50),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(Icons.folder,
                          color: projectColor, size: 32),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.project.name,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (widget.project.description != null)
                            Text(
                              widget.project.description!,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16),

                // Date de création
                Text(
                  'Créé le ${_formatDate(widget.project.createdAt)}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),

                SizedBox(height: 16),

                // Chips de statistiques des tâches
                Wrap(
                  spacing: 8,
                  children: [
                    _buildChip(
                      'À faire: ${taskCounts[TaskStatus.todo] ?? 0}',
                      Colors.orange,
                    ),
                    _buildChip(
                      'En cours: ${taskCounts[TaskStatus.inProgress] ?? 0}',
                      Colors.blue,
                    ),
                    _buildChip(
                      'Terminées: ${taskCounts[TaskStatus.done] ?? 0}',
                      Colors.green,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Titre liste des tâches
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Tâches (${tasks.length})',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // État vide
          if (tasks.isEmpty)
            Center(
              child: Column(
                children: [
                  SizedBox(height: 32),
                  Icon(Icons.task, size: 60, color: Colors.grey.shade300),
                  SizedBox(height: 12),
                  Text(
                    'Aucune tâche pour ce projet',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Appuyez sur + pour ajouter une tâche',
                    style: TextStyle(color: Colors.grey.shade400),
                  ),
                ],
              ),
            )
          else
          // Liste des tâches
            ...tasks.map((task) => TaskCard(
              task: task,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TaskDetailScreen(task: task),
                  ),
                );
              },
            )),

          SizedBox(height: 80),
        ],
      ),

      // Bouton ajouter une tâche
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TaskFormScreen(
                projectId: widget.project.id,
              ),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  /// Chip de statistique
  Widget _buildChip(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Formate la date
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}