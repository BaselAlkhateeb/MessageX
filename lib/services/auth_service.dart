import 'package:firebase_auth/firebase_auth.dart';
import 'package:messagex/models/user_model.dart';
import 'package:messagex/services/firestore_service.dart';

class AuthService {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirestoreService firestoreService = FirestoreService();
  User? get currentUser => auth.currentUser;
  String? get currentUserId => auth.currentUser?.uid;
  Stream<User?> get authStateChanges => auth.authStateChanges();

  Future<UserModel?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;
      if (user != null) {
        await firestoreService.updateUserOnlineStatus(user.uid, true);
        return await firestoreService.getUser(user.uid);
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('faild to sign in : ${e.toString()}');
    }
  }

  Future<UserModel?> registerWithEmailAndPassword(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;
      if (user != null) {
        await user.updateDisplayName(displayName);
        final userModel = UserModel(
          id: user.uid,
          email: email,
          displayName: displayName,
          isOnline: true,
          photoUrl: '',
          lastSeen: DateTime.now(),
          createdAt: DateTime.now(),
        );

        await firestoreService.createUser(userModel);
        return userModel;
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('faild to register : ${e.toString()}');
    }
  }

  Future<void> sendRestPassword(String email) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('faild to reset password : ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    try {
      if (currentUser != null) {
        await firestoreService.updateUserOnlineStatus(currentUserId!, false);
      }
      await auth.signOut();
    } catch (e) {
      throw Exception('faild to sign out : ${e.toString()}');
    }
  }

  Future<void> deleteAccount() async {
    try {
      if (currentUser != null) {
        await firestoreService.deleteUser(currentUserId!);
        await currentUser!.delete();
      }
    } catch (e) {
      throw Exception('faild to sign out : ${e.toString()}');
    }
  }
}
