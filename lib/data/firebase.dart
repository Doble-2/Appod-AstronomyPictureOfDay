import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static const _localFavoritesKey = 'localFavorites';

  /// Lee la lista de favoritos local (SharedPreferences).
  Future<List<String>> _getLocalFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_localFavoritesKey) ?? [];
  }

  Future<String?> registration({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save the user's UID to SharedPreferences for future login
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userUID', userCredential.user!.uid);

      return 'Success';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        return 'The account already exists for that email.';
      } else {
        return e.message;
      }
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save the user's UID to SharedPreferences for future login
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userUID', userCredential.user!.uid);

      return 'Success';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        return 'Wrong password provided for that user.';
      } else {
        return e.message;
      }
    } catch (e) {
      return e.toString();
    }
  }

  // Function to check if a user is already logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    String? userUID = prefs.getString('userUID');

    if (userUID != null) {
      try {
        // Verify the user's UID with Firebase
        User? user = FirebaseAuth.instance.currentUser;
        return user != null && user.uid == userUID;
      } catch (e) {
        return false;
      }
    }
    return false;
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userUID');
  }

  Future<void> addFavorite(String date) async {
    final prefs = await SharedPreferences.getInstance();
    String? userUID = prefs.getString('userUID');

    // Sin sesión: favorito local (funciona sin login).
    if (userUID == null) {
      final local = await _getLocalFavorites();
      if (!local.contains(date)) {
        local.add(date);
        await prefs.setStringList(_localFavoritesKey, local);
      }
      return;
    }

    CollectionReference favorites =
        FirebaseFirestore.instance.collection('favorites');

    QuerySnapshot querySnapshot =
        await favorites.where('uid', isEqualTo: userUID).get();
    if (querySnapshot.docs.isNotEmpty) {
      // Document exists, update the 'favorites' array
      DocumentSnapshot documentSnapshot = querySnapshot.docs.first;

      Map<String, dynamic> data =
          documentSnapshot.data() as Map<String, dynamic>;
      List currentFavorites = data['images'] as List;
      if (currentFavorites.contains(date)) {
        // La fecha ya está en los favoritos, no la agregamos
        return;
      } else {
        currentFavorites.add(date);

        await favorites
            .doc(documentSnapshot.id)
            .update({'images': currentFavorites});
         
      }
    } else {
      // Document doesn't exist, create a new document
      await favorites
          .add({
            'uid': userUID,
            'images': [
              date
            ], // Initialize the favorites array with the new date
          });
    }
    return;
  }

  Future<List> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    String? userUID = prefs.getString('userUID');

    // Sin sesión: devolver favoritos locales.
    if (userUID == null) {
      return _getLocalFavorites();
    }

    CollectionReference favorites =
        FirebaseFirestore.instance.collection('favorites');

    QuerySnapshot querySnapshot =
        await favorites.where('uid', isEqualTo: userUID).get();
    if (querySnapshot.docs.isNotEmpty) {
      // Document exists, update the 'favorites' array
      DocumentSnapshot documentSnapshot = querySnapshot.docs.first;

      Map<String, dynamic> data =
          documentSnapshot.data() as Map<String, dynamic>;

      return data['images'] as List;
    } else {
      // Document doesn't exist, create a new document
      return [];
    }
  }

  Future<void> removeFavorite(String date) async {
    final prefs = await SharedPreferences.getInstance();
    String? userUID = prefs.getString('userUID');

    // Sin sesión: eliminar de favoritos locales.
    if (userUID == null) {
      final local = await _getLocalFavorites();
      local.remove(date);
      await prefs.setStringList(_localFavoritesKey, local);
      return;
    }

    CollectionReference favorites =
        FirebaseFirestore.instance.collection('favorites');

    QuerySnapshot querySnapshot =
        await favorites.where('uid', isEqualTo: userUID).get();

    if (querySnapshot.docs.isNotEmpty) {
      // Document exists, update the 'favorites' array
      DocumentSnapshot documentSnapshot = querySnapshot.docs.first;

      Map<String, dynamic> data =
          documentSnapshot.data() as Map<String, dynamic>;
      List currentFavorites = data['images'] as List;

      if (currentFavorites.contains(date)) {
        // La fecha está en los favoritos, la eliminamos
        currentFavorites.remove(date);

        await favorites
            .doc(documentSnapshot.id)
            .update({'images': currentFavorites});
      }
    }
    return;
  }
}
