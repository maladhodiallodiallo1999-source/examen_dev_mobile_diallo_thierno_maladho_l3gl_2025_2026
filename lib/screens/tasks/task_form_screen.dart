import 'package:flutter/material.dart';
import 'package:sunu_task/models/task.dart';

class TaskFormScreen extends StatelessWidget {
  final Task? task;
  final String? projectId;
  const TaskFormScreen({super.key, this.task, this.projectId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(task == null ? 'Nouvelle tâche' : 'Modifier')),
      body: Center(child: Text('Formulaire tâche')),
    );
  }
}