import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  Future<String?> registerUser({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final usernameTaken = await isUsernameTaken(username);
      if (usernameTaken) return 'Username already taken';

      final credentials = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _db.collection('users').doc(credentials.user!.uid).set({
        'username': username,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'isVerified': false,
        'bio': '',
        'avatarUrl': '',
      });

      await credentials.user?.sendEmailVerification();

      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') return 'Email already in use';
      if (e.code == 'weak-password') return 'Password too weak';
      return 'Registration failed: ${e.message}';
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  Future<String?> loginUser({
    required String identifier, 
    required String password,
  }) async {
    try {
      String email = identifier;

      
      if (!identifier.contains('@')) {
        final query = await _db
            .collection('users')
            .where('username', isEqualTo: identifier)
            .limit(1)
            .get();

        if (query.docs.isEmpty) return 'User not found';

        email = query.docs.first.data()['email'];
      }

      final credentials = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credentials.user!.reload();

      if (!credentials.user!.emailVerified) {
        await _auth.signOut();
        return 'Please verify your email before logging in.';
      }

      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') return 'User not found';
      if (e.code == 'wrong-password') return 'Wrong password';
      return 'Login failed: ${e.message}';
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  Future<void> logout() async => await _auth.signOut();

  Future<bool> isEmailVerified() async {
    final user = _auth.currentUser;
    await user?.reload();
    return user?.emailVerified ?? false;
  }

  Future<void> resendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  Future<bool> isUsernameTaken(String username) async {
    final result = await _db
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
    return result.docs.isNotEmpty;
  }

  Future<String?> getCurrentUsername() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data()?['username'];
  }

  String? getCurrentUserId() => _auth.currentUser?.uid;
  String? getCurrentUserEmail() => _auth.currentUser?.email;


  Future<String?> getCurrentEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    return user?.email;
  }
}