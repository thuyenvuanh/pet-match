import 'dart:io';

import 'package:pet_match/src/domain/models/breed_model.dart';
import 'package:pet_match/src/domain/models/location_model.dart';

class Profile {
  String? id;
  Breed? breed;
  String? name;
  String? gender;
  double? height;
  double? weight;
  File? avatarFile;
  String? avatar;
  String? cover;
  DateTime? birthday;
  Location? location;
  String? introduction;
  List<Breed>? interests;
  List<String>? gallery;

  Profile(
      {this.id,
      this.breed,
      this.name,
      this.gender,
      this.height,
      this.weight,
      this.avatarFile,
      this.cover,
      this.birthday,
      this.location,
      this.introduction,
      this.interests,
      this.gallery});

  Profile.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    breed = json['type'] != null ? Breed.fromJson(json['type']) : null;
    name = json['name'];
    gender = json['gender'];
    avatar = json['avatar'];
    cover = json['cover'];
    height = json['height'];
    weight = json['weight'];
    birthday = DateTime.fromMillisecondsSinceEpoch(int.parse(json['birthday']));
    location =
        json['location'] != null ? Location.fromJson(json['location']) : null;
    introduction = json['introduction'];
    if (json['interests'] != null) {
      interests = <Breed>[];
      json['interests'].forEach((v) {
        interests!.add(Breed.fromJson(v));
      });
    }
    gallery = json['gallery'];
  }

  Profile.fromShortJson(Map<String, dynamic> json) {
    id = json['id'];
    avatar = json['avatar'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    if (breed != null) {
      data['type'] = breed!.toJson();
    }
    data['name'] = name;
    data['gender'] = gender;
    data['avatar'] = avatar;
    data['cover'] = cover;
    data['height'] = height;
    data['weight'] = weight;
    if (birthday != null) {
      data['birthday'] = birthday!.millisecondsSinceEpoch.toString();
    }
    if (location != null) {
      data['location'] = location!.toJson();
    }
    data['introduction'] = introduction;
    if (interests != null) {
      data['interests'] = interests!.map((v) => v.toJson()).toList();
    }
    data['gallery'] = gallery;
    return data;
  }
}
