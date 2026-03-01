import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sunu_task/models/project.dart';
import 'package:sunu_task/providers/auth_provider.dart';
import 'package:sunu_task/providers/project_provider.dart';
import 'package:sunu_task/widgets/common/custom_button.dart';
import 'package:sunu_task/widgets/common/custom_text_field.dart';

/// Écran de création et modification de projet
class ProjectFormScreen extends StatefulWidget {
  // null = création, non-null = modification
  final Project? project;

  const ProjectFormScreen({super.key, this.project});

  @override
  State<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends State<ProjectFormScreen> {
  // Clé du formulaire pour la validation
  final _formKey = GlobalKey<FormState>();

  // Controllers pour lire les valeurs saisies
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Couleurs prédéfinies pour le projet
  final List<Color> _colors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
  ];

  // Couleur sélectionnée (bleu par défaut)
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();

    // Si modification → pré-remplir les champs
    if (widget.project != null) {
      _nameController.text = widget.project!.name;
      _descriptionController.text = widget.project!.description ?? '';
      _selectedColor = Color(widget.project!.color);
    } else {
      // Création → couleur par défaut
      _selectedColor = _colors[0];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Sauvegarde le projet (création ou modification)
  Future<void> _saveProject() async {
    // 1. Valider le formulaire
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final projectProvider = context.read<ProjectProvider>();

    if (widget.project == null) {
      // 2. Création d'un nouveau projet
      await projectProvider.createProject(
        authProvider.currentUser!.id,
        _nameController.text.trim(),
        _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        _selectedColor.value,
      );
    } else {
      // 3. Modification du projet existant
      final Project updatedProject = widget.project!.copyWith(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        color: _selectedColor.value,
      );
      await projectProvider.updateProject(updatedProject);
    }

    // 4. Retourner à l'écran précédent
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // Détermine si on est en mode création ou modification
    final bool isEditing = widget.project != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier le projet' : 'Nouveau projet'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Champ Nom du projet
              CustomTextField(
                label: 'Nom du projet',
                hint: 'Ex: Application Mobile',
                controller: _nameController,
                prefixIcon: Icons.folder,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom';
                  }
                  if (value.length < 3) {
                    return 'Minimum 3 caractères';
                  }
                  return null;
                },
              ),

              SizedBox(height: 16),

              // Champ Description
              CustomTextField(
                label: 'Description (optionnel)',
                hint: 'Décrivez votre projet...',
                controller: _descriptionController,
                maxLines: 3,
              ),

              SizedBox(height: 24),

              // Sélecteur de couleur
              Text(
                'Couleur du projet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              SizedBox(height: 12),

              // 8 cercles de couleurs
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _colors.map((color) {
                  final bool isSelected = _selectedColor == color;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedColor = color);
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        // Bordure blanche si sélectionné
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                        // Ombre si sélectionné
                        boxShadow: isSelected
                            ? [
                          BoxShadow(
                            color: color.withAlpha(150),
                            blurRadius: 8,
                            spreadRadius: 2,
                          )
                        ]
                            : null,
                      ),
                      // Icône de validation si sélectionné
                      child: isSelected
                          ? Icon(Icons.check, color: Colors.white, size: 20)
                          : null,
                    ),
                  );
                }).toList(),
              ),

              SizedBox(height: 24),

              // Aperçu en temps réel
              Text(
                'Aperçu',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              SizedBox(height: 12),

              // Aperçu de la carte projet
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _selectedColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _selectedColor.withAlpha(80)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _selectedColor.withAlpha(40),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.folder,
                          color: _selectedColor, size: 24),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nom en temps réel
                          ListenableBuilder(
                            listenable: _nameController,
                            builder: (context, _) {
                              return Text(
                                _nameController.text.isEmpty
                                    ? 'Nom du projet'
                                    : _nameController.text,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: _nameController.text.isEmpty
                                      ? Colors.grey
                                      : null,
                                ),
                              );
                            },
                          ),
                          // Description en temps réel
                          ListenableBuilder(
                            listenable: _descriptionController,
                            builder: (context, _) {
                              return Text(
                                _descriptionController.text.isEmpty
                                    ? 'Description...'
                                    : _descriptionController.text,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32),

              // Bouton Créer/Modifier
              Consumer<ProjectProvider>(
                builder: (context, provider, child) {
                  return CustomButton(
                    text: isEditing ? 'Modifier' : 'Créer le projet',
                    icon: isEditing ? Icons.save : Icons.add,
                    isLoading: provider.isLoading,
                    onPressed: _saveProject,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}