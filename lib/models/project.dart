/// Modèle de données pour un Projet
/// Immutable (tous les champs sont final)
class Project {
  final String id;
  final String name;
  final String description;

  /// Couleur stockée en format hex string : ex "0xFF6C63FF"
  final String color;

  /// ID de l'utilisateur propriétaire du projet
  final String userId;

  final DateTime createdAt;

  Project({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
    required this.userId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Crée une copie avec des champs modifiés
  Project copyWith({
    String? id,
    String? name,
    String? description,
    String? color,
    String? userId,
    DateTime? createdAt,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Convertit en Map pour la sauvegarde
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color': color,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Crée un Project depuis un Map
  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      color: map['color'] as String,
      userId: map['userId'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  @override
  String toString() {
    return 'Project(id: $id, name: $name, userId: $userId)';
  }
}
