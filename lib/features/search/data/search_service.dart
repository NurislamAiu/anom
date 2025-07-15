import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auth/domain/user_model.dart';

class SearchService {
  final _db = FirebaseFirestore.instance;

  Future<List<UserModel>> searchUsers(String query) async {
    final snapshot = await _db
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: query)
        .where('username', isLessThanOrEqualTo: query + '\uf8ff')
        .get();

    return snapshot.docs
        .map((doc) => UserModel.fromJson(doc.data()))
        .toList();
  }
}