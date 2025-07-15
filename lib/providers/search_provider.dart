import 'package:flutter/material.dart';
import '../features/auth/domain/user_model.dart';
import '../features/search/data/search_service.dart';

class SearchProvider extends ChangeNotifier {
  final _service = SearchService();
  List<UserModel> _results = [];

  List<UserModel> get results => _results;

  Future<void> search(String query) async {
    if (query.trim().isEmpty) return;

    _results = await _service.searchUsers(query.trim());
    notifyListeners();
  }

  void clear() {
    _results = [];
    notifyListeners();
  }
}