import 'package:flutter/material.dart';
import 'package:sunu_task/models/project.dart';
import 'package:sunu_task/services/storage_service.dart';
import 'package:uuid/uuid.dart';

/// Gère la collection de projets de l'utilisateur
class ProjectProvider extends ChangeNotifier {

  // ======== Propriétés privées =========
  List<Project> _projects = [];
  Project? _selectedProject;
  bool _isLoading = false;

  // ======== Getters publics =========
  List<Project> get projects => _projects;
  Project? get selectedProject => _selectedProject;
  int get projectCount => _projects.length;
  bool get isLoading => _isLoading;

  // ======== Méthodes =========

  /// Charge les projets d'un utilisateur
  Future<void> loadProjects(String userId) async {
    _isLoading = true;
    notifyListeners();

    _projects = StorageService.instance.getProjects(userId);

    _isLoading = false;
    notifyListeners();
  }

  /// Créer un nouveau projet
  Future<void> createProject(String userId, String name,
      String? description, int color) async {
    final Project project = Project(
      id: const Uuid().v4(),
      name: name,
      description: description,
      userId: userId,
      color: color,
    );

    await StorageService.instance.saveProject(project);
    _projects.add(project);
    notifyListeners();
  }

  /// Modifier un projet existant
  Future<void> updateProject(Project project) async {
    await StorageService.instance.saveProject(project);

    // Remplace l'ancien projet dans la liste
    final int index = _projects.indexWhere((p) => p.id == project.id);
    if (index >= 0) {
      _projects[index] = project;
    }
    notifyListeners();
  }

  /// Supprimer un projet et toutes ses tâches
  Future<void> deleteProject(String projectId) async {
    // Supprimer le projet
    await StorageService.instance.deleteProject(projectId);
    // Supprimer toutes les tâches du projet
    await StorageService.instance.deleteTasksByProject(projectId);
    // Retirer de la liste locale
    _projects.removeWhere((p) => p.id == projectId);
    notifyListeners();
  }

  /// Sélectionner un projet (pour la navigation)
  void selectProject(Project? project) {
    _selectedProject = project;
    notifyListeners();
  }
}