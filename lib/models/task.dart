/// Statuts possibles d'une tâche
enum TaskStatus {
  todo,       // À faire
  inProgress, // En cours
  done,       // Terminée
}

/// Priorités possibles d'une tâche
enum TaskPriority {
  low,    // Basse
  medium, // Moyenne
  high,   // Haute
}

/// Modèle de données pour une Tâche
class Task {
  final String id;
  final String title;
  final String description;
  final TaskStatus status;
  final TaskPriority priority;

  /// ID du projet auquel appartient cette tâche
  final String projectId;

  /// ID de l'utilisateur propriétaire
  final String userId;

  final DateTime createdAt;

  /// Date limite optionnelle
  final DateTime? dueDate;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.projectId,
    required this.userId,
    DateTime? createdAt,
    this.dueDate,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Crée une copie avec des champs modifiés
  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    String? projectId,
    String? userId,
    DateTime? createdAt,
    DateTime? dueDate,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      projectId: projectId ?? this.projectId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
    );
  }

  /// Convertit en Map pour la sauvegarde
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status.name,       // "todo", "inProgress", "done"
      'priority': priority.name,   // "low", "medium", "high"
      'projectId': projectId,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
    };
  }

  /// Crée une Task depuis un Map
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      // Convertit le string en enum
      status: TaskStatus.values.firstWhere((e) => e.name == map['status']),
      priority: TaskPriority.values.firstWhere((e) => e.name == map['priority']),
      projectId: map['projectId'] as String,
      userId: map['userId'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      dueDate: map['dueDate'] != null
          ? DateTime.parse(map['dueDate'] as String)
          : null,
    );
  }

  @override
  String toString() {
    return 'Task(id: $id, title: $title, status: $status)';
  }
}
