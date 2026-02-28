import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sunu_task/providers/auth_provider.dart';
import 'package:sunu_task/providers/project_provider.dart';
import 'package:sunu_task/providers/task_provider.dart';
import 'package:sunu_task/screens/auth/login_screen.dart';

/// Onglet Profil - Informations de l'utilisateur connecté
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final projectCount = context.watch<ProjectProvider>().projectCount;
    final taskCount = context.watch<TaskProvider>().tasks.length;

    if (user == null) return SizedBox();

    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        SizedBox(height: 24),

        // Avatar et nom
        Center(
          child: Column(
            children: [
              // Avatar avec première lettre du nom
              CircleAvatar(
                radius: 50,
                backgroundColor: Theme.of(context).primaryColor,
                child: Text(
                  user.name[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Nom
              Text(
                user.name,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 4),

              // Email
              Text(
                user.email,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),

              SizedBox(height: 8),

              // Date d'inscription
              Text(
                'Membre depuis le ${_formatDate(user.createdAt)}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 32),

        // Statistiques personnelles
        Text(
          'Mes statistiques',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        SizedBox(height: 12),

        Row(
          children: [
            // Nombre de projets
            Expanded(
              child: _buildStatCard(
                title: 'Projets',
                value: projectCount.toString(),
                icon: Icons.folder,
                color: Colors.blue,
              ),
            ),
            SizedBox(width: 12),
            // Nombre de tâches
            Expanded(
              child: _buildStatCard(
                title: 'Tâches',
                value: taskCount.toString(),
                icon: Icons.task,
                color: Colors.green,
              ),
            ),
          ],
        ),

        SizedBox(height: 32),

        // Bouton déconnexion
        OutlinedButton.icon(
          onPressed: () async {
            // Confirmation avant déconnexion
            final bool? confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Déconnexion'),
                content: Text('Voulez-vous vraiment vous déconnecter ?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text('Annuler'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text('Déconnexion',
                        style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );

            if (confirm == true) {
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                );
              }
            }
          },
          icon: Icon(Icons.logout, color: Colors.red),
          label: Text(
            'Déconnexion',
            style: TextStyle(color: Colors.red),
          ),
          style: OutlinedButton.styleFrom(
            minimumSize: Size(double.infinity, 50),
            side: BorderSide(color: Colors.red),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  /// Carte de statistique
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  /// Formate la date en texte lisible
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}