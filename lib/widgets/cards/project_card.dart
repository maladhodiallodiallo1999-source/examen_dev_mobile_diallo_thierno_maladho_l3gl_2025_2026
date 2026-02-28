import 'package:flutter/material.dart';
import 'package:sunu_task/models/project.dart';

/// Carte affichant les informations d'un projet
class ProjectCard extends StatelessWidget {
  // Le projet à afficher
  final Project project;

  // Nombre de tâches du projet
  final int taskCount;

  // Action quand on tape sur la carte (navigation vers le détail)
  final VoidCallback? onTap;

  // Action quand on veut modifier le projet
  final VoidCallback? onEdit;

  // Action quand on veut supprimer le projet
  final VoidCallback? onDelete;

  const ProjectCard({
    super.key,
    required this.project,
    this.taskCount = 0,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Récupère la couleur du projet depuis sa valeur entière
    final Color projectColor = Color(project.color);

    return Card(
      // Ombre légère sous la carte
      elevation: 2,
      // Coins arrondis
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        // InkWell ajoute l'effet de vague au tap
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              // Pastille de couleur du projet
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  // Couleur du projet avec transparence
                  color: projectColor.withAlpha(40),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.folder,
                  color: projectColor,
                  size: 24,
                ),
              ),

              SizedBox(width: 16),

              // Nom et description du projet
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nom du projet
                    Text(
                      project.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      // Coupe le texte si trop long
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Description (si elle existe)
                    if (project.description != null &&
                        project.description!.isNotEmpty) ...[
                      SizedBox(height: 4),
                      Text(
                        project.description!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],

                    SizedBox(height: 8),

                    // Nombre de tâches
                    Row(
                      children: [
                        Icon(
                          Icons.task_alt,
                          size: 14,
                          color: Colors.grey.shade500,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '$taskCount tâche${taskCount > 1 ? 's' : ''}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Menu contextuel (modifier / supprimer)
              PopupMenuButton<String>(
                // Les options du menu
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 18, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Modifier'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Supprimer',
                            style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                // Action selon le choix
                onSelected: (value) {
                  if (value == 'edit') onEdit?.call();
                  if (value == 'delete') onDelete?.call();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}