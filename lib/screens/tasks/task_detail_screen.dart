import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sunu_task/models/task.dart';
import 'package:sunu_task/providers/task_provider.dart';
import 'package:sunu_task/screens/tasks/task_form_screen.dart';

/// Écran de détail d'une tâche
class TaskDetailScreen extends StatelessWidget {
  final Task task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détail de la tâche'),
        actions: [
          // Bouton modifier
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TaskFormScreen(task: task),
                ),
              );
            },
          ),
          // Bouton supprimer
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              final bool? confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Supprimer la tâche'),
                  content:
                  Text('Voulez-vous vraiment supprimer cette tâche ?'),
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

              if (confirm == true && context.mounted) {
                await context.read<TaskProvider>().deleteTask(task.id);
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Titre
          Text(
            task.title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              // Texte barré si terminée
              decoration: task.status == TaskStatus.done
                  ? TextDecoration.lineThrough
                  : null,
            ),
          ),

          SizedBox(height: 16),

          // Description
          if (task.description != null && task.description!.isNotEmpty) ...[
            Text(
              'Description',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 8),
            Text(
              task.description!,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            SizedBox(height: 16),
          ],

          // Statut avec changement rapide
          Text(
            'Statut',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),

          SizedBox(height: 8),

          // 3 boutons de statut
          Row(
            children: [
              Expanded(
                child: _buildStatusButton(
                  context,
                  label: 'À faire',
                  status: TaskStatus.todo,
                  color: Colors.orange,
                  isSelected: task.status == TaskStatus.todo,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _buildStatusButton(
                  context,
                  label: 'En cours',
                  status: TaskStatus.inProgress,
                  color: Colors.blue,
                  isSelected: task.status == TaskStatus.inProgress,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _buildStatusButton(
                  context,
                  label: 'Terminée',
                  status: TaskStatus.done,
                  color: Colors.green,
                  isSelected: task.status == TaskStatus.done,
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          // Priorité
          Text(
            'Priorité',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),

          SizedBox(height: 8),

          Row(
            children: [
              Icon(
                _getPriorityIcon(),
                color: _getPriorityColor(),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                _getPriorityLabel(),
                style: TextStyle(
                  fontSize: 15,
                  color: _getPriorityColor(),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          // Date d'échéance
          if (task.dueDate != null) ...[
            Text(
              'Date d\'échéance',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: _isOverdue() ? Colors.red : Colors.grey.shade600,
                ),
                SizedBox(width: 8),
                Text(
                  _formatDate(task.dueDate!),
                  style: TextStyle(
                    fontSize: 15,
                    color:
                    _isOverdue() ? Colors.red : Colors.grey.shade600,
                    fontWeight: _isOverdue()
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                if (_isOverdue()) ...[
                  SizedBox(width: 8),
                  Text(
                    '(En retard)',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ],

          SizedBox(height: 16),

          // Date de création
          Text(
            'Créée le ${_formatDate(task.createdAt)}',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  /// Bouton de changement rapide de statut
  Widget _buildStatusButton(
      BuildContext context, {
        required String label,
        required TaskStatus status,
        required Color color,
        required bool isSelected,
      }) {
    return GestureDetector(
      onTap: () async {
        // Changer le statut directement depuis le détail
        await context
            .read<TaskProvider>()
            .updateTaskStatus(task.id, status);
        if (context.mounted) Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withAlpha(20),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withAlpha(100)),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  /// Icône selon la priorité
  IconData _getPriorityIcon() {
    switch (task.priority) {
      case TaskPriority.high:
        return Icons.keyboard_double_arrow_up;
      case TaskPriority.medium:
        return Icons.keyboard_arrow_up;
      case TaskPriority.low:
        return Icons.keyboard_arrow_down;
    }
  }

  /// Couleur selon la priorité
  Color _getPriorityColor() {
    switch (task.priority) {
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.low:
        return Colors.green;
    }
  }

  /// Label selon la priorité
  String _getPriorityLabel() {
    switch (task.priority) {
      case TaskPriority.high:
        return 'Haute';
      case TaskPriority.medium:
        return 'Moyenne';
      case TaskPriority.low:
        return 'Basse';
    }
  }

  /// Vérifie si la date est dépassée
  bool _isOverdue() {
    if (task.dueDate == null) return false;
    if (task.status == TaskStatus.done) return false;
    return task.dueDate!.isBefore(DateTime.now());
  }

  /// Formate la date
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}