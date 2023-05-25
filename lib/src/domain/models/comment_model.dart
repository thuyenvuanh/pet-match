import 'package:intl/intl.dart';
import 'package:pet_match/src/domain/models/profile_model.dart';
import 'package:pet_match/src/utils/extensions.dart';

class Comment {
  String? id;
  String? comment;
  Profile? profile;
  DateTime? createdTS;
  DateTime? updatedTS;

  Comment(
      {this.id, this.comment, this.createdTS, this.updatedTS, this.profile});

  Comment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    comment = json['comment'];
    createdTS = DateFormat().parsePetMatch(json['created-date']);
    updatedTS = DateFormat().parsePetMatch(json['updated-date']);
    profile = Profile.fromJson(json['profile']);
  }

  toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['comment'] = comment;
    data['created-date'] = DateFormat().formatPetMatch(createdTS!);
    data['updated-date'] = DateFormat().formatPetMatch(updatedTS!);
    if (profile != null) {
      data['profile'] = profile!.toJson();
    }
  }
}
