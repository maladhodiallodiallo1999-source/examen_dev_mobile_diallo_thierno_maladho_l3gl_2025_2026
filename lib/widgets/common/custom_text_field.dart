import 'package:flutter/material.dart';

/// Champ de texte personnalisé avec support de validation
/// C'est un StatefulWidget car il gère l'affichage/masquage du mot de passe
class CustomTextField extends StatefulWidget {
  // Le label affiché au dessus du champ (ex: "Email", "Mot de passe")
  final String label;

  // Le controller permet de lire la valeur saisie depuis l'extérieur
  final TextEditingController? controller;

  // Le texte d'exemple affiché quand le champ est vide
  final String? hint;

  // La fonction de validation - retourne un message d'erreur ou null si valide
  final String? Function(String?)? validator;

  // Si true, le texte est masqué (pour les mots de passe)
  final bool obscureText;

  // Le type de clavier à afficher (email, numérique, texte...)
  final TextInputType? keyboardType;

  // L'icône affichée à gauche du champ
  final IconData? prefixIcon;

  // Nombre de lignes du champ (1 par défaut, plus pour les descriptions)
  final int maxLines;

  const CustomTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.validator,
    this.obscureText = false, // Par défaut le texte est visible
    this.keyboardType,
    this.prefixIcon,
    this.maxLines = 1, // Par défaut une seule ligne
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  // Variable qui contrôle si le mot de passe est masqué ou visible
  // true = masqué (par défaut), false = visible
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      // widget.controller = accès aux propriétés du StatefulWidget depuis le State
      controller: widget.controller,

      // Si c'est un champ mot de passe, on utilise _isObscured pour basculer
      // Sinon on affiche toujours le texte normalement
      obscureText: widget.obscureText ? _isObscured : false,

      // Type de clavier adapté (email, numérique...)
      keyboardType: widget.keyboardType,

      // Un champ mot de passe ne peut avoir qu'une seule ligne
      maxLines: widget.obscureText ? 1 : widget.maxLines,

      // Fonction de validation appelée quand on soumet le formulaire
      validator: widget.validator,

      decoration: InputDecoration(
        // Label et placeholder
        labelText: widget.label,
        hintText: widget.hint,

        // Icône à gauche du champ (optionnelle)
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon)
            : null,

        // Icône œil à droite - uniquement pour les champs mot de passe
        // Permet de basculer entre masqué et visible
        suffixIcon: widget.obscureText
            ? IconButton(
          icon: Icon(
            // Change l'icône selon l'état : œil ouvert ou fermé
            _isObscured ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            // setState redessine le widget avec le nouvel état
            setState(() {
              _isObscured = !_isObscured; // Inverse la valeur
            });
          },
        )
            : null,

        // Bordure normale (champ inactif)
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),

        // Bordure quand le champ est inactif - gris clair
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),

        // Bordure quand le champ est actif (l'utilisateur tape) - couleur principale
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),

        // Bordure quand la validation échoue - rouge
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red, width: 1),
        ),

        // Fond légèrement grisé pour mieux distinguer le champ
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }
}