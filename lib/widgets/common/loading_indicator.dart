import 'package:flutter/material.dart';

/// Indicateur de chargement réutilisable
/// Affiché quand l'app charge des données (isLoading = true)
class LoadingIndicator extends StatelessWidget {
  // Taille du cercle de chargement (par défaut 40)
  final double size;

  // Couleur du cercle (par défaut la couleur principale du thème)
  final Color? color;

  const LoadingIndicator({
    super.key,
    this.size = 40,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          // Si une couleur est fournie on l'utilise, sinon on prend la couleur du thème
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? Theme.of(context).primaryColor,
          ),
          strokeWidth: 3,
        ),
      ),
    );
  }
}