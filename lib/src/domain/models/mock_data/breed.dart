import 'package:pet_match/src/domain/models/breed_model.dart';
import 'package:pet_match/src/domain/models/species_model.dart';

List<Breed> breeds = [
  Breed(
      id: "f152bcf2-f36f-11ed-a05b-0242ac120003",
      name: "Chó Husky",
      species: species.elementAt(0)),
  Breed(
      id: "f152bfae-f36f-11ed-a05b-0242ac120003",
      name: "Chó Alaska",
      species: species.elementAt(0)),
  Breed(
      id: "f152c102-f36f-11ed-a05b-0242ac120003",
      name: "Chó Shiba",
      species: species.elementAt(0)),
  Breed(
      id: "f152c256-f36f-11ed-a05b-0242ac120003",
      name: "Chó Poodle",
      species: species.elementAt(0)),
  Breed(
      id: "b2a0db24-f577-11ed-a05b-0242ac120003",
      name: "Mèo ta",
      species: species.elementAt(1)),
];

List<Species> species = [
  Species(id: 'd5652886-f36f-11ed-a05b-0242ac120003', name: 'Chó'),
  Species(id: 'd5652b1a-f36f-11ed-a05b-0242ac120003', name: 'Mèo'),
  Species(id: 'd5652c64-f36f-11ed-a05b-0242ac120003', name: 'Cá'),
  Species(id: 'd5652d9a-f36f-11ed-a05b-0242ac120003', name: 'Chim'),
];
