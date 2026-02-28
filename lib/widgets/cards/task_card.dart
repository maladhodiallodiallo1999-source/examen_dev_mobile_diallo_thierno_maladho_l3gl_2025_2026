import 'package:flutter/material.dart';
import 'package:sunu_task/models/task.dart';

/// Carte affichant les informations d'une tâche
class TaskCard extends StatelessWidget {
  // La tâche à afficher
  final Task task;

  // Action quand on tape sur la carte
  final VoidCallback? onTap;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Indicateur de priorité (icône + couleur)
                  Icon(
                    _getPriorityIcon(),
                    size: 18,
                    color: _getPriorityColor(),
                  ),

                  SizedBox(width: 8),

                  // Titre de la tâche
                  Expanded(
                    child: Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        // Texte barré si la tâche est terminée
                        decoration: task.status == TaskStatus.done
                            ? TextDecoration.lineThrough
                            : null,
                        color: task.status == TaskStatus.done
                            ? Colors.grey
                            : null,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  SizedBox(width: 8),

                  // Badge de statut
                  _buildStatusBadge(),
                ],
              ),

              // Description (si elle existe)
              if (task.description != null &&
                  task.description!.isNotEmpty) ...[
                SizedBox(height: 8),
                Text(
                  task.description!,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // Date d'échéance (si elle existe)
              if (task.dueDate != null) ...[
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 13,
                      color: _isOverdue()
                          ? Colors.red
                          : Colors.grey.shade500,
                    ),
                    SizedBox(width: 4),
                    Text(
                      _formatDate(task.dueDate!),
                      style: TextStyle(
                        fontSize: 12,
                        // Rouge si la date est dépassée
                        color: _isOverdue()
                            ? Colors.red
                            : Colors.grey.shade500,
                        fontWeight: _isOverdue()
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Retourne le badge de statut avec la bonne couleur
  Widget _buildStatusBadge() {
    // Couleur et texte selon le statut
    Color badgeColor;
    String badgeText;

    switch (task.status) {
      case TaskStatus.todo:
        badgeColor = Colors.orange;
        badgeText = 'À faire';
        break;
      case TaskStatus.inProgress:
        badgeColor = Colors.blue;
        badgeText = 'En cours';
        break;
      case TaskStatus.done:
        badgeColor = Colors.green;
        badgeText = 'Terminée';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        // Couleur avec transparence pour le fond
        color: badgeColor.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor.withAlpha(100)),
      ),
      child: Text(
        badgeText,
        style: TextStyle(
          fontSize: 11,
          color: badgeColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Retourne l'icône selon la priorité
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

  /// Retourne la couleur selon la priorité
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

  /// Vérifie si la date d'échéance est dépassée
  bool _isOverdue() {
    if (task.dueDate == null) return false;
    if (task.status == TaskStatus.done) return false;
    return task.dueDate!.isBefore(DateTime.now());
  }

  /// Formate la date en texte lisible
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}