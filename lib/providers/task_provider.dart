import 'package:flutter/foundation.dart';
import 'package:SunuTask/models/task.dart';
import 'package:SunuTask/services/storage_service.dart';

/// Gère les tâches avec filtrage et tri
class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  TaskStatus? _statusFilter;
  TaskPriority? _priorityFilter;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  /// Retourne les tâches filtrées et triées
  List<Task> get tasks {
    List<Task> filtered = List.from(_tasks);

    // Application des filtres
    if (_statusFilter != null) {
      filtered = filtered.where((t) => t.status == _statusFilter).toList();
    }
    if (_priorityFilter != null) {
      filtered = filtered.where((t) => t.priority == _priorityFilter).toList();
    }

    // Tri : inProgress > todo > done, puis high > medium > low
    filtered.sort((a, b) {
      int statusOrder(TaskStatus s) {
        switch (s) {
          case TaskStatus.inProgress: return 0;
          case TaskStatus.todo:       return 1;
          case TaskStatus.done:       return 2;
        }
      }

      int priorityOrder(TaskPriority p) {
        switch (p) {
          case TaskPriority.high:   return 0;
          case TaskPriority.medium: return 1;
          case TaskPriority.low:    return 2;
        }
      }

      final sc = statusOrder(a.status).compareTo(statusOrder(b.status));
      if (sc != 0) return sc;
      return priorityOrder(a.priority).compareTo(priorityOrder(b.priority));
    });

    return filtered;
  }

  /// Compteur de tâches par statut (pour le dashboard)
  Map<TaskStatus, int> get taskCountByStatus {
    return {
      TaskStatus.todo:       _tasks.where((t) => t.status == TaskStatus.todo).length,
      TaskStatus.inProgress: _tasks.where((t) => t.status == TaskStatus.inProgress).length,
      TaskStatus.done:       _tasks.where((t) => t.status == TaskStatus.done).length,
    };
  }

  /// Charge les tâches d'un projet
  Future<void> loadTasks(String projectId) async {
    _isLoading = true;
    notifyListeners();
    _tasks = await StorageService.instance.getTasksByProjectId(projectId);
    _isLoading = false;
    notifyListeners();
  }

  /// Charge toutes les tâches d'un utilisateur
  Future<void> loadAllTasks(String userId) async {
    _isLoading = true;
    notifyListeners();
    _tasks = await StorageService.instance.getTasksByUserId(userId);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> createTask(Task task) async {
    await StorageService.instance.saveTask(task);
    _tasks.add(task);
    notifyListeners();
  }

  Future<void> updateTask(Task task) async {
    await StorageService.instance.saveTask(task);
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      notifyListeners();
    }
  }

  Future<void> deleteTask(String taskId) async {
    await StorageService.instance.deleteTask(taskId);
    _tasks.removeWhere((t) => t.id == taskId);
    notifyListeners();
  }

  /// Change le statut d'une tâche rapidement
  Future<void> updateTaskStatus(String taskId, TaskStatus status) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      final updated = _tasks[index].copyWith(status: status);
      await updateTask(updated);
    }
  }

  // ===== Filtres =====
  void setStatusFilter(TaskStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }

  void setPriorityFilter(TaskPriority? priority) {
    _priorityFilter = priority;
    notifyListeners();
  }

  void clearFilters() {
    _statusFilter = null;
    _priorityFilter = null;
    notifyListeners();
  }

  void clearTasks() {
    _tasks = [];
    notifyListeners();
  }
}
