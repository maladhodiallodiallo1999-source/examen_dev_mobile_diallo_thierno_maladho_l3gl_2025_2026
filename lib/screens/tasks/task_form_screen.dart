import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:SunuTask/core/constants/app_colors.dart';
import 'package:SunuTask/models/task.dart';
import 'package:SunuTask/providers/auth_provider.dart';
import 'package:SunuTask/providers/task_provider.dart';
import 'package:SunuTask/widgets/common/custom_button.dart';
import 'package:SunuTask/widgets/common/custom_text_field.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? task;
  final String? projectId;
  const TaskFormScreen({super.key, this.task, this.projectId});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  TaskStatus _status = TaskStatus.todo;
  TaskPriority _priority = TaskPriority.medium;
  DateTime? _dueDate;
  bool _isLoading = false;
  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _status = widget.task!.status;
      _priority = widget.task!.priority;
      _dueDate = widget.task!.dueDate;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final provider = context.read<TaskProvider>();
    final userId = context.read<AuthProvider>().currentUser!.id;

    if (_isEditing) {
      await provider.updateTask(widget.task!.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        status: _status, priority: _priority, dueDate: _dueDate,
      ));
    } else {
      await provider.createTask(Task(
        id: const Uuid().v4(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        status: _status, priority: _priority,
        projectId: widget.projectId!,
        userId: userId,
        dueDate: _dueDate,
      ));
    }

    setState(() => _isLoading = false);
    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> _handleDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer la tâche ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer', style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await context.read<TaskProvider>().deleteTask(widget.task!.id);
      Navigator.pop(context);
    }
  }

  Widget _buildSelector<T>({required String label, required List<T> values, required T selected, required String Function(T) getLabel, required Color Function(T) getColor, required void Function(T) onSelect}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      const SizedBox(height: 8),
      Row(children: values.map((v) {
        final isSelected = selected == v;
        final color = getColor(v);
        return Expanded(child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: GestureDetector(
              onTap: () => setState(() => onSelect(v)),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? color : color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color),
                ),
                child: Center(child: Text(getLabel(v), style: TextStyle(color: isSelected ? Colors.white : color, fontSize: 12, fontWeight: FontWeight.w600))),
              ),
            ),
          ),
        ));
      }).toList()),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifier la tâche' : 'Nouvelle tâche'),
        actions: [
          if (_isEditing) IconButton(icon: const Icon(Icons.delete_outlined, color: AppColors.error), onPressed: _handleDelete),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            CustomTextField(
              label: 'Titre',
              controller: _titleController,
              validator: (v) => (v == null || v.isEmpty) ? 'Titre obligatoire' : null,
            ),
            const SizedBox(height: 16),
            CustomTextField(label: 'Description', controller: _descriptionController, maxLines: 3),
            const SizedBox(height: 24),

            // Sélecteur de statut
            _buildSelector<TaskStatus>(
              label: 'Statut',
              values: TaskStatus.values,
              selected: _status,
              getLabel: (s) => s == TaskStatus.todo ? 'À faire' : s == TaskStatus.inProgress ? 'En cours' : 'Terminée',
              getColor: (s) => s == TaskStatus.todo ? AppColors.statusTodo : s == TaskStatus.inProgress ? AppColors.statusInProgress : AppColors.statusDone,
              onSelect: (s) => _status = s,
            ),
            const SizedBox(height: 16),

            // Sélecteur de priorité
            _buildSelector<TaskPriority>(
              label: 'Priorité',
              values: TaskPriority.values,
              selected: _priority,
              getLabel: (p) => p == TaskPriority.high ? 'Haute' : p == TaskPriority.medium ? 'Moyenne' : 'Basse',
              getColor: (p) => p == TaskPriority.high ? AppColors.priorityHigh : p == TaskPriority.medium ? AppColors.priorityMedium : AppColors.priorityLow,
              onSelect: (p) => _priority = p,
            ),
            const SizedBox(height: 16),

            // Date d'échéance
            const Text("Date d'échéance", style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _dueDate ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                );
                if (date != null) setState(() => _dueDate = date);
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary),
                ),
                child: Row(children: [
                  const Icon(Icons.calendar_today_outlined, color: AppColors.primary, size: 18),
                  const SizedBox(width: 12),
                  Text(
                    _dueDate == null ? 'Choisir une date' : '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}',
                    style: TextStyle(color: _dueDate == null ? AppColors.textDisable : AppColors.textPrimary),
                  ),
                  const Spacer(),
                  if (_dueDate != null) GestureDetector(
                    onTap: () => setState(() => _dueDate = null),
                    child: const Icon(Icons.clear, size: 16, color: AppColors.textSecondary),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 32),

            CustomButton(
              text: _isEditing ? 'Modifier' : 'Créer la tâche',
              onPressed: _isLoading ? null : _handleSubmit,
              isLoading: _isLoading,
            ),
          ]),
        ),
      ),
    );
  }
}
