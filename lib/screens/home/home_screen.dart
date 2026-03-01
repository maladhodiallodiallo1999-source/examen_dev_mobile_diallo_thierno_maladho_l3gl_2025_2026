import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sunu_task/providers/auth_provider.dart';
import 'package:sunu_task/providers/project_provider.dart';
import 'package:sunu_task/providers/task_provider.dart';
import 'package:sunu_task/screens/auth/login_screen.dart';
import 'package:sunu_task/screens/home/tabs/dashboard_tab.dart';
import 'package:sunu_task/screens/home/tabs/profile_tab.dart';
import 'package:sunu_task/screens/home/tabs/projects_tab.dart';
import 'package:sunu_task/screens/home/tabs/tasks_tab.dart';
import 'package:sunu_task/screens/projects/project_form_screen.dart';

/// Écran principal avec navigation par onglets
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Index de l'onglet actuel (0 = Dashboard)
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Charger les données au démarrage
    _loadData();
  }

  /// Charge les projets et tâches de l'utilisateur connecté
  Future<void> _loadData() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser == null) return;

    final String userId = authProvider.currentUser!.id;

    // Charger les projets
    await context.read<ProjectProvider>().loadProjects(userId);
    // Charger les tâches
    await context.read<TaskProvider>().loadTasksByUser(userId);
  }

  /// Déconnexion de l'utilisateur
  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
      );
    }
  }

  /// Titres des onglets
  String get _currentTitle {
    switch (_currentIndex) {
      case 0: return 'Dashboard';
      case 1: return 'Projets';
      case 2: return 'Tâches';
      case 3: return 'Profil';
      default: return 'SunuTask';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Récupère l'utilisateur connecté
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentTitle),
        elevation: 0,
      ),

      // Menu latéral (Drawer)
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // En-tête du Drawer avec infos utilisateur
            UserAccountsDrawerHeader(
              accountName: Text(
                user?.name ?? 'Utilisateur',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(user?.email ?? ''),
              // Avatar avec la première lettre du nom
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  user?.name.isNotEmpty == true
                      ? user!.name[0].toUpperCase()
                      : 'U',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
            ),

            // Items de navigation
            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text('Dashboard'),
              selected: _currentIndex == 0,
              onTap: () {
                setState(() => _currentIndex = 0);
                Navigator.pop(context); // Ferme le Drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.folder),
              title: Text('Projets'),
              selected: _currentIndex == 1,
              onTap: () {
                setState(() => _currentIndex = 1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.task),
              title: Text('Tâches'),
              selected: _currentIndex == 2,
              onTap: () {
                setState(() => _currentIndex = 2);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profil'),
              selected: _currentIndex == 3,
              onTap: () {
                setState(() => _currentIndex = 3);
                Navigator.pop(context);
              },
            ),

            Divider(),

            // Bouton déconnexion
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text('Déconnexion',
                  style: TextStyle(color: Colors.red)),
              onTap: _logout,
            ),
          ],
        ),
      ),

      // Contenu principal — IndexedStack préserve l'état des onglets
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          DashboardTab(),
          ProjectsTab(),
          TasksTab(),
          ProfileTab(),
        ],
      ),

      // Barre de navigation en bas
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: 'Projets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task),
            label: 'Tâches',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),

      // Bouton flottant visible sur Dashboard et Projets
      floatingActionButton: _currentIndex <= 1
          ? FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ProjectFormScreen(),
            ),
          );
        },
        child: Icon(Icons.add),
      )
          : null,
    );
  }
}