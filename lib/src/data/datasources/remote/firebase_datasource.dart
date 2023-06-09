import 'dart:convert';
import 'dart:developer' as dev;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pet_match/src/api/auth_request.dart';
import 'package:pet_match/src/domain/models/token_model.dart';
import 'package:pet_match/src/utils/error/exceptions.dart';
import 'package:pet_match/src/utils/extensions.dart';
import 'package:pet_match/src/utils/firebase_options.dart';
import 'package:pet_match/src/utils/rest_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRemoteDataSource {
  static const String firebaseAuthClientId =
      "1000051075559-gdsppsaspenpnlg5mbhn9gdkaeu1e547.apps.googleusercontent.com";
  static const _authServer = "/pet-match/api/v1/auth/authenticate";
  static const _authKey = 'authToken';

  final fi = FirebaseAuth.instance;
  final RestClient _restClient;
  final SharedPreferences _localStorage;

  String? get userId => fi.currentUser?.uid;

  AuthRemoteDataSource(RestClient restClient, SharedPreferences localStorage)
      : _restClient = restClient,
        _localStorage = localStorage;

  Future<User?> signInGoogle() async {
    final GoogleSignInAccount? googleUser;
    try {
      if (DefaultFirebaseOptions.currentPlatform ==
          DefaultFirebaseOptions.ios) {
        googleUser =
            await GoogleSignIn(clientId: firebaseAuthClientId).signIn();
      } else {
        googleUser = await GoogleSignIn().signIn();
      }
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      await fi.signInWithCredential(credential);
      final idTokenString = (await fi.currentUser?.getIdTokenResult())?.token;

      final authReq = AuthorizationRequest(
        idTokenString: idTokenString,
        fcmToken: await FirebaseMessaging.instance.getToken(),
      );
      var res = await _restClient.post(
        _authServer,
        authorization: false,
        body: json.encode(authReq.toJson()),
      );
      Map<String, dynamic> response = json.decode(res);
      final authToken = AuthorizationToken.fromJson(response);
      dev.log(authToken.accessToken!);
      _localStorage.addToAuthStorage(_authKey, authToken.toJson());
      return fi.currentUser!;
    } catch (e) {
      fi.signOut();
      return null;
    }
  }

  Future<void> sendOtp({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(String, int?) codeSent,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    try {
      if (fi.currentUser == null) throw const AuthException("User not found");
      await fi.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        timeout: const Duration(minutes: 2),
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      );
    } on FirebaseAuthException catch (e) {
      dev.log('error occurred when verify phone number: ${e.code}');
      throw AuthException(e.code);
    } on AuthException {
      rethrow;
    }
  }

  Future<User> link(PhoneAuthCredential credential) async {
    var cre = await fi.currentUser!.linkWithCredential(credential);
    return cre.user!;
  }

  Future<void> signOut() async {
    await _localStorage.resetAuthStorage();
    await _localStorage.resetSessionStorage();
    await fi.signOut();
  }
}
