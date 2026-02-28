import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunu_task/models/project.dart';
import 'package:sunu_task/models/task.dart';
import 'package:sunu_task/models/User.dart';

/// Service de stockage local avec pattern Singleton
class StorageService {

  //===== Singleton ==========
  static StorageService? _instance;

  static StorageService get instance {
    _instance ??= StorageService._();
    return _instance!;
  }

  StorageService._();

  //===== SharedPreferences ==========
  late SharedPreferences _prefs;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  // ======== Clés de Stockage =========
  static const String _keyOnboardingComplete = 'onboarding_complete';
  static const String _keyCurrentUser = 'current_user';
  static const String _keyUsers = 'users';
  static const String _keyProjects = 'projects';
  static const String _keyTasks = 'tasks';

  // ======== Onboarding =========
  bool get isOnboardingComplete {
    return _prefs.getBool(_keyOnboardingComplete) ?? false;
  }

  Future<void> setOnboardingComplete(bool value) async {
    await _prefs.setBool(_keyOnboardingComplete, value);
  }

  // ======== Utilisateur Connecté =========
  /// Sauvegarder l'utilisateur connecté
  Future<void> saveCurrentUser(User user) async {
    final String userJson = jsonEncode(user.toMap());
    await _prefs.setString(_keyCurrentUser, userJson);
  }

  /// Récupérer l'utilisateur connecté
  User? getCurrentUser() {
    final String? userJson = _prefs.getString(_keyCurrentUser);
    if (userJson == null) return null;
    return User.fromMap(jsonDecode(userJson));
  }

  /// Supprimer l'utilisateur connecté (déconnexion)
  Future<void> clearCurrentUser() async {
    await _prefs.remove(_keyCurrentUser);
  }

  // ======== Utilisateurs =========
  /// Récupérer tous les utilisateurs
  List<User> getUsers() {
    final List<String> usersJson =
        _prefs.getStringList(_keyUsers) ?? [];
    return usersJson
        .map((json) => User.fromMap(jsonDecode(json)))
        .toList();
  }

  /// Sauvegarder un nouvel utilisateur
  Future<void> saveUser(User user) async {
    final List<User> users = getUsers();
    users.add(user);
    final List<String> usersJson =
    users.map((u) => jsonEncode(u.toMap())).toList();
    await _prefs.setStringList(_keyUsers, usersJson);
  }

  // ======== Projets =========
  /// Récupérer tous les projets d'un utilisateur
  List<Project> getProjects(String userId) {
    final List<String> projectsJson =
        _prefs.getStringList(_keyProjects) ?? [];
    return projectsJson
        .map((json) => Project.fromMap(jsonDecode(json)))
        .where((project) => project.userId == userId)
        .toList();
  }

  /// Sauvegarder un projet
  Future<void> saveProject(Project project) async {
    final List<String> projectsJson =
        _prefs.getStringList(_keyProjects) ?? [];
    final List<Map<String, dynamic>> projects =
    projectsJson.map((json) => jsonDecode(json) as Map<String, dynamic>).toList();

    // Cherche si le projet existe déjà (mode modification)
    final int index = projects.indexWhere((p) => p['id'] == project.id);

    if (index >= 0) {
      // Modification : remplace l'ancien
      projects[index] = project.toMap();
    } else {
      // Création : ajoute le nouveau
      projects.add(project.toMap());
    }

    final List<String> updatedJson =
    projects.map((p) => jsonEncode(p)).toList();
    await _prefs.setStringList(_keyProjects, updatedJson);
  }

  /// Supprimer un projet
  Future<void> deleteProject(String projectId) async {
    final List<String> projectsJson =
        _prefs.getStringList(_keyProjects) ?? [];
    final List<Map<String, dynamic>> projects =
    projectsJson.map((json) => jsonDecode(json) as Map<String, dynamic>).toList();

    projects.removeWhere((p) => p['id'] == projectId);

    final List<String> updatedJson =
    projects.map((p) => jsonEncode(p)).toList();
    await _prefs.setStringList(_keyProjects, updatedJson);
  }

  // ======== Tâches =========
  /// Récupérer toutes les tâches d'un projet
  List<Task> getTasks(String projectId) {
    final List<String> tasksJson =
        _prefs.getStringList(_keyTasks) ?? [];
    return tasksJson
        .map((json) => Task.fromMap(jsonDecode(json)))
        .where((task) => task.projectId == projectId)
        .toList();
  }

  /// Récupérer toutes les tâches d'un utilisateur
  List<Task> getTasksByUser(String userId) {
    final List<String> tasksJson =
        _prefs.getStringList(_keyTasks) ?? [];
    return tasksJson
        .map((json) => Task.fromMap(jsonDecode(json)))
        .where((task) => task.userId == userId)
        .toList();
  }

  /// Sauvegarder une tâche
  Future<void> saveTask(Task task) async {
    final List<String> tasksJson =
        _prefs.getStringList(_keyTasks) ?? [];
    final List<Map<String, dynamic>> tasks =
    tasksJson.map((json) => jsonDecode(json) as Map<String, dynamic>).toList();

    final int index = tasks.indexWhere((t) => t['id'] == task.id);

    if (index >= 0) {
      tasks[index] = task.toMap();
    } else {
      tasks.add(task.toMap());
    }

    final List<String> updatedJson =
    tasks.map((t) => jsonEncode(t)).toList();
    await _prefs.setStringList(_keyTasks, updatedJson);
  }

  /// Supprimer une tâche
  Future<void> deleteTask(String taskId) async {
    final List<String> tasksJson =
        _prefs.getStringList(_keyTasks) ?? [];
    final List<Map<String, dynamic>> tasks =
    tasksJson.map((json) => jsonDecode(json) as Map<String, dynamic>).toList();

    tasks.removeWhere((t) => t['id'] == taskId);

    final List<String> updatedJson =
    tasks.map((t) => jsonEncode(t)).toList();
    await _prefs.setStringList(_keyTasks, updatedJson);
  }

  /// Supprimer toutes les tâches d'un projet
  Future<void> deleteTasksByProject(String projectId) async {
    final List<String> tasksJson =
        _prefs.getStringList(_keyTasks) ?? [];
    final List<Map<String, dynamic>> tasks =
    tasksJson.map((json) => jsonDecode(json) as Map<String, dynamic>).toList();

    tasks.removeWhere((t) => t['projectId'] == projectId);

    final List<String> updatedJson =
    tasks.map((t) => jsonEncode(t)).toList();
    await _prefs.setStringList(_keyTasks, updatedJson);
  }
}