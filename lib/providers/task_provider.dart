import 'package:flutter/material.dart';
import 'package:sunu_task/models/task.dart';
import 'package:sunu_task/services/storage_service.dart';
import 'package:uuid/uuid.dart';

/// Gère les tâches d'un projet avec filtrage et tri
class TaskProvider extends ChangeNotifier {

  // ======== Propriétés privées =========
  List<Task> _tasks = [];
  TaskStatus? _statusFilter;
  TaskPriority? _priorityFilter;
  bool _isLoading = false;

  // ======== Getters publics =========
  bool get isLoading => _isLoading;

  /// Retourne les tâches filtrées et triées
  List<Task> get tasks {
    List<Task> filtered = List.from(_tasks);

    // Appliquer le filtre de statut
    if (_statusFilter != null) {
      filtered = filtered
          .where((t) => t.status == _statusFilter)
          .toList();
    }

    // Appliquer le filtre de priorité
    if (_priorityFilter != null) {
      filtered = filtered
          .where((t) => t.priority == _priorityFilter)
          .toList();
    }

    // Tri : inProgress > todo > done, puis high > medium > low
    filtered.sort((a, b) {
      // Ordre des statuts
      const statusOrder = {
        TaskStatus.inProgress: 0,
        TaskStatus.todo: 1,
        TaskStatus.done: 2,
      };

      // Ordre des priorités
      const priorityOrder = {
        TaskPriority.high: 0,
        TaskPriority.medium: 1,
        TaskPriority.low: 2,
      };

      // Comparer d'abord par statut
      final int statusCompare =
      statusOrder[a.status]!.compareTo(statusOrder[b.status]!);
      if (statusCompare != 0) return statusCompare;

      // Si même statut, comparer par priorité
      return priorityOrder[a.priority]!
          .compareTo(priorityOrder[b.priority]!);
    });

    return filtered;
  }

  /// Compteur de tâches par statut
  Map<TaskStatus, int> get taskCountByStatus {
    return {
      TaskStatus.todo: _tasks
          .where((t) => t.status == TaskStatus.todo)
          .length,
      TaskStatus.inProgress: _tasks
          .where((t) => t.status == TaskStatus.inProgress)
          .length,
      TaskStatus.done: _tasks
          .where((t) => t.status == TaskStatus.done)
          .length,
    };
  }

  // ======== Méthodes CRUD =========

  /// Charger les tâches d'un projet
  Future<void> loadTasks(String projectId) async {
    _isLoading = true;
    notifyListeners();

    _tasks = StorageService.instance.getTasks(projectId);

    _isLoading = false;
    notifyListeners();
  }

  /// Charger toutes les tâches d'un utilisateur
  Future<void> loadTasksByUser(String userId) async {
    _isLoading = true;
    notifyListeners();

    _tasks = StorageService.instance.getTasksByUser(userId);

    _isLoading = false;
    notifyListeners();
  }

  /// Créer une nouvelle tâche
  Future<void> createTask({
    required String projectId,
    required String userId,
    required String title,
    String? description,
    TaskStatus status = TaskStatus.todo,
    TaskPriority priority = TaskPriority.medium,
    DateTime? dueDate,
  }) async {
    final Task task = Task(
      id: const Uuid().v4(),
      projectId: projectId,
      userId: userId,
      title: title,
      description: description,
      status: status,
      priority: priority,
      dueDate: dueDate,
    );

    await StorageService.instance.saveTask(task);
    _tasks.add(task);
    notifyListeners();
  }

  /// Modifier une tâche
  Future<void> updateTask(Task task) async {
    await StorageService.instance.saveTask(task);

    final int index = _tasks.indexWhere((t) => t.id == task.id);
    if (index >= 0) {
      _tasks[index] = task;
    }
    notifyListeners();
  }

  /// Supprimer une tâche
  Future<void> deleteTask(String taskId) async {
    await StorageService.instance.deleteTask(taskId);
    _tasks.removeWhere((t) => t.id == taskId);
    notifyListeners();
  }

  /// Mettre à jour uniquement le statut d'une tâche
  Future<void> updateTaskStatus(String taskId, TaskStatus status) async {
    final int index = _tasks.indexWhere((t) => t.id == taskId);
    if (index >= 0) {
      final Task updatedTask = _tasks[index].copyWith(status: status);
      await StorageService.instance.saveTask(updatedTask);
      _tasks[index] = updatedTask;
      notifyListeners();
    }
  }

  // ======== Filtres =========

  /// Filtrer par statut
  void setStatusFilter(TaskStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }

  /// Filtrer par priorité
  void setPriorityFilter(TaskPriority? priority) {
    _priorityFilter = priority;
    notifyListeners();
  }

  /// Effacer tous les filtres
  void clearFilters() {
    _statusFilter = null;
    _priorityFilter = null;
    notifyListeners();
  }
}