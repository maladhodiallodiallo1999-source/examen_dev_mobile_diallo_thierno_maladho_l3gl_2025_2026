import 'package:flutter/foundation.dart';
import 'package:SunuTask/models/project.dart';
import 'package:SunuTask/services/storage_service.dart';

/// Gère la liste des projets de l'utilisateur
class ProjectProvider extends ChangeNotifier {
  List<Project> _projects = [];
  Project? _selectedProject;
  bool _isLoading = false;

  List<Project> get projects => _projects;
  Project? get selectedProject => _selectedProject;
  int get projectCount => _projects.length;
  bool get isLoading => _isLoading;

  /// Charge les projets d'un utilisateur
  Future<void> loadProjects(String userId) async {
    _isLoading = true;
    notifyListeners();

    _projects = await StorageService.instance.getProjectsByUserId(userId);

    _isLoading = false;
    notifyListeners();
  }

  /// Crée un nouveau projet
  Future<void> createProject(Project project) async {
    await StorageService.instance.saveProject(project);
    _projects.add(project);
    notifyListeners();
  }

  /// Modifie un projet existant
  Future<void> updateProject(Project project) async {
    await StorageService.instance.saveProject(project);
    final index = _projects.indexWhere((p) => p.id == project.id);
    if (index != -1) {
      _projects[index] = project;
      notifyListeners();
    }
  }

  /// Supprime un projet (et ses tâches)
  Future<void> deleteProject(String projectId) async {
    await StorageService.instance.deleteProject(projectId);
    await StorageService.instance.deleteTasksByProjectId(projectId);
    _projects.removeWhere((p) => p.id == projectId);
    notifyListeners();
  }

  /// Sélectionne un projet pour la navigation
  void selectProject(Project? project) {
    _selectedProject = project;
    notifyListeners();
  }
}
