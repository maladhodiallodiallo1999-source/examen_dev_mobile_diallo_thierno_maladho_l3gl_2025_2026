import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:SunuTask/core/constants/app_colors.dart';
import 'package:SunuTask/core/constants/app_strings.dart';
import 'package:SunuTask/providers/auth_provider.dart';
import 'package:SunuTask/providers/project_provider.dart';
import 'package:SunuTask/providers/task_provider.dart';
import 'package:SunuTask/screens/auth/login_screen.dart';
import 'package:SunuTask/screens/home/tabs/dashboard_tab.dart';
import 'package:SunuTask/screens/home/tabs/projects_tab.dart';
import 'package:SunuTask/screens/home/tabs/tasks_tab.dart';
import 'package:SunuTask/screens/home/tabs/profile_tab.dart';
import 'package:SunuTask/screens/projects/project_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    DashboardTab(),
    ProjectsTab(),
    TasksTab(),
    ProfileTab(),
  ];

  final List<String> _titles = [
    AppStrings.home,
    AppStrings.projects,
    AppStrings.tasks,
    AppStrings.profile,
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      await context.read<ProjectProvider>().loadProjects(user.id);
      await context.read<TaskProvider>().loadAllTasks(user.id);
    }
  }

  Future<void> _handleLogout() async {
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (r) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(title: Text(_titles[_currentIndex])),

      // ===== DRAWER =====
      drawer: Drawer(
        child: Column(children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primary),
            accountName: Text(user?.name ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: Text(user?.email ?? ''),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : '?',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ),
          ),
          _DrawerItem(icon: Icons.dashboard_outlined, label: AppStrings.home, index: 0, current: _currentIndex, onTap: (i) { setState(() => _currentIndex = i); Navigator.pop(context); }),
          _DrawerItem(icon: Icons.folder_outlined, label: AppStrings.projects, index: 1, current: _currentIndex, onTap: (i) { setState(() => _currentIndex = i); Navigator.pop(context); }),
          _DrawerItem(icon: Icons.check_circle_outline, label: AppStrings.tasks, index: 2, current: _currentIndex, onTap: (i) { setState(() => _currentIndex = i); Navigator.pop(context); }),
          _DrawerItem(icon: Icons.person_outlined, label: AppStrings.profile, index: 3, current: _currentIndex, onTap: (i) { setState(() => _currentIndex = i); Navigator.pop(context); }),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text(AppStrings.logout, style: TextStyle(color: AppColors.error)),
            onTap: _handleLogout,
          ),
        ]),
      ),

      // ===== BODY avec IndexedStack =====
      body: IndexedStack(index: _currentIndex, children: _tabs),

      // ===== BOTTOM NAV =====
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textDisable,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.folder_outlined), label: 'Projets'),
          BottomNavigationBarItem(icon: Icon(Icons.check_circle_outline), label: 'Tâches'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outlined), label: 'Profil'),
        ],
      ),

      // ===== FAB sur Dashboard et Projets =====
      floatingActionButton: _currentIndex <= 1
          ? FloatingActionButton(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProjectFormScreen())),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index, current;
  final void Function(int) onTap;
  const _DrawerItem({required this.icon, required this.label, required this.index, required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, color: index == current ? AppColors.primary : AppColors.textSecondary),
    title: Text(label, style: TextStyle(color: index == current ? AppColors.primary : AppColors.textPrimary, fontWeight: index == current ? FontWeight.w600 : FontWeight.normal)),
    selected: index == current,
    onTap: () => onTap(index),
  );
}
