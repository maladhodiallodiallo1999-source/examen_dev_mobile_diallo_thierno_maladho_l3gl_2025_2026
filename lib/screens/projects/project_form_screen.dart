import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:SunuTask/core/constants/app_colors.dart';
import 'package:SunuTask/models/project.dart';
import 'package:SunuTask/providers/auth_provider.dart';
import 'package:SunuTask/providers/project_provider.dart';
import 'package:SunuTask/widgets/common/custom_button.dart';
import 'package:SunuTask/widgets/common/custom_text_field.dart';
import 'package:SunuTask/widgets/cards/project_card.dart';

class ProjectFormScreen extends StatefulWidget {
  final Project? project; // null = création, non-null = modification
  const ProjectFormScreen({super.key, this.project});

  @override
  State<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends State<ProjectFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  final List<String> _colors = [
    '0xFF0293ED', '0xFF4CAF50', '0xFFE91E63', '0xFFFF5722',
    '0xFF9C27B0', '0xFF009688', '0xFFFF9800', '0xFF607D8B',
  ];

  String _selectedColor = '0xFF0293ED';
  bool _isLoading = false;
  bool get _isEditing => widget.project != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameController.text = widget.project!.name;
      _descriptionController.text = widget.project!.description;
      _selectedColor = widget.project!.color;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final userId = context.read<AuthProvider>().currentUser!.id;
    final provider = context.read<ProjectProvider>();

    if (_isEditing) {
      await provider.updateProject(widget.project!.copyWith(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        color: _selectedColor,
      ));
    } else {
      await provider.createProject(Project(
        id: const Uuid().v4(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        color: _selectedColor,
        userId: userId,
      ));
    }

    setState(() => _isLoading = false);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Modifier le projet' : 'Nouveau projet')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            CustomTextField(
              label: 'Nom du projet',
              controller: _nameController,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Nom obligatoire';
                if (v.trim().length < 3) return 'Minimum 3 caractères';
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(label: 'Description (optionnel)', controller: _descriptionController, maxLines: 3),
            const SizedBox(height: 24),

            // Sélecteur de couleur
            const Text('Couleur du projet', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12, runSpacing: 12,
              children: _colors.map((hex) {
                final isSelected = _selectedColor == hex;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = hex),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: Color(int.parse(hex)),
                      shape: BoxShape.circle,
                      border: isSelected ? Border.all(color: AppColors.textPrimary, width: 3) : null,
                      boxShadow: isSelected ? [BoxShadow(color: Color(int.parse(hex)).withOpacity(0.5), blurRadius: 8)] : null,
                    ),
                    child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),

            // Aperçu en temps réel
            const Text('Aperçu', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            ListenableBuilder(
              listenable: Listenable.merge([_nameController, _descriptionController]),
              builder: (_, __) => ProjectCard(
                project: Project(
                  id: 'preview',
                  name: _nameController.text.isEmpty ? 'Nom du projet' : _nameController.text,
                  description: _descriptionController.text,
                  color: _selectedColor,
                  userId: '',
                ),
              ),
            ),
            const SizedBox(height: 24),

            CustomButton(
              text: _isEditing ? 'Modifier' : 'Créer le projet',
              onPressed: _isLoading ? null : _handleSubmit,
              isLoading: _isLoading,
            ),
          ]),
        ),
      ),
    );
  }
}
