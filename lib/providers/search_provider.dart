import 'package:flutter/material.dart';
import '../features/auth/domain/user_model.dart';
import '../features/search/data/search_service.dart';

class SearchProvider extends ChangeNotifier {
  final _service = SearchService();
  List<UserModel> _results = [];

  List<UserModel> get results => _results;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> search(String query) async {
    query = query.trim();
    if (query.isEmpty) return;

    _isLoading = true;
    _results = [];
    notifyListeners();

    _results = await _service.searchUsers(query);

    _isLoading = false;
    notifyListeners();
  }

  void clear() {
    _results = [];
    notifyListeners();
  }
}