import 'package:flutter/material.dart';
import 'package:sunu_task/models/task.dart';

class TaskDetailScreen extends StatelessWidget {
  final Task task;
  const TaskDetailScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(task.title)),
      body: Center(child: Text('Détail de la tâche')),
    );
  }
}