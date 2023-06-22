import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;

import 'package:pet_match/src/api/send_like_request.dart';
import 'package:pet_match/src/api/send_pass_request.dart';
import 'package:pet_match/src/domain/models/profile_model.dart';
import 'package:pet_match/src/utils/error/exceptions.dart';
import 'package:pet_match/src/utils/rest_helper.dart';
import 'package:pet_match/src/domain/models/reaction.dart';

class SwipeRemoteDataSource {
  final RestClient _client;

  static const String getSuggestions = '/pet-match/api/v1/profiles/suggestion';
  static const String sendReaction = '/pet-match/api/v1/reaction';
  static const String sendPassReaction = '/pet-match/api/v1/reaction/remove';
  static const String getLikedProfilesNP = '/pet-match/api/v1/reaction/likes';

  SwipeRemoteDataSource(RestClient restClient) : _client = restClient;

  Future<List<Reaction>> getLikedProfiles(Profile profile) async {
    try {
      final res = await _client.get('$getLikedProfilesNP/${profile.id}');
      List<dynamic> likedProfilesJson = List.from(json.decode(res));
      return likedProfilesJson.map((e) => Reaction.fromJson(e)).toList();
    } on NetworkException {
      dev.log('[swipe_remote_datasource] Failed to get suggestion profiles');
      rethrow;
    } on TimeoutException {
      dev.log('[swipe_remote_datasource] Server take too long to response');
      rethrow;
    }
  }

  Future<List<Profile>> getSuggestion(Profile profile) async {
    try {
      final res = await _client.post(
        getSuggestions,
        body: json.encode({
          'profile-id': profile.id,
        }),
      );
      List<dynamic> suggestionList = List.castFrom(json.decode(res));
      return suggestionList.map((e) => Profile.fromJson(e)).toList();
    } on NetworkException {
      dev.log('[swipe_remote_datasource] Failed to get suggestion profiles');
      rethrow;
    } on TimeoutException {
      dev.log('[swipe_remote_datasource] Server take too long to response');
      rethrow;
    }
  }

  Future<Reaction> sendLike(Profile from, Profile to, String? comment) async {
    try {
      var reqBody = ReactionRequest(
        createdBy: from.id,
        profileId: to.id,
        comment: comment,
      );
      String body = await _client.post(
        sendReaction,
        body: json.encode(reqBody.toJson()),
      );
      dev.log('[swipe_remote_datasource] Submitted successfully');
      Reaction reaction = Reaction.fromJson(json.decode(body));
      return reaction;
    } on NetworkException {
      dev.log('[swipe_remote_datasource] Failed to send like');
      rethrow;
    } on TimeoutException {
      dev.log('[swipe_remote_datasource] Server take too long to response');
      rethrow;
    }
  }

  Future<Reaction> sendPass(Profile createdBy, Profile profile) async {
    try {
      var passRequest = SendPassRequest(
        createdBy: createdBy.id,
        profile: profile.id,
      );
      String body = await _client.post(sendPassReaction,
          body: json.encode(passRequest.toJson()));
      Reaction data = Reaction.fromJson(json.decode(body));
      dev.log('[swipe_remote_datasource] passed');
      return data;
    } on NetworkException {
      dev.log('[swipe_remote_datasource] Failed to send like');
      rethrow;
    } on TimeoutException {
      dev.log('[swipe_remote_datasource] Server take too long to response');
      rethrow;
    }
  }
}
