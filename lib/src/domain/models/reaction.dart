import 'package:intl/intl.dart';
import 'package:pet_match/src/domain/models/profile_model.dart';
import 'package:pet_match/src/utils/extensions.dart';

class Reaction {
  String? comment;
  DateTime? createdTS;
  DateTime? updatedTS;
  Profile? profile;

  Reaction({
    this.comment,
    this.createdTS,
    this.updatedTS,
    this.profile,
  });

  Reaction.fromJson(Map<String, dynamic> json) {
    comment = json['comment'];
    createdTS = DateFormat().parsePetMatch(json['created-at']);
    updatedTS = DateFormat().parsePetMatch(json['updated-at']);
    profile = Profile.fromJson(json['profile']);
  }

  toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['comment'] = comment;
    data['created-at'] = DateFormat().formatPetMatch(createdTS!);
    data['updated-at'] = DateFormat().formatPetMatch(updatedTS!);
    data['profile'] = profile!.toJson();
    return data;
  }
}
