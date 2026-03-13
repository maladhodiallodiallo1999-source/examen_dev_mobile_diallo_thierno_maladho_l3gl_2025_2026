import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:SunuTask/models/User.dart';
import 'package:SunuTask/models/project.dart';
import 'package:SunuTask/models/task.dart';

class StorageService {
  static StorageService? _instance;

  static StorageService get instance {
    _instance ??= StorageService._();
    return _instance!;
  }

  StorageService._();

  late SharedPreferences _prefs;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  static const String _keyOnboardingComplete = 'onboarding_complete';
  static const String _keyCurrentUser = 'current_user';
  static const String _keyUsers = 'users';
  static const String _keyProjects = 'projects';
  static const String _keyTasks = 'tasks';

  // ONBOARDING
  bool get isOnboardingComplete {
    return _prefs.getBool(_keyOnboardingComplete) ?? false;
  }
  Future<void> setOnboardingComplete() async {
    await _prefs.setBool(_keyOnboardingComplete, true);
  }
  Future<void> resetOnboarding() async {
    await _prefs.remove(_keyOnboardingComplete);
  }

  // UTILISATEURS
  Future<List<User>> getUsers() async {
    final String? usersJson = _prefs.getString(_keyUsers);
    if (usersJson == null) return [];
    final List<dynamic> list = jsonDecode(usersJson);
    return list.map((u) => User.fromMap(u as Map<String, dynamic>)).toList();
  }
  Future<void> saveUser(User user) async {
    final users = await getUsers();
    final index = users.indexWhere((u) => u.id == user.id);
    if (index != -1) { users[index] = user; } else { users.add(user); }
    await _prefs.setString(_keyUsers, jsonEncode(users.map((u) => u.toMap()).toList()));
  }
  Future<void> saveCurrentUser(User user) async {
    await _prefs.setString(_keyCurrentUser, jsonEncode(user.toMap()));
  }
  Future<User?> getCurrentUser() async {
    final String? userJson = _prefs.getString(_keyCurrentUser);
    if (userJson == null) return null;
    return User.fromMap(jsonDecode(userJson) as Map<String, dynamic>);
  }
  Future<void> clearCurrentUser() async {
    await _prefs.remove(_keyCurrentUser);
  }

  // PROJETS
  Future<List<Project>> getProjects() async {
    final String? projectsJson = _prefs.getString(_keyProjects);
    if (projectsJson == null) return [];
    final List<dynamic> list = jsonDecode(projectsJson);
    return list.map((p) => Project.fromMap(p as Map<String, dynamic>)).toList();
  }
  Future<List<Project>> getProjectsByUserId(String userId) async {
    final projects = await getProjects();
    return projects.where((p) => p.userId == userId).toList();
  }
  Future<void> saveProject(Project project) async {
    final projects = await getProjects();
    final index = projects.indexWhere((p) => p.id == project.id);
    if (index != -1) { projects[index] = project; } else { projects.add(project); }
    await _prefs.setString(_keyProjects, jsonEncode(projects.map((p) => p.toMap()).toList()));
  }
  Future<void> deleteProject(String projectId) async {
    final projects = await getProjects();
    projects.removeWhere((p) => p.id == projectId);
    await _prefs.setString(_keyProjects, jsonEncode(projects.map((p) => p.toMap()).toList()));
  }

  // TÂCHES
  Future<List<Task>> getTasks() async {
    final String? tasksJson = _prefs.getString(_keyTasks);
    if (tasksJson == null) return [];
    final List<dynamic> list = jsonDecode(tasksJson);
    return list.map((t) => Task.fromMap(t as Map<String, dynamic>)).toList();
  }
  Future<List<Task>> getTasksByProjectId(String projectId) async {
    final tasks = await getTasks();
    return tasks.where((t) => t.projectId == projectId).toList();
  }
  Future<List<Task>> getTasksByUserId(String userId) async {
    final tasks = await getTasks();
    return tasks.where((t) => t.userId == userId).toList();
  }
  Future<void> saveTask(Task task) async {
    final tasks = await getTasks();
    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) { tasks[index] = task; } else { tasks.add(task); }
    await _prefs.setString(_keyTasks, jsonEncode(tasks.map((t) => t.toMap()).toList()));
  }
  Future<void> deleteTask(String taskId) async {
    final tasks = await getTasks();
    tasks.removeWhere((t) => t.id == taskId);
    await _prefs.setString(_keyTasks, jsonEncode(tasks.map((t) => t.toMap()).toList()));
  }
  Future<void> deleteTasksByProjectId(String projectId) async {
    final tasks = await getTasks();
    tasks.removeWhere((t) => t.projectId == projectId);
    await _prefs.setString(_keyTasks, jsonEncode(tasks.map((t) => t.toMap()).toList()));
  }

  Future<void> clearAll() async {
    await _prefs.clear();
  }
}