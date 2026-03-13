import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:SunuTask/models/User.dart';
import 'package:SunuTask/services/storage_service.dart';

/// Gère l'authentification et la session utilisateur
class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Charge l'utilisateur connecté depuis le stockage
  Future<void> init() async {
    _currentUser = await StorageService.instance.getCurrentUser();
    notifyListeners();
  }

  /// Connexion avec email + mot de passe
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final users = await StorageService.instance.getUsers();

      // Cherche l'utilisateur avec ces identifiants
      final matches = users.where(
        (u) => u.email == email && u.password == password,
      ).toList();

      if (matches.isEmpty) {
        throw Exception('Email ou mot de passe incorrect');
      }

      final user = matches.first;
      await StorageService.instance.saveCurrentUser(user);
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return true;

    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Inscription : crée un nouvel utilisateur
  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final users = await StorageService.instance.getUsers();

      // Vérifie si l'email est déjà utilisé
      final emailExists = users.any((u) => u.email == email);
      if (emailExists) {
        throw Exception('Un compte existe déjà avec cet email');
      }

      // Crée le nouvel utilisateur
      final newUser = User(
        id: const Uuid().v4(),
        name: name,
        email: email,
        password: password,
      );

      await StorageService.instance.saveUser(newUser);
      await StorageService.instance.saveCurrentUser(newUser);
      _currentUser = newUser;
      _isLoading = false;
      notifyListeners();
      return true;

    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Déconnexion
  Future<void> logout() async {
    await StorageService.instance.clearCurrentUser();
    _currentUser = null;
    notifyListeners();
  }

  /// Met à jour le profil utilisateur
  Future<void> updateProfile({String? name, String? email}) async {
    if (_currentUser == null) return;
    final updated = _currentUser!.copyWith(
      name: name ?? _currentUser!.name,
      email: email ?? _currentUser!.email,
    );
    await StorageService.instance.saveCurrentUser(updated);
    await StorageService.instance.saveUser(updated);
    _currentUser = updated;
    notifyListeners();
  }

  /// Efface le message d'erreur
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
