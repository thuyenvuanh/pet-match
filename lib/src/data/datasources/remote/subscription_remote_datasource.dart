import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_match/src/domain/models/subscription_model.dart';
import 'package:pet_match/src/utils/error/exceptions.dart';
import 'package:pet_match/src/utils/rest_helper.dart';

class SubscriptionRemoteDataSource {
  static const getCurrentActiveSubEndpoint = "pet-match/api/v1/subscription/current";
  static final _userId = FirebaseAuth.instance.currentUser!.uid;

  final RestClient restClient;

  SubscriptionRemoteDataSource(this.restClient);

  Future<Subscription> getSubscriptionData(String userId) async {
    try {
      String res =
          await restClient.get('$getCurrentActiveSubEndpoint/$_userId');
      Subscription subscription = Subscription.fromJson(json.decode(res));
      return subscription;
    } on NetworkException {
      dev.log('[swipe_remote_datasource] Failed to get suggestion profiles');
      rethrow;
    } on TimeoutException {
      dev.log('[swipe_remote_datasource] Server take too long to response');
      rethrow;
    }
  }
}

    //! MOCK DATA
    // final startFrom = DateTime.now().subtract(const Duration(days: 100));
    // Subscription basicSub = Subscription(
    //   id: faker.guid.guid(),
    //   duration: const Duration(days: 0),
    //   name: "BASIC",
    //   startFrom: startFrom,
    //   status: "Active",
    // );
    // Subscription premiumSub = Subscription(
    //   id: faker.guid.guid(),
    //   duration: const Duration(days: 100),
    //   name: "PREMIUM",
    //   startFrom: startFrom.add(const Duration(days: 100)),
    //   status: "Active",
    // );
    // return basicSub;