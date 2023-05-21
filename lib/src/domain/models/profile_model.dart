import 'dart:io';

import 'package:intl/intl.dart';
import 'package:pet_match/src/domain/models/breed_model.dart';
import 'package:pet_match/src/domain/models/location_model.dart';

class Profile {
  String? id;
  Breed? breed;
  String? name;
  String? gender;
  double? height;
  double? weight;
  String? avatar;
  DateTime? birthday;
  Location? location;
  String? description;
  List<Breed>? interests;
  List<String>? gallery;

  Profile(
      {this.id,
      this.breed,
      this.name,
      this.gender,
      this.height,
      this.weight,
      this.birthday,
      this.location,
      this.description,
      this.interests,
      this.gallery});

  Profile.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    breed = json['breed'] != null ? Breed.fromJson(json['breed']) : null;
    name = json['name'];
    gender = json['gender'];
    avatar = json['avatar'];
    height = json['height'];
    weight = json['weight'];
    if (json[birthday] != null) {
      birthday = DateFormat("dd/MM/yyyy HH:mm:ss").parse(json['birthday']);
    }
    location =
        json['location'] != null ? Location.fromJson(json['location']) : null;
    description = json['description'];
    if (json['interests'] != null) {
      interests = <Breed>[];
      json['interests'].forEach((v) {
        interests!.add(Breed.fromJson(v));
      });
    } else {
      interests = [];
    }
    if (json['gallery'] != null) {
      gallery = List.from(json['gallery']);
    } else {
      gallery = [];
    }
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
      data['breed'] = breed!.toJson();
    }
    data['name'] = name;
    data['gender'] = gender!.toUpperCase();
    data['avatar'] = avatar;
    data['height'] = height;
    data['weight'] = weight;
    if (birthday != null) {
      data['birthday'] = DateFormat("dd/MM/yyyy HH:mm:ss").format(birthday!);
    }
    if (location != null) {
      data['location'] = location!.toJson();
    }
    data['description'] = description;
    if (interests != null) {
      data['interests'] = interests!.map((v) => v.toJson()).toList();
    }
    data['gallery'] = gallery;
    return data;
  }
}
