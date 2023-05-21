import 'package:pet_match/src/domain/models/species_model.dart';

class Breed {
  String? id;
  String? name;
  Species? species;

  Breed({this.id, this.name, this.species});

  Breed.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    species = Species.fromJson(json['species']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    if (species != null) data['species'] = species?.toJson();
    return data;
  }
}
