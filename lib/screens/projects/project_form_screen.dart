import 'package:flutter/material.dart';
import 'package:sunu_task/models/project.dart';

class ProjectFormScreen extends StatelessWidget {
  final Project? project;
  const ProjectFormScreen({super.key, this.project});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(project == null ? 'Nouveau projet' : 'Modifier')),
      body: Center(child: Text('Formulaire projet')),
    );
  }
}