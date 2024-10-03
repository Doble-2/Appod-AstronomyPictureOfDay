import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nasa_apod/ui/blocs/apod_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  // ignore: unused_field
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
        User? user = await FirebaseAuth.instance.currentUser;
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

  Future<Future<void>> addFavorite(String date) async {
    Fluttertoast.showToast(
        msg: "Procesando la solicitud, por favor espere...",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        fontSize: 16.0);
    final prefs = await SharedPreferences.getInstance();
    String? userUID = prefs.getString('userUID');

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
        return Fluttertoast.showToast(
            msg: "La fecha ya está en tus favoritos.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            fontSize: 16.0);
      } else {
        currentFavorites.add(date);

        favorites
            .doc(documentSnapshot.id)
            .update({'images': currentFavorites})
            .then((value) => print("Favorite added successfully!"))
            .catchError((error) => print("Failed to update favorite: $error"));

        return Fluttertoast.showToast(
            msg: "Operación completada con éxito.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            fontSize: 16.0);
      }
    } else {
      // Document doesn't exist, create a new document
      favorites
          .add({
            'uid': userUID,
            'images': [
              date
            ], // Initialize the favorites array with the new date
          })
          .then((value) => print("Favorite added successfully!"))
          .catchError((error) => print("Failed to add favorite: $error"));
      return Fluttertoast.showToast(
          msg: "Ha ocurrido un error. Vuelva a intentarlo.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          fontSize: 16.0);
    }
  }

  Future<List> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    String? userUID = prefs.getString('userUID');

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

  Future<Future<void>> removeFavorite(String date) async {
    Fluttertoast.showToast(
        msg: "Procesando la solicitud, por favor espere...",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        fontSize: 16.0);
    final prefs = await SharedPreferences.getInstance();
    String? userUID = prefs.getString('userUID');

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

        favorites
            .doc(documentSnapshot.id)
            .update({'images': currentFavorites})
            .then((value) => print("Favorite removed successfully!"))
            .catchError((error) => print("Failed to update favorite: $error"));

        return Fluttertoast.showToast(
            msg: "La fecha ha sido eliminada de tus favoritos.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            fontSize: 16.0);
      } else {
        // La fecha no está en los favoritos
        return Fluttertoast.showToast(
            msg: "La fecha no está en tus favoritos.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            fontSize: 16.0);
      }
    } else {
      // Document doesn't exist
      return Fluttertoast.showToast(
          msg: "No hay favoritos para eliminar.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          fontSize: 16.0);
    }
  }
}
