import 'package:flutter/material.dart';
import 'package:sunu_task/models/User.dart';
import 'package:sunu_task/services/storage_service.dart';
import 'package:uuid/uuid.dart';

/// Gère l'authentification et la session utilisateur
class AuthProvider extends ChangeNotifier {

  // ======== Propriétés privées =========
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  // ======== Getters publics =========
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ======== Méthodes =========

  /// Charge l'utilisateur connecté depuis le stockage
  Future<void> init() async {
    _currentUser = StorageService.instance.getCurrentUser();
    notifyListeners();
  }

  /// Connexion
  Future<bool> login(String email, String password) async {
    // 1. Démarrer le chargement
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 2. Récupérer tous les utilisateurs
      final List<User> users = StorageService.instance.getUsers();

      // 3. Chercher l'utilisateur avec cet email et mot de passe
      final User? user = users.firstWhere(
            (u) => u.email == email && u.password == password,
        orElse: () => throw Exception('Email ou mot de passe incorrect'),
      );

      // 4. Sauvegarder l'utilisateur connecté
      await StorageService.instance.saveCurrentUser(user!);
      _currentUser = user;

      _isLoading = false;
      notifyListeners();
      return true;

    } catch (e) {
      // 5. Erreur
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Inscription
  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. Vérifier si l'email existe déjà
      final List<User> users = StorageService.instance.getUsers();
      final bool emailExists = users.any((u) => u.email == email);

      if (emailExists) {
        throw Exception('Un compte existe déjà avec cet email');
      }

      // 2. Créer le nouvel utilisateur avec un ID unique
      final User newUser = User(
        id: const Uuid().v4(),
        name: name,
        email: email,
        password: password,
      );

      // 3. Sauvegarder l'utilisateur
      await StorageService.instance.saveUser(newUser);

      // 4. Connecter automatiquement
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
    _error = null;
    notifyListeners();
  }

  /// Mise à jour du profil
  Future<void> updateProfile({String? name, String? email}) async {
    if (_currentUser == null) return;

    final User updatedUser = _currentUser!.copyWith(
      name: name,
      email: email,
    );

    await StorageService.instance.saveCurrentUser(updatedUser);
    _currentUser = updatedUser;
    notifyListeners();
  }

  /// Efface le message d'erreur
  void clearError() {
    _error = null;
    notifyListeners();
  }
}