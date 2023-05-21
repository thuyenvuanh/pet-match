import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pet_match/src/utils/error/failure.dart';

class FirebaseDataSource {
  static const String firebaseAuthClientId =
      "1000051075559-gdsppsaspenpnlg5mbhn9gdkaeu1e547.apps.googleusercontent.com";

  final fi = FirebaseAuth.instance;

  String? get userId => fi.currentUser?.uid;

  Future<UserCredential> signInGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    return await fi.signInWithCredential(credential);
  }

  Future<void> sendOtp({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(String, int?) codeSent,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    try {
      if (fi.currentUser == null) throw Exception("User not found");
      await fi.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        timeout: const Duration(minutes: 2),
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      );
    } on Exception catch (e) {
      throw AuthFailure(code: "UNKNOWN", message: e.toString());
    }
  }

  Future<User> link(PhoneAuthCredential credential) async {
    var cre = await fi.currentUser!.linkWithCredential(credential);
    return cre.user!;
  }
}
