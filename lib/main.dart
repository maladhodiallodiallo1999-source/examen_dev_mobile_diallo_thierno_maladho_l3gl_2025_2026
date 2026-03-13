import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:SunuTask/core/theme/app_theme.dart';
import 'package:SunuTask/providers/app_provider.dart';
import 'package:SunuTask/providers/auth_provider.dart';
import 'package:SunuTask/providers/project_provider.dart';
import 'package:SunuTask/providers/task_provider.dart';
import 'package:SunuTask/screens/splash/splash_screen.dart';
import 'package:SunuTask/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.instance.init();
  runApp(const SunuTask());
}

class SunuTask extends StatelessWidget {
  const SunuTask({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProjectProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
      ],
      child: MaterialApp(
        title: 'SunuTask',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        home: const SplashScreen(),
      ),
    );
  }
}