import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sunu_task/models/task.dart';
import 'package:sunu_task/providers/auth_provider.dart';
import 'package:sunu_task/providers/task_provider.dart';
import 'package:sunu_task/widgets/common/custom_button.dart';
import 'package:sunu_task/widgets/common/custom_text_field.dart';

/// Écran de création et modification de tâche
class TaskFormScreen extends StatefulWidget {
  // null = création, non-null = modification
  final Task? task;
  // ID du projet auquel appartient la tâche
  final String? projectId;

  const TaskFormScreen({super.key, this.task, this.projectId});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Statut sélectionné (À faire par défaut)
  TaskStatus _selectedStatus = TaskStatus.todo;

  // Priorité sélectionnée (Moyenne par défaut)
  TaskPriority _selectedPriority = TaskPriority.medium;

  // Date d'échéance sélectionnée
  DateTime? _selectedDueDate;

  @override
  void initState() {
    super.initState();
    // Si modification → pré-remplir les champs
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description ?? '';
      _selectedStatus = widget.task!.status;
      _selectedPriority = widget.task!.priority;
      _selectedDueDate = widget.task!.dueDate;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Ouvre le sélecteur de date
  Future<void> _selectDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _selectedDueDate = picked);
    }
  }

  /// Sauvegarde la tâche
  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final taskProvider = context.read<TaskProvider>();

    if (widget.task == null) {
      // Création
      await taskProvider.createTask(
        projectId: widget.projectId!,
        userId: authProvider.currentUser!.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        status: _selectedStatus,
        priority: _selectedPriority,
        dueDate: _selectedDueDate,
      );
    } else {
      // Modification
      final Task updatedTask = widget.task!.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        status: _selectedStatus,
        priority: _selectedPriority,
        dueDate: _selectedDueDate,
      );
      await taskProvider.updateTask(updatedTask);
    }

    if (mounted) Navigator.pop(context);
  }

  /// Supprime la tâche avec confirmation
  Future<void> _deleteTask() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Supprimer la tâche'),
        content: Text('Voulez-vous vraiment supprimer cette tâche ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Supprimer',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await context.read<TaskProvider>().deleteTask(widget.task!.id);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.task != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier la tâche' : 'Nouvelle tâche'),
        actions: [
          // Bouton supprimer visible uniquement en mode modification
          if (isEditing)
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: _deleteTask,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Champ Titre
              CustomTextField(
                label: 'Titre',
                hint: 'Ex: Créer la maquette',
                controller: _titleController,
                prefixIcon: Icons.title,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un titre';
                  }
                  return null;
                },
              ),

              SizedBox(height: 16),

              // Champ Description
              CustomTextField(
                label: 'Description (optionnel)',
                hint: 'Décrivez la tâche...',
                controller: _descriptionController,
                maxLines: 3,
              ),

              SizedBox(height: 24),

              // Sélecteur de statut
              Text(
                'Statut',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildStatusSelector(
                      label: 'À faire',
                      status: TaskStatus.todo,
                      color: Colors.orange,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: _buildStatusSelector(
                      label: 'En cours',
                      status: TaskStatus.inProgress,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: _buildStatusSelector(
                      label: 'Terminée',
                      status: TaskStatus.done,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24),

              // Sélecteur de priorité
              Text(
                'Priorité',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildPrioritySelector(
                      label: 'Haute',
                      priority: TaskPriority.high,
                      color: Colors.red,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: _buildPrioritySelector(
                      label: 'Moyenne',
                      priority: TaskPriority.medium,
                      color: Colors.orange,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: _buildPrioritySelector(
                      label: 'Basse',
                      priority: TaskPriority.low,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24),

              // Sélecteur de date d'échéance
              Text(
                'Date d\'échéance (optionnel)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              SizedBox(height: 12),

              GestureDetector(
                onTap: _selectDueDate,
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade50,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today,
                          color: Colors.grey.shade600),
                      SizedBox(width: 12),
                      Text(
                        _selectedDueDate == null
                            ? 'Sélectionner une date'
                            : '${_selectedDueDate!.day.toString().padLeft(2, '0')}/'
                            '${_selectedDueDate!.month.toString().padLeft(2, '0')}/'
                            '${_selectedDueDate!.year}',
                        style: TextStyle(
                          color: _selectedDueDate == null
                              ? Colors.grey.shade500
                              : Colors.black,
                        ),
                      ),
                      Spacer(),
                      // Bouton pour effacer la date
                      if (_selectedDueDate != null)
                        GestureDetector(
                          onTap: () {
                            setState(() => _selectedDueDate = null);
                          },
                          child: Icon(Icons.close,
                              size: 18, color: Colors.grey),
                        ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 32),

              // Bouton Créer/Modifier
              Consumer<TaskProvider>(
                builder: (context, provider, child) {
                  return CustomButton(
                    text: isEditing ? 'Modifier' : 'Créer la tâche',
                    icon: isEditing ? Icons.save : Icons.add,
                    isLoading: provider.isLoading,
                    onPressed: _saveTask,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Conteneur animé pour le statut
  Widget _buildStatusSelector({
    required String label,
    required TaskStatus status,
    required Color color,
  }) {
    final bool isSelected = _selectedStatus == status;
    return GestureDetector(
      onTap: () => setState(() => _selectedStatus = status),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withAlpha(20),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : color.withAlpha(80),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  /// Conteneur animé pour la priorité
  Widget _buildPrioritySelector({
    required String label,
    required TaskPriority priority,
    required Color color,
  }) {
    final bool isSelected = _selectedPriority == priority;
    return GestureDetector(
      onTap: () => setState(() => _selectedPriority = priority),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withAlpha(20),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : color.withAlpha(80),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}