import 'dart:developer' as dev;
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_match/src/domain/models/subscription_model.dart';
import 'package:pet_match/src/utils/extensions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionLocalDataSource {
  final SharedPreferences _localStorage;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String _subscriptionKey = "subscription";

  SubscriptionLocalDataSource(SharedPreferences sharedPreferences)
      : _localStorage = sharedPreferences;

  Future<Subscription> cacheData(Subscription subscription) async {
    await _localStorage.addToAuthStorage(
        _subscriptionKey, subscription.toJson());
    if (!subscription.isActive()) {
      await getRemainsSwipe();

      // List<Map<String, dynamic>> counts =
      //     _localStorage.getFromGlobalStorage(_swipeCountLog) ?? [];
      // Map<String, dynamic> log = counts.firstWhere(
      //   (element) =>
      //       element['user-id'] == FirebaseAuth.instance.currentUser!.uid,
      //   orElse: () => {},
      // );
      // if (log.isEmpty) {
      //   const newData = <String, dynamic>{};
      //   newData['user-id'] = FirebaseAuth.instance.currentUser!.uid;
      //   newData['date'] = DateTime.now();
      //   newData['remains'] = 5;
      //   newData['adsClicked'] = 0;
      //   counts.add(newData);
      // }
      // if (log.isNotEmpty && !(log['date'] as DateTime).isToday()) {
      //   log['date'] = DateTime.now();
      //   log['remains'] = 5;
      //   log['adsClicked'] = 0;
      // }
      // await _localStorage.addToGlobalStorage(_swipeCountLog, counts);
    }
    return subscription;
  }

  Subscription? getSubscriptionData() {
    final map = _localStorage.getFromAuthStorage(_subscriptionKey);
    if (map == null) {
      return null;
    }
    return Subscription.fromJson(map);
  }

  Future<int> getRemainsSwipe() async {
    try {
      CollectionReference counts =
          FirebaseFirestore.instance.collection('counts');
      final doc = await counts.doc(_auth.currentUser!.uid).get();
      if (doc.data() == null) {
        var newData = <String, dynamic>{};
        newData['user-id'] = FirebaseAuth.instance.currentUser!.uid;
        newData['date'] = DateTime.now();
        newData['remains'] = 5;
        newData['adsClicked'] = 0;
        await counts.doc(_auth.currentUser!.uid).set(newData);
        return newData['remains'];
      }

      if (!(doc.get('date') as Timestamp).toDate().isToday()) {
        await counts.doc(_auth.currentUser!.uid).update({
          'date': DateTime.now(),
          'remains': 5,
        });
        return 5;
      }
      return doc['remains'];
    } on Exception catch (e) {
      dev.log(e.runtimeType.toString());
      rethrow;
    }
  }

  Future<void> subtractRemain() async {
    CollectionReference counts =
        FirebaseFirestore.instance.collection('counts');
    final doc = await counts.doc(_auth.currentUser!.uid).get();
    await counts.doc(_auth.currentUser!.uid).update({
      'remains': max(doc.get('remains') - 1, 0),
    });
  }

  Future<int> addMoreSwipes() async {
    CollectionReference counts =
        FirebaseFirestore.instance.collection('counts');
    final doc = await counts.doc(_auth.currentUser!.uid).get();
    await counts.doc(_auth.currentUser!.uid).update({
      'remains': doc.get('remains') + 1,
    });
    return (await counts.doc(_auth.currentUser!.uid).get()).get('remains');
  }
}
