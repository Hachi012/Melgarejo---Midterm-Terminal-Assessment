import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ResourceProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<dynamic> _posts = [];
  List<dynamic> _users = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<dynamic> get posts => _posts;
  List<dynamic> get users => _users;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> loadPosts() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _posts = await _apiService.getPosts();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error loading posts: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUsers() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _users = await _apiService.getUsers();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error loading users: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
